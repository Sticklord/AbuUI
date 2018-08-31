--[[

AbuCT by Abu

Modified version of xCT by affli @ RU-Howling Fjord
Thanks ALZA and Shestak for making this mod possible.

Improved the spammerger, interrupt message, reflect message
and various other small changes

]]--

--some init
local addon, ns = ...
local config = ns.config
local OHList = ns.MergeOffhandList
local MergeList = ns.MergeList
local BlackList = ns.BlackList
local lowHealth, lowMana
local BlankIcon = "Interface\\Addons\\AbuCombattext\\blank"
local dmg, heal

-- Number of frames
local numf
if config.damage or config.healing then
	numf=4
else
	numf=3
end

-- detect vehicle
local function SetUnit()
	if UnitHasVehicleUI("player") then
		ns.unit = "vehicle"
	else
		ns.unit = "player"
	end
	CombatTextSetActiveUnit(ns.unit)
end

--limit lines
local function LimitLines()
	for i = 1, #ns.frames do
		local f = ns.frames[i]
		f:SetMaxLines(f:GetHeight() / config.fontsize)
	end
end

-- regex string for loot items
local PAR_L_I = "([^|]*)|cff(%x*)|H[^:]*:(%d+):[-?%d+:]+|h%[?([^%]]*)%]|h|r?%s?x?(%d*)%.?"

-- loot events
local function ChatMsgMoney_Handler(msg)
	local g, s, c = tonumber(msg:match("(%d+) Gold")), tonumber(msg:match("(%d+) Silver")), tonumber(msg:match("(%d+) Copper"))
	local money, o = (g and g * 10000 or 0) + (s and s * 100 or 0) + (c or 0), "Money: "
	if money >= config.minmoney then
		if config.moneycolorblind then
			o = o..(g and g.." G " or "")..(s and s.." S " or "")..(c and c.." C " or "")
		else
			o = o..GetCoinTextureString(money).." "
		end
		if msg:find("share") then o = o.."(split)" end
		AbuCT3:AddMessage(o, 1, 1, 0) -- yellow
	end
end

local function ChatMsgLoot_Handler(msg)
	local pM, iQ, iI, iN, iA = select(3, string.find(msg, PAR_L_I))
	local quality, _, _, itemType, _, _, _, icon = select(3, GetItemInfo(iI))
	local quest, crafted, bought = (itemType == "Quest"), (pM == "You create: "), (pM == "You receive item: ")
	local self_looted = (pM == "You receive loot: ") or bought
	
	if (config.lootitems and self_looted and quality >= config.itemsquality) or (quest and config.questitems) or (crafted and config.crafteditems) then
		local r, g, b = GetItemQualityColor(quality)
		
		-- Type and Item Name
		local s = "Received: ["..iN.."] "
		if bought then
			s = "Purchased: ["..iN.."] "
		elseif crafted then
			if config.crafteditems == false then return end -- hide crafted items if show is set to false
			s = "Crafted: ["..iN.."] "
		elseif quest then
			if config.questitems == false then return end -- hide quest items if show is set to false
			s = "Quest Item: ["..iN.."] "
		end
	
		-- Add the Texture
		if config.loothideicons then
			s = s.." "
		else
			s = s.."\124T"..icon..":"..config.looticonsize..":"..config.looticonsize..":0:0:64:64:5:59:5:59\124t"
		end
	
		-- Amount Looted
		local amount = tonumber(iA)
		if amount and amount > 1 then
			s = s.." x "..amount
		else
			amount = 1
			s = s.." x 1"
		end
	
		-- Add the message
		if config.itemstotal then
			-- Delay it so we can read total count:
			C_Timer.After(.5, function()
				AbuCT3:AddMessage(s.." ("..GetItemCount(iI).. ")", r, g, b)
			end)
		else
			AbuCT3:AddMessage(s, r, g, b)
		end
	end
end

