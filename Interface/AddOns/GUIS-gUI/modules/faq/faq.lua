--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: FAQ")

-- Lua API
local pairs, ipairs, select = pairs, ipairs, select 
local tinsert, unpack = tinsert, unpack 

-- WoW API
local CreateFrame = CreateFrame
local PlaySound = PlaySound

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end
local UnregisterCallback = function(...) module:UnregisterCallback(...) end
local FireCallback = function(...) module:FireCallback(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end

local CreateScrollFrame
local CreateTagButton, CreateFontString, CreateImage, CreateButton

-- tables to hold the FAQ data
local faqs = {}
local tags = {}

-- taglisting
-----------------------------------------------------------------
local tagbuttons = {} -- available and selected tags
local selectedTags = {} -- list of currently selected tags

-- faq display
-----------------------------------------------------------------
local currentFAQ -- currently selected FAQ
local displayItems = {} -- list of items in the current FAQ display 
local messages = {} -- fontstrings in the currently displayed FAQ
local images = {} -- images in the currently displayed FAQ
local buttons = {} -- buttons in the currently displayed FAQ

-- faq list
-----------------------------------------------------------------
local listButtons = {}


-- default settings, if settngs is something we need
local defaults = {
}

-- copy & pasted from optionsmenu.lua
-- protect the environment, recycle code! :)
do
	CreateScrollFrame = function(name, parent, w, h)
		local self = CreateFrame("ScrollFrame", name, parent or UIParent) -- "UIPanelScrollFrameTemplate"
		self:SetSize(w, h)
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
		
		return self, self:GetScrollChild()
	end
end

