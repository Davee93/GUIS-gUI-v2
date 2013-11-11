local L = LibStub("gLocale-1.0"):NewLocale((select(1, ...)), "frFR")
if not L then return end

--[[
	frFR.lua
	French locale by Rogueh - Ysondre EU
]]-- 

-- Skinning
L["Scroll"] = "Parchemin"

--------------------------------------------------------------------------------------------------
--		Modules
--------------------------------------------------------------------------------------------------
-- ActionBars
do
	L["Layout '%s' doesn't exist, valid values are %s."] = "Mise en page '%s' n'\195\169xiste pas, les valeurs valident sont %s."
	L["There is a problem with your ActionBars.|nThe user interface needs to be reloaded in order to fix it.|nReload now?"] = "Il y a un probl\195\168me avec vos barres d'action.|nL'interface utilisateur \195\160 besoin d'\195\170tre recharger pour r\195\169parer ceci.|nRecharger maintenant?"
	L["<Left-Click> to show additional ActionBars"] = "<Left-Click> pour voir une barre d'action suppl\195\169mentaire"
	L["<Left-Click> to hide this ActionBar"] = "<Left-Click> pour cacher cette barre d'action"
end

-- ActionBars: micromenu
do
	L["Achievements"] = "Haut faits"
	L["Character Info"] = "Infos personnage"
	L["Customer Support"] = "Assistance client\195\168le"
	L["Dungeon Finder"] = "Recherche des Donjons"
	L["Dungeon Journal"] = "Journal des Donjons"
	L["Game Menu"] = "Menu du Jeu"
	L["Guild"] = "Guilde"
	L["Guild Finder"] = "Recherche de Guilde"
	L["You're not currently a member of a Guild"] = "Vous n'\195\170tes pas membre d'une guilde"
	L["Player vs Player"] = "Joueur contre Joueur"
	L["Quest Log"] = "Journal des qu\195\170tes"
	L["Raid"] = "Raid"
	L["Spellbook & Abilities"] = "Grimoire & Techniques"
	L["Starter Edition accounts cannot perform that action"] = "Les comptes de l'\195\169dition d\195\169couverte ne peuvent pas effectuer cette action"
	L["Talents"] = "Talents"
	L["This feature becomes available once you earn a Talent Point."] = "Cette fonctionnalit\195\169 sera disponible une fois que vous gagner un point de talent."
end

-- ActionBars: menu
do
	L["ActionBars are banks of hotkeys that allow you to quickly access abilities and inventory items. Here you can activate additional ActionBars and control their behaviors."] = "Vos barres d'action sont des banques de raccourcis qui vous permettent d'acc\195\169der rapidement \195\160 vos techniques et aux objets de votre inventaire. Ici vous pouvez activer vos barres d'action suppl\195\169mentaires et contr\195\180ler leurs comportements."
	L["Secure Ability Toggle"] = "S\195\169curiser les techniques"
	L["When selected you will be protected from toggling your abilities off if accidently hitting the button more than once in a short period of time."] = "Quand selectionn\195\169 vous serez prot\195\169ger contre l'appuis r\195\169p\195\169ter par accident d'une technique dans un court laps de temps."
	L["Lock ActionBars"] = "Verouille les barres d'action"
	L["Prevents the user from picking up/dragging spells on the action bar. This function can be bound to a function key in the keybindings interface."] = "Emp\195\170che l'utilisateur de prendre/glisser des sorts sur la barre d'action. Cette fonction peut \195\170tre affect\195\169 \195\160 une touche dans l'interface des raccourcis clavier."
	L["Pick Up Action Key"] = "Prendre une touche d'action"
	L["ALT key"] = "Touche ALT"
	L["Use the \"ALT\" key to pick up/drag spells from locked actionbars."] = "Utilisez la touche \"ALT\" pour prendre/glisser des sorts depuis vos barres d'action bloqu\195\169es."
	L["CTRL key"] = "Touche CTRL"
	L["Use the \"CTRL\" key to pick up/drag spells from locked actionbars."] = "Utilisez la touche \"CTRL\" pour prendre/glisser des sorts depuis vos barres d'action bloqu\195\169es."
	L["SHIFT key"] = "Touche SHIFT"
	L["Use the \"SHIFT\" key to pick up/drag spells from locked actionbars."] = "Utilisez la touche \"SHIFT\" pour prendre/glisser des sorts depuis vos barres d'action bloqu\195\169es."
	L["None"] = "Aucun"
	L["No key set."] = "Pas de touche configur\195\169."
	L["Visible ActionBars"] = "barres d'action visible"
	L["Show the rightmost side ActionBar"] = "Montrer les barres d'action du c\195\180t\195\169 le plus \195\160 droite"
	L["Show the leftmost side ActionBar"] = "Montrer les barres d'action du c\195\180t\195\169 le plus \195\160 gauche"
	L["Show the secondary ActionBar"] = "Montrer la deuxi\195\168me barre d'action"
	L["Show the third ActionBar"] = "Montrer la troisi\195\168me barre d'action"
	L["Show the Pet ActionBar"] = "Montrer la barre du famillier"
	L["Show the Shapeshift/Stance/Aspect Bar"] = "Montrer la barre de forme/posture/aspect"
	L["Show the Totem Bar"] = "Montrer la barre des totems"
	L["Show the Micro Menu"] = "Montrer le mini-menu"
	L["ActionBar Layout"] = "Disposition de la barre d'action"
	L["Sort ActionBars from top to bottom"] = "Mettre vos barres d'action du haut vers le bas"
	L["This displays the main ActionBar on top, and is the default behavior of the UI. Disable to display the main ActionBar at the bottom."] = "Ceci affiche votre barre d'action principale en haut, et c'est l'option par d\195\169faut de l'UI. D\195\169sactiver pour afficher votre barre d'action en bas."
	L["Button Size"] = "Taille du bouton"
	L["Choose the size of the buttons in your ActionBars"] = "Choisir la taille de vos boutons dans vos barres d'action"
	L["Sets the size of the buttons in your ActionBars. Does not apply to the TotemBar."] = "D\195\169finit la taille des boutons dans vos barres d'action. Ne pas appliquer \195\160 la barre des totems."
end

-- ActionBars: Install
do
	L["Select Visible ActionBars"] = "Selectionner les barres d'action visiblent"
	L["Here you can decide what actionbars to have visible. Most actionbars can also be toggled by clicking the arrows located next to their edges which become visible when hovering over them with the mouse cursor. This does not work while engaged in combat."] = "Ici vous pouvez decider quelles barres d'action seront visiblent. Beaucoup de vos barres d'action peuvent \195\170tres affich\195\169 par clic sur les fl\195\168ches situ\195\169e dans les coins qui sont visible quand vous passez la souris dessus. Ceci ne fonctionne pas en combat."
	L["You can try out different layouts before proceding!"] = "Vous pouvez essayer plusieurs disposition avant de proc\195\169der!"
	L["Toggle Bar 2"] = "Voir la barre 2"
	L["Toggle Bar 3"] = "Voir la barre 3"
	L["Toggle Bar 4"] = "Voir la barre 4"
	L["Toggle Bar 5"] = "Voir la barre 5"
	L["Toggle Pet Bar"] = "Voir la barre du famillier"
	L["Toggle Shapeshift/Stance/Aspect Bar"] = "Voir la barre de forme/posture/aspect"
	L["Toggle Totem Bar"] = "Voir la barre des Totems"
	L["Toggle Micro Menu"] = "Voir la barre du mini-menu"
	
	L["Select Main ActionBar Position"] = "Selectionner la position de votre barre d'action principale"
	L["When having multiple actionbars visible, do you prefer to have the main actionbar displayed at the top or at the bottom? The default setting is top."] = "quand vous avez de multiple barres d'action visible, vous pr\195\169f\195\168rez avoir votre barre d'action principal affich\195\169 en haut ou en bas ? Le r\195\169glage par d\195\169faut est en haut."
end

-- ActionButtons: Keybinds (displayed on buttons)
do
	L["A"] = "A" -- Alt
	L["C"] = "C" -- Ctrl
	L["S"] = "S" -- Shift
	L["M"] = "M" -- Bouton de la Souris
	L["M3"] = "M3" -- Molette/Troisi\195\168me bouton de la Souris
	L["N"] = "N" -- Pavé numérique
	L["NL"] = "VN" -- Verr Num
	L["CL"] = "CL" -- Verr Maj
	L["Clr"] = "Clr" -- Clear
	L["Del"] = "Suppr" -- Suppr
	L["End"] = "Fin" -- Fin
	L["Home"] = "Home" -- Accueil
	L["Ins"] = "Ins" -- Insér.
	L["Tab"] = "Tab" -- Tab
	L["Bs"] = "Bs" -- Retour arri\195\168re
	L["WD"] = "WD" -- Molette de la Souris vers le bas
	L["WU"] = "WU" -- Molette de la Souris vers le haut
	L["PD"] = "PD" -- Page en bas
	L["PU"] = "PU" -- Page en haut
	L["SL"] = "SL" -- Arr\195\170t défil.
	L["Spc"] = "Spc" -- Barre d'espace
	L["Dn"] = "Dn" -- Fl\195\168che du bas
	L["Lt"] = "Lt" -- Fl\195\168che de gauche
	L["Rt"] = "Rt" -- Fl\195\168che de droite
	L["Up"] = "Up" -- Fl\195\168che du haut
end

