--####################################################################################
--####################################################################################
--Link Parsing
--####################################################################################
--Dependencies: HiddenTooltip.lua

local LinkParsing	= {};
LinkParsing.__index	= LinkParsing;
LinkTranslator_LinkParsing	= LinkParsing; --Global declaration

local HiddenTooltip = LinkTranslator_HiddenTooltip; --Local pointer


--Local variables that cache stuff so we dont have to recreate large objects
local cache_IsRegistered	= false;--Boolean
local cache_EventFunction	= nil;	--Nil or pointer to the eventhandler
local cache_Link			= {};	--Table where the key is the untranslated link and value is the translated link.
local cache_LinkCount		= 0;	--Size of cache_Link table. The table will grow during the playsession. If it ever reaches CONST_LINKMAX we simply reset the table to empty.
local cache_PlayerName		= "";	--Name of the player. We skip checking our own links
local cache_prevMessage		= "";	--Orignal message that was last passed to MessageEventFilter()
local cache_prevMessageNew	= "";	--Modified message that was last passed to MessageEventFilter()

local cache_NumLinks	= 0;		--Number of links in cache (will not reset when cache goes over CONST_LINKMAX)
local cache_NumReplace	= 0;		--Number of link replacements done
local cache_NumChat		= 0;		--Number of uniqe chatlines encountered
local cache_NumTime		= time();	--Timestamp when addon was loaded


--Local Constants
local CONST_LINKMAX			= 500; --Max number of entries allowed in cache_Link. This is to prevent scenarios with very long playsessions that accumulate huge number of itemlinks that might affect memory too much.
local CONST_CHATEVENTS		= {"CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER"};
							--Table with all chat events we subscribe to. We dont subscribe to Battle.net channels: CHAT_MSG_BN_WHISPER, CHAT_MSG_BN_CONVERSATION, CHAT_MSG_BN_INLINE_TOAST_BROADCAST

--Local pointers to global functions
local pairs		= pairs;
local strfind	= strfind;
local strmatch	= strmatch;
local strsub	= strsub;
local strlen	= strlen;
local strtrim	= strtrim;
local strlower	= strlower;
local tostring	= tostring;

--local GetItemInfo	= GetItemInfo;
--local GetSpellLink= GetSpellLink;

--####################################################################################
--####################################################################################
--Public
--####################################################################################


--Return some basic statistic for the addon
function LinkParsing:getStatistics()
	local floor		= floor; --local fpointer
	local tostring	= tostring;

	local total		= difftime(time(), cache_NumTime); --Diff between now() and when addon was loaded in seconds
	local hour		= floor(total / 3600);
	local minute	= floor( (total - (3600*hour)) / 60);
	local second	= total - (3600*hour) - (60*minute);
	local strTime	= 								tostring(hour).." hour(s), "..tostring(minute).." minute(s), "..tostring(second).." seconds";
	if (hour < 1)					then strTime =	tostring(minute).." minute(s), "..tostring(second).." seconds"; end
	if (hour < 1 and minute < 1)	then strTime =	tostring(second).." seconds"; end

	--Number of links in cache, Number of replacements, Number of chatlines scanned, Total time since addon started
	return cache_NumLinks, cache_NumReplace, cache_NumChat, strTime;
end


--Register or unregister to chat channels
function LinkParsing:RegisterMessageEventFilters(register)
	if (register ~= true) then register = false; end --Boolean
	if (register == cache_IsRegistered) then return register; end --Don't do anything if its already done

	--Created a permanent pointer to the eventhandler function. We need this to register/unregister from chat events
	if (cache_EventFunction == nil) then
		cache_EventFunction = function(objSelf, channel, message, author, ...) return self:MessageEventFilter(objSelf, channel, message, author, ...) end;
	end--if

	local reg = ChatFrame_AddMessageEventFilter; --local fpointer
	if (register ~= true) then reg = ChatFrame_RemoveMessageEventFilter; end

	--Hook cache_EventFunction to all the different chat events listed in CONST_CHATEVENTS
	for key, eventName in pairs(CONST_CHATEVENTS) do
		reg(eventName, cache_EventFunction);
	end--for

	--Cache the player's name
	cache_PlayerName = GetUnitName("player", false);

	cache_IsRegistered = register;
	return register;
