--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Minimap")

-- Lua API
local format = string.format
local pairs, unpack = pairs, unpack
local setmetatable = setmetatable

-- WoW API
local CalendarGetNumPendingInvites = CalendarGetNumPendingInvites
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local GetSubZoneText = GetSubZoneText
local GetZonePVPInfo = GetZonePVPInfo
local GetZoneText = GetZoneText
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsInInstance = IsInInstance
local IsAddOnLoaded = IsAddOnLoaded
local LoadAddOn = LoadAddOn
local tDeleteItem = tDeleteItem
local ToggleAchievementFrame = ToggleAchievementFrame
local ToggleCharacter = ToggleCharacter
local ToggleFrame = ToggleFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleHelpFrame = ToggleHelpFrame
local UIFrameFade = UIFrameFade
local UIFrameFadeRemoveFrame = UIFrameFadeRemoveFrame
local UIFrameIsFading = UIFrameIsFading
local UIFrameIsFlashing = UIFrameIsFlashing
local UIFrameFlash = UIFrameFlash
local UnitLevel = UnitLevel

local Minimap = Minimap

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local CreateUIPanel = function(...) return LibStub("gPanel-2.0"):CreateUIPanel(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local RegisterBucketEvent = function(...) return module:RegisterBucketEvent(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end
local gFH = LibStub("gFrameHandler-1.0")

-- simple 4.3 namechange fix that is backwards compatible
local LFGSearchStatus = LFGSearchStatus or LFDSearchStatus

local ACHIEVEMENT_BUTTON = L["Achievements"]
local CHARACTER_BUTTON = L["Character Info"]
local DUNGEONS_BUTTON = L["Dungeon Finder"]
local ENCOUNTER_JOURNAL = L["Dungeon Journal"]
local ERR_RESTRICTED_ACCOUNT = L["Starter Edition accounts cannot perform that action"]
local GUILD = L["Guild"]
local HELP_BUTTON = L["Customer Support"]
local LOOKINGFORGUILD = _G.LOOKINGFORGUILD and L["Guild Finder"] or L["You're not currently a member of a Guild"]
local LOOKING_FOR_RAID = L["Raid Finder"]
local MAINMENU_BUTTON = L["Game Menu"]
local PLAYER_V_PLAYER = L["Player vs Player"]
local QUESTLOG_BUTTON = L["Quest Log"]
local RAID = L["Raid"]
local SPELLBOOK_ABILITIES_BUTTON = L["Spellbook & Abilities"]
local TALENTS_BUTTON = L["Talents"]
local TALENTS_UNAVAILABLE_TOOLTIP = L["This feature becomes available once you earn a Talent Point."]

local SANCTUARY_TERRITORY = L["(Sanctuary)"]
local FREE_FOR_ALL_TERRITORY = L["(PvP Area)"]
local FACTION_CONTROLLED_TERRITORY = L["(%s Territory)"]
local CONTESTED_TERRITORY = L["(Contested Territory)"]
local COMBAT_ZONE = L["(Combat Zone)"]
local SOCIAL_BUTTON = L["Social"]

local createShowHookAndHide, adopt
local initMinimapIcons, updateMinimapIcons, positionIcon
local UpdateCoordinates, UpdateZoneText, UpdateInstanceDifficulty, UpdateNewCalendarEvent

-- icons
local points = {
	["TOP"] = { 1, -1 };
	["BOTTOM"] = { 1, 1 };
	["LEFT"] = { 1, 1 };
	["RIGHT"] = { -1, 1 };
	["CENTER"] = { 1, 1 };
	["TOPLEFT"] = { 1, -1 };
	["TOPRIGHT"] = { -1, -1 };
	["BOTTOMLEFT"] = { 1, 1 };
	["BOTTOMRIGHT"] = { -1, 1 };
}

local insets = {
	instanceDifficulty = { X = 0, Y = 0 };
	lfg = { X = 2, Y = 2 };
	mail = { X = 0, Y = 16 };
	pvp = { X = 2, Y = 2 };
	tracking = { X = 0, Y = 0 };
	voice = { X = 2, Y = 2 };
	worldMap = { X = 2, Y = 30 };
}

local db = {
	instanceDifficulty = { enable = false, point = "TOPLEFT"};
	lfg = { enable = true, point = "BOTTOMLEFT"};
	mail = { enable = true, point = "BOTTOM"};
	pvp = { enable = true, point = "BOTTOMRIGHT"}; -- moving it. we can queue for TB and Dungeons at the same time
	tracking = { enable = false, point = "LEFT"};
	voice = { enable = false, point = "TOPRIGHT"};
	worldMap = { enable = false, point = "TOPRIGHT"};
};

local defaults = {
	useMouseWheelZoom = true;
	showCoordinates = true;
	showClock = true;
	showInstanceDifficultyOverlay = true;
	showMiddleClickMenu = true;
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
				msg = L["The Minimap is a miniature map of your closest surrounding areas, allowing you to easily navigate as well as quickly locate elements such as specific vendors, or a herb or ore you are tracking. If you wish to change the position of the Minimap, you can unlock it for movement with |cFF4488FF/glock|r."];
			};
			{
				type = "group";
				order = 5;
				virtual = true;
				children = {
					{ -- clock
						type = "widget";
						element = "CheckButton";
						name = "showClock";
						order = 1;
						width = "full"; 
						msg = L["Display the clock"];
						desc = nil;
						set = function(self) 
							GUIS_DB.minimap.showClock = not(GUIS_DB.minimap.showClock)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.minimap.showClock end;
					};
					{ -- coordinates
						type = "widget";
						element = "CheckButton";
						name = "showCoordinates";
						order = 5;
						width = "full"; 
						msg = L["Display the current player coordinates on the Minimap when available"];
						desc = nil;
						set = function(self) 
							GUIS_DB.minimap.showCoordinates = not(GUIS_DB.minimap.showCoordinates)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.minimap.showCoordinates end;
					};
					{ -- mousewheelzoom
						type = "widget";
						element = "CheckButton";
						name = "useMouseWheelZoom";
						order = 10;
						width = "full"; 
						msg = L["Use the Mouse Wheel to zoom in and out"];
						desc = nil;
						set = function(self) 
							GUIS_DB.minimap.useMouseWheelZoom = not(GUIS_DB.minimap.useMouseWheelZoom)
						end;
						get = function() return GUIS_DB.minimap.useMouseWheelZoom end;
					};
					{ -- blizzard: rotate minimap
						type = "widget";
						element = "CheckButton";
						name = "rotateMinimap";
						order = 11;
						width = "full"; 
						msg = L["Rotate Minimap"];
						desc = L["Check this to rotate the entire minimap instead of the player arrow."];
						set = function(self) 
--							ToggleMiniMapRotation()
							SetCVar("rotateMinimap", (tonumber(GetCVar("rotateMinimap")) == 1) and 0 or 1)
							--InterfaceOptionsDisplayPanelRotateMinimap.cvar
							Minimap_UpdateRotationSetting()
						end;
						get = function() return tonumber(GetCVar("rotateMinimap")) == 1 end;
					};	
					{ -- instance difficulty overlay
						type = "widget";
						element = "CheckButton";
						name = "showInstanceDifficultyOverlay";
						order = 15;
						width = "full"; 
						msg = L["Display the difficulty of the current instance when hovering over the Minimap"];
						desc = nil;
						set = function(self) 
							GUIS_DB.minimap.showInstanceDifficultyOverlay = not(GUIS_DB.minimap.showInstanceDifficultyOverlay)
						end;
						get = function() return GUIS_DB.minimap.showInstanceDifficultyOverlay end;
					};
					{ -- middleclick menu
						type = "widget";
						element = "CheckButton";
						name = "showMiddleClickMenu";
						order = 20;
						width = "full"; 
						msg = L["Display the shortcut menu when clicking the middle mouse button on the Minimap"];
						desc = nil;
						set = function(self) 
							GUIS_DB.minimap.showMiddleClickMenu = not(GUIS_DB.minimap.showMiddleClickMenu)
						end;
						get = function() return GUIS_DB.minimap.showMiddleClickMenu end;
					};
				};
			};
		};
	};
}

