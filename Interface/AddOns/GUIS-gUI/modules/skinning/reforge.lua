--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningReforge")

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
		
		ReforgingFrame:RemoveTextures()
	
		-- removed in 4.3
		if (ReforgingFrameTopInset) then ReforgingFrameTopInset:RemoveTextures() end
		if (ReforgingFrameInset) then ReforgingFrameInset:RemoveTextures() end
		if (ReforgingFrameBottomInset) then ReforgingFrameBottomInset:RemoveTextures() end
		if (ReforgingFrameFilterOldStat) then 
			ReforgingFrameFilterOldStat:RemoveTextures() 
			ReforgingFrameFilterOldStatButton:SetUITemplate("arrow", "down")
		end
		if (ReforgingFrameFilterNewStat) then 
			ReforgingFrameFilterNewStat:RemoveTextures() 
			ReforgingFrameFilterNewStatButton:SetUITemplate("arrow", "down")
		end
		
		ReforgingFrameItemButton:RemoveTextures()
		
		ReforgingFrameRestoreButton:SetUITemplate("button", true)
		ReforgingFrameReforgeButton:SetUITemplate("button", true)
		ReforgingFrameCloseButton:SetUITemplate("closebutton")

		ReforgingFrame:SetUITemplate("simplebackdrop")

		ReforgingFrameItemButton:SetUITemplate("simplebackdrop")
		ReforgingFrameItemButtonIconTexture:ClearAllPoints()
		ReforgingFrameItemButtonIconTexture:SetPoint("TOPLEFT", ReforgingFrameItemButton, "TOPLEFT", 3, -3)
		ReforgingFrameItemButtonIconTexture:SetPoint("BOTTOMRIGHT", ReforgingFrameItemButton, "BOTTOMRIGHT", -3, 3)
		
		if (F.IsBuild(4,3,0)) then
			ReforgingFrameButtonFrame:RemoveTextures()
			ReforgingFrameButtonFrameButtonBorder:RemoveTextures()
			ReforgingFrameButtonFrameButtonBottomBorder:RemoveTextures()
			ReforgingFrameButtonFrameMoneyLeft:RemoveTextures()
			ReforgingFrameButtonFrameMoneyRight:RemoveTextures()
			ReforgingFrameButtonFrameMoneyMiddle:RemoveTextures()

			ReforgingFrameReforgeButton:ClearAllPoints()
			ReforgingFrameReforgeButton:SetPoint("BOTTOMRIGHT", ReforgingFrame, "BOTTOMRIGHT", -8, 8)

			ReforgingFrameRestoreButton:ClearAllPoints()
			ReforgingFrameRestoreButton:SetPoint("BOTTOMRIGHT", ReforgingFrameReforgeButton, "BOTTOMLEFT", -8, 0)
			
			ReforgingFrameMoneyFrame:ClearAllPoints()
			ReforgingFrameMoneyFrame:SetPoint("BOTTOMLEFT", ReforgingFrame, 16, 12)
			
			ReforgingFrameRestoreMessage:SetTextColor(unpack(C["index"]))
			ReforgingFrame.missingDescription:SetTextColor(unpack(C["index"]))
			
			local statbackdrop = CreateFrame("Frame", nil, ReforgingFrame)
			statbackdrop:SetPoint("TOP", ReforgingFrameLeftStat1, "TOP", 0, 8)
			statbackdrop:SetPoint("LEFT", ReforgingFrame, "LEFT", 12, 0)
			statbackdrop:SetPoint("BOTTOMRIGHT", ReforgingFrame, "BOTTOMRIGHT", -12, 34)
			statbackdrop:SetFrameLevel(ReforgingFrame:GetFrameLevel())
			
			statbackdrop:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
			
			ReforgingFrameFinishedGlowFinishedFlare:ClearAllPoints()
			ReforgingFrameFinishedGlowFinishedFlare:SetPoint("TOPLEFT", statbackdrop, "TOPLEFT", 3, -3)
			ReforgingFrameFinishedGlowFinishedFlare:SetPoint("BOTTOMRIGHT", statbackdrop, "BOTTOMRIGHT", -3, 3)
		end

		local updateButton = function(self)
			if (select(2, GetReforgeItemInfo())) then
				ReforgingFrameItemButtonIconTexture:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			else
				ReforgingFrameItemButtonIconTexture:SetTexture("")
			end
		end
		hooksecurefunc("ReforgingFrame_Update", updateButton)
	end
	F.SkinAddOn("Blizzard_ReforgingUI", SkinFunc)
end
