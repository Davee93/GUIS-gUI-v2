--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningItemText")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

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

	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
	
	ItemTextFrame:RemoveTextures()
	ItemTextScrollFrame:RemoveTextures()
	
	ItemTextNextPageButton:SetUITemplate("arrow")
	ItemTextPrevPageButton:SetUITemplate("arrow")
	ItemTextCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -36, -14)
	ItemTextFrame:SetUITemplate("backdrop", nil, 8, 8, 48, 32)
	ItemTextScrollFrame:SetUITemplate("backdrop", nil, -8, -8, -8, -8):SetBackdropColor(r, g, b, panelAlpha)
	ItemTextScrollFrameScrollBar:SetUITemplate("scrollbar")
	ItemTextStatusBar:SetUITemplate("statusbar", true)
	
	ItemTextScrollFrameScrollBar:ClearAllPoints()
	ItemTextScrollFrameScrollBar:SetPoint("TOPLEFT", ItemTextScrollFrame, "TOPRIGHT", 12, 0)
	ItemTextScrollFrameScrollBar:SetPoint("BOTTOMLEFT", ItemTextScrollFrame, "BOTTOMRIGHT", 12, 0)
	
	ItemTextMaterialTopLeft:SetTexture("")
	ItemTextMaterialTopRight:SetTexture("")
	ItemTextMaterialBotLeft:SetTexture("")
	ItemTextMaterialBotRight:SetTexture("")
	
	ItemTextMaterialTopLeft.SetTexture = noop
	ItemTextMaterialTopRight.SetTexture = noop
	ItemTextMaterialBotLeft.SetTexture = noop
	ItemTextMaterialBotRight.SetTexture = noop

	ItemTextPageText:SetTextColor(unpack(C["index"]))
	ItemTextPageText.SetTextColor = noop

	ItemTextPrevPageButton:ClearAllPoints()
	ItemTextPrevPageButton:SetPoint("TOPLEFT", 16, -36)
	
	ItemTextNextPageButton:ClearAllPoints()
	ItemTextNextPageButton:SetPoint("TOPRIGHT", -38, -36)
	
	ItemTextTitleText:ClearAllPoints()
	ItemTextTitleText:SetPoint("TOP", -24, -16)
end