-- ActionButtons: menu
do
	L["ActionButtons are buttons allowing you to use items, cast spells or run a macro with a single keypress or mouseclick. Here you can decide upon the styling and visible elements of your ActionButtons."] = "Les boutons d'actions sont des boutons allou\195\169 pour utiliser vos objets, lancer un sort ou une macro avec un seule touche ou un clic. Ici vous pourrez d\195\169cider du style et des \195\169l\195\169ments visible de vos boutons d'actions."
	L["Button Styling"] = "Style des boutons"
	L["Button Text"] = "Texte des boutons"
	L["Show hotkeys on the ActionButtons"] = "Voir les raccourcis sur les boutons d'actions"
	L["Show Keybinds"] = "Voir les raccourcis"
	L["This will display your currently assigned hotkeys on the ActionButtons"] = "Ceci afficheras vos raccourcis actuel sur les boutons d'actions"
	L["Show macro names on the ActionButtons"] = "Voir le nom des macros sur les boutons d'actions"
	L["Show Names"] = "Voir les noms"
	L["This will display the names of your macros on the ActionButtons"] = "Ceci afficheras le nom de vos macros sur les boutons d'actions"
	L["Show gloss layer on ActionButtons"] = "Voir une couche de l'effet gloss sur les boutons d'actions"
	L["Show Gloss"] = "Voir l'effet gloss"
	L["This will display the gloss overlay on the ActionButtons"] = "Ceci afficheras l'effet gloss sur les boutons d'actions"
	L["Show shade layer on ActionButtons"] = "Voir l'effet d'ombre sur les ActionButtons"
	L["This will display the shade overlay on the ActionButtons"] = "Ceci afficheras l'effet d'ombre sur les boutons d'actions"
	L["Show Shade"] = "Voir l'ombre"
	--L["Set amount of gloss"] = true
	--L["Set amount of shade"] = true
end

-- Auras: menu
do
	L["These options allow you to control how buffs and debuffs are displayed. If you wish to change the position of the buffs and debuffs, you can unlock them for movement with |cFF4488FF/glock|r."] = "Cette option vous autorise \195\160 controler combien d'am\195\169liorations et d'affaiblissements sont affich\195\169s. Si votre souhait est de changer la position des am\195\169liorations et des affaiblissements, vous pouvez les d\195\169bloquer avec |cFF4488FF/glock|r."
	L["Aura Styling"] = "Style des auras"
	L["Show gloss layer on Auras"] = "Voir l'effet gloss sur les auras"
	L["Show Gloss"] = "Voir l'effet gloss"
	L["This will display the gloss overlay on the Auras"] = "Ceci afficheras une couche de l'effet gloss sur les auras"
	L["Show shade layer on Auras"] = "Voir l'effet d'ombre sur les auras"
	L["This will display the shade overlay on the Auras"] = "Ceci afficheras une couche de l'effet d'ombre sur les auras"
	L["Show Shade"] = "Voir l'ombre" 
	L["Time Display"] = "Affichage du temps"
	L["Show remaining time on Auras"] = "Voir le temps restant sur les auras"
	L["Show Time"] = "Voir le temps"
	L["This will display the currently remaining time on Auras where applicable"] = "Ceci afficheras le temps actuel restant sur les auras"
	L["Show cooldown spirals on Auras"] = "Voir le temps de recharge en spirale sur les Auras"
	L["Show Cooldown Spirals"] = "Voir le temps de recharge en spirale"
	L["This will display cooldown spirals on Auras to indicate remaining time"] = "Ceci afficheras le temps de recharge en spirale sur les auras pour indiquer le temps restant"
end

-- Bags
do
	L["Gizmos"] = "Gizmos" -- used for "special" things like the toy train set
	L["Equipment Sets"] = "Equipments" -- used for the stored equipment sets
	L["New Items"] = "Nouveaux objets" -- used for the unsorted new items category in the bags
	L["Click to sort"] = "Cliquer pour trier"
	L["<Left-Click to toggle display of the Bag Bar>"] = "<Clic gauche pour basculer l'affichage de la barre des sacs>"
	L["<Left-Click to open the currency frame>"] = "<Clic gauche pour ouvrir votre monnaie>"
	L["<Left-Click to open the category selection menu>"] = "<Clic gauche pour ouvrir le menu de s\195\169lection de cat\195\169gorie>"
	L["<Left-Click to search for items in your bags>"] = "<Clic gauche pour rechercher des objets dans vos sacs>"
	L["Close all your bags"] = "Fermer tout vos sacs"
	L["Close this category and keep it hidden"] = "Fermer cette cat\195\169gorie et la garder cach\195\169"
	L["Close this category and show its contents in the main container"] = "Fermer cette cat\195\169gorie et afficher son contenu dans le sac principal"
end

-- Bags: menus 
do
	L["A character can store items in its backpack, bags and bank. Here you can configure the appearance and behavior of these."] = "Un personnage peut stocker des objets dans son sac \195\160 dos, sacs et banque. Ici vous pouvez configurer l'apparence et le comportement de tout sa."
	L["Container Display"] = "Affichage des conteneurs"
	L["Show this category and its contents"] = "Voir cette cat\195\169gorie et son contenus"
	L["Hide this category and all its contents completely"] = "Masquer cette cat\195\169gorie et tout son contenus compl\195\168tement"
	L["Bypass"] = "By-pass"
	L["Hide this category, and display its contents in the main container instead"] = "Masquer cette cat\195\169gorie, et afficher son contenu dans le conteneur principal"
	L["Choose the minimum item quality to display in this category"] = "Choisissez la qualit\195\169 des objets minimum \195\160 afficher dans cette cat\195\169gorie"
	L["Bag Width"] = "Largeur du conteneur"
	L["Sets the number of horizontal slots in the bag containers. Does not apply to the bank."] = "D\195\169finit le nombre d'emplacement horizontales dans les conteneurs. Ne s'applique pas \195\160 la banque."
	L["Bag Scale"] = "Echelle du conteneur"
	L["Sets the overall scale of the bags"] = "D\195\169finit l'\195\169chelle globale des conteneurs"
	L["Restack"] = "Empiler"
	L["Automatically restack items when opening your bags or the bank"] = "Empiler automatiquement les objets lorsque vous ouvrez vos sacs ou la banque"
	L["Automatically restack when looting or crafting items"] = "Empiler automatiquement en pillant ou en cr\195\169ant des objets"
	L["Sorting"] = "Trier"
	L["Sort the items within each container"] = "Trier les objets de chaque sac"
	L["Sorts the items inside each container according to rarity, item level, name and quanity. Disable to have the items remain in place."] = "Trie les \195\169l\195\169ments \195\160 l'int\195\169rieur de chaque sac selon la raret\195\169, le iLvL, le nom et quantit\195\169e. D\195\169sactiver pour avoir les objets qui resterons en place."
	L["Compress empty bag slots"] = "Compresser les emplacements de sacs vides"
	L["Compress empty slots down to maximum one row of each type."] = "compresser les emplacements vides en bas au maximum \195\160 une rang\195\169e de chaque type."
	L["Lock the bags into place"] = "Verrouiller les sacs en place"
	L["Bag scale"] = "Echelle du sac"
	L["Button Styling"] = "Style du bouton" 
	L["Show gloss layer on buttons"] = "Voir l'effet gloss sur les boutons"
	L["Show Gloss"] = "Voir l'effet gloss" 
	L["This will display the gloss overlay on the buttons"] = "Ceci afficheras une couche de l'effet gloss sur les boutons"
	L["Show shade layer on buttons"] = "Voir l'effet d'ombre sur les buttons"
	L["This will display the shade overlay on the buttons"] = "Ceci afficheras une couche de l'effet d'ombre sur les buttons"
	L["Show Shade"] = "Voir l'effet d'ombre"
	L["Apply 'All In One' Layout"] = "Appliquer la disposition 'All In One'"
	L["Click here to automatically configure the bags and bank to be displayed as large unsorted containers."] = "Cliquez ici pour configurer automatiquement les sacs et la banque \195\160 \195\170tre affich\195\169s en tant que grands conteneurs non tri\195\169s."
	L["The bags can be configured to work as one large 'all-in-one' container, with no categories, no sorting and no empty space compression. If you wish to have that type of layout, click the button:"] = "Les sacs peuvent \195\170tre configur\195\169s pour fonctionner comme un grand conteneur 'All In One', sans cat\195\169gories, sans aucun tri et aucune compression de l'espace vide. Si vous souhaitez avoir ce type de mise en page, cliquez sur le bouton:"
	L["The 'New Items' category will display newly acquired items if enabled. Here you can set which categories and rarities to include."] = "La cat\195\169gorie des 'Nouveaux objets' afficheras les objets nouvellement acquis si elle est activ\195\169e. Ici vous pouvez d\195\169finir les cat\195\169gories et les raret\195\169s \195\160 inclure."
	L["Minimum item quality"] = "Qualit\195\169 d'objet minimum"
	L["Choose the minimum item rarity to be included in the 'New Items' category."] = "Choisir la qualit\195\169 minimum des objets pour \195\170tre inclus dans la cat\195\169gorie 'Nouveaux objets'."
end

-- Bags: Install
do
	L["Select Layout"] = "Sectionnez votre mise en page"
	L["The %s bag module has a variety of configuration options for display, layout and sorting."] = "Le %s module de sac poss\195\168de une vari\195\169t\195\169 d'options de configuration pour l'affichage, la mise en page et le tri."
	L["The two most popular has proven to be %s's default layout, and the 'All In One' layout."] = "Les deux plus populaires sont av\195\169r\195\169 \195\170tre %s's la mise en page par d\195\169faut, et 'All In One'."
	L["The 'All In One' layout features all your bags and bank displayed as singular large containers, with no categories, no sorting and no empty space compression. This is the layout for those that prefer to sort and control things themselves."] = "La mise en page 'All In One' vous permet d'afficher tous vos sacs et votre banque dans un seul conteneur, sans cat\195\169gorie, sans triage. Cette disposition est pr\195\169f\195\169\rable si vous souhaitez tout g\195\169rer vous m\195\170me."
	L["%s's layout features the opposite, with all categories split into separate containers, and sorted within those containers by rarity, item level, stack size and item name. This layout also compresses empty slots to take up less screen space."] = "%s's cette mise en page propose chaque cat\195\169gorie dans son conteneur bien distinct, tri\195\169 par raret\195\169, niveau d'objet, taille des empilements et nom des objets. Cette mise en page compresse l'espace libre."
	L["You can open your bags to test out the different layouts before proceding!"] = "Vous pouvez ouvrir vos sacs afin de tester les diff\195\169rentes configurations avant de proc\195\169der!"
	L["Apply %s's Layout"] = "Appliquer la disposition %s's"
end

-- Bags: chat commands
do
	L["Empty bag slots will now be compressed"] = "Les emplacements de sac vide seront maintenant compress\195\169"
	L["Empty bag slots will no longer be compressed"] = "Les emplacements de sac vide ne seront plus compress\195\169"
end

