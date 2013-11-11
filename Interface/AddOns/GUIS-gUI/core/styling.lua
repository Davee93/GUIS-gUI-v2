--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

-- Lua API
local _G = _G
local select, unpack = select, unpack
local floor = math.floor
local gsub, strupper = string.gsub, string.upper
local getmetatable = getmetatable

-- WoW API
local CreateFrame = CreateFrame
local EnumerateFrames = EnumerateFrames
local GetActionInfo = GetActionInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local IsEquippedAction = IsEquippedAction

-- GUIS API
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local M = LibStub("gMedia-3.0")
local gPanel = LibStub("gPanel-2.0")

local RemoveTextures, RemoveClutter
local CreateHighlight, CreateChecked, CreatePushed

local NUM_MOUSE_BUTTONS = 31

------------------------------------------------------------------------------------------------------------
-- 	UI Panel Templates
------------------------------------------------------------------------------------------------------------
--[[
	the format of all UI templates should follow some simple rules, 
	as assumptions are made by the modules that use them.
	
	1) calling them multiple times should NOT create additional new elements
	2) there should always be a return value, and that should be whatever object
		SetBackdropColor() can be applied to
]]--
local panelAlpha = 9/10
local SetHoverScripts = function(object)
	if not(object._hasHoverScripts) then
		object.__originalRGB = { object:GetBackdropColor() }
		object.__originalBorderRGB = { object:GetBackdropBorderColor() }
		
		object:HookScript("OnEnter", function(object) 
--			object:SetBackdropColor(C["hovercolor"][1], C["hovercolor"][2], C["hovercolor"][3])
			object:SetBackdropColor(0, 0, 0)
			object:SetBackdropBorderColor(C["hoverbordercolor"][1], C["hoverbordercolor"][2], C["hoverbordercolor"][3])
		end)

		object:HookScript("OnLeave", function(object)
			object:SetBackdropColor(unpack(object.__originalRGB))
			object:SetBackdropBorderColor(unpack(object.__originalBorderRGB))
		end)
		
		object._hasHoverScripts = true
	end
end

local SetShineScripts = function(object, shineAlpha, shineDuration, shineScale)
	if not(object.__hasShineEffect) then
		object.shineFrame = F.Shine:New(object, shineAlpha, shineDuration, shineScale)
		
		object:HookScript("OnEnter", function(self) 
			self.shineFrame:Start()
		end)
	
		object.__hasShineEffect = true
	end
end

gPanel:RegisterUITemplate("simpleborder", function(object)
	object:SetBackdrop(M["Backdrop"]["PixelBorder"])
	object:SetBackdropBorderColor(unpack(C["border"]))
	object:CreateUIShadow()
	
	return object
end)

gPanel:RegisterUITemplate("border", function(object, arg, top, left, bottom, right)
	local border = object.__UIBackdrop or CreateFrame("Frame", nil, object)
	border:SetPoint("TOPLEFT", arg or object, "TOPLEFT", -3 + (left or 0), 3 - (top or 0))
	border:SetPoint("BOTTOMRIGHT", arg or object, "BOTTOMRIGHT", 3 - (right or 0), -3 + (bottom or 0))
	border:SetFrameLevel(max(0, object:GetFrameLevel() - 1))
	border:SetBackdrop(M["Backdrop"]["PixelBorder"])
	border:SetBackdropBorderColor(unpack(C["border"]))
	border:CreateUIShadow()
	
	object.__UIBackdrop = border
	
	return border
end)

-- this will create a separate frame, 1 level lower than the target, 
-- with the 3px border positioned OUTSIDE the target.
-- top, left, bottom, right are insets from the edge towards the center
gPanel:RegisterUITemplate("backdrop", function(object, arg, top, left, bottom, right)
	local border = object.__UIBackdrop or CreateFrame("Frame", nil, object)
	border:SetPoint("TOPLEFT", arg or object, "TOPLEFT", -3 + (left or 0), 3 - (top or 0))
	border:SetPoint("BOTTOMRIGHT", arg or object, "BOTTOMRIGHT", 3 - (right or 0), -3 + (bottom or 0))
	border:SetFrameLevel(max(0, object:GetFrameLevel() - 1))
	border:SetBackdrop(M["Backdrop"]["PixelBorder-Satin"])
	border:SetBackdropColor(C["overlay"][1], C["overlay"][2], C["overlay"][3], panelAlpha)
	border:SetBackdropBorderColor(unpack(C["border"]))
	border:CreateUIShadow()
	
	object.__UIBackdrop = border
	
	return border
end)

gPanel:RegisterUITemplate("blackbackdrop", function(object, arg, top, left, bottom, right)
	local border = object.__UIBackdrop or CreateFrame("Frame", nil, object)
	border:SetPoint("TOPLEFT", arg or object, "TOPLEFT", -3 + (left or 0), 3 - (top or 0))
	border:SetPoint("BOTTOMRIGHT", arg or object, "BOTTOMRIGHT", 3 - (right or 0), -3 + (bottom or 0))
	border:SetFrameLevel(max(0, object:GetFrameLevel() - 1))
	border:SetBackdrop(M["Backdrop"]["PixelBorder-Satin"])
	border:SetBackdropColor(C["background"][1], C["background"][2], C["background"][3], panelAlpha)
	border:SetBackdropBorderColor(unpack(C["border"]))
	border:CreateUIShadow()
	
	object.__UIBackdrop = border
	
	return border
end)

-- the 'simple' versions create a backdrop directly on the frame,
-- and the 3px border is positioned inside the object
gPanel:RegisterUITemplate("simplebackdrop", function(object, arg)
	object:SetBackdrop(M["Backdrop"]["PixelBorder-Satin"])
	object:SetBackdropColor(C["overlay"][1], C["overlay"][2], C["overlay"][3], panelAlpha)
	object:SetBackdropBorderColor(unpack(C["border"]))
	object:CreateUIShadow()
	
	return object
end)

gPanel:RegisterUITemplate("simpleblackbackdrop", function(object, arg)
	object:SetBackdrop(M["Backdrop"]["PixelBorder-Satin"])
	object:SetBackdropColor(C["background"][1], C["background"][2], C["background"][3], panelAlpha)
	object:SetBackdropBorderColor(unpack(C["border"]))
	object:CreateUIShadow()
	
	return object
end)

gPanel:RegisterUITemplate("simplestatusbarbackdrop", function(object, arg)
	object:SetBackdrop(M["Backdrop"]["StatusBarBorder"])
	object:SetBackdropColor(unpack(C["overlay"]))
	object:SetBackdropBorderColor(unpack(C["border"]))
	object:CreateUIShadow()
	
	return object
end)

gPanel:RegisterUITemplate("thinborder", function(object, arg)
	object:SetBackdrop(M["Backdrop"]["ThinBorder"])
	object:SetBackdropColor(unpack(C["background"]))
	object:CreateUIShadow()
	
	return object
end)

gPanel:RegisterUITemplate("itembutton", function(object, arg)
	object:SetBackdrop(M["Backdrop"]["ItemButton"])
	object:SetBackdropColor(C["backdrop"][1], C["backdrop"][2], C["backdrop"][3], 1)
	object:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3], 1)
	object:CreateUIShadow()
	
	-- add or adjust shade layer
	if (object.Shade) then
		object.Shade:SetDrawLayer("OVERLAY", 1)
		object.Shade:ClearAllPoints()
		object.Shade:SetPoint("TOPLEFT", object, "TOPLEFT", 3, -3)
		object.Shade:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -3, 3)
		
	else 
		object.Shade = object:CreateTexture()
		object.Shade:SetDrawLayer("OVERLAY", 1)
		object.Shade:SetTexture(M["Button"]["Shade"])
		object.Shade:SetVertexColor(0, 0, 0)
		object.Shade:SetAlpha(1/2)
		object.Shade:ClearAllPoints()
		object.Shade:SetPoint("TOPLEFT", object, "TOPLEFT", 3, -3)
		object.Shade:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -3, 3)
		
		if (object:GetName()) then
			_G[object:GetName() .. "Shade"] = object.Shade
		end
	end
	
	-- add or adjust gloss layer
	if (object.Gloss) then
		object.Gloss:SetDrawLayer("OVERLAY", 2)
		object.Gloss:ClearAllPoints()
		object.Gloss:SetPoint("TOPLEFT", object, "TOPLEFT", 3, -3)
		object.Gloss:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -3, 3)
		
	else 
		object.Gloss = object:CreateTexture()
		object.Gloss:SetDrawLayer("OVERLAY", 2)
		object.Gloss:SetTexture(M["Button"]["Gloss"])
		object.Gloss:SetVertexColor(1, 1, 1)
		object.Gloss:SetAlpha(1/2)
		object.Gloss:ClearAllPoints()
		object.Gloss:SetPoint("TOPLEFT", object, "TOPLEFT", 3, -3)
		object.Gloss:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -3, 3)
		
		if (object:GetName()) then
			_G[object:GetName() .. "Gloss"] = object.Gloss
		end
	end
	
	return object
