-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3

-- If set to false it will use the SQLite database within the server's installation to store the progress
-- Set to true to use MySQL to save the karmabet progress
-- Requires the mysqloo addon for Windows/Linux for GMod
-- Refer to lua/autorun/server/sv_karma_betting_mysql.lua for configuration options
-- KARMABET_USE_MYSQL = false
CreateConVar( "karmabet_savemode", "none", FCVAR_ARCHIVE, "" )
CreateConVar( "karmabet_mysql_host", "none", FCVAR_ARCHIVE, "" )
CreateConVar( "karmabet_mysql_dbname", "none", FCVAR_ARCHIVE, "" )
CreateConVar( "karmabet_mysql_username", "none", FCVAR_ARCHIVE, "" )
CreateConVar( "karmabet_mysql_pw", "none", FCVAR_ARCHIVE, "" )
CreateConVar( "karmabet_mysql_port", "none", FCVAR_ARCHIVE, "" )

-- The language of the plugin
-- Possible settings: "english" or "german"
-- KARMABET_LANGUAGE = "english"
CreateConVar( "karmabet_language", "english", FCVAR_ARCHIVE, "" )

-- Configure the minimum amount of identified corpses to show the total amount of placed bets publicly
-- KARMABET_MINIMUM_IDENTIFIED_BODIES = 2
CreateConVar( "karmabet_min_identified_bodies", "2", FCVAR_ARCHIVE, "" )

-- Minimum amount of karma to bet
-- KARMABET_MINIMUM_KARMA = 10
CreateConVar( "karmabet_min_karma", "10", FCVAR_ARCHIVE, "" )

-- Maximum amount of karma to bet
-- KARMABET_MAXIMUM_KARMA = 200
CreateConVar( "karmabet_max_karma", "200", FCVAR_ARCHIVE, "" )

-- Amount of Karma being bet when choosing "all" as argument
-- KARMABET_AMOUNT_ALL = 350
CreateConVar( "karmabet_allin_karma", "350", FCVAR_ARCHIVE, "" )

-- Minimum karma of a player to have to bet (bets exceeding their karma will be lowered to this minimum here)
-- KARMABET_MINIMUM_LIVE_KARMA = 600
CreateConVar( "karmabet_min_live_karma", "600", FCVAR_ARCHIVE, "" )

-- Time to bet once a round has started
-- KARMABET_BET_TIME = 180
CreateConVar( "karmabet_bet_time", "180", FCVAR_ARCHIVE, "" )

-- Cooldown time in seconds for the !mybets command (Prevents database spam)
-- KARMABET_MYBETS_COOLDOWN = 5
CreateConVar( "karmabet_mybets_cooldown", "5", FCVAR_ARCHIVE, "" )

-- Cooldown time in seconds for the public !bestbets command (Prevents database/chat spam)
-- KARMABET_BESTBETS_COOLDOWN = 180
CreateConVar( "karmabet_bestbets_cooldown", "180", FCVAR_ARCHIVE, "" )

-- Cooldown time in seconds for the public !worstbets command (Prevents database/chat spam)
-- KARMABET_WORSTBETS_COOLDOWN = 180
CreateConVar( "karmabet_worstbets_cooldown", "180", FCVAR_ARCHIVE, "" )

-- Print debug messages to console?
-- KARMABET_DEBUG = false
CreateConVar( "karmabet_debug", "0", FCVAR_ARCHIVE, "" )