-- partial resists styler
local part = "-%s (%s %s)"
local r, g, b
-- the function, handles everything
local function OnEvent(self, event, subevent, ...)
	-- Regular combat text
	if event == "COMBAT_TEXT_UPDATE" then
		local arg2, arg3 = ...
		if SHOW_COMBAT_TEXT == "0" then
			return
		else
			if subevent == "DAMAGE" then
				AbuCT1:AddMessage("-"..arg2, .75, .1, .1)
				
			elseif subevent == "DAMAGE_CRIT" then
				AbuCT1:AddMessage(config.critprefix.."-"..arg2..config.critpostfix, 1, .1, .1)
				
			elseif subevent == "SPELL_DAMAGE" then
				AbuCT1:AddMessage("-"..arg2, .75, .3, .85)
				
			elseif subevent == "SPELL_DAMAGE_CRIT" then
				AbuCT1:AddMessage(config.critprefix.."-"..arg2..config.critpostfix, 1, .3, .5)
				
			elseif subevent == "HEAL" then
				if arg3 >= config.healtreshold then
					if arg2 then
						if COMBAT_TEXT_SHOW_FRIENDLY_NAMES == "1" then
							AbuCT2:AddMessage(arg2.." +"..arg3, .1, .75, .1)
						else
							AbuCT2:AddMessage("+"..arg3, .1, .75, .1)
						end
					end
				end
				
			elseif subevent == "HEAL_CRIT" then
				if arg3 >= config.healtreshold then
					if arg2 then
						if COMBAT_TEXT_SHOW_FRIENDLY_NAMES == "1" then
							AbuCT2:AddMessage(arg2.." +"..arg3, .1, 1, .1)
						else
							AbuCT2:AddMessage("+"..arg3, .1, 1, .1)
						end
					end
				end
				
			elseif subevent == "PERIODIC_HEAL" then
				if arg3 >= config.healtreshold then
					AbuCT2:AddMessage("+"..arg3, .1, .5, .1)
				end

			elseif subevent == "SPELL_CAST" then
				AbuCT3:AddMessage(arg2, 1, .82, 0)
			
			elseif subevent == "MISS" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(MISS, .5, .5, .5)
				
			elseif subevent=="DODGE" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(DODGE, .5, .5, .5)
				
			elseif subevent=="PARRY" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(PARRY, .5, .5, .5)
				
			elseif subevent == "EVADE" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(EVADE, .5, .5, .5)
				
			elseif subevent == "IMMUNE" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(IMMUNE, .5, .5, .5)
				
			elseif subevent == "DEFLECT" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(DEFLECT, .5, .5, .5)
				
			elseif subevent == "REFLECT" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(REFLECT, .5, .5, .5)
				
			elseif subevent == "SPELL_MISS" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(MISS, .5, .5, .5)
				
			elseif subevent == "SPELL_DODGE" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(DODGE, .5, .5, .5)
				
			elseif subevent == "SPELL_PARRY" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(PARRY, .5, .5, .5)
				
			elseif subevent == "SPELL_EVADE" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(EVADE, .5, .5, .5)
				
			elseif subevent == "SPELL_IMMUNE" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(IMMUNE, .5, .5, .5)
				
			elseif subevent == "SPELL_DEFLECT" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(DEFLECT, .5, .5, .5)
				
			elseif subevent == "SPELL_REFLECT" and COMBAT_TEXT_SHOW_DODGE_PARRY_MISS == "1" then
				AbuCT1:AddMessage(REFLECT, .5, .5, .5)

			elseif subevent == "RESIST" then
				if arg3 then
					if COMBAT_TEXT_SHOW_RESISTANCES == "1" then
						AbuCT1:AddMessage(part:format(arg2, RESIST, arg3), .75, .5, .5)
					else
						AbuCT1:AddMessage(arg2, .75, .1, .1)
					end
				elseif COMBAT_TEXT_SHOW_RESISTANCES == "1" then
					AbuCT1:AddMessage(RESIST, .5, .5, .5)
				end
				
			elseif subevent == "BLOCK" then
				if arg3 then
					if COMBAT_TEXT_SHOW_RESISTANCES == "1" then
						AbuCT1:AddMessage(part:format(arg2, BLOCK, arg3), .75, .5, .5)
					else
						AbuCT1:AddMessage(arg2, .75, .1, .1)
					end
				elseif COMBAT_TEXT_SHOW_RESISTANCES == "1" then
					AbuCT1:AddMessage(BLOCK, .5, .5, .5)
				end
				
			elseif subevent == "ABSORB" then
				if arg3 then
					if COMBAT_TEXT_SHOW_RESISTANCES == "1" then
						AbuCT1:AddMessage(part:format(arg2, ABSORB, arg3), .75, .5, .5)
					else
						AbuCT1:AddMessage(arg2, .75, .1, .1)
					end
				elseif COMBAT_TEXT_SHOW_RESISTANCES == "1" then
					AbuCT1:AddMessage(ABSORB, .5, .5, .5)
				end
				
			elseif subevent == "SPELL_RESIST" then
				if arg3 then
					if COMBAT_TEXT_SHOW_RESISTANCES == "1" then
						AbuCT1:AddMessage(part:format(arg2, RESIST, arg3), .5, .3, .5)
					else
						AbuCT1:AddMessage(arg2, .75, .3, .85)
					end
				elseif COMBAT_TEXT_SHOW_RESISTANCES == "1"then
					AbuCT1:AddMessage(RESIST, .5, .5, .5)
				end
				
			elseif subevent == "SPELL_BLOCK" then
				if arg3 then
					if COMBAT_TEXT_SHOW_RESISTANCES == "1" then
						AbuCT1:AddMessage(part:format(arg2, BLOCK, arg3), .5, .3, .5)
					else
						AbuCT1:AddMessage("-"..arg2, .75, .3, .85)
					end
				elseif COMBAT_TEXT_SHOW_RESISTANCES == "1" then
					AbuCT1:AddMessage(BLOCK, .5, .5, .5)
				end
				
			elseif subevent == "SPELL_ABSORB" then
				if arg3 then
					if COMBAT_TEXT_SHOW_RESISTANCES == "1" then
						AbuCT1:AddMessage(part:format(arg2, ABSORB, arg3), .5, .3, .5)
					else
						AbuCT1:AddMessage(arg2, .75, .3, .85)
					end
				elseif COMBAT_TEXT_SHOW_RESISTANCES == "1" then
					AbuCT1:AddMessage(ABSORB, .5, .5, .5)
				end

			elseif subevent == "ENERGIZE" and COMBAT_TEXT_SHOW_ENERGIZE == "1" then
				if  tonumber(arg2) > 0 then
					if arg3 and arg3 == "MANA" or arg3 == "RAGE" or arg3 == "FOCUS" or arg3 == "ENERGY" or arg3 == "RUINIC_POWER" or arg3 == "SOUL_SHARDS" then
						AbuCT3:AddMessage("+"..arg2.." ".._G[arg3], PowerBarColor[arg3].r, PowerBarColor[arg3].g, PowerBarColor[arg3].b)
					end
				end

			elseif subevent == "PERIODIC_ENERGIZE" and COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE == "1" then
				if  tonumber(arg2) > 0 then
					if arg3 and arg3 == "MANA" or arg3 == "RAGE" or arg3 == "FOCUS" or arg3 == "ENERGY" or arg3 == "RUINIC_POWER" or arg3 == "SOUL_SHARDS" then
						AbuCT3:AddMessage("+"..arg2.." ".._G[arg3], PowerBarColor[arg3].r, PowerBarColor[arg3].g, PowerBarColor[arg3].b)
					end
				end
				
			elseif subevent == "SPELL_AURA_START" and COMBAT_TEXT_SHOW_AURAS == "1" then
				AbuCT3:AddMessage("+"..arg2, 1, .5, .5)
				
			elseif subevent == "SPELL_AURA_END" and COMBAT_TEXT_SHOW_AURAS == "1" then
				AbuCT3:AddMessage("-"..arg2, .5, .5, .5)
				
			elseif subevent == "SPELL_AURA_START_HARMFUL" and COMBAT_TEXT_SHOW_AURAS == "1" then
				AbuCT3:AddMessage("+"..arg2, 1, .1, .1)
				
			elseif subevent == "SPELL_AURA_END_HARMFUL" and COMBAT_TEXT_SHOW_AURAS == "1" then
				AbuCT3:AddMessage("-"..arg2, .1, 1, .1)

			elseif subevent == "HONOR_GAINED" and COMBAT_TEXT_SHOW_HONOR_GAINED == "1" then
				arg2 = tonumber(arg2)
				if arg2 and abs(arg2) > 1 then
					arg2 = floor(arg2)
					if arg2 > 0 then
						AbuCT3:AddMessage(HONOR.." +"..arg2, .1, .1, 1)
					end
				end

			elseif subevent == "FACTION" and COMBAT_TEXT_SHOW_REPUTATION == "1" then
				AbuCT3:AddMessage(arg2.." +"..arg3, .1, .1, 1)

			elseif subevent == "SPELL_ACTIVE" and COMBAT_TEXT_SHOW_REACTIVES == "1" then
				AbuCT3:AddMessage(arg2, 1, .82, 0)
			end
		end

	elseif event == "UNIT_HEALTH" and COMBAT_TEXT_SHOW_LOW_HEALTH_MANA == "1" then
		if subevent == ns.unit then
			if UnitHealth(ns.unit) / UnitHealthMax(ns.unit) <= COMBAT_TEXT_LOW_HEALTH_THRESHOLD then
				if not lowHealth then
					AbuCT3:AddMessage(HEALTH_LOW, 1, .1, .1)
					lowHealth = true
				end
			else
				lowHealth = nil
			end
		end

	elseif event == "UNIT_MANA" and COMBAT_TEXT_SHOW_LOW_HEALTH_MANA == "1" then
		if subevent == ns.unit then
			local _, powerToken = UnitPowerType(ns.unit)
			if powerToken == "MANA" and UnitPower(ns.unit) / UnitPowerMax(ns.unit) <= COMBAT_TEXT_LOW_MANA_THRESHOLD then
				if not lowMana then
					AbuCT3:AddMessage(MANA_LOW, 1, .1, .1)
					lowMana = true
				end
			else
				lowMana = nil
			end
		end

	elseif event == "PLAYER_REGEN_ENABLED" and COMBAT_TEXT_SHOW_COMBAT_STATE == "1" then
			AbuCT3:AddMessage("-"..LEAVING_COMBAT, .1, 1, .1)

	elseif event == "PLAYER_REGEN_DISABLED" and COMBAT_TEXT_SHOW_COMBAT_STATE == "1" then
			AbuCT3:AddMessage("+"..ENTERING_COMBAT, 1, .1, .1)

	elseif event == "UNIT_COMBO_POINTS" and COMBAT_TEXT_SHOW_COMBO_POINTS == "1" then
		if subevent == ns.unit then
			local cp = GetComboPoints(ns.unit, "target")
				if cp > 0 then
					r, g, b = 1, .82, .0
					if cp == MAX_COMBO_POINTS then
						r, g, b = 0, .82, 1
					end
					AbuCT3:AddMessage(format(COMBAT_TEXT_COMBO_POINTS, cp), r, g, b)
				end
		end

	elseif event == "RUNE_POWER_UPDATE" then
		local arg1, arg2 = subevent, ...
		if arg2 then
			local rune = GetRuneType(arg1);
			local msg = COMBAT_TEXT_RUNE[rune];
			if rune == 1 then 
				r, g, b = .75, 0, 0
			elseif rune==2 then
				r, g, b = .75, 1, 0
			elseif rune == 3 then
				r, g, b = 0, 1, 1  
			end
			if rune and rune < 4 then
				AbuCT3:AddMessage("+"..msg, r, g, b)
			end
		end

	elseif event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITING_VEHICLE" then
		if arg1 == "player" then
			SetUnit()
		end

	elseif event == "PLAYER_ENTERING_WORLD" then
		SetUnit()
		LimitLines()

		if config.damage or config.healing then
			ns.pguid = UnitGUID("player")
		end
	
	elseif event == "CHAT_MSG_LOOT" then
		ChatMsgLoot_Handler(subevent)
		
	elseif event == "CHAT_MSG_MONEY" then
		ChatMsgMoney_Handler(sub)
	end
