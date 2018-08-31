local ADDON, ns = ...

local DriverFrame = CreateFrame('Frame', ADDON..'DriverFrame', UIParent)
local UnitFrameMixin = {}
local UnitBuffMixin = {}
_G[ADDON] = ns

local config = {
	Colors = {
		Frame 	= AbuGlobal.GlobalConfig.Colors.Frame,	
		Border   = AbuGlobal.GlobalConfig.Colors.Border,
		Interrupt = AbuGlobal.GlobalConfig.Colors.Interrupt,
	},

	IconTextures = {
		White = AbuGlobal.GlobalConfig.IconTextures.White,
		Normal = AbuGlobal.GlobalConfig.IconTextures.Normal,
		Shadow = AbuGlobal.GlobalConfig.IconTextures.Shadow,
	},

	-- Nameplates
	StatusbarTexture = AbuGlobal.GlobalConfig.Statusbar.Light,
	Font = AbuGlobal.GlobalConfig.Fonts.Normal,
	FontSize = 12,

	friendlyConfig = {
		useClassColors = true,						-- Class colored bar
		colorHealthBySelection = true,				-- npc healthbar coloring by type (neutral, hostile...)
		colorHealthByRaidIcon = true,				-- Blue bar if its marked with square for example
		colorHealthWithExtendedColors = true, 		-- Not entirely sure what this does

		displayName = true,							-- display name
		displayNameByPlayerNameRules = true,		-- Use the UnitShouldDisplayName() to display name
		colorNameByClass = false,
		colorNameBySelection = false,				-- Color name by selection color(hostile friend neutral)
		colorNameWithExtendedColors = false, 		-- Again, not entirely sure what this does

		considerSelectionInCombatAsHostile = true,  -- Red for enemies you are in combat with
		displayAggroHighlight = false,
		displaySelectionHighlight = true,			-- Stronger border around your target

		filter = "NONE", -- The aura filter on the plate

		castBarHeight = 8,
		healthBarHeight = 8,

		displayHealPrediction = true,				-- Absorb, incoming heals etc..
		displayNameWhenSelected = true,				-- Only show name when selected
		displayQuest = true,						-- Show quest icon 

		greyOutWhenTapDenied = false,				-- Grey if tapped
		showClassificationIndicator = true,  		-- Elite border
		tankBorderColor = false,
		--displayDispelDebuffs = true,
		--smoothHealthUpdates = false,
		--fadeOutOfRange = false,
		--displayStatusText = true,
		--playLoseAggroHighlight = true,
	},

	enemyConfig = {
		useClassColors = true,						-- Class colored bar
		colorHealthBySelection = true,
		colorHealthByRaidIcon = true,
		colorHealthWithExtendedColors = false, 		-- Not entirely sure what this does

		displayName = true,
		displayNameByPlayerNameRules = true,
		colorNameByClass = false,
		colorNameBySelection = true,
		colorNameWithExtendedColors = true, 		-- Again, not sure what this does

		considerSelectionInCombatAsHostile = true,
		displayAggroHighlight = true,
		displaySelectionHighlight = true,			-- Stronger border around your target

		filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY",

		castBarHeight = 8,
		healthBarHeight = 8,

		displayHealPrediction = true,
		displayNameWhenSelected = true,
		displayQuest = true,

		greyOutWhenTapDenied = true,
		showClassificationIndicator = true, -- Elite border
		tankBorderColor = true,
		--displayDispelDebuffs = true,
		--smoothHealthUpdates = false,
		--fadeOutOfRange = false,
		--displayStatusText = true,
		--playLoseAggroHighlight = true,
	},

	playerConfig = {
		displayHealPrediction = true,
		filter = "HELPFUL",
		useClassColors = true,
		hideCastbar = true,
		healthBarHeight = 4*2,
		manaBarHeight = 4*2,
		
		displaySelectionHighlight = false,
		displayAggroHighlight = false,
		displayName = false,
		fadeOutOfRange = false,
		colorNameBySelection = true,
		smoothHealthUpdates = false,
		displayNameWhenSelected = false,
		hideCastbar = true,
	},
}

ns.config = config
ns.DriverFrame = DriverFrame
ns.UnitFrameMixin = UnitFrameMixin

local BorderTex = 'Interface\\AddOns\\AbuNameplates\\media\\Plate.blp'
local BorderTexGlow = 'Interface\\AddOns\\AbuNameplates\\media\\PlateGlow.blp'
local MarkTex = 'Interface\\AddOns\\AbuNameplates\\media\\Mark.blp'
local HighlightTex = 'Interface\\AddOns\\AbuNameplates\\media\\Highlight.blp'

local TexCoord 		= {24/256, 186/256, 35/128, 59/128}
local CbTexCoord 	= {24/256, 186/256, 59/128, 35/128}
local GlowTexCoord 	= {15/256, 195/256, 21/128, 73/128}
local CbGlowTexCoord= {15/256, 195/256, 73/128, 21/128}
local HiTexCoord 	= {5/128, 105/128, 20/32, 26/32}

