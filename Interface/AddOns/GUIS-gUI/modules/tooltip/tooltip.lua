--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Tooltip")

-- Lua API
local _G = _G
local pairs, select, unpack = pairs, select, unpack

-- WoW API
local CreateFrame = CreateFrame
local GetGuildInfo = GetGuildInfo
local GetItemIcon = GetItemIcon
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealmName = GetRealmName
local InCombatLockdown = InCombatLockdown
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsPlayer = UnitIsPlayer
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitRace = UnitRace
local UnitReaction = UnitReaction

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local GetPoint = function(...) return LibStub("gFrameHandler-1.0"):GetPoint(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local RGBToHex = RGBToHex

local Tooltip

local GameTooltip = GameTooltip
local GameTooltipStatusBar = GameTooltipStatusBar
local RAID_CLASS_COLORS = C["RAID_CLASS_COLORS"]
local FACTION_BAR_COLORS = C["FACTION_BAR_COLORS"]
local RARE = ITEM_QUALITY3_DESC

local CLASSIFICATION = {
	["elite"] = ("|cFF%s+|r"):format(RGBToHex(C["boss"].r, C["boss"].g, C["boss"].b));
	["rare"] = ("|cFF%s %s|r"):format(RGBToHex(C["rare"][1], C["rare"][2], C["rare"][3]) , RARE);
	["rareelite"] = ("|cFF%s+ %s|r"):format(RGBToHex(C["boss"].r, C["boss"].g, C["boss"].b), RARE);
	["worldboss"] = ("|cFF%s%s|r"):format(RGBToHex(C["boss"].r, C["boss"].g, C["boss"].b), BOSS);
}

local TOOLTIPS = {
	ConsolidatedBuffsTooltip;
	FriendsTooltip;
	GameTooltip; 
	ItemRefTooltip; 
	ShoppingTooltip1; 
	ShoppingTooltip2; 
	ShoppingTooltip3;
	WorldMapTooltip; 
	WorldMapCompareTooltip1;
	WorldMapCompareTooltip2;
	WorldMapCompareTooltip3;
	
	-- these two fuckers escaped our smart on-demand function
	DropDownList1Backdrop;
	DropDownList2Backdrop;
	DropDownList1MenuBackdrop;
	DropDownList2MenuBackdrop;
	
	ChatMenu;
	EmoteMenu;
	LanguageMenu;
	VoiceMacroMenu;
}

local defaults = {
	anchortocursor = 0; -- 0 = default pos (can be moved by the user), 1 = always to mouse, 2 = only anchor units
	hidewhilecombat = 0; -- 0 = always show, 1 = hide in combat
	showtitle = 1; -- show player titles
	showrealm = 1; -- show realm names for other realms
	showhealth = 1; -- show health values on the health bars
	userpos = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -8, 110 }
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
				msg = L["Here you can change the settings for the game tooltips"];
			};
			{
				type = "group";
				order = 5;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Visibility"];
					};
					{ -- hide in combat
						type = "widget";
						element = "CheckButton";
						name = "hidewhilecombat";
						order = 5;
						width = "full"; 
						msg = L["Hide while engaged in combat"];
						desc = nil;
						set = function(self) 
							GUIS_DB["tooltip"].hidewhilecombat = GetBinary(not(GetBoolean(GUIS_DB["tooltip"].hidewhilecombat)))
						end;
						get = function() return GetBoolean(GUIS_DB["tooltip"].hidewhilecombat) end;
					};
					{
						type = "widget";
						element = "Header";
						order = 19;
						msg = L["Elements"];
					};
					{ -- healthbar text
						type = "widget";
						element = "CheckButton";
						name = "showhealth";
						order = 20;
						width = "full"; 
						msg = L["Show values on the tooltip healthbar"];
						desc = nil;
						set = function(self) 
							GUIS_DB["tooltip"].showhealth = GetBinary(not(GetBoolean(GUIS_DB["tooltip"].showhealth)))
						end;
						get = function() return GetBoolean(GUIS_DB["tooltip"].showhealth) end;
					};
					{ -- titles
						type = "widget";
						element = "CheckButton";
						name = "showtitle";
						order = 30;
						width = "full"; 
						msg = L["Show player titles in the tooltip"];
						desc = nil;
						set = function(self) 
							GUIS_DB["tooltip"].showtitle = GetBinary(not(GetBoolean(GUIS_DB["tooltip"].showtitle)))
						end;
						get = function() return GetBoolean(GUIS_DB["tooltip"].showtitle) end;
					};
					{ -- realm
						type = "widget";
						element = "CheckButton";
						name = "showrealm";
						order = 40;
						width = "full"; 
						msg = L["Show player realms in the tooltip"];
						desc = nil;
						set = function(self) 
							GUIS_DB["tooltip"].showrealm = GetBinary(not(GetBoolean(GUIS_DB["tooltip"].showrealm)))
						end;
						get = function() return GetBoolean(GUIS_DB["tooltip"].showrealm) end;
					};
					{
						type = "widget";
						element = "Header";
						order = 100;
						msg = L["Positioning"];
					};
					{
						type = "widget";
						element = "Text";
						order = 101;
						msg = L["Choose what tooltips to anchor to the mouse cursor, instead of displaying in their default positions:"];
					};
					{ -- nameplates
						type = "widget";
						element = "Dropdown";
						order = 110;
						msg = nil;
						desc = {
							"|cFFFFFFFF" .. NONE .. "|r",
							"|cFFFFD100" .. L["All tooltips will be displayed in their default positions."] .. "|r", 
							" ",
							"|cFFFFFFFF" .. ALL .. "|r",
							"|cFFFFD100" .. L["All tooltips will be anchored to the mouse cursor."] .. "|r", 
							" ",
							"|cFFFFFFFF" .. L["Only Units"] .. "|r",
							"|cFFFFD100" .. L["Only unit tooltips will be anchored to the mouse cursor, while other tooltips will be displayed in their default positions."] .. "|r"
						};
						args = { NONE, ALL, L["Only Units"] };
						set = function(self, option)
							GUIS_DB["tooltip"].anchortocursor = UIDropDownMenu_GetSelectedID(self) - 1
						end;
						get = function(self) return GUIS_DB["tooltip"].anchortocursor + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};					
				};
			};
		};
	};
}

