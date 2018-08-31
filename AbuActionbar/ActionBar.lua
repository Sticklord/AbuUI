
local _, ns = ...
local cfg = ns.Config
local playerClass

local FRAMES_DISABLE_MOVEMENT = {
	'MultiBarLeft',
	'MultiBarRight',
	'MultiBarBottomRight',
	'PossessBarFrame',
	'MULTICASTACTIONBAR_YPOS',
	'MultiCastActionBarFrame',
}

local HIDE_FRAMES = {
	'ActionBarUpButton', 'ActionBarDownButton',
	'MainMenuBarBackpackButton','CharacterBag0Slot','CharacterBag1Slot','CharacterBag2Slot','CharacterBag3Slot',
	'MainMenuBarTexture2','MainMenuMaxLevelBar2','MainMenuBarTexture3','MainMenuMaxLevelBar3',
	--ArtifactWatchBar.StatusBar.WatchBarTexture2, ArtifactWatchBar.StatusBar.WatchBarTexture3,
	--ArtifactWatchBar.StatusBar.XPBarTexture2, ArtifactWatchBar.StatusBar.XPBarTexture3,
	--HonorWatchBar.StatusBar.WatchBarTexture2, HonorWatchBar.StatusBar.WatchBarTexture3,
	--ReputationWatchBar.StatusBar.WatchBarTexture2, ReputationWatchBar.StatusBar.WatchBarTexture3,
	'MainMenuBarPageNumber',
	'SlidingActionBarTexture0','SlidingActionBarTexture1',
	'StanceBarLeft','StanceBarMiddle','StanceBarRight',
	'PossessBackground1','PossessBackground2',
}

local SHORTEN_FRAMES = {
    MainMenuBar,
    MainMenuExpBar,
    MainMenuBarMaxLevelBar,
    --ArtifactWatchBar,
    --ArtifactWatchBar.StatusBar,
    --HonorWatchBar,
    --HonorWatchBar.StatusBar,
    --ReputationWatchBar,
    --ReputationWatchBar.StatusBar,
}

function ns.Print(...)
	if (not ...) then return; end
	local s = ""
	local t = {...}
	for i = 1, #t do
		s = s .. " " .. t[i]
	end
	return print("|cffffcf00Abu:|r"..s)
end

local actionbars = {'ActionButton', 'MultiBarBottomLeftButton','MultiBarBottomRightButton','MultiBarRightButton','MultiBarLeftButton'}
function ns.actionbutton_iterator()
	local i = 0
	local barIndex = 1

	return function ()
		i = i + 1
		if i > 12 then 
			i = 1 
			barIndex = barIndex + 1 
		end
		if actionbars[barIndex] then 
			return _G[actionbars[barIndex]..i]
		end
	end
end

ns.eventFrame = CreateFrame('Frame')
ns.eventFrame:SetScript('OnEvent', function(self, event, ...)
	if (self[event]) then self[event](self, event, ...) end
end)

if true then return end

---------------------------------------------------------------------
--	Shorten the Main Menu bar
---------------------------------------------------------------------

for _, name in pairs(HIDE_FRAMES) do
	local object = _G[name] or name
	if (object:IsObjectType('Frame') or object:IsObjectType('Button')) then
		object:UnregisterAllEvents()
		object:SetScript('OnEnter', nil)
		object:SetScript('OnLeave', nil)
		object:SetScript('OnClick', nil)
	else
		object.Show = nop
	end
	object:Hide()
end
--  [[  Shorten textures  ]]  --
for _, f in pairs(SHORTEN_FRAMES) do
	f:SetWidth(512)
end

    -- remove divider

for i = 1, 19, 2 do
    for _, object in pairs({_G['MainMenuXPBarDiv'..i]}) do
        object.Show = object.Hide
        object:Hide()
    end
end

hooksecurefunc(_G['MainMenuXPBarDiv2'], 'Show', function(self)
    local divWidth = MainMenuExpBar:GetWidth() / 10
    local xpos = divWidth - 4.5

    for i = 2, 19, 2 do
        local texture = _G['MainMenuXPBarDiv'..i]
        local xalign = floor(xpos)
        texture:SetPoint('LEFT', xalign, 1)
        xpos = xpos + divWidth
    end
end)

_G['MainMenuXPBarDiv2']:Show()