end

-- the frames
ns.locked = true
ns.frames = { }
for i = 1, numf do
	local f = CreateFrame("ScrollingMessageFrame", "AbuCT"..i, UIParent)
	f:SetFont(config.font, config.fontsize, config.fontstyle)
	f:SetShadowColor(0, 0, 0, 0)
	f:SetFading(true)
	f:SetFadeDuration(0.5)
	f:SetTimeVisible(config.timevisible)
	f:SetMaxLines(config.maxlines)
	f:SetSpacing(2)
	f:SetPoint("CENTER", 0, 0)
	f:SetMovable(true)
	f:SetResizable(true)
	f:SetMinResize(64, 64)
	f:SetMaxResize(768, 768)
	f:SetClampedToScreen(true)
	f:SetClampRectInsets(0, 0, config.fontsize, 0)
	if i == 1 then
		f:SetWidth(220)
		f:SetHeight(300)
		f:SetPoint("CENTER", -300, 0)
		f:SetJustifyH(config.justify_1)
	elseif i == 2 then
		f:SetWidth(220)
		f:SetHeight(300)
		f:SetPoint("CENTER", -530, 0)
		f:SetJustifyH(config.justify_2)
	elseif i == 3 then
		f:SetWidth(400)
		f:SetHeight(128)
		f:SetPoint("CENTER", 0, 230)
		f:SetJustifyH(config.justify_3)
	else
		f:SetWidth(300)
		f:SetHeight(300)
		f:SetPoint("CENTER", 400, 0)
		f:SetJustifyH(config.justify_4)
		local a, _, c = f:GetFont()
		if config.damagefontsize == "auto" then
			if config.icons then
				f:SetFont(a, config.iconsize / 2, c)
			end
		elseif type(config.damagefontsize) == "number" then
			f:SetFont(a, config.damagefontsize, c)
		end   
	end
	ns.frames[i] = f
