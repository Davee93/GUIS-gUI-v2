--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ChatFilters")

-- Lua API
local ipairs, pairs, unpack = ipairs, pairs, unpack
local strfind, gsub, strmatch = string.find, string.gsub, string.match

-- WoW API
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter
local GetMinimapZoneText = GetMinimapZoneText
local SetCVar = SetCVar

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) module:UnregisterCallback(...) end

local dirtyTalk
local noYellSpam, noTradeSpam, noWeirdGroupSpam
local learnFilter, sleepFilter, sleepFilterCheck

-- goldspam in /yell
local gold = "gold"
local goldSpam = { "%$", "www", "%.com", "%.net", "%.org" }
local specialGoldSpam = { "%,còm", "%,cóm" }

-- other /yell spam
-- 	*feel free to email me any other offensive or dead annoying crap that 
-- 	are spammed by people on a regular basis, and I'll add it to the list if it's fitting
local yellSpam = { "anal", "cunt", "rape", "dirge", "murloc", "{rt%d}", "{star}", "{circle}", "{diamond}", "{triangle}", "{moon}", "{square}", "{cross}" }

-- always enable profanity. stupid filter. 
dirtyTalk = function()
	SetCVar("profanityFilter", 0)
end

----------------------------------------------------------------------------------
-- Chat filters
----------------------------------------------------------------------------------
noWeirdGroupSpam = function(self, event, msg)
	if (strfind(msg, (ERR_TARGET_NOT_IN_GROUP_S:gsub("%%s", "(.+)")))) then
		return true
	end
end

noTradeSpam = function(selv, event, msg, ...)
	-- check for gold spammers
	-- we do this by checking for URLs combined with 'gold'
	if (strmatch(msg:lower(), gold)) then
		for _, word in ipairs(goldSpam) do
			if (strmatch(msg:lower(), word)) then
				return true
			end
		end
	end
	for _, word in ipairs(specialGoldSpam) do
		if (strmatch(msg:lower(), word)) then
			return true
		end
	end

	-- check for retarded spam by people dragging 
	-- the average IQ of the entire human race down
	for _, word in ipairs(yellSpam) do
		if (strmatch(msg:lower(), word)) then
			return true
		end
	end	
end

noYellSpam = function(self, event, msg, ...)
	-- check for gold spammers
	-- we do this by checking for URLs combined with 'gold'
	if (strmatch(msg:lower(), gold)) then
		for _, word in ipairs(goldSpam) do
			if (strmatch(msg:lower(), word)) then
				return true
			end
		end
	end
	
	-- check for retarded spam by people dragging 
	-- the average IQ of the entire human race down
	for _, word in ipairs(yellSpam) do
		if (strmatch(msg:lower(), word)) then
			return true
		end
	end
end

-- TODO: create searches based on WoWs localized global strings for these functions
learnFilter = function(self, event, arg)
    if strfind(arg, "You have unlearned") or strfind(arg, "You have learned a new spell:") or strfind(arg, "You have learned a new ability:") or strfind(arg, "Your pet has unlearned") then
        return true
    end
end

sleepFilter = function(self, event, arg1)
    if strfind(arg1, "falls asleep. Zzzzzzz.") then
		return true
    end
end

-- http://www.wowpedia.org/API_SetMapByID
local city = {
	[301] = true; -- Stormwind City
	[321] = true; -- Orgrimmar
	[341] = true; -- Ironforge
	[362] = true; -- Thunder Bluff
	[381] = true; -- Darnassus
	[382] = true; -- Undercity
	[471] = true; -- The Exodar
	[480] = true; -- Silvermoon City
	[481] = true; -- Shattrath City
	[504] = true; -- Dalaran
	[684] = true; -- Gilneas
}

-- enable sleep filter only in cities
sleepFilterCheck = function()
	SetMapToCurrentZone()
	if (city[(GetCurrentMapAreaID())]) then 
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", sleepFilter)
	else
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_TEXT_EMOTE", sleepFilter)
	end
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Chat")) then 
		self:Kill() 
		return 
	end

	-- activate learning spam filter (when changing spec)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", learnFilter)
	
	-- sometimes when leaving raidgroups, we're flooded with "is not in your party"-messages
	-- since we're not actually getting any errors, just system messages, we simply hide the spam. For now.
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", noWeirdGroupSpam)

	-- clean up the /yell and trade channel a bit
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", noTradeSpam)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", noYellSpam)

	-- check whether to activate sleep spam filter or not
	RegisterCallback("PLAYER_ENTERING_WORLD", sleepFilterCheck)
	RegisterCallback("ZONE_CHANGED_INDOORS", sleepFilterCheck)
	RegisterCallback("ZONE_CHANGED_NEW_AREA", sleepFilterCheck)
	
	-- keep profanity visible 
	-- *EDIT: no longer needed, but still keeping it for easy configuration purposes
	RegisterCallback("CVAR_UPDATE", dirtyTalk)
	RegisterCallback("PLAYER_ENTERING_WORLD", dirtyTalk)
end
