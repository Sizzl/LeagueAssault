//================================================================================
// CSHPCheatRI.
//================================================================================

class CSHPCheatRI extends ReplicationInfo;

struct xxtGCF
{
  var bool zzbCheckVR;
  var bool zzbCheckFire;
  var bool zzbCheckPlayer;
  var bool zzbCheckConsole;
};

var string StrTab[255];
var string zzDECSTRTAB[255];
var string encoding_table[64];
var int zzKeyNdx;
var bool zzbDebug;
var string VersionStr;
var string LeagueASVersionStr;
var bool zzWatchFOV;
var bool zzWatchCV;
var bool zzbCVWarned;
var bool zzbCheckForRogues;
var bool zzbRogueFound;
var int zzSecurityLevel;
var bool zzbNGStatsOnly;
var bool zzbAllowNoSmoke;
var int zzGameState;
var string zzServerPacks;
var xxtGCF zzbGlobalCheckFlags;
var bool zzbInitialized;
var float zzTimeStamp;
var float zzTimeCheck;
var bool zzbClientMsgWaiting;
var int zzClientMsgType;
var string zzClientMsg;
var PlayerPawn zzMyPlayer;
var CSHPConsole zzMyConsole;
var CSHPBadge zzMyBadge;
var int zzCanvasGrace;
var int zzAckDelay;
var bool zzbGlobalVRCheck;
var bool zzbGlobalFireCheck;
var rotator zzMyVR;
var byte zzbFire;
var byte zzbAltFire;
var bool zzbIsMac;
var bool zzbIsPC;
var bool zzbIsLinux;
var bool zzbHasVR;
var bool zzbSetPlayerAlready;
var string zzLastCheat;
var HackProtection zzMyMutie;
var bool zzbBadGuy;
var CSHPCheatReporter zzCheat;
var float zzLastHey;
var int zzClientInitStatus;
var int zzClientInitTries;
var int zzLastServerMsg;
var float zzTimeOutGrace;
var int zzNames;
var int zzNameSize;
var int zzImports;
var int zzExports;
var int zzGenerations;
var int zzLazyLoaders;
var string zzLookupName;
var int zzInvalidConsoleCnt;

replication
{
  reliable if ( Role<ROLE_Authority )
    xxServerLog2, xxServerLog, xxDoServerMsg;

  reliable if ( Role<ROLE_Authority )
    xxHeyServer, xxServerGo, xxServerACK;

  reliable if ( Role==ROLE_Authority )
    LeagueASVersionStr, zzWatchFOV, zzWatchCV, zzbCheckForRogues,
    zzSecurityLevel, zzbNGStatsOnly, zzbAllowNoSmoke, zzGameState,
    zzServerPacks;

  reliable if ( Role==ROLE_Authority )
    xxClientGoCrashYourself, xxClientGo;

  reliable if ( Role==ROLE_Authority )
    xxHeyClient, xxClientACK;
}

function xxPreDecrypt ()
{
}

simulated event PostNetBeginPlay ()
{
  Super.PostNetBeginPlay();
  if ( (Level.NetMode == NM_Client) && (Role < ROLE_SimulatedProxy) ||  !bNetOwner )
  {
    return;
  }
  xxPreDecrypt();
  zzAckDelay = 5;
  GotoState( 'xxClientInitializing' );
}

simulated function xxVerifyCompile ()
{
}

simulated function xxVerifyClass ()
{
}

simulated function xxAttachConsole ()
{
  local CSHPConsole C;
  local UTConsole oldc;

  if ( zzMyConsole == None )
  {
    zzMyConsole = CSHPConsole(zzMyPlayer.Player.Console);
    if ( zzMyConsole == None )
    {
      zzMyPlayer.Player.Console.Disable('Tick');
      C = new (None,Class'CSHPConsole');
      if ( C != None )
      {
        oldc = UTConsole(zzMyPlayer.Player.Console);
        C.zzMyCheatRI = self;
        C.zzOldConsole = oldc;
        zzMyPlayer.Player.Console = C;
        zzMyConsole = C;
        zzMyConsole.xxGetValues();
        zzMyConsole.ConsoleWindow.WindowTitle = "Console - " $ zzMyBadge.VersionStr;
      } else {
        xxDoClientMsg(1,1,"");
      }
    } else {
      if ( zzMyPlayer.Player.Console.Class != Class'CSHPConsole' )
      {
        zzbBadGuy = True;
        xxDoClientMsg(1,2,"" $ string(zzMyPlayer.Player.Console.Class));
        zzMyPlayer.ConsoleCommand("disconnect");
      }
    }
  }
}

