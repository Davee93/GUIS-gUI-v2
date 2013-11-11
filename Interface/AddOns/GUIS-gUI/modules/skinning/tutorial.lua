--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTutorial")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

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

	if (TutorialFramePrevButton) then TutorialFramePrevButton:SetUITemplate("arrow", "left") end
	if (TutorialFrameNextButton) then TutorialFrameNextButton:SetUITemplate("arrow", "right") end

	TutorialFrameOkayButton:SetUITemplate("button", true)
	TutorialFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -4, -4)

	TutorialFrame:RemoveTextures()
	TutorialFrame:SetUITemplate("simplebackdrop")
end
