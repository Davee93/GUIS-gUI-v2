--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ActionBars")

-- Lua API
local pairs, unpack = pairs, unpack
local tonumber = tonumber

-- WoW API
local ActionButton_ShowGrid = ActionButton_ShowGrid
local CreateFrame = CreateFrame
local GetActionBarToggles = GetActionBarToggles
local GetCurrentBindingSet = GetCurrentBindingSet
local GetModifiedClick = GetModifiedClick
local InCombatLockdown = InCombatLockdown
local SaveBindings = SaveBindings
local SetActionBarToggles = SetActionBarToggles
local SetModifiedClick = SetModifiedClick
local UIDropDownMenu_GetSelectedID = UIDropDownMenu_GetSelectedID
local UIDropDownMenu_SetSelectedID = UIDropDownMenu_SetSelectedID

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gAB = LibStub("gActionBars-2.0")
local gFH = LibStub("gFrameHandler-1.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local CreateUIPanel = function(...) return LibStub("gPanel-2.0"):CreateUIPanel(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local FireCallback = function(...) return module:FireCallback(...) end
local GetBinary = GetBinary
local GetBoolean = GetBoolean

local _,playerClass = UnitClass("player")

local panel = {}
local bottomPanel = module:GetName() .. "BottomActionBarPanel"
local leftPanel = module:GetName() .. "LeftActionBarPanel"
local rightPanel = module:GetName() .. "RightActionBarPanel"
local sidePanel = module:GetName() .. "SideActionBarPanel"
local extraPanel = module:GetName() .. "ExtraActionBarPanel"

local createArrow
local fixPanelStrata, postUpdatePanels, updateBottomOffset
local getLayoutList

-- this globabl will be used by anything hooked to the actionbars, 
-- like the player/target unitframes when not user placed
_G.GUIS_UNITFRAME_OFFSET = 0

-- these sizes are chosen for a reason
-- a size of 29 is the default, and aligns perfectly with the unitframes and all 3 bottom bars are visible
-- a size of 46 aligns when only the stacking bars are visible, giving a good look for single bar UIs
local MIN_BUTTON_SIZE, MAX_BUTTON_SIZE = 29, 46

local defaults = {
	layout = 1;
	showbar_shift = 1;
	showbar_pet = 1;
	showbar_totem = 1;
	showbar_5 = 0;
	showbar_4 = 0;
	showbar_3 = 1;
	showbar_2 = 1;
	showbar_micro = 0;
	lockActionBars = 1;
	buttonSize = 29;
}

-- todo:
-- 	* move layouts along with panelinfo back into a separate file, as in v1.0
-- 	* bake whether or not bars can be hidden by the user into the layout
--
-- Important:
--		* Don't use actual frame references in this table, use strings. (e.g. "UIParent", not UIParent)
local layouts = {
	-- default actionbar on the top
	[1] = {
		[1] = { -- default actionbar
			pos = function() return GetBoolean(GUIS_DB["actionbars"].showbar_2 == 1) 
				and { "BOTTOM", "UIParent", "BOTTOM", 0, 12 + GUIS_DB["actionbars"].buttonSize + 2 } -- 43
				or { "BOTTOM", "UIParent", "BOTTOM", 0, 12 } end; 
			attributes = function() return {
				"primary", 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize
			} end;
		};

		[2] = { -- 'bottomleft' bar (under the main bar in our UI)
			pos = function() return { "BOTTOM", "UIParent", "BOTTOM", 0, 12 } end; 
			attributes = function() return {
				"bottomleft", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize,
				"visible", GetBoolean(GUIS_DB["actionbars"].showbar_2)
			} end;
		};

		[31] = {
			pos = function() return { "BOTTOMRIGHT", "UIParent", "BOTTOM", 
				-( (GUIS_DB["actionbars"].buttonSize * NUM_ACTIONBAR_BUTTONS)/2 + (2*(NUM_ACTIONBAR_BUTTONS - 1))/2 + 11), -- 196
				12 
			} end; -- 'bottomright' bar, left part
			attributes = function() return {
				"bottomright", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"width", 3, 
				"height", 2, 
				"buttons", "1,2,3,4,5,6", 
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_3)
			} end;
		};

		[32] = {
			pos = function() return { "BOTTOMLEFT", "UIParent", "BOTTOM", 
				( (GUIS_DB["actionbars"].buttonSize * NUM_ACTIONBAR_BUTTONS)/2 + (2*(NUM_ACTIONBAR_BUTTONS - 1))/2 + 11), -- 196
				12 
			} end; -- 'bottomright' bar, right part
			attributes = function() return {
				"bottomright", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"width", 3, 
				"height", 2, 
				"buttons", "7,8,9,10,11,12",
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_3)
			} end;
		};

		[4] = {
			pos = function() return { "RIGHT", "UIParent", "RIGHT", -12, 0 } end; -- right sidebar
			attributes = function() return {
				"right", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"width", 1, 
				"height", NUM_ACTIONBAR_BUTTONS,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_4)
			} end;
		};

		[5] = {
			pos = function() return { "RIGHT", "UIParent", "RIGHT", -(12 + GUIS_DB["actionbars"].buttonSize + 2), 0 } end; -- left sidebar
			attributes = function() return {
				"left", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"width", 1, 
				"height", NUM_ACTIONBAR_BUTTONS,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_5) and GetBoolean(GUIS_DB.actionbars.showbar_4)
			} end;
		};

		["pet"] = {
			pos = function() return { "BOTTOM", "UIParent", "BOTTOM", 0, 260 } end; -- pet bar
			attributes = function() return {
				"pet", 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"movable", true,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_pet)
			} end;
		};

		["shift"] = {
			pos = function() return { "TOPLEFT", "UIParent", "TOPLEFT", 180, -8 } end; -- shapeshift/stance/aspect bar
			attributes = function() return {
				"shift", 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"movable", true,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_shift)
			} end;
		};

		-- sizes and gaps are ignored here, the library just repositions the default bar
		["totem"] = {
			pos = function() return { "BOTTOM", "UIParent", "BOTTOM", 0, 240 } end; -- totem bar
			attributes = function() return {
				"totem", 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"movable", true,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_totem)
			} end;
		};

		["extra"] = {
			pos = function() return { "CENTER", "UIParent", "CENTER", 0, 0 } end; -- extra action bar
			attributes = function() return {
				"novehicleui", true, 
			} end;
		};
	};
	
	[2] = {
		[1] = {
			pos = function() return { "BOTTOM", "UIParent", "BOTTOM", 0, 12 } end; -- default actionbar
			attributes = function() return {
				"primary", 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize
			} end;
		};

		[2] = {
			pos = function() return { "BOTTOM", "UIParent", "BOTTOM", 0, (12 + GUIS_DB["actionbars"].buttonSize + 2) } end; -- 'bottomleft' bar (under the main bar in our UI)
			attributes = function() return {
				"bottomleft", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize,
				"visible", GetBoolean(GUIS_DB["actionbars"].showbar_2)
			} end;
		};

		[31] = {
			pos = function() return { "BOTTOMRIGHT", "UIParent", "BOTTOM", 
				-( (GUIS_DB["actionbars"].buttonSize * NUM_ACTIONBAR_BUTTONS)/2 + (2*(NUM_ACTIONBAR_BUTTONS - 1))/2 + 11), -- 196
				12 
			} end; -- 'bottomright' bar, left part
			attributes = function() return {
				"bottomright", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"width", 3, 
				"height", 2, 
				"buttons", "1,2,3,4,5,6", 
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_3)
			} end;
		};

		[32] = {
			pos = function() return { "BOTTOMLEFT", "UIParent", "BOTTOM", 
				( (GUIS_DB["actionbars"].buttonSize * NUM_ACTIONBAR_BUTTONS)/2 + (2*(NUM_ACTIONBAR_BUTTONS - 1))/2 + 11), -- 196
				12 
			} end; -- 'bottomright' bar, right part
			attributes = function() return {
				"bottomright", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"width", 3, 
				"height", 2, 
				"buttons", "7,8,9,10,11,12",
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_3)
			} end;
		};

		[4] = {
			pos = function() return { "RIGHT", "UIParent", "RIGHT", -12, 0 } end; -- right sidebar
			attributes = function() return {
				"right", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"width", 1, 
				"height", NUM_ACTIONBAR_BUTTONS,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_4)
			} end;
		};

		[5] = {
			pos = function() return { "RIGHT", "UIParent", "RIGHT", -(12 + GUIS_DB["actionbars"].buttonSize + 2), 0 } end; -- left sidebar
			attributes = function() return {
				"left", 
				"novehicleui", true, 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"width", 1, 
				"height", NUM_ACTIONBAR_BUTTONS,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_5) and GetBoolean(GUIS_DB.actionbars.showbar_4)
			} end;
		};

		["pet"] = {
			pos = function() return { "BOTTOM", "UIParent", "BOTTOM", 0, 260 } end; -- pet bar
			attributes = function() return {
				"pet", 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"movable", true,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_pet)
			} end;
		};

		["shift"] = {
			pos = function() return { "TOPLEFT", "UIParent", "TOPLEFT", 180, -8 } end; -- shapeshift/stance/aspect bar
			attributes = function() return {
				"shift", 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"movable", true,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_shift)
			} end;
		};

		-- sizes and gaps are ignored here, the library just repositions the default bar
		["totem"] = {
			pos = function() return { "BOTTOM", "UIParent", "BOTTOM", 0, 240 } end; -- totem bar
			attributes = function() return {
				"totem", 
				"gap", 2,
				"buttonsize", GUIS_DB.actionbars.buttonSize, 
				"movable", true,
				"visible", GetBoolean(GUIS_DB.actionbars.showbar_totem)
			} end;
		};

		["extra"] = {
			pos = function() return { "CENTER", "UIParent", "CENTER", 0, 0 } end; -- extra action bar
			attributes = function() return {
				"novehicleui", true, 
			} end;
		};
	};	
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
				msg = L["ActionBars are banks of hotkeys that allow you to quickly access abilities and inventory items. Here you can activate additional ActionBars and control their behaviors."];
			};
			
			{
				type = "group";
				order = 10;
				name = "blizzard";
				virtual = true;
				children = {
					{ -- blizzard: secure ability toggle
						type = "widget";
						element = "CheckButton";
						name = "secureAbilityToggle";
						order = 10;
						width = "full"; 
						msg = L["Secure Ability Toggle"];
						desc = L["When selected you will be protected from toggling your abilities off if accidently hitting the button more than once in a short period of time."];
						set = function(self) 
							SetCVar("secureAbilityToggle", (tonumber(GetCVar("secureAbilityToggle")) == 1) and 0 or 1)
						end;
						get = function() return tonumber(GetCVar("secureAbilityToggle")) == 1 end;
					};
					{ -- blizzard: lock actionbars
						type = "widget";
						element = "CheckButton";
						name = "lockActionBars";
						order = 20;
						width = "full"; 
						msg = L["Lock ActionBars"];
						desc = L["Prevents the user from picking up/dragging spells on the action bar. This function can be bound to a function key in the keybindings interface."];
						set = function(self) 
							GUIS_DB.actionbars.lockActionBars = GetBinary(not(GetBoolean(GUIS_DB.actionbars.lockActionBars)))
							self:onrefresh()
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.lockActionBars) end;
						onrefresh = function(self) 
--							if GetBoolean(GUIS_DB.actionbars.lockActionBars) and (tonumber(LOCK_ACTIONBAR) ~= 1) then
--								GUIS_DB.actionbars.lockActionBars = 0
--								self:SetChecked(self:get())
--								module:UpdateActionBarLock()
--							end

	--						if not(GetBoolean(GUIS_DB.actionbars.lockActionBars)) and (tonumber(LOCK_ACTIONBAR) == 1) then
	--							GUIS_DB.actionbars.lockActionBars = 1
	--							self:SetChecked(self:get())
	--							module:UpdateActionBarLock()
	--						end
						
							module:UpdateActionBarLock()
	
							if GetBoolean(GUIS_DB.actionbars.lockActionBars) then
								self.parent.child.pickupKey:Enable()
							else
								self.parent.child.pickupKey:Disable()
							end
						end;
						onshow = function(self) self:onrefresh() end;
						init = function(self) self:onrefresh() end;
					};
					{ -- blizzard: pick up key
						type = "widget";
						element = "Dropdown";
						name = "pickupKey";
						order = 30;
						width = "full";
						msg = L["Pick Up Action Key"];
						desc = {
							"|cFFFFFFFF" .. L["ALT key"] .. "|r";
							"|cFFFFD100" .. L["Use the \"ALT\" key to pick up/drag spells from locked actionbars."] .. "|r";
							" ";
							"|cFFFFFFFF" .. L["CTRL key"] .. "|r";
							"|cFFFFD100" .. L["Use the \"CTRL\" key to pick up/drag spells from locked actionbars."] .. "|r";
							" ";
							"|cFFFFFFFF" .. L["SHIFT key"] .. "|r";
							"|cFFFFD100" .. L["Use the \"SHIFT\" key to pick up/drag spells from locked actionbars."] .. "|r";
							" ";
							"|cFFFFFFFF" .. L["None"] .. "|r";
							"|cFFFFD100" .. L["No key set."] .. "|r";
						};
						args = { L["ALT key"], L["CTRL key"], L["SHIFT key"], L["None"] };
						set = function(self, option)
							local value
							local option = option or UIDropDownMenu_GetSelectedID(self)
							if (option == 1) then
								value = "ALT"
							elseif (option == 2) then
								value = "CTRL"
							elseif (option == 3) then
								value = "SHIFT"
							else
								value = "NONE"
							end
							
							SetModifiedClick("PICKUPACTION", value)
							SaveBindings(GetCurrentBindingSet())
						end;
						get = function(self) 
							local value = GetModifiedClick("PICKUPACTION")
							return (value == "ALT") and 1 or (value == "CTRL") and 2 or (value == "SHIFT") and 3 or 4
						end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};				};
			};
			{
				type = "group";
				order = 15;
				name = "buttonsize";
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 10;
						width = "full";
						msg = L["Button Size"];
					};
					{
						type = "widget";
						element = "Text";
						order = 11;
						width = "full";
						msg = L["Choose the size of the buttons in your ActionBars"];
					};
					{ -- button size
						type = "widget";
						element = "Slider";
						name = "buttonSize";
						order = 50;
						width = "full";
						msg = nil;
						desc = L["Sets the size of the buttons in your ActionBars. Does not apply to the TotemBar."];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB.actionbars.buttonSize = value
								
								module:UpdateAll()
							end
						end;
						get = function(self)
							return GUIS_DB.actionbars.buttonSize
						end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_BUTTON_SIZE, MAX_BUTTON_SIZE, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
				};
			};
			{
				type = "group";
				order = 20;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 10;
						width = "half";
						msg = L["Visible ActionBars"];
					};
					{
						type = "widget";
						element = "Header";
						order = 11;
						width = "half";
						msg = L["ActionBar Layout"];
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showStanceBar";
						order = 105;
						width = "half"; 
						msg = L["Show the Shapeshift/Stance/Aspect Bar"];
						desc = nil;
						set = function(self) 
							GUIS_DB.actionbars.showbar_shift = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_shift)))
							module:Toggle("shift", GetBoolean(GUIS_DB.actionbars.showbar_shift))
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.showbar_shift) end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "setMainBarPosition";
						order = 106;
						width = "half"; 
						msg = L["Sort ActionBars from top to bottom"];
						desc = { L["This displays the main ActionBar on top, and is the default behavior of the UI. Disable to display the main ActionBar at the bottom."] , " ", F.warning(L["Requires the UI to be reloaded!"]) };
						set = function(self) 
							if (GUIS_DB.actionbars.layout == 1) then
								GUIS_DB.actionbars.layout = 2
							else
								GUIS_DB.actionbars.layout = 1
							end
							
							-- let's do a copout and require a reload here. much easier.
							F.ScheduleRestart()
						end;
						get = function() return (GUIS_DB.actionbars.layout == 1) end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showPetBar";
						order = 110;
						width = "full"; 
						msg = L["Show the Pet ActionBar"];
						desc = nil;
						set = function(self) 
							GUIS_DB.actionbars.showbar_pet = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_pet)))

							module:Toggle("pet", GetBoolean(GUIS_DB.actionbars.showbar_pet))
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.showbar_pet) end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showTotemBar";
						order = 115;
						width = "full"; -- indented = true;
						msg = L["Show the Totem Bar"];
						desc = nil;
						set = function(self) 
							GUIS_DB.actionbars.showbar_totem = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_totem)))

							module:Toggle("totem", GetBoolean(GUIS_DB.actionbars.showbar_totem))
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.showbar_totem) end;
						init = function(self) 
							if (playerClass ~= "SHAMAN") then
								self:Disable()
							end
						end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showSecondBar";
						order = 150;
						width = "full"; 
						msg = L["Show the secondary ActionBar"];
						desc = nil;
						set = function(self) 
							GUIS_DB.actionbars.showbar_2 = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_2)))
							module:Toggle(2, GetBoolean(GUIS_DB.actionbars.showbar_2))
							self:onrefresh()
						end;
						onrefresh = function(self) 
							if (GetBoolean(GUIS_DB.actionbars.showbar_2)) then
								if not(self.parent.child.showThirdBar:IsEnabled()) then
									self.parent.child.showThirdBar:Enable()
								end
							else
								if (self.parent.child.showThirdBar:IsEnabled()) then
									self.parent.child.showThirdBar:Disable()
								end
							end
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.showbar_2) end;
						init = function(self) 
							if (GetBoolean(GUIS_DB.actionbars.showbar_3)) then
								self:Disable()
							end
						end;
					};
					-- we only need a button for the first half of the third bar, as they are connected
					{
						type = "widget";
						element = "CheckButton";
						name = "showThirdBar";
						order = 155;
						width = "full"; 
						msg = L["Show the third ActionBar"];
						desc = nil;
						set = function(self) 
							GUIS_DB.actionbars.showbar_3 = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_3)))
							module:Toggle(31, GetBoolean(GUIS_DB.actionbars.showbar_3))
							self:onrefresh()
						end;
						onrefresh = function(self) 
							if not(GetBoolean(GUIS_DB.actionbars.showbar_3)) then
								if not(self.parent.child.showSecondBar:IsEnabled()) then
									self.parent.child.showSecondBar:Enable()
								end
							else
								if (self.parent.child.showSecondBar:IsEnabled()) then
									self.parent.child.showSecondBar:Disable()
								end
							end
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.showbar_3) end;
						init = function(self) 
							if not(GetBoolean(GUIS_DB.actionbars.showbar_2)) then
								self:Disable()
							end
						end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showRightBar";
						order = 160;
						width = "full";
						msg = L["Show the rightmost side ActionBar"];
						desc = nil;
						set = function(self) 
							GUIS_DB.actionbars.showbar_4 = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_4)))
							module:Toggle(4, GetBoolean(GUIS_DB.actionbars.showbar_4))
							module:Toggle(5, GetBoolean(GUIS_DB.actionbars.showbar_5) and GetBoolean(GUIS_DB.actionbars.showbar_4)) 
							self:onrefresh()
						end;
						onrefresh = function(self) 
							if (GetBoolean(GUIS_DB.actionbars.showbar_4)) then
								if not(self.parent.child.showLeftBar:IsEnabled()) then
									self.parent.child.showLeftBar:Enable()
								end
							else
								if (self.parent.child.showLeftBar:IsEnabled()) then
									self.parent.child.showLeftBar:Disable()
								end
							end
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.showbar_4) end;
						init = function(self) self:onrefresh() end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showLeftBar";
						order = 165;
						width = "full"; indented = true;
						msg = L["Show the leftmost side ActionBar"];
						desc = nil;
						set = function(self) 
							GUIS_DB.actionbars.showbar_5 = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_5)))
							module:Toggle(5, GetBoolean(GUIS_DB.actionbars.showbar_5) and GetBoolean(GUIS_DB.actionbars.showbar_4)) 
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.showbar_5) end;
						init = function(self) 
							if not(GetBoolean(GUIS_DB.actionbars.showbar_4)) then
								self:Disable()
							end
						end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showMicroMenu";
						order = 1000;
						width = "full"; 
						msg = L["Show the Micro Menu"];
						desc = nil;
						set = function(self) 
							GUIS_DB.actionbars.showbar_micro = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_micro)))
							local micro = LibStub("gCore-3.0"):GetModule("GUIS-gUI: ActionBarsMicroMenu")
							if (micro) then
								if not(GetBoolean(GUIS_DB.actionbars.showbar_micro)) then
									if (micro.MicroMenu:IsShown()) then
										micro.MicroMenu:Hide()
									end
								else
									if not(micro.MicroMenu:IsShown()) then
										micro.MicroMenu:Show()
									end
								end
							end
						end;
						get = function() return GetBoolean(GUIS_DB.actionbars.showbar_micro) end;
					};
				};
			};
		};
	};
}