simulated function xxAttachBadge ()
{
  local Mutator zzHM;

  if ( (zzMyBadge != None) || (zzMyPlayer == None) || (zzMyPlayer.myHUD == None) )
  {
    return;
  }
  zzMyBadge = Spawn(Class'CSHPBadge',zzMyPlayer);
  if ( zzMyBadge == None )
  {
    xxServerLog("Couldn't Spawn Badge");
  } else {
    zzMyBadge.xxPreDecrypt();
    zzHM = zzMyPlayer.myHUD.HUDMutator;
    if ( zzHM != None )
    {
      zzMyBadge.zzNextHud = zzHM;
    }
    zzMyBadge.zzMyCheatRI = self;
    zzMyBadge.LeagueASVersionStr = LeagueASVersionStr;
    zzMyPlayer.myHUD.HUDMutator = zzMyBadge;
  }
}

simulated function bool xxTestPlayer ()
{
  return (PlayerPawn(Owner) == None) || (PlayerPawn(Owner) != zzMyPlayer) || (zzMyPlayer.Player == None);
}

simulated function bool xxTestConsole ()
{
  return (zzMyConsole == None) || (zzMyPlayer.Player.Console != zzMyConsole) || (zzMyPlayer.Player.Console.Class != Class'CSHPConsole');
}

simulated function xxCheckEntryActors()
{
  local Actor zzCheckActor;

  foreach zzMyPlayer.GetEntryLevel().AllActors( Class'Actor', zzCheckActor )
  {
    xxCheckActor( zzCheckActor );
  }
}

simulated function xxCheckLevelActors()
{
  local Actor zzCheckActor;

  foreach AllActors( Class'Actor', zzCheckActor )
  {
    xxCheckActor( zzCheckActor );
  }
}

simulated function xxCheckActor( Actor zzInActor )
{
  local string zzActorPackage, zzSelfPackage, zzMapName;

  zzActorPackage = Left( string(zzInActor.Class), InStr(string(zzInActor.Class),".") );
  zzSelfPackage = Left( string(Self.Class), InStr(string(Self.Class),".") );
  zzMapName = Left( string(Self), InStr(string(Self),".") );
  if ( Caps(zzActorPackage)!="BOTPACK" && Caps(zzActorPackage)!="ENGINE" && Caps(zzActorPackage)!="UNREALSHARE" && Caps(zzActorPackage)!="UNREALI" && Caps(zzActorPackage)!="LEAGUEAS-CP" && Caps(zzActorPackage)!=Caps(zzSelfPackage) && Caps(zzActorPackage)!="UBROWSER" && Caps(zzActorPackage)!="UTBROWSER" && Caps(zzActorPackage)!="UMENU" && Caps(zzActorPackage)!=Caps(zzMapName) )
  {
    if ( InStr(Caps(zzServerPacks),Chr(34)$Caps(zzActorPackage)$Chr(34))==-1 )
    {
      if ( !(zzbAllowNoSmoke && Caps(zzActorPackage)=="NOSMOKE") )
      {
        if ( zzbRogueFound )
        {
          xxDoClientMsg( 1, 21, "" );
        }
        else
        {
          zzInActor.Destroy();
          xxServerLog( "Rogue Actor Detected. Class:"@string(zzInActor.Class)$"." );
          zzbRogueFound = true;
        }
      }
    }
  }
}

simulated function xxCheckVR( Canvas zzCanvas, float Delta )
{
  local rotator zzOldViewRotation, zzr;
  local string zzpstate;
  local bool zzbCheckMod, zzbCheckVR, zzbCheckFire;

  zzpstate = "" $ string(zzMyPlayer.GetStateName());
  zzbCheckMod = Level.Pauser=="" && (zzpstate~="PlayerWalking" || zzpstate~="PlayerSwimming") && zzMyPlayer.Weapon!=None && !zzMyPlayer.Weapon.IsA( 'WarheadLauncher' ) && zzGameState==1;
  zzbCheckMod = zzbCheckMod && zzbHasVR;
  zzbCheckVR = Normalize( zzMyPlayer.ViewRotation )!=Normalize( zzMyVR );
  zzbCheckFire = int(zzMyPlayer.bFire)!=int(zzbFire) || int(zzMyPlayer.bAltFire)!=int(zzbAltFire);
  zzbCheckVR = zzbCheckVR && zzbCheckMod;
  zzbCheckFire = zzbCheckFire && zzbCheckMod;
  zzbGlobalCheckFlags.zzbCheckVR = zzbGlobalCheckFlags.zzbCheckVR || zzbCheckVR;
  zzbGlobalCheckFlags.zzbCheckFire = zzbGlobalCheckFlags.zzbCheckFire || zzbCheckFire;
  if ( zzbCheckVR )
  {
    zzbBadGuy = true;
    xxDoClientMsg( 1, 4, "" );
  }
  if ( zzbCheckFire )
  {
    zzbBadGuy = true;
    xxDoClientMsg( 1, 5, "" );
  }
}

