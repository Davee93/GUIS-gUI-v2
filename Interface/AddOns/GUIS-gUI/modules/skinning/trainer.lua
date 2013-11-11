--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTrainer")

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
		
		ClassTrainerFrame:RemoveTextures()
		ClassTrainerScrollFrameScrollChild:RemoveTextures()
		ClassTrainerFrameSkillStepButton:RemoveTextures()
		ClassTrainerFrameBottomInset:RemoveTextures()
		ClassTrainerFrameInset:RemoveTextures()
		ClassTrainerFramePortrait:RemoveTextures()
		
		ClassTrainerFramePortrait:Kill()

		ClassTrainerTrainButton:SetUITemplate("button", true)
		ClassTrainerFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -4, -4)
		ClassTrainerFrameFilterDropDown:SetUITemplate("dropdown", true)
		ClassTrainerScrollFrameScrollBar:SetUITemplate("scrollbar")

		if (ClassTrainerStatusBar) then 
			ClassTrainerStatusBar:SetUITemplate("statusbar", true)
			ClassTrainerStatusBar:SetSize(180, 15)
			ClassTrainerStatusBar:SetPoint("TOPLEFT", 9, -36)
		end
		
		ClassTrainerFrame:SetUITemplate("backdrop", nil, -3, 0, 0, 0)
		ClassTrainerScrollFrame:SetUITemplate("backdrop", nil, 0, 2, -1, 0):SetBackdropColor(r, g, b, panelAlpha)
		ClassTrainerScrollFrame:SetHeight(ClassTrainerScrollFrame:GetHeight() - 8)

		local backdrop = ClassTrainerFrameSkillStepButton:SetUITemplate("itembackdrop", ClassTrainerFrameSkillStepButton.icon)
		ClassTrainerFrameSkillStepButton.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		ClassTrainerFrameSkillStepButton.icon:SetParent(backdrop)
		ClassTrainerFrameSkillStepButtonHighlight:SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 1/3)
		ClassTrainerFrameSkillStepButton.selectedTex:SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 1/3)		
		F.GlossAndShade(backdrop, ClassTrainerFrameSkillStepButton.icon)
		
		for i,button in pairs(ClassTrainerScrollFrame.buttons) do
			local icon = _G[button:GetName() .. "Icon"]
			
			button:RemoveTextures()
			
			local backdrop = button:SetUITemplate("itembackdrop", icon)
			
			icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			icon:SetParent(backdrop)
			
			F.GlossAndShade(backdrop, icon)

			local highlight = button:CreateHighlight()
			highlight:ClearAllPoints()
			highlight:SetPoint("BOTTOM", icon, "BOTTOM", 0, -5)
			highlight:SetPoint("LEFT", icon, "LEFT", -5, 0)
			highlight:SetPoint("TOP", icon, "TOP", 0, 5)
			highlight:SetPoint("RIGHT", button, "RIGHT", 1, 0)
				
			local pushed = button:CreatePushed()
			pushed:ClearAllPoints()
			pushed:SetAllPoints(highlight)

			button.selectedTex:SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 1/3)
			button.selectedTex:SetAllPoints(highlight)

			_G[button:GetName() .. "Highlight"] = highlight
			_G[button:GetName() .. "Pushed"] = pushed
		end
	end
	F.SkinAddOn("Blizzard_TrainerUI", SkinFunc)
end