end)

gPanel:RegisterUITemplate("blank", function(object, arg)
	object:SetBackdrop(M["Backdrop"]["PixelBorder-Blank"])
	object:SetBackdropColor(C["background"][1], C["background"][2], C["background"][3], 1)
	object:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3], 1)
--	object:CreateUIShadow()
	
	return object
end)

gPanel:RegisterUITemplate("targetborder", function(object, arg, top, left, bottom, right)
	local border = object.__UITargetBackdrop or CreateFrame("Frame", nil, object)
	border:SetPoint("TOPLEFT", arg or object, "TOPLEFT", (left or 0), (top or 0))
	border:SetPoint("BOTTOMRIGHT", arg or object, "BOTTOMRIGHT", (right or 0), (bottom or 0))
	border:SetBackdrop(M["Backdrop"]["TargetBorder"])
	border:SetBackdropBorderColor(unpack(C["target"]))
	border:SetFrameLevel(max(0, object:GetFrameLevel() - 1))
	
	object.__UITargetBackdrop = border

	return border
end)

gPanel:RegisterUITemplate("highlightborder", function(object)
	object:SetBackdrop(M["Backdrop"]["HighlightBorder"])
	object:SetBackdropColor(1, 1, 1, 1/3)
	object:SetBackdropBorderColor(unpack(C["target"]))
	object:SetFrameLevel(max(0, object:GetFrameLevel() - 1))

	return object
end)


-- same as 'simplebackdrop', but the border has a 2px visual indent from the frame edges,
-- thus creating the illusion of space between objects where there is none
-- this applies to all 'indented' versions
gPanel:RegisterUITemplate("simplebackdrop-indented", function(object)
	object:SetBackdrop(M["Backdrop"]["PixelBorderIndented-Satin"])
	object:SetBackdropColor(C["overlay"][1], C["overlay"][2], C["overlay"][3], panelAlpha)
	object:SetBackdropBorderColor(unpack(C["border"]))
	object:CreateUIShadow()
	object:GetUIShadowFrame():SetPoint("TOPLEFT", object, "TOPLEFT", 2, -2)
	object:GetUIShadowFrame():SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -2, 2)
	
	return object
end)

gPanel:RegisterUITemplate("itembackdrop", function(object, arg, top, left, bottom, right)
	local border = object.__UIBackdrop or CreateFrame("Frame", nil, object)
	border:SetPoint("TOPLEFT", arg or object, "TOPLEFT", -3 + (left or 0), 3 - (top or 0))
	border:SetPoint("BOTTOMRIGHT", arg or object, "BOTTOMRIGHT", 3 - (right or 0), -3 + (bottom or 0))
	border:SetBackdrop(M["Backdrop"]["ItemButton"])
	border:SetBackdropColor(C["backdrop"][1], C["backdrop"][2], C["backdrop"][3], 1)
	border:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3], 1)
	border:SetFrameLevel(max(0, object:GetFrameLevel() - 1))
	border:CreateUIShadow()
	
	object.__UIBackdrop = border
	
	return border
end)

------------------------------------------------------------------------------------------------------------
-- 	Skinning Templates
------------------------------------------------------------------------------------------------------------

gPanel:RegisterUITemplate("button", function(object, strip, shine, shineAlpha, shineDuration, shineScale)
	if (strip) then 
		object:RemoveTextures() 
	end

	object:SetUITemplate("simplebackdrop")

	if not(object.candyLayer) then
		object.candyLayer = CreateFrame("Frame", nil, object)
		object.candyLayer:SetPoint("TOPLEFT", 3, -3)
		object.candyLayer:SetPoint("BOTTOMRIGHT", -3, 3)
		F.GlossAndShade(object.candyLayer)
	end
	
	local text = object.text or object:GetName() and _G[object:GetName() .. "Text"]
	if (text) and (text.SetFontObject) then
		text:SetFontObject(GUIS_SystemFontSmall)
		object:SetNormalFontObject(GUIS_SystemFontSmall)
		object:SetHighlightFontObject(GUIS_SystemFontSmallHighlight)
		object:SetDisabledFontObject(GUIS_SystemFontSmallDisabled)
	end
	
	if (object:GetName()) then
		local l = _G[object:GetName() .. "Left"]
		local m = _G[object:GetName() .. "Middle"]
		local r = _G[object:GetName() .. "Right"]
		
		
		if (l) then l:SetAlpha(0) end
		if (m) then m:SetAlpha(0) end
		if (r) then r:SetAlpha(0) end
	end

	if (object.SetNormalTexture) then object:SetNormalTexture("") end
	if (object.SetHighlightTexture) then object:SetHighlightTexture("") end
	if (object.SetPushedTexture) then object:SetPushedTexture("") end
	if (object.SetDisabledTexture) then object:SetDisabledTexture("") end
	
	SetHoverScripts(object)
	
	if (shine) then
		SetShineScripts(object, shineAlpha, shineDuration, shineScale)
	end
	
	return object
end)

gPanel:RegisterUITemplate("button-indented", function(object, strip, shine, shineAlpha, shineDuration, shineScale)
	if (strip) then 
		object:RemoveTextures() 
	end

	object:SetUITemplate("simplebackdrop-indented")

	object.candyLayer = CreateFrame("Frame", nil, object)
	object.candyLayer:SetPoint("TOPLEFT", 5, -5)
	object.candyLayer:SetPoint("BOTTOMRIGHT", -5, 5)
	F.GlossAndShade(object.candyLayer)
	
	local text = object.text or object:GetName() and _G[object:GetName() .. "Text"]
	if (text) and (text.SetFontObject) then
		text:SetFontObject(GUIS_SystemFontSmall)
		object:SetNormalFontObject(GUIS_SystemFontSmall)
		object:SetHighlightFontObject(GUIS_SystemFontSmallHighlight)
		object:SetDisabledFontObject(GUIS_SystemFontSmallDisabled)
	end

	if (object:GetName()) then
		local l = _G[object:GetName() .. "Left"]
		local m = _G[object:GetName() .. "Middle"]
		local r = _G[object:GetName() .. "Right"]
		
		
		if (l) then l:SetAlpha(0) end
		if (m) then m:SetAlpha(0) end
		if (r) then r:SetAlpha(0) end
	end

	if (object.SetNormalTexture) then object:SetNormalTexture("") end
	if (object.SetHighlightTexture) then object:SetHighlightTexture("") end
	if (object.SetPushedTexture) then object:SetPushedTexture("") end
	if (object.SetDisabledTexture) then object:SetDisabledTexture("") end
	
	SetHoverScripts(object)

	if (shine) then
		SetShineScripts(object, shineAlpha, shineDuration, shineScale)
	end
	
	return object
end)

