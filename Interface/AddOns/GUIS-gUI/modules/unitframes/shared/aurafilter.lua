--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

-- Lua API
local pairs, select = pairs, select

-- WoW API
local GetSpellInfo = GetSpellInfo
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitPlayerControlled = UnitPlayerControlled

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local R = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: UnitFrameAuras")

local class = select(2, UnitClass("player"))
local race = select(2, UnitRace("player"))

R.AuraList = {}
R.PetAuraList = {}

local addAura = function(spellID, v)
	local spellName = GetSpellInfo(spellID)
	
	-- storing all relevant auras by name instead of ID
	if (spellName) then
		if not(R.AuraList[spellName]) then
			R.AuraList[spellName] = v
		end
	else
		-- in case of an invalid/deprecated spellID, we print it out for easier debugging
		-- print(spellID)
	end
end

local addAuras = function(auras) 
	for spellID, v in pairs(auras) do 
		addAura(spellID, v)
	end 
end

local addPetAuras = function(auras)
	for spellID, v in pairs(auras) do 
		local spellName = GetSpellInfo(spellID)
		
		-- storing all relevant auras by name instead of ID
		if (spellName) then
			if not(R.PetAuraList[spellName]) then
				R.PetAuraList[spellName] = v
			end
		else
			-- in case of an invalid/deprecated spellID, we print it out for easier debugging
			-- print(spellID)
		end
	end 
end

-- give other modules access to adding debuffs
R.addAura = addAura
R.addAuras = addAuras
R.addPetAuras = addPetAuras

--[[
	1 = by anyone on anyone
	2 = by player on anyone
	3 = by anyone on friendly
	4 = by anyone on player
]]--

------------------------------------------------------------------------
--	Stuff we always want to see in PvP
------------------------------------------------------------------------
addAuras({
	-- damage boosts
	[90355] = 1; -- Ancient Hysteria [hunter core hound]
	[26297] = 1; -- Berserking
	[2825]  = 1; -- Bloodlust
	[32182] = 1; -- Heroism
	[10060] = 1; -- Power Infusion
	[80353] = 1; -- Time Warp
	[49016] = 1; -- Unholy Frenzy
	
	-- defensive/shields
	[19263] = 1; -- Deterrence
	[1022]  = 1; -- Hand of Protection
	[33206] = 1; -- Pain Suppression
	[467]   = 1; -- Thorns
	
	-- regenerative buffs
	[29166] = 1; -- Innervate

	-- disarm effects
	[50541] = 1; -- Clench (hunter scorpid)
	[676]   = 1; -- Disarm (warrior)
	[51722] = 1; -- Dismantle (rogue)
	[64058] = 1; -- Psychic Horror (priest)
	[91644] = 1; -- Snatch (hunter bird of prey)

	-- silencing effects
	[25046] = 1; -- Arcane Torrent (blood elf)
	[31935] = 1; -- Avenger's Shield (paladin)
	[1330]  = 1; -- Garrote - Silence (rogue)
	[50479] = 1; -- Nether Shock (hunter nether ray)
	[15487] = 1; -- Silence (priest)
	[18498] = 1; -- Silenced - Gag Order (warrior)
	[18469] = 1; -- Silenced - Improved Counterspell (mage)
	[18425] = 1; -- Silenced - Improved Kick (rogue)
	[34490] = 1; -- Silencing Shot (hunter)
	[81261] = 1; -- Solar Beam (druid)
	[24259] = 1; -- Spell Lock (warlock felhunter)
	[47476] = 1; -- Strangulate (death knight)

	-- spell-locks
	[2139]  = 1; -- Counterspell (mage)
	[1766]  = 1; -- Kick (rogue)
	[47528] = 1; -- Mind Freeze (death knight)
	[6552]  = 1; -- Pummel (warrior)
	[26090] = 1; -- Pummel (hunter gorilla)
	[50318] = 1; -- Serenity Dust (hunter moth)
	[80964] = 1; -- Skull Bash (Bear) (druid)
	[80965] = 1; -- Skull Bash (Cat) (druid)
	[57994] = 1; -- Wind Shear (shaman)
	
	-- crowd control
	[710]   = 1; -- Banish
	[76780] = 1; -- Bind Elemental
	[33786] = 1; -- Cyclone
	[339]   = 1; -- Entangling Roots
	[5782]  = 1; -- Fear
	[3355]  = 1; -- Freezing Trap 
	[51514] = 1; -- Hex
	[2637]  = 1; -- Hibernate
	[118]   = 1; -- Polymorph
	[61305] = 1; -- Polymorph [Black Cat]
	[28272] = 1; -- Polymorph [Pig]
	[61721] = 1; -- Polymorph [Rabbit]
	[61780] = 1; -- Polymorph [Turkey]
	[28271] = 1; -- Polymorph [Turtle]
	[20066] = 1; -- Repentance
	[6770]  = 1; -- Sap
	[6358]  = 1; -- Seduction
	[9484]  = 1; -- Shackle Undead
	[10326] = 1; -- Turn Evil
	[20549] = 1; -- War Stomp
	[19386] = 1; -- Wyvern Sting
})

