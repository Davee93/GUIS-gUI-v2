--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGossip")

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

	GossipFrameGreetingPanel:RemoveTextures()
	GossipGreetingScrollFrame:RemoveTextures()
	GossipFramePortrait:RemoveTextures()
	
	GossipFramePortrait:Kill()

	GossipFrameGreetingGoodbyeButton:SetUITemplate("button", true)
	GossipGreetingScrollFrameScrollBar:SetUITemplate("scrollbar")
	GossipFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -34, -26)

	GossipFrame:SetUITemplate("backdrop", nil, 18, 15, 65, 30)
	
	GossipGreetingText:SetTextColor(unpack(C["index"]))
	
	for i = 1, NUMGOSSIPBUTTONS do
		local text = select(3, _G["GossipTitleButton" .. i]:GetRegions())
		text:SetTextColor(unpack(C["index"]))
	end	
	
	local SkinFunc = function()
		for i = 1, NUMGOSSIPBUTTONS do
			local button = _G["GossipTitleButton" .. i]
			
			if (button:GetFontString()) then
				if (button:GetFontString():GetText()) and (button:GetFontString():GetText():find("|cff000000")) then
					button:GetFontString():SetText(gsub(button:GetFontString():GetText(), "|cff000000", "|cff" .. RGBToHex(unpack(C["value"]))))
				end
			end
		end
	end
	hooksecurefunc("GossipFrameUpdate", SkinFunc)
end
