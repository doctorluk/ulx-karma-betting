-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.1

local betting_pos_x = 150
local betting_pos_y = ScrH() / 2 - (ScrH() / 5)
local t_betcount = 0
local i_betcount = 0

hook.Add( "HUDPaint", "BettingHUD", function()
	if t_betcount ~= 0 or i_betcount ~= 0 then
		draw.DrawText( "Laufende Wetten", "TargetID", ScrW() - betting_pos_x, betting_pos_y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		draw.DrawText( t_betcount .. " für Traitor", "TargetIDSmall", ScrW() - betting_pos_x, betting_pos_y + 20, Color( 255, 0, 0, 255 ), TEXT_ALIGN_LEFT )
		draw.DrawText( i_betcount .. " für Innocent", "TargetIDSmall", ScrW() - betting_pos_x, betting_pos_y + 35, Color( 0, 255, 0, 255 ), TEXT_ALIGN_LEFT )
	end
end)

-- Start betting
net.Receive( "karmabet_updatehud", function( net_response )

	t_betcount = net.ReadInt( 32 )
	i_betcount = net.ReadInt( 32 )
	
	print("[KARMA DEBUG] Received Server's betting call with T-Count: " .. t_betcount .. " and I-Count: " .. i_betcount)
end)