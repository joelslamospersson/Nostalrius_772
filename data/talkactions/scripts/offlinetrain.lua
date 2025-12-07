function onSay(player, words, param)
	if not player:isPremium() then
		player:sendCancelMessage("You need a premium account to use offline training.")
		return false
	end

	if param == "" then
		local currentSkill = player:getOfflineTrainingSkill()
		local skillText = "None"
		if currentSkill == SKILL_SWORD then
			skillText = "Sword Fighting"
		elseif currentSkill == SKILL_AXE then
			skillText = "Axe Fighting"
		elseif currentSkill == SKILL_CLUB then
			skillText = "Club Fighting"
		elseif currentSkill == SKILL_DISTANCE then
			skillText = "Distance Fighting"
		elseif currentSkill == SKILL_MAGLEVEL then
			skillText = "Magic Level"
		end
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Current offline training skill: " .. skillText .. ". Available time: " .. math.floor(player:getOfflineTrainingTime() / 1000 / 60) .. " minutes.")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /offlinetrain <number or skill name>")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Available: 1/sword, 2/axe, 3/club, 4/distance, 5/magic")
		return false
	end

	local skill = nil
	local skillNames = {
		[SKILL_SWORD] = "Sword Fighting",
		[SKILL_AXE] = "Axe Fighting",
		[SKILL_CLUB] = "Club Fighting",
		[SKILL_DISTANCE] = "Distance Fighting",
		[SKILL_MAGLEVEL] = "Magic Level"
	}

	-- Check if it's a number (1-5)
	local num = tonumber(param)
	if num then
		if num == 1 then
			skill = SKILL_SWORD
		elseif num == 2 then
			skill = SKILL_AXE
		elseif num == 3 then
			skill = SKILL_CLUB
		elseif num == 4 then
			skill = SKILL_DISTANCE
		elseif num == 5 then
			skill = SKILL_MAGLEVEL
		end
	end

	-- If not a number, check skill names
	if not skill then
		local skillMap = {
			["sword"] = SKILL_SWORD,
			["axe"] = SKILL_AXE,
			["club"] = SKILL_CLUB,
			["distance"] = SKILL_DISTANCE,
			["dist"] = SKILL_DISTANCE,
			["magic"] = SKILL_MAGLEVEL,
			["mag"] = SKILL_MAGLEVEL,
			["ml"] = SKILL_MAGLEVEL
		}
		skill = skillMap[string.lower(param)]
	end

	if not skill then
		player:sendCancelMessage("Invalid skill. Use: 1/sword, 2/axe, 3/club, 4/distance, 5/magic")
		return false
	end

	player:setOfflineTrainingSkill(skill)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Offline training skill set to: " .. (skillNames[skill] or "Unknown") .. ". Click the bed again to start training.")
	return false
end

