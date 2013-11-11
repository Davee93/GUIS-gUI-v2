--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningVoidStorage")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local ScheduleTimer = function(...) return module:ScheduleTimer(...) end
local CancelTimer = function(...) return module:CancelTimer(...) end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end

	-- feature added in WoW Client Patch 4.3
	if not(F.IsBuild(4,3,0)) then
		return
	end

	local SkinFunc = function()
		local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
		local VOID_DEPOSIT_MAX = 9
		local VOID_WITHDRAW_MAX = 9
		local VOID_STORAGE_MAX = 80

		VoidStorageFrame:RemoveTextures()
		VoidStorageBorderFrame:RemoveTextures()
		VoidStorageContentFrame:RemoveTextures()
		VoidStorageCostFrame:RemoveTextures()
		VoidStorageDepositFrame:RemoveTextures()
		VoidStorageMoneyFrame:RemoveTextures()
		VoidStorageStorageFrame:RemoveTextures()
		VoidStorageWithdrawFrame:RemoveTextures()
		
		VoidStorageTransferButton:SetUITemplate("button", true)
		VoidStoragePurchaseButton:SetUITemplate("button", true)
		VoidStorageHelpBoxButton:SetUITemplate("button", true)
		
		VoidStorageBorderFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -8, -8)
		
		VoidItemSearchBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)

		VoidStorageFrame:SetUITemplate("simplebackdrop")
		VoidStorageHelpBox:SetUITemplate("simplebackdrop")
		VoidStoragePurchaseFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		VoidStorageCostFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		VoidStorageDepositFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		VoidStorageWithdrawFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		VoidStorageStorageFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		
		for i = 1,VOID_DEPOSIT_MAX do
			local button = _G["VoidStorageDepositButton" .. i]
			button:RemoveTextures()
			F.StyleActionButton(button)
		end

		for i = 1,VOID_WITHDRAW_MAX do
			local button = _G["VoidStorageWithdrawButton" .. i]
			button:RemoveTextures()
			F.StyleActionButton(button)
		end

		for i = 1,VOID_STORAGE_MAX do
			local button = _G["VoidStorageStorageButton" .. i]
			local bg = _G["VoidStorageStorageButton" .. i .. "Bg"]
			bg:RemoveTextures()
			F.StyleActionButton(button)
			
			local backdrop = button:GetBackdrop()
			backdrop.bgFile = M["Background"]["VoidStorage"]
			
			button:SetBackdrop(backdrop)
			button:SetBackdropBorderColor(unpack(C["border"]))
		end

		local postUpdateItem = function(item, itemID)
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
		
		local postUpdateStorage = function()
			for i = 1, VOID_DEPOSIT_MAX do
				postUpdateItem(_G["VoidStorageDepositButton" .. i], (GetVoidTransferDepositInfo(i)))
			end

			for i = 1, VOID_WITHDRAW_MAX do
				postUpdateItem(_G["VoidStorageWithdrawButton" .. i], (GetVoidTransferWithdrawalInfo(i)))
			end

			for i = 1, VOID_STORAGE_MAX do
				postUpdateItem(_G["VoidStorageStorageButton" .. i], (GetVoidItemInfo(i)))
			end
		end
		
		-- meh...
		RegisterCallback("VOID_STORAGE_DEPOSIT_UPDATE", postUpdateStorage)
		RegisterCallback("VOID_STORAGE_CONTENTS_UPDATE", postUpdateStorage)
		hooksecurefunc("VoidStorage_ItemsUpdate", postUpdateStorage)

		-- Adding a minor delay here, to make up for server latency.
		-- Otherwise we'll have randomly colored itembuttons, 
		-- 	as not all the buttons and items seem to appear at once.
		local timer
		VoidStorageFrame:HookScript("OnShow", function(self)
			-- kill the existing timer
			if (timer) then
				CancelTimer(timer)
				timer = nil
			end
			
			-- make a new timer
			if not(timer) then
				-- func, interval, delay, duration, endFunc
				timer = ScheduleTimer(postUpdateStorage, 1/5, 0, 5, function() timer = nil end)
			end
		end)
		
		postUpdateStorage()
	end
	F.SkinAddOn("Blizzard_VoidStorageUI", SkinFunc)
end