local faq = {
	{
		q = L["I can't find the Calendar!"];
		a = {
			{
				type = "text";
				msg = L["You can open the calendar by clicking the middle mouse button while hovering over the Minimap, or by assigning a keybind to it in the Blizzard keybinding interface avaiable from the GameMenu. The Calendar keybind is located far down the list, along with the GUIS keyinds."];
			};
			{
				type = "image";
				w = 256; h = 256;
				path = M["Texture"]["Minimap-Calendar"]
			};
		};
		tags = { "minimap", "calendar" };
	};
	{
		q = L["Where can I see the current dungeon- or raid difficulty and size when I'm inside an instance?"];
		a = {
			{
				type = "text";
				msg = L["You can see the maximum size of your current group by hovering the cursor over the Minimap while being inside an instance. If you currently have activated Heroic mode, a skull will be visible next to the size display as well."];
			};
		};
		tags = { "minimap", "party", "raid" };
	};
	{
		q = L["How can I move the Minimap?"];
		a = {
			{ 
				type = "text";  
				msg = L["You can manually move the Minimap as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key."];
			};
			{
				type = "image";
				w = 512; h = 256;
				path = M["Texture"]["Core-FrameLock"]
			};
		};
		tags = { "minimap", "positioning" };
	};
}

createShowHookAndHide = function(object)
	if (object.BlizzardShow) then return end
	
	object.BlizzardShow = object.Show
	object.Show = object.Hide
	object:Hide()