local faq = {
	{
		q = L["How can I toggle the display of player realms and titles in the tooltips?"];
		a = {
			{
				type = "text";
				msg = L["You can change most of the tooltip settings from the options menu."];
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
		tags = { "tooltips" };
	};
}

--
-- returns the default position of the tooltip, depending on which sidebars are visible
local getDefaultPosition = function()
	local m = _G["GUIS-gUI: ActionBarsMicroMenuFrame"]
	local x = -((MultiBarLeftButton1:IsVisible() and 31 or 0) + (MultiBarRightButton1:IsVisible() and 45 or 0)) + (((m) and (m:IsVisible())) and 28 or 0)
	local y = 80

	return defaults.userpos[1], defaults.userpos[2], defaults.userpos[3], (defaults.userpos[4] + x), (defaults.userpos[5] + y)
end

local getPosition = function()
	local point, anchor, relpoint, xoff, yoff = unpack(GUIS_DB["tooltip"].userpos)
	
	local isDefault
	
	return getDefaultPosition()
end

local SetColor = function(self)
	self:SetBackdropColor(C["background"][1], C["background"][2], C["background"][3], 0.8)
	self:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3], 1)
end

local GetUnitNameColor = function(unit)
	local color 
	
	local reaction = UnitReaction(unit, "player")
	local class = select(2, UnitClass(unit))
	
	if (unit) then
		if UnitIsPlayer(unit) and class then
			color = RAID_CLASS_COLORS[class]
		elseif reaction then
			color = FACTION_BAR_COLORS[reaction]
		else
			color = { r = 0.6; g = 0.6; b = 0.6 }
		end
	end
	
	return color.r, color.g, color.b
end

