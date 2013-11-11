--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGuildControl")

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
		
		GuildControlUI:RemoveTextures()
		GuildControlUIHbar:RemoveTextures()
		GuildControlUIRankBankFrame:RemoveTextures()
		GuildControlUIRankBankFrameInset:RemoveTextures()
		GuildControlUIRankSettingsFrameGoldBox:RemoveTextures()
		GuildControlUIRankBankFrameInsetScrollFrame:RemoveTextures()
		
		GuildControlUIRankOrderFrameNewButton:SetUITemplate("button")
		
		GuildControlUICloseButton:SetUITemplate("closebutton", "TOPRIGHT", GuildControlUI, "TOPRIGHT", -4, -4)
		
		GuildControlUINavigationDropDown:SetUITemplate("dropdown", true)
		GuildControlUIRankSettingsFrameRankDropDown:SetUITemplate("dropdown", true)
		GuildControlUIRankBankFrameRankDropDown:SetUITemplate("dropdown", true)
		
		GuildControlUIRankSettingsFrameGoldBox:SetUITemplate("editbox", -5, -2, 5, -2):SetBackdropColor(r, g, b, panelAlpha)
		
		GuildControlUI:SetUITemplate("backdrop")
		
		local chatBg = CreateFrame("Frame", nil, GuildControlUIRankSettingsFrame)
		chatBg:SetUITemplate("backdrop", GuildControlUIRankSettingsFrameChatBg):SetBackdropColor(r, g, b, panelAlpha)

		local rosterBg = CreateFrame("Frame", nil, GuildControlUIRankSettingsFrame)
		rosterBg:SetUITemplate("backdrop", GuildControlUIRankSettingsFrameRosterBg):SetBackdropColor(r, g, b, panelAlpha)

		local infoBg = CreateFrame("Frame", nil, GuildControlUIRankSettingsFrame)
		infoBg:SetUITemplate("backdrop", GuildControlUIRankSettingsFrameInfoBg):SetBackdropColor(r, g, b, panelAlpha)

		local bankBg = CreateFrame("Frame", nil, GuildControlUIRankSettingsFrame)
		bankBg:SetUITemplate("backdrop", GuildControlUIRankSettingsFrameBankBg):SetBackdropColor(r, g, b, panelAlpha)
		
		GuildControlUIRankBankFrameInsetScrollFrameScrollBar:SetUITemplate("scrollbar")
		
		for i = 1, NUM_RANK_FLAGS do
			local checkbutton = _G["GuildControlUIRankSettingsFrameCheckbox" .. i]
			if (checkbutton) then
				checkbutton:SetUITemplate("checkbutton")
			end
		end
		
		local skinned = {}
		local updateBankPermissions = function()
			for i = 1, MAX_GUILDBANK_TABS do
				local tabName = "GuildControlBankTab" .. i
				if _G[tabName] and not(skinned[tabName]) then
					_G["GuildControlBankTab" .. i]:SetHeight(_G["GuildControlBankTab" .. i]:GetHeight() + 16)

					_G["GuildControlBankTab" .. i .. "Bg"]:RemoveTextures()
					_G["GuildControlBankTab" .. i .. "BuyPurchaseButton"]:SetUITemplate("button")

					_G["GuildControlBankTab" .. i .. "Owned"]:SetUITemplate("simplebackdrop-indented"):SetBackdropColor(r, g, b, panelAlpha)
					_G["GuildControlBankTab" .. i .. "Owned"]:SetUIShadowColor(0, 0, 0, 0)
					
					_G["GuildControlBankTab" .. i .. "OwnedViewCheck"]:SetUITemplate("checkbutton")
					_G["GuildControlBankTab" .. i .. "OwnedViewCheck"]:SetPoint("TOPRIGHT", -100, -12)
					_G["GuildControlBankTab" .. i .. "OwnedViewCheck"]:SetUIShadowColor(0, 0, 0, 0)
					_G["GuildControlBankTab" .. i .. "OwnedDepositCheck"]:SetUITemplate("checkbutton")
					_G["GuildControlBankTab" .. i .. "OwnedDepositCheck"]:SetUIShadowColor(0, 0, 0, 0)
					_G["GuildControlBankTab" .. i .. "OwnedUpdateInfoCheck"]:SetUITemplate("checkbutton")
					_G["GuildControlBankTab" .. i .. "OwnedUpdateInfoCheck"]:SetUIShadowColor(0, 0, 0, 0)
					
					_G["GuildControlBankTab" .. i .. "Owned"].editBox:RemoveClutter()
					_G["GuildControlBankTab" .. i .. "Owned"].editBox:SetHeight(_G["GuildControlBankTab" .. i .. "Owned"].editBox:GetHeight() + 4)
					_G["GuildControlBankTab" .. i .. "Owned"].editBox:SetUITemplate("simplebackdrop-indented"):SetBackdropColor(r, g, b, panelAlpha)
					_G["GuildControlBankTab" .. i .. "Owned"].editBox:SetFontObject(GUIS_NumberFontSmall)
					_G["GuildControlBankTab" .. i .. "Owned"].editBox:SetTextInsets(2, 2, 2, 2)

					local icon = _G["GuildControlBankTab" .. i .. "Owned"].tabIcon
					icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
					icon:ClearAllPoints()
					icon:SetPoint("TOPLEFT", _G["GuildControlBankTab" .. i], "TOPLEFT", 12, -12)
					
					skinned[tabName] = true
				end
			end
		end
		
		local fixTexCoord = function(self)
			self:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			self:GetNormalTexture().SetTexCoord = noop

			self:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
			self:GetPushedTexture().SetTexCoord = noop

			self:GetDisabledTexture():SetTexCoord(0, 1, 0, 1)
			self:GetDisabledTexture().SetTexCoord = noop

			self:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
			self:GetHighlightTexture().SetTexCoord = noop

			self.SetNormalTexture = noop
			self.SetPushedTexture = noop
			self.SetHighlightTexture = noop
			self.SetDisabledTexture = noop
	
		end

		local updateRanks = function()
			for i = 1, GuildControlGetNumRanks() do
				local rank = _G["GuildControlUIRankOrderFrameRank" .. i]
				if (rank) and not(skinned["GuildControlUIRankOrderFrameRank" .. i]) then

					rank.downButton:SetUITemplate("arrow")
					rank.upButton:SetUITemplate("arrow")
					rank.deleteButton:SetUITemplate("closebutton")

					fixTexCoord(rank.upButton)
					fixTexCoord(rank.downButton)
					fixTexCoord(rank.deleteButton)
					
					rank.nameBox:SetUITemplate("editbox", -4, -2, 4, -4):SetBackdropColor(r, g, b, panelAlpha)
					
					skinned["GuildControlUIRankOrderFrameRank" .. i] = true
				end
			end				
		end

		RegisterCallback("GUILD_RANKS_UPDATE", updateRanks)
		RegisterCallback("GUILD_ROSTER_UPDATE", updateRanks)
		
		hooksecurefunc("GuildControlUI_RankOrder_Update", updateRanks)
		hooksecurefunc("GuildControlUI_BankTabPermissions_Update", updateBankPermissions)
		
	end
	F.SkinAddOn("Blizzard_GuildControlUI", SkinFunc)
	
end
