local name, ns = ...

local cfg = ns.Config
if (not cfg.Tooltip.Enable) then return; end

local cfgGlobal = ns.GlobalConfig

local playerGUID
local ShowIDs = false

local 	GetTime, UnitName, UnitLevel, UnitExists, UnitIsDeadOrGhost, UnitFactionGroup, UnitIsPlayer, GetMouseFocus =
		GetTime, UnitName, UnitLevel, UnitExists, UnitIsDeadOrGhost, UnitFactionGroup, UnitIsPlayer, GetMouseFocus
local 	UnitClass, UnitIsTapDenied, UnitReaction, IsShiftKeyDown = 
		UnitClass, UnitIsTapDenied, UnitReaction, IsShiftKeyDown
local 	find, format, select, _G, floor, unpack, GameTooltip =
		find, format, select, _G, floor, unpack, GameTooltip

local roleicons = {
	TANK = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:0:19:22:41|t',
	HEALER = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:1:20|t',
	DAMAGER = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:22:41|t',
	NONE = '',
}

local ILVL_PREFIX = STAT_AVERAGE_ITEM_LEVEL .. ':'

local Classification = {
	worldboss = "|cffAF5050B|r",
	rareelite = "|cffAF5050R+|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050R|r",
}

local Tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	AutoCompleteBox,
	FriendsTooltip,
	ConsolidatedBuffsTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	WorldMapTooltip.BackdropFrame,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3,
	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,
	DropDownList3MenuBackdrop,
	BNToastFrame,
	SmallTextTooltip,
	EmbeddedItemTooltip,
}

local COLORS = {
	NIL = 	 { r = 1,  g = 1,  b = 1 },
	TAPPED = { r = 0.6,g = 0.6,b = 0.6 },
}

