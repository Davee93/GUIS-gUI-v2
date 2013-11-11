--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTrade")

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
	
	local MAX_TRADE_ITEMS = MAX_TRADE_ITEMS or 7
	local MAX_TRADABLE_ITEMS = MAX_TRADABLE_ITEMS or 6
	local TRADE_ENCHANT_SLOT = MAX_TRADE_ITEMS
	
	TradeFrame:RemoveTextures()
	TradeHighlightPlayer:RemoveTextures()
	TradeHighlightRecipient:RemoveTextures()
	TradeHighlightPlayerEnchant:RemoveTextures()
	TradeHighlightRecipientEnchant:RemoveTextures()

	TradeFramePlayerPortrait:Kill()
	TradeFrameRecipientPortrait:Kill()

	TradeFrame:SetUITemplate("backdrop", nil, 8, 10, 44, 22)
	
	TradeFrameTradeButton:SetUITemplate("button", true)
	TradeFrameCancelButton:SetUITemplate("button", true)
	TradeFrameCloseButton:SetUITemplate("closebutton")
	
	-- player
	TradeFramePlayerNameText:ClearAllPoints()
	TradeFramePlayerNameText:SetPoint("TOPLEFT", 75 - 58, -20)
	
	TradePlayerInputMoneyFrame.gold:SetUITemplate("editbox")
	TradePlayerInputMoneyFrame.silver:SetUITemplate("editbox")
	TradePlayerInputMoneyFrame.copper:SetUITemplate("editbox")
	
	TradePlayerInputMoneyFrame.gold:SetFontObject(GUIS_NumberFontNormal)
	TradePlayerInputMoneyFrame.silver:SetFontObject(GUIS_NumberFontNormal)
	TradePlayerInputMoneyFrame.copper:SetFontObject(GUIS_NumberFontNormal)
	
	local trade, item
	for i = 1, MAX_TRADE_ITEMS do
		trade = _G["TradePlayerItem" .. i]
		item = _G["TradePlayerItem" .. i .. "ItemButton"]
		
		trade:RemoveTextures()
		
		if (i%2 == 1) then
			trade:SetBackdrop({
				bgFile = M["Background"]["Blank"]; 
				edgeFile = nil; 
				edgeSize = 0;
				insets = { 
					bottom = 0; 
					left = 0; 
					right = 0; 
					top = 0; 
				};
			})
			trade:SetBackdropColor(1, 1, 1, 1/10)
		end
		
		F.StyleActionButton(item)
	end
	
	TradeHighlightPlayer:SetUITemplate("highlightborder")
	TradeHighlightRecipient:SetUITemplate("highlightborder")
	TradeHighlightPlayerEnchant:SetUITemplate("highlightborder")
	TradeHighlightRecipientEnchant:SetUITemplate("highlightborder")
	
	-- recipient
	TradeFrameRecipientNameText:ClearAllPoints()
	TradeFrameRecipientNameText:SetPoint("TOPLEFT", 245 - 58, -20)

	for i = 1, MAX_TRADE_ITEMS do
		trade = _G["TradeRecipientItem" .. i]
		item = _G["TradeRecipientItem" .. i .. "ItemButton"]

		trade:RemoveTextures()

		if (i%2 == 1) then
			trade:SetBackdrop({
				bgFile = M["Background"]["Blank"]; 
				edgeFile = nil; 
				edgeSize = 0;
				insets = { 
					bottom = 0; 
					left = 0; 
					right = 0; 
					top = 0; 
				};
			})
			trade:SetBackdropColor(1, 1, 1, 1/10)
		end

		F.StyleActionButton(item)
	end
	
end
