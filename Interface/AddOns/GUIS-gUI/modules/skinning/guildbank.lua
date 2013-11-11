--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGuildBank")

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
		
		GuildBankFrame:RemoveTextures()
		GuildBankEmblemFrame:RemoveTextures()
		GuildBankInfoScrollFrame:RemoveTextures()
		GuildBankTransactionsScrollFrame:RemoveTextures()
		GuildBankPopupFrame:RemoveTextures()
		GuildBankPopupScrollFrame:RemoveTextures()
		GuildBankPopupNameLeft:RemoveTextures()
		GuildBankPopupNameRight:RemoveTextures()
		GuildBankPopupNameMiddle:RemoveTextures()
	
		GuildBankFrameDepositButton:SetUITemplate("button")
		GuildBankFrameWithdrawButton:SetUITemplate("button")
		GuildBankInfoSaveButton:SetUITemplate("button")
		GuildBankFramePurchaseButton:SetUITemplate("button")
		GuildBankPopupOkayButton:SetUITemplate("button")
		GuildBankPopupCancelButton:SetUITemplate("button")
		GuildBankPopupEditBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		
		if (F.IsBuild(4,3,0)) then
			GuildItemSearchBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
			GuildItemSearchBox:SetPoint("TOPRIGHT", -20, -36)
		end

		GuildBankFrame:SetUITemplate("backdrop", nil, 8, 8, 6, 0)
		GuildBankPopupFrame:SetUITemplate("backdrop", nil, 6, 8, 24, 24)
		
		GuildBankTransactionsScrollFrameScrollBar:SetUITemplate("scrollbar")
		GuildBankInfoScrollFrameScrollBar:SetUITemplate("scrollbar")
		GuildBankPopupScrollFrameScrollBar:SetUITemplate("scrollbar")
		
		GuildBankFrameTab1:SetUITemplate("tab")
		GuildBankFrameTab2:SetUITemplate("tab")
		GuildBankFrameTab3:SetUITemplate("tab")
		GuildBankFrameTab4:SetUITemplate("tab")
		
		GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
		GuildBankFrame.inset:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
		GuildBankFrame.inset:SetPoint("TOPLEFT", 30, -65)
		GuildBankFrame.inset:SetPoint("BOTTOMRIGHT", -20, 63)	
		
		GuildBankEmblemFrame:Kill()
		
		for i = 1, GuildBankFrame:GetNumChildren() do
			local child = select(i, GuildBankFrame:GetChildren())
			if (child.GetPushedTexture) and (child:GetPushedTexture()) and not(child:GetName()) then
				child:SetUITemplate("closebutton") -- another one that can't be auto-detected
			end
		end
		
		local updateAllBorders = function()
			for i = 1, NUM_GUILDBANK_COLUMNS do
				_G["GuildBankColumn" .. i]:RemoveTextures()
				
				for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
					local button = _G["GuildBankColumn" .. i .. "Button" .. j]
					local tab = GetCurrentGuildBankTab()
					local slot = (NUM_SLOTS_PER_GUILDBANK_GROUP * (i-1)) + j
					local link = GetGuildBankItemLink(tab, slot)

					if (link) then
						local quality = (select(3, GetItemInfo(link)))
						if (quality) and (quality ~= 1) then
							local r, g, b, hex = GetItemQualityColor(quality)
							button:SetBackdropBorderColor(r, g, b)
						else
							button:SetBackdropBorderColor(unpack(C["border"]))
						end
					else
						button:SetBackdropBorderColor(unpack(C["border"]))
					end
				end
			end
		end
		
		for i = 1, NUM_GUILDBANK_COLUMNS do
			_G["GuildBankColumn" .. i]:RemoveTextures()
			
			for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
				local button = _G["GuildBankColumn" .. i .. "Button" .. j]
				local icon = _G["GuildBankColumn" .. i .. "Button" .. j .. "IconTexture"]

				-- button:RemoveTextures() -- removing all kills the search overlay. baaad. 
				F.StyleActionButton(button)
			end
		end
		
		for i = 1, 8 do
			local button = _G["GuildBankTab" .. i .. "Button"]
			
			_G["GuildBankTab" .. i]:RemoveTextures()
			F.StyleActionButton(button)
		end
		
		for i = 1, 16 do
			local button = _G["GuildBankPopupButton" .. i]
			
			button:RemoveTextures()
			F.StyleActionButton(button)
		end	

		updateAllBorders()
		hooksecurefunc("GuildBankFrame_Update", updateAllBorders)
		
	end
	F.SkinAddOn("Blizzard_GuildBankUI", SkinFunc)
end