------------------------------------------------------------------------
--	Taunts
------------------------------------------------------------------------
if (class == "DEATHKNIGHT") or (class == "DRUID") or (class == "PALADIN") or (class == "WARRIOR") then addAuras({
	[5209]  = 1; -- Challenging Roar
	[1161]  = 1; -- Challenging Shout
	[56222] = 1; -- Dark Command
	[57604] = 1; -- Death Grip 
	[20736] = 1; -- Distracting Shot
	[39270] = 1; -- Growl
	[62124] = 1; -- Hand of Reckoning
	[31790] = 1; -- Righteous Defense
	[355]   = 1; -- Taunt
	[58857] = 1; -- Twin Howl [shaman spirit wolves]
}) end

------------------------------------------------------------------------
--	Enemy Damage Dealt Reductions
------------------------------------------------------------------------
-- attack speed reduced
if (class == "WARRIOR") then addAuras({
	[54404] = 1; -- Dust Cloud [hunter tallstrider]
	[8042]  = 1; -- Earth Shock
	[55095] = 1; -- Frost Fever
	[58179] = 1; -- Infected Wounds [Rank 1]
	[58180] = 1; -- Infected Wounds [Rank 2]
	[68055] = 1; -- Judgements of the Just
	[14251] = 1; -- Riposte
	[90315] = 1; -- Tailspin [hunter fox]
	[6343]  = 1; -- Thunder Clap
}) end

-- casting speed reduced
if (class == "MAGE") or (class == "ROGUE") or (class == "WARLOCK") then addAuras({
	[1714]  = 1; -- Curse of Tongues
	[58604] = 1; -- Lava Breath [hunter core hound]
	[5760]  = 1; -- Mind-Numbing Poison
	[31589] = 1; -- Slow
	[50274] = 1; -- Spore Cloud [hunter sporebat]
}) end

-- physical damage dealt reduced
if (class == "DEATHKNIGHT") or (class == "DRUID") or (class == "WARRIOR") then addAuras({
	[702]   = 1; -- Curse of Weakness
	[99]    = 1; -- Demoralizing Roar
	[50256] = 1; -- Demoralizing Roar [hunter bear]
	[1160]  = 1; -- Demoralizing Shout
	[81130] = 1; -- Scarlet Fever
	[26017] = 1; -- Vindication
}) end

------------------------------------------------------------------------
--	Enemy Damage Received Boosts
------------------------------------------------------------------------
-- armor reduced
if (class == "DRUID") or (class == "WARRIOR") then addAuras({
	[35387] = 1; -- Corrosive Spit [hunter serpent]
	[91565] = 1; -- Faerie Fire
	[8647]  = 1; -- Expose Armor
	[7386]  = 1; -- Sunder Armor
	[50498] = 1; -- Tear Armor [hunter raptor]
}) end

