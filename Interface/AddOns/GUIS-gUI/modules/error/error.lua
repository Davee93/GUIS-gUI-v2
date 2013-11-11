--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UIError")

-- GUIS-gUI environment
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")

local useWhiteList
local lastError, lastTime

local defaults = {
}

--
-- time in seconds between each identical error message
local HZ = 2.0

-- set a whitelist and a blacklist
-- using constants to avoid localization issues
-- http://www.wowpedia.org/WoW_Constants/Errors
local whiteList = {
	[ ERR_BAG_FULL ] = true, 								-- That bag is full.
	[ ERR_BAG_IN_BAG ] = true, 							-- Can't put non-empty bags in other bags. 
	[ ERR_BANK_FULL ] = true, 								-- Your bank is full 
	[ ERR_FISH_ESCAPED ] = true, 							-- Your fish got away! 
	[ ERR_INV_FULL ] = true,								-- Inventory is full. 
	[ ERR_ITEM_CANT_BE_DESTROYED ] = true, 				-- That item cannot be destroyed. 
	[ ERR_ITEM_MAX_COUNT ] = true,							-- You can't carry any more of those items.
	[ ERR_LOGOUT_FAILED ] = true, 							-- You can't logout now. 
	[ ERR_LOOT_WHILE_INVULNERABLE ] = true, 				-- Cannot loot while invulnerable. 
	[ ERR_MOUNT_LOOTING ] = true, 							-- You can't mount while looting! 
	[ ERR_MOUNT_SHAPESHIFTED ] = true, 					-- You can't mount while shapeshifted! 
	[ ERR_MOUNT_TOOFARAWAY ] = true, 						-- That mount is too far away!  
	[ ERR_MUST_EQUIP_ITEM ] = true, 						-- You must equip that item to use it.  
	[ ERR_MUST_REPAIR_DURABILITY ] = true, 				-- You must repair that item's durability to use it. 
	[ ERR_NO_SLOT_AVAILABLE ] = true, 						-- No equipment slot is available for that item. 
	[ ERR_NOT_ENOUGH_MONEY ] = true, 						-- You don't have enough money. 
	[ ERR_NOT_EQUIPPABLE ] = true, 						-- This item cannot be equipped. 
	[ ERR_NOT_IN_COMBAT ] = true, 							-- You can't do that while in combat 
	[ ERR_NOT_WHILE_SHAPESHIFTED ] = true, 				-- You can't do that while shapeshifted.  
	[ ERR_PASSIVE_ABILITY ] = true, 						-- You can't put a passive ability in the action bar. 
	[ ERR_PET_SPELL_DEAD ] = true, 						-- Your pet is dead. 
	[ ERR_QUEST_LOG_FULL ] = true, 						-- Your quest log is full.  
	[ ERR_TAXINOPATHS ] = true, 							-- You don't know any flight locations connected to this one. 
	[ ERR_TAXINOSUCHPATH ] = true, 						-- There is no direct path to that destination! 
	[ ERR_TAXINOTENOUGHMONEY ] = true, 					-- You don't have enough money! 
	[ ERR_TAXIPLAYERALREADYMOUNTED ] = true, 				-- You are already mounted! Dismount first. 
	[ ERR_TAXIPLAYERBUSY ] = true, 						-- You are busy and can't use the taxi service now. 
	[ ERR_TAXIPLAYERMOVING ] = true, 						-- You are moving. 
	[ ERR_TAXIPLAYERSHAPESHIFTED ] = true, 				-- You can't take a taxi while disguised! 
	[ ERR_TAXISAMENODE ] = true, 							-- You are already there! 
	[ ERR_TOOBUSYTOFOLLOW ] = true, 						-- You're too busy to follow anything! 
	[ ERR_TRADE_BAG_FULL ] = true, 						-- Trade failed, you don't have enough space. 
	[ ERR_TRADE_MAX_COUNT_EXCEEDED ] = true, 				-- You have too many of a unique item. 
	[ ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED ] = true,	 	-- Your trade partner has too many of a unique item. 
	[ ERR_TRADE_QUEST_ITEM ] = true, 						-- You can't trade a quest item.  
	[ SPELL_FAILED_NO_MOUNTS_ALLOWED ] = true, 			-- You can't mount here.
	[ SPELL_FAILED_ONLY_BATTLEGROUNDS ] = true, 			-- Can only use in battlegrounds
}

