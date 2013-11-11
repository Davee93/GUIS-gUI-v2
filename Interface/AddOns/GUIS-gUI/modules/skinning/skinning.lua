--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinning")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- WoW API
local IsAddOnLoaded = IsAddOnLoaded

-- GUIS API
local M = LibStub("gMedia-3.0")
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local addonsToSkin = {}

local defaults = {
	-- default skinning modules
	["GUIS-gUI: UISkinningAchievement"] = true;
	["GUIS-gUI: UISkinningAchievementPopup"] = true;
	["GUIS-gUI: UISkinningArcheology"] = true;
	["GUIS-gUI: UISkinningAuctionHouse"] = true;
	["GUIS-gUI: UISkinningAutoComplete"] = true;
	["GUIS-gUI: UISkinningBarberShop"] = true;
	["GUIS-gUI: UISkinningBGScore"] = true;
	["GUIS-gUI: UISkinningBlizzardHelp"] = true;
	["GUIS-gUI: UISkinningBlizzardOptionsMenu"] = true;
	["GUIS-gUI: UISkinningCalendar"] = true;
	["GUIS-gUI: UISkinningCharacter"] = true;
	["GUIS-gUI: UISkinningChat"] = true;
	["GUIS-gUI: UISkinningColorPicker"] = true;
	["GUIS-gUI: UISkinningDebugTools"] = true;
	["GUIS-gUI: UISkinningDressingRoom"] = true;
	["GUIS-gUI: UISkinningDungeonFinder"] = true;
	["GUIS-gUI: UISkinningDungeonJournal"] = true;
	["GUIS-gUI: UISkinningFriends"] = true;
	["GUIS-gUI: UISkinningGameMenu"] = true;
	["GUIS-gUI: UISkinningGhostFrame"] = true;
	["GUIS-gUI: UISkinningGuild"] = true;
	["GUIS-gUI: UISkinningGuildBank"] = true;
	["GUIS-gUI: UISkinningGuildControl"] = true;
	["GUIS-gUI: UISkinningGuildFinder"] = true;
	["GUIS-gUI: UISkinningGuildInvite"] = true;
	["GUIS-gUI: UISkinningGuildRegistrar"] = true;
	["GUIS-gUI: UISkinningGlyph"] = true;
	["GUIS-gUI: UISkinningGossip"] = true;
	["GUIS-gUI: UISkinningGreeting"] = true;
	["GUIS-gUI: UISkinningInspect"] = true;
	["GUIS-gUI: UISkinningItemText"] = true;
	["GUIS-gUI: UISkinningKeyBinding"] = true;
	["GUIS-gUI: UISkinningLoot"] = true;
	["GUIS-gUI: UISkinningMacro"] = true;
	["GUIS-gUI: UISkinningMail"] = true;
	["GUIS-gUI: UISkinningMerchant"] = true;
	["GUIS-gUI: UISkinningMovePad"] = true;
	["GUIS-gUI: UISkinningOpacityFrame"] = true;
	["GUIS-gUI: UISkinningPetition"] = true;
	["GUIS-gUI: UISkinningPvP"] = true;
	["GUIS-gUI: UISkinningQuest"] = true;
	["GUIS-gUI: UISkinningQuestLog"] = true;
	["GUIS-gUI: UISkinningRaid"] = true;
	["GUIS-gUI: UISkinningRaidBrowser"] = true;
	["GUIS-gUI: UISkinningRaidFinder"] = true;
	["GUIS-gUI: UISkinningReadyCheck"] = true;
	["GUIS-gUI: UISkinningReforge"] = true;
	["GUIS-gUI: UISkinningRollPoll"] = true;
	["GUIS-gUI: UISkinningSocket"] = true;
	["GUIS-gUI: UISkinningSpellbook"] = true;
	["GUIS-gUI: UISkinningStackSplit"] = true;
	["GUIS-gUI: UISkinningStaticPopUps"] = true;
	["GUIS-gUI: UISkinningTabard"] = true;
	["GUIS-gUI: UISkinningTalents"] = true;
	["GUIS-gUI: UISkinningTaxi"] = true;
	["GUIS-gUI: UISkinningTicketStatus"] = true;
	["GUIS-gUI: UISkinningTimeManager"] = true;
	["GUIS-gUI: UISkinningTrade"] = true;
	["GUIS-gUI: UISkinningTradeSkill"] = true;
	["GUIS-gUI: UISkinningTransmogrification"] = true;
	["GUIS-gUI: UISkinningTrainer"] = true;
	["GUIS-gUI: UISkinningTutorial"] = true;
	["GUIS-gUI: UISkinningVoidStorage"] = true;
	["GUIS-gUI: UISkinningWatchFrame"] = true;
	["GUIS-gUI: UISkinningWorldMap"] = true;
	["GUIS-gUI: UISkinningZoneMap"] = true;
	
	-- module settings
	-- zonemap
	zoneMap = {
		pos = { "CENTER", "UIParent", "CENTER", 0, 0 };
	};
}

F.SkinAddOn = function(addon, func)
	if not(addon) or not(func) then
		return
	end

	if (IsAddOnLoaded(addon)) then
		func()
	else
		addonsToSkin[addon] = func
	end
end

module.RestoreDefaults = function(self)
	GUIS_DB["skinning"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["skinning"] = GUIS_DB["skinning"] or {}
	GUIS_DB["skinning"] = ValidateTable(GUIS_DB["skinning"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill() 
		return 
	end

	local AddOnSkinner = function(self, event, addon)
		if not(addon) or not(addonsToSkin[addon]) then
			return
		end
		
		addonsToSkin[addon]()
		
		-- remove the entry, don't call it again
		addonsToSkin[addon] = nil
	end
	RegisterCallback("ADDON_LOADED", AddOnSkinner)
	
end