-- bleed damage taken increased
if (class == "DRUID") or (class == "ROGUE") then addAuras({
	[35290] = 1; -- Gore [hunter boar] 
	[16511] = 1; -- Hemorrhage
	[33878] = 1; -- Mangle [Bear Form]
	[33876] = 1; -- Mangle [Cat Form]
	[57386] = 1; -- Stampede [hunter rhino]
	[50271] = 1; -- Tendon Rip [hunter hyena]
	[46857] = 1; -- Trauma <== Blood Frenzy
}) end

-- healing effects reduced
if (class == "HUNTER") or (class == "ROGUE") or (class == "WARRIOR") then addAuras({
	[56112] = 1; -- Furious Attacks
	[48301] = 1; -- Mind Trauma <== Improved Mind Blast
	[30213] = 1; -- Legion Strike [warlock felguard]
	[54680] = 1; -- Monstrous Bite [hunter devilsaur]
	[12294] = 1; -- Mortal Strike
	[82654] = 1; -- Widow Venom
	[13218] = 1; -- Wound Poison
}) end

------------------------------------------------------------------------
-- Racials
------------------------------------------------------------------------
if (race == "Draenei") then addAuras({
	[59545] = 4; -- Gift of the Naaru (death knight)
	[59543] = 4; -- Gift of the Naaru (hunter)
	[59548] = 4; -- Gift of the Naaru (mage)
	[59542] = 4; -- Gift of the Naaru (paladin)
	[59544] = 4; -- Gift of the Naaru (priest)
	[59547] = 4; -- Gift of the Naaru (shaman)
	[28880] = 4; -- Gift of the Naaru (warrior)
	
}) elseif (race == "Dwarf") then addAuras({
	[20594] = 4; -- Stoneform
	
}) elseif (race == "NightElf") then addAuras({
	[58984] = 4; -- Shadowmeld
	
}) elseif (race == "Orc") then addAuras({
	[20572] = 4; -- Blood Fury (attack power)
	[33702] = 4; -- Blood Fury (spell power)
	[33697] = 4; -- Blood Fury (attack power and spell damage)
	
}) elseif (race == "Scourge") then addAuras({
	[7744]  = 4; -- Will of the Forsaken
	
}) elseif (race == "Tauren") then addAuras({
	[20549] = 1; -- War Stomp
	
}) elseif (race == "Troll") then addAuras({
	[26297] = 1; -- Berserking
	
}) elseif (race == "Worgen") then addAuras({
	[68992] = 4; -- Darkflight
}) end

------------------------------------------------------------------------
--	Death Knight
------------------------------------------------------------------------
if (class == "DEATHKNIGHT") then addAuras({
	[45524] = 1; -- Chains of Ice
	[49203] = 1; -- Hungering Cold
	[49016] = 1; -- Unholy Frenzy

	[55078] = 2; -- Blood Plague
	[77606] = 2; -- Dark Simulacrum
	[43265] = 2; -- Death and Decay
	[65142] = 2; -- Ebon Plague
	[55095] = 2; -- Frost Fever
	[81130] = 2; -- Scarlet Fever
	[50536] = 2; -- Unholy Blight 

	[48707] = 4; -- Anti-Magic Shell
	[81141] = 4; -- Blood Swarm <== Crimson Scourge
	[49222] = 4; -- Bone Shield
	[81256] = 4; -- Dancing Rune Weapon
	[59052] = 4; -- Freezing Fog <== Rime
	[48792] = 4; -- Icebound Fortitude
	[51124] = 4; -- Killing Machine
	[49039] = 4; -- Lichborne
	[51271] = 4; -- Pillar of Frost
	[50421] = 4; -- Scent of Blood
	[81340] = 4; -- Sudden Doom
	[55233] = 4; -- Vampiric Blood
	[81162] = 4; -- Will of the Necropolis 
}) end

