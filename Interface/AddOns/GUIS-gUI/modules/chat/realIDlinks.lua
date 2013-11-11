--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ChatRealIDLinks")

-- Lua API
local gsub, strmatch = string.gsub, string.match

-- WoW API
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetQuestDifficultyColor = GetQuestDifficultyColor
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")

local AddLinkColors, GetLinkColor

--
-- Originally written by P3lim (http://www.wowinterface.com/downloads/info19210-RealLinks.html)
GetLinkColor = function(data)
	local type, id, arg1 = strmatch(data, "(%w+):(%d+):(%d+)")
	
	if (not type) then 
		return "|cffffff88" 
	end
	
	if (type == "item") then
		local quality = (select(3, GetItemInfo(id)))
		if (quality) then
			return "|c" .. (select(4, GetItemQualityColor(quality)))
		else
			return "|cffffff88"
		end
	elseif (type == "quest") then
		local color = GetQuestDifficultyColor(arg1)
		return format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
		
	elseif (type == "spell") then
		return "|cff71d5ff"
		
	elseif (type == "achievement") then
		return "|cffffff00"
		
	elseif (type == "trade") or (type == "enchant") then
		return "|cffffd000"
		
	elseif (type == "instancelock") then
		return "|cffff8000"
		
	elseif (type == "glyph") then
		return "|cff66bbff"
		
	elseif (type == "talent") then
		return "|cff4e96f7"
		
	elseif (type == "levelup") then
		return "|cffFF4E00"
		
	end
end

AddLinkColors = function(self, event, msg, ...)
	local data = strmatch(msg, "|H(.-)|h(.-)|h")
	if (data) then
		return false, gsub(msg, "|H(.-)|h(.-)|h", GetLinkColor(data) .. "|H%1|h%2|h|r"), ...
	else
		return false, msg, ...
	end
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Chat")) then 
		self:Kill() 
		return 
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", AddLinkColors)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", AddLinkColors)
end