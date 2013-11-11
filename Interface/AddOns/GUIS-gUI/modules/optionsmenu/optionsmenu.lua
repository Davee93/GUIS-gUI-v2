--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: OptionsMenu")

-- Lua API
local _G = _G
local pairs, ipairs, select, unpack = pairs, ipairs, select, unpack
local sort, tconcat, tinsert = table.sort, table.concat, table.insert
local tonumber = tonumber

-- WoW API
local CreateFrame = CreateFrame
local GetAddOnMetadata = GetAddOnMetadata
local InterfaceOptions_AddCategory = InterfaceOptions_AddCategory
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
local StaticPopup_Show = StaticPopup_Show

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gAB = LibStub("gActionButtons-2.0")
local gBars = LibStub("gActionBars-2.0")
local gPanel = LibStub("gPanel-2.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end
local UnregisterCallback = function(...) module:UnregisterCallback(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end
local ArgCheck = function(...) module:ArgCheck(...) end

local Widgets
local New, Create, CreateGroup, CreateWidget
local GetName, RegisterAsWidget, RegisterAsGroup
local SetTooltipScripts
local sortByOrder

local menus = {}
local widgetPool, groups = {}, {}

-- size of the InterfaceOptionsFramePanelContainer. We don't trust the automatic generation.
-- local w, h = InterfaceOptionsFramePanelContainer:GetSize(); w = w or 623; h = h or 568
--local containerWidth = InterfaceOptionsFrame:GetWidth() - InterfaceOptionsFrameAddOns:GetWidth() - 22 - 16 - 22 
--local containerHeight = InterfaceOptionsFrameAddOns:GetHeight() - 40 - 1
local containerWidth, containerHeight = 623, 568

-- we need named frames
local groupName, widgetName = module:GetName() .. "OptionsGroup", module:GetName() .. "Widget"
local groupCount, widgetCount = 0, 0

-- supported object types 
local types = { ["group"] = true, ["widget"] = true }

------------------------------------------------------------------------------------------------------------
-- 	Shared Functions
------------------------------------------------------------------------------------------------------------
sortByOrder = function(a, b)
	if (a) and (b) then
		if (a.order) and (b.order) then
			if (a.order) ~= (b.order) then
				return ((a.order) < (b.order))

			elseif (a.msg) and (b.msg) then
				return ((a.msg) < (b.msg))
			end
		end
	end
end

RegisterAsWidget = function(object)
	object.type = "widget"
	
	local methods = {
		-- dummy holders to avoid nil errors
		Enable = function(self) self.disabled = false end;
		Disable = function(self) self.disabled = true end;
		IsEnabled = function(self) return not(self.disabled) end;
		SetValue = noop;
		GetValue = noop;
	}
	for method,func in pairs(methods) do
		-- don't overwrite existing methods
		if not(object[method]) then
			object[method] = func
		end
	end
	
	return object
end


RegisterAsGroup = function(object)
	object.type = "group"
	
	-- generic methods for all groups
	-- will be overwritten by user methods and values
	local methods = {
		get = function(self) 
			return self:GetValue()
		end;
		
		set = function(self) 
			local value = self:get()
			for i = 1, #self.children do
				if (i == value) then
					self.children[i]:SetValue(true)
				else
					self.children[i]:SetValue(false)
				end
			end
		end;
		
		-- having a 'refresh' function in every group will effectively
		-- make it refresh itself and all child objects, no matter where 
		-- in the menu tree we are
		refresh = function(self)
			for i = 1, #self.children do
				if (self.children[i].refresh) then
					self.children[i]:refresh()
				end
			end
		end;
		
		GetValue = function(self)
			return self.selected
		end;
		
		SetValue = function(self, value)
			self.selected = value
		end;

		Enable = function(self) 
			self.disabled = false
			for _,widget in pairs(self.children) do
				widget:Enable()
			end
		end;
		
		Disable = function(self) 
			self.disabled = true
			for _,widget in pairs(self.children) do
				widget:Disable()
			end
		end;
		
		IsEnabled = function(self)
			return not(self.disabled)
		end;
		--[[
		-- add our sort function
		Sort = function(self) 
			local previousWidget
			local point, rpoint, vpoint, vrpoint, x, y, j
			local padding = self.padding or 8
			local maxWidth, maxHeight = self:GetWidth(), self:GetHeight()
			local currentWidth, currentHeight, lineHeight = 0, 0, 0
			local i = 1
			local sortX = self["growth-x"] or "LEFT"
			local sortY = self["growth-y"] or "DOWN"
			
			if (sortX == "LEFT") then
				point = "LEFT"
				rpoint = "RIGHT"
				x = padding
				
			elseif (sortX == "RIGHT") then
				point = "RIGHT"
				rpoint = "LEFT"
				x = -padding
			else
				error(("'%s' is an illegal value for 'growth-x'. Valid values are 'LEFT' and 'RIGHT'."):format(sortX))
			end
			
			if (sortY == "DOWN") then
				vpoint = "TOP"
				vrpoint = "BOTTOM"
				y = -padding
				
			elseif (sortY == "UP") then
				vpoint = "BOTTOM"
				vrpoint = "TOP"
				y = padding
			else
				error(("'%s' is an illegal value for 'growth-y'. Valid values are 'DOWN' and 'UP'."):format(sortX))
			end
			
			while (i <= #self.children) do
				-- end of the line, move on to the next
				if ((currentWidth + self.children[i]:GetWidth()) > maxWidth) then
					currentHeight = currentHeight + lineHeight + padding
					lineHeight = 0
					previousWidget = nil
				end
				
				if((currentHeight + self.children[i]:GetHeight()) < maxHeight) then
					lineHeight = max(lineHeight, self.children[i]:GetHeight())
					
					self.children[i]:ClearAllPoints()

					if (i == 1) then
						-- first widget in the container
						self.children[i]:SetPoint(vpoint .. point, self, vpoint .. point, 0, 0)
						
					elseif (previousWidget) then
						self.children[i]:SetPoint(point, self.children[previousWidget], rpoint, x, 0)
						
					else
						-- first widget on the current line
						if (vpoint == "TOP") then
							self.children[i]:SetPoint(vpoint .. point, self, vpoint .. point, 0, -currentHeight)
							
						elseif (vpoint == "BOTTOM") then
							self.children[i]:SetPoint(vpoint .. point, self, vpoint .. point, 0, currentHeight)
						end
					end
				
					self.children[i]:Show()
					
					previousWidget = i
					
					-- move on to the next widget
					i = i + 1
				else
					-- container height exceded, break here
					break
				end
			end
			
			-- overflow. Hide remaining widgets
			if (i <= #self.children) then
				for j = i, #self.children do
					self.children[j]:Hide()
				end
			end
		end;
		]]--
	}
	for method,func in pairs(methods) do
		object[method] = func
	end
	
	-- table for pointers to named children
	object.child = {}
	
	-- table for numeric/indexed child listings
	-- used for radiobutton/dropdown/tab functions etc
	object.children = {}

	
	return object
end

GetName = function(type)
	if (type == "group") then
		groupCount = groupCount + 1
		return groupName .. groupCount
		
	elseif (type == "widget") then
		widgetCount = widgetCount + 1
		return widgetName .. widgetCount
	end
end

SetTooltipScripts = function(self, hook)
	local SetScript = hook and "HookScript" or "SetScript"
	
	self[SetScript](self, "OnEnter", function(self)
		if (self.tooltipText) then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")

			if (type(self.tooltipText) == "string") then
				GameTooltip:SetText(self.tooltipText, 1.0, .82, .0, 1.0, 1)
				
			elseif (type(self.tooltipText) == "table") then
				for i = 1, #self.tooltipText do
					if (i == 1) then
						GameTooltip:SetText(self.tooltipText[i], 1.0, 1.0, 1.0, 1.0, 1)
					else
						GameTooltip:AddLine(self.tooltipText[i], 1.0, .82, .0, 1.0)
					end
				end
			end
			
			if (self.tooltipRequirement) then
				GameTooltip:AddLine(self.tooltipRequirement, 1.0, .0, .0, 1.0)
			end

			GameTooltip:Show()
		end
	end)
	
	self[SetScript](self, "OnLeave", function(self)
		GameTooltip:Hide()
	end)
end


------------------------------------------------------------------------------------------------------------
-- 	Widgets
------------------------------------------------------------------------------------------------------------
-- make sure all objects are represented here, or it will bug out
ObjectPadding = {
	-- text objects
	Title = { x = { before = 0, after = 0 }, y = { before = 16, after = 16 } };
	Header = { x = { before = 0, after = 0 }, y = { before = 16, after = 8 } };
	Text = { x = { before = 8, after = 0 }, y = { before = 0, after = 8 } };
	
	-- image objects
	Texture = { x = { before = 0, after = 0 }, y = { before = 0, after = 0 } };
	
	-- frame groups
	Frame = { x = { before = 0, after = 0 }, y = { before = 0, after = 0 } };
	ScrollFrame = { x = { before = 0, after = 0 }, y = { before = 0, after = 0 } };

	-- input widgets
	Button = { x = { before = 8, after = 8 }, y = { before = 8, after = 8 } };
	CheckButton = { x = { before = 8, after = 0 }, y = { before = 4, after = 4 } };
	ColorSelect = { x = { before = 0, after = 0 }, y = { before = 0, after = 0 } };
	Dropdown = { x = { before = -8, after = 0 }, y = { before = 0, after = 0 } }; --negative padding to make up for our dropdown styling
	EditBox = { x = { before = 0, after = 0 }, y = { before = 0, after = 0 } };
	RadioButton = { x = { before = 8, after = 0 }, y = { before = 4, after = 4 } };
	Slider = { x = { before = 16, after = 16 }, y = { before = 16, after = 16 } };
	StatusBar = { x = { before = 16, after = 16 }, y = { before = 8, after = 8 } };
	TabButton = { x = { before = 0, after = 0 }, y = { before = 0, after = 0 } };
}
Widgets = {
	-- use for page titles
	Title = function(parent, msg, name, ...)
		local self = parent:CreateFontString(name, "ARTWORK")
		self.isEnabled = true
		self:SetFontObject(GUIS_SystemFontLarge)
		self:SetTextColor(unpack(C["value"]))
		self:SetWordWrap(true)
		self:SetNonSpaceWrap(true)
		self:SetText(msg)

		self.Enable = function(self) 
			self.isEnabled = true
			self:SetTextColor(unpack(C["value"]))
		end

		self.Disable = function(self) 
			self.isEnabled = false
			self:SetTextColor(unpack(C["disabled"]))
		end

		self.IsEnabled = function(self) return self.isEnabled end
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end
		
		return self, ...
	end;

	-- use for paragraph headers
	Header = function(parent, msg, name, ...)
		local self = parent:CreateFontString(name, "ARTWORK")
		self.isEnabled = true
		self:SetFontObject(GUIS_SystemFontNormalWhite)
		self:SetTextColor(unpack(C["index"]))
		self:SetWordWrap(true)
		self:SetNonSpaceWrap(true)
		self:SetText(msg)
		
		self.Enable = function(self) 
			self.isEnabled = true
			self:SetTextColor(unpack(C["index"]))
		end

		self.Disable = function(self) 
			self.isEnabled = false
			self:SetTextColor(unpack(C["disabled"]))
		end

		self.IsEnabled = function(self) return self.isEnabled end

		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("LEFT", parent, "RIGHT", 8, 0)
		end

		return self, ...
	end;

	-- use for normal text
	Text = function(parent, msg, name, ...)
		local self = parent:CreateFontString(name, "ARTWORK")
		self.isEnabled = true
		self:SetFontObject(GUIS_SystemFontSmallWhite)
		self:SetTextColor(unpack(C["index"]))
		self:SetWordWrap(true)
		self:SetNonSpaceWrap(true)
		self:SetText((type(msg) == "table") and tconcat(msg, "|n") or msg)
		
		self.Enable = function(self) 
			self.isEnabled = true
			self:SetTextColor(unpack(C["index"]))
		end

		self.Disable = function(self) 
			self.isEnabled = false
			self:SetTextColor(unpack(C["disabled"]))
		end

		self.IsEnabled = function(self) return self.isEnabled end
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("LEFT", parent, "RIGHT", 8, 0)
		end

		return self, ...
	end;
	
	Texture = function(parent, msg, name, ...)
		local self = parent:CreateTexture(name, "ARTWORK")
		self:SetSize(32, 32)
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("LEFT", parent, "RIGHT", 8, 0)
		end

		return self, ...
	end;

	Button = function(parent, msg, name, ...)
		local self = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
		self:SetSize(80, 22)
		self:SetUITemplate("button", true)
		self:SetText(msg)
		
		self:SetScript("OnClick", function(self)
			if (self.set) then
				self:set()
				
			elseif (self.parent.set) then
				self.parent:set()
			end
		end)

		SetTooltipScripts(self)
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end
		
		return self, ...
	end;

	CheckButton = function(parent, msg, name, ...)
		local self = CreateFrame("CheckButton", name, parent, "OptionsBaseCheckButtonTemplate")  -- OptionsBaseCheckButtonTemplate?
		self:SetUITemplate("checkbutton", true)
		
		local text = self:CreateFontString(name .. "Text", "ARTWORK")
		text:SetFontObject(GUIS_SystemFontSmallWhite)
		text:SetPoint("LEFT", self, "RIGHT", 8, 0)
		text:SetTextColor(unpack(C["index"]))
		text:SetWordWrap(true)
		text:SetNonSpaceWrap(true)
		text:SetText(msg)
		self.text = text	

		self.refresh = function(self, option)
			if (self.get) then
				self:SetChecked(option or self:get())
				
			elseif (self.parent.get) then
				self:SetChecked(option or self.parent:get())
			end

			if (self.onrefresh) then
				self:onrefresh()
			end
		end

		self:SetScript("OnShow", function(self) self:refresh() end)
		self:SetScript("OnEnable", function(self) self.text:SetTextColor(unpack(C["index"])) end)
		self:SetScript("OnDisable", function(self) self.text:SetTextColor(unpack(C["disabled"])) end)
		self:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				PlaySound("igMainMenuOptionCheckBoxOn")
			else
				PlaySound("igMainMenuOptionCheckBoxOff")
			end
			
			if (self.set) then
				self:set()
				
			elseif (self.parent.set) then
				self.parent:set()
			end
		end)
		
		SetTooltipScripts(self)
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self, ...
	end;

	Frame = function(parent, name, ...)
		local self = CreateFrame("Frame", name, parent or UIParent)
		self:SetSize(containerWidth, containerHeight)
		self:EnableMouse(false)
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self
	end;

	-- not using a template for this one
	ScrollFrame = function(parent, name, ...)
		local self = CreateFrame("ScrollFrame", name, parent or UIParent) -- "UIPanelScrollFrameTemplate"
		self:SetSize(containerWidth - 32 - 16, containerHeight - 32)
		self:EnableMouseWheel(true)
		
		self.ScrollChild = CreateFrame("Frame", name .. "ScrollChild", self)
		self.ScrollChild:SetSize(self:GetSize())
		self.ScrollChild:SetAllPoints(self)
		
		self:SetScrollChild(self.ScrollChild)
		self:SetVerticalScroll(0)
		
		self.ScrollBar = CreateFrame("Slider", name .. "ScrollBar", self, "UIPanelScrollBarTemplate")
		self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, -16)
		self.ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 6, 16)
		self.ScrollBar:SetWidth(16)
		self.ScrollBar:SetMinMaxValues(0, 0)
		self.ScrollBar:SetValue(0)
		self.ScrollBar:SetUITemplate("scrollbar", true)

		self.ScrollBar.up = _G[name .. "ScrollBarScrollUpButton"]
		self.ScrollBar.up:Disable()
		self.ScrollBar.up:SetScript("OnClick", function(self)
			local ScrollBar = self:GetParent()
			local ScrollFrame = self:GetParent():GetParent()
			local scrollStep = ScrollFrame.scrollStep or (ScrollBar:GetHeight() / 3)

			ScrollBar:SetValue(min(0, ScrollBar:GetValue() - scrollStep))
			
			PlaySound("UChatScrollButton")
		end)
		
		self.ScrollBar.down = _G[name .. "ScrollBarScrollDownButton"]
		self.ScrollBar.down:Disable()
		self.ScrollBar.down:SetScript("OnClick", function(self)
			local ScrollBar = self:GetParent()
			local ScrollFrame = self:GetParent():GetParent()
			local scrollStep = ScrollFrame.scrollStep or (ScrollFrame:GetHeight() / 3)

			ScrollBar:SetValue(min(ScrollFrame:GetVerticalScrollRange(), ScrollBar:GetValue() + scrollStep))

			PlaySound("UChatScrollButton")
		end)
		
		self.Update = function(self)
			local w, h = self:GetSize()
			local sW, sH = self.ScrollChild:GetSize()

			if (w ~= sW) then
				self.ScrollChild:SetWidth(w)
			end

			if (h ~= sH) then
				self.ScrollChild:SetHeight(h)
			end
			
			self:UpdateScrollChildRect()

			local min, max, value = 0, self:GetVerticalScrollRange(), self:GetVerticalScroll()
			
			if (value > max) then
				value = max
			end
			
			if (value < min) then
				value = min
			end
			
			self.ScrollBar:SetMinMaxValues(min, max)
			
			if (value == min) then
				if (self.ScrollBar.up:IsEnabled()) then
					self.ScrollBar.up:Disable()
				end

				if not(self.ScrollBar.down:IsEnabled()) then
					self.ScrollBar.down:Enable()
				end
				
			elseif (value == max) then
				if (self.ScrollBar.down:IsEnabled()) then
					self.ScrollBar.down:Disable()
				end
				
				if not(self.ScrollBar.up:IsEnabled()) then
					self.ScrollBar.up:Enable()
				end
			else
				if not(self.ScrollBar.up:IsEnabled()) then
					self.ScrollBar.up:Enable()
				end

				if not(self.ScrollBar.down:IsEnabled()) then
					self.ScrollBar.down:Enable()
				end
			end
		end

		self.ScrollBar:SetScript("OnValueChanged", function(self, value)
			self:GetParent():SetVerticalScroll(value)
			self:GetParent():Update()
		end)
		
		self:SetScript("OnMouseWheel", function(self, delta)
			if (delta > 0) then
				if (self.ScrollBar.up:IsEnabled()) then
					self.ScrollBar:SetValue(max(0, self.ScrollBar:GetValue() - 20))
				end
				
			elseif (delta < 0) then
				if (self.ScrollBar.down:IsEnabled()) then
					self.ScrollBar:SetValue(min(self:GetVerticalScrollRange(), self.ScrollBar:GetValue() + 20))
				end
			end
		end)
		
		-- we schedule a timer to update the frame contents 1/5 second after it's shown
		-- we only do this the first time
		local once
		self:SetScript("OnShow", function(self) 
			if not(once) then
				ScheduleTimer(function() self:Update() end, nil, 1/5)
				once = true
			end
		end)
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self, self:GetScrollChild()
	end;

	ColorSelect = function(parent, msg, name, ...)
		local self = CreateFrame("ColorSelect", name, parent)

		SetTooltipScripts(self)
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self, ...
	end;

	Dropdown = function(parent, msg, name, args, width, ...)
		local width = width or 100
		local self = CreateFrame("Button", name, parent, "UIDropDownMenuTemplate")
		self:SetUITemplate("dropdown", true, width)
		self:SetHitRectInsets(-26, 0, 0, 0)
		
		SetTooltipScripts(self)
		
		local label = self:CreateFontString(name .. "Label", "ARTWORK")
		label:SetFontObject(GUIS_SystemFontSmallWhite)
		label:SetPoint("LEFT", self, "RIGHT", 0, 0)
		label:SetText(msg)
		self.label = label
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end
		
		local onclick = function(self)
			-- select the item you clicked on
			UIDropDownMenu_SetSelectedID(_G[name], self:GetID())

			-- fire off the button's 'set' function, and pass the ID along
			_G[name].set(_G[name], self:GetID())
			_G[name].selectedID = self:GetID()
		end
		
		self.args = CopyTable(args)
		self.refresh = function(self, option)
			if (self.get) then
				self.selectedID = self:get()
			end
			
			option = option or self.selectedID
			
			if (option) and (self.args[option]) then
				_G[name .. "Text"]:SetText(self.args[option])
			end

			if (self.onrefresh) then
				self:onrefresh()
			end
		end
		
		self:HookScript("OnShow", function(self) self:refresh() end)
--		self:HookScript("OnHide", function(self) self:refresh() end)
		
		local info = {}
		local init = function(self, level)
--			for i,v in pairs(args) do
			for i = 1, #args do
				wipe(info)
		
				info = UIDropDownMenu_CreateInfo()
				info.text = args[i] -- v
				info.value = i
				info.func = onclick

				UIDropDownMenu_AddButton(info, level)
			end
		end

		UIDropDownMenu_Initialize(self, init)
		UIDropDownMenu_SetWidth(self, width)
		UIDropDownMenu_SetButtonWidth(self, width)
		UIDropDownMenu_JustifyText(self, "LEFT")
		UIDropDownMenu_SetSelectedID(self, 1) -- selecting option #1 as default

		return self, ...
	end;

	EditBox = function(parent, msg, name, args, ...)
		local self = CreateFrame("Frame", nil, parent)
		self:EnableMouse(true)
		self:SetSize(90, 14)
		self:SetScript("OnMouseDown", function(self) self.editBox:Show() end)

		local text = self:CreateFontString(name .. "Text", "ARTWORK")
		text:SetFontObject(GUIS_NumberFontNormalYellow)
		text:SetPoint("BOTTOMLEFT", 0, 2)
		text:SetJustifyH("LEFT")
		text:SetJustifyV("BOTTOM")
		text:SetText("")
		text:SetTextColor(unpack(C["value"]))
		self.text = text
		
		local suffix = self:CreateFontString(name .. "TextSuffix", "ARTWORK")
		suffix:SetFontObject(GUIS_SystemFontSmallWhite)
		suffix:SetPoint("BOTTOMLEFT", text, "BOTTOMRIGHT")
		suffix:SetJustifyH("LEFT")
		suffix:SetJustifyV("BOTTOM")
		suffix:SetTextColor(unpack(C["index"]))
		suffix:SetText(msg)
		self.suffix = suffix
		
		local editBox = CreateFrame("EditBox", nil, self)
		editBox.parent = self
		editBox:Hide()
		editBox:SetSize(self:GetWidth() + 8, self:GetHeight() + 8)
		editBox:SetPoint("BOTTOMLEFT", -4, -2)
		editBox:SetJustifyH("LEFT")
		editBox:SetJustifyV("BOTTOM")
		editBox:SetTextInsets(4, 4, 0, 0)
		editBox:SetFontObject(GUIS_NumberFontNormal)
		editBox:SetAutoFocus(false)
		editBox:SetNumeric((args) and args.numeric)
		editBox:SetUITemplate("simplebackdrop")
		
		editBox.Refresh = function(self) 
			if (self.parent.get) then
				if (self:IsNumeric()) then
					self:SetNumber(self.parent:get())
				else
					self:SetText(self.parent:get())
				end
			else
				if (self:IsNumeric()) then
					self:SetNumber("")
				else
					self:SetText("")
				end
			end
		end

		editBox:SetScript("OnHide", function(self) 
			self.parent.text:Show()
			self.parent.suffix:Show()
		end)
		
		editBox:SetScript("OnShow", function(self) 
			self.parent.text:Hide()
			self.parent.suffix:Hide()
			
			self:Refresh()
			self:SetFocus()
			self:HighlightText()
		end)
		
		editBox:SetScript("OnEditFocusLost", editBox.Hide)
		editBox:SetScript("OnEscapePressed", editBox.Hide)
		editBox:SetScript("OnEnterPressed", function(self) 
			self:Hide()
			
			local msg = self:IsNumeric() and self:GetNumber() or self:GetText()
			if (msg) then
				if (self.parent.set) then
					self.parent:set(msg)
				end
			end
			
			self.parent:refresh()
		end)
		
		self.editBox = editBox
		
		SetTooltipScripts(self)
		
		self.refresh = function(self)
			if (self.get) then
				self.text:SetText(self.get())
			else
				self.text:SetText("")
			end
			
			if (self.editBox:IsShown()) then
				self.editBox:Refresh()
			end
			
			if (self.onrefresh) then
				self:onrefresh()
			end
		end
		
		self:HookScript("OnSizeChanged", function(self) 
			self.editBox:SetSize(self:GetWidth() + 8, self:GetHeight() + 8)
		end)
		
		self.Enable = function(self) 
			self.isEnabled = true
			self:EnableMouse(true)
			self.text:SetTextColor(unpack(C["value"]))
			self.suffix:SetTextColor(unpack(C["index"]))
		end

		self.Disable = function(self) 
			self.isEnabled = false
			self:EnableMouse(false)
			self.text:SetTextColor(unpack(C["disabled"]))
			self.suffix:SetTextColor(unpack(C["disabled"]))
			if (self.editBox:IsShown()) then
				self.editBox:Hide()
			end
		end

		self.IsEnabled = function(self) return self.isEnabled end
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self, ...
	end;

	RadioButton = function(parent, msg, name, ...)
		local self = CreateFrame("CheckButton", name, parent, "UIRadioButtonTemplate")
		self:SetUITemplate("radiobutton", true)

		local text = self:CreateFontString(name .. "Text", "ARTWORK")
		text:SetFontObject(GUIS_SystemFontSmallWhite)
		text:SetPoint("LEFT", self, "RIGHT", 8, 0)
		text:SetTextColor(unpack(C["index"]))
		text:SetWordWrap(true)
		text:SetNonSpaceWrap(true)
		text:SetText(msg)
		self.text = text	

		self.refresh = function(self, option)
			if (self.get) then
				self:SetChecked(option or self:get())
				
			elseif (self.parent.get) then
				self:SetChecked(option or self.parent:get())
			end

			if (self.onrefresh) then
				self:onrefresh()
			end
		end

		self:SetScript("OnShow", function(self) self:refresh() end)
		self:SetScript("OnEnable", function(self) self.text:SetTextColor(unpack(C["index"])) end)
		self:SetScript("OnDisable", function(self) self.text:SetTextColor(unpack(C["disabled"])) end)
		self:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				PlaySound("igMainMenuOptionCheckBoxOn")
			else
				PlaySound("igMainMenuOptionCheckBoxOff")
			end
			
			if (self.set) then
				self:set()
				
			elseif (self.parent.set) then
				self.parent:set()
			end
		end)

		SetTooltipScripts(self)
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self, ...
	end;

	Slider = function(parent, msg, name, orientation, ...)
		orientation = orientation or "HORIZONTAL"
		
		local self = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
		self:SetOrientation(orientation)
		self:SetUITemplate("slider", orientation)
		
		self.low = _G[name .. "Low"]
		self.high = _G[name .. "High"]
		self.text = _G[name .. "Text"]
		
		self.refresh = function(self, option)
			if (self.get) then
				local value = self:get()
				if (value) then
					self:SetValue(value)
				end
			end
		end

		self:SetScript("OnShow", function(self) self:refresh() end)
		
		self:SetScript("OnValueChanged", function(self, value)
			if (self.set) then
				self:set(value)
			end
		end)
		
		SetTooltipScripts(self)

		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self, ...
	end;

	StatusBar = function(parent, msg, name, ...)
		local self = CreateFrame("StatusBar", name, parent)
		self:SetUITemplate("statusbar", true)
		
		SetTooltipScripts(self)
		
		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self, ...
	end;
	
	TabButton = function(parent, msg, name, ...)
		local self = CreateFrame("CheckButton", name, parent, "TabButtonTemplate")
		self:SetUITemplate("tab", true)

		if (...) then
			self:SetPoint(...)
		else
			self:SetPoint("TOPLEFT")
		end

		return self, ...
	end;
}

