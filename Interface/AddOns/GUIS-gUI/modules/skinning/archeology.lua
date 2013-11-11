--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningArcheology")

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
		ArchaeologyFrame:RemoveTextures()
		ArchaeologyFrameBgLeft:RemoveTextures(true)
		ArchaeologyFrameBgRight:RemoveTextures(true)
		ArchaeologyFrameSummaryPage:RemoveTextures()
		ArchaeologyFrameCompletedPage:RemoveTextures()
		ArchaeologyFrameInset:RemoveTextures()
		
		ArchaeologyFrameCompletedPagePrevPageButton:SetUITemplate("arrow", "left")
		ArchaeologyFrameCompletedPageNextPageButton:SetUITemplate("arrow", "right")
		
		ArchaeologyFrameArtifactPageSolveFrameSolveButton:SetUITemplate("button", true)
		ArchaeologyFrameCloseButton:SetUITemplate("closebutton")
		ArchaeologyFrameRaceFilter:SetUITemplate("dropdown", true)
		
		ArchaeologyFrame:SetUITemplate("simplebackdrop")
		
		ArchaeologyFrameRankBar:SetUITemplate("statusbar", true)
		ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetUITemplate("statusbar", true)
		
		ArchaeologyFramePortrait:Kill()
		
		ArchaeologyFrameInfoButton:ClearAllPoints()
		ArchaeologyFrameInfoButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPLEFT", 8, -8)
		
		ArchaeologyFrameCompletedPage.infoText:SetTextColor(unpack(C["index"]))
		ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(unpack(C["value"]))
		ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(unpack(C["index"]))
		ArchaeologyFrameHelpPageDigTitle:SetTextColor(unpack(C["value"]))
		ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(unpack(C["index"]))
		ArchaeologyFrameHelpPageTitle:SetTextColor(unpack(C["value"]))
				
		for i = 1, ARCHAEOLOGY_MAX_RACES do
			local frame = _G["ArchaeologyFrameSummaryPageRace" .. i]
			if (frame) then
				frame.raceName:SetTextColor(unpack(C["index"]))
			end
		end
		
		for i = 1, ArchaeologyFrameCompletedPage:GetNumRegions() do
			local region = select(i, ArchaeologyFrameCompletedPage:GetRegions())
			if (region:GetObjectType() == "FontString") then
				region:SetTextColor(unpack(C["value"]))
			end
		end
		
		for i = 1, ArchaeologyFrameSummaryPage:GetNumRegions() do
			local region = select(i, ArchaeologyFrameSummaryPage:GetRegions())
			if (region:GetObjectType() == "FontString") then
				region:SetTextColor(unpack(C["value"]))
			end
		end

		local backdrop = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPage):SetUITemplate("itembackdrop", ArchaeologyFrameArtifactPageIcon)
		ArchaeologyFrameArtifactPageIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		ArchaeologyFrameArtifactPageIcon:SetParent(backdrop)
		ArchaeologyFrameArtifactPageIcon:SetDrawLayer("OVERLAY")
			
		for i=1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
			local artifact = _G["ArchaeologyFrameCompletedPageArtifact" .. i]
			
			if (artifact) then
				local icon = _G[artifact:GetName() .. "Icon"]
				local bg = _G[artifact:GetName() .. "Bg"]
				local border = _G[artifact:GetName() .. "Border"]
				local name = _G[artifact:GetName() .. "ArtifactName"]
				local subtext = _G[artifact:GetName() .. "ArtifactSubText"]
			
				if (artifact) then artifact:RemoveTextures() end
				
				bg:Kill()
				border:Kill()

				local BackdropHolder = CreateFrame("Frame", nil, artifact)
				BackdropHolder:SetFrameLevel(artifact:GetFrameLevel() - 1)
				BackdropHolder:SetAllPoints(icon)

				icon.backdrop = BackdropHolder:SetUITemplate("border")
				icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				icon:SetDrawLayer("OVERLAY")
				icon:SetParent(icon.backdrop)
				
				name:SetTextColor(unpack(C["value"]))
				subtext:SetTextColor(0.6, 0.6, 0.6)
			end
		end
	end
	F.SkinAddOn("Blizzard_ArchaeologyUI", SkinFunc)

end
