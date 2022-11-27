//================================================================================
// HackProtection.
//================================================================================

class HackProtection extends Mutator
  Localized;

var string StrTab[255];
var string zzDECSTRTAB[255];
var string encoding_table[64];
var int zzKeyNdx;
var() config int SecurityLevel;
var() config float SecurityFrequency;
var() config float SecurityTolerance;
var() config int ScanForRogues;
var() config bool bTrackFOV;
var() config bool bTrackCV;
var() config int Advertise;
var() config bool bOnlyAdminKick;
var() config bool bUseNumericIP;
var() config bool bNGStatsOnly;
var() config bool bAllowNoSmoke;
var() config bool bUseCSHPLog;
var() config bool bFastTeams;
var() config int MaxInitTries;
var() config int bAdminWarn;
var bool zzbInitialized;
var PlayerPawn zzPlayerList[32];
var CSHPCheatRI zzPlayerRIList[32];
var int zzPlayerNetSpeed[32];
var vector zzPlayerVList[32];
var int zzPlayerHeld[32];
var string zzCheatTestIP;
var string zzMyPacks;
var CSHPCheatReporter zzMyCheat;
var localized string zzErrMsg;
var float zzTeamChangeTime;
var int zzGameState;
var string VersionStr;
var CSHPLog zzCheatLog;

function xxPreDecrypt()
{
}

event PreBeginPlay()
{
  xxPreDecrypt();
}

function xxCLog( string S )
{
  local Pawn zzP;

  if ( zzCheatLog!=None )
  {
    zzCheatLog.LogEventString( S );
    zzCheatLog.FileFlush();
  }
  for ( zzP=Level.PawnList; zzP!=None; zzP=zzP.nextPawn )
  {
    if ( zzP.IsA('MessagingSpectator') )
    {
      zzP.ClientMessage( "[CSHP]"@S, '' );
    }
  }
  Log( S );
}

function PostBeginPlay()
{
  local int zzi;

  Super.PostBeginPlay();
  if ( bUseCSHPLog )
  {
    zzCheatLog = Spawn( Class'CSHPLog' );
  }
  if ( zzCheatLog!=None )
  {
    zzCheatLog.StartLog();
  }
  xxCLog( "__________________________________________" );
  xxCLog( "" );
  xxCLog( "  ####   ####  #   #  ####" );
  xxCLog( " #      #      #   #  #   #" );
  xxCLog( " #       ###   #####  ####" );
  xxCLog( " #          #  #   #  #" );
  xxCLog( "  ####  ####   #   #  #" );
  xxCLog( "__________________________________________" );
  xxCLog( "" );
  xxCLog( "Version ....................... "$VersionStr );
  xxCLog( "Security Level is ............. "$string(SecurityLevel) );
  xxCLog( "Security Frequency is ......... "$string(SecurityFrequency) );
  xxCLog( "Security Tolerance is ......... "$string(SecurityTolerance) );
  xxCLog( "Scanning for Rogue Actors ..... "$string(ScanForRogues) );
  xxCLog( "Tracking FOV .................. "$string(bTrackFOV) );
  xxCLog( "Tracking CV ................... "$string(bTrackCV) );
  xxCLog( "Only Admin Kick ............... "$string(bOnlyAdminKick) );
  xxCLog( "Use Numeric IP ................ "$string(bUseNumericIP) );
  xxCLog( "NGStat Players Only ........... "$string(bNGStatsOnly) );
  xxCLog( "Allow NoSmoke ................. "$string(bAllowNoSmoke) );
  xxCLog( "Use CSHP Log .................. "$string(bUseCSHPLog) );
  xxCLog( "Fast Teams .................... "$string(bFastTeams) );
  xxCLog( "MaxInitTries .................. "$string(MaxInitTries) );
  xxCLog( "Admin Warning Enabled ......... "$string(bAdminWarn) );
  xxCLog( "" );
  xxCLog( "__________________________________________" );
  if ( Advertise>0 && Level.NetMode!=NM_Standalone && InStr(Level.Game.GameReplicationInfo.ServerName,"[CSHP]")==-1 )
  {
    if ( Advertise==1 )
    {
      Level.Game.GameReplicationInfo.ServerName = "[CSHP] " $ Level.Game.GameReplicationInfo.ServerName;
    }
    else if ( Advertise==2 )
    {
      Level.Game.GameReplicationInfo.ServerName = Level.Game.GameReplicationInfo.ServerName $ " [CSHP]";
    }
  }
  zzMyCheat = Spawn( Class'CSHPCheatReporter', Self );
  if ( zzMyCheat!=None )
  {
    zzMyCheat.zzMyMutie = Self;
  }
  else
  {
    Log( "[CSHPs] Get ready for a lot of errors, can't spawn Cheat Reporter" );
  }
  zzCheatTestIP = "";
  Level.Game.RegisterMessageMutator( Self );
}