------------------------------------------------------------------------
--	Druid
------------------------------------------------------------------------
if (class == "DRUID") then addAuras({
	[77764] = 1; -- Stampeding Roar
	[467]   = 1; -- Thorns

	[5211]  = 2; -- Bash
	[33786] = 2; -- Cyclone
	[339]   = 2; -- Entangling Roots
	[16979] = 2; -- Feral Charge
	[45334] = 2; -- Feral Charge Effect [Bear Form]
	[61138] = 2; -- Feral Charge - Cat 
	[2637]  = 2; -- Hibernate
	[5570]  = 2; -- Insect Swarm
	[33745] = 2; -- Lacerate
	[33763] = 2; -- Lifebloom
	[94447] = 2; -- Lifebloom [Tree of Life version]
	[22570] = 2; -- Maim
	[8921]  = 2; -- Moonfire
	[9005]  = 2; -- Pounce
	[9007]  = 2; -- Pounce Bleed
	[1822]  = 2; -- Rake
	[8936]  = 2; -- Regrowth
	[774]   = 2; -- Rejuvenation
	[1079]  = 2; -- Rip
	[93402] = 2; -- Sunfire
	[77758] = 2; -- Thrash
	[48438] = 2; -- Wild Growth

	[22812] = 4; -- Barkskin
	[50334] = 4; -- Berserk
	[16870] = 4; -- Clearcasting <== Omen of Clarity
	[1850]  = 4; -- Dash
	[5229]  = 4; -- Enrage
	[48518] = 4; -- Eclipse (Lunar)
	[48517] = 4; -- Eclipse (Solar)
	[22842] = 4; -- Frenzied Regeneration
	[81093] = 4; -- Fury of Stormrage
	[81192] = 4; -- Lunar Shower
	[16886] = 4; -- Nature's Grace
	[16689] = 4; -- Nature's Grasp
	[17116] = 4; -- Nature's Swiftness
	[80951] = 4; -- Pulverize
	[69369] = 4; -- Predator's Swiftness (clearcast from Predatory Strikes)
	[52610] = 4; -- Savage Roar
	[93400] = 4; -- Shooting Stars
	[81021] = 4; -- Stampede [Ravage effect]
	[81022] = 4; -- Stampede [Ravage effect]
	[61336] = 4; -- Survival Instincts
	[5217]  = 4; -- Tiger's Fury
	[33891] = 4; -- Tree of Life
	[61391] = 4; -- Typhoon

}) end

------------------------------------------------------------------------
--	Hunter
------------------------------------------------------------------------
if (class == "HUNTER") then addAuras({
	[1130]  = 1; -- Hunter's Mark
	[88691] = 1; -- Marked for Death
	[82654] = 1; -- Widow Venom

	[50433] = 2; -- Ankle Crack [crocolisk]
	[19574] = 2; -- Bestial Wrath
	[3674]  = 2; -- Black Arrow
	[35101] = 2; -- Concussive Barrage
	[5116]  = 2; -- Concussive Shot
	[19306] = 2; -- Counterattack
	[20736] = 2; -- Distracting Shot
	[64808] = 2; -- Entrapment
	[19185] = 2; -- Entrapment 
	[53301] = 2; -- Explosive Shot
	[13812] = 2; -- Explosive Trap  43446
	[1539]  = 2; -- Feed Pet
	[3355]  = 2; -- Freezing Trap  31932 43415 55041
	[13810] = 2; -- Ice Trap
	[13797] = 2; -- Immolation Trap 
	[51740] = 2; -- Immolation Trap Effect
	[24394] = 2; -- Intimidation
	[136]   = 2; -- Mend Pet
	[63468] = 2; -- Piercing Shots
	[1513]  = 2; -- Scare Beast
	[19503] = 2; -- Scatter Shot
	[1978]  = 2; -- Serpent Sting
	[2974]  = 2; -- Wing Clip
	[19386] = 2; -- Wyvern Sting

	[82921] = 4; -- Bombardment
	[51755] = 4; -- Camouflage
	[15571] = 4; -- Dazed <== Aspect of the Cheetah
	[19263] = 4; -- Deterrence
	[5384]  = 4; -- Feign Death
	[82692] = 4; -- Focus Fire
	[56453] = 4; -- Lock and Load
	[34477] = 4; -- Misdirection
	[3045]  = 4; -- Rapid Fire
	[35099] = 4; -- Rapid Killing
	[82925] = 4; -- Ready, Set, Aim...
	[34692] = 4; -- The Beast Within
	[77769] = 4; -- Trap Launcher
}) end

