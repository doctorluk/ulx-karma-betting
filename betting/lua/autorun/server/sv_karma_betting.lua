-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3

if SERVER then
	
	if not KARMABET_LANG then
		print("[KARMABET] ERROR! FAILED LOADING LANGUAGE! CHECK CONFIG AND RESTART SERVER!")
		print("[KARMABET] ERROR! FAILED LOADING LANGUAGE! CHECK CONFIG AND RESTART SERVER!")
		print("[KARMABET] ERROR! FAILED LOADING LANGUAGE! CHECK CONFIG AND RESTART SERVER!")
		return
	end
	
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
	function karmabet_echoBetPlacement( ply, amount, target, puthidden, all )
	
		local color = Color( 0, 255, 0, 255 )
		if target == "innocent" then
			target = "Innocent"
		else
			target = "Traitor"
			color = Color( 255, 0, 0, 255 )
		end
		
		local hidden = " "
		local allin = ""
		
		if puthidden then
			hidden = KARMABET_LANG.echo_hidden
		end
		
		if all then
			allin = KARMABET_LANG.echo_allin
		end
		
		for _, player in ipairs( player.GetHumans() ) do
			if not player:Alive() or player:IsSpec() then
				ULib.tsayColor( player, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "]" .. hidden, 
				Color( 200, 200, 0, 255 ), allin, 
				Color( 255, 255, 0, 0 ), ply:Nick(),
				Color( 60, 90, 100, 255 ), KARMABET_LANG.echo_bets,
				Color( 190, 40, 40, 255), amount .. "",	
				Color( 60, 90, 100, 255 ), KARMABET_LANG.echo_karmaonteam, 
				color, target .. "")
			end
		end
		
	end
	
	-- Big check whether or not someone can bet
	function karmabet_canBet( calling_ply, amount, target, all )
	
		local puthidden = false
	
		if not calling_ply then return false end
	
		-- Only dead/spectating players are allowed to bet
		if calling_ply:Alive() and not calling_ply:IsSpec() then
			karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_deadalive )
			return false
		end
		
		-- Only allow betting while a round is active
		if GetRoundState() ~= ROUND_ACTIVE then
			karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_activeround )
			return false
		end
		
		-- Prevent betting when betting is disabled
		if not KARMABET_CAN_BET or KARMABET_HAS_RUN then
			karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_timeup )
			return false
		end
		
		-- Prevent betting when slowmo (of end-round) is running
		if game.GetTimeScale() ~= 1 then
			karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_slowmo )
			return false
		end
		
		-- Check for valid team
		target = string.lower( target )
		if target == "t" or target == "traitor" then
			target = "traitor"
		elseif target == "i" or target == "inno" or target == "innocent" then
			target = "innocent"
		else
			karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_wrongtarget )
			return false
		end
		
		-- Check if player has enough karma to bet
		if calling_ply:GetLiveKarma() < GetConVar( "karmabet_min_live_karma" ):GetInt() then
			karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_notenoughkarma )
			return false
		end
		
		-- Make this bet only visible for spectators and dead players
		if not puthidden and not karmabet_enoughCorpsesFound() then
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
			local was_all = tmptable[3]
			
			-- Only allow betting for the same team again
			if saved_target ~= target then
				karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_wrongteam )
				return false
			end
			
			-- Player went all-in, he can't do anything 
			if was_all then
				karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_allin )
				return false
			end
			
			-- Limit new amount to maximum
			local maxAdd = 0
			
			if all then
				maxAdd = GetConVar( "karmabet_allin_karma" ):GetInt() - saved_amount
			else
				maxAdd = GetConVar( "karmabet_max_karma" ):GetInt() - saved_amount
			end
			
			if amount > maxAdd then
				amount = maxAdd
			end
			
			-- Report hit maximum
			if amount == 0 then
				karmabet_reportError( calling_ply, KARMABET_LANG.cantbet_maxbetwarn_1 .. GetConVar( "karmabet_max_karma" ):GetInt() .. KARMABET_LANG.cantbet_maxbetwarn_2 )
				return false
			end
			
			-- Check for lower karma limit
			amount = karmabet_getAdjustedBetForLowKarma( calling_ply, amount )
			if amount == 0 then return false end
			
			-- Update player's saved amount
			local new_saved_amount = amount + saved_amount
			if puthidden then
				karmabet_tbl_betters_hidden[calling_ply:SteamID()] = { new_saved_amount, target, all }
			else
				karmabet_tbl_betters[calling_ply:SteamID()] = { new_saved_amount, target, all }
			end
		else
			-- Check for lower karma limit
			amount = karmabet_getAdjustedBetForLowKarma( calling_ply, amount )
			if amount == 0 then return false end
		end
		
		-- If all passes, start bet
		karmabet_start( calling_ply, amount, target, puthidden, all )
		
		return true
	end
	
	-- Adjusts bet to remaining karma above minimum
	function karmabet_getAdjustedBetForLowKarma( ply, amount )
	
		if ply:GetLiveKarma() - amount < GetConVar( "karmabet_min_live_karma" ):GetInt() then
			amount = math.floor( ply:GetLiveKarma() - GetConVar( "karmabet_min_live_karma" ):GetInt() )
			if amount == 0 then
				karmabet_reportError( ply, KARMABET_LANG.cantbet_notenoughremainingkarma )
				return amount
			end
			karmabet_reportNotice( ply, KARMABET_LANG.cantbet_lowkarma_1 .. amount .. KARMABET_LANG.cantbet_lowkarma_2 )
		end
		return amount
		
	end
	
	function karmabet_enoughCorpsesFound()
		if GetConVar( "karmabet_debug" ):GetBool() then
			print("[Karmabet] Corpses found: ".. karmabet_corpses_found .. ", KARMABET_MINIMUM_IDENTIFIED_BODIES: " .. GetConVar( "karmabet_min_identified_bodies" ):GetInt())
		end
		return karmabet_corpses_found >= GetConVar( "karmabet_min_identified_bodies" ):GetInt()
	end
	
	-- Actually start the bet
	function karmabet_start( calling_ply, amount, target, puthidden, all )
	
		local amountSending = 0
	
		-- Reduce player's karma by the amount he bet
		calling_ply:SetLiveKarma( calling_ply:GetLiveKarma() - amount )
		
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
				karmabet_tbl_betters_hidden[calling_ply:SteamID()] = { amount, target, all }
			end
		else
			if not karmabet_tbl_betters[calling_ply:SteamID()] then
				karmabet_tbl_betters[calling_ply:SteamID()] = { amount, target, all }
			end
		end
		-- PrintTable( karmabet_tbl_betters )
		
		karmabet_echoBetPlacement( calling_ply, amount, target, puthidden, all )
		
		if not puthidden then karmabet_updateAllPlayers() end
		
	end
	
	-- Function called when finding a player
	function karmabet_onBodyFound( ply, deadply, rag )
		if ply and deadply then
			karmabet_corpses_found = karmabet_corpses_found + 1
			-- karmabet_reportNotice( nil, "[DEBUG] Found corpse of player " .. deadply:Nick() .. ", karmabet_corpses_found: " .. karmabet_corpses_found )
		end
		
		if karmabet_enoughCorpsesFound() and table.Count( karmabet_tbl_betters_hidden ) > 0 then
			for id, entry in pairs( karmabet_tbl_betters_hidden ) do
				local ply = player.GetBySteamID( id )
				if ply then -- See if he's actually on the server
					karmabet_tbl_betters[id] = { entry[1], entry[2], entry[3] }
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
	
	-- Update the display for all players
	function karmabet_updateAllPlayers()
		
		net.Start( "karmabet_updatehud" )
		net.WriteInt( karmabet_bet_total_t, 32 )
		net.WriteInt( karmabet_bet_total_i, 32 )
		net.WriteInt( KARMABET_LANG.id, 8 )
		net.Broadcast()
		
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
		
		timer.Create( "karmabet_timer_timewarning", GetConVar( "karmabet_bet_time" ):GetInt() - 20, 1, function()
		
			ULib.tsayColor( nil, false,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ", 
				Color( 255, 255, 0, 0 ), KARMABET_LANG.timer_timeleft )
			
		end )
		
		timer.Create( "karmabet_timer", GetConVar( "karmabet_bet_time" ):GetInt(), 1, function()
		
			ULib.tsayColor( nil, false,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ", 
				Color( 255, 255, 0, 0 ), KARMABET_LANG.timer_betsclosed )
			
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
					local allin = entry[3]
					
					if target == karmabet_winner then
					
						local karmaReturned = math.ceil( amount + ( amount * own_bet_winscale ) + ( loser_amount * losers_bet_winscale ) )
						
						karmabet_tbl_results[id] = { karmaReturned, target }
						
						ULib.tsayColor( nil, false,
							Color( 50, 50, 50, 255 ), "[", 
							Color( 190, 40, 40, 255 ), "Karmabet",
							Color( 50, 50, 50, 255 ), "] ",
							Color( 255, 255, 0, 0 ), ply:Nick(),
							Color( 0, 255, 0, 255 ), KARMABET_LANG.roundend_wins,
							Color( 255, 255, 255, 255 ), karmaReturned .. "",
							Color( 0, 255, 0, 255 ), " " .. KARMABET_LANG.general_karma .. "!" )
						
						local newKarma = ply:GetLiveKarma() + karmaReturned
						if newKarma > GetConVar("ttt_karma_max"):GetInt() then newKarma = GetConVar("ttt_karma_max"):GetInt() end
						ply:SetBaseKarma( newKarma )
						ply:SetLiveKarma( newKarma )
						
					else
					
						ULib.tsayColor( nil, false,
							Color( 50, 50, 50, 255 ), "[", 
							Color( 190, 40, 40, 255 ), "Karmabet",
							Color( 50, 50, 50, 255 ), "] ",
							Color( 255, 255, 0, 0 ), ply:Nick(),
							Color( 255, 0, 0, 255 ), KARMABET_LANG.roundend_loses,
							Color( 255, 255, 255, 255 ), amount .. "",
							Color( 255, 0, 0, 255 ), " " .. KARMABET_LANG.general_karma .. "!" )
						
						karmabet_tbl_results[id] = { amount, target }
					end
				end
			end
			
			-- PrintTable( karmabet_tbl_results )
			karmabet_insertIntoDatabase()
			
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
		net.WriteInt( KARMABET_LANG.id, 8 )
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