gPanel:RegisterUITemplate("tab", function(object, strip, shine, shineAlpha, shineDuration, shineScale)
	if (strip) then 
		object:RemoveTextures() 
	end

	local backdrop = object:SetUITemplate("backdrop", nil, 5, 12, 5, 12)

	if not(object.candyLayer) then
		object.candyLayer = CreateFrame("Frame", nil, backdrop)
		object.candyLayer:SetPoint("TOPLEFT", 3, -3)
		object.candyLayer:SetPoint("BOTTOMRIGHT", -3, 3)
		F.GlossAndShade(object.candyLayer)
	end
	
	local text = object.text or object:GetName() and _G[object:GetName() .. "Text"]
	if (text) and (text.SetFontObject) then
		text:SetFontObject(GUIS_SystemFontSmall)
		object:SetNormalFontObject(GUIS_SystemFontSmall)
		object:SetHighlightFontObject(GUIS_SystemFontSmallHighlight)
		object:SetDisabledFontObject(GUIS_SystemFontSmallDisabled)
		
		-- not strictly happy with this, but it avoids taint, if nothing else
		--[[
		hooksecurefunc("PanelTemplates_SelectTab", function(tab) 
			if (tab == object) then
				tab:SetDisabledFontObject(GUIS_SystemFontSmallHighlight)
			end
		end)
		
		hooksecurefunc("PanelTemplates_SetDisabledTabState", function(tab) 
			if (tab == object) then
				tab:SetDisabledFontObject(GUIS_SystemFontSmallDisabled)
			end
		end)
		]]--
	end

	if (object:GetName()) then
		local l = _G[object:GetName() .. "Left"]
		local m = _G[object:GetName() .. "Middle"]
		local r = _G[object:GetName() .. "Right"]
		local ld = _G[object:GetName() .. "LeftDisabled"]
		local md = _G[object:GetName() .. "MiddleDisabled"]
		local rd = _G[object:GetName() .. "RightDisabled"]
		
		if (l) then l:SetAlpha(0) end
		if (m) then m:SetAlpha(0) end
		if (r) then r:SetAlpha(0) end
		if (ld) then ld:SetAlpha(0) end
		if (md) then md:SetAlpha(0) end
		if (rd) then rd:SetAlpha(0) end
	end

	if (object.SetNormalTexture) then object:SetNormalTexture("") end
	if (object.SetHighlightTexture) then object:SetHighlightTexture("") end
	if (object.SetPushedTexture) then object:SetPushedTexture("") end
	if (object.SetDisabledTexture) then object:SetDisabledTexture("") end
	
	SetHoverScripts(object)

	if (shine) then
		SetShineScripts(object, shineAlpha, shineDuration, shineScale)
	end
	
	return object
end)

gPanel:RegisterUITemplate("scrollbar", function(object, strip)
	object:RemoveTextures()
	object:RemoveClutter()
	
	local name = object:GetName()
	if (name) then
		if (_G[name .. "ScrollDownButton"]) then
			_G[name .. "ScrollDownButton"]:SetUITemplate("arrow", "down")
			_G[name .. "ScrollDownButton"]:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			_G[name .. "ScrollDownButton"]:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
			_G[name .. "ScrollDownButton"]:GetDisabledTexture():SetTexCoord(0, 1, 0, 1)
			_G[name .. "ScrollDownButton"]:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
		end

		if (_G[name .. "ScrollUpButton"]) then
			_G[name .. "ScrollUpButton"]:SetUITemplate("arrow", "up")
			_G[name .. "ScrollUpButton"]:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			_G[name .. "ScrollUpButton"]:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
			_G[name .. "ScrollUpButton"]:GetDisabledTexture():SetTexCoord(0, 1, 0, 1)
			_G[name .. "ScrollUpButton"]:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
		end
		
		if (_G[name .. "ThumbTexture"]) then
			_G[name .. "ThumbTexture"]:SetTexture(C["disabled"][1], C["disabled"][2], C["disabled"][3], 1)
			_G[name .. "ThumbTexture"]:SetWidth(_G[name .. "ThumbTexture"]:GetWidth() - 8)
			_G[name .. "ThumbTexture"]:SetHeight(_G[name .. "ThumbTexture"]:GetHeight() - 8)
			
			object:CreateUIShadow()
			object:GetUIShadowFrame():SetPoint("TOPLEFT", _G[name .. "ThumbTexture"], "TOPLEFT", -3, 3)
			object:GetUIShadowFrame():SetPoint("BOTTOMRIGHT", _G[name .. "ThumbTexture"], "BOTTOMRIGHT", 3, -3)
		end
	end
	
	for i = 1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		
		if (region:GetName()) and ((region:GetName():find("Up")) or (region:GetName():find("Down"))) then
			region:SetUITemplate("arrow")
			
			region:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			region:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
			region:GetDisabledTexture():SetTexCoord(0, 1, 0, 1)
			region:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
		end
	end
	
	for v = 1, object:GetNumChildren() do
		local child = select(v, object:GetChildren())
		
		for i = 1, child:GetNumRegions() do
			local region = select(i, child:GetRegions())
			
			if (region:GetName()) and ((region:GetName():find("Up")) or (region:GetName():find("Down"))) then
				region:SetUITemplate("arrow")

				region:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
				region:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
				region:GetDisabledTexture():SetTexCoord(0, 1, 0, 1)
				region:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
			end
		end
	end
	
	return object
end)

gPanel:RegisterUITemplate("slider", function(object, orientation)
--	object:SetBackdrop(nil)
	object:SetUITemplate("simplebackdrop-indented")

	object.SetBackdrop = noop
	
	return object

--[[	
	-- needed for tons of situations
	object:SetFrameLevel(object:GetFrameLevel() + 5)

	local backdrop = object:SetUITemplate("backdrop")
	backdrop.frame = object
	
	backdrop.SetOrientation = function(object, orientation)
		if (orientation ~= "VERTICAL") and (orientation ~= "HORIZONTAL") then
			orientation = object.frame:GetOrientation()
		end
	
		if (orientation == "VERTICAL") then
			backdrop:ClearAllPoints()
			backdrop:SetPoint("TOPLEFT", object.frame, "TOPLEFT", 3, -8)
			backdrop:SetPoint("BOTTOMRIGHT", object.frame, "BOTTOMRIGHT", -3, 8)
		else
			backdrop:ClearAllPoints()
			backdrop:SetPoint("TOPLEFT", object.frame, "TOPLEFT", 8, -3)
			backdrop:SetPoint("BOTTOMRIGHT", object.frame, "BOTTOMRIGHT", -8, 3)
		end
	end
	
	-- hook the slider's SetOrientation function
	hooksecurefunc(object, "SetOrientation", function(object, orientation) backdrop:SetOrientation(orientation) end)
	
	-- initial positioning
	backdrop:SetOrientation(orientation)
	
	return backdrop
	]]--
end)

gPanel:RegisterUITemplate("closebutton", function(object, ...)
	object:SetNormalTexture(M["Button"]["UICloseButton"])
	object:SetPushedTexture(M["Button"]["UICloseButtonDown"])
	object:SetHighlightTexture(M["Button"]["UICloseButtonHighlight"])
	object:SetDisabledTexture(M["Button"]["UICloseButtonDisabled"])

	object:SetSize(16, 16)

	if (...) then
		local a, b, c, d, e, f = ...
		
		if (a == true) then
			object.SetNormalTexture = noop
			object.SetPushedTexture = noop
			object.SetHighlightTexture = noop
			object.SetDisabledTexture = noop
			
			if (b) then
				object:ClearAllPoints()
				object:SetPoint(b, c, d, e, f)
			end
		else
			object:ClearAllPoints()
			object:SetPoint(a, b, c, d, e)
		end
	else
		local point, anchor, relpoint, x, y = object:GetPoint()
		if (point) then
			object:ClearAllPoints()
			object:SetPoint(point, anchor, relpoint, x-8, y-8)
		end
	end
	
	return object
end)

gPanel:RegisterUITemplate("radiobutton", function(object, strip)
	if (strip) then 
		object:RemoveTextures() 
	end

	object:SetUITemplate("simplebackdrop")
	
	local name = object:GetName()
	local text = object.text or name and _G[name .. "Text"]
	if (text) and (text.SetFontObject) then
		text:SetFontObject(GUIS_SystemFontSmallWhite)
		object:SetNormalFontObject(GUIS_SystemFontSmallWhite)
		object:SetHighlightFontObject(GUIS_SystemFontSmallHighlight)
		object:SetDisabledFontObject(GUIS_SystemFontSmallDisabled)
	end

	if (object.SetCheckedTexture) then
		object:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		
		object:GetCheckedTexture():SetDrawLayer("OVERLAY")
		object:GetCheckedTexture():SetTexCoord(0, 1, 0, 1)
		object:GetCheckedTexture().SetTexCoord = noop
	end
	
	if (object.SetDisabledTexture) then
		object:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")

		object:GetDisabledTexture():SetDrawLayer("OVERLAY")
		object:GetDisabledTexture():SetTexCoord(0, 1, 0, 1)
		object:GetDisabledTexture().SetTexCoord = noop
	end
	
	if (object.SetHighlightTexture) then
		local highlight = object:CreateTexture(nil, "OVERLAY")
		highlight:ClearAllPoints()
		highlight:SetPoint("TOPLEFT", object, "TOPLEFT", 2, -2)
		highlight:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -2, 2)
		highlight:SetTexture(C["index"][1], C["index"][2], C["index"][3], 1/4)

		object:SetHighlightTexture(highlight)

		if (name) then
			_G[name .. "Highlight"] = highlight
		end
	end
	
	object.SetDisabledTexture = noop	
	object.SetNormalTexture = noop
	object.SetPushedTexture = noop
	object.SetHighlightTexture = noop
	
	return object
