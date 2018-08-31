	------------------------------------------------------------
--	Based on FacePaint by Aprikot
	------------------------------------------------------------
local AddonName, ns = ...

local color = ns.GlobalConfig.Colors.Frame

local frames = {
	"CompactRaidGroup1BorderFrame",
	"CompactRaidGroup2BorderFrame",
	"CompactRaidGroup3BorderFrame",
	"CompactRaidGroup4BorderFrame",
	"CompactRaidGroup5BorderFrame",
	"CompactRaidGroup6BorderFrame",
	"CompactRaidGroup7BorderFrame",
	"CompactRaidGroup8BorderFrame",
	"CompactRaidFrameContainerBorderFrameBorderBottom",
	"CompactRaidFrameContainerBorderFrameBorderBottomLeft",
	"CompactRaidFrameContainerBorderFrameBorderBottomRight",
	"CompactRaidFrameContainerBorderFrameBorderLeft",
	"CompactRaidFrameContainerBorderFrameBorderRight",
	"CompactRaidFrameContainerBorderFrameBorderTop",
	"CompactRaidFrameContainerBorderFrameBorderTopLeft",
	"CompactRaidFrameContainerBorderFrameBorderTopRight",
	
	-- RaidFrameManaged
	"CompactRaidFrameManagerBg",
	"CompactRaidFrameManagerBorderBottom",
	"CompactRaidFrameManagerBorderBottomLeft",
	"CompactRaidFrameManagerBorderBottomRight",
	"CompactRaidFrameManagerBorderRight",
	"CompactRaidFrameManagerBorderTopLeft",
	"CompactRaidFrameManagerBorderTopRight",
	"CompactRaidFrameManagerBorderTop",
	
	-- Minimap
	"MiniMapBattlefieldBorder",
	"MiniMapLFGFrameBorder",
	"MinimapBackdrop",
	"MinimapBorder",
	"MiniMapMailBorder",
	"MiniMapTrackingButtonBorder",
	"MinimapBorderTop",
	"MinimapZoneTextButton",
	"MiniMapWorldMapButton",
	"MiniMapWorldIcon",
	"QueueStatusMinimapButtonBorder",

	-- Action bar old
	"ReputationXPBarTexture0",
	"ReputationXPBarTexture1",
	"ReputationXPBarTexture2",
	"ReputationXPBarTexture3",
	"MainMenuBarTexture0",
	"MainMenuBarTexture1",
	"MainMenuBarTexture2",
	"MainMenuBarTexture3",
	"MainMenuXPBarTextureRightCap",
	"MainMenuXPBarTextureMid",
	"MainMenuXPBarTextureLeftCap",
	"MainMenuBarLeftEndCap",
	"MainMenuBarRightEndCap",

	"MainMenuBarArtFrame",

	"MainMenuMaxLevelBar0",
	"MainMenuMaxLevelBar1",
	"MainMenuMaxLevelBar2",
	"MainMenuMaxLevelBar3",
	"MainMenuBarMaxLevelBar",
	"MainMenuBarMaxLevelBarTexture0",
	"MainMenuBarMaxLevelBarTexture1",
	"MainMenuBarMaxLevelBarTexture2",
	"MainMenuBarMaxLevelBarTexture3",

	"ReputationWatchBarTexture0",
	"ReputationWatchBarTexture1",
	"ReputationWatchBarTexture2",
	"ReputationWatchBarTexture3",

	--ArtifactWatchBar.StatusBar.WatchBarTexture0,
	--ArtifactWatchBar.StatusBar.WatchBarTexture1, 
	--ArtifactWatchBar.StatusBar.WatchBarTexture2, 
	--ArtifactWatchBar.StatusBar.WatchBarTexture3,
	--ArtifactWatchBar.StatusBar.XPBarTexture0,
	--ArtifactWatchBar.StatusBar.XPBarTexture1,
	--ArtifactWatchBar.StatusBar.XPBarTexture2,
	--ArtifactWatchBar.StatusBar.XPBarTexture3,

	MainMenuBarArtFrame.LeftEndCap,
	MainMenuBarArtFrame.RightEndCap,
	MainMenuBarArtFrameBackground.BackgroundLarge,
	MainMenuBarArtFrameBackground.BackgroundSmall,

	StatusTrackingBarManager.SingleBarLarge,
	StatusTrackingBarManager.SingleBarLargeUpper,
	StatusTrackingBarManager.SingleBarSmall,
	StatusTrackingBarManager.SingleBarSmallUpper,
}
for i = 1, 19 do
	table.insert(frames, "MainMenuXPBarDiv"..i)
end

-- BAGS
for i = 1, 13 do
	table.insert(frames, "ContainerFrame"..i.."BackgroundTop")
	table.insert(frames, "ContainerFrame"..i.."BackgroundMiddle1")
	table.insert(frames, "ContainerFrame"..i.."BackgroundMiddle2")
	table.insert(frames, "ContainerFrame"..i.."BackgroundBottom")
end


local function Paint(obj)

	if not obj or obj:GetObjectType() ~= "Texture" then
		return
	end
	obj:SetVertexColor(unpack(color))
end

ns:RegisterEvent("ADDON_LOADED", function(event, name)
	if name ~= AddonName then return end

	if not IsAddOnLoaded("Blizzard_TimeManager") then
		LoadAddOn("Blizzard_TimeManager")
	end

	Paint(GameTimeFrame:GetPushedTexture())
	Paint(GameTimeFrame:GetNormalTexture())

	Paint(CompactRaidFrameManagerToggleButton:GetRegions())
	Paint(TimeManagerClockButton:GetRegions())

	for _, name in pairs(frames) do
		if type(name) == 'string' then
			Paint(_G[name])
		else
			Paint(name)
		end
	end
end)