--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local MAJOR, MINOR = "gMedia-3.0", 15
local M, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not M then return end 

-- Lua API
local type = type

local locale = GetLocale()

--[[
	gMedia is a work in progress, and will be developed further
]]--

------------------------------------------------------------------------------------------------------------
-- 	API
------------------------------------------------------------------------------------------------------------
--
-- function returns 'true' if media is succesfully registered, nil otherwise
-- 'mediaType' refers to an internal category like "Background", "Button", "Font" or "Border"
-- 'key' is the name of your media, which can be anything you like as long as it's unique for its mediaType.
-- 	it is recommended to use long and descriptive names for your media, to avoid naming conflicts.
-- 'data' is the full path and filename of the media 
function M:Register(mediaType, key, data)
	if type(mediaType) ~= "string" then
		geterrorhandler()((MAJOR .. ": Register(mediaType, key, data) 'mediaType' - string expected, got %s"):format(type(mediaType)), 2)
		return 
	end
	
	if type(key) ~= "string" then
		geterrorhandler()((MAJOR .. ": Register(mediaType, key, data) 'key' - string expected, got %s"):format(type(key)), 2)
		return 
	end
	
	if type(data) ~= "string" and type(data) ~= "table" then
		geterrorhandler()((MAJOR .. ": Register(mediaType, key, data) 'data' - string or table expected, got %s"):format(type(data)), 2)
		return 
	end

	if not self[mediaType] then
		self[mediaType] = {}
	end
	
	if self[mediaType][key] then return end
	
	self[mediaType][key] = data
	return true
end

------------------------------------------------------------------------------------------------------------
-- 	Default Media (All Blizzard)
------------------------------------------------------------------------------------------------------------
M:Register("Background", 	"Blank", 								[[Interface\ChatFrame\ChatFrameBackground]])
M:Register("Background", 	"Blizzard Tooltip", 					[[Interface\Tooltips\UI-Tooltip-Background]])
M:Register("Background", 	"Blizzard Dialog", 					[[Interface\DialogFrame\UI-DialogBox-Background]])
M:Register("Background", 	"Blizzard Event Notification",	[[Interface\Calendar\EventNotification]])

M:Register("Border", 		"Blizzard Dialog", 					[[Interface\DialogFrame\UI-DialogBox-Border]])
M:Register("Border", 		"Blizzard Dialog Gold", 			[[Interface\DialogFrame\UI-DialogBox-Gold-Border]])
M:Register("Border", 		"Blizzard Tooltip", 					[[Interface\Tooltips\UI-Tooltip-Border]])

M:Register("Button", 		"Glow", 									[[Interface\Buttons\UI-ActionButton-Border]])
M:Register("Button", 		"Pass", 									[[Interface\Buttons\UI-GroupLoot-Pass-Up]])
M:Register("Button", 		"PassDown", 							[[Interface\Buttons\UI-GroupLoot-Pass-Down]])
M:Register("Button", 		"PassHighlight", 						[[Interface\Buttons\UI-GroupLoot-Pass-Highlight]])

M:Register("StatusBar", 	"Blizzard", 							[[Interface\TargetingFrame\UI-StatusBar]])
M:Register("StatusBar", 	"Spark", 								[[Interface\CastingBar\UI-CastingBar-Spark]])

M:Register("Icon", 			"WorldState Alliance", 				[["Interface\WorldStateScore\AllianceIcon"]])
M:Register("Icon", 			"WorldState Horde", 					[["Interface\WorldStateScore\HordeIcon"]])

M:Register("IconString", 	"HeroicSkull", 						[[|TInterface\LFGFrame\UI-LFG-ICON-HEROIC:0:0:0:0|t]])
M:Register("IconString", 	"Role-DPS", 							[[|TInterface\LFGFrame\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:22:41|t]])
M:Register("IconString", 	"Role-Heal", 							[[|TInterface\LFGFrame\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:22:41|t]])
M:Register("IconString", 	"Role-Tank", 							[[|TInterface\LFGFrame\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:0:19:22:41|t]])