end)

-- jumping through hoops to make this nonsense compatible with ScrollFrames
gPanel:RegisterUITemplate("dropdown", function(object, strip, width)
	if (strip) then
		if (strip == true) then
			object:RemoveTextures()
		end
		
		if (tonumber(strip)) and (tonumber(strip) > 0) then
			width = strip
		end
	end
	
	local button = _G[object:GetName() .. "Button"]
	local text = _G[object:GetName() .. "Text"]

	if (width) then
		object:SetWidth(width)
	end
	
	button:SetUITemplate("arrow", "down")
	button:SetUITemplate("simplebackdrop")
	
	text:ClearAllPoints()
	text:SetPoint("RIGHT", button:GetNormalTexture(), "LEFT", 0, 0)
	text:SetPoint("LEFT", button, "LEFT", 8, 0)
	text:SetPoint("BOTTOM", button, "BOTTOM", 0, 5)
	text:SetJustifyV("BOTTOM")
	text.ClearAllPoints = noop
	text.SetPoint = noop
	
	text:SetParent(button)
	text:SetDrawLayer("OVERLAY")
	text:SetFontObject(GUIS_SystemFontSmallWhite)
	
	button:ClearAllPoints()
	button:SetPoint("RIGHT", object, "RIGHT", -12, 0)
	button:SetPoint("LEFT", object, "LEFT", 12, 0)
	button:SetPoint("TOP", object, "TOP", 0, -2)
	button:SetPoint("BOTTOM", object, "BOTTOM", 0, 7)
	button.ClearAllPoints = noop
	button.SetPoint = noop
	
	return button
end)

gPanel:RegisterUITemplate("checkbutton", function(object, ...)
	object:RemoveTextures()
	object:SetUITemplate("simplebackdrop-indented")
	
	local text = object.text or object:GetName() and _G[object:GetName() .. "Text"]
	if (text) and (text.SetFontObject) then
		text:SetFontObject(GUIS_SystemFontSmallWhite)
		object:SetNormalFontObject(GUIS_SystemFontSmallWhite)
		object:SetHighlightFontObject(GUIS_SystemFontSmallHighlight)
		object:SetDisabledFontObject(GUIS_SystemFontSmallDisabled)
	end

	if (object.SetCheckedTexture) then
		object:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		object:GetCheckedTexture():SetTexCoord(0, 1, 0, 1)
		object:GetCheckedTexture().SetTexCoord = noop
		object:GetCheckedTexture():SetPoint("TOPLEFT", -3, 3)
		object:GetCheckedTexture():SetPoint("BOTTOMRIGHT", 3, -3)
		object:GetCheckedTexture():SetParent(object)
		object:GetCheckedTexture():SetDrawLayer("OVERLAY", 7)
	end
	
	if (object.SetDisabledTexture) then
		object:SetDisabledTexture("")
		object:GetDisabledTexture():SetTexCoord(0, 1, 0, 1)
		object:GetDisabledTexture().SetTexCoord = noop
	end

	if (object.SetDisabledCheckedTexture) then
		object:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
		object:GetDisabledCheckedTexture():SetTexCoord(0, 1, 0, 1)
		object:GetDisabledCheckedTexture().SetTexCoord = noop
	end
	
	if (object.SetHighlightTexture) then
		local highlight = object:CreateTexture()
		highlight:SetDrawLayer("OVERLAY")
		highlight:ClearAllPoints()
		highlight:SetPoint("TOPLEFT", object, "TOPLEFT", 5, -5)
		highlight:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -5, 5)
		highlight:SetTexture(C["index"][1], C["index"][2], C["index"][3], 1/4)

		object:SetHighlightTexture(highlight)

		if (object:GetName()) then
			_G[object:GetName() .. "Highlight"] = highlight
		end
	end
	
	object.SetNormalTexture = noop
	object.SetPushedTexture = noop
	object.SetHighlightTexture = noop
	
	return object
end)

gPanel:RegisterUITemplate("editbox", function(object, top, left, bottom, right, textTop, textLeft, textBottom, textRight)
	RemoveClutter(object)
	
	object:SetFrameLevel(object:GetFrameLevel() + 1)

	local backdrop = object:SetUITemplate("backdrop")
	backdrop:ClearAllPoints()
	backdrop:SetPoint("TOPLEFT", object, "TOPLEFT", -3 + (left or 0), 2 + (top or 0))
	backdrop:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 3+ (right or 0), -2 + (bottom or 0))

	if (object.SetFontObject) then
		object:SetFontObject(GUIS_ChatFontNormal)
	end

	local name = object:GetName()
	if (name) then
		if ((name:find("Silver")) or (name:find("Copper"))) then
			backdrop:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -12, -2 + (bottom or 0))
		end
		
		local header = _G[name.."Header"]
		if (header) then
			header:SetFontObject(GUIS_ChatFontNormal)
		end
	end
	
	if (textTop) or (textLeft) or (textBottom) or (textRight) then
		object:SetTextInsets(textLeft or 0, textRight or 0, textTop or 0, textBottom or 0)
	end
	
	return backdrop
end)

gPanel:RegisterUITemplate("statusbar", function(object, border)
	RemoveTextures(object)
	
	if (border) then
		local backdrop = object:SetUITemplate("border")
	end

	object:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	F.GlossAndShade(object)
	
	local name = object:GetName()

	local text = object.text or name and _G[name .. "Text"]
	if (text) and (text.SetFontObject) then
		text:SetFontObject(GUIS_NumberFontNormal)
	end

	local title = object.title or name and _G[name .. "Title"]
	if (title) and (title.SetFontObject) then
		title:SetFontObject(GUIS_SystemFontNormal)
	end

	local label = object.label or name and _G[name .. "Label"]
	if (label) and (label.SetFontObject) then
		label:SetFontObject(GUIS_SystemFontSmall)
	end
	
	return object
end)

