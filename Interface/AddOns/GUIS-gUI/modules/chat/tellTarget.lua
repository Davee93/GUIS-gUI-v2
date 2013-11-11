--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ChatTellTarget")

-- Lua API
local gsub, strlen, strsub = string.gsub, string.len, string.sub

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end

local OnTextChanged
local sendTell, sendMacroTell

sendTell = function(who)
	if not(UnitExists(who)) then return end

	local unitname, realm = UnitName(who)
	if (unitname) then 
		unitname = gsub(unitname, " ", "") 
	end
	
	if (unitname) and (not UnitIsSameServer("player", who)) then
		unitname = unitname .. "-" .. gsub(realm, " ", "")
	end
	
	return unitname
end

sendMacroTell = function(who, msg)
	if not(UnitExists(who)) then return end

	SendChatMessage(msg, "WHISPER", nil, sendTell(who))
end

OnTextChanged = function(self)
	local text = self:GetText()
	if (strlen(text) < 5) then
		if (strsub(text, 1, 4) == "/tt ") or (strsub(text, 1, 4) == "/wt ") then
			ChatFrame_SendTell((sendTell("target") or ""), SELECTED_CHAT_FRAME)
			
		elseif (strsub(text, 1, 4) == "/tf ") or (strsub(text, 1, 4) == "/wf ") then
			ChatFrame_SendTell((sendTell("focus") or ""), SELECTED_CHAT_FRAME)
			
		end
	end
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Chat")) then 
		self:Kill() 
		return 
	end
end

module.OnEnable = function()
	for i = 1, NUM_CHAT_WINDOWS do
		_G[("ChatFrame%dEditBox"):format(i)]:HookScript("OnTextChanged", OnTextChanged)
	end

	-- these chat commands exists for the purpose of user macros
	CreateChatCommand(function(msg) sendMacroTell("target", msg) end, {"tt", "wt"})
	CreateChatCommand(function(msg) sendMacroTell("focus", msg) end, {"tf", "wf"})
end
