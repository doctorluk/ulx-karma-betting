# Karma Betting for Trouble in Terrorist Town
## Bet your karma on a team, similar to betting money in Counter-Strike!

### FEATURES / DESCRIPTION
This addon for TTT enables those who have been killed to place their karma on a certain team, be it Innocent or Traitor.  
Imagine you're playing with 10 players and most of them are dead, but you as the only innocent player left don't know. You see the bets increase on the right side, but for the enemy team. You picture yourself winning the round so all the other players who bet against you will lose their karma. Ain't that some sweet _karma_ for them? _Tehe..._

Usage of the MySQL capability of this plugin enables webhosts e.g. to implement the Bet-King into their MOTD to provide their players with additional imaginary fame.

### COMMAND LIST
**!bet** - Opens up a small window in which you can select the team and the amount of karma you want to bet.

**!bet \<team> \<amount>** - Places a bet on \<team> with \<amount>
- _**team**_ → Either "innocent", "inno" or "i" for the INNOCENT team, or "traitor" or "t" for the TRAITOR team
- _**amount**_ → An amount between karmabet_min_karma and karmabet_max_karma or "all" (amount = karmabet_allin_karma)

**!mybets \[\<days>]** - Displays your net amount of won/lost karma by betting (defaults to 7 days)
- _**days**_ (optional) → Number between 1 and 31 defining the "lookback" time

**!bestbets** - Publicly prints the 5 highest betting players of the last 7 days

**!worstbets** - Publicly prints the 5 worst betting players of the last 7 days (total karma below 0)

### REQUIREMENTS
ULX: https://steamcommunity.com/workshop/filedetails/?id=557962280  
ULib: https://steamcommunity.com/workshop/filedetails/?id=557962238  
(These do **not** have to be installed via Workshop. Manual installations also work)

If you intend to use the MySQL feature you'll need the [mysqloo](https://facepunch.com/showthread.php?t=1357773) Module to be installed. By default it will use SQLite which works just fine.

### INSTALLATION
**Installing via Steam Workshop**  
1. Go to http://steamcommunity.com/sharedfiles/filedetails/?id=822165242 and add the addon to you server's workshop collection  
2. Done

**Installing manually (no automatic updates!)**  
1. [Download](https://github.com/doctorluk/ulx-karma-betting/archive/master.zip) the package  
2. Extract it  
3. Upload the folder *betting* to your garrysmod/addons/ folder  
4. Done

### CONFIGURATION
Copy these lines into your server.cfg and change them to your liking. **They are not required to be set, by default this plugin will work just fine without these**

> karmabet_savemode "sqlite" // sqlite or mysql  
karmabet_language "english" // english or german

> karmabet_min_identified_bodies 2 // Minimum amount of corpses that have to be found by other players for total bet amounts to be visible by all players  
karmabet_min_karma 10 // Minimum amount of karma a player can bet  
karmabet_max_karma 200 // Maximum amount of karma a player can bet before going "all"-in  
karmabet_allin_karma 350 // Amount of karma a player bets when choosing "all"  
karmabet_min_live_karma 600 // Minimum karma of a player to have to bet (bets that would reduce their karma below this point are adjusted to hit this amount upon losing)  
karmabet_bet_time 180 // Time in seconds for dead/spectating players to place their bet during a round  
karmabet_mybets_cooldown 5 // Time in seconds between every !mybets command  
karmabet_bestbets_cooldown 180 // Time in seconds between every !bestbets command  
karmabet_worstbets_cooldown 180 // Time in seconds between every !worsbets command  

> karmabet_debug 0 // Print debugging messages to server console, 1 = yes, 0 = no

>// THESE SETTINGS ARE ONLY REQUIRED TO BE CHANGED IF YOU SET karmabet_savemode "mysql"  
karmabet_mysql_host "localhost"  
karmabet_mysql_dbname "database_name"  
karmabet_mysql_username "database_user"  
//karmabet_mysql_pw "DO_NOT_PUT_PASSWORD_HERE" // For the sake of safety, define this in your COMMAND LINE like this:  
// ...+host_workshop_collection "blabla" **+karmabet_mysql_pw "put_password_here"** +rcon_password "bluuh_blah" ...  
karmabet_mysql_port 3306`