simulated function bool xxCheckPackages ()
{
  local string zzt;
  local string zzPackages;
  local string zzPackage;
  local bool zzbValid;
  local xxCSHPcc zzactor;
  local SpawnNotify SN;

  if (  !xxValidVersion() )
  {
    xxDoClientMsg(2,-1,"");
    return True;
  }
  zzbValid = True;
  SN = Level.SpawnNotify;
  Level.SpawnNotify = None;
  zzactor = Spawn(Class'xxCSHPcc');
  Level.SpawnNotify = SN;
  if ( zzactor == None )
  {
    return False;
  }
  if ( zzactor.Class != Class'xxCSHPcc' )
  {
    return False;
  }
  zzPackages = zzactor.ConsoleCommand("OBJ LINKERS");
  zzactor.Destroy();
  if ( zzPackages == "" )
  {
    return False;
  }
  zzPackage = xxParsePackage(zzPackages);
  while ( (zzPackage != "") && zzbValid )
  {
    xxParseLine(zzPackage);
    switch (zzLookupName)
    {
      case "Core 436":
      zzbValid = xxCheckValues(327,10,16,669,10,0);
      break;
      case "Engine 436":
      zzbValid = xxCheckValues(3348,112,60,5370,17,1);
      break;
      case "IpDrv 436":
      zzbValid = xxCheckValues(136,4,28,168,10,0);
      break;
      case "Fire 436":
      zzbValid = xxCheckValues(181,5,15,108,10,0);
      break;
      case "UnrealShare 436":
      zzbValid = xxCheckValues(4604,143,787,8865,3,1);
      if (  !zzbValid )
      {
        zzbValid = xxCheckValues(4563,143,787,8773,1,0);
      }
      break;
      case "UnrealI 436":
      zzbValid = xxCheckValues(2201,68,670,3017,1,0);
      break;
      case "Botpack 436":
      zzbValid = xxCheckValues(7625,194,1490,12695,14,0);
      break;
      case "UWindow 436":
      zzbValid = xxCheckValues(1407,46,98,3423,10,0);
      break;
      case "UMenu 436":
      zzbValid = xxCheckValues(2012,62,503,3068,12,0);
      if (  !zzbValid && zzbIsMac )
      {
        zzbValid = xxCheckValues(1716,41,503,2776,1,0);
      } else {
        if (  !zzbValid && zzbIsLinux )
        {
          zzbValid = xxCheckValues(1711,41,502,2773,1,0);
        }
      }
      break;
      case "UBrowser 436":
      zzbValid = xxCheckValues(1082,37,269,1843,10,0);
      break;
      case "UTServerAdmin 436":
      zzbValid = xxCheckValues(326,11,127,353,10,0);
      break;
      case "UTBrowser 436":
      zzbValid = xxCheckValues(138,4,68,63,10,0);
      break;
      case "UTMenu 436":
      zzbValid = xxCheckValues(1984,62,720,3065,11,0);
      if (  !zzbValid && zzbIsMac )
      {
        zzbValid = xxCheckValues(1761,41,719,2853,1,0);
      }
      break;
      case "UWeb 436":
      zzbValid = xxCheckValues(153,4,35,156,10,0);
      break;
      case "IpServer 436":
      zzbValid = xxCheckValues(142,4,59,158,11,0);
      break;
      case "Engine 432":
      zzbValid = xxCheckValues(3345,112,60,5370,14,0);
      break;
      case "Core 432":
      zzbValid = xxCheckValues(326,10,16,669,9,0);
      break;
      case "Fire 432":
      zzbValid = xxCheckValues(180,5,15,108,9,0);
      break;
      case "Botpack 432":
      zzbValid = xxCheckValues(7453,198,1490,12393,12,0);
      break;
      case "UnrealI 432":
      zzbValid = xxCheckValues(2201,68,670,3017,1,0);
      break;
      case "UMenu 432":
      zzbValid = xxCheckValues(1919,62,503,2977,10,0);
      if (  !zzbValid )
      {
        zzbValid = xxCheckValues(2009,62,503,3067,10,0);
      }
      break;
      case "UWindow 432":
      zzbValid = xxCheckValues(1406,46,98,3423,9,0);
      break;
      case "UBrowser 432":
      zzbValid = xxCheckValues(1080,37,269,1842,9,0);
      break;
      case "UTBrowser 432":
      zzbValid = xxCheckValues(137,4,68,63,9,0);
      break;
      case "IpDrv 432":
      zzbValid = xxCheckValues(135,4,28,168,9,0);
      break;
      case "UTMenu 432":
      zzbValid = xxCheckValues(1983,62,720,3065,10,0);
      break;
      case "UWeb 432":
      zzbValid = xxCheckValues(152,4,35,156,9,0);
      break;
      case "UTServerAdmin 432":
      zzbValid = xxCheckValues(325,11,127,353,9,0);
      break;
      case "IpServer 432":
      zzbValid = xxCheckValues(141,4,59,158,10,0);
      break;
      default:
    }
    zzPackage = xxParsePackage(zzPackages);
  }
  return zzbValid;
}

