# ULX Karma Betting

## What it is for
This plugin can be installed on Garry's Mod servers to enable betting of Karma while being dead or spectating.

## What it does
Players are able to bet their karma when they're dead or spectating. The living players are being updated live on the counters, but don't see who bet. They only see the total amount of bets placed. After 3 minutes (by default) the betting process ends. On round end the winners/losers are picked and the winners are rewarded while the losers lose all of the karma they bet.

## General Requirements (SQLite)
- The gamemode must be TTT (Trouble in Terrorist Town)
- ULX and ULIB: http://ulyssesmod.net/

### Additional Requirements when using MySQL
- mysqloo extention installed on the server for Garry's Mod (https://facepunch.com/showthread.php?t=1357773)
- A MySQL Server with Database access

## How to install
- Upload the folder betting into your addons folder (usually located at garrysmod\addons)

## How to configure
All configuration options can be found at betting\lua\autorun\sv_karma_betting_config.lua and each line has comments that describe the configuration options.
