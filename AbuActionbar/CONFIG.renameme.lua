local _, ns = ...
local Gcfg = AbuGlobal.GlobalConfig


ns.Config.PrintBindings = false
ns.Config.ShowKeybinds = false

ns.Config.Font = Gcfg.Fonts.Actionbar
ns.Config.FontSize = 19


ns.Config.Textures.Normal = Gcfg.IconTextures.Normal
ns.Config.Textures.Background = Gcfg.IconTextures.Background
ns.Config.Textures.Highlight  = Gcfg.IconTextures.Highlight 
ns.Config.Textures.Checked = Gcfg.IconTextures.Checked
ns.Config.Textures.Pushed = Gcfg.IconTextures.Pushed
ns.Config.Textures.Shadow = Gcfg.IconTextures.Shadow
ns.Config.Textures.White = Gcfg.IconTextures.White
ns.Config.Textures.Debuff = Gcfg.IconTextures.Debuff
ns.Config.Textures.Flash = Gcfg.IconTextures.Flash

-- Hide the stance bar for these classes if set to true
ns.Config.HideStanceBar['DEATHKNIGHT'] = false
ns.Config.HideStanceBar['DRUID'] = false
ns.Config.HideStanceBar['HUNTER'] = false
ns.Config.HideStanceBar['MAGE'] = false
ns.Config.HideStanceBar['MONK'] = false
ns.Config.HideStanceBar['PALADIN'] = false
ns.Config.HideStanceBar['PRIEST'] = false
ns.Config.HideStanceBar['ROGUE'] = false
ns.Config.HideStanceBar['SHAMAN'] = false
ns.Config.HideStanceBar['WARLOCK'] = false
ns.Config.HideStanceBar['WARRIOR'] = true


-- Fade these bars out if they're set to true.
ns.Config.FadeOutBars['MultiBarLeft'] = true
ns.Config.FadeOutBars['MultiBarRight'] = true
ns.Config.FadeOutBars['MultiBarBottomRight'] = false


-- Change bar on different conditions, like tons of macros would do
-- Take this for example: [help]2;[mod:alt]2;1. 
-- [if you can help your target] show bar 2; [if modifier key alt is down] show bar 2; else show bar 1
-- comment out the line to disable for that class

ns.Config.ActionbarPaging['MONK']    = '[help]2;[mod:alt]2;1'
ns.Config.ActionbarPaging['PRIEST']  = '[help]2;[mod:alt]2;1'
ns.Config.ActionbarPaging['PALADIN'] = '[help]2;[mod:alt]2;1'
ns.Config.ActionbarPaging['SHAMAN']  = '[help]2;[mod:alt]2;1'
ns.Config.ActionbarPaging['DRUID']   = '[help,nostance:1/2/3/4]2;[mod:alt]2;[stance:2]7;[stance:1]9;'
--ns.Config.ActionbarPaging['ROGUE']   = '[stance:1]7;[stance:3]7;1'
