-- Localization
local L = setmetatable( 
{
	MAIN = "Main",
	ALTS = "Alts",
}, 
{
	__index = function ( self, Key )
		if ( Key ~= nil ) then
			rawset( self, Key, Key );
			return Key;
		end
	end;
} );
--[[ -- example for German
if ( GetLocale() == "deDE" ) then
	L = setmetatable( 
	{
		MAIN = "Main",
		ALTS = "Alts",
	}, 
	{ __index = L; } );
end
]]

local addonName, addonTable = ...

-- Event frame
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("GUILD_ROSTER_UPDATE")
f:SetScript("OnEvent", 
function(self,event,...) 
	if self[event] then
		return self[event](...)
	end
end)
local tex=f:CreateTexture()
local textlen=f:CreateFontString(nil,nil,"GameTooltipText")

-- addon local variables or caches
local LibAlts
local guildStatus = {}
local guildTooltip = {}
local fmtstatus = "\124T%s.tga:16:16:0:0\124t"
local ONLINE = string.format(fmtstatus,FRIENDS_TEXTURE_ONLINE)
local AFK = string.format(fmtstatus,FRIENDS_TEXTURE_AFK)
local DND = string.format(fmtstatus,FRIENDS_TEXTURE_DND)
local REMOTE
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS
local fmtclassico = "\124TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes.blp:0:0:0:0:%d:%d:%d:%d:%d:%d\124t"
local INLINE_CLASS_ICON
local LIST_DELIM = ";"
local LIST_CONCAT = ", "
local GetGuildRosterInfo = GetGuildRosterInfo
local strjoin = string.join
local strsplit = string.split
local strformat = string.format
local gsub = string.gsub
local tostring = tostring

-- utility functions
local function initializeClassIcons()
	tex:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
	local texw, texh = tex:GetSize(true)
	if texw and (texw > 0) then
		INLINE_CLASS_ICON = {}
		for i,c in ipairs(CLASS_SORT_ORDER) do
			local x1,x2,y1,y2 = unpack(CLASS_ICON_TCOORDS[c])
		 	x1,x2,y1,y2 = (x1*texw), (x2*texw), (y1*texh), (y2*texh)
			INLINE_CLASS_ICON[c] = string.format(fmtclassico,texw,texh,x1,x2,y1,y2)
		end
	end
end

local function updateRoster(...)
	for i=1,GetNumGuildMembers(true) do
		local name, rank, _, level, _, zone, note, ofnote, online, isAway, eclass, _, _, isMobile = GetGuildRosterInfo(i);
--  local name, rank, rankIndex, level, class, zone, note, officernote, online, isAway, classFileName, achievementPoints, achievementRank, isMobile, canSoR = GetGuildRosterInfo(index);    -- 4.3.2 isAway ? 0 = active, 1 = away, 2 = busy
		local lastonline
		if name then
			if (isAway == 0) then
				guildStatus[name] = ONLINE
			elseif (isAway == 1) then
				guildStatus[name] = AFK
			elseif (isAway == 2) then
				guildStatus[name] = DND
			end
			if isMobile and ChatFrame_GetMobileEmbeddedTexture then
				if not REMOTE then REMOTE = ChatFrame_GetMobileEmbeddedTexture(0.4, 0.6, 0.4) end
				guildStatus[name] = REMOTE
				zone = REMOTE_CHAT
			end
			if online then
				lastonline = GUILD_ONLINE_LABEL
			else
				lastonline = f.guildroster and GuildRoster_GetLastOnline(i) or ""
			end
			rank = rank and (gsub(rank,LIST_DELIM,""))
			level = level and (gsub(tostring(level),LIST_DELIM,""))
			lastonline = lastonline and (gsub(lastonline,LIST_DELIM,""))
			zone = zone and (gsub(zone,LIST_DELIM,""))
			note = note and (gsub(note,LIST_DELIM,""))
			ofnote = ofnote and (gsub(ofnote,LIST_DELIM,""))
			guildTooltip[name] = strjoin(LIST_DELIM,(rank or ""),(level or ""),(lastonline or ""),(zone or ""),eclass,name,(note or ""),(ofnote or ""))
		end
	end
end

