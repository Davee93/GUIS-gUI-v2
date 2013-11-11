--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Quest")

-- Lua API
local format = string.format
local pairs, unpack = pairs, unpack

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gFrameHandler = LibStub("gFrameHandler-1.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local FireCallback = function(...) return module:FireCallback(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end

local defaults = {
	questLogLevel = true;
	autoCollapseWatchFrame = true;
	autoCollapseOnBoss = true;
	autoAlignWatchFrame = true;
	rightAlignWatchFrame = true;
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
			{ -- description
				type = "widget";
				element = "Text";
				order = 2;
				msg = L["These options allow you to customize how game objectives like Quests and Achievements are displayed in the user interface. If you wish to change the position of the ObjectivesTracker, you can unlock it for movement with |cFF4488FF/glock|r."];
			};
			
			{ -- questlog
				type = "group";
				order = 20;
				name = "questlog";
				virtual = true;
				children = {
					{ -- questlog title
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["QuestLog"];
					};
				
					{ -- blizzard: auto quest watch
						type = "widget";
						element = "CheckButton";
						name = "autoQuestWatch";
						order = 10;
						width = "full"; 
						msg = AUTO_QUEST_WATCH_TEXT;
						desc = nil;
						set = function(self) 
							SetCVar("autoQuestWatch", (tonumber(GetCVar("autoQuestWatch")) == 1) and "0" or "1")
							self:onrefresh()
						end;
						get = function() return tonumber(GetCVar("autoQuestWatch")) == 1 end;
						onrefresh = function(self) 
							AUTO_QUEST_WATCH = (tonumber(GetCVar("autoQuestWatch")) == 1) and "1" or "0"
						end;
						init = function(self) 
							self:onrefresh()
							hooksecurefunc("InterfaceOptionsFrame_LoadUVars", self.onrefresh)
						end;
					};
					{ -- blizzard: auto track quest progress
						type = "widget";
						element = "CheckButton";
						name = "autoQuestProgress";
						order = 15;
						width = "full"; 
						msg = AUTO_QUEST_PROGRESS_TEXT;
						desc = nil;
						set = function(self) 
							SetCVar("autoQuestProgress", (tonumber(GetCVar("autoQuestProgress")) == 1) and 0 or 1)
						end;
						get = function() return tonumber(GetCVar("autoQuestProgress")) == 1 end;
					};
					{ -- quest levels
						type = "widget";
						element = "CheckButton";
						name = "questLogLevel";
						order = 10;
						width = "full"; 
						msg = L["Display quest level in the QuestLog"];
						desc = nil;
						set = function(self) 
							GUIS_DB.quest.questLogLevel = not(GUIS_DB.quest.questLogLevel)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.quest.questLogLevel end;
					};
					{ -- blizzard: quest difficulty on map
						type = "widget";
						element = "CheckButton";
						name = "mapQuestDifficulty";
						order = 20;
						width = "full"; 
						msg = MAP_QUEST_DIFFICULTY_TEXT;
						desc = nil;
						set = function(self) 
							SetCVar("mapQuestDifficulty", (tonumber(GetCVar("mapQuestDifficulty")) == 1) and 0 or 1)
						end;
						get = function() return tonumber(GetCVar("mapQuestDifficulty")) == 1 end;
					};
				};
			};
			{ -- objectives
				type = "group";
				order = 30;
				name = "objectives";
				virtual = true;
				children = {
					{ -- objectives title
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Objectives Tracker"];
					};
					--[[
					{ -- autocollapse
						type = "widget";
						element = "CheckButton";
						name = "autoCollapseWatchFrame";
						order = 50;
						width = "full"; 
						msg = L["Display quest level in the QuestLog"];
						desc = nil;
						set = function(self) 
							GUIS_DB.quest.autoCollapseWatchFrame = not(GUIS_DB.quest.autoCollapseWatchFrame)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.quest.autoCollapseWatchFrame end;
					};
					]]--
					{ -- blizzard: wider objectives tracker
						type = "widget";
						element = "CheckButton";
						name = "watchFrameWidth";
						order = 30;
						width = "full"; 
						msg = WATCH_FRAME_WIDTH_TEXT;
						desc = nil;
						set = function(self) 
							SetCVar("watchFrameWidth", (tonumber(GetCVar("watchFrameWidth")) == 1) and 0 or 1)
							module:UpdateAll()
						end;
						get = function() return tonumber(GetCVar("watchFrameWidth")) == 1 end;
					};
					{ -- autocollapse watchframe when boss frames are visible
						type = "widget";
						element = "CheckButton";
						name = "autoCollapseOnBoss";
						order = 55;
						width = "full"; 
						msg = L["Autocollapse the WatchFrame when a boss unitframe is visible"];
						desc = nil;
						set = function(self) 
							GUIS_DB.quest.autoCollapseOnBoss = not(GUIS_DB.quest.autoCollapseOnBoss)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.quest.autoCollapseOnBoss end;
					};
					{ -- autoalign the watchframe
						type = "widget";
						element = "CheckButton";
						name = "autoAlignWatchFrame";
						order = 60;
						width = "full"; 
						msg = L["Automatically align the WatchFrame based on its current position"];
						desc = nil;
						set = function(self) 
							GUIS_DB.quest.autoAlignWatchFrame = not(GUIS_DB.quest.autoAlignWatchFrame)
							self:onrefresh()
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.quest.autoAlignWatchFrame end;
						onrefresh = function(self) 
							if (GUIS_DB.quest.autoAlignWatchFrame) then
								self.parent.child.rightAlignWatchFrame:Disable()
							else
								self.parent.child.rightAlignWatchFrame:Enable()
							end
						end;
						init = function(self) self:onrefresh() end;
					};
					{ -- right-align the watchframe
						type = "widget";
						element = "CheckButton";
						name = "rightAlignWatchFrame";
						order = 65;
						width = "full";
						msg = L["Align the WatchFrame to the right"];
						desc = nil;
						set = function(self) 
							GUIS_DB.quest.rightAlignWatchFrame = not(GUIS_DB.quest.rightAlignWatchFrame)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB.quest.rightAlignWatchFrame end;
					};
				};
			};
		};
	};
}

