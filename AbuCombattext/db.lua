
--some init
local addon, ns = ...
local config = ns.config

ns.myname = UnitName("player")
ns.myclass = select(2, UnitClass("player"))

--[[	
		List for spells that should not update too quickly, i.e. dotsand slow aoes.
		[Spell ID for spell to be merged] = seconds between each update

		Use a minus value to make it scale with haste:
		-- arcane missiles has 2 sec base cast time (with 0 haste)
		If you have 25% haste this will:
			[spellID] = -2

		Basically mean
			[spellID] = 1.5
		unless of course if your haste changes
]]

-- outgoing healing filter, hide this spammy shit, plx
if config.healing then
		ns.healfilter = { }
		-- See class-specific config for filtered spells.
end

ns.MergeList = {
	-- items (legendary cloaks)
	[147891] = 3.1,   -- Legedary Cloak (Melee - dmg over 3s)
	[148008] = 3.1,   -- Legedary Cloak (Caster - dmg over 3s)
	[148009] = 4,   -- Legedary Cloak (Healer - heal over 10s)
	[149276] = 3.1, -- Legedary Cloak (Hunter - dmg over 3s)

	-- Trinket: Kardris' Toxic Totem (Based on class and spec)
	[146061] = 3,   -- Multi-Strike (Physical, Melee)
	[146063] = 3,   -- Multi-Strike (Holy Dmg, ?????)
	[146064] = 3,   -- Multi-Strike (Arcane Boomkin)
	[146065] = 3,   -- Multi-Strike (Shadow, Lock/Priest)
	[146067] = 3,   -- Multi-Strike (Fire, Frost Mage)
	[146069] = 3,   -- Multi-Strike (Physical, Hunter)
	[146071] = 3,   -- Multi-Strike (Nature, Ele Shaman)
	[146070] = 3,   -- Multi-Strike (Arcane Mage)
	[146075] = 3,   -- Multi-Strike (Nature, Monk)
	[146177] = 3,   -- Multi-Strike (Holy, Healing)
	[146178] = 3,   -- Multi-Strike (Nature, Healing)

	-- Trinket: Thok's Acid-Grooved Tooth (Based on class and spec)
	[146137] = 3,   -- Cleave (Physical, Melee)
	[146157] = 3,   -- Cleave (Holy Dmg, ?????)
	[146158] = 3,   -- Cleave (Arcane Boomkin)
	[146159] = 3,   -- Cleave (Shadow, Lock/Priest)
	[146160] = 3,   -- Cleave (Fire, Frost Mage)
	[146162] = 3,   -- Cleave (Physical, Hunter)
	[146166] = 3,   -- Cleave (Arcane Mage)
	[146171] = 3,   -- Cleave (Nature, Ele)
	[148234] = 3,   -- Cleave (Holy, Healing)
	[148235] = 3,   -- Cleave (Nature, Healing)
}

-- class config, overrides general
if ns.myclass == "WARLOCK" then
	if config.healing then
		ns.healfilter[28176] = 3  -- Fel Armor
		ns.healfilter[63106] = 3  -- Siphon Life
		ns.healfilter[54181] = 3  -- Fel Synergy
		ns.healfilter[89653] = 3  -- Drain Life
		ns.healfilter[79268] = 3  -- Soul Harvest
		ns.healfilter[30294] = 3  -- Soul Leech
	end
elseif ns.myclass == "DRUID" then
	-- Healer spells
	ns.MergeList[774]   = 3  -- Rejuvenation (Normal)
	ns.MergeList[64801] = 3  -- Rejuvenation (First tick)
	ns.MergeList[48438] = 3  -- Wild Growth
	ns.MergeList[8936]  = 3  -- Regrowth
	ns.MergeList[33763] = 3  -- Lifebloom
	ns.MergeList[44203] = 3  -- Tranquility
	ns.MergeList[81269] = 3  -- Efflorescence
elseif ns.myclass == "DEMONHUNTER" then
	-- Healer spells
	ns.MergeList[222031] = 0.5  -- Chaos something
	ns.MergeList[198030] = 1	-- Beam
	ns.MergeList[185123] = 1 -- Glaive