function Tick( float DeltaTime )
{
  local int zzi, zzj, zzspd;
  local Pawn zzP;
  local CSHPCheatRI zzRI;
  local Inventory zzInv;

  if ( (Level.Game.bGameEnded || Level.NextSwitchCountdown<0.5) && zzCheatLog!=None )
  {
    zzCheatLog.StopLog();
    zzCheatLog.Destroy();
    zzCheatLog = None;
  }
  if ( zzGameState!=2 && Level.Game.bGameEnded )
  {
    zzGameState = 2;
  }
  else if ( zzGameState==0 && xxGameIsPlaying() )
  {
    zzGameState = 1;
  }
  for ( zzi=0; zzi<32; zzi++ )
  {
    zzP = zzPlayerList[zzi];
    zzRI = zzPlayerRIList[zzi];
    if ( (zzP==None || zzP.bDeleteMe) && zzRI!=None )
    {
      zzPlayerList[zzi] = None;
      zzPlayerRIList[zzi].Destroy();
      zzPlayerRIList[zzi] = None;
      zzPlayerHeld[zzi] = 0;
      zzPlayerVList[zzi] = vect(0.0,0.0,0.0);
      zzP = None;
    }
    if ( zzP!=None )
    {
      if ( zzRI!=None )
      {
        zzRI.zzGameState = zzGameState;
      }
      if ( !zzP.IsInState('PlayerWaiting') )
      {
        if ( zzPlayerHeld[zzi]==1 )
        {
          if ( zzPlayerRIList[zzi]!=None && zzPlayerRIList[zzi].zzbInitialized )
          {
            zzPlayerHeld[zzi] = 0;
            if ( !zzPlayerList[zzi].IsA('Spectator') )
            {
              zzPlayerList[zzi].SetPhysics( PHYS_Walking );
              Level.Game.RestartPlayer( zzPlayerList[zzi] );
            }
          }
          else
          {
            zzPlayerList[zzi].SetLocation( zzPlayerVList[zzi] );
          }
        }
        else if ( !zzPlayerRIList[zzi].zzbInitialized )
        {
          if ( !zzPlayerList[zzi].IsA('Spectator') )
          {
            zzPlayerList[zzi].Weapon = None;
            zzPlayerList[zzi].SelectedItem = None;
            for ( zzInv=zzPlayerList[zzi].Inventory; zzInv!=None; zzInv=zzInv.Inventory )
            {
              zzInv.Destroy();
            }
            zzPlayerList[zzi].bHidden = true;
            zzPlayerList[zzi].SetPhysics( PHYS_None );
            zzPlayerList[zzi].SetCollision( false, false, false );
            zzPlayerVList[zzi] = zzPlayerList[zzi].Location;
          }
          zzPlayerHeld[zzi] = 1;
        }
      }
    }
  }
  for ( zzP=Level.PawnList; zzP!=None; zzP=zzP.nextPawn )
  {
    if ( zzP.IsA('PlayerPawn') && zzP.PlayerReplicationInfo.bFeigningDeath )
    {
      if ( zzP.Weapon!=None )
      {
        zzP.bFire = 0;
        zzP.bAltFire = 0;
      }
    }
    if ( zzP.IsA('PlayerPawn') && !zzP.IsA('Spectator') && NetConnection(PlayerPawn(zzP).Player)!=None && !zzP.IsA('MessagingSpectator') && xxFindPIndexFor(zzP)==-1 )
    {
      zzi = 0;
      while ( zzi<32 && zzPlayerList[zzi]!=None )
      {
        zzi++;
      }
      zzPlayerList[zzi] = PlayerPawn(zzP);
      zzPlayerHeld[zzi] = 0;
      zzRI = Spawn( Class'CSHPCheatRI', zzP, , zzP.Location );
      if ( zzRI==None )
      {
        xxCLog( "[CSHPs] -- ERROR: CRI = None" );
      }
      else
      {
        zzPlayerRIList[zzi] = zzRI;
        zzPlayerNetSpeed[zzi] = 0;
        zzRI.zzMyMutie = Self;
        zzRI.zzSecurityLevel = SecurityLevel;
        zzRI.zzCheckForRogues = ScanForRogues;
        zzRI.zzWatchFOV = bTrackFOV;
        zzRI.zzWatchCV = bTrackCV;
        zzRI.zzbNGStatsOnly = bNGStatsOnly;
        zzRI.zzCheat = zzMyCheat;
        zzRI.zzbAllowNoSmoke = bAllowNoSmoke;
        zzRI.LeagueASVersionStr = LeagueAssault(Level.Game).VersionStr $ LeagueAssault(Level.Game).SubVersionStr;
        zzRI.zzServerPacks = zzMyPacks;
        zzMyCheat.xxClientLoggedIn( zzP, zzRI );
        zzRI.zzTimeOutGrace = Level.TimeSeconds+SecurityFrequency*Level.TimeDilation*float(3);
      }
    }
  }
}

