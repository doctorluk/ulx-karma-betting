-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.0
if SERVER then
	
	if KARMABET_USE_MYSQL then return end

	print( "[Karmabet] Using SQLite." )
	
	
	local query_success = nil
	
	query_success = sql.Query( "CREATE TABLE IF NOT EXISTS karmabet (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, bet_id INTEGER NOT NULL, name TEXT, steamid TEXT, amount INTEGER, date DATETIME DEFAULT CURRENT_TIMESTAMP)" )
	
	if query_success == false then
		print( "[Karmabet] Error creating SQLite table!" )
	end
	
	-- Shows the five highest entries in the database
	function karmabet_showMyBetSummary( ply, steamid )
		local list = sql.Query( "SELECT sum(amount) as total FROM `karmabet` WHERE steamid = " .. sql.SQLStr(steamid) .. " LIMIT 1" )
		
		print( "[Karmabet] showMyBetSummary table results:" ) 
		PrintTable(list)
				
		for k, v in ipairs( list ) do
			if #list == 0 or not tonumber(v.total) then
				ULib.tsayColor( ply, true,
					Color( 50, 50, 50, 255 ), "[", 
					Color( 190, 40, 40, 255 ), "Karmabet",
					Color( 50, 50, 50, 255 ), "] ",
					Color( 255, 255, 0, 255 ), "Leider keine Einträge gefunden!" )
				return
			end
			
			if tonumber(v.total) >= 0 then
				ULib.tsayColor( ply, true,
					Color( 50, 50, 50, 255 ), "[", 
					Color( 190, 40, 40, 255 ), "Karmabet",
					Color( 50, 50, 50, 255 ), "] ",
					Color( 255, 255, 255, 255 ), "Deine Wettbalance: ",
					Color( 0, 255, 0, 255 ), v.total .. " ",
					Color( 255, 255, 255, 255 ), "Karma!" )
			else
				ULib.tsayColor( ply, true,
					Color( 50, 50, 50, 255 ), "[", 
					Color( 190, 40, 40, 255 ), "Karmabet",
					Color( 50, 50, 50, 255 ), "] ",
					Color( 255, 255, 255, 255 ), "Deine Wettbalance: ",
					Color( 255, 0, 0, 255 ), v.total .. " ",
					Color( 255, 255, 255, 255 ), "Karma!" )
			end
		end
	end
	
	-- Shows the five highest entries in the database
	function karmabet_showBestBetters( duration )
		local list = sql.Query( "SELECT name, sum(amount) as total FROM `karmabet` WHERE date > (SELECT DATETIME('now', '-7 day')) GROUP BY steamid HAVING sum(amount) > 0 ORDER BY total DESC LIMIT 5" )
		
		print( "[Karmabet] showBestBetters table results:" ) 
		PrintTable(list)
	
		if #list == 0 then
			ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 255, 0, 255 ), "Leider keine Einträge gefunden!" )
			return
		end
		
		ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 255, 0, 255 ), "Die ", 
				Color( 0, 255, 0, 255 ), "besten ",
				Color( 255, 255, 255, 255 ), #list .. " ",
				Color( 255, 255, 0, 255 ), "Wetthelden: " )
				
		for k, v in ipairs( list ) do
			ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 0, 255, 0, 255 ), "#" .. k .. ": ",
				Color( 255, 255, 0, 255 ), v.name .. " ",
				Color( 255, 255, 255, 255 ), "mit ",
				Color( 0, 255, 0, 255 ), v.total .. " ",
				Color( 255, 255, 255, 255 ), "Karma!" )
		end
	end
	
	function karmabet_showWorstBetters( duration )
		local list = sql.Query( "SELECT name, sum(amount) as total FROM `karmabet` WHERE date > (SELECT DATETIME('now', '-7 day')) GROUP BY steamid HAVING sum(amount) < 0 ORDER BY total DESC LIMIT 5" )
			
		print( "[Karmabet] showWorstBetters table results:" ) 
		PrintTable(list)
	
		if #list == 0 then
			ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 255, 0, 255 ), "Leider keine Einträge gefunden!" )
			return
		end
		
		ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 255, 0, 255 ), "Die ", 
				Color( 255, 0, 0, 255 ), "schlechtesten ",
				Color( 255, 255, 255, 255 ), #list .. " ",
				Color( 255, 255, 0, 255 ), "Wettnoobs: " )
				
		for k, v in ipairs( list ) do
			ULib.tsayColor( nil, true,
				Color( 50, 50, 50, 255 ), "[", 
				Color( 190, 40, 40, 255 ), "Karmabet",
				Color( 50, 50, 50, 255 ), "] ",
				Color( 255, 0, 0, 255 ), "#" .. k .. ": ",
				Color( 255, 255, 0, 255 ), v.name .. " ",
				Color( 255, 255, 255, 255 ), "mit ",
				Color( 255, 0, 0, 255 ), v.total .. " ",
				Color( 255, 255, 255, 255 ), "Karma!" )
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
	
		print("[Karmabet] last_betid table result:") 
		PrintTable(data) 
		
		-- Set default bet_id to 1 if table is empty
		local bet_id = 1
		
		-- Extract latest bet_id from table
		if data[1].last_betid and data[1].last_betid ~= "NULL" then -- SQLite returns a string with "NULL" if no entires found
			bet_id = data[1].last_betid
		end
		
		print( "[Karmabet] All betters table:" ) 
		PrintTable( karmabet_tbl_results )
		
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