local raidIconColor = {
	[1] = {r = 1.0,  g = 0.92, b = 0,     },
	[2] = {r = 0.98, g = 0.57, b = 0,     },
	[3] = {r = 0.83, g = 0.22, b = 0.9,   },
	[4] = {r = 0.04, g = 0.95, b = 0,     },
	[5] = {r = 0.7,  g = 0.82, b = 0.875, },
	[6] = {r = 0,    g = 0.71, b = 1,     },
	[7] = {r = 1.0,  g = 0.24, b = 0.168, },
	[8] = {r = 0.98, g = 0.98, b = 0.98,  },
}

local Backdrop = {
	bgFile = 'Interface\\Buttons\\WHITE8x8',
}

local insetFunctions = {
	["player"] = C_NamePlate.SetNamePlateSelfPreferredClickInsets,
	["friendly"] =  C_NamePlate.SetNamePlateFriendlyPreferredClickInsets,
	["enemy"] = C_NamePlate.SetNamePlateEnemyPreferredClickInsets
}

-------
--  DriverFrame
------

function DriverFrame:OnEvent(event, ...)
	if (event == 'ADDON_LOADED') then
		local addon_name = ...
		if (addon_name == ADDON) then
			self:OnLoad()
		end
	elseif event == 'VARIABLES_LOADED' then
		self:UpdateNamePlateOptions();
	elseif (event == 'NAME_PLATE_CREATED') then
		local namePlateFrameBase = ...
		self:OnNamePlateCreated(namePlateFrameBase)
	elseif (event == 'NAME_PLATE_UNIT_ADDED') then
		local namePlateUnitToken = ...
		self:OnNamePlateAdded(namePlateUnitToken)
	elseif (event == 'NAME_PLATE_UNIT_REMOVED') then
		local namePlateUnitToken = ...
		self:OnNamePlateRemoved(namePlateUnitToken)
	elseif event == 'PLAYER_TARGET_CHANGED' then
		self:OnTargetChanged();
	elseif event == 'DISPLAY_SIZE_CHANGED' then -- resolution change
		self:UpdateNamePlateOptions()
	elseif event == "CVAR_UPDATE" then
		local name = ...;
		if name == "SHOW_CLASS_COLOR_IN_V_KEY" or name == "SHOW_NAMEPLATE_LOSE_AGGRO_FLASH" then
			self:UpdateNamePlateOptions();
		end
	elseif event == 'UPDATE_MOUSEOVER_UNIT' then
		self:UpdateMouseOver()
	elseif event == 'UNIT_FACTION' then
		self:OnUnitFactionChanged(...)
	elseif event == 'RAID_TARGET_UPDATE' then
		self:OnRaidTargetUpdate()
	elseif event == 'QUEST_LOG_UPDATE' then
		self:OnQuestLogUpdate()
	elseif event == 'UNIT_AURA' then
		local unit = ...
		if strsub(unit, 1, 9) ~= 'nameplate' then return; end --dont update twice
		self:OnUnitAuraUpdate(unit)
	end
end

DriverFrame:SetScript('OnEvent', DriverFrame.OnEvent)
DriverFrame:RegisterEvent'ADDON_LOADED'
DriverFrame:RegisterEvent'VARIABLES_LOADED'

function DriverFrame:DisableBlizzard()
	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame:Hide()

	-- blizzard option panel calls this
	NamePlateDriverFrame.UpdateNamePlateOptions = function() 
		DriverFrame:UpdateNamePlateOptions()
	end

	-- Fix a taint with SetTargetClampingInsets 
	NamePlateDriverFrame.SetupClassNameplateBars = function(self)
		local targetMode = GetCVarBool("nameplateResourceOnTarget");
		if (self.nameplateBar and self.nameplateBar.overrideTargetMode ~= nil) then
			targetMode = self.nameplateBar.overrideTargetMode;
		end
		self:SetupClassNameplateBar(targetMode, self.nameplateBar);
		self:SetupClassNameplateBar(false, self.nameplateManaBar);

		--if targetMode and self.nameplateBar then
		--	local percentOffset = tonumber(GetCVar("nameplateClassResourceTopInset"));
		--	if self:IsUsingLargerNamePlateStyle() then
		--		percentOffset = percentOffset + .1;
		--	end
		--	C_NamePlate.SetTargetClampingInsets(percentOffset * UIParent:GetHeight(), 0.0);
		--else
		--	C_NamePlate.SetTargetClampingInsets(0.0, 0.0);
		--end
	end
end

function DriverFrame:OnLoad()
	self:DisableBlizzard()

	self:RegisterEvent'NAME_PLATE_CREATED'
	self:RegisterEvent'NAME_PLATE_UNIT_ADDED'
	self:RegisterEvent'NAME_PLATE_UNIT_REMOVED'

	self:RegisterEvent'PLAYER_TARGET_CHANGED'

	self:RegisterEvent'DISPLAY_SIZE_CHANGED' -- Resolution change
	self:RegisterEvent'CVAR_UPDATE'

	self:RegisterEvent'UPDATE_MOUSEOVER_UNIT'
	self:RegisterEvent'UNIT_FACTION'

	self:RegisterEvent'RAID_TARGET_UPDATE'
	self:RegisterEvent'QUEST_LOG_UPDATE'

	self:RegisterEvent'UNIT_AURA'
end

