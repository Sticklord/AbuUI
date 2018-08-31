local _, ns = ...
local Gcfg = AbuGlobal.GlobalConfig

ns.Config = {
	PrintBindings = false,
	ShowKeybinds = true,

	Font = Gcfg.Fonts.Actionbar,
	FontSize = 19,

	Textures = {
		Normal = Gcfg.IconTextures.Normal,
		Background = Gcfg.IconTextures.Background,
		Highlight  = Gcfg.IconTextures.Highlight ,
		Checked = Gcfg.IconTextures.Checked,
		Pushed = Gcfg.IconTextures.Pushed,
		Shadow = Gcfg.IconTextures.Shadow,
		White = Gcfg.IconTextures.White,
		Debuff = Gcfg.IconTextures.Debuff,
		Flash = Gcfg.IconTextures.Flash,
	},

	HideStanceBar = { -- Hide stance bar for these classes if set to true.
		['DEATHKNIGHT'] = false,
		['DRUID'] = false,
		['HUNTER'] = false,
		['MAGE'] = false,
		['MONK'] = false,
		['PALADIN'] = false,
		['PRIEST'] = false,
		['ROGUE'] = false,
		['SHAMAN'] = false,
		['WARLOCK'] = false,
		['WARRIOR'] = true,
	},

	FadeOutBars = { -- Fade these bars out if they're set to true.
		['MultiBarLeft'] = 0.2,
		['MultiBarRight'] = 0,
		['MultiBarBottomRight'] = 0,
	},

	ActionbarPaging = { -- Change bar on different conditions, like tons of macros would do
		-- 1	(Primary) Action Bar 1
		-- 2	(Primary) Action Bar 2
		-- 3	Right Bar
		-- 4	Right Bar 2
		-- 5	Bottom Right Bar
		-- 6	Bottom Left Bar
		-- 7	Druid Cat Form/Rogue Stealth/Warrior Battle Stance/Priest Shadowform/Monk Fierce Tiger
		-- 8	Warrior Defensive Stance/Rogue Shadow Dance/Monk Sturdy Ox
		-- 9	Druid Bear Form/Warrior Berserker Stance/Monk Wise Serpent
		-- 10	Druid Moonkin Form
		['MONK']    = '[help]2;[mod:alt]2;',
		['PRIEST']  = '[help]2;[mod:alt]2;',
		['PALADIN'] = '[help]2;[mod:alt]2;',
		['SHAMAN']  = '[help]2;[mod:alt]2;',
		--['DRUID']   = '[help,nostance:1/2/3/4]2;[mod:alt]2;[stance:2]7;[stance:1]9;',
		['DRUID']   = '[help]2;[mod:alt]2;[stance:2]7;[stance:1]9;',
		--['ROGUE']   = '[stance:1]7;[stance:3]7;1',
	},
}