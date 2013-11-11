local L = LibStub("gLocale-1.0"):NewLocale((select(1, ...)), "enUS", true) -- do NOT set the 'true' flag on any other locales!
if not(L) then return end

--[[
	Start other locale files with the following (where "ruRU" should be replaced with your locale):
	
		local L = LibStub("gLocale-1.0"):NewLocale((select(1, ...)), "ruRU")
		if not(L) then return end	
]]--

--[[
	enUS.lua
	
	This is the default locale. 
	Everything not specified in any other locale file will be retrieved from here. 
	This file should also serve as a template when translating to other locales.
	
	When the value of an entry is set to 'true', the key name will be returned instead. 
	This should only apply to the default locale, which is this one. 
	In all other locales you should put the translated text within quotation marks in place of the 'true' value, 
	and never touch the text in the key/index. 
	
	NEVER change the key/index names located between the square brackets in L["EXAMPLENAME"]
	NEVER change anything within escape sequences or search patterns, eg:
		"(|Hplayer.+|h) has earned the achievement (.+)!"
			- only "has earned the achievement" should be translated here, as the rest are links and formatting
		
		"|cFFFFD100Hello to you!|r"
			- only "Hello to you!" should be translated here, as the rest is a color code. 
			
		If you wish to learn more about escape sequences and search patterns, I recommend the following:
			http://www.wowpedia.org/UI_escape_sequences -- text codes unique to WoW
			http://www.wowpedia.org/Pattern_matching -- Lua text patterns


	I proof read all submitted locales before releasing them, though, so major errors should hopefully be avoided! 

	I can however not do anything about your bad spelling, so try to keep that to a minimum... 
	If I knew how to write in all sorts of languages, I really wouldn't be needing anybody to localize. ;)
	
	Enjoy!
]]--

--------------------------------------------------------------------------------------------------
--		Modules
--------------------------------------------------------------------------------------------------
-- ActionBars
do
	L["Layout '%s' doesn't exist, valid values are %s."] = true
	L["There is a problem with your ActionBars.|nThe user interface needs to be reloaded in order to fix it.|nReload now?"] = true
	L["<Left-Click> to show additional ActionBars"] = true
	L["<Left-Click> to hide this ActionBar"] = true
end

-- ActionBars: micromenu
do
	L["Achievements"] = true
	L["Character Info"] = true
	L["Customer Support"] = true
	L["Dungeon Finder"] = true
	L["Dungeon Journal"] = true
	L["Game Menu"] = true
	L["Guild"] = true
	L["Guild Finder"] = true
	L["You're not currently a member of a Guild"] = true
	L["Player vs Player"] = true
	L["Quest Log"] = true
	L["Raid"] = true
	L["Spellbook & Abilities"] = true
	L["Starter Edition accounts cannot perform that action"] = true
	L["Talents"] = true
	L["This feature becomes available once you earn a Talent Point."] = true
end

-- ActionBars: menu
do
	L["ActionBars are banks of hotkeys that allow you to quickly access abilities and inventory items. Here you can activate additional ActionBars and control their behaviors."] = true
	L["Secure Ability Toggle"] = true
	L["When selected you will be protected from toggling your abilities off if accidently hitting the button more than once in a short period of time."] = true
	L["Lock ActionBars"] = true
	L["Prevents the user from picking up/dragging spells on the action bar. This function can be bound to a function key in the keybindings interface."] = true
	L["Pick Up Action Key"] = true
	L["ALT key"] = true
	L["Use the \"ALT\" key to pick up/drag spells from locked actionbars."] = true
	L["CTRL key"] = true
	L["Use the \"CTRL\" key to pick up/drag spells from locked actionbars."] = true
	L["SHIFT key"] = true
	L["Use the \"SHIFT\" key to pick up/drag spells from locked actionbars."] = true
	L["None"] = true
	L["No key set."] = true
	L["Visible ActionBars"] = true
	L["Show the rightmost side ActionBar"] = true
	L["Show the leftmost side ActionBar"] = true
	L["Show the secondary ActionBar"] = true
	L["Show the third ActionBar"] = true
	L["Show the Pet ActionBar"] = true
	L["Show the Shapeshift/Stance/Aspect Bar"] = true
	L["Show the Totem Bar"] = true
	L["Show the Micro Menu"] = true
	L["ActionBar Layout"] = true
	L["Sort ActionBars from top to bottom"] = true
	L["This displays the main ActionBar on top, and is the default behavior of the UI. Disable to display the main ActionBar at the bottom."] = true
	L["Button Size"] = true
	L["Choose the size of the buttons in your ActionBars"] = true
	L["Sets the size of the buttons in your ActionBars. Does not apply to the TotemBar."] = true
end

-- ActionBars: Install
do
	L["Select Visible ActionBars"] = true
	L["Here you can decide what actionbars to have visible. Most actionbars can also be toggled by clicking the arrows located next to their edges which become visible when hovering over them with the mouse cursor. This does not work while engaged in combat."] = true
	L["You can try out different layouts before proceding!"] = true

	L["Toggle Bar 2"] = true
	L["Toggle Bar 3"] = true
	L["Toggle Bar 4"] = true
	L["Toggle Bar 5"] = true
	L["Toggle Pet Bar"] = true
	L["Toggle Shapeshift/Stance/Aspect Bar"] = true
	L["Toggle Totem Bar"] = true
	L["Toggle Micro Menu"] = true
	
	L["Select Main ActionBar Position"] = true
	L["When having multiple actionbars visible, do you prefer to have the main actionbar displayed at the top or at the bottom? The default setting is top."] = true
end

-- ActionButtons: Keybinds (displayed on buttons)
do
	L["A"] = true -- Alt
	L["C"] = true -- Ctrl
	L["S"] = true -- Shift
	L["M"] = true -- Mouse Button
	L["M3"] = true -- Middle/Third Mouse Button
	L["N"] = true -- Numpad
	L["NL"] = true -- Numlock
	L["CL"] = true -- Capslock
	L["Clr"] = true -- Clear
	L["Del"] = true -- Delete
	L["End"] = true -- End
	L["Home"] = true -- Home
	L["Ins"] = true -- Insert
	L["Tab"] = true -- Tab
	L["Bs"] = true -- Backspace
	L["WD"] = true -- Mouse Wheel Down
	L["WU"] = true -- Mouse Wheel Up
	L["PD"] = true -- Page Down
	L["PU"] = true -- Page Up
	L["SL"] = true -- Scroll Lock
	L["Spc"] = true -- Spacebar
	L["Dn"] = true -- Down Arrow
	L["Lt"] = true -- Left Arrow
	L["Rt"] = true -- Right Arrow
	L["Up"] = true -- Up Arrow
