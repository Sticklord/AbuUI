local name, ns = ...

--  [[ Map Edit 	]] --
WorldMapFrame:SetScript("OnMouseWheel", function(self, delta)
	local newLevel = GetCurrentMapDungeonLevel() + delta
	if newLevel >= 1 and newLevel <= GetNumDungeonMapLevels() then
		PlaySound("INTERFACESOUND_GAMESCROLLBUTTON")
		SetDungeonMapLevel(newLevel)
	end
end)

--	[[	Raid Warnings	]] --
RaidWarningFrame:ClearAllPoints()
RaidWarningFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 260)
RaidWarningFrameSlot2:ClearAllPoints()
RaidWarningFrameSlot2:SetPoint('TOP', RaidWarningFrameSlot1, 'BOTTOM', 0, -3)
RaidBossEmoteFrameSlot2:ClearAllPoints()
RaidBossEmoteFrameSlot2:SetPoint('TOP', RaidBossEmoteFrameSlot1, 'BOTTOM', 0, -3)

--	[[ Hide Annoying Spell Overlays	]] --
hooksecurefunc("SpellActivationOverlay_ShowOverlay", function(self, spellID)
	if ns.Config.HidePowa[spellID] then
		SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, spellID)
	end
end)

-- 	[[ Remove Poisonous stuff ]] --
PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
StaticPopupDialogs.RESURRECT.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil

--	[[	Hide fish tooltips	]]  --
local function HideFishTip()
	GameTooltip:HookScript("OnShow", function()
		local tooltipText = GameTooltipTextLeft1
		if tooltipText and tooltipText:GetText() == "Fishing Bobber" then
			GameTooltip:Hide()
		end
	end)
end
ns:RegisterEvent("PLAYER_LOGIN", HideFishTip)

-- Replace Blizzards duration display
do	local minute, hour, day = 60, 60*60, 60*60*24
	local hourish, dayish = minute*59, hour*23 
	function _G.SecondsToTimeAbbrev(sec)
		if ( sec >= dayish  ) then
			return '|cffffffff%dd|r', floor(sec/day + .5);
		elseif ( sec >= hourish  ) then
			return '|cffffffff%dh|r', floor(sec/hour + .5);
		elseif ( sec >= minute  ) then
			return '|cffffffff%dm|r', floor(sec/minute + .5);
		end
		return '|cffffffff%d|r', sec;
end	end

--	[[	Change Raid Sliders ]]  --
local function ChangeRaidSliders()
	if not IsAddOnLoaded('Blizzard_CompactUnitFrameProfiles') then
		LoadAddOn("Blizzard_CompactUnitFrameProfiles")
	end
	CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider:SetMinMaxValues(1,150) 
	CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider:SetMinMaxValues(1,150)
end

ns:RegisterEvent("PLAYER_LOGIN", ChangeRaidSliders)

-- [[ Change LFD to holiday ]]
LFDParentFrame:HookScript("OnShow", function()
	for i = 1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		if(select(15,GetLFGDungeonInfo(id))) and (not GetLFGDungeonRewards(id)) then
			LFDQueueFrame_SetType(id)
		end
	end
end)

---------------------------------------------------------------------------
-- 					autoclick StaticPopupDialogs						 --
---------------------------------------------------------------------------

local function autoClick(which, arg1, arg2, data)
	for i=1,STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..i]
		if (not frame:IsVisible()) then
			return;
		end

		if frame.which == "CONFIRM_LOOT_ROLL" then
			if frame.data == arg1 and frame.data2 == arg2 then
				StaticPopup_OnClick(frame, 1) 
			end
		elseif frame.which == "CONFIRM_PURCHASE_TOKEN_ITEM" then
			if string.find(arg1, "Garrison Resources") then
				StaticPopup_OnClick(frame, 1) 
			end
		end
	end
end
hooksecurefunc("StaticPopup_Show", autoClick)

StaticPopupDialogs["LOOT_BIND"].OnCancel = function(self, slot)
	if GetNumGroupMembers() == 0 then 
		ConfirmLootSlot(slot) 
	end
end