end

-- register events
local AbuCT = CreateFrame("Frame")
AbuCT:RegisterEvent("COMBAT_TEXT_UPDATE")
AbuCT:RegisterEvent("UNIT_HEALTH")
AbuCT:RegisterEvent("UNIT_MANA")
AbuCT:RegisterEvent("PLAYER_REGEN_DISABLED")
AbuCT:RegisterEvent("PLAYER_REGEN_ENABLED")
AbuCT:RegisterEvent("UNIT_COMBO_POINTS")
if config.dkrunes and select(2, UnitClass("player")) == "DEATHKNIGHT" then
	AbuCT:RegisterEvent("RUNE_POWER_UPDATE")
end
AbuCT:RegisterEvent("UNIT_ENTERED_VEHICLE")
AbuCT:RegisterEvent("UNIT_EXITING_VEHICLE")
AbuCT:RegisterEvent("PLAYER_ENTERING_WORLD")
-- register loot events
if config.lootitems or config.questitems or config.crafteditems then
	AbuCT:RegisterEvent("CHAT_MSG_LOOT") 
end
if config.lootmoney then 
	AbuCT:RegisterEvent("CHAT_MSG_MONEY")
end

AbuCT:SetScript("OnEvent",OnEvent)

-- turn off blizz ct
CombatText:UnregisterAllEvents()
CombatText:SetScript("OnLoad", nil)
CombatText:SetScript("OnEvent", nil)
CombatText:SetScript("OnUpdate", nil)

-- steal external messages sent by other addons using CombatText_AddMessage
--Blizzard_CombatText_AddMessage = CombatText_AddMessage
local function CombatText_AddMessage(message,scrollFunction, r, g, b, displayType, isStaggered)
	AbuCT3:AddMessage(message, r, g, b)
