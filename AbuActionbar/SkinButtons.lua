local _, ns = ...
local cfg = ns.Config

local _G, pairs, unpack = _G, pairs, unpack
local IsActionInRange = _G.IsActionInRange
local IsUsableAction = _G.IsUsableAction

local Color = {
	Normal = { 0.7, 0.7, 0.6 , 1},
	OutOfRange = { 1, 0.2, 0.2 , 1},
	OutOfMana = { 0.3, 0.3, 1, 1},
	NotUsable = { 0.35, 0.35, 0.35, 1},
	HotKeyText = { 0.6, 0.6, 0.6, 1},
	CountText = { 1, 1, 1, 1},
	Background = {0.2,0.2,0.2,0.8},
	Shadow = { 0, 0, 0, 0.7},
}

local function IsSpecificButton(self, name)
	local sbut = self:GetName():match(name)
	if (sbut) then
		return true
	else
		return false
	end
end

local function CreateBackGround(button, fBG)
	if not button or button.Shadow then return; end

	-- Shadow
	if fBG and type(fBG) == 'table' and fBG:GetObjectType() == 'texture' then
		fBG:ClearAllPoints()
		fBG:SetPoint('TOPRIGHT', button, 5, 5)
		fBG:SetPoint('BOTTOMLEFT', button, -5, -5)
		fBG:SetTexture(cfg.Textures.Shadow)
		fBG:SetVertexColor(unpack(Color.Shadow))
		button.Shadow = fBG
	else
		local shadow = button:CreateTexture(nil, "BACKGROUND")
		shadow:SetParent(button)
		shadow:SetPoint('TOPRIGHT', button, 5, 5)
		shadow:SetPoint('BOTTOMLEFT', button, -5, -5)
		shadow:SetTexture(cfg.Textures.Shadow)
		shadow:SetVertexColor(unpack(Color.Shadow))
		button.Shadow = shadow
	end

	-- Background Texure
	local tex = button:CreateTexture(nil, "BACKGROUND", nil, -8)
	tex:SetAllPoints(button)
	tex:SetTexture(cfg.Textures.Background)
	tex:SetVertexColor(unpack(Color.Background))
	return tex
end

local function ActionButtonUpdateHotkey(self, actionButtonType)
	local hotkey = _G[self:GetName()..'HotKey']
	local text = hotkey:GetText()
	if cfg.ShowKeybinds or ns.Binder.shouldShowBindings then
		if text and text ~= '' and text ~= RANGE_INDICATOR then
			hotkey:SetText(ns.GetKeyText(text))
			hotkey:Show()
		end
	else
		hotkey:Hide()
	end

	if self.BackGround then return; end

	if (not IsSpecificButton(self, 'OverrideActionBarButton')) then
		hotkey:ClearAllPoints()
		hotkey:SetPoint('TOPRIGHT', self, 0, -3)
		hotkey:SetFont(cfg.Font, cfg.FontSize - 1, 'OUTLINE')
		hotkey:SetVertexColor(unpack(Color.HotKeyText))
	else
		hotkey:ClearAllPoints()
		hotkey:SetFont(cfg.Font, cfg.FontSize + 2, 'OUTLINE')
		hotkey:SetPoint('TOPRIGHT', self, -5, -6)
		hotkey:SetVertexColor(unpack(Color.HotKeyText))
	end
end

