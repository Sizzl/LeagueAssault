

# LeagueAssault
A popular game-type modification for Unreal Tournament 1999, first established in 2001 and used within league and public games hosted by utassault.net and other popular game hosting sites.

**Table of Contents**
* [Top](#leagueassault)
  * [History](#history)
  * [Release notes](#release-notes)
    * [Version 135](#version-135)
    * [Version 134](#version-134)
    * [Version 133](#version-133)
    * [Versions 131-132](#versions-131-132)
    * [Version 130](#version-130)
    * [Versions 125-129 beta](#versions-125-129-beta)
    * [Version 124](#version-124)
    * [Versions 120-123 beta](#versions-120-123-beta)
    * [Version 119](#version-119)
    * [Version 118](#version-118)
    * [Version 116 beta](#version-116-beta)
    * [Version 111](#version-111)
    * [Version 104](#version-104)
    * [Versions 100-103](#versions-100-103)

## History
Born out of an extension to the popular Unreal Tournament mutator "Eavy Assault Plus", the Advanced Assault project team began working on additional fixes, enhancements and maps to suplement the leagues running at utassault.net.

## Release notes

### Version 135

- Netspeed tracking and limiting
- Removed buggy laser fence in AS-AutoRIP
- Updated Say/TeamSay commands
- Added coloured rifles to iAS. To match the coloured beams
- Fix bug with AutoRIP laser fence

#### Netspeed

Netspeed is now monitored and in-life changes are prevented. A players netspeed will now show on the scoreboard (unless mute is active) and players will suicide if they change their netspeed during the game. Netspeeds less than 2600 are not permitted.

#### Say / Teamsay variables

%NEARESTTEAMMATE% should be self explanitory, %LOCATION% has been changed to show the name of the nearest objective if location is unknown.

### Version 134

Released April 2002.

- FOV bug fix
- Fixed AntiHammerLaunch, AnitRocketLaunch & Mapvote mutators breaking ngstats compatibility
- Replaced Attackers Pulse rifle with minigun on OceanFloor (quick and easy fix for the OceanFloor bug)
- More CSHP improvements. Full rogue actor scanning is back, but at this stage not enabled by default
- GolgothaAL: Pulse Rifle replaced with minigun ammo.
- Overlord: Removed Teleporter exit objective trigger in Boiler room.

### Version 133
Mostly bug fixes, plus an iAS mutator with team colours.

- Fixed Bridge Box exploit
- Fixed Enhanced CSHP causing 1 second pauses on large maps
- Altered CSHP so that it will only crash on a known cheat, if it cannot identify a hack it will only kick, not crash the client
- Added bServerNameGameType option to auto prefix the server name with StdAS / ProAS/ iAS depending on game type
- Added built in InstaGIB Assault mutator with team coloured instagib shots

### Versions 131-132

Released March 2002.

- Introduced AntiHammerLaunch and AntiRocketLaunch mutators (131)
- Auto Pausing
- PublicString & PrivateString Variables: Allows server admin to customise the string that is displayed by bAdminNameScore and bServerNameScore options
- Fixed Elapsed Time not working in offline/practice mode
- Fixed Anti Rocket Launch & Anti Hammer Launch mutators preventing spawn protection from working
- Allow "ThrowArmor" (US English) as well as "ThrowArmour" (British English) for command
- Automatically logout those connecting with admin password when server is in match mode
- Stop "toggle bSnaplevel" causing constant suiciding
- Fixed FOV changing
- AdvancedSay & AdvancedTeamSay scrapped, parameters will now work in standard Say and TeamSay commands
- Fixed FortStandards blocking tracehit weapons
- Enhanced CSHP with a new type of cheat protection, stops those cheats known to get past v130 and closes a large loophole in the cheat protection

#### Auto Pausing 
New system wont pause if the teams are even (even if the server isn't full) and it wont pause if the teams aren't even at the start of the map (only if a player drops mid game).

Maximum pause time is now for the whole match and not based on per map, default is 3 minutes

- RequestPause function allows clans to pause at ANY time not just when a player drops
- CancelPause function allows clans to cancel the pause during the pause count down or resume while the game is paused at any time


### Version 130
Released circa December 2001.

#### Client Side Hack Protection

Further anti-cheat / anti-hack / bug-fix measures added:

- Multi-Weapon bug/cheat fix.

-------------
### Versions 125-129 beta
Released circa October 2001

LeagueAS functionality is now split across 3 different packages:

**LeagueAS-SP.u**

Installed server-side only, contains code only required to run on servers. This split in functionality allows for updates to League Assault without the need for a new client download - where possible (e.g. map changes / fixes CAN be changed server side).

**LeagueAS1xx.u**

Installed and runs on the server and client. Contains the majority of League Assault code. Will download from the server to the client if the client doesn't have it.

**LeagueAS-CP.u**

Installed on the server & client but only runs on the client (has to be installed on the server to ensure the client can download the file if they don't have it).
Contains all the client side settings for League Assault (ensuring that settings will now be carried from one version of League Assault to the next). Also contains the code for the new League Assault menu options and a browser window.

#### Client Side Hack Protection

Further anti-cheat / anti-hack / bug-fix measures added:

- CenterView tracking.
- Admin, Moderator & God Mode status tracking.
- Change Teams bug/cheat fix.
- Grab command disabled.
- After time map completion bug fix.
- Invisible Players / Commanders bug/cheat fix.

#### Game Play / Player Related Features

**Spawn Protection**
 - Added flashing Health Status on HUD when spawn protection is active, warning in console when spawn protection wears off.

#### Misc. Changes / fixes

- Added ngStats compatibility with the standard Assault Gametype.
- Added Gamespy / Browser compatibility with the standard Assault Gametype.
- bServerNameScore setting appends the server status to the servers name (and score in a match) in the same way the bAdminNameScore shows the status as the admin name.
- Asterisk now shown next to the names of those who have clicked when the server is in tournament mode or match mode.
- Client Side Options window to set all of League Assaults options in a user friendly GUI interface.
- Integrated League Assault Browser.
- Change Teams Cheat fixed.
- Completing a map after the time has run out bug fixed.
- Added who completed an objective for IRC reporting.
- Allow Display of elapsed time on the Extended HUD instead of Remaining Time.
- Warning when Spawn Protection wears off.
- Fixed Invisible players bug by preventing Commanders joining a game under any circumstances.
- Registered Player Name, Clan & Password handling for future anti-mercing systems, in addition League Assault will automatically use any Name & Clan tag settings during a match, overriding the standard playername.
- Anti-Hammer Launch, Anti-Rocket Launch and MapVoting mutators built into the Server Package.
- CenterView tracking performs a suicide of abusers.

-------------
### Version 124
Released circa September 2001

#### Client Side Hack Protection

First release of League Assault which includes CSHP v1.7.29 built in.

#### Server / Admin Related Features

#####  Game Parameters
The following additional game parameters can be found under the [LeagueAS.LeagueAssault] section of the unrealtournament.ini or can be set using the set command.

**bEnableCSHP** (boolean) (true): Indicates whether or not CSHP should be enabled. Should only be set to false if you wish to use a separate version of CSHP.


-------------
### Versions 120-123 beta
Released circa June 2001.

Bug fixes, preparing for v124 release.


-------------
### Version 119
Released circa June 2001.

#### Game Play / Player Related New Features

**Improved HUD**

The HUD has been improved to show:

- Packet loss and ping.

- Team Sizes (or match score during a match).

- A complete team listing with location, weapon, health, armour and weapon of each team mate.

- A complete objective listing including the status of each (completed / uncompleted) and if completed by whom.

Extended HUD may be toggled on/off with **ToggleExtendedHUD** and individual features may be toggled with **ToggleExtendedHUDItems** command or through editing the LeagueASXXX.LeagueAS_HUD section of your user.ini. HUD font size may be toggled with **ToggleExtendedHUDFont** command and through .ini editing.

#### Admin commands

The following additional commands may be executed by a server admin only and must be preceeded by the admin command:

**ShowMatchLog**: Returns a list of logged match results.

**ClearMatchLog**: Clears the match log.


-------------
### Version 118
Released circa June 2001.

Full change list documented and published at [leagueas.utassault.net](https://web.archive.org/web/20010623101046/http://leagueas.utassault.net/).

#### Game Play / Player Related New Features

##### Extended Say/TeamSay Commands
There are 2 new say commands:

**AdvancedSay**: Similar to standard UT Say command except supports new parameters (see below).

**AdvancedTeamSay**: Similar to standard UT TeamSay command except supports new parameters (see below).

**Parameters**

All of the above extended say commands support the following new parameters. Place these parameters in you text and they will be replaced with the corresponding values. e.g. AdvancedTeamSay I have %HEALTH% Health will be sent to your team mates as "I have 54 Healh" (if you had 54 health).

|Parameter |Description |
|--|--|
| %LOCATION% | Inserts your current map location (does not work with all maps). |
| %HEALTH% | Inserts your current health. |
| %ARMOUR% | Inserts your current armor amount. |
| %WEAPON% | Inserts the current weapon your are holding. |
| %AMMO% | Insert the ammo count of the current weapon your are holding. |
| %MYNAME% | Inserts your name. |
| %MYTEAM% |  Inserts your team's name (colour). |
| %ENEMYTEAM% |  Inserts the opposing team's name (colour). |
| %OBJECTIVE% | Inserts the name of the nearest objective.  |


##### ThrowArmor Command

This new command allows you to throw some or all of your armor in the same way you would your weapon. This allows you to share your armor with your team mates. Executing this command with no parameter will throw the lowest rated armor you are carrying (Order rating: Thigh Pads -> Chest Armor -> Shield Belt). Alternatively you can add a parameter value 1, 2 or 3 after to throw a specific armor item (1:Thigh Pads, 2:Chest Armor, 3:Shield Belt).

##### ChangeTeams Command
Executing the ChangeTeams command will change a players current team to the opposing team.
 
##### ToggleMute Command
The ToggleMute command allows message muting. There are 3 options:
1. Mute OFF.
2. Mute ENEMY Messages.
3. Mute ALL Messages.

If a player has mute on it will show next to his name on the scoreboard.
 
##### Echo Command
Executing the Echo command relays the selected text to your console.
 
##### ShowMatchScore Command
The ShowMatchScore command will display the score during a match.
 
##### Spawn Protection
Players are granted a limited period of invulnerability when they spawn. Attackers get 4 seconds of invulnerability, defenders 2 second.

#### Game Play / Player Related Alterations & Fixes

##### Improved Scoreboard
The scoreboard has been improved to show:
An individual players packet loss as well as ping.
Team ping & packet loss.
A complete objective listing including the status of each (completed / uncompleted) and if completed by whom.
 
##### Spawn with Dual Enforcers
All players now spawn with Dual Enforcers instead of the previous single Enforcer.
 
##### Auto Cannon Health Reduced
All auto-cannons have had their health reduced from 220 to 100.
 
##### Changes to Spawn Point Selection System
The spawn point selection system has been changed so that it no longer considers the players in the same zone or within sight of the spawn point a factor. Spawn point priority is now (from lowest to highest):

1. Any Spawn point which will cause a telefrag.
2. The last used spawn point.
3. All other spawn points.
 
#####  Changes to Attacking Team Selection System
The attacking team selection system has been changes so that it is no longer the first player onto the server that decided which team attacks first but instead the team that won the last round is the team which attacks first.

#### Server / Admin Related Features
 
#####  Game Parameters
The following game parameters can be found under the [LeagueAS.LeagueAssault] section of the unrealtournament.ini or can be set using the set command.

**bMatchMode** (boolean) (false): Indicates whether the server is in match mode or not. Whilst in match mode the server will keep track of the scores, start each map after a preset time or once everyone has toggled ready, logout all admins and moderators (see below) at the start of a map, set both teams so that they may be no bigger than 1/2 the max number of players, disable team changing and disable practice mode (see below). SHOULD NOT BE SET MANUALLY USE StartMatch COMMAND.

**bPracticeMode** (boolean) (false): Indicates whether the server is in practice mode or not. Practice mode makes all players invulnerable and allows them to execute the SummonItem command to summon any item from the botpack package. SHOULD NOT BE SET MANUALLY USE TogglePracticeMode COMMAND.

**bAttackOnly** (boolean) (false): Indicates that the server should only play 1 round of each map, only 1 team gets the chance to attack after the attack is complete the server switches to the next map.

**bStandardise** (boolean) (true): Indicates whether or not to force standard game speed, air control etc settings.

**bAdminNameScore** (boolean) (false): Indicates whether to show the match score under the servers Admin Name option, allows the match score to be shown on a web site etc using programs such as qstat. If no match is in progress it will display "OPEN - PUBLIC" if the server is not passworded and "CLOSED - PRIVATE" if it is.

**MatchLength** (integer) (14): The length in maps of a match. 

**FirstMapStartTime** (integer) (300): The time in seconds the first map should force start after the StartMatch command has been executed.

**SubsequentMapStartTime** (integer) (60): The time in seconds each subsequent map should force start.

**TeamNameRed** (string) (Red): The team name for the red team (used only if  bMatchMode is true).

**TeamNameBlue** (string) (Blue): The team name for the blue team (used only if bMatchMode is true).

**ModeratorPassword** (string) (moderator): The password required to login as moderator (see below).

**MatchPasswordRed** (string) (): The password required to join the red team (used only if bMatchMode is true).

**MatchPasswordBlue** (string) (): The password required to join the blue team (used only if bMatchMode is true).

**MatchPasswordSpec** (string) (): The password required to join as a spectator (used only if bMatchMode is true).

 
#####  Admin Commands
The following commands may be executed by a server admin only and must be preceeded by the admin command (e.g admin StartMatch):

**StartMatch**: Requires that Tournament Mode be active. Resets the scores and initiates a new match. The first map will start after a period of time designated by FirstMapStartTime and each subsequent map after a period of time designated by SubsequentMapStartTime. The match will end after MatchLength maps at which point the server will pause not restarting the map and will disable match mode. The admin should then simply change/restart the map to return it to normal play.

**EndMatch**: Instructs the server to terminate the match after the current map is complete.

**ResetTeamNames**: Rests the team names to "Red" and "Blue".

**TogglePracticeMode**: Toggles practice mode on and off.

**StopCountDown**: Stops the game timer.

**VoidMapRed** & **VoidMapBlue**: Each command removes 1 point from the respective teams score during a match, used to correct the score if a map played needs to be voided.

 
##### Server Moderators
Players may login/logout as moderator (with the correct password designated by the ModeratorPassword parameter). A player logged in as moderator will have his/her name shown in green. Moderators may execute some commands previously restricted to admins only:
**ModeratorLogin <password>**: Logs a player in as a moderator.

**ModeratorLogout**: Logs out a moderator.

**Moderator <command>**: Executes a command as a moderator. Valid commands are servertravel, kick, summon and stopcountdown.


#### Map Changes
**Asthenosphere**
 - Fixed air vent block exploit

**GuardiaAL**
 - Removed all Flak ammo

-------------
### Versions 112-117 beta
Released circa May 2001.

#### Map Changes
**Asthenosphere**
 - Replaced the shock ammo in the air vents with Health Vials
 - Added thigh pads to same spot in air vents
 - Replaced 1 Shock Ammo in each of the final defensive spawn points
 - Took away 1 rocket pack (leaving of of each).

**Ballistic**
 - Fixed generator sniper shot exploit; unfortunately it is not possible to fix the spawn point problem in the mod :(

**RiverbedAL**
 - Took the steel boxes out of the main entrance of at the request of GRZ (to save a map update for something so minor).

**OceanFloorAL**
 - Removed AI monsters/fish.

#### Bug Fixes

- Spectator bug has been fixed (well more circumvented but its not possible anymore either way).
- Scoreboard now looks ok at 640x480 resolution.
- Moderators can now issue the full set of commands available to them.

#### New Features

- Moderators logged in now show in Green.
- ToggleMute function allows you mute either all messages or just those from the opposite team.
- AdvancedSay and AdvancedTeamSay commands from AdvancedAS are in.
- ThrowArmour command from AdvancedAS is in.
- Remote server setup facilities added. Will now allow setup of servers from a remote application, and soon from a completely automated server setup system.
- Cannot change teams AT ALL, during a match
- Team names are now only used during matches
- Tournament mode automatically disabled at the end of a match
- Echo command from AdvancedAS is in.

#### In development

Client Options - potential for future authorisation system to prevent mercs.

-------------
### Version 111
Released circa March/April 2001.

Undisclosed bug fixes and changes since version 104, ready for League usage.

-------------
### Version 104
Released circa March 2001. Adds many League related features to aid with match set-up and running.

#### Map Changes

**Frigate**
- Flak Ammo in ship respawns quicker.
- Under pier spawn removed.

**Overlord**

- Added Minigun Ammo at the start.
- Mortar is less effective.

**Lavafort][**

- Removed minigun cannon.

**Asthenosphere**

- Removed Shock ammo at the end (where defenders spawn).
- Added Anti Spawn Camper features :) (I'll let you find those yourseld).

Cosmetic / bug fixes including the final objective on Bridge.

#### Complete Feature List

- Everyone spawns with Dual Enforcers.
- Spawn Protection (4 second attackers, 2 second defenders).
- Team Change Command (and backwards compat with ABP)
- Match start timing. The first (warm up map) will start after 5 minutes, the remaining maps after 1 minute. Countdowns can be overridden if everyone clicks fire.
- Team Names and Match Scoring. Team names can be changed from the standard Red and Blue to the names of the clans. The results of each map are kept by the server and a running match score is displayed at the end of each map.
- Match Result Logging. At the end of each match the result is logged to a file for the league admins (in case you lazy arses don't bother to submit and in the case of any disputes).
- 2 Match Passwords, 1 for each team. Each password will enter you into the server on your respective team, and the server will not allow you to join if your team is already 6 players in size.
- Admin only spectators so that we can join as spec to admin the server but clans cannot sneak a spec in to spy (or for the up coming possible commentary).
- Scoreboard shows PL and average team ping and PL. Also shows a list of objectives and who completed which.
- Server Moderators to keep people in check during public play and for clan practices.
- Clan that wins the previous map will attack first on the next map.
- Admins and Moderators are automatically disabled on match start to prevent an suspicions of cheating.


-------------
### Versions 100-103
Internal / Draft releases circa Q4 2000 / Q1 2001.

Merges many of the EavyAssaultPlus fixes into this release, including but not limited to:

#### Map Changes
**Rook**
- Door blocking first objective fixed (mover changed to crush)

**Mazon**
- Gate and other objective blocking fixed (movers changed to crush)

**LavaFort][**
- Various string (name / description) fixes for objectives

**Bridge**
- Various string (name / description) fixes for objectives

**Overlord**
 - Flag shot explot fixed (objective resized)

