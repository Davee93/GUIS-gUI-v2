--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 
local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs

if not(ORD) or not(oUF) then 
	return 
end

-- Lua API
local select = select

-- WoW API
local GetSpellInfo = GetSpellInfo

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local R = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: UnitFrameAuras")

ORD.ShowDispelableDebuff = true
ORD.FilterDispellableDebuff = true
ORD.MatchByspellIDToName = true

local spellIDToName = function(spellID)
	-- add the aura to our custom filter for the unitframes
	R.addAura(spellID, 3) -- by anyone on friendly
	
	return (select(1, GetSpellInfo(spellID)))	
end

R.RaidDebuffs = {
	--------------------------------------------------------------------------------------------------
	--		Misc
	--------------------------------------------------------------------------------------------------
	-- for testing purposes only
	--spellIDToName(11196); 	-- Recently Bandaged
	--spellIDToName(67479); 	-- Impale (Gormok The Impaler, Heroic 25 TotC)

	--------------------------------------------------------------------------------------------------
	--		Baradin Hold
	--------------------------------------------------------------------------------------------------
	spellIDToName(95173); 	-- Consuming Darkness

	--------------------------------------------------------------------------------------------------
	--		Blackwing Descent
	--------------------------------------------------------------------------------------------------
	-- Magmaw
	spellIDToName(91911); 	-- Constricting Chains
	spellIDToName(94679); 	-- Parasitic Infection
	spellIDToName(94617); 	-- Mangle
	
	-- Omintron Defense System
	spellIDToName(79835); 	--Poison Soaked Shell	
	spellIDToName(91433); 	--Lightning Conductor
	spellIDToName(91521); 	--Incineration Security Measure
	
	-- Maloriak
	spellIDToName(77699); 	-- Flash Freeze
	spellIDToName(77760); 	-- Biting Chill
	
	-- Atramedes
	spellIDToName(92423); 	-- Searing Flame
	spellIDToName(92485); 	-- Roaring Flame
	spellIDToName(92407); 	-- Sonic Breath
	
	-- Chimaeron
	spellIDToName(82881); 	-- Break
	spellIDToName(89084); 	-- Low Health

	--Sinestra
	spellIDToName(92956); 	-- Wrack	

	--------------------------------------------------------------------------------------------------
	--		The Bastion of Twilight
	--------------------------------------------------------------------------------------------------
	-- Valiona & Theralion
	spellIDToName(92878); 	-- Blackout
	spellIDToName(86840); 	-- Devouring Flames
	spellIDToName(95639); 	-- Engulfing Magic
	
	-- Halfus Wyrmbreaker
	spellIDToName(39171); 	-- Malevolent Strikes
	
	-- Twilight Ascendant Council
	spellIDToName(92511); 	-- Hydro Lance
	spellIDToName(82762); 	-- Waterlogged
	spellIDToName(92505); 	-- Frozen
	spellIDToName(92518); 	-- Flame Torrent
	spellIDToName(83099); 	-- Lightning Rod
	spellIDToName(92075); 	-- Gravity Core
	spellIDToName(92488); 	-- Gravity Crush
	
	-- Cho'gall
	spellIDToName(86028); 	-- Cho's Blast
	spellIDToName(86029); 	-- Gall's Blast

	--------------------------------------------------------------------------------------------------
	--		 Throne of the Four Winds
	--------------------------------------------------------------------------------------------------
	-- Conclave of Wind

	-- Nezir <Lord of the North Wind>
	spellIDToName(93131); 	--Ice Patch

	-- Anshal <Lord of the West Wind>
	spellIDToName(86206); 	--Soothing Breeze
	spellIDToName(93122); 	--Toxic Spores

	-- Rohash <Lord of the East Wind>
	spellIDToName(93058); 	--Slicing Gale 

	-- Al'Akir
	spellIDToName(93260); 	-- Ice Storm
	spellIDToName(93295); 	-- Lightning Rod

	--------------------------------------------------------------------------------------------------
	--		 Firelands
	--------------------------------------------------------------------------------------------------
	-- Beth'tilac
	spellIDToName(99506);	-- Widows Kiss
	spellIDToName(97202);	-- Fiery Web Spin
	spellIDToName(49026);	-- Fixate
	spellIDToName(97079);	-- Seeping Venom
	
	-- Lord Rhyolith
	
	-- Alysrazor
	spellIDToName(101296);	-- Fieroblast
	spellIDToName(100723);	-- Gushing Wound
	spellIDToName(99389);	-- Imprinted
	spellIDToName(101729);	-- Blazing Claw
	
	-- Shannox
	spellIDToName(99837);	-- Crystal Prison
	spellIDToName(99937);	-- Jagged Tear
	
	-- Baleroc
	spellIDToName(99256);	-- Torment
	spellIDToName(99252);	-- Blaze of Glory
	spellIDToName(99516);	-- Countdown
	
	-- Majordomo Staghelm
	spellIDToName(98450);	-- Searing Seeds
	
	-- Ragnaros
	spellIDToName(99399);	-- Burning Wound
	spellIDToName(100293);	-- Lava Wave
	spellIDToName(98313);	-- Magma Blast
	spellIDToName(100675);	-- Dreadflame
	
	--------------------------------------------------------------------------------------------------
	--		 Dragon Soul
	--------------------------------------------------------------------------------------------------
	-- Morchok
	spellIDToName(103541);	-- Safe
	spellIDToName(103536);	-- Warning
	spellIDToName(103534);	-- Danger
	spellIDToName(108570);	-- Black Blood of the Earth

	-- Warlord Zon'ozz
	spellIDToName(103434);	-- Disrupting Shadows

	-- Yor'sahj the Unsleeping
	spellIDToName(105171);	-- Deep Corruption

	-- Hagara the Stormbinder
	spellIDToName(105465);	-- Lighting Storm
	spellIDToName(104451);	-- Ice Tomb
	spellIDToName(109325);	-- Frostflake
	spellIDToName(105289);	-- Shattered Ice
	spellIDToName(105285);	-- Target

	-- Ultraxion
	spellIDToName(110079);	-- Fading Light
	spellIDToName(109075);	-- Fading Light

	-- Warmaster Blackhorn
	spellIDToName(108043); -- Devastate
	spellIDToName(108046); -- Shockwave
	spellIDToName(107567); -- Brutal Strike
	spellIDToName(107558); -- Degeneration

	-- Spine of Deathwing
	spellIDToName(105563); -- Grasping Tendrils
	spellIDToName(105479); -- Searing Plasma
	spellIDToName(105490); -- Fiery Grip

	-- Madness of Deathwing
	spellIDToName(105841); -- Degenerative bite
	spellIDToName(105445); -- Blistering heat
	spellIDToName(109603); -- Tetanus
	spellIDToName(110141); -- Shrapnel

}

ORD:RegisterDebuffs(R.RaidDebuffs)

