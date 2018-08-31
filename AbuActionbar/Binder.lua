--[==================================================[

	Binder
		-Mouseover button binder
		-All bindings are saved per character

--]==================================================]

local _, ns = ...

local Binder = CreateFrame("Frame", "SpellBinder", UIParent)
ns.Binder = Binder
local SBButton, MButton = nil, nil
local cfg = ns.Config
-- Tables for text on buttons
local macroText, spellText, spellFlyoutText = {}, {}, {}

local find = string.find
local _G = getfenv(0)

-- [[  Get formatted key for text ]]  --
local GetKeyText
do
	local displaySubs = {
		['s%-'] 			= 's',
		['a%-'] 			= 'a',
		['c%-'] 			= 'c',
		['st%-']			= 'c',
		['Mouse Button ']	= 'M',
		KEY_MOUSEWHEELUP 	= 'wU',
		KEY_MOUSEWHEELDOWN	= 'wD',
		['Middle Mouse']	= 'M3',
		['KEY_NUMLOCK'] 	= 'nL',
		['Num Pad '] 		= 'n',
		['NUMPAD'] 			= 'n',
		KEY_PAGEUP 			= 'pU',
		KEY_PAGEDOWN 		= 'pD',
		KEY_SPACE 			= 'Sp',
		KEY_INSERT			= 'Ins',
		KEY_HOME 			= 'Hm',
		KEY_DELETE			= 'Del',
		["PLUS"]    		= "+",
		["MINUS"]   		= "-",
		["MULTIPLY"]		= "*",
		["DIVIDE"]  		= "/",
		["DECIMAL"] 		= ".",
	}
	local gsub = string.gsub
	function GetKeyText(key)
		if not key then
			return ""
		end
		for k, v in pairs(displaySubs) do
			key = gsub(key, k, v)
		end
		return key
	end
end
ns.GetKeyText = GetKeyText

local keyMap = {
	['LSHIFT'] = 'IGNORE',
	['RSHIFT'] = 'IGNORE',
	['LCTRL'] = 'IGNORE',
	['RCTRL'] = 'IGNORE',
	['LALT'] = 'IGNORE',
	['RALT'] = 'IGNORE',
	['UNKNOWN'] = 'IGNORE',
	['LeftButton'] = 'IGNORE',
	['MiddleButton'] = 'BUTTON3',
	['Button4'] = 'BUTTON4',
	['Button5'] = 'BUTTON5',
}

--  [[  Get the COMMAND from a button  ]] --
local function GetCommandFromButton(b, bType)
	local id, name, command = nil, nil, ''

	if bType == 'SPELL' then -- Spellbook or directly bound
		id = SpellBook_GetSpellBookSlot(b)
		name = GetSpellBookItemName(id, SpellBookFrame.bookType)
		command = 'SPELL '..(name or '')
	elseif bType == 'FLYOUT' then
		id = b.spellID
		name = GetSpellInfo(b.spellID)
		command = 'SPELL '..name
	elseif bType == 'MACRO' then -- Macro's
		name = _G[b:GetName()..'Name']:GetText()
		command = 'MACRO '..name

	elseif bType == "STANCE" or bType == "PET" then -- Special bar
		name = b:GetName()
		id = tonumber(b:GetID())
		if not name then return end
		if (not id) or (id < 1) or (id > (bType=="STANCE" and 10 or 12)) then
			command = "CLICK "..name..":LeftButton"
		else
			command = (bType == "STANCE" and "SHAPESHIFTBUTTON" or "BONUSACTIONBUTTON")..id
		end

	else -- Normal action bar
		id = tonumber(b.action)
		name = b:GetName()

		if not id or id < 1 or id > 132 then
			command = "CLICK "..name..":LeftButton"
		else
			local num = 1 + (id - 1) % 12
			if id < 25 or id > 72 then
				command = "ACTIONBUTTON"..num
			elseif id < 37 then
				command = "MULTIACTIONBAR3BUTTON"..num
			elseif id < 49 then
				command = "MULTIACTIONBAR4BUTTON"..num
			elseif id < 61 then
				command = "MULTIACTIONBAR2BUTTON"..num
			else
				command = "MULTIACTIONBAR1BUTTON"..num
			end
		end
	end
	b.name = name
	return command
