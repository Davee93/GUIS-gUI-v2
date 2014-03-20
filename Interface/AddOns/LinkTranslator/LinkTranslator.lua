--####################################################################################
--####################################################################################
--Main class
--####################################################################################
--####################################################################################
--Dependencies: LinkParsing.lua

--LINKTRANSLATOR_GameVersion		= nil; --UIversion number of the game for quick lookup for other parts of the code for compatibility
	--if (LINKTRANSLATOR_GameVersion < 50300) then
		--Before patch 5.3.0

local LINKTRANSLATOR_addon_version = GetAddOnMetadata("LinkTranslator", "Version");	--Version number for the addon

--####################################################################################
--####################################################################################
--Event Handling and Cache
--####################################################################################

LinkTranslator			= {};	--Global declaration
LinkTranslator.__index	= LinkTranslator;

local LinkParsing	= LinkTranslator_LinkParsing;		--Local pointer


--OnLoad Event
function LinkTranslator:OnLoad(s)
	--We here only register for the events that we want to listen to, LinkTranslator:OnEvent() handles the various events
	s:RegisterEvent("PLAYER_ENTERING_WORLD");
	return nil;
end

--Handles the events for the addon
function LinkTranslator:OnEvent(s, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		--Startup
		--local ___version, ___internalVersion, ___thedate, ___uiVersion = GetBuildInfo();
		--LINKTRANSLATOR_GameVersion = ___uiVersion; --UI version number used for compatibility checks between game versions.

		--Show welcome message
		--print("LinkTranslator loaded ("..LINKTRANSLATOR_addon_version..").");

		--Register for chat channels (rest is done in LinkParsing)
		LinkParsing:RegisterMessageEventFilters(true);

		--After the first call to RegisterMessageEventFilters we dont need this anymore
		s:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
	return nil;
end


--Settings frame
function LinkTranslator:SettingsFrame_OnLoad(panel, title)
	title:SetText("LinkTranslator "..LINKTRANSLATOR_addon_version.." "); --<FontString> containing the title & version number

	-- Set the name of the Panel
	panel.name = "LinkTranslator";
	panel.default	= function (self) print("There are no settings for LinkTranslator"); end;

	--Add the panel to the Interface Options
	InterfaceOptions_AddCategory(panel);
end

--Settings frame
function LinkTranslator:SettingsFrame_Show(panel, lineA,lineB,lineC,lineD)
	local val1,val2,val3,val4 = LinkParsing:getStatistics();
	local c, r = "|cFF00FF40", "|r.";
	local tostring = tostring; --local fpointer

	--<Fonstrings> with space for statistics.
	lineA:SetText("Time running: "..c..tostring(val4)..r);
	lineB:SetText("Number of chatlines: "..c..tostring(val3)..r);
	lineC:SetText("Number of links in chat: "..c..tostring(val1)..r);
	lineD:SetText("Number of links replaced: "..c..tostring(val2)..r);
end

--####################################################################################
--####################################################################################