------------------------------------------------------------------------
--	Mage
------------------------------------------------------------------------
if (class == "MAGE") then addAuras({
	[11113] = 2; -- Blast Wave
	[12486] = 2; -- Chilled <== Blizzard <== Ice Shards 
	[7321]  = 2; -- Chilled <== Frost Aura
	[83853] = 2; -- Combustion
	[120]   = 2; -- Cone of Cold
	[22959] = 2; -- Critical Mass
	[44572] = 2; -- Deep Freeze
	[31661] = 2; -- Dragon's Breath
	[54646] = 2; -- Focus Magic
	[122]   = 2; -- Frost Nova
	[116]   = 2; -- Frostbolt
	[44614] = 2; -- Frostfire Bolt
	[12654] = 2; -- Ignite
	[12355] = 2; -- Impact
	[83301] = 2; -- Improved Cone of Cold [Rank 1]
	[83302] = 2; -- Improved Cone of Cold [Rank 2]
	[44457] = 2; -- Living Bomb
	[118]   = 2; -- Polymorph
	[61305] = 2; -- Polymorph [Black Cat]
	[28272] = 2; -- Polymorph [Pig]
	[61721] = 2; -- Polymorph [Rabbit]
	[61780] = 2; -- Polymorph [Turkey]
	[28271] = 2; -- Polymorph [Turtle]
	[82691] = 2; -- Ring of Frost
	[31589] = 2; -- Slow
	[130]   = 2; -- Slow Fall

	[36032] = 4; -- Arcane Blast
	[79683] = 4; -- Arcane Missiles!
	[12042] = 4; -- Arcane Power
	[31643] = 4; -- Blazing Speed
	[57761] = 4; -- Brain Freeze
	[44544] = 4; -- Fingers of Frost
	[48108] = 4; -- Hot Streak
	[11426] = 4; -- Ice Barrier
	[45438] = 4; -- Ice Block
	[12472] = 4; -- Icy Veins
	[64343] = 4; -- Impact
	[66]    = 4; -- Invisibility
	[543]   = 4; -- Mage Ward
	[1463]  = 4; -- Mana Shield
	[12043] = 4; -- Presence of Mind
}) end

------------------------------------------------------------------------
--	Paladin
------------------------------------------------------------------------
if (class == "PALADIN") then addAuras({
	[70940] = 1; -- Divine Guardian
	[25771] = 1; -- Forbearance
	[1044]  = 1; -- Hand of Freedom
	[1022]  = 1; -- Hand of Protection
	[6940]  = 1; -- Hand of Sacrifice
	[1038]  = 1; -- Hand of Salvation

	[31935] = 2; -- Avenger's Shield
	[31803] = 2; -- Censure <== Seal of Truth
	[853]   = 2; -- Hammer of Justice
	[2812]  = 2; -- Holy Wrath
	[20066] = 2; -- Repentance
	[10326] = 2; -- Turn Evil

	[86701] = 4; -- Ancient Crusader <== Guardian of Ancient Kings
	[86657] = 4; -- Ancient Guardian <== Guardian of Ancient Kings
	[86674] = 4; -- Ancient Healer <== Guardian of Ancient Kings
	[31850] = 4; -- Ardent Defender
	[31821] = 4; -- Aura Mastery
	[31884] = 4; -- Avenging Wrath
	[88819] = 4; -- Daybreak
	[85509] = 4; -- Denounce
	[31842] = 4; -- Divine Favor
	[54428] = 4; -- Divine Plea
	[498]   = 4; -- Divine Protection
	[90174] = 4; -- Divine Purpose
	[642]   = 4; -- Divine Shield
	[82327] = 4; -- Holy Radiance
	[20925] = 4; -- Holy Shield
	[54149] = 4; -- Infusion of Light
	[84963] = 4; -- Inquisition
	[53651] = 3; -- Light's Beacon
	[85433] = 4; -- Sacred Duty
	[85497] = 4; -- Speed of Light [haste effect]
	[59578] = 4; -- The Art of War
	[85696] = 4; -- Zealotry
}) end

