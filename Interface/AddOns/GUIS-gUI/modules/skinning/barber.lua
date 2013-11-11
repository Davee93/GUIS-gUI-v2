--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningBarberShop")

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
		BarberShopFrame:RemoveTextures(true)
		BarberShopFrameBackground:RemoveTextures()
		BarberShopAltFormFrameBackground:RemoveTextures()
		BarberShopAltFormFrameBorder:RemoveTextures()
		BarberShopFrameMoneyFrame:RemoveTextures()
--		BarberShopBannerFrame:RemoveTextures()
--		BarberShopBannerFrameBGTexture:RemoveTextures()
		BarberShopFrameOkayButton:RemoveTextures()
		BarberShopFrameCancelButton:RemoveTextures()
		BarberShopFrameResetButton:RemoveTextures()
		
		BarberShopFrameOkayButton:SetUITemplate("button", true)
		BarberShopFrameCancelButton:SetUITemplate("button", true)
		BarberShopFrameResetButton:SetUITemplate("button", true)
		
		BarberShopFrame:SetUITemplate("backdrop", nil, 32, 32, 32, 32)
		BarberShopAltFormFrame:SetUITemplate("backdrop", nil, -3, -2, -4, -3)
		
		for i = 1, 4 do
			local selector = _G["BarberShopFrameSelector" .. i]
			if (selector) then
				selector:RemoveTextures()
				_G["BarberShopFrameSelector" .. i .. "Prev"]:SetUITemplate("arrow", "left")
				_G["BarberShopFrameSelector" .. i .. "Next"]:SetUITemplate("arrow", "right")
			end
		end
	
	end
	F.SkinAddOn("Blizzard_BarbershopUI", SkinFunc)
end
