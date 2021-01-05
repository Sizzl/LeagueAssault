//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAssault extends Assault config;

var() config bool bMatchMode;
var() config bool bPracticeMode;
var() config bool bAdminOnlySpectators;
var() config bool bStandardise;
var() config bool bAdminNameScore;
var() config int MapVoteChangeLimit;
var() config int TeamScore[2];
var() config int MapsLeft;
var() config int MatchLength;
var() config int FirstMapStartTime;
var() config int SubsequentMapStartTime;
var() config string TeamNameRed;
var() config string TeamNameBlue;
var() config string MapsWon[2];
var() private config string ModeratorPassword;
var() private config string MatchPasswordRed;
var() private config string MatchPasswordBlue;

var string VersionStr;
var LeagueAS_GameReplicationInfo LeagueASGameReplicationInfo;
var private PlayerPawn ModList[12];
var bool bGameStarted, MapsTweaked;
var float TeamChangeTime;

//************************************************************************************************
//TweakMaps: Alters some Assault maps to fix bugs and improve gameplay.
//************************************************************************************************
function TweakMaps()
{	
	local Actor A; 
	local string S, SA;
	local MiniAmmo MA;
	local vector V;
	local rotator R;
	local TeamTrigger T;
	local TeamCannon TC;

	if ( MapsTweaked )
		return;
	MapsTweaked = True;
    S = Left(Self, InStr(Self, "."));        
    ForEach AllActors(class'Actor', A)     
		{
			SA = Mid(A, InStr(A, ".") + 1);

			if ( A.IsA('TeamCannon') )
				TeamCannon(A).Health = 100;

			//Specific Map Changes
			//////////////AS-Frigate//////////////
			if ( S ~= "AS-Frigate" )
            	{
				if ( (SA ~= "flakammo3") || (SA ~= "flakammo2") )
                   	FlakAmmo(A).RespawnTime = 10.000000;
				else if ( SA ~= "PlayerStart10" )
                   	PlayerStart(A).bEnabled = False;
                }
			//////////////AS-Rook//////////////
			else if ( S ~= "AS-Rook" )
				{
				if ( SA ~= "Mover13" )
					Mover(A).MoverEncroachType = ME_CrushWhenEncroach;
				else if ( SA ~= "FortStandard1" )
					FortStandard(A).FortName = "Chain 1";
				else if ( SA ~= "FortStandard0" )
					FortStandard(A).FortName = "Chain 2";
				else if ( SA ~= "FortStandard3" )
					FortStandard(A).FortName = "Escape!";
				}
			//////////////AS-Overlord//////////////
			else if ( S ~= "AS-Overlord" )
				{
				if ( (SA ~= "Mover6") || (SA ~= "Mover7") )
					Mover(A).MoverEncroachType = ME_CrushWhenEncroach;
				else if ( SA ~= "TeamTrigger3" )
					A.SetCollisionSize(A.CollisionRadius * 2/3, A.CollisionHeight);
				else if ( SA ~= "FortStandard3" )
					{
					FortStandard(A).bFlashing = False;
					FortStandard(A).FortName = "Main Gun Control";
					}
				else if ( SA ~= "FortStandard4" )
					{
					FortStandard(A).FortName = "The Boiler Room";
					FortStandard(A).DestroyedMessage = "has been breached.";
					}
				else if ( SA ~= "FortStandard0" )
					{
					FortStandard(A).FortName = "The Beachhead";
					FortStandard(A).DestroyedMessage = "has been breached.";
					}
				else if ( SA ~= "SniperRifle0" )
					{
					V.X = 450;
					V.Y = 1712;
					V.Z = -1744;
					MA = Spawn(class'MiniAmmo', Self,, V, A.Rotation);
					MA.RespawnTime = 5;
					V.X = 235;
					V.Y = 1761;
					V.Z = -1744;
					MA = Spawn(class'MiniAmmo', Self,, V, A.Rotation);
					MA.RespawnTime = 5;
					}
				else if ( SA ~= "MortarSpawner0" )
					{
					MortarSpawner(A).ShellSpeed = 500;
					MortarSpawner(A).RateOfFire = 8;
					MortarSpawner(A).ShellDamage = 100;
					MortarSpawner(A).Deviation= 800;
					}
				}
			//////////////AS-Mazon//////////////
			else if ( S ~= "AS-Mazon" )
				{
				if ( (SA ~= "Mover4") || (SA ~= "Mover5") || (SA ~= "Mover6") )
					Mover(A).MoverEncroachType = ME_CrushWhenEncroach;
				}
			//////////////AS-HiSpeed//////////////	
			else if ( S ~= "AS-HiSpeed" )
				{
				if ( SA ~= "Mover5" )
					A.SetCollision(False);
				}	
			//////////////AS-Lavafort][//////////////
			else if ( S ~= "AS-Lavafort][" )
				{
				if ( SA ~= "FortStandard7" )
					{
					FortStandard(A).FortName = "The lava cave";
					FortStandard(A).DestroyedMessage = "has been entered!";
					}
				else if ( SA ~= "FortStandard6" )
					{
					FortStandard(A).FortName = "The fort";
					FortStandard(A).DestroyedMessage = "has been entered!";
					}
				else if ( SA ~= "FortStandard4" )
					{
					FortStandard(A).FortName = "The lift";
					FortStandard(A).DestroyedMessage = "has been passed!";
					}
				else if ( SA ~= "FortStandard3" )
					{
					FortStandard(A).FortName = "The entrance cave";
					FortStandard(A).DestroyedMessage = "has been breached!";
					}
				else if ( SA ~= "FortStandard5" )
					FortStandard(A).Destroy();
				else if ( SA ~= "MinigunCannon0" )
					A.Destroy();
				}
			//////////////AS-Bridge//////////////
			else if ( S ~= "AS-Bridge" )
				{
				if ( SA ~= "FortStandard3" )
					{
					FortStandard(A).FortName = "The base";
					FortStandard(A).DestroyedMessage = "has been entered!";
					}
				else if ( SA ~= "FortStandard7" )
					{
					FortStandard(A).FortName = "The bridge";
					FortStandard(A).DestroyedMessage = "has been reached!";
					}
				else if ( SA ~= "FortStandard22" )
					{
					A.SetCollisionSize(A.CollisionRadius * 2/3, A.CollisionHeight);
					V.X = 2768;
					V.Y = -1255;
					V.Z = 1478;
					T = Spawn(class'TeamTrigger', FortStandard(A), FortStandard(A).Tag, V, FortStandard(A).Rotation);
					T.Team = 0;
					T.Event = 'FF';
					}
				else if ( (SA ~= "Mover16") || (SA ~= "Mover17") || (SA ~= "Mover18") || (SA ~= "Mover19") )
					A.SetCollision(False);
				}
			//////////////AS-Ballistic//////////////
			else if ( S ~= "AS-Ballistic" )
				{
				if ( SA ~= "FortStandard3" )
					{
					FortStandard(A).FortName = "Nuclear strike";
					FortStandard(A).DestroyedMessage = "underway!";
					}
				}
			//////////////AS-Asthenosphere//////////////
			else if ( S ~= "AS-Asthenosphere" )
			{
				if ( (SA ~= "Mover21") || (SA ~= "Mover26") )
					Mover(A).MoverEncroachType = ME_CrushWhenEncroach;
				else if ( (SA ~= "ShockCore4") || (SA ~= "ShockCore13") || (SA ~= "ShockCore15") || (SA ~= "ShockCore14")	)
					A.Destroy();
				else if ( SA ~= "FortStandard8" )
					{
					V.X = 0;
					V.Y = -5628;
					V.Z = 40.4;
					R.Pitch = 0;
					R.Roll = 0;
					R.Yaw = -16264;
					TC = Spawn(class'TeamCannon', FortStandard(A), FortStandard(A).Tag, V, R);
					TC.MyTeam = 1;
					TC.ProjectileType = Class'ShockProj';
					V.Y = -4848;
					TC = Spawn(class'TeamCannon', FortStandard(A), FortStandard(A).Tag, V, R);
					TC.ProjectileType = Class'RocketMk2';
					}
			}
		}
}
//************************************************************************************************
//SetScoreStrings. Sets the scores.
//************************************************************************************************
function SetScoreStrings(string InScore)
{
	LeagueASGameReplicationInfo.MatchScore = InScore;
	if ( bAdminNameScore )
		LeagueASGameReplicationInfo.AdminName = LeagueASGameReplicationInfo.MatchScore;
}
//************************************************************************************************
//GetWinningTeam: Returns the team number of the winning team.
//************************************************************************************************
function int GetWinningTeam()
{
	if ( bDefenseSet )
		{
		if ( bAssaultWon )
			return Attacker.TeamIndex;
		else if (!bTiePartOne)
			return Defender.TeamIndex;
		else
			return -1;
		}
	else
		return -1;
}
//************************************************************************************************
//AddModerator: Adds a moderator to the list.
//************************************************************************************************
function AddModerator(PlayerPawn Moderator, string Password)
{
   local int i;

   if (ModeratorPassword == "")
		return;   

   if (!IsAModerator(Moderator) && (Password == ModeratorPassword) )
   		{
   		log(Moderator.PlayerReplicationInfo.PlayerName@"became a server moderator.", 'LeagueAssault');
		BroadcastMessage(Moderator.PlayerReplicationInfo.PlayerName@"became a server moderator.");
   
   		for(i=0;i<12;i++)
   			{
      		while((ModList[i]==None))
      			{
         		ModList[i] = Moderator;
         		return;
      			}
   			}
		}
}
//************************************************************************************************
//IsAModerator: Checks if a player is a moderator.
//************************************************************************************************
function bool IsAModerator(PlayerPawn Moderator)
{
   local int i;
   
   if ( Moderator == None )
   		return false;

   for(i=0;i<12;i++)
   {
      if(ModList[i] == Moderator)
      {
         return true;
      }
   }
   return false;
}
//************************************************************************************************
//RemoveModerator: Removes a moderator from the list.
//************************************************************************************************
function RemoveModerator(PlayerPawn Moderator)
{
   local int i;
   
   for(i=0;i<12;i++)
   	{
      if(ModList[i] == Moderator)
      	{
         ModList[i] = None;
   		 log(Moderator.PlayerReplicationInfo.PlayerName@"gave up moderator abilities.", 'LeagueAssault');
		 BroadcastMessage(Moderator.PlayerReplicationInfo.PlayerName@"gave up moderator abilities.");
      	}
   	}
}
//************************************************************************************************
//PEF Functions are executed by players from LeagueAS_Inventory.
//************************************************************************************************
function PEFChangeTeams(PlayerPawn Sender)
{		
	if ( !bMatchMode )
	{
		if ( (Sender.PlayerReplicationInfo.Team < MaxAllowedTeams) && (Level.TimeSeconds > TeamChangeTime) )
		{
			if ( Sender.PlayerReplicationInfo.Team == Attacker.TeamIndex )
				Sender.ChangeTeam(Defender.TeamIndex);
			else
				Sender.ChangeTeam(Attacker.TeamIndex);
			TeamChangeTime = Level.TimeSeconds + 2;
		}
	}
}
//************************************************************************************************
function PEFResetTeamNames()
{
	TeamNameRed = "Red";
	TeamNameBlue = "Blue";
	TeamColor[0] = "Red"; 
	TeamColor[1] = "Blue";
	Teams[0].TeamName = "Red";
	Teams[1].TeamName = "Blue";
	BroadcastMessage("TEAM NAMES RESET!");
	SaveConfig();
}
//************************************************************************************************
function PEFTogglePracticeMode()
{
	local Pawn P;	
	
	bPracticeMode = !bPracticeMode;
	if ( bPracticeMode )
		BroadcastMessage("PRACTICE MODE ENABLED!");
	else
		BroadcastMessage("PRACTICE MODE DISABLED!");
	SaveConfig();

	if ( bPracticeMode )
		{
		//BroadcastMessage("SERVER IS IN PRACTICE MODE");
		for( P = Level.PawnList; P!=None; P=P.nextPawn )		
        	if( P.IsA('PlayerPawn') )
				P.ReducedDamageType = 'All';
		}
	else
		{
		//BroadcastMessage("SERVER IS IN PRACTICE MODE");
		for( P = Level.PawnList; P!=None; P=P.nextPawn )		
        	if( P.IsA('PlayerPawn') )
				P.ReducedDamageType = '';
		}

}
//************************************************************************************************
function PEFStartMatch(PlayerPawn Sender)
{
	if ( !bTournament )
		{
		Sender.ClientMessage("Tournament mode must be active to start a match!");
		return;
		}

	if ( bGameStarted )
		{
		Sender.ClientMessage("Cannot start a match after game has started!");
		return;
		}

	if ( bMatchMode )
		{
		Sender.ClientMessage("Match in progress, please end current match before starting new one.");
		return;
		}
	
	LeagueASGameReplicationInfo.StartTimeRemaining = FirstMapStartTime;						
	bMatchMode = true;
	LeagueASGameReplicationInfo.bMatchModeEnabled = true;
	BroadcastMessage("Starting Match Countdown...", true);
	TeamScore[0] = 0;
	TeamScore[1] = 0;
	MapsWon[0]="";
	MapsWon[1]="";
	SetScoreStrings(TeamColor[0]@"0 - 0"@TeamColor[1]$".");
	MapsLeft = MatchLength + 1;
	bPracticeMode = false;
	SaveConfig();
}
//************************************************************************************************
function PEFEndMatch()
{
	BroadcastMessage("Match will terminate after current map is complete!", true);
	MapsLeft = 1;
}
//************************************************************************************************
function PEFVoidMap(PlayerPawn Sender, int TeamNum)
{
	Sender.ClientMessage("Voided 1 Map...");
	TeamScore[TeamNum]--;
	MapsLeft++;
	PEFShowScores(Sender);
}
//************************************************************************************************
function PEFShowScores(PlayerPawn Sender)
{
	Sender.ClientMessage(TeamColor[0]@" -"@string(TeamScore[0]));
	//Sender.ClientMessage("("$Team0MapsWon$")");
	Sender.ClientMessage(TeamColor[1]@" -"@string(TeamScore[1]));
	//Sender.ClientMessage("("$Team1MapsWon$")");
	If (MapsLeft==0)
		Sender.ClientMessage("THE MATCH HAS ENDED!");
	else if (MapsLeft==1)
		Sender.ClientMessage("1 MAP REMAINING...");
	else
		Sender.ClientMessage(string(MapsLeft)@"MAPS REMAINING...");
}
//************************************************************************************************
//Remaining functions/events are extended from the Assault and other game types.
//************************************************************************************************
event PreLogin (string Options, string Address, out string Error, out string FailCode)
{
	local string InPassword;
	
	Super.PreLogin(Options, Address, Error, FailCode);

	InPassword = ParseOption( Options, "Password" );
	if ( bMatchMode && (MatchPasswordRed != "") && (MatchPasswordBlue != "") )
		{
		if ( ((Caps(InPassword) == Caps(MatchPasswordRed)) && (Teams[0].Size < (MaxPlayers / 2))) || ((Caps(InPassword) == Caps(MatchPasswordBlue)) && (Teams[1].Size < (MaxPlayers / 2))) )
			{
			Error = "";
			FailCode = "";
			}
		}
	else if (Caps(InPassword) == Caps(ModeratorPassword))
		{
		Error = "";
		FailCode = "";
		}

}
//************************************************************************************************
event playerpawn Login (string Portal, string Options, out string Error, class<playerpawn> SpawnClass)
{
	local PlayerPawn NewPlayer;
	local string InPassword, ModOptions, Pair, Key, Value, OvClass;

	InPassword = ParseOption ( Options, "Password" );
	ModOptions = "";

	//Modify team option if nessacary.
	if ( bMatchMode && (MatchPasswordRed != "") && (MatchPasswordBlue != "") && (!ClassIsChildOf(SpawnClass, class'Spectator')) )
		{
		if ( (Caps(InPassword) == Caps(MatchPasswordRed))	)
			{
			while( GrabOption( Options, Pair ) )
				{
				GetKeyValue( Pair, Key, Value );
				if( Key ~= "Team" )
					ModOptions = ModOptions$"?Team=0";
				else
					ModOptions = ModOptions$"?"$Pair;
				}
			}
		else if ( (Caps(InPassword) == Caps(MatchPasswordBlue)) )
			{
			while( GrabOption( Options, Pair ) )
				{
				GetKeyValue( Pair, Key, Value );
				if( Key ~= "Team" )
					ModOptions = ModOptions$"?Team=1";
				else
					ModOptions = ModOptions$"?"$Pair;
				}
			}
		else
			ModOptions = Options;
		}
	else
		ModOptions = Options;

	Log("Modified Options - "$ModOptions, 'LeagueAssault');

	NewPlayer = Super.Login(Portal, ModOptions, Error, SpawnClass);

	OvClass = ParseOption ( Options, "OverrideClass" );
	//Check for admin only specs
	if ( (NewPlayer != None) && bAdminOnlySpectators && bMatchMode && (OvClass ~= "BOTPACK.CHSPECTATOR") && !NewPlayer.bAdmin )
		{
		Error = "Administrator only Spectators!";
		NumSpectators--;
		return None;
		}

	//Login moderator if nessacary.
	if (Caps(InPassword) == Caps(ModeratorPassword))
		AddModerator(NewPlayer, InPassword);

	if ( bPracticeMode )
		NewPlayer.ReducedDamageType = 'All';

	return NewPlayer;
}
//************************************************************************************************
function NavigationPoint FindPlayerStart(Pawn Player, optional byte InTeam, optional string incomingName)
{
	local Pawn P;
	local int i,D;
	local byte Team;

	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
		Team = Player.PlayerReplicationInfo.Team;
	else
		Team = InTeam;

	if ( Team != 255 )
	{
		if ( Team > 1 )
			Team = 0;
		if ( Defender == None )
		{
			log("Setting up Teams...", 'LeagueAssault');

			D = CurrentDefender;
			if ( (D != 0) && (D != 1) )
				D = 0;

			log("Team "$string(D)$" is defending.", 'LeagueAssault');
			Defender = Teams[D];
			if ( D == 0 )
				{
				log("Team 1 is attacking.", 'LeagueAssault');
				Attacker = Teams[1];
				}
			else
				{
				log("Team 0 is attacking.", 'LeagueAssault');
				Attacker = Teams[0];
				}

			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('StationaryPawn') )
					StationaryPawn(P).SetTeam(Defender.TeamIndex);

			if (WorldLog != None)
			{
				WorldLog.LogSpecialEvent("assault_defender", Defender.TeamIndex);
				WorldLog.LogSpecialEvent("assault_attacker", Attacker.TeamIndex);
			}
			if (LocalLog != None)
			{
				LocalLog.LogSpecialEvent("assault_defender", Defender.TeamIndex);
				LocalLog.LogSpecialEvent("assault_attacker", Attacker.TeamIndex);
			}
		}
		if ( Teams[Team] == Defender )
			Team = 0;
		else
			Team = 1;
	}

	return Super(TeamGamePlus).FindPlayerStart(None, Team, incomingName);
}
//************************************************************************************************
function RestartGame()
{
	local Pawn P;
	local int i;

	if ( bDontRestart )
		return;

	if ( !bGameEnded || (EndTime > Level.TimeSeconds) ) // still showing end screen
		return;

	if ( bDefenseSet ) 
		{
		log("Map Change Initiated...", 'LeagueAssault');
		if ( GetWinningTeam() != -1 )
			{
			log("Team "$string(GetWinningTeam())$" won the round.", 'LeagueAssault');
			if (GetWinningTeam() == 1)
				CurrentDefender = 0;
			else
				CurrentDefender = 1;
			log("Setting Team "$string(CurrentDefender)$" as the defending team for the next map.", 'LeagueAssault');
			}
		else
			CurrentDefender = 0;
		
		SaveConfig();

		Default.bDefenseSet = False;
		Default.Part = 1;
		Default.SavedTime = 0;
		Default.NumDefenses = 0;	
		Default.GameCode = "";	
		Default.bTiePartOne = false;
		Default.CurrentDefender = CurrentDefender;
		StaticSaveConfig();

		Super(TeamGamePlus).RestartGame();
		}
	else
		{
		bDontRestart = true;		
		if ( Defender.TeamIndex == 1 )
			CurrentDefender = 0;
		else
			CurrentDefender = 1;
		bDefenseSet = true;
		Part = 2;
		SavedTime  = TimeLimit * 60 - RemainingTime;
		SaveConfig();
		Level.ServerTravel( "?Restart", false );
		}
}
//************************************************************************************************
function RemoveFort(FortStandard F, Pawn Instigator)
{
	local int i;

	for (i=0; i<19; i++)
   		{
    	if ( (LeagueASGameReplicationInfo.FortName[i] == F.FortName) || (LeagueASGameReplicationInfo.FortName[i] == string(F)) )
			LeagueASGameReplicationInfo.FortCompleted[i] = "Completed! - by"@Instigator.PlayerReplicationInfo.PlayerName; 
		}

	Super.RemoveFort(F, Instigator);

}
//************************************************************************************************
function AddDefaultInventory( pawn PlayerPawn )
{
	local Inventory i;
	local Enforcer SecondEnforcer;

	i = PlayerPawn.FindInventoryType(class'LeagueAS_Inventory');
	if ( i == None )
		i = Spawn(class'LeagueAS_Inventory', PlayerPawn);
	else
		{
		i.Destroy();
		i = Spawn(class'LeagueAS_Inventory', PlayerPawn);
		}
	if ( i != None )
		{
		i.bHeldItem = true;
		i.GiveTo(PlayerPawn);
		LeagueAS_Inventory(i).ActivateSpawnProtection();
		}
	
	if ( !PlayerPawn.IsA('Spectator') && !(bRequireReady && (CountDown > 0)) )
		{
		Super(GameInfo).AddDefaultInventory(PlayerPawn);		
		GiveWeapon(PlayerPawn, "BotPack.Enforcer");
		i = PlayerPawn.FindInventoryType(class'Enforcer');
		if ( i != None )
			Enforcer(i).AmmoType.UseAmmo(28);
		SecondEnforcer = Spawn(class'Enforcer', PlayerPawn);
		If ( SecondEnforcer != None )
			{
			PlayerPawn.Inventory.HandlePickUpQuery(SecondEnforcer);
			SecondEnforcer.Destroy();
			}
		}

}
//************************************************************************************************
function bool SetEndCams(string Reason)
{
	local int WinningTeam;
	local Pawn P;

	Super.SetEndCams(Reason);

	if ( bDefenseSet && bMatchMode)
		{
		if (!(MapsLeft > MatchLength))
			{
			WinningTeam = GetWinningTeam();
			If ( WinningTeam != -1 )
				{
				TeamScore[WinningTeam]++;
				if ( MapsWon[WinningTeam] == "" )
					MapsWon[WinningTeam] = Left(Self, InStr(Self, "."));
				else
					MapsWon[WinningTeam] = MapsWon[WinningTeam]$","@Left(Self, InStr(Self, "."));
				}
			}
		MapsLeft--;
		if ((TeamScore[0] > (TeamScore[1] + MapsLeft)) || (TeamScore[1] > (TeamScore[0] + MapsLeft)))
			MapsLeft=0;
		for( P = Level.PawnList; P!=None; P=P.nextPawn )
        	if( P.IsA('PlayerPawn') )
			{
				SetScoreStrings(TeamColor[0]@TeamScore[0]@"-"@TeamScore[1]@TeamColor[1]$".");
				if (WinningTeam == -1)
					LeagueASGameReplicationInfo.GameEndedComments = "Tie!"@LeagueASGameReplicationInfo.MatchScore;
				else
					LeagueASGameReplicationInfo.GameEndedComments = TeamColor[WinningTeam]@"Wins!"@LeagueASGameReplicationInfo.MatchScore;
				P.ClientGameEnded();
				P.GotoState('GameEnded');
			}	
		if ( MapsLeft == 0 )
			{
			bDontRestart = true;
			bMatchMode = false;
			LeagueASGameReplicationInfo.bMatchModeEnabled = false;
			}
		}
	SaveConfig();
	return true;
}
//************************************************************************************************
function StartMatch()
{
	local Pawn P;
	local int i;
	
	Super.StartMatch();
	bGameStarted = true;
	LeagueASGameReplicationInfo.StartTimeRemaining = -1;

	//Remove ALL admins and moderators if is a match
	if ( bMatchMode )
		{
		for( P = Level.PawnList; P!=None; P=P.nextPawn )
        	if( P.IsA('PlayerPawn') )
				{
				PlayerPawn(P).bAdmin = false;
				PlayerPawn(P).PlayerReplicationInfo.bAdmin = false;
				P.ReducedDamageType = '';
				}
		if ( bMatchMode )
			{
			for(i=0;i<12;i++)
			ModList[i] = None;
			}
		}

	if ( bPracticeMode )
		{
		BroadcastMessage("SERVER IS IN PRACTICE MODE");
		for( P = Level.PawnList; P!=None; P=P.nextPawn )		
        	if( P.IsA('PlayerPawn') )
				P.ReducedDamageType = 'All';
		}

}
//************************************************************************************************
event timer()
{
	local Pawn P;
	local bool bReady;

	Super.Timer();

	if (!bMatchMode)
		LeagueASGameReplicationInfo.StartTimeRemaining = -1;
	else if (LeagueASGameReplicationInfo.StartTimeRemaining >= 0)
		{
		LeagueASGameReplicationInfo.StartTimeRemaining--;
   		if(!bRequireReady)
   			{
     		LeagueASGameReplicationInfo.StartTimeRemaining = -1;
			bMatchMode = false;
			LeagueASGameReplicationInfo.bMatchModeEnabled = false;
   			}
   		if(LeagueASGameReplicationInfo.StartTimeRemaining == 300)
   			{
      		BroadcastMessage("5 MINUTES UNTIL GAME START...", true);
      		if (MapsLeft > MatchLength)
	  			BroadcastMessage("WARM UP MAP ONLY!", true);
   			}
   		if(LeagueASGameReplicationInfo.StartTimeRemaining == 180)
   			{
      		BroadcastMessage("3 MINUTES UNTIL GAME START....", true);
      		if (MapsLeft > MatchLength)
	  			BroadcastMessage("WARM UP MAP ONLY!", true);
   			}
   		if(LeagueASGameReplicationInfo.StartTimeRemaining == 60)
   			{
      		BroadcastMessage("1 MINUTE UNTIL GAME START....", true);
      		if (MapsLeft > MatchLength)
	  			BroadcastMessage("WARM UP MAP ONLY!", true);
   			}
		if(LeagueASGameReplicationInfo.StartTimeRemaining == 30)
   			{
     		BroadcastMessage("30 SECONDS UNTIL GAME START....", true);
      		if (MapsLeft > MatchLength)
	  			BroadcastMessage("WARM UP MAP ONLY!", true);
   			}
   		if(LeagueASGameReplicationInfo.StartTimeRemaining == 10)
   			{
      		BroadcastMessage("10 SECONDS UNTIL GAME START...", true);
      		if (MapsLeft > MatchLength)
	  			BroadcastMessage("WARM UP MAP ONLY!", true);
   			}
   		if(LeagueASGameReplicationInfo.StartTimeRemaining < 11 && LeagueASGameReplicationInfo.StartTimeRemaining > 0 )  
   			{
			bReady = true;
			for (P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('PlayerPawn') && !P.IsA('Spectator') && !PlayerPawn(P).bReadyToPlay )
					bReady = false;
			if (NumPlayers < MaxPlayers)
				bReady = false;	
			if ( !bReady )
				{
				CountDown = LeagueASGameReplicationInfo.StartTimeRemaining;
				for( P = Level.PawnList; P!=None; P=P.NextPawn )
         			if( P.IsA('TournamentPlayer') )
            			TournamentPlayer(P).TimeMessage(LeagueASGameReplicationInfo.StartTimeRemaining);
				}
   			}
		if(LeagueASGameReplicationInfo.StartTimeRemaining == 0)  // force level to start
   			{
				if ( !bGameEnded && bMatchMode && bRequireReady )
					{
					bNetReady = False;
					bRequireReady = False;
					StartMatch();
					}
   					LeagueASGameReplicationInfo.StartTimeRemaining = -1;
  			}
		}
}
//************************************************************************************************
event PreBeginPlay()
{
	local int x;
	local mutator M;
	local Pawn P;
		
	Super.PreBeginPlay();

	bGameStarted = false;

	LeagueASGameReplicationInfo = LeagueAS_GameReplicationInfo(GameReplicationInfo);
	
	class'TeamCannon'.Default.Health=100;
	class'MinigunCannon'.Default.Health=100;

	TweakMaps();

	//Set standard AS Settings
	If ( bStandardise )
		{
		bHardCoreMode = True;
		bChallengeMode = False;
		bMultiWeaponStay=True;
		AirControl=0.350000;
		SetGameSpeed(1);	
		}

	//If Match disable practice mode.
	if ( bMatchMode )
		bPracticeMode = false;

}
//************************************************************************************************
function bool GetRule( out string Rules, out string Result )
{

	if( Left(Rules,1)=="\\" )
	{
		// Get result.
		Result = Mid(Rules,1);
		if( InStr(Result,"\\")>=0 )
			Result = Left( Result, InStr(Result,"\\") );

		// Update options.
		Rules = Mid(Rules,1);
		if( InStr(Rules,"\\")>=0 )
			Rules = Mid( Rules, InStr(Rules,"\\") );
		else
			Rules = "";

		return true;
	}
	else return false;

}
//************************************************************************************************
event BeginPlay()
{

	local int FortCount, i;
	local FortStandard F;
	local string ServerRules, Rule;
	local bool ServerHasPass;

	Super.BeginPlay();

	TeamColor[0] = TeamNameRed;
	TeamColor[1] = TeamNameBlue;

	ServerRules = GetRules();

	while( GetRule( ServerRules, Rule ) )
		{
		log(Rule);
		if( Rule ~= "password" )
			{
			GetRule( ServerRules, Rule );
			ServerHasPass = (Rule ~= "True" );
			break;
			}
		}

	if ( bMatchMode )
		{	
		LeagueASGameReplicationInfo.StartTimeRemaining = SubsequentMapStartTime;
		SetScoreStrings(TeamColor[0]@TeamScore[0]@"-"@TeamScore[1]@TeamColor[1]$".");
		LeagueASGameReplicationInfo.bMatchModeEnabled = true;
		}
	else
		{
		MapsLeft = 0;
		LeagueASGameReplicationInfo.StartTimeRemaining = -1;
		TeamScore[0] = 0;
		TeamScore[1] = 0;
		if ( ServerHasPass )
			SetScoreStrings("LOCKED - PRIVATE");
		else
			SetScoreStrings("OPEN - PUBLIC");
		}

		TeamChangeMessage = "Type 'ChangeTeams' to change teams.";
	
	//Set up HUD objective INFO
	FortCount = 0;
	ForEach AllActors(class'FortStandard', F)     
		{
		if (F.FortName == "Assault Target")
			LeagueASGameReplicationInfo.FortName[FortCount] = string(F);
		else if ((F.FortName == "") || (F.FortName == " "))
			LeagueASGameReplicationInfo.FortName[FortCount] = string(F);
		else
			LeagueASGameReplicationInfo.FortName[FortCount] = F.FortName;
		LeagueASGameReplicationInfo.FortCompleted[FortCount] = "Not Complete!";
		FortCount++;
		}

	SaveConfig();
}
//************************************************************************************************
function PostBeginPlay()
{
	Super.PostBeginPlay();
	TeamColor[0] = TeamNameRed;
	TeamColor[1] = TeamNameBlue;
	Teams[0].TeamName = TeamNameRed;
	Teams[1].TeamName = TeamNameBlue;
}
//************************************************************************************************
function SendStartMessage(PlayerPawn P)
{

	ObjectivesMessage = GameName@VersionStr;
	Super.SendStartMessage(P);

}
//************************************************************************************************

