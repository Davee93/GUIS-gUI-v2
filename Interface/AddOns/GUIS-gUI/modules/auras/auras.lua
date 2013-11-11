--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Auras")

-- Lua API
local pairs, unpack, select = pairs, unpack, select
local tinsert = table.insert
local ceil, floor, max = math.ceil, math.floor, math.max
local strfind = string.find

-- WoW API
local CreateFrame = CreateFrame
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventorySlotInfo = GetInventorySlotInfo
local GetTime = GetTime 
local GetScreenWidth = GetScreenWidth
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local UnitAura = UnitAura
local UnitHasVehicleUI = UnitHasVehicleUI

local GameTooltip = GameTooltip
local UIParent = UIParent

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gFH = LibStub("gFrameHandler-1.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local RegisterBucketEvent = function(...) return module:RegisterBucketEvent(...) end
local ScheduleTimer = function(...) return module:ScheduleTimer(...) end
local StyleActionButton = function(...) LibStub("gAuras-2.0").StyleActionButton(...) end

local DebuffTypeColor = DebuffTypeColor

local createHeader, style
local updateHeaders, updateStyle, updateWeaponEnchant, updateTime
local SetGloss, SetShade, SetCooldown, SetText, ApplyToAll

local headers, buttons = {}, {}
local day, hour, minute = 86400, 3600, 60

local defaults = {
	showgloss = true;
	showshade = true;
	glossalpha = 1/3;
	shadealpha = 1/2;
	showTimeText = true;
	showCooldownSpiral = false;
}

local menuTable = {
	{
		type = "group";
		name = module:GetName();
		order = 1;
		virtual = true;
		children = {
			{
				type = "widget";
				element = "Title";
				order = 1;
				msg = F.getName(module:GetName());
			};
			{
				type = "widget";
				element = "Text";
				order = 2;
				msg = L["These options allow you to control how buffs and debuffs are displayed. If you wish to change the position of the buffs and debuffs, you can unlock them for movement with |cFF4488FF/glock|r."];
			};
			{
				type = "group";
				order = 5;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 10;
						width = "half";
						msg = L["Aura Styling"];
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showGloss";
						order = 100;
						width = "half"; 
						msg = L["Show gloss layer on Auras"];
						desc = { L["Show Gloss"], L["This will display the gloss overlay on the Auras"] };
						set = function(self) 
							GUIS_DB.auras.showgloss = not(GUIS_DB.auras.showgloss)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.auras.showgloss end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showShade";
						order = 105;
						width = "half"; 
						msg = L["Show shade layer on Auras"];
						desc = { L["Show Shade"], L["This will display the shade overlay on the Auras"] };
						set = function(self) 
							GUIS_DB.auras.showshade = not(GUIS_DB.auras.showshade)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.auras.showshade end;
					};
					{
						type = "widget";
						element = "Header";
						order = 11;
						width = "half";
						msg = L["Time Display"];
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showDuration";
						order = 101;
						width = "half"; 
						msg = L["Show remaining time on Auras"];
						desc = { L["Show Time"], L["This will display the currently remaining time on Auras where applicable"] };
						set = function(self) 
							GUIS_DB.auras.showTimeText = not(GUIS_DB.auras.showTimeText)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.auras.showTimeText end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showCooldown";
						order = 106;
						width = "half"; 
						msg = L["Show cooldown spirals on Auras"];
						desc = { L["Show Cooldown Spirals"], L["This will display cooldown spirals on Auras to indicate remaining time"] };
						set = function(self) 
							GUIS_DB.auras.showCooldownSpiral = not(GUIS_DB.auras.showCooldownSpiral)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.auras.showCooldownSpiral end;
					};
				};
			};
		};
	};
}

local faq = {
	{
		q = L["How can I change how my buffs and debuffs look?"];
		a = {
			{
				type = "text";
				msg = L["You can change a lot of settings like the time display and the cooldown spiral in the options menu."];
			};
			{
				type = "button";
				msg = L["Go to the options menu"];
				click = function(self) 
					PlaySound("igMainMenuOption")
					securecall("CloseAllWindows")
					
					F.OpenToOptionsCategory(F.getName(module:GetName()))
				end;
			};
		};
		tags = { "auras", "buffs", "debuffs" };
	};
	{
		q = L["Sometimes the weapon buffs don't display correctly!"];
		a = {
			{
				type = "text";
				msg = L["Correct. Sadly this is a bug in the tools Blizzard has given to us addon developers, and not something that is easily fixed. You'll simply have to live with it for now."];
			};
		};
		tags = { "auras", "buffs", "debuffs" };
	};
}

