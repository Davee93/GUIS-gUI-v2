--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Status")

-- GUIS-gUI environment
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")

local defaults = {
	-- bars module
	showXPBar = true; 
	showXPBarAtMax = false; -- show xpbar at MAX_PLAYER_LEVEL (highest in your expansion, or if you have cancelled XP gains)
	showRepBar = true;
	showCaptureBar = true; -- capture bars in EotS
	
	-- score module
	showWorldScore = true;
	showDetailedScore = false; -- only show numbers and names, not text like "waves" or "reinforcements" except on mouseover
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
				msg = L["Here you can set the visibility and behaviour of various objects like the XP and Reputation Bars, the Battleground Capture Bars and more. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."];
			};
			{ -- status bars
				type = "group";
				order = 10;
				name = "statusbars";
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["StatusBars"];
					};
					{ -- xpbar
						type = "widget";
						element = "CheckButton";
						name = "showXPBar";
						order = 10;
						width = "full"; 
						msg = L["Show the player experience bar."];
						desc = nil;
						set = function(self) 
							GUIS_DB["status"].showXPBar = not(GUIS_DB["status"].showXPBar)
							self:onrefresh()
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["status"].showXPBar end;
						onrefresh = function(self) 
							if (GUIS_DB["status"].showXPBar) then
								self.parent.child.showXPBarAtMax:Enable()
							else
								self.parent.child.showXPBarAtMax:Disable()
							end
						end;
						init = function(self) self:onrefresh() end;
					};					
					{ -- xpbar at max
						type = "widget";
						element = "CheckButton";
						name = "showXPBarAtMax";
						order = 11;
						indented = true;
						width = "full"; 
						msg = L["Show when you are at your maximum level or have turned off experience gains."];
						desc = nil;
						set = function(self) 
							GUIS_DB["status"].showXPBarAtMax = not(GUIS_DB["status"].showXPBarAtMax)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["status"].showXPBarAtMax end;
					};	
					{ -- repbar
						type = "widget";
						element = "CheckButton";
						name = "showRepBar";
						order = 15;
						width = "full"; 
						msg = L["Show the currently tracked reputation."];
						desc = nil;
						set = function(self) 
							GUIS_DB["status"].showRepBar = not(GUIS_DB["status"].showRepBar)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["status"].showRepBar end;
					};					
					{ -- capturebar
						type = "widget";
						element = "CheckButton";
						name = "showCaptureBar";
						order = 25;
						width = "full"; 
						msg = L["Show the capturebar for PvP objectives."];
						desc = nil;
						set = function(self) 
							GUIS_DB["status"].showCaptureBar = not(GUIS_DB["status"].showCaptureBar)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["status"].showCaptureBar end;
					};					
				};
			};
		};
	};
}

module.UpdateAll = function(self)
	local StatusBars = LibStub("gCore-3.0"):GetModule("GUIS-gUI: StatusBars")
	if (StatusBars) then
		StatusBars:UpdateAll()
	end
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["status"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["status"] = GUIS_DB["status"] or {}
	GUIS_DB["status"] = ValidateTable(GUIS_DB["status"], defaults)
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill() 
		return 
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

module.OnEnable = function(self)	
end