-- Get the Unit Color
local function GetUnitColor( unit )
	if (not unit) then unit = "mouseover" end

	local color
	if (UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		color = _G.RAID_CLASS_COLORS[class]
	elseif (UnitIsTapDenied(unit)) then
		color = COLORS.TAPPED
	else
		local reaction = UnitReaction(unit, "player")
		if (reaction) then
			color = _G.FACTION_BAR_COLORS[reaction]
		end
	end
	if (not color) then
		color = COLORS.NIL
	end
	return color, color.r, color.g, color.b
end

-- Format Numbers
local function GetFormattedValue(val)
	if(val >= 1e6) then
		return ("%.2fm"):format(val / 1e6)
	elseif(val >= 1e3) then
		return ("%.0fk"):format(val / 1e3)
	else
		return ("%d"):format(val)
	end
end

-- Find a line
local function FindLine(self, text, offset)
	offset = offset or 2
	for i=offset, self:NumLines() do
		local tipText = _G[self:GetName().."TextLeft"..i]
		if(tipText:GetText() and tipText:GetText():find(text)) then
			return tipText
		end
	end
end

-- Get the correct Unit
local function GetGameTooltipUnit(self)
	local _, unit = self:GetUnit()

	-- Check if we got the correct unit
	if (not unit) then
		local MFocus = GetMouseFocus()
		if (MFocus and MFocus.GetAttribute and MFocus:GetAttribute("unit")) then
			unit = MFocus:GetAttribute("unit");
		end
		if (not unit) or (not UnitExists(unit)) then
			return false;
		end
	end
	return unit
end

--  [[  Apply The Tooltip Style  ]]  --
local function FixFuckingBlueColor(self)
	self:SetBackdropColor(0, 0, 0, .7)
	self:SetBorderColor(unpack(cfgGlobal.Colors.Border))
end

local function SetTooltipStyle(self)
	if not self then return; end

	local borderSize, bgSize
    if (self == _G.ConsolidatedBuffsTooltip) then
        bgSize = 3
        borderSize = 12
    elseif (self == _G.FriendsTooltip) then
        self:SetScale(1.1)
        bgSize = 3
        borderSize = 8
    else
        bgSize = 3
        borderSize = 12
    end

    local backdrop = {	bgFile = 'Interface\\Buttons\\WHITE8x8', 
						tile = false,
						tileSize = 16,
						edgeSize = 3,
						insets = {left = bgSize, right = bgSize, top = bgSize, bottom = bgSize}};
	self:SetBackdrop(backdrop)

	ns.CreateBorder(self, borderSize, 0)
end

-------------------------------------------------------------
----   Inspect Stuff

local GetInspectInfo, TryInspect
do
	local itemLevelPattern = _G.ITEM_LEVEL:gsub("%%d", "(%%d+)")
	local tt = CreateFrame("GameTooltip", "AbuLevelScanTip", nil, "GameTooltipTemplate")
	tt:SetOwner(WorldFrame, "ANCHOR_NONE")

	local function GetItemLevel(unit, slot)
		tt:ClearLines()
		if not tt:SetInventoryItem(unit, slot, true) then
			return false
		end

		local ilvl
		for i = 2, 5 do
			local text = _G["AbuLevelScanTipTextLeft"..i]:GetText()
			if text and text ~= '' then
				ilvl = tonumber(text:match(itemLevelPattern))
				if ilvl and ilvl > 0 then
					break;
				end
			end
		end
		return ilvl
	end

	local function GetSumItemLevel(unit, startIndex, endIndex)
		local totilvl = 0
		local mainHandlvl, offHandlvl
		for i = startIndex, endIndex do
			if (i ~= INVSLOT_BODY) and (i ~= INVSLOT_TABARD) and (i ~= INVSLOT_RANGED) then
				local ilvl = GetItemLevel(unit, i)
				if not ilvl then 
					return false 
				end
				totilvl = totilvl + ilvl
			end
		end
		return totilvl
	end


	-- Get spec Icon 
	local function GetSpecIcon(unit)
		local spec = GetInspectSpecialization(unit)

		if(spec and spec > 0) then
			local role = GetSpecializationRoleByID(spec);
			if(role ~= nil) then
				local _, _, _, icon = GetSpecializationInfoByID(spec);
				return icon
			end
		end
	end

	local requestedGUID, currentGUID
	local lastInspectTime = 0
	function TryInspect()
		if (InspectFrame and InspectFrame:IsShown()) or UnitIsDeadOrGhost("player") then
			return true;
		end
		local now = GetTime()
		if now - lastInspectTime < 1.5 then return; end
		lastInspectTime = now

		local unit = "mouseover"
		local GUID = UnitExists(unit) and UnitGUID(unit)

		if (GUID) then
			requestedGUID = GUID
			NotifyInspect(unit)
		end
	end

	local delayedItemScanner = CreateFrame('Frame')
	delayedItemScanner:Hide()
	delayedItemScanner:SetScript('OnUpdate', function(self, elapsed)
		local unit = nil
		if UnitExists('mouseover') and UnitGUID('mouseover') == currentGUID then
			unit = 'mouseover'
		elseif UnitExists('target') and UnitGUID('target') == currentGUID then
			unit = 'target'
		end

		if unit then
			local itemLevel = GetSumItemLevel(unit, 1, 15) 
			local weaponIlvl = math.max(GetSumItemLevel(unit, 16, 16) or 0,  GetSumItemLevel(unit, 17, 17) or 0)-- some classes have high level in offhand 
			if itemLevel and weaponIlvl > 0 then
				local cache = GameTooltip.inspectCache[currentGUID]
				local ilvl = math.floor((itemLevel + weaponIlvl)/15)
				if cache.iLvl and cache.iLvl == ilvl or unit == 'target' then -- 2 times same ilvl, MUST BE GOOD (good enough for me anyways)
					cache.lastUpdate = floor(GetTime() + 180)
				end
				cache.iLvl = ilvl

			end
		end
		self:Hide()
	end)

	GameTooltip:HookScript("OnEvent", function(self, event, ...)
		local unit = "mouseover"
		if event == "MODIFIER_STATE_CHANGED" then
			local key = ...
			if((key == "LSHIFT" or key == "RSHIFT") and UnitExists(unit)) then
				self:SetUnit(unit)
			end
		elseif event == "INSPECT_READY" then
			currentGUID = ...

			self.inspectCache[currentGUID] = self.inspectCache[currentGUID] or { }
			local cache = self.inspectCache[currentGUID]
			cache.lastUpdate = 0

			-- Fetch data while we got inspect
			local icon = GetSpecIcon(unit)
			if icon then
				cache.icon = icon
			end
			delayedItemScanner:Show()
			if UnitExists('mouseover') then
				GameTooltip:SetUnit('mouseover')
			end
		end
	end)
	GameTooltip:RegisterEvent('UNIT_INVENTORY_CHANGED')

	-- Getting the inspect Info, sometimes
	function GetInspectInfo(self, unit, level, needIlvl)
		if (not CanInspect(unit)) then return; end

		if (unit == 'player' or UnitIsUnit(unit, 'player')) then
			local _, _, _, icon = GetSpecializationInfo(GetSpecialization() or 0)
			local _, iLvl = GetAverageItemLevel()
			return icon, floor(iLvl)
		end

		local GUID = UnitGUID(unit)
		local cache = self.inspectCache[GUID]
		local icon, iLvl

		if (cache) then
			icon = cache.icon
			iLvl = cache.iLvl

			-- chech if we dont need to update
			if (cache.lastUpdate > GetTime()) and (icon) and (not needIlvl or iLvl) then
				return icon, iLvl
			end
		end
		TryInspect()
		return icon, iLvl
	end
end

local dotmaker = CreateFrame("Frame")
do
	dotmaker.count = 1
	dotmaker.elapsed = 0
	local UPDATE_TIME = 0.5
	local dots = { '.', '..', '...', '..' }

	dotmaker:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < UPDATE_TIME then return; end
		self.elapsed = 0

		local found
		for i = 1, GameTooltip:NumLines() do
			local string = _G['GameTooltipTextLeft'..i]
			local stringtext = string and string:GetText()

			if stringtext and stringtext:match(ILVL_PREFIX) then
				_G['GameTooltipTextRight'..i]:SetText("|cffFFFFFF".. dots[self.count] .. "|r")

				if self.count == 4 then
					self.count = 1
				else
					self.count = self.count + 1
				end

				TryInspect()
				found = true
				return;
			end
		end
		if not found then
			self:Hide()
		end
	end)
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local unit = GetGameTooltipUnit(self)
	if not unit then
		return GameTooltip:Hide()
	end

	if strmatch(GameTooltipTextLeft1:GetText(), string.gsub(CORPSE_TOOLTIP, '%%s', '([^ ]+)')) then
		local color = unitrgb.dead
		return GameTooltipTextLeft1:SetTextColor(color[1], color[2], color[3])
	end

	for i = 3, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if (linetext) then
			if (linetext:find(_G.PVP)) or (linetext:find(_G.FACTION_ALLIANCE)) or (linetext:find(_G.FACTION_HORDE)) then
				tiptext:SetText(nil)
				tiptext:Hide()
			end
		end
	end

	local canInspect = CanInspect(unit)
	local level = UnitLevel(unit)
	local isShiftKeyDown = IsShiftKeyDown()
	local color, r, g, b = GetUnitColor(unit)
	local name, realm = UnitName(unit)
	local LevelLine_OffSet = 2

	if UnitIsPlayer(unit) and name ~= _G.UNKNOWN then
		-- [[ Player Name Stuff ]]
		local titledName = UnitPVPName(unit)
		if cfg.Tooltip.ShowTitle and titledName then
			name = titledName
		end

		local role = UnitGroupRolesAssigned(unit)
		if (cfg.Tooltip.RoleIcon and role) then
			name = roleicons[role]..' '..name
		end

		local relationship = UnitRealmRelationship(unit)
		if (realm and realm ~= '') then
			if (isShiftKeyDown) then
				name = name..'-'..realm
			elseif( relationship == LE_REALM_RELATION_COALESCED) then
				name = name..'|cffcccccc'..FOREIGN_SERVER_LABEL..'|r'
			elseif( relationship == LE_REALM_RELATION_VIRTUAL) then
				name = name..'|cffcccccc'..INTERACTIVE_SERVER_LABEL..'|r'
			end
		end

		local status
		if UnitIsAFK(unit) then
			status = CHAT_FLAG_AFK
		elseif UnitIsDND(unit) then
			status = CHAT_FLAG_DND
		elseif not UnitIsConnected(unit) then
			status = '[DC]'
		end
		if (status) then name = name..' |cff00cc00'..status..'|r' end
		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", color.colorStr, name)

		-- [[ Guild ]] --
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		if (guildName) then
			LevelLine_OffSet = 3
			if (guildRealm and isShiftKeyDown) then
				guildName = guildName.."-"..guildRealm
			end

			if (cfg.Tooltip.ShowGuildRanks) then
				GameTooltipTextLeft2:SetText(("<|cffff20cc%s|r> |cff00E6A8%s|r"):format(guildName, guildRankName))
			else
				GameTooltipTextLeft2:SetText(("<|cffff20cc%s|r>"):format(guildName))
			end
		end
	end

	local LevelLine = FindLine(self, LEVEL, LevelLine_OffSet)
	if LevelLine then
		local specIcon, iLvl = GetInspectInfo(self, unit, level, isShiftKeyDown)

		local diffColor 
		if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
			level = UnitBattlePetLevel(unit)
			local teamLevel = C_PetJournal.GetPetTeamAverageLevel();
			if(teamLevel) then
				diffColor = GetRelativeDifficultyColor(teamLevel, level); 
			else
				diffColor = GetQuestDifficultyColor(level)
			end
		else
			diffColor = GetQuestDifficultyColor(level)
		end
		if level <= 0 then
			diffColor.r = 0.68
			diffColor.g = 0.31
			diffColor.b = 0.31
			level = "??"
		end

		local pvpFlag = ""
		local race, class, colorString
		if canInspect and UnitIsPlayer(unit) then
			local englishRace
			race, englishRace = UnitRace(unit)
			local _, factionGroup = UnitFactionGroup(unit)
			if(factionGroup and englishRace == "Pandaren") then
				race = factionGroup..(race and " "..race or "")
			end
			class = UnitClass(unit)
			class = format("|c%s%s|r", color.colorStr, class)
			if specIcon then
				class = ' |T'..specIcon..':0|t '..class
			end
		else
			race = Classification[UnitClassification(unit)] or ""
			class = UnitCreatureType(unit) or ""

			if(UnitIsPVP(unit)) then
				pvpFlag = format(" (%s)", PVP)
			end
		end

		LevelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s %s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level or "", race or "", class or "", pvpFlag)

		if (canInspect) and (isShiftKeyDown) then
			if (iLvl) then
				dotmaker:Hide()
				self:AddDoubleLine(ILVL_PREFIX, "|cFFFFFFFF"..iLvl)
			else
				self:AddDoubleLine(ILVL_PREFIX, " ")
				dotmaker:Show()
			end
		end
	end

	-- [[ Target Of Target ]] --
	local unittarget = unit.."target"
	if (UnitExists(unittarget)) then		
		local target
		if(UnitIsUnit(unittarget, "player")) then
			target = format("|cffff0000%s|r", '<You>')
		else
			local _, r, g, b = GetUnitColor(unittarget)
			target = format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, UnitName(unittarget))
			local Icon = GetRaidTargetIndex(unittarget)
			if ICON_LIST[Icon] then
				target = format("%s%s", ICON_LIST[Icon].."10|t", target)
			end
		end
		GameTooltip:AddDoubleLine(TARGET..":", target)
	end

	-- [[ Fix statusbar pos ]] --
	self:AddLine(' ')
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint('LEFT', self:GetName()..'TextLeft'..self:NumLines(), 1, -3)
	GameTooltipStatusBar:SetPoint('RIGHT', self, -10, 0)

	if(color) then
		GameTooltipStatusBar:SetStatusBarColor(r, g, b)
	else
		GameTooltipStatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end
