--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningSocket")

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
		
		ItemSocketingFrame:RemoveTextures()
		ItemSocketingScrollFrame:RemoveTextures()

		ItemSocketingFramePortrait:Kill()
		
		ItemSocketingSocketButton:SetUITemplate("button", true)
		ItemSocketingCloseButton:SetUITemplate("closebutton")
		ItemSocketingFrame:SetUITemplate("backdrop", nil, 7, 12, 27, 6)
		ItemSocketingScrollFrame:SetUITemplate("backdrop", nil, -2, 0, -1, 0):SetBackdropColor(r, g, b, panelAlpha)
		ItemSocketingScrollFrameScrollBar:SetUITemplate("scrollbar")
		
		for i = 1, MAX_NUM_SOCKETS do
			local button = _G["ItemSocketingSocket"..i]
			local icon = _G["ItemSocketingSocket"..i.."IconTexture"]
			
			button:RemoveTextures()
			_G["ItemSocketingSocket"..i.."BracketFrame"]:RemoveTextures()
			_G["ItemSocketingSocket"..i.."Background"]:RemoveTextures()

			button:SetUITemplate("backdrop")
			icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			local updateFunc = function(self)
				local color = GEM_TYPE_INFO[GetSocketTypes(i)]
				button:SetBackdropColor(color.r, color.g, color.b, 15/100)
				button:SetBackdropBorderColor(color.r, color.g, color.b)
			end
			ItemSocketingFrame:HookScript("OnUpdate", updateFunc)
		end

	end
	F.SkinAddOn("Blizzard_ItemSocketingUI", SkinFunc)
end