local faq = {
	{
		q = L["How do I change the currently active Action Page?"];
		a = {
			{ 
				type = "text";  
				msg = L["There are no on-screen buttons to do this, so you will have to use keybinds. You can set the relevant keybinds in the Blizzard keybinding interface."];
			};
		};
		tags = { "actionbars", "actionpage" };
	};
	{
		q = L["How do I toggle the MiniMenu?"];
		a = {
			{ 
				type = "text";  
				msg = L["The MiniMenu can be displayed by typing |cFF4488FF/showmini|r followed by the Enter key, and |cFF4488FF/hidemini|r to hide it. You can also toggle it from the options menu or by running the install tutorial by typing |cFF4488FF/install|r."];
			};
		};
		tags = { "actionbars", "minimenu" };
	};
	{
		q = L["How can I change the visible actionbars?"];
		a = {
			{ 
				type = "text";  
				msg = L["You can toggle most actionbars by clicking the arrows located close to their corners. These arrows become visible when hovering over them with the mouse if you're not currently engaged in combat. You can also toggle the actionbars from the options menu, or by running the install tutorial by typing |cFF4488FF/install|r followed by the Enter key."];
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
			{
				type = "image";
				w = 128; h = 256;
				path = M["Texture"]["Actionbars-SideArrow"]
			};
		};
		tags = { "actionbars" };
	};
	{
		q = L["How can I move the actionbars?"];
		a = {
			{ 
				type = "text";  
				msg = L["Not all actionbars can be moved, as some are an integrated part of the UI layout. Most of the movable frames in the UI can be unlocked by typing |cFF4488FF/glock|r followed by the Enter key."];
			};
			{
				type = "image";
				w = 512; h = 256;
				path = M["Texture"]["Core-FrameLock"]
			};
		};
		tags = { "actionbars", "positioning" };
	};
}

getLayoutList = function()
	local t = {}
	for i, v in pairs(layouts) do
		tinsert(t, i)
	end
	
	sort(t)
	
	local r 
	for i, v in ipairs(t) do
		if (r) then
			r = r .. ", " .. tostring(v)
		else
			r = tostring(v)
		end
	end
	
	t = nil
	
	return r or ""
end

createArrow = function(object, optionKey, barName, show, arrowTexture, extraTargetList, dependencyList)
	local target = gAB:GetVisibilityBar(barName)

	object:SetFrameStrata("MEDIUM")
	object:SetFrameLevel(50)
	object:SetAlpha(0)
	object:SetSize(24, 24)
	object:SetUITemplate("simpleblackbackdrop")
	
	object.arrow = object:CreateTexture(nil, "OVERLAY")
	object.arrow:SetPoint("TOPLEFT", 3, -3)
	object.arrow:SetPoint("BOTTOMRIGHT", -3, 3)
	object.arrow:SetTexture(arrowTexture)
	
	F.GlossAndShade(object, object.arrow)
	
	-- if this is an expandarrow, we need additional visibility checks
	if (show) then
		target:HookScript("OnShow", function() 
			object:Hide()
		end)

		target:HookScript("OnHide", function() 
			object:Show()
		end)
		
		if (target:IsShown()) then
			object:Hide()
		end
	end

	-- extra target to look out for
	if (extraTargetList) then
		object.extraTargetList = extraTargetList
		object.isExtraTargetVisible = function(self)
			for _,extraTarget in pairs(extraTargetList) do
				if (extraTarget:IsShown()) then
					return true
				end
			end
		end
	end

	if (dependencyList) then
		object.dependencyList = dependencyList
		object.isDependencyVisible = function(self)
			for _,dependency in pairs(dependencyList) do
				if (dependency:IsShown()) then
					return true
				end
			end
		end
	end
	
	if (extraTargetList) then
		for _,extraTarget in pairs(extraTargetList) do
			extraTarget:HookScript("OnShow", function() 
				object:Hide()
			end)

			extraTarget:HookScript("OnHide", function() 
				if (dependencyList) then
					if (object:isDependencyVisible()) then
						object:Show()
					end
				else
					object:Show()
				end
			end)
			
			if (extraTarget:IsShown()) then
				object:Hide()
			end
		end
	end
	
	if (dependencyList) then
		for _,dependency in pairs(dependencyList) do
			dependency:HookScript("OnHide", function() 
				object:Hide()
			end)
		
			dependency:HookScript("OnShow", function() 
				if (extraTargetList) then
					if not(object:isExtraTargetVisible()) and not(target:IsShown()) and not(object:IsShown()) then
						object:Show()
					end
				else
					if not(target:IsShown()) and not(object:IsShown()) then
						object:Show()
					end
				end
			end)

			if not(dependency:IsShown()) then
				object:Hide()
			end
		end
	end

	object:SetScript("OnEnter", function(self) 
		if (InCombatLockdown()) 
		or ((show) and (target:IsShown())) 
		or ((object.extraTargetList) and (object:isExtraTargetVisible()))
		or ((object.dependencyList) and not(object:isDependencyVisible())) then
			return
		end
		
		self:SetAlpha(1)
		self:SetBackdropBorderColor(C["hoverbordercolor"][1], C["hoverbordercolor"][2], C["hoverbordercolor"][3])

		--[[
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", -4, 4)

		if (show) then
			GameTooltip:AddLine(L["<Left-Click> to show additional ActionBars"])
		else
			GameTooltip:AddLine(L["<Left-Click> to hide this ActionBar"])
		end
		
		GameTooltip:Show()
		]]--
	end)

	object:SetScript("OnLeave", function(self)
		self:SetAlpha(0)
		self:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3])
		
