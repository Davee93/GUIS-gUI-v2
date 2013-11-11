--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningCalendar")

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

	local SkinFunc = function()
		local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
		
		CalendarFrame:RemoveTextures()
		CalendarTodayFrame:RemoveTextures()
		CalendarEventPickerCloseButton:RemoveTextures()
		CalendarEventPickerTitleFrame:RemoveTextures()
		CalendarEventPickerFrame:RemoveTextures()
		CalendarViewEventInviteListSection:RemoveTextures()
		CalendarViewEventInviteList:RemoveTextures()
		CalendarViewEventDescriptionContainer:RemoveTextures()
		CalendarViewEventFrame:RemoveTextures()
		CalendarViewHolidayFrame:RemoveTextures(true)
		CalendarViewHolidayTitleFrame:RemoveTextures()
		CalendarViewRaidFrame:RemoveTextures()
		CalendarViewRaidTitleFrame:RemoveTextures()
		CalendarMassInviteFrame:RemoveTextures()
		CalendarMassInviteTitleFrame:RemoveTextures()
		CalendarTexturePickerFrame:RemoveTextures()
		CalendarTexturePickerTitleFrame:RemoveTextures()
		CalendarCreateEventInviteListSection:RemoveTextures()
		CalendarCreateEventDescriptionContainer:RemoveTextures()
		CalendarCreateEventInviteList:RemoveTextures()
		CalendarCreateEventFrame:RemoveTextures()
		CalendarCreateEventTitleFrame:RemoveTextures()
		CalendarFilterFrame:RemoveTextures()
		CalendarCreateEventCloseButton:RemoveTextures()
		CalendarViewRaidCloseButton:RemoveTextures()
		CalendarViewHolidayCloseButton:RemoveTextures()
		CalendarMassInviteCloseButton:RemoveTextures()
		CalendarCreateEventCloseButton:RemoveTextures()
		
		CalendarNextMonthButton:SetUITemplate("arrow", "right")
		CalendarPrevMonthButton:SetUITemplate("arrow", "left")
		CalendarFilterButton:SetUITemplate("arrow", "down")
		
		CalendarCreateEventCreateButton:SetUITemplate("button", true)
		CalendarCreateEventMassInviteButton:SetUITemplate("button", true)
		CalendarCreateEventInviteButton:SetUITemplate("button", true)
		CalendarTexturePickerAcceptButton:SetUITemplate("button", true)
		CalendarTexturePickerCancelButton:SetUITemplate("button", true)
		CalendarCreateEventInviteButton:SetUITemplate("button", true)
		CalendarCreateEventRaidInviteButton:SetUITemplate("button", true)
		CalendarMassInviteGuildAcceptButton:SetUITemplate("button", true)
		CalendarMassInviteArenaButton2:SetUITemplate("button", true)
		CalendarMassInviteArenaButton3:SetUITemplate("button", true)
		CalendarMassInviteArenaButton5:SetUITemplate("button", true)
		CalendarViewEventAcceptButton:SetUITemplate("button", true)
		CalendarViewEventTentativeButton:SetUITemplate("button", true)
		CalendarViewEventRemoveButton:SetUITemplate("button", true)
		CalendarViewEventDeclineButton:SetUITemplate("button", true)
		CalendarEventPickerCloseButton:SetUITemplate("closebutton")

		CalendarCreateEventLockEventCheck:SetUITemplate("checkbutton")
		
		CalendarCloseButton:SetUITemplate("closebutton", "TOPRIGHT", CalendarFrame, -8, -8)
		CalendarViewEventCloseButton:SetUITemplate("closebutton")
		CalendarViewRaidCloseButton:SetUITemplate("closebutton")
		CalendarViewHolidayCloseButton:SetUITemplate("closebutton")
		CalendarMassInviteCloseButton:SetUITemplate("closebutton")
		CalendarCreateEventCloseButton:SetUITemplate("closebutton")
		
		CalendarCreateEventHourDropDown:RemoveTextures()
		CalendarCreateEventMinuteDropDown:RemoveTextures()
		CalendarCreateEventAMPMDropDown:RemoveTextures()
		CalendarCreateEventRepeatOptionDropDown:RemoveTextures()
		CalendarCreateEventTypeDropDown:RemoveTextures()
		
		CalendarCreateEventHourDropDown:SetUITemplate("dropdown", true, 80)
		CalendarCreateEventMinuteDropDown:SetUITemplate("dropdown", true, 80)
		CalendarCreateEventAMPMDropDown:SetUITemplate("dropdown", true)
		CalendarCreateEventRepeatOptionDropDown:SetUITemplate("dropdown", true)
		CalendarMassInviteGuildRankMenu:SetUITemplate("dropdown", true)
		CalendarCreateEventTypeDropDown:SetUITemplate("dropdown", true)
		
		CalendarCreateEventInviteEdit:SetUITemplate("editbox", 0, 0, 0, -12):SetBackdropColor(r, g, b, panelAlpha)
		CalendarCreateEventTitleEdit:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		CalendarMassInviteGuildMinLevelEdit:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		CalendarMassInviteGuildMaxLevelEdit:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		
		CalendarFrame:SetUITemplate("backdrop")
		CalendarCreateEventFrame:SetUITemplate("backdrop")
		CalendarCreateEventInviteList:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CalendarCreateEventDescriptionContainer:SetUITemplate("backdrop"):SetBackdropColor(r, g, b, panelAlpha)
		CalendarTexturePickerFrame:SetUITemplate("backdrop")
		CalendarMassInviteFrame:SetUITemplate("backdrop", nil, 0, 0, 0, 30)
		CalendarViewRaidFrame:SetUITemplate("backdrop")
		CalendarViewHolidayFrame:SetUITemplate("backdrop")
		CalendarViewEventFrame:SetUITemplate("backdrop")
		CalendarViewEventDescriptionContainer:SetUITemplate("backdrop")
		CalendarViewEventInviteList:SetUITemplate("backdrop")
		CalendarEventPickerFrame:SetUITemplate("backdrop")
		
		CalendarTexturePickerScrollBar:SetUITemplate("scrollbar")
		CalendarViewEventInviteListScrollFrameScrollBar:SetUITemplate("scrollbar")
		CalendarEventPickerScrollBar:SetUITemplate("scrollbar")
		
		CalendarContextMenu:SetBackdrop(M["Backdrop"]["PixelBorder-Satin"])
		CalendarContextMenu:SetBackdropColor(unpack(C["overlay"]))
		CalendarContextMenu:SetBackdropBorderColor(unpack(C["border"]))
	
		CalendarInviteStatusContextMenu:SetBackdrop(M["Backdrop"]["PixelBorder-Satin"])
		CalendarInviteStatusContextMenu:SetBackdropColor(unpack(C["overlay"]))
		CalendarInviteStatusContextMenu:SetBackdropBorderColor(unpack(C["border"]))
		
		CalendarCreateEventIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		CalendarCreateEventIcon.SetTexCoord = noop
	
		CalendarTodayFrame:SetUITemplate("targetborder")
		CalendarTodayFrame:SetSize(CalendarDayButton1:GetSize())

		-- CALENDAR_MAX_DAYS_PER_MONTH
		for i = 1, 42 do

			local button = _G["CalendarDayButton" .. i]
			button:SetFrameLevel(button:GetFrameLevel() + 1)
			button:GetHighlightTexture():SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 1/3)

			local backdrop = button:SetUITemplate("backdrop")
			backdrop:SetBackdropColor(r, g, b, panelAlpha)

			button:GetHighlightTexture():ClearAllPoints()
			button:GetHighlightTexture():SetPoint("TOPLEFT", backdrop, "TOPLEFT", 3, -3)
			button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -3, 3)
			
			button:GetNormalTexture():ClearAllPoints()
			button:GetNormalTexture():SetPoint("TOPLEFT", backdrop, "TOPLEFT", 3, -3)
			button:GetNormalTexture():SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -3, 3)
			
			-- this kills the blizzard background, and makes our standard satin texture a bit more interesting
			button:GetNormalTexture():SetTexture(M["Background"]["MildSatin"])
			button:GetNormalTexture():SetVertexColor(r, g, b, 1/3)
			button:GetNormalTexture():SetTexCoord(random(0, 35) * 1/100, random(65, 100) * 1/100, random(0, 35) * 1/100, random(65, 100) * 1/100)
			button:GetNormalTexture().SetTexCoord = noop
			button:GetNormalTexture().SetTexture = noop
			
			_G[button:GetName() .. "DarkFrame"]:SetAlpha(2/3)

			_G[button:GetName() .. "OverlayFrame"]:ClearAllPoints()
			_G[button:GetName() .. "OverlayFrame"]:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 3, -3)
			_G[button:GetName() .. "OverlayFrame"]:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -3, 3)

			_G[button:GetName() .. "EventTexture"]:ClearAllPoints()
			_G[button:GetName() .. "EventTexture"]:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 3, -3)
			_G[button:GetName() .. "EventTexture"]:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -3, 3)

			_G[button:GetName() .. "EventBackgroundTexture"]:ClearAllPoints()
			_G[button:GetName() .. "EventBackgroundTexture"]:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 3, -3)
			_G[button:GetName() .. "EventBackgroundTexture"]:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -3, 3)
			
			_G[button:GetName() .. "PendingInviteTexture"]:ClearAllPoints()
			_G[button:GetName() .. "PendingInviteTexture"]:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 3, -3)
			_G[button:GetName() .. "PendingInviteTexture"]:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -3, 3)

			button:SetWidth(button:GetWidth() - 8)
			button:SetHeight(button:GetHeight() - 8)
			button:ClearAllPoints()

			if ( i == 1 ) then
				button:SetPoint("TOPLEFT", CalendarWeekday1Background, "BOTTOMLEFT", 4, -4)
			elseif ( i % 7 == 1 ) then
				button:SetPoint("TOPLEFT", _G["CalendarDayButton" .. (i - 7)], "BOTTOMLEFT", 0, -8)
			else
				button:SetPoint("TOPLEFT", _G["CalendarDayButton" .. (i - 1)], "TOPRIGHT", 8, 0)
			end
			
			local font, size, style = _G[button:GetName() .. "DateFrameDate"]:GetFont()
			_G[button:GetName() .. "DateFrameDate"]:SetFont(font, size, "THINOUTLINE")

			-- CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS
			for event = 1, 4 do
				eventButton = _G[button:GetName() .. "EventButton" .. event]
				
				if (eventButton) then
					eventButton:SetWidth(eventButton:GetWidth() - 8)
					
					font, size, style = _G[eventButton:GetName() .. "Text1"]:GetFont()
					_G[eventButton:GetName() .. "Text1"]:SetFont(font, size, "THINOUTLINE")
				
					font, size, style = _G[eventButton:GetName() .. "Text2"]:GetFont()
					_G[eventButton:GetName() .. "Text2"]:SetFont(font, size, "THINOUTLINE")

					eventButton:GetHighlightTexture():SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 1/3)
					_G[eventButton:GetName() .. "Black"]:SetTexture(C["pushed"].r, C["pushed"].g, C["pushed"].b, 1/3)
				end
			end
		end
		
		local once
		local updateClassButtons = function()
			if (once) then
				return
			end
			
			for i, class in ipairs(CLASS_SORT_ORDER) do
				local button = _G["CalendarClassButton" .. i]
				
				button:RemoveTextures()
				button:SetUITemplate("simplebackdrop")
				
				local tcoords = CLASS_ICON_TCOORDS[class]
				button:GetNormalTexture():SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
				button:GetNormalTexture():SetTexCoord(tcoords[1] + 5/256, tcoords[2] - 5/256, tcoords[3] + 5/256, tcoords[4] - 5/256)
			end
			
			CalendarClassTotalsButton:RemoveTextures()
			CalendarClassTotalsButton:SetUITemplate("backdrop", nil, -3, -6, -3, -6)
			
			once = true
		end
		CalendarClassButtonContainer:HookScript("OnShow", updateClassButtons)
	
	end
	F.SkinAddOn("Blizzard_Calendar", SkinFunc)
end