------------------------------------------------------------------------
--	Priest
------------------------------------------------------------------------
if (class == "PRIEST") then addAuras({
	[6346]  = 1; -- Fear Ward
	[453]   = 1; -- Mind Soothe
	[17]    = 1; -- Power Word: Shield
	[6788]  = 1; -- Weakened Soul

	[2944]  = 2; -- Devouring Plague
	[77613] = 2; -- Grace
	[47788] = 2; -- Guardian Spirit
	[14914] = 2; -- Holy Fire
	[88625] = 2; -- Holy Word: Chastise
	[605]   = 2; -- Mind Control
	[87178] = 2; -- Mind Spike
	[33206] = 2; -- Pain Suppression
	[87193] = 2; -- Paralysis [Rank 1]
	[87194] = 2; -- Paralysis [Rank 2]
	[10060] = 2; -- Power Infusion
	[33076] = 2; -- Prayer of Mending
	[64044] = 2; -- Psychic Horror
	[8122]  = 2; -- Psychic Scream
	[139]   = 2; -- Renew
	[9484]  = 2; -- Shackle Undead
	[589]   = 2; -- Shadow Word: Pain
	[34914] = 2; -- Vampiric Touch

	[14751] = 4; -- Chakra
	[81208] = 4; -- Chakra: Heal
	[81206] = 4; -- Chakra: Prayer of Healing
	[81207] = 4; -- Chakra: Renew
	[81209] = 4; -- Chakra: Smite
	[87117] = 4; -- Dark Evangelism 
	[87118] = 4; -- Dark Evangelism 
	[47585] = 4; -- Dispersion
	[81660] = 4; -- Evangelism 
	[81661] = 4; -- Evangelism 
	[586]   = 4; -- Fade
	[89485] = 4; -- Inner Focus
	[81292] = 4; -- Mind Melt [Rank 1]
	[87160] = 4; -- Mind Melt [Rank 2]
	[63735] = 4; -- Serendipity
	[77487] = 4; -- Shadow Orb
	[88688] = 4; -- Surge of Light
}) end

------------------------------------------------------------------------
--	Rogue
------------------------------------------------------------------------
if (class == "ROGUE") then addAuras({
	[8647]  = 1; -- Expose Armor
	[14251] = 1; -- Riposte

	[51585] = 2; -- Blade Twisting
	[2094]  = 2; -- Blind
	[1833]  = 2; -- Cheap Shot
	[44289] = 2; -- Crippling Poison 
	[2818]  = 2; -- Deadly Poison 
	[26679] = 2; -- Deadly Throw
	[84747] = 2; -- Deep Insight
	[51722] = 2; -- Dismantle
	[703]   = 2; -- Garrote
	[1776]  = 2; -- Gouge
	[408]   = 2; -- Kidney Shot
	[84617] = 2; -- Revealing Strike
	[1943]  = 2; -- Rupture
	[79140] = 2; -- Vendetta
	[13218] = 2; -- Wound Poison 

	[13750] = 4; -- Adrenaline Rush
	[13877] = 4; -- Blade Flurry
	[31230] = 4; -- Cheat Death
	[31224] = 4; -- Cloak of Shadows
	[14177] = 4; -- Cold Blood
	[84590] = 4; -- Deadly Momentum
	[5277]  = 4; -- Evasion
	[73651] = 4; -- Recuperate
	[51713] = 4; -- Shadow Dance
	[5171]  = 4; -- Slice and Dice
	[2983]  = 4; -- Sprint
	[57934] = 4; -- Tricks of the Trade
}) end

