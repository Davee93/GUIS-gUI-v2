--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGhostFrame")

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

	GhostFrame:RemoveTextures()
	GhostFrameLeft:Kill()
	GhostFrameMiddle:Kill()
	GhostFrameRight:Kill()

	GhostFrame:SetUITemplate("simplebackdrop")

	local highlight = GhostFrame:CreateTexture()
	highlight:SetTexture(1, 1, 1, 1/3)
	highlight:SetPoint("TOPLEFT", 3, -3)
	highlight:SetPoint("BOTTOMRIGHT", -3, 3)
	highlight:SetDrawLayer("OVERLAY", -1)
	GhostFrame:SetHighlightTexture(highlight)

	local iconBackdrop = CreateFrame("Frame", nil, GhostFrameContentsFrame)
	iconBackdrop:SetAllPoints(GhostFrameContentsFrameIcon)
	iconBackdrop:SetUITemplate("thinborder")

	GhostFrameContentsFrame:SetPoint("TOPLEFT", 0, 0)
	GhostFrameContentsFrame.SetPoint = noop
	GhostFrameContentsFrameText:SetFontObject(GUIS_SystemFontNormal)
	GhostFrameContentsFrameIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	GhostFrameContentsFrameIcon:SetDrawLayer("OVERLAY", 1)
	GhostFrameContentsFrameIcon:SetParent(iconBackdrop)
end