-- possibly the biggest overkill ever, just to save me time later
-- lazy is the new art, at least when I do it
gPanel:RegisterUITemplate("arrow", function(object, direction, ...)
	local Direction

	if not(direction) then
		local name = (object.GetName) and (object:GetName())
		if (name:find("Collapse")) or (name:find("Toggle")) then
			if not(object.BlizzSetNormalTexture) then
				object.BlizzSetNormalTexture = object.SetNormalTexture
				object.BlizzSetPushedTexture = object.SetPushedTexture
				object.BlizzSetHighlightTexture = object.SetHighlightTexture
				object.BlizzSetDisabledTexture = object.SetDisabledTexture
			end
			
			object.SetNormalTexture = function(object, normal)
				if not(normal) or not(normal.find) then
					return
				end
				
				if (normal and normal:find("Plus")) then
					object:BlizzSetNormalTexture(M["Icon"]["ArrowDown"])
					object:BlizzSetPushedTexture(nil)
					object:BlizzSetHighlightTexture(M["Icon"]["ArrowDownHighlight"])
					object:BlizzSetDisabledTexture(M["Icon"]["ArrowDownDisabled"])
											
				elseif (normal and normal:find("Minus")) then
					object:BlizzSetNormalTexture(M["Icon"]["ArrowUp"])
					object:BlizzSetPushedTexture(nil)
					object:BlizzSetHighlightTexture(M["Icon"]["ArrowUpHighlight"])
					object:BlizzSetDisabledTexture(M["Icon"]["ArrowUpDisabled"])
				end
			end
			
			local normal = object:GetNormalTexture():GetTexture()
			
			object.SetPushedTexture = noop
			object.SetHighlightTexture = noop
			object.SetDisabledTexture = noop
			object:SetNormalTexture(normal)
			
			Direction = (normal and normal:find("Plus")) and "Down" or "Up"
			
		elseif (name:find("Expand")) then
			if not(object.BlizzSetNormalTexture) then
				object.BlizzSetNormalTexture = object.SetNormalTexture
				object.BlizzSetPushedTexture = object.SetPushedTexture
				object.BlizzSetHighlightTexture = object.SetHighlightTexture
				object.BlizzSetDisabledTexture = object.SetDisabledTexture
			end

			object.SetNormalTexture = function(object, normal) 
				if not(normal) or not(normal.find) then
					return
				end
				
				if (normal and normal:find("Prev")) then
					object:BlizzSetNormalTexture(M["Icon"]["ArrowLeft"])
					object:BlizzSetPushedTexture(M["Icon"]["ArrowLeft"])
					object:BlizzSetHighlightTexture(M["Icon"]["ArrowLeftHighlight"])
					object:BlizzSetDisabledTexture(M["Icon"]["ArrowLeftDisabled"])
											
				elseif (normal and normal:find("Next")) then
					object:BlizzSetNormalTexture(M["Icon"]["ArrowRight"])
					object:BlizzSetPushedTexture(M["Icon"]["ArrowRight"])
					object:BlizzSetHighlightTexture(M["Icon"]["ArrowRightHighlight"])
					object:BlizzSetDisabledTexture(M["Icon"]["ArrowRightDisabled"])
				end
			end

			local normal = object:GetNormalTexture():GetTexture()
			
			object.SetPushedTexture = noop
			object.SetHighlightTexture = noop
			object.SetDisabledTexture = noop
			object:SetNormalTexture(normal)
			
			Direction = (normal and normal:find("Prev")) and "Left" or "Right"
		
		elseif (name:find("Prev")) or (name:find("Left")) or (name:find("Dec")) then
			Direction = "Left"
		
		elseif (name:find("Next")) or (name:find("Right")) or (name:find("Inc")) then
			Direction = "Right"
		
		elseif (name:find("Up")) then
			Direction = "Up"
		
		elseif (name:find("Down")) then
			Direction = "Down"

		elseif (name:find("Top")) then
			Direction = "Top"

		elseif (name:find("Bottom")) then
			Direction = "Bottom"

		elseif (name:find("First")) then
			Direction = "First"

		elseif (name:find("Last")) then
			Direction = "Last"
		end
	else
		if (direction == "left") then
			Direction = "Left"
			
		elseif (direction == "right") then
			Direction = "Right"
			
		elseif (direction == "up") then
			Direction = "Up"
			
		elseif (direction == "down") then
			Direction = "Down"
			
		elseif (direction == "top") then
			Direction = "Top"

		elseif (direction == "bottom") then
			Direction = "Bottom"
			
		elseif (direction == "first") then
			Direction = "First"
			
		elseif (direction == "collapse") then
			if not(object.BlizzSetNormalTexture) then
				object.BlizzSetNormalTexture = object.SetNormalTexture
				object.BlizzSetPushedTexture = object.SetPushedTexture
				object.BlizzSetHighlightTexture = object.SetHighlightTexture
				object.BlizzSetDisabledTexture = object.SetDisabledTexture
			end
			
			object.SetNormalTexture = function(object, normal)
				if not(normal) or not(normal.find) then
					return
				end
				
				if (normal and normal:find("Plus")) then
					object:BlizzSetNormalTexture(M["Icon"]["ArrowDown"])
					object:BlizzSetPushedTexture(nil)
					object:BlizzSetHighlightTexture(M["Icon"]["ArrowDownHighlight"])
					object:BlizzSetDisabledTexture(M["Icon"]["ArrowDownDisabled"])
											
				elseif (normal and normal:find("Minus")) then
					object:BlizzSetNormalTexture(M["Icon"]["ArrowUp"])
					object:BlizzSetPushedTexture(nil)
					object:BlizzSetHighlightTexture(M["Icon"]["ArrowUpHighlight"])
					object:BlizzSetDisabledTexture(M["Icon"]["ArrowUpDisabled"])
				end
			end
			
			local normal = object:GetNormalTexture():GetTexture()
			
			object.SetPushedTexture = noop
			object.SetHighlightTexture = noop
			object.SetDisabledTexture = noop
			object:SetNormalTexture(normal)
			
			Direction = (normal and normal:find("Plus")) and "Down" or "Up"
			
		elseif (direction == "expand") then
			if not(object.BlizzSetNormalTexture) then
				object.BlizzSetNormalTexture = object.SetNormalTexture
				object.BlizzSetPushedTexture = object.SetPushedTexture
				object.BlizzSetHighlightTexture = object.SetHighlightTexture
				object.BlizzSetDisabledTexture = object.SetDisabledTexture
			end

			object.SetNormalTexture = function(object, normal) 
				if not(normal) or not(normal.find) then
					return
				end
				
				if (normal and normal:find("Prev")) then
					object:BlizzSetNormalTexture(M["Icon"]["ArrowLeft"])
					object:BlizzSetPushedTexture(M["Icon"]["ArrowLeft"])
					object:BlizzSetHighlightTexture(M["Icon"]["ArrowLeftHighlight"])
					object:BlizzSetDisabledTexture(M["Icon"]["ArrowLeftDisabled"])
											
				elseif (normal and normal:find("Next")) then
					object:BlizzSetNormalTexture(M["Icon"]["ArrowRight"])
					object:BlizzSetPushedTexture(M["Icon"]["ArrowRight"])
					object:BlizzSetHighlightTexture(M["Icon"]["ArrowRightHighlight"])
					object:BlizzSetDisabledTexture(M["Icon"]["ArrowRightDisabled"])
				end
			end

			local normal = object:GetNormalTexture():GetTexture()
			
			object.SetPushedTexture = noop
			object.SetHighlightTexture = noop
			object.SetDisabledTexture = noop
			object:SetNormalTexture(normal)
			
			Direction = (normal and normal:find("Prev")) and "Left" or "Right"
		
		elseif (direction == "last") then
			Direction = "Last"
		end
	end

	if not(Direction) then
		return
	end
	
	RemoveTextures(object)

	object:SetNormalTexture(M["Icon"]["Arrow" .. Direction])
	object:SetPushedTexture(M["Icon"]["Arrow" .. Direction])
	object:SetHighlightTexture(M["Icon"]["Arrow" .. Direction .. "Highlight"])
	object:SetDisabledTexture(M["Icon"]["Arrow" .. Direction .. "Disabled"])
	
	if (...) then
		object:ClearAllPoints()
		object:SetPoint(...)
	end
	
	return object
end)

-- set the gPanel textures and colors to what gUI uses
gPanel:SetColor("background", C["background"])
gPanel:SetColor("border", C["border"])
gPanel:SetColor("index", C["index"])
gPanel:SetColor("overlay", C["overlay"])
gPanel:SetColor("shadow", C["shadow"])
gPanel:SetColor("value", C["value"])
gPanel:SetFontObject(GUIS_PanelFont)

-- add shade and gloss layers to an object
F.GlossAndShade = function(self, target)
	self.Shade = self.Shade or self:CreateTexture()
	self.Shade:SetDrawLayer("OVERLAY", 1)
	self.Shade:SetTexture(M["Button"]["Shade"])
	self.Shade:SetVertexColor(0, 0, 0, 1/4)
	self.Shade:SetAllPoints(target or self)

	self.Gloss = self.Gloss or self:CreateTexture()
	self.Gloss:SetDrawLayer("OVERLAY", 2)
	self.Gloss:SetTexture(M["Button"]["Gloss"])
	self.Gloss:SetVertexColor(1, 1, 1, 1/4)
	self.Gloss:SetAllPoints(target or self)	
end

-- replace :Show() and :Hide() with smart functions that fade in and out
-- the following taint ToggleGameMenu(), 
-- and prevents 'Esc' from stopping casts, clearing targets, etc
local fadeBlacklist = {
	["OpacityFrame"] = true;
	["SpellFlyout"] = true;
}