function DriverFrame:UpdateNamePlateOptions()
	self.baseNamePlateWidth = 110;
	self.baseNamePlateHeight = 45;

	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"));
	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"));
	C_NamePlate.SetNamePlateFriendlySize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight);
	C_NamePlate.GetNamePlateEnemySize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight);
	C_NamePlate.SetNamePlateSelfSize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight);


	for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
		frame.UnitFrame:ApplyFrameOptions(frame.UnitFrame.unit);
		frame.UnitFrame:UpdateAllElements()
	end

	self:UpdateClassResourceBar()
	self:UpdateManaBar()
end

function DriverFrame:OnNamePlateCreated(nameplate)
	local f = CreateFrame('Button', nameplate:GetName()..'UnitFrame', nameplate)
	f:SetAllPoints(nameplate)
	f:Show()
	Mixin(f, UnitFrameMixin)
	f:Create(nameplate)
	f:EnableMouse(false)
	f.currentInsetType = ""

	nameplate.UnitFrame = f
end

function DriverFrame:OnNamePlateAdded(namePlateUnitToken)
	local nameplate = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken)
	nameplate.UnitFrame:ApplyFrameOptions(namePlateUnitToken)
	nameplate.UnitFrame:OnAdded(namePlateUnitToken)
	nameplate.UnitFrame:UpdateAllElements()

	self:UpdateManaBar()
	self:UpdateClassResourceBar()
	self:OnUnitAuraUpdate(namePlateUnitToken);
end

function DriverFrame:OnNamePlateRemoved(namePlateUnitToken)
	local nameplate = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken)
	nameplate.UnitFrame:OnAdded(nil)
end

function DriverFrame:OnTargetChanged()
	local nameplate = C_NamePlate.GetNamePlateForUnit'target'
	if nameplate then
		self:OnUnitAuraUpdate'target'
	end

	self:UpdateManaBar()
	self:UpdateClassResourceBar()
end

function DriverFrame:OnUnitAuraUpdate(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
	if (nameplate) then
		--nameplate.UnitFrame.BuffFrame:UpdateBuffs(unit);
		nameplate.UnitFrame.BuffFrame:UpdateBuffs(unit, nameplate.UnitFrame.optionTable.filter)
	end
end

function DriverFrame:OnRaidTargetUpdate()
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		frame.UnitFrame:UpdateRaidTarget()
		CompactUnitFrame_UpdateHealthColor(frame.UnitFrame)
	end
end

function DriverFrame:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
	if (nameplate) then
		CompactUnitFrame_UpdateName(nameplate.UnitFrame);
		CompactUnitFrame_UpdateHealthColor(nameplate.UnitFrame);
	end
end

function DriverFrame:OnQuestLogUpdate()
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		frame.UnitFrame:UpdateQuestVisuals()
	end
end

local mouseoverframe -- if theres a better way im all ears
function DriverFrame:OnUpdate(elapsed) 
	local nameplate = C_NamePlate.GetNamePlateForUnit'mouseover'
	if not nameplate or nameplate ~= mouseoverframe then
		mouseoverframe.UnitFrame.hoverHighlight:Hide()
		mouseoverframe = nil
		self:SetScript('OnUpdate', nil)
	end
end

function DriverFrame:UpdateMouseOver()
	local nameplate = C_NamePlate.GetNamePlateForUnit'mouseover'

	if mouseoverframe == nameplate then
		return
	elseif mouseoverframe then
		mouseoverframe.UnitFrame.hoverHighlight:Hide()
		self:SetScript('OnUpdate', nil)
	end

	if nameplate then
		nameplate.UnitFrame.hoverHighlight:Show()
		mouseoverframe = nameplate
		self:SetScript('OnUpdate', self.OnUpdate) --onupdate until mouse leaves frame
	end
end

-------------------------
--	Class Resource bar
-------------------------

function DriverFrame:UpdateClassResourceBar()
	local classResourceBar = NamePlateDriverFrame.nameplateBar;
	if ( not classResourceBar ) then 
		return;
	end
	classResourceBar:Hide();

	local showSelf = GetCVar("nameplateShowSelf");
	if ( showSelf == "0" ) then
		return;
	end

	local targetMode = GetCVarBool("nameplateResourceOnTarget");
	if (classResourceBar.overrideTargetMode ~= nil) then
		targetMode = classResourceBar.overrideTargetMode;
	end

	if ( targetMode ) then
		local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target");
		if ( namePlateTarget ) then
			classResourceBar:SetParent(NamePlateTargetResourceFrame);
			NamePlateTargetResourceFrame:SetParent(namePlateTarget.UnitFrame);
			NamePlateTargetResourceFrame:ClearAllPoints();
			NamePlateTargetResourceFrame:SetPoint("BOTTOM", namePlateTarget.UnitFrame.name, "TOP", 0, 9);
			classResourceBar:Show();
		end
		NamePlateTargetResourceFrame:SetShown(namePlateTarget ~= nil);
	elseif ( not targetMode ) then
		local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
		if ( namePlatePlayer ) then
			classResourceBar:SetParent(NamePlatePlayerResourceFrame);
			NamePlatePlayerResourceFrame:SetParent(namePlatePlayer.UnitFrame);
			NamePlatePlayerResourceFrame:ClearAllPoints();
			NamePlatePlayerResourceFrame:SetPoint("TOP",ClassNameplateManaBarFrame, "BOTTOM", 0, -3);
			classResourceBar:Show();
		end
		NamePlatePlayerResourceFrame:SetShown(namePlatePlayer ~= nil);
	end
end

-------------------------
--	Class Mana Bar
-------------------------

local manabar = ClassNameplateManaBarFrame
manabar:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
manabar:SetBackdrop(Backdrop)
manabar:SetBackdropColor(0, 0, 0, .8)
manabar.Border:Hide()

manabar.FeedbackFrame.BarTexture:SetTexture(config.StatusbarTexture)

manabar.border = manabar:CreateTexture(nil, 'ARTWORK', nil, 2)
manabar.border:SetTexture(BorderTex)
manabar.border:SetTexCoord(unpack(TexCoord))
manabar.border:SetPoint('TOPLEFT', manabar, -4, 6)
manabar.border:SetPoint('BOTTOMRIGHT', manabar, 4, -6)
manabar.border:SetVertexColor(unpack(config.Colors.Frame))

function ClassNameplateManaBarFrame:OnOptionsUpdated()
	self:SetHeight(config.playerConfig.healthBarHeight);
end

function DriverFrame:UpdateManaBar()
	manabar:Hide()

	local showSelf = GetCVar("nameplateShowSelf");
	if ( showSelf == "0" ) then
		return;
	end

	local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
	if ( namePlatePlayer ) then
		manabar:SetParent(namePlatePlayer);
		manabar:ClearAllPoints();
		manabar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMLEFT", 0, -6);
		manabar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -6);
		manabar:Show();
	end