local blackList = {
	[ ERR_ABILITY_COOLDOWN ] = true, 						-- Ability is not ready yet.
	[ ERR_ATTACK_CHARMED ] = true, 						-- Can't attack while charmed. 
	[ ERR_ATTACK_CONFUSED ] = true, 						-- Can't attack while confused.
	[ ERR_ATTACK_DEAD ] = true, 							-- Can't attack while dead. 
	[ ERR_ATTACK_FLEEING ] = true, 						-- Can't attack while fleeing. 
	[ ERR_ATTACK_PACIFIED ] = true, 						-- Can't attack while pacified. 
	[ ERR_ATTACK_STUNNED ] = true, 						-- Can't attack while stunned.
	[ ERR_AUTOFOLLOW_TOO_FAR ] = true, 					-- Target is too far away.
	[ ERR_BADATTACKFACING ] = true, 						-- You are facing the wrong way!
	[ ERR_BADATTACKPOS ] = true, 							-- You are too far away!
	[ ERR_CLIENT_LOCKED_OUT ] = true, 						-- You can't do that right now.
	[ ERR_ITEM_COOLDOWN ] = true, 							-- Item is not ready yet. 
	[ ERR_OUT_OF_ENERGY ] = true, 							-- Not enough energy
	[ ERR_OUT_OF_FOCUS ] = true, 							-- Not enough focus
	[ ERR_OUT_OF_HEALTH ] = true, 							-- Not enough health
	[ ERR_OUT_OF_MANA ] = true, 							-- Not enough mana
	[ ERR_OUT_OF_RAGE ] = true, 							-- Not enough rage
	[ ERR_OUT_OF_RANGE ] = true, 							-- Out of range.
	[ ERR_SPELL_COOLDOWN ] = true, 						-- Spell is not ready yet.
	[ ERR_SPELL_FAILED_ALREADY_AT_FULL_HEALTH ] = true, 	-- You are already at full health.
	[ ERR_SPELL_OUT_OF_RANGE ] = true, 					-- Out of range.
	[ ERR_USE_TOO_FAR ] = true, 							-- You are too far away.
	[ SPELL_FAILED_CANT_DO_THAT_RIGHT_NOW ] = true, 		-- You can't do that right now.
	[ SPELL_FAILED_CASTER_AURASTATE ] = true, 				-- You can't do that yet
	[ SPELL_FAILED_CASTER_DEAD ] = true, 					-- You are dead
	[ SPELL_FAILED_CASTER_DEAD_FEMALE ] = true, 			-- You are dead
	[ SPELL_FAILED_CHARMED ] = true, 						-- Can't do that while charmed
	[ SPELL_FAILED_CONFUSED ] = true, 						-- Can't do that while confused
	[ SPELL_FAILED_FLEEING ] = true, 						-- Can't do that while fleeing
	[ SPELL_FAILED_ITEM_NOT_READY ] = true, 				-- Item is not ready yet
	[ SPELL_FAILED_NO_COMBO_POINTS ] = true, 				-- That ability requires combo points
	[ SPELL_FAILED_NOT_BEHIND ] = true, 					-- You must be behind your target.
	[ SPELL_FAILED_NOT_INFRONT ] = true, 					-- You must be in front of your target.
	[ SPELL_FAILED_OUT_OF_RANGE ] = true, 					-- Out of range
	[ SPELL_FAILED_PACIFIED ] = true, 						-- Can't use that ability while pacified
	[ SPELL_FAILED_SPELL_IN_PROGRESS ] = true, 			-- Another action is in progress
	[ SPELL_FAILED_STUNNED ] = true, 						-- Can't do that while stunned
	[ SPELL_FAILED_UNIT_NOT_INFRONT ] = true, 				-- Target needs to be in front of you.
	[ SPELL_FAILED_UNIT_NOT_BEHIND ] = true, 				-- Target needs to be behind you.
}

module.UI_ERROR_MESSAGE = function(self, error)
	if not(error) then return end
	
	local now = GetTime()
	
	if (error == lastError) and ((lastTime + HZ) > now) then
		return
	end
	
	if (useWhiteList and whiteList[error]) or ((not useWhiteList) and (not blackList[error])) then
		UIErrorsFrame:AddMessage(error, C["error"][1], C["error"][2], C["error"][3], 1.0)
	end
	
	lastError, lastTime = error, now
end

module.UI_INFO_MESSAGE = function(self, error)
	if not(error) then return end
	
	UIErrorsFrame:AddMessage(error, C["value"][1], C["value"][2], C["value"][3], 1.0)
end

module.RestoreDefaults = function(self)
	GUIS_DB["error"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["error"] = GUIS_DB["error"] or {}
	GUIS_DB["error"] = ValidateTable(GUIS_DB["error"], defaults)
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill() 
		return 
	end
end

module.OnEnable = function(self)	
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	UIErrorsFrame:UnregisterEvent("UI_INFO_MESSAGE")
	UIErrorsFrame:SetFontObject(GUIS_SystemFontLarge)

	self:RegisterEvent("UI_ERROR_MESSAGE")
	self:RegisterEvent("UI_INFO_MESSAGE")
end
