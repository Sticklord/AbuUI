local AddonName, ns = ...
local WIDTH, HEIGHT = 445, 228
local X, Y = 15, 55

local CH = {
	gen = 'General',
	tr  = 'Trade',
	def = 'LocalDefense',
	rec = 'GuildRecruitment',
	lfg = 'LookingForGroup',
}

local function CreateBestChatLayout()
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_OpenNewWindow("Spam")
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	FCF_OpenNewWindow("Lewts")
	FCF_DockFrame(ChatFrame4)
	FCF_SetLocked(ChatFrame4, 1)

	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G["ChatFrame"..i]
		local id = chat:GetID()

		--Font size
		FCF_SetChatWindowFontSize(nil, chat, 14)
		
		--Chat frame size
		chat:SetSize(WIDTH, HEIGHT)
		
		-- tell wow that we are using new size
		SetChatWindowSavedDimensions(id, WIDTH, HEIGHT)
		
		if i == 1 then
			chat:SetPoint("BOTTOMLEFT", UIParent, X,Y)
			chat:SetUserPlaced(true)
			FCF_StopDragging(chat)
		elseif i == 2 then 
			FCF_SetWindowName(chat, "Log") 
		end
		-- save new default position and dimension
		FCF_SavePositionAndDimensions(chat)
		
	end
	FCFDock_SelectWindow(GENERAL_CHAT_DOCK, ChatFrame1)
	
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_RemoveAllChannels(ChatFrame1)
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")

	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "CHANNEL")
	ChatFrame_AddMessageGroup(ChatFrame1, "TARGETICONS")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")
	ChatFrame_AddMessageGroup(ChatFrame1, "PET_BATTLE_COMBAT_LOG")
	ChatFrame_AddMessageGroup(ChatFrame1, "PET_BATTLE_INFO")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
	ChatFrame_AddChannel(ChatFrame1, CH.gen)

	ChatFrame_RemoveAllMessageGroups(ChatFrame2)

	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddChannel(ChatFrame3, CH.tr)
	ChatFrame_AddChannel(ChatFrame3, CH.def)
	ChatFrame_AddChannel(ChatFrame3, CH.lfg)
	ChatFrame_AddChannel(ChatFrame3, CH.rec)
	ChatFrame_AddMessageGroup(ChatFrame3, "CHANNEL")

	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame4, "CURRENCY")
	ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_MISC_INFO")
end

local function SetUpStandards()
	SetCVar("whisperMode", "popout_and_inline")
	SetCVar("showTutorials", 0)
	SetCVar("chatStyle", "classic", "chatStyle")
	SetCVar("autoLootDefault", 1, "AUTO_LOOT_DEFAULT_TEXT")
	SetCVar("screenshotQuality", 10)
	SetCVar("screenshotFormat", "tga")
	SetCVar("spamFilter", 0)
	SetCVar("showArenaEnemyFrames", 0)
	SetCVar("UberTooltips", 1)
	SetCVar("violenceLevel", 5)
	SetCVar("autoDismount", 1)
	SetCVar("autoDismountFlying", 1)
	CreateBestChatLayout()
	
	ns:Print("Fixed default settings.")
end

_G.SLASH_ABUSETUP1 = '/abusetup'
SlashCmdList.ABUSETUP = SetUpStandards