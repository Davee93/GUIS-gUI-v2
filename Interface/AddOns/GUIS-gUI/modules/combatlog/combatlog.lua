--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: CombatLog")

-- WoW API -- 
-- not going to localize this, we need to work with the global one
--local Blizzard_CombatLog_Update_QuickButtons = Blizzard_CombatLog_Update_QuickButtons

-- GUIS-gUI environment
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) return module:UnregisterCallback(...) end

local OriginalBlizzard_CombatLog_Update_QuickButtons
local GUISFilterIndex

local filters = {
	["GUISFilter"] = {
		name = L["GUIS"];
		hasQuickButton = true;
		quickButtonName = L["GUIS"];
		quickButtonDisplay = { party = true; solo = true; raid = true };
		onQuickBar = true;
		tooltip = L["Show simplified messages of actions done by you and done to you."];
		
		settings = {
			fullText = false;
			textMode = TEXT_MODE_A;

			timestamp = false;
			timestampFormat = TEXT_MODE_A_TIMESTAMP;

			unitColoring = true;
			sourceColoring = true;
			destColoring = true;
			lineColoring = false;
			lineHighlighting = true;

			abilityColoring = true;
			abilityActorColoring = false;
			abilitySchoolColoring = true;
			abilityHighlighting = true;

			actionColoring = false;
			actionActorColoring = false;
			actionHighlighting = false;

			amountColoring = true;
			amountActorColoring = false;
			amountSchoolColoring = true;
			amountHighlighting = true;

			schoolNameColoring = true;
			schoolNameActorColoring = false;
			schoolNameHighlighting = true;

			noMeleeSwingColoring = false;
			missColoring = true;

			braces = true;
			unitBraces = true;
			sourceBraces = true;
			destBraces = true;
			spellBraces = true;
			itemBraces = true;

			showHistory = true;

			lineColorPriority = 1;  -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest

			unitIcons = true;

			hideBuffs = false;
			hideDebuffs = false;
		};
		
		colors = {
			eventColoring = {};
			highlightedEvents = { ["PARTY_KILL"] = true; };
			defaults = CopyTable(C["combatlog"].defaults);
			schoolColoring = CopyTable(C["combatlog"].schoolColoring);
			unitColoring = CopyTable(C["combatlog"].unitColoring);
		};
		
		filters = {
			[1] = {
				eventList = {
					["ENVIRONMENTAL_DAMAGE"] = true;
					["SWING_DAMAGE"] = true;
					["SWING_MISSED"] = true;
					["RANGE_DAMAGE"] = true;
					["RANGE_MISSED"] = true;
				    --["SPELL_CAST_START"] = true;
				    --["SPELL_CAST_SUCCESS"] = true;
					--["SPELL_CAST_FAILED"] = true;
					["SPELL_MISSED"] = true;
					["SPELL_DAMAGE"] = true;
					["SPELL_HEAL"] = true;
					["SPELL_ENERGIZE"] = true;
					["SPELL_DRAIN"] = true;
					["SPELL_LEECH"] = true;
					["SPELL_INSTAKILL"] = true;
					["SPELL_INTERRUPT"] = true;
					["SPELL_EXTRA_ATTACKS"] = true;
					--["SPELL_DURABILITY_DAMAGE"] = true;
					--["SPELL_DURABILITY_DAMAGE_ALL"] = true;
					["SPELL_AURA_APPLIED"] = true;
					["SPELL_AURA_APPLIED_DOSE"] = true;
					["SPELL_AURA_BROKEN"] = true;
					["SPELL_AURA_BROKEN_SPELL"] = true;
					["SPELL_AURA_REFRESH"] = true;
					["SPELL_AURA_REMOVED"] = true;
					["SPELL_AURA_REMOVED_DOSE"] = true;
					["SPELL_DISPEL"] = true;
					["SPELL_STOLEN"] = true;
					["ENCHANT_APPLIED"] = true;
					["ENCHANT_REMOVED"] = true;
					["SPELL_PERIODIC_MISSED"] = true;
					["SPELL_PERIODIC_DAMAGE"] = true;
					["SPELL_PERIODIC_HEAL"] = true;
					["SPELL_PERIODIC_ENERGIZE"] = true;
					["SPELL_PERIODIC_DRAIN"] = true;
					["SPELL_PERIODIC_LEECH"] = true;
					["SPELL_DISPEL_FAILED"] = true;
					--["DAMAGE_SHIELD"] = true;
					--["DAMAGE_SHIELD_MISSED"] = true;
					--["DAMAGE_SPLIT"] = true;
					["PARTY_KILL"] = true;
					["UNIT_DIED"] = true;
					["UNIT_DESTROYED"] = true;
					["UNIT_DISSIPATES"] = true;
				};
				sourceFlags = {
					[COMBATLOG_FILTER_MINE] = true;
					[COMBATLOG_FILTER_MY_PET] = true;
				};
				destFlags = nil;
			};
			[2] = {
				eventList = {
					--["ENVIRONMENTAL_DAMAGE"] = true;
					["SWING_DAMAGE"] = true;
					["SWING_MISSED"] = true;
					["RANGE_DAMAGE"] = true;
					["RANGE_MISSED"] = true;
				    --["SPELL_CAST_START"] = true;
				    --["SPELL_CAST_SUCCESS"] = true;
					--["SPELL_CAST_FAILED"] = true;
					["SPELL_MISSED"] = true;
					["SPELL_DAMAGE"] = true;
					["SPELL_HEAL"] = true;
					["SPELL_ENERGIZE"] = true;
					["SPELL_DRAIN"] = true;
					["SPELL_LEECH"] = true;
					["SPELL_INSTAKILL"] = true;
					["SPELL_INTERRUPT"] = true;
					["SPELL_EXTRA_ATTACKS"] = true;
					--["SPELL_DURABILITY_DAMAGE"] = true;
					--["SPELL_DURABILITY_DAMAGE_ALL"] = true;
					--["SPELL_AURA_APPLIED"] = true;
					--["SPELL_AURA_APPLIED_DOSE"] = true;
					--["SPELL_AURA_REMOVED"] = true;
					--["SPELL_AURA_REMOVED_DOSE"] = true;
					["SPELL_DISPEL"] = true;
					["SPELL_STOLEN"] = true;
					["ENCHANT_APPLIED"] = true;
					["ENCHANT_REMOVED"] = true;
					--["SPELL_PERIODIC_MISSED"] = true;
					--["SPELL_PERIODIC_DAMAGE"] = true;
					--["SPELL_PERIODIC_HEAL"] = true;
					--["SPELL_PERIODIC_ENERGIZE"] = true;
					--["SPELL_PERIODIC_DRAIN"] = true;
					--["SPELL_PERIODIC_LEECH"] = true;
					["SPELL_DISPEL_FAILED"] = true;
					--["DAMAGE_SHIELD"] = true;
					--["DAMAGE_SHIELD_MISSED"] = true;
					--["DAMAGE_SPLIT"] = true;
					["PARTY_KILL"] = true;
					["UNIT_DIED"] = true;
					["UNIT_DESTROYED"] = true;
					["UNIT_DISSIPATES"] = true;
				};
				sourceFlags = nil;
				destFlags = {
					[COMBATLOG_FILTER_MINE] = true;
					[COMBATLOG_FILTER_MY_PET] = true;
				};
			};
		};
	};
}
local GUISFilter = filters["GUISFilter"]