end


--Event handler for ChatFrame_AddMessageEventFilter()
function LinkParsing:MessageEventFilter(objSelf, channel, message, author, ...)
	--Return TRUE to stop the message from propagating. Return FALSE + all arguments to keep propagating it

	--Source: http://www.wowwiki.com/API_ChatFrame_AddMessageEventFilter
	--Note that your function will be called once for every frame the message-event is registered for. It's possible to get two calls for whisper, say, and yell messages, and seven for channel messages. Due to this non-deterministic calling, your filter function should not have side-effects.
	if (cache_prevMessage == message) then return false, cache_prevMessageNew, author, ...; end

	--Keep for faster return later
	cache_prevMessage	 = message;				--Original message
	cache_prevMessageNew = cache_prevMessage;	--(Possibly) modified message

	if (author ~= cache_PlayerName) then --Ignore links that the player send himself
		--print("    ANOTHER AUTHOR '"..tostring(author).."' '"..tostring(channel).."'");
		local arrLinks = self:getLinks(message); --Check to see if there are any links in the string and return them
		if (arrLinks ~= nil) then
			--print("    FOUND LINKS");
			arrLinks = self:lookupLinks(arrLinks); --Lookup the localized title for the links (from cache or tooltipscanning)
			if (arrLinks ~= nil) then
				--print("    ORIGINAL: '"..tostring(message).."'");
				message	= self:replaceLinks(message, arrLinks); --Replace the oldlinks in the string with newlinks
				cache_prevMessageNew = message;
				--print("    REPLACED: '"..tostring(message).."'");
			else
				--print("    NOTHING TO REPLACE");
			end--if
		end--if
	else
		--print("    MYSELF AUTHOR");
	end--if author

	cache_NumChat = cache_NumChat +1; --Statistics
	return false, message, author, ...;
end


--####################################################################################
--####################################################################################
--Support functions
--####################################################################################


--Replace all old links with the new links
function LinkParsing:replaceLinks(message, arrLinks)
	local pairs	= pairs; --local fpointer
	local gsub	= gsub;
	for old, new in pairs(arrLinks) do
		old = self:escapeMagicalCharacters(old); --escape any magical characters so that they are seen as literal strings
		message = gsub(message, old, new);
		cache_NumReplace = cache_NumReplace +1; --Statistics
	end--for
	return message;
end