end

adopt = function(object)
	if not(object) then return end

	object:SetParent(Minimap)
	object.SetParent = noop
end

positionIcon = function(object, frame)
	local db = db
	if not(db[object]) or not(frame) then
		return
	end
	
	frame:ClearAllPoints()
	frame:SetPoint(db[object].point, insets[object].X * points[db[object].point][1], insets[object].Y * points[db[object].point][2])
end

--
-- update the coordinate display
UpdateCoordinates = function()
	if (not GUIS_DB["minimap"].showCoordinates) or (not Minimap.Coordinates:IsVisible()) then 
		return 
	end
	
	local x, y = GetPlayerMapPosition("player")
	if ((x == 0) and (y == 0)) or not x or not y then
		Minimap.Coordinates:SetAlpha(0)
	else
		Minimap.Coordinates:SetAlpha(1)
		Minimap.Coordinates:SetFormattedText("%.2f %.2f", x*100, y*100)
	end
end

--
-- update the zone title
UpdateZoneText = function(self, event, ...)
	Minimap.ZoneText:SetText(GetMinimapZoneText())

	local pvpType, isSubZonePvP, factionName = GetZonePVPInfo()
	if (pvpType == "sanctuary") then
		Minimap.ZoneText:SetTextColor(0.41, 0.8, 0.94)
		
	elseif (pvpType == "arena") then
		Minimap.ZoneText:SetTextColor(1.0, 0.1, 0.1)
		
	elseif (pvpType == "friendly") then
		Minimap.ZoneText:SetTextColor(0.1, 1.0, 0.1)
		
	elseif (pvpType == "hostile") then
		Minimap.ZoneText:SetTextColor(1.0, 0.1, 0.1)
		
	elseif (pvpType == "contested") then
		Minimap.ZoneText:SetTextColor(1.0, 0.7, 0.0)
		
	elseif (pvpType == "combat") then
		Minimap.ZoneText:SetTextColor(1.0, 0.1, 0.1)
		
	else
		Minimap.ZoneText:SetTextColor(1.0, 0.9294, 0.7607)
	end
end

--
-- update the instance difficulty
UpdateInstanceDifficulty = function(self, event, ...)
	local inInstance, instanceType = IsInInstance()

	if (GUIS_DB["minimap"].showInstanceDifficultyOverlay) then 

		local text = ""

		if inInstance then
			local name, type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic = GetInstanceInfo()
			
			local isHeroic
			if (instanceType == "party") then
				if (difficultyIndex == 1) then
					text = "5"
				elseif (difficultyIndex == 2) then
					text = "5"
					isHeroic = true
				end
			elseif (instanceType == "raid") then
				if (difficultyIndex == 1) then
					if (maxPlayers == 40) then
						text = "40"
					else
						text = "10"
					end
				elseif (difficultyIndex == 2) then
					text = "25"
				elseif (difficultyIndex == 3) then
					text = "10" 
					isHeroic = true
				elseif (difficultyIndex == 4) then
					text = "25"
					isHeroic = true
				end
			end
			
			--
			-- for instances with dynamic difficulty, where the difficulty can be changed inside
			-- (Icecrown Citadel)
			if isDynamic then
				if (dynamicDifficulty == 1) then
					isHeroic = true
				end
			end
			
			--
			-- add the heroic skull icon if this is any form of heroic
			if isHeroic then 
				text = text .. M["IconString"]["HeroicSkull"]
			end
		end
		
		if (Minimap.InstanceDifficulty) then
			Minimap.InstanceDifficulty:SetText(text)
		end
		
		if (GuildInstanceDifficulty) then 
			if (GuildInstanceDifficulty:IsShown()) then
				if (not GuildInstanceDifficulty.BlizzardShow) then
					createShowHookAndHide(GuildInstanceDifficulty)
				end
				GuildInstanceDifficulty:Hide()
			end
		end

	else
		if (Minimap.InstanceDifficulty) then
			Minimap.InstanceDifficulty:SetText("")
		end
	
		if (not GuildInstanceDifficulty) then return end
		
		if (not GuildInstanceDifficulty.BlizzardShow) then
			createShowHookAndHide(GuildInstanceDifficulty)
		end

		if (inInstance) and ((instanceType == "party") or (instanceType == "raid")) then
			GuildInstanceDifficulty:BlizzardShow()
		else
			GuildInstanceDifficulty:Hide()
		end
	end