local SetUnitTooltip = function(self)
	local lines = self:NumLines()
	local unit = select(2, self:GetUnit())

	if (not unit) and (UnitExists("mouseover")) then
		unit = "mouseover"
	end
	
	if (not unit) then 
		self:Hide() 
		return 
	end	
	
	local level = UnitLevel(unit)
	local levelColor = (level ~= -1) and GetQuestDifficultyColor(level) or C["boss"]
	local race = UnitRace(unit)
	local name, realm = UnitName(unit)
	local classification = UnitClassification(unit)
	local creatureType = UnitCreatureType(unit)
	local r, g, b = GetUnitNameColor(unit)

	if (GUIS_DB["tooltip"].showtitle) and (GUIS_DB["tooltip"].showtitle == 1) then
		name = UnitPVPName(unit)
	end
	
	if (name) then
		_G["GameTooltipTextLeft1"]:SetFormattedText("|cFF%s%s|r", RGBToHex(r, g, b), name)
	end
	
	if (UnitIsPlayer(unit)) then
		if (UnitIsAFK(unit)) then
			self:AppendText(("|cFF%s %s|r"):format(RGBToHex(r, g, b), CHAT_FLAG_AFK))
		elseif UnitIsDND(unit) then 
			self:AppendText(("|cFF%s %s|r"):format(RGBToHex(r, g, b), CHAT_FLAG_DND))
		end
		
		if (realm) and (realm ~= "") then 
			_G["GameTooltipTextLeft1"]:SetFormattedText("|cFF%s%s|r|cFF%s - %s|r", RGBToHex(r, g, b), name or "", RGBToHex(C.realm[1], C.realm[2], C.realm[3]), realm)
		end

		if (GetGuildInfo(unit)) then
			_G["GameTooltipTextLeft2"]:SetFormattedText("|cFF%s<%s>|r", RGBToHex(C.guild[1], C.guild[2], C.guild[3]), GetGuildInfo(unit))
		end

		local n = GetGuildInfo(unit) and 3 or 2

		if (GetCVar("colorblindMode") == "1") then 
			n = n + 1 
		end
		
		_G[("GameTooltipTextLeft%d"):format(n)]:SetFormattedText("|cFF%s%s|r %s", RGBToHex(levelColor.r, levelColor.g, levelColor.b), level ~= -1 and level or "", race or "")

	else
		for i = 2, lines do
			local line = _G[("GameTooltipTextLeft%d"):format(i)]
			
			if (line) and (line:GetText():find(LEVEL) or (creatureType and line:GetText():find(creatureType))) then
				classification = ((level == -1) and (classification == "elite")) and "worldboss" or classification
				
				local text = ""
				if (classification ~= "worldboss") and (level > 0) then
					text = text .. "|cFF" .. RGBToHex(levelColor.r, levelColor.g, levelColor.b) .. level .. "|r"
				end
				
				if (CLASSIFICATION[classification]) then
					text = text .. CLASSIFICATION[classification] .. " "
					
				elseif ((classification ~= "worldboss") and (level > 0)) then
					text = text .. " "
				end
				
				if (creatureType) then
					text = text .. creatureType
				end
				
				line:SetText(text)
				
				break
			end
		end
	end

	if (UnitExists(unit .. "target")) and ((unit ~= "player")) then
		local r, g, b = GetUnitNameColor(unit .. "target")
		local name, realm = UnitName(unit .. "target")
		GameTooltip:AddLine(((name == (select(1, UnitName("player")))) and ((realm == nil) or (realm == (GetRealmName())))) and "|cFFFF0000>> " .. strupper(UNIT_YOU) .. " <<|r" or ">> " .. name .. " <<", r, g, b)
	end

	if (self:GetWidth() < 120) then
		self:SetWidth(120)
	end
end

local Update = function(self, ...)
	if (self:GetAnchorType() == "ANCHOR_CURSOR") then
		if (self.Refresh) then
			self.Refresh = false

			SetColor(self)
		end
	end
end