end

-- hook blizz float mode selector. blizz sucks, because changing  cVar combatTextFloatMode doesn't fire CVAR_UPDATE
--hooksecurefunc("InterfaceOptionsCombatTextPanelFCTDropDown_OnClick",ScrollDirection)
--COMBAT_TEXT_SCROLL_ARC="" --may cause unexpected bugs, use with caution!
--InterfaceOptionsCombatTextPanelFCTDropDown:Hide() -- sorry, blizz fucking bug with SCM:SetInsertMode()

-- awesome configmode and testmode
local StartConfigmode = function()
	for i = 1, #ns.frames do
		local f = ns.frames[i]
		f:SetBackdrop( { bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
						 edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
						 tile     = false,
						 tileSize = 0,
						 edgeSize = 2,
						 insets = { left = 0, right = 0, top = 0, bottom = 0 }
					   } )
		f:SetBackdropColor(.1, .1, .1, .8)
		f:SetBackdropBorderColor(.1, .1, .1, .5)

		f.fs = f.fs or f:CreateFontString(nil, "OVERLAY")
		f.fs:SetFont(config.font, config.fontsize, config.fontstyle)
		f.fs:SetPoint("BOTTOM", f, "TOP", 0, 0)
		if i == 1 then
			f.fs:SetText(DAMAGE)
			f.fs:SetTextColor(1, .1, .1, .9)
		elseif i == 2 then
			f.fs:SetText(SHOW_COMBAT_HEALING)
			f.fs:SetTextColor(.1,1,.1,.9)
		elseif i == 3 then
			f.fs:SetText(COMBAT_TEXT_LABEL)
			f.fs:SetTextColor(.1,.1,1,.9)
		else
			f.fs:SetText(SCORE_DAMAGE_DONE.." / "..SCORE_HEALING_DONE)
			f.fs:SetTextColor(1,1,0,.9)
		end
		f.fs:Show()

		f.t = f.t or f:CreateTexture"ARTWORK"
		f.t:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
		f.t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -19)
		f.t:SetHeight(20)
		f.t:SetTexture(.5, .5, .5)
		f.t:SetAlpha(.3)
		f.t:Show()

		f.d = f.d or f:CreateTexture("ARTWORK")
		f.d:SetHeight(16)
		f.d:SetWidth(16)
		f.d:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
		f.d:SetTexture(.5, .5, .5)
		f.d:SetAlpha(.3)
		f.d:Show()

		f.tr = f.tr or f:CreateTitleRegion()
		f.tr:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
		f.tr:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
		f.tr:SetHeight(20)

		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", f.StartSizing)
		f:SetScript("OnDragStop", f.StopMovingOrSizing)
		f:SetScript("OnSizeChanged", function(self)
			self:SetMaxLines(self:GetHeight() / config.fontsize)
			self:Clear()
		end)
	end
end

local function EndConfigmode()
	for i = 1, #ns.frames do
		local f = ns.frames[i]
		f:SetBackdrop(nil)
		f.fs:Hide()
		f.t:Hide()
		f.d:Hide()

		f:EnableMouse(false)
		f:SetScript("OnDragStart", nil)
		f:SetScript("OnDragStop", nil)
	end
	ns:Print("Window positions unsaved, don't forget to reload UI.")
end

local function StartTestMode()
-- init really random number generator.
	local random = math.random
	local UpdateInterval
	random(time()); random(); random(time())
	
	local TimeSinceLastUpdate = 0
	ns.dmindex = { }
	ns.dmindex[1] = 1
	ns.dmindex[2] = 2
	ns.dmindex[3] = 4
	ns.dmindex[4] = 8
	ns.dmindex[5] = 16
	ns.dmindex[6] = 32
	ns.dmindex[7] = 64
	
	for i = 1, #ns.frames do
		ns.frames[i]:SetScript("OnUpdate", function(self, elapsed)
			UpdateInterval = random(65, 1000) / 250
			TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
			if TimeSinceLastUpdate > UpdateInterval then
				if i == 1 then
					ns.frames[i]:AddMessage("-"..random(100000), 1, random(255) / 255, random(255) / 255)
				elseif i == 2 then
					ns.frames[i]:AddMessage("+"..random(50000), .1, random(128, 255) / 255, .1)
				elseif i == 3 then
					ns.frames[i]:AddMessage(COMBAT_TEXT_LABEL, random(255) / 255, random(255) / 255, random(255) / 255)
				elseif i == 4 then
					local spell, id
					while( not spell) do
						id = random(10000)
						spell = GetSpellInfo(id)
					end
					dmg(nil, nil, nil, "SPELL_DAMAGE", nil, UnitGUID("pet"), nil, nil, nil, nil, nil, 0, 0, id, nil, 1+random(5), random(50000))
				end
				TimeSinceLastUpdate = 0
			end
		end) 
	end
end

