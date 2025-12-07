function onLogin(player)
	-- DEBUG MODE: Set to true for testing (1 minute threshold, 20x skill gains)
	local DEBUG_MODE = false
	
	local lastLogout = player:getLastLogout()
	local offlineTime = lastLogout ~= 0 and math.min(os.time() - lastLogout, 86400 * 21) or 0
	local offlineTrainingSkill = player:getOfflineTrainingSkill()
	
	-- Minimum offline time threshold (1 minute for debug, 10 minutes for production)
	local MIN_OFFLINE_TIME = DEBUG_MODE and 60 or 600
	
	-- Debug output
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "DEBUG: Skill=" .. offlineTrainingSkill .. ", OfflineTime=" .. offlineTime .. ", LastLogout=" .. lastLogout .. ", DebugMode=" .. tostring(DEBUG_MODE))
	
	if offlineTrainingSkill == -1 then
		player:addOfflineTrainingTime(offlineTime * 1000)
		return true
	end

	-- Check if player was offline long enough
	-- Do this BEFORE resetting the skill, so we can use the skill value for training
	if offlineTime < MIN_OFFLINE_TIME then
		-- Not enough time offline, reset skill and show message
		player:setOfflineTrainingSkill(-1)
		player:save()
		local requiredMinutes = math.ceil(MIN_OFFLINE_TIME / 60)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("You must be logged out for more than %d minute%s to start offline training.", requiredMinutes, requiredMinutes > 1 and "s" or ""))
		return true
	end
	
	-- Store the skill value before resetting (we need it for training calculation)
	local trainingSkill = offlineTrainingSkill
	
	-- Reset skill to -1 (no training selected) after checking time
	-- This ensures that if player logs out and logs back in without sleeping, training won't be active
	player:setOfflineTrainingSkill(-1)
	
	-- Save the player data to persist the skill reset
	-- This ensures the skill is -1 when the player logs in again without sleeping
	player:save()

	local trainingTime = math.max(0, math.min(offlineTime, math.min(43200, player:getOfflineTrainingTime() / 1000)))
	player:removeOfflineTrainingTime(trainingTime * 1000)

	local remainder = offlineTime - trainingTime
	if remainder > 0 then
		player:addOfflineTrainingTime(remainder * 1000)
	end

	if trainingTime < 60 then
		return true
	end

	-- Store skill levels before training
	local skillLevelBefore = 0
	local shieldLevelBefore = player:getSkillLevel(SKILL_SHIELD)
	local skillPercentBefore = 0
	local shieldPercentBefore = player:getSkillPercent(SKILL_SHIELD) or 0
	
	if trainingSkill == SKILL_MAGLEVEL then
		skillLevelBefore = player:getMagicLevel()
		-- Try to get magic level percent - if method doesn't exist (server not recompiled), use 0
		local success, mlPercent = pcall(function() return player:getMagicLevelPercent() end)
		if success and mlPercent ~= nil then
			skillPercentBefore = mlPercent
		else
			skillPercentBefore = 0
		end
	else
		skillLevelBefore = player:getSkillLevel(trainingSkill)
		local skillPercent = player:getSkillPercent(trainingSkill)
		skillPercentBefore = (skillPercent ~= nil) and skillPercent or 0
	end

	local vocation = player:getVocation()
	local promotion = vocation:getPromotion()
	local topVocation = not promotion and vocation or promotion

	local updateSkills = false
	if table.contains({SKILL_CLUB, SKILL_SWORD, SKILL_AXE, SKILL_DISTANCE}, trainingSkill) then
		local modifier = topVocation:getAttackSpeed() / 1000
		local skillTries = (trainingTime / modifier) / (trainingSkill == SKILL_DISTANCE and 4 or 2)
		
		-- DEBUG MODE: Multiply skill gains by 20x
		if DEBUG_MODE then
			skillTries = skillTries * 20
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("DEBUG: Skill tries multiplied by 20x: %.2f", skillTries))
		end
		
		updateSkills = player:addOfflineTrainingTries(trainingSkill, math.floor(skillTries))
	elseif trainingSkill == SKILL_MAGLEVEL then
		-- Magic level training calculation
		-- Formula matches forgottenserver-master: trainingTime * (manaGainAmount / (gainTicks * 2))
		local gainTicks = topVocation:getManaGainTicks()
		if gainTicks == 0 or gainTicks == nil then
			gainTicks = 3 -- Default: 3 seconds per tick
		end
		gainTicks = gainTicks * 2
		
		local manaGainAmount = vocation:getManaGainAmount()
		if manaGainAmount == 0 or manaGainAmount == nil then
			-- Fallback: use a default mana gain if vocation doesn't have it configured
			-- This is typically 5-10 mana per tick depending on vocation
			manaGainAmount = 5
		end
		
		-- Calculate magic level tries: trainingTime * (manaGainAmount / gainTicks)
		-- This simulates how much mana would be gained over the training time
		-- Note: gainTicks is already multiplied by 2 above
		local magicTries = trainingTime * (manaGainAmount / gainTicks)
		
		-- DEBUG MODE: Multiply magic level gains by 20x
		if DEBUG_MODE then
			magicTries = magicTries * 20
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("DEBUG Magic: gainTicks=%d, manaGain=%d, trainingTime=%d, tries=%.2f (20x multiplier applied)", gainTicks, manaGainAmount, trainingTime, magicTries))
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("DEBUG Magic: gainTicks=%d, manaGain=%d, trainingTime=%d, tries=%.2f", gainTicks, manaGainAmount, trainingTime, magicTries))
		end
		
		if magicTries > 0 then
			local triesToAdd = math.floor(magicTries)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("DEBUG: Adding %d magic level tries", triesToAdd))
			updateSkills = player:addOfflineTrainingTries(SKILL_MAGLEVEL, triesToAdd)
			if not updateSkills then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "DEBUG: addOfflineTrainingTries returned false - check if player can gain magic level")
			end
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Warning: Magic level training calculated 0 tries. Check vocation configuration.")
		end
	end

	if updateSkills then
		local shieldTries = trainingTime / 4
		
		-- DEBUG MODE: Multiply shield gains by 20x
		if DEBUG_MODE then
			shieldTries = shieldTries * 20
		end
		
		player:addOfflineTrainingTries(SKILL_SHIELD, math.floor(shieldTries))
	end

	-- Get skill levels after training
	local skillLevelAfter = 0
	local shieldLevelAfter = player:getSkillLevel(SKILL_SHIELD)
	local skillPercentAfter = 0
	local shieldPercentAfter = player:getSkillPercent(SKILL_SHIELD) or 0
	
	if trainingSkill == SKILL_MAGLEVEL then
		skillLevelAfter = player:getMagicLevel()
		-- Try to get magic level percent - if method doesn't exist (server not recompiled), use 0
		local success, mlPercent = pcall(function() return player:getMagicLevelPercent() end)
		if success and mlPercent ~= nil then
			skillPercentAfter = mlPercent
		else
			skillPercentAfter = 0
		end
	else
		skillLevelAfter = player:getSkillLevel(trainingSkill)
		local skillPercent = player:getSkillPercent(trainingSkill)
		skillPercentAfter = (skillPercent ~= nil) and skillPercent or 0
	end

	-- Build training message
	local text = "During your absence you trained for"
	local hours = math.floor(trainingTime / 3600)
	if hours > 1 then
		text = string.format("%s %d hours", text, hours)
	elseif hours == 1 then
		text = string.format("%s 1 hour", text)
	end

	local minutes = math.floor((trainingTime % 3600) / 60)
	if minutes ~= 0 then
		if hours ~= 0 then
			text = string.format("%s and", text)
		end

		if minutes > 1 then
			text = string.format("%s %d minutes", text, minutes)
		else
			text = string.format("%s 1 minute", text)
		end
	end

	text = string.format("%s.", text)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, text)

	-- Display skill gains (always show if training occurred)
	local skillNames = {
		[SKILL_SWORD] = "Sword Fighting",
		[SKILL_AXE] = "Axe Fighting",
		[SKILL_CLUB] = "Club Fighting",
		[SKILL_DISTANCE] = "Distance Fighting",
		[SKILL_MAGLEVEL] = "Magic Level"
	}
	
	local skillName = skillNames[trainingSkill] or "Unknown"
	
	-- Calculate skill level gains
	local skillLevelGain = skillLevelAfter - skillLevelBefore
	local shieldLevelGain = shieldLevelAfter - shieldLevelBefore
	local skillPercentGain = skillPercentAfter - skillPercentBefore
	local shieldPercentGain = shieldPercentAfter - shieldPercentBefore
	
	-- Build the skill gains message
	local gainsText = ""
	
	-- Main skill gains
	if skillLevelGain > 0 then
		gainsText = string.format("%s: +%d level%s", skillName, skillLevelGain, skillLevelGain > 1 and "s" or "")
		if skillPercentAfter > 0 then
			gainsText = string.format("%s (%d%%)", gainsText, skillPercentAfter)
		end
	elseif skillPercentGain > 0 or skillPercentAfter > skillPercentBefore then
		-- Show percentage progress
		gainsText = string.format("%s: %d%% (+%d%%)", skillName, skillPercentAfter, skillPercentGain)
	elseif skillLevelAfter == skillLevelBefore and skillPercentAfter == skillPercentBefore then
		-- No visible progress, but training occurred
		gainsText = string.format("%s: %d%% (no visible progress)", skillName, skillPercentAfter)
	else
		-- Fallback: just show current level and percent
		gainsText = string.format("%s: Level %d (%d%%)", skillName, skillLevelAfter, skillPercentAfter)
	end
	
	-- Add shielding gains
	if shieldLevelGain > 0 then
		if gainsText ~= "" then
			gainsText = gainsText .. ", "
		end
		gainsText = string.format("%sShielding: +%d level%s", gainsText, shieldLevelGain, shieldLevelGain > 1 and "s" or "")
		if shieldPercentAfter > 0 then
			gainsText = string.format("%s (%d%%)", gainsText, shieldPercentAfter)
		end
	elseif shieldPercentGain > 0 or shieldPercentAfter > shieldPercentBefore then
		if gainsText ~= "" then
			gainsText = gainsText .. ", "
		end
		gainsText = string.format("%sShielding: %d%% (+%d%%)", gainsText, shieldPercentAfter, shieldPercentGain)
	elseif updateSkills then
		-- Shielding was trained but no visible progress
		if gainsText ~= "" then
			gainsText = gainsText .. ", "
		end
		gainsText = string.format("%sShielding: %d%%", gainsText, shieldPercentAfter)
	end
	
	-- Always show gains message if training occurred
	-- If updateSkills is true, training was applied, so always show something
	if updateSkills then
		if gainsText == "" then
			-- Training was applied but no visible change - show current status
			gainsText = string.format("%s: Level %d (%d%%)", skillName, skillLevelAfter, skillPercentAfter)
			if shieldLevelAfter > 0 or shieldPercentAfter > 0 then
				gainsText = string.format("%s, Shielding: Level %d (%d%%)", gainsText, shieldLevelAfter, shieldPercentAfter)
			end
		end
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, gainsText)
	else
		-- Training wasn't applied - show why
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Training applied but no skill gains detected. %s: Level %d (%d%%)", skillName, skillLevelAfter, skillPercentAfter))
	end

	return true
end

