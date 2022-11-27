//================================================================================
// LeagueAS_Inventory.
//================================================================================

class LeagueAS_Inventory extends Inventory
  NoNativeReplication;

var Pawn PlayerOwner;
var LeagueAssault LeagueAssaultGame;
var bool SpawnProtectActive;
var bool Initialized;
var Vector OwnerStartPosition;
var int Counter;
var int Count;

replication
{
  reliable if ( Role < ROLE_Authority )
    ThrowArmour,AdvancedSay,AdvancedTeamSay,SummonItem,Echo,ToggleMute,ChangeTeams,ShowMatchScore,Moderator,ModeratorLogout,ModeratorLogin;
}

event Spawned ()
{
  PlayerOwner = Pawn(Owner);
  LeagueAssaultGame = LeagueAssault(Level.Game);
  SaveConfig();
}

exec function StartMatch ()
{
  if (  !LeagueAssaultGame.bGameEnded && (PlayerPawn(PlayerOwner).bAdmin || (Level.NetMode == 0)) )
  {
    LeagueAssaultGame.PEFStartMatch(PlayerPawn(PlayerOwner));
  }
}

exec function EndMatch ()
{
  if ( (PlayerPawn(PlayerOwner).bAdmin || (Level.NetMode == 0)) && LeagueAssaultGame.bMatchMode )
  {
    LeagueAssaultGame.PEFEndMatch();
  }
}

exec function ResetTeamNames ()
{
  if ( PlayerPawn(PlayerOwner).bAdmin || (Level.NetMode == 0) )
  {
    LeagueAssaultGame.PEFResetTeamNames();
  }
}

exec function TogglePracticeMode ()
{
  if ( PlayerPawn(PlayerOwner).bAdmin || (Level.NetMode == 0) )
  {
    LeagueAssaultGame.PEFTogglePracticeMode();
  }
}

exec function VoidMapRed ()
{
  if ( PlayerPawn(PlayerOwner).bAdmin || (Level.NetMode == 0) )
  {
    LeagueAssaultGame.PEFVoidMap(PlayerPawn(PlayerOwner),0);
  }
}

exec function VoidMapBlue ()
{
  if ( PlayerPawn(PlayerOwner).bAdmin || (Level.NetMode == 0) )
  {
    LeagueAssaultGame.PEFVoidMap(PlayerPawn(PlayerOwner),1);
  }
}

exec function ShowMatchLog ()
{
  if ( PlayerPawn(PlayerOwner).bAdmin || (Level.NetMode == 0) )
  {
    PlayerPawn(PlayerOwner).ClientMessage(LeagueAssaultGame.Matchlog);
  }
}

exec function ClearMatchLog ()
{
  if ( PlayerPawn(PlayerOwner).bAdmin || (Level.NetMode == 0) )
  {
    LeagueAssaultGame.Matchlog = "";
    LeagueAssaultGame.SaveConfig();
  }
}

exec function ModeratorLogin (string ModPassword)
{
  if (  !LeagueAssaultGame.bMatchMode )
  {
    LeagueAssaultGame.AddModerator(PlayerPawn(PlayerOwner),ModPassword);
  }
}

exec function ModeratorLogout ()
{
  LeagueAssaultGame.RemoveModerator(PlayerPawn(PlayerOwner));
}

exec function Moderator (string CommandLine)
{
  local string Command;

  if ( LeagueAssaultGame.IsAModerator(PlayerPawn(PlayerOwner)) )
  {
    Command = Left(CommandLine,InStr(CommandLine," "));
    if ( Command ~= "servertravel" )
    {
      ConsoleCommand(CommandLine);
      Log(PlayerOwner.PlayerReplicationInfo.PlayerName @ "issued moderator command:" @ CommandLine $ ".");
    } else {
      if ( Command ~= "kick" )
      {
        PlayerPawn(PlayerOwner).bAdmin = True;
        PlayerPawn(PlayerOwner).Kick(Mid(CommandLine,InStr(CommandLine," ") + 1,Len(CommandLine) - InStr(CommandLine," ")));
        PlayerPawn(PlayerOwner).bAdmin = False;
        Log(PlayerOwner.PlayerReplicationInfo.PlayerName @ "issued moderator command:" @ CommandLine $ ".");
      } else {
        if ( Command ~= "summon" )
        {
          PlayerPawn(PlayerOwner).bAdmin = True;
          PlayerPawn(PlayerOwner).Summon(Mid(CommandLine,InStr(CommandLine," ") + 1,Len(CommandLine) - InStr(CommandLine," ")));
          PlayerPawn(PlayerOwner).bAdmin = False;
          Log(PlayerOwner.PlayerReplicationInfo.PlayerName @ "issued moderator command:" @ CommandLine $ ".");
        } else {
          if ( CommandLine ~= "stopcountdown" )
          {
            StopCountDown();
          } else {
            PlayerOwner.ClientMessage("Unrecognised or unauthorised command.");
          }
        }
      }
    }
  }
}

exec function StopCountDown ()
{
  if (  !LeagueAssaultGame.bGameEnded && (PlayerPawn(PlayerOwner).bAdmin || LeagueAssaultGame.IsAModerator(PlayerPawn(PlayerOwner)) || (Level.NetMode == 0)) )
  {
    LeagueAssaultGame.GameReplicationInfo.bStopCountDown = True;
    LeagueAssaultGame.GameReplicationInfo.RemainingTime = 0;
    LeagueAssaultGame.GameReplicationInfo.RemainingMinute = 0;
    LeagueAssaultGame.TimeLimit = 0;
    LeagueAssaultGame.RemainingTime = 0;
    LeagueAssaultGame.SavedTime = 0.0;
    LeagueAssaultGame.bDefenseSet = True;
  }
}