local function EndTestMode()
	for i = 1, #ns.frames do
		ns.frames[i]:SetScript("OnUpdate", nil)
		ns.frames[i]:Clear()
	end
	ns.dmindex = nil
end

-- /AbuCT lock popup dialog
StaticPopupDialogs["ABUCT_LOCK"] = {
	text         = "To save AbuCT window positions you need to reload your UI.\n Click "..ACCEPT.." to reload UI.\nClick "..CANCEL.." to do it later.",
	button1      = ACCEPT,
	button2      = CANCEL,
	OnAccept     = function() if not InCombatLockdown() then ReloadUI() end end,
	timeout      = 0,
	whileDead    = 1,
	hideOnEscape = true,
	showAlert    = true,
}

-- slash commands
_G.SLASH_ABUCT1 = "/AbuCT"
_G.SLASH_ABUCT2 = "/ACT"

local LOCKED = true
SlashCmdList["ABUCT"] = function()

	if LOCKED then
		if (not InCombatLockdown()) then
			StartConfigmode()
			StartTestMode()
			LOCKED = false
		else
			ns:Print("can't be configured in combat.")
		end
	else
		EndTestMode()
		EndConfigmode()
		StaticPopup_Show("ABUCT_LOCK")
		LOCKED = true
	end
end

-- awesome shadow priest helper
if config.stopvespam and ns.myclass == "PRIEST" then
	local sp = CreateFrame("Frame")
	sp:SetScript("OnEvent", function(...)
			if GetShapeshiftForm() == 1 then
				if config.blizzheadnumbers then
					SetCVar('CombatHealing', 0)
				end
			else
				if config.blizzheadnumbers then
					SetCVar('CombatHealing', 1)
				end
			end
		end)
	sp:RegisterEvent("PLAYER_ENTERING_WORLD")    
	sp:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	sp:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
end

-- spam merger
local spamsub = "       "
local SQ
local pairs = pairs
local AbuCTspam

if config.damage or config.healing then

	AbuCTspam = CreateFrame("Frame")
	AbuCTspam:Hide()
	SQ = { }

	ns.MergeSpam = function(spellId, add)
		if not SQ[spellId] then -- New spell that is not seen yet or deleted
			SQ[spellId] = {queue = 0, msg = "", color = { }, count = 0, locked = false, countCrits = 0}
			local holdTime = MergeList[spellId]
			-- If the spell is in the list with a custom timer
			if holdTime then
				SQ[spellId].countTime = 0
				if holdTime > 0 then
					SQ[spellId].holdTime = holdTime / config.mergetime
				else-- minus value, scale it with haste
					local time = (-holdTime)*(100 - (GetCombatRatingBonus(CR_HASTE_MELEE) or 0)) / 100 
					SQ[spellId].holdTime = ceil(time / config.mergetime)
				end
			end
		end

		local amount
		local spam = SQ[spellId]["queue"]
		if spam and type(spam) == "number" then
			amount = spam + add
		else
			amount = add
		end
		SQ[spellId]["queue"] = amount

		-- Make the AbuCTspam eventframe start updating if it isn't
		if (not AbuCTspam:IsVisible()) then AbuCTspam:Show() end
	end

	local lastUpdate = 0
	AbuCTspam:SetScript("OnUpdate", function(self, elapsed)
		lastUpdate = lastUpdate + elapsed

		if lastUpdate > config.mergetime then
			local activeEvents = 0
			local count

			for k, v in pairs(SQ) do
				if not SQ[k]["locked"] and SQ[k]["queue"] > 0 then

					-- Keep track of the active events
					activeEvents = activeEvents + 1

					-- Check if we should hold the spell and wait for next update
					if SQ[k].holdTime and SQ[k].holdTime > SQ[k].countTime then
						SQ[k].countTime = SQ[k].countTime + 1
					else
					-- Or print it out
						if SQ[k]["count"] > 9 then
							count = " |cffFFFFFF x "..SQ[k]["count"].."|r"
						elseif SQ[k]["count"] > 1 then
							count = " |cffFFFFFF x "..SQ[k]["count"].." |r"
						else
							count = spamsub
						end

						--Only show crit pre/postfix if 100% of the attacks are crits
						if (SQ[k]["countCrits"] == SQ[k]["count"]) then
							SQ[k]["queue"] = config.critprefix..SQ[k]["queue"]..config.critpostfix
						end

						AbuCT4:AddMessage(SQ[k]["queue"]..SQ[k]["msg"]..count, SQ[k]["color"].r, SQ[k]["color"].g, SQ[k]["color"].b)
						SQ[k]["countCrits"] = 0
						SQ[k]["queue"] = 0
						SQ[k]["count"] = 0

						if SQ[k].holdTime then
							SQ[k] = nil
						end
					end
				end
			end
			-- Stop updating if its nothing to update, think green.
			if activeEvents == 0 then
				self:Hide()
			end
			lastUpdate = 0
		end
	end)
	
end

