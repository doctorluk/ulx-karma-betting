-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3

-- NOTE: To add client-side translations of the running bet display, you need to edit cl_karma_betting.lua aswell!

if GetConVar( "karmabet_language" ):GetString() ~= "english" then return end

KARMABET_LANG = {}

KARMABET_LANG.id = 1

KARMABET_LANG.general_karma = "Karma"
KARMABET_LANG.general_karma_ex = "Karma!"

KARMABET_LANG.echo_hidden = "[HIDDEN] "
KARMABET_LANG.echo_allin = ">ALL IN< "
KARMABET_LANG.echo_bets = " bets "
KARMABET_LANG.echo_karmaonteam = " Karma on the team "

KARMABET_LANG.cantbet_deadalive = "You can only bet when you're not alive!"
KARMABET_LANG.cantbet_activeround = "You can only bet during an active round!"
KARMABET_LANG.cantbet_timeup = "Time to bet has run out!"
KARMABET_LANG.cantbet_slowmo = "Can't bet during slowmotion! (Damn Cheater!)"
KARMABET_LANG.cantbet_wrongtarget = "Missing target team! Try entering T for Traitors or I for Innocents."
KARMABET_LANG.cantbet_notenoughkarma = "Your Karma is too low to vote!"
KARMABET_LANG.cantbet_notenoughremainingkarma = "Your remaining Karma is too low to vote!"
KARMABET_LANG.cantbet_lowkarma_1 = "Your Karma is low! You could only bet " -- + amount
KARMABET_LANG.cantbet_lowkarma_2 = " Karma!"
KARMABET_LANG.cantbet_allin = "You already went all-in. There's nothing you can do now!"
KARMABET_LANG.cantbet_wrongteam = "You can only increase your bets on the team for which you already bet!"
KARMABET_LANG.cantbet_maxbetwarn_1 = "You can't bet more than " -- + amount
KARMABET_LANG.cantbet_maxbetwarn_2 = " Karma!"

KARMABET_LANG.timer_timeleft = "20 seconds remaining to bet!"
KARMABET_LANG.timer_betsclosed = "Bets closed!"

KARMABET_LANG.roundend_wins = " wins "
KARMABET_LANG.roundend_loses = " loses "

KARMABET_LANG.db_noentries = "Sorry, no entries found!"

KARMABET_LANG.mybets_all = "ALL"
KARMABET_LANG.mybets_days = " days"
KARMABET_LANG.mybets_day = " day"
KARMABET_LANG.mybets_balance = "Your betting balance"

KARMABET_LANG.bestbets_the = "The "
KARMABET_LANG.bestbets_best = "best "
KARMABET_LANG.bestbets_betters = "Betheroes: "
KARMABET_LANG.bestbets_with = "with "

KARMABET_LANG.worstbets_the = "The "
KARMABET_LANG.worstbets_worst = "worst "
KARMABET_LANG.worstbets_betters = "Betnoobs: "
KARMABET_LANG.worstbets_with = "with "

KARMABET_LANG.ulx_syntax = "NUMBER between " .. GetConVar( "karmabet_min_karma" ):GetInt() .. " and " .. GetConVar( "karmabet_max_karma" ):GetInt() .. " OR 'all' (= " .. GetConVar( "karmabet_allin_karma" ):GetInt() .. ")"
KARMABET_LANG.ulx_cd_mybets = "This command was used recently. Please wait a moment and try again."
KARMABET_LANG.ulx_cd_bestbets = "This command was used recently. Please wait a moment and try again."
KARMABET_LANG.ulx_cd_worstbets = "This command was used recently. Please wait a moment and try again."

print( "[Karmabet] Loaded " .. table.Count(KARMABET_LANG) .. " language strings for language " .. GetConVar( "karmabet_language" ):GetString() )