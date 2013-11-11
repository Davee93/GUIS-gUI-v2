--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningFriends")

-- Lua API
local pairs, unpack = pairs, unpack

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
	
	AddFriendNoteFrame:RemoveTextures()
	ChannelFrameDaughterFrame:RemoveTextures()
	ChannelListScrollFrame:RemoveTextures()
	ChannelRoster:RemoveTextures()
	FriendsFrame:RemoveTextures(true)
	FriendsFrameFriendsScrollFrame:RemoveTextures()
	FriendsFriendsFrame:RemoveTextures()
	FriendsFriendsList:RemoveTextures()
	FriendsFriendsNoteFrame:RemoveTextures()
	FriendsFramePendingButton1:RemoveTextures()
	FriendsFramePendingButton2:RemoveTextures()
	FriendsFramePendingButton3:RemoveTextures()
	FriendsFramePendingButton4:RemoveTextures()
	FriendsListFrame:RemoveTextures()
	FriendsTabHeader:RemoveTextures()
	WhoFrameColumnHeader1:RemoveTextures()
	WhoFrameColumnHeader2:RemoveTextures()
	WhoFrameColumnHeader3:RemoveTextures()
	WhoFrameColumnHeader4:RemoveTextures()
	FriendsFrameBroadcastInputMiddle:RemoveTextures()
	FriendsFrameBroadcastInputLeft:RemoveTextures()
	FriendsFrameBroadcastInputRight:RemoveTextures()
	FriendsTabHeaderTab1:RemoveTextures()
	FriendsTabHeaderTab2:RemoveTextures()
	FriendsTabHeaderTab3:RemoveTextures()
	ChannelFrameDaughterFrameChannelNameMiddle:RemoveTextures()
	ChannelFrameDaughterFrameChannelNameLeft:RemoveTextures()
	ChannelFrameDaughterFrameChannelNameRight:RemoveTextures()
	ChannelFrameDaughterFrameChannelPasswordMiddle:RemoveTextures()
	ChannelFrameDaughterFrameChannelPasswordLeft:RemoveTextures()
	ChannelFrameDaughterFrameChannelPasswordRight:RemoveTextures()
	PendingListFrame:RemoveTextures()
	IgnoreListFrame:RemoveTextures()
	
	if (FriendsFramePortrait) then FriendsFramePortrait:Kill() end
	if (FriendsFrameIcon) then FriendsFrameIcon:Kill() end
	
	if (FriendsFrameBottomLeft) then FriendsFrameBottomLeft:RemoveTextures() end
	if (FriendsFrameBottomRight) then FriendsFrameBottomRight:RemoveTextures() end
	if (FriendsFrameTopLeft) then FriendsFrameTopLeft:RemoveTextures() end
	if (FriendsFrameTopRight) then FriendsFrameTopRight:RemoveTextures() end
	if (FriendsFrameInset) then FriendsFrameInset:RemoveTextures() end
	if (WhoFrameListInset) then WhoFrameListInset:RemoveTextures() end
	if (ChannelFrameVerticalBar) then ChannelFrameVerticalBar:RemoveTextures() end

	AddFriendFrame:SetUITemplate("backdrop")
	ChannelFrameDaughterFrame:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChannelFrameDaughterFrameChannelName:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
	ChannelFrameDaughterFrameChannelPassword:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
	
	WhoListScrollFrameScrollBar:SetUITemplate("scrollbar")
	FriendsFrameFriendsScrollFrameScrollBar:SetUITemplate("scrollbar")
	FriendsFrameIgnoreScrollFrameScrollBar:SetUITemplate("scrollbar")
	FriendsFramePendingScrollFrameScrollBar:SetUITemplate("scrollbar")
	
	if (F.IsBuild(4,3,0)) then
		WhoFrameEditBoxInset:RemoveTextures()
		ChannelFrameLeftInset:RemoveTextures()
		ChannelFrameRightInset:RemoveTextures()
		
		WhoFrameListInset:SetUITemplate("backdrop", nil, 4, 3, 6, 3):SetBackdropColor(r, g, b, panelAlpha)
		FriendsFrame:SetUITemplate("backdrop", nil, -8, -6, 0, -6)
		
		WhoListScrollFrameScrollBar:ClearAllPoints()
		WhoListScrollFrameScrollBar:SetPoint("TOPRIGHT", WhoFrameListInset, -4, -19)
		WhoListScrollFrameScrollBar:SetPoint("BOTTOMRIGHT", WhoFrameListInset, -4, 19)

		FriendsFrameIgnoreScrollFrameScrollBar:ClearAllPoints()
		FriendsFrameIgnoreScrollFrameScrollBar:SetPoint("TOPRIGHT", FriendsFrameInset, -4, -19)
		FriendsFrameIgnoreScrollFrameScrollBar:SetPoint("BOTTOMRIGHT", FriendsFrameInset, -4, 19)

		FriendsFramePendingScrollFrameScrollBar:ClearAllPoints()
		FriendsFramePendingScrollFrameScrollBar:SetPoint("TOPRIGHT", FriendsFrameInset, -4, -19)
		FriendsFramePendingScrollFrameScrollBar:SetPoint("BOTTOMRIGHT", FriendsFrameInset, -4, 19)
	
	else
		FriendsFrame:SetUITemplate("backdrop", nil, 6, 6, 76, 31)
	end
	
	-- 4.3.3 (?) scroll of resurrection stuff
	if (ScrollOfResurrectionSelectionFrame) then
		-- ress icon
		FriendsTabHeaderSoRButtonIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		FriendsTabHeaderSoRButtonIcon:ClearAllPoints()
		FriendsTabHeaderSoRButtonIcon:SetPoint("TOPLEFT", 3, -3)
		FriendsTabHeaderSoRButtonIcon:SetPoint("BOTTOMRIGHT", -3, 3)
		FriendsTabHeaderSoRButton:SetUITemplate("simpleborder")
		FriendsTabHeaderSoRButton:GetHighlightTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
		FriendsTabHeaderSoRButton:GetHighlightTexture():SetTexture(1, 1, 1, 1/2)
		FriendsTabHeaderSoRButton:GetHighlightTexture():SetAllPoints(FriendsTabHeaderSoRButtonIcon)
		FriendsTabHeaderSoRButton:GetPushedTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
		FriendsTabHeaderSoRButton:GetPushedTexture():SetTexture(1, 0.82, 0, 1/2)
		FriendsTabHeaderSoRButton:GetPushedTexture():SetAllPoints(FriendsTabHeaderSoRButtonIcon)
	
		F.GlossAndShade(FriendsTabHeaderSoRButton, FriendsTabHeaderSoRButtonIcon)
	
		-- ress selection frame
		ScrollOfResurrectionSelectionFrame:RemoveTextures()
		ScrollOfResurrectionSelectionFrame:SetUITemplate("simplebackdrop")
		ScrollOfResurrectionSelectionFrameList:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar:SetUITemplate("scrollbar")
		ScrollOfResurrectionSelectionFrameAcceptButton:SetUITemplate("button", true)
		ScrollOfResurrectionSelectionFrameCancelButton:SetUITemplate("button", true)
		ScrollOfResurrectionSelectionFrameTargetEditBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)

		-- ress frame
		ScrollOfResurrectionFrame:RemoveTextures()
		ScrollOfResurrectionFrame:SetUITemplate("simplebackdrop")
		ScrollOfResurrectionFrameNoteFrame:SetUITemplate("simplebackdrop")
		ScrollOfResurrectionFrameAcceptButton:SetUITemplate("button", true)
		ScrollOfResurrectionFrameCancelButton:SetUITemplate("button", true)
		
	end

	FriendsFriendsFrame:SetUITemplate("backdrop")
	FriendsFrameFriendsScrollFrame:SetUITemplate("backdrop", nil, -1, 0, 0, 3):SetBackdropColor(r, g, b, panelAlpha)

	WhoFrameDropDown:SetUITemplate("dropdown", true)
	FriendsFrameStatusDropDown:SetUITemplate("dropdown", true)
	
	AddFriendNameEditBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
	FriendsFrameBroadcastInput:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
	WhoFrameEditBox:SetUITemplate("editbox", -8, -3, 8, 23):SetBackdropColor(r, g, b, panelAlpha)
	
	for i,v in pairs(FriendsFrameFriendsScrollFrame.buttons) do
		v:RemoveTextures()
		v:CreateHighlight()
		v:CreatePushed()
		
		if (v.gameIcon) then
			v.gameIcon:SetDrawLayer("OVERLAY")
		end
		
		if (v.name) then
			v.name:SetDrawLayer("OVERLAY")
		end

		if (v.compactInfo) then
			v.compactInfo:SetDrawLayer("OVERLAY")
		end

		if (v.info) then
			v.info:SetDrawLayer("OVERLAY")
		end

		if (v.broadcastMessage) then
			v.broadcastMessage:SetDrawLayer("OVERLAY")
		end
		
		if (v.travelPassButton) then
		end

		if (v.summonButton) then
