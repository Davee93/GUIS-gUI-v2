--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningReadyCheck")

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

	ReadyCheckFrame:RemoveTextures()
	ReadyCheckFrameYesButton:SetUITemplate("button", true)
	ReadyCheckFrameNoButton:SetUITemplate("button", true)
	ReadyCheckFrame:SetUITemplate("backdrop")

	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameYesButton:SetPoint("RIGHT", ReadyCheckFrame, "CENTER", -2, -20)

	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameNoButton:ClearAllPoints()
	ReadyCheckFrameNoButton:SetPoint("LEFT", ReadyCheckFrameYesButton, "RIGHT", 3, 0)

	ReadyCheckFrameText:SetParent(ReadyCheckFrame)	
	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:SetPoint("TOP", 0, -12)

	ReadyCheckListenerFrame:SetAlpha(0)

	-- sometimes the lines get wrapped, and that looks bad. 
	ReadyCheckFrame:SetSize(350, 100) -- original size 323, 100
	ReadyCheckFrameText:SetSize(320, 36) -- original size 240, 36

	-- we'll get a big black box when performing ready checks, so we need to hide it!
	local fixDisplayBugs = function(self)
		if (self.initiator) and (UnitIsUnit("player", self.initiator)) then 
			self:Hide() 
		end
	end
	
	ReadyCheckFrame:HookScript("OnShow", fixDisplayBugs)
end
