local name, ns = ...

_G['AbuGlobal'] = {
	GlobalConfig = ns.GlobalConfig,
	CreateBorder = ns.CreateBorder,
}
---------------------------------------------------------------------------
--								COMMANDS								 --
---------------------------------------------------------------------------

--Reeeeeload
_G.SLASH_RELOADUI1 = '/rl'
SlashCmdList.RELOADUI = ReloadUI

--Stacked
_G.SLASH_FSTACK1 = '/fs'
SlashCmdList.FSTACK = function(msg) SlashCmdList.FRAMESTACK(msg) end

-- gm 
_G.SLASH_HELP1 = '/gm'
_G.SLASH_HELP2 = '/ticket'
SlashCmdList.HELP = ToggleHelpFrame

--ItemID
_G.SLASH_ITEMID1 = '/itemid'
SlashCmdList.ITEMID = function(msg) 
	local _, link = GetItemInfo(msg) 
	if link then 
		ChatFrame1:AddMessage(msg .. " has item ID: " .. link:match("item:(%d+):")) 
	end 
end
----------------------------------------
--Antiafk hihihi
local function UnAfk()
	local button = _G[StaticPopup_Visible("CAMP").."Button1"]
	if button then
		button:Click()
	end
end

_G.SLASH_UNAFK1 = '/antiafk'
local isUnAfk = false
SlashCmdList.UNAFK = function(msg)
	if (not isUnAfk) then
		ns:RegisterEvent("PLAYER_CAMPING", UnAfk)
		ns:Print("Anti AFK Mode: ON")
	else
		ns:UnregisterEvent("PLAYER_CAMPING", UnAfk)
		ns:Print("Anti AFK Mode: OFF")
	end
	isUnAfk = not isUnAfk
end

-----------------------------------
-- add delay to macros
_G.SLASH_IN1 = "/in"
_G.SLASH_IN2 = "/timer"

local box = _G.MacroEditBox

SlashCmdList.IN = function(input)
	local time, cmd = input:match'^([^%s]+)%s+(.*)$'
	time = tonumber(time)
	if (not time) or (not cmd) then return; end

	C_Timer.After(math.max(time, 0.01), function()
		box:GetScript("OnEvent")(box, "EXECUTE_CHAT_LINE", cmd)
	end)
end

---------
-- Map 
--[[
for i = 1, 4 do
	_G["WorldMapParty"..i]:SetSize(25,25)
end
for i = 1, 40 do
	_G["WorldMapRaid"..i]:SetSize(20,20)
end
]]
--if true then return end
local playerCoords = WorldMapFrame.BorderFrame:CreateFontString("$parentPlayerCoordsText", "OVERLAY", "NumberFontNormal")
local cursorCoords = WorldMapFrame.BorderFrame:CreateFontString("$parentCursorCoordsText", "OVERLAY", "NumberFontNormal")
playerCoords:SetPoint('BOTTOMRIGHT', WorldMapFrame.BorderFrame, 'BOTTOM', -50, 10)
playerCoords:Show()
cursorCoords:SetPoint('BOTTOMLEFT', WorldMapFrame.BorderFrame, 'BOTTOM', 50, 10)
cursorCoords:Show()
local function getCursorCoords()
	local x, y = GetCursorPosition()
	local left, top = WorldMapFrame.ScrollContainer.Child:GetLeft(), WorldMapFrame.ScrollContainer.Child:GetTop()
	local width = WorldMapFrame.ScrollContainer.Child:GetWidth()
	local height = WorldMapFrame.ScrollContainer.Child:GetHeight()
	local scale = WorldMapFrame.ScrollContainer.Child:GetEffectiveScale()
	local cx = (x/scale - left) / width
	local cy = (top - y/scale) / height

	if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
		return nil, nil
	end

	return cx, cy
end

local poll_updateplayerposition = 1
local elapsed = 0
local function worldMap_OnUpdate(self, e)

	local cx, cy = getCursorCoords()
	if not cx then
		cursorCoords:SetText('Cursor: --, --')
	else
		cursorCoords:SetFormattedText('Cursor: %d, %d', cx*100, cy*100)
	end

	elapsed = elapsed - e
	if elapsed > 0 then
		return
	end
	elapsed = poll_updateplayerposition

	local id = C_Map.GetBestMapForUnit("player")
	if id then
		local px, py = C_Map.GetPlayerMapPosition(id, "player"):GetXY()
		if px and py and px > 0 and py > 0 then
			playerCoords:SetFormattedText('Player: %d, %d', px*100, py*100)
			return
		end
	end
	playerCoords:SetText('Player: --, --')
end
WorldMapFrame:HookScript('OnUpdate', worldMap_OnUpdate)