end

local function SetBindings(b, key, command)
	SetBinding(key, command)
	if cfg.PrintBindings then
		ns.Print(key.." bound to "..b.name..".")
	end
end

local function ClearBindings(b, keys)
	if keys then -- Delete all the set keys for the button
		for i, key in ipairs(keys) do
			SetBinding(key)
		end
		if cfg.PrintBindings then
			ns.Print('Cleared all bindings for: '..b.name..".")
		end
	end
end

--  [[  Get the key bound to a button  ]]  --
local function GetButtonKey(b, Type)
	if Type == 'FLYOUT' then
		if b.spellID and GetSpellInfo(b.spellID)then
			return GetBindingKey('SPELL '..GetSpellInfo(b.spellID))
		end
	elseif Type == 'SPELLBOOK' then
		local slot, slotType, slotID = SpellBook_GetSpellBookSlot(b)
		if slot and slotType then
			local name = GetSpellBookItemName(slot, SpellBookFrame.bookType)
			-- 'SPELL Blink'
			return GetBindingKey(slotType.." "..name)
		end
	elseif Type == 'MACRO' then
		local name = _G[b:GetName()..'Name']
		if name and name:GetText() then
			return GetBindingKey('MACRO '..name:GetText())
		end
	end
	return ''
end

--  [[  Fired whenever the mouse interracts with buttons  ]]  --
function Binder:Update(b, bType)
	if not self.isBinding or InCombatLockdown() then return end
	self.button = b
	self.bType = bType
	
	self:ClearAllPoints()
	self:SetAllPoints(b)

	self.button.command = GetCommandFromButton(self.button, bType)
	if bType == 'SPELL' then 
		local slot, slotType = SpellBook_GetSpellBookSlot(self.button)
		-- Hide flyouts togglers and passive spells
		if IsPassiveSpell(slot, SpellBookFrame.bookType) or slotType == 'FLYOUT' then
			return self:Hide()
		end
	elseif not bType and b.action then -- Actionbar
		local actionType = GetActionInfo(b.action)
		if actionType == 'flyout' then -- no point binding flyouts
			return self:Hide()
		end
	end

	-- Update displayed text on buttons
	self:UpdateFlyoutText()
	self:UpdateSpellText()
	self:UpdateMacroText()

	self:Show()
end

--  [[  Fired whenever the mouse is over and a button is clicked ]]  --
function Binder:Listener(key)
	if key == "ESCAPE" or key == "RightButton" then
		local command = GetCommandFromButton(self.button, self.bType)
		local keys = {GetBindingKey(command)}
		ClearBindings(self.button, keys)
		self:Update(self.button, self.bType)
		return
	end
	
	if keyMap[key] == 'IGNORE' then 
		return 
	elseif keyMap[key] then
		key = keyMap[key]
	end
	
	local alt = IsAltKeyDown() and "ALT-" or ""
	local ctrl = IsControlKeyDown() and "CTRL-" or ""
	local shift = IsShiftKeyDown() and "SHIFT-" or ""
	
	SetBindings(self.button, alt..ctrl..shift..key, self.button.command)
	self:Update(self.button, self.bType)
end

function Binder:ToggleGrid(show)
	for button in ns.actionbutton_iterator() do
		for i = 1, 12 do
			button:SetAttribute("showgrid", show and 1 or 0)
			ActionButton_ShowGrid(button)
		end
	end
end

function Binder:StartBinding()
	if InCombatLockdown() then return ns.Print("Can't bind in combat!") end
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	ns.Print('Starting binding mode.')
	self.isBinding = true
	self:ToggleGrid(self.isBinding)
	self:UpdateButtons()
end

function Binder:ShowBindings(enable)
	if self.isBinding then return; end
	self.shouldShowBindings = enable
	ns:ToggleBindings(enable)
end

function Binder:StopBinding(save)
	if self.isBinding then
		if save then
			SaveBindings(2)
			ns.Print('Bindings |cff00ff00saved|r.')
		else
			LoadBindings(2)
			ns.Print('Bindings |cffff0000discarded|r.')
		end
		self.isBinding = false
		self:ToggleGrid(self.isBinding)
		self:HideFrame()
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	end
	self:UpdateButtons()
