-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/

--[[

	SERVER CONFIG SETTINGS

]]
-- Saving settings
CreateConVar( "karmabet_savemode", "sqlite", {FCVAR_DONTRECORD}, "" )
CreateConVar( "karmabet_mysql_host", "none", {FCVAR_DONTRECORD, FCVAR_PROTECTED}, "" )
CreateConVar( "karmabet_mysql_dbname", "none", {FCVAR_DONTRECORD, FCVAR_PROTECTED}, "" )
CreateConVar( "karmabet_mysql_username", "none", {FCVAR_DONTRECORD, FCVAR_PROTECTED}, "" )
CreateConVar( "karmabet_mysql_pw", "none", {FCVAR_DONTRECORD, FCVAR_PROTECTED}, "" )
CreateConVar( "karmabet_mysql_port", "none", {FCVAR_DONTRECORD, FCVAR_PROTECTED}, "" )

-- The language of the plugin
CreateConVar( "karmabet_language", "english", {FCVAR_DONTRECORD}, "" )

-- Configure the minimum amount of identified corpses to show the total amount of placed bets publicly
CreateConVar( "karmabet_min_identified_bodies", "2", {FCVAR_DONTRECORD}, "" )

-- Minimum amount of karma to bet
CreateConVar( "karmabet_min_karma", "10", {FCVAR_DONTRECORD}, "" )

-- Maximum amount of karma to bet
CreateConVar( "karmabet_max_karma", "200", {FCVAR_DONTRECORD}, "" )

-- Amount of Karma being bet when choosing "all" as argument
CreateConVar( "karmabet_allin_karma", "350", {FCVAR_DONTRECORD}, "" )

-- Minimum karma of a player to have to bet (bets that would reduce their karma below this point are adjusted to hit this amount upon losing) 
CreateConVar( "karmabet_min_live_karma", "600", {FCVAR_DONTRECORD}, "" )

-- Time to bet once a round has started
CreateConVar( "karmabet_bet_time", "180", {FCVAR_DONTRECORD}, "" )

-- Cooldown time in seconds for the !mybets command (Prevents database spam)
CreateConVar( "karmabet_mybets_cooldown", "5", {FCVAR_DONTRECORD}, "" )

-- Cooldown time in seconds for the public !bestbets command (Prevents database/chat spam)
CreateConVar( "karmabet_bestbets_cooldown", "180", {FCVAR_DONTRECORD}, "" )

-- Cooldown time in seconds for the public !worstbets command (Prevents database/chat spam)
CreateConVar( "karmabet_worstbets_cooldown", "180", {FCVAR_DONTRECORD}, "" )

-- Print debug messages to console
CreateConVar( "karmabet_debug", "0", {FCVAR_DONTRECORD}, "" )

--[[

	OTHER STATIC CONFIGS

]]
-- List of valid languages within the addon
KARMABET_VALID_LANGUAGES = { english = true, german = true }
KARMABET_LANG = {}