local fadeIsShownBlacklist = {
	["AudioOptionsFrame"] = true;
	["GameMenuFrame"] = true;
	["HelpFrame"] = true;
	["InterfaceOptionsFrame"] = true;
	["MultiCastFlyoutFrame"] = true;
	["TimeManagerFrame"] = true;
	["VideoOptionsFrame"] = true;
}
F.CreateFadeHooks = function(self, fadeInTime, fadeOutTime, finishedFunc)
	-- completely abort, the frame is using :Hide() in ToggleGameMenu()
	if ((self:GetName()) and fadeBlacklist[self:GetName()]) then
		return
	end

	-- abort this if frame:IsShown() is used in ToggleGameMenu() to avoid taint
	if not((self:GetName()) and fadeIsShownBlacklist[self:GetName()]) then
		-- we need to replace this to be able to 
		--	fade a frame back in before it is completely faded out
		self.IsShown = function(self)
			if (self.running) then
				if (self.runType == "IN") then
					return true
				end
				
				if (self.runType == "OUT") then
					return false
				end
			end
			
			return UIParent.IsShown(self)
		end
	end
	
	fadeInTime = fadeInTime or 1/3
	fadeOutTime = fadeOutTime or fadeInTime
	finishedFunc = finishedFunc or noop
	
	self.Show = function(self) 
		if (self.running) then
			if (self.runType == "IN") then
				UIParent.Show(self)
				return
			end
			
			if (self.runType == "OUT") then
				if (self.fadeInfo) and (self.fadeInfo.startAlpha == self:GetAlpha()) then
					return
				end
			end
		end
		
		local wasFading
		if UIFrameIsFading(self) then 
			wasFading = self:GetAlpha()
			UIFrameFadeRemoveFrame(self)
		end

		self.running = true
		self.runType = "IN"
		
		local fadeInfo = {
			mode = "IN";
			timeToFade = fadeInTime;
			startAlpha = wasFading or 0;
			endAlpha = 1;
			finishedFunc = function() 
				finishedFunc(self)
				self.running = nil 
				self.runType = nil
			end;
		}
		UIFrameFade(self, fadeInfo) 
	end

	self.Hide = function(self) 
		if (self.running) then
			if (self.runType == "OUT") then
				return
			end
		end

		if UIFrameIsFading(self) then 
			UIFrameFadeRemoveFrame(self)
		end

		self.running = true
		self.runType = "OUT"

		local fadeInfo = {
			mode = "OUT";
			timeToFade = fadeOutTime;
			startAlpha = self:GetAlpha();
			endAlpha = 0;
			finishedFunc = function() 
				UIParent.Hide(self)
				finishedFunc(self)
				self.running = nil
				self.runType = nil
			end;
		}
		UIFrameFade(self, fadeInfo) 
	end
end

-- make text red. very advanced function. oh yeah.
F.warning = function(msg)
	return "|cFFFF0000" .. msg .. "|r"
end

--------------------------------------------------------------------------------------------------
--		Shine
--------------------------------------------------------------------------------------------------
--
-- Shine effect
-- usage:
-- 	local shineFrame = F.Shine:New(target, maxAlpha, duration, scale)
-- 	shineFrame:Start()
--		shineFrame:Hide()
do
	local MAXALPHA = 1
	local SCALE = 5 -- too huge for this?
	local DURATION = 0.75
	local TEXTURE = [[Interface\Cooldown\star4]]

	local New = function(frameType, parentClass)
		local class = CreateFrame(frameType)
		class.mt = { __index = class }

		if (parentClass) then
			class = setmetatable(class, { __index = parentClass })
			
			class.super = function(self, method, ...)
				parentClass[method](self, ...)
			end
		end

		class.Bind = function(self, obj)
			return setmetatable(obj, self.mt)
		end

		return class
	end

	local Shine = New("Frame")

	Shine.New = function(self, parent, maxAlpha, duration, scale)
		local f = self:Bind(CreateFrame("Frame", nil, parent)) 
		f:Hide()
		f:SetScript("OnHide", f.OnHide)
		f:SetAllPoints(parent)
		f:SetToplevel(true)

		f.animation = f:CreateShineAnimation(maxAlpha, duration, scale)

		local icon = f:CreateTexture(nil, "OVERLAY")
		icon:SetPoint("CENTER")
		icon:SetBlendMode("ADD")
		icon:SetAllPoints(f)
		icon:SetTexture(TEXTURE)

		return f
	end

	local animation_OnFinished = function(self)
		local parent = self:GetParent()
		if (parent:IsShown()) then
			parent:Hide()
		end
	end

	Shine.CreateShineAnimation = function(self, maxAlpha, duration, scale)
		local MAXALPHA = maxAlpha or MAXALPHA
		local SCALE = scale or SCALE
		local DURATION = duration or DURATION

		local g = self:CreateAnimationGroup()
		g:SetLooping("NONE")
		g:SetScript("OnFinished", animation_OnFinished)

		local startTrans = g:CreateAnimation("Alpha")
		startTrans:SetChange(-1) -- make it 0, no matter the maxAlpha
		startTrans:SetDuration(0)
		startTrans:SetOrder(0)

		local grow = g:CreateAnimation("Scale")
		grow:SetOrigin("CENTER", 0, 0)
		grow:SetScale(SCALE, SCALE)
		grow:SetDuration(DURATION/2)
		grow:SetOrder(1)

		local brighten = g:CreateAnimation("Alpha")
		brighten:SetChange(MAXALPHA)
		brighten:SetDuration(DURATION/2)
		brighten:SetOrder(1)

		local shrink = g:CreateAnimation("Scale")
		shrink:SetOrigin("CENTER", 0, 0)
		shrink:SetScale(-SCALE, -SCALE)
		shrink:SetDuration(DURATION/2)
		shrink:SetOrder(2)

		local fade = g:CreateAnimation("Alpha")
		fade:SetChange(-MAXALPHA)
		fade:SetDuration(DURATION/2)
		fade:SetOrder(2)

		return g
	end

	Shine.OnHide = function(self)
		if (self.animation:IsPlaying()) then
			self.animation:Finish()
		end
		self:Hide()
	end

	Shine.Start = function(self)
		if (self.animation:IsPlaying()) then
			self.animation:Finish()
		end
		self:Show()
		self.animation:Play()
	end
	
	-- global access
	F.Shine = Shine
end

--------------------------------------------------------------------------------------------------
--		Action Buttons
--------------------------------------------------------------------------------------------------

F.ShortenHotKey = function(key)
	if (key) then
		local s = "-"
		
		key = gsub(strupper(key), " ", "")

		key = gsub(key, "MOUSEBUTTON", L["M"])
		key = gsub(key, "BUTTON", L["M"])
		key = gsub(key, "MIDDLEMOUSE", L["M3"])

		key = gsub(key, "ALT%-", L["A"] .. s)
		key = gsub(key, "CTRL%-", L["C"] .. s)
		key = gsub(key, "SHIFT%-", L["S"] .. s)
		key = gsub(key, "NUMPAD", L["N"])

		key = gsub(key, "PLUS", "%+")
		key = gsub(key, "MINUS", "%-")
		key = gsub(key, "MULTIPLY", "%*")
		key = gsub(key, "DIVIDE", "%/")

		key = gsub(key, "BACKSPACE", L["Bs"])

		key = gsub(key, "CAPSLOCK", L["CL"])
		key = gsub(key, "CLEAR", L["Clr"])
		key = gsub(key, "DELETE", L["Del"])
		key = gsub(key, "END", L["End"])
		key = gsub(key, "HOME", L["Home"])
		key = gsub(key, "INSERT", L["Ins"])
		key = gsub(key, "MOUSEWHEELDOWN", L["WD"])
		key = gsub(key, "MOUSEWHEELUP", L["WU"])
		key = gsub(key, "NUMLOCK", L["NL"])
		key = gsub(key, "PAGEDOWN", L["PD"])
		key = gsub(key, "PAGEUP", L["PU"])
		key = gsub(key, "SCROLLLOCK", L["SL"])
		key = gsub(key, "SPACEBAR", L["Spc"])
		key = gsub(key, "SPACE", L["Spc"])
		key = gsub(key, "TAB", L["Tab"])

		key = gsub(key, "DOWNARROW", L["Dn"])
		key = gsub(key, "LEFTARROW", L["Lt"])
		key = gsub(key, "RIGHTARROW", L["Rt"])
		key = gsub(key, "UPARROW", L["Up"])

		return key
	end