local defaults = {
	maintainFilter = true; -- maintain the contents of the GUIS filter so that they're always the same
	autoSetOnLogin = true; -- autmatically switch to the GUIS filter when you log in or reload the UI
	autoSetOnEnter = true; -- autmatically switch to the GUIS filter whenever you see a loading screen
	autoSetOnCombat = true; -- automatically switch to the GUIS filter when entering combat
	keepSimpleQuickButtons = true; -- keep only the GUIS and 'everything' quickbuttons visible, with GUIS at the start
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
				type = "group";
				order = 5;
				virtual = true;
				children = {
					{ -- maintain
						type = "widget";
						element = "CheckButton";
						name = "maintainFilter";
						order = 5;
						width = "full"; 
						msg = L["Maintain the settings of the GUIS filter so that they're always the same"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combatlog.maintainFilter = not(GUIS_DB.combatlog.maintainFilter)
						end;
						get = function() return GUIS_DB.combatlog.maintainFilter end;
					};
					{ -- quickbuttons
						type = "widget";
						element = "CheckButton";
						name = "keepSimpleQuickButtons";
						order = 10;
						width = "full"; 
						msg = L["Keep only the GUIS and '%s' quickbuttons visible, with GUIS at the start"]:format(QUICKBUTTON_NAME_EVERYTHING);
						desc = nil;
						set = function(self) 
							GUIS_DB.combatlog.keepSimpleQuickButtons = not(GUIS_DB.combatlog.keepSimpleQuickButtons)
						end;
						get = function() return GUIS_DB.combatlog.keepSimpleQuickButtons end;
					};
					{ -- login/reload
						type = "widget";
						element = "CheckButton";
						name = "autoSetOnLogin";
						order = 15;
						width = "full"; 
						msg = L["Autmatically switch to the GUIS filter when you log in or reload the UI"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combatlog.autoSetOnLogin = not(GUIS_DB.combatlog.autoSetOnLogin)
						end;
						get = function() return GUIS_DB.combatlog.autoSetOnLogin end;
					};
					{ -- loading screen
						type = "widget";
						element = "CheckButton";
						name = "autoSetOnEnter";
						order = 20;
						width = "full"; 
						msg = L["Autmatically switch to the GUIS filter whenever you see a loading screen"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combatlog.autoSetOnEnter = not(GUIS_DB.combatlog.autoSetOnEnter)
						end;
						get = function() return GUIS_DB.combatlog.autoSetOnEnter end;
					};
					{ -- combat
						type = "widget";
						element = "CheckButton";
						name = "autoSetOnCombat";
						order = 25;
						width = "full"; 
						msg = L["Automatically switch to the GUIS filter when entering combat"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combatlog.autoSetOnCombat = not(GUIS_DB.combatlog.autoSetOnCombat)
						end;
						get = function() return GUIS_DB.combatlog.autoSetOnCombat end;
					};
				};
			};
		};
	};
}

--
-- we have to manually refresh the global links to the combat log tables whenever we change a value in them
local Refresh = function()
	if (IsAddOnLoaded("Blizzard_CombatLog")) then
		Blizzard_CombatLog_RefreshGlobalLinks()
	end
end

local updateGUISFilterIndex = function()
	Refresh()

	-- reset our index
	GUISFilterIndex = nil
	
	-- search the filter list for the GUIS filter
	for index, filter in ipairs(Blizzard_CombatLog_Filters.filters) do
		if (type(filter) == "table") and (filter.name == L["GUIS"]) then
			GUISFilterIndex = index
		end
	end
	
	return GUISFilterIndex
end

local createOrUpdateGUISFilter = function()
	updateGUISFilterIndex()
	
	if (GUISFilterIndex) then
		if (GUIS_DB["combatlog"].maintainFilter) then
			Blizzard_CombatLog_Filters.filters[GUISFilterIndex] = DuplicateTable(GUISFilter, Blizzard_CombatLog_Filters.filters[GUISFilterIndex])
			
			Refresh()
		end
	else
		tinsert(Blizzard_CombatLog_Filters.filters, GUISFilter)
		updateGUISFilterIndex()

		Blizzard_CombatLog_Update_QuickButtons()
	end
end

local setFilterToGUIS = function()
	if not(updateGUISFilterIndex()) then
		createOrUpdateGUISFilter()
	end
	
	Blizzard_CombatLog_Filters.currentFilter = GUISFilterIndex
	Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter]
	Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings)
	
	Refresh()
	
	if (Blizzard_CombatLog_CurrentSettings.settings) and (Blizzard_CombatLog_CurrentSettings.settings.showHistory) then
		Blizzard_CombatLog_Refilter()
	end
	
	Blizzard_CombatLog_Update_QuickButtons()
