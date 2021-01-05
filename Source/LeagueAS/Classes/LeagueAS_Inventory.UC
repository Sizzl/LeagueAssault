//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_Inventory extends Inventory;

var Pawn PlayerOwner;
var LeagueAssault LeagueAssaultGame;
var bool SpawnProtectActive, Initialized;
var vector OwnerStartPosition;
var int Counter, Count;

//************************************************************************************************
replication {

    Reliable if (Role<Role_Authority)
		ModeratorLogin, ModeratorLogout, Moderator, ShowMatchScore, ChangeTeams, SummonItem;

}
//************************************************************************************************
event Spawned()
{
	PlayerOwner = Pawn(Owner);
	LeagueAssaultGame = LeagueAssault(Level.Game);
	SaveConfig();
}
//************************************************************************************************
exec function StartMatch()
{
	if ( !LeagueAssaultGame.bGameEnded && (PlayerPawn(PlayerOwner).bAdmin || (Level.Netmode == NM_Standalone)) )
		LeagueAssaultGame.PEFStartMatch(PlayerPawn(PlayerOwner));
}
//************************************************************************************************
exec function EndMatch()
{
	if ((PlayerPawn(PlayerOwner).bAdmin || (Level.Netmode == NM_Standalone)) && LeagueAssaultGame.bMatchMode)
		LeagueAssaultGame.PEFEndMatch();
}
//************************************************************************************************
exec function ResetTeamNames()
{
	if (PlayerPawn(PlayerOwner).bAdmin || (Level.Netmode == NM_Standalone))
		LeagueAssaultGame.PEFResetTeamNames();
}
//************************************************************************************************
exec function TogglePracticeMode()
{
	if (PlayerPawn(PlayerOwner).bAdmin || (Level.Netmode == NM_Standalone))
		LeagueAssaultGame.PEFTogglePracticeMode();
}
//************************************************************************************************
exec function VoidMapRed()
{
	if (PlayerPawn(PlayerOwner).bAdmin || (Level.Netmode == NM_Standalone))
		LeagueAssaultGame.PEFVoidMap(PlayerPawn(PlayerOwner), 0);
}
//************************************************************************************************
exec function VoidMapBlue()
{
	if (PlayerPawn(PlayerOwner).bAdmin || (Level.Netmode == NM_Standalone))
		LeagueAssaultGame.PEFVoidMap(PlayerPawn(PlayerOwner), 1);
}
//************************************************************************************************
exec function ModeratorLogin( string ModPassword )
{
	If (!LeagueAssaultGame.bMatchMode)
		LeagueAssaultGame.AddModerator(PlayerPawn(PlayerOwner), MoDPassword);	
}
//************************************************************************************************
exec function ModeratorLogout()
{
	LeagueAssaultGame.RemoveModerator(PlayerPawn(PlayerOwner));	
}
//************************************************************************************************
exec function Moderator( string CommandLine )
{
	local string Command;
	
	If (LeagueAssaultGame.IsAModerator(PlayerPawn(PlayerOwner)))
		{
		Command = Left(CommandLine, InStr(CommandLine, " "));		
		if ((Command) ~= "servertravel")
			{
			ConsoleCommand( CommandLine );
			Log(PlayerOwner.PlayerReplicationInfo.PlayerName@"issued moderator command:"@CommandLine$".");
			}
		else if ( (Command ~= "kick") || (Command ~= "summon") || (Command ~= "stopcountdown") )
			{
			PlayerPawn(PlayerOwner).bAdmin = true;
			PlayerPawn(PlayerOwner).Kick(Mid(CommandLine, (InStr(CommandLine, " ") + 1), (Len(CommandLine) - InStr(CommandLine, " "))));
			PlayerPawn(PlayerOwner).bAdmin = false;
			Log(PlayerOwner.PlayerReplicationInfo.PlayerName@"issued moderator command:"@CommandLine$".");
			}
		else
			PlayerOwner.ClientMessage("Unrecognised or Unauthorised command.");
		}
}
//************************************************************************************************
exec function StopCountDown()
{
	if ( !LeagueAssaultGame.bGameEnded || PlayerPawn(PlayerOwner).bAdmin || (Level.Netmode == NM_Standalone))
		{
		LeagueAssaultGame.GameReplicationInfo.bStopCountDown = True;
		LeagueAssaultGame.GameReplicationInfo.RemainingTime = 0;
		LeagueAssaultGame.GameReplicationInfo.RemainingMinute = 0;
		LeagueAssaultGame.TimeLimit = 0;
		LeagueAssaultGame.RemainingTime = 0;
		LeagueAssaultGame.SavedTime = 0;
		LeagueAssaultGame.bDefenseSet = true;
		}
}
//************************************************************************************************
exec function ShowMatchScore()
{
	if (LeagueAssaultGame.bMatchMode)
		LeagueAssaultGame.PEFShowScores(PlayerPawn(PlayerOwner));
}
//************************************************************************************************
exec function ChangeTeams()
{	
	LeagueAssaultGame.PEFChangeTeams(PlayerPawn(PlayerOwner));
}
//************************************************************************************************
exec function SummonItem(string ClassName)
{	
	local class<actor> NewClass;

	If (!LeagueAssaultGame.bMatchMode && (LeagueAssaultGame.bPracticeMode))
		{
		NewClass = class<actor>( DynamicLoadObject( "BotPack."$ClassName, class'Class' ) );
		if( NewClass!=None )
			Spawn( NewClass,,,PlayerOwner.Location + 72 * Vector(PlayerOwner.Rotation) + vect(0,0,1) * 15 );
		BroadcastMessage(PlayerOwner.PlayerReplicationInfo.PlayerName@"-> Summon"@ClassName, true, 'CriticalEvent');
		}
		
}
//************************************************************************************************
function ActivateSpawnProtection()
{
	if ( (PlayerOwner == None) )
		{
		Destroy();
		return;
		}
	if ( PlayerOwner.PlayerReplicationInfo.Team == LeagueAssaultGame.Attacker.TeamIndex )
		Counter = 20;
	else
		Counter = 10;
	Count = Counter;
	PlayerOwner.Style = STY_Translucent;
	PlayerOwner.ScaleGlow = 0;
	SpawnProtectActive = true;
	SetTimer(0.2, True);
}
//************************************************************************************************
function InventoryTakeDamage(out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType)
{
	local float DamageTaken, DamageTakenByBoost;

	if ( SpawnProtectActive && (Victim != InstigatedBy) )
		{
		ActualDamage = 0;
		Momentum = vect(0,0,0);
		}
}
//************************************************************************************************
function Timer()
{
	if ( PlayerOwner == None )
		Destroy();
	if ( !Initialized && ((Location.X != PlayerOwner.Location.X) || (Location.Y != PlayerOwner.Location.Y)) )
		Initialized = True;
	if ( (OwnerStartPosition.X == 0) && (OwnerStartPosition.Y == 0)	)
		{
			OwnerStartPosition.X = PlayerOwner.Location.X;
			OwnerStartPosition.Y = PlayerOwner.Location.Y;
		}
	if ( SpawnProtectActive && Initialized && ((PlayerOwner.Location.X != OwnerStartPosition.X) || (PlayerOwner.Location.Y != OwnerStartPosition.Y)) )
	{
		if ( Count < 0 )
		{
			SpawnProtectActive = False;
			PlayerOwner.Style = PlayerOwner.Default.Style;
			PlayerOwner.ScaleGlow = PlayerOwner.Default.ScaleGlow;
		}
		else
			PlayerOwner.ScaleGlow = (1 / Counter) * (Counter - Count--);
	}
}
//************************************************************************************************

defaultproperties
{
      PlayerOwner=None
      LeagueAssaultGame=None
      SpawnProtectActive=False
      Initialized=False
      OwnerStartPosition=(X=0.000000,Y=0.000000,Z=0.000000)
      Counter=0
      Count=0
}
