--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGlyph")

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
		
		GlyphFrameSideInset:RemoveTextures()
		GlyphFrameHeader1:RemoveTextures()
		GlyphFrameHeader2:RemoveTextures()
		GlyphFrameHeader3:RemoveTextures()
		GlyphFrameScrollFrame:RemoveTextures()
		GlyphFrameScrollFrameScrollChild:RemoveTextures()
		
		GlyphFrameFilterDropDown:SetUITemplate("dropdown", true, 210)

		GlyphFrameScrollFrameScrollBar:SetUITemplate("scrollbar")
		GlyphFrameSearchBox:SetUITemplate("editbox")

		GlyphFrameClearInfoFrame:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
		local backdrop = GlyphFrameSparkleFrame:SetUITemplate("backdrop", nil, 2, 0, 0, 2)
		backdrop:SetFrameLevel(GlyphFrame:GetFrameLevel() + 1)
		backdrop:SetBackdropColor(r, g, b, 3/4)

		GlyphFrameClearInfoFrameIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		GlyphFrameClearInfoFrameIcon:ClearAllPoints()
		GlyphFrameClearInfoFrameIcon:SetPoint("TOPLEFT", 3, -3)
		GlyphFrameClearInfoFrameIcon:SetPoint("BOTTOMRIGHT", -3, 3)

		GlyphFrame.levelOverlay1:SetParent(GlyphFrameSparkleFrame)
		GlyphFrame.levelOverlayText1:SetParent(GlyphFrameSparkleFrame)
		GlyphFrame.levelOverlay2:SetParent(GlyphFrameSparkleFrame)
		GlyphFrame.levelOverlayText2:SetParent(GlyphFrameSparkleFrame)

		for i = 1, 9 do
			_G["GlyphFrameGlyph" .. i]:SetFrameLevel(_G["GlyphFrameGlyph" .. i]:GetFrameLevel() + 5)
		end
		
		for i = 1, 10 do
			local button = _G["GlyphFrameScrollFrameButton" .. i]
			local icon = _G["GlyphFrameScrollFrameButton" .. i .. "Icon"]
			
			if (button) then
				button:RemoveTextures()

				button:SetFrameLevel(button:GetFrameLevel() + 2)
				button:SetUITemplate("button"):SetBackdropColor(r, g, b, panelAlpha)
			end
			
			if (icon) then
				icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			end
		end
	end
	F.SkinAddOn("Blizzard_GlyphUI", SkinFunc)
end
