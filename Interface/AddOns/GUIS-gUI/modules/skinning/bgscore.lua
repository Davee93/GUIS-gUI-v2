--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningBGScore")

-- Lua API
local unpack = unpack

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local Skin

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end
	
	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
	
	WorldStateScoreFrame:RemoveTextures()
	WorldStateScoreFrameInset:RemoveTextures()
	WorldStateScoreScrollFrame:RemoveTextures()
	
	WorldStateScoreFrame:SetUITemplate("simplebackdrop")
	WorldStateScoreFrameInset:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	WorldStateScoreFrameLeaveButton:SetUITemplate("button", true)
	WorldStateScoreFrameCloseButton:SetUITemplate("closebutton")
	WorldStateScoreScrollFrameScrollBar:SetUITemplate("scrollbar")
	WorldStateScoreFrameTab1:SetUITemplate("tab", true)
	WorldStateScoreFrameTab2:SetUITemplate("tab", true)
	WorldStateScoreFrameTab3:SetUITemplate("tab", true)
end
