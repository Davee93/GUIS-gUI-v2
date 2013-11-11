--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UIPanels")

-- Lua API
local pairs = pairs

-- WoW API
local CreateFrame = CreateFrame

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateUIPanel = function(...) return LibStub("gPanel-2.0"):CreateUIPanel(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local fixUIPanelSize, fixPanelStrata
local updateMinimapPanels, newMinimapPanel 

local bottomLeftPanel = module:GetName() .. "BottomLeftPanel" 
local bottomRightPanel = module:GetName() .. "BottomRightPanel"
local panel = {}

local defaults = {
	------------------------------------------------------------------------------------------------------------
	-- 	Panel Settings
	------------------------------------------------------------------------------------------------------------
	showBottomRight = true;
	showBottomLeft = true;
	
	------------------------------------------------------------------------------------------------------------
	-- 	Plugins
	------------------------------------------------------------------------------------------------------------
	-- "Gold" 
	hideCopper = true; -- hides copper if you're above the stored threshold
	hideSilver = true; -- hides silver if you're above the stored threshold
	copperThreshold = 100 * 100 * 100; -- hide copper if you're at or above this copper sum
	silverThreshold = 1000 * 100 * 100; -- hide silver if you're at or above this copper sum

	-- "msfps"
	showWorldLatency = true;
	showRealmLatency = true;
	showFPS = true;
	
	------------------------------------------------------------------------------------------------------------
	-- 	Tooltips
	------------------------------------------------------------------------------------------------------------
	-- Currency tooltip 
	trackedCurrencies = {}; -- empty by default. populate this with currency IDs as the keys. values should be true/nil
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
				msg = L["UI Panels are special frames providing information about the game as well allowing you to easily change settings. Here you can configure the visibility and behavior of these panels. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."];
			};
			{ -- panel visibility
				type = "group";
				order = 10;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Visible Panels"];
					};
					{
						type = "widget";
						element = "Text";
						order = 2;
						msg = L["Here you can decide which of the UI panels should be visible. They can still be moved with |cFF4488FF/glock|r when hidden."];
					};
					{ -- bottom right panel
						type = "widget";
						element = "CheckButton";
						name = "showBottomRight";
						order = 5;
						width = "full"; 
						msg = L["Show the bottom right UI panel"];
						desc = nil;
						set = function(self) 
							GUIS_DB.panels.showBottomRight = not(GUIS_DB.panels.showBottomRight)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.panels.showBottomRight end;
					};
					{ -- maintain
						type = "widget";
						element = "CheckButton";
						name = "showBottomLeft";
						order = 10;
						width = "full"; 
						msg = L["Show the bottom left UI panel"];
						desc = nil;
						set = function(self) 
							GUIS_DB.panels.showBottomLeft = not(GUIS_DB.panels.showBottomLeft)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.panels.showBottomLeft end;
					};
				};
			};
			{ -- bottom left panel
				type = "group";
				order = 20;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Bottom Left Panel"];
					};
				};
			};
			{ -- bottom right panel
				type = "group";
				order = 30;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Bottom Right Panel"];
					};
				};
			};
			{ -- bottomleft panel plugin choice
				type = "group";
				order = 10;
				virtual = true;
				children = {
				};
			};
			{ -- bottomright panel plugin choice
				type = "group";
				order = 20;
				virtual = true;
				children = {
				};
			};
			{ -- latency/fps plugin
				type = "group";
				order = 100;
				virtual = true;
				children = {
				};
			};
			{ -- gold plugin
				type = "group";
				order = 200;
				virtual = true;
				children = {
				};
			};
		};
	};
}

fixUIPanelSize = function()
	panel[bottomLeftPanel]:SetSize(F.fixPanelWidth(), F.fixPanelHeight())
	panel[bottomRightPanel]:SetSize(F.fixPanelWidth(), F.fixPanelHeight())
end

