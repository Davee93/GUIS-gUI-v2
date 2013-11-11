--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGuild")

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
		if (GuildFramePromoteButton) then GuildFramePromoteButton:SetUITemplate("arrow", "up") end
		if (GuildFrameDemoteButton) then GuildFrameDemoteButton:SetUITemplate("arrow", "down") end
		if (GuildFramePromoteButton) then GuildInfoFrame:RemoveTextures() else GuildInfoFrameInfo:RemoveTextures() end
		
		GuildNewPerksFrame:RemoveTextures()
		GuildFrameInset:RemoveTextures()
		GuildFrameBottomInset:RemoveTextures()
		GuildAllPerksFrame:RemoveTextures()
		GuildMemberDetailFrame:RemoveTextures()
		GuildMemberNoteBackground:RemoveTextures()
		GuildLogContainer:RemoveTextures()
		GuildLogFrame:RemoveTextures()
		GuildRewardsFrame:RemoveTextures()
		GuildMemberOfficerNoteBackground:RemoveTextures()
		GuildTextEditContainer:RemoveTextures()
		GuildTextEditFrame:RemoveTextures()
		if (GuildRecruitmentRolesFrame) then GuildRecruitmentRolesFrame:RemoveTextures() end
		if (GuildRecruitmentAvailabilityFrame) then GuildRecruitmentAvailabilityFrame:RemoveTextures() end
		if (GuildRecruitmentInterestFrame) then GuildRecruitmentInterestFrame:RemoveTextures() end
		if (GuildRecruitmentLevelFrame) then GuildRecruitmentLevelFrame:RemoveTextures() end
		if (GuildRecruitmentCommentFrame) then GuildRecruitmentCommentFrame:RemoveTextures() end
		if (GuildRecruitmentCommentInputFrame) then GuildRecruitmentCommentInputFrame:RemoveTextures() end 
		if (GuildInfoFrameApplicantsContainer) then GuildInfoFrameApplicantsContainer:RemoveTextures() end
		if (GuildInfoFrameApplicants) then GuildInfoFrameApplicants:RemoveTextures() end
		GuildNewsBossModel:RemoveTextures()
		GuildNewsBossModelTextFrame:RemoveTextures()
		GuildXPBarLeft:RemoveTextures()
		GuildXPBarRight:RemoveTextures()
		GuildXPBarMiddle:RemoveTextures()
		GuildXPBarBG:RemoveTextures()
		GuildXPBarShadow:RemoveTextures()
		GuildXPBarDivider1:RemoveTextures()
		GuildXPBarDivider2:RemoveTextures()
		GuildXPBarDivider3:RemoveTextures()
		GuildXPBarDivider4:RemoveTextures()
		GuildLevelFrame:RemoveTextures()
		GuildFactionBarLeft:RemoveTextures()
		GuildFactionBarRight:RemoveTextures()
		GuildFactionBarMiddle:RemoveTextures()
		GuildFactionBarBG:RemoveTextures()
		GuildFactionBarShadow:RemoveTextures()
		GuildLatestPerkButton:RemoveTextures()
		GuildNextPerkButton:RemoveTextures()
		GuildRosterColumnButton1:RemoveTextures()
		GuildRosterColumnButton2:RemoveTextures()
		GuildRosterColumnButton3:RemoveTextures()
		GuildRosterColumnButton4:RemoveTextures()
		if (GuildInfoFrameTab1) then GuildInfoFrameTab1:RemoveTextures() end
		if (GuildInfoFrameTab2) then GuildInfoFrameTab2:RemoveTextures() end 
		if (GuildInfoFrameTab3) then GuildInfoFrameTab3:RemoveTextures() end
		GuildFrame:RemoveTextures()
		GuildNewsFrame:RemoveTextures()
		GuildNewsFiltersFrame:RemoveTextures()
		
		GuildFrameTabardEmblem:Kill()
	
		GuildPerksToggleButton:SetUITemplate("button", true)
		GuildMemberRemoveButton:SetUITemplate("button", true)
		GuildMemberGroupInviteButton:SetUITemplate("button", true)
		GuildAddMemberButton:SetUITemplate("button", true)
		GuildViewLogButton:SetUITemplate("button", true)
		GuildControlButton:SetUITemplate("button", true)
		GuildTextEditFrameAcceptButton:SetUITemplate("button", true)
		if (GuildRecruitmentListGuildButton) then GuildRecruitmentListGuildButton:SetUITemplate("button", true) end
		if (GuildRecruitmentInviteButton) then GuildRecruitmentInviteButton:SetUITemplate("button", true) end
		if (GuildRecruitmentMessageButton) then GuildRecruitmentMessageButton:SetUITemplate("button", true) end
		if (GuildRecruitmentDeclineButton) then GuildRecruitmentDeclineButton:SetUITemplate("button", true) end
		if (GuildRecruitmentQuestButton) then GuildRecruitmentQuestButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentDungeonButton) then GuildRecruitmentDungeonButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentRaidButton) then GuildRecruitmentRaidButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentPvPButton) then GuildRecruitmentPvPButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentRPButton) then GuildRecruitmentRPButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentWeekdaysButton) then GuildRecruitmentWeekdaysButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentWeekendsButton) then GuildRecruitmentWeekendsButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentHealerButton) and (GuildRecruitmentHealerButton.checkButton) then GuildRecruitmentHealerButton.checkButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentTankButton) and (GuildRecruitmentTankButton.checkButton) then GuildRecruitmentTankButton.checkButton:SetUITemplate("checkbutton") end
		if (GuildRecruitmentDamagerButton) and (GuildRecruitmentDamagerButton.checkButton) then GuildRecruitmentDamagerButton.checkButton:SetUITemplate("checkbutton") end
		GuildRosterShowOfflineButton:SetUITemplate("checkbutton")

		for i = 1,7 do _G["GuildNewsFilterButton" .. i]:SetUITemplate("checkbutton") end

		if (GuildRecruitmentLevelAnyButton) then GuildRecruitmentLevelAnyButton:SetUITemplate("radiobutton", true) end
		if (GuildRecruitmentLevelMaxButton) then GuildRecruitmentLevelMaxButton:SetUITemplate("radiobutton", true) end
	
		GuildMemberDetailCloseButton:SetUITemplate("closebutton")
		GuildNewsFiltersFrameCloseButton:SetUITemplate("closebutton")
		GuildFrameCloseButton:SetUITemplate("closebutton")

		if (GuildMemberRankDropdown) then GuildMemberRankDropdown:SetUITemplate("dropdown", true) end
		GuildRosterViewDropdown:SetUITemplate("dropdown", true)
		
		GuildFrame:SetUITemplate("simplebackdrop")
		GuildLogFrame:SetUITemplate("simplebackdrop")
		GuildNewsBossModel:SetUITemplate("simplebackdrop")
		GuildNewsFiltersFrame:SetUITemplate("simplebackdrop")
		GuildTextEditFrame:SetUITemplate("simplebackdrop")
		GuildMemberDetailFrame:SetUITemplate("simplebackdrop")
		if (GuildRecruitmentInterestFrame) then GuildRecruitmentInterestFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha) end
		if (GuildRecruitmentLevelFrame) then GuildRecruitmentLevelFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha) end
		if (GuildRecruitmentCommentFrame) then GuildRecruitmentCommentFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha) end
		if (GuildRecruitmentAvailabilityFrame) then GuildRecruitmentAvailabilityFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha) end
		if (GuildRecruitmentRolesFrame) then GuildRecruitmentRolesFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha) end
		GuildMemberNoteBackground:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		GuildMemberOfficerNoteBackground:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		GuildTextEditContainer:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)

		GuildLogScrollFrame:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
		if (GuildInfoChallenges) then GuildInfoChallenges:SetUITemplate("backdrop", nil, 0, 0, 0, 4):SetBackdropColor(r, g, b, panelAlpha) end
		
		if (F.IsBuild(4,3,0)) then
			if (GuildInfoFrameInfoMOTDScrollFrame) then GuildInfoFrameInfoMOTDScrollFrame:SetUITemplate("backdrop", nil, -2, -14, -4, -14):SetBackdropColor(r, g, b, panelAlpha) end
			if (GuildInfoFrameInfoMOTDScrollFrameScrollBar) then GuildInfoFrameInfoMOTDScrollFrameScrollBar:SetUITemplate("scrollbar") end
		else 
			if (GuildInfoMOTD) and (GuildInfoMOTD.SetUITemplate) then GuildInfoMOTD:SetUITemplate("backdrop", nil, -2, -14, -4, -14):SetBackdropColor(r, g, b, panelAlpha) end
		end
		
		GuildInfoDetailsFrame:SetUITemplate("backdrop", nil, -2, -14, -4, -14):SetBackdropColor(r, g, b, panelAlpha)
	
		GuildPerksContainerScrollBar:SetUITemplate("scrollbar")	
		GuildRosterContainerScrollBar:SetUITemplate("scrollbar")
		GuildNewsContainerScrollBar:SetUITemplate("scrollbar")
		GuildInfoDetailsFrameScrollBar:SetUITemplate("scrollbar")
		GuildTextEditScrollFrameScrollBar:SetUITemplate("scrollbar")
		GuildLogScrollFrameScrollBar:SetUITemplate("scrollbar")
		GuildRewardsContainerScrollBar:SetUITemplate("scrollbar")
		if (GuildInfoFrameApplicantsContainerScrollBar) then GuildInfoFrameApplicantsContainerScrollBar:SetUITemplate("scrollbar") end
		
		GuildFrameTab1:SetUITemplate("tab", true)
		GuildFrameTab2:SetUITemplate("tab", true)
		GuildFrameTab3:SetUITemplate("tab", true)
		GuildFrameTab4:SetUITemplate("tab", true)
		GuildFrameTab5:SetUITemplate("tab", true)
		
		--GuildMemberRankDropdownText:Kill() -- why did I do this...?
		
		--------------------------------------------------------------------------------------------------
		--		Guild Level TODO: fix this stuff, make it update
		--------------------------------------------------------------------------------------------------		
		GuildLevelFrame:Kill()
		
		--------------------------------------------------------------------------------------------------
		--		Guild XP Bar
		--------------------------------------------------------------------------------------------------		
		GuildXPFrame:ClearAllPoints()
		GuildXPFrame:SetPoint("TOP", GuildFrame, "TOP", 0, -40)
		
		GuildXPBar:SetPoint("TOP", 0, -50)
		GuildXPBar:SetHeight(14)

		GuildXPBar.progress:SetTexture(M["StatusBar"]["StatusBar"])
		GuildXPBar.progress:SetPoint("LEFT", GuildXPBar, "LEFT", 0, 0)
		GuildXPBar.progress:SetPoint("TOP", GuildXPBar, "TOP", 0, 0)
		GuildXPBar.progress:SetPoint("BOTTOM", GuildXPBar, "BOTTOM", 0, 0)

		GuildXPBar.cap:SetTexture(M["StatusBar"]["StatusBar"])
		GuildXPBar.cap:SetPoint("TOP", GuildXPBar, "TOP", 0, 0)
		GuildXPBar.cap:SetPoint("BOTTOM", GuildXPBar, "BOTTOM", 0, 0)

		GuildXPBarText:SetFontObject(GUIS_NumberFontNormal)
		GuildXPBarText:ClearAllPoints()
		GuildXPBarText:SetPoint("CENTER")
		
		GuildXPFrameLevelText:SetPoint("BOTTOM", GuildXPBar, "TOP", 0, 4)
		GuildXPFrameLevelText:SetFontObject(GUIS_SystemFontNormal)

		GuildXPBarCapMarker:RemoveTextures()
	
		GuildXPBar.backdrop = GuildXPBar:SetUITemplate("border")
		GuildXPBar.eyeCandy = CreateFrame("Frame", nil, GuildXPBar.backdrop)
		GuildXPBar.eyeCandy:SetPoint("TOPLEFT", GuildXPBar.backdrop, "TOPLEFT", 3, -3)
		GuildXPBar.eyeCandy:SetPoint("BOTTOMRIGHT", GuildXPBar.backdrop, "BOTTOMRIGHT", -3, 3)
		F.GlossAndShade(GuildXPBar.eyeCandy)
		
		--------------------------------------------------------------------------------------------------
		--		Guild Faction Bar
		--------------------------------------------------------------------------------------------------		
		GuildFactionBar.progress:SetTexture(M["StatusBar"]["StatusBar"])
		GuildFactionBar.progress:SetPoint("LEFT", GuildFactionBar, "LEFT", 0, 0)
		GuildFactionBar.progress:SetPoint("TOP", GuildFactionBar, "TOP", 0, 0)
		GuildFactionBar.progress:SetPoint("BOTTOM", GuildFactionBar, "BOTTOM", 0, 0)

		GuildFactionBar.cap:SetTexture(M["StatusBar"]["StatusBar"])
		GuildFactionBar.cap:SetPoint("TOP", GuildFactionBar, "TOP", 0, 0)
		GuildFactionBar.cap:SetPoint("BOTTOM", GuildFactionBar, "BOTTOM", 0, 0)

		GuildFactionBarCapMarker:RemoveTextures()

		-- they don't use the Text here, Label is used for the value instead