createHeader = function(name, ...)
	local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")

	header:SetClampedToScreen(true)
	header:SetAttribute("minWidth", 636)
	header:SetAttribute("minHeight", 106)

	for i = 1, select("#", ...), 2 do
		local attribute, value = select(i, ...)
		if not(attribute) then break end
		
		header:SetAttribute(attribute, value)
	end
	
	header:Show()

	return header
end

updateTime = function(button, header)
	if not(button) or not(button:IsVisible()) then return end
	
	local timeLeft = max((button.expirationTime or 0) - GetTime(), 0)
	
	if (timeLeft ~= button.timeLeft) then
		-- more than a day
		if (timeLeft > day) then
			button.Duration:SetFormattedText("%1dd", ceil(timeLeft / day))
			
		-- more than an hour
		elseif (timeLeft > hour) then
			button.Duration:SetFormattedText("%1dh", ceil(timeLeft / hour))
		
		-- more than a minute
		elseif (timeLeft > minute) then
			button.Duration:SetFormattedText("%1dm", ceil(timeLeft / minute))
		
		-- more than 10 seconds
		elseif (timeLeft > 10) then 
			button.Duration:SetFormattedText("%1d", floor(timeLeft))
		
		-- between 6 and 10 seconds
		elseif (timeLeft <= 10) and (timeLeft >= 6) then
			button.Duration:SetFormattedText("|cffff8800%1d|r", floor(timeLeft))
			
		-- between 3 and 5 seconds
		elseif (timeLeft >= 3) and (timeLeft < 6)then
			button.Duration:SetFormattedText("|cffff0000%1d|r", floor(timeLeft))
			
		-- less than 3 seconds
		elseif (timeLeft > 0) and (timeLeft < 3) then
			button.Duration:SetFormattedText("|cffff0000%.1f|r", timeLeft)
			
		else
			button.Duration:SetText("")
		end
		
		button.timeLeft = timeLeft
	end
	
	if (GameTooltip:IsOwned(button)) then
		GameTooltip:SetUnitAura(header:GetAttribute("unit"), button:GetID(), header:GetAttribute("filter"))
--		GameTooltip:SetUnitAura(SecureButton_GetUnit(button:GetParent()), button:GetID(), button.filter)
	end
end

style = function(button, header)
	button:SetUITemplate("simplebackdrop")
	
	button.Icon = button:CreateTexture()
	button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
	button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
	button.Icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)

	button.Cooldown = CreateFrame("Cooldown", nil, button)
	button.Cooldown:SetAllPoints(button.Icon)
	button.Cooldown:SetReverse()
	
	button.Count = button:CreateFontString(nil, "OVERLAY")
	button.Count:SetFontObject(GUIS_NumberFontTiny)
	button.Count:SetJustifyH("RIGHT")
	button.Count:SetJustifyV("BOTTOM")
	button.Count:SetPoint("BOTTOMRIGHT", button.Icon, "BOTTOMRIGHT", -1, 1)
	
	button.Duration = button:CreateFontString(nil, "OVERLAY")
	button.Duration:SetFontObject(GUIS_SystemFontSmall)
	button.Duration:SetJustifyH("CENTER")
	button.Duration:SetJustifyV("TOP")
	button.Duration:SetPoint("TOP", button, "BOTTOM", 0, -2)
	
	local layer, subLayer = button.Icon:GetDrawLayer()
	
	button.Shade = button:CreateTexture()
	button.Shade:SetDrawLayer(layer or "BACKGROUND", subLayer and subLayer + 1 or 2)
	button.Shade:SetTexture(M["Button"]["Shade"])
	button.Shade:SetVertexColor(0, 0, 0, 1/3)
	button.Shade:SetAllPoints(button.Icon)

	button.Gloss = button:CreateTexture()
	button.Gloss:SetDrawLayer(layer or "BACKGROUND", subLayer and subLayer + 2 or 3)
	button.Gloss:SetTexture(M["Button"]["Gloss"])
	button.Gloss:SetVertexColor(1, 1, 1, 1/3)
	button.Gloss:SetAllPoints(button.Icon)

	if (GUIS_DB["auras"].showgloss) then
		button.Gloss:Show()
	else
		button.Gloss:Hide()
	end

	if (GUIS_DB["auras"].showshade) then
		button.Shade:Show()
	else
		button.Shade:Hide()
	end

	if (GUIS_DB["auras"].showCooldownSpiral) then
		button.Cooldown:Show()
	else
		button.Cooldown:Hide()
	end
	
	if (GUIS_DB["auras"].showTimeText) then
		button.Duration:Show()
	else
		button.Duration:Hide()
	end
	
	if not(buttons[button]) then
		buttons[button] = true
	end

	do
		local button, header = button, header
		ScheduleTimer(function() updateTime(button, header) end, 0.1)
	end