local function ActionBarButton(button)
	if (not button) then return; end

	local name = button:GetName()
	local normal = _G[name..'NormalTexture'] or button:GetNormalTexture() --Sometimes it doesnt exist
	local icon = _G[name..'Icon']
	local flash = _G[name..'Flash']
	local count = _G[name..'Count']
	local macroname = _G[name..'Name']
	local cooldown = _G[name..'Cooldown']
	local buttonBg = _G[name..'FloatingBG']
	local border = _G[name..'Border']
	local flyoB = _G[name.."FlyoutBorder"]
	local flyoBS = _G[name.."FlyoutBorderShadow"]

	-- Flyouts
	if flyoB then flyoB:SetTexture(nil) end
	if flyoBS then flyoBS:SetTexture(nil) end

	-- Hide Macro name
	if (macroname) then macroname:Hide() end

	-- Button Count (feathers, monk roll)
	count:SetPoint('BOTTOMRIGHT', button, -2, 1)
	count:SetFont(cfg.Font, cfg.FontSize, 'OUTLINE')
	count:SetVertexColor(unpack(Color.CountText))

	-- Flash
	flash:SetTexture(cfg.Textures.Flash)

	-- Mod icon abit
	icon:SetTexCoord(.05, .95, .05, .95)

	-- Adjust cooldown
	cooldown:ClearAllPoints()
	cooldown:SetPoint('TOPRIGHT', button, -1, -1)
	cooldown:SetPoint('BOTTOMLEFT', button, 1, 1)

	-- Don't need to know what i've equipped
	border:SetTexture(nil)

	normal:ClearAllPoints()
	normal:SetPoint('TOPRIGHT', button, 2, 2)
	normal:SetPoint('BOTTOMLEFT', button, -2, -2)
	normal:SetVertexColor(unpack(Color.Normal))

	-- Apply textures
	button:SetNormalTexture(cfg.Textures.Normal)
	button:SetCheckedTexture(cfg.Textures.Checked)
	button:SetHighlightTexture(cfg.Textures.Highlight)
	button:SetPushedTexture(cfg.Textures.Pushed)

	button:GetCheckedTexture():SetAllPoints(normal)
	button:GetPushedTexture():SetAllPoints(normal)
	button:GetHighlightTexture():SetAllPoints(normal)

	ActionButtonUpdateHotkey(button)
	button.BackGround = CreateBackGround(button, buttonBg)
end

local function PetStancePossessButton(button)
	if not button then return; end
	button:SetNormalTexture(cfg.Textures.Normal)

	if button.BackGround then return; end

	local name = button:GetName()
	local icon = _G[name..'Icon']
	local flash = _G[name..'Flash']
	local normal = _G[name..'NormalTexture2'] or _G[name..'NormalTexture']
	local cooldown = _G[name..'Cooldown']

	normal:ClearAllPoints()
	normal:SetPoint('TOPRIGHT', button, 1.5, 1.5)
	normal:SetPoint('BOTTOMLEFT', button, -1.5, -1.5)
	normal:SetVertexColor(unpack(Color.Normal))

	-- Apply textures
	button:SetCheckedTexture(cfg.Textures.Checked)
	button:SetHighlightTexture(cfg.Textures.Highlight)
	button:SetPushedTexture(cfg.Textures.Pushed)
	button:GetCheckedTexture():SetAllPoints(normal)
	button:GetPushedTexture():SetAllPoints(normal)
	button:GetHighlightTexture():SetAllPoints(normal)

	cooldown:ClearAllPoints()
	cooldown:SetPoint('TOPRIGHT', button, -1, -1)
	cooldown:SetPoint('BOTTOMLEFT', button, 1, 1)

	icon:SetTexCoord(.05, .95, .05, .95)
	icon:SetPoint('TOPRIGHT', button, 1, 1)
	icon:SetPoint('BOTTOMLEFT', button, -1, -1)

	flash:SetTexture(cfg.Textures.Flash)

	if IsSpecificButton(button, 'PetActionButton') then -- Pet bar sets normaltexture
		hooksecurefunc(button, "SetNormalTexture", function(self, texture)
			if texture and texture ~= cfg.Textures.Normal then
				self:SetNormalTexture(cfg.Textures.Normal)
			end
		end)
	end

	ActionButtonUpdateHotkey(button)
	button.BackGround = CreateBackGround(button)
end

local function LeaveVehicleButton(button)
	if not button or (button and button.BackGround)then return; end
	button.BackGround = CreateBackGround(button)
end

local function ShowGrid(self)
	if (self.NormalTexture) then
		self.NormalTexture:SetAlpha(1)
	end
end

local function ActionButton_UpdateUsable(self)
	local normal = _G[self:GetName()..'NormalTexture']
	if (normal) then
		if OneRingLib then
			local r, g, b = OneRingLib.ext.OPieUI:GetTexColor(_G[self:GetName()..'Icon']:GetTexture())
        	normal:SetVertexColor(r, g, b)
    	else
			normal:SetVertexColor(unpack(Color.Normal))
		end
	end

	local isUsable, notEnoughMana = IsUsableAction(self.action)
	local icon = _G[self:GetName().."Icon"]
	if (isUsable) then
		if self.isInRange == false then
			return icon:SetVertexColor(Color.OutOfRange[1], Color.OutOfRange[2], Color.OutOfRange[3])
		else
			return icon:SetVertexColor(1, 1, 1, 1)
		end
	elseif (notEnoughMana) then
		return icon:SetVertexColor(Color.OutOfMana[1], Color.OutOfMana[2], Color.OutOfMana[3])
	else
		return icon:SetVertexColor(Color.NotUsable[1], Color.NotUsable[2], Color.NotUsable[3])
	end
