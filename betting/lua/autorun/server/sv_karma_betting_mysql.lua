-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/

if SERVER then

	require( "mysqloo" )
	local db
	local queue = {}

	hook.Add( "Think", "karmabet_mysql", function ()
		-- This function runs when the server is fully loaded
		-- All cvars have been read and are available within this function

		hook.Remove( "Think", "karmabet_mysql" ) -- Only run this callback once

		-- We can now make sure save mode has been set to "mysql"
		if string.lower( GetConVar( "karmabet_savemode" ):GetString() ) ~= "mysql" then
			return -- Stop! Save mode is not mysql...
		end

		-- Read all ConVars from server.cfg
		local DATABASE_HOST = GetConVar( "karmabet_mysql_host" ):GetString()
		local DATABASE_NAME = GetConVar( "karmabet_mysql_dbname" ):GetString()
		local DATABASE_USERNAME = GetConVar( "karmabet_mysql_username" ):GetString()
		local DATABASE_PASSWORD = GetConVar( "karmabet_mysql_pw" ):GetString()
		local DATABASE_PORT = GetConVar( "karmabet_mysql_port" ):GetInt()
		
		-- Check if MySQL config vars are set in server.cfg and/or command line
		if 
		DATABASE_HOST == GetConVar( "karmabet_mysql_host" ):GetDefault()
		or 
		DATABASE_NAME == GetConVar( "karmabet_mysql_dbname" ):GetDefault()
		or 
		DATABASE_USERNAME == GetConVar( "karmabet_mysql_username" ):GetDefault()
		or 
		DATABASE_PASSWORD == GetConVar( "karmabet_mysql_pw" ):GetDefault()
		then
			print("[Karmabet][ERROR] Your MySQL Database Settings are missing!")
			print("[Karmabet][ERROR] Your MySQL Database Settings are missing!")
			print("[Karmabet][ERROR] Your MySQL Database Settings are missing!")
			print("[Karmabet][ERROR] Loading SQLite Module instead!")
			hook.Call( "karmabet_loadsqlite" ) -- Fall back to SQLite
			return
		end

		-- Send text to console to know we're inside here
		print("[Karmabet] MySQL Module has been loaded. Waiting for players connecting/playing to initiate MySQL connection...")

		-- initialize the database
		db = mysqloo.connect( DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_NAME, DATABASE_PORT )

		-- Define hooks
		function db:onConnectionFailed( err )
			print( "[Karmabet] Database connection failed: " .. err )
		end

		function db:onConnected()
			print( "[Karmabet] Connected to MySQL." )
		end

		-- Finally connect to the database
		db:connect()
		
		local function query( str, callback )
			if not db then return end
			local q = db:query( str )
			
			function q:onSuccess( data )
				if callback ~= nil then
					callback( data )
				end
			end
			
			function q:onError( err )
				if db:status() == mysqloo.DATABASE_NOT_CONNECTED then
					table.insert( queue, { str, callback } )
					db:connect()
				return end
				
				print( "[Karmabet] Error! Query failed: " .. err )
			end
			
			q:start()
		end			

		-- Shows the player's sum of all bets he placed
		function karmabet_showMyBetSummary( ply, steamid, duration )
		
			-- Set the duration between 1-31 days or all-time
			local duration = tonumber( duration ) or "all"
			if isnumber( duration ) then
				duration = math.Clamp( duration, 1, 31 ) -- Limit lookbacks between 1 and 31
			end
			
			local querystring = ""
			
			-- Construct query string depending on the duration
			if ( duration == "all" ) then
				querystring = "SELECT sum(amount) as total FROM `karmabet` WHERE steamid = '" .. db:escape(steamid) .. "' LIMIT 1"
			else
				querystring = "SELECT sum(amount) as total FROM `karmabet` WHERE date >= DATE_SUB(NOW(), INTERVAL " .. tonumber(duration) .. " DAY) AND steamid = '" .. db:escape(steamid) .. "' LIMIT 1"
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
			
			-- Send the query to MySQL and act on the response
			query( querystring, function( list )
				
				if GetConVar( "karmabet_debug" ):GetBool() then
					print( "[Karmabet] showMyBetSummary table results:" ) 
					PrintTable(list)
				end
				
				for k, v in ipairs( list ) do
					-- Result is empty
					if #list == 0 or not tonumber( v.total ) then
						ULib.tsayColor( ply, true,
							Color( 50, 50, 50, 255 ), "[", 
							Color( 190, 40, 40, 255 ), "Karmabet",
							Color( 50, 50, 50, 255 ), "] ",
							Color( 255, 255, 0, 255 ), KARMABET_LANG.db_noentries )
						return
					end
					
					-- Positive karma first, then negative karma
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
			end)
		end
		
		-- Shows the five highest entries in the database
		function karmabet_showBestBetters( duration )
			query( "SELECT name, sum(amount) as total FROM `karmabet` WHERE date >= DATE_SUB(NOW(), INTERVAL 7 DAY) GROUP BY steamid HAVING sum(amount) > 0 ORDER BY total DESC LIMIT 5", function( list )
				
				if GetConVar( "karmabet_debug" ):GetBool() then
					print( "[Karmabet] showBestBetters table results:" ) 
					PrintTable(list)
				end
				
				-- Empty list
				if #list == 0 then
					ULib.tsayColor( nil, true,
						Color( 50, 50, 50, 255 ), "[", 
						Color( 190, 40, 40, 255 ), "Karmabet",
						Color( 50, 50, 50, 255 ), "] ",
						Color( 255, 255, 0, 255 ), KARMABET_LANG.db_noentries )
					return
				end
				
				-- First text saying "These are the x best betters:"
				ULib.tsayColor( nil, true,
						Color( 50, 50, 50, 255 ), "[", 
						Color( 190, 40, 40, 255 ), "Karmabet",
						Color( 50, 50, 50, 255 ), "] ",
						Color( 255, 255, 0, 255 ), KARMABET_LANG.bestbets_the, 
						Color( 0, 255, 0, 255 ), KARMABET_LANG.bestbets_best,
						Color( 255, 255, 255, 255 ), #list .. " ",
						Color( 255, 255, 0, 255 ), KARMABET_LANG.bestbets_betters )
				-- followed by a list of the players found in the db
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
			end)
		end
		
		-- Shows the five lowest entries in the database
		function karmabet_showWorstBetters( duration )
			query( "SELECT name, sum(amount) as total FROM `karmabet` WHERE date >= DATE_SUB(NOW(), INTERVAL 7 DAY) GROUP BY steamid HAVING sum(amount) < 0 ORDER BY total ASC LIMIT 5", function( list )
				
				if GetConVar( "karmabet_debug" ):GetBool() then
					print( "[Karmabet] showWorstBetters table results:" ) 
					PrintTable(list)
				end
				
				-- List is empty
				if #list == 0 then
					ULib.tsayColor( nil, true,
						Color( 50, 50, 50, 255 ), "[", 
						Color( 190, 40, 40, 255 ), "Karmabet",
						Color( 50, 50, 50, 255 ), "] ",
						Color( 255, 255, 0, 255 ), KARMABET_LANG.db_noentries )
					return
				end
				
				-- First text saying "These are the x worst betters:"
				ULib.tsayColor( nil, true,
						Color( 50, 50, 50, 255 ), "[", 
						Color( 190, 40, 40, 255 ), "Karmabet",
						Color( 50, 50, 50, 255 ), "] ",
						Color( 255, 255, 0, 255 ), KARMABET_LANG.worstbets_the, 
						Color( 255, 0, 0, 255 ), KARMABET_LANG.worstbets_worst,
						Color( 255, 255, 255, 255 ), #list .. " ",
						Color( 255, 255, 0, 255 ), KARMABET_LANG.worstbets_betters )
				-- followed by a list of the players found in the db	
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
			end)
		end
		
		function karmabet_insertIntoDatabase()
			--[[
			Database Structure:
			1: id
			2: bet_id
			3: steamid
			4: amount
			5: date
			INSERT INTO karmabet(`bet_id`, `name`, `steamid`, `amount`)	VALUES( bet_id, 'name', 'steamid', amount), ( bet_id, ...);
			...
			]]--
			
			query( "SELECT MAX(bet_id) + 1 as last_betid FROM karmabet WHERE 1 LIMIT 1", function( data )
				
				if GetConVar( "karmabet_debug" ):GetBool() then
					PrintTable(data) 
				end				
				-- Set default bet_id to 1 if table is empty
				local bet_id = 1
				
				-- Extract latest bet_id from table
				if data[1].last_betid then
					bet_id = data[1].last_betid
				end
				
				local loops = 0
				local querystr = "INSERT INTO `" .. DATABASE_NAME .. "`.`karmabet` (`bet_id`, `name`, `steamid`, `amount`) VALUES("
				
				PrintTable( karmabet_tbl_results )
				-- Go through the table of karmabet participants and construct the SQL-String
				for id, entry in pairs( karmabet_tbl_results ) do
				
					local ply = player.GetBySteamID( id )
					if ply then 
						local amount = entry[1]
						local target = entry[2]
						
						if loops > 0 then
							querystr = querystr .. ", ("
						end
							
						if target == karmabet_winner then
							querystr = querystr
							.. bet_id .. ", '" 
							.. db:escape( ply:Nick() ) .. "', '" 
							.. db:escape( id ) .. "', " 
							.. amount .. ")"
						else
							querystr = querystr
							.. bet_id .. ", '" 
							.. db:escape( ply:Nick() ) .. "', '" 
							.. db:escape( id ) .. "', " 
							.. (-1 * amount) .. ")"
						end
						
						loops = loops + 1
					end
				end
				
				if loops == 0 then return end
				
				querystr = querystr .. ";"
				query( querystr )
				
				if GetConVar( "karmabet_debug" ):GetBool() then
					ServerLog("[Karmabet] Query String: " .. querystr .. "\n")
				end
			end )
		end 
	end)
end