--		GameTooltip:Hide()
	end)
	
	object:SetScript("OnMouseUp", function(self, button)
		if (InCombatLockdown()) or (self:GetAlpha() == 0) then
			return
		end
		
		if (button == "LeftButton") then
			GUIS_DB["actionbars"][optionKey] = show and 1 or 0
			module:Toggle(barName, show) 
		end
	end)
	
	-- just in case
	RegisterCallback("PLAYER_REGEN_DISABLED", function() 
		object:SetAlpha(0)
		object:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3])
	end)
	
	return object
end

--
-- Pre-hooking the SetFrameStrata function to make sure they stay in place
fixPanelStrata = function()
	for _,p in pairs(panel) do
		if not(p.BlizzSetFrameStrata) then
			p.BlizzSetFrameStrata = p.SetFrameStrata
			p.SetFrameStrata = function(self, strata) 
				self:BlizzSetFrameStrata("LOW")
			end

			p:SetFrameStrata()
		end
	end
end

-- this function is called before the following custom events;
-- GUIS_ACTIONBAR_VISIBILITY_UPDATE, GUIS_ACTIONBAR_POSITION_UPDATE, GUIS_ACTIONBAR_BUTTON_UPDATE
-- meaning that the global variable 'GUIS_UNITFRAME_OFFSET' can always be considered 'correct'
-- after that specific event
updateBottomOffset = function()
	local buttonSize = GUIS_DB["actionbars"].buttonSize
	local padding = 28 -- should have been more exact here
	if (GUIS_DB["actionbars"].layout == 1) or (GUIS_DB["actionbars"].layout == 2) then
		if (GUIS_DB["actionbars"].showbar_2 == 1) then
			GUIS_UNITFRAME_OFFSET = (padding + buttonSize*2)
			
		else
			GUIS_UNITFRAME_OFFSET = (padding + buttonSize*2) - (buttonSize - 2) - 4
		end
		
	elseif (GUIS_DB["actionbars"].layout == 3) then
		if (GUIS_DB["actionbars"].showbar_3 == 1) then
			GUIS_UNITFRAME_OFFSET = (padding + buttonSize*2) + (buttonSize - 2) + 4
			
		elseif (GUIS_DB["actionbars"].showbar_2 == 1) then
			GUIS_UNITFRAME_OFFSET = (padding + buttonSize*2)
			
		else
			GUIS_UNITFRAME_OFFSET = (padding + buttonSize*2) - (buttonSize - 2) - 4
		end
	end