end

------------------------
--	Nameplate
------------------------
local function UpdateBuffs(self, unit, filter) -- All this just so I can change the look
	self.unit = unit;
	self.filter = filter
	self:UpdateAnchor();

	if filter == "NONE" then
		for i, buff in ipairs(self.buffList) do
			buff:Hide();
		end
	else
		-- Some buffs may be filtered out, use this to create the buff frames.
		local buffIndex = 1;
		for i = 1, BUFF_MAX_DISPLAY do
			local name, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura(unit, i, filter);
			if (self:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll, duration)) then
				local buff = self.buffList[buffIndex]
				if (not buff) then
					buff = CreateFrame("Frame", self:GetParent():GetName() .. "Buff" .. buffIndex, self, "NameplateBuffButtonTemplate");
					self.buffList[buffIndex] = buff
					buff:SetSize(26,18)
					buff.Icon:SetSize(24,16)
					buff.Icon:SetDrawLayer('BACKGROUND', 0)

					buff.Border:SetTexture(config.IconTextures.Normal)
					buff.Border:SetDrawLayer('OVERLAY', 1)

					buff.CountFrame.Count:SetFont(config.Font, config.FontSize, 'THINOUTLINE') -- Why does it have its own frame?

					buff.Cooldown:SetHideCountdownNumbers(false)
					buff.Cooldown:SetFrameLevel(buff:GetFrameLevel())

					buff.Cooldown.Text = buff.Cooldown:GetRegions()
					buff.Cooldown.Text:SetFont(config.Font, config.FontSize, 'THINOUTLINE')
					buff.Cooldown.Text:SetPoint('CENTER', buff, 'CENTER', 0.5, 8)

					buff:SetMouseClickEnabled(false);
					buff.layoutIndex = buffIndex;
				end
				local buff = self.buffList[buffIndex];
				buff:SetID(i);
				buff.name = name;
				buff.Icon:SetTexture(texture);
				if (count > 1) then
					buff.CountFrame.Count:SetText(count);
					buff.CountFrame.Count:Show();
				else
					buff.CountFrame.Count:Hide();
				end

				CooldownFrame_Set(buff.Cooldown, expirationTime - duration, duration, duration > 0, true);

				buff:Show();
				buffIndex = buffIndex + 1;
			else
				if self.buffList[i] then
					self.buffList[i]:Hide();
				end
			end
		end
	end
	self:Layout();
end

local function shieldShow(self)
	local border = self:GetParent().IconBorder
	border:SetTexture(config.IconTextures.White)
	border:SetVertexColor(unpack(config.Colors.Interrupt))
end
local function shieldHide(self)
	local border = self:GetParent().IconBorder
	border:SetTexture(config.IconTextures.Normal)
	border:SetVertexColor(unpack(config.Colors.Border))
end

