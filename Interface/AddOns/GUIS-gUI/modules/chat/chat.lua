--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Chat")

-- Lua API
local pairs, ipairs = pairs, ipairs
local gsub, strfind = string.gsub, string.find

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) module:UnregisterCallback(...) end

local AddMessage
local AlignMe, ColorEditBox 
local GetPosition, SetPosition, PrepareFrame
local SetUpChatFrame, SetPosAndSize, SetFrameFont
local channels = {}
local stickyChannels = { "BATTLEGROUND", "CHANNEL", "CHANNEL1", "CHANNEL2", "CHANNEL3", "CHANNEL4", "CHANNEL5", "CHANNEL6", "CHANNEL7", "CHANNEL8", "CHANNEL9", "CHANNEL10", "GUILD", "OFFICER", "PARTY", "RAID", "RAID_WARNING", "SAY" }

--[[
	Timestamps: (http://www.lua.org/pil/22.1.html)
		%a	abbreviated weekday name (e.g., Wed)
		%A	full weekday name (e.g., Wednesday)
		%b	abbreviated month name (e.g., Sep)
		%B	full month name (e.g., September)
		%c	date and time (e.g., 09/16/98 23:48:10)
		%d	day of the month (16) [01-31]
		%H	hour, using a 24-hour clock (23) [00-23]
		%I	hour, using a 12-hour clock (11) [01-12]
		%M	minute (48) [00-59]
		%m	month (09) [01-12]
		%p	either "am" or "pm" (pm)
		%S	second (10) [00-61]
		%w	weekday (3) [0-6 = Sunday-Saturday]
		%x	date (e.g., 09/16/98)
		%X	time (e.g., 23:48:10)
		%Y	full year (1998)
		%y	two-digit year (98) [00-99]
		%%	the character `%´
]]--

local defaults = {
	-- autosetup
	autoAlignMain = true; -- auto-align the Main window to the bottom left info panel
	autoAlignLoot = true; -- auto-align the Loot window to the bottom right info panel
	autoSizeMain = true; -- always set set size of the Main window to the minimum
	autoSizeLoot = true; -- always set set size of the Loot window to the minimum
	useLootFrame = true; -- use the Loot frame, and maintain its channels and groups
	
	-- chat bubble module
	collapseBubbles = true; -- shrink and expand chatbubbles on mouseover
	
	-- chat frame settings
	abbreviateChannels = true; -- abbreviate channel names
	abbreviateStrings = true; -- abbreviate strings for a cleaner chat
	removeBrackets = true; -- no brackets in the chat
	autoAlignChat = true; -- auto-align all chat windows based on position
	useIcons = true; -- use emoticons in the chat
	useIconsInBubbles = true; -- use emoticons in chat bubbles

	-- extra sound settings
	enableWhisperSound = true;

	-- timestamps
	useTimeStamps = true;
	useTimeStampsInLoot = false; -- display the timestamps in the "Loot" window
	timeStampFormat = "%H:%M"; 
	timeStampColor = { 0.6, 0.6, 0.6 };
	
	-- work in progress, none of the following options are there yet
	easyChatInit = false;
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
			{ -- subtext
				type = "widget";
				element = "Text";
				order = 2;
				msg = L["Here you can change the settings of the chat windows and chat bubbles. |n|n|cFFFF0000If you wish to change visible chat channels and messages within a chat window, background color, font size, or the class coloring of character names, then Right-Click the chat tab located above the relevant chat window instead.|r"];
			};
			{ -- sound
				type = "group";
				order = 10;
				name = "sound";
				virtual = true;
				children = {
					{ -- whispersound
						type = "widget";
						element = "CheckButton";
						name = "enableWhisperSound";
						order = 10;
						width = "full"; 
						msg = L["Enable sound alerts when receiving whispers or private Battle.net messages."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].enableWhisperSound = not(GUIS_DB["chat"].enableWhisperSound)
						end;
						get = function() return GUIS_DB["chat"].enableWhisperSound end;
					};
				};
			};
			{ -- display
				type = "group";
				order = 20;
				name = "display";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Chat Display"];
					};
					{ -- abbreviate channel names
						type = "widget";
						element = "CheckButton";
						name = "abbreviateChannels";
						order = 10;
						width = "full"; 
						msg = L["Abbreviate channel names."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].abbreviateChannels = not(GUIS_DB["chat"].abbreviateChannels)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["chat"].abbreviateChannels end;
					};
					{ -- abbreviate global strings
						type = "widget";
						element = "CheckButton";
						name = "abbreviateStrings";
						order = 20;
						width = "full"; 
						msg = L["Abbreviate global strings for a cleaner chat."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].abbreviateStrings = not(GUIS_DB["chat"].abbreviateStrings)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["chat"].abbreviateStrings end;
					};
					{ -- remove brackets
						type = "widget";
						element = "CheckButton";
						name = "removeBrackets";
						order = 30;
						width = "full"; 
						msg = L["Display brackets around player- and channel names."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].removeBrackets = not(GUIS_DB["chat"].removeBrackets)
							module:UpdateAll()
						end;
						get = function() return not(GUIS_DB["chat"].removeBrackets) end;
					};
					{ -- icons
						type = "widget";
						element = "CheckButton";
						name = "useIcons";
						order = 40;
						width = "full"; 
						msg = L["Use emoticons in the chat"];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].useIcons = not(GUIS_DB["chat"].useIcons)
						end;
						get = function() return GUIS_DB["chat"].useIcons end;
					};
					{ -- autoalign chat
						type = "widget";
						element = "CheckButton";
						name = "autoAlignChat";
						order = 50;
						width = "full"; 
						msg = L["Auto-align the text depending on the chat window's position."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].autoAlignChat = not(GUIS_DB["chat"].autoAlignChat)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["chat"].autoAlignChat end;
					};
					{ -- autoalign main chat window
						type = "widget";
						element = "CheckButton";
						name = "autoAlignMain";
						order = 60;
						width = "full"; 
						msg = L["Auto-align the main chat window to the bottom left panel/corner."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].autoAlignMain = not(GUIS_DB["chat"].autoAlignMain)
						end;
						get = function() return GUIS_DB["chat"].autoAlignMain end;
					};
					{ -- autosize main chat window
						type = "widget";
						element = "CheckButton";
						name = "autoSizeMain";
						order = 70;
						width = "full"; 
						msg = L["Auto-size the main chat window to match the bottom left panel size."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].autoSizeMain = not(GUIS_DB["chat"].autoSizeMain)
						end;
						get = function() return GUIS_DB["chat"].autoSizeMain end;
					};
				};
			};
			{ -- timestamps
				type = "group";
				order = 30;
				name = "timestamps";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Timestamps"];
					};
					{ -- display timestamps
						type = "widget";
						element = "CheckButton";
						name = "useTimeStamps";
						order = 10;
						width = "full"; 
						msg = L["Show timestamps."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].useTimeStamps = not(GUIS_DB["chat"].useTimeStamps)
						end;
						get = function() return GUIS_DB["chat"].useTimeStamps end;
					};
				};
			};
			{ -- bubbles
				type = "group";
				order = 40;
				name = "bubbles";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Chat Bubbles"];
					};
					{ -- collapse bubbles
						type = "widget";
						element = "CheckButton";
						name = "collapseBubbles";
						order = 10;
						width = "full"; 
						msg = L["Collapse chat bubbles"];
						desc = L["Collapses the chat bubbles to preserve space, and expands them on mouseover."];
						set = function(self) 
							GUIS_DB["chat"].collapseBubbles = not(GUIS_DB["chat"].collapseBubbles)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["chat"].collapseBubbles end;
					};
					{ -- icons in chat bubbles
						type = "widget";
						element = "CheckButton";
						name = "useIconsInBubbles";
						order = 20;
						width = "full"; 
						msg = L["Display emoticons in the chat bubbles"];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].useIconsInBubbles = not(GUIS_DB["chat"].useIconsInBubbles)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["chat"].useIconsInBubbles end;
					};
				};
			};
			{ -- loot
				type = "group";
				order = 50;
				name = "loot";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Loot Window"];
					};
					{ -- maintain lootframe channels and groups
						type = "widget";
						element = "CheckButton";
						name = "useLootFrame";
						order = 10;
						width = "full"; 
						msg = L["Maintain the channels and groups of the 'Loot' window."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].useLootFrame = not(GUIS_DB["chat"].useLootFrame)
						end;
						get = function() return GUIS_DB["chat"].useLootFrame end;
					};
					{ -- autoalign lootframe
						type = "widget";
						element = "CheckButton";
						name = "autoAlignLoot";
						order = 30;
						width = "full"; 
						msg = L["Auto-align the 'Loot' chat window to the bottom right panel/corner."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].autoAlignLoot = not(GUIS_DB["chat"].autoAlignLoot)
						end;
						get = function() return GUIS_DB["chat"].autoAlignLoot end;
					};
					{ -- autosize lootframe
						type = "widget";
						element = "CheckButton";
						name = "autoSizeLoot";
						order = 40;
						width = "full"; 
						msg = L["Auto-size the 'Loot' chat window to match the bottom right panel size."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].autoSizeLoot = not(GUIS_DB["chat"].autoSizeLoot)
						end;
						get = function() return GUIS_DB["chat"].autoSizeLoot end;
					};
					{ -- timestamps in loot
						type = "widget";
						element = "CheckButton";
						name = "useTimeStampsInLoot";
						order = 20;
						width = "full"; 
						msg = L["Show timestamps."];
						desc = nil;
						set = function(self) 
							GUIS_DB["chat"].useTimeStampsInLoot = not(GUIS_DB["chat"].useTimeStampsInLoot)
						end;
						get = function() return GUIS_DB["chat"].useTimeStampsInLoot end;
					};
				};
			};
		};
	};
}

AddMessage = function(self, msg, ...)
	if not(self) or not(msg) or not(self.BlizzAddMessage) then 
		return self, msg, ... 
	end

	-- uncomment to break the chat
	-- for development purposes only. weird stuff happens when used. 
	--	msg = gsub(msg, "|", "||")

	-- abbreviate channel names 
	if (GUIS_DB["chat"].abbreviateChannels) then
		msg = gsub(msg, "|Hchannel:(%w+):(%d)|h%[(%d)%. (%w+)%]|h", function(a, an, b, c)
			if not(channels[c]) then
				channels[c] = c
			end   
			return "|Hchannel:"..a..":"..an.."|h"..b.."."..channels[c]:abbreviate().."|h"
		end)
	end
	
	-- remove brackets
	if (GUIS_DB["chat"].removeBrackets) then
		msg = gsub(msg, "|Hchannel:(%w+)|h%[(%w+)%]|h", "|Hchannel:%1|h%2|h")
		msg = gsub(msg, "|Hchannel:(%w+)|h%[(%d)%. (%w+)%]|h", "|Hchannel:%1|h%2.%3|h")
		msg = gsub(msg, "|Hplayer:(.+):(.+)|h%[(.+)%]|h%:", "|Hplayer:%1:%2|h%3|h:")
	end
	
	-- add timestamps, but separate between the 'Loot' frame and others, 
	-- as they have separate options
	local isLootWindow = ((GetChatWindowInfo(self:GetID())) == L["Loot"])
	if ((isLootWindow) and (GUIS_DB["chat"].useTimeStampsInLoot))
	or (not(isLootWindow) and (GUIS_DB["chat"].useTimeStamps)) then
		local timeString = BetterDate(GUIS_DB["chat"].timeStampFormat, time())

		if not(GUIS_DB["chat"].removeBrackets) then
			timeString = "[" .. timeString .. "]"
		end
		
		local timeStamp = ("|cFF%s%s|r"):format(RGBToHex(unpack(GUIS_DB["chat"].timeStampColor)), timeString)

		if (GUIS_DB["chat"].autoAlignChat) and (self:GetJustifyH() == "RIGHT") then
			msg = msg .. " " .. timeStamp
		else
			msg = timeStamp .. " " .. msg
		end
	end
	
	self:BlizzAddMessage(msg, ...)
end

AlignMe = function(self, ...) 
	-- avoid stack overflow
	if (self.aligning) or not(GUIS_DB["chat"].autoAlignChat) then 
		return 
	end
	
	self.aligning = true
	
	local w, r, l = GetScreenWidth(), self:GetRight() or 0, self:GetLeft() or 0
	if ((w - r) < l) then
		self:SetJustifyH("RIGHT")
		self:SetIndentedWordWrap(false)
	else
		self:SetJustifyH("LEFT")
		self:SetIndentedWordWrap(true)
	end
	
	self.aligning = nil
end

ColorEditBox = function(editbox)
	if not(editbox:GetBackdrop()) then 
		return 
	end

	if (ACTIVE_CHAT_EDIT_BOX) then
		local type = editbox:GetAttribute("chatType")
		
		if (type == "CHANNEL") then
			local id = GetChannelName(editbox:GetAttribute("channelTarget"))
			if (id == 0) then	
				editbox:SetBackdropBorderColor(unpack(C["border"]))
				editbox:SetBackdropColor(unpack(C["overlay"]))
				editbox:SetUIShadowColor(unpack(C["shadow"]))
			else 
				-- 4.3
				local r,g,b = 1, 1, 1
				if (type) and (ChatTypeInfo[type..id]) then
					r = ChatTypeInfo[type..id].r or r
					g = ChatTypeInfo[type..id].g or g
					b = ChatTypeInfo[type..id].b or b
				end
				editbox:SetBackdropBorderColor(r, g, b)
				editbox:SetBackdropColor(r/3, g/3, b/3)
				editbox:SetUIShadowColor(r/3, g/3, b/3)
			end
		else
			-- 4.3
			local r,g,b = 1, 1, 1
			if (type) and (ChatTypeInfo[type]) then
				r = ChatTypeInfo[type].r or r
				g = ChatTypeInfo[type].g or g
				b = ChatTypeInfo[type].b or b
			end
			editbox:SetBackdropBorderColor(r, g, b)
			editbox:SetBackdropColor(r/3, g/3, b/3)
			editbox:SetUIShadowColor(r/3, g/3, b/3)
		end
	else
		editbox:SetBackdropBorderColor(unpack(C["border"]))
		editbox:SetBackdropColor(unpack(C["overlay"]))
		editbox:SetUIShadowColor(unpack(C["shadow"]))
	end
end

PrepareFrame = function(frame)
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetHitRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:SetMinResize(F.GetDefaultChatFrameWidth(), F.GetDefaultChatFrameHeight())
end

SetPosAndSize = function(frame)
	local easyChat = LibStub("gCore-3.0"):GetModule("GUIS-gUI: ChatEasy")
	if not(easyChat) then 
		return
	end
	
	PrepareFrame(frame)
	
	local name = frame:GetName()
	if (name == "ChatFrame1") then
		if (GUIS_DB["chat"].autoAlignMain) then easyChat:SetPoint("main") end
		if (GUIS_DB["chat"].autoSizeMain) then easyChat:SetSize("main") end
		
	else
		local cName, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(frame:GetID())
		if not(docked) then
			if (GUIS_DB["chat"].useLootFrame) and (cName == L["Loot"]) then
				if (GUIS_DB["chat"].autoAlignLoot) then easyChat:SetPoint("loot") end
				if (GUIS_DB["chat"].autoSizeLoot) then easyChat:SetSize("loot") end
			end
		end
	end
end

SetFrameFont = function(frame)
	frame:SetFontObject(GUIS_ChatFontNormal)
	frame:SetFont(GUIS_ChatFontNormal:GetFont())

	local name = frame:GetName()

	_G[name.."TabText"]:SetFontObject(GUIS_SystemFontNormal)
	_G[name.."TabText"]:SetFont(GUIS_SystemFontNormal:GetFont())

	_G[name.."EditBoxHeader"]:SetFontObject(GUIS_ChatFontNormal)
	_G[name.."EditBox"]:SetFontObject(GUIS_ChatFontNormal)
end

SetUpChatFrame = function(frame)
	local name = frame:GetName()
	
	SetFrameFont(frame)
	PrepareFrame(frame)

	if (frame.styled) then 
		return 
	end	
	
	frame.styled = true

	if not(frame.BlizzAddMessage) and (frame.AddMessage) and (frame ~= _G["ChatFrame2"]) then
		frame.BlizzAddMessage = frame.AddMessage
		frame.AddMessage = AddMessage
	end

	------------------------------------------------------------------------------------------------------------
	-- 	Alignment
	------------------------------------------------------------------------------------------------------------
	AlignMe(frame)

	hooksecurefunc(frame, "SetPoint", AlignMe)
	hooksecurefunc(frame, "SetAllPoints", AlignMe)
	hooksecurefunc(frame, "ClearAllPoints", AlignMe)
	hooksecurefunc(frame, "SetJustifyH", AlignMe)
	
	-- the tab is dragged, not the frame
	if (not _G[name.."Tab"]._onDragHooked) then
		_G[name.."Tab"]:HookScript("OnDragStart", function() AlignMe(frame) end)
		_G[name.."Tab"]:HookScript("OnDragStop", function() AlignMe(frame) end)
		_G[name.."Tab"]:HookScript("OnReceiveDrag", function() AlignMe(frame) end)

		_G[name.."Tab"]._onDragHooked = true
	end
	
	------------------------------------------------------------------------------------------------------------
	-- 	Background Textures
	------------------------------------------------------------------------------------------------------------
	for i,v in pairs(CHAT_FRAME_TEXTURES) do
		if (strfind(v, "ButtonFrame")) then
			_G[name .. v]:SetTexture("")
		end
	end
	
	------------------------------------------------------------------------------------------------------------
	-- 	Buttons
	------------------------------------------------------------------------------------------------------------
	_G[name.."ButtonFrameUpButton"]:Kill()
	_G[name.."ButtonFrameDownButton"]:Kill()
	_G[name.."ButtonFrameBottomButton"]:Kill()
	_G[name.."ButtonFrameMinimizeButton"]:Kill()

	------------------------------------------------------------------------------------------------------------
	-- 	EditBox
	------------------------------------------------------------------------------------------------------------
	_G[name.."EditBoxLeft"]:SetTexture("")
	_G[name.."EditBoxRight"]:SetTexture("")
	_G[name.."EditBoxMid"]:SetTexture("")
	_G[name.."EditBoxFocusLeft"]:SetTexture("")
	_G[name.."EditBoxFocusMid"]:SetTexture("")
	_G[name.."EditBoxFocusRight"]:SetTexture("")
 
	_G[name.."EditBox"]:Hide()
	_G[name.."EditBox"]:SetAltArrowKeyMode(false)
	_G[name.."EditBox"]:SetHeight(F.fixPanelHeight())
	_G[name.."EditBox"]:ClearAllPoints()
	_G[name.."EditBox"]:SetPoint("TOP", frame, "BOTTOM", 0, -7)
	_G[name.."EditBox"]:SetPoint("RIGHT", frame, "RIGHT", 3, 0)
	_G[name.."EditBox"]:SetPoint("LEFT", frame, "LEFT", -3, 0)

	_G[name.."EditBox"]:SetUITemplate("simplebackdrop")
--	_G[name.."EditBox"]:CreateUIShadow(5) -- we want a really visible shadow around active editboxes
	
	_G[name.."EditBox"]:HookScript("OnEditFocusGained", function(self) self:Show() end)
	_G[name.."EditBox"]:HookScript("OnEditFocusLost", function(self) self:Hide() end)

	hooksecurefunc("ChatEdit_UpdateHeader", ColorEditBox)

	------------------------------------------------------------------------------------------------------------
	-- 	Tabs
	------------------------------------------------------------------------------------------------------------
	_G[name.."TabLeft"]:SetTexture("")
	_G[name.."TabMiddle"]:SetTexture("")
	_G[name.."TabRight"]:SetTexture("")
	_G[name.."TabSelectedLeft"]:SetTexture("")
	_G[name.."TabSelectedMiddle"]:SetTexture("")
	_G[name.."TabSelectedRight"]:SetTexture("")
	_G[name.."TabHighlightLeft"]:SetTexture("")
	_G[name.."TabHighlightMiddle"]:SetTexture("")
	_G[name.."TabHighlightRight"]:SetTexture("")

	_G[name.."Tab"]:SetAlpha(1)
	_G[name.."Tab"].SetAlpha = UIFrameFadeRemoveFrame

	if not(frame.isTemporary) then
		_G[name .. "TabText"]:Hide()

		_G[name.."Tab"]:HookScript("OnEnter", function(self) _G[name .. "TabText"]:Show() end)
		_G[name.."Tab"]:HookScript("OnLeave", function(self) _G[name .. "TabText"]:Hide() end)
		
		_G[name.."ClickAnywhereButton"]:HookScript("OnEnter", function(self) _G[name .. "TabText"]:Show() end)
		_G[name.."ClickAnywhereButton"]:HookScript("OnLeave", function(self) _G[name .. "TabText"]:Hide() end)
	end
	
	if (_G[name.."Tab"].conversationIcon) then 
		_G[name.."Tab"].conversationIcon:Kill()
	end
	
	_G[name.."Tab"]:HookScript("OnClick", function() _G[name.."EditBox"]:Hide() end)
	_G[name.."ClickAnywhereButton"]:HookScript("OnClick", function() 
		FCF_Tab_OnClick(_G[name]) -- click the tab to actually select this frame
		_G[name.."EditBox"]:Hide() -- hide the annoying half-transparent editbox 
	end)
end

do
	local frame
	local parts = 6
	module.Install = function(self, option, index)
		local easyChat = LibStub("gCore-3.0"):GetModule("GUIS-gUI: ChatEasy")
	
		if (option == "frame") then
			if not(frame) then
--				frame = CreateFrame("Frame", nil, UIParent)
--				frame:Hide()
--				frame:SetSize(600, 200)
			end
			
			return frame, parts
			
		elseif (option == "title") then
			if not(index) or (index == 1) then
				return F.getName(self:GetName()) .. ": " .. L["Public Chat Window"]
			
			elseif (index == 2) then
				return F.getName(self:GetName()) .. ": " .. L["Loot Window"]
			
			elseif (index == 3) then
				return F.getName(self:GetName()) .. ": " .. L["Initial Window Size & Position"]

			elseif (index == 4) then
				return F.getName(self:GetName()) .. ": " .. L["Window Auto-Positioning"]

			elseif (index == 5) then
				return F.getName(self:GetName()) .. ": " .. L["Window Auto-Sizing"]
			
			elseif (index == 6) then
				return F.getName(self:GetName()) .. ": " .. L["Channel & Window Colors"]

			end
		
		elseif (option == "description") then
			if not(index) or (index == 1) then
				return L["Public chat like Trade, General and LocalDefense can be displayed in a separate tab in the main chat window. This will keep your main chat window free from intrusive spam, while still having all the relevant public chat available. Do you wish to do so now?"]
				
			elseif (index == 2) then
				return L["Information like received loot, crafted items, experience, reputation and honor gains as well as all currencies and similar received items can be displayed in a separate chat window. Do you wish to do so now?"] .. "|n|n" .. F.warning(L["This is recommended!"])
				
			elseif (index == 3) then
				return L["Your chat windows can be configured to match the unitframes and the bottom UI panels in size and position. Do you wish to do so now?"] .. "|n|n" .. F.warning(L["This is recommended!"])
				
			elseif (index == 4) then
				return L["Your chat windows will slightly change position when you change UI scale, game window size or screen resolution. The UI can maintain the position of the '%s' and '%s' chat windows whenever you log in, reload the UI or in any way change the size or scale of the visible area. Do you wish to activate this feature?"]:format(L["Main"], L["Loot Window"]) .. "|n|n" .. F.warning(L["This is recommended!"])
			
			elseif (index == 5) then
				return L["Would you like the UI to maintain the default size of the chat frames, aligning them in size to visually fit the unitframes and bottom UI panels?"] .. "|n|n" .. F.warning(L["This is recommended!"])
				
			elseif (index == 6) then
				return L["Would you like to change chatframe colors to what %s recommends?"]:format(L["Goldpaw"])
			end
		
		elseif (option == "execute") then
			if not(index) or (index == 1) then
				return function() 
					easyChat:Create("public") 
				end
			
			elseif (index == 2) then
				return function()
					GUIS_DB["chat"].useLootFrame = true
					easyChat:Create("loot")
					module:PostUpdateGUI()
				end
				
			elseif (index == 3) then
				return function()
					-- size our main frames
					easyChat:SetSize("main")
					easyChat:SetSize("loot")
					
					-- position our main frames
					easyChat:SetPoint("main")
					easyChat:SetPoint("loot")
					
					-- dock all the rest, if any
					easyChat:DockFloaters()
				end

			elseif (index == 4) then
				return function()
					GUIS_DB["chat"].autoAlignMain = true
					GUIS_DB["chat"].autoAlignLoot = true
					module:PostUpdateGUI()
				end
			
			elseif (index == 5) then
				return function()
					GUIS_DB["chat"].autoAlignMain = true
					GUIS_DB["chat"].autoAlignLoot = true
					module:PostUpdateGUI()
				end
				
			elseif (index == 6) then
				return function()
					easyChat:SetColor()
				end
			end
		
			return noop
			
		elseif (option == "cancel") then
			return noop
			
		end
	end
end

module.UpdateAll = function(self)
	local icons = LibStub("gCore-3.0"):GetModule("GUIS-gUI: ChatIcons")
	if (icons) then
		icons:UpdateAll()
	end
	
	local abbreviations = LibStub("gCore-3.0"):GetModule("GUIS-gUI: ChatAbbreviations")
	if (abbreviations) then
		abbreviations:UpdateAll()
	end
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["chat"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["chat"] = GUIS_DB["chat"] or {}
	GUIS_DB["chat"] = ValidateTable(GUIS_DB["chat"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then
		self:Kill()
		return
	end
	
	------------------------------------------------------------------------------------------------------------
	-- 	Styling
	------------------------------------------------------------------------------------------------------------
	--
	-- style all the initial frames
	for _,name in ipairs(CHAT_FRAMES) do 
		SetUpChatFrame(_G[name])
	end

	-- style and position the toastframe
	BNToastFrame:SetUITemplate("simplebackdrop-indented")
	BNToastFrameCloseButton:SetUITemplate("closebutton")
	BNToastFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 16)
	end)

	--
	-- style any additional BNet frames when they are opened
	hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType, chatTarget, sourceChatFrame, selectWindow)
		local frame = FCF_GetCurrentChatFrame()
		
		SetUpChatFrame(frame)
	end)
	
	hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame, chatType, chatTarget)
		SetFrameFont(chatFrame)
	end)
	
	-- here we do our magic to remove the silly alphachange on mouseover, 
	-- yet allowing the user to change the alpha to his/hers preference! YAY!
	--
	-- 4 hours of headache to figure this one out. It better work! >:(
	--
	local SetAlpha = function(frame)
		if not(frame.oldAlpha) then return end

		for index, value in pairs(CHAT_FRAME_TEXTURES) do
		
			if not(value:find("Tab")) then
				local object = _G[frame:GetName() .. value]

				if (object:IsShown()) then
					UIFrameFadeRemoveFrame(object)

					object:SetAlpha(frame.oldAlpha)
				end
			end
		end
		
	end
	hooksecurefunc("FCF_FadeInChatFrame", function(frame) SetAlpha(frame) end)
	hooksecurefunc("FCF_FadeOutChatFrame", function(frame) SetAlpha(frame) end)
	hooksecurefunc("FCF_SetWindowAlpha", function(frame) SetAlpha(frame) end)
	
	-- set position and size of the "Main" and "Loot" windows
	local postUpdateSizeAndPos = function()
		for _,name in ipairs(CHAT_FRAMES) do 
			SetPosAndSize(_G[name])
		end
	end
	postUpdateSizeAndPos()
	
	RegisterCallback("PLAYER_ENTERING_WORLD", postUpdateSizeAndPos)
	RegisterCallback("PLAYER_ALIVE", postUpdateSizeAndPos)
	RegisterCallback("DISPLAY_SIZE_CHANGED", postUpdateSizeAndPos)
	RegisterCallback("UI_SCALE_CHANGED", postUpdateSizeAndPos)
	RegisterCallback("VARIABLES_LOADED", postUpdateSizeAndPos)

	------------------------------------------------------------------------------------------------------------
	-- 	Channels
	------------------------------------------------------------------------------------------------------------
	-- make pretty much everything sticky, so you can press ENTER to directly speak in Trade, Officer, etc etc
	for _,v in ipairs(stickyChannels) do 
		ChatTypeInfo[v].sticky = 1
	end

	------------------------------------------------------------------------------------------------------------
	-- 	Functionality
	------------------------------------------------------------------------------------------------------------
	--
	-- allow SHIFT + MouseWheel to scroll to the top or bottom
	hooksecurefunc("FloatingChatFrame_OnMouseScroll", function(self, delta)
		if (delta < 0) then
			if IsShiftKeyDown() then
				self:ScrollToBottom()
			end
		elseif (delta > 0) then
			if IsShiftKeyDown() then
				self:ScrollToTop()
			end
		end
	end)

	------------------------------------------------------------------------------------------------------------
	-- 	Sounds
	------------------------------------------------------------------------------------------------------------
	local playWhisperSound = function(self, event, ...)
		if (GUIS_DB["chat"].enableWhisperSound) then
			PlaySoundFile(M["Sound"]["Whisper"], "Master") -- PlaySound("TellMessage", "Master") 
		end
	end
	RegisterCallback("CHAT_MSG_WHISPER", playWhisperSound)
	RegisterCallback("CHAT_MSG_BN_WHISPER", playWhisperSound)
	
	
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

	------------------------------------------------------------------------------------------------------------
	-- 	Chat Commands
	------------------------------------------------------------------------------------------------------------
	CreateChatCommand(function() 
		ToggleFrame(ChatMenu) 
	end, "chatmenu")

	CreateChatCommand(function() 
		GUIS_DB["chat"].useTimeStamps = true; 
		module:PostUpdateGUI()
	end, { "showtimestamps" })

	CreateChatCommand(function() 
		GUIS_DB["chat"].useTimeStamps = false; 
		module:PostUpdateGUI()
	end, { "hidetimestamps" })

	CreateChatCommand(function() 
		GUIS_DB["chat"].removeBrackets = false; 
		module:UpdateAll()
		module:PostUpdateGUI()
	end, { "showbrackets", "showchatbrackets" })

	CreateChatCommand(function() 
		GUIS_DB["chat"].removeBrackets = true; 
		module:UpdateAll()
		module:PostUpdateGUI()
	end, { "hidebrackets", "hidechatbrackets" })

	CreateChatCommand(function()
		GUIS_DB["chat"].autoAlignLoot = true
		GUIS_DB["chat"].autoAlignMain = true
		module:PostUpdateGUI()
	end, "enablechatautoalign")

	CreateChatCommand(function()
		GUIS_DB["chat"].autoAlignLoot = false
		GUIS_DB["chat"].autoAlignMain = false
		module:PostUpdateGUI()
	end, "disablechatautoalign")

	CreateChatCommand(function()
		GUIS_DB["chat"].autoSizeLoot = true
		GUIS_DB["chat"].autoSizeMain = true
		module:PostUpdateGUI()
	end, "enablechatautosize")

	CreateChatCommand(function()
		GUIS_DB["chat"].autoSizeLoot = false
		GUIS_DB["chat"].autoSizeMain = false
		module:PostUpdateGUI()
	end, "disablechatautosize")
end

