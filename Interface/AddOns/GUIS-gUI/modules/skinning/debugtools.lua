--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningDebugTools")

-- Lua API
local select = select

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
		EventTraceFrame:RemoveTextures()
		ScriptErrorsFrame:RemoveTextures()
		
		EventTraceFrame:SetUITemplate("simplebackdrop")
		ScriptErrorsFrame:SetUITemplate("simplebackdrop")
		ScriptErrorsFrameClose:SetUITemplate("closebutton")
		EventTraceFrameCloseButton:SetUITemplate("closebutton")
		ScriptErrorsFrameScrollFrameScrollBar:SetUITemplate("scrollbar")
		
		for i = 1, ScriptErrorsFrame:GetNumChildren() do
			local button = select(i, ScriptErrorsFrame:GetChildren())
			if (button:GetObjectType() == "Button") and not(button.GetName and button:GetName()) then
				button:SetUITemplate("button")
			end
		end	
	end

	F.SkinAddOn("Blizzard_DebugTools", SkinFunc)
end
