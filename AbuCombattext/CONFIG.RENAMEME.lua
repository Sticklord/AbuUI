local addon, ns=...
---------------------------------------------------------------------------------
-- use ["option"] = true/false, to set options.

-- xCT outgoing damage/healing options
ns.config.damage = true						-- show outgoing damage in it's own frame
ns.config.healing = true					-- show outgoing healing in it's own frame
ns.config.showhots = true					-- show periodic healing effects in xCT healing frame.
ns.config.critprefix = "|cffFF0000*|r"		-- symbol that will be added before amount, if you deal critical strike/heal. leave "" for empty. default is red *
ns.config.critpostfix = "|cffFF0000*|r"		-- postfix symbol, "" for empty.
ns.config.icons = true						-- show outgoing damage icons
ns.config.iconswings = false				-- show outgoing damage icons for weapon swings (white attacks)
ns.config.iconsize = 16						-- icon size of spells in outgoing damage frame, also has effect on dmg font size if it's set to "auto"
ns.config.petdamage = true					-- show your pet damage.
ns.config.dotdamage = true					-- show damage from your dots. someone asked an option to disable lol.
ns.config.treshold = 500					-- minimum damage to show in outgoing damage frame
ns.config.healtreshold = 1100				-- minimum healing to show in incoming/outgoing healing messages.
	
-- appearence
ns.config.font = "Fonts\\ARIALN.ttf"		-- "Fonts\\ARIALN.ttf" is default WoW font.
ns.config.fontsize = 16						-- The size of all the fonts
ns.config.fontstyle = "OUTLINE"				-- valid options are "OUTLINE", "MONOCHROME", "THICKOUTLINE", "OUTLINE,MONOCHROME", "THICKOUTLINE,MONOCHROME"
ns.config.damagefont = "Fonts\\ARIALN.ttf"	-- "Fonts\\FRIZQT__.ttf" is default WoW damage font
ns.config.damagefontsize = "16"				-- size of xCT damage font. use "auto" to set it automatically depending on icon size, or use own value, 16 for example. if it's set to number value icons will change size.
ns.config.timevisible = 3					-- time (seconds) a single message will be visible. 3 is a good value.
ns.config.maxlines = 64						-- max lines to keep in scrollable mode. more lines=more memory. nom nom nom.

-- justify messages in frames, valid values are "RIGHT" "LEFT" "CENTER"
ns.config.justify_1 = "LEFT"				-- incoming damage justify
ns.config.justify_2 = "RIGHT"				-- incoming healing justify
ns.config.justify_3 = "CENTER"				-- various messages justify (mana, rage, auras, etc)
ns.config.justify_4 = "RIGHT"				-- outgoing damage/healing justify

-- class modules and goodies
ns.config.stopvespam = true					-- automaticly turns off healing spam for priests in shadowform. HIDE THOSE GREEN NUMBERS PLX!
ns.config.dkrunes = true					-- show deathknight rune recharge
ns.config.mergetime = 0.2					-- Time in seconds between each output

-- display looted items (set both to false to revert changes and go back to the original xCT)
ns.config.lootitems       = true			-- show all looted items
ns.config.lootmoney       = false			-- Display looted money

-- fine tune loot options
ns.config.loothideicons   = false			-- hide item icons when looted
ns.config.looticonsize    = 20				-- Icon size of looted, crafted and quest items
ns.config.crafteditems    = nil				-- show crafted items ( nil = default, false = always hide, true = always show)
ns.config.questitems      = nil				-- show quest items ( nil = default, false = always hide, true = always show)
ns.config.itemsquality    = 2			  	-- filter items shown by item quality: 0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary, 6 = Artifact, 7 = Heirloom
ns.config.itemstotal      = true			-- show the total amount of items in bag ("[Epic Item Name]x1 (x23)")
ns.config.moneycolorblind = false			-- shows letters G, S, and C instead of textures
ns.config.minmoney        = 0			  	-- filter money received events, less than this amount (4G 32S 12C = 43212)