local Position = function(tooltip, parent)
	if (GUIS_DB["tooltip"].anchortocursor == 0) then
		tooltip.default = 1
		tooltip:SetOwner(parent, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint("BOTTOMRIGHT", -8, 195) -- This works for now.

	elseif (GUIS_DB["tooltip"].anchortocursor == 1) then
		tooltip:ClearAllPoints()
		tooltip:SetOwner(parent, "ANCHOR_CURSOR")
		tooltip.default = 1

	elseif (GUIS_DB["tooltip"].anchortocursor == 2) then
		if UnitExists("mouseover") then
			tooltip:ClearAllPoints()
			tooltip:SetOwner(parent, "ANCHOR_CURSOR")
			tooltip.default = 1
		else
			tooltip:SetOwner(parent,"ANCHOR_NONE")
			tooltip.default = 1
			tooltip:ClearAllPoints()
			tooltip:SetPoint(getPosition())
		end
	end
end

local showIcon = function()
	local frame = _G["ItemLinkIcon"]
	local tip = _G["ItemRefTooltip"]
	
	frame:Hide()

	local link = (select(2, tip:GetItem()))
	local icon = link and GetItemIcon(link)

	if not(icon) then 
		tip.hasIcon = nil
		return 
	end
	
	local rarity = (select(3, GetItemInfo(link)))
	
	if (rarity) and (rarity > 1) then
		local r, g, b = GetItemQualityColor(rarity)
		frame:SetBackdropBorderColor(r, g, b, 1)
		tip.hasIcon = true
	else
		frame:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3], 1)
		tip.hasIcon = nil
	end

	frame.icon:SetTexture(icon)
	frame:Show()	
end

