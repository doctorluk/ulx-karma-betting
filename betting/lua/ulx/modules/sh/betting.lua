-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.2

ulx.bestbetsLastRun = 0
ulx.worstbetsLastRun = 0
ulx.mybetsLastRun = 0

local CATEGORY = "Karma Betting"

function ulx.startkarmabet( calling_ply, target, amount )

	karmabet_canBet( calling_ply, math.floor(amount), target )
	
end
local startkarmabet = ulx.command( CATEGORY, "ulx startkarmabet", ulx.startkarmabet, "!bet" )
startkarmabet:addParam{ type=ULib.cmds.StringArg, hint="'Traitor' or 'Innocent'" }
startkarmabet:addParam{ type=ULib.cmds.NumArg, hint="Amount, between " .. KARMABET_MINIMUM_KARMA .. " and " .. KARMABET_MAXIMUM_KARMA, min=KARMABET_MINIMUM_KARMA, max=KARMABET_MAXIMUM_KARMA }
startkarmabet:defaultAccess( ULib.ACCESS_ALL )
startkarmabet:help( "Starts a Karma bet." )


function ulx.mybets( calling_ply, duration )

	if not calling_ply then return false end
	
	if ulx.mybetsLastRun + KARMABET_MYBETS_COOLDOWN > os.time() then
		karmabet_reportError( calling_ply, KARMABET_LANG.ulx_cd_mybets )
		return
	end
	ulx.mybetsLastRun = os.time()
	
	karmabet_showMyBetSummary( calling_ply, calling_ply:SteamID(), duration )
	
end
local mybets = ulx.command( CATEGORY, "ulx mybets", ulx.mybets, "!mybets" )
mybets:addParam{ type=ULib.cmds.StringArg, hint="'all' or 1-31", ULib.cmds.optional }
mybets:defaultAccess( ULib.ACCESS_ALL )
mybets:help( "Shows your total bets." )


function ulx.bestbets( calling_ply )

	if ulx.bestbetsLastRun + KARMABET_BESTBETS_COOLDOWN > os.time() then
		karmabet_reportError( calling_ply, KARMABET_LANG.ulx_cd_bestbets )
		return
	end
	ulx.bestbetsLastRun = os.time()
	
	karmabet_showBestBetters()
	
end
local bestbets = ulx.command( CATEGORY, "ulx bestbets", ulx.bestbets, "!bestbets" )
bestbets:defaultAccess( ULib.ACCESS_ALL )
bestbets:help( "Shows best betters of last 7 days." )

function ulx.worstbets( calling_ply )

	if ulx.worstbetsLastRun + KARMABET_WORSTBETS_COOLDOWN > os.time() then
		karmabet_reportError( calling_ply, KARMABET_LANG.ulx_cd_worstbets )
		return
	end
	ulx.worstbetsLastRun = os.time()
	
	karmabet_showWorstBetters()
	
end
local worstbets = ulx.command( CATEGORY, "ulx worstbets", ulx.worstbets, "!worstbets" )
worstbets:defaultAccess( ULib.ACCESS_ALL )
worstbets:help( "Shows worst betters of last 7 days." )