function int xxFindPIndexFor( Pawn zzP )
{
  local int zzi;

  for ( zzi=0; zzi<32; zzi++ )
  {
    if ( zzPlayerList[zzi]!=None && zzPlayerList[zzi]==zzP )
    {
      return zzi;
    }
  }
  return -1;
}

function Mutate( string MutateString, PlayerPawn Sender )
{
  local PlayerPawn zzP;
  local int zzi;
  local bool zzb;

  if ( MutateString~="CheatKick" )
  {
    if ( !bOnlyAdminKick || Sender.bAdmin )
    {
      for ( zzi=0; zzi<32; zzi++ )
      {
        if ( zzPlayerList[zzi]!=None && zzPlayerRIList[zzi]!=None && zzPlayerRIList[zzi].zzbBadGuy )
        {
          zzPlayerList[zzi].Destroy();
        }
      }
    }
  }
  else if ( MutateString~="CheatShow" )
  {
    zzb = false;
    for ( zzi=0; zzi<32; zzi++ )
    {
      if ( zzPlayerList[zzi]!=None && zzPlayerRIList[zzi]!=None && zzPlayerRIList[zzi].zzbBadGuy )
      {
        zzb = true;
        Sender.ClientMessage( ""$zzPlayerList[zzi].PlayerReplicationInfo.PlayerName$" is cheating - "$zzPlayerRIList[zzi].zzLastCheat, , true );
      }
    }
    if ( !zzb )
    {
      Sender.ClientMessage( "No-one is cheating." );
    }
  }
  else if ( MutateString~="CheatInfo" )
  {
    Sender.ClientMessage( "This server is running "$VersionStr );
    Sender.ClientMessage( "Security Level is: "$string(SecurityLevel) );
    Sender.ClientMessage( "Scanning for Rogues: "$string(ScanForRogues) );
    Sender.ClientMessage( "Tracking FOV: "$string(bTrackFOV) );
    Sender.ClientMessage( "Tracking CV: "$string(bTrackCV) );
    Sender.ClientMessage( "Only Admin Kick: "$string(bOnlyAdminKick) );
    Sender.ClientMessage( "NGStats Only: "$string(bNGStatsOnly) );
    Sender.ClientMessage( "Allow NoSmoke: "$string(bAllowNoSmoke) );
    Sender.ClientMessage( "Use CSHP Log: "$string(bUseCSHPLog) );
    Sender.ClientMessage( "Fast Teams: "$string(bFastTeams) );
    Sender.ClientMessage( "Admin Warning Enabled: "$string(bAdminWarn) );
  }
  else if ( MutateString~="CheatTest" && Sender.bAdmin )
  {
    zzCheatTestIP = zzP.GetPlayerNetworkAddress();
    Sender.ClientMessage( "The IP "$zzCheatTestIP$" is exempt from Cheat logging for the rest of this map" );
    xxCLog( "[CSHPs] : The IP "$zzCheatTestIP$" is exempt from Cheat logging for the rest of this map (set by"$PlayerPawn(Owner).PlayerReplicationInfo.PlayerName$")" );
  }
  else if ( bFastTeams && MutateString~="FixTeams" )
  {
    MakeTeamsEven( Sender );
  }
  else if ( bFastTeams && MutateString~="NextTeam" )
  {
    NextTeam( Sender );
  }
  else if ( bFastTeams && Left(MutateString,11)~="ChangeTeam" )
  {
    SetTeam( Sender, Mid(MutateString,12) );
  }
  if ( NextMutator!=None )
  {
    NextMutator.Mutate( MutateString, Sender );
  }
}

