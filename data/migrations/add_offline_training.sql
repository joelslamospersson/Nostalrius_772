-- Migration script to add offline training fields to players table
-- Run this script on your database to add the required columns

ALTER TABLE `players` ADD COLUMN `offlinetraining_time` SMALLINT UNSIGNED NOT NULL DEFAULT 43200;
ALTER TABLE `players` ADD COLUMN `offlinetraining_skill` INT NOT NULL DEFAULT -1;