-- damage
if(config.damage)then
	local reflected = {}
	local unpack, select, time = unpack, select, time
	local gflags = bit.bor( COMBATLOG_OBJECT_AFFILIATION_MINE,
							COMBATLOG_OBJECT_REACTION_FRIENDLY,
							COMBATLOG_OBJECT_CONTROL_PLAYER,
							COMBATLOG_OBJECT_TYPE_GUARDIAN )
							
	local AbuCTd = CreateFrame("Frame")

	dmg = function(self, event, ...) 
		local msg, icon
		local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, srcFlags2, destGUID, destName, destFlags, destFlags2 = select(1,...)

		if (sourceGUID == ns.pguid and destGUID ~= ns.pguid) or (sourceGUID == UnitGUID("pet") and config.petdamage) or (sourceFlags == gflags) then
			if eventType=="SWING_DAMAGE" then
				-- 4.2
				local amount, _, _, _, _, _, critical = select(12, ...)
				if amount >= config.treshold then
					msg = amount
					if sourceGUID == UnitGUID("pet") or sourceFlags == gflags then
						msg = '|cffFFA050'..msg..'|r'
						if config.iconswings then
							icon = PET_ATTACK_TEXTURE
						end
					elseif config.iconswings then
						icon = GetSpellTexture(6603)
					end
					if critical then
						msg = config.critprefix .. msg .. config.critpostfix
					end
					if icon then
						msg = msg.." \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
					else
						msg = msg.." \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
					end
					AbuCT4:AddMessage(msg..spamsub)
				end
				
			elseif eventType == "RANGE_DAMAGE" then
				-- 4.2
				local spellId, _, _, amount, _, _, _, _, _, critical = select(12, ...)
				if amount >= config.treshold then
					msg = amount
					if critical then
						msg = config.critprefix..msg..config.critpostfix
					end
					if config.iconswings then
						icon = GetSpellTexture(spellId)
						msg = msg.." \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
					else
						msg = msg.." \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
					end
					AbuCT4:AddMessage(msg..spamsub)
				end
	
			elseif eventType == "SPELL_DAMAGE" or (eventType == "SPELL_PERIODIC_DAMAGE" and config.dotdamage) then
				-- 4.2
				local spellId, _, spellSchool, amount, _, _, _, _, _, critical = select(12, ...)
				if amount >= config.treshold then
					local color = { }
					local rawamount = amount
					if critical then
						amount = config.critprefix..amount..config.critpostfix
					end
					if config.icons then
						icon = GetSpellTexture(spellId)
					end
					if ns.schoolColor[spellSchool] then
						color = ns.schoolColor[spellSchool]
					else
						color = ns.schoolColor[1]
					end
					if icon then
						msg = " \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
					else
						msg = " \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
					end

					local secondarySpellID = OHList[spellId]
					if secondarySpellID then
						spellId = secondarySpellID
					end

					ns.MergeSpam(spellId, rawamount)
					SQ[spellId]["locked"] = true

					if (critical) then
						SQ[spellId]["countCrits"] = SQ[spellId]["countCrits"] + 1
					end

					SQ[spellId]["msg"]    = msg
					SQ[spellId]["color"]  = color
					SQ[spellId]["count"]  = SQ[spellId]["count"] + 1
					SQ[spellId]["locked"] = false
				end
	
			elseif eventType == "SWING_MISSED" then
				-- 4.2
				local missType, _ = select(12, ...)
				if config.iconswings then
					if sourceGUID == UnitGUID("pet") or sourceFlags == gflags then
						icon = PET_ATTACK_TEXTURE
					else
						icon = GetSpellTexture(6603)
					end
					missType = missType.." \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				else
					missType = missType.." \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				end
				AbuCT4:AddMessage(missType..spamsub)
	
			elseif eventType == "SPELL_MISSED" or eventType == "RANGE_MISSED" then
				-- 4.2
				local spellId, _, _, missType, _ = select(12, ...)
				if(BlackList[spellId]) then --Ignoring blacklisted spells
					return
				end
				if config.icons then
					icon = GetSpellTexture(spellId)
					missType = missType.." \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				else
					missType = missType.." \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				end 
				AbuCT4:AddMessage(missType..spamsub)
	
			elseif eventType == "SPELL_DISPEL" then
				-- 4.2
				local target, _, _, id, effect, _, etype = select(12, ...)
				local color
				if config.icons then
					icon = GetSpellTexture(id)
				end
				if icon then
					msg = " \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				else
					msg = " \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				end
				if etype == "BUFF"then
					color = { 0, 1, .5 }
				else
					color = { 1, 0, .5 }
				end
				AbuCT3:AddMessage(ACTION_SPELL_DISPEL..": "..effect..msg..spamsub, unpack(color))
				
			elseif eventType == "PARTY_KILL" then
				local tname = select(9, ...)
				AbuCT3:AddMessage(ACTION_PARTY_KILL..": "..tname, .2, 1, .2)
			end
		end

		if (eventType == 'SPELL_INTERRUPT') then
			if bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
				local extSpId, _, extSpSchool = select(15, ...)
				local school

				if (ns.schoolColor[extSpSchool]) then
					school = ns.schoolColor[extSpSchool]
				else
					school = { r = 1, g = 0.5, b = 0, n = 'Unknown'}
				end

				if config.icons then
					icon = GetSpellTexture(extSpId)
				end

				if icon then
					msg = " \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				else
					msg = " \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				end
				AbuCT4:AddMessage("Interrupted: "..school.n..msg..spamsub, school.r, school.g, school.b)
			end

		elseif (eventType == 'SPELL_STOLEN') then
			if bit.band(srcFlags2, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
				local extSpId,extraSpellName, extSpSchool = select(15,...)
				local school
				if (ns.schoolColor[extSpSchool]) then
					school = ns.schoolColor[extSpSchool]
				else
					school = { r = 1, g = 0.5, b = 0, n = 'Unknown'}
				end

				if config.icons then
					icon = GetSpellTexture(extSpId)
				end
				if icon then
					msg = " \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				else
					msg = " \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
				end
				AbuCT3:AddMessage("Stole "..extraSpellName..msg..spamsub, sc, school.r, school.g, school.b)
			end
		end
		-- Reflect madness
		if eventType=="SPELL_AURA_APPLIED" or eventType=="SPELL_AURA_REMOVED" then
			if bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
				local spellName = select(13,...)
				if spellName=="Mass Spell Reflection" then
					if eventType=="SPELL_AURA_APPLIED" then
						reflected[destGUID] = true
					else
						reflected[destGUID] = false
					end
				end
			end
		elseif (eventType=="SPELL_MISSED") then
			local spellId, spellName, _, missType = select(12,...)
			if config.icons then
				icon = GetSpellTexture(spellId)
			end
			if icon then
				msg = " \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
			else
				msg = " \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
			end

			if (bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0) then
				if (missType=="REFLECT") then
					AbuCT3:AddMessage("Reflected "..spellName..msg..spamsub, 1, 1, 1)
				elseif (destName=="Grounding Totem") and (bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0) then
					AbuCT3:AddMessage("Grounded "..spellName..msg..spamsub, 1, 1, 1)
				end
			elseif (bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) <= 0) then
				local spellName,_,missType = select(13,...)
				if (missType=="REFLECT") then
					if reflected[destGUID] ~= nil then
						if reflected[destGUID] then
							AbuCT3:AddMessage("Reflected "..spellName..msg..spamsub, 1, 1, 1)
						end
					end
				end
			end
		elseif (eventType=="SPELL_DAMAGE") then
			local spellId, spellName = select(12,...)
			if config.icons then
				icon = GetSpellTexture(spellId)
			end
			if icon then
				msg = " \124T"..icon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
			else
				msg = " \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
			end
			if bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
				local spellName = select(13,...)
				if (destName=="Grounding Totem") then
					AbuCT3:AddMessage("Grounded "..spellName..msg..spamsub, 1, 1, 1)
				end
			end
		end
	end
	
	AbuCTd:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	
	-- this is corrected for 4.2, call normal
	AbuCTd:SetScript("OnEvent", dmg)