end)

-------------------------------------------------------------
-- Color Item border
GameTooltip:HookScript('OnTooltipCleared', function(self)
	if not self.borderTextures then return; end
	self:SetBorderTextureFile('default')
	FixFuckingBlueColor(self)
end)

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	local item, iLink = self:GetItem()
	if item and self.borderTextures then
		local _, _, quality = GetItemInfo(item)
		if quality then
			self:SetBorderTextureFile('white')
			self:SetBorderColor(GetItemQualityColor(quality))
		end
	end
end)

local function GameTooltipStatusBar_OnValueChanged(self, value)
	if not value and not self.Text then return; end
	local unit = GetGameTooltipUnit(self:GetParent())
	
	local min, max = self:GetMinMaxValues()

	if (value > 0) and (max == 1) then
		self.Text:SetFormattedText('%d%%', floor(value * 100))
	elseif (value == 0 or (unit and UnitIsDeadOrGhost(unit))) then
		self.Text:SetText(DEAD)
	else
		self.Text:SetText(GetFormattedValue(value).." / "..GetFormattedValue(max))
	end
end
-- Showing ID's
local function SetUnitAura(self, unit, index, filter)
	local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)
	if(ShowIDs and id) then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
		else
			self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		end
		GameTooltip:Show()
	end
end