local StyleToolTip = function(self)
	if not(self) then
		return
	end
	
	-- Style the Tooltip and color border.
	local function style(self)
	if(not self) then return end
	if(not self.freebtipBD) then
		--self:SetUITemplate("blank") -- We need to apply it here.
	end
		if self.GetItem then
			local _, item = self:GetItem()
			if(item) then
				local quality = select(3, GetItemInfo(item))
				if quality and quality >= 2 then
					local r, g, b = GetItemQualityColor(quality)
					self:SetBackdropBorderColor(r, g, b)
				end		
			end
		end
		local frameName = self:GetName()
		if(not frameName) then return end
	end
	for i, self in ipairs(TOOLTIPS) do
		if(self) then
			self:HookScript("OnShow", function(self)
				style(self)
			end)
		end
	end

	self:HookScript("OnShow", function(self) 
	self:SetBackdrop(M["Backdrop"]["Blank-Inset"])
		
		-- this makes sure the tooltips have a correct scale, regardless of its parent
		self:SetScale(UIParent:GetScale() / self:GetEffectiveScale())

		SetColor(self)
		
		--[[
		if	(_G[self:GetName() .. "MoneyFrame1"]) then
		
			_G[self:GetName() .. "MoneyFrame1PrefixText"]:SetFontObject(GUIS_TooltipFontNormal)
			_G[self:GetName() .. "MoneyFrame1SuffixText"]:SetFontObject(GUIS_TooltipFontNormal)
			
			_G[self:GetName() .. "MoneyFrame1GoldButton"]:GetNormalFontObject():SetFontObject(GUIS_NumberFontNormal)
			_G[self:GetName() .. "MoneyFrame1SilverButton"]:GetNormalFontObject():SetFontObject(GUIS_NumberFontNormal)
			_G[self:GetName() .. "MoneyFrame1CopperButton"]:GetNormalFontObject():SetFontObject(GUIS_NumberFontNormal)
		end
		]]--
		
		self.Refresh = true
		
		if (GUIS_DB["tooltip"].hidewhilecombat == 1) then
			if (InCombatLockdown()) then
				self:Hide()
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			else
				self:RegisterEvent("PLAYER_REGEN_DISABLED")
			end
		end
	end)

	self:HookScript("OnEvent", function(self, event) 
		if (event == "PLAYER_REGEN_DISABLED") and (GUIS_DB["tooltip"].hidewhilecombat == 1) then 
			self:Hide()
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
		
		if (event == "PLAYER_REGEN_ENABLED") then 
			self:Show()
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
		end
	end)
	
	return true
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["tooltip"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["tooltip"] = GUIS_DB["tooltip"] or {}
	GUIS_DB["tooltip"] = ValidateTable(GUIS_DB["tooltip"], defaults)
	
	GUIS_DB["tooltip"].hidewhilecombat = 0
end

----------------------------------------------------------------------------------------
--	Fix compare tooltips(by Blizzard)(../FrameXML/GameTooltip.lua)
----------------------------------------------------------------------------------------
hooksecurefunc("GameTooltip_ShowCompareItem", function(self, shift)
	if not self then
		self = GameTooltip
	end
	local item, link = self:GetItem()
	if not link then return end

	local shoppingTooltip1, shoppingTooltip2, shoppingTooltip3 = unpack(self.shoppingTooltips)

	local item1 = nil
	local item2 = nil
	local item3 = nil
	local side = "left"
	if shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, self) then
		item1 = true
	end
	if shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, self) then
		item2 = true
	end
	if shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, self) then
		item3 = true
	end

	-- Find correct side
	local rightDist = 0
	local leftPos = self:GetLeft()
	local rightPos = self:GetRight()
	if not rightPos then
		rightPos = 0
	end
	if not leftPos then
		leftPos = 0
	end

	rightDist = GetScreenWidth() - rightPos

	if leftPos and (rightDist < leftPos) then
		side = "left"
	else
		side = "right"
	end

	-- See if we should slide the tooltip
	if self:GetAnchorType() and self:GetAnchorType() ~= "ANCHOR_PRESERVE" then
		local totalWidth = 0

		if item1 then
			totalWidth = totalWidth + shoppingTooltip1:GetWidth()
		end
		if item2 then
			totalWidth = totalWidth + shoppingTooltip2:GetWidth()
		end
		if item3 then
			totalWidth = totalWidth + shoppingTooltip3:GetWidth()
		end

		if side == "left" and totalWidth > leftPos then
			self:SetAnchorType(self:GetAnchorType(), totalWidth - leftPos, 0)
		elseif side == "right" and (rightPos + totalWidth) > GetScreenWidth() then
			self:SetAnchorType(self:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0)
		end
	end

	-- Anchor the compare tooltips
	if item3 then
		shoppingTooltip3:SetOwner(self, "ANCHOR_NONE")
		shoppingTooltip3:ClearAllPoints()
		if side and side == "left" then
			shoppingTooltip3:SetPoint("TOPRIGHT", self, "TOPLEFT", -3, -10)
		else
			shoppingTooltip3:SetPoint("TOPLEFT", self, "TOPRIGHT", 3, -10)
		end
		shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, self)
		shoppingTooltip3:Show()
	end

	if item1 then
		if item3 then
			shoppingTooltip1:SetOwner(shoppingTooltip3, "ANCHOR_NONE")
		else
			shoppingTooltip1:SetOwner(self, "ANCHOR_NONE")
		end
		shoppingTooltip1:ClearAllPoints()
		if side and side == "left" then
			if item3 then
				shoppingTooltip1:SetPoint("TOPRIGHT", shoppingTooltip3, "TOPLEFT", -3, 0)
			else
				shoppingTooltip1:SetPoint("TOPRIGHT", self, "TOPLEFT", -3, -10)
			end
		else
			if item3 then
				shoppingTooltip1:SetPoint("TOPLEFT", shoppingTooltip3, "TOPRIGHT", 3, 0)
			else
				shoppingTooltip1:SetPoint("TOPLEFT", self, "TOPRIGHT", 3, -10)
			end
		end
		shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, self)
		shoppingTooltip1:Show()

		if item2 then
			shoppingTooltip2:SetOwner(shoppingTooltip1, "ANCHOR_NONE")
			shoppingTooltip2:ClearAllPoints()
			if side and side == "left" then
				shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -3, 0)
			else
				shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 3, 0)
			end
			shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, self)
			shoppingTooltip2:Show()
		end
	end