--		GuildFactionBarText:SetFontObject(GUIS_NumberFontNormal)
--		GuildFactionBarText:ClearAllPoints()
--		GuildFactionBarText:SetPoint("CENTER")

		GuildFactionBarLabel:ClearAllPoints()
		GuildFactionBarLabel:SetPoint("CENTER")
		GuildFactionBarLabel:SetFontObject(GUIS_NumberFontNormal)

		GuildFactionBar.backdrop = GuildFactionBar:SetUITemplate("border")
		GuildFactionBar.eyeCandy = CreateFrame("Frame", nil, GuildFactionBar.backdrop)
		GuildFactionBar.eyeCandy:SetPoint("TOPLEFT", GuildFactionBar.backdrop, "TOPLEFT", 3, -3)
		GuildFactionBar.eyeCandy:SetPoint("BOTTOMRIGHT", GuildFactionBar.backdrop, "BOTTOMRIGHT", -3, 3)
		F.GlossAndShade(GuildFactionBar.eyeCandy)

		--------------------------------------------------------------------------------------------------
		--		Guild Perks
		--------------------------------------------------------------------------------------------------		
		GuildLatestPerkButtonIconTexture:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		GuildLatestPerkButtonIconTexture:ClearAllPoints()
		GuildLatestPerkButtonIconTexture:SetPoint("TOPLEFT", 3, -3)
		
		GuildLatestPerkButton.backdrop = GuildLatestPerkButton:SetUITemplate("border")
		GuildLatestPerkButton.backdrop:ClearAllPoints()
		GuildLatestPerkButton.backdrop:SetPoint("TOPLEFT", GuildLatestPerkButtonIconTexture, "TOPLEFT", -3, 3)
		GuildLatestPerkButton.backdrop:SetPoint("BOTTOMRIGHT", GuildLatestPerkButtonIconTexture, "BOTTOMRIGHT", 3, -3)

		GuildNextPerkButtonIconTexture:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		GuildNextPerkButtonIconTexture:ClearAllPoints()
		GuildNextPerkButtonIconTexture:SetPoint("TOPLEFT", 3, -3)
		
		GuildNextPerkButton.backdrop = GuildNextPerkButton:SetUITemplate("border")
		GuildNextPerkButton.backdrop:ClearAllPoints()
		GuildNextPerkButton.backdrop:SetPoint("TOPLEFT", GuildNextPerkButtonIconTexture, "TOPLEFT", -3, 3)
		GuildNextPerkButton.backdrop:SetPoint("BOTTOMRIGHT", GuildNextPerkButtonIconTexture, "BOTTOMRIGHT", 3, -3)
		
		local makeHighlight = function(name, i, addSelectTexture)
			local button = _G[name .. i]
			
			button:SetBackdrop(nil)
			button.SetBackdrop = noop
			
			button:CreateHighlight()
			button:CreatePushed()

			-- can it get any worse?
			local selected = button:GetRegions()
			if (addSelectTexture) and  (selected) and (selected.GetObjectType) and (selected:GetObjectType() == "Texture") then
				selected:SetTexture(C["value"][1], C["value"][2], C["value"][3], 1/4)
			end
		end
		
