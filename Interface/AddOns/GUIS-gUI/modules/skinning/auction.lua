--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningAuctionHouse")

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
		
		local AuctionDressUpFrame = AuctionDressUpFrame
		local AuctionDressUpFrameCloseButton = AuctionDressUpFrameCloseButton
		local AuctionDressUpModelRotateLeftButton = AuctionDressUpModelRotateLeftButton
		local AuctionDressUpModelRotateRightButton = AuctionDressUpModelRotateRightButton
		local AuctionDressUpFrameResetButton = AuctionDressUpFrameResetButton

		if (F.IsBuild(4,3,0)) then
			AuctionDressUpFrame = SideDressUpFrame
			AuctionDressUpFrameResetButton = SideDressUpModelResetButton
			AuctionDressUpFrameCloseButton = SideDressUpModelCloseButton
		end

		AuctionFrame:RemoveTextures(true)
		AuctionDressUpFrame:RemoveTextures()
		AuctionDressUpFrameCloseButton:RemoveTextures()
		AuctionProgressFrame:RemoveTextures()
		AuctionsScrollFrame:RemoveTextures()
		AuctionsItemButton:RemoveTextures()
		BidScrollFrame:RemoveTextures()
		BrowseFilterScrollFrame:RemoveTextures()
		BrowseScrollFrame:RemoveTextures()
		
		AuctionsBidSort:RemoveClutter()
		AuctionsDurationSort:RemoveClutter()
		AuctionsHighBidderSort:RemoveClutter()
		AuctionsQualitySort:RemoveClutter()
		BidBidSort:RemoveClutter()
		BidBuyoutSort:RemoveClutter()
		BidDurationSort:RemoveClutter()
		BidLevelSort:RemoveClutter()
		BidQualitySort:RemoveClutter()
		BidStatusSort:RemoveClutter()
		BrowseCurrentBidSort:RemoveClutter()
		BrowseDurationSort:RemoveClutter()
		BrowseHighBidderSort:RemoveClutter()
		BrowseLevelSort:RemoveClutter()
		BrowseQualitySort:RemoveClutter()
			
		if not(F.IsBuild(4,3,0)) then
			AuctionDressUpModelRotateLeftButton:SetUITemplate("arrow")
			AuctionDressUpModelRotateRightButton:SetUITemplate("arrow")
		end
		
		BrowseNextPageButton:SetUITemplate("arrow")
		BrowsePrevPageButton:SetUITemplate("arrow")

		AuctionDressUpFrameResetButton:SetUITemplate("button", true)
		AuctionsCancelAuctionButton:SetUITemplate("button", true)
		AuctionsCloseButton:SetUITemplate("button", true)
		AuctionsCreateAuctionButton:SetUITemplate("button", true)
		AuctionsNumStacksMaxButton:SetUITemplate("button", true)
		AuctionsStackSizeMaxButton:SetUITemplate("button", true)
		BidBidButton:SetUITemplate("button", true)
		BidBuyoutButton:SetUITemplate("button", true)
		BidCloseButton:SetUITemplate("button", true)
		BrowseBidButton:SetUITemplate("button", true)
		BrowseBuyoutButton:SetUITemplate("button", true)
		BrowseCloseButton:SetUITemplate("button", true)
		BrowseSearchButton:SetUITemplate("button", true)
		BrowseResetButton:SetUITemplate("button", true)
		
		IsUsableCheckButton:SetUITemplate("checkbutton")
		ShowOnPlayerCheckButton:SetUITemplate("checkbutton")

		AuctionFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -4, -10)
		AuctionDressUpFrameCloseButton:SetUITemplate("closebutton")

		BrowseDropDown:SetUITemplate("dropdown", true)
		DurationDropDown:SetUITemplate("dropdown", true)
		PriceDropDown:SetUITemplate("dropdown", true)

		BrowseName:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BrowseMinLevel:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BrowseMaxLevel:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BrowseBidPriceGold:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BrowseBidPriceSilver:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BrowseBidPriceCopper:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BidBidPriceGold:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BidBidPriceSilver:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BidBidPriceCopper:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		AuctionsStackSizeEntry:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		AuctionsNumStacksEntry:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		StartPriceGold:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		StartPriceSilver:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		StartPriceCopper:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BuyoutPriceGold:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BuyoutPriceSilver:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		BuyoutPriceCopper:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)

		-- these are just too tiny, we need to expand them a bit,
		-- as well as reposition and clean it up
		BrowseMinLevel:SetWidth(BrowseMinLevel:GetWidth() + 8)
		BrowseMaxLevel:SetWidth(BrowseMaxLevel:GetWidth() + 8)
		BrowseMaxLevel:SetPoint("LEFT", BrowseMinLevel, "RIGHT", 8, 0)
		BrowseLevelHyphen:Hide()

		if (F.IsBuild(4,3,0)) then frame.backdrop = frame:SetUITemplate("backdrop", nil, 2, 0, 2, 0) end
		
		AuctionFrame:SetUITemplate("backdrop", nil, 6, -6, 9, 0)
		AuctionDressUpFrame:SetUITemplate("backdrop", nil,  8, -2, 8, 8)
		AuctionProgressFrame:SetUITemplate("backdrop", nil, 8, 8, 8, 8)

		AuctionsScrollFrameScrollBar:SetUITemplate("scrollbar")
		BidScrollFrameScrollBar:SetUITemplate("scrollbar")
		BrowseFilterScrollFrameScrollBar:SetUITemplate("scrollbar")
		BrowseScrollFrameScrollBar:SetUITemplate("scrollbar")

		AuctionProgressBar:SetUITemplate("statusbar", true)
		
		-- make sure all tabs by all addons eventually are skinned
		local skinnedTabs = {}
		local updateTabs = function()
			local i = 1
			local tab = _G["AuctionFrameTab" .. i]
			while (tab) do
				if not(skinnedTabs[tab]) then
					tab:SetUITemplate("tab", true)
				end
				
				i = i + 1
				tab = _G["AuctionFrameTab" .. i]
			end
		end
		AuctionFrame:HookScript("OnShow", updateTabs)
		updateTabs()

		AuctionDressUpFrame:SetPoint("TOPLEFT", AuctionFrame, "TOPRIGHT", 8, -28)
		AuctionDressUpFrameResetButton:SetPoint("BOTTOM", AuctionDressUpFrame, "BOTTOM", 0, 16)

		AuctionProgressFrameCancelButton:SetUITemplate("closebutton", "LEFT", AuctionProgressBar, "RIGHT", 12, 0) -- have to force this
		AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
