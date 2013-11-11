--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningMail")

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
	
	MailFrame:RemoveTextures(true)
	InboxFrame:RemoveTextures()
	OpenMailFrame:RemoveTextures()
	SendMailFrame:RemoveTextures()
	OpenMailInvoiceFrame:RemoveTextures()
	OpenMailScrollFrame:RemoveTextures()
	SendMailScrollFrame:RemoveTextures()
	OpenMailLetterButton:RemoveTextures()
	OpenMailMoneyButton:RemoveTextures()

	MailFrameTopLeft:Kill()
	MailFrameTopRight:Kill()
	MailFrameBotLeft:Kill()
	MailFrameBotRight:Kill()
	OpenMailArithmeticLine:Kill()
	OpenStationeryBackgroundLeft:Kill()
	OpenStationeryBackgroundRight:Kill()
	SendStationeryBackgroundLeft:Kill()
	SendStationeryBackgroundRight:Kill()
	
	OpenMailFrameIcon:Kill()
	
	select(2, InboxNextPageButton:GetRegions()):Kill()
	select(2, InboxPrevPageButton:GetRegions()):Kill()
	
	InboxNextPageButton:SetUITemplate("arrow", "right", "BOTTOMRIGHT", InboxFrame, "BOTTOMRIGHT", -40, 85)
	InboxPrevPageButton:SetUITemplate("arrow", "left", "BOTTOMLEFT", InboxFrame, "BOTTOMLEFT", 10, 85)
	
	SendMailMailButton:SetUITemplate("button")
	SendMailCancelButton:SetUITemplate("button")
	OpenMailReportSpamButton:SetUITemplate("button")
	OpenMailReplyButton:SetUITemplate("button")
	OpenMailDeleteButton:SetUITemplate("button")
	OpenMailCancelButton:SetUITemplate("button")
	
	SendMailSendMoneyButton:SetUITemplate("radiobutton", true)
	SendMailCODButton:SetUITemplate("radiobutton", true)

	InboxCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -34, -4)
	OpenMailCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -34, -4)
	
	SendMailNameEditBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
	SendMailSubjectEditBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
	SendMailMoneyGold:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
	SendMailMoneySilver:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
	SendMailMoneyCopper:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
	
	SendMailMoneyGold:SetFontObject(GUIS_NumberFontNormal)
	SendMailMoneySilver:SetFontObject(GUIS_NumberFontNormal)
	SendMailMoneyCopper:SetFontObject(GUIS_NumberFontNormal)
	
	MailFrame:SetUITemplate("backdrop", nil, 0, 4, 74, 30)
	OpenMailFrame:SetUITemplate("backdrop", nil, 0, 4, 74, 30)
	OpenMailScrollFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	SendMailScrollFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	
	F.StyleActionButton(OpenMailLetterButton)
	F.StyleActionButton(OpenMailMoneyButton)
	OpenMailMoneyButton:SetBackdropBorderColor(1, 0.82, 0)
	
	OpenMailScrollFrameScrollBar:SetUITemplate("scrollbar")
	SendMailScrollFrameScrollBar:SetUITemplate("scrollbar")
	
	MailFrameTab1:SetUITemplate("tab")
	MailFrameTab2:SetUITemplate("tab")

	SendMailBodyEditBox:SetTextColor(unpack(C["index"]))
	OpenMailBodyText:SetTextColor(unpack(C["index"]))
	InvoiceTextFontNormal:SetTextColor(unpack(C["index"]))

	InboxTitleText:SetPoint("TOP", 0, -8)
	OpenMailTitleText:SetPoint("TOP", 0, -8)
	SendMailTitleText:SetPoint("TOP", 0, -8)

	local updateItem = function(item, itemID)
		local quality
		if (itemID) then
			quality = (itemID) and (select(3, GetItemInfo(itemID)))
		end
		
		if (quality) and (quality > 1) then
			local r, g, b, hex = GetItemQualityColor(quality)
			item:SetBackdropBorderColor(r, g, b)
		else
			item:SetBackdropBorderColor(unpack(C["border"]))
		end
	end

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local bg = _G["MailItem" .. i]
		local b = _G["MailItem" .. i .. "Button"]
		local w,h = bg:GetSize()
		local w2,h2 = b:GetSize()

		bg:RemoveTextures()
		bg:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)

		b:ClearAllPoints()
		b:SetPoint("TOPLEFT", bg, "TOPLEFT", 4, -4)
		b:SetHitRectInsets(-4, -(w-(w2+4)), -4, -(h-(h2+4)))
		b:RemoveTextures()
		F.StyleActionButton(b)
	end
	
	for i = 1, ATTACHMENTS_MAX_SEND do				
		local b = _G["OpenMailAttachmentButton" .. i]
		b:RemoveTextures()
		F.StyleActionButton(b)
	end
	
	local skin = {}
	local UpdateSendMail = function()
		for i = 1, ATTACHMENTS_MAX_SEND do				
			local itemName, itemTexture, stackCount, quality = GetSendMailItem(i)
			local b = _G["SendMailAttachment" .. i]
			
			if not(skin[b]) then
				b:RemoveTextures()
				F.StyleActionButton(b)
				
				skin[b] = true
			end
			
			local t = b:GetNormalTexture()
			if (t) then
				t:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				t:ClearAllPoints()
				t:SetPoint("TOPLEFT", 3, -3)
				t:SetPoint("BOTTOMRIGHT", -3, 3)
			end
			
			if (itemName) then
				updateItem(b, itemName)
			else
				updateItem(b)
			end
		end
	end
	hooksecurefunc("SendMailFrame_Update", UpdateSendMail)
	
	local UpdateInbox = function()
		local numItems, totalItems = GetInboxNumItems()
		local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity
		local button, buttonIcon
		
		for i = 1, INBOXITEMS_TO_DISPLAY do
			button = _G["MailItem" .. i .. "Button"]
			buttonIcon = _G["MailItem" .. i .. "ButtonIcon"]
			
			if (index <= numItems) then
				packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity = GetInboxHeaderInfo(index)
				
				if (wasRead) then
					updateItem(button)
				else
					if (itemCount) and (buttonIcon:GetTexture() == packageIcon) then
						updateItem(button, GetInboxItemLink(index, 1))
					elseif (money) and (money > 0) then
						button:SetBackdropBorderColor(1, 0.82, 0)
					else
						updateItem(button)
					end
				end
			else
				updateItem(button)
			end
			
			index = index + 1
		end
	end
	hooksecurefunc("InboxFrame_Update", UpdateInbox)
	
	local UpdateOpenMail = function()
		if not(InboxFrame.openMailID) then
			return
		end
		
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(InboxFrame.openMailID)
		local bodyText, texture, isTakeable, isInvoice = GetInboxText(InboxFrame.openMailID)
		local itemButtonCount, itemRowCount = OpenMail_GetItemCounts(isTakeable, textCreated, money)
		
		if (itemRowCount > 0) and (OpenMailFrame.activeAttachmentButtons) then
			local rowIndex = 1;
			for i, attachmentButton in pairs(OpenMailFrame.activeAttachmentButtons) do

				if (attachmentButton ~= OpenMailLetterButton) and (attachmentButton ~= OpenMailMoneyButton) then
					updateItem(attachmentButton, GetInboxItemLink(InboxFrame.openMailID, attachmentButton:GetID()))
				end
			end
		end
	end
	hooksecurefunc("OpenMail_Update", UpdateOpenMail)
end
