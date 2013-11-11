local addon, ns = ...
local L = LibStub("gLocale-1.0"):GetLocale(addon)

local title = GetAddOnMetadata(addon, "Title")
local version = GetAddOnMetadata(addon, "Version")
local curseversion = GetAddOnMetadata(addon, "X-Curse-Packaged-Version")

--------------------------------------------------------------------------------------------------
--		GUIS: gUI General
--------------------------------------------------------------------------------------------------
_G["BINDING_HEADER_GUISKEYBINDSMAIN"] = title .. " " .. (curseversion or version) or ""
_G["BINDING_NAME_GUISTOGGLECALENDAR"] = L["Toggle Calendar"]
_G["BINDING_NAME_GUISTOGGLECUSTOMERSUPPORT"] = HELP_BUTTON

--------------------------------------------------------------------------------------------------
--		ActionBars Module 
--------------------------------------------------------------------------------------------------
_G["BINDING_NAME_GUISEXITVEHICLE"] = BINDING_NAME_VEHICLEEXIT

--------------------------------------------------------------------------------------------------
--		Chat Module 
--------------------------------------------------------------------------------------------------
_G["BINDING_NAME_GUISTELLTARGET"] = L["Whisper target"]
_G["BINDING_NAME_GUISTELLFOCUS"] = L["Whisper focus"]

--------------------------------------------------------------------------------------------------
--		Blizzard Replacements 
--------------------------------------------------------------------------------------------------
_G["BINDING_NAME_GUISSHOWTALENTS"] = L["Show Talent Pane"]

