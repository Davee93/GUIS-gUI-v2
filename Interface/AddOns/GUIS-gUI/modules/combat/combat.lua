--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Combat")

-- Lua API

-- WoW API 

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) return module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) return module:UnregisterCallback(...) end

local defaults = {
	scrollingText = true; -- use our own scrolling combat text module
	dps = true; -- show our simple dps/heal meter
	threat = true; -- show our threat bar
	
	-- dps/heal settings
	showSoloDPS = true; -- show the DPS meter when you are solo/ungrouped
	showPvPDPS = false; -- show the DPS meter in PvP situations
	showDPSVerboseReport = true; -- give a simple verbose report to the chat upon combat end
	minDPS = 1000; -- don't show reports unless you do at least this much DPS
	minTime = 60; -- don't show reports for fights shorter than this in seconds
	
	-- threat settings
	showWarnings = false; -- show warnings when you change threat group
	showSoloThreat = false; -- show the threat meter when you are solo/ungrouped
	showPvPThreat = false; -- show the threat meter in PvP situations (will show for pets, bosses, npcs, etc)
	showHealerThreat = false; -- shows the threat meter for healers as well as tanks/dps
	showFocusThreat = false; -- shows the threat for the focus target instead of target when availble
}

local menuTable = {
	{
		type = "group";
		name = module:GetName();
		order = 1;
		virtual = true;
		children = {
			{ -- title
				type = "widget";
				element = "Title";
				order = 1;
				msg = F.getName(module:GetName());
			};
			
			{ -- dps/hps enable
				type = "widget";
				element = "CheckButton";
				name = "showDPS";
				order = 5;
				width = "full"; 
				msg = L["Enable simple DPS/HPS meter"];
				desc = nil;
				set = function(self) 
					GUIS_DB.combat.dps = not(GUIS_DB.combat.dps)
					self:onrefresh()
					module:UpdateAll()
				end;
				onrefresh = function(self) 
					if (self:get()) then
						if not(self.parent.child.dps:IsEnabled()) then
							self.parent.child.dps:Enable()
						end
					else
						if (self.parent.child.dps:IsEnabled()) then
							self.parent.child.dps:Disable()
						end
					end
				end;
				get = function() return GUIS_DB.combat.dps end;
				init = function(self) self:onrefresh() end;

			};

			{ -- dps/hps choices
				type = "group";
				order = 15;
				name = "dps";
				virtual = true;
				children = {
					{ -- dps/hps title
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Simple DPS/HPS Meter"];
					};
					{ -- solo
						type = "widget";
						element = "CheckButton";
						name = "showSoloDPS";
						order = 10;
						msg = L["Show DPS/HPS when you are solo"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combat.showSoloDPS = not(GUIS_DB.combat.showSoloDPS)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.combat.showSoloDPS end;
					};
					{ -- pvp
						type = "widget";
						element = "CheckButton";
						name = "showPvPDPS";
						order = 15;
						msg = L["Show DPS/HPS when you are in a PvP instance"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combat.showPvPDPS = not(GUIS_DB.combat.showPvPDPS)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.combat.showPvPDPS end;
					};
					{ -- verbose report
						type = "widget";
						element = "CheckButton";
						name = "showDPSVerboseReport";
						order = 20;
						msg = L["Display a simple verbose report at the end of combat"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combat.showDPSVerboseReport = not(GUIS_DB.combat.showDPSVerboseReport)
							self:onrefresh()
							module:UpdateAll()
						end;
						onrefresh = function(self) 
							if (self:get()) then
								self.parent.child.report:Enable()
							else
								self.parent.child.report:Disable()
							end
						end;
						get = function() return GUIS_DB.combat.showDPSVerboseReport end;
						init = function(self) self:onrefresh() end;
					};
					{ -- verbose report choices
						type = "group";
						order = 21;
						name = "report";
						virtual = true;
						children = {
							{ -- minimum average DPS text
								type = "widget";
								element = "Header";
								name = "minDPSText";
								order = 10;
								width = "minimum";
								indented = true;
								msg = L["Minimum DPS to display: "];
							};
							
							{ -- minimum average DPS inputbox
								type = "widget";
								element = "EditBox";
								args = { numeric = true };
								name = "minDPS";
								order = 11;
								width = "last";
								msg = L["dps"];
								set = function(self, msg) 
									local value = tonumber(msg)
									
									if (value) then
										value = floor(value)
										if (value >= 0) then
											GUIS_DB.combat.minDPS = value
											
											module:UpdateAll()
										end
									end
								end;
								get = function(self) return GUIS_DB.combat.minDPS end;
							};
							
							
							{ -- minimum combat duration text
								type = "widget";
								element = "Header";
								name = "minTimeText";
								order = 20;
								width = "minimum";
								indented = true;
								msg = L["Minimum combat duration to display: "];
							};
							
							{ -- minimum combat duration inputbox
								type = "widget";
								element = "EditBox";
								args = { numeric = true };
								name = "minTime";
								order = 21;
								width = "last";
								msg = L["s"];
								set = function(self, msg) 
									local value = tonumber(msg)
									
									if (value) then
										value = floor(value)
										if (value >= 0) then
											GUIS_DB.combat.minTime = value
											
											module:UpdateAll()
										end
									end
								end;
								get = function(self) return GUIS_DB.combat.minTime end;
							};
						};
					};
				};
			};

			{ -- threat enable
				type = "widget";
				element = "CheckButton";
				name = "showThreat";
				order = 6;
				width = "full"; 
				msg = L["Enable simple Threat meter"];
				desc = nil;
				set = function(self) 
					GUIS_DB.combat.threat = not(GUIS_DB.combat.threat)
					self:onrefresh()
					module:UpdateAll()
				end;
				onrefresh = function(self) 
					if (self:get()) then
						if not(self.parent.child.threat:IsEnabled()) then
							self.parent.child.threat:Enable()
						end
					else
						if (self.parent.child.threat:IsEnabled()) then
							self.parent.child.threat:Disable()
						end
					end
				end;
				get = function() return GUIS_DB.combat.threat end;
				init = function(self) self:onrefresh() end;
			};
			
			{ -- sct enable
				type = "widget";
				element = "CheckButton";
				name = "showSCT";
				order = 6;
				width = "full"; 
				msg = L["Enable simple scrolling combat text"] .. " " .. L["(In Development)"];
				desc = nil;
				set = function(self) 
					GUIS_DB.combat.scrollingText = not(GUIS_DB.combat.scrollingText)
					self:onrefresh()
					module:UpdateAll()
				end;
				onrefresh = function(self) 
					self:Disable()
--					if (self:get()) then
--						if not(self.parent.child.scrollingText:IsEnabled()) then
--							self.parent.child.scrollingText:Enable()
--						end
--					else
--						if (self.parent.child.scrollingText:IsEnabled()) then
--							self.parent.child.scrollingText:Disable()
--						end
--					end
				end;
				get = function() return GUIS_DB.combat.scrollingText end;
				init = function(self) self:onrefresh() end;
			};
			
			{ -- threat choices
				type = "group";
				order = 25;
				name = "threat";
				virtual = true;
				children = {
					{ -- threat title
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Simple Threat Meter"];
					};
					{ -- solo
						type = "widget";
						element = "CheckButton";
						name = "showSoloThreat";
						order = 10;
						msg = L["Show threat when you are solo"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combat.showSoloThreat = not(GUIS_DB.combat.showSoloThreat)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.combat.showSoloThreat end;
					};
					{ -- pvp
						type = "widget";
						element = "CheckButton";
						name = "showPvPThreat";
						order = 15;
						msg = L["Show threat when you are in a PvP instance"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combat.showPvPThreat = not(GUIS_DB.combat.showPvPThreat)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.combat.showPvPThreat end;
					};
					{ -- healer
						type = "widget";
						element = "CheckButton";
						name = "showHealerThreat";
						order = 20;
						msg = L["Show threat when you are a healer"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combat.showHealerThreat = not(GUIS_DB.combat.showHealerThreat)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.combat.showHealerThreat end;
					};
					{ -- focus
						type = "widget";
						element = "CheckButton";
						name = "showFocusThreat";
						order = 25;
						msg = L["Use the Focus target when it exists"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combat.showFocusThreat = not(GUIS_DB.combat.showFocusThreat)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.combat.showFocusThreat end;
					};
					{ -- warnings! achtung!
						type = "widget";
						element = "CheckButton";
						name = "showWarnings";
						order = 30;
						msg = L["Enable threat warnings"];
						desc = nil;
						set = function(self) 
							GUIS_DB.combat.showWarnings = not(GUIS_DB.combat.showWarnings)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.combat.showWarnings end;
					};
				};
			};
			
			{ -- sct choices
				type = "group";
				order = 35;
				name = "sct";
				virtual = true;
				children = {
				};
			};
		};
	};
}

module.UpdateAll = function(self)
	local dps = LibStub("gCore-3.0"):GetModule("GUIS-gUI: CombatDPS")
	if (dps) then
		dps:UpdateAll()
	end
	
	local threat = LibStub("gCore-3.0"):GetModule("GUIS-gUI: CombatThreat")
	if (threat) then
		threat:UpdateAll()
	end

	local cst = LibStub("gCore-3.0"):GetModule("GUIS-gUI: CombatScrollingText")
	if (cst) then
		cst:UpdateAll()
	end
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["combat"] = DuplicateTable(defaults)
	
	self:UpdateAll()
end

module.Init = function()
	GUIS_DB["combat"] = GUIS_DB["combat"] or {}
	GUIS_DB["combat"] = ValidateTable(GUIS_DB["combat"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
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
		gOM:RegisterWithBlizzard(gOM:New(menuTable, true), F.getName(self:GetName()), 
 			"default", restoreDefaults, 
			"cancel", cancelChanges, 
			"okay", applyChanges)
	end
end