elseif ns.myclass == "PRIEST" then
 -- Healer spells
	ns.MergeList[47750] = 3  -- Penance (Heal Effect)
	ns.MergeList[77489] = 3  -- Echo of Light
	ns.MergeList[34861] = 3  -- Circle of Healing
	ns.MergeList[33110] = 3  -- Prayer of Mending
	ns.MergeList[63544] = 3  -- Divine Touch
 -- Damager spells
	ns.MergeList[589]   = 3  -- Shadow Word: Pain
	ns.MergeList[34914] = 3  -- Vampiric Touch
	ns.MergeList[2944]  = 3  -- Devouring Plague
	ns.MergeList[63675] = 3  -- Improved Devouring Plague
	ns.MergeList[87532] = 3  -- Shadowy Apparition
	if config.healing then
		ns.healfilter[2944]  = 3  -- Devouring Plague (Healing)
		ns.healfilter[15290] = 3  -- Vampiric Embrace
	end
elseif ns.myclass == "MAGE" then

	ns.MergeList[44461] = 3  -- Living Bomb Explosion
	ns.MergeList[44457] = 3  -- Living Bomb Dot
	ns.MergeList[1449]  = 2  -- Arcane Explosion
	ns.MergeList[114923]= 3  -- Nether Tempest
	ns.MergeList[148022]= 5  -- Iceicle
	ns.MergeList[7268]	= -2  -- Arcane Missiles

elseif ns.myclass == "WARRIOR" then

	ns.MergeList[12721]  = 3  -- Deep Wounds
	ns.MergeList[113344] = 3  -- Bloodbath 
	ns.MergeList[115767] = 3  -- Deep Wounds

	if config.healing then
		ns.healfilter[23880] = 3  -- Bloodthirst
		ns.healfilter[55694] = 3  -- Enraged Regeneration
	end
elseif ns.myclass == "HUNTER" then

	ns.MergeList[82834] = 3  -- Serpent Sting (Instant Serpent Spread)
	ns.MergeList[88466] = 3  -- Serpent Sting (DOT Serpent Spread)
	ns.MergeList[1978]  = 3  -- Serpent Sting
	ns.MergeList[13812] = 3  -- Explosive Trap  

elseif ns.myclass == "DEATHKNIGHT" then

	ns.MergeList[55095] = 3  -- Frost Fever
	ns.MergeList[55078] = 3  -- Blood Plague
	ns.MergeList[55536] = 3  -- Unholy Blight
	ns.MergeList[52212] = 2  -- Death and Decay

elseif ns.myclass == "ROGUE" then
	ns.MergeList[2818]  = 1  -- Deadly Poison
	ns.MergeList[8680]  = 1  -- Wound Poison
	ns.MergeList[51723] = 1  -- Fan of knives
	ns.MergeList[121411]= 1  -- Crimson tempest dot
end
 

-- for attacks with 2 hits, for example whirlwind with 2 weapons.
--  [Offhand SpellID] = Mainhand SpellID
ns.MergeOffhandList = {
-- demon hunter
	[199547] = 222031,		-- some chaos spell
	-- Hunter (Damage)
	[118253] = 83077, 		-- Serpent Sting (Tick)
	[120761] = 121414,		-- Glaive Toss
	
	-- Mage (Damage)
	[44457]  = 44461, 		-- Living Bomb (DOT)
	[114954] = 114923,		-- Nether Tempest (50% to random player)
	
	-- Monk (Damage)
	[117418] = 113656,		-- Fists of Fury
	[125033] = 124098,		-- Zen Sphere: Detonate (Damage)
	
	-- Monk (Healing)
	[126890] = 117895,		-- Eminence (Statue)
	[125953] = 115175,		-- Soothing Mist (Statue)
	[124101] = 124081,		-- Zen Sphere: Detonate (Heal)
	
	-- Priest (Damage)
	[124469] = 49821,		-- Mind Sear
	
	-- Rogue (Damage)
	[122233] = 121411,		-- Crimson Tempest (DoT)
	[113780] = 2818,		-- Deadly Poison (DoT)
	[27576] = 5374,			-- Mutilate

	-- Shaman (damage)
	[45297]  = 421,   		-- Chain Lightning (Mastery)
	[114738] = 114074,		-- Lava Beam (Mastery)
	[32176]  = 32175, 		-- Stormstrike
	[115360] = 115357,		-- Stormblast
	[114093] = 114089,		-- Wind Lash (Ascendance)
	
	-- Warlock (Damage)
	[131737] = 980,  		-- Agony (Malefic Grasp)
	[131740] = 172,  		-- Corruption (Malefic Grasp)
	[131736] = 30108,		-- Unstable Affliction (Malefic Grasp)
	[27285]  = 27243,		-- Seed of Corruption (Explosion)
	[87385]  = 27243,		-- Seed of Corruption (Explosion Soulburned)
	
	-- Warrior
	[85384]  = 96103, 		-- Raging Blow
	[44949]  = 1680,  		-- Whirlwind (Offhand)
	[95738] = 50622,  		-- Bladestorm (Offhand)
	[145585] = 107570,		-- StormBolt (OH)
}