end

local running
local setSimpleQuickButtons = function()
	if not(GUIS_DB["combatlog"].keepSimpleQuickButtons) then
		return
	end
	
	if (running) then
		return
	else
		running = true
	end
	
	Refresh()
	
	-- remove quickbuttons for everything except the GUIS and 'everything' filters
	for i, filter in ipairs(Blizzard_CombatLog_Filters.filters) do
		if ((filter.name == QUICKBUTTON_NAME_EVERYTHING) or (filter.name == L["GUIS"])) then
			filter.hasQuickButton = true
			filter.onQuickBar = true
		else
			filter.hasQuickButton = nil
			filter.onQuickBar = false
		end
	end
	
	-- move the GUIS quickbutton to the top of the list
	updateGUISFilterIndex()
	if (GUISFilterIndex) and (GUISFilterIndex > 1) then
		local current = Blizzard_CombatLog_Filters.currentFilter

		-- insert a copy of the GUIS filter at the top
		tinsert(Blizzard_CombatLog_Filters.filters, 1, CopyTable(Blizzard_CombatLog_Filters.filters[GUISFilterIndex]))
		
		-- remove the old GUIS filter
		tremove(Blizzard_CombatLog_Filters.filters, GUISFilterIndex + 1)

		-- the selected filter was below the GUIS filter, so it keeps  the same index
		if (current > GUISFilterIndex) then
			-- no action required
		
		-- the selected filter was above the GUIS filter, so it got pushed down
		elseif (current < GUISFilterIndex) then
			Blizzard_CombatLog_Filters.currentFilter = current + 1
			
		-- the select filter WAS the GUIS filter, so we set it to the first entry which is the new GUIS filter
		elseif (current == GUISFilterIndex) then
			Blizzard_CombatLog_Filters.currentFilter = 1
		end

		-- update the GUIS filter index
		-- we could just set it to 1...
		updateGUISFilterIndex()
		
		Refresh()
		Blizzard_CombatLog_Update_QuickButtons()
	end
	
	running = nil
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["combatlog"] = DuplicateTable(defaults)
end