end

function Binder:HideFrame()
	self:ClearAllPoints()
	self:Hide()
end

--  [[  Update the toggle buttons  ]]  --
function Binder:UpdateButtons()
	-- toggle buttons
	if self.isBinding then
		SBButton:SetText('Stop Binding')
		if MButton then
			MButton:SetText('Stop Binding') 
		end
	else
		SBButton:SetText('Start Binding')
		if MButton then 
			MButton:SetText('Start Binding') 
		end
	end
end

--  [[  Get the right text on buttons  ]]  --
function Binder:UpdateSpellText()
	local text, key
	for i = 1, #spellText do
		text = spellText[i]
		key = GetButtonKey(text:GetParent(), 'SPELLBOOK')
		text:SetText(GetKeyText(key))
	end
end
function Binder:UpdateFlyoutText()
	local text, key
	for i = 1, #spellFlyoutText do
		text = spellFlyoutText[i]
		key = GetButtonKey(text:GetParent(), 'FLYOUT')
		text:SetText(GetKeyText(key))
	end
end
function Binder:UpdateMacroText()
	local text, key
	for i = 1, #macroText do
		text = macroText[i]
		key = GetButtonKey(text:GetParent(), 'MACRO')
		text:SetText(GetKeyText(key))
	end
end

function Binder:IsInBindingMode()
	return self.isBinding
end

--  [[  Creating the toggle button  ]] --
local function button_OnClick(self, button)
	if Binder.isBinding then
		if IsModifierKeyDown() then
			Binder:StopBinding(false)
		else
			Binder:StopBinding(true)
		end
	else
		Binder:StartBinding()
	end
end

local function button_OnEnter(self)
  GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, 0)
  GameTooltip:SetText("Shift click to discard bindings")
  GameTooltip:Show()
end
local function button_OnLeave()
  GameTooltip:Hide()
end

--  [[  Fired when macro frame is first opened  ]]  --
local function SetupMacroButton()
	if MButton then return end
	MacroExitButton:SetWidth(70)
	MacroNewButton:SetWidth(70)
	MacroNewButton:SetPoint("BOTTOMRIGHT", -72, 4)

	MButton = CreateFrame("Button", "MacroBinderButton", MacroFrame, "UIPanelButtonTemplate")
	MButton:ClearAllPoints()
	MButton:SetPoint("BOTTOMLEFT", 81, 4)
	MButton:SetHeight(22)
	MButton:SetWidth(118)
	MButton:SetText("Start Binding")

	for i=1,36 do
		local b = _G["MacroButton"..i]
		b:HookScript("OnEnter", function(self) Binder:Update(self, "MACRO") end)
	end

	-- Create the macro text
	local i = 1
	while _G['MacroButton'..i] do
		local text = _G['MacroButton'..i]:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		text:SetPoint("TOPRIGHT")
		macroText[i] = text
		i = i + 1
	end

	MButton:SetScript('OnClick', button_OnClick)
	MButton:SetScript('OnEnter', button_OnEnter)
	MButton:SetScript('OnLeave', button_OnLeave)
	Binder:UpdateButtons()

	hooksecurefunc("MacroFrame_Update", Binder.UpdateMacroText)
	MacroFrame:HookScript("OnShow", function() Binder:ShowBindings(true) end)
	MacroFrame:HookScript("OnHide", function(self)
		if (not SpellBookFrame:IsShown()) then
			Binder:StopBinding(false)
			Binder:ShowBindings(false)
		end
	end)
end