end

--
-- Adjust panels and positions upon visibility changes
postUpdatePanels = function(self, event, barName, show)
	if (GUIS_DB["actionbars"].layout == 1) or (GUIS_DB["actionbars"].layout == 2) then
		-- side panel
		if not(barName) or ((barName) and ((barName == 4) or (barName == 5))) then
			if (MultiBarLeftButton1:IsVisible()) then
				panel[sidePanel]:SetPoint("TOPLEFT", MultiBarLeftButton1, "TOPLEFT", -4, 4)
			else
				panel[sidePanel]:SetPoint("TOPLEFT", MultiBarRightButton1, "TOPLEFT", -4, 4)
			end
		end
		
		-- bottom panel
		if not(barName) or ((barName) and (barName == 2)) then
			if (MultiBarBottomLeftButton1:IsVisible()) then
				-- adjust the position of bar 1 if bar 2 became visible
				if (event ~= "GUIS_ACTIONBAR_PANEL_UPDATE") then
					if (GUIS_DB["actionbars"].layout == 1) and ((barName) and (barName == 2)) then
						gAB:GetBar(1):ClearAllPoints()
						gAB:GetBar(1):SetPoint(unpack(layouts[GUIS_DB["actionbars"].layout][1].pos()))
					end
				end
			
				-- adjust the panel
				if (GUIS_DB["actionbars"].layout == 1) then
					panel[bottomPanel]:SetPoint("TOPLEFT", ActionButton1, "TOPLEFT", -4, 4)
					panel[bottomPanel]:SetPoint("BOTTOMRIGHT", MultiBarBottomLeftButton12, "BOTTOMRIGHT", 4, -4)
				else
					panel[bottomPanel]:SetPoint("TOPLEFT", MultiBarBottomLeftButton1, "TOPLEFT", -4, 4)
					panel[bottomPanel]:SetPoint("BOTTOMRIGHT", ActionButton12, "BOTTOMRIGHT", 4, -4)
				end
			else
				-- adjust the position of bar 1 if bar 2 was hidden
				if (event ~= "GUIS_ACTIONBAR_PANEL_UPDATE") then
					if (GUIS_DB["actionbars"].layout == 1) and ((barName) and (barName == 2)) then
						gAB:GetBar(1):ClearAllPoints()
						gAB:GetBar(1):SetPoint(unpack(layouts[GUIS_DB["actionbars"].layout][1].pos()))
					end
				end
				
				panel[bottomPanel]:SetPoint("TOPLEFT", ActionButton1, "TOPLEFT", -4, 4)
				panel[bottomPanel]:SetPoint("BOTTOMRIGHT", ActionButton12, "BOTTOMRIGHT", 4, -4)
			end
		end
	end
end

module.Toggle = function(self, bar, status)
	if (InCombatLockdown()) then 
		print(L["Can't toggle Action Bars while engaged in combat!"])
		return
	end
	
	-- we always update the offset variable
	updateBottomOffset()
	
	if (status) then
		if not(gAB:GetVisibilityBar(bar):IsShown()) then
--			gAB:GetBar(bar):Show()
			gAB:GetVisibilityBar(bar):Show()

			FireCallback("GUIS_ACTIONBAR_VISIBILITY_UPDATE", bar, status)
		end
	else
		if (gAB:GetVisibilityBar(bar):IsShown()) then
			gAB:GetVisibilityBar(bar):Hide()
--			gAB:GetBar(bar):Hide()

			FireCallback("GUIS_ACTIONBAR_VISIBILITY_UPDATE", bar, status)
		end
	end
end

module.Reset = function(self)
	-- we can pass the whole actionbar list directly to the reset function, 
	-- as the reset function will ignore anything that isn't previously registered
	gFH:Reset(gAB:GetAllBars())
end

-- function allowing external modules to change the actionbar layout
module.SetActiveStyle = function(self, layout)
	layout = tonumber(layout)
	if not(layout) then
		return
	end
	
	if not(layouts[layout]) then
		print(L["Layout '%s' doesn't exist, valid values are %s."]:format(layout, getLayoutList()))
		return
	end
	
	-- let's do a copout and require a reload here. much easier.
	if (GUIS_DB["actionbars"].layout ~= layout) then
		GUIS_DB["actionbars"].layout = layout
		F.ScheduleRestart()
	end
		
	F.RestartIfScheduled()
end