defaultproperties
{
      bMatchMode=False
      bPracticeMode=False
      bAdminOnlySpectators=False
      bStandardise=True
      bAdminNameScore=False
      MapVoteChangeLimit=0
      TeamScore(0)=0
      TeamScore(1)=0
      MapsLeft=0
      MatchLength=14
      FirstMapStartTime=300
      SubsequentMapStartTime=60
      TeamNameRed="Red"
      TeamNameBlue="Blue"
      MapsWon(0)=""
      MapsWon(1)=""
      ModeratorPassword="moderator"
      MatchPasswordRed=""
      MatchPasswordBlue=""
      VersionStr="V1.11"
      LeagueASGameReplicationInfo=None
      ModList(0)=None
      ModList(1)=None
      ModList(2)=None
      ModList(3)=None
      ModList(4)=None
      ModList(5)=None
      ModList(6)=None
      ModList(7)=None
      ModList(8)=None
      ModList(9)=None
      ModList(10)=None
      ModList(11)=None
      bGameStarted=False
      MapsTweaked=False
      TeamChangeTime=0.000000
      ScoreBoardType=Class'LeagueAS111.LeagueAS_Scoreboard'
      GameName="utassault.net League Assault"
      MutatorClass=Class'LeagueAS111.LeagueAS_Mutator'
      GameReplicationInfoClass=Class'LeagueAS111.LeagueAS_GameReplicationInfo'
}
