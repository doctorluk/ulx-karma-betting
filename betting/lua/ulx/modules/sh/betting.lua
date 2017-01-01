-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/

ulx.bestbetsLastRun = 0
ulx.worstbetsLastRun = 0
ulx.mybetsLastRun = 0

local CATEGORY = "Karma Betting"

function ulx.startkarmabet( calling_ply, target, amount )

	local target = target
	local amount = amount
	
	local all = false

	-- Checking for DERMA Call
	if target == "" and amount == "" then
	
		if not karmabet_getRoundCondition( calling_ply ) then return end
		
		net.Start( "karmabet_betgui" )
		net.WriteInt( GetConVar( "karmabet_min_karma" ):GetInt(), 32 )
		net.WriteInt( GetConVar( "karmabet_max_karma" ):GetInt(), 32 )
		net.WriteInt( GetConVar( "karmabet_allin_karma" ):GetInt(), 32 )
		net.WriteInt( KARMABET_LANG.id, 8 )
		net.WriteString( karmabet_getRunningBetTeam( calling_ply ) )
		net.Send( calling_ply )
		return
	end
	
	-- Make sure order of arguments does not matter
	if ( isstring(amount) and isnumber(tonumber(target)) ) or ( isstring(target) and target == "all" ) then
		local tmp_target = target
		target = amount
		amount = tmp_target
	end
	
	-- Check amount syntax
	-- NUMBER CHECK
	if isnumber( tonumber( amount ) ) then
		amount = math.floor( tonumber( amount ) )
		
		if amount < GetConVar( "karmabet_min_karma" ):GetInt() or amount > GetConVar( "karmabet_max_karma" ):GetInt() then
			karmabet_reportError( calling_ply, KARMABET_LANG.ulx_syntax )
			return false
		end
	
	-- 'all' CHECK
	elseif string.lower( amount ) == "all" then
		amount = GetConVar( "karmabet_allin_karma" ):GetInt()
		all = true
	else
		karmabet_reportError( calling_ply, KARMABET_LANG.ulx_syntax )
		return false
	end

	karmabet_canBet( calling_ply, amount, target, all )
	
end
local startkarmabet = ulx.command( CATEGORY, "ulx startkarmabet", ulx.startkarmabet, "!bet" )
startkarmabet:addParam{ type=ULib.cmds.StringArg, hint="'Traitor' or 'Innocent'", ULib.cmds.optional }
startkarmabet:addParam{ type=ULib.cmds.StringArg, hint=KARMABET_LANG.ulx_syntax, ULib.cmds.optional }
startkarmabet:defaultAccess( ULib.ACCESS_ALL )
startkarmabet:help( "Starts a Karma bet." )


function ulx.mybets( calling_ply, duration )

	if not calling_ply then return false end
	
	if ulx.mybetsLastRun + GetConVar( "karmabet_mybets_cooldown" ):GetInt() > os.time() then
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

	if ulx.bestbetsLastRun + GetConVar( "karmabet_bestbets_cooldown" ):GetInt() > os.time() then
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

	if ulx.worstbetsLastRun + GetConVar( "karmabet_worstbets_cooldown" ):GetInt() > os.time() then
		karmabet_reportError( calling_ply, KARMABET_LANG.ulx_cd_worstbets )
		return
	end
	ulx.worstbetsLastRun = os.time()
	
	karmabet_showWorstBetters()
	
end
local worstbets = ulx.command( CATEGORY, "ulx worstbets", ulx.worstbets, "!worstbets" )
worstbets:defaultAccess( ULib.ACCESS_ALL )
worstbets:help( "Shows worst betters of last 7 days." )