--Loop though links and retreive itemlinks from cache or tooltipscanning
function LinkParsing:lookupLinks(arrLinks)
	local pairs  = pairs; --local fpointer
	local arrRes = nil; --array of finished translated links (key == old link, value == new link). it will only return links that are different between key/value so it wont waste replacing identical links
	local arrNew = nil; --array of links that we need to lookup (key = old link, value == table with linkdata=

	--Check against cache for any previously parsed links.
	for key, tblData in pairs(arrLinks) do
		local c = cache_Link[key];
		if (c ~= nil) then
			--We have looked up this one before
			if (c == key) then
				--Link does not need to be translated; its already in the same language as returned by the local client
				--print("    no need to translate '"..tostring(c).."'");
			else
				--Link is not in the same language; its already been parsed so we just use the cached data
				if (arrRes == nil) then arrRes = {}; end
				arrRes[key] = c;
				--print("    already translated '"..tostring(c).."' ==> '"..tostring(key).."'");
			end--if c
		else
			--We dont have this link in cache. We must look it up
			if (arrNew == nil) then arrNew = {}; end
			arrNew[key] = tblData;
			--print("    not cached '"..tostring(key).."'");
		end--if c
	end--for key, tblData

	--If we dont need to parse any new links then just return whatever was found in the cache (or it might even be nil)
	if (arrNew == nil) then return arrRes; end

	--Traverse and try to lookup these new and uncached links
	for key, tblData in pairs(arrNew) do
		--Lookup the uncached link and get the old & new link returned, if the lookup fails it returns nil
		local tblOldLink, tblNewLink = self:parseLink(key, tblData);
		if (tblOldLink ~= nil) then
			if (tblOldLink ~= tblNewLink) then --Skip returning it if the old & new links are identical
				if (arrRes == nil) then arrRes = {}; end
				arrRes[tblOldLink] = tblNewLink;
			end--if
			--If the old & new link happens to be identical then we will store them in the cache too for faster lookup later

			cache_Link[tblOldLink] = tblNewLink;	--Store in cache for later reuse
			cache_LinkCount = cache_LinkCount +1;	--Increment counter to keep track of size
			cache_NumLinks  = cache_NumLinks +1;	--Statistics
			if (cache_LinkCount > CONST_LINKMAX) then cache_Link = {}; cache_LinkCount = 0; end --If we go over the limit we simply reset the whole cache
			--print("    added to cache '"..tostring(tblOldLink).."' ==> '"..tostring(tblNewLink).."'");
		end--if tblOldLink
	end--for key, tblData

	return arrRes;
end


--Retreive the localized title of an itemlink
function LinkParsing:parseLink(key, tblData)
	--Input:	Table: TYPE:string, TEXT:string, LINK:string
	--Returns:	oldLink, newLink OR nil if it was not able to lookup the link

	local strType	= strtrim(strlower(tblData["TYPE"]));
	--local strID	= tblData["ID"]; --ID is only available for 'trade' and 'battlepet' types
	local strTEXT	= tblData["TEXT"];
	local strLink	= key; --tblData["LINK"];
	local strLOCAL	= nil; --tblData["LOCALTEXT"];

	if strType == "player" then
		strLOCAL = strTEXT; --Playerlinks are not translated, simply return it
	elseif strType == "global" and "trade" then
		--Tradelinks: Cooking, Alchemy etc
		--local link = GetSpellLink(tblData["ID"]); --the ID is actually a spellid number. We can look that up and get a generic spelllink
		local booResult, link = pcall(GetSpellLink, tblData["ID"]); --the ID is actually a spellid number. We can look that up and get a generic spelllink
		if (booResult == false) then link = nil; end --if the call crashes we ignore the link.
		if (link ~= nil) then
			local tmp = self:getLinks(link); --pull out just the text from the itemlink
			if (tmp~=nil) then --always just a table with 1 subentry
				for _key, _tblData in pairs(tmp) do strLOCAL = _tblData["TEXT"]; end
			end--if tmp
		end--if link
	elseif strType == "battlepet" then
		--Tooltipscanning crashes when attempting to scan battlepet links. We need to ask the PetJournal and match on the Species number (SpeciesID == you can have 3 pets of a species like 'Albino snake')
		strLOCAL = C_PetJournal.GetPetInfoBySpeciesID(tblData["ID"]);
	--[[
	elseif strType == "item" then
		local name, link, quality = GetItemInfo(strID); --is it an item? (if item isnt in cache then it will return nil)
		if (name == nil) then name = HiddenTooltip:GetEquipmentItemInfo(strLink, "TITLE"); end
		if (name == nil) then name, link, quality = GetItemInfo(strTEXT); end
		if (name ~= nil) then strLOCAL = name; end
	elseif strType == "spell" then
		local link = GetSpellLink(strID); --is it an item? (if item isnt in cache then it will return nil)
		if (name == nil) then name = HiddenTooltip:GetEquipmentItemInfo(strLink, "TITLE"); end
		if (link == nil) then link = GetSpellLink(strTEXT); end
		if (link ~= nil) then
			local tmp = self:getLinks(link); --pull out just the text from the itemlink
			if (tmp~=nil) then --always just a table with 1 subentry
				for key, tblData in pairs(tmp) do strLOCAL = tblData["TEXT"]; end
			end
		end--if
	]]--
	else
		--strType can also be: item, spell, quest, talent, glyph, trade, currency, instance, achievement, enchant
		strLOCAL = HiddenTooltip:GetEquipmentItemInfo(strLink, "TITLE");
	end

	--print("parseLinks: '"..tostring(strTEXT).."' ==> '"..tostring(strLOCAL).."'");
	if (strLOCAL == nil or strLOCAL == "") then return nil; end --Was not able to lookup link (maybe because of slow gameclient/ui or a bad link)
	if (strLOCAL == strTEXT) then return strLink, strLink; end --The text is identical

	strTEXT = self:escapeMagicalCharacters(strTEXT); --escape any magical characters so that they are seen as literal strings
	local strLinkNew = gsub(strLink, strTEXT, strLOCAL); --We replace the text inside the old link to create the new link, this way we preserve the linkdata etc
	return strLink, strLinkNew;
end


--Traverse string and return table with unique links or nil
function LinkParsing:getLinks(message)
	--Will return nil or a table with subtable(s) with itemlink data in them.
	local strfind	= strfind; --local fpointer

	--local p = "|H(.-):(%d+).*%|h[(.+)%]"; --Original from phanx
	local p = "|H(.-):(%d+).-%|h%[(.-)%]%|h"; --Narrowed down so that it will find the nearest end of the link in the string (|h)

	local startPos, endPos, firstWord, restOfString = strfind(message, p);
	if (startPos == nil) then return nil; end

	local strmatch	= strmatch; --local fpointer
	local strsub	= strsub;
	local tostring	= tostring;

	local res = {}; --Result table
	while (startPos ~= nil) do
		local linkType, linkID, linkText = strmatch(message, p, startPos);
		local strLink					 = tostring(strsub(message, startPos,endPos)); --extract the whole link as-is (used with tooltipscanning)
		--print("    startPos: "..tostring(startPos).. " endPos:"..tostring(endPos).." firstWord: '"..tostring(firstWord).."' restOfString: '"..tostring(restOfString).."'");
		--print("    type: "..tostring(linkType).. " id:"..tostring(linkID).." text: '"..tostring(linkText).."' Link: '"..tostring(strLink).."'\n");

		--Store for later translation
		local tmp = { ["TYPE"]=tostring(linkType), ["TEXT"]=tostring(linkText) }; --["ID"]=linkID, ["LINK"]=strLink
		if (linkType == "trade" or linkType == "battlepet") then tmp["ID"] = linkID; end --Special cases: we only need the spellID for tradelinks and battlepets
		res[strLink] = tmp; --If the same link is being repeated in the message, then as a bonus of using it as the key we wont store it more than once in the result

		startPos, endPos, firstWord, restOfString = strfind(message, p, endPos); --resume from the end of this link
	end--while

	return res;
end


--This is copied from StringParsing.lua
	--Local variables that cache stuff so we dont have to recreate large objects
	local CONST_escapeMagicalCharacters	= {"(",")",".","%","+","-","*","?","[","]","^","$"}; --Hardcoded, these are the magical characters that have special meaning when it comes to LUA patterns, by adding % infront of them we escape them
	local CONST_escapeMagicalPattern	= "[%(%)%.%%%+%-%*%?%[%]%^%$]+"; --Pattern used to determine if a magical char is in the string

	--Replaces any occurences of ( ) . % + - * ? [ ] ^ $ by adding a % ahead of it
	function LinkParsing:escapeMagicalCharacters(str)
		local start = strfind(str, CONST_escapeMagicalPattern, 1); --We look for any of the magical characters, if none are in there then skip the loop
		if (start == nil) then
			return str;
		else
			local _strsub = strsub; --local fpointer
			local res = "";
			local esc = CONST_escapeMagicalCharacters;
			for i = 1, strlen(str) do
				local char = _strsub(str,i,i);
				for j = 1, #esc do
					if (char == esc[j]) then
						char = "%"..char;
						break;
					end--if
				end--for j
				res = res..char;
			end--for i
			return res;
		end
	end


--####################################################################################
--####################################################################################