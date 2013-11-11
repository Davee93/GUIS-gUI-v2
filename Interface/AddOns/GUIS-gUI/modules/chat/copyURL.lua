--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ChatCopyURL")

-- Lua API
local gsub = string.gsub

-- WoW API
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")

local getURL, parseURL
local OnHyperLinkShow
local curLink

local color = "16FF5D"
local usebracket = false
local usecolor = true

getURL = function(msg)
	if (usecolor) then
		if (usebracket) then
			return "|cff"..color.."|Hurl:"..msg.."|h["..msg.."]|h|r "
		else
			return "|cff"..color.."|Hurl:"..msg.."|h"..msg.."|h|r "
		end
	else
		if (usebracket) then
			return "|Hurl:"..msg.."|h["..msg.."]|h "
		else
			return "|Hurl:"..msg.."|h"..msg.."|h "
		end
	end
end

parseURL = function(self, event, msg, ...)
	local newMsg, found = gsub(msg, "(%a+)://(%S+)%s?", getURL("%1://%2"))
	if (found > 0) then 
		return false, newMsg, ... 
	end
	
	newMsg, found = gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", getURL("www.%1.%2"))
	if (found > 0) then 
		return false, newMsg, ... 
	end

	newMsg, found = gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", getURL("%1@%2%3%4"))
	if (found > 0) then 
		return false, newMsg, ... 
	end
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Chat")) then 
		self:Kill() 
		return 
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", parseURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", parseURL)

	-- prehook Blizzards function
	_G.ChatFrame_OnHyperlinkShow = function(self, link, text, button)
		if ((link):sub(1, 3) == "url") then
			local editBox = ChatEdit_ChooseBoxForSend()
			curLink = (link):sub(5)

			if not(editBox:IsShown()) then
				ChatEdit_ActivateChat(editBox)
			end

			editBox:Insert(curLink)
			editBox:HighlightText()
			curLink = nil

			return
		end
		
		-- this is the original Blizzard function,
		-- as we copied it to our local at the start
		ChatFrame_OnHyperlinkShow(self, link, text, button)
	end
end

module.OnEnable = function()
end