function NextTeam( PlayerPawn zzP )
{
  local int nWantedTeam;
  local TeamGamePlus tgp;
  local float zzOldTeam;

  if ( Level.Game.bTeamGame && Level.Game.IsA('TeamGamePlus') && (Level.TimeSeconds-zzTeamChangeTime>float(60) || !xxGameIsPlaying() && Level.TimeSeconds-zzTeamChangeTime>float(5)) )
  {
    tgp = TeamGamePlus(Level.Game);
    zzOldTeam = float(zzP.PlayerReplicationInfo.Team);
    nWantedTeam = int(zzOldTeam+float(1));
    if ( nWantedTeam>=tgp.MaxTeams )
    {
      nWantedTeam = 0;
    }
    zzP.ChangeTeam( nWantedTeam );
    if ( float(zzP.PlayerReplicationInfo.Team)!=zzOldTeam )
    {
      if ( zzP.ViewTarget!=None )
      {
        zzP.bBehindView = false;
        zzP.ViewTarget = None;
      }
      zzTeamChangeTime = Level.TimeSeconds;
    }
  }
}

function MakeTeamsEven( PlayerPawn zzP )
{
  local int zzOldTeam, lowTeam, i, lowTeamSize;
  local TeamGamePlus tgp;

  if ( Level.Game.IsA('TeamGamePlus') && Level.Game.bTeamGame )
  {
    tgp = TeamGamePlus(Level.Game);
    lowTeamSize = 128;
    for ( i=0; i<tgp.MaxTeams; i++ )
    {
      if ( tgp.Teams[i].Size<lowTeamSize )
      {
        lowTeamSize = tgp.Teams[i].Size;
        lowTeam = i;
      }
    }
    zzOldTeam = int(zzP.PlayerReplicationInfo.Team);
    if ( tgp.Teams[zzOldTeam].Size-lowTeamSize<2 )
    {
      return;
    }
    Level.Game.ChangeTeam( zzP, lowTeam );
    if ( int(zzP.PlayerReplicationInfo.Team)!=zzOldTeam )
    {
      if ( zzP.ViewTarget!=None )
      {
        zzP.bBehindView = false;
        zzP.ViewTarget = None;
      }
      xxDied( zzP );
      zzTeamChangeTime = Level.TimeSeconds;
    }
  }
}

function SetTeam( PlayerPawn zzP, string zzsteam )
{
  local bool zzbValid;
  local int zzOldTeam, zzteam;

  if ( Level.Game.bTeamGame && Level.Game.IsA('TeamGamePlus') && (Level.TimeSeconds-zzTeamChangeTime>float(60) || !xxGameIsPlaying() && Level.TimeSeconds-zzTeamChangeTime>float(5)) )
  {
    zzbValid = true;
    if ( zzsteam~="red" || zzsteam~="0" )
    {
      zzteam = 0;
    }
    else if ( zzsteam~="blue" || zzsteam~="1" )
    {
      zzteam = 1;
    }
    else if ( zzsteam~="green" || zzsteam~="2" )
    {
      zzteam = 2;
    }
    else if ( zzsteam~="gold" || zzsteam~="3" )
    {
      zzteam = 3;
    }
    else
    {
      zzbValid = false;
    }
    if ( !zzbValid && zzteam>=TeamGamePlus(Level.Game).MaxTeams )
    {
      zzbValid = false;
    }
    if ( !zzbValid )
    {
      zzP.ClientMessage( "Wrong team selected : "$zzsteam );
      return;
    }
    zzOldTeam = int(zzP.PlayerReplicationInfo.Team);
    zzP.ChangeTeam( zzteam );
    if ( int(zzP.PlayerReplicationInfo.Team)!=zzOldTeam )
    {
      if ( zzP.ViewTarget!=None )
      {
        zzP.bBehindView = false;
        zzP.ViewTarget = None;
      }
      zzTeamChangeTime = Level.TimeSeconds;
    }
  }
}