function UnitFrameMixin:Create(unitframe)
	-- Healthbar
	local h = CreateFrame('Statusbar', '$parentHealthBar', unitframe)
	self.healthBar = h
	h:SetFrameLevel(90)
	h:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
	h:SetBackdrop(Backdrop)
	h:SetBackdropColor(0, 0, 0, .8)

	-- 	Healthbar textures --blizzard capital letters policy
	self.myHealPrediction = h:CreateTexture('$parentmyHealPrediction', 'BORDER', nil, 5)
	self.myHealPrediction:SetVertexColor(0.0, 0.659, 0.608)
	self.myHealPrediction:SetTexture(config.StatusbarTexture)

	self.otherHealPrediction = h:CreateTexture('$parentotherHealPrediction', 'ARTWORK', nil, 5)
	self.otherHealPrediction:SetVertexColor(0.0, 0.659, 0.608)
	self.otherHealPrediction:SetTexture(config.StatusbarTexture)

	self.totalAbsorb = h:CreateTexture('$parenttotalAbsorb', 'ARTWORK', nil, 5)
	self.totalAbsorb:SetTexture[[Interface\RaidFrame\Shield-Fill]]
	--
	self.totalAbsorbOverlay = h:CreateTexture('$parenttotalAbsorbOverlay', 'BORDER', nil, 6)
	self.totalAbsorbOverlay:SetTexture([[Interface\RaidFrame\Shield-Overlay]], true, true);	--Tile both vertically and horizontally
	self.totalAbsorbOverlay:SetAllPoints(self.totalAbsorb);
	self.totalAbsorbOverlay.tileSize = 20;
	self.totalAbsorb.overlay = self.totalAbsorbOverlay -- for CompactUnitFrameUtil_UpdateFillBar
	--
	self.myHealAbsorb = h:CreateTexture('$parentmyHealAbsorb', 'ARTWORK', nil, 1)
	self.myHealAbsorb:SetTexture([[Interface\RaidFrame\Absorb-Fill]], true, true)

	self.myHealAbsorbLeftShadow = h:CreateTexture('$parentmyHealAbsorbLeftShadow', 'ARTWORK', nil, 1)
	self.myHealAbsorbLeftShadow:SetTexture[[Interface\RaidFrame\Absorb-Edge]]

	self.myHealAbsorbRightShadow = h:CreateTexture('$parentmyHealAbsorbRightShadow', 'ARTWORK', nil, 1)
	self.myHealAbsorbRightShadow:SetTexture[[Interface\RaidFrame\Absorb-Edge]]
	self.myHealAbsorbRightShadow:SetTexCoord(1, 0, 0, 1)
	--
	h.border = h:CreateTexture('$parentborder', 'ARTWORK', nil, 2)
	h.border:SetTexture(BorderTex)
	h.border:SetTexCoord(unpack(TexCoord))
	h.border:SetPoint('TOPLEFT', h, -4, 6)
	h.border:SetPoint('BOTTOMRIGHT', h, 4, -6)
	h.border:SetVertexColor(unpack(config.Colors.Frame))
	--
	self.overAbsorbGlow = h:CreateTexture('$parentoverAbsorbGlow', 'ARTWORK', nil, 3)
	self.overAbsorbGlow:SetTexture[[Interface\RaidFrame\Shield-Overshield]]
	self.overAbsorbGlow:SetBlendMode'ADD'
	self.overAbsorbGlow:SetPoint('BOTTOMLEFT', h, 'BOTTOMRIGHT', -4, -1)
	self.overAbsorbGlow:SetPoint('TOPLEFT', h, 'TOPRIGHT', -4, 1)
	self.overAbsorbGlow:SetWidth(8);

	self.overHealAbsorbGlow = h:CreateTexture('$parentoverHealAbsorbGlow', 'ARTWORK', nil, 3)
	self.overHealAbsorbGlow:SetTexture[[Interface\RaidFrame\Absorb-Overabsorb]]
	self.overHealAbsorbGlow:SetBlendMode'ADD'
	self.overHealAbsorbGlow:SetPoint('BOTTOMRIGHT', h, 'BOTTOMLEFT', 2, -1)
	self.overHealAbsorbGlow:SetPoint('TOPRIGHT', h, 'TOPLEFT', 2, 1)
	self.overHealAbsorbGlow:SetWidth(8);

	-- Castbar
	local c = CreateFrame('StatusBar', '$parentCastBar', nameplate)
	do
		self.castBar = c
		c:SetFrameLevel(100)
		c:Hide()
		c:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
		c:SetBackdrop(Backdrop)
		c:SetBackdropColor(0, 0, 0, .5)

		--		Castbar textures
		c.border = c:CreateTexture('$parentborder', 'ARTWORK', nil, 0)
		c.border:SetTexCoord(unpack(CbTexCoord))
		c.border:SetTexture(BorderTex)
		c.border:SetPoint('TOPLEFT', c, -4, 6)
		c.border:SetPoint('BOTTOMRIGHT', c, 4, -6)
		c.border:SetVertexColor(unpack(config.Colors.Frame))

		c.BorderShield = c:CreateTexture('$parentBorderShield', 'ARTWORK', nil, 1)
		c.BorderShield:SetTexture(MarkTex)
		c.BorderShield:SetTexCoord(unpack(CbTexCoord))
		c.BorderShield:SetAllPoints(c.border)
		c.BorderShield:SetBlendMode'ADD'
		c.BorderShield:SetVertexColor(1, .9, 0, 0.7)
		CastingBarFrame_AddWidgetForFade(c, c.BorderShield)
		hooksecurefunc(c.BorderShield, 'Show', shieldShow)
		hooksecurefunc(c.BorderShield, 'Hide', shieldHide)

		c.Text = c:CreateFontString('$parentText', 'OVERLAY', nil, 1)
		c.Text:SetPoint('CENTER', c, 0, 0)
		c.Text:SetPoint('LEFT', c, 0, 0)
		c.Text:SetPoint('RIGHT', c, 0, 0)
		c.Text:SetFont(config.Font, config.FontSize, 'THINOUTLINE')
		c.Text:SetShadowColor(0, 0, 0, 0)

		c.Icon = c:CreateTexture('$parentIcon', 'OVERLAY', nil, 1)
		c.Icon:SetTexCoord(.1, .9, .1, .9)
		c.Icon:SetPoint('BOTTOMRIGHT', c, 'BOTTOMLEFT', -7, 0)
		c.Icon:SetPoint('TOPRIGHT', h, 'TOPLEFT', -7, 0)
		CastingBarFrame_AddWidgetForFade(c, c.Icon)

		c.IconBorder = c:CreateTexture('$parentIconBorder', 'OVERLAY', nil, 2)
		c.IconBorder:SetTexture(config.IconTextures.Normal)
		c.IconBorder:SetVertexColor(unpack(config.Colors.Border))
		c.IconBorder:SetPoint('TOPRIGHT', c.Icon, 2, 2)
		c.IconBorder:SetPoint('BOTTOMLEFT', c.Icon, -2, -2)
		CastingBarFrame_AddWidgetForFade(c, c.IconBorder)

		c.Spark = c:CreateTexture('$parentSpark', 'OVERLAY', nil, 2)
		c.Spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
		c.Spark:SetBlendMode'ADD'
		c.Spark:SetSize(16,16)
		c.Spark:SetPoint('CENTER', c, 0, 0)

		c.Flash = c:CreateTexture('$parentFlash', 'OVERLAY', nil, 2)
		c.Flash:SetTexture(config.StatusbarTexture)
		c.Flash:SetBlendMode'ADD'

		c:SetScript('OnEvent', CastingBarFrame_OnEvent)
		c:SetScript('OnUpdate',CastingBarFrame_OnUpdate)
		c:SetScript('OnShow', CastingBarFrame_OnShow)
		CastingBarFrame_OnLoad(c, nil, false, true);
		--CastingBarFrame_SetNonInterruptibleCastColor(c, 0.7, 0.7, 0.7)
	end

	-- Misc
	self.classificationIndicator = h:CreateTexture(nil, 'OVERLAY', nil)
	self.classificationIndicator:SetSize(14,13)
	self.classificationIndicator:SetPoint('RIGHT', h, 'LEFT', 0, 0)

	self.raidTargetIcon = h:CreateTexture(nil, 'OVERLAY', nil)
	self.raidTargetIcon:SetSize(18,18)
	self.raidTargetIcon:SetPoint('LEFT', h, 'RIGHT', 4, 1)
	self.raidTargetIcon:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]]

	self.name = h:CreateFontString(nil, 'ARTWORK', 5)
	self.name:SetPoint('BOTTOM', h, 'TOP', 0, 4)
	self.name:SetWordWrap(false)
	self.name:SetJustifyH'CENTER'
	self.name:SetFont(config.Font, config.FontSize, 'THINOUTLINE')

	self.aggroHighlight = h:CreateTexture(nil, 'BORDER', nil, 4)
	self.aggroHighlight:SetTexture(BorderTexGlow)
	self.aggroHighlight:SetTexCoord(unpack(GlowTexCoord))
	self.aggroHighlight:SetPoint('TOPLEFT', h.border, -7, 15)
	self.aggroHighlight:SetPoint('BOTTOMRIGHT', h.border, 7, -15)
	self.aggroHighlight:SetAlpha(.7)
	self.aggroHighlight:Hide()

	self.hoverHighlight = h:CreateTexture(nil, 'ARTWORK', nil, 1)
	self.hoverHighlight:SetTexture(HighlightTex)
	self.hoverHighlight:SetAllPoints(h)
	self.hoverHighlight:SetVertexColor(1, 1, 1)
	self.hoverHighlight:SetBlendMode('ADD')
	self.hoverHighlight:SetTexCoord(unpack(HiTexCoord))
	self.hoverHighlight:Hide()

	self.selectionHighlight = h:CreateTexture(nil, 'ARTWORK', nil, 4)
	self.selectionHighlight:SetTexture(MarkTex)
	self.selectionHighlight:SetTexCoord(unpack(TexCoord))
	self.selectionHighlight:SetAllPoints(h.border)
	self.selectionHighlight:SetBlendMode('ADD')
	self.selectionHighlight:SetVertexColor(.8, .8, 1, .7)
	self.selectionHighlight:Hide()
	self.selectionHighlight._SetVertexColor = self.selectionHighlight.SetVertexColor
	self.selectionHighlight.SetVertexColor = nop

	self.BuffFrame = CreateFrame('StatusBar', '$parentBuffFrame', self, 'HorizontalLayoutFrame')
	Mixin(self.BuffFrame, NameplateBuffContainerMixin)
	self.BuffFrame:SetPoint('LEFT', self.healthBar, -1, 0)
	self.BuffFrame.spacing = 4
	self.BuffFrame.fixedHeight = 18
	self.BuffFrame:SetScript('OnEvent', self.BuffFrame.OnEvent)
	self.BuffFrame:SetScript('OnUpdate', self.BuffFrame.OnUpdate)
	self.BuffFrame:OnLoad()
	self.BuffFrame.UpdateBuffs = UpdateBuffs

	-- Quest
	self.questIcon = self:CreateTexture(nil, nil, nil, 0)
	self.questIcon:SetSize(28, 22)
	self.questIcon:SetTexture('Interface/QuestFrame/AutoQuest-Parts')
	self.questIcon:SetTexCoord(0.30273438, 0.41992188, 0.015625, 0.953125)
	self.questIcon:SetPoint('LEFT', h, 'RIGHT', 4, 0)

	self.questText = self:CreateFontString(nil, nil, "SystemFont_Outline_Small")
	self.questText:SetPoint('CENTER', self.questIcon, 1, 1)
	self.questText:SetShadowOffset(1, -1)
	self.questText:SetTextColor(1,.82,0)
