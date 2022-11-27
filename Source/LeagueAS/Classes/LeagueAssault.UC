//================================================================================
// LeagueAssault.
//================================================================================

class LeagueAssault extends LeagueAS_LAAbstract;

var() config bool bngStatsCompatibility;
var() config bool bEnableCSHP;
var() config bool bAttackOnly;
var() config bool bMatchMode;
var() config bool bPracticeMode;
var() config bool bStandardise;
var() config bool bAuthorisePlayers;
var() config bool bAdminNameScore;
var() config bool bServerNameScore;
var() config bool bAutoPausing;
var() config int MaxPauseTime;
var() config int TeamScore[2];
var() config int MapsLeft;
var() config int MatchLength;
var() config int FirstMapStartTime;
var() config int SubsequentMapStartTime;
var() config string TeamNameRed;
var() config string TeamNameBlue;
var() config string MapsWon[2];
var() config string Matchlog;
var() config private string ModeratorPassword;
var() config private string MatchPasswordRed;
var() config private string MatchPasswordBlue;
var() config private string MatchPasswordSpec;
var string VersionStr;
var string SubVersionStr;
var string OldServerName;
var LeagueAS_GameReplicationInfo LeagueASGameReplicationInfo;
var private PlayerPawn ModList[12];
var bool bMapStarted;
var bool bMapEnded;
var float TeamChangeTime;
var LeagueAS_SSDAbstract ServerSetupDataLink;
var LeagueAS_PADAbstract PlayerAuthDataLink;
var LeagueAS_SSMAbstract ServerSideModule;
var HackProtection CSHP;
var LeagueAS_AutoPauser AutoPauser;

function SetPassword (int Team, string Pass)
{
  if ( Team == 0 )
  {
    MatchPasswordRed = Pass;
  } else {
    if ( Team == 1 )
    {
      MatchPasswordBlue = Pass;
    } else {
      if ( Team == 2 )
      {
        ModeratorPassword = Pass;
      }
    }
  }
}

function SetScoreStrings (string InScore)
{
  LeagueASGameReplicationInfo.MatchScore = InScore;
  if ( bAdminNameScore )
  {
    LeagueASGameReplicationInfo.AdminName = LeagueASGameReplicationInfo.MatchScore;
  }
  if ( bServerNameScore )
  {
    if ( OldServerName == "" )
    {
      OldServerName = LeagueASGameReplicationInfo.ServerName;
    }
    LeagueASGameReplicationInfo.ServerName = OldServerName @ "[" $ LeagueASGameReplicationInfo.MatchScore $ "]";
  }
}

function int GetWinningTeam ()
{
  if ( bDefenseSet )
  {
    if ( bAssaultWon )
    {
      return Attacker.TeamIndex;
    } else {
      if (  !bTiePartOne )
      {
        return Defender.TeamIndex;
      } else {
        return -1;
      }
    }
  } else {
    return -1;
  }
}

function AddModerator (PlayerPawn Moderator, string Password)
{
  local int i;

  if ( ModeratorPassword == "" )
  {
    return;
  }
  if (  !IsAModerator(Moderator) && (Password == ModeratorPassword) )
  {
    Log(Moderator.PlayerReplicationInfo.PlayerName @ "became a server moderator.",'LeagueAssault');
    BroadcastMessage(Moderator.PlayerReplicationInfo.PlayerName @ "became a server moderator.");
    i = 0;
    while ( i < 12 )
    {
      if ( ModList[i] == None )
      {
        ModList[i] = Moderator;
        return;
      }
      i++;
    }
  }
}

function bool IsAModerator (PlayerPawn Moderator)
{
  local int i;

JL0014:
  if ( Moderator == None )
  {
    return False;
  }
  i = 0;
  while ( i < 12 )
  {
    if ( ModList[i] == Moderator )
    {
      return True;
    }
    i++;
  }
  return False;
}

function RemoveModerator (PlayerPawn Moderator)
{
  local int i;

  i = 0;
  while ( i < 12 )
  {
    if ( ModList[i] == Moderator )
    {
      ModList[i] = None;
      Log(Moderator.PlayerReplicationInfo.PlayerName @ "gave up moderator abilities.",'LeagueAssault');
      BroadcastMessage(Moderator.PlayerReplicationInfo.PlayerName @ "gave up moderator abilities.");
    }
    i++;
  }
}

function float DistanceFrom (Actor P1, Actor P2)
{
  local float DistanceX;
  local float DistanceY;
  local float DistanceZ;
  local float ADistance;

  DistanceX = P1.Location.X - P2.Location.X;
  DistanceY = P1.Location.Y - P2.Location.Y;
  DistanceZ = P1.Location.Z - P2.Location.Z;
  ADistance = Sqrt(Square(DistanceX) + Square(DistanceY) + Square(DistanceZ));
  return ADistance;
}

function string NearestObj (PlayerPawn Sender)
{
  local FortStandard F;
  local FortStandard NearestFort;
  local float DistToNearestFort;
  local float ThisFortDist;

  DistToNearestFort = 0.0;
  foreach AllActors(Class'FortStandard',F)
  {
    ThisFortDist = DistanceFrom(Sender,F);
    if ( (DistToNearestFort == 0) || (ThisFortDist < DistToNearestFort) )
    {
      NearestFort = F;
      DistToNearestFort = ThisFortDist;
    }
  }
  if ( NearestFort.FortName == "Assault Target" )
  {
    return string(NearestFort);
  } else {
    if ( (NearestFort.FortName == "") || (NearestFort.FortName == " ") )
    {
      return string(NearestFort);
    } else {
      return NearestFort.FortName;
    }
  }
}

function int GetArmourAmount (Pawn P)
{
  local int ArmorAmount;
  local Inventory Inv;

  ArmorAmount = 0;
  Inv = P.Inventory;
  while ( Inv != None )
  {
    if ( Inv.bIsAnArmor )
    {
      ArmorAmount += Inv.Charge;
    }
    Inv = Inv.Inventory;
  }
  return ArmorAmount;
}

