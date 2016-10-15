-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.1

ulx.showbestbettersLastRun = 0
ulx.showworstbettersLastRun = 0
ulx.showmybetsummaryLastRun = 0

local CATEGORY = "Karma Betting"

function ulx.startkarmabet( calling_ply, amount, target )
	if karmabet_canBet( calling_ply, math.floor(amount), target ) then
		-- ulx.fancyLogAdmin( calling_ply, "#A started betting #i Karma in favor of " .. target, amount )
	end
end
local startkarmabet = ulx.command( CATEGORY, "ulx startkarmabet", ulx.startkarmabet, "!bet" )
startkarmabet:addParam{ type=ULib.cmds.NumArg, hint="Menge, zwischen " .. KARMABET_MINIMUM_KARMA .. " und " .. KARMABET_MAXIMUM_KARMA, min=KARMABET_MINIMUM_KARMA, max=KARMABET_MAXIMUM_KARMA }
startkarmabet:addParam{ type=ULib.cmds.StringArg, hint="'Traitor' oder 'Innocent'" }
startkarmabet:defaultAccess( ULib.ACCESS_ALL )
startkarmabet:help( "Starts a Karma bet." )


function ulx.showmybetsummary( calling_ply )
	if not calling_ply then return false end
	
	if ulx.showmybetsummaryLastRun + 5 > os.time() then
		karmabet_reportError( calling_ply, "Dieser Befehl wurde gerade erst ausgeführt! Versuche es in 5 Sekunden erneut.")
		return
	end
	ulx.showmybetsummaryLastRun = os.time()
	
	karmabet_showMyBetSummary( calling_ply, calling_ply:SteamID() )
end
local showmybetsummary = ulx.command( CATEGORY, "ulx showmybetsummary", ulx.showmybetsummary, "!mybets" )
showmybetsummary:defaultAccess( ULib.ACCESS_ALL )
showmybetsummary:help( "Shows your total bets." )


function ulx.showbestbetters( calling_ply )

	if ulx.showbestbettersLastRun + 180 > os.time() then
		karmabet_reportError( calling_ply, "Warte, bis du den Befehl wieder ausführst!")
		return
	end
	ulx.showbestbettersLastRun = os.time()
	
	karmabet_showBestBetters()
end
local showbestbetters = ulx.command( CATEGORY, "ulx showbestbetters", ulx.showbestbetters, "!bestbets" )
showbestbetters:defaultAccess( ULib.ACCESS_ALL )
showbestbetters:help( "Shows best betters of last 7 days." )

function ulx.showworstbetters( calling_ply )

	if ulx.showworstbettersLastRun + 180 > os.time() then
		karmabet_reportError( calling_ply, "Warte, bis du den Befehl wieder ausführst!")
		return
	end
	ulx.showworstbettersLastRun = os.time()
	
	karmabet_showWorstBetters()
end
local showworstbetters = ulx.command( CATEGORY, "ulx showworstbetters", ulx.showworstbetters, "!worstbets" )
showworstbetters:defaultAccess( ULib.ACCESS_ALL )
showworstbetters:help( "Shows worst betters of last 7 days." )