end

function UnitFrameMixin:ApplyFrameOptions(namePlateUnitToken)
	local unit
	if UnitIsUnit('player', namePlateUnitToken) then 
		unit = 'player'
		self.optionTable = config.playerConfig
	elseif UnitIsFriend('player', namePlateUnitToken) then 
		unit = 'friendly'
		self.optionTable = config.friendlyConfig
	else 
		unit = 'enemy'
		self.optionTable = config.enemyConfig
	end

	if unit == 'player' then
		self.healthBar:SetPoint('LEFT', self, 'LEFT', 12, 5);
		self.healthBar:SetPoint('RIGHT', self, 'RIGHT', -12, 5);
		self.healthBar:SetHeight(self.optionTable.healthBarHeight);

	else
		self.castBar:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 12, 6);
		self.castBar:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -12, 6);
		self.castBar:SetHeight(self.optionTable.castBarHeight);
		self.castBar.Icon:SetWidth(self.optionTable.castBarHeight + self.optionTable.healthBarHeight + 6)
	
		self.healthBar:SetPoint('BOTTOMLEFT', self.castBar, 'TOPLEFT', 0, 6);
		self.healthBar:SetPoint('BOTTOMRIGHT', self.castBar, 'TOPRIGHT', 0, 6);
		self.healthBar:SetHeight(self.optionTable.healthBarHeight);
	end

	-- update insets, lazy way
	if false and not (self.currentInsetType == unit) then
		print(self:GetName(),'new inset type', unit,'old:',self.currentInsetType)
		self.currentInsetType = unit
		local nameplate = self:GetParent()
		nameplate.GetAdditionalInsetPadding = NamePlateBaseMixin.GetAdditionalInsetPadding
		insetFunctions[unit](NamePlateBaseMixin.GetPreferredInsets(nameplate))
	end