------------------------------------------------------------------------------------------------------------
-- 	Item Creation
------------------------------------------------------------------------------------------------------------
CreateWidget = function(element, parent, msg, ...)
	if not(Widgets[element]) or not(parent) or not(parent.type == "group") then
		return
	end
	
	-- need to create a dummy to hold the methods, 
	-- as we need to pass along some selected values to the widget creation
	-- TODO: Find a better way, this is amateurish at best
	local methodHolder = {}
	if (...) then
		for i = 1, select("#", ...), 2 do 
			local key, value = select(i, ...) 
			methodHolder[key] = value
		end
	end
	
	local widget = RegisterAsWidget(Widgets[element](parent, msg, GetName("widget"), methodHolder.args, methodHolder.width))
	
	-- add the methods we collected previously to our widget
	for key,value in pairs(methodHolder) do
		widget[key] = value
	end

	-- create navigational pointers
	widget.parent = parent
	
	if (widget.name) and (widget.name ~= "") then
		-- just in case the parent for some reason isn't a 'real' group
		widget.parent.child = widget.parent.child or {}

		-- add the widget to our parent's 'child' table
		widget.parent.child[widget.name] = widget
	end

	widgetPool[widget] = true
	
	return widget
end

CreateGroup = function(parent, ...)
	-- use a frame as the holder for our group
	local group = RegisterAsGroup(Widgets["Frame"](parent, GetName("group")))
	
	if (...) then
		for i = 1, select("#", ...), 2 do 
			local key, value = select(i, ...) 
			group[key] = value
		end
	end
	
	-- create navigational pointers
	if (parent ~= UIParent) then
		group.parent = parent
		
		if (group.name) and (group.name ~= "") then
			-- just in case the parent for some reason isn't a group
			group.parent.child = group.parent.child or {}
			
			-- add the group to our parent's 'child' table
			group.parent.child[group.name] = group
		end
	end
	
	groups[group] = true
	
	return group