--
-- What fonts are set as Text, Number and Damage is based on
-- the localized versions of Blizzards Fonts.xml
--
if locale == "koKR" then
	M:Register("Font", "굵은 글꼴", 					[[Fonts\2002B.TTF]])
	M:Register("Font", "기본 글꼴", 					[[Fonts\2002.TTF]])
	M:Register("Font", "데미지 글꼴", 					[[Fonts\K_Damage.TTF]])
	M:Register("Font", "퀘스트 글꼴", 					[[Fonts\K_Pagetext.TTF]])
	
	M:Register("Font", "Text", 					M["Font"]["기본 글꼴"])
	M:Register("Font", "Number", 					M["Font"]["기본 글꼴"])
	M:Register("Font", "Damage", 					M["Font"]["데미지 글꼴"])

elseif locale == "zhCN" then
	M:Register("Font", "伤害数字", 					[[Fonts\ZYKai_C.ttf]])
	M:Register("Font", "默认", 						[[Fonts\ZYKai_T.ttf]])
	M:Register("Font", "聊天", 						[[Fonts\ZYHei.ttf]])

	M:Register("Font", "Text", 					M["Font"]["默认"])
	M:Register("Font", "Number", 					M["Font"]["聊天"])
	M:Register("Font", "Damage", 					M["Font"]["伤害数字"])

elseif locale == "zhTW" then
	M:Register("Font", "提示訊息", 					[[Fonts\bHEI00M.ttf]])
	M:Register("Font", "聊天", 						[[Fonts\bHEI01B.ttf]])
	M:Register("Font", "傷害數字", 					[[Fonts\bKAI00M.ttf]])
	M:Register("Font", "預設", 						[[Fonts\bLEI00D.ttf]])

	M:Register("Font", "Text", 					M["Font"]["預設"])
	M:Register("Font", "Number", 					M["Font"]["聊天"])
	M:Register("Font", "Damage", 					M["Font"]["傷害數字"])
	
elseif locale == "ruRU" then
	M:Register("Font", "Arial Narrow", 			[[Fonts\ARIALN.TTF]])
	M:Register("Font", "Friz Quadrata", 			[[Fonts\FRIZQT__.TTF]])
	M:Register("Font", "Morpheus", 				[[Fonts\MORPHEUS.TTF]])
	M:Register("Font", "Nimrod MT", 				[[Fonts\NIM_____.ttf]])
	M:Register("Font", "Skurri", 					[[Fonts\SKURRI.TTF]])

	M:Register("Font", "Text", 					M["Font"]["Friz Quadrata"])
	M:Register("Font", "Number", 					M["Font"]["Arial Narrow"])
	M:Register("Font", "Damage", 					M["Font"]["Friz Quadrata"])

else
	M:Register("Font", "Arial Narrow", 			[[Fonts\ARIALN.TTF]])
	M:Register("Font", "Friz Quadrata", 		[[Fonts\FRIZQT__.TTF]])
	M:Register("Font", "Morpheus", 				[[Fonts\MORPHEUS.TTF]])
	M:Register("Font", "Skurri", 					[[Fonts\SKURRI.TTF]])
	
	M:Register("Font", "Text", 					M["Font"]["Friz Quadrata"])
	M:Register("Font", "Number", 					M["Font"]["Arial Narrow"])
	M:Register("Font", "Damage", 					M["Font"]["Friz Quadrata"])

end

M:Register("Backdrop", "Blank", {
	bgFile = M["Background"]["Blank"];
	insets = { 
		bottom = 0; 
		left = 0; 
		right = 0; 
		top = 0; 
	};
})

M:Register("Backdrop", "Blank-Inset", {
	bgFile = M["Background"]["Blank"];
	edgeFile = M["Background"]["Blank"];
	edgeSize = 1;
	insets = { 
		bottom = -1; 
		left = -1; 
		right = -1; 
		top = -1; 
	};
})

M:Register("Backdrop", "Border", {
	edgeFile = M["Background"]["Blank"];
	edgeSize = 1;
	insets = {
		left = 1;
		right = 1;
		top = 1;
		bottom = 1;
	};
})

M:Register("Backdrop", "Blank-Border", {
	bgFile = M["Background"]["Blank"];
	edgeFile = M["Background"]["Blank"];
	edgeSize = 1;
	insets = {
		left = 1;
		right = 1;
		top = 1;
		bottom = 1;
	};
})