--  [[  MultiBarBottomRight (now top middle)  ]]  --
MultiBarBottomRight:EnableMouse(false)
MultiBarBottomRight:ClearAllPoints()
MultiBarBottomRight:SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton1, 'TOPLEFT', 0, 6)

MainMenuBarTexture0:SetPoint('BOTTOM', MainMenuBarArtFrame, -128, 0)
MainMenuBarTexture1:SetPoint('BOTTOM', MainMenuBarArtFrame, 128, 0)
MainMenuMaxLevelBar0:SetPoint('BOTTOM', MainMenuBarMaxLevelBar, 'TOP', -128, 0)
MainMenuBarLeftEndCap:SetPoint('BOTTOM', MainMenuBarArtFrame, -289, 0)
MainMenuBarRightEndCap:SetPoint('BOTTOM', MainMenuBarArtFrame, 289, 0)

hooksecurefunc('MainMenuBarVehicleLeaveButton_Update', function()
	MainMenuBarVehicleLeaveButton:ClearAllPoints()
	MainMenuBarVehicleLeaveButton:SetPoint('LEFT', MainMenuBar, 'RIGHT', 10, 75)
end)

-- Xp bar text displays
local function mouseoverText(frame, textobject)
	textobject:SetFont('Fonts\\ARIALN.ttf', 14, 'THINOUTLINE')
	textobject:SetShadowOffset(0, 0)
	textobject:SetAlpha(0)
	frame:HookScript('OnEnter', function()
		UIFrameFadeIn(textobject, 0.2, textobject:GetAlpha() or 0, 1)
	end)
	frame:HookScript('OnLeave', function()
		UIFrameFadeOut(textobject, 0.2, textobject:GetAlpha() or 1, 0)
	end)
end
--mouseoverText(ArtifactWatchBar, ArtifactWatchBar.OverlayFrame.Text)
mouseoverText(MainMenuExpBar, MainMenuBarExpText)
--mouseoverText(HonorWatchBar, HonorWatchBar.OverlayFrame.Text)

--  [[  Pet Bar  ]]  --
PetActionBarFrame:EnableMouse(false)
PetActionBarFrame:SetFrameStrata('HIGH')
PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 19, 7)

-- [[  Stance Bar  ]]  --
if (cfg.HideStanceBar[playerClass]) then
	for i = 1, NUM_STANCE_SLOTS do
		local button = _G['StanceButton'..i]
		button:SetAlpha(0)
		button.SetAlpha = function() end

		button:EnableMouse(false)
		button.EnableMouse = function() end
	end
end
hooksecurefunc(StanceBarFrame, "SetPoint", function(self, ...)
	if InCombatLockdown() then return; end
	local point, anchor, rpoint, x, y = ...

	if MultiBarBottomRight:IsVisible() and y < 80 then
		self:SetPoint(point, anchor, rpoint, x, y + 45)
	end
end)

--  [[  MultiBarRight  ]]  --
MultiBarRight:ClearAllPoints()
MultiBarRight:SetPoint('TOPRIGHT', UIParent, 'RIGHT', -6, (MultiBarRight:GetHeight() / 2))

--  [[  MultiBarLeft  ]]  --
MultiBarLeft:SetParent(UIParent)
MultiBarLeft:ClearAllPoints()
MultiBarLeft:SetPoint('TOPRIGHT', MultiBarRightButton1, 'TOPLEFT', -6, 0)

--  [[  Kill the shit that places spells  ]] --
IconIntroTracker:UnregisterAllEvents()
IconIntroTracker:Hide()
IconIntroTracker.Show = function() end

