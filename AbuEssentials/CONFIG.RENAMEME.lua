local name, ns = ...
local path = 'Interface\\AddOns\\AbuEssentials\\Textures\\'

--[[
	[1] = path..'Font\\Atarian.ttf',
	[2] = path..'Font\\Defused.ttf',
	[3] = path..'Font\\AccPrec.ttf',
	[4] = path..'Font\\ExpresswayFree.ttf',
--]]

-- Settings for this addon
	
-- Hiding blizzard power auras:
ns.Config.HidePowa[135286] = true 	-- Teeth n claw druid
ns.Config.HidePowa[93622] = true  	-- Mangle


ns.Config.EnableMailModule = true -- Enable take all mail button


ns.Config.Tooltip.Enable = true				-- Enable tooltip skinning
ns.Config.Tooltip.ShowTitle = false			-- Show player title
ns.Config.Tooltip.RoleIcon = true			-- Show a role icon
ns.Config.Tooltip.ShowGuildRanks = true		-- Show guild rank of a player
ns.Config.Tooltip.FontSize = 13				-- Fontsize
ns.Config.Tooltip.Position = {'BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -57, 190}

-- THings to do when visiting a vendor, hold shift to ignore all.
ns.Config.Vendor.AutoRepair = true		-- Repair automagically when visiting a vendor 
ns.Config.Vendor.SellGreyCrap = true	-- Sells ALL grey stuff
ns.Config.Vendor.BuyEssentials = true	-- Restock a set items for your character, like Tome of clear mind


ns.Config.SkinMinimap = true -- Skin the minimap
ns.Config.PopBubbles = true -- Remove border around speech bubbles


-- Global setting for all abu addons. Mainly colors, textures, fonts etc.

ns.GlobalConfig.Colors.Frame = 	{ 0.5, 0.5, 0.4 } -- Colors to skin the blizzard things.
ns.GlobalConfig.Colors.Border = 	{ 0.9, 0.9, 0.8 } -- Colors for button borders
ns.GlobalConfig.Colors.Interrupt = { .9, .8, .2 }

ns.GlobalConfig.Fonts.Damage = path..'Font\\Defused.ttf'
ns.GlobalConfig.Fonts.Normal = path..'Font\\ExpresswayFree.ttf'
ns.GlobalConfig.Fonts.Actionbar = path..'Font\\AccPrec.ttf'
ns.GlobalConfig.Fonts.Fancy = path..'Font\\Atarian.ttf'

ns.GlobalConfig.Statusbar.Normal = path..'statusbarTex.tga'
ns.GlobalConfig.Statusbar.Light = path.."tex.tga"


ns.GlobalConfig.IconTextures.Normal = path..'Border\\textureNormal'
ns.GlobalConfig.IconTextures.Background = path..'Border\\textureBackground'
ns.GlobalConfig.IconTextures.Highlight = path..'Border\\textureHighlight'
ns.GlobalConfig.IconTextures.Checked = path..'Border\\textureChecked'
ns.GlobalConfig.IconTextures.Pushed = path..'Border\\texturePushed'
ns.GlobalConfig.IconTextures.Shadow = path..'Border\\textureShadow'
ns.GlobalConfig.IconTextures.White = path..'Border\\textureWhite'
ns.GlobalConfig.IconTextures.Debuff = path..'Border\\textureDebuff'
ns.GlobalConfig.IconTextures.Flash = nil
