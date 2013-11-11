--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTalents")

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
		local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
		
		PlayerTalentFrame:RemoveTextures()
		PlayerTalentFrameInset:RemoveTextures()
		PlayerTalentFrameTalents:RemoveTextures()
		PlayerTalentFramePanel1HeaderIcon:RemoveTextures()
		PlayerTalentFramePanel2HeaderIcon:RemoveTextures()
		PlayerTalentFramePanel3HeaderIcon:RemoveTextures()
		PlayerTalentFramePetPanelHeaderIcon:RemoveTextures()
		PlayerTalentFramePetTalents:RemoveTextures()
		PlayerTalentFramePetInfo:RemoveTextures()

		PlayerTalentFramePanel1InactiveShadow:Kill()
		PlayerTalentFramePanel2InactiveShadow:Kill()
		PlayerTalentFramePanel3InactiveShadow:Kill()
		PlayerTalentFramePanel1SummaryRoleIcon:Kill()
		PlayerTalentFramePanel2SummaryRoleIcon:Kill()
		PlayerTalentFramePanel3SummaryRoleIcon:Kill()
		PlayerTalentFramePetShadowOverlay:Kill()
		PlayerTalentFrameHeaderHelpBox:Kill()
		
		if (PlayerTalentFramePetModelRotateLeftButton) then PlayerTalentFramePetModelRotateLeftButton:SetUITemplate("arrow", "left") end
		if (PlayerTalentFramePetModelRotateRightButton) then PlayerTalentFramePetModelRotateRightButton:SetUITemplate("arrow", "right") end

		PlayerTalentFrameActivateButton:SetUITemplate("button", true)
		PlayerTalentFrameToggleSummariesButton:SetUITemplate("button", true)
		PlayerTalentFrameLearnButton:SetUITemplate("button", true)
		PlayerTalentFrameResetButton:SetUITemplate("button", true)
		PlayerTalentFrameTab1:SetUITemplate("tab", true)
		PlayerTalentFrameTab2:SetUITemplate("tab", true)
		PlayerTalentFrameTab3:SetUITemplate("tab", true)
		
		PlayerTalentFrameCloseButton:SetUITemplate("closebutton")

		PlayerTalentFrame:SetUITemplate("backdrop", nil, 0, 0, 4, 0)
		PlayerTalentFramePanel1:SetUITemplate("backdrop", nil, 2, 5, 5, 5):SetBackdropColor(r, g, b, panelAlpha)
		PlayerTalentFramePanel2:SetUITemplate("backdrop", nil, 2, 5, 5, 5):SetBackdropColor(r, g, b, panelAlpha)
		PlayerTalentFramePanel3:SetUITemplate("backdrop", nil, 2, 5, 5, 5):SetBackdropColor(r, g, b, panelAlpha)
		PlayerTalentFramePetPanel:SetUITemplate("backdrop", nil, 2, 5, 5, 5):SetBackdropColor(r, g, b, panelAlpha)
		
		local strip = function(object)
			for i = 1, object:GetNumRegions() do
				local region = select(i, object:GetRegions())
				if (region:GetObjectType() == "Texture") then
					if (region:GetName()) and (region:GetName():find("Branch")) then
						region:SetDrawLayer("OVERLAY")
					elseif (region:GetName()) and (region:GetName():find("Background")) then
						-- tone down the intensity of the background images a bit, but keep them visible
						region:SetVertexColor(1, 1, 1, 1/3)
					else
						region:SetTexture(nil)
					end
				end
			end
		end
		strip(PlayerTalentFramePanel1)
		strip(PlayerTalentFramePanel2)
		strip(PlayerTalentFramePanel3)
		strip(PlayerTalentFramePetPanel)
		
		-- skin the talent group tab buttons on the side
		for i = 1, GetNumTalentGroups() do
			local button = _G["PlayerSpecTab" .. i]
			local icon = select(2, button:GetRegions())
			
			icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", 3, -3)
			icon:SetPoint("BOTTOMRIGHT", -3, 3)
			
			button:RemoveClutter()
			F.StyleActionButton(button)
		end

		-- skin the talent tree tabs
		for group = 1, GetNumTalentTabs() do
			local panel =  _G["PlayerTalentFramePanel" .. group]
			local arrow = _G["PlayerTalentFramePanel" .. group .. "Arrow"]
			local header = _G["PlayerTalentFramePanel" .. group .. "HeaderIcon"]
			local button = _G["PlayerTalentFramePanel" .. group .. "SelectTreeButton"]
			local treeSelect = _G["PlayerTalentFramePanel" .. group .. "SelectTreeButton"]
			local summary = _G["PlayerTalentFramePanel" .. group .. "Summary"]
			local summaryIcon = _G["PlayerTalentFramePanel" .. group .. "SummaryIcon"]
			
			treeSelect:SetFrameLevel(treeSelect:GetFrameLevel() + 5)
			treeSelect:SetUITemplate("button", true)

			if (summary) then 