end

F.StyleHotKey = function(text, hotkey, button, actionButtonType)
	if (text == _G["RANGE_INDICATOR"]) then
		hotkey:SetText("")
	else
		hotkey:SetText(F.ShortenHotKey(text))
	end
end

local totemTex = {
	[EARTH_TOTEM_SLOT] = { 67/128, 94/128, 4/256, 31/256 }; -- earth
	[FIRE_TOTEM_SLOT] = { 68/128, 95/128, 101/256, 128/256 }; -- fire
	[WATER_TOTEM_SLOT] = { 40/128, 67/128, 210/256, 237/256 }; -- water
	[AIR_TOTEM_SLOT] = { 67/128, 94/128, 37/256, 64/256 }; -- air
}
F.StyleActionButton = function(self)
	if not(self) then
		return
	end

	local actionType, ID, subType
	if (self.action) then
		actionType, ID, subType = GetActionInfo(self.action)
	end

	local name = self:GetName()

	self.Button = self
	self.ActionType = actionType
	self.ItemID = actionType == "item" and ID
	self.ItemRarity = actionType == "item" and (select(3,GetItemInfo(ID)))
	self.Name = name

	self.Autocast = self.Autocast or _G[name.."AutoCastable"]
	self.Background = self.Background or _G[name].background
	self.Border = self.Border or _G[name.."Border"]
	self.Cooldown = self.Cooldown or _G[name.."Cooldown"]
	self.Count = self.Count or _G[name.."Count"]
	self.Flash = self.Flash or _G[name.."Flash"]
	self.FloatingBG = self.FloatingBG or _G[name.."FloatingBG"]
	self.Frame = self.Frame or _G[name.."Frame"]
	self.Gloss = self.Gloss or _G[name.."Gloss"]
	self.Highlight = self.Highlight or _G[name.."Highlight"]
	self.Hotkey = self.Hotkey or _G[name.."HotKey"]
	self.Hover = self.Hover or _G[name.."HoverTex"]
	self.Icon = self.Icon or _G[name.."Icon"] or _G[name.."IconTexture"]
	self.Macro = self.Macro or _G[name.."Name"]
	self.NormalTexture = self.NormalTexture or _G[name.."NormalTexture"] or _G[name.."NormalTexture2"]
	self.Overlay = self.Overlay or _G[name].overlay
	self.Panel = self.Panel or _G[name.."Panel"]
	self.Pushed = self.Pushed or _G[name.."PushedTex"]
	self.Search = self.Search or self.searchOverlay or _G[name .. "SearchOverlay"]
	self.Shade = self.Shade or _G[name.."Shade"]
	self.Shine = self.Shine or _G[name.."Shine"]
	
	-- totembuttons
	if (name:find("MultiCastAction")) or (name:find("MultiCastSlot")) then
		if not(self.TotemBorder) then 
			if (name:find("MultiCastAction")) then 
				self.TotemBorder = self.overlayTex
				
			elseif (name:find("MultiCastSlot")) then
				local region
				for i = 1, self:GetNumRegions() do
					region = select(i, self:GetRegions())
					if (region) and (region.GetTexture) and (region:GetTexture() == [[Interface\Buttons\UI-TotemBar]]) then
						self.TotemBorder = region
					end
				end
			end
		end
		
			
		if not(self.TotemBackground) then
			local Background = self:CreateTexture()
			Background:SetDrawLayer("BACKGROUND", 5)
			Background:SetTexture([[Interface\Buttons\UI-TotemBar]])
		
			self.TotemBackground = Background

			if (name:find("Action")) then
				local action = tonumber((name:gsub("MultiCastActionButton(%d+)", "%1")))
				local slot = SHAMAN_TOTEM_PRIORITIES[(action % MAX_TOTEMS == 0 and MAX_TOTEMS or action % MAX_TOTEMS)]
				
				Background:SetTexCoord(unpack(totemTex[slot]))
				
			elseif (name:find("Slot")) then
				local slot = tonumber((name:gsub("MultiCastSlotButton(%d+)", "%1")))
				
				Background:SetTexCoord(unpack(totemTex[slot]))
			end
		end
		
		if (self.TotemBorder) then
			self.TotemBorder:SetTexture("")
			self.TotemBorder.SetTexture = noop
		end
		
		if (self.TotemBackground) then
			self.TotemBackground:ClearAllPoints()
			self.TotemBackground:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
			self.TotemBackground:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
		end
	end
	
	-- backdrop, border and overlays
	self:SetUITemplate("itembutton")

	if (self.Hotkey) then
		local text = self.Hotkey:GetText()
		if (text) then
			F.StyleHotKey(text, self.Hotkey, self, self.ActionType) -- self.ActionType?
		end
	end
	
	if (self.Border) then
		self.Border:SetAlpha(0)
	end

	if (self.Frame) and (self.Frame.SetTexture) then
		self.Frame:SetTexture("")
	end
	
	if (self.FloatingBG) then
--		self.FloatingBG:Kill()
		self.FloatingBG:SetAlpha(0)
	end
	
	--[[
	if (self.FlyoutBorder) then
		self.FlyoutBorder:SetAlpha(0)
	end

	if (self.FlyoutBorderShadow) then
		self.FlyoutBorderShadow:SetAlpha(0)
	end
	]]--
	
	if (self.NormalTexture) then
		self.NormalTexture:ClearAllPoints()
		self.NormalTexture:SetPoint("TOPLEFT", self.Button, "TOPLEFT", -3, 3)
		self.NormalTexture:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", 3, -3)
		self.NormalTexture:SetVertexColor(C["normal"].r, C["normal"].g, C["normal"].b, 1)
	end
	
	if (self.Icon) then
		self.Icon:ClearAllPoints()
		self.Icon:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
		self.Icon:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
		self.Icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		self.Icon:SetDrawLayer("ARTWORK", 0)
	end

	if (self.Highlight) then
		self.Highlight:SetAlpha(0)
	end
	
	-- spell activation overlay, amongst other things
	-- don't reposition this, as it is handled by Blizzard in Interface\FrameXML\ActionButton.Lua
	if (self.Overlay) then
	end
	
	-- add or adjust new search overlay
	--[[
	if (self.Search) then
		self.Search:SetDrawLayer("OVERLAY", 7)
		self.Search:ClearAllPoints()
		self.Search:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
		self.Search:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
		
	else 
		self.Search = self:CreateTexture()
		self.Search:SetDrawLayer("OVERLAY", 1)
		self.Search:SetTexture(M["Background"]["Blank"])
		self.Search:SetVertexColor(0, 0, 0)
		self.Search:SetAlpha(4/5)
		self.Search:ClearAllPoints()
		self.Search:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
		self.Search:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
		
		if (self:GetName()) then
			_G[self:GetName() .. "Search"] = self.Search
		end
	end
	]]--
		
	if (self.Background) then
		self.Background:ClearAllPoints()
		self.Background:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
		self.Background:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
	end

	-- autocast ant trails and corner indicators
	if (self.Autocast) then
		self.Autocast:ClearAllPoints()
		self.Autocast:SetPoint("TOPLEFT", self.Button, "TOPLEFT", -12, 12)
		self.Autocast:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", 12, -12)
	end

	if (self.Shine) then
		self.Shine:ClearAllPoints()
		self.Shine:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
		self.Shine:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
	end

	if (self.Cooldown) then
		self.Cooldown:ClearAllPoints()
		self.Cooldown:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
		self.Cooldown:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
	end
	
	if (self.Count) then
		self.Count:ClearAllPoints()
		self.Count:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -2, 2)
		self.Count:SetFontObject(GUIS_NumberFontTiny)
		self.Count:SetJustifyH("RIGHT")
		self.Count:SetJustifyV("BOTTOM")
		self.Count:SetDrawLayer("OVERLAY", 4)
	end

	if (self.Hotkey) then
		self.Hotkey:ClearAllPoints()
		self.Hotkey:SetPoint("TOPRIGHT", self.Button, "TOPRIGHT", 0, 0)
		self.Hotkey.SetPoint = noop
		self.Hotkey.SetAllPoints = noop
		self.Hotkey.ClearAllPoints = noop
		self.Hotkey:SetWidth(self.Button:GetWidth())
		self.Hotkey:SetFontObject(GUIS_ItemButtonHotKeyFont)
		self.Hotkey:SetJustifyH("RIGHT")
		self.Hotkey:SetJustifyV("TOP")
		self.Hotkey:SetDrawLayer("OVERLAY", 4)
	end

	if (self.Macro) then
		self.Macro:ClearAllPoints()
		self.Macro:SetPoint("BOTTOMLEFT", self.Button, "BOTTOMLEFT", 2, 2)
		self.Macro:SetWidth(self.Button:GetWidth())
		self.Macro:SetFontObject(GUIS_ItemButtonNameFontMedium)
		self.Macro:SetJustifyH("LEFT")
		self.Macro:SetJustifyV("BOTTOM")
		self.Macro:SetDrawLayer("OVERLAY", 3)
	end

	if (self.Flash)  then
		self.Flash:SetTexture(1, 0, 0, 1/3)
		self.Flash:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
		self.Flash:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
	end
	
	if (self.Button.SetHighlightTexture) and (not _G[self.Name .. "HoverTex"]) then
		local hover = self.Button:CreateTexture(self.Name .. "HoverTex", nil, self)
		hover:SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 0.3)
		hover:ClearAllPoints()
		hover:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
		hover:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
