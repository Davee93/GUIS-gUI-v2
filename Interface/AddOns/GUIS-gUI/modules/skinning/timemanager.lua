--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTimeManager")

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

	local SkinFunc = function()
--		TimeManagerFrame:SetClampedToScreen(true)
		TimeManagerFrame:SetFrameStrata("HIGH")
		TimeManagerFrame:ClearAllPoints()
		TimeManagerFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 8, 11)
		
		StopwatchFrame:RemoveTextures()
		StopwatchTabFrame:RemoveTextures()
		TimeManagerFrame:RemoveTextures()
		TimeManagerStopwatchFrame:RemoveTextures()

		TimeManagerAlarmHourDropDown:SetUITemplate("dropdown", true, 80)
		TimeManagerAlarmMinuteDropDown:SetUITemplate("dropdown", true, 80)
		TimeManagerAlarmAMPMDropDown:SetUITemplate("dropdown", true, 80)

		TimeManagerAlarmEnabledButton:SetUITemplate("button")
		TimeManagerMilitaryTimeCheck:SetUITemplate("checkbutton")
		TimeManagerLocalTimeCheck:SetUITemplate("checkbutton")
		
		-- MoP beta edits
		if (TimeManagerCloseButton) then
			TimeManagerCloseButton:SetUITemplate("closebutton")
		end
		
		StopwatchCloseButton:SetUITemplate("closebutton", "TOPRIGHT", 0, 0)

		TimeManagerAlarmMessageEditBox:SetUITemplate("editbox")

		TimeManagerFrame:SetUITemplate("backdrop", nil, 8, 0, 0, 42)

		TimeManagerStopwatchCheck:SetUITemplate("border")
		TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)

		local hover = TimeManagerStopwatchCheck:CreateTexture(nil, "OVERLAY") 
		hover:SetAllPoints(TimeManagerStopwatchCheck)
		hover:SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 1/3)
		TimeManagerStopwatchCheck:SetHighlightTexture(hover)
		
		local StopWatchSkin = StopwatchFrame:SetUITemplate("backdrop", nil, 14, 0, 0, 0)

		local ExpandStopWatch = function()
			StopWatchSkin:ClearAllPoints()
			StopWatchSkin:SetPoint("TOPLEFT", 0, 3)
			StopWatchSkin:SetPoint("BOTTOMRIGHT", 0, 0)
		end

		local FixAlarmButton = function()
			TimeManagerAlarmEnabledButton:SetUITemplate("button")
		end
		
		local FixHoverLay = function()
			StopwatchFrameHoverlay:SetFrameStrata(StopwatchFrame:GetFrameStrata())
			StopwatchFrameHoverlay:SetFrameLevel(StopwatchFrame:GetFrameLevel() + 100)
		end

		local ShrinkStopWatch = function()
			StopWatchSkin:ClearAllPoints()
			StopWatchSkin:SetPoint("TOPLEFT", 0, -14)
			StopWatchSkin:SetPoint("BOTTOMRIGHT", 0, 0)
		end
		
		StopwatchFrame:HookScript("OnEnter", ExpandStopWatch)
		StopwatchFrame:HookScript("OnLeave", ShrinkStopWatch)
		StopwatchCloseButton:HookScript("OnEnter", ExpandStopWatch)
		StopwatchCloseButton:HookScript("OnLeave", ShrinkStopWatch)
		StopwatchPlayPauseButton:HookScript("OnEnter", ExpandStopWatch)
		StopwatchPlayPauseButton:HookScript("OnLeave", ShrinkStopWatch)
		StopwatchResetButton:HookScript("OnEnter", ExpandStopWatch)
		StopwatchResetButton:HookScript("OnLeave", ShrinkStopWatch)
		TimeManagerAlarmEnabledButton:HookScript("OnClick", FixAlarmButton)
		TimeManagerFrame:HookScript("OnShow", FixAlarmButton)
	end
	F.SkinAddOn("Blizzard_TimeManager", SkinFunc)
end
