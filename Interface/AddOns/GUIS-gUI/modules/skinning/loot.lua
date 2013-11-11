--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningLoot")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end
	
	if not(MissingLootFrame) then
		return
	end

	MissingLootFrame:RemoveTextures()
	
	MissingLootFramePassButton:SetUITemplate("closebutton")
	MissingLootFrame:SetUITemplate("backdrop", nil, 4, 4, -10, 4)
	
	
	UIPARENT_MANAGED_FRAME_POSITIONS["MissingLootFrame"] = nil
	
	MissingLootFrame:SetPoint("BOTTOM", 0, 220) -- same point as we initially set the first roll frame
	MissingLootFrameLabel:SetFontObject(GUIS_SystemFontSmall)
	
	local skinItemButton = function(button)
		-- debugging
		--[[
		button.icon:SetTexture(0,1,0)
		button.count:SetText("45"); button.count:Show()
		button.name:SetText("Incredible Item of Total Imbaness")
		]]--

		local iconTexture = button.icon:GetTexture()
		
		button:SetWidth(button:GetWidth() - 6)
		button:SetHeight(button:GetHeight() - 6)

		button.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		button.name:SetFontObject(GUIS_SystemFontSmall)
		button.count:SetFontObject(GUIS_NumberFontSmall)
		
		local nameFrame = _G[button:GetName() .. "NameFrame"]
		nameFrame:SetTexture("")
		
		local IconBackdrop = CreateFrame("Frame", nil, button)
		IconBackdrop:SetAllPoints(button.icon)
		IconBackdrop:SetUITemplate("border")

		button.IconBackdrop = IconBackdrop
		
		button.icon:SetParent(button.IconBackdrop)

		button.count:SetParent(button.IconBackdrop)
		button.count:SetDrawLayer("OVERLAY")
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 0, 1)

		for i = 1, button:GetNumRegions() do
			local region = select(i, button:GetRegions())
			if (region) and (region:GetObjectType() == "Texture") then
				if (region:GetTexture() == "Interface\\Common\\Icon-NoLoot") then
					region:SetParent(button.IconBackdrop)
					region:ClearAllPoints()
					region:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMLEFT", -3, -3)
				else
					region:SetTexture("")
				end
			end
		end

		button.icon:SetTexture(iconTexture)
	end
	
	local skinned = {}
	local skinItems = function()
		for i = 1, MissingLootFrame.numShownItems do
			local texture, name, count, quality = GetMissingLootItemInfo(i)
			local button = _G["MissingLootFrameItem" .. i]
			local point, anchor, relpoint, x, y = button:GetPoint()
						
			button:SetPoint(point, anchor, relpoint, (x == 0) and 0 or (x + 3), (y == 0) and 0 or (y - 3))
			
			if (button) then 
				if not(skinned[i]) then
					skinItemButton(button)
					skinned[i] = true
				end
				
				local color = ITEM_QUALITY_COLORS[quality]
				button.IconBackdrop:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end
	
	skinItemButton(MissingLootFrameItem1)
	
	hooksecurefunc("MissingLootFrame_Show", skinItems)
	
end
