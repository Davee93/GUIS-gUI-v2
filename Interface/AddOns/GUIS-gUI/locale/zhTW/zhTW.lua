local L = LibStub("gLocale-1.0"):NewLocale((select(1, ...)), "zhTW")
if not L then return end

--[[
	All Chinese locales by Banz Lin
]]--

--------------------------------------------------------------------------------------------------
--		Modules
--------------------------------------------------------------------------------------------------
-- ActionBars
do
	L["Layout '%s' doesn't exist, valid values are %s."] = "%s 樣式不存在，錯誤代碼為 %s."
	L["There is a problem with your ActionBars.|nThe user interface needs to be reloaded in order to fix it.|nReload now?"] = "動作列出現問題.|n要修正問題必須重新載入介面.|n現在重新載入?"
	L["<Left-Click> to show additional ActionBars"] = "左鍵點擊顯示額外的動作列"
	L["<Left-Click> to hide this ActionBar"] = "左鍵點擊隱藏此動作列"
end

-- ActionBars: micromenu
do
	L["Achievements"] = "成就"
	L["Character Info"] = "角色資訊"
	L["Customer Support"] = "客服支援"
	L["Dungeon Finder"] = "地城搜尋器"
	L["Dungeon Journal"] = "地城導覽手冊"
	L["Game Menu"] = "遊戲選項"
	L["Guild"] = "公會"
	L["Guild Finder"] = "公會搜尋器"
	L["You're not currently a member of a Guild"] = "你目前並非公會成員"
	L["Player vs Player"] = "PVP"
	L["Quest Log"] = "任務紀錄"
	L["Raid"] = "團隊搜尋器"
	L["Spellbook & Abilities"] = "法術書和技能"
	L["Starter Edition accounts cannot perform that action"] = "體驗帳號無法執行此動作"
	L["Talents"] = "天賦"
	L["This feature becomes available once you earn a Talent Point."] = "你一但獲得天賦點數，才能使用此功能"
end

-- ActionBars: menu
do
	L["ActionBars are banks of hotkeys that allow you to quickly access abilities and inventory items. Here you can activate additional ActionBars and control their behaviors."] = "動作列是一個存放熱鍵的工具列，可讓你更快速地使用技能與物品欄的物品。你可以在這裡啟用額外的動作列並控制它們的功能。"
	L["Secure Ability Toggle"] = "切換技能觸發保險"
	L["When selected you will be protected from toggling your abilities off if accidently hitting the button more than once in a short period of time."] = "若你不慎在短時間內按到按鍵，將防止關閉技能"
	L["Lock ActionBars"] = "鎖定動作列"
	L["Prevents the user from picking up/dragging spells on the action bar. This function can be bound to a function key in the keybindings interface."] = "使玩家無法拖曳動作列上的技能圖示，這項功能可以透過按鍵設定介面來設定對應的快速鍵。"
	L["Pick Up Action Key"] = "拖曳動作鍵"
	L["ALT key"] = "ALT鍵"
	L["Use the \"ALT\" key to pick up/drag spells from locked actionbars."] = "配合「ALT」鍵從鎖定的動作列上拖曳技能圖示"
	L["CTRL key"] = "CTRL鍵"
	L["Use the \"CTRL\" key to pick up/drag spells from locked actionbars."] = "配合「CTRL」鍵從鎖定的動作列上拖曳技能圖示"
	L["SHIFT key"] = "SHIFT鍵"
	L["Use the \"SHIFT\" key to pick up/drag spells from locked actionbars."] = "配合「SHIFT」鍵從鎖定的動作列上拖曳技能圖示"
	L["None"] = "無"
	L["No key set."] = "未設定按鍵"
	L["Visible ActionBars"] = "顯示動作列"
	L["Show the rightmost side ActionBar"] = "右方動作列"
	L["Show the leftmost side ActionBar"] = "右方動作列2"
	L["Show the secondary ActionBar"] = "顯示第二動作列"
	L["Show the third ActionBar"] = "顯示第三動作列"
	L["Show the Pet ActionBar"] = "顯示寵物動作列"
	L["Show the Shapeshift/Stance/Aspect Bar"] = "顯示姿態列"
	L["Show the Totem Bar"] = "顯示圖騰動作列"
	L["Show the Micro Menu"] = "顯示微型選單"
	L["ActionBar Layout"] = "動作列樣式"
	L["Sort ActionBars from top to bottom"] = "從上到下排列動作列"
	L["This displays the main ActionBar on top, and is the default behavior of the UI. Disable to display the main ActionBar at the bottom."] = "在上方顯示主要動作列，這是UI預設，取消選擇則顯示在下方。"
	L["Button Size"] = "按鈕大小"
	L["Choose the size of the buttons in your ActionBars"] = "設定動作列按鈕的大小"
	L["Sets the size of the buttons in your ActionBars. Does not apply to the TotemBar."] = "設定動作列按鈕的大小，但此設定並不套用到圖騰動作列上"
end

-- ActionBars: Install
do
	L["Select Visible ActionBars"] = "選擇要顯示的動作列"
	L["Here you can decide what actionbars to have visible. Most actionbars can also be toggled by clicking the arrows located next to their edges which become visible when hovering over them with the mouse cursor. This does not work while engaged in combat."] = "你可以選擇要顯示的動作列，透過用滑鼠游標懸停在動作列旁，並點擊顯示的箭頭切換。戰鬥中不可使用此功能。"
	L["You can try out different layouts before proceding!"] = "繼續下一步前，你可以嘗試不同樣式!"

	L["Toggle Bar 2"] = "第二動作列"
	L["Toggle Bar 3"] = "第三動作列"
	L["Toggle Bar 4"] = "第四動作列"
	L["Toggle Bar 5"] = "第五動作列"
	L["Toggle Pet Bar"] = "寵物動作列"
	L["Toggle Shapeshift/Stance/Aspect Bar"] = "姿態列"
	L["Toggle Totem Bar"] = "圖騰動作列"
	L["Toggle Micro Menu"] = "微型選單列"
	
	L["Select Main ActionBar Position"] = "選擇主要動作列位置"
	L["When having multiple actionbars visible, do you prefer to have the main actionbar displayed at the top or at the bottom? The default setting is top."] = "當有多個動作列顯示時，你希望主要動作列顯示在上方或下方? 預設是上方。"
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
	L["ActionButtons are buttons allowing you to use items, cast spells or run a macro with a single keypress or mouseclick. Here you can decide upon the styling and visible elements of your ActionButtons."] = "動作按鈕允許您透過單一按鍵或是滑鼠點擊使用物品，法術或執行一個巨集，在這裡你可以決定動作按鈕的視覺樣式。"
	L["Button Styling"] = "按鈕樣式"
	L["Button Text"] = "按鈕文字"
	L["Show hotkeys on the ActionButtons"] = "在按鈕上顯示熱鍵"
	L["Show Keybinds"] = "顯示按鍵綁定"
	L["This will display your currently assigned hotkeys on the ActionButtons"] = "這會在按鈕上顯示你目前綁定的熱鍵"
	L["Show macro names on the ActionButtons"] = "在按鈕上顯示巨集名稱"
	L["Show Names"] = "顯示巨集"
	L["This will display the names of your macros on the ActionButtons"] = "這會在按鈕上顯示巨集名稱"
	L["Show gloss layer on ActionButtons"] = "在按鈕上顯示漸層"
	L["Show Gloss"] = "顯示漸層"
	L["This will display the gloss overlay on the ActionButtons"] = "這會在按鈕上顯示漸層"
	L["Show shade layer on ActionButtons"] = "在按鈕上顯示遮罩"
	L["This will display the shade overlay on the ActionButtons"] = "這會在按鈕上顯示遮罩"
	L["Show Shade"] = "顯示遮罩"
	--L["Set amount of gloss"] = true
	--L["Set amount of shade"] = true
end

-- Auras: menu
do
	L["These options allow you to control how buffs and debuffs are displayed. If you wish to change the position of the buffs and debuffs, you can unlock them for movement with |cFF4488FF/glock|r."] = "這些選項可控制增益與減益效果的顯示方式。如果你想移動位置，你可以使用 |cFF4488FF/glock|r 指令解除鎖定。"
	L["Aura Styling"] = "樣式"
	L["Show gloss layer on Auras"] = "在增益減益圖示上顯示漸層"
	L["Show Gloss"] = "顯示漸層"
	L["This will display the gloss overlay on the Auras"] = "這會在增益減益圖示上顯示漸層"
	L["Show shade layer on Auras"] = "在增益減益圖示上顯示遮罩"
	L["This will display the shade overlay on the Auras"] = "這會在增益減益圖示上顯示遮罩"
	L["Show Shade"] = "顯示遮罩"
	L["Time Display"] = "時間顯示"
	L["Show remaining time on Auras"] = "顯示剩餘時間"
	L["Show Time"] = "顯示時間"
	L["This will display the currently remaining time on Auras where applicable"] = "這會顯示目前增益減益剩餘時間"
	L["Show cooldown spirals on Auras"] = "在增益減益圖示上顯示旋轉倒數"
	L["Show Cooldown Spirals"] = "顯示旋轉倒數"
	L["This will display cooldown spirals on Auras to indicate remaining time"] = "這會在增益減益圖示上顯示旋轉倒數"
