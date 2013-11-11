--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: TotemBar")

-- WoW API
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local MultiCastActionBarFrame = MultiCastActionBarFrame

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) module:RegisterCallback(...) end
local UnregisterCallback = function(...) module:UnregisterCallback(...) end

local _,playerClass = UnitClass("player")

local settings = {
	pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 230 };
}

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: ActionBars")) or (playerClass ~= "SHAMAN") then
		self:Kill()
		return
	end
	
	if not(MultiCastActionBarFrame) then
		return
	end
	
	local totemBar = CreateFrame("Frame", "GUIS_TotemBar", UIParent)
	totemBar:SetSize(MultiCastActionBarFrame:GetSize())
	totemBar:PlaceAndSave(unpack(settings.pos))
	
	MultiCastActionBarFrame:SetScript("OnUpdate", nil)
	MultiCastActionBarFrame:SetScript("OnShow", nil)
	MultiCastActionBarFrame:SetScript("OnHide", nil)
	MultiCastActionBarFrame:SetParent(totemBar)
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", totemBar, "BOTTOMLEFT", 0, 0)
	MultiCastActionBarFrame.SetParent = noop
	MultiCastActionBarFrame.SetPoint = noop
--	MultiCastRecallSpellButton.SetPoint = noop -- TAINT!!! TAINT!!!! TAINT!!!! >:(
	
	-- MultiCastSummonSpellButton:GetParent():GetName()

	UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MULTICASTACTIONBAR_YPOS"] = nil

	hooksecurefunc("MultiCastActionButton_Update", function(actionButton) 
		local safecall = function()
			actionButton:SetAllPoints(actionButton.slotButton) 
		end
		F.SafeCall(safecall)
	end)

end

