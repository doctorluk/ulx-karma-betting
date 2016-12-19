-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3

-- NOTE: To add client-side translations of the running bet display, you need to edit cl_karma_betting.lua aswell!

if GetConVar( "karmabet_language" ):GetString() ~= "german" then return end

KARMABET_LANG = {}

KARMABET_LANG.id = 2

KARMABET_LANG.general_karma = "Karma"
KARMABET_LANG.general_karma_ex = "Karma!"

KARMABET_LANG.echo_hidden = "[VERSTECKT] "
KARMABET_LANG.echo_allin = ">ALL IN< "
KARMABET_LANG.echo_bets = " wettet "
KARMABET_LANG.echo_karmaonteam = " Karma auf das Team "

KARMABET_LANG.cantbet_deadalive = "Du kannst nur wetten, wenn du nicht lebst!"
KARMABET_LANG.cantbet_activeround = "Man kann nur während einer aktiven Runde wetten!"
KARMABET_LANG.cantbet_timeup = "Zeit zum Wetten ist abgelaufen!"
KARMABET_LANG.cantbet_slowmo = "Kann nicht während der Zeitlupe wetten! (Du Cheater!)"
KARMABET_LANG.cantbet_wrongtarget = "Du hast kein Ziel eingegeben! Versuche T oder I für Traitor oder Innocent."
KARMABET_LANG.cantbet_notenoughkarma = "Dein Karma ist zu gering um zu wetten!"
KARMABET_LANG.cantbet_notenoughremainingkarma = "Dein verbleibendes Karma ist zu gering um zu wetten!"
KARMABET_LANG.cantbet_lowkarma_1 = "Dein Karma ist low! Es konnte nur " -- + amount
KARMABET_LANG.cantbet_lowkarma_2 = " Karma gesetzt werden!"
KARMABET_LANG.cantbet_allin = "Du bist all-in gegangen. Jetzt kannst du nur noch warten!"
KARMABET_LANG.cantbet_wrongteam = "Du kannst nur dem gleichen Team mehr wetten und nicht mehr wechseln!"
KARMABET_LANG.cantbet_maxbetwarn_1 = "Du kannst nicht mehr als " -- + amount
KARMABET_LANG.cantbet_maxbetwarn_2 = " wetten!"

KARMABET_LANG.timer_timeleft = "Noch 20 Sekunden um zu wetten!"
KARMABET_LANG.timer_betsclosed = "Wetten geschlossen!"

KARMABET_LANG.roundend_wins = " gewinnt "
KARMABET_LANG.roundend_loses = " verliert "

KARMABET_LANG.db_noentries = "Leider keine Einträge gefunden!"

KARMABET_LANG.mybets_all = "ALLE"
KARMABET_LANG.mybets_days = " Tage"
KARMABET_LANG.mybets_day = " Tag"
KARMABET_LANG.mybets_balance = "Deine Wettbalance"

KARMABET_LANG.bestbets_the = "Die "
KARMABET_LANG.bestbets_best = "besten "
KARMABET_LANG.bestbets_betters = "Wetthelden: "
KARMABET_LANG.bestbets_with = "mit "

KARMABET_LANG.worstbets_the = "Die "
KARMABET_LANG.worstbets_worst = "schlechtesten "
KARMABET_LANG.worstbets_betters = "Wettnoobs: "
KARMABET_LANG.worstbets_with = "mit "

KARMABET_LANG.ulx_syntax = "Zahl zwischen " .. GetConVar( "karmabet_min_karma" ):GetInt() .. " und " .. GetConVar( "karmabet_max_karma" ):GetInt() .. " ODER 'all' (= " .. GetConVar( "karmabet_allin_karma" ):GetInt() .. ")"
KARMABET_LANG.ulx_cd_mybets = "Dieser Befehl wurde gerade erst ausgeführt! Bitte warte einen Moment und versuche es erneut."
KARMABET_LANG.ulx_cd_bestbets = "Dieser Befehl wurde gerade erst ausgeführt! Bitte warte einen Moment und versuche es erneut."
KARMABET_LANG.ulx_cd_worstbets = "Dieser Befehl wurde gerade erst ausgeführt! Bitte warte einen Moment und versuche es erneut."

print( "[Karmabet] Loaded " .. table.Count(KARMABET_LANG) .. " language strings for language " .. GetConVar( "karmabet_language" ):GetString() )