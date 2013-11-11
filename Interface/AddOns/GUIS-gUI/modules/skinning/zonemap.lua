--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningZoneMap")

-- Lua API
local _G = _G
local unpack = unpack

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
		local zoneMap = CreateFrame("Frame", "GUIS_ZoneMap", UIParent)
		zoneMap:Hide()
		zoneMap:SetPoint(unpack(GUIS_DB["skinning"].zoneMap.pos))
		zoneMap:SetSize(219, 147) -- 225, 150 
		zoneMap:SetFrameStrata("MEDIUM")
		zoneMap:SetFrameLevel(50)
		zoneMap:EnableMouse(true)
		zoneMap:SetMovable(true)
		
		zoneMap.bg = CreateFrame("Frame", nil, zoneMap)
		zoneMap.bg:SetUITemplate("backdrop")
		zoneMap.bg:SetAllPoints()
		zoneMap.bg:SetFrameLevel(0)

		zoneMap.alpha = 1
		
		local once
		BattlefieldMinimap:SetScript("OnShow", function(self)
			zoneMap:Show()		
			
			if not(once) then
				BattlefieldMinimapCorner:RemoveTextures()
				BattlefieldMinimapBackground:RemoveTextures()
				BattlefieldMinimapTabLeft:RemoveTextures()
				BattlefieldMinimapTabMiddle:RemoveTextures()
				BattlefieldMinimapTabRight:RemoveTextures()

				BattlefieldMinimapTab:Kill()
				
				BattlefieldMinimapCloseButton:SetUITemplate("closebutton")
				
				once = true
			end

			
			self:SetParent(UIParent) -- zoneMap
			self:SetPoint("TOPLEFT", zoneMap, "TOPLEFT", 0, 0)
			self:SetFrameStrata(zoneMap:GetFrameStrata())
			self:SetFrameLevel(49)

			BattlefieldMinimapCloseButton:ClearAllPoints()
			BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", -4, 0)
			BattlefieldMinimapCloseButton:SetFrameLevel(51)

			zoneMap:SetScale(1)
			zoneMap:SetAlpha(zoneMap.alpha)
			
			BattlefieldMinimap_Update()
		end)

		BattlefieldMinimap:SetScript("OnHide", function(self)
			zoneMap:SetScale(0.00001)
			zoneMap:SetAlpha(0)
		end)

		zoneMap:SetScript("OnMouseUp", function(self, button)
			if (button == "LeftButton") then
				self:StopMovingOrSizing()
				
				-- store the position ( gFrameHandler-1.0.35 or higher )
				GUIS_DB["skinning"].zoneMap.pos = { self:GetRealPoint() }
				
				if (OpacityFrame:IsShown()) then 
					OpacityFrame:Hide() 
				end 
			elseif (button == "RightButton") then
				ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
				if (OpacityFrame:IsShown()) then 
					OpacityFrame:Hide() 
				end 
			end
		end)

		zoneMap:SetScript("OnMouseDown", function(self, button)
			if (button == "LeftButton") then
				if (BattlefieldMinimapOptions) and (BattlefieldMinimapOptions.locked) then
					return
				else
					self:StartMoving()
				end
			end
		end)
		
		-- taint or yay?
		BattlefieldMinimap_UpdateOpacity = function(opacity)
			BattlefieldMinimapOptions.opacity = opacity or OpacityFrameSlider:GetValue()
			
			local alpha = 1.0 - BattlefieldMinimapOptions.opacity
			BattlefieldMinimapBackground:SetAlpha(alpha)
			
			if ( alpha >= 0.15 ) then
				alpha = alpha - 0.15
			end
			
			local reverse
			if (GetNumberOfDetailTiles) then
				local numDetailTiles = GetNumberOfDetailTiles()
				local tile
				for i = 1, numDetailTiles do
					tile = _G["BattlefieldMinimap" .. i]
					if (tile) then
						tile:SetAlpha(alpha)
					end
				end
			else
				reverse = true
			end
			
			if (NUM_BATTLEFIELDMAP_OVERLAYS) then
				local overlay
				for i = 1, NUM_BATTLEFIELDMAP_OVERLAYS do
					overlay = _G["BattlefieldMinimapOverlay" .. i]
					if (overlay) then
						overlay:SetAlpha(alpha)
					end
				end
			end
			
			if (BattlefieldMinimapCorner) then
				BattlefieldMinimapCorner:SetAlpha(alpha)
			end

			local reverseAlpha = (reverse) and 1 - alpha or alpha
			BattlefieldMinimapCloseButton:SetAlpha(reverseAlpha)
			zoneMap:SetAlpha(reverseAlpha)
			zoneMap.alpha = reverseAlpha
		end
--		hooksecurefunc("BattlefieldMinimap_UpdateOpacity", opacityFunc)
		
		BattlefieldMinimap_UpdateOpacity(BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 1)
	end

	F.SkinAddOn("Blizzard_BattlefieldMinimap", SkinFunc)
	
end