module.Init = function()
	GUIS_DB["combatlog"] = GUIS_DB["combatlog"] or {}
	GUIS_DB["combatlog"] = ValidateTable(GUIS_DB["combatlog"], defaults)
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill() 
		return 
	end
	
	local start = function()
		Refresh()
		
		-- pre-hook the quickbutton updater, to keep only our selected buttons visible
		--[[
			3/23 21:00:12.058  Global variable Blizzard_CombatLog_Update_QuickButtons tainted by GUIS-gUI - Interface\AddOns\GUIS-gUI\modules\combatlog\combatlog.lua:341 start()
		]]--
--		OriginalBlizzard_CombatLog_Update_QuickButtons = Blizzard_CombatLog_Update_QuickButtons
--		Blizzard_CombatLog_Update_QuickButtons = function()
--			setSimpleQuickButtons()
--		end
		hooksecurefunc("Blizzard_CombatLog_Update_QuickButtons", setSimpleQuickButtons)

		if (GUIS_DB["combatlog"].maintainFilter) then
			createOrUpdateGUISFilter()
		end
		
		if (GUIS_DB["combatlog"].autoSetOnLogin) then
			setFilterToGUIS()
		end	
		
		hooksecurefunc("CombatConfig_CreateCombatFilter", updateGUISFilterIndex)
		hooksecurefunc("CombatConfig_DeleteCurrentCombatFilter", updateGUISFilterIndex)
		hooksecurefunc("ChatConfig_MoveFilterUp", updateGUISFilterIndex)
		hooksecurefunc("ChatConfig_MoveFilterDown", updateGUISFilterIndex)
		
		RegisterCallback("PLAYER_REGEN_DISABLED", setFilterToGUIS)
		
		if (GUIS_DB["combatlog"].autoSetOnLogin) then
			if IsLoggedIn() then
				setFilterToGUIS()
			else
				RegisterCallback("PLAYER_LOGIN", setFilterToGUIS)
			end
		end

		RegisterCallback("PLAYER_ENTERING_WORLD", function()
			if (GUIS_DB["combatlog"].autoSetOnEnter) then
				setFilterToGUIS()
			end
		end)
	end
	
	if (IsAddOnLoaded("Blizzard_CombatLog")) then
		start()
	else
		local callback
		local proxy = function(self, event, addon)
			if (addon == "Blizzard_CombatLog") then
				start()
				UnregisterCallback(callback)
			end
		end
		callback = RegisterCallback("ADDON_LOADED", proxy)
	end
	
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

module.OnDisable = function(self)
	Refresh()
end