local faq = {
	{
		q = L["My actionbars cover the quest tracker!"];
		a = {
			{
				type = "text";
				msg = L["You can manually move the quest tracker as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key. If you wish the quest tracker to automatically move in relation to your actionbars, then reset its position to the default. |n|nWhen a frame is unlocked with the |cFF4488FF/glock|r command, you can right click on its overlay and select 'Reset' to return it to its default position. For some frames like the quest tracker, this will allow the UI to decide where it should be put."];
			};
			{
				type = "image";
				w = 512; h = 256;
				path = M["Texture"]["Core-FrameLock"]
			};
		};
		tags = { "actionbars", "positioning", "quest tracker" };
	};
	{
		q = L["How can I move the quest tracker?"];
		a = {
			{ 
				type = "text";  
				msg = L["You can manually move the quest tracker as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key. If you wish the quest tracker to automatically move in relation to your actionbars, then reset its position to the default. |n|nWhen a frame is unlocked with the |cFF4488FF/glock|r command, you can right click on its overlay and select 'Reset' to return it to its default position. For some frames like the quest tracker, this will allow the UI to decide where it should be put."];
			};
			{
				type = "image";
				w = 512; h = 256;
				path = M["Texture"]["Core-FrameLock"]
			};
		};
		tags = { "quest tracker", "positioning" };
	};
}

local questlevel = function()
	if not(GUIS_DB["quest"].questLogLevel) then return end

	local buttons = QuestLogScrollFrame.buttons
	local numButtons = #buttons
	local scrollOffset = HybridScrollFrame_GetOffset(QuestLogScrollFrame)
	local numEntries, numQuests = GetNumQuestLogEntries()
	
	for i = 1, numButtons do
		local questIndex = i + scrollOffset
		local questLogTitle = buttons[i]
		if (questIndex <= numEntries) then
			local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(questIndex)
			if (not isHeader) then
				questLogTitle:SetText("[" .. level .. "] " .. title)
				QuestLogTitleButton_Resize(questLogTitle)
			end
		end
	end
end

module.UpdateAll = function(self) 
	questlevel()
	
	local watchframe = LibStub("gCore-3.0"):GetModule("GUIS-gUI: QuestWatchFrame")
	if (watchframe) then
		watchframe:UpdateAll()
	end
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["quest"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["quest"] = GUIS_DB["quest"] or {}
	GUIS_DB["quest"] = ValidateTable(GUIS_DB["quest"], defaults)
end

module.OnInit = function(self)
	if F.kill("GUIS-gUI: Quest") then
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
	
	-- register the FAQ
	do
		local FAQ = LibStub("gCore-3.0"):GetModule("GUIS-gUI: FAQ")
		FAQ:NewGroup(faq)
	end
end

module.OnEnter = function(self)
	hooksecurefunc("QuestLog_Update", questlevel)
	QuestLogScrollFrameScrollBar:HookScript("OnValueChanged", questlevel)
end