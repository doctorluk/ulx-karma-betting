-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3
if SERVER then
	
	if KARMABET_USE_MYSQL then return end

	print( "[Karmabet] Using SQLite." )
	
	local query_success = nil
	
	query_success = sql.Query( "CREATE TABLE IF NOT EXISTS karmabet (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, bet_id INTEGER NOT NULL, name TEXT, steamid TEXT, amount INTEGER, date DATETIME DEFAULT CURRENT_TIMESTAMP)" )
	
	if query_success == false then
		print( "[Karmabet] Error creating SQLite table!" )
	end
	
	-- Shows the player's sum of all bets he placed
	function karmabet_showMyBetSummary( ply, steamid, duration )
	
		local duration = tonumber( duration ) or "all"
		if isnumber( duration ) then
			duration = math.Clamp( duration, 1, 31 ) -- Limit lookbacks between 1 and 31
		end
		
		local querystring = "SELECT sum(amount) as total FROM `karmabet` WHERE steamid = '" .. db:escape(steamid) .. "' LIMIT 1"
		
		if ( duration ~= "all" and duration <= 31 and duration > 0 ) then
			querystring = "SELECT sum(amount) as total FROM `karmabet` WHERE date > (SELECT DATETIME('now', '-" .. duration .. " day')) AND steamid = '" .. db:escape(steamid) .. "' LIMIT 1"
		end
		
		local list = sql.Query( querystring )
		
		if KARMABET_DEBUG then
			print( "[Karmabet] showMyBetSummary table results:" ) 
			if list then
				PrintTable(list)
			else
				print( "Empty list!" )
			end
		end
		
		-- Format the reported range to be printed to chat
		local durationDisplay = KARMABET_LANG.mybets_all
		if isnumber( duration ) then
			if duration > 1 then
				durationDisplay = duration .. KARMABET_LANG.mybets_days
			else
				durationDisplay = duration .. KARMABET_LANG.mybets_day
			end
		end
			
				
		for k, v in ipairs( list ) do
			if #list == 0 or not tonumber(v.total) then
				ULib.tsayColor( ply, true,
					Color( 50, 50, 50, 255 ), "[", 
					Color( 190, 40, 40, 255 ), "Karmabet",
					Color( 50, 50, 50, 255 ), "] ",
					Color( 255, 255, 0, 255 ), KARMABET_LANG.db_noentries )
				return
			end
			
			if tonumber(v.total) >= 0 then
				ULib.tsayColor( ply, true,
					Color( 50, 50, 50, 255 ), "[", 
					Color( 190, 40, 40, 255 ), "Karmabet",
					Color( 50, 50, 50, 255 ), "] ",
					Color( 255, 255, 255, 255 ), KARMABET_LANG.mybets_balance .. " [" .. durationDisplay .. "]: ",
					Color( 0, 255, 0, 255 ), v.total .. " ",
					Color( 255, 255, 255, 255 ), KARMABET_LANG.general_karma_ex )
			else
				ULib.tsayColor( ply, true,
					Color( 50, 50, 50, 255 ), "[", 
					Color( 190, 40, 40, 255 ), "Karmabet",
					Color( 50, 50, 50, 255 ), "] ",
					Color( 255, 255, 255, 255 ), KARMABET_LANG.mybets_balance .. " [" .. durationDisplay .. "]: ",
					Color( 255, 0, 0, 255 ), v.total .. " ",
					Color( 255, 255, 255, 255 ), KARMABET_LANG.general_karma_ex )
			end
		end
	end
	
	-- Shows the five highest entries in the database
	function karmabet_showBestBetters( duration )
		local list = sql.Query( "SELECT name, sum(amount) as total FROM `karmabet` WHERE date > (SELECT DATETIME('now', '-7 day')) GROUP BY steamid HAVING sum(amount) > 0 ORDER BY total DESC LIMIT 5" )
		
		if KARMABET_DEBUG then
			print( "[Karmabet] showBestBetters table results:" ) 
			if list then
				PrintTable(list)
			else
				print( "Empty list!" )
			end
		end
	
		if not list or #list == 0 then
			ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 255, 0, 255 ), KARMABET_LANG.db_noentries )
			return
		end
		
		ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 255, 0, 255 ), KARMABET_LANG.bestbets_the, 
				Color( 0, 255, 0, 255 ), KARMABET_LANG.bestbets_best,
				Color( 255, 255, 255, 255 ), #list .. " ",
				Color( 255, 255, 0, 255 ), KARMABET_LANG.bestbets_betters )
				
		for k, v in ipairs( list ) do
			ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 0, 255, 0, 255 ), "#" .. k .. ": ",
				Color( 255, 255, 0, 255 ), v.name .. " ",
				Color( 255, 255, 255, 255 ), KARMABET_LANG.bestbets_with,
				Color( 0, 255, 0, 255 ), v.total .. " ",
				Color( 255, 255, 255, 255 ), KARMABET_LANG.general_karma_ex )
		end
	end
	
	-- Shows the five lowest entries in the database
	function karmabet_showWorstBetters( duration )
		local list = sql.Query( "SELECT name, sum(amount) as total FROM `karmabet` WHERE date > (SELECT DATETIME('now', '-7 day')) GROUP BY steamid HAVING sum(amount) < 0 ORDER BY total DESC LIMIT 5" )
		
		if KARMABET_DEBUG then
			print( "[Karmabet] showWorstBetters table results:" ) 
			if list then
				PrintTable(list)
			else
				print( "Empty list!" )
			end
		end
	
		if not list or #list == 0 then
			ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 255, 0, 255 ), KARMABET_LANG.db_noentries )
			return
		end
		
		ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 255, 0, 255 ), KARMABET_LANG.worstbets_the, 
				Color( 255, 0, 0, 255 ), KARMABET_LANG.worstbets_worst,
				Color( 255, 255, 255, 255 ), #list .. " ",
				Color( 255, 255, 0, 255 ), KARMABET_LANG.worstbets_betters )
				
		for k, v in ipairs( list ) do
			ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 0, 0, 255 ), "#" .. k .. ": ",
				Color( 255, 255, 0, 255 ), v.name .. " ",
				Color( 255, 255, 255, 255 ), KARMABET_LANG.worstbets_with,
				Color( 255, 0, 0, 255 ), v.total .. " ",
				Color( 255, 255, 255, 255 ), KARMABET_LANG.general_karma_ex )
		end
	end
	
	function karmabet_insertIntoDatabase()
		--[[
		Database Structure:
		1: id
		2: bet_id
		3: steamid
		4: amount
		5: date
		INSERT INTO karmabet(`bet_id`, `name`, `steamid`, `amount`)	VALUES( bet_id, 'name', 'steamid', amount), ( bet_id .....);
		...
		]]--
		
		local data = sql.Query( "SELECT MAX(bet_id) + 1 as last_betid FROM karmabet WHERE 1 LIMIT 1" )
		
		if KARMABET_DEBUG then
			print("[Karmabet] last_betid table result:")
			if data then
				PrintTable(data)
			else
				print( "Empty list!" )
			end
		end 
		
		-- Set default bet_id to 1 if table is empty
		local bet_id = 1
		
		-- Extract latest bet_id from table
		if data[1].last_betid and data[1].last_betid ~= "NULL" then -- SQLite returns a string with "NULL" if no entires found
			bet_id = data[1].last_betid
		end
		
		if KARMABET_DEBUG then
			print( "[Karmabet] All betters table:" ) 
			PrintTable( karmabet_tbl_results )
		end
		
		sql.Begin()
		-- Go through the table of karmabet participants and construct the SQL-String
		for id, entry in pairs( karmabet_tbl_results ) do
		
			local ply = player.GetBySteamID( id )
			if ply then 
				local amount = entry[1]
				local target = entry[2]
				
				if target == karmabet_winner then
					sql.Query( "INSERT INTO karmabet (bet_id, name, steamid, amount) VALUES(" .. bet_id .. ", " .. sql.SQLStr( ply:Nick() ) .. ", " .. sql.SQLStr( id ) .. ", " .. amount .. ")" )
				else
					sql.Query( "INSERT INTO karmabet (bet_id, name, steamid, amount) VALUES(" .. bet_id .. ", " .. sql.SQLStr( ply:Nick() ) .. ", " .. sql.SQLStr( id ) .. ", " .. ( -1 * amount ) .. ")" )
				end
			end
		end
		
		sql.Commit()
		
	end 

end