simulated function bool xxValidVersion ()
{
  local int i;

  i = int(Level.EngineVersion);
  return (i == 436) || (i == 432);
}

simulated function bool xxCheckValues (int zzinnames, int zzinnamesize, int zzinimports, int zzinexports, int zzingenerations, int zzinlazyloaders)
{
  return (zzNames == zzinnames) && (zzGenerations == zzingenerations) || (zzNames == zzinnames + zzinlazyloaders) && (zzGenerations == zzingenerations + zzinlazyloaders) && (zzImports == zzinimports) && (zzExports == zzinexports);
}

simulated function string xxParsePackage (out string zzPackages)
{
  local int zzpos;
  local string zzPackage;

  zzpos = InStr(zzPackages,".u");
  if ( zzpos != -1 )
  {
    zzPackage = Left(zzPackages,zzpos) $ " ";
    zzPackages = Mid(zzPackages,zzpos + 1);
  } else {
    zzPackage = zzPackages;
    zzPackages = "";
  }
  return zzPackage;
}

simulated function xxParseLine (string zzPackage)
{
  local string zzfullname;

  zzfullname = xxParsePart(zzPackage,"(Package ",")");
  zzNames = int(xxParsePart(zzPackage,"="," "));
  zzNameSize = int(xxParsePart(zzPackage,"/","K"));
  zzImports = int(xxParsePart(zzPackage,"="," "));
  zzExports = int(xxParsePart(zzPackage,"="," "));
  zzGenerations = int(xxParsePart(zzPackage,"="," "));
  zzLazyLoaders = int(xxParsePart(zzPackage,"="," "));
  zzLookupName = zzfullname @ Level.EngineVersion;
}

simulated function string xxParsePart (out string zzPackage, string zzbegin, string zzend)
{
  local int zzpos;
  local string zzpart;

  zzpos = InStr(zzPackage,zzbegin) + Len(zzbegin);
  zzPackage = Mid(zzPackage,zzpos);
  zzpos = InStr(zzPackage,zzend);
  zzpart = Left(zzPackage,zzpos);
  zzPackage = Mid(zzPackage,zzpos + Len(zzend));
  return zzpart;
}

simulated function xxLogAimbot (string zzcode)
{
  xxDoClientMsg(1,7,"");
}

function xxDoServerMsg (int zzMessageType, int zzMessageId, int zzCheatID, string zzMisc)
{
  zzLastServerMsg = zzMessageId;
  zzCheat.xxServerCheatFound(Owner,self,zzMessageId,zzCheatID,zzMisc);
}

simulated function xxDoClientMsg (int zzMessageType, int zzMessageId, string zzMisc)
{
  local UTConsole zzCon;

  xxDoServerMsg(zzMessageType,zzMessageId,xxIdCheat(),zzMisc);
  if ( zzbClientMsgWaiting )
  {
    return;
  }
  zzCon = zzMyConsole.zzOldConsole;
  zzMyConsole.xxrevert();
  zzCon.bQuickKeyEnable = True;
  zzCon.LaunchUWindow();
  zzCon.ShowConsole();
  zzbClientMsgWaiting = True;
  zzClientMsgType = zzMessageType;
}

simulated function xxProcessMessages ()
{
  if ( zzbClientMsgWaiting )
  {
    if ( zzMyConsole.Root != None )
    {
      switch (zzClientMsgType)
      {
        case 0:
        xxShowNGStatsMsg();
        break;
        case 1:
        xxCheatFound();
        break;
        case 2:
        xxShowBadVerMsg();
        break;
        case 3:
        xxBadCRC();
        break;
        default:
      }
      zzbClientMsgWaiting = False;
      zzClientMsgType = -1;
    }
  }
}