--
-- Pre-hooking the SetFrameStrata function to make sure they stay in place
fixPanelStrata = function()
	for _,p in pairs(panel) do
		if not p.BlizzSetFrameStrata then
			p.BlizzSetFrameStrata = p.SetFrameStrata
			p.SetFrameStrata = function(self, strata) 
				self:BlizzSetFrameStrata("LOW")
			end

			p:SetFrameStrata()
		end
	end
end

module.GetPanel = function(self, name)
	return panel[name]
end

module.GetPanelBySearch = function(self, name)
	for i,v in pairs(panel) do
		if (v:GetName():find(name)) then
			return v
		end
	end
end

module.UpdateAll = function(self)
	panel[bottomLeftPanel]:SetVisibility(GUIS_DB.panels.showBottomLeft)
	panel[bottomRightPanel]:SetVisibility(GUIS_DB.panels.showBottomRight)
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["panels"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["panels"] = GUIS_DB["panels"] or {}

	-- we don't clean away values not listed in defaults here by intention.
	-- we want external modules to be able to save their settings through this table
	-- use with CAUTION!
	GUIS_DB["panels"] = ValidateTable(GUIS_DB["panels"], defaults, true) 
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill() 
		return 
	end

	local r, g, b = unpack(C["overlay"])
	local panelAlpha = 1

	--
	-- bottom left UI panel
	panel[bottomLeftPanel] = CreateUIPanel(UIParent, bottomLeftPanel)
	panel[bottomLeftPanel]:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	panel[bottomLeftPanel]:PlaceAndSave(F.fixPanelPosition("BottomLeft"))
	panel[bottomLeftPanel]:SetSize(F.fixPanelWidth(), F.fixPanelHeight())
	panel[bottomLeftPanel]:SpawnPlugin("Friends", "LEFT")
	panel[bottomLeftPanel]:SpawnPlugin("msfps", "CENTER")
	panel[bottomLeftPanel]:SpawnPlugin("Guild", "RIGHT")
	panel[bottomLeftPanel]:Refresh()
	
	panel[bottomLeftPanel].candyLayer = CreateFrame("Frame", nil, panel[bottomLeftPanel])
	panel[bottomLeftPanel].candyLayer:SetPoint("TOPLEFT", 3, -3)
	panel[bottomLeftPanel].candyLayer:SetPoint("BOTTOMRIGHT", -3, 3)
	F.GlossAndShade(panel[bottomLeftPanel].candyLayer)

	--
	-- bottom right UI panel
	panel[bottomRightPanel] = CreateUIPanel(UIParent, bottomRightPanel)
	panel[bottomRightPanel]:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	panel[bottomRightPanel]:PlaceAndSave(F.fixPanelPosition("BottomRight"))
	panel[bottomRightPanel]:SetSize(F.fixPanelWidth(), F.fixPanelHeight())
	panel[bottomRightPanel]:SpawnPlugin("Bags", "LEFT")
	panel[bottomRightPanel]:SpawnPlugin("Gold", "CENTER")
	panel[bottomRightPanel]:SpawnPlugin("Durability", "RIGHT")
	panel[bottomRightPanel]:Refresh()
	
	panel[bottomRightPanel].candyLayer = CreateFrame("Frame", nil, panel[bottomRightPanel])
	panel[bottomRightPanel].candyLayer:SetPoint("TOPLEFT", 3, -3)
	panel[bottomRightPanel].candyLayer:SetPoint("BOTTOMRIGHT", -3, 3)
	F.GlossAndShade(panel[bottomRightPanel].candyLayer)

	-- for easier external access
	panel.BottomLeft = panel[bottomLeftPanel]
	panel.BottomRight = panel[bottomRightPanel]

	-- fix the strata issue
	RegisterCallback("PLAYER_ENTERING_WORLD", fixPanelStrata)

	-- make sure sizes update when the user changes scale or screen size
	RegisterCallback("PLAYER_ENTERING_WORLD", fixUIPanelSize)
	RegisterCallback("DISPLAY_SIZE_CHANGED", fixUIPanelSize)
	RegisterCallback("UI_SCALE_CHANGED", fixUIPanelSize)
	
	module:UpdateAll()
	
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
end