end)

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill()
		return 
	end

	--[[
	GameTooltipHeaderText:SetFontObject(GUIS_TooltipFontTitle)
	GameTooltipText:SetFontObject(GUIS_TooltipFontNormal)

	for i = 1,3 do
		_G["ShoppingTooltip" .. i .. "TextLeft1"]:SetFontObject(GUIS_TooltipFontSmall)
		_G["ShoppingTooltip" .. i .. "TextRight1"]:SetFontObject(GUIS_TooltipFontNormal)
		_G["ShoppingTooltip" .. i .. "TextLeft2"]:SetFontObject(GUIS_TooltipFontNormal)
		_G["ShoppingTooltip" .. i .. "TextRight2"]:SetFontObject(GUIS_TooltipFontSmallWhite)
		_G["ShoppingTooltip" .. i .. "TextLeft3"]:SetFontObject(GUIS_TooltipFontSmallWhite)
		_G["ShoppingTooltip" .. i .. "TextRight3"]:SetFontObject(GUIS_TooltipFontSmallWhite)
		_G["ShoppingTooltip" .. i .. "TextLeft4"]:SetFontObject(GUIS_TooltipFontSmall)
		_G["ShoppingTooltip" .. i .. "TextRight4"]:SetFontObject(GUIS_TooltipFontSmallWhite)
	end
	
	SmallTextTooltipText:SetFontObject(GUIS_TooltipFontSmallWhite)
	]]--

	--Adding more shadows to more tooltips
	GameTooltip:CreateUIShadow()
	ShoppingTooltip1:CreateUIShadow()
	ShoppingTooltip2:CreateUIShadow()
	ShoppingTooltip3:CreateUIShadow()
	SmallTextTooltip:CreateUIShadow()
	ItemRefTooltip:CreateUIShadow()
	DropDownList1:CreateUIShadow()
	
	-- style all the registered tooltips and dropdowns
	for _,tooltip in pairs(TOOLTIPS) do
		StyleToolTip(tooltip)
	end
	
	-- since only the first 2 dropdown levels are created upon login,
	-- we're going to hook ourself into the creation process instead
	local extraStyled = {}
	local skinDropDown = function(level, index)
		for i = 3, UIDROPDOWNMENU_MAXLEVELS do
			local menu = "DropDownList" .. i .. "MenuBackdrop"
			local dropdown = "DropDownList" .. i .. "Backdrop"
			
			if (_G[menu]) and not(extraStyled[menu]) then
				if (StyleToolTip(_G[menu])) then
					extraStyled[menu] = true
				end
			end
			
			if (_G[dropdown]) and not(extraStyled[dropdown]) then
				if (StyleToolTip(_G[dropdown])) then
					extraStyled[dropdown] = true
				end
			end
		end
	end
	hooksecurefunc("UIDropDownMenu_CreateFrames", skinDropDown)

	-- hook the positioning of the default tooltip
	GameTooltip:HookScript("OnTooltipSetUnit", SetUnitTooltip)
	GameTooltip:HookScript("OnUpdate", Update)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", Position)

	-- create a nice icon for itemlinks
	local ItemLinkIcon = CreateFrame("Frame", "ItemLinkIcon", _G["ItemRefTooltip"])
	ItemLinkIcon:SetPoint("TOPRIGHT", _G["ItemRefTooltip"], "TOPLEFT", -4, 0)
	ItemLinkIcon:CreateUIShadow()
	ItemLinkIcon:SetSize(38, 38)
	ItemLinkIcon:SetUITemplate("blank")
	ItemLinkIcon.icon = ItemLinkIcon:CreateTexture("icon", "ARTWORK")
	ItemLinkIcon.icon:ClearAllPoints()
	ItemLinkIcon.icon:SetPoint("TOPLEFT", ItemLinkIcon, 3, -3)
	ItemLinkIcon.icon:SetPoint("BOTTOMRIGHT", ItemLinkIcon, -3, 3)
	ItemLinkIcon.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	F.GlossAndShade(ItemLinkIcon, ItemLinkIcon.icon)

	hooksecurefunc("SetItemRef", showIcon)
	
	ItemRefCloseButton:SetNormalTexture(M["Button"]["UICloseButton"])
	ItemRefCloseButton:SetPushedTexture(M["Button"]["UICloseButtonDown"])
	ItemRefCloseButton:SetHighlightTexture(M["Button"]["UICloseButtonHighlight"])
	ItemRefCloseButton:SetDisabledTexture(M["Button"]["UICloseButtonDisabled"])
	ItemRefCloseButton:SetSize(16, 16)
	ItemRefCloseButton:ClearAllPoints()
	ItemRefCloseButton:SetPoint("TOPRIGHT", ItemRefTooltip, "TOPRIGHT", -4, -4)

	-- make the StatusBar (health) prettier, and add some text
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 0, 5)
	GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", 0, 5)
	GameTooltipStatusBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	GameTooltipStatusBar:SetStatusBarColor(unpack(C.health))
	GameTooltipStatusBar.SetStatusBarColor = noop
	GameTooltipStatusBar:SetHeight(6)
	GameTooltipStatusBar:SetBackdrop(M["Backdrop"]["Blank-Inset"])

	F.GlossAndShade(GameTooltipStatusBar)
	
	GameTooltipStatusBar.Text = GameTooltipStatusBar:CreateFontString()
	GameTooltipStatusBar.Text:SetDrawLayer("OVERLAY", 4)
	GameTooltipStatusBar.Text:SetFontObject(GUIS_NumberFontNormal)
	GameTooltipStatusBar.Text:SetJustifyH("CENTER")
	GameTooltipStatusBar.Text:SetJustifyV("MIDDLE")
	GameTooltipStatusBar.Text:SetPoint("CENTER", GameTooltipStatusBar , "CENTER", 0, 0)

	GameTooltipStatusBar:CreateUIShadow()
	GameTooltipStatusBar:SetBackdropColor(C["background"][1], C["background"][2], C["background"][3], 0.8)
	GameTooltipStatusBar:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3], 1)

	local SetHealthValue = function(value, max)
		if (value ~= max) then
			return format("|cffffffff%d%%|r |cffD7BEA5-|r |cffffffff%s|r", floor(value / max * 100), ("[shortvalue:%d]"):format(value):tag())
		else
			return format("|cffffffff"..("[shortvalue:%d]"):format(max):tag().."|r")
		end
	end

	GameTooltipStatusBar:HookScript("OnUpdate", function(self, elapsed)
		if not(self:IsVisible()) then return end

		self.elapsed = (self.elapsed or 0) + elapsed

		if (self.elapsed >= 0.1) then
			if (GUIS_DB["tooltip"].showhealth == 1) then
				local value, minValue, maxValue = GameTooltipStatusBar:GetValue(), GameTooltipStatusBar:GetMinMaxValues()
				
				if (value ~= self.oldValue) then
					if (value > 0) then
						self.Text:SetText(SetHealthValue(value, maxValue))
						self:SetBackdropColor(C["background"][1], C["background"][2], C["background"][3], 0.8)
						self:SetBackdropBorderColor(C["background"][1], C["background"][2], C["background"][3], 0.8)
						self:SetUIShadowColor(unpack(C["shadow"]))
						self.Gloss:Show()
						self.Shade:Show()
					else
						self.Text:SetText("")
						self:SetBackdropColor(0,0,0,0)
						self:SetBackdropBorderColor(0,0,0,0)
						self:SetUIShadowColor(0, 0, 0, 0)
						self.Gloss:Hide()
						self.Shade:Hide()
					end
				end

				self.oldValue = value
			else
				self.Text:SetText("")
			end
			
			self.elapsed = self.elapsed % 0.1
		end
	end)
	
	-- skin the Blizzard debug tools tooltips
	local SkinDebugTools = function(self, event, addon)
		if not(addon == "Blizzard_DebugTools") then
			return
		end
		
		StyleToolTip(EventTraceTooltip)
		StyleToolTip(FrameStackTooltip)
	end
	RegisterCallback("ADDON_LOADED", SkinDebugTools)
	
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
