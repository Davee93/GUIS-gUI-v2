--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local MAJOR, MINOR = "gActionBars-2.0", 100
local gActionBars, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not gActionBars then return end 

assert(LibStub("gFrameHandler-1.0"), MAJOR .. " couldn't find an instance of gFrameHandler-1.0")

-- Lua API
local strfind, strsplit, format = string.find, string.split, string.format
local pairs, select, unpack = pairs, select, unpack
local type = type
local tconcat, tinsert = table.concat, table.insert
local setmetatable = setmetatable
local rawget = rawget
local wipe = wipe

-- WoW API
local ActionButton_ShowGrid = ActionButton_ShowGrid
local AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local CreateFrame = CreateFrame
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetPetActionInfo = GetPetActionInfo
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local GetPetActionSlotUsable = GetPetActionSlotUsable
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsLoggedIn = IsLoggedIn
local IsPetAttackAction = IsPetAttackAction
local PetActionBar_UpdateCooldowns = PetActionBar_UpdateCooldowns
local PetActionButton_StartFlash = PetActionButton_StartFlash
local PetActionButton_StopFlash = PetActionButton_StopFlash
local PetHasActionBar = PetHasActionBar
local SetCVar = SetCVar
local SetDesaturation = SetDesaturation

--[[
local BOTTOMRIGHT_ACTIONBAR_PAGE = BOTTOMRIGHT_ACTIONBAR_PAGE
local BOTTOMLEFT_ACTIONBAR_PAGE = BOTTOMLEFT_ACTIONBAR_PAGE
local LEFT_ACTIONBAR_PAGE = LEFT_ACTIONBAR_PAGE
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local NUM_MULTI_CAST_BUTTONS_PER_PAGE = NUM_MULTI_CAST_BUTTONS_PER_PAGE
local NUM_MULTI_CAST_PAGES = NUM_MULTI_CAST_PAGES
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local RIGHT_ACTIONBAR_PAGE = RIGHT_ACTIONBAR_PAGE
]]--

local GetBoolean = GetBoolean

-- template frames
gActionBars.templateBar = gActionBars.templateBar or CreateFrame("Button", "gAB20TemplateBar", UIParent, "SecureHandlerStateTemplate")
gActionBars.templateBar:Hide()

gActionBars.BARS = gActionBars.BARS or {}
gActionBars.disabled = gActionBars.disabled or {}
gActionBars.Initialized = gActionBars.Initialized or false

local noop = function() return end
local playerClass = (select(2, UnitClass("player")))
local actionbarMeta = { __index = gActionBars.templateBar }

-- we use a table within a table for the buttonlists to simplify button ordering
local defaultButtons = {
	["primary"] = { {["ActionButton"] = { 1, NUM_ACTIONBAR_BUTTONS }; }; };
	["bottomleft"] = { {["MultiBarBottomLeftButton"] = { 1, NUM_ACTIONBAR_BUTTONS }; }; };
	["bottomright"] = { {["MultiBarBottomRightButton"] = { 1, NUM_ACTIONBAR_BUTTONS }; }; };
	["right"] = { {["MultiBarRightButton"] = { 1, NUM_ACTIONBAR_BUTTONS }; }; };
	["left"] = { {["MultiBarLeftButton"] = { 1, NUM_ACTIONBAR_BUTTONS }; }; };
	["pet"] = { {["PetActionButton"] = { 1, NUM_PET_ACTION_SLOTS }; }; };
	["shift"] = { {["ShapeshiftButton"] = { 1, NUM_SHAPESHIFT_SLOTS }; }; };
	["totem"] = { 
		{["MultiCastSummonSpellButton"] = { -1, -1 }; };
		{["MultiCastSlotButton"] = { 1, MAX_TOTEMS }; };
		{["MultiCastRecallSpellButton"] = { -1, -1 }; };
	};
--	["extra"] = { {["ExtraACtionButton"] = { 1, 1 }; }; };
}

--
-- available types of actionbars
-- * 	by setting all common types to 'page' 
-- 	we allow for page switching when holding modifier keys
local barTypes = {
	["primary"] = "page";
	["bottomleft"] = "page";
	["bottomright"] = "page";
	["left"] = "page";
	["right"] = "page";
	["pet"] = "static";
	["shift"] = "static";
	["totem"] = "static";
}