end

-- Bags
do
	L["Gizmos"] = "小玩意" -- used for "special" things like the toy train set
	L["Equipment Sets"] = "自訂套裝" -- used for the stored equipment sets
	L["New Items"] = "新物品" -- used for the unsorted new items category in the bags
	L["Click to sort"] = "點擊排序"
	L["<Left-Click to toggle display of the Bag Bar>"] = "<左鍵點擊切換顯示背包列>"
	L["<Left-Click to open the currency frame>"] = "<左鍵點擊顯示貨幣面版>"
	L["<Left-Click to open the category selection menu>"] = "<左鍵點擊開啟分類選單>"
	L["<Left-Click to search for items in your bags>"] = "<左鍵點擊搜尋背包物品>"
	L["Close all your bags"] = "關閉所有背包"
	L["Close this category and keep it hidden"] = "關閉此分類並隱藏"
	L["Close this category and show its contents in the main container"] = "關閉此分類並將它所有物品顯示在主分類中"
end

-- Bags: menus 
do
	L["A character can store items in its backpack, bags and bank. Here you can configure the appearance and behavior of these."] = "每個人物可以將物品存放在背包或銀行，這裡你可以設定背包的外觀和行為。"
	L["Container Display"] = "顯示背包"
	L["Show this category and its contents"] = "顯示此分類和它的物品"
	L["Hide this category and all its contents completely"] = "隱藏此分類和它的物品"
	L["Bypass"] = "略過"
	L["Hide this category, and display its contents in the main container instead"] = "隱藏此分類並將它所有物品顯示在主分類中"
	L["Choose the minimum item quality to display in this category"] = "選擇此分類要顯示的最小物品品質"
	L["Bag Width"] = "背包寬度"
	L["Sets the number of horizontal slots in the bag containers. Does not apply to the bank."] = "設定背包水平物品數量，此設定不會套用到銀行。"
	L["Bag Scale"] = "大小比例"
	L["Sets the overall scale of the bags"] = "設定背包整體大小比例"
	L["Restack"] = "重新堆疊"
	L["Automatically restack items when opening your bags or the bank"] = "當你打開背包或銀行時自動重新堆疊"
	L["Automatically restack when looting or crafting items"] = "當你獲得戰利品或製作物品時自動重新堆疊"
	L["Sorting"] = "排序"
	L["Sort the items within each container"] = "排序物品"
	L["Sorts the items inside each container according to rarity, item level, name and quanity. Disable to have the items remain in place."] = "依據物品稀有程度、等級、名稱、數量排序。取消則不排序"
	L["Compress empty bag slots"] = "壓縮背包可用空間"
	L["Compress empty slots down to maximum one row of each type."] = "壓縮背包最多顯示一行可用空間"
	L["Lock the bags into place"] = "鎖定背包"
	L["Slot Button Size"] = "儲存格大小"
	L["Choose the size of the slot buttons in your bags."] = "設定背包儲存格的大小"
	L["Sets the size of the slot buttons in your bags. Does not affect the overall scale."] = "設定背包儲存格大小，此設定不覆蓋背包整體大小比例設定值"
	L["Bag scale"] = "大小比例"
	L["Button Styling"] = "儲存格樣式"
	L["Show gloss layer on buttons"] = "在儲存格上顯示漸層"
	L["Show Gloss"] = "顯示漸層"
	L["This will display the gloss overlay on the buttons"] = "這會在儲存格上顯示漸層"
	L["Show shade layer on buttons"] = "在儲存格上顯示遮罩"
	L["This will display the shade overlay on the buttons"] = "這會在儲存格上顯示遮罩"
	L["Show Shade"] = "顯示遮罩"
	L["Show Durability"] = "顯示耐久度"
	L["This will display durability on damaged items in your bags"] = "這會在物品上顯示耐久度"
	L["Color unequippable items red"] = "將無法裝備物品顯示成紅色"
	L["This will color equippable items in your bags that you are unable to equip red"] = "這會將你背包裡你無法裝備的物品顯示成紅色"
	L["Apply 'All In One' Layout"] = "套用整合樣式背包"
	L["Click here to automatically configure the bags and bank to be displayed as large unsorted containers."] = "點擊此處自動將背包及銀行設定成顯示成整合樣式背包"
	L["The bags can be configured to work as one large 'all-in-one' container, with no categories, no sorting and no empty space compression. If you wish to have that type of layout, click the button:"] = "背包可設定成無分類、無排序、無空間壓縮之整合樣式背包，如果你想要這種樣式背包，點擊這個按鈕："
	L["The 'New Items' category will display newly acquired items if enabled. Here you can set which categories and rarities to include."] = "如果啟用此設定，新獲得的物品會顯示在新物品分類，你可以設定要包含哪種類別及稀有程度。"
	L["Minimum item quality"] = "最低物品品質"
	L["Choose the minimum item rarity to be included in the 'New Items' category."] = "選擇在新物品類別中要顯示的最低物品品質"
end

-- Bags: Install
do
	L["Select Layout"] = "選擇樣式"
	L["The %s bag module has a variety of configuration options for display, layout and sorting."] = "%s 背包模組有不同顯示樣式及排序設定選項。"
	L["The two most popular has proven to be %s's default layout, and the 'All In One' layout."] = "兩種常用模式：預設的 %s 背包及整合式背包"
	L["The 'All In One' layout features all your bags and bank displayed as singular large containers, with no categories, no sorting and no empty space compression. This is the layout for those that prefer to sort and control things themselves."] = "整合模式將你身上及銀行所有包包整合成一超大包包，不做分類、不排序、不壓縮空格，此模式是給喜歡自己排列及控制物品位置的玩家。"
	L["%s's layout features the opposite, with all categories split into separate containers, and sorted within those containers by rarity, item level, stack size and item name. This layout also compresses empty slots to take up less screen space."] = "%s 模式則相反，將物品分類，每個分類依物品品質、等級、堆疊數量、名稱排序，並壓縮背包空間以節省螢幕空間。"
	L["You can open your bags to test out the different layouts before proceding!"] = "繼續下一步前，你可以開啟背包測試不同樣式!"
	L["Apply %s's Layout"] = "套用 %s 樣式"
end

-- Bags: chat commands
do
	L["Empty bag slots will now be compressed"] = "背包空間將會被壓縮"
	L["Empty bag slots will no longer be compressed"] = "背包空間不會被壓縮"
end

-- Bags: restack
do
	L["Restack is already running, use |cFF4488FF/restackbags resume|r if stuck"] = "重新堆疊已在執行，如果無動作，使用 |cFF4488FF/restackbags resume|r 指令"
	L["Resuming restack operation"] = "重啟重新堆疊作業"
	L["No running restack operation to resume"] = "不，執行重新堆疊作業"
	L["<Left-Click to restack the items in your bags>"] = "<左鍵點擊重新堆疊物品>"
	L["<Left-Click to restack the items in your bags>|n<Right-Click for options>"] = "<左鍵點擊重新堆疊物品>|n<右鍵開啟選單>"
end