end

--
-- format:
--		local group = Create("group", parent, msg, ...)
--		local widget = Create("widget", element, parent, msg, ...)
--
-- example:
--		local group = Create("group", "SetValue", function(self, choice) self.widget[choice]:SetValue(true) end)
-- 	local widget = group:Create("widget", "CheckButton", )
Create = function(type, element, parent, msg, ...)
	if not(types[type]) then 
		return
	end
	
	local object
	if (type == "group") then
		-- for groups, 'element' is the parent, and 'parent' and 'msg' part of ...
		object = CreateGroup(element, parent, msg, ...)
		
		-- add a :Create() method to the group for easier creation
		if not(object.Create) then
			object.Create = function(self, type, element, parent, msg, ...) 
				local child = Create(type, element, parent, msg, ...) 
				
				-- insert the new child into the group's indexed widget pool
				tinsert(self.children, child)
				
				return child
			end
		end
		
	elseif (type == "widget") then
		object = CreateWidget(element, parent, msg, ...)
		
		-- insert the new widget into its parent group's indexed widget pool
		if (parent.children) then
			tinsert(parent.children, object)
		end
	end
	
	return object
end

-- in this function we translate the menuTable to widgets, groups and frames
New = function(menuTable, ...)
	if not(menuTable) or not(type(menuTable) == "table") then
		return
	end
	
	local useScrollFrame = ...
	local panel, scrollframe, inset, halfWidth, fullWidth
	local firstWidget

	panel = Widgets["Frame"](UIParent, GetName("group"))
	panel:Hide()

	-- ScrollFrames get messed up texture and frame order, and weird distortions
	-- unless there is a real space issue, never ever use them for anything but text!!
	if (useScrollFrame) then
		scrollframe, inset = Widgets["ScrollFrame"](panel, GetName("group"))

		scrollframe:SetWidth(panel:GetWidth() - 32 - 16)
		scrollframe:SetHeight(panel:GetHeight() - 32)
		scrollframe:SetPoint("TOPLEFT", 16, -16)
		scrollframe:SetPoint("BOTTOMRIGHT", -32, 16)

		fullWidth = panel:GetWidth() - 32 - 16
	else
		inset = CreateFrame("Frame", nil, panel)
		inset:SetWidth(panel:GetWidth() - 32)
		inset:SetHeight(panel:GetHeight() - 32)
		inset:SetPoint("TOPLEFT", 16, -16)
		inset:SetPoint("BOTTOMRIGHT", -16, 16)

		fullWidth = panel:GetWidth() - 32
	end
	halfWidth = fullWidth/2
	
	-- add a :Create() method to the panel for easier creation
	if not(inset.Create) then
		inset.Create = function(self, type, element, parent, msg, ...) 
			local child = Create(type, element, parent, msg, ...) 
			
			-- insert the new child into the group's indexed widget pool
			tinsert(self.children, child)
			
			return child
		end
	end

	-- doing this to grab generic group methods
	panel.inset = RegisterAsGroup(inset)
	
	local init = {}
	local bottomPadding = 0
	local traverse, previous -- need to define previous here
	
	traverse = function(panel, menuTable)
		sort(menuTable, sortByOrder)
		
		local object
		for i = 1, #menuTable do
			local item = menuTable[i]
			if (item) and (item.type) and (types[item.type]) then

				if (item.type == "group") then
					if (panel.type == "group") then
						object = panel:Create("group", panel, "name", item.name)
					else
						object = Create("group", panel, "name", item.name)
					end

					object.element = "Frame"
					
					if (item.virtual) then
						object:SetSize(0.00001, 0.00001)
					end
					
				elseif (item.type == "widget") then
					if (panel.type == "group") then
						object = panel:Create("widget", item.element, panel, item.msg, "name", item.name, "args", item.args)
					else
						object = Create("widget", item.element, panel, item.msg, "name", item.name, "args", item.args)
					end
					
					if not(object) then
						error(("No widget type named '%s' exists! Capitalization typo?"):format(item.element), 2)
					end
					
					object.element = item.element
					
					-- scrollframes distort graphics and messes with layers
					-- we need some fixes if we're using one
					if (useScrollFrame) then
						if (object.GetUIShadowFrame) and (object:GetUIShadowFrame()) then
							object:GetUIShadowFrame():Hide()
						end
					end

					if (item.desc) then
						object.tooltipText = item.desc
					end
				end
				
				-- size and position of the item
				object.width = item.width or "full"
				if (object.width == "full") then
					object.newLine = true
				
				-- last item on a line
				elseif (object.width == "last") then
					object.newLine = true
				
				-- two halves in a row
				elseif (object.width == "half") and ((previous) and (previous.width == "half")) then
					-- only change to a new line if the previous object didn't
					if not(previous.newLine) then
						object.newLine = true
					end
				end
				
				-- need to keep track of bottom padding on each line, 
				-- and make the last item on each line have the maximum bottom padding
				
				-- grab values for object padding
				local pad = ObjectPadding[object.element]
				
				local lastPad
				if (previous) then
					lastPad = ObjectPadding[previous.element]
				end
				
				local indent = item.indented and 32 or 0
				
				-- first element of the group
				if (i == 1) then
					-- check if there is a previous group to make room for
					if (previous) and (firstWidget) then
						object:ClearAllPoints()
						object:SetPoint("LEFT", panel, "LEFT", indent + (pad.x.before), 0)
						object:SetPoint("TOP", previous, "BOTTOM", 0, -(pad.y.before + max(lastPad.y.after, bottomPadding)))
					else
						object:ClearAllPoints()
						object:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
					end
					
					bottomPadding = pad.y.after
					
				else
					-- first item on a new line
					if (object.width == "full") or (previous.newLine) then
						object:ClearAllPoints()
						object:SetPoint("LEFT", panel, "LEFT", indent + (pad.x.before), 0)
						object:SetPoint("TOP", previous, "BOTTOM", 0, -(pad.y.before + max(lastPad.y.after, bottomPadding)))
						
						bottomPadding = pad.y.after
						
						-- second item on a half line
					elseif (previous.width == "half") then
						object:ClearAllPoints()
						object:SetPoint("LEFT", panel, "LEFT", halfWidth + indent + (pad.x.before), 0)
						object:SetPoint("TOP", previous, "TOP", 0, 0)
						
						bottomPadding = max(pad.y.after, bottomPadding)

						-- minimum size, no overflow checking here so use with caution!! achtung achtung!
					elseif (previous.width == "minimum") then
						object:ClearAllPoints()
						object:SetPoint("TOPLEFT", previous, "TOPRIGHT", (pad.x.before + lastPad.x.after), 0)
						
						bottomPadding = max(pad.y.after, bottomPadding)
					end
				end
				
				-- set the width of text objects, to enable wrapping
				if (object.element == "Text") then
					if (object.width == "half") then
						object:SetWidth(halfWidth - (pad.x.before + pad.x.after))
						
					elseif (object.width == "full") then 
						object:SetWidth(fullWidth - (pad.x.before + pad.x.after))
					end
				end
				
				object.get = item.get
				object.set = item.set
				object.init = item.init
				object.onrefresh = item.onrefresh
				object.onenable = item.onenable
				object.ondisable = item.ondisable
				object.onshow = item.onshow
				object.onhide = item.onhide

				if (object.init) then
					tinsert(init, object)
				end

				if (object:IsObjectType("Frame")) then
					if (object.onenable) then
						object:HookScript("OnEnable", object.onenable) 
					end
					
					if (object.ondisable) then
						object:HookScript("OnDisable", object.ondisable) 
					end
											
					if (object.onshow) then
						object:HookScript("OnShow", object.onshow)
					end
					
					if (object.onhide) then
						object:HookScript("OnHide", object.onhide) 
					end
				end

				-- set the pointer to the current object before iterating over the sub-group
				previous = object

				-- the first widget have been drawn, now it is ok to indent before an item
				if (item.type == "widget") and not(firstWidget) then
					firstWidget = true
				end
				
				if (item.type == "group") then
					traverse(object, item.children)
				end
			end
		end
	end
	
	traverse(inset, menuTable)
	
	for _,object in pairs(init) do
		object.init(object)
	end
	init = nil
	
	-- blizzard menu compatible refresh function
	panel.refresh = function(self) 
		local topLevel = self.inset.children 
		for i = 1, #topLevel do
			if (topLevel[i].refresh) then
				topLevel[i]:refresh()
			end
		end
	end
	
	return panel