local simpleButtonReference = {
	["primary"] = "ActionButton";
	["bottomleft"] = "MultiBarBottomLeftButton";
	["bottomright"] = "MultiBarBottomRightButton";
	["left"] = "MultiBarLeftButton";
	["right"] = "MultiBarRightButton";
	["pet"] = "PetActionButton";
	["shift"] = "ShapeshiftButton";
--	["extra"] = "ExtraActionButton";
}

local shiftClass = {
	["DRUID"] = true;
	["WARRIOR"] = true;
	["PALADIN"] = true;
	["DEATHKNIGHT"] = true;
	["ROGUE"] = true;
	["PRIEST"] = true;
	["HUNTER"] = true;
	["WARLOCK"] = true;
}

--
-- just a simple conversion table to easier remember the bar 'positions'
BarToID = {
	["primary"] = 1;
	["secondary"] = 2;
	["right"] = RIGHT_ACTIONBAR_PAGE; -- 3
	["left"] = LEFT_ACTIONBAR_PAGE; -- 4
	["bottomright"] = BOTTOMRIGHT_ACTIONBAR_PAGE; -- 5
	["bottomleft"] = BOTTOMLEFT_ACTIONBAR_PAGE; -- 6
}
setmetatable(BarToID, { __index = function(t, i) 
	return rawget(t,i) or 0
end })

-- these values can be modified to change the page switching
-- mostly used for druids that want a stealth bar (which would be 8 for the 'Prowl' value)
ClassConditionals = {
	["DRUID"] = { 7, 7, 9, 10 }; -- Cat, Prowl, Bear, Moonkin
	["PRIEST"] = { 7 }; -- Shadow Form
	["ROGUE"] = { 7, 8 }; -- Stealth, Shadow Dance
	["WARLOCK"] = { 7 }; -- Demon Form
	["WARRIOR"] = { 7, 8, 9 }; -- Battle, Defensive, Berserker
}