simulated function int xxIdCheat ()
{
  if ( Caps(string(zzMyConsole.Class)) ~= "funbot.funbot" )
  {
    return 0;
  }
  if ( zzMyConsole.ConsoleCommand("a1") )
  {
    return 1;
  }
  if ( Caps(string(zzMyConsole.Class)) ~= "relics.input" )
  {
    return 2;
  }
  if ( Caps(string(zzMyConsole.Class)) ~= "relicsbindings.input" )
  {
    return 3;
  }
  if ( zzMyConsole.GetPropertyText("justiceaim") != "" )
  {
    return 4;
  }
  if ( zzMyConsole.GetPropertyText("saintaim") != "" )
  {
    return 5;
  }
  if (  !zzbIsMac && zzMyConsole.ConsoleCommand("starttimer") )
  {
    return 6;
  }
  if ( zzMyConsole.GetPropertyText("bhackaim") != "" )
  {
    return 7;
  }
  if ( zzMyConsole.GetPropertyText("TOBOT_INFO") != "" )
  {
    return 8;
  }
  if ( zzMyConsole.GetPropertyText("TBT_Info") != "" )
  {
    return 9;
  }
  if ( zzMyConsole.GetPropertyText("w_teammate") != "" )
  {
    return 10;
  }
  if ( zzMyConsole.GetPropertyText("Tell_Version") != "" )
  {
    return 11;
  }
  if ( zzMyConsole.GetPropertyText("L_Enemy") != "" )
  {
    return 12;
  }
  if ( zzMyConsole.GetPropertyText("NoClanRules") != "" )
  {
    return 13;
  }
  if ( zzMyConsole.GetPropertyText("Elf") != "" )
  {
    return 14;
  }
  foreach zzMyPlayer.GetEntryLevel().AllActors( Class'Actor', zzCheckActor )
  {
    if ( Caps(string(zzCheckActor.Class))=="TRACEBOT.TB_BOT" )
    {
      return 15;
    }
  }
  return -1;
}

simulated function xxCheatFound ()
{
  local UTConsole zzCon;

  if ( zzbBadGuy )
  {
    return;
  }
  zzMyConsole.xxrevert();
  zzCon = zzMyConsole.zzOldConsole;
  zzCon.AddString("========================================================");
  zzCon.AddString("  CSHP has detected that a cheat hiding in your client ");
  zzCon.AddString("========================================================");
  if ( zzSecurityLevel == 1 )
  {
    zzCon.AddString("Because of this you have been removed from the ");
    zzCon.AddString("server.  Fair play is important, stop cheating ");
    zzCon.AddString("and then you can return!");
  } else {
    if ( zzSecurityLevel == 2 )
    {
      zzCon.AddString("Because of this you have been banned on this server!");
    }
  }
  zzCon.AddString(" ");
  zzCon.AddString("If you feel this was in error, please contact the admin");
  zzCon.AddString("at: " $ PlayerPawn(Owner).GameReplicationInfo.AdminEmail);
  zzbBadGuy = True;
}

simulated function xxBadCRC ()
{
  local UTConsole zzCon;

  if ( zzbBadGuy )
  {
    return;
  }
  zzMyConsole.xxrevert();
  zzCon = zzMyConsole.zzOldConsole;
  zzCon.AddString("========================================================");
  zzCon.AddString("      Your client has failed the UCRC check ");
  zzCon.AddString("========================================================");
  if ( zzSecurityLevel == 1 )
  {
    zzCon.AddString("Because of this you have been removed from the ");
    zzCon.AddString("server.  Please try reinstalling the latest  ");
    zzCon.AddString("patch before you play here!");
    zzCon.AddString("");
    zzCon.AddString("It can be found at: http://unreal.epicgames.com");
  } else {
    if ( zzSecurityLevel == 2 )
    {
      zzCon.AddString("Because of this you have been removed from the ");
      zzCon.AddString("server and banned.  Please try reinstalling the latest  ");
      zzCon.AddString("patch, and the contact the server admin");
      zzCon.AddString("");
      zzCon.AddString("The Patch can be found at: http://unreal.epicgames.com");
    }
  }
  zzCon.AddString(" ");
  zzCon.AddString("If you feel this was in error, please contact the admin");
  zzCon.AddString("at: " $ PlayerPawn(Owner).GameReplicationInfo.AdminEmail);
  zzbBadGuy = True;
}

simulated function xxShowNGStatsMsg ()
{
  local Console zzCon;

  if ( zzMyConsole == None )
  {
    return;
  }
  zzCon = zzMyConsole.zzOldConsole;
  zzMyConsole.xxrevert();
  zzCon.AddString("=====================================");
  zzCon.AddString("       This is NG STAT's ONLY        ");
  zzCon.AddString("=====================================");
  zzCon.AddString(" ");
  zzCon.AddString("Only players who participate in the NG Stat's Ranking ");
  zzCon.AddString("are allowed on this server.  Please refer to the NG Stats");
  zzCon.AddString("home page at http://www.ngworldstats.com or the server's");
  zzCon.AddString("web site for more information!");
  zzCon.AddString(" ");
  zzMyPlayer.ConsoleCommand("Disconnect");
}