---------------------------------------------
--		Mouseover Fading
---------------------------------------------
local enableMouseOverFading
do 
	local Bar_OnEnter = function(bar)
		if bar.FadeOutAnim:IsPlaying() then bar.FadeOutAnim:Stop() end

		if bar.FadeInAnim:IsPlaying() or bar:GetAlpha() > 0.95 then return end
		bar.FadeInAnim:Play()
	end

	local Bar_OnLeave = function(bar)
		if not bar:IsMouseOver() then -- In case mouse went from bar to button or vice
			bar.FadeOutAnim:Play()
		end
	end

	local Button_OnEnter = function(button)
		local bar = button:GetParent()
		Bar_OnEnter(bar)
	end

	local Button_OnLeave = function(button)
		local bar = button:GetParent()
		Bar_OnLeave(bar)
	end

	local function SetupFlyoutDetection()
		local modifiedFlyoutsIndex = 0
		-- Fix so flyoutbuttons counts as bars
		hooksecurefunc(SpellFlyout, "Toggle", function(self, flyoutID, parent, direction, distance, isActionBar, specID, showFullTooltip)
			if not self:IsShown() then return end
			local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID)
			for i = modifiedFlyoutsIndex + 1, numSlots do
				local name = 'SpellFlyoutButton'..i
				local b = _G[name]
				if b then
					b:HookScript("OnEnter", function(self)
						local flyOut = self:GetParent()
						if flyOut.isActionBar then
							local parentBar = flyOut:GetParent():GetParent()
							if not cfg.FadeOutBars[parentBar:GetName()] then return end
							Bar_OnEnter(parentBar)
						end
					end)
					b:HookScript("OnLeave", function(self)
						local flyOut = self:GetParent()
						if flyOut.isActionBar then
							local parentBar = flyOut:GetParent():GetParent()
							if not cfg.FadeOutBars[parentBar:GetName()] then return end
							Bar_OnLeave(parentBar)
						end
					end)
				end
			end
			modifiedFlyoutsIndex = numSlots
		end)
		SpellFlyout:HookScript("OnEnter", function(self)
			if self.isActionBar then
				local parentBar = self:GetParent():GetParent()
				if not cfg.FadeOutBars[parentBar:GetName()] then return end
				Bar_OnEnter(parentBar)
			end
		end)
		SpellFlyout:HookScript("OnLeave", function(self)
			if self.isActionBar then
				local parentBar = self:GetParent():GetParent()
				if not cfg.FadeOutBars[parentBar:GetName()] then return end
				Bar_OnLeave(parentBar)
			end
		end)
	end
	
	local flyoutsReady = false
	function enableMouseOverFading(bar, minAlpha)
		if not tonumber(minAlpha) or minAlpha >= 1 then return; end
		if not flyoutsReady then
			SetupFlyoutDetection()
			flyoutsReady = true
		end

		-- hook for cooldown alpha
		hooksecurefunc(bar, "SetAlpha", function(self, alpha)
			local name = self:GetName()
			alpha = alpha * .7
			for i = 1, 12 do
				_G[name..'Button'..i].cooldown:SetSwipeColor(0,0,0,alpha)
			end
		end)

		local FadeOutAnim = bar:CreateAnimationGroup()
		FadeOutAnim:SetToFinalAlpha(true)
		FadeOutAnim.a1 = FadeOutAnim:CreateAnimation("Alpha")
		FadeOutAnim.a1:SetTarget(bar);
		FadeOutAnim.a1:SetFromAlpha(1);
		FadeOutAnim.a1:SetToAlpha(minAlpha);
		FadeOutAnim.a1:SetSmoothing("IN");
		FadeOutAnim.a1:SetDuration(0.4);
		FadeOutAnim.a1:SetStartDelay(2);
		bar.FadeOutAnim = FadeOutAnim

		local FadeInAnim = bar:CreateAnimationGroup()
		FadeInAnim:SetToFinalAlpha(true)
		FadeInAnim.a1 = FadeInAnim:CreateAnimation("Alpha")
		FadeInAnim.a1:SetTarget(bar);
		FadeInAnim.a1:SetFromAlpha(minAlpha);
		FadeInAnim.a1:SetToAlpha(1);
		FadeInAnim.a1:SetSmoothing("IN");
		FadeInAnim.a1:SetDuration(0.4);
		bar.FadeInAnim = FadeInAnim

		bar:SetAlpha(minAlpha)
		bar:EnableMouse(true) -- So it doesnt hide when mouse is between buttons
		bar:HookScript("OnEnter", Bar_OnEnter)
		bar:HookScript("OnLeave", Bar_OnLeave)
		bar:Show()

		for i = 1, 12 do
			local button = _G[bar:GetName()..'Button'..i]
			button:HookScript("OnEnter", Button_OnEnter)
			button:HookScript("OnLeave", Button_OnLeave)
		end
	end
end

for barname, alpha in pairs(cfg.FadeOutBars) do
	local bar = _G[barname]
	if bar and tonumber(alpha) then
		enableMouseOverFading(bar, alpha)
	end
end