--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local MAJOR, MINOR = "gLocale-1.0", 15
local gLocale, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not(gLocale) then return end 

-- Lua APIs
local setmetatable = setmetatable

gLocale.L = gLocale.L or {} 
gLocale.defaults = gLocale.defaults or {}

local readmeta, writemeta, writedefaultmeta
local defaultLocale, currentLocale, clientLocale
local assertfalse

-- GAME_LOCALE = "abZX" -- bogus locale to see if it breaks, which it does

-- for development purposes
local clientLocale = GAME_LOCALE or GetLocale()

-- too similar for us to separate
if (clientLocale == "enGB") then
	clientLocale = "enUS"
end

if (clientLocale == "ptPT") then
	clientLocale = "ptBR"
end

if (clientLocale == "esMX") then
	clientLocale = "esES"
end

assertfalse = function() assert(false, MAJOR .. ": Can't retrieve existing keys with locales retrieved with :NewLocale(), use :GetLocale() instead") end

readmeta = setmetatable({}, {
	-- accept new entries with this?
	-- they won't be inserted into the correct locale, just the current one,
	-- so addons need to make sure what they insert is in the current GetLocale() themselves!!
	__newindex = function(self, key, value)
		rawset(self, key, value == true and key or value) 
	end;
	
	-- fire a non-breaking error if an unknown index is requested
	__index = function(self, key)
		rawset(self, key, key)
		geterrorhandler()(MAJOR .. ": No entry exists for '" .. tostring(key) .. "'")

		return key
	end;
})

writemeta = setmetatable({}, {
	__newindex = function(self, key, value)
		rawset(currentLocale, key, value == true and key or value) 
	end;
	__index = assertfalse;
})

--
-- write proxy for locales created with :NewLocale
-- does not allow the user to overwrite existing entries
-- if you specify the same string twice, the second value will be ignored
writedefaultmeta = setmetatable({}, {
	__newindex = function(self, key, value)
		if not(rawget(currentLocale, key)) then
			rawset(currentLocale, key, value == true and key or value)
		end
	end;
	__index = assertfalse;
})

--
-- @param addon <string> can be anything, as long as its name is unique with this handler
-- @param locale <string> is the name of the locale, typically "enUS", "esMX", etc
-- @return <table> pointer to the new locale
function gLocale:NewLocale(addon, locale, default)
	if type(addon) ~= "string" then
		geterrorhandler()((MAJOR .. ": NewLocale(addon, locale) 'addon' - string expected, got %s"):format(type(addon)), 2)
		return 
	end

	if type(locale) ~= "string" then
		geterrorhandler()((MAJOR .. ": NewLocale(addon, locale) 'locale' - string expected, got %s"):format(type(locale)), 2)
		return 
	end

	self.L[addon] = self.L[addon] or {}

	if (self.L[addon][locale]) then
		geterrorhandler()((MAJOR .. ": NewLocale(addon, locale) 'locale' - data for locale '%s' already exists"):format(type(locale)), 2)
		return 
	end

	-- return a nil value if the locale is neither the current client language nor the default locale
	if not(locale == clientLocale) and not(default) then
		return
	end
	
	self.L[addon][locale] = readmeta
	
	-- set the value of the current locale we're registering. Don't register more than one at once, or it'll bug out
	currentLocale = self.L[addon][locale]
	
	if (default) then
		defaultLocale = locale
		
		return writedefaultmeta
	end

	return writemeta
end

--
-- retrieve the current locale for the game client
function gLocale:GetLocale(addon, silent)
	if type(addon) ~= "string" then
		geterrorhandler()((MAJOR .. ": GetLocale(addon) 'addon' - string expected, got %s"):format(type(addon)), 2)
		return 
	end
	
	if not(self.L[addon]) then
		if not(silent) then
			geterrorhandler()((MAJOR .. ": GetLocale(addon) 'addon' - couldn't find any registered locales for addon '%s'"):format(addon), 2)
		end
		return 
	end

	return self.L[addon][clientLocale] or self.L[addon][defaultLocale]
end