--		hover:SetDrawLayer("OVERLAY", 1)
		self.Button:SetHighlightTexture(hover)
	end
 
	if (self.Button.SetPushedTexture) then
		if (_G[self.Name .. "PushedTex"]) then
			self.Button:GetPushedTexture():SetDrawLayer("OVERLAY")
		else
			local pushed = self.Button:CreateTexture(self.Name .. "PushedTex", nil, self)
			pushed:SetTexture(C["pushed"].r, C["pushed"].g, C["pushed"].b, 0.3)
			pushed:ClearAllPoints()
			pushed:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
			pushed:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
			pushed:SetDrawLayer("OVERLAY")
			self.Button:SetPushedTexture(pushed)
			self.Button:GetPushedTexture():SetDrawLayer("OVERLAY")
			
			_G[self.Name .. "PushedTex"] = pushed
		end
	end
 
	if (self.Button.SetCheckedTexture) then 
		if (_G[self.Name .. "CheckedTex"]) then
			self.Button:GetCheckedTexture():SetDrawLayer("OVERLAY")
		else
			local checked = self.Button:CreateTexture(self.Name .. "CheckedTex", nil, self)
			checked:SetTexture(C["checked"].r, C["checked"].g, C["checked"].b, 0.5)
			checked:ClearAllPoints()
			checked:SetPoint("TOPLEFT", self.Button, "TOPLEFT", 3, -3)
			checked:SetPoint("BOTTOMRIGHT", self.Button, "BOTTOMRIGHT", -3, 3)
			checked:SetDrawLayer("OVERLAY")
			self.Button:SetCheckedTexture(checked)
			self.Button:GetCheckedTexture():SetDrawLayer("OVERLAY")
			
			_G[self.Name .. "CheckedTex"] = checked
		end
	end
	
	self.Button:SetNormalTexture("")
	--[[
	if (self.NormalTexture) then
		if self.action and IsEquippedAction(self.action) and self.ItemRarity and self.ItemRarity > 1 then
			local r, g, b, _ = GetItemQualityColor(self.ItemRarity)
			self.NormalTexture:SetVertexColor(r, g, b, 1)
		else
			self.NormalTexture:SetVertexColor(C["normal"].r, C["normal"].g, C["normal"].b, 1)
		end
	end
	]]--

	if (self.action) and (IsEquippedAction(self.action)) and (self.ItemRarity) and (self.ItemRarity > 1) then  
		local r, g, b, _ = GetItemQualityColor(self.ItemRarity)
		self:SetBackdropBorderColor(r * 4/5, g * 4/5, b * 4/5, 1)
	else
		self:SetBackdropBorderColor(C["normal"].r, C["normal"].g, C["normal"].b, 1)
	end
	
	if (self.TotemBorder) then
		local tc = C["totem"][(((self:GetID() - 1) % 4) + 1)]
		
		--[[
		if (self.NormalTexture) then
			self.NormalTexture:SetVertexColor(tc.r, tc.g, tc.b, 1)
		end
		]]--
		
		self:SetBackdropBorderColor(tc.r * 4/5, tc.g * 4/5, tc.b * 4/5, 1)
	end
end

--------------------------------------------------------------------------------------------------
--		Skinning API
--------------------------------------------------------------------------------------------------

do
	local clutter = { "Left"; "Right"; "Middle" ;"Mid"; "Top"; "Bottom"; "Background"; "BG"; "Track"; "TopRight"; "TopLeft"; "BottomLeft"; "BottomRight"; }
	RemoveClutter = function(self)
		if not(self) or not(self.GetName) or not(self:GetName()) then
			return
		end
		
		local t
		for i,v in pairs(clutter) do
			t = _G[self:GetName() .. v]
			if (t) then
				t:Kill()
			end
		end
	end
end

RemoveTextures = function(self, force)
	if (self:GetObjectType() == "Texture") then
		self:SetTexture("")
		
		if (force) then
			self:Kill()
		end
	else
		for i = 1, self:GetNumRegions() do
			local region = select(i, self:GetRegions())
			if (region:GetObjectType() == "Texture") then
				region:SetTexture("")
				
				if (force) then
					region:Kill()
				end
			end
		end
	end
end

CreateHighlight = function(self, top, left, bottom, right)
	local highlight = self:CreateTexture(nil, "OVERLAY")
	highlight:ClearAllPoints()
	highlight:SetPoint("TOPLEFT", self, "TOPLEFT", (left or 0), (top or 0))
	highlight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (right or 0), (bottom or 0))
	highlight:SetTexture(C["index"][1], C["index"][2], C["index"][3], 1/3)
	self:SetHighlightTexture(highlight)
	
	local name = self:GetName()
	if (name) then
		_G[name .. "Highlight"] = highlight
	end
	
	return self:GetHighlightTexture()
end

CreateChecked = function(self, top, left, bottom, right)
	local checked = self:CreateTexture(nil, "OVERLAY")
	checked:ClearAllPoints()
	checked:SetPoint("TOPLEFT", self, "TOPLEFT", (left or 0), (top or 0))
	checked:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (right or 0), (bottom or 0))
	checked:SetTexture(C["index"][1], C["index"][2], C["index"][3], 1/2)
	self:SetCheckedTexture(checked)
	
	local name = self:GetName()
	if (name) then
		_G[name .. "Checked"] = checked
	end

	return checked
end

CreatePushed = function(self, top, left, bottom, right)
	local pushed = self:CreateTexture(nil, "OVERLAY")
	pushed:ClearAllPoints()
	pushed:SetPoint("TOPLEFT", self, "TOPLEFT", (left or 0), (top or 0))
	pushed:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (right or 0), (bottom or 0))
	pushed:SetTexture(C["value"][1], C["value"][2], C["value"][3], 1/4)
	self:SetPushedTexture(pushed)
	
	local name = self:GetName()
	if (name) then
		_G[name .. "Pushed"] = pushed
	end
	
	return self:GetPushedTexture()
end

------------------------------------------------------------------------------------------------------------
-- 	API calls
------------------------------------------------------------------------------------------------------------
do
	local setAPI = function(frame)
		local meta = getmetatable(frame).__index

		-- downstripping
		meta.RemoveClutter = RemoveClutter 
		meta.RemoveTextures = RemoveTextures 

		-- element creation
		meta.CreateHighlight = CreateHighlight 
		meta.CreateChecked = CreateChecked 
		meta.CreatePushed = CreatePushed 
	end

	local done = {}

	local frames = EnumerateFrames()
	while frames do
		if (not done[frames:GetObjectType()]) then
			setAPI(frames)
			done[frames:GetObjectType()] = true
		end

		frames = EnumerateFrames(frames)
	end
	
	-- textures
	local meta = getmetatable(CreateFrame("Frame"):CreateTexture()).__index
	meta.RemoveTextures = RemoveTextures 
	
	done = nil
end