local function SetupSpellButton()
	SBButton = CreateFrame("Button", "SpellBookBinderButton", SpellBookSpellIconsFrame, "UIPanelButtonTemplate")
	SBButton:ClearAllPoints()
	SBButton:SetPoint("BOTTOMLEFT", 94, 29 )
	SBButton:SetHeight(28)
	SBButton:SetWidth(200)
	SBButton:SetText("Start Binding")

	SBButton:SetScript('OnClick', button_OnClick)
	SBButton:SetScript('OnEnter', button_OnEnter)
	SBButton:SetScript('OnLeave', button_OnLeave)

	--  [[	Spellbook text  ]]  --
	local i = 1
	while _G["SpellButton"..i] do
		local text = _G["SpellButton"..i]:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		text:SetPoint("TOPRIGHT")
		spellText[i] = text
		i = i + 1
	end

	hooksecurefunc("SpellBookFrame_UpdateSpells", function()
		if not SpellBookFrame:IsVisible() then return end
		Binder:UpdateSpellText()
	end)

	SpellBookFrame:HookScript("OnShow", function() Binder:ShowBindings(true) end)
	SpellBookFrame:HookScript("OnHide", function(self)
		if (not MButton) or (MButton and not MacroFrame:IsShown()) then
			Binder:StopBinding(false)
			Binder:ShowBindings(false)
		end
	end)
end

local function RegisterFlyouts()
	for i=1, GetNumFlyouts() do
		local id = GetFlyoutID(i)
		local _, _, numSlots, isKnown = GetFlyoutInfo(id)
		if (isKnown) then
			for k=1, numSlots do
				local b = _G["SpellFlyoutButton"..k]
				if SpellFlyout:IsShown() and b and b:IsShown() then
					if not b.hookedFlyout then
						b:HookScript("OnEnter", function(b) Binder:Update(b, "FLYOUT"); end);
						b.hookedFlyout = true
						-- Create flyout text
						if not spellFlyoutText[k] then
							local text = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
							text:SetPoint("TOPRIGHT")
							spellFlyoutText[k] = text
						end
					end
				end
			end
		end
	end
	Binder:UpdateFlyoutText()
end

Binder:RegisterEvent('PLAYER_LOGIN')
Binder:SetScript('OnEvent', function(self)
	if self.loaded then return end
	
	SetupSpellButton()
	if not IsAddOnLoaded('Blizzard_MacroUI') then
		hooksecurefunc("LoadAddOn", function(addon)
			if addon == 'Blizzard_MacroUI' then
				SetupMacroButton()
			end
		end)
	else
		SetupMacroButton()
	end

	self:SetFrameStrata("DIALOG")
	self:SetFrameLevel(90)
	self:EnableMouse(true)
	self:EnableKeyboard(true)
	self:EnableMouseWheel(true)
	self.texture = self:CreateTexture()
	self.texture:SetAllPoints(self)
	self.texture:SetColorTexture(0, 0, 0, .25)
	self:Hide()

	self:SetScript("OnEvent", function(self)
		self:StopBinding(false)
	end)
	self:SetScript("OnLeave", function(self)
		self:HideFrame()
	end)
	self:SetScript("OnKeyUp", function(self, key)
		self:Listener(key)
	end)
	self:SetScript("OnMouseUp", function(self, key)
		self:Listener(key)
	end)
	self:SetScript("OnMouseWheel", function(self, delta)
		if delta > 0 then 
			self:Listener("MOUSEWHEELUP")
		else 
			self:Listener("MOUSEWHEELDOWN")
		end
	end)

	-- Registering
	local stance = StanceButton1:GetScript("OnClick")
	local pet = PetActionButton1:GetScript("OnClick")
	local button = ActionButton1:GetScript("OnClick")
	local function register(val)
		if val.IsProtected and val.GetObjectType and val.GetScript and val:GetObjectType()=="CheckButton" and val:IsProtected() then
			local script = val:GetScript("OnClick")
			if script==button then
				val:HookScript("OnEnter", function(self) Binder:Update(self) end)
			elseif script==stance then
				val:HookScript("OnEnter", function(self) Binder:Update(self, "STANCE") end)
			elseif script==pet then
				val:HookScript("OnEnter", function(self) Binder:Update(self, "PET") end)
			end
		end
	end
	local val = EnumerateFrames()
	while val do
		register(val)
		val = EnumerateFrames(val)
	end

	-- Spellbookframe
	for i=1,12 do
		local b = _G["SpellButton"..i]
		b:HookScript("OnEnter", function(self) Binder:Update(self, "SPELL") end)
	end
	--Flyouts
	hooksecurefunc(SpellFlyout, "Toggle", RegisterFlyouts)

	self.loaded = true
end)