module.UpdateAll = function(self)
	if (InCombatLockdown()) then
		return
	end
	
	local buttonSize, data, a, b, c, d, e, f, g, h, i, j
	for name,bar in pairs(gAB:GetAllBars()) do
		if (bar) then
			-- compare the saved buttonsize to the actual buttonsize 
			buttonSize = bar:GetAttribute("buttonsize")
			if (buttonSize ~= GUIS_DB.actionbars.buttonSize) then
				bar:SetAttribute("buttonsize", GUIS_DB.actionbars.buttonSize)
				bar:Arrange()
				
				-- update the bottom offset value
				updateBottomOffset()
				
				-- fire a callback telling other modules about it
				FireCallback("GUIS_ACTIONBAR_BUTTON_UPDATE", name, bar)
			end
			
			-- compare the calculated default position to the actual position
			data = layouts[GUIS_DB["actionbars"].layout][name]
			if (data) and (data.pos) then
				a, b, c, d, e = unpack(data.pos())
				f, g, h, i, j = bar:GetPoint()
				
				-- has our default position changed?
				if (a~=f) or (b~=g) or (c~=h) or (d~=i) or (e~=j) then
					if (bar:GetAttribute("movable")) then
						if not(bar:HasMoved()) then
							bar:ClearAllPoints()
							bar:SetPoint(a, b, c, d, e)
						end 
--						bar:PlaceAndSave(a, b, c, d, e)

						-- update default position
						bar:RegisterForSave(a, b, c, d, e)
					else
						bar:ClearAllPoints()
						bar:SetPoint(a, b, c, d, e)
					end

					-- update the bottom offset value
					updateBottomOffset()
					
					-- fire off positional event in case somebody is listening
					FireCallback("GUIS_ACTIONBAR_POSITION_UPDATE", name, bar)
				end
			end
		end
	end
end

module.GetPanel = function(self, bar)
	if (bar == "bottom") then
		return panel[bottomPanel]
		
	elseif (bar == "left") then
		return panel[leftPanel]
		
	elseif (bar == "right") then
		return panel[rightPanel]
		
	elseif (bar == "side") then
		return panel[sidePanel]
		
	elseif (bar == "extra") then
--		return panel[extraPanel]
	
	end
end

module.UpdateActionBarLock = function(self)
	SetCVar("lockActionBars", GUIS_DB.actionbars.lockActionBars)
	LOCK_ACTIONBAR = (GUIS_DB.actionbars.lockActionBars == 1) and "1" or nil
end