simulated function xxShowBadVerMsg ()
{
  local Console zzCon;

  if ( zzMyConsole == None )
  {
    return;
  }
  zzCon = zzMyConsole.zzOldConsole;
  zzMyConsole.xxrevert();
  zzCon.AddString("=====================================");
  zzCon.AddString("        You need to updated!!!       ");
  zzCon.AddString("=====================================");
  zzCon.AddString(" ");
  zzCon.AddString("This server only supports Unreal Tournament versions ");
  zzCon.AddString("432 and 436.  We have detected you are using " $ Level.EngineVersion $ "!");
  zzCon.AddString("Before you can play here, you must upgrade.  Please go");
  zzCon.AddString("to http://unreal.epicgames.com and download the latest version!");
  zzCon.AddString(" ");
  zzMyPlayer.ConsoleCommand("Disconnect");
}

function xxServerLog (string zzLogString)
{
  zzCheat.xxServerLog(Owner,self,zzLogString);
}

function xxServerLog2 (string zzLogString)
{
  zzCheat.xxServerLog2(Owner,zzLogString);
}

function xxServerACK (float zzTimeStamp)
{
  xxClientACK(Level.TimeSeconds);
}

function xxServerGo (float zzTimeStamp)
{
  xxClientGo(Level.TimeSeconds);
  GotoState('ServerWorking');
}

function xxHeyServer (xxtGCF zzbCheckFlags, float zzNewTimeStamp)
{
  zzTimeStamp = zzNewTimeStamp;
  zzLastHey = Level.TimeSeconds;
  if ( zzbCheckFlags.zzbCheckConsole )
  {
    zzCheat.xxServerCheatFound(Owner,self,9,-1,"");
  }
  if ( zzbCheckFlags.zzbCheckVR )
  {
    zzCheat.xxServerCheatFound(Owner,self,7,-1,"");
  }
  if ( zzbCheckFlags.zzbCheckFire )
  {
    zzCheat.xxServerCheatFound(Owner,self,5,-1,"");
  }
  if ( zzbCheckFlags.zzbCheckPlayer )
  {
    zzCheat.xxServerCheatFound(Owner,self,8,-1,"");
  }
}

simulated function xxClientACK (float zzTimeStamp)
{
  if (  !IsInState('xxClientAcking') )
  {
    xxServerLog2("CA Received @ " $ string(Level.TimeSeconds) $ " sent @ " $ string(zzTimeStamp) $ " but in wrong state");
    return;
  }
  if ( xxIdCheat() != -1 )
  {
    xxDoServerMsg(1,17,xxIdCheat(),"");
    return;
  }
  GotoState('xxClientAuthorizing');
}

simulated function xxClientGo (float zzTimeStamp)
{
  if (  !IsInState('xxClientAuthorizing') )
  {
    xxServerLog2("CG Received @ " $ string(Level.TimeSeconds) $ " sent @ " $ string(zzTimeStamp) $ " but in wrong state");
    return;
  }
  if ( xxIdCheat() != -1 )
  {
    xxDoServerMsg(1,17,xxIdCheat(),"");
    return;
  }
  GotoState('xxClientWorking');
}

simulated function xxClientGoCrashYourself ()
{
  zzMyPlayer.SetOwner(self);
  SetOwner(zzMyPlayer);
}

simulated function xxHeyClient (float zzTimeStamp)
{
  local bool zzb1;
  local bool zzb2;

  if (  !IsInState('xxClientWorking') )
  {
    xxServerLog2("CG Received @ " $ string(Level.TimeSeconds) $ " sent @ " $ string(zzTimeStamp) $ " but in wrong state");
    return;
  }
  zzb1 = xxTestPlayer();
  zzbGlobalCheckFlags.zzbCheckPlayer = zzbGlobalCheckFlags.zzbCheckPlayer || zzb1;
  zzb2 = xxTestConsole();
  zzbGlobalCheckFlags.zzbCheckConsole = zzbGlobalCheckFlags.zzbCheckConsole || zzb2;
  xxHeyServer(zzbGlobalCheckFlags,Level.TimeSeconds);
  if ( zzb1 )
  {
    xxDoClientMsg(1,8,"");
  }
  if ( zzb2 )
  {
    xxDoClientMsg(1,9,"");
  }
}

