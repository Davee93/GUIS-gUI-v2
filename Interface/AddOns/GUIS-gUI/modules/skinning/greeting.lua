--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGreeting")

-- Lua API
local pairs, select, unpack = pairs, select, unpack
local gsub = string.gsub

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end
	
	local SkinFunc = function()
		QuestFrameGreetingPanel:RemoveTextures()
		QuestGreetingFrameHorizontalBreak:RemoveTextures()
		QuestFrameGreetingGoodbyeButton:SetUITemplate("button")

		AvailableQuestsText:SetTextColor(unpack(C["value"]))
		CurrentQuestsText:SetTextColor(unpack(C["value"]))
		GreetingText:SetTextColor(unpack(C["index"]))
	
		for i = 1, MAX_NUM_QUESTS do
			local button = _G["QuestTitleButton" .. i]
			
			if (button:GetFontString()) then
				if (button:GetFontString():GetText()) and (button:GetFontString():GetText():find("|cff000000")) then
					button:GetFontString():SetText(gsub(button:GetFontString():GetText(), "|cff000000", "|cff" .. RGBToHex(unpack(C["value"]))))
				end
			end
		end
	end
	QuestFrameGreetingPanel:HookScript("OnShow", SkinFunc)
end