end

module.Create = function(self, ...)
	return Create(...)
end

-- using this one to simply hook new menus into the main one
-- external usage:
-- 	local gOM = LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu")
-- 	local panel = gOM:New(menuTable)
module.New = function(self, ...)
	local panel = New(...)
	
	if (ns.GUIS_MENU) then
		panel.parent = ns.GUIS_MENU.name
	else
		panel.parent = nil
	end
	
	return panel
end

--[[

	Source: http://wowprogramming.com/docs/api/InterfaceOptions_AddCategory
	
	panel - The menu frame itself
	panel.name - string (required) - The name of the AddOn or group of configuration options. This is the text that will display in the AddOn options list.
	panel.parent - string (optional) - Name of the parent of the AddOn or group of configuration options. This identifies "panel" as the child of another category. If the parent category doesn't exist, "panel" will be displayed as a regular category.
	panel.okay - function (optional) - This method will run when the player clicks "okay" in the Interface Options.
	panel.cancel - function (optional) - This method will run when the player clicks "cancel" in the Interface Options. Use this to revert their changes.
	panel.default - function (optional) - This method will run when the player clicks "defaults". Use this to revert their changes to your defaults.
	panel.refresh - function (optional) - This method will run when the Interface Options frame calls its OnShow function and after defaults have been applied via the panel.default method described above. Use this to refresh your panel's UI in case settings were changed without player interaction.
	
	-- register it with blizzard
	InterfaceOptions_AddCategory(panel)
	
	-- open to a menu, or sub-category
	InterfaceOptionsFrame_OpenToCategory(panel.name)
	
]]--