do
	local frame
	local parts = 2
	module.Install = function(self, option, index)
		if (option == "frame") then
			if not(frame) then
				frame = {}
			end

			if not(index) or (index == 1) then
				if not(frame[1]) then
					frame[1] = CreateFrame("Frame", nil, UIParent)
					frame[1]:Hide()
					frame[1]:SetSize(600, 128)
					
					local w, h = 85, 22
					local top, left, bottom, right = 3, -3, -3, 3
					
					-- bar 3
					do
						local bar3 = CreateFrame("Button", nil, frame[1], "UIPanelButtonTemplate")
						bar3:SetSize(w, h)
						bar3:SetUITemplate("button", true)
						bar3.highlight = bar3:SetUITemplate("targetborder", nil, top, left, bottom, right)
						bar3:SetText(L["Toggle Bar 3"])
						bar3:SetPoint("TOPRIGHT", frame[1], "TOP", -8, -16)
						bar3:SetScript("OnShow", function(self)
							if (GetBoolean(GUIS_DB.actionbars.showbar_3)) then
								self:GetParent().bar2:Disable()
								self.highlight:Show()
							else
								self:GetParent().bar2:Enable()
								self.highlight:Hide()
							end
						end)
						bar3:SetScript("OnClick", function(self)
							GUIS_DB.actionbars.showbar_3 = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_3)))
							module:Toggle(31, GetBoolean(GUIS_DB.actionbars.showbar_3))
							module:PostUpdateGUI()
							self:GetScript("OnShow")(self)
						end)
						frame[1].bar3 = bar3
					end

					-- bar 2
					do
						local bar2 = CreateFrame("Button", nil, frame[1], "UIPanelButtonTemplate")
						bar2:SetSize(w, h)
						bar2:SetUITemplate("button", true)
						bar2.highlight = bar2:SetUITemplate("targetborder", nil, top, left, bottom, right)
						bar2:SetText(L["Toggle Bar 2"])
						bar2:SetPoint("RIGHT", frame[1].bar3, "LEFT", -16, 0)
						bar2:SetScript("OnShow", function(self)
							if (GetBoolean(GUIS_DB.actionbars.showbar_2)) then
								self:GetParent().bar3:Enable()
								self.highlight:Show()
							else
								self:GetParent().bar3:Disable()
								self.highlight:Hide()
							end
						end)
						bar2:SetScript("OnClick", function(self)
							GUIS_DB.actionbars.showbar_2 = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_2)))
							module:Toggle(2, GetBoolean(GUIS_DB.actionbars.showbar_2))
							module:PostUpdateGUI()
							self:GetScript("OnShow")(self)
						end)
						frame[1].bar2 = bar2
					end

					-- bar 4
					do
						local bar4 = CreateFrame("Button", nil, frame[1], "UIPanelButtonTemplate")
						bar4:SetSize(w, h)
						bar4:SetUITemplate("button", true)
						bar4.highlight = bar4:SetUITemplate("targetborder", nil, top, left, bottom, right)
						bar4:SetText(L["Toggle Bar 4"])
						bar4:SetPoint("LEFT", frame[1].bar3, "RIGHT", 16, 0)
						bar4:SetScript("OnShow", function(self)
							if (GetBoolean(GUIS_DB.actionbars.showbar_4)) then
								self:GetParent().bar5:Enable()
								self.highlight:Show()
							else
								self:GetParent().bar5:Disable()
								self.highlight:Hide()
							end
						end)
						bar4:SetScript("OnClick", function(self)
							GUIS_DB.actionbars.showbar_4 = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_4)))
							module:Toggle(4, GetBoolean(GUIS_DB.actionbars.showbar_4))
							module:PostUpdateGUI()
							self:GetScript("OnShow")(self)
						end)
						frame[1].bar4 = bar4
					end
					
					-- bar 5
					do
						local bar5 = CreateFrame("Button", nil, frame[1], "UIPanelButtonTemplate")
						bar5:SetSize(w, h)
						bar5:SetUITemplate("button", true)
						bar5.highlight = bar5:SetUITemplate("targetborder", nil, top, left, bottom, right)
						bar5:SetText(L["Toggle Bar 5"])
						bar5:SetPoint("LEFT", frame[1].bar4, "RIGHT", 16, 0)
						bar5:SetScript("OnShow", function(self)
							if (GetBoolean(GUIS_DB.actionbars.showbar_5)) then
								self:GetParent().bar4:Disable()
								self.highlight:Show()
							else
								self:GetParent().bar4:Enable()
								self.highlight:Hide()
							end
						end)
						bar5:SetScript("OnClick", function(self)
							GUIS_DB.actionbars.showbar_5 = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_5)))
							module:Toggle(5, GetBoolean(GUIS_DB.actionbars.showbar_5))
							module:PostUpdateGUI()
							self:GetScript("OnShow")(self)
						end)
						frame[1].bar5 = bar5
					end
					
					-- shiftbar
					do
						local shift = CreateFrame("Button", nil, frame[1], "UIPanelButtonTemplate")
						shift:SetSize(w, h)
						shift:SetUITemplate("button", true)
						shift.highlight = shift:SetUITemplate("targetborder", nil, top, left, bottom, right)
						shift:SetText(L["Toggle Shapeshift/Stance/Aspect Bar"])
						shift:SetWidth(shift:GetFontString():GetStringWidth() + 32)
						shift:SetPoint("TOP", frame[1].bar3, "BOTTOMRIGHT", 8, -16)
						shift:SetScript("OnShow", function(self)
							if (GetBoolean(GUIS_DB.actionbars.showbar_shift)) then
								self.highlight:Show()
							else
								self.highlight:Hide()
							end
						end)
						shift:SetScript("OnClick", function(self)
							GUIS_DB.actionbars.showbar_shift = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_shift)))
							module:Toggle("shift", GetBoolean(GUIS_DB.actionbars.showbar_shift))
							module:PostUpdateGUI()
							self:GetScript("OnShow")(self)
						end)
						frame[1].shift = shift
					end
					
					-- petbar
					do
						local pet = CreateFrame("Button", nil, frame[1], "UIPanelButtonTemplate")
						pet:SetSize(w*1.5, h)
						pet:SetUITemplate("button", true)
						pet.highlight = pet:SetUITemplate("targetborder", nil, top, left, bottom, right)
						pet:SetText(L["Toggle Pet Bar"])
						pet:SetPoint("LEFT", frame[1].shift, "RIGHT", 16, 0)
						pet:SetScript("OnShow", function(self)
							if (GetBoolean(GUIS_DB.actionbars.showbar_pet)) then
								self.highlight:Show()
							else
								self.highlight:Hide()
							end
						end)
						pet:SetScript("OnClick", function(self)
							GUIS_DB.actionbars.showbar_pet = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_pet)))
							module:Toggle("pet", GetBoolean(GUIS_DB.actionbars.showbar_pet))
							module:PostUpdateGUI()
							self:GetScript("OnShow")(self)
						end)
						frame[1].pet = pet
					end

					-- totembar
					do
						local totem = CreateFrame("Button", nil, frame[1], "UIPanelButtonTemplate")
						totem:SetSize(w*1.5, h)
						totem:SetUITemplate("button", true)
						totem.highlight = totem:SetUITemplate("targetborder", nil, top, left, bottom, right)
						totem:SetText(L["Toggle Totem Bar"])
						totem:SetPoint("RIGHT", frame[1].shift, "LEFT", -16, 0)
						totem:SetScript("OnShow", function(self)
							if (playerClass ~= "SHAMAN") then
								self:Disable()
								self.highlight:Hide()
							else
								if (GetBoolean(GUIS_DB.actionbars.showbar_totem)) then
									self.highlight:Show()
								else
									self.highlight:Hide()
								end
							end
						end)
						totem:SetScript("OnClick", function(self)
							GUIS_DB.actionbars.showbar_totem = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_totem)))
							module:Toggle("totem", GetBoolean(GUIS_DB.actionbars.showbar_totem))
							module:PostUpdateGUI()
							self:GetScript("OnShow")(self)
						end)
						frame[1].totem = totem
					end
					
					-- micromenu 
					do
						local micro = CreateFrame("Button", nil, frame[1], "UIPanelButtonTemplate")
						micro:SetSize(w*1.5, h)
						micro:SetUITemplate("button", true)
						micro.highlight = micro:SetUITemplate("targetborder", nil, top, left, bottom, right)
						micro:SetText(L["Toggle Micro Menu"])
						micro:SetPoint("TOP", frame[1].shift, "BOTTOM", 0, -16)
						micro:SetScript("OnShow", function(self)
							if (GetBoolean(GUIS_DB.actionbars.showbar_micro)) then
								self.highlight:Show()
							else
								self.highlight:Hide()
							end
						end)
						micro:SetScript("OnClick", function(self)
							GUIS_DB.actionbars.showbar_micro = GetBinary(not(GetBoolean(GUIS_DB.actionbars.showbar_micro)))
							local micro = LibStub("gCore-3.0"):GetModule("GUIS-gUI: ActionBarsMicroMenu")
							if (micro) then
								if not(GetBoolean(GUIS_DB.actionbars.showbar_micro)) then
									if (micro.MicroMenu:IsShown()) then
										micro.MicroMenu:Hide()
									end
								else
									if not(micro.MicroMenu:IsShown()) then
										micro.MicroMenu:Show()
									end
								end
							end
							module:PostUpdateGUI()
							self:GetScript("OnShow")(self)
						end)
						frame[1].micro = micro
					end
					
				end

				return frame[1], parts
				
			elseif (index == 2) then
				if not(frame[2]) then
					frame[2] = CreateFrame("Frame", nil, UIParent)
					frame[2]:Hide()
					frame[2]:SetSize(600, 50)
				end
				
				local w, h = 85, 22
				local top, left, bottom, right = 3, -3, -3, 3
				
				-- top
				do
					local thetop = CreateFrame("Button", nil, frame[2], "UIPanelButtonTemplate")
					thetop:SetSize(w, h)
					thetop:SetUITemplate("button", true)
					thetop.highlight = thetop:SetUITemplate("targetborder", nil, top, left, bottom, right)
					thetop:SetText(L["Top"])
					thetop:SetPoint("TOPRIGHT", frame[2], "TOP", -8, -16)
					thetop:SetScript("OnShow", function(self)
						if (GUIS_DB.actionbars.layout == 1) then
							self.highlight:Show()
							self:GetParent().thebottom.highlight:Hide()
						else
							self.highlight:Hide()
							self:GetParent().thebottom.highlight:Show()
						end
					end)
					thetop:SetScript("OnClick", function(self)
						GUIS_DB.actionbars.layout = 1
						module:PostUpdateGUI()
						self:GetScript("OnShow")(self)

						-- let's do a copout and require a reload here. much easier.
						F.ScheduleRestart()
					end)
					frame[2].thetop = thetop
				end
				
				-- bottom
				do
					local thebottom = CreateFrame("Button", nil, frame[2], "UIPanelButtonTemplate")
					thebottom:SetSize(w, h)
					thebottom:SetUITemplate("button", true)
					thebottom.highlight = thebottom:SetUITemplate("targetborder", nil, top, left, bottom, right)
					thebottom:SetText(L["Bottom"])
					thebottom:SetPoint("LEFT", frame[2].thetop, "RIGHT", 16, 0)
					thebottom:SetScript("OnShow", function(self)
						if (GUIS_DB.actionbars.layout == 2) then
							self.highlight:Show()
							self:GetParent().thetop.highlight:Hide()
						else
							self.highlight:Hide()
							self:GetParent().thetop.highlight:Show()
						end
					end)
					thebottom:SetScript("OnClick", function(self)
						GUIS_DB.actionbars.layout = 2
						module:PostUpdateGUI()
						self:GetScript("OnShow")(self)

						-- let's do a copout and require a reload here. much easier.
						F.ScheduleRestart()
					end)
					frame[2].thebottom = thebottom
				end

				return frame[2], parts
			
			end
			
			return nil, parts
			
		elseif (option == "title") then
			if not(index) or (index == 1) then
				return F.getName(module:GetName()) .. ": " .. L["Select Visible ActionBars"]
			
			elseif (index == 2) then
				return F.getName(module:GetName()) .. ": " .. L["Select Main ActionBar Position"]
			end
		
		elseif (option == "description") then
			if not(index) or (index == 1) then
				return L["Here you can decide what actionbars to have visible. Most actionbars can also be toggled by clicking the arrows located next to their edges which become visible when hovering over them with the mouse cursor. This does not work while engaged in combat."] .. "|n|n" .. F.warning(L["You can try out different layouts before proceding!"])
				
			elseif (index == 2) then
				return L["When having multiple actionbars visible, do you prefer to have the main actionbar displayed at the top or at the bottom? The default setting is top."] .. "|n|n" .. F.warning(L["Changing this setting requires the UI to be reloaded in order to complete."])
			end
	
		elseif (option == "execute") then
			if not(index) or (index == 1) then
				return noop
			elseif (index == 2) then
			end
			
		elseif (option == "cancel") then
			return noop
			
		elseif (option == "post") then
			if not(index) or (index == 1) then
				return function(self, index)
					self:SetApplyButtonText(L["Continue"])
				end
			elseif (index == 2) then
				return function(self, index)
					self:SetApplyButtonText(L["Continue"])
				end
			end
		end
	end
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	-- this one requires a restart. Our basic copout.
	F.ScheduleRestart()
	
	GUIS_DB["actionbars"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["actionbars"] = GUIS_DB["actionbars"] or {}
	GUIS_DB["actionbars"] = ValidateTable(GUIS_DB["actionbars"], defaults)
	
	-- initial update of the bottom offset global variable
	updateBottomOffset()
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill() 
		return 
	end
	
	-- disable before creating new bars, or we'll have invisible stuff
	gAB:DisableBlizzard()
		
	-- we need to handle the actionbar lock manually, 
	-- since our hijacking of the menu option disabled blizzards own functionality
	module:UpdateActionBarLock()
	
	-- need to update it when variables are loaded, as blizzard will reset the global variable then
	hooksecurefunc("InterfaceOptionsFrame_LoadUVars", function() module:UpdateActionBarLock() end)
	
	for barName, data in pairs(layouts[GUIS_DB["actionbars"].layout]) do
		-- register the bar with its default settings
		local bar = gAB:New(barName, unpack(data.attributes()))
		
		-- just an extra safe-check, since we might have bars listed 
		-- that aren't yet supported by gActionBars
		if (bar) then
			-- register it with gFrameHandler if it's movable
			if (bar:GetAttribute("movable")) then
				bar:PlaceAndSave(unpack(data.pos()))
			else
				bar:ClearAllPoints()
				bar:SetPoint(unpack(data.pos()))
			end

			-- fire off visibility event in case somebody is listening
			FireCallback("GUIS_ACTIONBAR_VISIBILITY_UPDATE", barName, bar:GetAttribute("visible"))
		end
	end

	if (GUIS_DB["actionbars"].layout == 1) or (GUIS_DB["actionbars"].layout == 2) then
		-- actionbar 1 and 2 panel
		panel[bottomPanel] = CreateUIPanel(UIParent, bottomPanel, true)
		panel[bottomPanel]:SetUITemplate("simplebackdrop")
		panel[bottomPanel]:SetParent(gAB:GetBar(1))
		panel[bottomPanel]:ClearAllPoints()
	--	panel[bottomPanel]:SetPoint("TOPLEFT", UIParent, "BOTTOM", -189, 76)
	--	panel[bottomPanel]:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 189, 8)
		panel[bottomPanel]:SetPoint("TOPLEFT", ActionButton1, "TOPLEFT", -4, 4)
		panel[bottomPanel]:SetPoint("BOTTOMRIGHT", MultiBarBottomLeftButton12, "BOTTOMRIGHT", 4, -4)
		panel[bottomPanel]:Refresh()
		
		--
		-- actionbar 3 panel, left part
		panel[leftPanel] = CreateUIPanel(UIParent, leftPanel, true)
		panel[leftPanel]:SetUITemplate("simplebackdrop")
		panel[leftPanel]:SetParent(gAB:GetBar(31))
		panel[leftPanel]:ClearAllPoints()
		panel[leftPanel]:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "TOPLEFT", -4, 4)
		panel[leftPanel]:SetPoint("BOTTOMRIGHT", MultiBarBottomRightButton6, "BOTTOMRIGHT", 4, -4)
	--	panel[leftPanel]:SetPoint("TOPLEFT", UIParent, "BOTTOM", -291, 76)
	--	panel[leftPanel]:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -192, 8)
		panel[leftPanel]:Refresh()

		--
		-- actionbar 3 panel, right part
		panel[rightPanel] = CreateUIPanel(UIParent, rightPanel, true)
		panel[rightPanel]:SetUITemplate("simplebackdrop")
		panel[rightPanel]:SetParent(gAB:GetBar(32))
		panel[rightPanel]:ClearAllPoints()
		panel[rightPanel]:SetPoint("TOPLEFT", MultiBarBottomRightButton7, "TOPLEFT", -4, 4)
		panel[rightPanel]:SetPoint("BOTTOMRIGHT", MultiBarBottomRightButton12, "BOTTOMRIGHT", 4, -4)
	--	panel[rightPanel]:SetPoint("TOPLEFT", UIParent, "BOTTOM", 192, 76)
	--	panel[rightPanel]:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 291, 8)
		panel[rightPanel]:Refresh()

		--
		-- actionbar 4 and 5 panel (sidebars)
		panel[sidePanel] = CreateUIPanel(MultiBarRightButton1, sidePanel, true)
		panel[sidePanel]:SetUITemplate("simplebackdrop")
		panel[sidePanel]:ClearAllPoints()
		panel[sidePanel]:SetPoint("TOPLEFT", MultiBarRightButton1, "TOPLEFT", -4, 4)
		panel[sidePanel]:SetPoint("BOTTOMRIGHT", MultiBarRightButton12, "BOTTOMRIGHT", 4, -4)
	--	panel[sidePanel]:SetPoint("TOPLEFT", UIParent, "RIGHT", -45, 189)
	--	panel[sidePanel]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -8, -189)
		panel[sidePanel]:Refresh()
	
		-- hooks to adjust the panels
		RegisterCallback("GUIS_ACTIONBAR_VISIBILITY_UPDATE", postUpdatePanels)
		RegisterCallback("GUIS_ACTIONBAR_PANEL_UPDATE", postUpdatePanels)
		
		-- fire off the panel update callback when a bar is toggled directly through its StateDriver
		gAB:GetBar(2):HookScript("OnShow", function() FireCallback("GUIS_ACTIONBAR_PANEL_UPDATE") end)
		gAB:GetBar(2):HookScript("OnHide", function() FireCallback("GUIS_ACTIONBAR_PANEL_UPDATE") end)

		-- actionbar 2 left minimize arrow 
		local bar2MinLeft = createArrow(CreateFrame("Frame", bottomPanel .. "HideButtonLeft", gAB:GetBar(2)), "showbar_2", 2, false, M["Icon"]["ArrowRight"], { gAB:GetVisibilityBar(31), gAB:GetVisibilityBar(32) })
		bar2MinLeft:SetPoint("BOTTOMRIGHT", panel[bottomPanel], "BOTTOMLEFT", -4, 0)

		-- actionbar 2 right minimize arrow 
		local bar2MinRight = createArrow(CreateFrame("Frame", bottomPanel .. "HideButtonRight", gAB:GetBar(2)), "showbar_2", 2, false, M["Icon"]["ArrowLeft"], { gAB:GetVisibilityBar(31), gAB:GetVisibilityBar(32) })
		bar2MinRight:SetPoint("BOTTOMLEFT", panel[bottomPanel], "BOTTOMRIGHT", 4, 0)

		-- actionbar 2 left maximize arrow
		local bar2MaxLeft = createArrow(CreateFrame("Frame", bottomPanel .. "ShowButtonLeft", gAB:GetBar(1)), "showbar_2", 2, true, M["Icon"]["ArrowLeft"])
		bar2MaxLeft:SetPoint("BOTTOMRIGHT", panel[bottomPanel], "BOTTOMLEFT", -4, 0)

		-- actionbar 2 right maximize arrow
		local bar2MaxRight = createArrow(CreateFrame("Frame", bottomPanel .. "ShowButtonRight", gAB:GetBar(1)), "showbar_2", 2, true, M["Icon"]["ArrowRight"])
		bar2MaxRight:SetPoint("BOTTOMLEFT", panel[bottomPanel], "BOTTOMRIGHT", 4, 0)

		-- actionbar 31 minimize arrow
		local bar31Min = createArrow(CreateFrame("Frame", leftPanel .. "HideButton", gAB:GetBar(31)), "showbar_3", 31, false, M["Icon"]["ArrowRight"])
		bar31Min:SetPoint("TOPRIGHT", panel[leftPanel], "TOPLEFT", -4, 0)
		
		-- actionbar 31 maximize arrow
		local bar31Max = createArrow(CreateFrame("Frame", leftPanel .. "ShowButton", gAB:GetBar(1)), "showbar_3", 31, true, M["Icon"]["ArrowLeft"], nil, { gAB:GetVisibilityBar(2) })
		bar31Max:SetPoint("TOPRIGHT", panel[bottomPanel], "TOPLEFT", -4, 0)
		
		-- actionbar 32 minimize arrow
		local bar32Min = createArrow(CreateFrame("Frame", rightPanel .. "HideButton", gAB:GetBar(32)), "showbar_3", 32, false, M["Icon"]["ArrowLeft"])
		bar32Min:SetPoint("TOPLEFT", panel[rightPanel], "TOPRIGHT", 4, 0)
		
		-- actionbar 32 maximize arrow
		local bar32Max = createArrow(CreateFrame("Frame", rightPanel .. "ShowButton", gAB:GetBar(1)), "showbar_3", 32, true, M["Icon"]["ArrowRight"], nil, { gAB:GetVisibilityBar(2) })
		bar32Max:SetPoint("TOPLEFT", panel[bottomPanel], "TOPRIGHT", 4, 0)
		
		-- actionbar 4 maximize bar 4 arrow
		local bar4Max = createArrow(CreateFrame("Frame", sidePanel .. "Bar4ShowButton", UIParent), "showbar_4", 4, true, M["Icon"]["ArrowLeft"])
		bar4Max:SetPoint("TOPRIGHT", panel[sidePanel], "TOPRIGHT", 0, 0)

		-- actionbar 5 maximize bar 5 arrow
		local bar5Max = createArrow(CreateFrame("Frame", sidePanel .. "Bar5ShowButton", gAB:GetBar(4)), "showbar_5", 5, true, M["Icon"]["ArrowLeft"])
		bar5Max:SetPoint("TOPRIGHT", panel[sidePanel], "TOPLEFT", -8, 0)

		-- actionbar 4 minimize bar 4 arrow
		local bar4Min = createArrow(CreateFrame("Frame", sidePanel .. "Bar4HideButton", gAB:GetBar(4)), "showbar_4", 4, false, M["Icon"]["ArrowDown"], { gAB:GetVisibilityBar(5) })
		bar4Min:SetPoint("BOTTOM", gAB:GetBar(4), "TOP", 0, 8)

		-- actionbar 5 minimize bar 5 arrow
		local bar5Min = createArrow(CreateFrame("Frame", sidePanel .. "Bar5HideButton", gAB:GetBar(5)), "showbar_5", 5, false, M["Icon"]["ArrowDown"])
		bar5Min:SetPoint("BOTTOM", gAB:GetBar(5), "TOP", 0, 8)
		
		-- we want to connect the visibility of the two halves of bar 3
		local postUpdateThirdBar = function(self, event, bar, status)
			if (bar == 31) then
				self:Toggle(32, status)
				
			elseif (bar == 32) then
				self:Toggle(31, status)
			end
		end
		RegisterCallback("GUIS_ACTIONBAR_VISIBILITY_UPDATE", postUpdateThirdBar)

	end

	-- hotfix for the ExtraActionBarFrame
	if (ExtraActionBarFrame) then
		local ExtraActionBarFrameHolder = CreateFrame("Frame", self:GetName() .. "ExtraActionBarFrameHolder", UIParent)
		ExtraActionBarFrameHolder:SetSize(160, 80)
		ExtraActionBarFrameHolder:PlaceAndSave(unpack(layouts[GUIS_DB["actionbars"].layout].extra.pos()))

		ExtraActionBarFrame:SetParent(ExtraActionBarFrameHolder)
		ExtraActionBarFrame:ClearAllPoints()
		ExtraActionBarFrame:SetPoint("CENTER", ExtraActionBarFrameHolder, "CENTER", 0, 0)

	end

	-- do we really need a background panel for one single button?
