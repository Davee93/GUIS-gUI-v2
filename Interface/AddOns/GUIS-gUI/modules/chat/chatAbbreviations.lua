--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ChatAbbreviations")

-- Lua API
local _G = _G
local ipairs, pairs, unpack = ipairs, pairs, unpack
local strfind, strmatch = string.find, string.match

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local noMik = not IsAddOnLoaded("MikScrollingBattleText")

local Store, RestoreChannels, RestoreStrings, AbbreviateStrings, AbbreviateChannels
local oldStrings, oldChannels

local originals, original_channels = {}, {}
local channels = {
	CHAT_GUILD_GET 										= "|Hchannel:Guild|h" .. "[" .. L["G"] .. "]" .. "|h %s:\32";
	CHAT_OFFICER_GET 										= "|Hchannel:o|h" .. "[" .. L["O"] .. "]" .. "|h %s:\32";
	CHAT_BATTLEGROUND_GET 								= "|Hchannel:Battleground|h" .. "[" .. L["BG"] .. "]" .. "|h %s:\32";
	CHAT_BATTLEGROUND_LEADER_GET 						= "|Hchannel:Battleground|h" .. "[" .. L["BGL"] .. "]" .. "|h %s:\32";
	CHAT_PARTY_GET 										= "|Hchannel:party|h" .. "[" .. L["P"] .. "]" .. "|h %s:\32";
	CHAT_PARTY_GUIDE_GET 								= "|Hchannel:party|h" .. "[" .. L["DG"] .. "]" .. "|h %s:\32";
	CHAT_PARTY_LEADER_GET 								= "|Hchannel:party|h" .. "[" .. L["PL"] .. "]" .. "|h %s:\32";
	CHAT_RAID_GET 											= "|Hchannel:raid|h" .. "[" .. L["R"] .. "]" .. "|h %s:\32";
	CHAT_RAID_LEADER_GET 								= "|Hchannel:raid|h" .. "[" .. L["RL"] .. "]" .. "|h %s:\32";
	CHAT_RAID_WARNING_GET 								= "[" .. L["RW"] .. "]" .. " %s:\32";
	CHAT_MONSTER_PARTY_GET 								= "|Hchannel:Party|h" .. "[" .. L["P"] .. "]" .. "|h %s:\32";
}

