-- Made by Luk
-- http://steamcommunity.com/id/doctorluk/
-- Version: 1.3

-- If set to false it will use the SQLite database within the server's installation to store the progress
-- Set to true to use MySQL to save the karmabet progress
-- Requires the mysqloo addon for Windows/Linux for GMod
-- Refer to lua/autorun/server/sv_karma_betting_mysql.lua for configuration options
KARMABET_USE_MYSQL = false

-- The language of the plugin
-- Possible settings: "english" or "german"
KARMABET_LANGUAGE = "english"

-- Configure the minimum amount of identified corpses to show the total amount of placed bets publicly
KARMABET_MINIMUM_IDENTIFIED_BODIES = 2

-- Minimum amount of karma to bet
KARMABET_MINIMUM_KARMA = 10

-- Maximum amount of karma to bet
KARMABET_MAXIMUM_KARMA = 200

-- Amount of Karma being bet when choosing "all" as argument
-- TODO: IMPLEMENTATION PENDING
KARMABET_AMOUNT_ALL = 350

-- Minimum karma of a player to have to bet (bets exceeding their karma will be lowered to this minimum here)
KARMABET_MINIMUM_LIVE_KARMA = 600

-- Time to bet once a round has started
KARMABET_BET_TIME = 180

-- Cooldown time in seconds for the !mybets command (Prevents database spam)
KARMABET_MYBETS_COOLDOWN = 5

-- Cooldown time in seconds for the public !bestbets command (Prevents database/chat spam)
KARMABET_BESTBETS_COOLDOWN = 180

-- Cooldown time in seconds for the public !worstbets command (Prevents database/chat spam)
KARMABET_WORSTBETS_COOLDOWN = 180

-- Print debug messages to console?
KARMABET_DEBUG = false
