--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTabard")

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

	local whiteList = {
		["TabardFrameEmblemTopRight"] = true;
		["TabardFrameEmblemTopLeft"] = true;
		["TabardFrameEmblemBottomRight"] = true;
		["TabardFrameEmblemBottomLeft"] = true;
	}
	
	for i = 1, TabardFrame:GetNumRegions() do
		local region = select(i, TabardFrame:GetRegions())
		if (region:GetObjectType() == "Texture") then
			if not(region:GetName() and whiteList[region:GetName()]) then
				region:SetTexture("")
			end
		end
	end
	
	TabardFrameCostFrame:RemoveTextures() 
	TabardFrameCustomizationFrame:RemoveTextures()
	TabardFrameCustomization1:RemoveTextures()
	TabardFrameCustomization2:RemoveTextures()
	TabardFrameCustomization3:RemoveTextures()
	TabardFrameCustomization4:RemoveTextures()
	TabardFrameCustomization5:RemoveTextures()
	
	if (TabardCharacterModelRotateLeftButton) then TabardCharacterModelRotateLeftButton:SetUITemplate("arrow", "left") end
	if (TabardCharacterModelRotateRightButton) then TabardCharacterModelRotateRightButton:SetUITemplate("arrow", "right") end 

	TabardFrameCustomization1LeftButton:SetUITemplate("arrow", "left")
	TabardFrameCustomization1RightButton:SetUITemplate("arrow", "right")
	TabardFrameCustomization2LeftButton:SetUITemplate("arrow", "left")
	TabardFrameCustomization2RightButton:SetUITemplate("arrow", "right")
	TabardFrameCustomization3LeftButton:SetUITemplate("arrow", "left")
	TabardFrameCustomization3RightButton:SetUITemplate("arrow", "right")
	TabardFrameCustomization4LeftButton:SetUITemplate("arrow", "left")
	TabardFrameCustomization4RightButton:SetUITemplate("arrow", "right")
	TabardFrameCustomization5LeftButton:SetUITemplate("arrow", "left")
	TabardFrameCustomization5RightButton:SetUITemplate("arrow", "right")

	TabardFrameCancelButton:SetUITemplate("button")
	TabardFrameAcceptButton:SetUITemplate("button")
	TabardFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -24, -8)
	
	TabardFrame:SetUITemplate("backdrop", nil, 0, 0, 64, 16)
end
