--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: VehicleExitButton")

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gFH = LibStub("gFrameHandler-1.0")
local gAB = LibStub("gActionBars-2.0")

-- Globals:
-- VehicleExitButton
local VehicleExitButton

local CreateExitButton = function(name)
	local button = CreateFrame("Button", name, UIParent, "SecureHandlerClickTemplate")
	button:SetSize(37, 37)
	button:SetUITemplate("simplebackdrop")
	
	button.Background = button:CreateTexture()
	button.Background:SetDrawLayer("BACKGROUND", 1)
	button.Background:SetTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]])
	button.Background:SetTexCoord(17/64, 51/64, 17/64, 51/64)
	button.Background:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
	button.Background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)

	F.GlossAndShade(button, button.Background)

	local hover = button:CreateTexture()
	hover:SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 1/3)
	hover:SetAllPoints(button.Background)
	button:SetHighlightTexture(hover)

	local pushed = button:CreateTexture()
	pushed:SetTexture(C["pushed"].r, C["pushed"].g, C["pushed"].b, 1/3)
	pushed:SetAllPoints(button.Background)
	pushed:SetAlpha(0)
	
	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function() VehicleExit() end)
	button:SetScript("OnMouseDown", function(self) pushed:SetAlpha(1) end)
	button:SetScript("OnMouseUp", function(self) pushed:SetAlpha(0) end)

	RegisterStateDriver(button, "visibility", "[vehicleui] show; hide")
	
	return button
end

module.OnInit = function(self)
	if F.kill("GUIS-gUI: ActionBars") then 
		self:Kill() 
		return 
	end
end

-- need to 
module.OnEnable = function(self)
	-- layoutspecific buttons
	local bars = LibStub("gCore-3.0"):GetModule("GUIS-gUI: ActionBars")
	if (bars) then
		if (GUIS_DB["actionbars"].layout == 1) or (GUIS_DB["actionbars"].layout == 2) then
			local left, right = bars:GetPanel("left"), bars:GetPanel("right")
			CreateExitButton(left:GetName() .. "VehicleExitButton"):SetPoint("TOPRIGHT", left, -4, 0)
			CreateExitButton(right:GetName() .. "VehicleExitButton"):SetPoint("TOPLEFT", right, 4, 0)
			
			return
		end
	end

	-- movable exit button
	VehicleExitButton = CreateExitButton("VehicleExitButton")
	VehicleExitButton:PlaceAndSave("CENTER", "UIParent", "CENTER", -270, -150)
	
	-- make it a global, it ought to be
	_G.VehicleExitButton = VehicleExitButton
end