end

function UnitFrameMixin:OnAdded(namePlateUnitToken)
	self.unit = namePlateUnitToken
	self.displayedUnit = namePlateUnitToken
	self.inVehicle = false;
	
	if namePlateUnitToken then 
		self:RegisterEvents()
	else
		self:UnregisterEvents()
	end

	if self.castBar then
		if namePlateUnitToken and (not self.optionTable.hideCastbar) then
			CastingBarFrame_SetUnit(self.castBar, namePlateUnitToken, false, true);
		else
			CastingBarFrame_SetUnit(self.castBar, nil, nil, nil);
		end
	end
end

function UnitFrameMixin:RegisterEvents()
	self:RegisterEvent'UNIT_NAME_UPDATE'
	self:RegisterEvent'PLAYER_TARGET_CHANGED'

	self:RegisterEvent'UNIT_ENTERED_VEHICLE'
	self:RegisterEvent'UNIT_EXITED_VEHICLE'
	self:RegisterEvent'UNIT_PET'

	self:UpdateUnitEvents();
	self:SetScript('OnEvent', self.OnEvent);
end

function UnitFrameMixin:UpdateUnitEvents()
	local unit = self.unit;
	local displayedUnit;
	if ( unit ~= self.displayedUnit ) then
		displayedUnit = self.displayedUnit;
	end
	self:RegisterUnitEvent('UNIT_MAXHEALTH', unit, displayedUnit);
	self:RegisterUnitEvent('UNIT_HEALTH_FREQUENT', unit, displayedUnit); 

	self:RegisterUnitEvent('UNIT_THREAT_SITUATION_UPDATE', unit, displayedUnit);
	self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE', unit, displayedUnit);
	self:RegisterUnitEvent('UNIT_HEAL_PREDICTION', unit, displayedUnit);

	self:RegisterUnitEvent('UNIT_ABSORB_AMOUNT_CHANGED', unit.displayedUnit);
	self:RegisterUnitEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', unit.displayedUnit);
end

function UnitFrameMixin:UnregisterEvents()
	self:SetScript('OnEvent', nil)
	self:UnregisterAllEvents()
end

function UnitFrameMixin:UpdateAllElements()
	self:UpdateInVehicle()

	if UnitExists(self.displayedUnit) then
		self:UpdateRaidTarget()
		CompactUnitFrame_UpdateSelectionHighlight(self)
		CompactUnitFrame_UpdateMaxHealth(self) 
		CompactUnitFrame_UpdateHealth(self)
		CompactUnitFrame_UpdateHealPrediction(self)
		CompactUnitFrame_UpdateClassificationIndicator(self)
		CompactUnitFrame_UpdateHealthColor(self)
		self:UpdateName()
		self:UpdateThreat()
		self:UpdateQuestVisuals()
	end