function bool xxCheckTimeStamp (float Delta)
{
  if ( Level.TimeSeconds <= zzTimeOutGrace )
  {
    return False;
  }
  if ( Level.TimeSeconds - zzLastHey > zzMyMutie.SecurityTolerance )
  {
    zzCheat.xxClientTimedOut(Owner,self);
  }
  return Level.TimeSeconds - zzLastHey > zzMyMutie.SecurityTolerance;
}

auto state ServerAwaitingACK
{
  function xxTalkToClient ()
  {
    if ( zzClientInitTries > zzMyMutie.MaxInitTries )
    {
      zzCheat.xxClientTimedOut(Owner,self);
    } else {
      zzClientInitTries++;
    }
  }
Begin:
  while ( True )
  {
    Sleep(2.0 * Level.TimeDilation);
    xxTalkToClient();
  }
}

state ServerWorking
{
  function BeginState ()
  {
    zzLastHey = Level.TimeSeconds;
    zzCheat.xxClientLoggedOn(Owner,self);
    zzbInitialized = True;
  }
  
  function xxTalkToClient ()
  {
    xxHeyClient(Level.TimeSeconds);
  }
Begin:
  zzTimeStamp = 0.0;
  while ( True )
  {
    Sleep(zzMyMutie.SecurityFrequency * Level.TimeDilation);
    xxTalkToClient();
  }
}

state ServerKick
{
Begin:
  Sleep(0.5);
  Owner.Destroy();
  Destroy();
}

simulated state xxClientInitializing
{
  simulated function xxWaitForPlayer ()
  {
    local PlayerPawn zzP;
  
    if ( zzMyPlayer == None )
    {
      foreach AllActors(Class'PlayerPawn',zzP)
      {
        if ( zzP.Player != None )
        {
          zzMyPlayer = zzP;
          break;
        } 
      }
    }
    else if ( !zzbSetPlayerAlready )
    {
      zzbIsMac = InStr( Caps(""$string(zzMyPlayer.Player.Class)), "MACVIEWPORT" )>-1;
      zzbIsPC = InStr( Caps(""$string(zzMyPlayer.Player.Class)), "WINDOWSVIEWPORT" )>-1;
      zzbIsLinux = !(zzbIsMac || zzbIsPC);
      if ( zzMyPlayer.Player.Console==None )
      {
        xxDoClientMsg( 1, 19, "" );
        GotoState( '' );
        return;
      }
      xxAttachBadge();
      xxAttachConsole();
      if ( zzbCheckForRogues )
      {
        xxCheckEntryActors();
        xxCheckLevelActors();
      }
      GotoState( 'xxClientAcking' );
      zzbSetPlayerAlready = true;
    }
  }
Begin:
  while ( True )
  {
    xxWaitForPlayer();
    Sleep(0.01);
  }
}

simulated state xxClientAcking
{
Begin:
  xxServerACK(Level.TimeSeconds);
}

simulated state xxClientAuthorizing
{
  simulated function xxInitClient ()
  {
    local int zzi;
    local int zzj;
    local string zzl;
    local string zzs;
    local PlayerStart zzPS;
    local bool zzb;
  
    zzb = xxTestPlayer();
    zzbGlobalCheckFlags.zzbCheckPlayer = zzbGlobalCheckFlags.zzbCheckPlayer || zzb;
    if ( zzb )
    {
      xxDoClientMsg(1,8,"");
      GotoState('None');
      return;
    }
    zzb = xxTestConsole();
    zzbGlobalCheckFlags.zzbCheckConsole = zzbGlobalCheckFlags.zzbCheckConsole || zzb;
    if ( zzb )
    {
      xxDoClientMsg(1,9,"");
      GotoState('None');
      return;
    }
    xxVerifyCompile();
    if ( !xxCheckPackages() )
    {
      xxDoClientMsg(3,10,"" $ zzLookupName);
      GotoState('None');
      return;
    }
    zzMyBadge.xxInit();
    xxVerifyClass();
    if ( zzbNGStatsOnly && (zzMyPlayer.GetNGSecret() == "") )
    {
      xxDoClientMsg(0,-1,"");
      GotoState('None');
      return;
    }
  }
Begin:
  xxInitClient();
  xxServerGo(Level.TimeSeconds);
}