end

--
-- update the new calendar event notifications
UpdateNewCalendarEvent = function(self, event, ...)
	local pendingCalendarInvites = CalendarGetNumPendingInvites()
	if (pendingCalendarInvites > (Minimap.NewEvent.pendingCalendarInvites or 0)) then
		if (not CalendarFrame) or (CalendarFrame and not CalendarFrame:IsShown()) then
			-- stop the fading if it's currently fading out
			if (UIFrameIsFading(Minimap.NewEvent)) then 
				UIFrameFadeRemoveFrame(Minimap.NewEvent)
			end
			
			-- start a flash, to get the users attention
			-- this flash will continue for 24 hours, or basically "forever"
			-- it will be cancelled when there are no more unanswered events
			UIFrameFlash(Minimap.NewEvent, 1.5, 1.5, 86402, true, 1.5, 0.5)

			Minimap.NewEvent.pendingCalendarInvites = pendingCalendarInvites
		end
		Minimap.NewEventText:SetText(L["New Event!"])
		
	elseif (pendingCalendarInvites == 0) then
		Minimap.NewEvent.pendingCalendarInvites = 0

		-- the frame will be hidden eventually, but we want it to be smooth
		if (Minimap.NewEvent:IsShown()) then
			-- stop the flashing, but let it remain at its ending Alpha
			if (UIFrameIsFlashing(Minimap.NewEvent)) then
				local frame = Minimap.NewEvent
				
				-- stolen from the function UIFrameFlashStop in UIParent.lua, 
				-- but without the forced Show/Hide at the end
				tDeleteItem(FLASHFRAMES, frame)
				frame.flashTimer = nil
				if (frame.syncId) then
					UIFrameFlashTimerRefCount[frame.syncId] = UIFrameFlashTimerRefCount[frame.syncId]-1
					if UIFrameFlashTimerRefCount[frame.syncId] == 0 then
						UIFrameFlashTimers[frame.syncId] = nil
						UIFrameFlashTimerRefCount[frame.syncId] = nil
					end
					frame.syncId = nil
				end
			end
			
			-- fade out the frame, if it's not already fading
			if (not UIFrameIsFading(Minimap.NewEvent)) then
				local fadeInfo = {}
				fadeInfo.mode = "OUT"
				fadeInfo.startAlpha = Minimap.NewEvent:GetAlpha()
				fadeInfo.endAlpha = 0
				fadeInfo.timeToFade = Minimap.NewEvent:GetAlpha() * 1.5
				fadeInfo.finishedFunc = function() 
					Minimap.NewEvent:Hide() 
					Minimap.NewEventText:SetText("")
				end

				UIFrameFade(Minimap.NewEvent, fadeInfo)
			end
		end
	end
end

local iconsInitialized, updateMinimapIcons
initMinimapIcons = function()
	if (iconsInitialized) then return end
	
	adopt(MiniMapBattlefieldFrame)
	adopt(MinimapNorthTag)
	adopt(MiniMapTracking)
	adopt(MiniMapVoiceChatFrame)
	adopt(MiniMapWorldMapButton)
	adopt(MinimapZoomIn)
	adopt(MinimapZoomOut)
	adopt(MiniMapLFGFrame)
	adopt(MiniMapMailFrame)
	adopt(MiniMapTrackingButton)
	adopt(LFGSearchStatus)
	adopt(MiniMapInstanceDifficulty)

	createShowHookAndHide(GameTimeFrame)
	createShowHookAndHide(MiniMapInstanceDifficulty)
	createShowHookAndHide(MinimapNorthTag)
	createShowHookAndHide(MiniMapTracking)
	createShowHookAndHide(MiniMapTrackingButton)
	createShowHookAndHide(MiniMapVoiceChatFrame)
	createShowHookAndHide(MiniMapWorldMapButton)
	createShowHookAndHide(MinimapZoomIn)
	createShowHookAndHide(MinimapZoomOut)

	MiniMapMailFrame:SetSize(24, 24)
	MiniMapMailIcon:SetTexture(M["Icon"]["MailBox"])
	MiniMapMailIcon:SetAllPoints(MiniMapMailFrame)

	MiniMapTrackingButton:SetSize(24, 24)
	MiniMapTrackingButton:SetHighlightTexture("")
	MiniMapTrackingButton:SetPushedTexture("")
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)

	-- MoP beta edits
	if (MiniMapBattlefieldFrame) then 
		MiniMapBattlefieldFrame:SetSize(24, 24)
	end
	
	if (MiniMapLFGFrame) then
		MiniMapLFGFrame:SetSize(24, 24)
	end
	
	iconsInitialized = true
	
	-- update the icons according to user settings
	updateMinimapIcons()