end

-- ActionButtons: menu
do
	L["ActionButtons are buttons allowing you to use items, cast spells or run a macro with a single keypress or mouseclick. Here you can decide upon the styling and visible elements of your ActionButtons."] = true
	L["Button Styling"] = true
	L["Button Text"] = true
	L["Show hotkeys on the ActionButtons"] = true
	L["Show Keybinds"] = true
	L["This will display your currently assigned hotkeys on the ActionButtons"] = true
	L["Show macro names on the ActionButtons"] = true
	L["Show Names"] = true
	L["This will display the names of your macros on the ActionButtons"] = true
	L["Show gloss layer on ActionButtons"] = true
	L["Show Gloss"] = true
	L["This will display the gloss overlay on the ActionButtons"] = true
	L["Show shade layer on ActionButtons"] = true
	L["This will display the shade overlay on the ActionButtons"] = true
	L["Show Shade"] = true
	--L["Set amount of gloss"] = true
	--L["Set amount of shade"] = true
end

-- Auras: menu
do
	L["These options allow you to control how buffs and debuffs are displayed. If you wish to change the position of the buffs and debuffs, you can unlock them for movement with |cFF4488FF/glock|r."] = true
	L["Aura Styling"] = true
	L["Show gloss layer on Auras"] = true
	L["Show Gloss"] = true 
	L["This will display the gloss overlay on the Auras"] = true
	L["Show shade layer on Auras"] = true
	L["This will display the shade overlay on the Auras"] = true
	L["Show Shade"] = true 
	L["Time Display"] = true
	L["Show remaining time on Auras"] = true
	L["Show Time"] = true
	L["This will display the currently remaining time on Auras where applicable"] = true
	L["Show cooldown spirals on Auras"] = true
	L["Show Cooldown Spirals"] = true
	L["This will display cooldown spirals on Auras to indicate remaining time"] = true
end

-- Bags
do
	L["Gizmos"] = true -- used for "special" things like the toy train set
	L["Equipment Sets"] = true -- used for the stored equipment sets
	L["New Items"] = true -- used for the unsorted new items category in the bags
	L["Click to sort"] = true
	L["<Left-Click to toggle display of the Bag Bar>"] = true
	L["<Left-Click to open the currency frame>"] = true
	L["<Left-Click to open the category selection menu>"] = true
	L["<Left-Click to search for items in your bags>"] = true
	L["Close all your bags"] = true
	L["Close this category and keep it hidden"] = true
	L["Close this category and show its contents in the main container"] = true
end

-- Bags: menus 
do
	L["A character can store items in its backpack, bags and bank. Here you can configure the appearance and behavior of these."] = true
	L["Container Display"] = true
	L["Show this category and its contents"] = true
	L["Hide this category and all its contents completely"] = true
	L["Bypass"] = true
	L["Hide this category, and display its contents in the main container instead"] = true
	L["Choose the minimum item quality to display in this category"] = true
	L["Bag Width"] = true
	L["Sets the number of horizontal slots in the bag containers. Does not apply to the bank."] = true
	L["Bag Scale"] = true
	L["Sets the overall scale of the bags"] = true
	L["Restack"] = true
	L["Automatically restack items when opening your bags or the bank"] = true
	L["Automatically restack when looting or crafting items"] = true
	L["Sorting"] = true
	L["Sort the items within each container"] = true
	L["Sorts the items inside each container according to rarity, item level, name and quanity. Disable to have the items remain in place."] = true
	L["Compress empty bag slots"] = true
	L["Compress empty slots down to maximum one row of each type."] = true
	L["Lock the bags into place"] = true
	L["Slot Button Size"] = true
	L["Choose the size of the slot buttons in your bags."] = true
	L["Sets the size of the slot buttons in your bags. Does not affect the overall scale."] = true
	L["Bag scale"] = true
	L["Button Styling"] = true 
	L["Show gloss layer on buttons"] = true
	L["Show Gloss"] = true 
	L["This will display the gloss overlay on the buttons"] = true
	L["Show shade layer on buttons"] = true
	L["This will display the shade overlay on the buttons"] = true
	L["Show Shade"] = true 
	L["Show Durability"] = true
	L["This will display durability on damaged items in your bags"] = true
	L["Color unequippable items red"] = true
	L["This will color equippable items in your bags that you are unable to equip red"] = true
	L["Apply 'All In One' Layout"] = true
	L["Click here to automatically configure the bags and bank to be displayed as large unsorted containers."] = true
	L["The bags can be configured to work as one large 'all-in-one' container, with no categories, no sorting and no empty space compression. If you wish to have that type of layout, click the button:"] = true
	L["The 'New Items' category will display newly acquired items if enabled. Here you can set which categories and rarities to include."] = true
	L["Minimum item quality"] = true
	L["Choose the minimum item rarity to be included in the 'New Items' category."] = true
end

-- Bags: Install
do
	L["Select Layout"] = true
	L["The %s bag module has a variety of configuration options for display, layout and sorting."] = true
	L["The two most popular has proven to be %s's default layout, and the 'All In One' layout."] = true
	L["The 'All In One' layout features all your bags and bank displayed as singular large containers, with no categories, no sorting and no empty space compression. This is the layout for those that prefer to sort and control things themselves."] = true
	L["%s's layout features the opposite, with all categories split into separate containers, and sorted within those containers by rarity, item level, stack size and item name. This layout also compresses empty slots to take up less screen space."] = true
	L["You can open your bags to test out the different layouts before proceding!"] = true
	L["Apply %s's Layout"] = true
end

-- Bags: chat commands
do
	L["Empty bag slots will now be compressed"] = true
	L["Empty bag slots will no longer be compressed"] = true
end

-- Bags: restack
do
	L["Restack is already running, use |cFF4488FF/restackbags resume|r if stuck"] = true
	L["Resuming restack operation"] = true
	L["No running restack operation to resume"] = true
	L["<Left-Click to restack the items in your bags>"] = true
	L["<Left-Click to restack the items in your bags>|n<Right-Click for options>"] = true
end

