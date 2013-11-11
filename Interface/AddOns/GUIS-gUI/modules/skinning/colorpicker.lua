--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningColorPicker")

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
	
	local r, g, b, a
	
	ColorPickerFrame:SetUITemplate("simplebackdrop")

	for i = 1, ColorPickerFrame:GetNumRegions() do
		local v = select(i, ColorPickerFrame:GetRegions())
		if (v:GetObjectType() == "Texture") then
			local t = v:GetTexture()
			if ((t == [[Interface\DialogFrame\UI-DialogBox-Border]]) 
				or (t == [[Interface\DialogFrame\UI-DialogBox-Background]]) 
				or (t == [[Interface\DialogFrame\UI-DialogBox-Header]])) then
			
				v:SetTexture("")
			end
		end
	end
	
	ColorPickerCancelButton:SetUITemplate("button")
	ColorPickerOkayButton:SetUITemplate("button")
	OpacitySliderFrame:SetUITemplate("slider")
	ColorPickerFrameHeader:SetPoint("TOP", 0, 4)
	
	local copy = function()
		r, g, b = ColorPickerFrame:GetColorRGB()
		a = OpacitySliderFrame:GetValue()
	end
	
	local paste = function()
		if (r) and (g) and (b) then
			ColorPickerFrame:SetColorRGB(r, g, b)
		end
		
		if (a) then
			OpacitySliderFrame:SetValue(a)
		end
	end
	
	local copyButton = CreateFrame("Button", "ColorPickerCopyButton", ColorPickerFrame, "MagicButtonTemplate") 
	copyButton:SetText(L["Copy"])
	copyButton:SetPoint("TOPLEFT", 4, -4)
	copyButton:SetScript("OnClick", copy)
	copyButton:SetUITemplate("button", true)

	local pasteButton = CreateFrame("Button", "ColorPickerPasteButton", ColorPickerFrame, "MagicButtonTemplate") 
	pasteButton:SetText(L["Paste"])
	pasteButton:SetPoint("TOPRIGHT", -4, -4)
	pasteButton:SetScript("OnClick", paste)
	pasteButton:SetUITemplate("button", true)
	
	local CreateFontString = function()
		local box = ColorPickerFrame:CreateFontString(nil, "BACKGROUND")
		box:SetFontObject(GUIS_SystemFontNormalWhite)
		
		return box
	end
	
	local CreateEditBox = function(parent, showFunc, hideFunc)
		local clickFrame = CreateFrame("Frame", nil, ColorPickerFrame)
		clickFrame.parent = parent
		clickFrame:EnableMouse(true)
		clickFrame:SetAllPoints(parent)
		clickFrame:SetScript("OnMouseDown", function(self) self.editBox:Show() end)

		parent.clickFrame = clickFrame
		
		local editBox = CreateFrame("EditBox", nil, clickFrame)
		editBox.parent = parent
		editBox.Refresh = showFunc
		editBox:Hide()
		editBox:SetSize(48, 20)
		editBox:SetPoint("CENTER")
		editBox:SetJustifyH("RIGHT")
		editBox:SetAutoFocus(false)
		editBox:SetUITemplate("editbox")
		editBox:SetScript("OnHide", hideFunc)
		editBox:SetScript("OnShow", function(self) 
			showFunc(self)
			self:SetFocus()
			self:HighlightText() -- EditBox_HighlightText
		end)
		editBox:SetScript("OnEscapePressed", function(self) self:Hide() end)
		editBox:SetScript("OnEnterPressed", function(self) self:Hide() end)
		editBox:SetScript("OnEditFocusLost", function(self) self:Hide() end)

		parent.editBox = editBox
		clickFrame.editBox = editBox
	end
	
	local setR = CreateFontString()
	setR:SetPoint("TOPLEFT", ColorSwatch, "BOTTOMLEFT", 0, -8)
	CreateEditBox(setR, function(self) 
		self:SetText(("%.2f"):format((select(1, ColorPickerFrame:GetColorRGB())))) 
	end, 
	function(self) 
		local n = tonumber(self:GetText())
		if (n) and (n >= 0) and (n <= 1) then
			local r, g, b = ColorPickerFrame:GetColorRGB()
			ColorPickerFrame:SetColorRGB(n, g, b)
			self.parent:Refresh() 
		end
	end)
	
	local setG = CreateFontString()
	setG:SetPoint("TOPLEFT", setR, "BOTTOMLEFT", 0, -8)
	CreateEditBox(setG, function(self) 
		self:SetText(("%.2f"):format((select(2, ColorPickerFrame:GetColorRGB())))) 
	end, 
	function(self) 
		local n = tonumber(self:GetText())
		if (n) and (n >= 0) and (n <= 1) then
			local r, g, b = ColorPickerFrame:GetColorRGB()
			ColorPickerFrame:SetColorRGB(r, n, b)
			self.parent:Refresh() 
		end
	end)

	local setB = CreateFontString()
	setB:SetPoint("TOPLEFT", setG, "BOTTOMLEFT", 0, -8)
	CreateEditBox(setB, function(self) 
		self:SetText(("%.2f"):format((select(3, ColorPickerFrame:GetColorRGB())))) 
	end, 
	function(self) 
		local n = tonumber(self:GetText())
		if (n) and (n >= 0) and (n <= 1) then
			local r, g, b = ColorPickerFrame:GetColorRGB()
			ColorPickerFrame:SetColorRGB(r, g, n)
			self.parent:Refresh() 
		end
	end)	
	
	local setA = CreateFontString()
	setA:SetPoint("TOPLEFT", setB, "BOTTOMLEFT", 0, -8)
	CreateEditBox(setA, function(self) 
		self:SetText(("%.2f"):format(1 - OpacitySliderFrame:GetValue())) 
	end, 
	function(self) 
		local n = tonumber(self:GetText())
		if (n) and (n >= 0) and (n <= 1) then
			OpacitySliderFrame:SetValue(1 - n)
			self.parent:Refresh() 
		end
	end)
	
	updateText = function() 
		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = OpacitySliderFrame:GetValue()

		setR:SetText(("%s: |cFFFFD100%.2f|r"):format(L["R"], r))
		setG:SetText(("%s: |cFFFFD100%.2f|r"):format(L["G"], g))
		setB:SetText(("%s: |cFFFFD100%.2f|r"):format(L["B"], b))
		setA:SetText(("%s: |cFFFFD100%.2f|r"):format(L["A"], 1 - a))
		
		setR.editBox:Refresh()
		setG.editBox:Refresh()
		setB.editBox:Refresh()
		setA.editBox:Refresh()
	end
	
	setR.Refresh = updateText
	setG.Refresh = updateText
	setB.Refresh = updateText
	setA.Refresh = updateText
	
	ColorPickerFrame:HookScript("OnShow", updateText)
	ColorPickerFrame:HookScript("OnColorSelect", updateText)
	OpacitySliderFrame:HookScript("OnValueChanged", updateText)
end
