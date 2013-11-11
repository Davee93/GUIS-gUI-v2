--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningMovePad")

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
		MovePadFrame:RemoveTextures()
		MovePadFrame:SetUITemplate("simplebackdrop")
		
		local buttons = {
			"MovePadStrafeLeft";
			"MovePadStrafeRight";
			"MovePadForward";
			"MovePadBackward";
			"MovePadJump";
		}
		local t, bName, b, i
		for _,bName in pairs(buttons) do
			b = _G[bName]
			i = _G[bName .. "Icon"]
			t = i:GetTexture()
			
			b:RemoveTextures()
			b:SetUITemplate("button")
			b:CreateHighlight()
			b:CreatePushed()

			i:SetTexture(t)
			i:SetDrawLayer("OVERLAY")
		end
		
		local first = MovePadLock:GetRegions()
		first:RemoveTextures()
	end
	F.SkinAddOn("Blizzard_MovePad", SkinFunc)
	
end