--------------------------------------------------------------------------------------------------
--		Tag Objects Creation
--------------------------------------------------------------------------------------------------
do
	
	-- create a tagbutton
	CreateTagButton = function()
		local frame = module.frame.availableTags:GetScrollChild()
		local w, h = frame:GetWidth() - 14, 22
		
		local button = CreateFrame("Button", module:GetName() .. "TagButton" .. (#tagbuttons + 1), frame, "UIPanelButtonTemplate")
		button:SetSize(w, h)
		button:SetUITemplate("button", true)
		button.selectedBorder = button:SetUITemplate("targetborder", nil, 3, -3, -3, 3)
		button.selectedOverlay = button:CreateTexture(nil, "OVERLAY")
		button.selectedOverlay:SetAllPoints()
		button.selectedOverlay:SetTexture(1, 1, 1, 1/10)

		button.Update = function(self)
			if (self.selected) then
				self.selectedBorder:Show()
				self.selectedOverlay:Show()
			else
				self.selectedBorder:Hide()
				self.selectedOverlay:Hide()
			end
		end

		button:SetScript("OnClick", function(self) 
			if (self.selected) then
				module:DeselectTag(self)
			else
				module:SelectTag(self)
			end
		end)

		button:Update()
		
		return button
	end
	
	CreateListButton = function(msg)
		local button
		if (#listButtons > 0) then
			for i,v in ipairs(listButtons) do
				if not(v:GetText()) or (v:GetText() == "") then
					button = v
					break
				end
			end
		end
		
		if not(button) then
			button = CreateFrame("Button", module:GetName() .. "ListButton" .. (#listButtons + 1), module.frame.faqList:GetScrollChild(), "UIPanelButtonTemplate")
			button:Hide() -- hide while preparing it 
			button:SetUITemplate("button", true)
			button:SetWidth(button:GetParent():GetWidth() - 12)
			button:GetFontString():SetTextColor(0.27, 0.53, 1)
			button:GetFontString():SetWidth((button:GetParent():GetWidth() - 12) - 64)
			button:GetFontString():SetJustifyH("CENTER")
			button:GetFontString():SetJustifyV("MIDDLE")
			button:SetScript("OnClick", function(self)
				if (self:GetID()) and (self:GetID() ~= 0) then
					module:DisplayFAQ(self:GetID())
				end
			end)
			tinsert(listButtons, button)
		end
		
		button:Hide() -- hide while preparing it 
		button:SetID(0) -- setting it to 0, the function that called this one will update it
		button:GetFontString():SetHeight(1000)
		button:SetText(msg)
		
		local h = button:GetFontString():GetStringHeight()
		button:GetFontString():SetHeight(h)
		button:SetHeight(h + 32)
		
		return button		
	end
	
	-- retrieve a fontstring
	CreateFontString = function(msg, question)
		local fontstring
		if (#messages > 0) then
			for i,v in ipairs(messages) do
				if not(v:GetText()) or (v:GetText() == "") then
					fontstring = v
					break
				end
			end
		end
		
		if not(fontstring) then
			fontstring = module.frame.faqDisplay:GetScrollChild():CreateFontString(nil, "ARTWORK")
			fontstring:SetWidth(fontstring:GetParent():GetWidth() - 32)
			tinsert(messages, fontstring)
		end
		
		fontstring:Hide()

		if (question) then
			fontstring:SetFontObject(GUIS_SystemFontNormal)
			fontstring:SetTextColor(0.27, 0.53, 1)
		else
			fontstring:SetFontObject(GUIS_SystemFontSmallWhite)
			fontstring:SetTextColor(1, 1, 1)
		end
		
		fontstring:SetHeight(1000)
		fontstring:SetText(msg)
		fontstring:SetHeight(fontstring:GetStringHeight())
		
		return fontstring
	end
	
	-- retrieve an image
	CreateImage = function(path, w, h, ...)
		local image
		if (#images > 0) then
			for i,v in ipairs(images) do
				if not(v:GetTexture()) or (v:GetTexture() == "") then
					image = v
					break
				end
			end
		end
		
		if not(image) then
			image = module.frame.faqDisplay:GetScrollChild():CreateTexture(nil, "ARTWORK")
			image:Hide()
			tinsert(images, image)
		end
		
		image:SetTexture(path)
		image:SetSize(w, h)

		if (...) then
			image:SetTexCoord(...)
		end
		
		return image
	end
	
	-- retrieve a clickable button
	CreateButton = function(msg, click)
		local button
		if (#buttons > 0) then
			for i,v in ipairs(buttons) do
				if not(v:GetScript("OnClick")) then
					button = v
					break
				end
			end
		end
		
		if not(button) then
			button = CreateFrame("Button", module:GetName() .. "Button" .. (#buttons + 1), module.frame.faqDisplay:GetScrollChild(), "UIPanelButtonTemplate")
			button:Hide()
			button:SetUITemplate("button", true)
			button:GetFontString():SetJustifyH("CENTER")
			button:GetFontString():SetJustifyV("MIDDLE")
			tinsert(buttons, button)
		end
		
		-- maximum width and height. insane numbers.
		local max = button:GetParent():GetWidth() - 12 - 32
		button:SetWidth(max)
		button:SetHeight(1000)
		button:SetText(msg)
		
		-- shrink the width if possible
		local stringWidth = button:GetFontString():GetStringWidth()
		local w = min(max, stringWidth + 32)
		button:SetWidth(w + 32)
		button:GetFontString():SetWidth(w)
		
		-- figure out the height
		local stringHeight = button:GetFontString():GetStringHeight()
		button:GetFontString():SetHeight(stringHeight)
		button:SetHeight(stringHeight + 16)
		
		-- smack in our script
		button:SetScript("OnClick", click)
		
		return button
	end

end

module.New = function(self, faqObject)
	faqs[#faqs + 1] = faqObject
	
	if not(self.frame) then
		self:CreateFrame()
	end
	
	self:UpdateTags()
	
	return #faqs
end

do
	local id = {}
	module.NewGroup = function(self, faqGroup)
		wipe(id)

		for i,faqObject in ipairs(faqGroup) do
			tinsert(id, self:New(faqObject))
		end
		
		return unpack(id)
	end
end

-- sort the taglist with the selected tags first
-- and everything in alphabetical order
do
	local displayorder = { selected = {}, available = {} }
	local sortSelected = function(a, b)
		local at = selectedTags[a]
		local bt = selectedTags[b]
		
		if (at) and (bt) then
			return (at < bt)
		end
	end

	local sortAvailable = function(a, b)
		local at = a:GetText()
		local bt = b:GetText()
		
		if (at) and (bt) then
			return (at < bt)
		end
	end

	module.SortTags = function(self)
		local frame = self.frame.availableTags
		
		wipe(displayorder.selected)
		wipe(displayorder.available)
		
		-- find and sort the remaining buttons
		for i,v in ipairs(tagbuttons) do
			-- clear all positions
			v:ClearAllPoints()
			
			if (v.selected) then
				tinsert(displayorder.selected, v)
			else
				-- insert a pointer to the button itself
				tinsert(displayorder.available, v)
			end
		end
		sort(displayorder.selected, sortSelected)
		sort(displayorder.available, sortAvailable)
		
		-- show the selected buttons first
		local haveSelection
		local button, previous
		local count = 0
		for i,v in ipairs(displayorder.selected) do
			button = v
			if (button) then
				count = count + 1
				
				if (count == 1) then
					button:SetPoint("TOP", frame:GetScrollChild(), "TOP", 0, -7)
				else
					button:SetPoint("TOP", previous, "BOTTOM", 0, -8)
				end
				
				haveSelection = true
				previous = button
			end
		end
		
		for i,v in ipairs(displayorder.available) do
			button = v
			if (button) then
				count = count + 1
				
				if (count == 1) then
					button:SetPoint("TOP", frame:GetScrollChild(), "TOP", 0, -7)
				else
					if (haveSelection) then
						button:SetPoint("TOP", previous, "BOTTOM", 0, -12)
						
						haveSelection = nil
					else
						button:SetPoint("TOP", previous, "BOTTOM", 0, -6)
					end
				end
				
				previous = button
			end
		end
		
		frame:Update()
		
		-- changing the selected tags shows the FAQ listing
		self:ShowFAQList()
	end
end

-- simple function to retrieve either a tagbutton or tagstrings actual tagvalue in lowercase
-- this is used mainly to compare tags from different sources, 
-- and to avoid "Actionbars" and "ActionBars" being treated as separate tags!
module.GetTagText = function(self, tag)
	if (type(tag) == "string") then
		return tag:lower()
	else
		return (tag:GetText()) and tag:GetText():lower()
	end
end

-- selects a tag
module.SelectTag = function(self, tag)
	local button
	if (type(tag) == "string") then
		for i,v in ipairs(tagbuttons) do
			if (v:GetText() == tag) then
				selectedTags[v] = tag
				button = v
				break
			end
		end
	else
		selectedTags[tag] = tag:GetText()
		button = tag
	end

	button.selected = true
	button:Update()

	self:SortTags()
	self:DisplayList()
end

-- deselects a tag
module.DeselectTag = function(self, tag)
	local button
	if (type(tag) == "string") then
		for i,v in ipairs(tagbuttons) do
			if (v:GetText() == tag) then
				selectedTags[v] = nil
				button = v
				break
			end
		end
	else
		selectedTags[tag] = nil
		button = tag
	end

	button.selected = nil
	button:Update()

	self:SortTags()
	self:DisplayList()
end

-- clear all selected tags
module.ClearAllTags = function(self)
	wipe(selectedTags)
	
	for _,tag in ipairs(tagbuttons) do
		tag.selected = nil
		tag:Update()
	end

	self:SortTags()
	self:DisplayList()
end

-- clears the currently displayed FAQ 
module.ClearDisplay = function(self)
	local frame = self.frame.faqDisplay

	for i,v in ipairs(displayItems) do
		if (v) then
			v:Hide()
			if (v.SetText) then
				v:SetText(nil)
			end
			
			if (v.SetTexture) then
				v:SetTexture("")
			end
			
			if (v.SetScript) then
				v:SetScript("OnClick", nil)
			end
		end
	end
	wipe(displayItems)
	
	currentFAQ = nil

	frame:Update()
end

-- display a FAQ
module.DisplayFAQ = function(self, faqID)
	local frame = self.frame.faqDisplay
	
	local faq = faqs[faqID]
	if not(faq) or not(faq.a) or not(faq.q) then
		return
	end

	-- clear the old FAQ if any is displayed
	self:ClearDisplay()
	
	local element, previous

	-- draw the new one up
	-- first element is always the question. make larger? hmmm...
	element = CreateFontString(faq.q, true)
	element:ClearAllPoints()
	element:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -16)
	element:Show()
	tinsert(displayItems, element)

	previous = element
	
	for i,object in ipairs(faq.a) do
		-- create the correct type of element
		if (object.type == "text") then
			element = CreateFontString(object.msg)
		
		elseif (object.type == "image") then
			element = CreateImage(object.path, object.w, object.h, (object.texcoords) and unpack(object.texcoords))
		
		elseif (object.type == "button") then
			element = CreateButton(object.msg, object.click)
			
		else
			element = nil
		end
		
		-- position the new element if it exists, set the pointer to this one
		if (element) then
			element:ClearAllPoints()
			element:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -12)
			element:Show()
			tinsert(displayItems, element)
			
			previous = element
		end
	end
	
	-- set the flag and switch to the FAQ display window
	currentFAQ = faqID
	self:ShowFAQDisplay()

	frame:Update()
end

-- clears the current FAQ list
module.ClearList = function(self)
	local frame = self.frame.faqList
	
	-- clear all list buttons
	for _,button in ipairs(listButtons) do
		button:SetID(0)
		button:SetText(nil)
		button:Hide()
	end

	frame:Update()
end

-- displays the currently available FAQs
-- tagList is optional, the selected tags in the UI will normally be used
-- tagList is added for external modules to open directly
do
	local listing = {}
	module.DisplayList = function(self, tagList)
		-- both the custom and selected tag list will have a string as its value
		-- the difference lies in the keys, which will be the tag button in the selected list, 
		-- and a simple numeric index in a custom list. 
		tagList = tagList or selectedTags
		
		self:ClearList()
		
		-- clean out the old listing
		wipe(listing)
		
		local i, id, faq, button, previous
		local show, found, hide, count

		-- iterate through all the faq objects
		for id, faq in ipairs(faqs) do
			show = nil -- don't show until proven worthy
			
			-- if this faq has tags attached, look them up
			-- if not, it won't be included
			-- a faq without tags is in fact just wasted space
			if (faq.tags) then
				-- compare to the supplied taglist
				-- a faq must have ALL the selected tags to be shown
				hide = nil -- we will activate this if a tag fails to be found within the faq object
				count = 0
				for _,tag in pairs(tagList) do
					-- compare the tag from the supplied taglist to those in the faq object
					count = count + 1
					
					found = nil
					for _,hasTag in ipairs(faq.tags) do
						if (self:GetTagText(hasTag) == self:GetTagText(tag)) then
							found = true -- we found a match!
						end
					end
					
					-- we didn't find any mach for the 'tag' entry from the supplied tag list in this faq object
					if not(found) then
						hide = true
					end
				end
				
				if (count == 0) then
					hide = true
				end
				
				-- set the 'show' flag if we haven't found a reason to keep this faq object hidden
				if not(hide) then
					show = true
				end
			end
			
			-- we found a match for all the tags in the supplied taglist! show this one!
			if (show) then
				tinsert(listing, id)
			end
		end
		
		local frame = self.frame.faqList
		count = 0
		if (#listing > 0) then
			if (frame.intro) then
				frame.intro:Hide()
			end
			
			for _,id in ipairs(listing) do
				faq = faqs[id]
				count = count + 1
				
				button = CreateListButton(faq.q)
				button:SetID(id)
				button:ClearAllPoints()
				if (count == 1) then
					button:SetPoint("TOP", frame, "TOP", 0, -6)
				else
					button:SetPoint("TOP", previous, "BOTTOM", 0, -7)
				end
				button:Show()
				
				previous = button
			end
		else
			-- show the intro screen
			if not(frame.intro) then
				local intro = CreateFrame("Frame", frame:GetName() .. "IntroMessage", frame)
				intro:SetSize(frame:GetSize())
				intro:SetAllPoints()
				
				local msg = intro:CreateFontString(nil, "OVERLAY")
				msg:SetFontObject(GUIS_SystemFontDisabled)
				msg:SetSize(intro:GetWidth()*9/10, intro:GetHeight()*9/10)
				msg:SetPoint("CENTER")
				msg:SetJustifyH("CENTER")
				
				msg:SetText(L["Select categories from the list on the left. |nYou can choose multiple categories at once to narrow down your search.|n|nSelected categories will be displayed on top of the listing, |nand clicking them again will deselect them!"])

				frame.intro = intro
			end
			
			frame.intro:Show()
		end
		
		frame:Update()
	end
end

-- updates the available tags based on the FAQ database
-- this will also reset the FAQ listing, and the selected tags
do
	local capitalize = function(first, rest)
	  return first:upper() .. rest:lower()
	end

	module.UpdateTags = function(self)
		wipe(tags)
		wipe(selectedTags)
		
		local count = 0
		
		local button, goodTag
		for _,faq in ipairs(faqs) do
			if (faq.tags) then
				for _,tag in ipairs(faq.tags) do
					goodTag = tag:gsub("(%a)([%w_']*)", capitalize)
					
					-- new unlisted tag?
					if not(tags[goodTag]) then
						count = count + 1
						
						-- get a button
						button = tagbuttons[count] or CreateTagButton()
						
						-- reset the button info, and update its display
						button:SetText(goodTag)
						button.selected = nil
						button:Update()
						
						-- put it in our tag button registry
						tagbuttons[count] = button
						
						tags[goodTag] = true
					end
				end
			end
		end
		
		currentFAQ = nil

		self:SortTags()
		self:DisplayList()
		self:ShowFAQList()
	end
end

-- function to switch to the FAQ listing
module.ShowFAQList = function(self)
	local frame = self.frame

	-- toggle frames
	frame.faqDisplay:Hide()
	frame.faqList:Show()

	-- toggle buttons
	frame.showList:Disable()

	if (currentFAQ) then
		frame.showFAQ:Enable()
	else
		frame.showFAQ:Disable()
	end
	
end

-- function to switch to the chosen FAQ display
module.ShowFAQDisplay = function(self)
	local frame = self.frame
	
	-- toggle frames
	frame.faqDisplay:Show()
	frame.faqList:Hide()
	
	-- toggle buttons
	frame.showList:Enable()
	frame.showFAQ:Disable()
end

module.CreateFrame = function(self)
	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])

	-- making all these calculations visible and through variables
	-- this is to make the process easier to understand and change in the future
	local w, h = 858, 660 -- ripping off the optionsmenu size here
	local edge = 16
	local scrollBarSize = 16
	local buttonHeight = 22
	
	-- main wrapper window
	local faqWindow = CreateFrame("Frame", self:GetName() .. "WrapperWindow", UIParent)
	faqWindow:Hide()
	faqWindow:SetUITemplate("simplebackdrop")
	faqWindow:SetSize(w, h)
	faqWindow:SetPoint("CENTER")
	faqWindow:SetFrameStrata("DIALOG")
	faqWindow:SetFrameLevel(110) -- this gets lowered sometime
	faqWindow:SetScript("OnShow", function(self) 
		module:UpdateTags()
	end)
	
	RegisterCallback("GUIS_INSTALL_SHOW", function() faqWindow:Hide() end)
	
	self.frame = faqWindow
	
	-- title element
	local title = faqWindow:CreateFontString(nil, "BACKGROUND")
	title:SetFontObject(GUIS_SystemFontLarge)
	title:SetPoint("TOP", 0, -edge)
	title:SetTextColor(unpack(C["value"]))
	title:SetHeight(1000)
	title:SetText(L["FAQ"])
	title:SetHeight(title:GetStringHeight() or 0)
	
	local subTitle = faqWindow:CreateFontString(nil, "BACKGROUND")
	subTitle:SetFontObject(GUIS_SystemFontTiny)
	subTitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
	subTitle:SetTextColor(unpack(C["index"]))
	subTitle:SetHeight(1000)
	subTitle:SetText(L["Frequently Asked Questions"])
	subTitle:SetHeight(subTitle:GetStringHeight() or 0)
	
	-- calculate the rest of the sizes
	local titleH = title:GetStringHeight() + subTitle:GetStringHeight()
	local headerH = edge + titleH + edge
	local footerH = edge/2 + buttonHeight + edge
	local sideBarW = (w - edge*3) * 1/4 - scrollBarSize
	local displayW = (w - edge*3) * 3/4 - scrollBarSize
	local displayH = (h - headerH - footerH)
	
	-- button to clear selected tag list
	local clear = CreateFrame("Button", self:GetName() .. "ClearSelectedTagsButton", faqWindow, "UIPanelButtonTemplate")
	clear:SetSize(sideBarW, buttonHeight)
	clear:SetPoint("BOTTOMLEFT", edge, edge)
	clear:SetUITemplate("button", true)
	clear:SetText(L["Clear All Tags"])
	clear:SetScript("OnClick", function(self) 
		module:ClearAllTags() 
	end)
	
	local showList = CreateFrame("Button", self:GetName() .. "ShowFAQListButton", faqWindow, "UIPanelButtonTemplate")
	showList:SetSize(sideBarW, buttonHeight)
	showList:SetPoint("LEFT", clear, "RIGHT", scrollBarSize + edge, 0)
	showList:SetUITemplate("button", true)
	showList:SetText(L["Return to the listing"])
	showList:SetScript("OnClick", function(self) 
		module:ShowFAQList()
	end)
	showList:Disable()
	faqWindow.showList = showList

	local showFAQ = CreateFrame("Button", self:GetName() .. "ShowFAQButton", faqWindow, "UIPanelButtonTemplate")
	showFAQ:SetSize(sideBarW, buttonHeight)
	showFAQ:SetPoint("LEFT", showList, "RIGHT", edge, 0)
	showFAQ:SetUITemplate("button", true)
	showFAQ:SetText(L["Show the current FAQ"])
	showFAQ:SetScript("OnClick", function(self) 
		module:ShowFAQDisplay()
	end)
	showFAQ:Disable()
	faqWindow.showFAQ = showFAQ

	local close = CreateFrame("Button", self:GetName() .. "CloseButton", faqWindow, "UIPanelButtonTemplate")
	close:SetSize(sideBarW, buttonHeight)
	close:SetPoint("LEFT", showFAQ, "RIGHT", edge, 0)
	close:SetUITemplate("button", true)
	close:SetText(L["Close"])
	close:SetScript("OnClick", function(self) 
		self:GetParent():Hide()
	end)

	local availableTagsWrapper = CreateFrame("Frame", self:GetName() .. "TagsWrapperWindow", faqWindow)
	availableTagsWrapper:SetSize(sideBarW, displayH)
	availableTagsWrapper:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	availableTagsWrapper:SetPoint("TOPLEFT", edge, -headerH)
	
	-- list of available tags
	local availableTags = CreateScrollFrame(self:GetName() .. "AvailableTags", availableTagsWrapper, sideBarW - 12, displayH - 12)
	availableTags:SetPoint("TOP", 0, -6)
	
	faqWindow.availableTags = availableTags

	local faqListWrapper = CreateFrame("Frame", self:GetName() .. "FAQWrapperWindow", faqWindow)
	faqListWrapper:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	faqListWrapper:SetSize(displayW, displayH)
	faqListWrapper:SetPoint("TOPLEFT", edge + sideBarW + scrollBarSize + edge, -headerH)

	-- list of faqs with the selected tags
	local faqList = CreateScrollFrame(self:GetName() .. "FAQListing", faqListWrapper, displayW - 12, displayH - 12)
	faqList:SetPoint("TOP", 0, -6)

	faqWindow.faqList = faqList

	-- the currently selected faq
	local faqDisplay = CreateScrollFrame(self:GetName() .. "FAQDisplay", faqListWrapper, displayW - 12, displayH - 12)
	faqDisplay:Hide()
	faqDisplay:SetAllPoints(faqList)
	faqWindow.faqDisplay = faqDisplay
	
	-- make it closable with Esc
	tinsert(UISpecialFrames, faqWindow:GetName())
end

module.Show = function(self)
	if not(self.frame) then
		self:CreateFrame()
	end
	
	self.frame:Show()
end

module.Hide = function(self)
	if not(self.frame) then
		return
	end
	
	self.frame:Hide()
end

module.IsShown = function(self)
	return (self.frame) and (self.frame:IsShown())
end

module.RestoreDefaults = function(self)
	GUIS_DB["faq"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["faq"] = GUIS_DB["faq"] or {}
	GUIS_DB["faq"] = ValidateTable(GUIS_DB["faq"], defaults)
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill() 
		return 
	end
	
	local show = function() 
		PlaySound("igMainMenuOption")
		securecall("CloseAllWindows")
		
		module:Show()
	end

	-- add a menu button for the FAQ module
	F.AddGameMenuButton("GUIS_FAQ", L["FAQ"], show)
		
	-- the chat command
	CreateChatCommand(show, "faq")
end