ns.BlackList = {
	[118895] = true,	 -- Dragons roar stun
}

-- Colors for spell types
ns.schoolColor = {
	[1]		= { r = 1.00,	g = 1.00,	b = 0.00,	n = 'Physical'};
	[2]		= { r = 1.00,	g = 0.90,	b = 0.50,	n = 'Holy'};
	[4]		= { r = 1.00,	g = 0.50,	b = 0.00,	n = 'Fire'};
	[8]		= { r = 0.30,	g = 1.00,	b = 0.30,	n = 'Nature'};
	[16]	= { r = 0.50,	g = 1.00,	b = 1.00,	n = 'Frost'};
	[32]	= { r = 0.50,	g = 0.50,	b = 1.00,	n = 'Shadow'};
	[64]	= { r = 1.00,	g = 0.50,	b = 1.00,	n = 'Arcane'};
	[3]		= { r = 1.00,	g = 0.95,	b = 0.25,	n = 'Holystrike'};
	[5]		= { r = 1.00,	g = 0.75,	b = 0.00,	n = 'Flamestrike'};
	[6] 	= { r = 1.00,	g = 0.70,	b = 0.25,	n = 'Holyfire'};
	[9] 	= { r = 0.65,	g = 1.00,	b = 0.15,	n = 'Stormstrike'};
	[10] 	= { r = 0.75,	g = 0.95,	b = 0.75,	n = 'Holystorm'};
	[12] 	= { r = 0.65,	g = 0.75,	b = 0.15,	n = 'Firestorm'};
	[17] 	= { r = 0.75,	g = 1.00,	b = 0.50,	n = 'Froststrike'};
	[18] 	= { r = 0.75,	g = 0.95,	b = 0.75,	n = 'Holyfrost'};
	[20] 	= { r = 0.75,	g = 0.75,	b = 0.50,	n = 'Frostfire'};
	[24]	= { r = 0.40,	g = 1.00,	b = 0.65,	n = 'Froststorm'};
	[33]	= { r = 0.75,	g = 0.75,	b = 0.50,	n = 'Shadowstrike'};
	[34]	= { r = 0.75,	g = 0.70,	b = 0.75,	n = 'Shadowlight'};
	[36]	= { r = 0.75,	g = 0.50,	b = 0.50,	n = 'Shadowflame'};
	[40]	= { r = 0.40,	g = 0.75,	b = 0.65,	n = 'Shadowstorm'};
	[48]	= { r = 0.50,	g = 0.75,	b = 1.00,	n = 'Shadowfrost'};
	[65]	= { r = 1.00,	g = 0.75,	b = 0.50,	n = 'Spellstrike'};
	[66]	= { r = 1.00,	g = 0.70,	b = 0.75,	n = 'Divine'};
	[68]	= { r = 1.00,	g = 0.50,	b = 0.50,	n = 'Spellfire'};
	[72]	= { r = 0.65,	g = 0.75,	b = 0.65,	n = 'Spellstorm'};
	[80]	= { r = 0.75,	g = 0.75,	b = 1.00,	n = 'Spellfrost'};
	[96]	= { r = 0.75,	g = 0.50,	b = 1.00,	n = 'Spellshadow'};
	[28]	= { r = 0.60,	g = 0.84,	b = 0.44,	n = 'Elemental'};
	[124]	= { r = 0.66,	g = 0.70,	b = 0.66,	n = 'Chromatic'};
	[126]	= { r = 0.72,	g = 0.73,	b = 0.64,	n = 'Magic'};
	[127]	= { r = 0.76,	g = 0.77,	b = 0.55,	n = 'Chaos'};
}