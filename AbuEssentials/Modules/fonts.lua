local _, ns = ...

local Standard = ns.GlobalConfig.Fonts.Normal
local Fancy = ns.GlobalConfig.Fonts.Fancy
-- Game engine fonts
_G.STANDARD_TEXT_FONT = Standard
_G.NAMEPLATE_FONT = Standard
_G.UNIT_NAME_FONT = Standard
_G.DAMAGE_TEXT_FONT = ns.GlobalConfig.Fonts.Damage
-- Based off tektickles i believe, by Tekkub
if true then return end
local function ChangeFont(obj, font, size, style, shadow)
	obj:SetFont(font, size, style)
	if (shadow) then
		obj:SetShadowOffset(1, -1)
	end
end

-- Change fonts

local Small    = 12
local Medium   = 13
local Large    = 16 
local Huge     = 18

-- Base fonts 									  FONT 		  SIZE 		OUTLINE 			SHADOW
ChangeFont(SystemFont_Tiny                   	, Standard 		, Small 	, nil				, false 	)
ChangeFont(SystemFont_Small                  	, Standard 		, Small 	, nil				, false 	)
ChangeFont(SystemFont_Outline_Small          	, Standard 		, Small 	, "OUTLINE"			, false 	)
ChangeFont(SystemFont_Shadow_Small           	, Standard 		, Small 	, nil				, false 	)
ChangeFont(SystemFont_InverseShadow_Small    	, Standard 		, Small 	, nil				, false 	)
ChangeFont(SystemFont_Med1                   	, Standard		, Medium	, nil				, false 	)
ChangeFont(SystemFont_Shadow_Med1            	, Standard		, Medium	, nil				, false 	)
ChangeFont(SystemFont_Med2                   	, Standard		, Medium	, nil				, false 	)
ChangeFont(SystemFont_Med3                   	, Standard		, Medium	, nil				, false 	)
ChangeFont(SystemFont_Shadow_Med3            	, Standard		, Medium	, nil				, false 	)
ChangeFont(SystemFont_Large                  	, Standard		, Large 	, nil				, false 	)
ChangeFont(SystemFont_Shadow_Large           	, Standard		, Large 	, nil				, false 	)
ChangeFont(SystemFont_Shadow_Large_Outline   	, Standard 		, Huge  	, "OUTLINE"			, false 	)
ChangeFont(SystemFont_Shadow_Huge1           	, Standard		, Huge  	, nil				, false 	)
ChangeFont(SystemFont_OutlineThick_Huge2     	, Standard		, Huge  	, "THICKOUTLINE"	, false 	)
ChangeFont(SystemFont_Shadow_Outline_Huge2   	, Standard		, Huge  	, "THICKOUTLINE"	, false 	)
ChangeFont(SystemFont_Shadow_Huge3           	, Standard		, Huge  	, nil				, false 	)
ChangeFont(SystemFont_OutlineThick_Huge4     	, Standard		, Huge  	, "THICKOUTLINE"	, false 	)
ChangeFont(SystemFont_OutlineThick_WTF       	, Standard		, 26		, "THICKOUTLINE"	, false 	)
		
ChangeFont(NumberFont_Shadow_Small           	, Standard		, Small 	, nil				, false 	)
ChangeFont(NumberFont_OutlineThick_Mono_Small	, Standard		, Medium	, "OUTLINE"			, false 	)
ChangeFont(NumberFont_Shadow_Med             	, Standard		, Medium	, nil				, false 	)
ChangeFont(NumberFont_Outline_Med            	, Standard		, Medium	, "OUTLINE"			, false 	)
ChangeFont(NumberFont_Outline_Large          	, Standard		, Large 	, "OUTLINE"			, false 	)
ChangeFont(NumberFont_Outline_Huge           	, Standard		, Huge  	, "OUTLINE"			, false 	)
		
ChangeFont(QuestFont_Large                   	, Fancy   		, Medium	, nil				, false 	)
ChangeFont(QuestFont_Shadow_Huge             	, Fancy   		, Huge  	, nil				, false 	)
ChangeFont(GameTooltipHeader                 	, Standard		, Medium	, nil				, false 	)
ChangeFont(MailFont_Large                    	, Fancy   		, Medium	, nil				, false 	)
ChangeFont(SpellFont_Small                   	, Standard		, Small 	, nil				, false 	)
ChangeFont(InvoiceFont_Med                   	, Standard		, Medium	, nil				, false 	)
ChangeFont(InvoiceFont_Small                 	, Standard		, Small 	, nil				, false 	)
ChangeFont(Tooltip_Med                       	, Standard		, Medium	, nil				, false 	)
ChangeFont(Tooltip_Small                     	, Standard 		, Small 	, nil				, false 	)
ChangeFont(AchievementFont_Small             	, Standard 		, Small 	, nil				, false 	)
ChangeFont(ReputationDetailFont              	, Standard 		, Small 	, nil				, false 	)
ChangeFont(FriendsFont_UserText              	, Standard 		, Small 	, nil				, false 	)
ChangeFont(FriendsFont_Normal                	, Standard		, Medium	, nil				, false 	)
ChangeFont(FriendsFont_Small                 	, Standard 		, Small 	, nil				, false 	)
ChangeFont(FriendsFont_Large                 	, Standard		, Large 	, nil				, false 	)
ChangeFont(CombatTextFont					 	, Standard  	, 150       , "THINOUTLINE"		, false 	)

_G.CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}