--		AuctionProgressFrameCancelButton:SetUITemplate("backdrop", AuctionProgressBarIcon)
		AuctionProgressBarIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				
		local point, anchor, relpoint, x, y = BrowseDropDown:GetPoint()
		BrowseDropDown:SetPoint(point, anchor, relpoint, x + 12, y)
		BrowseDropDown:SetWidth(160)
		
		local styleAHButton = function(name, i)
			local button = _G[name .. i]
			local icon = _G[name .. i .. "Item"]
			
			button:RemoveTextures()
			F.StyleActionButton(icon)

			button:CreateHighlight(3, -3, 3, 3)
			button:CreatePushed(3, -3, 3, 3)

		end
		
		for i = 1, NUM_FILTERS_TO_DISPLAY do
			local tab = _G["AuctionFilterButton" .. i]
			tab:RemoveTextures()
			tab:CreateHighlight()
			tab:CreatePushed()
		end

		for i = 1, NUM_AUCTIONS_TO_DISPLAY do
			styleAHButton("AuctionsButton", i)
		end
		
		for i = 1, NUM_BROWSE_TO_DISPLAY do
			styleAHButton("BrowseButton", i)
		end
		
		for i = 1, NUM_BIDS_TO_DISPLAY do
			styleAHButton("BidButton", i)
		end

		AuctionsItemButton:SetUITemplate("itembackdrop")
		local updateAuctionItem = function(self, ...)
			local button = AuctionsItemButton:GetNormalTexture()
			if (button) then
				button:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			end
		end
		hooksecurefunc(AuctionsItemButton, "SetNormalTexture", updateAuctionItem)

		AuctionsScrollFrame:SetHeight(336)	
		BidScrollFrame:SetHeight(332)
		BrowseFilterScrollFrame:SetHeight(300) 
		BrowseScrollFrame:SetHeight(300)

		AuctionsCreateAuctionButton:SetPoint("BOTTOMLEFT", 18, 44)
		
		local makeAHBackdrop = function(parent, toprightAnchor, x, y, bottomleftanchor, x2, y2)
			local backdrop = CreateFrame("Frame", nil, parent)
			backdrop:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)

			if (toprightAnchor) then
				backdrop:SetPoint("TOPLEFT", toprightAnchor, "TOPRIGHT", x, y)
			else
				backdrop:SetPoint("TOPLEFT", x, y)
			end

			if (bottomleftanchor) then
				backdrop:SetPoint("BOTTOMRIGHT", bottomleftanchor, "BOTTOMRIGHT", x2, y2)
			else
				backdrop:SetPoint("BOTTOMRIGHT", x2, y2)
			end
			
			backdrop:SetFrameLevel(backdrop:GetFrameLevel() - 2)
			
			return backdrop
		end

		AuctionFrameBrowse.leftBackdrop = makeAHBackdrop(AuctionFrameBrowse, nil, 20, -103, nil, -575, 42)
		AuctionFrameBrowse.rightBackdrop = makeAHBackdrop(AuctionFrameBrowse, AuctionFrameBrowse.leftBackdrop, 8, 0, AuctionFrame, -12, 42)
		AuctionFrameBid.backdrop = makeAHBackdrop(AuctionFrameBid, nil, 20, -72, nil, 63, 42)
		AuctionFrameAuctions.leftBackdrop = makeAHBackdrop(AuctionFrameAuctions, nil, 19, -70, nil, -550, 42)
		AuctionFrameAuctions.rightBackdrop = makeAHBackdrop(AuctionFrameAuctions, AuctionFrameAuctions.leftBackdrop, 8, 0, AuctionFrame, -11, 42)

	end
	F.SkinAddOn("Blizzard_AuctionUI", SkinFunc)
end