exec function ForceMatchStart ()
{
  if ( PlayerPawn(PlayerOwner).bAdmin )
  {
    LeagueAssaultGame.PEFForceMatchStart();
  }
}

exec function ShowMatchScore ()
{
  if ( LeagueAssaultGame.bMatchMode )
  {
    LeagueAssaultGame.PEFShowScores(PlayerPawn(PlayerOwner));
  }
}

exec function ChangeTeams ()
{
  LeagueAssaultGame.PEFChangeTeams(PlayerPawn(PlayerOwner));
}

exec function ToggleMute ()
{
  local ClientOptions CO;
  local LeagueAS_ExtPlayerReplicationInfo ePRI;

  foreach AllActors( Class'ClientOptions', CO )
  {
    if ( PlayerOwner==CO.Owner )
    {
      break;
    }
  }
  if ( CO.bMuteSay )
  {
    if ( CO.bMuteAll )
    {
      CO.bMuteSay = false;
      CO.bMuteAll = false;
      PlayerPawn(Owner).ClientMessage( "Mute OFF." );
    }
    else
    {
      CO.bMuteSay = true;
      CO.bMuteAll = true;
      PlayerPawn(Owner).ClientMessage( "Mute ALL Messages." );
    }
  }
  else
  {
    CO.bMuteSay = true;
    CO.bMuteAll = false;
    PlayerPawn(Owner).ClientMessage( "Mute ENEMY Messages." );
  }
  foreach AllActors( Class'LeagueAS_ExtPlayerReplicationInfo', ePRI )
  {
    if ( PlayerOwner==ePRI.Owner )
    {
      ePRI.bMuteSay = CO.bMuteSay;
      ePRI.bMuteAll = CO.bMuteAll;
    }
  }
  CO.CopyMuteOption( CO.bMuteSay, CO.bMuteAll );
}

exec function Echo (string EchoStr)
{
  PlayerPawn(PlayerOwner).ClientMessage(EchoStr);
}

exec function SummonItem (string ClassName)
{
  local Class<Actor> NewClass;

  if (  !LeagueAssaultGame.bMatchMode && LeagueAssaultGame.bPracticeMode )
  {
    NewClass = Class<Actor>(DynamicLoadObject("BotPack." $ ClassName,Class'Class'));
    if ( NewClass != None )
    {
      Spawn(NewClass,,,PlayerOwner.Location + 72 * vector(PlayerOwner.Rotation) + vect(0.00,0.00,1.00) * 15);
    }
    BroadcastMessage(PlayerOwner.PlayerReplicationInfo.PlayerName @ "-> Summon" @ ClassName,True,'CriticalEvent');
  }
}

exec function AdvancedTeamSay (string Text)
{
  LeagueAssaultGame.PEFAdvancedTeamSay(Text,PlayerPawn(PlayerOwner));
}

exec function AdvancedSay (string Text)
{
  LeagueAssaultGame.PEFAdvancedSay(Text,PlayerPawn(PlayerOwner));
}

exec function ThrowArmour (int ArmourType)
{
  LeagueAssaultGame.PEFThrowArmour(ArmourType,PlayerPawn(PlayerOwner));
}

function ActivateSpawnProtection ()
{
  if ( PlayerOwner == None )
  {
    Destroy();
    return;
  }
  if ( PlayerOwner.PlayerReplicationInfo.Team == LeagueAssaultGame.Attacker.TeamIndex )
  {
    Counter = 20;
  } else {
    Counter = 10;
  }
  Count = Counter;
  PlayerOwner.Style = 3;
  PlayerOwner.ScaleGlow = 0.0;
  SpawnProtectActive = True;
  SetTimer(0.2,True);
}

function InventoryTakeDamage (out int actualDamage, Pawn Victim, Pawn instigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType)
{
  if ( SpawnProtectActive && (Victim != instigatedBy) )
  {
    actualDamage = 0;
    Momentum = vect(0.00,0.00,0.00);
  }
}

function Timer ()
{
  if ( PlayerOwner == None )
  {
    Destroy();
  }
  if (  !Initialized && ((Location.X != PlayerOwner.Location.X) || (Location.Y != PlayerOwner.Location.Y)) )
  {
    Initialized = True;
  }
  if ( (OwnerStartPosition.X == 0) && (OwnerStartPosition.Y == 0) )
  {
    OwnerStartPosition.X = PlayerOwner.Location.X;
    OwnerStartPosition.Y = PlayerOwner.Location.Y;
  }
  if ( SpawnProtectActive && Initialized && ((PlayerOwner.Location.X != OwnerStartPosition.X) || (PlayerOwner.Location.Y != OwnerStartPosition.Y)) )
  {
    if ( Count < 0 )
    {
      PlayerOwner.ClientMessage("Spawn protection has worn off.");
      SpawnProtectActive = False;
      PlayerOwner.Style = PlayerOwner.Default.Style;
      PlayerOwner.ScaleGlow = PlayerOwner.Default.ScaleGlow;
    } else {
      PlayerOwner.ScaleGlow = 1.0 / Counter * (Counter - Count-- );
    }
  }
}