--	panel[extraPanel] = CreateUIPanel(UIParent, extraPanel, true)
--	panel[extraPanel]:SetParent(ExtraActionBarFrame)
--	panel[extraPanel]:SetUITemplate("simplebackdrop")
--	panel[extraPanel]:ClearAllPoints()
--	panel[extraPanel]:SetPoint("TOPLEFT", ExtraActionButton1, "TOPLEFT", -4, 4)
--	panel[extraPanel]:SetPoint("BOTTOMRIGHT", ExtraActionButton1, "BOTTOMRIGHT", 4, -4)
--	panel[extraPanel]:Refresh()
	
	
	-- make sure the strata and panel positions are correct upon entering the game world
	RegisterCallback("PLAYER_ENTERING_WORLD", fixPanelStrata)
	RegisterCallback("PLAYER_ENTERING_WORLD", postUpdatePanels)
	
	-- create the options menu
	do
		local restoreDefaults = function()
			if (InCombatLockdown()) then 
				print(L["Can not apply default settings while engaged in combat."])
				return
			end
			
			-- restore all frame positions
			self:Reset()
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
		gOM:RegisterWithBlizzard(gOM:New(menuTable, true), F.getName(self:GetName()), 
			"refresh", applySettings, 
			"default", restoreDefaults, 
			"cancel", cancelChanges, 
			"okay", applyChanges)
	end
	
	-- register the FAQ
	do
		local FAQ = LibStub("gCore-3.0"):GetModule("GUIS-gUI: FAQ")
		FAQ:NewGroup(faq)
	end
	
	CreateChatCommand(function(layout)
		module:SetActiveStyle(layout)
	end, "setactionbarlayout")
	
	CreateChatCommand(function() 
		module:Reset() 
	end, "resetbars")

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_pet = 1
		module:Toggle("pet", true) 
		module:PostUpdateGUI()
	end, {"showpet", "showpetbar"})

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_pet = 0
		module:Toggle("pet", false) 
		module:PostUpdateGUI()
	end, {"hidepet", "hidepetbar"})

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_shift = 1
		module:Toggle("shift", true) 
		module:PostUpdateGUI()
	end, {"showshift", "showshiftbar", "showstance", "showstancebar"})

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_shift = 0
		module:Toggle("shift", false) 
		module:PostUpdateGUI()
	end, {"hideshift", "hideshiftbar", "hidestance", "hidestancebar"})

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_totem = 1
		module:Toggle("totem", true) 
		module:PostUpdateGUI()
	end, {"showtotem", "showtotembar"})

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_totem = 1
		module:Toggle("totem", false) 
		module:PostUpdateGUI()
	end, {"hidetotem", "hidetotembar"})

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_5 = 1
		module:Toggle(5, GetBoolean(GUIS_DB.actionbars.showbar_5) and GetBoolean(GUIS_DB.actionbars.showbar_4)) 
		module:PostUpdateGUI()
	end, "showleftbar")

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_5 = 0
		module:Toggle(5, false) 
		module:PostUpdateGUI()
	end, "hideleftbar")

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_4 = 1
		module:Toggle(4, true) 
		module:Toggle(5, GetBoolean(GUIS_DB.actionbars.showbar_5) and GetBoolean(GUIS_DB.actionbars.showbar_4)) 
		module:PostUpdateGUI()
	end, "showrightbar")

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_4 = 0
		module:Toggle(4, false) 
		module:Toggle(5, GetBoolean(GUIS_DB.actionbars.showbar_5) and GetBoolean(GUIS_DB.actionbars.showbar_4)) 
		module:PostUpdateGUI()
	end, "hiderightbar")

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_4 = 1
		GUIS_DB["actionbars"].showbar_5 = 1
		module:Toggle(4, true) 
		module:Toggle(5, true) 
		module:PostUpdateGUI()
	end, "showsidebars")

	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_4 = 0
		GUIS_DB["actionbars"].showbar_5 = 0
		module:Toggle(4, false) 
		module:Toggle(5, false) 
		module:PostUpdateGUI()
	end, "hidesidebars")
	
	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_2 = 0
		GUIS_DB["actionbars"].showbar_3 = 0
		GUIS_DB["actionbars"].showbar_4 = 0
		GUIS_DB["actionbars"].showbar_5 = 0
		module:Toggle(5, false) 
		module:Toggle(4, false) 
		module:Toggle(32, false) 
		module:Toggle(31, false) 
		module:Toggle(2, false) 
		module:PostUpdateGUI()
	end, { "minbars", "minimizebars" })
	
	CreateChatCommand(function() 
		GUIS_DB["actionbars"].showbar_2 = 1
		GUIS_DB["actionbars"].showbar_3 = 1
		GUIS_DB["actionbars"].showbar_4 = 1
		GUIS_DB["actionbars"].showbar_5 = 1
		module:Toggle(2, true) 
		module:Toggle(31, true) 
		module:Toggle(32, true) 
		module:Toggle(4, true) 
		module:Toggle(5, true) 
		module:PostUpdateGUI()
	end, { "maxbars", "maximizebars" })
