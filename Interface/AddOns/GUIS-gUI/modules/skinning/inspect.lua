--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningInspect")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local Skin
local gearSlots = {
	"BackSlot";
	"ChestSlot";
	"HandsSlot";
	"HeadSlot";
	"FeetSlot";
	"Finger0Slot";
	"Finger1Slot";
	"LegsSlot";
	"MainHandSlot";
	"NeckSlot";
	"RangedSlot";
	"SecondaryHandSlot";
	"ShirtSlot";
	"ShoulderSlot";
	"TabardSlot";
	"Trinket0Slot";
	"Trinket1Slot";
	"WaistSlot";
	"WristSlot";
}

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end

	local SkinFunc = function()
		InspectFrame:RemoveTextures()
		InspectFrameInset:RemoveTextures()
		InspectTalentFramePointsBar:RemoveTextures()
		InspectModelFrameBorderTopLeft:RemoveTextures()
		InspectModelFrameBorderTopRight:RemoveTextures()
		InspectModelFrameBorderTop:RemoveTextures()
		InspectModelFrameBorderLeft:RemoveTextures()
		InspectModelFrameBorderRight:RemoveTextures()
		InspectModelFrameBorderBottomLeft:RemoveTextures()
		InspectModelFrameBorderBottomRight:RemoveTextures()
		InspectModelFrameBorderBottom:RemoveTextures()
		InspectModelFrameBorderBottom2:RemoveTextures()
		InspectModelFrameBackgroundOverlay:RemoveTextures()
		InspectPVPFrameBottom:RemoveTextures()
		InspectGuildFrameBG:RemoveTextures()
		InspectPVPTeam1:RemoveTextures()
		InspectPVPTeam2:RemoveTextures()
		InspectPVPTeam3:RemoveTextures()
		InspectTalentFrameTab1:RemoveTextures()
		InspectTalentFrameTab2:RemoveTextures()
		InspectTalentFrameTab3:RemoveTextures()
		
		if (InspectModelFrameRotateLeftButton) then InspectModelFrameRotateLeftButton:SetUITemplate("arrow", "left") end
		if (InspectModelFrameRotateRightButton) then InspectModelFrameRotateRightButton:SetUITemplate("arrow", "right") end
		
		InspectFrameCloseButton:SetUITemplate("closebutton")
		
		InspectFrame:SetUITemplate("backdrop")
		InspectModelFrame:SetUITemplate("backdrop", nil, 0, 0, 0, 0):SetBackdropColor(0, 0, 0, 1)
		InspectTalentFrame:SetUITemplate("backdrop")
		
		InspectFrameTab1:SetUITemplate("tab")
		InspectFrameTab2:SetUITemplate("tab")
		InspectFrameTab3:SetUITemplate("tab")
		InspectFrameTab4:SetUITemplate("tab")
		
		InspectFramePortrait:Kill()
		
		InspectPVPFrame:HookScript("OnShow", function() 
			InspectPVPFrameBG:RemoveTextures() 
		end)
		
		for i,v in pairs(gearSlots) do
			local button = _G["Inspect" .. v]

			button:RemoveTextures()
			F.StyleActionButton(button)
		end
		
		for i = 1, MAX_NUM_TALENTS do
			local button = _G["InspectTalentFrameTalent" .. i]

			if (button) then
				button:RemoveTextures()
				F.StyleActionButton(button)
			end
		end	
	
	end
	F.SkinAddOn("Blizzard_InspectUI", SkinFunc)
	
end