local maxWidth = 180
local stringtable = {}
local function wrapStrings(...)
	wipe(stringtable)
	local numAlts = select("#",...)
	local temp
	if numAlts > 1 then
		local i, k = 1, 1
		while i <= numAlts do
			if i < numAlts then
				if stringtable[k] then
					stringtable[k] = stringtable[k]..LIST_CONCAT..select(i,...)
				else
					stringtable[k] = select(i,...) -- first iteration
				end
				temp = stringtable[k]..LIST_CONCAT..select(i+1,...)
				textlen:SetText(temp)
				length = textlen:GetStringWidth()
				if length <= maxWidth then
					stringtable[k]=temp
					i = i+2
				else
					k = k+1
					i = i+1
				end
			else -- last item
				if stringtable[k] then
					temp = stringtable[k]..LIST_CONCAT..select(i,...)
					textlen:SetText(temp)
					length = textlen:GetStringWidth()
					if length <= maxWidth then
						stringtable[k]=temp
					else
						stringtable[k+1]=select(i,...)
					end
				else
					stringtable[k]=select(i,...)
				end
				i = i+1
			end
		end
	elseif numAlts == 1 then
		stringtable[1]=...
	end
	return stringtable
end

local alts = {}
local function updateTooltip(button,...)
	if button.tooltip then
		local rank,level,lastonline,zone,class,name,note,ofnote = strsplit(LIST_DELIM,button.tooltip)
		local classColor = RAID_CLASS_COLORS[class]

		GameTooltip:SetOwner(button,"ANCHOR_RIGHT")
		if not INLINE_CLASS_ICON then
			initializeClassIcons()
			GameTooltip:SetText(name,classColor.r,classColor.g,classColor.b)
		else
			GameTooltip:SetText(INLINE_CLASS_ICON[class]..name,classColor.r,classColor.g,classColor.b)
		end
		GameTooltip:AddLine(" "); 
		if rank and rank ~= "" then
			GameTooltip:AddDoubleLine(RANK,rank,
				NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
		if level and level ~= "" then
			GameTooltip:AddDoubleLine(LEVEL,level,
				NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
		if lastonline and lastonline ~= "" then
			GameTooltip:AddDoubleLine(LASTONLINE,lastonline,
				NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
		if zone and zone ~= "" then
			GameTooltip:AddDoubleLine(ZONE,zone,
				NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
		local notes
		if note and note ~= "" then
			notes = true
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(PUBLIC_NOTE,note,
				NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
		if ofnote and ofnote ~= "" then
			if not notes then GameTooltip:AddLine(" ") end
			GameTooltip:AddDoubleLine(OFFICER_NOTE_COLON,ofnote,
				NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
		local mains_alts
		if f.useLibAlts then
			local main -- , alts
			if LibAlts:IsMain(name) then
				wipe(alts)
				alts = wrapStrings(LibAlts:GetAlts(name))
				if next(alts) then
					mains_alts = true
					GameTooltip:AddLine(" ")
					for i,line in ipairs(alts) do
						if i==1 then
							GameTooltip:AddDoubleLine(L.ALTS,line,
								NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
								HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
						else
							GameTooltip:AddDoubleLine(" ",line,
								NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
								HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
						end
					end
				end
			elseif LibAlts:IsAlt(name) then
				main = LibAlts:GetMain(name) or ""
				if main ~= "" then
					if not mains_alts then GameTooltip:AddLine(" ") end
					GameTooltip:AddDoubleLine(L.MAIN,main,
						NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,
						HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
				end
			end
		end
		GameTooltip:Show()
	end
end

local function updateName(fontstring, name, isOnline, class)
	if (not class) then return end
	if guildStatus[name] and isOnline then
		local classColor = RAID_CLASS_COLORS[class]
		fontstring:SetText(guildStatus[name]..name)
		fontstring:SetTextColor(classColor.r, classColor.g, classColor.b)
	end
	local button = fontstring:GetParent()
	if button then
		if not button.hooked then
 			button:HookScript("OnEnter", updateTooltip)
			button.hooked = true
		end
		if guildTooltip[name] then
			button.tooltip = guildTooltip[name]
		end
	end
end

-- script handlers
function f.ADDON_LOADED(...)
	local addon = ...
 	if addon == "Blizzard_GuildUI" then
		hooksecurefunc("GuildRosterButton_SetStringText", updateName)
		LibAlts = LibStub:GetLibrary("LibAlts-1.0",true) -- silently fail if it doesn't exist
		if LibAlts and LibAlts.IsMain and LibAlts.IsAlt and LibAlts.GetMain and LibAlts.GetAlts then
      f.useLibAlts = true
    end
    initializeClassIcons()
    f.guildroster = true
		f:UnregisterEvent("ADDON_LOADED")
	end
end

function f.GUILD_ROSTER_UPDATE()
	updateRoster()
end