local globals = {
	CHAT_FLAG_AFK 											= "[" .. AFK .. "]" .. "\32";
	CHAT_FLAG_DND 											= "[" .. DND .. "]" .. "\32";
	CHAT_FLAG_GM 											= "[" .. L["GM"] .. "]" .. "\32";
	CHAT_AFK_GET 											= "%s [" .. AFK .. "]:\32";
	CLEARED_AFK 											= "-[" .. AFK .. "]";
	CLEARED_DND 											= "-[" .. DND .. "]";
	MARKED_AFK 												= "+[" .. AFK .. "]";
	MARKED_AFK_MESSAGE 									= "+[" .. AFK .. "]: %s";
	MARKED_DND 												= "+[" .. DND .. "]: %s";
	CHAT_CHANNEL_JOIN_GET 								= "+%s";
	CHAT_CHANNEL_LEAVE_GET 								= "-%s";
	CHAT_YOU_CHANGED_NOTICE 							= "#|Hchannel:%d|h" .. "[" .. "%s" .. "]" .. "|h";
	CHAT_YOU_JOINED_NOTICE 								= "+|Hchannel:%d|h" .. "[" .. "%s" .. "]" .. "|h";
	CHAT_YOU_LEFT_NOTICE 								= "-|Hchannel:%d|h" .. "[" .. "%s" .. "]" .. "|h";
	ERR_FRIEND_OFFLINE_S 								= "-%s";
	ERR_FRIEND_ONLINE_SS 								= "+|Hplayer:%s|h" .. "[" .. "%s" .. "]" .. "|h";
	CHAT_SAY_GET 											= "%s:\32";
	CHAT_WHISPER_GET 										= "%s:\32";
	CHAT_WHISPER_INFORM_GET 							= "|cFFAD2424@|r%s:\32";
	CHAT_YELL_GET 											= "%s:\32";
	CHAT_BN_WHISPER_GET 									= "%s:\32";
	CHAT_BN_WHISPER_INFORM_GET 						= "|cFFAD2424@|r%s:\32";
	CHAT_BN_WHISPER_SEND 								= "%s:\32";
	CHAT_BN_CONVERSATION_GET 							= "%s:\32";
	CHAT_BN_CONVERSATION_GET_LINK 					= "|Hchannel:BN_CONVERSATION:%d|h" .. "[" .. "%s" .. "]" .. "|h";
	CHAT_BN_CONVERSATION_SEND 							= "[" .. "%d" .. "]" .. ":";
	
	GAIN_EXPERIENCE 										= "+|cffffffff%d|r" .. L["XP"];

	-- CHAT_MONSTER_SAY_GET caused taint...?
	CHAT_MONSTER_SAY_GET 								= "%s:\32";
	CHAT_MONSTER_WHISPER_GET 							= "%s:\32";
	CHAT_MONSTER_YELL_GET 								= "%s:\32";

	ACHIEVEMENT_BROADCAST 								= "%s! %s!";
	ACHIEVEMENT_BROADCAST_SELF 						= "%s!";
	PLAYER_SERVER_FIRST_ACHIEVEMENT 					= "|Hplayer:%s|h" .. "[" .. "%s" .. "]" .. "|h! $a!";
	SERVER_FIRST_ACHIEVEMENT 							= "%s! $a!";
	GUILD_ACHIEVEMENT_BROADCAST 						= "\"%s\"! $a!";
	COMBATLOG_GUILD_XPGAIN 								= "+%d " .. L["Guild XP"];
	COMBATLOG_HONORAWARD 								= "+%.2f " .. COMBAT_HONOR_GAIN;
	COMBATLOG_HONORGAIN 									= "%s, " .. L["HK"] .. ": %s +%.2f " .. COMBAT_HONOR_GAIN;
	COMBATLOG_HONORGAIN_NO_RANK 						= "%s, +%.2f " .. COMBAT_HONOR_GAIN;

	LOOT_ITEM 												= "%s: +%s";
	LOOT_ITEM_MULTIPLE 									= "%s: +%sx%d";
	LOOT_ITEM_CREATED_SELF 								= "+%s";
	LOOT_ITEM_CREATED_SELF_MULTIPLE 					= "+%sx%d";

	-- adding this as a hotfix to allow display of your loot in MSBT
	-- will hopefully find a better solution later
	LOOT_ITEM_PUSHED_SELF 								= noMik and "+%s" or nil;
	LOOT_ITEM_PUSHED_SELF_MULTIPLE 					= noMik and "+%sx%d" or nil;
	LOOT_ITEM_SELF 										= noMik and "+%s" or nil;
	LOOT_ITEM_SELF_MULTIPLE 							= noMik and "+%sx%d" or nil;

	YOU_RECEIVED 											= "+";
	YOU_LOOT_MONEY 										= "+%s";
	LOOT_MONEY 												= "%s: +%s";
	LOOT_MONEY_SPLIT 										= "+%s";
	LOOT_MONEY_SPLIT_GUILD 								= "+%s (+%s " .. GUILD_BANK .. ")";
	LOOT_ROLL_YOU_WON 									= "> %s!";
	LOOT_ROLL_WON 											= "%s > %s!";
	ERR_QUEST_REWARD_EXP_I 								= "+%d " .. L["XP"];
	ERR_QUEST_REWARD_ITEM_MULT_IS 					= "+%dx%s";
	ERR_QUEST_REWARD_ITEM_S 							= "+%s";
	ERR_QUEST_REWARD_MONEY_S 							= "+%s";
	CURRENCY_GAINED 										= "+%s";
	CURRENCY_GAINED_MULTIPLE 							= "+%sx%d";
	COMBATLOG_XPGAIN_EXHAUSTION1 						= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s)";
	COMBATLOG_XPGAIN_EXHAUSTION1_GROUP 				= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s, +%d)";
	COMBATLOG_XPGAIN_EXHAUSTION1_RAID 				= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s, -%d)";
	COMBATLOG_XPGAIN_EXHAUSTION2 						= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s)";
	COMBATLOG_XPGAIN_EXHAUSTION2_GROUP 				= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s, +%d)";
	COMBATLOG_XPGAIN_EXHAUSTION2_RAID 				= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s, -%d)";
	COMBATLOG_XPGAIN_EXHAUSTION4 						= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s)";
	COMBATLOG_XPGAIN_EXHAUSTION4_GROUP 				= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s, +%d)";
	COMBATLOG_XPGAIN_EXHAUSTION4_RAID 				= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s, -%d)";
	COMBATLOG_XPGAIN_EXHAUSTION5 						= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s)";
	COMBATLOG_XPGAIN_EXHAUSTION5_GROUP 				= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s, +%d)";
	COMBATLOG_XPGAIN_EXHAUSTION5_RAID 				= "%s: +%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s, -%d)";
	COMBATLOG_XPGAIN_FIRSTPERSON 						= "%s: +%d " .. L["XP"];
	COMBATLOG_XPGAIN_FIRSTPERSON_GROUP 				= "%s: +%d " .. L["XP"] .. " (%d)";
	COMBATLOG_XPGAIN_FIRSTPERSON_RAID 				= "%s: +%d " .. L["XP"] .. " (%d)";
	COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED 			= "+%d " .. L["XP"];
	COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_GROUP 	= "+%d " .. L["XP"] .. " (%d)";
	COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_RAID 	= "+%d " .. L["XP"] .. " (%d)";
	COMBATLOG_XPGAIN_QUEST 								= "+%d " .. L["XP"] .. " (%s " .. L["XP"] .. " %s)";
	COMBATLOG_XPLOSS_FIRSTPERSON_UNNAMED 			= "-%d " .. L["XP"];
	FACTION_STANDING_DECREASED 						= "%s: -%d " .. COMBAT_FACTION_CHANGE;
	FACTION_STANDING_INCREASED 						= "%s: +%d " .. COMBAT_FACTION_CHANGE;
	FACTION_STANDING_INCREASED_BONUS 				= "%s: +%d " .. COMBAT_FACTION_CHANGE .. " (+%.1f)";
	ERR_SKILL_UP_SI 										= "%s: %d";
}