--			F.StyleActionButton(v.summonButton)
		end

		if (v.soRButton) then
		end
	end

	AddFriendEntryFrameAcceptButton:SetUITemplate("button")
	AddFriendEntryFrameCancelButton:SetUITemplate("button")
	AddFriendInfoFrameContinueButton:SetUITemplate("button")
	ChannelFrameDaughterFrameCancelButton:SetUITemplate("button")
	ChannelFrameDaughterFrameOkayButton:SetUITemplate("button")
	ChannelFrameNewButton:SetUITemplate("button")
	FriendsFrameAddFriendButton:SetUITemplate("button")
	FriendsFrameSendMessageButton:SetUITemplate("button")
	FriendsFrameIgnorePlayerButton:SetUITemplate("button")
	FriendsFramePendingButton1AcceptButton:SetUITemplate("button")
	FriendsFramePendingButton1DeclineButton:SetUITemplate("button")
	FriendsFramePendingButton2AcceptButton:SetUITemplate("button")
	FriendsFramePendingButton2DeclineButton:SetUITemplate("button")
	FriendsFramePendingButton3AcceptButton:SetUITemplate("button")
	FriendsFramePendingButton3DeclineButton:SetUITemplate("button")
	FriendsFramePendingButton4AcceptButton:SetUITemplate("button")
	FriendsFramePendingButton4DeclineButton:SetUITemplate("button")
	FriendsFrameUnsquelchButton:SetUITemplate("button")
	FriendsFriendsSendRequestButton:SetUITemplate("button")
	WhoFrameAddFriendButton:SetUITemplate("button")
	WhoFrameGroupInviteButton:SetUITemplate("button")
	WhoFrameWhoButton:SetUITemplate("button")
	
	FriendsFriendsCloseButton:SetUITemplate("button") -- changed this from 'closebutton'

	ChannelFrameDaughterFrameDetailCloseButton:SetUITemplate("closebutton")
	FriendsFrameCloseButton:SetUITemplate("closebutton")

	FriendsFrameTab1:SetUITemplate("tab")
	FriendsFrameTab2:SetUITemplate("tab")
	FriendsFrameTab3:SetUITemplate("tab")
	FriendsFrameTab4:SetUITemplate("tab")
	
	FriendsFriendsFrameDropDown:SetUITemplate("dropdown", true)
	FriendsFriendsScrollFrameScrollBar:SetUITemplate("scrollbar")

	local StripChannelList = function()
		for i=1, MAX_DISPLAY_CHANNEL_BUTTONS do
			local button = _G["ChannelButton"..i]
			if (button) then
				button:RemoveTextures()
				button:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
			end
		end
	end
	
	local StripChannelRoster = function()
		ChannelRosterScrollFrame:RemoveTextures() 
	end

	local StripWhoList = function()
		WhoListScrollFrame:RemoveTextures() 
	end

	ChannelFrame:HookScript("OnShow", function(self) self:RemoveTextures() end)
	WhoFrame:HookScript("OnShow", function(self) self:RemoveTextures() end)

	hooksecurefunc("ChannelList_Update", StripChannelList)
	hooksecurefunc("FriendsFrame_OnEvent", StripChannelRoster)
	hooksecurefunc("FriendsFrame_OnEvent", StripWhoList)
	
end
