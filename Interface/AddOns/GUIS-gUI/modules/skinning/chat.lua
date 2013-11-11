--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningChat")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) return module:UnregisterCallback(...) end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end
	
	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])

	local once
	local fixLogPanel = function(self, event, addon)
		if (once) then
			return
		end
		
		ChatConfigCombatSettingsFilters:RemoveTextures()
		ChatConfigCombatSettingsFiltersScrollFrameScrollBarBorder:RemoveTextures()
		CombatConfigMessageSourcesDoneBy:RemoveTextures()
		CombatConfigMessageSourcesDoneBy:RemoveTextures()
		CombatConfigColorsUnitColors:RemoveTextures()
		CombatConfigColorsHighlighting:RemoveTextures()
		CombatConfigColorsColorizeUnitName:RemoveTextures()
		CombatConfigColorsColorizeSpellNames:RemoveTextures()
		CombatConfigColorsColorizeDamageNumber:RemoveTextures()
		CombatConfigColorsColorizeDamageSchool:RemoveTextures()
		CombatConfigColorsColorizeEntireLine:RemoveTextures()
		CombatConfigTab1:RemoveTextures()
		CombatConfigTab2:RemoveTextures()
		CombatConfigTab3:RemoveTextures()
		CombatConfigTab4:RemoveTextures()
		CombatConfigTab5:RemoveTextures()

		CombatLogQuickButtonFrame_CustomTexture:Kill()

		ChatConfigMoveFilterDownButton:SetUITemplate("arrow", "down")
		ChatConfigMoveFilterUpButton:SetUITemplate("arrow", "up")
		CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetUITemplate("arrow", "down")

		ChatConfigCombatSettingsFiltersCopyFilterButton:SetUITemplate("button", true)
		ChatConfigCombatSettingsFiltersAddFilterButton:SetUITemplate("button", true)
		ChatConfigCombatSettingsFiltersDeleteButton:SetUITemplate("button", true)
		CombatConfigSettingsSaveButton:SetUITemplate("button", true)
		CombatLogDefaultButton:SetUITemplate("button", true)
		
		CombatConfigColorsColorizeUnitNameCheck:SetUITemplate("checkbutton")
		CombatConfigColorsColorizeSpellNamesCheck:SetUITemplate("checkbutton")
		CombatConfigColorsColorizeSpellNamesSchoolColoring:SetUITemplate("checkbutton")
		CombatConfigColorsColorizeDamageNumberCheck:SetUITemplate("checkbutton")
		CombatConfigColorsColorizeDamageNumberSchoolColoring:SetUITemplate("checkbutton")
		CombatConfigColorsColorizeDamageSchoolCheck:SetUITemplate("checkbutton")
		CombatConfigColorsColorizeEntireLineCheck:SetUITemplate("checkbutton")
		CombatConfigColorsHighlightingLine:SetUITemplate("checkbutton")
		CombatConfigColorsHighlightingAbility:SetUITemplate("checkbutton")
		CombatConfigColorsHighlightingSchool:SetUITemplate("checkbutton")
		CombatConfigColorsHighlightingDamage:SetUITemplate("checkbutton")
		
		CombatConfigFormattingShowTimeStamp:SetUITemplate("checkbutton")
		CombatConfigFormattingShowBraces:SetUITemplate("checkbutton")
		CombatConfigFormattingUnitNames:SetUITemplate("checkbutton")
		CombatConfigFormattingSpellNames:SetUITemplate("checkbutton")
		CombatConfigFormattingItemNames:SetUITemplate("checkbutton")
		CombatConfigFormattingFullText:SetUITemplate("checkbutton")
		CombatConfigSettingsShowQuickButton:SetUITemplate("checkbutton")
		CombatConfigSettingsSolo:SetUITemplate("checkbutton")
		CombatConfigSettingsParty:SetUITemplate("checkbutton")
		CombatConfigSettingsRaid:SetUITemplate("checkbutton")

		CombatConfigSettingsNameEditBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)

		ChatConfigCombatSettingsFilters:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigMessageSourcesDoneBy:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigMessageSourcesDoneTo:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigColorsUnitColors:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigColorsHighlighting:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigColorsColorizeUnitName:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigColorsColorizeSpellNames:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigColorsColorizeDamageNumber:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigColorsColorizeDamageSchool:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CombatConfigColorsColorizeEntireLine:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		
		CombatConfigColorsColorizeEntireLineBySource:SetUITemplate("radiobutton", true)
		CombatConfigColorsColorizeEntireLineByTarget:SetUITemplate("radiobutton", true)
		
		ChatConfigCombatSettingsFiltersScrollFrameScrollBar:SetUITemplate("scrollbar")

		CombatLogQuickButtonFrame_CustomProgressBar:SetUITemplate("statusbar", true)

		CombatLogQuickButtonFrame_CustomProgressBar:SetAllPoints(CombatLogQuickButtonFrame_CustomTexture)
		
		local skinned = {}

		local skinTieredCheckboxes = function(frame, checkBoxTable, checkBoxTemplate, subCheckBoxTemplate, columns, spacing)
			local checkBoxNameString = frame:GetName().."CheckBox"

			checkBoxTable = frame.checkBoxTable or checkBoxTable
			
			local button, subButton, subName
			for index, value in ipairs(checkBoxTable) do
				local button = _G[checkBoxNameString .. index]
				if (button) then
					if not(skinned[checkBoxNameString .. index]) then
						button:SetUITemplate("checkbutton")

						if (value.subTypes) then
							for k, v in ipairs(value.subTypes) do
								subName = checkBoxNameString .. index .. "_" .. k
								subButton = _G[subName]
								if (subButton) and not(skinned[subName]) then
									subButton:SetUITemplate("checkbutton")
									
									skinned[subName] = true
								end
							end
						end
						
						skinned[checkBoxNameString .. index] = true
					end
				end
			end
		end
		hooksecurefunc("ChatConfig_CreateTieredCheckboxes", skinTieredCheckboxes)

		local skinSwatches = function(frame, swatchTable, swatchTemplate, title)
			local nameString = frame:GetName() .. "Swatch"

			swatchTable = frame.swatchTable or swatchTable

			for index, value in ipairs(swatchTable) do
				local button = _G[nameString .. index]
				if (button) and not(skinned[nameString .. index]) then

					button:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
					
					skinned[nameString .. index] = true
				end
			end
		end
		hooksecurefunc("ChatConfig_CreateColorSwatches", skinSwatches)
		
		local updateQuickButtons = function()
			local buttonIndex = 1
			for i, filter in ipairs(Blizzard_CombatLog_Filters.filters) do
				local button = _G["CombatLogQuickButtonFrameButton" .. buttonIndex]
				if (button) then
					if not(skinned["CombatLogQuickButtonFrameButton" .. buttonIndex]) then
						button:SetNormalFontObject(GUIS_SystemFontSmallGray)
						button:SetHighlightFontObject(GUIS_SystemFontSmall)
						
						skinned["CombatLogQuickButtonFrameButton" .. buttonIndex] = true
					end
					
					if ((ShowQuickButton(filter)) and (filter.onQuickBar)) then
						buttonIndex = buttonIndex + 1
					end
				end
			end
		end
		hooksecurefunc("Blizzard_CombatLog_Update_QuickButtons", updateQuickButtons)
		
		once = true
	end

	if (IsAddOnLoaded("Blizzard_CombatLog")) then
		fixLogPanel()
	else
		local callback
		local proxy = function(self, event, addon)
			if (addon == "Blizzard_CombatLog") then
				fixLogPanel()
				UnregisterCallback(callback)
			end
		end
		callback = RegisterCallback("ADDON_LOADED", proxy)
	end
	
	ChatConfigFrame:RemoveTextures()
	
	-- this button may be killed already by the chat module
	-- we're still skinning it though, as people may not use the chat module
	ChatConfigFrameDefaultButton:SetUITemplate("button", true)
	ChatConfigFrameOkayButton:SetUITemplate("button", true)

	ChatConfigFrame:SetUITemplate("simplebackdrop")
	ChatConfigBackgroundFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigCategoryFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigChannelSettingsLeft:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigChannelSettingsClassColorLegend:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigChatSettingsLeft:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigChatSettingsClassColorLegend:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigOtherSettingsCombat:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigOtherSettingsPVP:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigOtherSettingsSystem:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChatConfigOtherSettingsCreature:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)

	ChatConfigFrameHeader:ClearAllPoints()
	ChatConfigFrameHeader:SetPoint("TOP", ChatConfigFrame, "TOP", 0, -8)
	
	local skinned = {}
	local button, check, checkBoxNameString, colorClass
	local skinChatConfigCheckBoxes = function(frame) 
		checkBoxNameString = frame:GetName() .. "CheckBox"
		
		for index, value in ipairs(frame.checkBoxTable) do
			button = _G[checkBoxNameString .. index]
			
			if (button) and not(skinned[checkBoxNameString .. index]) then
				button:RemoveTextures()
				
				colorClass = _G[checkBoxNameString .. index .. "ColorClasses"]
				check = _G[checkBoxNameString .. index .. "Check"]
--				swatchButton = _G[checkBoxNameString .. index .. "ColorSwatch"] 
				
				if (check) then
					check:SetUITemplate("checkbutton")
				end
				
				if (colorClass) then
					colorClass:SetUITemplate("checkbutton")
				end
				
				skinned[checkBoxNameString .. index] = true
			end
		end
		
		button, check, checkBoxNameString, colorClass = nil, nil, nil
	end
	hooksecurefunc("ChatConfig_CreateCheckboxes", skinChatConfigCheckBoxes)
end