local stored
Store = function()
	if (stored) then
		return
	end

	for i,v in pairs(globals) do
		if (v) then
			originals[i] = _G[i]
		end
	end
	
	for i,v in pairs(channels) do
		if (v) then
			original_channels[i] = _G[i]
		end
	end

	stored = true
end

AbbreviateChannels = function()
	if not(stored) then
		Store()
	end
	
	for i,v in pairs(channels) do
		if (v) then
			_G[i] = v
		end
	end
end

AbbreviateStrings = function()
	if not(stored) then
		Store()
	end
	
	for i,v in pairs(globals) do
		if (v) then
			_G[i] = v
		end
	end
end

RestoreChannels = function()
	if not(stored) then
		return
	end
	
	for i,v in pairs(original_channels) do
		if (v) then
			_G[i] = v
		end
	end
end

RestoreStrings = function()
	if not(stored) then
		return
	end
	
	for i,v in pairs(originals) do
		if (v) then
			_G[i] = v
		end
	end
end

module.UpdateAll = function(self, force) 
	if (force) or (oldChannels ~= GUIS_DB["chat"].abbreviateChannels) then
		if (GUIS_DB["chat"].abbreviateChannels) then
			AbbreviateChannels()
		else
			RestoreChannels()
		end
		oldChannels = GUIS_DB["chat"].abbreviateChannels
	end

	if (force) or (oldStrings ~= GUIS_DB["chat"].abbreviateStrings) then
		if (GUIS_DB["chat"].abbreviateStrings) then
			AbbreviateStrings()
		else
			RestoreStrings()
		end
		oldStrings = GUIS_DB["chat"].abbreviateStrings
	end
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Chat")) then 
		self:Kill() 
		return 
	end
	
	self:UpdateAll(true)
end

