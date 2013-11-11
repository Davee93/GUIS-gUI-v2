--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningWorldMap")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- WoW API
local GetCVarBool = GetCVarBool
local HideUIPanel = HideUIPanel
local ShowUIPanel = ShowUIPanel
local ToggleFrame = ToggleFrame
local WatchFrame_Update = WatchFrame_Update
local WorldMapFrame_SetFullMapView = WorldMapFrame_SetFullMapView

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
	
	local SetUIPanelAttribute = SetUIPanelAttribute
	if not(SetUIPanelAttribute) then
		-- thank you http://www.wowpedia.org/SetUIPanelAttribute
		SetUIPanelAttribute = function(frame, name, value)
			frame:SetAttribute("UIPanelLayout-"..name, value) 
		end
	end

	WorldMapFrame:RemoveTextures()
	
	WorldMapZoomOutButton:SetUITemplate("button")

	WorldMapQuestShowObjectives:SetUITemplate("checkbutton")
	WorldMapShowDigSites:SetUITemplate("checkbutton")
	WorldMapTrackQuest:SetUITemplate("checkbutton")
	
	WorldMapFrameCloseButton:SetUITemplate("closebutton")
	
	WorldMapFrameSizeDownButton:SetUITemplate("arrow", "left")
	WorldMapFrameSizeUpButton:RemoveTextures()
	WorldMapFrameSizeDownButton:ClearAllPoints()
	WorldMapFrameSizeDownButton:SetPoint("CENTER", WorldMapFrameCloseButton, "LEFT", 0, 5)
	WorldMapFrameSizeDownButton:SetSize(16, 16)
	
	WorldMapContinentDropDown:SetUITemplate("dropdown", true)
	WorldMapLevelDropDown:SetUITemplate("dropdown", true)
	WorldMapZoneDropDown:SetUITemplate("dropdown", true)
	WorldMapZoneMinimapDropDown:SetUITemplate("dropdown", true)

	WorldMapDetailFrame:SetUITemplate("backdrop")

	WorldMapQuestDetailScrollFrameScrollBar:SetUITemplate("scrollbar")
	WorldMapQuestRewardScrollFrameScrollBar:SetUITemplate("scrollbar")
	WorldMapQuestScrollFrameScrollBar:SetUITemplate("scrollbar")

	-- 4.3
	if (F.IsBuild(4,3,0)) then
		WorldMapShowDropDown:SetUITemplate("dropdown", true)
	end
	
	local mapSkin = WorldMapFrame:SetUITemplate("backdrop", nil, 0, 8, 8, 0)
	
	local MiniWorldMap = function()
		WorldMapLevelDropDown:ClearAllPoints()
		WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -10, -4)

		mapSkin:ClearAllPoints()
		mapSkin:SetPoint("TOPLEFT", -3, 6)
		mapSkin:SetPoint("BOTTOMRIGHT", 3, -3)
	end

	local LargeWorldMap = function()
		if not(InCombatLockdown()) then
			WorldMapFrame:SetParent(UIParent)
			WorldMapFrame:EnableMouse(false)
			WorldMapFrame:EnableKeyboard(false)
			SetUIPanelAttribute(WorldMapFrame, "area", "center");
			SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
		end
		
		mapSkin:ClearAllPoints()
		mapSkin:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -25, 78)
		mapSkin:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 25, -30)    
	end

	local QuestWorldMap = function()
		if not(InCombatLockdown()) then
			WorldMapFrame:SetParent(UIParent)
			WorldMapFrame:EnableMouse(false)
			WorldMapFrame:EnableKeyboard(false)
			SetUIPanelAttribute(WorldMapFrame, "area", "center"); 
			SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
		end
		
		mapSkin:ClearAllPoints()
		mapSkin:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -25, 78)
		mapSkin:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 334, -237)  

		if not(WorldMapQuestDetailScrollFrame.backdrop) then
			WorldMapQuestDetailScrollFrame.backdrop = WorldMapQuestDetailScrollFrame:SetUITemplate("backdrop")
			WorldMapQuestDetailScrollFrame.backdrop:ClearAllPoints()
			WorldMapQuestDetailScrollFrame.backdrop:SetPoint("TOPLEFT", -22, 3)
			WorldMapQuestDetailScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 25, -5)
			WorldMapQuestDetailScrollFrame.backdrop:SetBackdropColor(unpack(C["overlay"]))
		end
		
		if not(WorldMapQuestRewardScrollFrame.backdrop) then
			WorldMapQuestRewardScrollFrame.backdrop = WorldMapQuestRewardScrollFrame:SetUITemplate("backdrop")
			WorldMapQuestRewardScrollFrame.backdrop:ClearAllPoints()
			WorldMapQuestRewardScrollFrame.backdrop:SetPoint("TOPLEFT", 0, 3)
			WorldMapQuestRewardScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 25, -5)				
		end
		
		if not(WorldMapQuestScrollFrame.backdrop) then
			WorldMapQuestScrollFrame.backdrop = WorldMapQuestScrollFrame:SetUITemplate("backdrop")
			WorldMapQuestScrollFrame.backdrop:ClearAllPoints()
			WorldMapQuestScrollFrame.backdrop:SetPoint("TOPLEFT", 0, 3)
			WorldMapQuestScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 28, -4)				
		end
	end	

	local UpdateWorldMap = function()
		-- they keep re-adding the backdrop textures
		WorldMapFrame:RemoveTextures()

		if (WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE) then
			LargeWorldMap()
		elseif (WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE) then
			MiniWorldMap()
		elseif (WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE) then
			QuestWorldMap()
		end

		if not(InCombatLockdown()) then
			WorldMapFrame:SetScale(1)
			WorldMapFrameSizeDownButton:Show()
			WorldMapFrame:SetFrameLevel(40)
			WorldMapFrame:SetFrameStrata("HIGH")
		end
	end

	local FixTaint = function(self, event)
		local miniWorldMap = GetCVarBool("miniWorldMap")
		local quest = WorldMapQuestShowObjectives:GetChecked()

		if (event == "PLAYER_ENTERING_WORLD") then
			if not(miniWorldMap) then
				ToggleFrame(WorldMapFrame)
				ToggleFrame(WorldMapFrame)
			end
			
		elseif (event == "PLAYER_REGEN_DISABLED") then
			WorldMapFrameSizeDownButton:Disable()
			WorldMapFrameSizeUpButton:Disable()
			
			if (quest) then
				if WorldMapFrame:IsShown() then
					HideUIPanel(WorldMapFrame)
				end

				if not(miniWorldMap) and (WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE) then
					WorldMapFrame_SetFullMapView()
				end

				WatchFrame.showObjectives = nil
				WorldMapTitleButton:Hide()
				WorldMapBlobFrame:Hide()
				WorldMapPOIFrame:Hide()

				WorldMapQuestShowObjectives.Show = noop
				WorldMapTitleButton.Show = noop
				WorldMapBlobFrame.Show = noop
				WorldMapPOIFrame.Show = noop

				WatchFrame_Update()
			end
			WorldMapQuestShowObjectives:Hide()
			
		elseif (event == "PLAYER_REGEN_ENABLED") then
			WorldMapFrameSizeDownButton:Enable()
			WorldMapFrameSizeUpButton:Enable()
			
			if (quest) then
				WorldMapQuestShowObjectives.Show = WorldMapQuestShowObjectives:Show()
				WorldMapTitleButton.Show = WorldMapTitleButton:Show()
				WorldMapBlobFrame.Show = WorldMapBlobFrame:Show()
				WorldMapPOIFrame.Show = WorldMapPOIFrame:Show()

				WorldMapTitleButton:Show()

				WatchFrame.showObjectives = true

				if not(miniWorldMap) and (WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE) then
					WorldMapFrame_SetFullMapView()
				end

				WorldMapBlobFrame:Show()
				WorldMapPOIFrame:Show()

				WatchFrame_Update()
				
				if not(miniWorldMap) and (WorldMapFrame:IsShown()) and (WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE) then
					HideUIPanel(WorldMapFrame)
					ShowUIPanel(WorldMapFrame)
				end
			end
			WorldMapQuestShowObjectives:Show()
		end
	end

	-- initial size update
	if (F.IsBuild(4,3,0)) then
		UpdateWorldMap() 
	end

	WorldMapFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	WorldMapFrame:RegisterEvent("PLAYER_REGEN_ENABLED") 
	WorldMapFrame:RegisterEvent("PLAYER_REGEN_DISABLED") 

	WorldMapFrame:HookScript("OnEvent", FixTaint)
	WorldMapFrame:HookScript("OnShow", UpdateWorldMap)

	hooksecurefunc("WorldMap_ToggleSizeUp", UpdateWorldMap)
	hooksecurefunc("WorldMapFrame_SetFullMapView", LargeWorldMap)
	hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestWorldMap)
	
end