--		for i = 1, 5 do
--			makeHighlight("LookingForGuildBrowseFrameContainerButton", i, true)
--			makeHighlight("LookingForGuildAppsFrameContainerButton", i)
--		end

		local SkinNewButtons = function()
			for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
			end
		end

		for i = 1, 8 do
			local button = _G["GuildRewardsContainerButton" .. i]
			button:RemoveTextures()

			if (button.icon) then
				button.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				button.icon:ClearAllPoints()
				button.icon:SetPoint("TOPLEFT", 6, -6)
				button.icon:SetSize(button:GetHeight() - 10, button:GetHeight() - 10)
				
				button.backdrop = button:SetUITemplate("backdrop")
				button.backdrop:SetPoint("TOPLEFT", button.icon, "TOPLEFT", -3, 3)
				button.backdrop:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 3, -3)

				button.icon:SetParent(button.backdrop)
			end
		end

		for i = 1, 8 do
			local button = _G["GuildPerksContainerButton" .. i]
			button:RemoveTextures()
		
			if (button.icon) then
				button.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				button.icon:ClearAllPoints()
				button.icon:SetPoint("TOPLEFT", 8, -8)
				button.icon:SetSize(button:GetHeight() - 16, button:GetHeight() - 16)
				
				button.backdrop = button:SetUITemplate("backdrop")
				button.backdrop:SetPoint("TOPLEFT", button.icon, "TOPLEFT", -3, 3)
				button.backdrop:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 3, -3)

				button.icon:SetParent(button.backdrop)
			end
		end
		
		for i,button in pairs(GuildNewsContainer.buttons) do
			button:RemoveTextures(true)
		end
		
		for i,button in pairs(GuildRosterContainer.buttons) do
			local header = _G[button:GetName() .. "HeaderButton"]
			local a, b, c = header:GetRegions()
			a:SetAlpha(0)
			b:SetAlpha(0)
			c:SetAlpha(0)
			
			header:SetUITemplate("button"):SetBackdropColor(r, g, b, 1)
		end

		for i = 1, GuildTextEditFrame:GetNumChildren() do
			local child = select(i, GuildTextEditFrame:GetChildren())
			local point = select(1, child:GetPoint())
			if (child:GetName()) and (child:GetName():find("CloseButton")) then
				if (point == "TOPRIGHT") then
					child:SetUITemplate("closebutton")
				else
					child:SetUITemplate("button")
				end
			end
		end	
		
		for i = 1, GuildLogFrame:GetNumChildren() do
			local child = select(i, GuildLogFrame:GetChildren())
			local point = select(1, child:GetPoint())
			if (child:GetName()) and (child:GetName():find("CloseButton")) then
				if (point == "TOPRIGHT") then
					child:SetUITemplate("closebutton")
				else
					child:SetUITemplate("button")
				end
			end
		end
	end
	F.SkinAddOn("Blizzard_GuildUI", SkinFunc)
	
end
