--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTaxi")

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

	TaxiFrame:RemoveTextures()
	TaxiFrame:SetUITemplate("backdrop", nil, 0, 0, 0, 2)
	
	-- MoP beta edits
	if (TaxiFrameCloseButton) then
		TaxiFrameCloseButton:SetUITemplate("closebutton")
	end
	
	local border = CreateFrame("Frame", nil, TaxiFrame)
	border:SetUITemplate("border")
	border:SetAllPoints(TaxiRouteMap)
end
