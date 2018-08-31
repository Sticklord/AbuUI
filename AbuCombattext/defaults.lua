local addon, ns=...
ns.config={
---------------------------------------------------------------------------------
-- use ["option"] = true/false, to set options.

-- xCT outgoing damage/healing options
	damage = true,						-- show outgoing damage in it's own frame
	healing = true,						-- show outgoing healing in it's own frame
	showhots = true,					-- show periodic healing effects in xCT healing frame.
	critprefix = "|cffFF0000*|r",		-- symbol that will be added before amount, if you deal critical strike/heal. leave "" for empty. default is red *
	critpostfix = "|cffFF0000*|r",		-- postfix symbol, "" for empty.
	icons = true,						-- show outgoing damage icons
	iconswings = false,					-- show outgoing damage icons for weapon swings (white attacks)
	iconsize = 16,						-- icon size of spells in outgoing damage frame, also has effect on dmg font size if it's set to "auto"
	petdamage = true,					-- show your pet damage.
	dotdamage = true,					-- show damage from your dots. someone asked an option to disable lol.
	treshold = 0,						-- minimum damage to show in outgoing damage frame
	healtreshold = 1100,				-- minimum healing to show in incoming/outgoing healing messages.

-- appearence
	font = "Fonts\\ARIALN.ttf",			-- "Fonts\\ARIALN.ttf" is default WoW font.
	fontsize = 16,						-- The size of all the fonts
	fontstyle = "OUTLINE",				-- valid options are "OUTLINE", "MONOCHROME", "THICKOUTLINE", "OUTLINE,MONOCHROME", "THICKOUTLINE,MONOCHROME"
	damagefont = "Fonts\\ARIALN.ttf",	-- "Fonts\\FRIZQT__.ttf" is default WoW damage font
	damagefontsize = "16",				-- size of xCT damage font. use "auto" to set it automatically depending on icon size, or use own value, 16 for example. if it's set to number value icons will change size.
	timevisible = 3, 					-- time (seconds) a single message will be visible. 3 is a good value.
	maxlines = 64,						-- max lines to keep in scrollable mode. more lines=more memory. nom nom nom.

-- justify messages in frames, valid values are "RIGHT" "LEFT" "CENTER"
	justify_1 = "LEFT",					-- incoming damage justify
	justify_2 = "RIGHT",					-- incoming healing justify
	justify_3 = "CENTER",				-- various messages justify (mana, rage, auras, etc)
	justify_4 = "RIGHT",				-- outgoing damage/healing justify

-- class modules and goodies
	stopvespam = true,					-- automaticly turns off healing spam for priests in shadowform. HIDE THOSE GREEN NUMBERS PLX!
	dkrunes = true,						-- show deathknight rune recharge
	mergetime = 0.2,					-- Time in seconds between each output

-- display looted items (set both to false to revert changes and go back to the original xCT)
	lootitems       = true,  			-- show all looted items
	lootmoney       = false,  			-- Display looted money

-- fine tune loot options
	loothideicons   = false,			-- hide item icons when looted
	looticonsize    = 20,				-- Icon size of looted, crafted and quest items
	crafteditems    = nil,  			-- show crafted items ( nil = default, false = always hide, true = always show)
	questitems      = nil,  			-- show quest items ( nil = default, false = always hide, true = always show)
	itemsquality    = 2,     			-- filter items shown by item quality: 0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary, 6 = Artifact, 7 = Heirloom
	itemstotal      = true,  			-- show the total amount of items in bag ("[Epic Item Name]x1 (x23)")
	moneycolorblind = false, 			-- shows letters G, S, and C instead of textures
	minmoney        = 0,     			-- filter money received events, less than this amount (4G 32S 12C = 43212)
}