end

-- healing
if(config.healing)then
	local select, time = select, time
	local AbuCTh = CreateFrame("Frame")
	heal = function(self, event, ...)
		local msg, icon
		local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2 = select(1, ...)
		if sourceGUID == ns.pguid or sourceFlags == gflags then
			if eventType == 'SPELL_HEAL' or eventType == 'SPELL_PERIODIC_HEAL' and config.showhots then
				if config.healing then
					local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, ...)
					if ns.healfilter[spellId] then
						return
					end
					if amount >= config.healtreshold then
						local color = { }
						local rawamount = amount

						if ns.schoolColor[spellSchool] then
							color = ns.schoolColor[spellSchool]
						else
							color = ns.schoolColor[2] -- Holy
						end

						if critical then 
							amount = config.critprefix..amount..config.critpostfix
						end

						if config.icons then
							icon = GetSpellTexture(spellId)
						end

						if icon then 
							msg = ' \124T'..icon..':'..config.iconsize..':'..config.iconsize..':0:0:64:64:5:59:5:59\124t'
						else
							msg = " \124T"..BlankIcon..":"..config.iconsize..":"..config.iconsize..":0:0:64:64:5:59:5:59\124t"
						end

						local secondarySpellID = OHList[spellId]
						if secondarySpellID then
							spellId = secondarySpellID
						end

						ns.MergeSpam(spellId, rawamount)
						SQ[spellId]["locked"] = true

						if (critical) then
							SQ[spellId]["countCrits"] = SQ[spellId]["countCrits"] + 1
						end

						SQ[spellId]["msg"] = msg
						SQ[spellId]["color"] = color
						SQ[spellId]["count"] = SQ[spellId]["count"] + 1

						SQ[spellId]["locked"] = false
					end
				end
			end
		end
	end
	AbuCTh:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	-- this is corrected for 4.2, call normal
	AbuCTh:SetScript("OnEvent", heal)
end