------------------------------------------------------------------------
--	Shaman
------------------------------------------------------------------------
if (class == "SHAMAN") then addAuras({
	[3600]  = 1; -- Earthbind
	[56425] = 1; -- Earth's Grasp 
	[89523] = 1; -- Grounding Totem [reflect]
	[8178]  = 1; -- Grounding Totem Effect
	[77661] = 1; -- Searing Flames 
	[37976] = 1; -- Stoneclaw Stun

	[76780] = 2; -- Bind Elemental
	[974]   = 2; -- Earth Shield
	[8042]  = 2; -- Earth Shock
	[8050]  = 2; -- Flame Shock
	[8056]  = 2; -- Frost Shock
	[8034]  = 2; -- Frostbrand Attack 
	[51514] = 2; -- Hex
	[61295] = 2; -- Riptide
	[17364] = 2; -- Stormstrike
	[63685] = 2; -- Freeze (from Frozen Power)
	
	[16166] = 4; -- Elemental Mastery [instant cast]
	[77800] = 4; -- Focused Insight
	[65264] = 4; -- Lava Flows 
	[51530] = 4; -- Maelstrom Weapon
	[31616] = 4; -- Nature's Guardian
	[16188] = 4; -- Nature's Swiftness
	[30823] = 4; -- Shamanistic Rage
	[79206] = 4; -- Spiritwalker's Grace
	[53390] = 4; -- Tidal Waves
	[73685] = 4; -- Unleash Life (from Unleash Elements with Earthliving Weapon)

}) end

------------------------------------------------------------------------
--	Warlock
------------------------------------------------------------------------
if (class == "WARLOCK") then addAuras({
	[18233] = 1; -- Curse of Exhaustion
	[1490]  = 1; -- Curse of the Elements
	[1714]  = 1; -- Curse of Tongues
	[702]   = 1; -- Curse of Weakness
	[17800] = 1; -- Shadow and Flame 
	[20707] = 1; -- Soulstone Resurrection

	[18118] = 2; -- Aftermath
	[93986] = 2; -- Aura of Foreboding [stun effect]  93975
	[93987] = 2; -- Aura of Foreboding [root effect]  93974
	[980]   = 2; -- Bane of Agony
	[603]   = 2; -- Bane of Doom
	[80240] = 2; -- Bane of Havoc
	[710]   = 2; -- Banish
	[172]   = 2; -- Corruption
	[18223] = 2; -- Curse of Exhaustion
	[85767] = 2; -- Dark Intent
	[5782]  = 2; -- Fear
	[48181] = 2; -- Haunt
	[5484]  = 2; -- Howl of Terror
	[348]   = 2; -- Immolate
	[60947] = 2; -- Nightmare <== Improved Fear  60946
	[27243] = 2; -- Seed of Corruption
	[47960] = 2; -- Shadowflame  47897
	[30283] = 2; -- Shadowfury
	[63311] = 2; -- Shadowsnare <== Glyph of Shadowflame
	[18469] = 2; -- Silenced - Improved Counterspell
	[30108] = 2; -- Unstable Affliction
	
	[54277] = 4; -- Backdraft
	[34936] = 4; -- Backlash
	[79462] = 4; -- Demon Soul: Felguard
	[79460] = 4; -- Demon Soul: Felhunter
	[79459] = 4; -- Demon Soul: Imp
	[75463] = 4; -- Demon Soul: Succubus
	[79464] = 4; -- Demon Soul: Voidwalker
	[88448] = 4; -- Demonic Rebirth
	[47283] = 4; -- Empowered Imp
	[64371] = 4; -- Eradication
	[50589] = 4; -- Immolation Aura
	[47241] = 4; -- Metamorphosis
	[71165] = 4; -- Molten Core
	[57373] = 4; -- Nether Protection (Arcane)
	[54371] = 4; -- Nether Protection (Fire)
	[54372] = 4; -- Nether Protection (Frost)
	[54370] = 4; -- Nether Protection (Holy)
	[54375] = 4; -- Nether Protection (Nature)
	[54374] = 4; -- Nether Protection (Shadow)
	[91711] = 4; -- Nether Ward
	[7812]  = 4; -- Sacrifice
	[17941] = 4; -- Shadow Trance <== Nightfall
	[6229]  = 4; -- Shadow Ward
	[86211] = 4; -- Soul Swap
	[74434] = 4; -- Soulburn
}) end