end

updateWeaponEnchant = function(button, header, slot, active, time, charges)
	if (not button) then return end
	
	if (not button.Icon) then
		style(button, header)
	end
	
	if (active) then
		button.Icon:SetTexture(GetInventoryItemTexture("player", GetInventorySlotInfo(slot)))
		button.Count:SetText((charges > 1) and charges or "")
	end
	
	time = time and (time/1000 + GetTime())
	
	if (time ~= button.expirationTime) then
		button.expirationTime = time
	end

	if (UnitHasVehicleUI("player")) then
		button:SetAlpha(1/3)
	else
		button:SetAlpha(1)
	end
end

do
	local e1, e1time, e1charges, e2, e2time, e2charges, e3, e3time, e3charges 
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId
	local button

	updateStyle = function(header, event, unit)
		e1, e1time, e1charges, e2, e2time, e2charges, e3, e3time, e3charges = GetWeaponEnchantInfo()
		
		updateWeaponEnchant(header:GetAttribute("tempEnchant1"), header, "MainHandSlot", e1, e1time, e1charges)
		updateWeaponEnchant(header:GetAttribute("tempEnchant2"), header, "SecondaryHandSlot", e2, e2time, e2charges)
		updateWeaponEnchant(header:GetAttribute("tempEnchant3"), header, "RangedSlot", e3, e3time, e3charges)

		for index = 1,32 do
			button = header:GetAttribute("child" .. index)
			
			if (button) and (button:IsVisible()) then 
			
				if (not button.Icon) then
					style(button, header)
				end

				name, _, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(header:GetAttribute("unit"), button:GetID(), header:GetAttribute("filter"))

				if (name) then
					button.Icon:SetTexture(icon)
					
					if (expirationTime ~= button.expirationTime) then
						button.expirationTime = expirationTime
					end
					
					if (GUIS_DB["auras"].showCooldownSpiral) then
						button.Cooldown:Show()
						button.Cooldown:SetCooldown(expirationTime - duration, duration)
					else
						button.Cooldown:Hide()
					end				
					
					button.Count:SetText((count > 1) and count or "")
					
					if (strfind(button:GetAttribute("filter"), "HARMFUL")) then
						local color = DebuffTypeColor[debuffType] or { r = 0.7, g = 0, b = 0 }

						button:SetBackdropBorderColor(color.r, color.g, color.b)
					else
						if (unitCaster == "vehicle") then
							button:SetBackdropBorderColor(0, 3/4, 0, 1)
						else
							button:SetBackdropBorderColor(unpack(C["border"]))
						end
					end
				end
			end
		end
	end
end

updateHeaders = function(self, event, unit)
	if (event == "UNIT_AURA") and (unit) and ((unit ~= "player") or (UnitHasVehicleUI("player") and (unit ~= "vehicle"))) then
		return
	end
	
	for _,header in pairs(headers) do
		updateStyle(header, event, unit)
	end
end

SetGloss = function(button)
	if not(button.Gloss) then
		return
	end
	
	button.Gloss:SetAlpha(GUIS_DB["auras"].glossalpha)
	
	if (GetBoolean(GUIS_DB["auras"].showgloss)) then
		if not(button.Gloss:IsShown()) then
			button.Gloss:Show()
		end
	else
		if (button.Gloss:IsShown()) then
			button.Gloss:Hide()
		end
	end
end

SetShade = function(button)
	if not(button.Shade) then
		return
	end
	
	button.Shade:SetAlpha(GUIS_DB["auras"].shadealpha)

	if (GetBoolean(GUIS_DB["auras"].showshade)) then
		if not(button.Shade:IsShown()) then
			button.Shade:Show()
		end
	else
		if (button.Shade:IsShown()) then
			button.Shade:Hide()
		end
	end
end

SetCooldown = function(button)
	if not(button.Cooldown) then
		return
	end
	
	if (GUIS_DB["auras"].showCooldownSpiral) then
		if not(button.Cooldown:IsShown()) then
			button.Cooldown:Show()
		end
	else
		if (button.Cooldown:IsShown()) then
			button.Cooldown:Hide()
		end
	end
end