end

local function ActionButton_Update(button, e)
	local name = button:GetName()

	if name:find('MultiCast') then
		return;
	elseif name:find('ExtraActionButton') then
		return;
	end

	if OneRingLib then
		local r, g, b = OneRingLib.ext.OPieUI:GetTexColor(_G[name..'Icon']:GetTexture())
        button:GetNormalTexture():SetVertexColor(r, g, b)
        button:GetHighlightTexture():SetVertexColor(r, g, b)
        button:GetPushedTexture():SetVertexColor(r, g, b)
        button:GetCheckedTexture():SetVertexColor(r, g, b)
    else
		button:SetNormalTexture(cfg.Textures.Normal)
	end
end

local TOOLTIP_UPDATE_TIME = _G.TOOLTIP_UPDATE_TIME
local function ActionButton_OnUpdate(button, e)
	local rangeTimer = button.rangeTimer
	if (rangeTimer and rangeTimer == TOOLTIP_UPDATE_TIME) then
		local isInRange = IsActionInRange(button.action)

		if (button.isInRange ~= isInRange) then
			button.isInRange = isInRange
			ActionButton_UpdateUsable(button)
		end
	end
end

-- For shwowing keybinds when entering binding mode
function ns.ToggleBindings(enable)
	for _, name in pairs({'PetActionButton','PossessButton','StanceButton','ActionButton',"MultiBarBottomLeftButton",
						"MultiBarBottomRightButton","MultiBarRightButton","MultiBarLeftButton"}) do
		for i = 1, 12 do
			if _G[name..i..'HotKey'] then
				ActionButtonUpdateHotkey(_G[name..i])
			end
		end
	end
end

for button in ns.actionbutton_iterator() do
	ActionBarButton(button)
end

for i = 1, NUM_OVERRIDE_BUTTONS do
	ActionBarButton(_G["OverrideActionBarButton"..i])
end
--possess buttons
for i=1, NUM_POSSESS_SLOTS do
	PetStancePossessButton(_G["PossessButton"..i])
end
--petbar buttons
for i=1, NUM_PET_ACTION_SLOTS do
	PetStancePossessButton(_G["PetActionButton"..i])
end
--stancebar buttons
for i=1, NUM_STANCE_SLOTS do
	PetStancePossessButton(_G["StanceButton"..i])
end
ns.eventFrame:RegisterEvent'UPDATE_BINDINGS'
ns.eventFrame.UPDATE_BINDINGS = function() -- apply hotkeys to em
	for i = 1, NUM_STANCE_SLOTS do
		local button = _G["StanceButton"..i]
		local key = GetBindingKey("SHAPESHIFTBUTTON"..i)
		_G["StanceButton"..i.."HotKey"]:SetText(key)
		ActionButtonUpdateHotkey(button)
	end
end
--style leave button
LeaveVehicleButton(OverrideActionBarLeaveFrameLeaveButton)

hooksecurefunc("ActionButton_Update", ActionButton_Update)
hooksecurefunc("ActionButton_OnUpdate", ActionButton_OnUpdate)
hooksecurefunc("ActionButton_UpdateUsable", ActionButton_UpdateUsable)

-- Showgrid hides border, lets fix
hooksecurefunc("ActionButton_ShowGrid", ShowGrid)
-- Update Hotkey
hooksecurefunc("ActionButton_UpdateHotkeys", ActionButtonUpdateHotkey)

-- Detect Flyouts
SpellFlyoutBackgroundEnd:SetTexture(nil)
SpellFlyoutHorizontalBackground:SetTexture(nil)
SpellFlyoutVerticalBackground:SetTexture(nil)

local nextFlyout = 1
hooksecurefunc(SpellFlyout, "Toggle", function(self, id, parent)
	if (not self:IsShown()) then return; end

	local _, _, numSlots = GetFlyoutInfo(id)
	for i = nextFlyout, numSlots do
		ActionBarButton(_G["SpellFlyoutButton"..i])
	end
	nextFlyout = numSlots
end)
