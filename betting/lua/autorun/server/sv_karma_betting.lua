-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.0

if SERVER then
	
	KARMABET_CAN_BET = true
	
	karmabet_bet_total_t = 0
	karmabet_bet_total_i = 0
	karmabet_corpses_found = 0
	karmabet_tbl_betters = {}
	karmabet_tbl_betters_hidden = {}
	karmabet_tbl_results = {}
	karmabet_winner = ""
	
	-- Used to communicate with clients
	util.AddNetworkString( "karmabet_updatehud" )
	
	-- Show given player a predesigned error message
	function karmabet_reportError( ply, errormsg )
		ULib.tsayColor( ply, true,
			Color( 50, 50, 50, 255 ), "[", 
			Color( 190, 40, 40, 255 ), "Karmabet",
			Color( 50, 50, 50, 255 ), "] ", Color( 255, 0, 0, 255 ), "ERROR: ",
			Color( 255, 255, 0, 0 ), errormsg )
	end
	
	-- Show given player a predesigned notice message
	function karmabet_reportNotice( ply, note )
		ULib.tsayColor( ply, true,
			Color( 50, 50, 50, 255 ), "[", 
			Color( 190, 40, 40, 255 ), "Karmabet",
			Color( 50, 50, 50, 255 ), "] ",
			Color( 100, 100, 255, 255 ), "NOTICE: ",
			Color( 255, 255, 0, 0 ), note )
	end
	
	-- Show spectating/dead players that someone has placed a bet
	function karmabet_echoBetPlacement( ply, amount, target, puthidden )
	
		local color = Color( 0, 255, 0, 255 )
		if target == "innocent" then
			target = "Innocent"
		else
			target = "Traitor"
			color = Color( 255, 0, 0, 255 )
		end
		
		local hidden = " "
		
		if puthidden then
			hidden = "[VERSTECKT] "
		end
		
		for _, player in ipairs( player.GetHumans() ) do
			if not player:Alive() or player:IsSpec() then
				ULib.tsayColor( player, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "]" .. hidden, 
				Color( 255, 255, 0, 0 ), ply:Nick(),
				Color( 60, 90, 100, 255 ), " wettet ",
				Color( 190, 40, 40, 255), amount .. "",	
				Color( 60, 90, 100, 255 ), " Karma auf das Team ", 
				color, target .. "")
			end
		end
		
	end
	
	-- Big check whether or not someone can bet
	function karmabet_canBet( calling_ply, amount, target )
	
		local puthidden = false
	
		if not calling_ply then return false end
	
		-- Only dead/spectating players are allowed to bet
		if calling_ply:Alive() and not calling_ply:IsSpec() then
			karmabet_reportError( calling_ply, "Du kannst nur wetten, wenn du nicht lebst!" )
			return false
		end
		
		-- Only allow betting while a round is active
		if GetRoundState() ~= ROUND_ACTIVE then
			karmabet_reportError( calling_ply, "Man kann nur während einer aktiven Runde wetten!" )
			return false
		end
		
		-- Prevent betting when betting is disabled
		if not KARMABET_CAN_BET or KARMABET_HAS_RUN then
			karmabet_reportError( calling_ply, "Zeit zum Wetten ist abgelaufen!" )
			return false
		end
		
		-- Prevent betting when slowmo (of end-round) is running
		if game.GetTimeScale() ~= 1 then
			karmabet_reportError( calling_ply, "Kann nicht während der Zeitlupe wetten! (Du Cheater!)" )
			return false
		end
		
		-- Check for valid team
		target = string.lower( target )
		if target == "t" or target == "traitor" then
			target = "traitor"
		elseif target == "i" or target == "inno" or target == "innocent" then
			target = "innocent"
		else
			karmabet_reportError( calling_ply, "Du hast kein Ziel eingegeben! Versuche T oder I für Traitor oder Innocent." )
			return false
		end
		
		-- Check if player has enough karma to bet
		if calling_ply:GetLiveKarma() < KARMABET_MINIMUM_LIVE_KARMA then
			karmabet_reportError( calling_ply, "Dein Karma ist zu gering um zu wetten!" )
			return false
		end
		
		-- Reduce bet depending on how much Karma the player has left
		if calling_ply:GetLiveKarma() - amount < KARMABET_MINIMUM_LIVE_KARMA then
			amount = math.floor( calling_ply:GetLiveKarma() - KARMABET_MINIMUM_LIVE_KARMA )
			if amount == 0 then
				karmabet_reportError( calling_ply, "Dein verbleibendes Karma ist zu gering um zu wetten!" )
				return false
			end
			karmabet_reportNotice( calling_ply, "Dein Karma ist low! Es konnte nur " .. amount .. " Karma gesetzt werden!" )
		end
		
		if not karmabet_enoughCorpsesFound() then
			puthidden = true
		end
		
		local tmptable = {}
		
		-- Check if player changed his mind about voting or limit is reached
		if puthidden then
			tmptable = karmabet_tbl_betters_hidden[calling_ply:SteamID()]
		else
			tmptable = karmabet_tbl_betters[calling_ply:SteamID()]
		end
		
		if tmptable then
			local saved_amount = tmptable[1]
			local saved_target = tmptable[2]
			
			-- Only allow betting for the same team again
			if saved_target ~= target then
				karmabet_reportError( calling_ply, "Du kannst nur dem gleichen Team mehr wetten und nicht mehr wechseln!" )
				return false
			end
			
			-- Limit new amount to maximum
			local maxAdd = KARMABET_MAXIMUM_KARMA - saved_amount
			if amount > maxAdd then
				amount = maxAdd
			end
			
			-- Report hit maximum
			if amount == 0 then
				karmabet_reportError( calling_ply, "Du kannst nicht mehr als " .. KARMABET_MAXIMUM_KARMA .. " wetten!" )
				return false
			end
			
			-- Update player's saved amount
			local new_saved_amount = amount + saved_amount
			if puthidden then
				karmabet_tbl_betters_hidden[calling_ply:SteamID()] = { new_saved_amount, target }
			else
				karmabet_tbl_betters[calling_ply:SteamID()] = { new_saved_amount, target }
			end
		end
		
		-- If all passes, start bet
		karmabet_start( calling_ply, amount, target, puthidden )
		
		return true
	end
	
	function karmabet_enoughCorpsesFound()
		print(karmabet_corpses_found .. " " .. KARMABET_MINIMUM_IDENTIFIED_BODIES .. "\n")
		return karmabet_corpses_found >= KARMABET_MINIMUM_IDENTIFIED_BODIES
	end
	
	-- Actually start the bet
	function karmabet_start( calling_ply, amount, target, puthidden )
	
		-- Reduce player's karma by the amount he bet
		calling_ply:SetLiveKarma( calling_ply:GetLiveKarma() - amount )
		
		local amountSending = 0
		
		-- Add to global counter
		if target == "traitor" then
			karmabet_bet_total_t = karmabet_bet_total_t + amount
			amountSending = karmabet_bet_total_t
		else
			karmabet_bet_total_i = karmabet_bet_total_i + amount
			amountSending = karmabet_bet_total_i
		end
		
		-- Add player to table of players who have placed a bet
		if puthidden then
			if not karmabet_tbl_betters_hidden[calling_ply:SteamID()] then
				karmabet_tbl_betters_hidden[calling_ply:SteamID()] = { amount, target }
			end
		else
			if not karmabet_tbl_betters[calling_ply:SteamID()] then
				karmabet_tbl_betters[calling_ply:SteamID()] = { amount, target }
			end
		end
		-- PrintTable( karmabet_tbl_betters )
		
		karmabet_echoBetPlacement( calling_ply, amount, target, puthidden )
		
		if not puthidden then karmabet_updateAllPlayers() end
		
	end
	
	-- Function called when finding a player
	function karmabet_onBodyFound(ply, deadply, rag)
		if ply and deadply then
			karmabet_corpses_found = karmabet_corpses_found + 1
			-- karmabet_reportNotice( nil, "[DEBUG] Found corpse of player " .. deadply:Nick() .. ", karmabet_corpses_found: " .. karmabet_corpses_found )
		end
		
		if karmabet_enoughCorpsesFound() and table.Count( karmabet_tbl_betters_hidden ) > 0 then
			for id, entry in pairs( karmabet_tbl_betters_hidden ) do
				local ply = player.GetBySteamID( id )
				if ply then -- See if he's actually on the server
					karmabet_tbl_betters[id] = { entry[1], entry[2] }
				end
				
			end
			table.Empty( karmabet_tbl_betters_hidden )
			karmabet_refresh()
		end
		
	end
	hook.Add( "TTTBodyFound", "karmabet_onBodyFound", karmabet_onBodyFound )
	
	-- Lazy refresh of running bets
	function karmabet_refresh()
		local bet_i = 0
		local bet_t = 0
		
		for _, entry in pairs( karmabet_tbl_betters ) do
		
			if entry[2] == "traitor" then
				bet_t = entry[1] + bet_t
			elseif entry[2] == "innocent" then
				bet_i = entry[1] + bet_i
			end
			
		end
		
		karmabet_bet_total_t = bet_t
		karmabet_bet_total_i = bet_i
		
		karmabet_updateAllPlayers()
		
	end
	
	-- Update the display for all players/dead players
	function karmabet_updateAllPlayers()
		if (KARMABET_SHOUTOUT_ALIVE) then
			net.Start( "karmabet_updatehud" )
			net.WriteInt( karmabet_bet_total_t, 32 )
			net.WriteInt( karmabet_bet_total_i, 32 )
			net.Broadcast()
		else
			for k, v in ipairs( player.GetHumans() ) do
				if not (v:IsActive()) then
					net.Start( "karmabet_updatehud" )
					net.WriteInt( karmabet_bet_total_t, 32 )
					net.WriteInt( karmabet_bet_total_i, 32 )
					net.Send(v) -- sending for each player, because RecipientFilter is not working
				end
			end
		end
	end
	
	-- Running on the start of a round and timing the betting end
	function karmabet_timedBettingEnd()
	
		-- Reset everything to defaults
		KARMABET_CAN_BET = true
		KARMABET_HAS_RUN = false
		karmabet_corpses_found = 0
		table.Empty( karmabet_tbl_results )
		karmabet_winner = ""
		
		ServerLog("[Karmabet] Bets open!\n")
		
		timer.Create( "karmabet_timer_timewarning", KARMABET_BET_TIME - 20, 1, function()
			if (KARMABET_SHOUTOUT_ALIVE) then
				ULib.tsayColor( nil, false,
					Color( 50, 50, 50, 255 ), "[", 
					Color( 190, 40, 40, 255 ), "Karmabet",
					Color( 50, 50, 50, 255 ), "] ", 
					Color( 255, 255, 0, 0 ), "Noch 20 Sekunden um zu wetten!" )
			else
				for k, v in ipairs( player.GetHumans() ) do
					if not (v:IsActive()) then
						ULib.tsayColor( v, false,
							Color( 50, 50, 50, 255 ), "[", 
							Color( 190, 40, 40, 255 ), "Karmabet",
							Color( 50, 50, 50, 255 ), "] ", 
							Color( 255, 255, 0, 0 ), "Noch 20 Sekunden um zu wetten!" )
					end
				end
			end
		end )
		
		timer.Create( "karmabet_timer", KARMABET_BET_TIME, 1, function()
			if (KARMABET_SHOUTOUT_ALIVE) then
				ULib.tsayColor( nil, false,
					Color( 50, 50, 50, 255 ), "[", 
					Color( 190, 40, 40, 255 ), "Karmabet",
					Color( 50, 50, 50, 255 ), "] ", 
					Color( 255, 255, 0, 0 ), "Wetten geschlossen!" )
			else
				for k, v in ipairs( player.GetHumans() ) do
					if not (v:IsActive()) then
						ULib.tsayColor( v, false,
							Color( 50, 50, 50, 255 ), "[", 
							Color( 190, 40, 40, 255 ), "Karmabet",
							Color( 50, 50, 50, 255 ), "] ", 
							Color( 255, 255, 0, 0 ), "Wetten geschlossen!" )
					end
				end
			end
			KARMABET_CAN_BET = false
			ServerLog("[Karmabet] Bets closed!\n")
			
		end )
	end
	hook.Add( "TTTBeginRound", "karmabet_timedBettingEnd", karmabet_timedBettingEnd )
	
	-- Act after a round has ended
	function karmabet_onRoundEnd( winning_team )
		if not KARMABET_HAS_RUN then
		
			KARMABET_HAS_RUN = true
			
			timer.Remove( "karmabet_timer_timewarning" )
			timer.Remove( "karmabet_timer" )
			
			local loser_amount = karmabet_bet_total_t
			karmabet_winner = "innocent"
			
			if winning_team == WIN_TRAITOR then
				karmabet_winner = "traitor"
				loser_amount = karmabet_bet_total_i
			end
			
			local own_bet_winscale = (math.random(10, 25) / 100) -- between 10% and 25% of entered bet
			local losers_bet_winscale = (math.random(5, 15) / 100) -- between 5% and 15% of bets from the losing team
			
			-- First we put our hidden entries into the normal database	if that hasn't happened before
			for id, entry in pairs( karmabet_tbl_betters_hidden ) do
			
				local ply = player.GetBySteamID( id )
				if ply then -- See if he's actually on the server
					karmabet_tbl_betters[id] = { entry[1], entry[2] }
				end
				
			end
			
			table.Empty( karmabet_tbl_betters_hidden )
			
			-- Winners get their bet, and a bonus depending on the amount of bets against them				
			for id, entry in pairs( karmabet_tbl_betters ) do
			
				local ply = player.GetBySteamID( id )
				if ply then
					local amount = entry[1]
					local target = entry[2]
					
					if target == karmabet_winner then
					
						local karmaReturned = math.ceil( amount + ( amount * own_bet_winscale ) + ( loser_amount * losers_bet_winscale ) )
						
						karmabet_tbl_results[id] = { karmaReturned, target }
						
						ULib.tsayColor( nil, false,
							Color( 50, 50, 50, 255 ), "[", 
							Color( 190, 40, 40, 255), "Karmabet",
							Color( 50, 50, 50, 255), "] ",
							Color( 255, 255, 0, 0 ), ply:Nick(),
							Color( 0, 255, 0, 255), " gewinnt ",
							Color( 255, 255, 255, 255), karmaReturned .. "",
							Color( 0, 255, 0, 255), " Karma!" )
						
						local newKarma = ply:GetLiveKarma() + karmaReturned
						if newKarma > GetConVar("ttt_karma_max"):GetInt() then
							newKarma = GetConVar("ttt_karma_max"):GetInt()
						end
						ply:SetBaseKarma( newKarma )
						ply:SetLiveKarma( newKarma )
						
					else
					
						ULib.tsayColor( nil, false,
							Color( 50, 50, 50, 255 ), "[", 
							Color( 190, 40, 40, 255), "Karmabet",
							Color( 50, 50, 50, 255), "] ",
							Color( 255, 255, 0, 0 ), ply:Nick(),
							Color( 255, 0, 0, 255), " verliert ",
							Color( 255, 255, 255, 255), amount .. "",
							Color( 255, 0, 0, 255), " Karma!" )
						
						karmabet_tbl_results[id] = { amount, target }
					end
				end
			end
			
			-- PrintTable( karmabet_tbl_results )
			karmabet_insertResultsMySQL()
			
			table.Empty(karmabet_tbl_betters)
			karmabet_refresh()

			-- Since we run our Hook AFTER karma has been saved, we have to save it again, otherwise the gained karma
			-- is lost upon mapchange
			KARMA.Rebase()
			KARMA.RememberAll()
		end
	end
	hook.Add( "TTTEndRound", "karmabet_onRoundEnd", karmabet_onRoundEnd )
	
	-- Send new player current bets
	function karmabet_onPlayerConnect( ply )
		net.Start( "karmabet_updatehud" )
		net.WriteInt( karmabet_bet_total_t, 32 )
		net.WriteInt( karmabet_bet_total_i, 32 )
		net.Send( ply )
	end
	hook.Add( "PlayerInitialSpawn", "karmabet_onPlayerConnect", karmabet_onPlayerConnect )
	
	-- Disable !bet chat text
	hook.Add( "PlayerSay", "KarmabetChatPrevention", function( ply, text, team )
		text = string.lower(text)
		if ( string.sub( text, 1, 4 ) == "!bet" or string.sub( text, 1, 7 ) == "!mybets" ) then
			return ""
		end
	end )
	
end