-- external usage:
-- 	local gOM = LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu")
-- 	gOM:RegisterWithBlizzard(panel, name[, ...])
--
-- combined usage:
-- 	local gOM = LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu")
-- 	local panel = gOM:RegisterWithBlizzard(gOM:New(menuTable), name[, ...])
local BlizzardMenuQueue = {}
module.RegisterWithBlizzard = function(self, panel, name, ...)
	if not(panel) or (type(name) ~= "string") then
		return
	end
	
	panel.name = name

	if (...) then
		for i = 1, select("#", ...), 2 do 
			local key, value = select(i, ...) 
			panel[key] = value
		end
	end

	-- directly create the menu if we're already logged in, 
	-- or if it is lacking a parent object, thus indicating it's a top level menu. 
	if (IsLoggedIn()) or not(panel.parent) then
		InterfaceOptions_AddCategory(panel)
	else
		-- queue it up to be added later
		tinsert(BlizzardMenuQueue, panel)
	end
	
	return panel
end

module.Open = function(self, name)
	if (type(name) ~= "string") or not(menus[name]) or not(menus[name].name) then
		return
	end
	
	InterfaceOptionsFrame_OpenToCategory(menus[name].name)
end
F.OpenToOptionsCategory = function(name) module:Open(name) end

module.GetMenuTable = function(self, name)
	return menus[name].inset -- or menus[name]
