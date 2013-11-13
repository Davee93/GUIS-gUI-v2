local GUIS = LibStub("gCore-3.0"):GetModule("GUIS-gUI: Core")
local M = LibStub("gMedia-3.0")
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

if IsAddOnLoaded("Skada") then

local function CreateBackdrop(b)
	
	local s = CreateFrame("Frame", nil, b)
	s:SetPoint("TOPLEFT", -2, 2)
	s:SetPoint("BOTTOMRIGHT", 2, -2)
	if b:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(b:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end
	
	b.backdrop = s
end

local Skada = Skada
local barSpacing = 1, 1
local borderWidth = 1, 1

local barmod = Skada.displays["bar"]

local titleBG = {
	bgFile = "Interface\\AddOns\\GUIS-gUI\\media\\texture\\statusbar",
	tile = false,
	tileSize = 0
}

--[[local function CreateBar(win, name, label, value, maxvalue, icon, o)
	local bar = win.bargroup:NewCounterBar(name, label, value, maxvalue, icon, o)
	bar:EnableMouseWheel(true)
	bar:CreateUIShadow()
	F.GlossAndShade(bar)
	bar.iconFrame:SetUITemplate("simpleborder")
	bar:SetScript("OnMouseWheel", function(f, d) mod:OnMouseWheel(win, f, d) end)
	bar.iconFrame:SetScript("OnEnter", nil)
	bar.iconFrame:SetScript("OnLeave", nil)
	bar.iconFrame:EnableMouse(false)
	return bar
end]]--

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
barmod.ApplySettings_(self, win)
	
	local skada = win.bargroup

	if win.db.enabletitle then
		skada.button:SetBackdrop(titleBG)
		skada.button:SetBackdropColor(.05,.05,.05, .9)
		--F.GlossAndShade(skada.button)
	end

	skada:SetTexture("Interface\\AddOns\\GUIS-gUI\\media\\texture\\statusbar")
	skada:SetSpacing(barSpacing)
	--F.GlossAndShade(barmod)
	skada:SetFont("Interface\\AddOns\\GUIS-gUI\\media\\fonts\\PT Sans Narrow Bold.ttf", 12, "OUTLINE")
	skada:SetFrameLevel(5)
	
	skada:SetBackdrop(nil)
	if not skada.backdrop then
		CreateBackdrop(skada)
		skada.backdrop:ClearAllPoints()
		skada.backdrop:SetPoint('TOPLEFT', win.bargroup.button or win.bargroup, 'TOPLEFT', 0, 0)
		skada.backdrop:SetPoint('BOTTOMRIGHT', win.bargroup, 'BOTTOMRIGHT', 0, 0)
		skada.backdrop:SetUITemplate("backdrop")
	end	
end

for _, window in ipairs(Skada:GetWindows()) do
	window:UpdateDisplay()
	end
end
