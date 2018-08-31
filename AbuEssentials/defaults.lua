local name, ns = ...
local path = 'Interface\\AddOns\\AbuEssentials\\Textures\\'

--[[
	[1] = path..'Font\\Atarian.ttf',
	[2] = path..'Font\\Defused.ttf',
	[3] = path..'Font\\AccPrec.ttf',
	[4] = path..'Font\\ExpresswayFree.ttf',
--]]

-- Settings for this addon

ns.Config = {
	
	HidePowa = {		-- Hiding blizzard power auras:
		[135286] = true, 	-- Teeth n claw druid
		[93622] = true,  	-- Mangle
	},

	EnableMailModule = true, -- Enable take all mail button

	Tooltip = {
		Enable = true,				-- Enable tooltip skinning
		ShowTitle = false,			-- Show player title
		RoleIcon = true,			-- Show a role icon
		ShowGuildRanks = true,		-- Show guild rank of a player
		FontSize = 13,				-- Fontsize
		Position = {'BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -57, 190},
	},

	Vendor = { -- THings to do when visiting a vendor, hold shift to ignore all.
		AutoRepair = true,		-- Repair automagically when visiting a vendor, 
		SellGreyCrap = true,	-- Sells ALL grey stuff
		BuyEssentials = true,	-- Restock a set items for your character, like Tome of clear mind
	},

	SkinMinimap = true, -- Skin the minimap
	PopBubbles = true, -- Remove border around speech bubbles

}

-- global setting for all abu addons. Mainly colors, textures, fonts etc.
ns.GlobalConfig = {
	Colors = {
		Frame = 	{ 0.5, 0.5, 0.4 }, -- Colors to skin the blizzard things.
		Border = 	{ 0.7, 0.7, 0.6 }, -- Colors for button borders
		Interrupt = { .9, .8, .2 },
	},
	Fonts = {
		Damage = path..'Font\\Defused.ttf',
		Normal = path..'Font\\ExpresswayFree.ttf',
		Actionbar = path..'Font\\AccPrec.ttf',
		Fancy = path..'Font\\Atarian.ttf',
	},
	Statusbar = {
		Normal = path..'statusbarTex.tga',
		Light = path.."tex.tga",
	},
	IconTextures = {
		Normal = path..'Border\\normal',
		Background = path..'Border\\background',
		Highlight = path..'Border\\highlight',
		Checked = path..'Border\\checked',
		Pushed = path..'Border\\pushed',
		Shadow = path..'Border\\shadow',
		White = path..'Border\\white',
		Debuff = path..'Border\\normal',
		Flash = path..'Border\\flash',
	},
}