end

updateMinimapIcons = function()
	if not(iconsInitialized) then 
		initMinimapIcons()
		return
	end
	
	local db = db
	
	if (db["tracking"].enable) then
		positionIcon("tracking", MiniMapTrackingButton)

		MiniMapTracking:SetAllPoints(MiniMapTrackingButton)
		MiniMapTracking:BlizzardShow()
		MiniMapTrackingButton:BlizzardShow()
	else
		MiniMapTracking:Hide()
		MiniMapTrackingButton:Hide()
	end
	
	if (db["instanceDifficulty"].enable) then
		positionIcon("instanceDifficulty", MiniMapInstanceDifficulty)
		UpdateInstanceDifficulty()
	else
		MiniMapInstanceDifficulty:Hide()
	end
	
	if (db["mail"].enable) then
		positionIcon("mail", MiniMapMailFrame)
	end
	
	positionIcon("pvp", MiniMapBattlefieldFrame)
	positionIcon("lfg", MiniMapLFGFrame)
end

module.UpdateAll = function(self)
	if (GUIS_DB.minimap.showCoordinates) then
		insets.mail.Y = 16
		Minimap.Coordinates:Show()
	else
		insets.mail.Y = 2
		Minimap.Coordinates:Hide()
	end

	if (GUIS_DB.minimap.showClock) then
		TimeManagerClockButton:Show()
	else
		TimeManagerClockButton:Hide()
	end

	updateMinimapIcons()
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["minimap"] = DuplicateTable(defaults)
	
	self:UpdateAll()
end