--
-- turns a string containing any of the words "shift", "ctrl" or "alt" into a proper macro conditional
ModifierKeys = {}
do
	local modString = {}
	setmetatable(ModifierKeys, { __index = function(t, i) 
		wipe(modString)
		if (strfind(i, "shift")) then
			tinsert(modString, "mod:shift")
		end

		if (strfind(i, "alt")) then
			tinsert(modString, "mod:alt")
		end

		if (strfind(i, "ctrl")) then
			tinsert(modString, "mod:ctrl")
		end
		
		if (#modString > 0) then
			return "[" .. tconcat(modString, ", ") .. "]"
		else
			return ""
		end
	end })
end

-- returns a macro for RegisterStateDriver, based on bar ID and player class
StateDriverByID = {
	[0] = "0";
	[2] = "2";
	[3] = ("%d"):format(RIGHT_ACTIONBAR_PAGE);
	[4] = ("%d"):format(LEFT_ACTIONBAR_PAGE);
	[5] = ("%d"):format(BOTTOMRIGHT_ACTIONBAR_PAGE);
	[6] = ("%d"):format(BOTTOMLEFT_ACTIONBAR_PAGE);
}
do
	local pageDriver = {}
	setmetatable(StateDriverByID, { __index = function(t, i)
		i = tonumber(i)
		
		if (i == 1) then
			wipe(pageDriver)
			tinsert(pageDriver, "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11")
			
			if (playerClass == "DRUID") then
				tinsert(pageDriver, ("[bonusbar:1, nostealth] %d; [bonusbar:1, stealth] %d; [bonusbar:2] 8; [bonusbar:3] %d; [bonusbar:4] %d"):format(unpack(ClassConditionals[playerClass])))
				
			elseif (playerClass == "PRIEST") then
				tinsert(pageDriver, ("[bonusbar:1] %d"):format(unpack(ClassConditionals[playerClass])))
				
			elseif (playerClass == "ROGUE") then
				tinsert(pageDriver, ("[bonusbar:1] %d; [form:3] %d"):format(unpack(ClassConditionals[playerClass])))
				
			elseif (playerClass == "WARLOCK") then
				tinsert(pageDriver, ("[form:2] %d"):format(unpack(ClassConditionals[playerClass])))
				
			elseif (playerClass == "WARRIOR") then
				tinsert(pageDriver, ("[bonusbar:1] %d; [bonusbar:2] %d; [bonusbar:3] %d"):format(unpack(ClassConditionals[playerClass])))
				
			end

			tinsert(pageDriver,"1")
			
			return tconcat(pageDriver, "; ")
			
		elseif (type(i) ~= "number") or (not rawget(t, i)) then
			return rawget(t, 0) -- a return value of '0' means 'no paging'
			
		elseif (rawget(t, i)) then
			return (rawget(t, i))
		end
	end })
end

--
-- create a frame for a new actionbar that inherits from our template bar
local New = function(name)
	local showHideDummy = CreateFrame("Frame", name .. "Parent", UIParent)
	return setmetatable(CreateFrame("Frame", name, showHideDummy, "SecureHandlerStateTemplate"), actionbarMeta)
end

--
-- assign buttons to the actionbar
gActionBars.templateBar.SetButtons = function(self, ...)
	if (#self.buttons > 0) then
		for _,button in pairs(self.buttons) do
			_G[button]:ClearAllPoints()
			_G[button]:SetParent(gActionBars.templateBar)
		end
	end

	wipe(self.buttons)

	if (...) and (select(1, ...) ~= "") then
		for i = 1, select("#", ...) do
			tinsert(self.buttons, simpleButtonReference[self:GetAttribute("type")] .. (select(i, ...)))
		end
	else
		for i = 1, #defaultButtons[self:GetAttribute("type")] do
			for buttonType, buttonValues in pairs(defaultButtons[self:GetAttribute("type")][i]) do
				if (buttonValues[1] == -1) then
					tinsert(self.buttons, buttonType)
				else
					local a, b = buttonValues[1], buttonValues[2]
					if (a) and (b) then
						for i = a, b do
							tinsert(self.buttons, buttonType .. i)
						end
					end
				end
			end
		end
	end
	
end

--
-- arranges the buttons on the actionbar
gActionBars.templateBar.Arrange = function(self)
	if (#self.buttons == 0) then 
		return 
	end
	
	-- the totembar is some fragile piece of <censored> >:(
	if (self:GetAttribute("type") == "totem") then
		if (playerClass ~= "SHAMAN") or not(MultiCastActionBarFrame) or (MultiCastActionBarFrame.runOnce) then
			return
		end
		
		self:SetSize(MultiCastActionBarFrame:GetSize())
		
		MultiCastActionBarFrame:EnableMouse(false)
		
		MultiCastActionBarFrame:SetScript("OnUpdate", nil)
		MultiCastActionBarFrame:SetScript("OnShow", nil)
		MultiCastActionBarFrame:SetScript("OnHide", nil)
		MultiCastActionBarFrame:SetParent(self)
		MultiCastActionBarFrame.SetParent = noop

		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		MultiCastActionBarFrame.SetPoint = noop

		-- don't do this. let Blizzard handle the parenting and visibility alltogether
		-- otherwise we'll have a "ghost" summon button causing errors until you learn your first totem at level 4
--		for _,child in pairs({ MultiCastActionBarFrame:GetChildren() }) do
--			child:SetParent(self)
--		end
		
		local actionButton, texture
		for i = 1, NUM_MULTI_CAST_PAGES * NUM_MULTI_CAST_BUTTONS_PER_PAGE do
			actionButton = _G["MultiCastActionButton" .. i]
			actionButton:SetAllPoints(_G["MultiCastSlotButton"..(i % MAX_TOTEMS == 0 and MAX_TOTEMS or i % MAX_TOTEMS)])
		end

		hooksecurefunc("MultiCastActionButton_Update", function(actionButton) 
			if not(InCombatLockdown()) then 
				actionButton:SetAllPoints(actionButton.slotButton) 
			end 
		end)
		
		MultiCastActionBarFrame.runOnce = true
		
		return
	end

	local down = self:GetAttribute("growth-y") == "down"
	local right = self:GetAttribute("growth-x") == "right"
	local height = self:GetAttribute("height")
	local width = self:GetAttribute("width")
	local gap = self:GetAttribute("gap")
	local buttonsize = self:GetAttribute("buttonsize") or _G[self.buttons[1]]:GetWidth()

	-- size the bar to fit the buttons perfectly
	self:SetSize((buttonsize * width) + gap * (width-1), (buttonsize * height) + gap * (height - 1) )
	
	local button
	for i = 1, #self.buttons do
		if (i > (width * height)) then break end

		button = _G[self.buttons[i]]
		button:SetParent(self)
		button:SetSize(buttonsize, buttonsize)
		
		if (i == 1) then
			if (self:GetAttribute("type") == "shift") and (not self.fixShift) then
				local down, right = down, right
				self.fixShift = function() 
					ShapeshiftButton1:ClearAllPoints()
					ShapeshiftButton1:SetPoint((down and "TOP" or "BOTTOM") .. (right and "LEFT" or "RIGHT"), self, 0, 0)
				end
				hooksecurefunc("ShapeshiftBar_Update", self.fixShift)
			end
			button:ClearAllPoints()
			button:SetPoint((down and "TOP" or "BOTTOM") .. (right and "LEFT" or "RIGHT"), self, 0, 0)
			
		elseif ((i-1) % width == 0) then
			button:ClearAllPoints()
			button:SetPoint(down and "TOP" or "BOTTOM", _G[self.buttons[i-width]], down and "BOTTOM" or "TOP", 0, down and -gap or gap)	
			
		else
			button:ClearAllPoints()
			button:SetPoint(right and "LEFT" or "RIGHT", _G[self.buttons[i-1]], right and "RIGHT" or "LEFT", right and gap or -gap, 0)
		end
	end
end

--
-- initialize an actionbar
gActionBars.templateBar.Start = function(self)
	self:UnregisterAllEvents()
	
	local setUpStateBar = function(self)
		local execute = [[ buttons = table.new(); ]]

		local button
		for i = 1, #self.buttons do
			button = self.buttons[i]
			self:SetFrameRef(button, _G[button])
			
			execute = execute .. ([[
				table.insert(buttons, self:GetFrameRef("%s"));
			]]):format(button)

			_G[button]:SetParent(self)
			_G[button]:SetScript("OnDragStart", function(self) 
				-- except for this, the script is identical to the original 
				-- blizzard script in FrameXML\ActionBarFrame.xml
				if (InCombatLockdown()) then
					return
				end
				
				if ((LOCK_ACTIONBAR ~= "1") or (IsModifiedClick("PICKUPACTION"))) then
					SpellFlyout:Hide()
					PickupAction(self.action)
					ActionButton_UpdateState(self)
					ActionButton_UpdateFlash(self)
				end
			end)
		end
		
		self:Execute(execute)

		self:SetAttribute("_onstate-page", [[
			for i, button in ipairs(buttons) do 
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])
		
		RegisterStateDriver(self, "page", StateDriverByID[self:GetID()])
		RegisterStateDriver(self, "visibility", self:GetAttribute("novehicleui") and "[novehicleui] show; hide" or "show")
	end

	local setUpTotemBar = function(self)
		if (playerClass ~= "SHAMAN") then
			return
		end
		
		if (self.initialized) then 
			return 
		else
			self.initialized = true
		end

		RegisterStateDriver(self, "visibility", "[novehicleui] show; hide")
	end

	local setUpShiftBar = function(self)
--		if (not shiftClass[playerClass]) then
--			return
--		end

		self.UpdateShiftButtons = function()
			for i = 1, NUM_SHAPESHIFT_SLOTS do
				if (select(2, GetShapeshiftFormInfo(i))) then
					_G["ShapeshiftButton" .. i]:Show()
				else
					_G["ShapeshiftButton" .. i]:Hide()
				end
			end
		end

		self.UpdateShiftBar = function()
			local numForms = GetNumShapeshiftForms()
			local texture, name, isActive, isCastable
			local button, icon, cooldown
			local start, duration, enable
			for i = 1, NUM_SHAPESHIFT_SLOTS do
				button = _G["ShapeshiftButton"..i]
				icon = _G["ShapeshiftButton"..i.."Icon"]
				if (i <= numForms) then
					texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
					icon:SetTexture(texture)
					
					cooldown = _G["ShapeshiftButton"..i.."Cooldown"]
					if (texture) then
						cooldown:SetAlpha(1)
					else
						cooldown:SetAlpha(0)
					end
					
					start, duration, enable = GetShapeshiftFormCooldown(i)
					CooldownFrame_SetTimer(cooldown, start, duration, enable)
					
					if (isActive) then
						ShapeshiftBarFrame.lastSelected = button:GetID()
						button:SetChecked(1)
					else
						button:SetChecked(0)
					end

					if (isCastable) then
						icon:SetVertexColor(1.0, 1.0, 1.0)
					else
						icon:SetVertexColor(0.4, 0.4, 0.4)
					end
				end
			end
		end
		
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
		self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		self:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
		
		RegisterStateDriver(self, "visibility", shiftClass[playerClass] and "[novehicleui] show; hide" or "hide")
	end
	
	local setUpPetBar = function(self)
		self.UpdatePetBar = function(self, event)
			local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
			for i=1, NUM_PET_ACTION_SLOTS, 1 do
				local buttonName = "PetActionButton" .. i
				petActionButton = _G[buttonName]
				petActionIcon = _G[buttonName.."Icon"]
				petAutoCastableTexture = _G[buttonName.."AutoCastable"]
				petAutoCastShine = _G[buttonName.."Shine"]
				local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
				
				if (not isToken) then
					petActionIcon:SetTexture(texture)
					petActionButton.tooltipName = name
				else
					petActionIcon:SetTexture(_G[texture])
					petActionButton.tooltipName = _G[name]
				end
				
				petActionButton.isToken = isToken
				petActionButton.tooltipSubtext = subtext

				if (isActive) and (name ~= "PET_ACTION_FOLLOW") then
					petActionButton:SetChecked(1)
					if (IsPetAttackAction(i)) then
						PetActionButton_StartFlash(petActionButton)
					end
				else
					petActionButton:SetChecked(0)
					if (IsPetAttackAction(i)) then
						PetActionButton_StopFlash(petActionButton)
					end			
				end
				
				if (autoCastAllowed) then
					petAutoCastableTexture:Show()
				else
					petAutoCastableTexture:Hide()
				end
				
				if (autoCastEnabled) then
					AutoCastShine_AutoCastStart(petAutoCastShine)
				else
					AutoCastShine_AutoCastStop(petAutoCastShine)
				end
				
				if (name) then
					petActionButton:SetAlpha(1)
				else
					petActionButton:SetAlpha(0)
				end

				if (texture) then
					if GetPetActionSlotUsable(i) then
						SetDesaturation(petActionIcon, nil)
					else
						SetDesaturation(petActionIcon, 1)
					end
					petActionIcon:Show()
				else
					petActionIcon:Hide()
				end
				
				if (not PetHasActionBar()) and (texture) and (name ~= "PET_ACTION_FOLLOW") then
					PetActionButton_StopFlash(petActionButton)
					SetDesaturation(petActionIcon, 1)
					petActionButton:SetChecked(0)
				end
			end
		end
		
		PetActionBarFrame.showgrid = 1

		self:RegisterEvent("PLAYER_CONTROL_LOST")
		self:RegisterEvent("PLAYER_CONTROL_GAINED")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
		self:RegisterEvent("PET_BAR_UPDATE")
		self:RegisterEvent("PET_BAR_UPDATE_USABLE")
		self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
		self:RegisterEvent("PET_BAR_HIDE")
		self:RegisterEvent("PET_UI_UPDATE")
		self:RegisterEvent("UNIT_PET")
		self:RegisterEvent("UNIT_FLAGS")
		self:RegisterEvent("UNIT_AURA")
		
		RegisterStateDriver(self, "visibility", "[pet,novehicleui,nobonusbar:5] show; hide")
		hooksecurefunc("PetActionBar_Update", self.UpdatePetBar)
		
	end

	local setUp = function(self)
		if (self.started) then 
			return 
		else
			self.started = true
		end

		if (self:GetAttribute("type") == "totem") and (playerClass == "SHAMAN") then
			setUpTotemBar(self)
		end

		if (self:GetAttribute("type") == "shift") and (shiftClass[playerClass]) then
			setUpShiftBar(self)
		end
		
		if (self:GetAttribute("type") == "pet") then
			setUpPetBar(self)
		end
		
		if (barTypes[self:GetAttribute("type")] == "page") then
			setUpStateBar(self)
		end

		self:Arrange()
	end
	
	self:SetScript("OnEvent", function(self, event, ...)
		local arg1 = ...
		if (event == "PLAYER_LOGIN") then
			setUp(self)
			self:UnregisterEvent("PLAYER_LOGIN")
			
		elseif (event == "PLAYER_ENTERING_WORLD") then
			local button
			for i = 1, #self.buttons do
				button = _G[self.buttons[i]]
				button:SetParent(self)
				self:SetAttribute("addchild", button)
				
				if (self:GetAttribute("type") == "pet") then
					if not(InCombatLockdown()) then 
						button:Show()
					end
				end
			end
			
		elseif (event == "UPDATE_SHAPESHIFT_FORMS") then
			if (InCombatLockdown()) then 
				return 
			end
			
			self:UpdateShiftButtons()
			self:UpdateShiftBar()
			
		elseif (event == "UPDATE_SHAPESHIFT_USABLE") 
			or (event == "UPDATE_SHAPESHIFT_COOLDOWN")
			or (event == "UPDATE_SHAPESHIFT_FORM")
			or (event == "ACTIONBAR_PAGE_CHANGED") then
			
			self:UpdateShiftBar()
		
		elseif (event == "PET_BAR_UPDATE") 
			or (event == "PET_UI_UPDATE") 
			or (event == "PLAYER_CONTROL_GAINED") 
			or (event == "PLAYER_CONTROL_LOST") 
			or (event == "PLAYER_FARSIGHT_FOCUS_CHANGED") 
			or (event == "UNIT_FLAGS")
			or ((event == "UNIT_PET") and (arg1 == "player")) 
			or ((event == "UNIT_AURA") and (arg1 == "pet")) then
			
			self:UpdatePetBar()
			
		elseif (event == "PET_BAR_UPDATE_COOLDOWN") then
			PetActionBar_UpdateCooldowns()

		elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
			if not(IsAddOnLoaded("Blizzard_GlyphUI")) then
				LoadAddOn("Blizzard_GlyphUI")
			end
			
		else
			if (self:GetAttribute("type") == "primary") then
				MainMenuBar_OnEvent(self, event, ...) 
			end
		end
	end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	if (IsLoggedIn()) then
		setUp(self)
	else
		self:RegisterEvent("PLAYER_LOGIN")
	end
	
	if (self:GetAttribute("type") == "primary") then
		self:RegisterEvent("BAG_UPDATE")
		self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
		self:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	end
end

--
-- @param name <string or number> unique identifier (not global)
-- @param type <string> actionbar type (see barTypes table)
-- @param ... pairs of values fed to :SetAttribute(attribute, value)
-- @return <table> pointer to the new actionbar
local bars = 0
gActionBars.New = function(self, name, type, ...)
	if (not type) or (not barTypes[type]) or ((type == "totem") and (playerClass ~= "SHAMAN")) then 
		return 
	end

--	self:DisableBlizzard(type)
	
	if (not self.Initialized) then
		self:Init()
	end
	
	bars = bars + 1
--	local bar = New(("GUIS_ActionBar_%d_%s"):format(bars + 1, name or ""))
	local bar = New(("GUIS_ActionBar_%s"):format(name or "Auto"..(bars)))
	
	bar:SetAttribute("barname", name)
	bar:SetAttribute("type", type)
	bar:SetAttribute("growth-x", "right")
	bar:SetAttribute("growth-y", "down")
	bar:SetAttribute("gap", 2)
	bar:SetAttribute("width", (type == "shift") and NUM_SHAPESHIFT_SLOTS or (type == "pet") and NUM_PET_ACTION_SLOTS or (type == "totem") and (MAX_TOTEMS + 2) or NUM_ACTIONBAR_BUTTONS)
	bar:SetAttribute("height", 1)
	bar:SetAttribute("movable", nil)
	
	bar:SetID(BarToID[type])
	
	local buttons
	for i = 1, select("#", ...), 2 do
		local attribute, value = select(i, ...)
		if not(attribute) then break end
		
		if (attribute == "buttons") then
			buttons = value
			
		elseif (attribute == "visible") then
			if GetBoolean(value) then
--				bar:Show()
				bar:GetParent():Show()
			else
--				bar:Hide()
				bar:GetParent():Hide()
			end
		elseif (attribute == "novehicleui") then
			
		end

		bar:SetAttribute(attribute, value)
	end
	
	bar.buttons = {}
	bar:SetButtons(strsplit(",", buttons or ""))
	bar:Start()

	gActionBars.BARS[name] = bar
	
	return bar
end

--
-- @param name <string or number> unique identifier for your bar
-- @return <table> pointer to an actionbar, or nil
gActionBars.GetBar = function(self, name)
	return gActionBars.BARS[name]
end

gActionBars.GetVisibilityBar = function(self, name)
	return gActionBars.BARS[name]:GetParent()
end

--
-- @return <table> table containing all created bars
gActionBars.GetAllBars = function(self)
	return gActionBars.BARS
end

-- no validation check here, so use with extreme caution
gActionBars.SetClassConditionals = function(self, class, conditions)
	ClassConditionals[class] = conditions
end

--
-- disable the blizzard actionbars
local _GONE = CreateFrame("Frame"); _GONE:Hide()
gActionBars.DisableBlizzard = function(self)

	-- sometimes the main bar keybinds will break after a talent change, 
	-- this is an attempt to remedy that situation
	local fixKeybinds = function() 
		if (PlayerTalentFrame) then
			PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end
	end
	fixKeybinds()
	
	hooksecurefunc("TalentFrame_LoadUI", fixKeybinds)

	-- can we do this...?
--	ExhaustionTick_OnEvent = noop

	MainMenuBar:UnregisterAllEvents()
	MainMenuBar:SetParent(_GONE)
	MainMenuBar:SetScale(1/1e3)
	MainMenuBar:EnableMouse(false)
	
	MainMenuBarArtFrame:UnregisterAllEvents()
	MainMenuBarArtFrame:SetParent(_GONE)
	MainMenuBarArtFrame:Hide()

	MultiBarBottomLeft:SetParent(_GONE)
	MultiBarBottomLeft:Hide()

	MultiBarBottomRight:SetParent(_GONE)
	MultiBarBottomRight:Hide()

	MultiBarLeft:SetParent(_GONE)
	MultiBarLeft:Hide()

	MultiBarRight:SetParent(_GONE)
	MultiBarRight:Hide()
		
	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(_GONE)
	PetActionBarFrame:EnableMouse(false)
		
	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(_GONE)
	PossessBarFrame:EnableMouse(false)

	-- we don't disable events or anything here,
	-- since we're using the actual bar later on
	if (MultiCastActionBarFrame) then
		MultiCastActionBarFrame:Hide()
		MultiCastActionBarFrame:SetParent(_GONE)
	end

	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ShapeshiftBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarLeft"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MULTICASTACTIONBAR_YPOS"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ChatFrame1"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ChatFrame2"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ExtraActionBarFrame"] = nil

	-- MoP beta edits
	if (VehicleMenuBar) then
		VehicleMenuBar:UnregisterAllEvents()
		VehicleMenuBar:SetParent(_GONE)
		VehicleMenuBar:SetScale(1/1e3)
		VehicleMenuBar:EnableMouse(false)
	end
	
	if (BonusActionBarFrame) then
		BonusActionBarFrame:UnregisterAllEvents()
		BonusActionBarFrame:SetParent(_GONE)
		BonusActionBarFrame:Hide()
	end

	if (ShapeshiftBarFrame) then
		ShapeshiftBarFrame:UnregisterAllEvents()
		ShapeshiftBarFrame:Hide()
		ShapeshiftBarFrame:SetParent(_GONE)
		ShapeshiftBarFrame:EnableMouse(false)
	end	
end

gActionBars.Init = function(self)
	self.Initialized = true
end
