-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3

local betting_pos_x = 150
local betting_pos_y = ScrH() / 2 - (ScrH() / 5)
local t_betcount = 0
local i_betcount = 0
-- Languages:
-- 1 = english
-- 2 = german
local lang = 1
local KARMABET_LANG = {}

KARMABET_LANG[1] = {}
KARMABET_LANG[1].runningbets = "Running Bets"
KARMABET_LANG[1].for_t = " for Traitors"
KARMABET_LANG[1].for_i = " for Innocents"

KARMABET_LANG[2] = {}
KARMABET_LANG[2].runningbets = "Laufende Wetten"
KARMABET_LANG[2].for_t = " für Traitor"
KARMABET_LANG[2].for_i = " für Innocent"


hook.Add( "HUDPaint", "BettingHUD", function()
	-- Only show bets when there are bets placed
	if t_betcount ~= 0 or i_betcount ~= 0 then
		-- Top title
		draw.DrawText( KARMABET_LANG[lang].runningbets, "TargetID", ScrW() - betting_pos_x, betting_pos_y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		
		-- Traitor amount
		draw.DrawText( t_betcount .. KARMABET_LANG[lang].for_t, "TargetIDSmall", ScrW() - betting_pos_x, betting_pos_y + 20, Color( 255, 0, 0, 255 ), TEXT_ALIGN_LEFT )
		
		-- Innocent amount
		draw.DrawText( i_betcount .. KARMABET_LANG[lang].for_i, "TargetIDSmall", ScrW() - betting_pos_x, betting_pos_y + 35, Color( 0, 255, 0, 255 ), TEXT_ALIGN_LEFT )
	end
end)

-- Start betting
net.Receive( "karmabet_updatehud", function( net_response )

	t_betcount = net.ReadInt( 32 )
	i_betcount = net.ReadInt( 32 )
	lang = net.ReadInt( 4 )
	
end)