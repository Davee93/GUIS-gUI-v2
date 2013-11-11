--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ChatIcons")

-- Lua API
local strfind, gsub, strmatch = string.find, string.gsub, string.match
local strlen, strsub = string.len, string.sub

-- WoW API
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local E = LibStub("gDB-1.0"):NewDataBase("GUIS-gUI: Emoticons")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) module:UnregisterCallback(...) end

local emoticonFilter, symbolFilter

--
-- have to insert them in a specific order, or emoticons won't be detected correctly.
-- 	e.g. :( will be detected, but not >:(
--
--		* simple rule; the most advanced first, the simple ones at the end

-- these need to come first
tinsert(E, { "O:%-%)", M["Icon"]["Emoticon-Angel"]})
tinsert(E, { "O:%)", M["Icon"]["Emoticon-Angel"]})
tinsert(E, { "3:%)", M["Icon"]["Emoticon-Devil"]})
tinsert(E, { "3:%-%)", M["Icon"]["Emoticon-Devil"]})
tinsert(E, { ">:%(", M["Icon"]["Emoticon-Grumpy"] })
tinsert(E, { ">:%-%(", M["Icon"]["Emoticon-Grumpy"]})
tinsert(E, { ">:o", M["Icon"]["Emoticon-Upset"]})
tinsert(E, { ">:%-o", M["Icon"]["Emoticon-Upset"]})
tinsert(E, { ">:O", M["Icon"]["Emoticon-Upset"]})
tinsert(E, { ">:%-O", M["Icon"]["Emoticon-Upset"]})

-- these last
tinsert(E, { "O%.o", M["Icon"]["Emoticon-Confused"]})
tinsert(E, { "o%.O", M["Icon"]["Emoticon-Confused"]})
tinsert(E, { ":'%(", M["Icon"]["Emoticon-Cry"]})
tinsert(E, { ":%(", M["Icon"]["Emoticon-Frown"]})
tinsert(E, { ":%-%(", M["Icon"]["Emoticon-Frown"]})
--tinsert(E, { ":%[", M["Icon"]["Emoticon-Frown"]}) -- this messes with player links sometimes
tinsert(E, { "=%(", M["Icon"]["Emoticon-Frown"]})
tinsert(E, { ":%-O", M["Icon"]["Emoticon-Gasp"]})
tinsert(E, { ":O", M["Icon"]["Emoticon-Gasp"]})
tinsert(E, { ":%-o", M["Icon"]["Emoticon-Gasp"]})
tinsert(E, { ":o", M["Icon"]["Emoticon-Gasp"]})
tinsert(E, { "8%)", M["Icon"]["Emoticon-Glasses"]})
tinsert(E, { "8%-%)", M["Icon"]["Emoticon-Glasses"]})
tinsert(E, { "B%)", M["Icon"]["Emoticon-Glasses"]})
tinsert(E, { "B%-%)", M["Icon"]["Emoticon-Glasses"]})
tinsert(E, { ":D", M["Icon"]["Emoticon-Grin"]})
tinsert(E, { ":%-D", M["Icon"]["Emoticon-Grin"]})
tinsert(E, { "=D", M["Icon"]["Emoticon-Grin"]})
tinsert(E, { "<3", M["Icon"]["Emoticon-Heart"]})
tinsert(E, { "%^_%^", M["Icon"]["Emoticon-Kiki"]})
tinsert(E, { ":%*", M["Icon"]["Emoticon-Kiss"]})
tinsert(E, { ":%-%*", M["Icon"]["Emoticon-Kiss"]})
tinsert(E, { ":%)", M["Icon"]["Emoticon-Smile"]})
tinsert(E, { ":%-%)", M["Icon"]["Emoticon-Smile"]})
--tinsert(E, { ":%]", M["Icon"]["Emoticon-Smile"]}) -- links can be messed up by this
tinsert(E, { "=%)", M["Icon"]["Emoticon-Smile"]})
tinsert(E, { "%-_%-", M["Icon"]["Emoticon-Squint"]})
tinsert(E, { "8||", M["Icon"]["Emoticon-Sunglasses"]})
tinsert(E, { "8%-||", M["Icon"]["Emoticon-Sunglasses"]})
tinsert(E, { "B||", M["Icon"]["Emoticon-Sunglasses"]})
tinsert(E, { "B%-||", M["Icon"]["Emoticon-Sunglasses"]})
tinsert(E, { ":p", M["Icon"]["Emoticon-Tongue"]})
tinsert(E, { ":%-P", M["Icon"]["Emoticon-Tongue"]})
tinsert(E, { ":P", M["Icon"]["Emoticon-Tongue"]})
tinsert(E, { ":%-p", M["Icon"]["Emoticon-Tongue"]})
tinsert(E, { "=P", M["Icon"]["Emoticon-Tongue"]})
tinsert(E, { "[^http]:%/", M["Icon"]["Emoticon-Unsure"]})
tinsert(E, { "[^ftp]:%/", M["Icon"]["Emoticon-Unsure"]})
tinsert(E, { ":%-%/", M["Icon"]["Emoticon-Unsure"]})
tinsert(E, { "[^file]:%\\", M["Icon"]["Emoticon-Unsure"]})
tinsert(E, { ":%-%\\", M["Icon"]["Emoticon-Unsure"]})
tinsert(E, { ";%)", M["Icon"]["Emoticon-Wink"]})
tinsert(E, { ";%-%)", M["Icon"]["Emoticon-Wink"]})

-- friz quadrata smilies
tinsert(E, { "☺", M["Icon"]["Emoticon-Smile"]})
tinsert(E, { "☻", M["Icon"]["Emoticon-Gasp"]})

-- arrows
tinsert(E, { "←", M["Icon"]["ArrowLeft"]})
tinsert(E, { "<%-", M["Icon"]["ArrowLeft"]})
tinsert(E, { "<<", M["Icon"]["ArrowLeft"]})
tinsert(E, { "→", M["Icon"]["ArrowRight"]})
tinsert(E, { "%->", M["Icon"]["ArrowRight"]})
tinsert(E, { ">>", M["Icon"]["ArrowRight"]})
tinsert(E, { "↑", M["Icon"]["ArrowUp"]})
tinsert(E, { "%(^%)", M["Icon"]["ArrowUp"]})
tinsert(E, { "↓", M["Icon"]["ArrowDown"]})
tinsert(E, { "%(v%)", M["Icon"]["ArrowDown"]})

-- will eventually have to make some textures for a lot of these, 
-- as they don't exist in Waukegan LDO currently. Add them to the font?
local symbols = {
	-- normal shortcuts
	["%(c%)"] = "©";
	["%(copy%)"] = "©";
	["%(eur%)"] = "€";
	["%(euro%)"] = "€";
	["%(gbp%)"] = "£";
	["%(r%)"] = "®";
	["%(reg%)"] = "®";
	["%(tm%)"] = "™";
	["%(trade%)"] = "™";
	["%(usd%)"] = "$";
	
	-- exists in pt sans narrow, not in waukegan ldo
	["%!="] = "≠";
	["%~="] = "≠";
	["<>"] = "≠";
	["~~"] = "≈";
	["%(sqrt%)"] = "√";
	["%(integr%)"] = "∫";
	["%(sigma%)"] = "∑";
	["%(omega%)"] = "Ω";
	["%(delta%)"] = "∆";
	["%(inf%)"] = "∞";

	-- doesn't exist in either
--	["%(inter%)"] = "∩"; 
--	["%(lomega%)"] = "ω";
--	["%(phi%)"] = "Φ";
--	["%(psi%)"] = "Ψ";
--	["%(theta%)"] = "θ";
--	["%(lambda%)"] = "Λ";
--	["%(llambda%)"] = "λ";

	-- backwards compatibility to make 
	-- some of the items sent by WoWDings readable
--	["≠"] = "~="; -- exists in pt sans narrow
--	["≈"] = "~~"; -- exists in pt sans narrow
}

-- convert the table for faster texture conversion
for i = 1, #E do
	E[E[i][1]] = E[i][2]
end

F.EmoticonToTexture = function(msg)
	return (msg) and (E[msg]) and "|T" .. E[msg] .. ":0:0:0:0:16:16:0:16:0:16:255:255:255|t"
end

----------------------------------------------------------------------------------
-- Chat filters
----------------------------------------------------------------------------------
emoticonFilter = function(self, event, msg, ...)
	local E = E

	local i, emo, new
	for i = 1, #E do
		emo = E[i][1]
		if (strfind(msg, emo)) then
			new = gsub(new or msg, emo, F.EmoticonToTexture(emo))
		end
	end
	
	if (new) then
		return false, new, ...
	end
end

symbolFilter = function(self, event, msg, ...)
	local symbols = symbols
	
	local pattern, symbol, new
	for pattern,symbol in pairs(symbols) do
		if (strfind(msg, pattern)) then
			new = gsub(new or msg, pattern, symbol)
		end
	end

	if (new) then
		return false, new, ...
	end
end

local events = {
	"CHAT_MSG_BATTLEGROUND";
	"CHAT_MSG_BATTLEGROUND_LEADER";
	"CHAT_MSG_BN_CONVERSATION";
	"CHAT_MSG_BN_INLINE_TOAST_ALERT";
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST";
	"CHAT_MSG_BN_INLINE_TOAST_CONVERSATION";
	"CHAT_MSG_BN_WHISPER";
	"CHAT_MSG_BN_WHISPER_INFORM";
	"CHAT_MSG_CHANNEL";
	"CHAT_MSG_GUILD";
	"CHAT_MSG_MONSTER_WHISPER";
	"CHAT_MSG_OFFICER";
	"CHAT_MSG_PARTY";
	"CHAT_MSG_PARTY_LEADER";
	"CHAT_MSG_RAID";
	"CHAT_MSG_RAID_BOSS_WHISPER";
	"CHAT_MSG_RAID_LEADER";
	"CHAT_MSG_RAID_WARNING";
	"CHAT_MSG_SAY";
--		"CHAT_MSG_SYSTEM";
	"CHAT_MSG_WHISPER";
	"CHAT_MSG_WHISPER_INFORM";
	"CHAT_MSG_YELL";
}

module.UpdateAll = function(self)
	if (GUIS_DB["chat"].useIcons) then
		for _,event in pairs(events) do
			ChatFrame_AddMessageEventFilter(event, emoticonFilter)
			ChatFrame_AddMessageEventFilter(event, symbolFilter)
		end
	else
		for _,event in pairs(events) do
			ChatFrame_RemoveMessageEventFilter(event, emoticonFilter)
			ChatFrame_RemoveMessageEventFilter(event, symbolFilter)
		end
	end
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Chat")) then 
		self:Kill() 
		return 
	end
	
	self:UpdateAll()
end
