--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGuildRegistrar")

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
	
	GuildRegistrarFrame:RemoveTextures()
	GuildRegistrarGreetingFrame:RemoveTextures()
	
	GuildRegistrarFrame:SetUITemplate("backdrop", nil, 18, 12, 64, 34)
	GuildRegistrarFrameCloseButton:SetUITemplate("closebutton")
	GuildRegistrarFrameGoodbyeButton:SetUITemplate("button")
	GuildRegistrarFrameCancelButton:SetUITemplate("button")
	GuildRegistrarFramePurchaseButton:SetUITemplate("button")

	GuildRegistrarFrameEditBox:SetUITemplate("editbox", -4, 0, 4, 0)

	for i = 1, GuildRegistrarFrameEditBox:GetNumRegions() do
		local region = select(i, GuildRegistrarFrameEditBox:GetRegions())
		if (region:GetObjectType() == "Texture") then
			if (region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left") or (region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right") then
				region:RemoveTextures()
			end
		end
	end
	
	GuildRegistrarText:SetFontObject(GUIS_SystemFontNormal)
	GuildRegistrarText:SetTextColor(unpack(C["index"]))

	GuildRegistrarPurchaseText:SetTextColor(unpack(C["index"]))
	AvailableServicesText:SetTextColor(unpack(C["value"]))

	GuildRegistrarButton1:SetNormalFontObject(GUIS_SystemFontSmall)
	GuildRegistrarButton2:SetNormalFontObject(GUIS_SystemFontSmall)
end
