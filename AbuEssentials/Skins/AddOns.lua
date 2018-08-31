local AddonName, ns = ...

local function SkinAddOns(event, addon)
    if (IsAddOnLoaded('Omen')) and not(OmenBarList.borderTextures) then
        ns.CreateBorder(OmenBarList, 11, 4)
    end

    if (IsAddOnLoaded('Skada')) then
        local OriginalSkadaFunc = Skada.PLAYER_ENTERING_WORLD
        function Skada:PLAYER_ENTERING_WORLD()
            OriginalSkadaFunc(self)

            if (SkadaBarWindowSkada and not SkadaBarWindowSkada.borderTextures) then
                ns.CreateBorder(SkadaBarWindowSkada, 14, 5)
            end
        end

        local origApplyFunc = Skada.ApplySettings
        function Skada:ApplySettings(win)
            origApplyFunc(self, win)
            SkadaBarWindowSkada:SetBackdrop({
                bgFile = 'Interface\\Buttons\\WHITE8x8',
                tile = false,
                tileSize = 32,
                insets = { left = -2, right = -2, top = -2, bottom = -2 },
            })
            SkadaBarWindowSkada:SetBackdropColor(0, 0, 0, .3)
        end
    end

    if (IsAddOnLoaded("ShieldMaid")) and (not ShieldMaidShieldBarrierIcon.borderTextures) then
        local i1, i2 = ShieldMaidShieldBarrierIcon, ShieldMaidShieldBlockIcon
        ns.CreateBorder(i1, 16, 4)
        ns.CreateBorder(i2, 16, 4)
    end
end

ns:RegisterEvent("PLAYER_ENTERING_WORLD", SkinAddOns)