function string ProcessAdvancedSay (string Text, PlayerPawn Sender)
{
  local string TagName;
  local string FinalText;
  local string LocationStr;
  local string C;
  local bool StartTag;
  local int i;

  i = 0;
  while ( i < Len(Text) )
  {
    C = Mid(Text,i,1);
    if ( C == "%" )
    {
      if ( StartTag )
      {
        if ( TagName ~= "LOCATION" )
        {
          if ( Sender.PlayerReplicationInfo.PlayerLocation != None )
          {
            LocationStr = Sender.PlayerReplicationInfo.PlayerLocation.LocationName;
          } else {
            if ( Sender.PlayerReplicationInfo.PlayerZone != None )
            {
              LocationStr = Sender.PlayerReplicationInfo.PlayerZone.ZoneName;
            } else {
              LocationStr = "UNKNOWN";
            }
          }
          if ( LocationStr == "" )
          {
            LocationStr = "UNKNOWN";
          }
          FinalText = FinalText $ LocationStr;
        } else {
          if ( TagName ~= "HEALTH" )
          {
            FinalText = FinalText $ string(Sender.Health);
          } else {
            if ( TagName ~= "ARMOUR" )
            {
              FinalText = FinalText $ string(GetArmourAmount(Sender));
            } else {
              if ( TagName ~= "WEAPON" )
              {
                FinalText = FinalText $ Sender.Weapon.ItemName;
              } else {
                if ( TagName ~= "AMMO" )
                {
                  FinalText = FinalText $ string(Sender.Weapon.AmmoType.AmmoAmount);
                } else {
                  if ( TagName ~= "MYNAME" )
                  {
                    FinalText = FinalText $ Sender.PlayerReplicationInfo.PlayerName;
                  } else {
                    if ( TagName ~= "MYTEAM" )
                    {
                      FinalText = FinalText $ TeamColor[Sender.PlayerReplicationInfo.Team];
                    } else {
                      if ( TagName ~= "ENEMYTEAM" )
                      {
                        if ( Sender.PlayerReplicationInfo.Team == 0 )
                        {
                          FinalText = FinalText $ TeamColor[1];
                        } else {
                          FinalText = FinalText $ TeamColor[0];
                        }
                      } else {
                        if ( TagName ~= "OBJECTIVE" )
                        {
                          FinalText = FinalText $ NearestObj(Sender);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        TagName = "";
      }
      StartTag =  !StartTag;
    } else {
      if ( StartTag )
      {
        TagName = TagName $ C;
      } else {
        FinalText = FinalText $ C;
      }
    }
    i++;
  }
  return FinalText;
}

function PEFThrowArmour (int ArmourType, PlayerPawn Sender)
{
  local Vector X;
  local Vector Y;
  local Vector Z;
  local Inventory Inv;

  if ( (ArmourType < 1) || (ArmourType > 3) )
  {
    Inv = Sender.FindInventoryType(Class'ThighPads');
    if ( Inv == None )
    {
      Inv = Sender.FindInventoryType(Class'Armor2');
    }
    if ( Inv == None )
    {
      Inv = Sender.FindInventoryType(Class'UT_ShieldBelt');
    }
    if ( Inv != None )
    {
      Inv.Velocity = vector(Sender.ViewRotation) * 500 + vect(0.00,0.00,220.00);
      Inv.bTossedOut = True;
      GetAxes(Sender.Rotation,X,Y,Z);
      Inv.DropFrom(Sender.Location + 0.81 * Sender.CollisionRadius * X +  -0.5 * Sender.CollisionRadius * Y);
      if ( Inv.IsA('UT_ShieldBelt') )
      {
        UT_ShieldBelt(Inv).MyEffect.Destroy();
      }
    }
  } else {
    Inv = Sender.Inventory;
    while ( Inv != None )
    {
      if ( Inv.IsA('ThighPads') && (ArmourType == 1) || Inv.IsA('Armor2') && (ArmourType == 2) || Inv.IsA('UT_ShieldBelt') && (ArmourType == 3) )
      {
        Inv.Velocity = vector(Sender.ViewRotation) * 500 + vect(0.00,0.00,220.00);
        Inv.bTossedOut = True;
        GetAxes(Sender.Rotation,X,Y,Z);
        Inv.DropFrom(Sender.Location + 0.81 * Sender.CollisionRadius * X +  -0.5 * Sender.CollisionRadius * Y);
        if ( Inv.IsA('UT_ShieldBelt') )
        {
          UT_ShieldBelt(Inv).MyEffect.Destroy();
        }
      }
      Inv = Inv.Inventory;
    }
  }
}

function PEFAdvancedTeamSay (string Text, PlayerPawn Sender)
{
  local Pawn P;
  local string FinalMsg;

  FinalMsg = ProcessAdvancedSay(Text,Sender);
  P = Level.PawnList;
  while ( P != None )
  {
    if ( P.IsA('PlayerPawn') && (PlayerPawn(P).PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team) )
    {
      if ( Level.Game.MessageMutator.MutatorTeamMessage(Sender,P,Sender.PlayerReplicationInfo,FinalMsg,'Say',True) )
      {
        PlayerPawn(P).TeamMessage(Sender.PlayerReplicationInfo,FinalMsg,'Say',True);
      }
    }
    P = P.nextPawn;
  }
}

function PEFAdvancedSay (string Text, PlayerPawn Sender)
{
  local Pawn P;
  local string FinalMsg;

  FinalMsg = ProcessAdvancedSay(Text,Sender);
  P = Level.PawnList;
  while ( P != None )
  {
    if ( P.IsA('PlayerPawn') )
    {
      if ( Level.Game.MessageMutator.MutatorTeamMessage(Sender,P,Sender.PlayerReplicationInfo,FinalMsg,'Say',True) )
      {
        PlayerPawn(P).TeamMessage(Sender.PlayerReplicationInfo,FinalMsg,'Say',True);
      }
    }
    P = P.nextPawn;
  }
}

function PEFChangeTeams (PlayerPawn Sender)
{
  if (  !bMatchMode )
  {
    if ( (Sender.PlayerReplicationInfo.Team < MaxAllowedTeams) && (Level.TimeSeconds > TeamChangeTime) )
    {
      if ( Sender.PlayerReplicationInfo.Team == Attacker.TeamIndex )
      {
        Sender.ChangeTeam(Defender.TeamIndex);
      } else {
        Sender.ChangeTeam(Attacker.TeamIndex);
      }
      TeamChangeTime = Level.TimeSeconds + 2;
    }
  }
}

function PEFResetTeamNames ()
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

function PEFTogglePracticeMode ()
{
  local Pawn P;

  bPracticeMode =  !bPracticeMode;
  if ( bPracticeMode )
  {
    BroadcastMessage("PRACTICE MODE ENABLED!");
  } else {
    BroadcastMessage("PRACTICE MODE DISABLED!");
  }
  SaveConfig();
  if ( bPracticeMode )
  {
    P = Level.PawnList;
    while ( P != None )
    {
      if ( P.IsA('PlayerPawn') )
      {
        P.ReducedDamageType = 'All';
      }
      P = P.nextPawn;
    }
  } else {
    P = Level.PawnList;
    while ( P != None )
    {
      if ( P.IsA('PlayerPawn') )
      {
        P.ReducedDamageType = 'None';
      }
      P = P.nextPawn;
    }
  }
}

function PEFStartMatch (PlayerPawn Sender)
{
  if (  !bTournament )
  {
    Sender.ClientMessage("Tournament mode must be active to start a match!");
    return;
  }
  if ( bMapStarted )
  {
    Sender.ClientMessage("Cannot start a match after game has started!");
    return;
  }
  if ( bMatchMode )
  {
    Sender.ClientMessage("Match in progress, please end current match before starting new one.");
    return;
  }
  TeamColor[0] = TeamNameRed;
  TeamColor[1] = TeamNameBlue;
  Teams[0].TeamName = TeamNameRed;
  Teams[1].TeamName = TeamNameBlue;
  TeamChangeMessage = "Match in progress. Team Changing Disabled!";
  LeagueASGameReplicationInfo.StartTimeRemaining = FirstMapStartTime;
  bMatchMode = True;
  LeagueASGameReplicationInfo.bMatchModeEnabled = True;
  BroadcastMessage("Starting Match Countdown...",True);
  TeamScore[0] = 0;
  TeamScore[1] = 0;
  MapsWon[0] = "";
  MapsWon[1] = "";
  SetScoreStrings(TeamColor[0] @ "0 - 0" @ TeamColor[1]);
  MapsLeft = MatchLength + 1;
  bPracticeMode = False;
  RemainingTime = 120;
  SavedTime = 120.0;
  bDefenseSet = True;
  SaveConfig();
}

function PEFEndMatch ()
{
  BroadcastMessage("Match will terminate after current map is complete!",True);
  MapsLeft = 1;
}

function PEFVoidMap (PlayerPawn Sender, int TeamNum)
{
  Sender.ClientMessage("Voided Map...");
  TeamScore[TeamNum]--;
  MapsLeft++;
  PEFShowScores(Sender);
}

function PEFShowScores (PlayerPawn Sender)
{
  Sender.ClientMessage(TeamColor[0] @ " -" @ string(TeamScore[0]));
  Sender.ClientMessage(TeamColor[1] @ " -" @ string(TeamScore[1]));
  if ( MapsLeft == 0 )
  {
    Sender.ClientMessage("THE MATCH HAS ENDED!");
  } else {
    if ( MapsLeft == 1 )
    {
      Sender.ClientMessage("1 MAP REMAINING...");
    } else {
      Sender.ClientMessage(string(MapsLeft) @ "MAPS REMAINING...");
    }
  }
}

function PEFForceMatchStart ()
{
  if ( bRequireReady && (CountDown > 0) && (LeagueASGameReplicationInfo.StartTimeRemaining > 0) )
  {
    bNetReady = False;
    bRequireReady = False;
    StartMatch();
  }
}

event PreLogin (string Options, string Address, out string Error, out string FailCode)
{
  local string InPassword;
  local string OvClass;

  Super.PreLogin(Options,Address,Error,FailCode);
  InPassword = ParseOption(Options,"Password");
  OvClass = ParseOption(Options,"OverrideClass");
  if ( bMatchMode && (MatchPasswordRed != "") && (MatchPasswordBlue != "") )
  {
    if ( Caps(InPassword) == Caps(MatchPasswordRed) )
    {
      if ( Teams[0].Size < MaxPlayers / 2 )
      {
        Error = "";
        FailCode = "";
      } else {
        Error = MaxedOutMessage;
        FailCode = "TEAMFULL";
      }
    } else {
      if ( Caps(InPassword) == Caps(MatchPasswordBlue) )
      {
        if ( Teams[1].Size < MaxPlayers / 2 )
        {
          Error = "";
          FailCode = "";
        } else {
          Error = MaxedOutMessage;
          FailCode = "TEAMFULL";
        }
      }
    }
  } else {
    if ( (ModeratorPassword != "") && (Caps(InPassword) == Caps(ModeratorPassword)) )
    {
      Error = "";
      FailCode = "";
    }
  }
  if ( (Caps(OvClass) == "BOTPACK.CHSPECTATOR") && bMatchMode && (MatchPasswordSpec != "") )
  {
    if ( Caps(InPassword) == Caps(MatchPasswordSpec) )
    {
      Error = "";
      FailCode = "";
    } else {
      Error = WrongPassword;
      FailCode = "WRONGPW";
    }
  }
}

event PlayerPawn Login (string Portal, string Options, out string Error, Class<PlayerPawn> SpawnClass)
{
  local PlayerPawn NewPlayer;
  local ClientOptions CO;
  local LeagueAS_ExtPlayerReplicationInfo ePRI;
  local string InPassword;
  local string ModOptions;
  local string Pair;
  local string Key;
  local string Value;

  if ( ClassIsChildOf(SpawnClass,Class'Commander') )
  {
    return None;
  }
  InPassword = ParseOption(Options,"Password");
  ModOptions = "";
  if ( bMatchMode && (MatchPasswordRed != "") && (MatchPasswordBlue != "") )
  {
    if ( (Caps(InPassword) == Caps(MatchPasswordRed)) && (Teams[0].Size >= MaxPlayers / 2) || (Caps(InPassword) == Caps(MatchPasswordBlue)) && (Teams[1].Size >= MaxPlayers / 2) )
    {
      Error = MaxedOutMessage;
      return None;
    }
  }
  if ( bMatchMode && (MatchPasswordRed != "") && (MatchPasswordBlue != "") &&  !ClassIsChildOf(SpawnClass,Class'Spectator') )
  {
    if ( Caps(InPassword) == Caps(MatchPasswordRed) )
    {
      while ( GrabOption(Options,Pair) )
      {
        GetKeyValue(Pair,Key,Value);
        if ( Key ~= "Team" )
        {
          ModOptions = ModOptions $ "?Team=0";
        } else {
          ModOptions = ModOptions $ "?" $ Pair;
        }
      }
    } else {
      if ( Caps(InPassword) == Caps(MatchPasswordBlue) )
      {
        while ( GrabOption(Options,Pair) )
        {
          GetKeyValue(Pair,Key,Value);
          if ( Key ~= "Team" )
          {
            ModOptions = ModOptions $ "?Team=1";
          } else {
            ModOptions = ModOptions $ "?" $ Pair;
          }
        }
      } else {
        ModOptions = Options;
      }
    }
  } else {
    ModOptions = Options;
  }
  Log("Modified Options - " $ ModOptions,'LeagueAssault');
  NewPlayer = Super.Login(Portal,ModOptions,Error,SpawnClass);
  if ( bPracticeMode )
  {
    NewPlayer.ReducedDamageType = 'All';
  }
  CO = Spawn(Class'ClientOptions',NewPlayer,,NewPlayer.Location);
  ePRI = Spawn(Class'LeagueAS_ExtPlayerReplicationInfo',NewPlayer,,NewPlayer.Location);
  if ( (ModeratorPassword != "") && (Caps(InPassword) == Caps(ModeratorPassword)) )
  {
    AddModerator(NewPlayer,InPassword);
  }
  return NewPlayer;
}

event PostLogin (PlayerPawn NewPlayer)
{
  local ClientOptions CO;

  Super.PostLogin(NewPlayer);
  foreach AllActors(Class'ClientOptions',CO)
  {
    if ( NewPlayer == CO.Owner )
    {
      CO.CopyOptionsToServer();
    }
  }
  NewPlayer.ClientMessage("*********************************************************");
  NewPlayer.ClientMessage(GameName @ "(Version" @ VersionStr $ SubVersionStr $ ")");
  NewPlayer.ClientMessage("Incorporating" @ CSHP.VersionStr);
  NewPlayer.ClientMessage("Website: http://leagueas.utassault.net.");
  NewPlayer.ClientMessage("**********************************************************");
  NewPlayer.ClientMessage("Standard League Assault Commands:");
  NewPlayer.ClientMessage("ChangeTeams: Switch teams.");
  NewPlayer.ClientMessage("ToggleMute: Mute messages.");
  NewPlayer.ClientMessage("ShowMatchScore: View the score during a match.");
  NewPlayer.ClientMessage("ToggleExtendedHUD: Enable/disable the extended HUD.");
  NewPlayer.ClientMessage("**********************************************************");
  NewPlayer.ClientMessage("For a complete list of commands and features visit the website!");
  NewPlayer.ClientMessage("**********************************************************");
  NewPlayer.ClientMessage(" ");
  NewPlayer.ClientMessage(" ");
  NewPlayer.ClientMessage(" ");
  NewPlayer.ClientMessage(" ");
}

function PlayerDetailsRecieved (PlayerPawn JoinedPlayer, ClientOptions CO)
{
  local LeagueAS_ExtPlayerReplicationInfo ePRI;
  local bool Authorised;

  if ( bMatchMode && bAuthorisePlayers )
  {
    Authorised = PlayerAuthDataLink.AuthorisePlayer(CO);
    if (  !Authorised )
    {
      JoinedPlayer.ClientMessage("******************************************************");
      JoinedPlayer.ClientMessage("League Assault could not validate your player details!");
      JoinedPlayer.ClientMessage("You are not permitted to join this match!");
      JoinedPlayer.ClientMessage("******************************************************");
      JoinedPlayer.Destroy();
      CO.Destroy();
      return;
    }
  }
  if ( bMatchMode && (CO.PlayerName != "") )
  {
    if ( CO.bClanTagBefore )
    {
      JoinedPlayer.PlayerReplicationInfo.PlayerName = CO.ClanName @ CO.PlayerName;
    } else {
      JoinedPlayer.PlayerReplicationInfo.PlayerName = CO.PlayerName @ CO.ClanName;
    }
  }
  foreach AllActors(Class'LeagueAS_ExtPlayerReplicationInfo',ePRI)
  {
    if ( JoinedPlayer == ePRI.Owner )
    {
      return; // Check required
    }
  }
  ePRI.bMuteSay = CO.bMuteSay;
  ePRI.bMuteAll = CO.bMuteAll;
  Log("******************Player Joined******************",'LeagueAssault');
  Log("Player Name:" @ JoinedPlayer.PlayerReplicationInfo.PlayerName,'LeagueAssault');
  Log("Registered Player Name:" @ CO.PlayerName,'LeagueAssault');
  Log("Registered Clan Name:" @ CO.ClanName,'LeagueAssault');
  Log("IP Address:" @ JoinedPlayer.GetPlayerNetworkAddress(),'LeagueAssault');
  Log("*************************************************",'LeagueAssault');
  PlayerAuthDataLink.LogEvent("PLAYERJOIN::" $ JoinedPlayer.PlayerReplicationInfo.PlayerName $ ":" $ CO.PlayerName $ ":" $ CO.ClanName $ ":" $ CO.PlayerPassword $ ":" $ JoinedPlayer.GetPlayerNetworkAddress() $ ":" $ CO.IRCIdent);
}

function bool AddBot ()
{
  local Bot NewBot;
  local NavigationPoint StartSpot;
  local NavigationPoint OldStartSpot;
  local int DesiredTeam;
  local int i;
  local int MinSize;
  local LeagueAS_ExtPlayerReplicationInfo ePRI;

  NewBot = SpawnBot(StartSpot);
  if ( NewBot == None )
  {
    Log("Failed to spawn bot");
    return False;
  }
  if ( bBalanceTeams &&  !bRatedGame )
  {
    MinSize = Teams[0].Size;
    DesiredTeam = 0;
    i = 1;
    while ( i < MaxTeams )
    {
      if ( Teams[i].Size < MinSize )
      {
        MinSize = Teams[i].Size;
        DesiredTeam = i;
      }
      i++;
    }
  } else {
    DesiredTeam = NewBot.PlayerReplicationInfo.Team;
  }
  NewBot.PlayerReplicationInfo.Team = 255;
  if ( (DesiredTeam == 255) ||  !ChangeTeam(NewBot,DesiredTeam) )
  {
    ChangeTeam(NewBot,NextBotTeam);
    NextBotTeam++;
    if ( NextBotTeam >= MaxTeams )
    {
      NextBotTeam = 0;
    }
  }
  if ( bSpawnInTeamArea )
  {
    OldStartSpot = StartSpot;
    StartSpot = FindPlayerStart(NewBot,255);
    if ( StartSpot != None )
    {
      NewBot.SetLocation(StartSpot.Location);
      NewBot.SetRotation(StartSpot.Rotation);
      NewBot.ViewRotation = StartSpot.Rotation;
      NewBot.SetRotation(NewBot.Rotation);
      StartSpot.PlayTeleportEffect(NewBot,True);
    } else {
      StartSpot = OldStartSpot;
    }
  }
  StartSpot.PlayTeleportEffect(NewBot,True);
  SetBotOrders(NewBot);
  if ( LocalLog != None )
  {
    LocalLog.LogPlayerConnect(NewBot);
    LocalLog.FlushLog();
  }
  if ( WorldLog != None )
  {
    WorldLog.LogPlayerConnect(NewBot);
    WorldLog.FlushLog();
  }
  ePRI = Spawn(Class'LeagueAS_ExtPlayerReplicationInfo',NewBot,,NewBot.Location);
  return True;
}

function Logout (Pawn Exiting)
{
  local LeagueAS_ExtPlayerReplicationInfo ePRI;
  local ClientOptions CO;

  Super.Logout(Exiting);
  if ( Exiting.IsA('PlayerPawn') )
  {
    foreach AllActors(Class'ClientOptions',CO)
    {
      if ( Exiting == CO.Owner )
      {
        PlayerAuthDataLink.LogEvent("PLAYERLEAVE::" $ Exiting.PlayerReplicationInfo.PlayerName $ ":" $ CO.PlayerName $ ":" $ CO.ClanName $ ":" $ CO.PlayerPassword $ ":" $ PlayerPawn(Exiting).GetPlayerNetworkAddress() $ ":" $ CO.IRCIdent);
        CO.Destroy();
      }
    }
    foreach AllActors(Class'LeagueAS_ExtPlayerReplicationInfo',ePRI)
    {
      if ( Exiting == ePRI.Owner )
      {
        ePRI.Destroy();
      }
    }
    RemoveModerator(PlayerPawn(Exiting));
  }
}

function NavigationPoint FindSpawnPoint (Pawn Player, optional byte InTeam, optional string incomingName)
{
  local PlayerStart Dest;
  local PlayerStart Candidate[16];
  local PlayerStart Best;
  local float Score[16];
  local float BestScore;
  local float NextDist;
  local Pawn OtherPlayer;
  local int i;
  local int Num;
  local Teleporter Tel;
  local NavigationPoint N;
  local byte Team;

  if ( bStartMatch && (Player != None) && Player.IsA('TournamentPlayer') && (Level.NetMode == 0) && (TournamentPlayer(Player).StartSpot != None) )
  {
    return TournamentPlayer(Player).StartSpot;
  }
  if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
  {
    Team = Player.PlayerReplicationInfo.Team;
  } else {
    Team = InTeam;
  }
  if ( incomingName != "" )
  {
    foreach AllActors(Class'Teleporter',Tel)
    {
      if ( string(Tel.Tag) ~= incomingName )
      {
        return Tel;
      }
    }
  }
  if ( Team == 255 )
  {
    Team = 0;
  }
  N = Level.NavigationPointList;
  while ( N != None )
  {
    Dest = PlayerStart(N);
    if ( (Dest != None) && Dest.bEnabled && ( !bSpawnInTeamArea || (Team == Dest.TeamNumber)) )
    {
      if ( Num < 16 )
      {
        Candidate[Num] = Dest;
      } else {
        if ( Rand(Num) < 16 )
        {
          Candidate[Rand(16)] = Dest;
        }
      }
      Num++;
    }
    N = N.nextNavigationPoint;
  }
  if ( Num == 0 )
  {
    Log("Didn't find any player starts in list for team" @ string(Team) @ "!!!");
    foreach AllActors(Class'PlayerStart',Dest)
    {
      if ( Num < 16 )
      {
        Candidate[Num] = Dest;
      } else {
        if ( Rand(Num) < 16 )
        {
          Candidate[Rand(16)] = Dest;
        }
      }
      Num++;
    }
    if ( Num == 0 )
    {
      return None;
    }
  }
  if ( Num > 16 )
  {
    Num = 16;
  }
  i = 0;
  while ( i < Num )
  {
    if ( Candidate[i] == LastStartSpot )
    {
      Score[i] = -6000.0;
    } else {
      Score[i] = 4000.0 * FRand();
    }
    i++;
  }
  OtherPlayer = Level.PawnList;
  while ( OtherPlayer != None )
  {
    if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) &&  !OtherPlayer.IsA('Spectator') )
    {
      i = 0;
      while ( i < Num )
      {
        if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
        {
          NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
          if ( NextDist < Candidate[i].CollisionRadius + Candidate[i].CollisionHeight )
          {
            Score[i] -= 1000000.0;
          }
        }
        i++;
      }
    }
    OtherPlayer = OtherPlayer.nextPawn;
  }
  BestScore = Score[0];
  Best = Candidate[0];
  i = 1;
  while ( i < Num )
  {
    if ( Score[i] > BestScore )
    {
      BestScore = Score[i];
      Best = Candidate[i];
    }
    i++;
  }
  LastStartSpot = Best;
  return Best;
}

function NavigationPoint FindPlayerStart (Pawn Player, optional byte InTeam, optional string incomingName)
{
  local Pawn P;
  local int i;
  local int D;
  local byte Team;

  if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
  {
    Team = Player.PlayerReplicationInfo.Team;
  } else {
    Team = InTeam;
  }
  if ( Team != 255 )
  {
    if ( Team > 1 )
    {
      Team = 0;
    }
    if ( Defender == None )
    {
      Log("Setting up Teams...",'LeagueAssault');
      D = CurrentDefender;
      if ( (D != 0) && (D != 1) )
      {
        D = 0;
      }
      Log("Team " $ string(D) $ " is defending.",'LeagueAssault');
      Defender = Teams[D];
      if ( D == 0 )
      {
        Log("Team 1 is attacking.",'LeagueAssault');
        Attacker = Teams[1];
      } else {
        Log("Team 0 is attacking.",'LeagueAssault');
        Attacker = Teams[0];
      }
      P = Level.PawnList;
      while ( P != None )
      {
        if ( P.IsA('StationaryPawn') )
        {
          StationaryPawn(P).SetTeam(Defender.TeamIndex);
        }
        P = P.nextPawn;
      }
      if ( WorldLog != None )
      {
        WorldLog.LogSpecialEvent("assault_defender",string(Defender.TeamIndex));
        WorldLog.LogSpecialEvent("assault_attacker",string(Attacker.TeamIndex));
      }
      if ( LocalLog != None )
      {
        LocalLog.LogSpecialEvent("assault_defender",string(Defender.TeamIndex));
        LocalLog.LogSpecialEvent("assault_attacker",string(Attacker.TeamIndex));
      }
    }
    if ( Teams[Team] == Defender )
    {
      Team = 0;
    } else {
      Team = 1;
    }
  }
  return FindSpawnPoint(None,Team,incomingName);
}

function RestartGame ()
{
  local Pawn P;
  local int i;

  if ( bDontRestart )
  {
    return;
  }
  if (  !bGameEnded || (EndTime > Level.TimeSeconds) )
  {
    return;
  }
  if ( bDefenseSet )
  {
    Log("Map Change Initiated...",'LeagueAssault');
    if ( bAttackOnly )
    {
      Log("ATTACK ONLY MODE! Defending team remains the same.",'LeagueAssault');
      CurrentDefender = Defender.TeamIndex;
    } else {
      if ( GetWinningTeam() != -1 )
      {
        Log("Team " $ string(GetWinningTeam()) $ " won the round.",'LeagueAssault');
        if ( GetWinningTeam() == 1 )
        {
          CurrentDefender = 0;
        } else {
          CurrentDefender = 1;
        }
        Log("Setting Team " $ string(CurrentDefender) $ " as the defending team for the next map.",'LeagueAssault');
      } else {
        CurrentDefender = 0;
      }
    }
    SaveConfig();
    Default.bDefenseSet = False;
    Default.Part = 1;
    Default.SavedTime = 0.0;
    Default.NumDefenses = 0;
    Default.GameCode = "";
    Default.bTiePartOne = False;
    Default.CurrentDefender = CurrentDefender;
    StaticSaveConfig();
    Super(DeathMatchPlus).RestartGame();
  } else {
    bDontRestart = True;
    if ( Defender.TeamIndex == 1 )
    {
      CurrentDefender = 0;
    } else {
      CurrentDefender = 1;
    }
    bDefenseSet = True;
    Part = 2;
    SavedTime = TimeLimit * 60 - RemainingTime;
    SaveConfig();
    Level.ServerTravel("?Restart",False);
  }
}

function RemoveFort (FortStandard F, Pawn Instigator)
{
  local int i;
  local Pawn P;

  if (  !bMapEnded )
  {
    i = 0;
    while ( i < 19 )
    {
      if ( (LeagueASGameReplicationInfo.FortName[i] == F.FortName) || (LeagueASGameReplicationInfo.FortName[i] == string(F)) )
      {
        LeagueASGameReplicationInfo.FortCompleted[i] = "Completed! - by" @ Instigator.PlayerReplicationInfo.PlayerName;
      }
      i++;
    }
    Super.RemoveFort(F,Instigator);
    P = Level.PawnList;
    while ( P != None )
    {
      if ( P.IsA('MessagingSpectator') )
      {
        P.ClientMessage("Completed by" @ Instigator.PlayerReplicationInfo.PlayerName,'CriticalEvent');
      }
      P = P.nextPawn;
    }
  }
}

function AddDefaultInventory (Pawn PlayerPawn)
{
  local Inventory i;
  local enforcer SecondEnforcer;

  i = PlayerPawn.FindInventoryType(Class'LeagueAS_Inventory');
  if ( i == None )
  {
    i = Spawn(Class'LeagueAS_Inventory',PlayerPawn);
  } else {
    i.Destroy();
    i = Spawn(Class'LeagueAS_Inventory',PlayerPawn);
  }
  if ( i != None )
  {
    i.bHeldItem = True;
    i.GiveTo(PlayerPawn);
    if (  !PlayerPawn.PlayerReplicationInfo.bWaitingPlayer || PlayerPawn.PlayerReplicationInfo.bIsSpectator )
    {
      LeagueAS_Inventory(i).ActivateSpawnProtection();
    }
  }
  if (  !PlayerPawn.IsA('Spectator') &&  !bRequireReady && (CountDown > 0) )
  {
    Super(GameInfo).AddDefaultInventory(PlayerPawn);
    GiveWeapon(PlayerPawn,"BotPack.Enforcer");
    i = PlayerPawn.FindInventoryType(Class'enforcer');
    if ( i != None )
    {
      enforcer(i).AmmoType.UseAmmo(28);
    }
    SecondEnforcer = Spawn(Class'enforcer',PlayerPawn);
    if ( SecondEnforcer != None )
    {
      PlayerPawn.Inventory.HandlePickupQuery(SecondEnforcer);
      SecondEnforcer.Destroy();
    }
  }
}

function bool SetEndCams (string Reason)
{
  local int WinningTeam;
  local Pawn P;

  Super.SetEndCams(Reason);
  if ( bDefenseSet && bMatchMode )
  {
    if (  !MapsLeft > MatchLength )
    {
      WinningTeam = GetWinningTeam();
      if ( WinningTeam != -1 )
      {
        TeamScore[WinningTeam]++;
        if ( MapsWon[WinningTeam] == "" )
        {
          MapsWon[WinningTeam] = Left(string(self),InStr(string(self),"."));
        } else {
          MapsWon[WinningTeam] = MapsWon[WinningTeam] $ "," @ Left(string(self),InStr(string(self),"."));
        }
      }
    }
    MapsLeft--;
    if ( (TeamScore[0] > TeamScore[1] + MapsLeft) || (TeamScore[1] > TeamScore[0] + MapsLeft) )
    {
      MapsLeft = 0;
    }
    SetScoreStrings(TeamColor[0] @ string(TeamScore[0]) @ "-" @ string(TeamScore[1]) @ TeamColor[1]);
    LeagueASGameReplicationInfo.GameEndedComments = LeagueASGameReplicationInfo.GameEndedComments @ LeagueASGameReplicationInfo.MatchScore;
    P = Level.PawnList;
    while ( P != None )
    {
      if ( P.IsA('PlayerPawn') )
      {
        P.ClientGameEnded();
        P.GotoState('GameEnded');
      }
      P = P.nextPawn;
    }
    if ( MapsLeft == 0 )
    {
      bDontRestart = True;
      bMatchMode = False;
      bTournament = False;
      LeagueASGameReplicationInfo.bMatchModeEnabled = False;
      if ( Len(Matchlog) > 128 )
      {
        Matchlog = "";
      }
      Matchlog = Matchlog $ ";" @ LeagueASGameReplicationInfo.MatchScore;
    }
  }
  SaveConfig();
  bMapEnded = True;
  return True;
}

function StartMatch ()
{
  local Pawn P;
  local int i;

  Super.StartMatch();
  bMapStarted = True;
  LeagueASGameReplicationInfo.StartTimeRemaining = -1;
  if ( bMatchMode )
  {
    P = Level.PawnList;

    while ( P != None )
    {
      if ( P.IsA('PlayerPawn') )
      {
        PlayerPawn(P).bAdmin = False;
        PlayerPawn(P).PlayerReplicationInfo.bAdmin = False;
        P.ReducedDamageType = 'None';
      }
      P = P.nextPawn;
    }
    i = 0;
    while ( i < 12 )
    {
      ModList[i] = None;
      i++;
    }
  }
  if ( bPracticeMode )
  {
    BroadcastMessage("SERVER IS IN PRACTICE MODE");
    P = Level.PawnList;
    while ( P != None )
    {
      if ( P.IsA('PlayerPawn') )
      {
        P.ReducedDamageType = 'All';
      }
      P = P.nextPawn;
    }
  }
}

event Timer()
{
  local Pawn P;
  local PlayerPawn PP;
  local bool bReady;
  local Inventory Inv;
  local LeagueAS_ExtPlayerReplicationInfo ePRI;
  local FortStandard F, NearestFort;
  local float DistToNearestFort, ThisFortDist;
  local Pawn ePRIOwner;
  local ClientOptions CO;

  Super.Timer();
  if ( !bMatchMode )
  {
    LeagueASGameReplicationInfo.StartTimeRemaining = -1;
  }
  else if ( LeagueASGameReplicationInfo.StartTimeRemaining>=0 )
  {
    LeagueASGameReplicationInfo.StartTimeRemaining--;
    if ( !bRequireReady )
    {
      LeagueASGameReplicationInfo.StartTimeRemaining = -1;
      bMatchMode = false;
      LeagueASGameReplicationInfo.bMatchModeEnabled = false;
    }
    if ( LeagueASGameReplicationInfo.StartTimeRemaining==300 )
    {
      BroadcastMessage( "5 MINUTES UNTIL GAME START...", true );
      if ( MapsLeft>MatchLength )
      {
        BroadcastMessage( "WARM UP MAP ONLY!", true );
      }
    }
    if ( LeagueASGameReplicationInfo.StartTimeRemaining==180 )
    {
      BroadcastMessage( "3 MINUTES UNTIL GAME START....", true );
      if ( MapsLeft>MatchLength )
      {
        BroadcastMessage( "WARM UP MAP ONLY!", true );
      }
    }
    if ( LeagueASGameReplicationInfo.StartTimeRemaining==60 )
    {
      BroadcastMessage( "1 MINUTE UNTIL GAME START....", true );
      if ( MapsLeft>MatchLength )
      {
        BroadcastMessage( "WARM UP MAP ONLY!", true );
      }
    }
    if ( LeagueASGameReplicationInfo.StartTimeRemaining==30 )
    {
      BroadcastMessage( "30 SECONDS UNTIL GAME START....", true );
      if ( MapsLeft>MatchLength )
      {
        BroadcastMessage( "WARM UP MAP ONLY!", true );
      }
    }
    if ( LeagueASGameReplicationInfo.StartTimeRemaining==10 )
    {
      BroadcastMessage( "10 SECONDS UNTIL GAME START...", true );
      if ( MapsLeft>MatchLength )
      {
        BroadcastMessage( "WARM UP MAP ONLY!", true );
      }
    }
    if ( LeagueASGameReplicationInfo.StartTimeRemaining<11 && LeagueASGameReplicationInfo.StartTimeRemaining>0 )
    {
      bReady = true;
      for ( P=Level.PawnList; P!=None; P=P.nextPawn )
      {
        if ( P.IsA('PlayerPawn') && !P.IsA('Spectator') && !PlayerPawn(P).bReadyToPlay )
        {
          bReady = false;
        }
      }
      if ( NumPlayers<MaxPlayers )
      {
        bReady = false;
      }
      if ( !bReady )
      {
        CountDown = LeagueASGameReplicationInfo.StartTimeRemaining;
        for ( P=Level.PawnList; P!=None; P=P.nextPawn )
        {
          if ( P.IsA('TournamentPlayer') )
          {
            TournamentPlayer(P).TimeMessage( LeagueASGameReplicationInfo.StartTimeRemaining );
          }
        }
      }
    }
    if ( LeagueASGameReplicationInfo.StartTimeRemaining==0 )
    {
      if ( !bGameEnded && bMatchMode && bRequireReady )
      {
        foreach AllActors( Class'PlayerPawn', PP )
        {
          PP.bReadyToPlay = true;
        }
        bNetReady = false;
        bRequireReady = false;
        StartMatch();
      }
      LeagueASGameReplicationInfo.StartTimeRemaining = -1;
    }
  }
  if ( CSHP!=None && (CSHP.bAdminWarn==1 && bMatchMode || CSHP.bAdminWarn==2) && int(Level.NetMode)!=int(ENetMode.NM_Standalone) )
  {
    foreach AllActors( Class'PlayerPawn', PP )
    {
      if ( PP.bAdmin )
      {
        BroadcastMessage( "WARNING:"@PP.PlayerReplicationInfo.PlayerName@"is logged in as Administrator.", true, 'CriticalEvent' );
      }
      if ( IsAModerator(PP) )
      {
        BroadcastMessage( "WARNING:"@PP.PlayerReplicationInfo.PlayerName@"is logged in as Moderator.", true, 'CriticalEvent' );
      }
      if ( PP.ReducedDamageType!='' )
      {
        BroadcastMessage( "WARNING:"@PP.PlayerReplicationInfo.PlayerName@"has God Mode enabled.", true, 'CriticalEvent' );
      }
    }
  }
  foreach AllActors( Class'LeagueAS_ExtPlayerReplicationInfo', ePRI )
  {
    ePRIOwner = Pawn(ePRI.Owner);
    if ( ePRIOwner!=None && ePRI!=None )
    {
      foreach AllActors( Class'ClientOptions', CO )
      {
        if ( ePRIOwner==CO.Owner )
        {
          break;
        }
      }
      if ( CO!=None && ePRIOwner==CO.Owner )
      {
        ePRI.bMuteSay = CO.bMuteSay;
        ePRI.bMuteAll = CO.bMuteAll;
      }
      else
      {
        CO = None;
        ePRI.bMuteSay = false;
        ePRI.bMuteAll = false;
      }
      ePRI.PlayerName = ePRIOwner.PlayerReplicationInfo.PlayerName;
      ePRI.Team = int(ePRIOwner.PlayerReplicationInfo.Team);
      if ( ePRIOwner.IsA('PlayerPawn') )
      {
        ePRI.bModerator = IsAModerator( PlayerPawn(ePRIOwner) );
      }
      else
      {
        ePRI.bModerator = false;
      }
      ePRI.Health = ePRIOwner.Health;
      ePRI.Armour = GetArmourAmount( ePRIOwner );
      if ( ePRIOwner.Weapon!=None )
      {
        ePRI.WeaponName = ePRIOwner.Weapon.ItemName;
        if ( ePRIOwner.Weapon.AmmoType!=None )
        {
          ePRI.AmmoAmount = ePRIOwner.Weapon.AmmoType.AmmoAmount;
        }
        else
        {
          ePRI.AmmoAmount = 0;
        }
      }
      else
      {
        ePRI.WeaponName = "None";
        ePRI.AmmoAmount = 0;
      }
      DistToNearestFort = 0.0;
      foreach AllActors( Class'FortStandard', F )
      {
        ThisFortDist = DistanceFrom( ePRIOwner, F );
        if ( DistToNearestFort==float(0) || ThisFortDist<DistToNearestFort )
        {
          NearestFort = F;
          DistToNearestFort = ThisFortDist;
        }
      }
      if ( DistToNearestFort<float(1000) && NearestFort!=None )
      {
        if ( NearestFort.FortName=="Assault Target" || NearestFort.FortName=="" || NearestFort.FortName==" " )
        {
          ePRI.Location = "Near" @ string(NearestFort);
        }
        else
        {
          ePRI.Location = "Near" @ NearestFort.FortName;
        }
      }
      else if ( ePRIOwner.PlayerReplicationInfo!=None && ePRIOwner.PlayerReplicationInfo.PlayerLocation!=None )
      {
        ePRI.Location = ePRIOwner.PlayerReplicationInfo.PlayerLocation.LocationName;
      }
      else if ( ePRIOwner.PlayerReplicationInfo!=None && ePRIOwner.PlayerReplicationInfo.PlayerZone!=None )
      {
        ePRI.Location = ePRIOwner.PlayerReplicationInfo.PlayerZone.ZoneName;
      }
      else
      {
        ePRI.Location = "UNKNOWN";
      }
      if ( ePRI.Location=="" )
      {
        ePRI.Location = "UNKNOWN";
      }
      ePRI.bReadyToPlay = bTournament && !bMapStarted && ePRIOwner.IsA( 'PlayerPawn' ) && PlayerPawn(ePRIOwner).bReadyToPlay;
    }
  }
  LeagueASGameReplicationInfo.TimeRemaining = RemainingTime;
  if ( SavedTime>float(0) )
  {
    LeagueASGameReplicationInfo.TimeElapsed = int(SavedTime-float(RemainingTime));
  }
  else
  {
    LeagueASGameReplicationInfo.TimeElapsed = TimeLimit*60-RemainingTime;
  }
  ServerSideModule.OnTimer();
}

event PreBeginPlay ()
{
  local int X;
  local Mutator M;
  local Pawn P;
  local Class<LeagueAS_SSDAbstract> SSDClass;
  local Class<LeagueAS_PADAbstract> PADClass;
  local Class<LeagueAS_SSMAbstract> SSMClass;

  Super.PreBeginPlay();
  SSDClass = None;
  SSDClass = Class<LeagueAS_SSDAbstract>(DynamicLoadObject("LeagueAS-SP.ServerSetupDataLink",Class'Class'));
  if ( SSDClass == None )
  {
    ServerSetupDataLink = Spawn(Class'LeagueAS_SSDAbstract');
    Log("Failed to load class LeagueAS-SP.ServerSetupDataLink, data link will be unavailable.",'LeagueAssault');
  } else {
    ServerSetupDataLink = Spawn(SSDClass);
  }
  ServerSetupDataLink.Initialise();
  PADClass = None;
  PADClass = Class<LeagueAS_PADAbstract>(DynamicLoadObject("LeagueAS-SP.PlayerAuthDataLink",Class'Class'));
  if ( PADClass == None )
  {
    PlayerAuthDataLink = Spawn(Class'LeagueAS_PADAbstract');
    Log("Failed to load class LeagueAS-SP.PlayerAuthDataLink, player authorisation will be unavailable.",'LeagueAssault');
  } else {
    PlayerAuthDataLink = Spawn(PADClass);
  }
  PlayerAuthDataLink.Initialise();
  SSMClass = None;
  SSMClass = Class<LeagueAS_SSMAbstract>(DynamicLoadObject("LeagueAS-SP.ServerSideModule",Class'Class'));
  if ( SSMClass == None )
  {
    ServerSideModule = Spawn(Class'LeagueAS_SSMAbstract');
    Log("Failed to load class LeagueAS-SP.ServerSideModule, some features will be unavailable.",'LeagueAssault');
  } else {
    ServerSideModule = Spawn(SSMClass);
  }
  ServerSideModule.LeagueAssaultGame = self;
  SubVersionStr = ServerSideModule.SubVersionStr;
  ServerSideModule.OnStart();
  LeagueASGameReplicationInfo = LeagueAS_GameReplicationInfo(GameReplicationInfo);
  Class'TeamCannon'.Default.Health = 100;
  Class'MinigunCannon'.Default.Health = 100;
  if ( bStandardise )
  {
    bForceRespawn = True;
    bHardCoreMode = True;
    bChallengeMode = False;
    bMultiWeaponStay = True;
    AirControl = 0.34999999;
    SetGameSpeed(1.0);
  }
  if ( bMatchMode )
  {
    bPracticeMode = False;
  }
  MaxCommanders = 0;
}

function bool GetRule (out string Rules, out string Result)
{
  if ( Left(Rules,1)=="\\" )
  {
    Result = Mid( Rules, 1 );
    if ( InStr(Result,"\\")>=0 )
    {
      Result = Left( Result, InStr(Result,"\\") );
    }
    Rules = Mid( Rules, 1 );
    if ( InStr(Rules,"\\")>=0 )
    {
      Rules = Mid( Rules, InStr(Rules,"\\") );
    }
    else
    {
      Rules = "";
    }
    return true;
  }
  else
  {
    return false;
  }
}

event BeginPlay ()
{
  local int FortCount, i, j, LastDefPriority;
  local FortStandard F, HighestFort;
  local string ServerRules, Rule, MapName;
  local bool ServerHasPass, FortFound;

  Super.BeginPlay();
  if ( bMatchMode && bAutoPausing )
  {
    AutoPauser = Spawn( Class'LeagueAS_AutoPauser' );
  }
  if ( bEnableCSHP )
  {
    CSHP = Level.Spawn( Class'HackProtection' );
    CSHP.NextMutator = Level.Game.BaseMutator;
    Level.Game.BaseMutator = CSHP;
  }
  Class'PlayerPawn'.default.MaxTimeMargin = 1.0;
  Class'PlayerPawn'.StaticSaveConfig();
  if ( bMatchMode )
  {
    TeamColor[0] = TeamNameRed;
    TeamColor[1] = TeamNameBlue;
  }
  ServerRules = GetRules();
  while ( GetRule(ServerRules,Rule) )
  {
    if ( Rule~="password" )
    {
      GetRule( ServerRules, Rule );
      ServerHasPass = Rule~="True";
      break;
    }
  }
  MapName = Left( string(Self), InStr(string(Self),".") );
  if ( bMatchMode )
  {
    LeagueASGameReplicationInfo.StartTimeRemaining = SubsequentMapStartTime;
    SetScoreStrings( TeamColor[0]@string(TeamScore[0])@"-"@string(TeamScore[1])@TeamColor[1] );
    LeagueASGameReplicationInfo.bMatchModeEnabled = true;
    TeamChangeMessage = "Match in progress. Team Changing Disabled!";
    PlayerAuthDataLink.LogEvent( "SERVERINFO::"$GameReplicationInfo.ServerName$":"$MapName$":MATCH" );
  }
  else
  {
    MapsLeft = 0;
    LeagueASGameReplicationInfo.StartTimeRemaining = -1;
    TeamScore[0] = 0;
    TeamScore[1] = 0;
    if ( ServerHasPass )
    {
      SetScoreStrings( "LOCKED - PRIVATE" );
      PlayerAuthDataLink.LogEvent( "SERVERINFO::"$GameReplicationInfo.ServerName$":"$MapName$":PRIVATE" );
    }
    else
    {
      SetScoreStrings( "OPEN - PUBLIC" );
      PlayerAuthDataLink.LogEvent( "SERVERINFO::"$GameReplicationInfo.ServerName$":"$MapName$":PUBLIC" );
    }
    TeamChangeMessage = "Type 'ChangeTeams' to change teams.";
  }
  FortCount = 0;
  foreach AllActors( Class'FortStandard', F )
  {
    FortCount++;
  }
  LastDefPriority = -2147483648;
  for ( i=0; i<FortCount; i++ )
  {
    HighestFort = None;
    foreach AllActors( Class'FortStandard', F )
    {
      if ( HighestFort==None || int(F.DefensePriority)>=int(HighestFort.DefensePriority) )
      {
        FortFound = false;
        for ( j=0; j<20; j++ )
        {
          if ( LeagueASGameReplicationInfo.FortName[j]==F.FortName || LeagueASGameReplicationInfo.FortName[j]==string(F) )
          {
            FortFound = true;
          }
        }
        if ( !FortFound )
        {
          HighestFort = F;
        }
      }
    }
    if ( HighestFort!=None )
    {
      if ( HighestFort.FortName=="Assault Target" || HighestFort.FortName=="" || HighestFort.FortName==" " )
      {
        LeagueASGameReplicationInfo.FortName[i] = string(HighestFort);
      }
      else
      {
        LeagueASGameReplicationInfo.FortName[i] = HighestFort.FortName;
      }
      LeagueASGameReplicationInfo.FortCompleted[i] = "Not Complete!";
    }
  }
  SaveConfig();
}

function InitGame (string Options, out string Error)
{
  local FortStandard F;
  local name EndCamTag;

  Super.InitGame( Options, Error );
  TimeLimit = 1;
  if ( bAttackOnly )
  {
    foreach AllActors( Class'FortStandard', F )
    {
      TimeLimit = Max( TimeLimit, F.DefenseTime );
      if ( F.EndCamTag!='' )
      {
        EndCamTag = F.EndCamTag;
      }
    }
    RemainingTime = TimeLimit*60;
    bDefenseSet = true;
    SavedTime = 0.0;
  }
  else if ( SavedTime>float(0) )
  {
    RemainingTime = int(SavedTime);
    foreach AllActors( Class'FortStandard', F )
    {
      if ( F.EndCamTag!='' )
      {
        EndCamTag = F.EndCamTag;
      }
    }
  }
  else
  {
    foreach AllActors( Class'FortStandard', F )
    {
      TimeLimit = Max( TimeLimit, F.DefenseTime );
      if ( F.EndCamTag!='' )
      {
        EndCamTag = F.EndCamTag;
      }
    }
    RemainingTime = TimeLimit*60;
  }
  if ( EndCamTag!='' )
  {
    foreach AllActors( Class'SpectatorCam', EndCam, EndCamTag )
    {
      break;
    }
  }
  GoalTeamScore = 0.0;
  FragLimit = 0;
  bMegaSpeed = false;
  bUseTranslocator = false;
  bJumpMatch = false;
}

function PostBeginPlay ()
{
  Super.PostBeginPlay();
  if ( bMatchMode )
  {
    TeamColor[0] = TeamNameRed;
    TeamColor[1] = TeamNameBlue;
    Teams[0].TeamName = TeamNameRed;
    Teams[1].TeamName = TeamNameBlue;
  }
}

function PlayStartUpMessage (PlayerPawn NewPlayer)
{
  local int i;
  local Color WhiteColor;

  if ( int(NewPlayer.PlayerReplicationInfo.Team)>1 )
  {
    return;
  }
  NewPlayer.ClearProgressMessages();
  if ( Defender==Teams[int(NewPlayer.PlayerReplicationInfo.Team)] )
  {
    StartUpMessage = DefendMessage;
  }
  else
  {
    StartUpMessage = AttackMessage;
  }
  NewPlayer.SetProgressMessage( GameName, i++ );
  if ( bRequireReady && int(Level.NetMode)!=int(ENetMode.NM_Standalone) )
  {
    NewPlayer.SetProgressMessage( TourneyMessage, i++ );
  }
  else
  {
    NewPlayer.SetProgressMessage( StartUpMessage, i++ );
  }
  if ( GoalTeamScore>float(0) )
  {
    NewPlayer.SetProgressMessage( string(int(GoalTeamScore))@gamegoal, i++ );
  }
  if ( int(NewPlayer.PlayerReplicationInfo.Team)<4 )
  {
    NewPlayer.SetProgressColor( Class'ChallengeTeamHUD'.default.TeamColor[int(NewPlayer.PlayerReplicationInfo.Team)], i );
    if ( int(NewPlayer.PlayerReplicationInfo.Team)==Defender.TeamIndex )
    {
      NewPlayer.SetProgressMessage( StartUpTeamMessage@Teams[int(NewPlayer.PlayerReplicationInfo.Team)].TeamName@"(Defending).", i++ );
    }
    else
    {
      NewPlayer.SetProgressMessage( StartUpTeamMessage@Teams[int(NewPlayer.PlayerReplicationInfo.Team)].TeamName@"(Attacking).", i++ );
    }
    WhiteColor.R = byte(255);
    WhiteColor.G = byte(255);
    WhiteColor.B = byte(255);
    NewPlayer.SetProgressColor( WhiteColor, i );
    if ( !bRatedGame )
    {
      NewPlayer.SetProgressMessage( TeamChangeMessage, i++ );
    }
  }
  if ( int(Level.NetMode)==int(ENetMode.NM_Standalone) )
  {
    NewPlayer.SetProgressMessage( SingleWaitingMessage, i++ );
  }
}

function SendStartMessage (PlayerPawn P)
{
  ObjectivesMessage = GameName;
  Super.SendStartMessage(P);
}

function bool ChangeTeam (Pawn Other, int NewTeam)
{
  local Projectile P;

  if ( (Other.PlayerReplicationInfo.Team != 255) && bMatchMode )
  {
    return False;
  } else {
    foreach AllActors(Class'Projectile',P)
    {
      if ( (P.Owner == Other) || (P.Instigator == Other) )
      {
        P.Destroy();
      }
    }
    return Super.ChangeTeam(Other,NewTeam);
  }
}

function InitLogging ()
{
  local Mutator M;
  local DMMutator DMM;

  if ( bLocalLog && bLoggingGame )
  {
    Log( "Initiating local logging..." );
    LocalLog = Spawn( StatLogClass );
    LocalLog.bWorld = false;
    LocalLog.StartLog();
    LocalLog.LogStandardInfo();
    LocalLog.LogServerInfo();
    LocalLog.LogMapParameters();
    if ( bngStatsCompatibility )
    {
      DMM = Spawn( Class'DMMutator' );
      LocalLog.LogMutator( DMM );
      DMM.Destroy();
    }
    for ( M=BaseMutator; M!=None; M=M.NextMutator )
    {
      if ( !(bngStatsCompatibility && (M.IsA('CSHPBadge') || M.IsA('LeagueAS_Mutator') || M.IsA('HackProtection') || M.IsA('LeagueAS_AntiRocketLaunch') || M.IsA('LeagueAS_AntiHammerLaunch') || M.IsA('LeagueAS_MapVote'))) )
      {
        LocalLog.LogMutator( M );
      }
    }
    LogGameParameters( LocalLog );
    LocalLogFileName = LocalLog.GetLogFileName();
  }
  if ( int(Level.NetMode)!=int(ENetMode.NM_DedicatedServer) && int(Level.NetMode)!=int(ENetMode.NM_ListenServer) )
  {
    return;
  }
  if ( bWorldLog && bLoggingGame )
  {
    Log( "Initiating world logging..." );
    WorldLog = Spawn( StatLogClass );
    WorldLog.bWorld = true;
    WorldLog.StartLog();
    WorldLog.LogStandardInfo();
    WorldLog.LogServerInfo();
    WorldLog.LogMapParameters();
    WorldLog.InitialCheck( Self );
    if ( bngStatsCompatibility )
    {
      DMM = Spawn( Class'DMMutator' );
      WorldLog.LogMutator( DMM );
      DMM.Destroy();
    }
    for ( M=BaseMutator; M!=None; M=M.NextMutator )
    {
      if ( !(bngStatsCompatibility && (M.IsA('CSHPBadge') || M.IsA('LeagueAS_Mutator') || M.IsA('HackProtection') || M.IsA('LeagueAS_AntiRocketLaunch') || M.IsA('LeagueAS_AntiHammerLaunch') || M.IsA('LeagueAS_MapVote'))) )
      {
        WorldLog.LogMutator( M );
      }
    }
    LogGameParameters( WorldLog );
    WorldLogFileName = WorldLog.GetLogFileName();
  }
}

function LogGameParameters( StatLog StatLog )
{
  if ( StatLog==None )
  {
    return;
  }
  if ( bngStatsCompatibility )
  {
    StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameName"$Chr(9)$"Assault" );
    StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameClass"$Chr(9)$"Botpack.Assault" );
  }
  else
  {
    StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameName"$Chr(9)$GameName );
    StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameClass"$Chr(9)$string(Class) );
  }
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameVersion"$Chr(9)$Level.EngineVersion );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MinNetVersion"$Chr(9)$Level.MinNetVersion );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NoMonsters"$Chr(9)$string(bNoMonsters) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MuteSpectators"$Chr(9)$string(bMuteSpectators) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"HumansOnly"$Chr(9)$string(bHumansOnly) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"WeaponsStay"$Chr(9)$string(bCoopWeaponMode) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"ClassicDeathmessages"$Chr(9)$string(bClassicDeathMessages) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"LowGore"$Chr(9)$string(bLowGore) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"VeryLowGore"$Chr(9)$string(bVeryLowGore) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TeamGame"$Chr(9)$string(bTeamGame) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameSpeed"$Chr(9)$string(int(GameSpeed*float(100))) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxSpectators"$Chr(9)$string(MaxSpectators) );
  StatLog.LogEventString( StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxPlayers"$Chr(9)$string(MaxPlayers) );
}

defaultproperties
{
    bngStatsCompatibility=True
    bEnableCSHP=True
    bStandardise=True
    bAutoPausing=True
    MaxPauseTime=60
    MatchLength=14
    FirstMapStartTime=300
    SubsequentMapStartTime=60
    TeamNameRed="Red"
    TeamNameBlue="Blue"
    ModeratorPassword="moderator"
    VersionStr="1.30"
    AttackMessage="Assault the enemy base!"
    WinMessage="and win!"
    bForceRespawn=True
    ScoreBoardType=Class'LeagueAS_Scoreboard'
    HUDType=Class'LeagueAS_HUD'
    GameName="League Assault"
    MutatorClass=Class'LeagueAS_Mutator'
    GameReplicationInfoClass=Class'LeagueAS_GameReplicationInfo'
}
