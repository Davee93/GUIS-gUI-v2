--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningMacro")

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
		
		MacroFrame:RemoveTextures()
		MacroPopupFrame:RemoveTextures()
		MacroFrameSelectedMacroButton:RemoveTextures()
		MacroFrameTab1:RemoveTextures()
		MacroFrameTab2:RemoveTextures()
		MacroFrameTextBackground:RemoveTextures()
		MacroPopupNameLeft:RemoveTextures()
		MacroPopupNameMiddle:RemoveTextures()
		MacroPopupNameRight:RemoveTextures()
		MacroButtonScrollFrame:RemoveTextures()
		MacroPopupScrollFrame:RemoveTextures()
		
		MacroFramePortrait:Kill()
		
		if (MacroSaveButton) then MacroSaveButton:SetUITemplate("button") end
		if (MacroCancelButton) then MacroCancelButton:SetUITemplate("button") end
		MacroDeleteButton:SetUITemplate("button")
		MacroNewButton:SetUITemplate("button")
		MacroExitButton:SetUITemplate("button")
		MacroEditButton:SetUITemplate("button")
		MacroPopupOkayButton:SetUITemplate("button")
		MacroPopupCancelButton:SetUITemplate("button")
		MacroPopupEditBox:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
	
		MacroFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -30, -8)
	
		MacroFrame:SetUITemplate("backdrop", nil, 4, 8, 64, 26)
		MacroFrameScrollFrame:SetUITemplate("backdrop", nil, 0, 0, 0, 0):SetBackdropColor(r, g, b, panelAlpha)
		MacroButtonScrollFrame:SetUITemplate("backdrop", nil, 0, 1, -8, 3):SetBackdropColor(r, g, b, panelAlpha)
		MacroPopupFrame:SetUITemplate("backdrop", nil, 8, 12, 8, 8)
		MacroPopupScrollFrame:SetUITemplate("backdrop", nil, 13, 58, 3, 10):SetBackdropColor(r, g, b, panelAlpha)
		
		MacroButtonScrollFrameScrollBar:SetUITemplate("scrollbar")
		MacroFrameScrollFrameScrollBar:SetUITemplate("scrollbar")
		MacroPopupScrollFrameScrollBar:SetUITemplate("scrollbar")
		
		MacroFrameSelectedMacroButtonIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		MacroFrameSelectedMacroButton:SetUITemplate("itembackdrop", MacroFrameSelectedMacroButtonIcon)

		for i = 1, MAX_ACCOUNT_MACROS do
			local button = _G["MacroButton" .. i]
			local popup = _G["MacroPopupButton" .. i]
			
			if (button) then
				button:RemoveTextures()
				F.StyleActionButton(button)
			end
			
			if (popup) then
				popup:RemoveTextures()
				F.StyleActionButton(popup)
			end
		end
		
		MacroPopupFrame:HookScript("OnShow", function(self)
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", -32, 4)
		end)
		
	end
	F.SkinAddOn("Blizzard_MacroUI", SkinFunc)
	
end