end

function UnitFrameMixin:OnEvent(event, ...)
	local arg1, arg2, arg3, arg4 = ...

	if ( event == 'PLAYER_TARGET_CHANGED' ) then
		CompactUnitFrame_UpdateSelectionHighlight(self);
		self:UpdateName()
	elseif ( arg1 == self.unit or arg1 == self.displayedUnit ) then
		if ( event == 'UNIT_MAXHEALTH' ) then
			CompactUnitFrame_UpdateMaxHealth(self)
			CompactUnitFrame_UpdateHealth(self)
			CompactUnitFrame_UpdateHealPrediction(self)
		elseif ( event == 'UNIT_HEALTH' or event == 'UNIT_HEALTH_FREQUENT' ) then
			CompactUnitFrame_UpdateHealth(self)
			CompactUnitFrame_UpdateHealPrediction(self)
		elseif ( event == 'UNIT_NAME_UPDATE' ) then
			self:UpdateName()
			CompactUnitFrame_UpdateHealthColor(self)
		elseif ( event == 'UNIT_THREAT_SITUATION_UPDATE' ) then
			self:UpdateThreat()
		elseif ( event == 'UNIT_THREAT_LIST_UPDATE' ) then
			if ( self.optionTable.considerSelectionInCombatAsHostile ) then
				CompactUnitFrame_UpdateHealthColor(self)
				self:UpdateName()
			end
			self:UpdateThreat()
		elseif ( event == 'UNIT_HEAL_PREDICTION' or event == 'UNIT_ABSORB_AMOUNT_CHANGED' or event == 'UNIT_HEAL_ABSORB_AMOUNT_CHANGED' ) then
			CompactUnitFrame_UpdateHealPrediction(self)
		elseif ( event == 'UNIT_ENTERED_VEHICLE' or event == 'UNIT_EXITED_VEHICLE' or event == 'UNIT_PET' ) then
			self:UpdateAllElements()
		end
	end
end

function UnitFrameMixin:UpdateInVehicle()
	if ( UnitHasVehicleUI(self.unit) ) then
		if ( not self.inVehicle ) then
			self.inVehicle = true
			local prefix, id, suffix = string.match(self.unit, '([^%d]+)([%d]*)(.*)')
			self.displayedUnit = prefix..'pet'..id..suffix
			self:UpdateUnitEvents()
		end
	else
		if ( self.inVehicle ) then
			self.inVehicle = false
			self.displayedUnit = self.unit
			self:UpdateUnitEvents()
		end
	end
end

function UnitFrameMixin:UpdateRaidTarget()
	local icon = self.raidTargetIcon;
	local index = GetRaidTargetIndex(self.unit)
	if ( index ) then
		SetRaidTargetIconTexture(icon, index);
		icon:Show();
		if self.optionTable.colorHealthByRaidIcon then
			self.optionTable.healthBarColorOverride = raidIconColor[index]
		end
	else
		self.optionTable.healthBarColorOverride = nil
		icon:Hide();
	end
end

function UnitFrameMixin:UpdateName()
	if ( not ShouldShowName(self) ) then
		self.name:Hide();
	else
		self.name:SetText(GetUnitName(self.unit, true));

		local _, eClass = UnitClass(self.unit)
		local cColor = UnitIsPlayer(self.unit) and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[eClass]

		if ( self.optionTable.colorNameByClass and cColor) then
			self.name:SetVertexColor(cColor.r, cColor.g, cColor.b)
		elseif ( CompactUnitFrame_IsTapDenied(self) ) then
			-- Use grey if not a player and can't get tap on unit
			self.name:SetVertexColor(0.5, 0.5, 0.5);
		elseif ( self.optionTable.colorNameBySelection ) then
			if ( self.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(self.displayedUnit) ) then
				self.name:SetVertexColor(1.0, 0.0, 0.0);
			else
				self.name:SetVertexColor(UnitSelectionColor(self.unit, self.optionTable.colorNameWithExtendedColors));
			end
		else
			self.name:SetVertexColor(1, 1, 1)
		end

		self.name:Show();
	end
end

function UnitFrameMixin:UpdateThreat()
	local tex = self.aggroHighlight
	if not self.optionTable.tankBorderColor then
		tex:Hide() 
		return
	end

	local isTanking, status = UnitDetailedThreatSituation('player', self.displayedUnit)
	if status ~= nil then
		if ns.IsPlayerEffectivelyTank() then
			status = math.abs(status - 3)
		end
		if status > 0 then
			tex:SetVertexColor(GetThreatStatusColor(status))
			if not tex:IsShown() then 
				tex:Show()
			end
			return
		end
	end
	tex:Hide() 
end

function UnitFrameMixin:UpdateQuestVisuals()
	local isQuest, numLeft = ns.GetUnitQuestInfo(self.displayedUnit)
	if ( self.optionTable.displayQuest and isQuest ) then
		if (numLeft > 0) then
			self.questText:SetText(numLeft)
		else
			self.questText:SetText('?')
		end
		self.questIcon:Show()
	else
		self.questText:SetText(nil)
		self.questIcon:Hide()
	end
end

