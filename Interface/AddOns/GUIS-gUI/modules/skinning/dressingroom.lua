--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningDressingRoom")

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

	if (DressUpModelRotateLeftButton) then DressUpModelRotateLeftButton:SetUITemplate("arrow", "left") end
	if (DressUpModelRotateRightButton) then DressUpModelRotateRightButton:SetUITemplate("arrow", "right") end

	DressUpFrame:RemoveTextures(true)
	DressUpFrame:SetUITemplate("backdrop", nil, 0, 6, 70, 32)
	DressUpModel:SetUITemplate("backdrop"):SetBackdropColor(0, 0, 0, 1/3)
	
	DressUpFrameCancelButton:SetUITemplate("button")
	DressUpFrameResetButton:SetUITemplate("button")
	DressUpFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", DressUpFrame, "TOPRIGHT", -36, -4)
end