------------------------------------------------------------------------
--	Warrior
------------------------------------------------------------------------
if (class == "WARRIOR") then addAuras({
	[1160]  = 1; -- Demoralizing Shout
	[676]   = 1; -- Disarm
	[64382] = 1; -- Shattering Throw

	[86346] = 2; -- Colossus Smash
	[12809] = 2; -- Concussion Blow
	[1715]  = 2; -- Hamstring
	[3411]  = 2; -- Intervene
	[20511] = 2; -- Intimidating Shout
	[12294] = 2; -- Mortal Strike
	[12323] = 2; -- Piercing Howl
	[94009] = 2; -- Rend
	[46968] = 2; -- Shockwave
	[7386]  = 2; -- Sunder Armor
	[85388] = 2; -- Throwdown
	[6343]  = 2; -- Thunder Clap
	[50720] = 2; -- Vigilance

	[12964] = 4; -- Battle Trance
	[18499] = 4; -- Berserker Rage
	[46924] = 4; -- Bladestorm
	[46916] = 4; -- Bloodsurge
	[23885] = 4; -- Bloodthirst 
	[85730] = 4; -- Deadly Calm
	[12292] = 4; -- Death Wish
	[55694] = 4; -- Enraged Regeneration
	[1134]  = 4; -- Inner Rage
	[65156] = 4; -- Juggernaut
	[12975] = 4; -- Last Stand
	[85739] = 4; -- Meat Cleaver
	[1719]  = 4; -- Recklessness
	[20230] = 4; -- Retaliation
	[86663] = 2; -- Rude Interruption
	[2565]  = 4; -- Shield Block
	[871]   = 4; -- Shield Wall
	[23920] = 4; -- Spell Reflection
	[52437] = 4; -- Sudden Death
	[12328] = 4; -- Sweeping Strikes
	[50227] = 4; -- Sword and Board
	[60503] = 4; -- Taste for Blood
	[87096] = 4; -- Thunderstruck
	[34428] = 4; -- Victory Rush 
}) end

addPetAuras({
	-- Death Knight Ghouls
	[63560] = true; -- Dark Transformation
	[91342] = true; -- Shadow Infusion
	
	-- Hunter Pets
	[6991] 	= true; -- Feed Pet
	[51284]	= true; -- Feed Pet...?
	[19615]	= true; -- Frenzy Effect
	[136] 	= true; -- Mend Pet
})

local unitIsPlayer = { player = true, pet = true, vehicle = true }
local auraFilter = {
	[1] = function(self, unit, caster) return true end;
	[2] = function(self, unit, caster) return unitIsPlayer[caster] end;
	[3] = function(self, unit, caster) return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) end;
	[4] = function(self, unit, caster) return (unit == "player") and not(self.__owner.isGroupFrame) end;
}

F.CustomAuraFilter = function(self, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff)

	-- always filter the player, but only filter the target frame when in combat
	-- *unless the user has chosen to NOT use the filter...
	if (GUIS_DB["unitframes"].useTargetAuraFilter) and (InCombatLockdown()) or (unit == "player") then
		local auraHandling = R.AuraList[name]
		
		-- always return debuffs applied by a boss
		if ((auraHandling) and (auraFilter[auraHandling])) or (isBossDebuff) then
			return (isBossDebuff) or auraFilter[auraHandling](self, unit, caster)

--		elseif (not(caster) or (caster == unit)) and not(UnitPlayerControlled(unit)) and UnitCanAttack(unit, "player") then
		elseif (caster == unit) and not(UnitPlayerControlled(unit)) and UnitCanAttack(unit, "player") then
			return true
		end
	else
		-- return everything from anybody on the target when not in combat
		return true
	end
end

F.CustomPetAuraFilter = function(self, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff)
	-- always apply the aura filter to pets, and always show boss debuffs
	if ((name) and (R.PetAuraList[name])) or (isBossDebuff) then
		return true
	end
end

