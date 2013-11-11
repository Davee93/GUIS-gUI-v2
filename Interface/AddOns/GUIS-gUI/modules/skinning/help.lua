--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningBlizzardHelp")

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
	
	if not(F.IsBuild(4,2,0)) or not(HelpFrameKnowledgebase) then
		HelpFrame:RemoveTextures()
		HelpFrameHeader:RemoveTextures()

		HelpFrame:SetUITemplate("simplebackdrop")
		HelpFrameCloseButton:SetUITemplate("closebutton")
	
		return
	end
	
	HelpFrame:RemoveTextures()
	HelpFrameHeader:RemoveTextures()
	HelpFrameKnowledgebase:RemoveTextures()
	HelpFrameKnowledgebaseErrorFrame:RemoveTextures()
	HelpFrameLeftInset:RemoveTextures()
	HelpFrameMainInset:RemoveTextures()
	HelpFrameTicketScrollFrame:RemoveTextures()
	HelpFrameKnowledgebaseNavBar:RemoveTextures()
	HelpFrameKnowledgebaseNavBarOverlay:RemoveTextures()
	
	HelpFrameGM_ResponseScrollFrame1ScrollBar:SetUITemplate("scrollbar")
	HelpFrameGM_ResponseScrollFrame2ScrollBar:SetUITemplate("scrollbar")
	
	HelpFrameGM_ResponseNeedMoreHelp:SetUITemplate("button")
	HelpFrameGM_ResponseCancel:SetUITemplate("button")
	
	for i = 1, HelpFrameGM_Response:GetNumChildren() do
		local child = select(i, HelpFrameGM_Response:GetChildren())
		if (child:GetObjectType() == "Frame") then
--			child:SetBackdrop(nil)
--			child.SetBackdrop = noop
			child:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		end
	end

	local buttons = {
		"GMChatOpenLog";
		"HelpFrameAccountSecurityOpenTicket";
		"HelpFrameButton1";
		"HelpFrameButton2";
		"HelpFrameButton3";
		"HelpFrameButton4";
		"HelpFrameButton5";
		"HelpFrameButton6";
		"HelpFrameButton16";
		"HelpFrameCharacterStuckStuck";
		"HelpFrameKnowledgebaseNavBarHomeButton";
		"HelpFrameKnowledgebaseSearchButton";
		"HelpFrameOpenTicketHelpTopIssues";
		"HelpFrameOpenTicketHelpOpenTicket";
		"HelpFrameReportAbuseOpenTicket";
		"HelpFrameReportBugSubmit";
		"HelpFrameReportLagAuctionHouse";
		"HelpFrameReportLagChat";
		"HelpFrameReportLagLoot";
		"HelpFrameReportLagMail";
		"HelpFrameReportLagMovement";
		"HelpFrameReportLagSpell";
		"HelpFrameTicketCancel";
		"HelpFrameTicketSubmit";
		"HelpFrameSubmitSuggestionSubmit";
	}
	
	for _,buttonName in pairs(buttons) do
		local button = _G[buttonName]
		
		if (button) then
			button:SetUITemplate("button")
			
			if (button.text) then
				button.text:ClearAllPoints()
				button.text:SetPoint("CENTER")
				button.text:SetJustifyH("CENTER")
			end
		end
	end

	HelpFrameCloseButton:SetUITemplate("closebutton")
	HelpFrameKnowledgebaseErrorFrameCloseButton:SetUITemplate("closebutton")
	HelpFrameKnowledgebaseSearchBox:SetUITemplate("editbox")
	HelpFrameTicketScrollFrameScrollBar:SetUITemplate("scrollbar")
	HelpFrameKnowledgebaseScrollFrameScrollBar:SetUITemplate("scrollbar")
	HelpFrameKnowledgebaseScrollFrame2ScrollBar:SetUITemplate("scrollbar")
	
	if (HelpFrameReportBugScrollFrameScrollBar) then
		HelpFrameReportBugScrollFrameScrollBar:SetUITemplate("scrollbar")
	end

	if (HelpFrameSubmitSuggestionScrollFrameScrollBar) then
		HelpFrameSubmitSuggestionScrollFrameScrollBar:SetUITemplate("scrollbar")
	end
	
	HelpFrame:SetUITemplate("simplebackdrop")
	HelpFrameHeader:SetUITemplate("simplebackdrop")
	HelpFrameKnowledgebase:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	HelpFrameKnowledgebaseErrorFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	HelpFrameLeftInset:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	HelpFrameMainInset:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	HelpFrameTicketScrollFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	
	F.StyleActionButton(HelpFrameCharacterStuckHearthstone)
	
	local fixTexCoord = function(self)
		self:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
		self:GetNormalTexture().SetTexCoord = noop

		self:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
		self:GetPushedTexture().SetTexCoord = noop

		self:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
		self:GetHighlightTexture().SetTexCoord = noop

		self.SetNormalTexture = noop
		self.SetHighlightTexture = noop
		self.SetDisabledTexture = noop
	end
	
	HelpFrameKnowledgebaseNavBarOverflowButton:SetUITemplate("arrow", "left")
	fixTexCoord(HelpFrameKnowledgebaseNavBarOverflowButton)
	
	for i = 1, HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren() do
		local frame = _G["HelpFrameKnowledgebaseScrollFrameButton" .. i]
		
		frame:RemoveTextures()
		frame:CreateHighlight()
		frame:CreatePushed()
	end

	local updateNavButtons = function(self)
		if not(self == HelpFrameKnowledgebaseNavBar) then
			return
		end
		
		local navButton = self.navList[#self.navList]
		
		if not(navButton.GUISskinned) then
			navButton:SetUITemplate("button-indented", true)
			navButton.arrowUp:SetTexture("")
			navButton.arrowDown:SetTexture("")
			navButton.selected:SetTexture("")
			
			navButton.GUISskinned = true
		end

		-- lock this sucker down
		local NumberTwo = _G[self:GetName() .."Button2"]
		if (NumberTwo) and not(NumberTwo.suckerLocked) then
			local parent = select(2, NumberTwo:GetPoint())
			NumberTwo:ClearAllPoints()
			NumberTwo:SetPoint("LEFT", parent, "RIGHT", 0, 0)
			NumberTwo.ClearAllPoints = noop
			NumberTwo.SetPoint = noop
		end
	end
	hooksecurefunc("NavBar_AddButton", updateNavButtons)
end
