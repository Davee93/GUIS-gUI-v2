--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningSpellbook")

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
	
	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])

	SpellBookFrame:RemoveTextures(true)
	SpellBookFrameInset:RemoveTextures()
	SpellBookSpellIconsFrame:RemoveTextures()
	SpellBookSideTabsFrame:RemoveTextures()
	SpellBookPageNavigationFrame:RemoveTextures()
	SpellBookPage1:RemoveTextures()
	SpellBookPage2:RemoveTextures()
	SpellBookCompanionsModelFrame:RemoveTextures()
	SpellBookCompanionModelFrame:RemoveTextures()
	SpellBookCompanionModelFrameShadowOverlay:RemoveTextures()
	PrimaryProfession1IconBorder:RemoveTextures()
	PrimaryProfession2IconBorder:RemoveTextures()
	
	SpellBookPrevPageButton:SetUITemplate("arrow")
	SpellBookNextPageButton:SetUITemplate("arrow")
	
	if (SpellBookCompanionModelFrameRotateRightButton) then SpellBookCompanionModelFrameRotateRightButton:SetUITemplate("arrow") end
	if (SpellBookCompanionModelFrameRotateLeftButton) then SpellBookCompanionModelFrameRotateLeftButton:SetUITemplate("arrow") end

	SpellBookCompanionSummonButton:SetUITemplate("button")

	SpellBookFrameCloseButton:SetUITemplate("closebutton")

	SpellBookFrame:SetUITemplate("backdrop", nil, 0, 0, 3, 0)
	SpellBookCompanionModelFrame:SetUITemplate("backdrop", nil, -2, 2, 2, -2):SetBackdropColor(r, g, b, panelAlpha)

	SpellBookFrameTabButton1:SetUITemplate("tab", true)
	SpellBookFrameTabButton2:SetUITemplate("tab", true)
	SpellBookFrameTabButton3:SetUITemplate("tab", true)
	SpellBookFrameTabButton4:SetUITemplate("tab", true)
	SpellBookFrameTabButton5:SetUITemplate("tab", true)
	
	SpellBookPageText:SetTextColor(0.6, 0.6, 0.6)
	
	PrimaryProfession1UnlearnButton:SetPoint("RIGHT", PrimaryProfession1StatusBar, "LEFT", -8, 1)
	PrimaryProfession2UnlearnButton:SetPoint("RIGHT", PrimaryProfession2StatusBar, "LEFT", -8, 1)
	
	do
		local headers = {
			"PrimaryProfession1";
			"PrimaryProfession2";
			"SecondaryProfession1";
			"SecondaryProfession2";
			"SecondaryProfession3";
			"SecondaryProfession4";
		}
		for _, header in pairs(headers) do
			_G[header.."Missing"]:SetTextColor(unpack(C["value"]))
			_G[header].missingText:SetTextColor(0.6, 0.6, 0.6)
		end
		headers = nil
	end
	
	do	
		local buttons = {
			"PrimaryProfession1SpellButtonTop";
			"PrimaryProfession1SpellButtonBottom";
			"PrimaryProfession2SpellButtonTop";
			"PrimaryProfession2SpellButtonBottom";
			"SecondaryProfession1SpellButtonLeft";
			"SecondaryProfession1SpellButtonRight";
			"SecondaryProfession2SpellButtonLeft";
			"SecondaryProfession2SpellButtonRight";
			"SecondaryProfession3SpellButtonLeft";
			"SecondaryProfession3SpellButtonRight";
			"SecondaryProfession4SpellButtonLeft";
			"SecondaryProfession4SpellButtonRight";	
		}
		for _, buttonName in pairs(buttons) do
			local button = _G[buttonName]
			local highlight = _G[buttonName .. "Highlight"]
			local icon = _G[buttonName .. "IconTexture"]
			local rank = _G[buttonName .. "SubSpellName"]
			
			button:RemoveTextures()

			if (rank) then 
				rank:SetTextColor(unpack(C["index"])) 
			end
			
			if (highlight) then
				highlight:SetTexture(1, 1, 1, 1/3)
				highlight:ClearAllPoints()
				highlight:SetAllPoints(icon)

				local running
				hooksecurefunc(highlight, "SetTexture", function(self, ...)
					if not(running) then
						running = true
						self:SetTexture(1, 1, 1, 1/3)
						running = false
					end
				end)
			end
			
			if (icon) then
				icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", 3, -3)
				icon:SetPoint("BOTTOMRIGHT", -3, 3)

				local backdrop = button:SetUITemplate("itembackdrop")
				backdrop:ClearAllPoints()
				backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 3)
				backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)
				
				F.GlossAndShade(button, icon)
			end					
		end	
		buttons = nil
	end

	do
		local statusbars = {
			"PrimaryProfession1StatusBar",	
			"PrimaryProfession2StatusBar",	
			"SecondaryProfession1StatusBar",	
			"SecondaryProfession2StatusBar",	
			"SecondaryProfession3StatusBar",	
			"SecondaryProfession4StatusBar",
		}
		for _, statusbar in pairs(statusbars) do
			local statusbar = _G[statusbar]

			statusbar:RemoveTextures()
			statusbar:SetUITemplate("statusbar", true)

			statusbar:SetStatusBarColor(0, 190/255, 0)
			statusbar.rankText:ClearAllPoints()
			statusbar.rankText:SetPoint("CENTER")
			statusbar.rankText:SetFontObject(GUIS_NumberFontNormal)
		end	
		statusbars = nil
	end

	for i = 1, NUM_COMPANIONS_PER_PAGE do
		local button = _G["SpellBookCompanionButton" .. i]
		local icon = _G["SpellBookCompanionButton" .. i .. "IconTexture"]
		
		button:RemoveTextures()
		
		if (icon) then
			icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			local backdrop = button:SetUITemplate("itembackdrop")
			
			F.GlossAndShade(button, icon)
			
			local highlight = button:CreateTexture(nil, "OVERLAY")
			highlight:SetTexture(1, 1, 1, 1/3)
			highlight:SetAllPoints(icon)
			highlight:Hide()
			
			button:HookScript("OnEnter", function() highlight:Show() end)
			button:HookScript("OnLeave", function() highlight:Hide() end)
		end	
	end

	for i = 1, MAX_SKILLLINE_TABS do
		_G["SpellBookSkillLineTab" .. i .. "Flash"]:RemoveTextures()
		
		local tab = _G["SpellBookSkillLineTab" .. i]
		if (tab) then
			tab:RemoveTextures()
			
			tab:SetUITemplate("itembackdrop")
			tab:GetNormalTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
			tab:CreateHighlight()
			tab:CreateChecked()

			-- need to be ultracareful here, or we'll taint the SpellBookFrame
			local point, parent, rpoint, x, y = tab:GetPoint()
			tab:SetPoint(point, parent, rpoint, 5, y)
		end
	end

	local first = true
	local updateSpellButtons = function()
		for i = 1, SPELLS_PER_PAGE do
			local button = _G["SpellButton" .. i]
			local icon = _G["SpellButton" .. i .. "IconTexture"]
			local highlight = _G["SpellButton" .. i .. "Highlight"]
			
			if (first) then
				for i = 1, button:GetNumRegions() do
					local region = select(i, button:GetRegions())
					if (region:GetObjectType() == "Texture") then
						if (region:GetTexture() ~= "Interface\\Buttons\\ActionBarFlyoutButton") then
							region:SetTexture("")
						end
					end
				end
			end
			
			if (highlight) then
				highlight:SetTexture(1, 1, 1, 1/3)
				highlight:ClearAllPoints()
				highlight:SetAllPoints(icon)
			end

			if (icon) then
				icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				local backdrop = button:SetUITemplate("itembackdrop")
				
				F.GlossAndShade(button, icon)
			end	
			
			local r, g, b = _G["SpellButton" .. i .. "SpellName"]:GetTextColor()

			if (r < 0.8) then
				_G["SpellButton" .. i .. "SpellName"]:SetTextColor(0.6, 0.6, 0.6)
			end
			
			_G["SpellButton" .. i .. "SubSpellName"]:SetTextColor(0.6, 0.6, 0.6)
			_G["SpellButton" .. i .. "RequiredLevelString"]:SetTextColor(0.6, 0.6, 0.6)
		end
		
		first = nil
	end

	local updateSkillTab = function()
		for i = 1, MAX_SKILLLINE_TABS do
			local tab = _G["SpellBookSkillLineTab" .. i]

			if (select(5, GetSpellTabInfo(i))) then
				tab:GetNormalTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
			end

			F.GlossAndShade(tab, tab:GetNormalTexture())
		end
	end
	
	local updatePrimaryProfessions = function(self, index)
		local name = self:GetName()
		
		if not(name:find("Primary")) then
			return
		end
		
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier
		if (index) then
			name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier = GetProfessionInfo(index)
		else
			texture = "Interface\\Icons\\INV_Scroll_04"
		end
		
		local icon = self.icon
		
		if (icon) then
			icon:SetDesaturated(false)
			icon:SetTexture(texture)
			icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			
			local parentName = self:GetParent():GetName()
			if (parentName) then
				local border = _G[parentName .. "IconBorder"]
				if (border) then
					icon:ClearAllPoints()
					icon:SetPoint("TOPLEFT", border, "TOPLEFT", 3, -3)
					icon:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -3, 3)
				end
			end

			local backdrop = self:SetUITemplate("itembackdrop")
			backdrop:ClearAllPoints()
			backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 3)
			backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)
			
			F.GlossAndShade(self, icon)
		end
	end
	
	updateSpellButtons()
	updateSkillTab()

	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions()
	updatePrimaryProfessions(PrimaryProfession1, prof1)
	updatePrimaryProfessions(PrimaryProfession2, prof2)
	
	hooksecurefunc("FormatProfession", updatePrimaryProfessions)
	hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", updateSkillTab)
	hooksecurefunc("SpellButton_UpdateButton", updateSpellButtons)
end