end

module.Refresh = function(self, name)
	if (menus[name]) and (menus[name].refresh) then
		menus[name]:refresh()
	end
end

module.GetMenuObject = function(self, name, ...)
	local position = self:GetMenuTable(name)
	if not(position) then
		return
	end
	
	local SetSail = function(menu, childName)
		return (menu) and (menu.child) and (menu.child[childName])
	end
	
	for i = 1, select("#", ...) do
		position = SetSail(position, (select(i, ...)))
	end
	
	return position
end

module.ApplyToAllChildren = function(self, menuObject, func, ...)
	if not(menuObject) or not(menuObject.children) then
		return
	end
	
	for i = 1, #menuObject.children do
		func(menuObject.children[i], ...)
	end
end

module.ApplyMethodToAllChildren = function(self, menuObject, method, ...)
	if not(menuObject) or not(menuObject.children) then
		return
	end
	
	for i = 1, #menuObject.children do
		if (menuObject.children[i][method]) then
			menuObject.children[i][method](menuObject.children[i], ...)
		end
	end
end

-- menus should be added by modules prior to his, 
-- preferably in their OnInit() function.
module.OnEnable = function(self)
	-- sort the menus by their display names
	sort(BlizzardMenuQueue, function(a,b)
		if (a) and (b) then
			if (a.name) and (b.name) then
				return (a.name < b.name)
			end
		end
	end)
	
	-- NOW we add the menus, in alphabetical order
	for i = 1, #BlizzardMenuQueue do
		InterfaceOptions_AddCategory(BlizzardMenuQueue[i])
		
		menus[BlizzardMenuQueue[i].name] = BlizzardMenuQueue[i]
	end