local function GameTooltip_OnTooltipSetSpell(self)
	local _, _, id = self:GetSpell()
	if not id or not ShowIDs then return end

	local displayString = ("|cFFCA3C3C%s|r %d"):format(ID, id)
	local lines = self:NumLines()
	local isFound
	for i= 1, lines do
		local line = _G[("GameTooltipTextLeft%d"):format(i)]
		if line and line:GetText() and line:GetText():find(displayString) then
			isFound = true;
			break
		end
	end
	
	if not isFound then
		self:AddLine(displayString)
		self:Show()
	end
end

local function SetItemRef(link, text, button, chatFrame)
	local _, stop = link:find("^spell:(%d+)") 
	if ShowIDs and stop then
		local id = string.sub(link,7,stop)
		ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		ItemRefTooltip:Show()
	end
end
-- Make the spacing between comparing tooltips bigger
local function FixShoppingPosition(self, p, par, rp, x, y)
	if x ~= 0 then return; end
	x = (p == "TOPRIGHT") and -3 or 3
	self:SetPoint(p, par, rp, x, y)
end

local function onTooltipSetItem(self)
	if not ShowIDs then return end
	local _, link = self:GetItem()
	if link then
		local id = link:match('item:(%d*)')
		if id then
			self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
			self:Show()
		end
	end