end

local once
module.OnEnter = function(self)

	if not(once) then
		if (GUIS_VERSION.Initialized) then
			local a1, a2, a3, a4 = GetActionBarToggles()
			if not(a1) or not(a2) or not(a3) or not(a4) then
				SetActionBarToggles(1, 1, 1, 1)
				StaticPopup_Show("GUIS_RESTART_REQUIRED_TO_FIX_MISSING_ACTIONBARS")
			end
		end
		
		_G.ActionButton_HideGrid = noop

		for i = 1, NUM_ACTIONBAR_BUTTONS do
			_G[("ActionButton%d"):format(i)]:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(_G[("ActionButton%d"):format(i)])

			_G[("BonusActionButton%d"):format(i)]:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(_G[("BonusActionButton%d"):format(i)])

			_G[("MultiBarRightButton%d"):format(i)]:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(_G[("MultiBarRightButton%d"):format(i)])

			_G[("MultiBarBottomRightButton%d"):format(i)]:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(_G[("MultiBarBottomRightButton%d"):format(i)])

			_G[("MultiBarLeftButton%d"):format(i)]:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(_G[("MultiBarLeftButton%d"):format(i)])

			_G[("MultiBarBottomLeftButton%d"):format(i)]:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(_G[("MultiBarBottomLeftButton%d"):format(i)])
		end
		
		once = true
	end
end

-- save current actionbar lock state on exit
module.OnDisable = function(self)
	if GetBoolean(GUIS_DB.actionbars.lockActionBars) and (tonumber(LOCK_ACTIONBAR) ~= 1) then
		GUIS_DB.actionbars.lockActionBars = 0
		module:PostUpdateGUI()
		module:UpdateActionBarLock()
	end

	if not(GetBoolean(GUIS_DB.actionbars.lockActionBars)) and (tonumber(LOCK_ACTIONBAR) == 1) then
		GUIS_DB.actionbars.lockActionBars = 1
		module:PostUpdateGUI()
		module:UpdateActionBarLock()
	end
end