function xxDied( Pawn zzP )
{
  local Pawn OtherPawn;
  local Actor A;

  if ( xxGameIsPlaying() )
  {
    zzP.Health = Min( 0, zzP.Health );
    for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
    {
      OtherPawn.Killed( zzP, zzP, '' );
    }
    if ( zzP.Event!='' )
    {
      foreach AllActors( Class'Actor', A, zzP.Event )
      {
        A.Trigger( zzP, None );
      }
    }
    Level.Game.DiscardInventory( zzP );
    Velocity.Z *= 1.3;
    if ( zzP.Gibbed('Suicided') )
    {
      zzP.SpawnGibbedCarcass();
      zzP.HidePlayer();
    }
    zzP.PlayDying( 'Suicided', zzP.Location );
    if ( int(zzP.RemoteRole)==int(ENetRole.ROLE_AutonomousProxy) )
    {
      zzP.ClientDying( 'Suicided', zzP.Location );
    }
    zzP.GotoState( 'Dying' );
  }
}

function bool xxGameIsPlaying()
{
  local DeathMatchPlus DMP;

  if ( Level.Game.IsA('DeathMatchPlus') )
  {
    DMP = DeathMatchPlus(Level.Game);
    if ( DMP.bGameEnded || DMP.bRequireReady && DMP.CountDown>0 )
    {
      return false;
    }
  }
  return true;
}

event Destroyed()
{
  Super.Destroyed();
  if ( zzCheatLog!=None )
  {
    zzCheatLog.StopLog();
    zzCheatLog.Destroy();
    zzCheatLog = None;
  }
}

function bool MutatorBroadcastMessage( Actor Sender, Pawn Receiver, coerce out string Msg, optional bool bBeep, optional out name Type )
{
  local Actor A;
  local bool legalspec;

  A = Sender;
  if ( A.IsA('GameInfo') && Receiver!=None && Receiver.PlayerReplicationInfo!=None && (Receiver.PlayerReplicationInfo.PlayerName@"gave up administrator abilities.")==Msg && (Receiver.GetStateName()=='PlayerWaiting' || Receiver.PlayerReplicationInfo.bIsSpectator) )
  {
    Receiver.GotoState( '' );
    Receiver.GotoState( 'PlayerWaiting' );
  }
  while ( !A.IsA('Pawn') && A.Owner!=None )
  {
    A = A.Owner;
  }
  if ( A.IsA('Spectator') )
  {
    legalspec = Left( Msg, Len(Spectator(A).PlayerReplicationInfo.PlayerName)+1 )==(Spectator(A).PlayerReplicationInfo.PlayerName $ ":") || A.IsA( 'MessagingSpectator' );
  }
  if ( legalspec )
  {
    legalspec = Type=='Event';
  }
  if ( A.IsA('Pawn') && !legalspec )
  {
    return false;
  }
  return Super.MutatorBroadcastMessage( Sender, Receiver, Msg, bBeep );
}