-- Castbars: menu
do
	L["Here you can change the size and visibility of the on-screen castbars. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = true
	L["Show the player castbar"] = true
	L["Show for tradeskills"] = true
	L["Show the pet castbar"] = true
	L["Show the target castbar"] = true
	L["Show the focus target castbar"] = true
	L["Set Width"] = true
	L["Set the width of the bar"] = true
	L["Set Height"] = true
	L["Set the height of the bar"] = true
end

-- Chat: timestamp settings tooltip (http://www.lua.org/pil/22.1.html)
do
	L["|cFFFFD100%a|r abbreviated weekday name (e.g., Wed)"] = true
	L["|cFFFFD100%A|r full weekday name (e.g., Wednesday)"] = true
	L["|cFFFFD100%b|r abbreviated month name (e.g., Sep)"] = true
	L["|cFFFFD100%B|r full month name (e.g., September)"] = true
	L["|cFFFFD100%c|r date and time (e.g., 09/16/98 23:48:10)"] = true
	L["|cFFFFD100%d|r day of the month (16) [01-31]"] = true
	L["|cFFFFD100%H|r hour, using a 24-hour clock (23) [00-23]"] = true
	L["|cFFFFD100%I|r hour, using a 12-hour clock (11) [01-12]"] = true
	L["|cFFFFD100%M|r minute (48) [00-59]"] = true
	L["|cFFFFD100%m|r month (09) [01-12]"] = true
	L["|cFFFFD100%p|r either 'am' or 'pm'"] = true
	L["|cFFFFD100%S|r second (10) [00-61]"] = true
	L["|cFFFFD100%w|r weekday (3) [0-6 = Sunday-Saturday]"] = true
	L["|cFFFFD100%x|r date (e.g., 09/16/98)"] = true
	L["|cFFFFD100%X|r time (e.g., 23:48:10)"] = true
	L["|cFFFFD100%Y|r full year (1998)"] = true
	L["|cFFFFD100%y|r two-digit year (98) [00-99]"] = true
	L["|cFFFFD100%%|r the character `%´"] = true -- 'character' here refers to a letter or number, not a game character...
end

-- Chat: names of the chat frames handled by the addon
do
	L["Main"] = true
	L["Loot"] = true
	L["Log"] = true
	L["Public"] = true
end

-- Chat: abbreviated channel names
do
	L["G"] = true -- Guild
	L["O"] = true -- Officer
	L["P"] = true -- Party
	L["PL"] = true -- Party Leader
	L["DG"] = true -- Dungeon Guide
	L["R"] = true -- Raid
	L["RL"] = true -- Raid Leader
	L["RW"] = true -- Raid Warning
	L["BG"] = true -- Battleground
	L["BGL"] = true -- Battleground Leader
	L["GM"] = true -- Game Master
end

-- Chat: various abbreviations
do
	L["Guild XP"] = true -- Guild Experience
	L["HK"] = true -- Honorable Kill
	L["XP"] = true -- Experience
end

-- Chat: menu
do
	L["Here you can change the settings of the chat windows and chat bubbles. |n|n|cFFFF0000If you wish to change visible chat channels and messages within a chat window, background color, font size, or the class coloring of character names, then Right-Click the chat tab located above the relevant chat window instead.|r"] = true
	L["Enable sound alerts when receiving whispers or private Battle.net messages."] = true

	L["Chat Display"] = true
	L["Abbreviate channel names."] = true
	L["Abbreviate global strings for a cleaner chat."] = true
	L["Display brackets around player- and channel names."] = true
	L["Use emoticons in the chat"] = true
	L["Auto-align the text depending on the chat window's position."] = true
	L["Auto-align the main chat window to the bottom left panel/corner."] = true
	L["Auto-size the main chat window to match the bottom left panel size."] = true

	L["Timestamps"] = true
	L["Show timestamps."] = true
	L["Timestamp color:"] = true
	L["Timestamp format:"] = true

	L["Chat Bubbles"] = true
	L["Collapse chat bubbles"] = true
	L["Collapses the chat bubbles to preserve space, and expands them on mouseover."] = true
	L["Display emoticons in the chat bubbles"] = true

	L["Loot Window"] = true
	L["Create 'Loot' Window"] = true
	L["Enable the use of the special 'Loot' window."] = true
	L["Maintain the channels and groups of the 'Loot' window."] = true
	L["Auto-align the 'Loot' chat window to the bottom right panel/corner."] = true
	L["Auto-size the 'Loot' chat window to match the bottom right panel size."] = true
end

-- Chat: Install
do
	L["Public Chat Window"] = true
	L["Public chat like Trade, General and LocalDefense can be displayed in a separate tab in the main chat window. This will keep your main chat window free from intrusive spam, while still having all the relevant public chat available. Do you wish to do so now?"] = true

	L["Loot Window"] = true
	L["Information like received loot, crafted items, experience, reputation and honor gains as well as all currencies and similar received items can be displayed in a separate chat window. Do you wish to do so now?"] = true
	
	L["Initial Window Size & Position"] = true
	L["Your chat windows can be configured to match the unitframes and the bottom UI panels in size and position. Do you wish to do so now?"] = true
	L["This will also dock any additional chat windows."] = true	
	
	L["Window Auto-Positioning"] = true
	L["Your chat windows will slightly change position when you change UI scale, game window size or screen resolution. The UI can maintain the position of the '%s' and '%s' chat windows whenever you log in, reload the UI or in any way change the size or scale of the visible area. Do you wish to activate this feature?"] = true
	
	L["Window Auto-Sizing"] = true
	L["Would you like the UI to maintain the default size of the chat frames, aligning them in size to visually fit the unitframes and bottom UI panels?"] = true
	
	L["Channel & Window Colors"] = true
	L["Would you like to change chatframe colors to what %s recommends?"] = true
end

-- Combat
do
	L["dps"] = true -- Damage Per Second
	L["hps"] = true -- Healing Per Second
	L["tps"] = true -- Threat Per Second
	L["Last fight lasted %s"] = true
	L["You did an average of %s%s"] = true
	L["You are overnuking!"] = true
	L["You have aggro, stop attacking!"] = true
	L["You are tanking!"] = true
	L["You are losing threat!"] = true
	L["You've lost the threat!"] = true
end

-- Combat: menu
do
	L["Simple DPS/HPS Meter"] = true
	L["Enable simple DPS/HPS meter"] = true
	L["Show DPS/HPS when you are solo"] = true
	L["Show DPS/HPS when you are in a PvP instance"] = true
	L["Display a simple verbose report at the end of combat"] = true
	L["Minimum DPS to display: "] = true
	L["Minimum combat duration to display: "] = true
	L["Simple Threat Meter"] = true
	L["Enable simple Threat meter"] = true
	L["Use the Focus target when it exists"] = true
	L["Enable threat warnings"] = true
	L["Show threat when you are solo"] = true
	L["Show threat when you are in a PvP instance"] = true
	L["Show threat when you are a healer"] = true
	L["Enable simple scrolling combat text"] = true
end

-- Combatlog
do
	L["GUIS"] = true -- the visible name of our custom combat log filter, used to identify it
	L["Show simplified messages of actions done by you and done to you."] = true -- the description of this filter
end

-- Combatlog: menu
do
	L["Maintain the settings of the GUIS filter so that they're always the same"] = true
	L["Keep only the GUIS and '%s' quickbuttons visible, with GUIS at the start"] = true
	L["Autmatically switch to the GUIS filter when you log in or reload the UI"] = true
	L["Autmatically switch to the GUIS filter whenever you see a loading screen"] = true
	L["Automatically switch to the GUIS filter when entering combat"] = true
end

-- Loot
do
	L["BoE"] = true -- Bind on Equip
	L["BoP"] = true -- Bind on Pickup
end

-- Merchant
do
	L["Selling Poor Quality items:"] = true
	L["-%s|cFF00DDDDx%d|r %s"] = true -- nothing to localize in this one, unless you wish to change the formatting
	L["Earned %s"] = true
	L["You repaired your items for %s"] = true
	L["You repaired your items for %s using Guild Bank funds"] = true
	L["You haven't got enough available funds to repair!"] = true
	L["Your profit is %s"] = true
	L["Your expenses are %s"] = true
	L["Poor Quality items will now be automatically sold when visiting a vendor"] = true
	L["Poor Quality items will no longer be automatically sold"] = true
	L["Your items will now be automatically repaired when visiting a vendor with repair capabilities"] = true
	L["Your items will no longer be automatically repaired"] = true
	L["Your items will now be repaired using the Guild Bank if the options and the funds are available"] = true
	L["Your items will now be repaired using your own funds"] = true
	L["Detailed reports for autoselling of Poor Quality items turned on"] = true
	L["Detailed reports for autoselling of Poor Quality items turned off, only summary will be shown"] = true
	L["Toggle autosell of Poor Quality items"] = true
	L["Toggle display of detailed sales reports"] = true
	L["Toggle autorepair of your armor"] = true
	L["Toggle Guild Bank repairs"] = true
	L["<Alt-Click to buy the maximum amount>"] = true
end

-- Merchant: Menu
do
	L["Here you can configure the options for automatic actions upon visiting a merchant, like selling junk and repairing your armor."] = true
	L["Automatically repair your armor and weapons"] = true
	L["Enabling this option will show a detailed report of the automatically sold items in the default chat frame. Disabling it will restrict the report to gold earned, and the cost of repairs."] = true
	L["Automatically sell poor quality items"] = true
	L["Enabling this option will automatically sell poor quality items in your bags whenever you visit a merchant."] = true
	L["Show detailed sales reports"] = true
	L["Enabling this option will automatically repair your items whenever you visit a merchant with repair capability, as long as you have sufficient funds to pay for the repairs."] = true
	L["Use your available Guild Bank funds to when available"] = true
	L["Enabling this option will cause the automatic repair to be done using Guild funds if available."] = true
end

-- Minimap
do
	L["Calendar"] = true
	L["New Event!"] = true
	L["New Mail!"] = true
	
	L["Raid Finder"] = true
	
	L["(Sanctuary)"] = true
	L["(PvP Area)"] = true
	L["(%s Territory)"] = true
	L["(Contested Territory)"] = true
	L["(Combat Zone)"] = true
	L["Social"] = true
end

-- Minimap: menu
do
	L["The Minimap is a miniature map of your closest surrounding areas, allowing you to easily navigate as well as quickly locate elements such as specific vendors, or a herb or ore you are tracking. If you wish to change the position of the Minimap, you can unlock it for movement with |cFF4488FF/glock|r."] = true
	L["Display the clock"] = true
	L["Display the current player coordinates on the Minimap when available"] = true
	L["Use the Mouse Wheel to zoom in and out"] = true
	L["Display the difficulty of the current instance when hovering over the Minimap"] = true
	L["Display the shortcut menu when clicking the middle mouse button on the Minimap"] = true
	L["Rotate Minimap"] = true
	L["Check this to rotate the entire minimap instead of the player arrow."] = true
end

-- Nameplates: menu
do
	L["Nameplates are small health- and castbars visible over a character or NPC's head. These options allow you to control which Nameplates are visible within the game field while you play."] = true
	L["Automatically enable nameplates based on your current specialization"] = true
	L["Automatically enable friendly nameplates for repeatable quests that require them"] = true
	L["Only show friendly nameplates when engaged in combat"] = true
	L["Only show enemy nameplates when engaged in combat"] = true
	L["Use a blacklist to filter out certain nameplates"] = true
	L["Display character level"] = true
	L["Hide for max level characters when you too are max level"] = true
	L["Display character names"] = true
	L["Display combo points on your target"] = true
	
	L["Nameplate Motion Type"] = true
	L["Overlapping Nameplates"] = true
	L["Stacking Nameplates"] = true
	L["Spreading Nameplates"] = true
	L["This method will allow nameplates to overlap."] = true
	L["This method avoids overlapping nameplates by stacking them vertically."] = true
	L["This method avoids overlapping nameplates by spreading them out horizontally and vertically."] = true
	
	L["Friendly Units"] = true
	L["Friendly Players"] = true
	L["Turn this on to display Unit Nameplates for friendly units."] = true
	L["Enemy Units"] = true
	L["Enemy Players"] = true
	L["Turn this on to display Unit Nameplates for enemies."] = true
	L["Pets"] = true
	L["Turn this on to display Unit Nameplates for friendly pets."] = true
	L["Turn this on to display Unit Nameplates for enemy pets."] = true
	L["Totems"] = true
	L["Turn this on to display Unit Nameplates for friendly totems."] = true
	L["Turn this on to display Unit Nameplates for enemy totems."] = true
	L["Guardians"] = true
	L["Turn this on to display Unit Nameplates for friendly guardians."] = true
	L["Turn this on to display Unit Nameplates for enemy guardians."] = true
end

-- Panels
do
	L["<Left-Click to open all bags>"] = true
	L["<Right-Click for options>"] = true
	L["No Guild"] = true
	L["New Mail!"] = true
	L["No Mail"] = true
	L["Total Usage"] = "Total Memory Usage:"
	L["Tracked Currencies"] = true
	L["Additional AddOns"] = true
	L["Network Stats"] = true
	L["World latency:"] = true
	L["World latency %s:"] = true
	L["(Combat, Casting, Professions, NPCs, etc)"] = true
	L["Realm latency:"] = true
	L["Realm latency %s:"] = true
	L["(Chat, Auction House, etc)"] = true
	L["Display World Latency %s"] = true
	L["Display Home Latency %s"] = true
	L["Display Framerate"] = true

	L["Incoming bandwidth:"] = true
	L["Outgoing bandwidth:"] = true
	L["KB/s"] = true
	L["<Left-Click for more>"] = true
	L["<Left-Click to toggle Friends pane>"] = true
	L["<Left-Click to toggle Guild pane>"] = true
	L["<Left-Click to toggle Reputation pane>"] = true
	L["<Left-Click to toggle Currency frame>"] = true
	L["%d%% of normal experience gained from monsters."] = true
	L["You should rest at an Inn."] = true
	L["Hide copper when you have at least %s"] = true
	L["Hide silver and copper when you have at least %s"] = true
	L["Invite a member to the Guild"] = true
	L["Change the Guild Message Of The Day"] = true
	L["Select currencies to always watch:"] = true
	L["Select how your gold is displayed:"] = true
	
	L["No container equipped in slot %d"] = true
end

-- Panels: menu
do
	L["UI Panels are special frames providing information about the game as well allowing you to easily change settings. Here you can configure the visibility and behavior of these panels. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = true
	L["Visible Panels"] = true
	L["Here you can decide which of the UI panels should be visible. They can still be moved with |cFF4488FF/glock|r when hidden."] = true
	L["Show the bottom right UI panel"] = true
	L["Show the bottom left UI panel"] = true
	L["Bottom Right Panel"] = true
	L["Bottom Left Panel"] = true
	
end

-- Quest: menu
do
	L["QuestLog"] = true
	L["These options allow you to customize how game objectives like Quests and Achievements are displayed in the user interface. If you wish to change the position of the ObjectivesTracker, you can unlock it for movement with |cFF4488FF/glock|r."] = true
	L["Display quest level in the QuestLog"] = true
	L["Objectives Tracker"] = true
	L["Autocollapse the WatchFrame"] = true
	L["Autocollapse the WatchFrame when a boss unitframe is visible"] = true
	L["Automatically align the WatchFrame based on its current position"] = true
	L["Align the WatchFrame to the right"] = true
end

-- Tooltips
do
	L["Here you can change the settings for the game tooltips"] = true
	L["Hide while engaged in combat"] = true
	L["Show values on the tooltip healthbar"] = true
	L["Show player titles in the tooltip"] = true
	L["Show player realms in the tooltip"] = true
	L["Positioning"] = true
	L["Choose what tooltips to anchor to the mouse cursor, instead of displaying in their default positions:"] = true
	L["All tooltips will be displayed in their default positions."] = true
	L["All tooltips will be anchored to the mouse cursor."] = true
	L["Only Units"] = true
	L["Only unit tooltips will be anchored to the mouse cursor, while other tooltips will be displayed in their default positions."] = true
end

-- world status: menu
do
	L["Here you can set the visibility and behaviour of various objects like the XP and Reputation Bars, the Battleground Capture Bars and more. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = true
	L["StatusBars"] = true
	L["Show the player experience bar."] = true
	L["Show when you are at your maximum level or have turned off experience gains."] = true
	L["Show the currently tracked reputation."] = true
	L["Show the capturebar for PvP objectives."] = true
end

-- UnitFrames
do
	L["Due to entering combat at the worst possible time the UnitFrames were unable to complete the layout change.|nPlease reload the user interface with |cFF4488FF/rl|r to complete the operation!"] = true
end

-- UnitFrames: oUF_Trinkets
do
	L["Trinket ready: "] = true
	L["Trinket used: "] = true
	L["WotF used: "] = true
end

-- UnitFrames: menu
do
	L["These options can be used to change the display and behavior of unit frames within the UI. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = true

	L["Choose what unit frames to load"] = true
	L["Enable Party Frames"] = true
	L["Enable Arena Frames"] = true
	L["Enable Boss Frames"] = true
	L["Enable Raid Frames"] = true
	L["Enable MainTank Frames"] = true
	L["Enable ClassBar"] = true
	
	L["Set Focus"] = true
	L["Here you can enable and define a mousebutton and optional modifier key to directly set a focus target from clicking on a frame."] = true
	L["Enable Set Focus"] = true
	L["Enabling this will allow you to quickly set your focus target by clicking the key combination below while holding the mouse pointer over the selected frame."] = true
	L["Modifier Key"] = true

	L["Enable indicators for HoTs, DoTs and missing buffs."] = true
	L["This will display small squares on the party- and raidframes to indicate your active HoTs and missing buffs."] = true

	--L["Auras"] = true
	L["Here you can change the settings for the auras displayed on the player- and target frames."] = true
	L["Filter the target auras in combat"] = true
	L["This will filter out auras not relevant to your role from the target frame while engaged in combat, to make it easier to track your own debuffs."] = true
	L["Desature target auras not cast by the player"] = true
	L["This will desaturate auras on the target frame not cast by you, to make it easier to track your own debuffs."] = true	
	L["Texts"] = true
	L["Show values on the health bars"] = true
	L["Show values on the power bars"] = true
	L["Show values on the Feral Druid mana bar (when below 100%)"] = true
	
	L["Groups"] = true
	L["Here you can change what kind of group frames are used for groups of different sizes."] = true

	L["5 Player Party"] = true
	L["Use the same frames for parties as for raid groups."] = true
	L["Enabling this will show the same types of unitframes for 5 player parties as you currently have chosen for 10 player raids."] = true
	
	L["10 Player Raid"] = true
	L["Use same raid frames as for 25 player raids."] = true
	L["Enabling this will show the same types of unitframes for 10 player raids as you currently have chosen for 25 player raids."] = true

	L["25 Player Raid"] = true
	L["Automatically decide what frames to show based on your current specialization."] = true
	L["Enabling this will display the Grid layout when you are a Healer, and the smaller DPS layout when you are a Tank or DPSer."] = true
	L["Use Healer/Grid layout."] = true
	L["Enabling this will use the Grid layout instead of the smaller DPS layout for raid groups."] = true
	
	L["Player"] = true
	L["ClassBar"] = true
	L["The ClassBar is a larger display of class related information like Holy Power, Runes, Eclipse and Combo Points. It is displayed close to the on-screen CastBar and is designed to more easily track your most important resources."] = true
	L["Enable large movable classbar"] = true
	L["This will enable the large on-screen classbar"] = true
	L["Only in Combat"] = true
	L["Disable integrated classbar"] = true
	L["This will disable the integrated classbar in the player unitframe"] = true
	L["Show player auras"] = true
	L["This decides whether or not to show the auras next to the player frame"] = true
	
	L["Target"] = true
	L["Show target auras"] = true
	L["This decides whether or not to show the auras next to the target frame"] = true
end

-- UnitFrames: GroupPanel
do
	-- party
	L["Show the player along with the Party Frames"] = true
	L["Use Raid Frames instead of Party Frames"] = true
	
	-- raid
	L["Use the grid layout for all Raid sizes"] = true
end


--------------------------------------------------------------------------------------------------
--		FAQ
--------------------------------------------------------------------------------------------------
-- 	Even though most of these strings technically belong to their respective modules,
--		and not the FAQ interface, we still gather them all here for practical reasons.
do
	-- general
	L["FAQ"] = true
	L["Frequently Asked Questions"] = true
	L["Clear All Tags"] = true
	L["Show the current FAQ"] = true
	L["Return to the listing"] = true
	L["Go to the options menu"] = true
	L["Select categories from the list on the left. |nYou can choose multiple categories at once to narrow down your search.|n|nSelected categories will be displayed on top of the listing, |nand clicking them again will deselect them!"] = true
	
	-- core
	L["I wish to move something! How can I change frame positions?"] = true
	L["A lot of frames can be moved to custom positions. You can unlock them all for movement by typing |cFF4488FF/glock|r followed by the Enter key, and lock them with the same command. There are also multiple options available when right-clicking on the overlay of the movable frame."] = true

	-- actionbars
	L["How do I change the currently active Action Page?"] = true
	L["There are no on-screen buttons to do this, so you will have to use keybinds. You can set the relevant keybinds in the Blizzard keybinding interface."] = true
	L["How can I change the visible actionbars?"] = true
	L["You can toggle most actionbars by clicking the arrows located close to their corners. These arrows become visible when hovering over them with the mouse if you're not currently engaged in combat. You can also toggle the actionbars from the options menu, or by running the install tutorial by typing |cFF4488FF/install|r followed by the Enter key."] = true
	L["How do I toggle the MiniMenu?"] = true
	L["The MiniMenu can be displayed by typing |cFF4488FF/showmini|r followed by the Enter key, and |cFF4488FF/hidemini|r to hide it. You can also toggle it from the options menu or by running the install tutorial by typing |cFF4488FF/install|r."] = true
	L["How can I move the actionbars?"] = true
	L["Not all actionbars can be moved, as some are an integrated part of the UI layout. Most of the movable frames in the UI can be unlocked by typing |cFF4488FF/glock|r followed by the Enter key."] = true
	
	-- actionbuttons
	L["How can I toggle keybinds and macro names on the buttons?"] = true
	L["You can enable keybind display on the actionbuttons by typing |cFF4488FF/showhotkeys|r followed by the Enter key, and disable it with |cFF4488FF/hidehotkeys|r. Macro names can be toggled with the |cFF4488FF/shownames|r and |cFF4488FF/hidenames|r commands. All settings can also be changed in the options menu."] = true
	
	-- auras
	L["How can I change how my buffs and debuffs look?"] = true
	L["You can change a lot of settings like the time display and the cooldown spiral in the options menu."] = true
	L["Sometimes the weapon buffs don't display correctly!"] = true
	L["Correct. Sadly this is a bug in the tools Blizzard has given to us addon developers, and not something that is easily fixed. You'll simply have to live with it for now."] = true
	
	-- bags
	L["Sometimes when I choose to bypass a category, not all items are moved to the '%s' container, but some appear in others?"] = true
	L["Some items are put in the 'wrong' categories by Blizzard. Each category in the bag module has its own internal filter that puts these items in their category of they are deemed to belong there. If you bypass this category, the filter is also bypassed, and the item will show up in whatever category Blizzard originally put it in."] = true
	L["How can I change what categories and containers I see? I don't like the current layout!"] = true
	L["Categories can be quickly selected from the quickmenu available by clicking at the arrow next to the '%s' or '%s' containers."] = true
	L["You can change all the settings in the options menu as well as activate the 'all-in-one' layout easily!"] = true
	L["How can I disable the bags? I don't like them!"] = true
	L["All the modules can be enabled or disabled from within the options menu. You can locate the options menu from the button on the Game Menu, or by typing |cFF4488FF/gui|r followed by the Enter key."] = true
	L["I can't close my bags with the 'B' key!"] = true
	L["This is because you probably have bound the 'B' key to 'Open All Bags', which is a one way function. To have the 'B' key actually toggle the containers, you need to bind it to 'Toggle Backpack'. The UI can reassign the key for you automatically. Would you like to do so now?"] = true
	L["Let the 'B' key toggle my bags"] = true
	
	-- castbars
	L["How can I toggle the castbars for myself and my pet?"] = true
	L["The UI features movable on-screen castbars for you, your target, your pet, and your focus target. These bars can be positioned manually by typing |cFF4488FF/glock|r followed by the Enter key. |n|nYou can change their settings, size and visibility in the options menu."] = true
	
	-- minimap
	L["I can't find the Calendar!"] = true
	L["You can open the calendar by clicking the middle mouse button while hovering over the Minimap, or by assigning a keybind to it in the Blizzard keybinding interface avaiable from the GameMenu. The Calendar keybind is located far down the list, along with the GUIS keyinds."] = true
	L["Where can I see the current dungeon- or raid difficulty and size when I'm inside an instance?"] = true
	L["You can see the maximum size of your current group by hovering the cursor over the Minimap while being inside an instance. If you currently have activated Heroic mode, a skull will be visible next to the size display as well."] = true
	L["How can I move the Minimap?"] = true
	L["You can manually move the Minimap as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key."] = true
	
	-- quests
	L["How can I move the quest tracker?"] = true
	L["My actionbars cover the quest tracker!"] = true
	L["You can manually move the quest tracker as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key. If you wish the quest tracker to automatically move in relation to your actionbars, then reset its position to the default. |n|nWhen a frame is unlocked with the |cFF4488FF/glock|r command, you can right click on its overlay and select 'Reset' to return it to its default position. For some frames like the quest tracker, this will allow the UI to decide where it should be put."] = true
	
	-- talents
	L["I can't close the Talent Frame when pressing 'N'"] = true
	L["But you can still close it!|n|nYou can close it with the Escacpe key, or the closebutton located in he upper right corner of the Talent Frame.|n|nWhen closing the Talent Frame with the original keybind to toggle it, it becomes 'tainted'. This means that the game considers it to be 'insecure', and you won't be allowed to do actions like for example changing your glyphs. This only happens when closed with the hotkey, not when it's closed by the Escape key or the closebutton.|n|nBy reassigning your Talent Frame keybind to a function that only opens the frame, not toggles it, we have made sure that it gets closed the proper way, and you can continue to change your glyphs as intended."] = true
	
	-- tooltips
	L["How can I toggle the display of player realms and titles in the tooltips?"] = true
	L["You can change most of the tooltip settings from the options menu."] = true
	
	-- unitframes
	L["My party frames aren't showing!"] = true
	L["My raid frames aren't showing!"] = true
	L["You can set a lot of options for the party- and raidframes from within the options menu."] = true
	
	-- worldmap
	L["Why do the quest icons on the WorldMap disappear sometimes?"] = true
	L["Due to some problems with the default game interface, these icons must be hidden while being engaged in combat."] = true
end


--------------------------------------------------------------------------------------------------
--		Chat Command List
--------------------------------------------------------------------------------------------------
-- we're doing this in the worst possible manner, just because we can!
do
	local separator = "€€€"
	local cmd = "|cFF4488FF/glock|r - lock/unlock the frames for movement"
	cmd = cmd .. separator .. "|cFF4488FF/greset|r - reset the position of movable frames"
	cmd = cmd .. separator .. "|cFF4488FF/resetbars|r - reset the position of movable actionbars only"
	cmd = cmd .. separator .. "|cFF4488FF/resetbags|r - return the bags to their default position"
	cmd = cmd .. separator .. "|cFF4488FF/scalebags|r X - set the scale of the bags, where X is a number from 1.0 to 2.0"
	cmd = cmd .. separator .. "|cFF4488FF/compressbags|r - toggle compression of empty bag slots"
	cmd = cmd .. separator .. "|cFF4488FF/showsidebars|r, |cFF4488FF/hidesidebars|r - toggle display of both the side actionbars"
	cmd = cmd .. separator .. "|cFF4488FF/showrightbar|r, |cFF4488FF/hiderightbar|r - toggle display of the rightmost side actionbar"
	cmd = cmd .. separator .. "|cFF4488FF/showleftbar|r, |cFF4488FF/hideleftbar|r - toggle display of the leftmost side actionbar"
	cmd = cmd .. separator .. "|cFF4488FF/showpet|r, |cFF4488FF/hidepet|r - toggle display of the pet actionbar"
	cmd = cmd .. separator .. "|cFF4488FF/showshift|r, |cFF4488FF/hideshift|r - toggle display of the shift/stance/aspect actionbar"
	cmd = cmd .. separator .. "|cFF4488FF/showtotem|r, |cFF4488FF/hidetotem|r - toggle display of the totembar"
	cmd = cmd .. separator .. "|cFF4488FF/showmini|r, |cFF4488FF/hidemini|r - toggle display of the mini/micromenu"
	cmd = cmd .. separator .. "|cFF4488FF/rl|r - reload the user interface"
	cmd = cmd .. separator .. "|cFF4488FF/gm|r - opens the help frame"
	cmd = cmd .. separator .. "|cFF4488FF/showchatbrackets|r - show brackets around player- and channel names in chat"
	cmd = cmd .. separator .. "|cFF4488FF/hidechatbrackets|r - hide brackets from player- and channel names in chat"
	cmd = cmd .. separator .. "|cFF4488FF/chatmenu|r - opens the chatframe menu"
	cmd = cmd .. separator .. "|cFF4488FF/mapmenu|r - opens the Minimap middle-click menu"
	cmd = cmd .. separator .. "|cFF4488FF/tt|r or |cFF4488FF/wt|r - whispers your current target"
	cmd = cmd .. separator .. "|cFF4488FF/tf|r or |cFF4488FF/wf|r - whispers your current focus target"
	cmd = cmd .. separator .. "|cFF4488FF/showhotkeys|r, |cFF4488FF/hidehotkeys|r - toggle hotkeys on actionbuttons"
	cmd = cmd .. separator .. "|cFF4488FF/shownames|r, |cFF4488FF/hidenames|r - toggle macro name display on actionbuttons"
	cmd = cmd .. separator .. "|cFF4488FF/enableautorepair|r - enable automatic repairs of your armor"
	cmd = cmd .. separator .. "|cFF4488FF/disableautorepair|r - disable automatic repairs of your armor"
	cmd = cmd .. separator .. "|cFF4488FF/enableguildrepair|r - use guild funds when available to repair your armor"
	cmd = cmd .. separator .. "|cFF4488FF/disableguildrepair|r - disable the use of guild funds for repairs"
	cmd = cmd .. separator .. "|cFF4488FF/enableautosell|r - enable automatic selling of poor quality loot"
	cmd = cmd .. separator .. "|cFF4488FF/disableautosell|r - disable automatic selling of poor quality loot"
	cmd = cmd .. separator .. "|cFF4488FF/enabledetailedreport|r - shows a detailed per item sales report for poor loot"
	cmd = cmd .. separator .. "|cFF4488FF/disabledetailedreport|r - disables the detailed reports and only shows totals"
	cmd = cmd .. separator .. "|cFF4488FF/mainspec|r - activate your main talent specialization"
	cmd = cmd .. separator .. "|cFF4488FF/offspec|r - activate your secondary talent specialization"
	cmd = cmd .. separator .. "|cFF4488FF/togglespec|r - toggle between your dual talent specializations"
	cmd = cmd .. separator .. "|cFF4488FF/ghelp|r - shows this menu"
	L["chatcommandlist-separator"] = separator
	L["chatcommandlist"] = cmd
end


--------------------------------------------------------------------------------------------------
--		Keybinds Menu (Blizzard)
--------------------------------------------------------------------------------------------------
do
	L["Toggle Calendar"] = true
	L["Whisper focus"] = true
	L["Whisper target"] = true
end


--------------------------------------------------------------------------------------------------
--		Error Messages 
--------------------------------------------------------------------------------------------------
do
	L["Can't toggle Action Bars while engaged in combat!"] = true
	L["Can't change Action Bar layout while engaged in combat!"] = true
	L["Frames cannot be moved while engaged in combat"] = true
	L["Hiding movable frame anchors due to combat"] = true
	L["UnitFrames cannot be configured while engaged in combat"] = true
	L["Can't initialize bags while engaged in combat."] = true
	L["Please exit combat then re-open the bags!"] = true
end


--------------------------------------------------------------------------------------------------
--		Core Messages
--------------------------------------------------------------------------------------------------
do
	L["Goldpaw"] = "|cFFFF7D0AGoldpaw|r" -- my class colored name. no changes needed here.
	L["The user interface needs to be reloaded for the changes to take effect. Do you wish to reload it now?"] = true
	L["You can reload the user interface at any time with |cFF4488FF/rl|r or |cFF4488FF/reload|r"] = true
	L["Can not apply default settings while engaged in combat."] = true
	L["Show Talent Pane"] = true
end

-- menu
do
	L["UI Scale"] = true
	L["Use UI Scale"] = true
	L["Check to use the UI Scale Slider, uncheck to use the system default scale."] = true
	L["Changes the size of the game’s user interface."] = true
	L["Using custom UI scaling is not recommended. It will produce fuzzy borders and incorrectly sized objects."] = true
	L["Apply the new UI scale."] = true
	L["Load Module"] = true
	L["Module Selection"] = true
	L["Choose which modules should be loaded, and when."] = true
	L["Never load this module"] = true
	L["Load this module unless an addon with similar functionality is detected"] = true
	L["Always load this module, regardles of what other addons are loaded"] = true
	L["(In Development)"] = true
end

-- install tutorial
do
	-- general install tutorial messages
	L["Skip forward to the next step in the tutorial."] = true
	L["Previous"] = true
	L["Go backwards to the previous step in the tutorial."] = true
	L["Skip this step"] = true
	L["Apply the currently selected settings"] = true
	L["Procede with this step of the install tutorial."] = true
	L["Cancel the install tutorial."] = true
	L["Setup aborted. Type |cFF4488FF/install|r to restart the tutorial."] = true
	L["Setup aborted because of combat. Type |cFF4488FF/install|r to restart the tutorial."] = true
	L["This is recommended!"] = true

	-- core module's install tutorial
	L["This is the first time you're running %s on this character. Would you like to run the install tutorial now?"] = true
	L["Using custom UI scaling will distort graphics, create fuzzy borders, and otherwise ruin frame proportions and positions. It is adviced to always leave this off, as it will seriously affect the entire layout of the UI in unpredictable ways."] = true
	L["UI scaling is currently activated. Do you wish to disable this?"] = true
	L["|cFFFF0000UI scaling is currently deactivated, which is the recommended setting, so we are skipping this step.|r"] = true
end

-- general 
-- basically a bunch of very common words, phrases and abbreviations
-- that several modules might have need for
do
	L["R"] = true -- R as in Red
	L["G"] = true -- G as in Green
	L["B"] = true -- B as in Blue
	L["A"] = true -- A as in Alpha (for opacity/transparency)

	L["m"] = true -- minute
	L["s"] = true -- second
	L["h"] = true -- hour
	L["d"] = true -- day

	L["Alt"] = true -- the ALT key
	L["Ctrl"] = true -- the CTRL key
	L["Shift"] = true -- the SHIFT key
	L["Mouse Button"] = true

	L["Always"] = true
	L["Apply"] = true
	L["Bags"] = true
	L["Bank"] = true 
	L["Bottom"] = true
	L["Cancel"] = true
	L["Categories"] = true
	L["Close"] = true
	L["Continue"] = true
	L["Copy"] = true -- to copy. the verb.
	L["Default"] = true
	L["Elements"] = true -- like elements in a frame, not as in fire, ice etc
	L["Free"] = true -- free space in bags and bank
	L["General"] = true -- general as in general info
	L["Ghost"] = true -- when you are dead and have released your spirit
	L["Hide"] = true -- to hide something. not hide as in "thick hide".
	L["Lock"] = true -- to lock something, like a frame. the verb.
	L["Main"] = true -- used for Main chat frame, Main bag, etc
	L["Next"] = true
	L["Never"] = true
	L["No"] = true
	L["Okay"] = true
	L["Open"] = true
	L["Paste"] = true -- as in copy & paste. the verb.
	L["Reset"] = true
	L["Rested"] = true -- when you are rested, and will recieve 200% xp from kills
	L["Scroll"] = true -- "Scroll" as in "Scroll of Enchant". The noun, not the verb.
	L["Show"] = true
	L["Skip"] = true
	L["Top"] = true
	L["Total"] = true
	L["Visibility"] = true
	L["Yes"] = true

	L["Requires the UI to be reloaded!"] = true
	L["Changing this setting requires the UI to be reloaded in order to complete."] = true
end

-- gFrameHandler replacements (/glock)
do
	L["<Left-Click and drag to move the frame>"] = true
	L["<Left-Click+Shift to lock into position>"] = true
	--L["<Right-Click for options>"] = true -- the panel module supplies this one
	L["Center horizontally"] = true
	L["Center vertically"] = true
end

-- visible module names
do
	L["ActionBars"] = true
	L["ActionButtons"] = true
	L["Auras"] = true
	L["Bags"] = true
	L["Buffs & Debuffs"] = true
	L["Castbars"] = true
	L["Core"] = true
	L["Chat"] = true
	L["Combat"] = true
	L["CombatLog"] = true
	L["Errors"] = true
	L["Loot"] = true
	L["Merchants"] = true
	L["Minimap"] = true
	L["Nameplates"] = true
	L["Quests"] = true
	L["Timers"] = true
	L["Tooltips"] = true
	L["UI Panels"] = true
	L["UI Skinning"] = true
	L["UnitFrames"] = true
		L["PartyFrames"] = true
		L["ArenaFrames"] = true
		L["BossFrames"] = true
		L["RaidFrames"] = true
		L["MainTankFrames"] = true
	L["World Status"] = true
end

-- various stuff used in the install tutorial's intro screen
do
	L["Credits to: "] = true
	L["Web: "] = true
	L["Download: "] = true
	L["Twitter: "] = true
	L["Facebook: "] = true
	L["YouTube: "] = true
	L["Contact: "] = true 

	L["_ui_description_"] = "%s is a full user interface for World of Warcraft, meant as a replacement to the Blizzard default UI. It supports screen resolutions down to 1280 pixels in width, but a minimum of 1440 pixels is recommended.|n|nThe UI is written and maintained by Lars Norberg, who plays the Feral Druid %s located at the Draenor EU PvE Realm, Alliance side."
	
	L["_install_guide_"] = "In a few small steps you'll be guided through the installation process of some of the modules in this user interface. You can always change the options at a later time from the options menu available from the main game menu, or by typing |cFF4488FF/gui|r."
	
	L["_ui_credited_"] = "Rogueh(frFR), Banz Lin(enCN, enTW, zhCN, zhTW), UnoPrata(ptBR) and Kkthnxbye(compability)"

	L["_ui_copyright_"] = "Copyright (c) 2012, Lars '%s' Norberg. All rights reserved."

	-- nothing to localize on the following, I just put them here for easy reference
	L["_ui_web_"] = "www.friendlydruid.com"
	L["_ui_download_"] = "www.curse.com/addons/wow/guis-gui"
	L["_ui_facebook_"] = "www.facebook.com/goldpawguisgui"
	L["_ui_twitter_"] = "twitter.com/friendlydruid"
	L["_ui_youtube_"] = "www.youtube.com/user/FriendlyDruidTV"
	L["_ui_contact_"] = "goldpaw@friendlydruid.com"
end