module.Init = function(self)
	GUIS_DB["minimap"] = GUIS_DB["minimap"] or {}
	GUIS_DB["minimap"] = ValidateTable(GUIS_DB["minimap"], defaults)
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill()
		return 
	end
	
	--
	-- skin and style the main frame, fix its strata
	do
		Minimap:SetParent(UIParent)
		Minimap:SetFrameStrata("LOW")
		Minimap:SetFrameLevel(20)
		Minimap:SetSize(160, 160)
		Minimap:SetMaskTexture(M["Background"]["Blank"])
		Minimap:PlaceAndSave("TOPLEFT", UIParent, "TOPLEFT", 11, -11)
		Minimap:SetUITemplate("backdrop")
		
		local darkener = Minimap:CreateTexture()
		darkener:SetDrawLayer("BORDER", 1)
		darkener:SetTexture(0, 0, 0)
		darkener:SetAlpha(1/4)
		darkener:ClearAllPoints()
		darkener:SetPoint("TOPLEFT", -1, 1)
		darkener:SetPoint("BOTTOMRIGHT", 1, -1)
		Minimap.darkTexture = darkener

		local shade = Minimap:CreateTexture()
		shade:SetDrawLayer("BORDER", 2)
		shade:SetTexture(M["Button"]["LargeShade"])
		shade:SetVertexColor(0, 0, 0)
		shade:SetAlpha(1/2)
		shade:ClearAllPoints()
		shade:SetPoint("TOPLEFT", -1, 1)
		shade:SetPoint("BOTTOMRIGHT", 1, -1)
		Minimap.shadeTexture = shade
	end
	
	-- 
	-- allow the mousewheel to zoom in/out
	do
		Minimap:EnableMouseWheel(true)
		Minimap:SetScript("OnMouseWheel", function(self, d)
			if (not GUIS_DB["minimap"].useMouseWheelZoom) then return end
			
			if (d > 0) then
				Minimap:SetZoom(min(Minimap:GetZoomLevels(), Minimap:GetZoom() + 1))
			elseif (d < 0) then
				Minimap:SetZoom(max(0, Minimap:GetZoom() - 1))
			end
		end)
	end

	--
	-- make sure the clock is loaded
	-- this is far simpler then waiting for it
	if not(IsAddOnLoaded("Blizzard_TimeManager")) then 
		LoadAddOn("Blizzard_TimeManager")
	end
	
	--
	-- hide objects we don't want
	do
		local hiddenObjects = { 
			MiniMapBattlefieldBorder; 
			MinimapBorder; 
			MinimapBorderTop; 
			MinimapCluster;
			MiniMapLFGFrameBorder; 
			MiniMapMailBorder; 
			MiniMapTrackingBackground;
			MiniMapTrackingButtonBorder;
			MiniMapTrackingIconOverlay;
			MinimapZoneTextButton;
		}
		for i,v in pairs(hiddenObjects) do 
			if (v.SetTexture) then 
				v:SetTexture("")
				v.SetTexture = noop
			else
				v:Kill()
			end
		end
		
		hiddenObjects = nil
	end

	-- create our own zone text button
	do
		Minimap.ZoneText = Minimap:CreateFontString(nil, "OVERLAY")
		Minimap.ZoneText:ClearAllPoints()
		Minimap.ZoneText:SetPoint("TOP", Minimap, "TOP", 0, -2)
		Minimap.ZoneText:SetWidth(Minimap:GetWidth() - 4)
		Minimap.ZoneText:SetNonSpaceWrap(false)
		Minimap.ZoneText:SetFontObject(GUIS_SystemFontNormal) -- NumberFont_Outline_Med
		Minimap.ZoneText:SetJustifyH("CENTER")
		
		Minimap.ZoneTextButton = CreateFrame("Frame", nil, Minimap)
		Minimap.ZoneTextButton:SetAllPoints(Minimap.ZoneText)
		Minimap.ZoneTextButton:EnableMouse(true)
		
		Minimap.ZoneTextButton:SetScript("OnEnter", function() 
			local pvpType, isSubZonePvP, factionName = GetZonePVPInfo()
			local zoneName = GetZoneText()
			local subzoneName = GetSubZoneText()
			
			if (subzoneName == zoneName) then
				subzoneName = ""	
			end
			
			GameTooltip:SetOwner(Minimap, "ANCHOR_PRESERVE")
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 12, 0)
			GameTooltip:AddLine(zoneName, 1.0, 1.0, 1.0 )
			
			if (pvpType == "sanctuary") then
				GameTooltip:AddLine(subzoneName, 0.41, 0.8, 0.94 )	
				GameTooltip:AddLine(SANCTUARY_TERRITORY, 0.41, 0.8, 0.94)
				
			elseif (pvpType == "arena") then
				GameTooltip:AddLine(subzoneName, 1.0, 0.1, 0.1 )	
				GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, 1.0, 0.1, 0.1)
				
			elseif (pvpType == "friendly") then
				GameTooltip:AddLine(subzoneName, 0.1, 1.0, 0.1 )
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 0.1, 1.0, 0.1)
				
			elseif (pvpType == "hostile") then
				GameTooltip:AddLine(subzoneName, 1.0, 0.1, 0.1 );	
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 1.0, 0.1, 0.1)
				
			elseif (pvpType == "contested") then
				GameTooltip:AddLine(subzoneName, 1.0, 0.7, 0.0 )
				GameTooltip:AddLine(CONTESTED_TERRITORY, 1.0, 0.7, 0.0)
				
			elseif (pvpType == "combat") then
				GameTooltip:AddLine(subzoneName, 1.0, 0.1, 0.1 )
				GameTooltip:AddLine(COMBAT_ZONE, 1.0, 0.1, 0.1)
				
			else
				GameTooltip:AddLine(subzoneName, 1.0, 0.9294, 0.7607)
			end
			
			GameTooltip:Show()
		end)
		
		Minimap.ZoneTextButton:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end
	
	--
	-- fix the clock
	do
		TimeManagerClockButton:ClearAllPoints()
		TimeManagerClockButton:SetPoint("TOP", Minimap.ZoneTextButton, "BOTTOM", 0, -2)
		TimeManagerClockButton:DisableDrawLayer("BORDER")
		TimeManagerClockButton:SetFrameStrata(Minimap:GetFrameStrata())
		TimeManagerClockButton:SetFrameLevel(Minimap:GetFrameLevel() + 2)
		TimeManagerClockTicker:SetAllPoints(TimeManagerClockButton)
		TimeManagerClockTicker:SetFontObject(GUIS_SystemFontNormal)
		TimeManagerClockTicker:SetJustifyH("CENTER")
		TimeManagerClockTicker:SetJustifyV("TOP")
		TimeManagerClockButton:SetHeight((select(2, TimeManagerClockTicker:GetFontObject():GetFont())))
	end
	
	--
	-- create our own warning for new calendar events
	do
		Minimap.NewEvent = CreateFrame("Frame", "MinimapNewEventNotification", Minimap)
		Minimap.NewEvent:SetAlpha(0)
		Minimap.NewEvent:Hide()

		Minimap.NewEventText = Minimap.NewEvent:CreateFontString(nil, "OVERLAY")
		Minimap.NewEventText:SetPoint("TOP", TimeManagerClockTicker, "BOTTOM", 0, 0)
		Minimap.NewEventText:SetNonSpaceWrap(false)
		Minimap.NewEventText:SetFontObject(GUIS_SystemFontNormalWhite) -- NumberFont_Outline_Med
		Minimap.NewEventText:SetJustifyH("CENTER")
		Minimap.NewEventText:SetJustifyV("TOP")
		Minimap.NewEventText:SetHeight((select(2, TimeManagerClockTicker:GetFontObject():GetFont())))
		Minimap.NewEventText:SetText("")

		Minimap.NewEvent:SetAllPoints(Minimap.NewEventText)
		Minimap.NewEvent:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(Minimap, "ANCHOR_PRESERVE")
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 12, 0)
			GameTooltip:AddLine(GAMETIME_TOOLTIP_CALENDAR_INVITES)
			GameTooltip:Show()
		end)
		
		Minimap.NewEvent:SetScript("OnLeave", function(self) 
			GameTooltip:Hide()
		end)
		
		Minimap.NewEvent:SetScript("OnMouseDown", function(self) 
			if (not CalendarFrame) then 
				LoadAddOn("Blizzard_Calendar")
			end
			Calendar_Toggle()
		end)
	end
	
	--
	-- create our own instance difficulty overlay
	do
		Minimap.InstanceDifficulty = Minimap:CreateFontString(nil, "HIGHLIGHT")
		Minimap.InstanceDifficulty:SetFontObject(GUIS_NumberFontHuge)
		Minimap.InstanceDifficulty:SetTextColor(unpack(C["index"]))
		Minimap.InstanceDifficulty:SetJustifyH("CENTER")
		Minimap.InstanceDifficulty:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
	end
	
	-- 
	-- add player coordinates
	do
		Minimap.Coordinates = Minimap:CreateFontString(nil, "OVERLAY")
		Minimap.Coordinates:SetFontObject(GUIS_SystemFontSmall)
		Minimap.Coordinates:SetJustifyH("CENTER")
		Minimap.Coordinates:SetTextColor(unpack(C["value"]))
		Minimap.Coordinates:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 2)
		
		ScheduleTimer(UpdateCoordinates, 0.1, nil, nil)
	end

	--
	-- add our middleclick menu
	do
		local menuFrame = CreateFrame("Frame", "MinimapMiddleClickMenu", Minimap, "UIDropDownMenuTemplate")
		local menuList = {
			{
				text = L["Calendar"];
				notCheckable = true;
				func = function()
					if not(CalendarFrame) then 
						LoadAddOn("Blizzard_Calendar")
					end
					
					Calendar_Toggle()
				end
			};
			
			{
				text = ACHIEVEMENT_BUTTON; 
				notCheckable = true;
				func = function() 
					ToggleAchievementFrame()
				end
			};
			
			{
				text = CHARACTER_BUTTON;
				notCheckable = true;
				func = function() 
					ToggleCharacter("PaperDollFrame")
				end
			};
			
			not((IsTrialAccount) and (IsTrialAccount())) and 
			{
				text = (IsInGuild()) and GUILD or LOOKINGFORGUILD;
				notCheckable = true;
				func = function() 
					if IsInGuild() then 
						if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end 
						GuildFrame_Toggle() 
					else 
						if not LookingForGuildFrame then LoadAddOn("Blizzard_LookingForGuildUI") end 
						LookingForGuildFrame_Toggle() 
					end
				end
			};
			
			{
				text = HELP_BUTTON;
				notCheckable = true;
				func = function() 
					ToggleHelpFrame()
				end
			};
			
			{
				text = DUNGEONS_BUTTON; 
				notCheckable = true;
				func = function() 
					ToggleFrame(LFDParentFrame)
				end
			};
			
			{
				text = LOOKING_FOR_RAID; 
				notCheckable = true;
				func = function() 
					ToggleFrame(LFRParentFrame)
				end
			};
			
			{
				text = PLAYER_V_PLAYER;
				notCheckable = true;
				func = function() 
					ToggleFrame(PVPFrame)
				end
			};
			
			{
				text = QUESTLOG_BUTTON;
				notCheckable = true;
				func = function() 
					ToggleFrame(QuestLogFrame)
				end
			};
			
			{
				text = SOCIAL_BUTTON; 
				notCheckable = true;
				func = function() 
					ToggleFriendsFrame(1)
				end
			};
			
			{
				text = SPELLBOOK_ABILITIES_BUTTON;
				notCheckable = true;
				func = function() 
					if (not InCombatLockdown()) then
						ToggleFrame(SpellBookFrame)
					end
				end
			};
			
			{
				text = TALENTS_BUTTON;
				notCheckable = true;
				func = function() 
					if (not InCombatLockdown()) then
						if not(PlayerTalentFrame) then 
							LoadAddOn("Blizzard_TalentUI")
						end 
						
						if not GlyphFrame then 
							LoadAddOn("Blizzard_GlyphUI") 
						end 
						
						PlayerTalentFrame_Toggle()
					end
				end
			};
		}
		Minimap:SetScript("OnMouseUp", function(self, button)
			if (button == "RightButton") then
				if (not db["tracking"].enable) then
					ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
				end
				
			elseif (button == "MiddleButton") then
				if (GUIS_DB["minimap"].showMiddleClickMenu) then
					if (DropDownList1:IsShown()) then
						DropDownList1:Hide()
					else
						EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
					end
				end
			else
				Minimap_OnClick(self)
			end
		end)
		
		-- MoP beta edit
		if (MiniMapLFG_Update) then
			hooksecurefunc("MiniMapLFG_Update", updateMinimapIcons)
		elseif (MiniMapLFG_UpdateIsShown) then
			hooksecurefunc("MiniMapLFG_UpdateIsShown", updateMinimapIcons)
		end
		
		-- throw in a chatcommand for those that can't middleclick the minimap
		CreateChatCommand(function() EasyMenu(menuList, menuFrame, Minimap, 0, 0, "MENU", 2) end, { "mapmenu", "minimapmenu" })
	end
	
	RegisterCallback("PLAYER_ENTERING_WORLD", updateMinimapIcons)

	RegisterBucketEvent({
		"PLAYER_DIFFICULTY_CHANGED";
		"PLAYER_ENTERING_WORLD";
		"ZONE_CHANGED_NEW_AREA";
	}, 0.1, UpdateInstanceDifficulty)
	
	RegisterBucketEvent({
		"CALENDAR_NEW_EVENT";
		"CALENDAR_UPDATE_EVENT";
		"CALENDAR_UPDATE_EVENT_LIST";
		"CALENDAR_UPDATE_GUILD_EVENTS";
		"CALENDAR_UPDATE_INVITE_LIST";
		"CALENDAR_UPDATE_PENDING_INVITES";
		"PLAYER_ENTERING_WORLD";
	}, 0.1, UpdateNewCalendarEvent)
	
	RegisterBucketEvent({
		"PLAYER_ENTERING_WORLD";
		"ZONE_CHANGED";
		"ZONE_CHANGED_INDOORS";
		"ZONE_CHANGED_NEW_AREA";
	}, 0.1, UpdateZoneText)

	-- initial options update
	self:UpdateAll()
	
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

module.OnEnable = function(self)
	--
	-- make the bugsack icon prettier
	do
		if LibDBIcon10_BugSack and ((LibDBIcon10_BugSack:GetParent() == Minimap) or (LibDBIcon10_BugSack:GetParent() == _G.Minimap)) then
			local a, b = LibDBIcon10_BugSack, { LibDBIcon10_BugSack:GetRegions() }
			b[2]:SetTexture("")
			b[3]:SetTexture("")
			b[2].SetTexture = noop
			b[3].SetTexture = noop
			a:SetHighlightTexture("")
			a.SetHighlightTexture = noop
			a:ClearAllPoints()
			a:SetPoint("LEFT", Minimap, "LEFT", 0, 0)
			a.SetPoint = noop
			a:SetParent(Minimap)
		end
	end
end
