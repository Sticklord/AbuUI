local _, ns = ...

if (not ns.Config.SkinMinimap) then return; end

-- Hiding Crap
MinimapCluster:SetScale(1.0)
MinimapCluster:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -5, 5)
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MiniMapWorldMapButton:Hide()
--MinimapZoneTextButton:Hide()
MinimapBorderTop:Hide()
MiniMapTracking:UnregisterAllEvents()
MiniMapTracking:Hide()

-- Blip texture
--Minimap:SetBlipTexture("Interface\\AddOns\\AbuEssentials\\Textures\\Blip-BlizzardBig.tga")

-- Mousewheel zoom
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(_, zoom)
    if zoom > 0 then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end)

-- Minimap Tracking rightclick
Minimap:SetScript('OnMouseUp', function(self, button)  
	if (button == 'RightButton') then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * 0.7), -3)
	else
		Minimap_OnClick(self)
	end
end)

MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint('TOP',Minimap,'TOP',0,14)
MinimapZoneText:SetFont('Fonts\\ARIALN.ttf', 14, 'THINOUTLINE')
MinimapZoneText:SetShadowOffset(0, 0)
MinimapZoneText:SetAlpha(0)
Minimap:HookScript('OnEnter', function()
	UIFrameFadeIn(MinimapZoneText, 0.2, MinimapZoneText:GetAlpha() or 0, 1)
end)
Minimap:HookScript('OnLeave', function()
	UIFrameFadeOut(MinimapZoneText, 0.2, MinimapZoneText:GetAlpha() or 1, 0)
end)