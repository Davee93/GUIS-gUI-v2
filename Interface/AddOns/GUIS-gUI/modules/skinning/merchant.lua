--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningMerchant")

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
	
	MerchantFrame:RemoveTextures()
	MerchantBuyBackItem:RemoveTextures()
	
	MerchantFramePortrait:Kill()

	MerchantNextPageButton:SetUITemplate("arrow", "right")
	MerchantPrevPageButton:SetUITemplate("arrow", "left")
	
	MerchantFrame:SetUITemplate("backdrop", nil, 0, 6, 60, 16)
	MerchantBuyBackItem:SetUITemplate("backdrop", nil, -3, -3, -3, -3):SetBackdropColor(r, g, b, 1/3)
	MerchantRepairItemButton:SetUITemplate("simplebackdrop")
	MerchantGuildBankRepairButton:SetUITemplate("simplebackdrop")
	MerchantRepairAllButton:SetUITemplate("simplebackdrop")
	MerchantFrameTab1:SetUITemplate("tab")
	MerchantFrameTab2:SetUITemplate("tab")
	MerchantFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -20, -4)

	F.StyleActionButton(MerchantBuyBackItemItemButton)
	
	for i = 1, MerchantRepairItemButton:GetNumRegions() do
		local region = select(i, MerchantRepairItemButton:GetRegions())
		if (region:GetObjectType() == "Texture") and (region:GetTexture() == "Interface\\MerchantFrame\\UI-Merchant-RepairIcons") then
			region:SetTexCoord(0.04, 0.24, 0.06, 0.5)
			region:ClearAllPoints()
			region:SetPoint("TOPLEFT", 3, -3)
			region:SetPoint("BOTTOMRIGHT", -3, 3)
		end
	end	
	
	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
	MerchantGuildBankRepairButtonIcon:ClearAllPoints()
	MerchantGuildBankRepairButtonIcon:SetPoint("TOPLEFT", 3, -3)
	MerchantGuildBankRepairButtonIcon:SetPoint("BOTTOMRIGHT", -3, 3)

	MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	MerchantRepairAllIcon:ClearAllPoints()
	MerchantRepairAllIcon:SetPoint("TOPLEFT", 3, -3)
	MerchantRepairAllIcon:SetPoint("BOTTOMRIGHT", -3, 3)
	
	for i = 1, max(MERCHANT_ITEMS_PER_PAGE, BUYBACK_ITEMS_PER_PAGE) do
		local bar = _G["MerchantItem" .. i]
		local button = _G["MerchantItem" .. i .. "ItemButton"]
		local money = _G["MerchantItem" .. i .. "MoneyFrame"]
		local currency = _G["MerchantItem" .. i .. "AltCurrencyFrame"]

		F.StyleActionButton(button)
		
		bar:RemoveTextures()
		bar:SetUITemplate("backdrop", nil, -1, -1, 1, -1):SetBackdropColor(r, g, b, 1/3)

		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", bar, "TOPLEFT", 4, -4)

--		money:ClearAllPoints()
--		money:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 6, 0)
		
--		currency:ClearAllPoints()
--		currency:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 6, 0)
		
--		currency.OldSetPoint = currency.SetPoint
--		currency.SetPoint = function(self) 
--			self:ClearAllPoints()
--			self:OldSetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 6, 0)
--		end
	end
	
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

	local updateMerchantItems = function()
		local numMerchantItems = GetMerchantNumItems()
		local index, itemButton

		for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
			local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)
			local itemButton = _G["MerchantItem" .. i .. "ItemButton"]

			if ( index <= numMerchantItems ) then
				updateItem(itemButton, itemButton.link) 
			else
				updateItem(itemButton)
			end
		end
		
		local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(GetNumBuybackItems())
		if (buybackName) then
			updateItem(MerchantBuyBackItemItemButton, buybackName)
		else
			updateItem(MerchantBuyBackItemItemButton)
		end
	end
	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", updateMerchantItems)

	local updateMerchantBuyBackItems = function()
		local numBuybackItems = GetNumBuybackItems()
		local itemButton

		for i = 1, BUYBACK_ITEMS_PER_PAGE, 1 do
			itemButton = _G["MerchantItem" .. i .. "ItemButton"]
			if ( i <= numBuybackItems ) then
				updateItem(itemButton, GetBuybackItemLink(i)) 
			else
				updateItem(itemButton)
			end
		end
	end
	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", updateMerchantBuyBackItems)
end