function bool MutatorBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out Class<LocalMessage> Message, optional out int Switch, optional out PlayerReplicationInfo RelatedPRI_1, optional out PlayerReplicationInfo RelatedPRI_2, optional out Object OptionalObject )
{
  local Actor A;

  A = Sender;
  while ( !A.IsA('Pawn') && A.Owner!=None )
  {
    A = A.Owner;
  }
  if ( A.IsA('Pawn') )
  {
    return false;
  }
  return Super.MutatorBroadcastLocalizedMessage( Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

function ModifyLogin( out Class<PlayerPawn> SpawnClass, out string Portal, out string Options )
{
  local Class<TournamentPlayer> tpc;
  local string zzInSkin, zzInFace;
  local Texture zztex;

  Super.ModifyLogin( SpawnClass, Portal, Options );
  tpc = Class<TournamentPlayer>(SpawnClass);
  if ( tpc!=None )
  {
    zzInSkin = Caps( xxGetClass(Level.Game.ParseOption(Options,"Skin")) );
    zzInFace = Caps( xxGetClass(Level.Game.ParseOption(Options,"Face")) );
    if ( !xxValidSP(zzInSkin) || zzInFace!="" && !xxValidSP(zzInFace) )
    {
      Options = xxFixOption( Options, "Skin", tpc.default.DefaultSkinName );
      Options = xxFixOption( Options, "Face", "" );
    }
  }
}

function string xxFixOption( string Options, string InKey, string Value )
{
  local string NewOption, Pair, xKey, xVal;

  NewOption = "";
  while ( Level.Game.GrabOption(Options,Pair) )
  {
    Level.Game.GetKeyValue( Pair, xKey, xVal );
    if ( xKey~=InKey )
    {
      NewOption = NewOption $ "?" $ xKey $ "=" $ Value;
    }
    else
    {
      NewOption = NewOption $ "?" $ Pair;
    }
  }
  return NewOption;
}

function string xxGetClass( string zzClassname )
{
  local string zzcls;
  local int zzP;

  zzcls = Caps( zzClassname );
  zzP = InStr( zzcls, "." );
  return Left( zzcls, zzP );
}

function bool xxValidSP( string zzPackname )
{
  local int zzP;

  if ( zzMyPacks=="" )
  {
    zzMyPacks = Caps( ConsoleCommand("get engine.gameengine serverpackages") );
  }
  zzP = InStr( zzMyPacks, Chr(34)$zzPackname$Chr(34) );
  if ( zzP==-1 || zzPackname~="BOTPACK" )
  {
    return false;
  }
  return true;
}

function bool PreventDeath( Pawn Killed, Pawn Killer, name DamageType, vector HitLocation )
{
  local int zzCRINo;
  local CSHPCheatRI zzCRI;
  local PlayerReplicationInfo zzPRI;
  local CTFFlag zzflag;

  if ( Killer!=None && Killer.PlayerReplicationInfo!=None )
  {
    zzPRI = Killer.PlayerReplicationInfo;
    if ( zzPRI.HasFlag!=None )
    {
      zzflag = CTFFlag(zzPRI.HasFlag);
      if ( zzflag.Holder!=None && zzflag.Holder!=Killer )
      {
        zzPRI.HasFlag = None;
      }
    }
  }
  zzCRINo = xxFindPIndexFor( Killer );
  if ( zzCRINo>-1 )
  {
    zzCRI = zzPlayerRIList[zzCRINo];
    if ( zzCRI.xxCheckTimeStamp(0.0) )
    {
      return true;
    }
  }
  if ( Killed!=None && !xxIsPlaying(Killed) )
  {
    return true;
  }
  return Super.PreventDeath( Killed, Killer, DamageType, HitLocation );
}

function bool xxIsPlaying( Pawn zzOther )
{
  local PlayerReplicationInfo zzPRI;

  zzPRI = zzOther.PlayerReplicationInfo;
  if ( zzPRI!=None && (zzPRI.bIsSpectator || zzPRI.bWaitingPlayer) || Caps(string(zzOther.GetStateName()))=="GAMEENDED" )
  {
    return false;
  }
  return true;
}

function bool HandlePickupQuery( Pawn Other, Inventory Item, out byte bAllowPickup )
{
  local bool bValid;
  local int i;
  local Inventory belt, pads, Armor;

  bValid = false;
  for ( i=0; i<4; i++ )
  {
    if ( Other.Touching[i]==Item )
    {
      bValid = true;
    }
  }
  if ( !bValid )
  {
    return false;
  }
  if ( Item.IsA('UT_ShieldBelt') )
  {
    Item.default.Charge = 150;
  }
  else if ( Item.IsA('Armor2') || Item.IsA('ThighPads') )
  {
    belt = Other.FindInventoryType( Class'UT_ShieldBelt' );
    if ( belt!=None )
    {
      belt.default.Charge = 150;
      pads = Other.FindInventoryType( Class'ThighPads' );
      Armor = Other.FindInventoryType( Class'Armor2' );
      if ( Item.IsA('Armor2') && pads!=None )
      {
        belt.default.Charge = 150-pads.Charge;
      }
      else if ( Item.IsA('ThighPads') && Armor!=None )
      {
        belt.default.Charge = 150-Armor.Charge;
      }
    }
  }
  return Super.HandlePickupQuery( Other, Item, bAllowPickup );
}

defaultproperties
{
    SecurityLevel=1
    SecurityFrequency=2.00
    SecurityTolerance=60.00
    ScanForRogues=1
    bTrackFOV=1
    bTrackCV=True
    bOnlyAdminKick=True
    bFastTeams=True
    MaxInitTries=15
    bAdminWarn=1
    VersionStr="Enhanced CSHP"
}