end

module.Init = function(self)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill() 
		return 
	end
	
	local w, h = InterfaceOptionsFrame:GetWidth() or 0, InterfaceOptionsFrame:GetHeight() or 0
	if (w < 858) or (h < 660) then
		InterfaceOptionsFrame:SetSize(858, 660)

		InterfaceOptionsFrameAddOns:SetSize(175, 569)
		InterfaceOptionsFrameAddOns:ClearAllPoints()
		InterfaceOptionsFrameAddOns:SetPoint("TOPLEFT", 22, -40)

		InterfaceOptionsFrameCategories:SetSize(175, 569)
		InterfaceOptionsFrameCategories:ClearAllPoints()
		InterfaceOptionsFrameCategories:SetPoint("TOPLEFT", 22, -40)
		
		InterfaceOptionsFramePanelContainer:ClearAllPoints()
		InterfaceOptionsFramePanelContainer:SetPoint("TOPLEFT", InterfaceOptionsFrameCategories, "TOPRIGHT", 16, 0)
		InterfaceOptionsFramePanelContainer:SetPoint("BOTTOMLEFT", InterfaceOptionsFrameCategories, "BOTTOMRIGHT", 16, 1)
		InterfaceOptionsFramePanelContainer:SetPoint("RIGHT", -22, 0)
	end
	
	InterfaceOptionsFrame:HookScript("OnHide", function() F.RestartIfScheduled() end)
--	InterfaceOptionsFrameOkay:HookScript("OnClick", function() F.RestartIfScheduled() end)
end