end

local function LoadTooltips(event, name)
	-- Setup variables
	playerGUID = UnitGUID("player")
	GameTooltip.inspectCache = {}

	-- Basic Styling
	GameTooltipHeaderText:SetFont(cfgGlobal.Fonts.Normal, cfg.Tooltip.FontSize + 2)
	GameTooltipText:SetFont(cfgGlobal.Fonts.Normal, cfg.Tooltip.FontSize)
	GameTooltipTextSmall:SetFont(cfgGlobal.Fonts.Normal, cfg.Tooltip.FontSize)

	for _, tip in pairs(Tooltips) do
		SetTooltipStyle(tip)
		tip:HookScript("OnShow", FixFuckingBlueColor)
		tip:HookScript("OnHide", FixFuckingBlueColor)
	end

	-- Skin Statusbar
	local bar = GameTooltipStatusBar
	bar.Text = bar:CreateFontString(nil, "OVERLAY")
	bar.Text:SetPoint("CENTER", bar, 0, 1)
	bar.Text:SetFont(cfgGlobal.Fonts.Normal, cfg.Tooltip.FontSize, "THINOUTLINE")

	bar:SetHeight(6)
	bar:SetBackdrop({bgFile = 'Interface\\Buttons\\WHITE8x8'})
	bar:SetBackdropColor(0, 0, 0, 0.3)
	bar:SetScript('OnValueChanged', GameTooltipStatusBar_OnValueChanged)
	bar:SetStatusBarTexture(cfgGlobal.Statusbar.Normal)


	-- Fix the anchors
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		self:SetOwner(parent, "ANCHOR_NONE")
		self:SetPoint(unpack(cfg.Tooltip.Position))
	end)
	hooksecurefunc(ShoppingTooltip1, "SetPoint", FixShoppingPosition)
	hooksecurefunc(ShoppingTooltip2, "SetPoint", FixShoppingPosition)

	-- Spell / ItemID
	SlashCmdList.SPELLID = function(msg)
		ShowIDs = not ShowIDs
		if (ShowIDs) then
			ns:Print("ID's in tooltips: ON")
		else
			ns:Print("ID's in tooltips: OFF")
		end
	end
	_G.SLASH_SPELLID1 = "/spellid"

	hooksecurefunc(GameTooltip, "SetUnitAura", SetUnitAura)
	hooksecurefunc(GameTooltip, "SetUnitBuff", SetUnitAura)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", SetUnitAura)
	GameTooltip:HookScript("OnTooltipSetSpell", GameTooltip_OnTooltipSetSpell)
	GameTooltip:HookScript("OnTooltipSetItem", onTooltipSetItem)
	hooksecurefunc("SetItemRef", SetItemRef)

	-- Setup events
	GameTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:RegisterEvent("INSPECT_READY")
end

ns:RegisterEvent("PLAYER_LOGIN", LoadTooltips)