-- Castbars: menu
do
	L["Here you can change the size and visibility of the on-screen castbars. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "你可以改變施法條的大小及外觀，如果你想改變施法條的位置，你可以使用 |cFF4488FF/glock|r 指令解除鎖定"
	L["Show the player castbar"] = "顯示玩家施法條"
	L["Show for tradeskills"] = "顯示專業技能"
	L["Show the pet castbar"] = "顯示寵物施法條"
	L["Show the target castbar"] = "顯示目標施法條"
	L["Show the focus target castbar"] = "顯示專注目標施法條"
	L["Set Width"] = "寬度設定"
	L["Set the width of the bar"] = "設定施法條的寬度"
	L["Set Height"] = "高度設定"
	L["Set the height of the bar"] = "設定施法條的高度"
end

-- Chat: timestamp settings tooltip (http://www.lua.org/pil/22.1.html)
do
	L["|cFFFFD100%a|r abbreviated weekday name (e.g., Wed)"] = "|cFFFFD100%a|r 星期縮寫 (e.g., Wed)"
	L["|cFFFFD100%A|r full weekday name (e.g., Wednesday)"] = "|cFFFFD100%A|r 星期全名 (e.g., Wednesday)"
	L["|cFFFFD100%b|r abbreviated month name (e.g., Sep)"] = "|cFFFFD100%b|r 月份縮寫 (e.g., Sep)"
	L["|cFFFFD100%B|r full month name (e.g., September)"] = "|cFFFFD100%B|r 月份全名 (e.g., September)"
	L["|cFFFFD100%c|r date and time (e.g., 09/16/98 23:48:10)"] = "|cFFFFD100%c|r 日期與時間 (e.g., 09/16/98 23:48:10)"
	L["|cFFFFD100%d|r day of the month (16) [01-31]"] = "|cFFFFD100%d|r 日期 (16) [01-31]"
	L["|cFFFFD100%H|r hour, using a 24-hour clock (23) [00-23]"] = "|cFFFFD100%H|r 小時, 24時制 (23) [00-23]"
	L["|cFFFFD100%I|r hour, using a 12-hour clock (11) [01-12]"] = "|cFFFFD100%I|r 小時, 12時制 (11) [01-12]"
	L["|cFFFFD100%M|r minute (48) [00-59]"] = "|cFFFFD100%M|r 分 (48) [00-59]"
	L["|cFFFFD100%m|r month (09) [01-12]"] = "|cFFFFD100%m|r 月份數字 (09) [01-12]"
	L["|cFFFFD100%p|r either 'am' or 'pm'"] = "|cFFFFD100%p|r 'am' 或 'pm'"
	L["|cFFFFD100%S|r second (10) [00-61]"] = "|cFFFFD100%S|r 秒 (10) [00-61]"
	L["|cFFFFD100%w|r weekday (3) [0-6 = Sunday-Saturday]"] = "|cFFFFD100%w|r weekday (3) [0-6 = Sunday-Saturday]"
	L["|cFFFFD100%x|r date (e.g., 09/16/98)"] = "|cFFFFD100%x|r 日期 (e.g., 09/16/98)"
	L["|cFFFFD100%X|r time (e.g., 23:48:10)"] = "|cFFFFD100%X|r 時間 (e.g., 23:48:10)"
	L["|cFFFFD100%Y|r full year (1998)"] = "|cFFFFD100%Y|r 四位數年份 (1998)"
	L["|cFFFFD100%y|r two-digit year (98) [00-99]"] = "|cFFFFD100%y|r 二位數年份 (98) [00-99]"
	L["|cFFFFD100%%|r the character `%´"] = "|cFFFFD100%%|r 字元 `%´" -- 'character' here refers to a letter or number, not a game character...
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
	L["Guild XP"] = "公會經驗值" -- Guild Experience
	L["HK"] = "榮譽擊殺" -- Honorable Kill
	L["XP"] = "經驗值" -- Experience
end

-- Chat: menu
do
	L["Here you can change the settings of the chat windows and chat bubbles. |n|n|cFFFF0000If you wish to change visible chat channels and messages within a chat window, background color, font size, or the class coloring of character names, then Right-Click the chat tab located above the relevant chat window instead.|r"] = "你可以改變聊天視窗及對話泡泡的設定。 |n|n|cFFFF0000如果你想要改變聊天視窗所顯示的頻道、訊息、背景、字體大小和職業顏色，右鍵點擊聊天視窗上方的頁籤。|r"
	L["Enable sound alerts when receiving whispers or private Battle.net messages."] = "當收到密語或是 Battle.net 訊息時啟用聲音警示"

	L["Chat Display"] = "顯示設定"
	L["Abbreviate channel names."] = "頻道名稱縮寫"
	L["Abbreviate global strings for a cleaner chat."] = "通用名稱縮寫"
	L["Display brackets around player- and channel names."] = "將玩家及頻道名稱括號顯示"
	L["Use emoticons in the chat"] = "聊天視窗中使用表情符號"
	L["Auto-align the text depending on the chat window's position."] = "依聊天視窗窗位置自動對齊文字"
	L["Auto-align the main chat window to the bottom left panel/corner."] = "自動將主要視窗對齊左下方面版"
	L["Auto-size the main chat window to match the bottom left panel size."] = "自動縮放主要視窗大小符合左下方面版大小"

	L["Timestamps"] = "時間標記"
	L["Show timestamps."] = "顯示時間標記"
	L["Timestamp color:"] = "時間標記顏色："
	L["Timestamp format:"] = "時間標記格式"

	L["Chat Bubbles"] = "對話泡泡"
	L["Collapse chat bubbles"] = "關閉對話泡泡"
	L["Collapses the chat bubbles to preserve space, and expands them on mouseover."] = "收起對話泡泡以節省空間，將游標移至上方則展開"
	L["Display emoticons in the chat bubbles"] = "在對話泡泡中顯示表情符號"

	L["Loot Window"] = "戰利品視窗"
	L["Create 'Loot' Window"] = "建立戰利品視窗"
	L["Enable the use of the special 'Loot' window."] = "啟用戰利品視窗"
	L["Maintain the channels and groups of the 'Loot' window."] = "維持戰利品視窗的頻道和群組"
	L["Auto-align the 'Loot' chat window to the bottom right panel/corner."] = "自動將戰利品視窗對齊右下方面版"
	L["Auto-size the 'Loot' chat window to match the bottom right panel size."] = "自動縮放戰利品視窗大小符合右下方面版大小"
end

-- Chat: Install
do
	L["Public Chat Window"] = "公共頻道視窗"
	L["Public chat like Trade, General and LocalDefense can be displayed in a separate tab in the main chat window. This will keep your main chat window free from intrusive spam, while still having all the relevant public chat available. Do you wish to do so now?"] = "公共頻道窗就如同交易、一般及本地防務頻道一樣可以個別顯示在聊天視窗的頁籤中。可避免垃圾訊息佔據你主要的聊天視窗，同時仍可以使用所有相關頻道。你想要這樣嗎?"

	L["Loot Window"] = "戰利品視窗"
	L["Information like received loot, crafted items, experience, reputation and honor gains as well as all currencies and similar received items can be displayed in a separate chat window. Do you wish to do so now?"] = "就像獲得戰利品、製作的物品、經驗、聲望及榮譽值以及所有貨幣和收到類似物品可以顯示在單一視窗，你希望要這樣做嗎?"
	
	L["Initial Window Size & Position"] = "重置視窗大小及位置"
	L["Your chat windows can be configured to match the unitframes and the bottom UI panels in size and position. Do you wish to do so now?"] = "聊天視窗可以設置成對齊單位框架和符合下面UI面版的大小及位置，你希望這樣做嗎?"
	L["This will also dock any additional chat windows."] = "這會鎖定其他聊天視窗"	
	
	L["Window Auto-Positioning"] = "自動調整視窗位置"
	L["Your chat windows will slightly change position when you change UI scale, game window size or screen resolution. The UI can maintain the position of the '%s' and '%s' chat windows whenever you log in, reload the UI or in any way change the size or scale of the visible area. Do you wish to activate this feature?"] = "當你改變UI的縮放比例、遊戲視窗大小或是螢幕解析度，聊天視窗會稍微改變位置，每當你登入、重載介面或是以任何方式改變可視區域的大小或縮放比例時時，UI可以維持 %s 和 %s 視窗的位置。你希望啟用這項功能嗎?"
	
	L["Window Auto-Sizing"] = "自動縮放視窗"
	L["Would you like the UI to maintain the default size of the chat frames, aligning them in size to visually fit the unitframes and bottom UI panels?"] = "你希望UI維持聊天視窗的預設大小，調整它們的大小並對齊單位框架和下面的UI面版?"
	
	L["Channel & Window Colors"] = "頻道及視窗顏色"
	L["Would you like to change chatframe colors to what %s recommends?"] = "你希望將聊天視窗的顏色設定成 %s 建議值嗎?"
end

-- Combat
do
	L["dps"] = true -- Damage Per Second
	L["hps"] = true -- Healing Per Second
	L["tps"] = true -- Threat Per Second
	L["Last fight lasted %s"] = "上次戰鬥持續 %s"
	L["You did an average of %s%s"] = "平均 %s%s"
	L["You are overnuking!"] = "火力過大!"
	L["You have aggro, stop attacking!"] = "仇恨值過高，停止攻擊!"
	L["You are tanking!"] = "坦怪中"
	L["You are losing threat!"] = "喪失怪物仇恨中!"
	L["You've lost the threat!"] = "已無仇恨值!"
end

-- Combat: menu
do
	L["Simple DPS/HPS Meter"] = "簡易 DPS/HPS 計量器"
	L["Enable simple DPS/HPS meter"] = "啟用簡易 DPS/HPS 計量器"
	L["Show DPS/HPS when you are solo"] = "單人時顯示 DPS/HPS"
	L["Show DPS/HPS when you are in a PvP instance"] = "PvP時顯示 DPS/HPS"
	L["Display a simple verbose report at the end of combat"] = "戰鬥結束時顯示簡易報告"
	L["Minimum DPS to display: "] = "顯示 DPS 最少："
	L["Minimum combat duration to display: "] = "顯示戰鬥時間最少："
	L["Simple Threat Meter"] = "簡易威脅計量器"
	L["Enable simple Threat meter"] = "啟用簡易威脅計量器"
	L["Use the Focus target when it exists"] = "計算專注目標"
	L["Enable threat warnings"] = "啟用威脅警示"
	L["Show threat when you are solo"] = "單人時顯示威脅"
	L["Show threat when you are in a PvP instance"] = "PvP時顯示威脅"
	L["Show threat when you are a healer"] = "當你是補職時顯示威脅"
	L["Enable simple scrolling combat text"] = "啟用簡易捲動式戰鬥文字"
end

-- Combatlog
do
	L["GUIS"] = true -- the visible name of our custom combat log filter, used to identify it
	L["Show simplified messages of actions done by you and done to you."] = "顯示你所做過及別人對你做過的簡易訊息" -- the description of this filter
end

-- Combatlog: menu
do
	L["Maintain the settings of the GUIS filter so that they're always the same"] = "保留 GUIS 過濾器的設定"
	L["Keep only the GUIS and '%s' quickbuttons visible, with GUIS at the start"] = "GUIS 啟動時顯示 GUIS 及 %s 快速鍵"
	L["Autmatically switch to the GUIS filter when you log in or reload the UI"] = "當你登入或是重新載入介面時，自動切換至 GUIS 過濾器。"
	L["Autmatically switch to the GUIS filter whenever you see a loading screen"] = "每當進入載入畫面時，自動切換至 GUIS 過濾器。"
	L["Automatically switch to the GUIS filter when entering combat"] = "每當進入戰鬥時，自動切換至 GUIS 過濾器。"
end

-- Loot
do
	L["BoE"] = "裝綁" -- Bind on Equip
	L["BoP"] = "拾綁" -- Bind on Pickup
end

-- Merchant
do
	L["Selling Poor Quality items:"] = "販售粗糙等級物品"
	L["-%s|cFF00DDDDx%d|r %s"] = true -- nothing to localize in this one, unless you wish to change the formatting
	L["Earned %s"] = "獲得：%s"
	L["You repaired your items for %s"] = "修理裝備：%s"
	L["You repaired your items for %s using Guild Bank funds"] = "使用公會銀行修理裝備：%s"
	L["You haven't got enough available funds to repair!"] = "你沒有足夠金幣修理裝備!"
	L["Your profit is %s"] = "淨賺：%s"
	L["Your expenses are %s"] = "費用：%s"
	L["Poor Quality items will now be automatically sold when visiting a vendor"] = "開啟自動販售粗糙等級物品"
	L["Poor Quality items will no longer be automatically sold"] = "關閉自動販售粗糙等級物品"
	L["Your items will now be automatically repaired when visiting a vendor with repair capabilities"] = "開啟自動修理裝備"
	L["Your items will no longer be automatically repaired"] = "關閉自動修理裝備"
	L["Your items will now be repaired using the Guild Bank if the options and the funds are available"] = "開啟自動使用公會銀行修理裝備"
	L["Your items will now be repaired using your own funds"] = "使用自己金幣修理裝備"
	L["Detailed reports for autoselling of Poor Quality items turned on"] = "啟用自動販售粗糙等級物品詳細報告"
	L["Detailed reports for autoselling of Poor Quality items turned off, only summary will be shown"] = "關閉自動販售粗糙物品報告，只顯示總額"
	L["Toggle autosell of Poor Quality items"] = "啟用自動販售粗糙物品"
	L["Toggle display of detailed sales reports"] = "啟用販售詳細報告"
	L["Toggle autorepair of your armor"] = "啟用自動修理裝備"
	L["Toggle Guild Bank repairs"] = "啟用公會銀行修理裝備"
	L["<Alt-Click to buy the maximum amount>"] = "<Alt 點擊以購買最大數量>"
end

-- Minimap
do
	L["Calendar"] = "行事曆"
	L["New Event!"] = "新事件"
	L["New Mail!"] = "新郵件"
	
	L["Raid Finder"] = "團隊搜尋器"
	
	L["(Sanctuary)"] = "(避難所)"
	L["(PvP Area)"] = "(PVP區域)"
	L["(%s Territory)"] = "(%s 領地)"
	L["(Contested Territory)"] = "(爭奪中的領地)"
	L["(Combat Zone)"] = "(戰鬥區域)"
	L["Social"] = "好友名單"
end

-- Minimap: menu
do
	L["The Minimap is a miniature map of your closest surrounding areas, allowing you to easily navigate as well as quickly locate elements such as specific vendors, or a herb or ore you are tracking. If you wish to change the position of the Minimap, you can unlock it for movement with |cFF4488FF/glock|r."] = "小地圖是顯示你周邊地區的小型地圖，讓您輕鬆導航以及快速定位如商人，或你正追踪的藥草或礦石。如果你想改變目前小地圖的位置，你可以使用 |cFF4488FF/glock|r 指令解除鎖定。"
	L["Display the clock"] = "顯示時鐘"
	L["Display the current player coordinates on the Minimap when available"] = "在小地圖上顯示目前所在座標"
	L["Use the Mouse Wheel to zoom in and out"] = "使用滑鼠滾輪縮放"
	L["Display the difficulty of the current instance when hovering over the Minimap"] = "當滑鼠游標移至小地圖上方，顯示目前副本困難度"
	L["Display the shortcut menu when clicking the middle mouse button on the Minimap"] = "在小地圖上按滑鼠中鍵顯示快速選單"
	L["Rotate Minimap"] = "旋轉小地圖"
	L["Check this to rotate the entire minimap instead of the player arrow."] = "勾選此選項來旋轉整個小地圖而不是玩家箭頭"
end

-- Nameplates: menu
do
	L["Nameplates are small health- and castbars visible over a character or NPC's head. These options allow you to control which Nameplates are visible within the game field while you play."] = "單位名條在人物或NPC頭上顯示血量及施法條，這些選項可控制你想在遊戲主畫面中顯示的名稱。"
	L["Automatically enable nameplates based on your current specialization"] = "根據你的天賦自動顯示NPC"
	L["Automatically enable friendly nameplates for repeatable quests that require them"] = "自動顯示任務NPC"
	L["Only show friendly nameplates when engaged in combat"] = "戰鬥中只顯示友方單位"
	L["Only show enemy nameplates when engaged in combat"] = "戰鬥中只顯示敵方單位"
	L["Use a blacklist to filter out certain nameplates"] = "使用黑名單過濾單位名條"
	L["Display character level"] = "顯示人物等級"
	L["Hide for max level characters when you too are max level"] = "當你滿級時隱藏人物最高等級"
	L["Display character names"] = "顯示人物名稱"
	L["Display combo points on your target"] = "顯示你目標的連擊點數"
	
	L["Nameplate Motion Type"] = "名條排列類型"
	L["Overlapping Nameplates"] = "重疊名條"
	L["Stacking Nameplates"] = "堆疊名條"
	L["Spreading Nameplates"] = "分散名條"
	L["This method will allow nameplates to overlap."] = "這種方式會讓名條重疊"
	L["This method avoids overlapping nameplates by stacking them vertically."] = "這種方式會讓名條呈垂直堆疊以避免重疊"
	L["This method avoids overlapping nameplates by spreading them out horizontally and vertically."] = "這種方式會讓名條呈水平和垂直分散以避免重疊"
	
	L["Friendly Units"] = "友方單位"
	L["Friendly Players"] = "友方玩家"
	L["Turn this on to display Unit Nameplates for friendly units."] = "開啟此選項可顯示友方單位的名條"
	L["Enemy Units"] = "敵方單位"
	L["Enemy Players"] = "敵方玩家"
	L["Turn this on to display Unit Nameplates for enemies."] = "開啟此選項可顯示敵方單位的名條"
	L["Pets"] = "寵物"
	L["Turn this on to display Unit Nameplates for friendly pets."] = "開啟此選項可顯示友方寵物的名條"
	L["Turn this on to display Unit Nameplates for enemy pets."] = "開啟此選項可顯示敵方寵物的名條"
	L["Totems"] = "圖騰"
	L["Turn this on to display Unit Nameplates for friendly totems."] = "開啟此選項可顯示友方圖騰的名條"
	L["Turn this on to display Unit Nameplates for enemy totems."] = "開啟此選項可顯示敵方圖騰的名條"
	L["Guardians"] = "守護者"
	L["Turn this on to display Unit Nameplates for friendly guardians."] = "開啟此選項可顯示友方守護者的名條"
	L["Turn this on to display Unit Nameplates for enemy guardians."] = "開啟此選項可顯示敵方守護者的名條"
end

-- Panels
do
	L["<Left-Click to open all bags>"] = "<左鍵點擊開啟所有背包>"
	L["<Right-Click for options>"] = "<右鍵開啟選項>"
	L["No Guild"] = "無公會"
	L["New Mail!"] = "有新郵件"
	L["No Mail"] = "無新郵件"
	L["Total Usage"] = "插件記憶體："
	L["Tracked Currencies"] = "追蹤的貨幣"
	L["Additional AddOns"] = "額外的插件"
	L["Network Stats"] = "網路"
	L["World latency:"] = "世界延遲："
	L["World latency %s:"] = "世界延遲 %s："
	L["(Combat, Casting, Professions, NPCs, etc)"] = "(戰鬥、施法、專業、NPC等)"
	L["Realm latency:"] = "本地延遲："
	L["Realm latency %s:"] = "本地延遲 %s："
	L["(Chat, Auction House, etc)"] = "(聊天、拍賣場等)"
	L["Display World Latency %s"] = "顯示世界延遲 %s"
	L["Display Home Latency %s"] = "顯示本地延遲 %s"
	L["Display Framerate"] = "顯示幀數"

	L["Incoming bandwidth:"] = "下載頻寬"
	L["Outgoing bandwidth:"] = "上傳頻寬"
	L["KB/s"] = true
	L["<Left-Click for more>"] = "<左鍵點擊顯示更多資訊>"
	L["<Left-Click to toggle Friends pane>"] = "<左鍵顯示好友名單>"
	L["<Left-Click to toggle Guild pane>"] = "<左鍵點及開啟公會面版>"
	L["<Left-Click to toggle Reputation pane>"] = "<左鍵點及開啟聲望面版>"
	L["<Left-Click to toggle Currency frame>"] = "<左鍵點及開啟貨幣面版>"
	L["%d%% of normal experience gained from monsters."] = "從怪物身上獲得平時 %d%% 的經驗值 "
	L["You should rest at an Inn."] = "你必須在旅店休息"
	L["Hide copper when you have at least %s"] = "隱藏銅幣顯示當超過 %s"
	L["Hide silver and copper when you have at least %s"] = "隱藏銅幣及銀幣當超過 %s"
	L["Invite a member to the Guild"] = "邀請加入公會"
	L["Change the Guild Message Of The Day"] = "修改公會今日訊息"
	L["Select currencies to always watch:"] = "選擇要顯示的貨幣"
	L["Select how your gold is displayed:"] = "選擇如何顯示你的金幣："
	
	L["No container equipped in slot %d"] = "插槽 %d 無裝備任何背包"
end

-- Panels: menu
do
	L["UI Panels are special frames providing information about the game as well allowing you to easily change settings. Here you can configure the visibility and behavior of these panels. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "UI面版是提供遊戲資訊的特殊框架，以及讓你容易地改變設定。這個選項可以讓你設定這些面版的外觀和行為，如果你想改變它的位置，你可以使用 |cFF4488FF/glock|r 指令解除鎖定。"
end

-- Quest: menu
do
	L["QuestLog"] = "任務紀錄"
	L["These options allow you to customize how game objectives like Quests and Achievements are displayed in the user interface. If you wish to change the position of the ObjectivesTracker, you can unlock it for movement with |cFF4488FF/glock|r."] = "這些選項讓你可以自行設定如任務或成就等遊戲目標在使用者介面中顯示的方式，如果你想要改變任務追蹤的位置，你可以使用 |cFF4488FF/glock|r 指令解除鎖定。"
	L["Display quest level in the QuestLog"] = "顯示任務等級"
	L["Objectives Tracker"] = "任務追蹤"
	L["Autocollapse the WatchFrame"] = "自動隱藏任務追蹤視窗"
	L["Autocollapse the WatchFrame when a boss unitframe is visible"] = "出現首領框架時自動隱藏任務追蹤視窗"
	L["Automatically align the WatchFrame based on its current position"] = "依任務追蹤視窗目前位置自動對齊"
	L["Align the WatchFrame to the right"] = "任務追蹤視窗靠右對齊"
end

-- Tooltips
do
	L["Here you can change the settings for the game tooltips"] = "你可以改變遊戲提示設定"
	L["Hide while engaged in combat"] = "戰鬥中隱藏"
	L["Show values on the tooltip healthbar"] = "顯示血量數值"
	L["Show player titles in the tooltip"] = "顯示玩家頭銜"
	L["Show player realms in the tooltip"] = "顯示玩家伺服器類型"
	L["Positioning"] = "定位"
	L["Choose what tooltips to anchor to the mouse cursor, instead of displaying in their default positions:"] = "選擇哪些提示要啟用滑鼠游標跟隨，而非顯示在預設的位置："
	L["All tooltips will be displayed in their default positions."] = "在預設的位置顯示所有提示"
	L["All tooltips will be anchored to the mouse cursor."] = "所有提示啟用滑鼠游標跟隨"
	L["Only Units"] = "只有單位框架"
	L["Only unit tooltips will be anchored to the mouse cursor, while other tooltips will be displayed in their default positions."] = "只有單位框架啟用滑鼠游標跟隨，其他則顯示在預設的位置"
end

-- world status: menu
do
	L["Here you can set the visibility and behaviour of various objects like the XP and Reputation Bars, the Battleground Capture Bars and more. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "這個選項可以設定顯示經驗條、聲望條、戰場等物件，如果你想改變它的位置，你可以使用 |cFF4488FF/glock|r 指令解除鎖定。"
	L["StatusBars"] = "狀態列"
	L["Show the player experience bar."] = "顯示玩家經驗條"
	L["Show when you are at your maximum level or have turned off experience gains."] = "當你滿級或是不再獲得經驗值時顯示"
	L["Show the currently tracked reputation."] = "顯示目前追蹤的聲望"
	L["Show the capturebar for PvP objectives."] = "顯示 PVP 物品的佔領狀態列"
end

-- UnitFrames
do
	L["Due to entering combat at the worst possible time the UnitFrames were unable to complete the layout change.|nPlease reload the user interface with |cFF4488FF/rl|r to complete the operation!"] = "因進入戰鬥導致無法完成單位框架設定 |n請使用 |cFF4488FF/rl|r 重新載入使用者介面。"
end

-- UnitFrames: oUF_Trinkets
do
	L["Trinket ready: "] = "飾品就緒："
	L["Trinket used: "] = "飾品已使用："
	L["WotF used: "] = "亡靈意志已使用："
end

-- UnitFrames: menu
do
	L["These options can be used to change the display and behavior of unit frames within the UI. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "這些選項可以用來設定單位框架的顯示方式，如果你想要改變單位框架的位置，你可以使用 |cFF4488FF/glock|r 指令解除鎖定。"

	L["Choose what unit frames to load"] = "選擇載入哪種單位框架"
	L["Enable Party Frames"] = "啟用隊伍框架"
	L["Enable Arena Frames"] = "啟用競技場框架"
	L["Enable Boss Frames"] = "啟用首領框架"
	L["Enable Raid Frames"] = "啟用團隊框架"
	L["Enable MainTank Frames"] = "啟用主坦框架"
	L["ClassBar"] = "職業專屬動作列"
	L["The ClassBar is a larger display of class related information like Holy Power, Runes, Eclipse and Combo Points. It is displayed close to the on-screen CastBar and is designed to more easily track your most important resources."] = "職業專屬動作列顯示職業相關如聖能、符文，蝕星蔽月及連擊點數。它顯示在施法條附近用來更輕鬆地監視你重要的資源。"
	L["Enable ClassBar"] = "啟用職業專屬動作列"
	
	L["Set Focus"] = "專注設定"
	L["Here you can enable and define a mousebutton and optional modifier key to directly set a focus target from clicking on a frame."] = "此處你可以啟用並指定一組滑鼠按鍵及額外的輔助鍵，透過滑鼠點擊設定專注目標。"
	L["Enable Set Focus"] = "啟用專注目標設定"
	L["Enabling this will allow you to quickly set your focus target by clicking the key combination below while holding the mouse pointer over the selected frame."] = "啟用此功能可以讓你使用下列輔助鍵快速地將滑鼠箭頭懸停的目標設定為專注目標"
	L["Modifier Key"] = "輔助鍵"

	L["Enable indicators for HoTs, DoTs and missing buffs."] = "啟用HoTs、DoTs及增益監視器"
	L["This will display small squares on the party- and raidframes to indicate your active HoTs and missing buffs."] = "這會在隊伍及團隊框架上顯示你身上的HoTs、DoTs及增益"

	--L["Auras"] = "光環"
	L["Here you can change the settings for the auras displayed on the player- and target frames."] = "你可以設定如何顯示玩家及目標身上增益減益效果"
	L["Filter the target auras in combat"] = "戰鬥中過濾增益減益效果"
	L["This will filter out auras not relevant to your role from the target frame while engaged in combat, to make it easier to track your own debuffs."] = "戰鬥中過濾與你角色和目標無關的增益減益效果，讓你更容易監視你所施放的法術。"
	L["Desature target auras not cast by the player"] = "將目標身上不是玩家施放的增益減益效果法術去色"
	L["This will desaturate auras on the target frame not cast by you, to make it easier to track your own debuffs."] = "這會將目標身上不是玩家所施放的增益減益效果法術去色，讓你更容易地監視你所施放的法術。"
	L["Texts"] = "文字"
	L["Show values on the health bars"] = "在血量條上顯示數值"
	L["Show values on the power bars"] = "在能量條上顯示數值"
	L["Show values on the Feral Druid mana bar (when below 100%)"] = "當野性德魯伊法力條小於100%，在上面顯示數值"
	
	L["Groups"] = "群組"
	L["Here you can change what kind of group frames are used for groups of different sizes."] = "你可以設定不同群組大小要使用何種群組框架"

	L["5 Player Party"] = "5人隊伍"
	L["Use the same frames for parties as for raid groups."] = "將此框架當作是團隊框架"
	L["Enabling this will show the same types of unitframes for 5 player parties as you currently have chosen for 10 player raids."] = "啟用此選項會將你目前選的10人團隊框架顯示成5人的隊伍框架"
	
	L["10 Player Raid"] = "10人團隊"
	L["Use same raid frames as for 25 player raids."] = "將此框架當作是25人團隊框架"
	L["Enabling this will show the same types of unitframes for 10 player raids as you currently have chosen for 25 player raids."] = "啟用此選項會將你目前選的25人團隊框架顯示成10人的團隊框架"

	L["25 Player Raid"] = "25人團隊"
	L["Automatically decide what frames to show based on your current specialization."] = "自動根據你的天賦決定顯示何種框架"
	L["Enabling this will display the Grid layout when you are a Healer, and the smaller DPS layout when you are a Tank or DPSer."] = "啟用此選項將會自動切換成治療者的Grid版面，或是傷害輸出及坦克的DPS版面"
	L["Use Healer/Grid layout."] = "使用治療者Grid版面"
	L["Enabling this will use the Grid layout instead of the smaller DPS layout for raid groups."] = "啟用此選項將在團隊中使用Grid版面而非DPS版面"
end

-- UnitFrames: GroupPanel
do
	-- party
	L["Show the player along with the Party Frames"] = "在隊伍框架中顯示玩家"
	L["Use Raid Frames instead of Party Frames"] = "使用團隊風格的隊伍框架"
	
	-- raid
	L["Use the grid layout for all Raid sizes"] = "所有團隊都使用 grid 風格"
end


--------------------------------------------------------------------------------------------------
--		FAQ
--------------------------------------------------------------------------------------------------
-- 	Even though most of these strings technically belong to their respective modules,
--	and not the FAQ interface, we still gather them all here for practical reasons.
do
	-- general
	L["FAQ"] = true
	L["Frequently Asked Questions"] = "常見問題"
	L["Clear All Tags"] = "清除所有標籤"
	L["Show the current FAQ"] = "顯示目前FAQ"
	L["Return to the listing"] = "返回清單"
	L["Go to the options menu"] = "移至選單"
	
	-- core
	L["I wish to move something! How can I change frame positions?"] = "我想移動某些東西，我要如何改變框架的位置?"
	L["A lot of frames can be moved to custom positions. You can unlock them all for movement by typing |cFF4488FF/glock|r followed by the Enter key, and lock them with the same command. There are also multiple options available when right-clicking on the overlay of the movable frame."] = "有很多框架可以移到指定的位置，你可以輸入 |cFF4488FF/glock|r 指令並按確認鍵解除鎖定，並使用相同的指令鎖定它們。當你右鍵點擊可移動的框架時也有多種選項可使用。"

	-- actionbars
	L["How do I change the currently active Action Page?"] = "如何切換目前的動作列?"
	L["There are no on-screen buttons to do this, so you will have to use keybinds. You can set the relevant keybinds in the Blizzard keybinding interface."] = "畫面上沒有任何按鈕可供切換，你必須使用快速鍵，你可以在遊戲按鍵設定畫面中設定。"
	L["How can I change the visible actionbars?"] = "如何切換顯示動作列?"
	L["You can toggle most actionbars by clicking the arrows located close to their corners. These arrows become visible when hovering over them with the mouse if you're not currently engaged in combat. You can also toggle the actionbars from the options menu, or by running the install tutorial by typing |cFF4488FF/install|r followed by the Enter key."] = "如果你不在戰鬥中，當你將滑鼠游標懸停在動作列旁，這些箭頭會顯示，你可以點擊動作列角邊的箭頭來切換顯示動作列。你也可以從選單中或是輸入 |cFF4488FF/install|r 指令執行安裝教學來切換動作列。"
	L["How do I toggle the MiniMenu?"] = "如何切換微型選單列?"
	L["The MiniMenu can be displayed by typing |cFF4488FF/showmini|r followed by the Enter key, and |cFF4488FF/hidemini|r to hide it. You can also toggle it from the options menu or by running the install tutorial by typing |cFF4488FF/install|r."] = "輸入 |cFF4488FF/showmini|r 指令顯示微型選單，輸入 |cFF4488FF/hidemini|r 指令則隱藏，你也可以從選單中或是輸入 |cFF4488FF/install|r 指令執行安裝教學來切換微型選單。"
	L["How can I move the actionbars?"] = "如何移動動作列?"
	L["Not all actionbars can be moved, as some are an integrated part of the UI layout. Most of the movable frames in the UI can be unlocked by typing |cFF4488FF/glock|r followed by the Enter key."] = "並非所有的動作列可以被移動，像是一些是UI組成的一部份就不行，UI中大部分可移動的框架可以輸入 |cFF4488FF/glock|r 指令鎖定。"
	
	-- actionbuttons
	L["How can I toggle keybinds and macro names on the buttons?"] = "如何在按鈕上切換顯示快速鍵和巨集名稱?"
	L["You can enable keybind display on the actionbuttons by typing |cFF4488FF/showhotkeys|r followed by the Enter key, and disable it with |cFF4488FF/hidehotkeys|r. Macro names can be toggled with the |cFF4488FF/shownames|r and |cFF4488FF/hidenames|r commands. All settings can also be changed in the options menu."] = "你可以輸入 |cFF4488FF/showhotkeys|r 指令在動作按鈕上顯示熱鍵，|cFF4488FF/hidehotkeys|r 則是關閉顯示。輸入 |cFF4488FF/shownames|r 指令在動作按鈕上顯示巨集名稱，|cFF4488FF/hidenames|r 則是關閉顯示。"
	
	-- auras
	L["How can I change how my buffs and debuffs look?"] = "如何改變增益減益的顯示方式?"
	L["You can change a lot of settings like the time display and the cooldown spiral in the options menu."] = "你可以在選單上改變很多設定如時間顯示以及在圖示上顯示冷卻倒數。"
	L["Sometimes the weapon buffs don't display correctly!"] = "有時候武器效果並未正確顯示!"
	L["Correct. Sadly this is a bug in the tools Blizzard has given to us addon developers, and not something that is easily fixed. You'll simply have to live with it for now."] = "沒錯，可悲的是，這是暴雪提供給我們這些插件開發者的工具的bug，而且不是那麼容易地修正，現在只能這樣。"
	
	-- bags
	L["Sometimes when I choose to bypass a category, not all items are moved to the '%s' container, but some appear in others?"] = "有時候當我選擇略過某個分類時，不是所有物品都會移到 %s 類別，有些則是移到其他類別?"
	L["Some items are put in the 'wrong' categories by Blizzard. Each category in the bag module has its own internal filter that puts these items in their category of they are deemed to belong there. If you bypass this category, the filter is also bypassed, and the item will show up in whatever category Blizzard originally put it in."] = "有些物品是暴雪搞錯分類了，背包模組中每個分類內部都有自己的過濾器，將屬於該分類的物品納入，如果你略過某個分類，也就略過該分類的過濾器，因此該物品會以暴雪原先方式進行分類。"
	L["How can I change what categories and containers I see? I don't like the current layout!"] = "如何改變我所看到的背包及分類的外觀? 我不喜歡目前這樣!"
	L["Categories can be quickly selected from the quickmenu available by clicking at the arrow next to the '%s' or '%s' containers."] = "可以透過點擊 %s 或是 %s 旁邊的箭頭所出現的快速選單來切換分類的顯示方式。"
	L["You can change all the settings in the options menu as well as activate the 'all-in-one' layout easily!"] = "你可以選項設定中改變所有設定，以及啟用整合式背包樣式。"
	L["How can I disable the bags? I don't like them!"] = "如何禁用背包? 我不喜歡它!"
	L["All the modules can be enabled or disabled from within the options menu. You can locate the options menu from the button on the Game Menu, or by typing |cFF4488FF/gui|r followed by the Enter key."] = "從介面選單中可以啟用或是禁用所有模組，你可以在遊戲選單或是輸入 |cFF4488FF/gui|r 指令找到選項。"
	L["I can't close my bags with the 'B' key!"] = "我按 B 鍵無法關閉背包!"
	L["This is because you probably have bound the 'B' key to 'Open All Bags', which is a one way function. To have the 'B' key actually toggle the containers, you need to bind it to 'Toggle Backpack'. The UI can reassign the key for you automatically. Would you like to do so now?"] = "這是因為你已綁定 B 鍵打開所有背包，這是一個單向函數。你需要將 B 鍵綁定切換背包，才能用它切換開啟及關閉。你希望UI自動幫你重新綁定嗎?"
	
	-- castbars
	L["How can I toggle the castbars for myself and my pet?"] = "如何切換顯示我和寵物的施法條?"
	L["The UI features movable on-screen castbars for you, your target, your pet, and your focus target. These bars can be positioned manually by typing |cFF4488FF/glock|r followed by the Enter key. |n|nYou can change their settings, size and visibility in the options menu."] = "UI提供你、你的目標、你的寵物、以及你的專注目標可移動的施法條，輸入 |cFF4488FF/glock|r 可以手動調整位置。|n|n你可以在介面選單中改變它的大小和外觀。"
	
	-- minimap
	L["I can't find the Calendar!"] = "我找不到行事曆!"
	L["You can open the calendar by clicking the middle mouse button while hovering over the Minimap, or by assigning a keybind to it in the Blizzard keybinding interface avaiable from the GameMenu. The Calendar keybind is located far down the list, along with the GUIS keyinds."] = "你可以將滑鼠停在小地圖上，並點擊滑鼠中鍵開啟行事曆，或是在遊戲選單中按鍵設定指定快速鍵。行事曆按鍵設定位在選單底部的 GUIS 按鍵綁定。"
	L["Where can I see the current dungeon- or raid difficulty and size when I'm inside an instance?"] = "當我進入副本時，如何看出目前地城難度或是團隊人數?"
	L["You can see the maximum size of your current group by hovering the cursor over the Minimap while being inside an instance. If you currently have activated Heroic mode, a skull will be visible next to the size display as well."] = "進入副本後，當滑鼠游標停在小地圖上時，你可以看到目前團隊最大人數。如果是英雄模式，同時會在人數旁邊顯示一個骷髏頭。"
	L["How can I move the Minimap?"] = "如何移動小地圖?"
	L["You can manually move the Minimap as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key."] = "你可以輸入 |cFF4488FF/glock|r 指令像移動其他框架一樣手動移動小地圖。"
	
	-- quests
	L["How can I move the quest tracker?"] = "如何移動任務追蹤視窗?"
	L["My actionbars cover the quest tracker!"] = "我的動作列蓋到了任務追蹤視窗!"
	L["You can manually move the quest tracker as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key. If you wish the quest tracker to automatically move in relation to your actionbars, then reset its position to the default. |n|nWhen a frame is unlocked with the |cFF4488FF/glock|r command, you can right click on its overlay and select 'Reset' to return it to its default position. For some frames like the quest tracker, this will allow the UI to decide where it should be put."] = "你可以輸入 |cFF4488FF/glock|r 指令像移動其他框架一樣手動移動任務追蹤視窗。如果你希望任務追蹤視窗自動緊鄰動作列，將它重置成預設值。|n|n當使用 |cFF4488FF/glock|r 指令解除鎖定框架時，你可以右鍵點擊並選擇重置，回到預設位置。對於某些框架如任務追蹤視窗，這個動作會讓UI自行決定要放置的位置。"
	
	-- talents
	L["I can't close the Talent Frame when pressing 'N'"] = "我按 N 鍵無法關閉天賦面版!"
	L["But you can still close it!|n|nYou can close it with the Escacpe key, or the closebutton located in he upper right corner of the Talent Frame.|n|nWhen closing the Talent Frame with the original keybind to toggle it, it becomes 'tainted'. This means that the game considers it to be 'insecure', and you won't be allowed to do actions like for example changing your glyphs. This only happens when closed with the hotkey, not when it's closed by the Escape key or the closebutton.|n|nBy reassigning your Talent Frame keybind to a function that only opens the frame, not toggles it, we have made sure that it gets closed the proper way, and you can continue to change your glyphs as intended."] = "但你仍然可以關掉它!|n|n你可以使用 Esc 鍵或是右上角關閉按鈕關掉它。|n|n當你用原來綁定的按鍵關閉時，遊戲視為是不安全的，而且不允許你執行如改變雕文。這只會發生在使用快速鍵關閉的時候，而非在使用 Esc 鍵或是關閉按鈕的時候。|n|n當綁定只能開啟而非切換天賦面版的按鍵時，我們保證它可以正確地被關閉，而且你可以繼續改變你的雕文。"
	
	-- tooltips
	L["How can I toggle the display of player realms and titles in the tooltips?"] = "如何切換提示中玩家伺服器類型及頭銜的顯示方式?"
	L["You can change most of the tooltip settings from the options menu."] = "你可以在介面選單中改變提示設定"
	
	-- unitframes
	L["My party frames aren't showing!"] = "無法顯示我的隊伍框架!"
	L["My raid frames aren't showing!"] = "無法顯示我的團隊框架!"
	L["You can set a lot of options for the party- and raidframes from within the options menu."] = "你可以在介面選單中設定許多有關隊伍及團隊的設定。"
	
	-- worldmap
	L["Why do the quest icons on the WorldMap disappear sometimes?"] = "為何有時候世界地圖上的任務圖示消失了?"
	L["Due to some problems with the default game interface, these icons must be hidden while being engaged in combat."] = "由於遊戲預設介面的一些問題，這些圖示必須在戰鬥中隱藏。"
end


--------------------------------------------------------------------------------------------------
--		Chat Command List
--------------------------------------------------------------------------------------------------
-- we're doing this in the worst possible manner, just because we can!
do
	local separator = "€€€"
	local cmd = "|cFF4488FF/glock|r - 鎖定/解鎖 框架位置"
	cmd = cmd .. separator .. "|cFF4488FF/greset|r - 重置所有可移動框架位置"
	cmd = cmd .. separator .. "|cFF4488FF/resetbars|r - 重置所有可移動動作列位置"
	cmd = cmd .. separator .. "|cFF4488FF/resetbags|r - 重置背包位置"
	cmd = cmd .. separator .. "|cFF4488FF/scalebags|r X - 設定背包縮放比例，X 的範圍為 1.0 到 2.0"
	cmd = cmd .. separator .. "|cFF4488FF/compressbags|r - 切換壓縮空的背包格子"
	cmd = cmd .. separator .. "|cFF4488FF/showsidebars|r, |cFF4488FF/hidesidebars|r - 切換顯示右側兩列動作列"
	cmd = cmd .. separator .. "|cFF4488FF/showrightbar|r, |cFF4488FF/hiderightbar|r - 切換顯示右側動作列"
	cmd = cmd .. separator .. "|cFF4488FF/showleftbar|r, |cFF4488FF/hideleftbar|r - 切換顯示右側動作列2"
	cmd = cmd .. separator .. "|cFF4488FF/showpet|r, |cFF4488FF/hidepet|r - 切換顯示寵物動作列"
	cmd = cmd .. separator .. "|cFF4488FF/showshift|r, |cFF4488FF/hideshift|r - 切換顯示姿態列"
	cmd = cmd .. separator .. "|cFF4488FF/showtotem|r, |cFF4488FF/hidetotem|r - 切換顯示圖騰動作列"
	cmd = cmd .. separator .. "|cFF4488FF/showmini|r, |cFF4488FF/hidemini|r - 切換顯示微型選單"
	cmd = cmd .. separator .. "|cFF4488FF/rl|r - 重載介面"
	cmd = cmd .. separator .. "|cFF4488FF/gm|r - 打開幫助視窗"
	cmd = cmd .. separator .. "|cFF4488FF/showchatbrackets|r - 在玩家和頻道名稱周圍顯示括號"
	cmd = cmd .. separator .. "|cFF4488FF/hidechatbrackets|r - 隱藏玩家和頻道名稱周圍的括號"
	cmd = cmd .. separator .. "|cFF4488FF/chatmenu|r - 開啟聊天選單"
	cmd = cmd .. separator .. "|cFF4488FF/mapmenu|r - 開啟小地圖中鍵選單"
	cmd = cmd .. separator .. "|cFF4488FF/tt|r or |cFF4488FF/wt|r - 密語目前目標"
	cmd = cmd .. separator .. "|cFF4488FF/tf|r or |cFF4488FF/wf|r - 密語專注目標"
	cmd = cmd .. separator .. "|cFF4488FF/showhotkeys|r, |cFF4488FF/hidehotkeys|r - 切換在動作按鈕上顯示熱鍵"
	cmd = cmd .. separator .. "|cFF4488FF/shownames|r, |cFF4488FF/hidenames|r - 切換在動作按鈕上顯示巨集名稱"
	cmd = cmd .. separator .. "|cFF4488FF/enableautorepair|r - 啟用自動修裝"
	cmd = cmd .. separator .. "|cFF4488FF/disableautorepair|r - 關閉自動修裝"
	cmd = cmd .. separator .. "|cFF4488FF/enableguildrepair|r - 使用公會銀行修裝"
	cmd = cmd .. separator .. "|cFF4488FF/disableguildrepair|r - 關閉使用工會銀行修裝"
	cmd = cmd .. separator .. "|cFF4488FF/enableautosell|r - 啟用自動販售"
	cmd = cmd .. separator .. "|cFF4488FF/disableautosell|r - 關閉自動販售"
	cmd = cmd .. separator .. "|cFF4488FF/enabledetailedreport|r - 顯示自動販售詳細報告"
	cmd = cmd .. separator .. "|cFF4488FF/disabledetailedreport|r - 關閉自動販售詳細報告只顯示總額"
	cmd = cmd .. separator .. "|cFF4488FF/mainspec|r - 啟用你的主天賦"
	cmd = cmd .. separator .. "|cFF4488FF/offspec|r - 啟用你的副天賦"
	cmd = cmd .. separator .. "|cFF4488FF/togglespec|r - 切換雙天賦"
	cmd = cmd .. separator .. "|cFF4488FF/ghelp|r - 顯示所有命令清單"
	L["chatcommandlist-separator"] = separator
	L["chatcommandlist"] = cmd
end


--------------------------------------------------------------------------------------------------
--		Keybinds Menu (Blizzard)
--------------------------------------------------------------------------------------------------
do
	L["Toggle Calendar"] = "顯示行事曆"
	L["Whisper focus"] = true
	L["Whisper target"] = true
end


--------------------------------------------------------------------------------------------------
--		Error Messages 
--------------------------------------------------------------------------------------------------
do
	L["Can't toggle Action Bars while engaged in combat!"] = "戰鬥中無法切換動作列"
	L["Can't change Action Bar layout while engaged in combat!"] = "戰鬥中無法更改動作列樣式"
	L["Frames cannot be moved while engaged in combat"] = "戰鬥中無法移動框架"
	L["Hiding movable frame anchors due to combat"] = "戰鬥中隱藏可移動式框架"
	L["UnitFrames cannot be configured while engaged in combat"] = "戰鬥中無法設定單位框架"
	L["Can't initialize bags while engaged in combat."] = "戰鬥中無法初始化背包"
	L["Please exit combat then re-open the bags!"] = "請離開戰鬥並重新開啟背包"
end


--------------------------------------------------------------------------------------------------
--		Core Messages
--------------------------------------------------------------------------------------------------
do
	L["Goldpaw"] = "|cFFFF7D0AGoldpaw|r" -- my class colored name. no changes needed here.
	L["The user interface needs to be reloaded for the changes to take effect. Do you wish to reload it now?"] = "使用者介面須重新載入讓新的設定生效，你要現在重載嗎?"
	L["You can reload the user interface at any time with |cFF4488FF/rl|r or |cFF4488FF/reload|r"] = "你可以使用 |cFF4488FF/rl|r 或 |cFF4488FF/reload|r 指令隨時重載使用者介面"
	L["Can not apply default settings while engaged in combat."] = "戰鬥中無法套用預設值"
	L["Show Talent Pane"] = "顯示天賦面版"
end

-- menu
do
	L["UI Scale"] = "介面縮放比例"
	L["Use UI Scale"] = "使用介面縮放比例"
	L["Check to use the UI Scale Slider, uncheck to use the system default scale."] = "勾選使用介面縮放，取消勾選則使用系統大小"
	L["Changes the size of the game’s user interface."] = "改變遊戲使用者介面大小"
	L["Using custom UI scaling is not recommended. It will produce fuzzy borders and incorrectly sized objects."] = "不建議使用自定介面大小，這會造成邊框碎裂及物件大小錯誤"
	L["Apply the new UI scale."] = "套用新的介面比例"
	L["Load Module"] = "載入模組"
	L["Module Selection"] = "模組選擇"
	L["Choose which modules should be loaded, and when."] = "選擇要載入的模組及何時載入"
	L["Never load this module"] = "從不載入此模組"
	L["Load this module unless an addon with similar functionality is detected"] = "除非偵測到類似功能的插件，否則載入此模組"
	L["Always load this module, regardles of what other addons are loaded"] = "總是載入此模組，無視其他已載入的模組"
	L["(In Development)"] = "(開發中)"
end

-- install tutorial
do
	-- general install tutorial messages
	L["Skip forward to the next step in the tutorial."] = "在教學中向前轉跳到下一步驟"
	L["Previous"] = "前一步"
	L["Go backwards to the previous step in the tutorial."] = "在教學中倒退回到上一步驟"
	L["Skip this step"] = "跳過這一步驟"
	L["Apply the currently selected settings"] = "套用所選擇的設定"
	L["Procede with this step of the install tutorial."] = "在教學中執行此步驟"
	L["Cancel the install tutorial."] = "取消安裝教學"
	L["Setup aborted. Type |cFF4488FF/install|r to restart the tutorial."] = "安裝終止，輸入 |cFF4488FF/install|r 重新進入安裝教學"
	L["Setup aborted because of combat. Type |cFF4488FF/install|r to restart the tutorial."] = "因戰鬥導致安裝終止，輸入 |cFF4488FF/install|r 重新進入安裝教學"
	L["This is recommended!"] = "推薦!"

	-- core module's install tutorial
	L["This is the first time you're running %s on this character. Would you like to run the install tutorial now?"] = "這是你這個角色首次執行 %s，你想要進行安裝教學嗎?"
	L["Using custom UI scaling will distort graphics, create fuzzy borders, and otherwise ruin frame proportions and positions. It is adviced to always leave this off, as it will seriously affect the entire layout of the UI in unpredictable ways."] = "使用自訂UI縮放，將會扭曲圖形，產生邊框碎裂，並且破壞框架的比例和位置。建議不要使用UI縮放，因為這將嚴重影響整個UI產生無法預期的錯誤。"
	L["UI scaling is currently activated. Do you wish to disable this?"] = "UI縮放已啟用，你想要關閉它嗎?"
	L["|cFFFF0000UI scaling is currently deactivated, which is the recommended setting, so we are skipping this step.|r"] = "|cFFFF0000UI縮放已關閉，這是建議的設定，跳過這一步驟|r"
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
	L["Mouse Button"] = "滑鼠按鍵"

	L["Always"] = "總是"
	L["Apply"] = "套用"
	L["Bags"] = "背包"
	L["Bank"] = "銀行" 
	L["Bottom"] = "下"
	L["Cancel"] = "取消"
	L["Categories"] = "分類"
	L["Close"] = "關閉"
	L["Continue"] = "繼續"
	L["Copy"] = "複製" -- to copy. the verb.
	L["Default"] = "預設"
	L["Elements"] = "元件" -- like elements in a frame, not as in fire, ice etc
	L["Free"] = "空間" -- free space in bags and bank
	L["General"] = "一般" -- general as in general info
	L["Ghost"] = "鬼魂" -- when you are dead and have released your spirit
	L["Hide"] = "隱藏" -- to hide something. not hide as in "thick hide".
	L["Lock"] = "鎖定" -- to lock something, like a frame. the verb.
	L["Main"] = true -- used for Main chat frame, Main bag, etc
	L["Next"] = "下一個"
	L["Never"] = "從不"
	L["No"] = "否"
	L["Okay"] = "確定"
	L["Open"] = "開啟"
	L["Paste"] = "貼上" -- as in copy & paste. the verb.
	L["Reset"] = "重置"
	L["Rested"] = "充分休息" -- when you are rested, and will recieve 200% xp from kills
	L["Scroll"] = "附魔" -- "Scroll" as in "Scroll of Enchant". The noun, not the verb.
	L["Show"] = "顯示"
	L["Skip"] = "跳過"
	L["Top"] = "上"
	L["Total"] = "總共"
	L["Visibility"] = "透明度"
	L["Yes"] = "是"

	L["Requires the UI to be reloaded!"] = "需要重新載入UI"
	L["Changing this setting requires the UI to be reloaded in order to complete."] = "更改此設定需要重新載入UI以完成設定"
end

-- gFrameHandler replacements (/glock)
do
	L["<Left-Click and drag to move the frame>"] = "<左鍵點擊並拖曳來移動窗框>"
	L["<Left-Click+Shift to lock into position>"] = "<左鍵+Shift以鎖定位置>"
	--L["<Right-Click for options>"] = true -- the panel module supplies this one
	L["Center horizontally"] = "水平置中"
	L["Center vertically"] = "垂直置中"
end

-- visible module names
do
	L["ActionBars"] = "動作列"
	L["ActionButtons"] = "動作按鈕"
	L["Auras"] = "光環"
	L["Bags"] = "背包"
	L["Buffs & Debuffs"] = "增益減益效果"
	L["Castbars"] = "施法條"
	L["Core"] = "核心模組"
	L["Chat"] = "聊天"
	L["Combat"] = "戰鬥"
	L["CombatLog"] = "戰鬥紀錄"
	L["Errors"] = "錯誤訊息"
	L["Loot"] = "戰利品"
	L["Merchants"] = "交易"
	L["Minimap"] = "小地圖"
	L["Nameplates"] = "名條"
	L["Quests"] = "任務"
	L["Timers"] = "計時器"
	L["Tooltips"] = "提示說明"
	L["UI Panels"] = "面版"
	L["UI Skinning"] = "介面美化"
	L["UnitFrames"] = "單位框架"
		L["PartyFrames"] = "隊伍框架"
		L["ArenaFrames"] = "競技場框架"
		L["BossFrames"] = "首領框架"
		L["RaidFrames"] = "團隊框架"
		L["MainTankFrames"] = "主坦框架"
	L["World Status"] = "世界狀態"
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

	L["_ui_description_"] = "%s 是一個取代暴雪魔獸世界預設遊戲介面的使用者介面。它支援螢幕解析度至少為1280像素寬度，但建議1440像素寬度|n|n此 UI 是歐洲 Draenor PVE 伺服器一位聯盟玩家 Lars Norberg 所撰寫及維護，他的職業是野性德魯伊叫 %s。"
	
	L["_install_guide_"] = "接下來幾個步驟，會帶你安裝一些使用者介面模組。你稍後可以隨時從遊戲主選單的選項中或輸入|cFF4488FF/gui|r 指令改變設定。"
	
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