simulated state xxClientWorking
{
  simulated function xxPoliceClient ()
  {
    local bool zzOK;
    local PlayerPawn zzP;
    local UTConsole zzC;
    local string zza;
    local string zzx;
    local string zzy;
    local int zzpos;
    local int zzi;
    local UMenuModMenuList zzMl;
    local UMenuModMenu zzMm;
  
    if ( Class'LightSmokeTrail'.Default.bHidden || Class'UTSmokeTrail'.Default.bHidden || Class'UT_SpriteSmokePuff'.Default.bHidden )
    {
      if (  !zzbAllowNoSmoke )
      {
        xxDoClientMsg(1,15,"");
        GotoState('None');
        return;
      }
    }
    if ( zzMyConsole.Root == None )
    {
      return;
    }
    zzMm = UMenuRootWindow(zzMyConsole.Root).MenuBar.Mods;
    zzMl = UMenuModMenuList(zzMm.ModList.FindEntry(0));
    zzi = 0;
    while ( zzMl != None )
    {
      zzMl = UMenuModMenuList(zzMm.ModList.FindEntry(zzi));
      if ( zzMl != None )
      {
        if ( zzMl.MenuItemClassName == "lAimbot2.lAimbot2Menu" )
        {
          xxDoClientMsg(1,12,"");
        } else {
          if ( zzMl.MenuItemClassName == "uaimhax.haxItem" )
          {
            xxDoClientMsg(1,13,"");
          } else {
            if ( zzMl.MenuItemClassName == "nosmoke.nosmokeitem" )
            {
              if (  !zzbAllowNoSmoke )
              {
                xxDoClientMsg(1,14,"");
              }
            }
          }
        }
      }
      zzi++;
    }
  }
  
  simulated function xxCheckClient ()
  {
    local bool zzb;
    local string zzs;
    local Vector zznl;
    local Vector zzx;
    local Vector zzy;
    local Vector zzz;
    local PlayerReplicationInfo zzPRI;
    local int zzi;
    local int zzcx;
    local int zzcy;
  
    xxVerifyCompile();
    if ( zzbCheckForRogues )
    {
      xxCheckEntryActors();
    }
    zzbHasVR = false;
    zzb = xxTestPlayer();
    zzbGlobalCheckFlags.zzbCheckPlayer = zzbGlobalCheckFlags.zzbCheckPlayer || zzb;
    if ( zzb )
    {
      xxDoClientMsg(1,8,"");
      GotoState('None');
      return;
    }
    zzb = xxTestConsole();
    zzbGlobalCheckFlags.zzbCheckConsole = zzbGlobalCheckFlags.zzbCheckConsole || zzb;
    if ( zzb )
    {
      xxDoClientMsg(1,9,"");
      GotoState('None');
    }
    zzbHasVR = True;
    zzMyVR = zzMyPlayer.ViewRotation;
    zzbFire = zzMyPlayer.bFire;
    zzbAltFire = zzMyPlayer.bAltFire;
    xxProcessMessages();
    if ( Level.NetMode != NM_ListenServer )
    {
      if ( (zzMyPlayer != None) && (zzMyPlayer.GameReplicationInfo != None) && (zzMyPlayer.PlayerReplicationInfo != None) )
      {
        for ( zzi=0; zzi<32; zzi++ )
        {
          zzPRI = zzMyPlayer.GameReplicationInfo.PRIArray[zzi];
          if ( (zzPRI != None) && (zzPRI != zzMyPlayer.PlayerReplicationInfo) )
          {
            if (  !zzMyPlayer.GameReplicationInfo.bTeamGame || (zzPRI.Team != zzMyPlayer.PlayerReplicationInfo.Team) )
            {
              zzPRI.PlayerLocation = None;
              zzPRI.PlayerZone = None;
            }
          }
        }
      }
    }
    if ( zzWatchCV )
    {
      if ( int(zzMyPlayer.bSnapLevel)!=0 || zzMyPlayer.bCenterView )
      {
        if ( !zzbCVWarned )
        {
          zzMyPlayer.ClientMessage( "Using CenterView is prohibited!", 'CriticalEvent' );
          zzbCVWarned = true;
        }
        zzMyPlayer.bSnapLevel = 0;
        zzMyPlayer.bCenterView = false;
        zzMyPlayer.Suicide();
      }
    }
    if ( zzMyPlayer.Weapon!=None && !zzMyPlayer.Weapon.IsA('SniperRifle') && zzWatchFOV )
    {
      if ( zzMyPlayer.DesiredFOV<float(80) || zzMyPlayer.FovAngle<float(80) )
      {
        zzMyPlayer.SetDesiredFOV( 90.0 );
      }
    }
  }
  
  simulated function EndState ()
  {
    if (  !zzbClientMsgWaiting )
    {
      xxDoClientMsg(1,16,"");
      GotoState('None');
    }
  }
Begin:
  xxPoliceClient();
  while ( True )
  {
    xxCheckClient();
    Sleep(0.01);
  }
}

defaultproperties
{
    VersionStr="Enhanced CSHP"
    bAlwaysRelevant=False
    bAlwaysTick=True
    RemoteRole=ROLE_SimulatedProxy
    NetPriority=3.00
}