SetText = function(button)
	if not(button.Duration) then
		return
	end

	if (GUIS_DB["auras"].showTimeText) then
		if not(button.Duration:IsShown()) then
			button.Duration:Show()
		end
	else
		if (button.Duration:IsShown()) then
			button.Duration:Hide()
		end
	end
end

ApplyToAll = function(func, ...)
	for button,_ in pairs(buttons) do
		func(button, ...)
	end
end

module.UpdateAll = function(self)
	ApplyToAll(SetGloss)
	ApplyToAll(SetShade)
	ApplyToAll(SetText)
	ApplyToAll(SetCooldown)
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["auras"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["auras"] = GUIS_DB["auras"] or {}
	GUIS_DB["auras"] = ValidateTable(GUIS_DB["auras"], defaults)
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill() 
		return 
	end

	local buffsize = 29
	local columns = (GetScreenWidth() >= 1200) and 16 or 12
	local lines = (GetScreenWidth() >= 1200) and 2 or 3
	local width = buffsize + 2
	local height = buffsize + 2 + 14 + 4

	local buffs = createHeader(self:GetName() .. "PlayerBuffs", 
		"unit", "player",
		"filter", "HELPFUL",
		"sortMethod", "TIME",
		"sortDirection", "-",
		"point", "TOPRIGHT",
		"template", "GUIS_AuraButtonTemplate",
		"wrapAfter", columns,
		"wrapXOffset", 0,
		"wrapYOffset", -height,
		"maxWraps", lines,
		"minWidth", width * columns,
		"minHeight", height * lines,
		"xOffset", -width,
		"yOffset", 0,
		"separateOwn", nil,
		"includeWeapons", 1,
		"weaponTemplate", "GUIS_AuraButtonTemplate"
	)
	buffs:SetSize(columns * width, lines * height)
	buffs:PlaceAndSave("TOPRIGHT", UIParent, "TOPRIGHT", -8, -8)
	
	tinsert(headers, buffs)

	local debuffs = createHeader(self:GetName() .. "PlayerDebuffs", 
		"unit", "player",
		"filter", "HARMFUL",
		"sortMethod", "TIME",
		"sortDirection", "-",
		"point", "TOPRIGHT",
		"template", "GUIS_AuraButtonTemplate",
		"wrapAfter", columns,
		"wrapXOffset", 0,
		"wrapYOffset", -height,
		"maxWraps", lines,
		"minWidth", width * columns,
		"minHeight", height * lines,
		"xOffset", -width,
		"yOffset", 0
	)
	debuffs:SetSize(columns * width, lines * height)
	debuffs:PlaceAndSave("TOPRIGHT", UIParent, "TOPRIGHT", -8, -(8 + (8 + lines * height)))
	
	tinsert(headers, debuffs)
	
	local VehicleUpdater = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")
	VehicleUpdater:SetAttribute("_onstate-aurastate", [[
		local buffs = self:GetFrameRef("auraframe1")
		local debuffs = self:GetFrameRef("auraframe2")
		local state = (newstate == "invehicle") and "vehicle" or "player"
		buffs:SetAttribute("unit", state)
		debuffs:SetAttribute("unit", state)
	]])
	VehicleUpdater:SetFrameRef("auraframe1", buffs)
	VehicleUpdater:SetFrameRef("auraframe2", debuffs)
	RegisterStateDriver(VehicleUpdater, "aurastate", "[vehicleui] invehicle; notinvehicle")

	RegisterCallback("PLAYER_ENTERING_WORLD", updateHeaders)
	RegisterCallback("UNIT_AURA", updateHeaders)
	RegisterCallback("UNIT_INVENTORY_CHANGED", updateHeaders)
	
	-- create the options menu
	do
		local restoreDefaults = function()
			if (InCombatLockdown()) then 
				print(L["Can not apply default settings while engaged in combat."])
				return
			end
			
			-- restore all frame positions
			self:RestoreDefaults()
			
			-- request a restart if needed
			F.RestartIfScheduled()
		end
		
		local cancelChanges = function()
		end
		
		local applySettings = function()
		end
		
		local applyChanges = function()
		end
		
		local gOM = LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu")
		gOM:RegisterWithBlizzard(gOM:New(menuTable), F.getName(self:GetName()), 
 			"default", restoreDefaults, 
			"cancel", cancelChanges, 
			"okay", applyChanges)
	end

	-- register the FAQ
	do
		local FAQ = LibStub("gCore-3.0"):GetModule("GUIS-gUI: FAQ")
		FAQ:NewGroup(faq)
	end	
end