--				summary:SetAllPoints(panel)
				summary:SetFrameLevel(summary:GetFrameLevel() + 2) 
				summary:SetUITemplate("backdrop", nil, 2-4, 5-4, 5-4, 5-4) -- identical to talent panels
				
				local a,b,_,c,_,_,_,_,_,_,_,_,d,_ = summary:GetRegions()
				a:Hide(); b:Hide(); c:Hide(); d:Hide()
			
				summaryIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			end
		
			if (arrow) then 
				arrow:SetFrameLevel(arrow:GetFrameLevel() + 2) 
			end

			if (header) then
				local icon = _G["PlayerTalentFramePanel" .. group .. "HeaderIconIcon"]
				icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				
				header:ClearAllPoints()
				header:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -5)
				
				local backdrop = header:SetUITemplate("border")
				backdrop:ClearAllPoints()
				backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 3)
				backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)

				local points = _G["PlayerTalentFramePanel" .. group .. "HeaderIconPointsSpent"]
				points:SetFontObject(GUIS_NumberFontNormal)
			end

			for talent = 1, GetNumTalents(group) do
				local button = _G["PlayerTalentFramePanel" .. group .. "Talent" .. talent]
				local icon = _G["PlayerTalentFramePanel" .. group .. "Talent" .. talent .. "IconTexture"]
				
				if (button.Rank) then
					button.Rank:SetFontObject(GUIS_NumberFontNormal)
					button.Rank:ClearAllPoints()
					button.Rank:SetPoint("BOTTOMRIGHT", -1, 3)
				end
				
				if (icon) then
					button:RemoveTextures()
					F.StyleActionButton(button)

					icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
					
					button.SetHighlightTexture = noop
					button.SetPushedTexture = noop
					button:GetNormalTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
					button:GetPushedTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
					button:GetHighlightTexture():SetAllPoints(icon)
					button:GetPushedTexture():SetAllPoints(icon)
					button:SetFrameLevel(button:GetFrameLevel() +1)
				end
			end
		end
		
		-- skin the pet talents
		local arrow = _G["PlayerTalentFramePetPanelArrow"]
		if (arrow) then
			arrow:SetFrameLevel(arrow:GetFrameLevel() + 2)
			arrow:SetFrameStrata("HIGH")
		end

		local header = _G["PlayerTalentFramePetPanelHeaderIcon"]
		if (header) then
			local icon = _G["PlayerTalentFramePetPanelHeaderIconIcon"]
			icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			
			local backdrop = header:SetUITemplate("border")
			backdrop:ClearAllPoints()
			backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 3)
			backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)

			local points = _G["PlayerTalentFramePetPanelHeaderIconPointsSpent"]
			points:SetFontObject(GUIS_NumberFontNormal)
		end

		local header = _G["PlayerTalentFramePetInfo"]
		if (header) then
			local icon = _G["PlayerTalentFramePetIcon"]
			icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			
			local backdrop = header:SetUITemplate("border")
			backdrop:ClearAllPoints()
			backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 3)
			backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)
		end

		for talent = 1, GetNumTalents(1, false, true) do
			local button = _G["PlayerTalentFramePetPanelTalent" .. talent]
			local icon = _G["PlayerTalentFramePetPanelTalent" .. talent .. "IconTexture"]
			
			if (button.Rank) then
				button.Rank:SetFontObject(GUIS_NumberFontNormal)
				button.Rank:ClearAllPoints()
				button.Rank:SetPoint("BOTTOMRIGHT")
			end
			
			if (icon) then
				button:RemoveTextures()
				F.StyleActionButton(button)

				icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				
				button.SetHighlightTexture = noop
				button.SetPushedTexture = noop
				button:GetNormalTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
				button:GetPushedTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
				button:GetHighlightTexture():SetAllPoints(icon)
				button:GetPushedTexture():SetAllPoints(icon)
				button:SetFrameLevel(button:GetFrameLevel() +1)
			end
		end
	end
	F.SkinAddOn("Blizzard_TalentUI", SkinFunc)
end