-- Bags: restack
do
	L["Restack is already running, use |cFF4488FF/restackbags resume|r if stuck"] = "Empiler est en marche, utilisez |cFF4488FF/restackbags resume|r si bloqu\195\169"
	L["Resuming restack operation"] = "Reprise de l'empilement"
	L["No running restack operation to resume"] = "Pas d'op\195\169ration d'empilement en cours d'ex\195\169cution pour reprendre"
	L["<Left-Click to restack the items in your bags>"] = "<Clic-gauche pour empiler les objets dans vos sacs>"
	L["<Left-Click to restack the items in your bags>|n<Right-Click for options>"] = "<Clic gauche pour empiler les \195\\195\169ments dans vos sacs>|n<Clic-droit pour les options>"
end

-- Castbars: menu
do
	L["Here you can change the size and visibility of the on-screen castbars. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "Ici, vous pouvez modifier la taille et la visibilit\195\169 des barres de cast sur l'\195\169cran. Si vous souhaitez changer leurs positions, vous pouvez les d\195\169bloquer avec |cFF4488FF/glock|r."
	L["Show the player castbar"] = "Voir la barre de cast du joueur"
	L["Show for tradeskills"] = "Voir pour l'artisanats"
	L["Show the pet castbar"] = "Voir la barre de cast du pet"
	L["Show the target castbar"] = "Voir la barre de cast de la cible"
	L["Show the focus target castbar"] = "Voir la barre de cast du focus"
	L["Set Width"] = "D\195\169finir la largeur"
	L["Set the width of the bar"] = "D\195\169finir la largeur de la barre"
	L["Set Height"] = "R\195\169gler la hauteur"
	L["Set the height of the bar"] = "R\195\169gler la hauteur de la barre"
end

-- Chat: timestamp settings tooltip (http://www.lua.org/pil/22.1.html)
do
	L["|cFFFFD100%a|r abbreviated weekday name (e.g., Wed)"] = "|cFFFFD100%a|r nom abr\195\169g\195\169 du jour (e.g., Mer)"
	L["|cFFFFD100%A|r full weekday name (e.g., Wednesday)"] = "|cFFFFD100%A|r nom du jour complet (e.g., Mercredi)"
	L["|cFFFFD100%b|r abbreviated month name (e.g., Sep)"] = "|cFFFFD100%b|r anom abr\195\169g\195\169 du mois (e.g., Sep)"
	L["|cFFFFD100%B|r full month name (e.g., September)"] = "|cFFFFD100%B|r nom du mois complet (e.g., Septembre)"
	L["|cFFFFD100%c|r date and time (e.g., 09/16/98 23:48:10)"] = "|cFFFFD100%c|r la date et l'heure (e.g., 16/09/98 23:48:10)"
	L["|cFFFFD100%d|r day of the month (16) [01-31]"] = "|cFFFFD100%d|r jour du mois (16) [01-31]"
	L["|cFFFFD100%H|r hour, using a 24-hour clock (23) [00-23]"] = "|cFFFFD100%H|r heure, en utilisant une horloge de 24 heures (23) [00-23]"
	L["|cFFFFD100%I|r hour, using a 12-hour clock (11) [01-12]"] = "|cFFFFD100%I|r heure, en utilisant une horloge de 12 heures (11) [01-12]"
	L["|cFFFFD100%M|r minute (48) [00-59]"] = "|cFFFFD100%M|r minute (48) [00-59]"
	L["|cFFFFD100%m|r month (09) [01-12]"] = "|cFFFFD100%m|r mois (09) [01-12]"
	L["|cFFFFD100%p|r either 'am' or 'pm'"] = "|cFFFFD100%p|r l'un ou l'autre 'am' ou 'pm'"
	L["|cFFFFD100%S|r second (10) [00-61]"] = "|cFFFFD100%S|r seconde (10) [00-61]"
	L["|cFFFFD100%w|r weekday (3) [0-6 = Sunday-Saturday]"] = "|cFFFFD100%w|r jour de la semaine (3) [0-6 = Lundi-Samedi]"
	L["|cFFFFD100%x|r date (e.g., 09/16/98)"] = "|cFFFFD100%x|r date (e.g., 09/16/98)"
	L["|cFFFFD100%X|r time (e.g., 23:48:10)"] = "|cFFFFD100%X|r temps (e.g., 23:48:10)"
	L["|cFFFFD100%Y|r full year (1998)"] = "|cFFFFD100%Y|r ann\195\169e compl\195\168te (1998)"
	L["|cFFFFD100%y|r two-digit year (98) [00-99]"] = "|cFFFFD100%y|r deux chiffres pour l'ann\195\169e (98) [00-99]"
	L["|cFFFFD100%%|r the character `%´"] = "|cFFFFD100%%|r le caract\195\168re `%´" -- 'character' here refers to a letter or number, not a game character...
end

-- Chat: names of the chat frames handled by the addon
do
	L["Main"] = "Principale"
	L["Loot"] = "Loot"
	L["Log"] = "Log"
	L["Public"] = "Public"
end

-- Chat: abbreviated channel names
do
	L["G"] = "G" -- Guilde
	L["O"] = "O" -- Officier
	L["P"] = "P" -- Groupe
	L["PL"] = "PL" -- Chef de groupe
	L["DG"] = "DG" -- Guide du Donjon
	L["R"] = "R" -- Raid
	L["RL"] = "RL" -- Raid Leader
	L["RW"] = "RW" -- Raid Warning
	L["BG"] = "BG" -- Battleground
	L["BGL"] = "BGL" -- Battleground Leader
	L["GM"] = "GM" -- Game Master
end

-- Chat: various abbreviations
do
	L["Guild XP"] = "XP de Guilde" -- Expérience de Guilde.
	L["HK"] = "HK" -- Honorable Kill
	L["XP"] = "XP" -- Expérience
end

-- Chat: menu
do
	L["Here you can change the settings of the chat windows and chat bubbles. |n|n|cFFFF0000If you wish to change visible chat channels and messages within a chat window, background color, font size, or the class coloring of character names, then Right-Click the chat tab located above the relevant chat window instead.|r"] = "Ici, vous pouvez modifier les param\195\168tres de la fen\195\170tre de chat et des bulles. |n|n|cFFFF0000Si vous souhaitez changer les canaux de discussion et les messages visibles dans une fen\195\170tre de chat, couleur de fond, taille de la police, ou la coloration par classe des noms de personnages, faite clic droit sur l'onglet de chat situ\195\169e au-dessus de la fen\195\170tre de chat.|r"
	L["Enable sound alerts when receiving whispers or private Battle.net messages."] = "Activer les alertes sonores lors de la r\195\169ception des chuchotements ou des messages priv\195\169s Battle.net."

	L["Chat Display"] = "Affichage du Chat"
	L["Abbreviate channel names."] = "Abr\195\169ger les noms des canaux."
	L["Abbreviate global strings for a cleaner chat."] = "Abr\195\169ger les chaînes globales pour un Chat propre."
	L["Display brackets around player- and channel names."] = "Afficher des crochets autour du joueur- et des noms de canaux."
	L["Use emoticons in the chat"] = "Utilisez des \195\169motico\195\180nes dans le chat"
	L["Auto-align the text depending on the chat window's position."] = "Auto-aligner le texte en fonction de la position de la fen\195\170tre de chat."
	L["Auto-align the main chat window to the bottom left panel/corner."] = "Auto-aligner la fen\195\170tre principale en bas \195\160 gauche du panneau/coin."
	L["Auto-size the main chat window to match the bottom left panel size."] = "Auto-ajuster la taille de la fen\195\170tre principale pour la faire correspondre \195\160 la taille du panneau en bas \195\160 gauche."

	L["Timestamps"] = "horodateurs"
	L["Show timestamps."] = "Voir les horodateurs."
	L["Timestamp color:"] = "Couleur des horodateurs:"
	L["Timestamp format:"] = "Format des horodateurs:"

	L["Chat Bubbles"] = "Bulles du Chat"
	L["Collapse chat bubbles"] = "R\195\169duire les bulles du Chat"
	L["Collapses the chat bubbles to preserve space, and expands them on mouseover."] = "R\195\169duire les bulles du Chat pour pr\195\169server de l'espace, et les \195\169tendre au passage de la souris."
	L["Display emoticons in the chat bubbles"] = "Afficher les \195\169motic\195\180nes dans les bulles du Chat"

	L["Loot Window"] = "Fen\195\170tre de Loot"
	L["Create 'Loot' Window"] = "Cr\195\169er une fen\195\170tre de 'Loot'"
	L["Enable the use of the special 'Loot' window."] = "Activer l'utilisation de la fen\195\170tre sp\195\169ciale de 'Loot'."
	L["Maintain the channels and groups of the 'Loot' window."] = "Maintenir les canaux et les groupes de la fen\195\170tre de 'Loot'."
	L["Auto-align the 'Loot' chat window to the bottom right panel/corner."] = "Auto-aligner la fen\195\170tre de 'Loot' du Chat en bas \195\160 droite du panneau/coin."
	L["Auto-size the 'Loot' chat window to match the bottom right panel size."] = "Auto-ajuster la taille de la fen\195\170tre de 'Loot' du chat pour la faire correspondre \195\160 la taille du panneau en bas \195\160 droite."
end

-- Chat: Install
do
	L["Public Chat Window"] = "Fen\195\170tre du Chat Public"
	L["Public chat like Trade, General and LocalDefense can be displayed in a separate tab in the main chat window. This will keep your main chat window free from intrusive spam, while still having all the relevant public chat available. Do you wish to do so now?"] = "Le Chat Public chat comme le canal commerce, G\195\169n\195\169ral et de D\195\169fense peut-\195\170tre affich\195\169 dans un onglet s\195\169par\195\169 de la fen\195\170tre de chat principale. Ceci permet de lib\195\169rer la fen\195\170tre de chat principale du SPAM, tout en ayant le Chat public disponible. Voulez-vous le faire maintenant?"

	L["Loot Window"] = "Fen\195\170tre de Loot"
	L["Information like received loot, crafted items, experience, reputation and honor gains as well as all currencies and similar received items can be displayed in a separate chat window. Do you wish to do so now?"] = "Les informations comme les gains de butin, objets d'artisanat, l'exp\195\169rience, la r\195\169putation et l'honneur ainsi que tout les articles similaires peuvent \195\170tre affich\195\169es dans une fen\195\170tre de chat s\195\169par\195\169e. Le souhaitez-vous?"
	
	L["Initial Window Size & Position"] = "Position et taille initiale de la fen\195\170tre"
	L["Your chat windows can be configured to match the unitframes and the bottom UI panels in size and position. Do you wish to do so now?"] = "Vos fen\195\170tres de chat peuvent \195\170tre configur\195\169e pour correspondre \195\160 la taille et la position des barres d'unit\195\169e dans le panneau du bas. Voulez-vous le faire maintenant?"
	L["This will also dock any additional chat windows."] = "Ceci ancreras aussi les fen\195\170tres de chat suppl\195\169mentaire"
	
	L["Window Auto-Positioning"] = "Positionement automatique de la fen\195\170tre"
	L["Your chat windows will slightly change position when you change UI scale, game window size or screen resolution. The UI can maintain the position of the '%s' and '%s' chat windows whenever you log in, reload the UI or in any way change the size or scale of the visible area. Do you wish to activate this feature?"] = "la position de votre fen\195\170tre de chat changeras l\195\169g\195\168rement quand vous modifierez l'\195\169chelle de votre UI, la taille de la fen\195\170tre de jeu ou la r\195\169solution de votre \195\169cran. Votre UI peut maintenir la position '%s' et '%s' de la fen\195\170tre chat \195\160 chaque fois que vous vous connect\195\169. Voulez-vous activer cette fonction?"
	
	L["Window Auto-Sizing"] = "Dimensionnement automatique de la fen\195\170tre"
	L["Would you like the UI to maintain the default size of the chat frames, aligning them in size to visually fit the unitframes and bottom UI panels?"] = "Aimeriez-vous que l'UI maintienne la taille par d\195\169faut des fen\195\170tre de chat, en les alignants visuellement \195\160 la taille des barre d'unit\195\169es et aux panneaux situ\195\169 en bas de l'interface?"
	
	L["Channel & Window Colors"] = "Couleurs de Canal & Fen\195\170tre" 
	L["Would you like to change chatframe colors to what %s recommends?"] = "Aimeriez-vous changer les couleurs de la Fen\195\170tre de Chat \195\160 ce que recommande %s"
end

-- Combat
do
	L["dps"] = "dps" -- Dégâts Par Seconde
	L["hps"] = "hps" -- Soin Par Seconde
	L["tps"] = "tps" -- Menace Par Seconde
	L["Last fight lasted %s"] = "Dur\195\169e du dernier combat %s"
	L["You did an average of %s%s"] = "Vous avez fait une moyenne de %s%s"
	L["You are overnuking!"] = "Vous \195\170tes overnuking!"
	L["You have aggro, stop attacking!"] = "Vous avez l'aggro, cesser d'attaquer!"
	L["You are tanking!"] = "Vous tanker"
	L["You are losing threat!"] = "Vous perdez de l'aggro!"
	L["You've lost the threat!"] = "Vous avez perdu l'aggro!"
end

-- Combat: menu
do
	L["Simple DPS/HPS Meter"] = "Simple compteur de DPS/HPS"
	L["Enable simple DPS/HPS meter"] = "Activer le simple compteur de DPS/HPS"
	L["Show DPS/HPS when you are solo"] = "Voir le DPS/HPS quand vous \195\170tes seul"
	L["Show DPS/HPS when you are in a PvP instance"] = "Voir le DPS/HPS quand vous \195\170tes en PVP"
	L["Display a simple verbose report at the end of combat"] = "Afficher un simple rapport verbal \195\160 la fin du combat"
	L["Minimum DPS to display: "] = "DPS minimum pour l'affichage: "
	L["Minimum combat duration to display: "] = "Dur\195\169e minimum du combat pour l'affichage: "
	L["Simple Threat Meter"] = "Simple compteur de menace"
	L["Enable simple Threat meter"] = "Activer le simple compteur de menace"
	L["Use the Focus target when it exists"] = "Utiliser le Focalisation de la cible si elle existe"
	L["Enable threat warnings"] = "Activer l'alerte de la menace"
	L["Show threat when you are solo"] = "Voir la menace quand vous \195\170tes seul"
	L["Show threat when you are in a PvP instance"] = "Voir la menace quand vous \195\170tes en PVP"
	L["Show threat when you are a healer"] = "Voir la menace quand vous \195\170tes un soigneur"
	L["Enable simple scrolling combat text"] = "Activer le simple texte de combat flottant"
end

-- Combatlog
do
	L["GUIS"] = "GUIS" -- Le nom du filtre de votre journal de combat personalisé.
	L["Show simplified messages of actions done by you and done to you."] = "Voir les messages simplifi\195\169 des actions faites par vous et sur vous." -- the description of this filter
end

-- Combatlog: menu
do
	L["Maintain the settings of the GUIS filter so that they're always the same"] = "Maintenir les param\195\168tres du filtre GUIS de sorte \195\160 ce qu'ils soit toujours les m\195\170mes"
	L["Keep only the GUIS and '%s' quickbuttons visible, with GUIS at the start"] = "Garder seulement le GUIS et les boutons rapide visible '%s', avec GUIS au d\195\169but"
	L["Autmatically switch to the GUIS filter when you log in or reload the UI"] = "Basculer automatiquement sur le filtre GUIS quand vous vous connectez ou recharger votre UI"
	L["Autmatically switch to the GUIS filter whenever you see a loading screen"] = "Basculer automatiquement sur le filtre GUIS \195\160 chaque fois que vous voyez un \195\169cran de chargement"
	L["Autmatically switch to the GUIS filter when entering combat"] = "Basculer automatiquement sur le filtre GUIS quand vous entrez en combat"
end

-- Loot
do
	L["BoE"] = "LqE" -- Lier quand Equipé
	L["BoP"] = "LqR" -- Lier quand Ramassé
end

-- Merchant
do
	L["Selling Poor Quality items:"] = "Vendre les objets de qualit\195\169 pauvres:"
	L["-%s|cFF00DDDDx%d|r %s"] = true -- nothing to localize in this one, unless you wish to change the formatting
	L["Earned %s"] = "Gagn\195\169 %s"
	L["You repaired your items for %s"] = "Vous avez r\195\169par\195\169 vos objets pour %s"
	L["You repaired your items for %s using Guild Bank funds"] = "Vous avez r\195\169par\195\169 vos objets en utilisant les fonds de la Guilde pour %s"
	L["You haven't got enough available funds to repair!"] = "Vous n'avez pas assez de fonds disponibles pour r\195\169parer"
	L["Your profit is %s"] = "Votre b\195\169n\195\169fice est de %s" 
	L["Your expenses are %s"] = "Vos d\195\169penses sont de %s"
	L["Poor Quality items will now be automatically sold when visiting a vendor"] = " Vos objets de pauvre qualit\195\169 seront maintenant automatiquement vendus quand vous visiterez un vendeur"
	L["Poor Quality items will no longer be automatically sold"] = "Vos objets de pauvre qualit\195\169 ne seront plus vendus automatiquement"
	L["Your items will now be automatically repaired when visiting a vendor with repair capabilities"] = "Vos objets seront maintenant automatiquement r\195\169par\195\169 quand vous visiterez un vendeur avec les capacit\195\169s de r\195\169paration"
	L["Your items will no longer be automatically repaired"] = "Vos objets ne seront plus r\195\169par\195\169 automatiquement"
	L["Your items will now be repaired using the Guild Bank if the options and the funds are available"] = "Vos objets seront maintenant r\195\169par\195\169 en utilisant la Banque de Guilde si l'option et les fonds sont disponible"
	L["Your items will now be repaired using your own funds"] = "Vos objets seront maintenant r\195\169par\195\169 en utilisant vos propres fonds"
	L["Detailed reports for autoselling of Poor Quality items turned on"] = "Rapports d\195\169taill\195\169s pour la vente automatique des objets de pauvre qualit\195\169 activ\195\169" 
	L["Detailed reports for autoselling of Poor Quality items turned off, only summary will be shown"] = "Rapports d\195\169taill\195\169s pour la vente automatique des objets de pauvre qualit\195\169 activ\195\169 d\195\169sactiv\195\169, seulement un r\195\169sum\195\169 seras montr\195\169"
	L["Toggle autosell of Poor Quality items"] = "Basculer vers la vente automatique des objets de pauvre qualit\195\169"
	L["Toggle display of detailed sales reports"] = "Basculer vers l'affichage d\195\169taill\195\169s des rapports de vente"
	L["Toggle autorepair of your armor"] = "Basculer vers la r\195\169paration automatique de votre armure"
	L["Toggle Guild Bank repairs"] = "Basculer vers les r\195\169paration de la Banque de Guilde"
	L["<Alt-Click to buy the maximum amount>"] = "Alt-Clic pour acheter la quantit\195\169 maximale"
end

-- Minimap
do
	L["Calendar"] = "Calendrier"
	L["New Event!"] = "Nouvel \195\169v\195\169nement"
	L["New Mail!"] = "Nouveau Courriel"
	
	L["Raid Finder"] = "Recherche de Raid"
	
	L["(Sanctuary)"] = "(Sanctuaire"
	L["(PvP Area)"] = "(Zone PvP)"
	L["(%s Territory)"] = "(Territoire)"
	L["(Contested Territory)"] = "(Territoire Contest\195\169)"
	L["(Combat Zone)"] = "(Zone de Combat)"
	L["Social"] = "Social"
end

-- Minimap: menu
do
	L["The Minimap is a miniature map of your closest surrounding areas, allowing you to easily navigate as well as quickly locate elements such as specific vendors, or a herb or ore you are tracking. If you wish to change the position of the Minimap, you can unlock it for movement with |cFF4488FF/glock|r."] = "La Minimap est une miniature des zones environantes les plus proches, ce qui vous permet de naviguer et de localiser facilement des \195\169l\195\169ments comme les vendeurs, les herbes ou les mines que vous poursuivez. Si vous souhaitez d\195\169verouiller la position de la minimap vous pouvez le faire avec |cFF4488FF/glock|r."
	L["Display the clock"] = "Affichage de l'horloge"
	L["Display the current player coordinates on the Minimap when available"] = "Affichage des coordonn\195\169es actuelle du joueur lorsqu'elles sont disponible sur la Minimap." 
	L["Use the Mouse Wheel to zoom in and out"] = "Utilisez la molette de la souris pour zoomer et d\195\169zoomer"
	L["Display the difficulty of the current instance when hovering over the Minimap"] = "Affichage de la difficult\195\169e de l'instance courante quand vous passez la souris sur la Minimap"
	L["Display the shortcut menu when clicking the middle mouse button on the Minimap"] = "Affichage du mini-menu quand vous cliquez avec la molette de la souris sur la Minimap"
	L["Rotate Minimap"] = "Rotation de la minimap"
	L["Check this to rotate the entire minimap instead of the player arrow."] = "Cochez cette case pour faire tourner enti\195\168rement la minimap au lieu de la fl\195\168che du joueur"
end

-- Nameplates: menu
do
	L["Nameplates are small health- and castbars visible over a character or NPC's head. These options allow you to control which Nameplates are visible within the game field while you play."] = "Les Nameplates sont de petites barres de vie et barres de cast visible au dessus de la t\195\170te des NPC's. Cette option vous permet de contr\195\180ler la visibilit\195\169 et le champs de jeu des Nameplates."
	L["Automatically enable nameplates based on your current specialization"] = "Active automatiquement les nameplates en fonction de votre sp\195\169cialisation"
	L["Automatically enable friendly nameplates for repeatable quests that require them"] = "Active automatiquement les nameplates amicale pour les qu\195\170tes r\195\169p\195\169table qui en ont besoin"
	L["Only show friendly nameplates when engaged in combat"] = "Voir les nameplates amicale seulement quand vous entrez en combat"
	L["Only show enemy nameplates when engaged in combat"] = "Voir les nameplates \195\169nemie seulement quand vous entrez en combat"
	L["Use a blacklist to filter out certain nameplates"] = "Utilisez une liste noire pour filtrer certains nameplates"
	L["Display character level"] = "Affichage du niveau des personnages"
	L["Hide for max level characters when you too are max level"] = "Chachez le niveau maximum des personnages lorsque vous \195\170tes vous m\195\170me au niveau maximum"
	L["Display character names"] = "Affichage du nom des personnages"
	L["Display combo points on your target"] = "Affichage des points de combo sur votre cible" 
	
	L["Nameplate Motion Type"] = "Type de nameplate"
	L["Overlapping Nameplates"] = "Nameplates qui se chevauchent"
	L["Stacking Nameplates"] = "Nameplates empiler"
	L["Spreading Nameplates"] = "Nameplates en d\195\169talement"
	L["This method will allow nameplates to overlap."] = "Cette m\195\169thode autoriseras les namplates \195\160 se chevaucher."
	L["This method avoids overlapping nameplates by stacking them vertically."] = "Cette m\195\169thode \195\169vite que les nameplates se chevauche en les empilant verticalement."
	L["This method avoids overlapping nameplates by spreading them out horizontally and vertically."] = "Cette m\195\169thode \195\169vite que les nameplates se chevauche en les \195\169talant horizontalement et verticalement." 
	
	L["Friendly Units"] = "Unit\195\169s amicale"
	L["Friendly Players"] = "Joueurs amicale"
	L["Turn this on to display Unit Nameplates for friendly units."] = "Mettre en marche ceci pour afficher les Unit Nameplates pour unit\195\169s amicale"
	L["Enemy Units"] = "Unit\195\169s \195\169nemies"
	L["Enemy Players"] = "Joueur \195\169nemies"
	L["Turn this on to display Unit Nameplates for enemies."] = "Mettre en marche ceci pour afficher les Unit Nameplates pour unit\195\169s \195\169nemies"
	L["Pets"] = "Pets"
	L["Turn this on to display Unit Nameplates for friendly pets."] = "Mettre en marche ceci pour afficher les Unit Nameplates pour les pets amicaux"
	L["Turn this on to display Unit Nameplates for enemy pets."] = "Mettre en marche ceci pour afficher les Unit Nameplates pour les pets \195\169nemies"
	L["Totems"] = "Totems"
	L["Turn this on to display Unit Nameplates for friendly totems."] = "Mettre en marche ceci pour afficher les Unit Nameplates pour les totems amicaux"
	L["Turn this on to display Unit Nameplates for enemy totems."] = "Mettre en marche ceci pour afficher les Unit Nameplates pour les totems \195\169nemies"
	L["Guardians"] = "Gardiens"
	L["Turn this on to display Unit Nameplates for friendly guardians."] = "Mettre en marche ceci pour afficher les Unit Nameplates pour les gardiens amicaux"
	L["Turn this on to display Unit Nameplates for enemy guardians."] = "Mettre en marche ceci pour afficher les Unit Nameplates pour les gardiens \195\169nemies"
end

-- Panels
do
	L["<Left-Click to open all bags>"] = "Clic-gauche pour ouvrir tout les sacs"
	L["<Right-Click for options>"] = "Clic-droit pour les options"
	L["No Guild"] = "Aucune Guilde"
	L["New Mail!"] = "Nouveau courriel"
	L["No Mail"] = "Pas de courriel"
	L["Total Usage"] = "Utilisation de la m\195\169moire totale:"
	L["Tracked Currencies"] = "Suivis des devises"
	L["Additional AddOns"] = "AddOns suppl\195\169mentaires"
	L["Network Stats"] = "Statistiques r\195\169seau"
	L["World latency:"] = "Latence Monde:"
	L["World latency %s:"] = "Latence Monde %s:"
	L["(Combat, Casting, Professions, NPCs, etc)"] = "(Combat, Casting, M\195\169tiers, NPCs, etc)" 
	L["Realm latency:"] = "Latence Royaume:"
	L["Realm latency %s:"] = "Latence Royaume %s:"
	L["(Chat, Auction House, etc)"] = "(Chat, H\195\180tel des ventes, etc)"
	L["Display World Latency %s"] = "Affiche la latence monde %s"
	L["Display Home Latency %s"] = "Affiche la latence royaume %s"
	L["Display Framerate"] = "Affiche les IPS"

	L["Incoming bandwidth:"] = "Bande passante entrante:"
	L["Outgoing bandwidth:"] = "Bande passante sortante:"
	L["KB/s"] = "Ko/s"
	L["<Left-Click for more>"] = "Clic-gauche pour plus de d\195\169tails"
	L["<Left-Click to toggle Friends pane>"] = "Clic-gauche pour basculer vers le panneau amis"
	L["<Left-Click to toggle Guild pane>"] = "Clic-gauche pour basculer vers le panneau de Guilde"
	L["<Left-Click to toggle Reputation pane>"] = "Clic-gauche pour basculer vers le panneau de r\195\169putation"
	L["<Left-Click to toggle Currency frame>"] = "Clic-gauche pour basculer la fen\195\170tre des devises"
	L["%d%% of normal experience gained from monsters."] = "%d%% d'exp\195\169rience normal gagn\195\169 sur les monstres"
	L["You should rest at an Inn."] = "Tu devrais te reposer dans une auberge"
	L["Hide copper when you have at least %s"] = "Masquer les cuivres lorsque vous avez au moins %s"
	L["Hide silver and copper when you have at least %s"] = "Masquer l'argents et les cuivres lorsque vous avez au moins %s"
	L["Invite a member to the Guild"] = "Inviter un membre de la Guilde"
	L["Change the Guild Message Of The Day"] = "Changer le message du jour de Guilde"
	L["Select currencies to always watch:"] = "S\195\169lectionnez les devises \195\160 toujours regarder:"
	L["Select how your gold is displayed:"] = "S\195\169lectionnez la facon dont votre or est affich\195\169:"
end

-- Panels: menu
do
	L["UI Panels are special frames providing information about the game as well allowing you to easily change settings. Here you can configure the visibility and behavior of these panels. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "Les UI panels sont des fen195\170tres sp\195\169ciale qui fournissent des informations sur le jeu et une modification facile de ces param\195\168tres. Ici vous pouvez configurer la visibilit\195\169 et le comportement de ceux-ci. Si vous souhaitez changer leur position, vous pouvez les d\195\169bloquer avec |cFF4488FF/glock|r."
end

-- Quest: menu
do
	L["QuestLog"] = "journal de qu\195\170te"
	L["These options allow you to customize how game objectives like Quests and Achievements are displayed in the user interface. If you wish to change the position of the ObjectivesTracker, you can unlock it for movement with |cFF4488FF/glock|r."] = "Ces options vous permettent de personnaliser la facon dont les objectifs de jeu comme les qu\195\170tes et les haut faits sont affich\195\169s dans l'interface utilisateur. Si vous souhaitez modifier la position du suivis d'objectifs, vous pouvez le d\195\169verrouiller avec |cFF4488FF/glock|r."
	L["Display quest level in the QuestLog"] = "Affiche le niveau des qu\195\170tes dans le journal de qu\195\170te"
	L["Objectives Tracker"] = "Suivis des objectifs"
	L["Autocollapse the WatchFrame"] = "Plier/d\195\169plier automatiquement la WatchFrame"
	L["Autocollapse the WatchFrame when a boss unitframe is visible"] = "Plier/d\195\169plier automatiquement la WatchFrame quand une unit\195\169 de Boss est visible"
	L["Automatically align the WatchFrame based on its current position"] = "Aligner automatiquemnt la WatchFrame par rapport \195\160 sa position courante"
	L["Align the WatchFrame to the right"] = "Aligner la watchFrame sur la droite"
end

-- Tooltips
do
	L["Here you can change the settings for the game tooltips"] = "ici vous pouvez changer les param\195\168tres pour les info-bulles du jeu"
	L["Hide while engaged in combat"] = "Cacher quand vous entrer en combat"
	L["Show values on the tooltip healthbar"] = "Voir les valeurs sur les info-bulles de la barre de soin"
	L["Show player titles in the tooltip"] = "Voir les titres du joueur dans l'info-bulle"
	L["Show player realms in the tooltip"] = "Voir les royaumes dans l'info-bulle"
	L["Positioning"] = "Positionement"
	L["Choose what tooltips to anchor to the mouse cursor, instead of displaying in their default positions:"] = "Choisissez l'ancre des info-bulles sur le curseur, au lieu de l'affichage par d\195\169faut"
	L["All tooltips will be displayed in their default positions."] = "Tous les info-bulles s'affichent dans leurs positions par d\195\169faut."
	L["All tooltips will be anchored to the mouse cursor."] = "Tous les infobulles seront ancr\195\169 au curseur de la souris."
	L["Only Units"] = "Les unit\195\169s seules"
	L["Only unit tooltips will be anchored to the mouse cursor, while other tooltips will be displayed in their default positions."] = "les infobulles des unit\195\169s seules seront ancr\195\169s au curseur de la souris, tandis que d'autres info-bulles s'afficheront dans leurs positions par d\195\169faut."
end

-- world status: menu
do
	L["Here you can set the visibility and behaviour of various objects like the XP and Reputation Bars, the Battleground Capture Bars and more. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "Ici, vous pouvez d\195\169finir la visibilit\195\169 et le comportement des objets divers tels que les barres la r\195\169putation, la barre de capture des champs de bataille et plus. Si vous souhaitez changer leur position, vous pouvez les d\195\169bloquer avec |cFF4488FF/glock|r."
	L["StatusBars"] = "Barres d'\195\169tat"
	L["Show the player experience bar."] = "Afficher la barre d'exp\195\169rience du joueur."
	L["Show when you are at your maximum level or have turned off experience gains."] = "Indiquer que vous \195\170tes \195\160 votre niveau maximum ou que vous avez stopp\195\169 vos gains d'exp\195\169rience"
	L["Show the currently tracked reputation."] = "Afficher la r\195\169putation actuellement suivis."
	L["Show the capturebar for PvP objectives."] = "Afficher la barre de capture pour objectifs JcJ."
end

-- UnitFrames
do
	L["Due to entering combat at the worst possible time the UnitFrames were unable to complete the layout change.|nPlease reload the user interface with |cFF4488FF/rl|r to complete the operation!"] = "En raison de votre entrer en combat au pire moment possible, les cadres d'unit\195\169s ont \195\169t\195\169 incapables de compl\195\169ter le changement de disposition. |nVeuillez recharger l'interface utilisateur avec |cFF4488FF/rl|r pour terminer l'op\195\169ration!."
end

-- UnitFrames: oUF_Trinkets
do
	L["Trinket ready: "] = "Bijou pr\195\170t: "
	L["Trinket used: "] = "Bijou utilis\195\169: "
	L["WotF used: "] = "WotF utilis\195\169: "
end

-- UnitFrames: menu
do
	L["These options can be used to change the display and behavior of unit frames within the UI. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "Cette option peut \195\170tre utilis\195\169e pour changer l'affichage et le comportement des cadres d'unit\195\169s dans l'UI. Si vous shouaitez changer leur position, vous pouvez les dev\195\169rouiller avec |cFF4488FF/glock|r."

	L["Choose what unit frames to load"] = "Choisissez les cadres d'unit\195\169s que vous charg\195\169"
	L["Enable Party Frames"] = "Activer les cadres de Groupe"
	L["Enable Arena Frames"] = "Activer les cadres d'Ar\195\168ne"
	L["Enable Boss Frames"] = "Activer les cadres de Boss"
	L["Enable Raid Frames"] = "Activer les cadres de Raid"
	L["Enable MainTank Frames"] = "Activer les cadres du tank principal"
	L["ClassBar"] = "Barre de classe"
	L["The ClassBar is a larger display of class related information like Holy Power, Runes, Eclipse and Combo Points. It is displayed close to the on-screen CastBar and is designed to more easily track your most important resources."] = "la barre de classe est un affichage plus large des informations li\195\169es \195\160 la classe comme Holy power, les Runes, Eclipse et les Points de Combo. Elle est affich\195\169e \195\160 proximit\195\169 de la barre de cast et est concu pour suivre plus facilement vos ressources les plus importantes."
	L["Enable ClassBar"] = "Activer la barre de classe"
	
	L["Set Focus"] = "d\195\169finir la focalisation"
	L["Here you can enable and define a mousebutton and optional modifier key to directly set a focus target from clicking on a frame."] = "Ici vous pouvez activer et d\195\169finir un bouton de la souris et une touche de modif. optionnelle pour d\195\169finir la cible du focus via un clic sur un cadre"
	L["Enable Set Focus"] = "Activer d\195\169finir le focalisation"
	L["Enabling this will allow you to quickly set your focus target by clicking the key combination below while holding the mouse pointer over the selected frame."] = "L'activation de ceci vous permetras de d\195\169finir la focalisation de votre cible rapidement, en cliquant sur la combinaison de touches ci-dessous tout en maintenant le pointeur de la souris sur le cadre selectionn\195\169."
	L["Modifier Key"] = "Touche de modification"

	L["Enable indicators for HoTs, DoTs and missing buffs."] = "Activer les indicateurs pour les HoTs, DoTs et les am\195\169liorations manquante."
	L["This will display small squares on the party- and raidframes to indicate your active HoTs and missing buffs."] = "Ceci afficheras des petits carr\195\169 sur les cadres de groupe et les cadres de raid pour indiquer les HoTs actifs et les am\195\169liorations manquante."

	--L["Auras"] = true
	L["Here you can change the settings for the auras displayed on the player- and target frames."] = "Ici vous pouvez changer les param\195\168tres pour les auras affich\195\169es sur le joueur- et la cible."
	L["Filter the target auras in combat"] = "Filtrer les auras de la cible en combat"
	L["This will filter out auras not relevant to your role from the target frame while engaged in combat, to make it easier to track your own debuffs."] = "Ceci vous permettras de filtrer les auras qui ne vous correspondent pas sur votre cible quand vous \195\170tes en combat, afin de rendre plus facile le suivis de vos propres affaiblissements." 
	L["Desature target auras not cast by the player"] = "D\195\169satur\195\169 les auras de la cible non lanc\195\169 par le joueur"
	L["This will desaturate auras on the target frame not cast by you, to make it easier to track your own debuffs."] = "Ceci D\195\169satureras les auras de la cible non lanc\195\169 par le joueur, afin de facilit\195\169 la lisibilit\195\169 de vos propres affaiblissements."	
	L["Texts"] = "textes"
	L["Show values on the health bars"] = "Voir les valeurs sur les barres de soin"
	L["Show values on the power bars"] = "Voir les valeurs sur les barres de puissance"
	L["Show values on the Feral Druid mana bar (when below 100%)"] = "Voir les valeurs sur la barre de mana du druide f\195\169ral (en dessous de 100%)"
	
	L["Groups"] = "Groupes"
	L["Here you can change what kind of group frames are used for groups of different sizes."] = "Ici vous pouvez changer quel type de trames de groupes sont utilis\195\169s pour des groupes de tailles diff\195\169rentes."

	L["5 Player Party"] = "Groupe de 5 joueurs"
	L["Use the same frames for parties as for raid groups."] = "Utiliser les m\195\170mes cadres que les groupes pour les groupes de raid"
	L["Enabling this will show the same types of unitframes for 5 player parties as you currently have chosen for 10 player raids."] = "Activer ceci vous afficheras les m\195\170mes types de barres d'unit\195\169 que vous avez choisi en groupe de 5 joueurs pour un raid de 10 joueurs."
	
	L["10 Player Raid"] = "Raid de 10 joueurs"
	L["Use same raid frames as for 25 player raids."] = "Utiliser les m\195\170mes cadres de raid que pour un raid de 25 joueurs."
	L["Enabling this will show the same types of unitframes for 10 player raids as you currently have chosen for 25 player raids."] = "Activer ceci vous afficheras les m\195\170mes types de barres d'unit\195\169 d'un raid de 10 joueurs pour un raid de 25 joueurs."

	L["25 Player Raid"] = "Raid de 25 joueurs"
	L["Automatically decide what frames to show based on your current specialization."] = "Decider automatiquement quels sont types de cadres \195\160 voir en fonction de votre sp\195\169cialisation courante." 
	L["Enabling this will display the Grid layout when you are a Healer, and the smaller DPS layout when you are a Tank or DPSer."] = "Activer ceci vous afficheras une mise en page Grid quand vous \195\170tes soigneur, et une petite mise en page quand vous \195\170tes Tank ou DPSer."
	L["Use Healer/Grid layout."] = "Utiliser la mise ne page Soigneur/Grid."
	L["Enabling this will use the Grid layout instead of the smaller DPS layout for raid groups."] = "Activer cette option utiliseras la mise en page Grid au lieu de la petite mise en page de DPS pour les groupes de raid."
end

-- UnitFrames: GroupPanel
do
	-- party
	L["Show the player along with the Party Frames"] = "Afficher le joueur avec les cadres de groupe"
	L["Use Raid Frames instead of Party Frames"] = "Utiliser les cadres de raid au lieu des cadres de groupe"
	
	-- raid
	L["Use the grid layout for all Raid sizes"] = "utliser la mise en page Grid pour tout les raids"
end


--------------------------------------------------------------------------------------------------
--		FAQ
--------------------------------------------------------------------------------------------------
-- 	Even though most of these strings technically belong to their respective modules,
--		and not the FAQ interface, we still gather them all here for practical reasons.
do
	-- general
	L["FAQ"] = "FAQ"
	L["Frequently Asked Questions"] = "Foire aux questions"
	L["Clear All Tags"] = "Effacer tous les tags"
	L["Show the current FAQ"] = "Montrer la FAQ courante"
	L["Return to the listing"] = "Retour \195\160 la liste"
	L["Go to the options menu"] = "Aller au menu des options"
	
	-- core
	L["I wish to move something! How can I change frame positions?"] = "Je souhaite bouger quelque chose! Comment je peux changer la position des cadres?" 
	L["A lot of frames can be moved to custom positions. You can unlock them all for movement by typing |cFF4488FF/glock|r followed by the Enter key, and lock them with the same command. There are also multiple options available when right-clicking on the overlay of the movable frame."] = "Vous pouvez tout bouger, bloquer, d\195\169bloquer via |cFF4488FF/glock|r suivis de Entrer, il y a aussi plusieurs options quand vous cliquez-droit sur un cadre d\195\169bloquer."

	-- actionbars
	L["How do I change the currently active Action Page?"] = "Comment je peux changer la page d'action active?"
	L["There are no on-screen buttons to do this, so you will have to use keybinds. You can set the relevant keybinds in the Blizzard keybinding interface."] = "Vous pouvez r\195\169gler les raccourcis des pages d'action via l'interface des raccourcis de blizzard."
	L["How can I change the visible actionbars?"] = "Comment je peux changer les barres d'action visible?"
	L["You can toggle most actionbars by clicking the arrows located close to their corners. These arrows become visible when hovering over them with the mouse if you're not currently engaged in combat. You can also toggle the actionbars from the options menu, or by running the install tutorial by typing |cFF4488FF/install|r followed by the Enter key."] = "Vous pouvez Montrer/Masquer les barres d'action via les fl\195\168ches qui s'affiche dans les coins des barres au survol de la souris, ou via |cFF4488FF/install|r."
	L["How do I toggle the MiniMenu?"] = "Comment je fait pour activer le MiniMenu?"
	L["The MiniMenu can be displayed by typing |cFF4488FF/showmini|r followed by the Enter key, and |cFF4488FF/hidemini|r to hide it. You can also toggle it from the options menu or by running the install tutorial by typing |cFF4488FF/install|r."] = "Vous pouvez afficher le MiniMenu via |cFF4488FF/showmini|r, et le masquer via |cFF4488FF/hidemini|r."
	L["How can I move the actionbars?"] = "Comment je peux bouger les barres d'action?"
	L["Not all actionbars can be moved, as some are an integrated part of the UI layout. Most of the movable frames in the UI can be unlocked by typing |cFF4488FF/glock|r followed by the Enter key."] = "Vous ne pouvez pas bouger les barres d'action, la plupart des cadres se d\195\169bloque via |cFF4488FF/glock|r."
	
	-- actionbuttons
	L["How can I toggle keybinds and macro names on the buttons?"] = "Comment je peux activer le noms des macros et des raccourcis sur les boutons?"
	L["You can enable keybind display on the actionbuttons by typing |cFF4488FF/showhotkeys|r followed by the Enter key, and disable it with |cFF4488FF/hidehotkeys|r. Macro names can be toggled with the |cFF4488FF/shownames|r and |cFF4488FF/hidenames|r commands. All settings can also be changed in the options menu."] = "Pour voir les noms des raccourcis sur les boutons il faut utiliser ceci |cFF4488FF/showhotkeys|r, et cela pour les cacher |cFF4488FF/hidehotkeys|r. Pour afficher le nom des macros il faut taper ceci |cFF4488FF/shownames|r, et pour les masquer |cFF4488FF/shownames|r and |cFF4488FF/hidenames|r."
	
	-- auras
	L["How can I change how my buffs and debuffs look?"] = "Comment je peux changer la disposition de mes Buffs et debuffs?"
	L["You can change a lot of settings like the time display and the cooldown spiral in the options menu."] = "Vous pouvez changer beaucoup de param\195\168tres via le menu des options."
	L["Sometimes the weapon buffs don't display correctly!"] = "Quelques fois le buff de mes armes ne s'affichent pas correctement!"
	L["Correct. Sadly this is a bug in the tools Blizzard has given to us addon developers, and not something that is easily fixed. You'll simply have to live with it for now."] = "C'est un bug connus de l'outils Blizzard, et il faut faire avec pour l'instant."
	
	-- bags
	L["Sometimes when I choose to bypass a category, not all items are moved to the '%s' container, but some appear in others?"] = true
	L["Some items are put in the 'wrong' categories by Blizzard. Each category in the bag module has its own internal filter that puts these items in their category of they are deemed to belong there. If you bypass this category, the filter is also bypassed, and the item will show up in whatever category Blizzard originally put it in."] = true
	L["How can I change what categories and containers I see? I don't like the current layout!"] = true
	L["Categories can be quickly selected from the quickmenu available by clicking at the arrow next to the '%s' or '%s' containers."] = true
	L["You can change all the settings in the options menu as well as activate the 'all-in-one' layout easily!"] = true
	L["How can I disable the bags? I don't like them!"] = true
	L["All the modules can be enabled or disabled from within the options menu. You can locate the options menu from the button on the Game Menu, or by typing |cFF4488FF/gui|r followed by the Enter key."] = true
	
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
	local cmd = "|cFF4488FF/glock|r - V\195\169rouille/D\195\169bloque les cadres"
	cmd = cmd .. separator .. "|cFF4488FF/greset|r - r\195\169initialiser la position des cadres mobiles"
	cmd = cmd .. separator .. "|cFF4488FF/resetbars|r - r\195\169initialiser la position des barres d'action mobiles seulement"
	cmd = cmd .. separator .. "|cFF4488FF/resetbags|r - renvoie les sacs \195\160 leur position par d\195\169faut"
	cmd = cmd .. separator .. "|cFF4488FF/scalebags|r X - d\195\169finir l'\195\169chelle des sacs, ou X est un nombre compris de 1.0 \195\160 2.0"
	cmd = cmd .. separator .. "|cFF4488FF/compressbags|r - Activer la compression des emplacements de sac vide"
	cmd = cmd .. separator .. "|cFF4488FF/showsidebars|r, |cFF4488FF/hidesidebars|r - activer l'affichage des deux barres d'action du c\195\180t\195\169."
	cmd = cmd .. separator .. "|cFF4488FF/showrightbar|r, |cFF4488FF/hiderightbar|r - activer l'affichage le plus a droite des actionbar de c\195\180t\195\169."
	cmd = cmd .. separator .. "|cFF4488FF/showleftbar|r, |cFF4488FF/hideleftbar|r - activer l'affichage le plus a gauche des actionbar de c\195\180t\195\169."
	cmd = cmd .. separator .. "|cFF4488FF/showpet|r, |cFF4488FF/hidepet|r - activer l'affichage de la bare de pet"
	cmd = cmd .. separator .. "|cFF4488FF/showshift|r, |cFF4488FF/hideshift|r - activer l'affichage de la shift/stance/aspect actionbar"
	cmd = cmd .. separator .. "|cFF4488FF/showtotem|r, |cFF4488FF/hidetotem|r - activer l'affichage de la barre des totems"
	cmd = cmd .. separator .. "|cFF4488FF/showmini|r, |cFF4488FF/hidemini|r - activer l'affichage du mini/micromenu"
	cmd = cmd .. separator .. "|cFF4488FF/rl|r - recharger l'interface utilisateur"
	cmd = cmd .. separator .. "|cFF4488FF/gm|r - ouvrir le cadre d'aide"
	cmd = cmd .. separator .. "|cFF4488FF/showchatbrackets|r - voir les crochets autour du joueur- et les noms des cannaux dans le chat"
	cmd = cmd .. separator .. "|cFF4488FF/hidechatbrackets|r - masquer les crochets autour du joueur- et les noms des cannaux dans le chat"
	cmd = cmd .. separator .. "|cFF4488FF/chatmenu|r - ouvrir le menu du chat"
	cmd = cmd .. separator .. "|cFF4488FF/mapmenu|r - ouvrir le menu de la minimap du clic molette"
	cmd = cmd .. separator .. "|cFF4488FF/tt|r ou |cFF4488FF/wt|r - chuchoter a votre cible"
	cmd = cmd .. separator .. "|cFF4488FF/tf|r ou |cFF4488FF/wf|r - chuchoter a votre cible du focus"
	cmd = cmd .. separator .. "|cFF4488FF/showhotkeys|r, |cFF4488FF/hidehotkeys|r - activer les raccourcis sur les boutons d'action"
	cmd = cmd .. separator .. "|cFF4488FF/shownames|r, |cFF4488FF/hidenames|r - activer l'affichage du nom des macros sur les boutons d'action"
	cmd = cmd .. separator .. "|cFF4488FF/enableautorepair|r - activer la reparation automatique de votre armure"
	cmd = cmd .. separator .. "|cFF4488FF/disableautorepair|r - desactiver la reparation automatique de votre armure"
	cmd = cmd .. separator .. "|cFF4488FF/enableguildrepair|r - utiliser les fonds de la guilde pour reparer votre armure"
	cmd = cmd .. separator .. "|cFF4488FF/disableguildrepair|r - desactiver l'utilisation des fonds de la guilde pour reparer votre armure"
	cmd = cmd .. separator .. "|cFF4488FF/enableautosell|r - activer la vente automatique des loot de pauvre qualite"
	cmd = cmd .. separator .. "|cFF4488FF/disableautosell|r - desactiver la vente automatique des loot de pauvre qualite"
	cmd = cmd .. separator .. "|cFF4488FF/enabledetailedreport|r - montrer le rapport d\195\169tailler par objets vendus de qualit\195\169 communes"
	cmd = cmd .. separator .. "|cFF4488FF/disabledetailedreport|r - desactiver le rapport d\195\169tailler pour montrer seulement le total"
	cmd = cmd .. separator .. "|cFF4488FF/mainspec|r - activer votre specialisation principale"
	cmd = cmd .. separator .. "|cFF4488FF/offspec|r - activer votre specialisation secondaire"
	cmd = cmd .. separator .. "|cFF4488FF/togglespec|r - basculer entre vos deux specialisations"
	cmd = cmd .. separator .. "|cFF4488FF/ghelp|r - voir ce menu"
	L["chatcommandlist-separator"] = separator
	L["chatcommandlist"] = cmd
end


--------------------------------------------------------------------------------------------------
--		Keybinds Menu (Blizzard)
--------------------------------------------------------------------------------------------------
do
	L["Toggle Calendar"] = "Voir le Calendrier"
	L["Whisper focus"] = "Murmurer le focus"
	L["Whisper target"] = "Murmurer la cible"
end


--------------------------------------------------------------------------------------------------
--		Error Messages 
--------------------------------------------------------------------------------------------------
do
	L["Can't toggle Action Bars while engaged in combat!"] = "Vous ne pouvez pas basculer vers les barres d'action quand vous \195\170tes en combat!"
	L["Can't change Action Bar layout while engaged in combat!"] = "Vous ne pouvez pas changer la dispostion de votre barre d'action en combat!"
	L["Frames cannot be moved while engaged in combat"] = "Vous ne pouvez pas bouger les cadres en combat"
	L["Hiding movable frame anchors due to combat"] = "Cacher les ancres des cadres mobiles en raison du combat"
	L["UnitFrames cannot be configured while engaged in combat"] = "Les cadres d'unit\195\169 ne peuvent \195\170tre configur\195\169 en combat"
	L["Can't initialize bags while engaged in combat."] = "Impossible d'initialiser les sacs en combats."
	L["Please exit combat then re-open the bags!"] = "SVP quitter le combat, puis rouvrez les sacs!"
end


--------------------------------------------------------------------------------------------------
--		Core Messages
--------------------------------------------------------------------------------------------------
do
	L["Goldpaw"] = "|cFFFF7D0AGoldpaw|r" -- my class colored name. no changes needed here.
	L["The user interface needs to be reloaded for the changes to take effect. Do you wish to reload it now?"] = "l'interface utilisateur doit etre recharger pour que les changements prennet effet. Voulez-vous recharger maintenant?"
	L["You can reload the user interface at any time with |cFF4488FF/rl|r or |cFF4488FF/reload|r"] = "Vous pouvez recharger l'interface utilisateur nimporte quand avec |cFF4488FF/rl|r ou |cFF4488FF/reload|r"
	L["Can not apply default settings while engaged in combat."] = "Ne pas appliquer les parametres par defaut quand vous etes en combat"
	L["Show Talent Pane"] = "Voir le panneau des talents"
end

-- menu
do
	L["UI Scale"] = "Echelle de l'UI"
	L["Use UI Scale"] = "Utiliser l'echelle de l'interface"
	L["Check to use the UI Scale Slider, uncheck to use the system default scale."] = "Cochez pour utiliser le curseur de l'echelle de l'UI, decochez pour utiliser l'echelle par defaut."
	L["Changes the size of the game’s user interface."] = "changer la taille de l'interface utilisateur du jeu."
	L["Using custom UI scaling is not recommended. It will produce fuzzy borders and incorrectly sized objects."] = "Utiliser l'echelle de l'interface n'est pas recommander. Cela produiras des problemes de bordures et des tailles d'objets incorrect."
	L["Apply the new UI scale."] = "Appliquer la nouvelle echelle de l'UI"
	L["Load Module"] = "Module de charge"
	L["Module Selection"] = "Selection des modules"
	L["Choose which modules should be loaded, and when."] = "choisir quel module sera actif"
	L["Never load this module"] = "Ne jamais charger ce module"
	L["Load this module unless an addon with similar functionality is detected"] = "Chargez ce module sauf si un addon avec une fonctionnalite similaire est detecte"
	L["Always load this module, regardles of what other addons are loaded"] = "Toujours charger ce module, independamment des autres addons"
	L["(In Development)"] = "En developpement"
end

-- install tutorial
do
	-- general install tutorial messages
	L["Skip forward to the next step in the tutorial."] = "Avancer \195\160 l'\195\169tape suivante dans ce tutoriel."
	L["Previous"] = "Precedent"
	L["Go backwards to the previous step in the tutorial."] = "Revenir en arri\195\168re \195\160 l'\195\169tape pr\195\169cedente."
	L["Skip this step"] = "Passer cette etape"
	L["Apply the currently selected settings"] = "Appliquer les param\195\168tres selectionn\195\169s"
	L["Procede with this step of the install tutorial."] = "Proc\195\169der \195\160 cette \195\169tape du tutoriel d'installation."
	L["Cancel the install tutorial."] = "Annuler le tutoriel d'installation."
	L["Setup aborted. Type |cFF4488FF/install|r to restart the tutorial."] = "Configuration abandonn\195\169e. Faite | cFF4488FF/install | r pour red\195\169marrer le tutoriel."
	L["Setup aborted because of combat. Type |cFF4488FF/install|r to restart the tutorial."] = "Configuration interrompue \195\160 cause du combat. Faite | cFF4488FF/install | r pour red\195\169marrer le tutoriel."
	L["This is recommended!"] = "Ceci est recommand\195\169!"

	-- core module's install tutorial
	L["This is the first time you're running %s on this character. Would you like to run the install tutorial now?"] = "C'est la premi\195\168re fois que vous utilisez %s sur ce personnage. Aimeriez-vous executer le tutorial d'installation maintenant?"
	L["Using custom UI scaling will distort graphics, create fuzzy borders, and otherwise ruin frame proportions and positions. It is adviced to always leave this off, as it will seriously affect the entire layout of the UI in unpredictable ways."] = "Utiliser l'\195\169chelle de l'interface d\195\169forme l'affichage, je vous conseille de laisser par d\195\169faut."
	L["UI scaling is currently activated. Do you wish to disable this?"] = "l'\195\169chelle de l'UI est actuellment active. Voulez-vous la d\195\169sactiver?"
	L["|cFFFF0000UI scaling is currently deactivated, which is the recommended setting, so we are skipping this step.|r"] = "|cFFFF0000UI l'\195\169chelle est actuellement d\195\169sactiver, ce sont les param\195\168tres recommand\195\169, vous pouvez sauter cette \195\169tape.|r"
end

-- general 
-- basically a bunch of very common words, phrases and abbreviations
-- that several modules might have need for
do
	L["R"] = "R" -- R as in Red
	L["G"] = "G" -- G as in Green
	L["B"] = "B" -- B as in Blue
	L["A"] = "A" -- A as in Alpha (for opacity/transparency)

	L["m"] = "m" -- minute
	L["s"] = "s" -- second
	L["h"] = "h" -- hour
	L["d"] = "d" -- day

	L["Alt"] = "Alt" -- the ALT key
	L["Ctrl"] = "Ctrl" -- the CTRL key
	L["Shift"] = "Shift" -- the SHIFT key
	L["Mouse Button"] = "Bouton de Souris"

	L["Always"] = "Toujours"
	L["Apply"] = "Appliquer"
	L["Bags"] = "Sacs"
	L["Bank"] = "Banque"
	L["Bottom"] = "En bas"
	L["Cancel"] = "Annuler"
	L["Categories"] = "Cat\195\169gories"
	L["Close"] = "Fermer"
	L["Continue"] = "Continuer"
	L["Copy"] = "Copier" -- to copy. the verb.
	L["Default"] = "Par d\195\169faut"
	L["Elements"] = "\195\169l\195\169ments" -- like elements in a frame, not as in fire, ice etc
	L["Free"] = "Libre" -- free space in bags and bank
	L["General"] = "G\195\169n\195\169ral" -- general as in general info
	L["Ghost"] = "Ghost" -- when you are dead and have released your spirit
	L["Hide"] = "Cacher" -- to hide something. not hide as in "thick hide".
	L["Lock"] = "Verouiller" -- to lock something, like a frame. the verb.
	L["Main"] = "Tout En Un" -- used for Main chat frame, Main bag, etc
	L["Next"] = "Suivant"
	L["Never"] = "Jamais"
	L["No"] = "Non"
	L["Okay"] = "OK"
	L["Open"] = "Ouvrir"
	L["Paste"] = "Coller" -- as in copy & paste. the verb.
	L["Reset"] = "R\195\169initialiser"
	L["Rested"] = "Reposer" -- when you are rested, and will recieve 200% xp from kills
	L["Scroll"] = "Parchemin" -- "Scroll" as in "Scroll of Enchant". The noun, not the verb.
	L["Show"] = "Montrer"
	L["Skip"] = "Passer"
	L["Top"] = "En haut"
	L["Total"] = "Totale"
	L["Visibility"] = "Visibiliter"
	L["Yes"] = "Oui"

	L["Requires the UI to be reloaded!"] = "Requiert que l'UI soit recharger"
	L["Changing this setting requires the UI to be reloaded in order to complete."] = "La modification de ce param\195\168tre n\195\169cessite que l'UI soit recharger."
end

-- gFrameHandler replacements (/glock)
do
	L["<Left-Click and drag to move the frame>"] = "<Clic-gauche pour cliquer d\195\169poser le cadre>" 
	L["<Left-Click+Shift to lock into position>"] = "<Clic-gauche + shift pour verouiller la position>"
	--L["<Right-Click for options>"] = true -- the panel module supplies this one
	L["Center horizontally"] = "Centrer horizontalement"
	L["Center vertically"] = "Centrer verticalement"
end

-- visible module names
do
	L["ActionBars"] = "Barres d'action"
	L["ActionButtons"] = "Boutons d'action"
	L["Auras"] = "Auras"
	L["Bags"] = "Sacs"
	L["Buffs & Debuffs"] = "Buffs & Debuffs"
	L["Castbars"] = "Barres de cast"
	L["Core"] = true
	L["Chat"] = true
	L["Combat"] = true
	L["CombatLog"] = "Journal de combat"
	L["Errors"] = "Erreurs"
	L["Loot"] = true
	L["Merchants"] = "Marchands"
	L["Minimap"] = true
	L["Nameplates"] = true
	L["Quests"] = "Qu\195\170tes"
	L["Timers"] = true
	L["Tooltips"] = "Info-bulles"
	L["UI Panels"] = true
	L["UI Skinning"] = true
	L["UnitFrames"] = "Cadres d'unit\195\169"
		L["PartyFrames"] = "Cadres de groupe"
		L["ArenaFrames"] = "Cadres d'ar\195\168ne"
		L["BossFrames"] = "Cadres de boss"
		L["RaidFrames"] = "Cadres de raid"
		L["MainTankFrames"] = "Cadres des tank principaux"
	L["World Status"] = "Statut du Monde"
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

	L["_ui_description_"] = "%s est une interface utilisateur compl\195\168te pour World of Warcraft, faite pour remplacer l'interface par d\195\169faut de blizzard. La résolution minimun support\195\169e est de 1280 pixels de largeur, mais un minimun de 1440 pixels est recommand\195\169.|n|nL'interface utilisateur est \195\169crite et maintenu par Lars Norberg, qui joue un Druide Feral %s sur le serveur PvE Draenor EU, c\195\180t\195\169 Alliance."
	
	L["_install_guide_"] = "En quelques petites \195\169tapes vous serez guid\195\169 pour configurer plusieurs modules de l'interface utilisateur. Vous pouvez toujours changer les options depuis le menu GUI, ou avec |cFF4488FF/gui|r."
	
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

