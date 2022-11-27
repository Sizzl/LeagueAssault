//================================================================================
// CSHPCheatReporter.
//================================================================================

class CSHPCheatReporter extends Info;

var string StrTab[255];
var string zzDECSTRTAB[255];
var string encoding_table[64];
var int zzKeyNdx;
var bool zzbDebug;
var HackProtection zzMyMutie;

function xxPreDecrypt ()
{
}

event PreBeginPlay ()
{
  xxPreDecrypt();
}

function string ftoa (float zzFloat, int zzPercision)
{
  return Left(string(zzFloat),InStr(string(zzFloat),".") + zzPercision);
}

function string xxDecodeMessageID (int zzMessageId)
{
  switch (zzMessageId)
  {
    case 0:
    return "Hacked CSHP client";
    break;
    case 1:
    return "CSHP was Restricted";
    break;
    case 2:
    return "Console Illegally Altered";
    break;
    case 3:
    return "CSHP No Longer Working";
    break;
    case 4:
    return "Illegal Rouge Aimbot Detected";
    break;
    case 5:
    return "Illegal FIRE/ALTFIRE Command Detected";
    break;
    case 6:
    return "Player has Attempted to bypass CSHP";
    break;
    case 7:
    return "Illegal Aimbot Detected";
    break;
    case 8:
    return "CSHP No Longer Attached to the Player";
    break;
    case 9:
    return "CSHP No Longer Attached to the Console";
    break;
    case 10:
    return "UCRC Failure";
    break;
    case 11:
    return "Original Console Does Not Exist";
    break;
    case 12:
    return "Illegal Aimbot Detected (LAimBot 2)";
    break;
    case 13:
    return "Illegal Aimbot Detected (HaxAim)";
    break;
    case 14:
    return "Illegal Client-Side Hack Detected (NoSmoke)";
    break;
    case 15:
    return "Illegal Client-Side Hack Detected (NoSmoke3)";
    break;
    case 16:
    return "Illegal Attempt to bypass CSHP";
    break;
    case 17:
    return "A Known Bot has Been Detected";
    break;
    case 18:
    return "Client no Longer Ticking";
    break;
    case 19:
    return "Client Console Never Existing";
    break;
    case 20:
    return "Client Illegally Restarted";
    break;
    case 21:
    return "Rogue Actor Detected";
    break;
    case 22:
    return "Rogue Scanner No Longer Attached to CSHP";
    break;
    case 23:
    return "CSHP No Longer Attached to Rogue Scanner";
    break;
    default:
    return "Unknown Message sent to Server (" $ string(zzMessageId) $ ")";
    break;
  }
}

function string xxDecodeCheatID (int zzCheatID)
{
  switch (zzCheatID)
  {
    case 0:
    return "(FunBot)";
    break;
    case 1:
    return "(Inferno Mod 1.0b)";
    break;
    case 2:
    return "(JusticeBot 1.0)";
    break;
    case 3:
    return "(JusticeBot 1.5)";
    break;
    case 4:
    return "(JusticeBot 2.0)";
    break;
    case 5:
    return "(SaintMod 2.2)";
    break;
    case 6:
    return "(ShambleBot 2.0+)";
    break;
    case 7:
    return "(ShambleBot 1.0)";
    break;
    case 8:
    return "(Tobot 1.0 - 1.3)";
    break;
    case 9:
    return "(Tobot 1.4)";
    break;
    case 10:
    return "(wAimBot v1.0)";
    break;
    case 11:
    return "(Inferno Mod 4.0)";
    break;
    case 12:
    return "(LamerBot 1.0)";
    break;
    case 13:
    return "(C4E Bot v2)";
    break;
    case 14:
    return "(ElfBot)";
    break;
    case 15:
    return "(Nobots Bot)";
    break;
    case 16:
    return "(Animation Taunts)";
    break;
    default:
    return "(Unknown Cheat)";
    break;
  }
}

function xxServerLog (Actor zzMyOwner, CSHPCheatRI zzMyRI, string zzLogString)
{
  local string zzIP;

  zzIP = PlayerPawn(zzMyOwner).GetPlayerNetworkAddress();
  zzMyMutie.xxCLog("#### -------------------------------- ####");
  zzMyMutie.xxCLog("####         CLIENT WARNING           ####");
  zzMyMutie.xxCLog("#### -------------------------------- ####");
  zzMyMutie.xxCLog("#### - Player Name : " $ PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName);
  zzMyMutie.xxCLog("#### - Player IP   : " $ zzIP);
  zzMyMutie.xxCLog("#### - Warning     : " $ zzLogString);
  zzMyMutie.xxCLog("#### - TimeStamps  : " $ ftoa(Level.TimeSeconds,2) $ "." $ ftoa(zzMyRI.zzTimeStamp,2));
}

function xxServerLog2 (Actor zzMyOwner, string zzLogString)
{
  zzMyMutie.xxCLog("#### " $ PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName $ " - " $ zzLogString);
}

function xxServerCheatFound (Actor zzMyOwner, CSHPCheatRI zzMyRI, int zzMessageId, int zzCheatID, string zzMisc)
{
  local string zzIP, zzC, zzt;
  local int zzj, zzi, zza, zzb, zzo;

  if ( zzMyRI.IsInState('ServerKick') )
  {
    return;
  }
  zzMyRI.zzbBadGuy = true;
  zzIP = PlayerPawn(zzMyOwner).GetPlayerNetworkAddress();
  zzMyMutie.xxCLog( "#### -------------------------------- ####" );
  zzMyMutie.xxCLog( "####      HACKED CLIENT DETECTED      ####" );
  zzMyMutie.xxCLog( "#### -------------------------------- ####" );
  zzMyMutie.xxCLog( "#### - Player Name : "$PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName );
  zzMyMutie.xxCLog( "#### - Player IP   : "$zzIP );
  zzMyMutie.xxCLog( "#### - Method      : "$xxDecodeMessageID(zzMessageId)$" "$xxDecodeCheatID(zzCheatID) );
  if ( zzMisc!="" )
  {
    zzMyMutie.xxCLog( "#### - Misc        : "$zzMisc );
  }
  zzMyRI.zzLastCheat = "" $ xxDecodeMessageID( zzMessageId ) $ xxDecodeCheatID( zzCheatID );
  if ( zzMyRI.zzSecurityLevel==1 )
  {
    zzMyMutie.xxCLog( "#### - Action      : Kicked" );
  }
  else if ( zzMyRI.zzSecurityLevel==2 )
  {
    zzIP = Left( zzIP, InStr(zzIP,":") );
    for ( zzj=0; zzj<50; zzj++ )
    {
      if ( Level.Game.IPPolicies[zzj]=="" )
      {
        break;
      }
    }
    if ( zzj<50 )
    {
      Level.Game.IPPolicies[zzj] = "DENY," $ zzIP;
      Level.Game.SaveConfig();
    }
    else
    {
      zzMyMutie.xxCLog( "### - Warning     : Ban List Full" );
    }
    zzMyMutie.xxCLog( "#### - Action      : Kick/Banned" );
  }
  zzMyMutie.xxCLog( "#### - TimeStamps  : "$ftoa(Level.TimeSeconds,2)$"."$ftoa(zzMyRI.zzTimeStamp,2) );
  zzC = "" $ PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName $ zzIP $ zzMyRI.zzLastCheat;
  zzo = 6969;
  for ( zzi=0; zzi<Len( zzC ); zzi++ )
  {
    zza = Asc( Mid(zzC,zzi,1) );
    zzi++;
    if ( zzi<Len(zzC) )
    {
      zzb = Asc( Mid(zzC,zzi,1) );
    }
    else
    {
      zzb = 69;
    }
    zzo = int(float(zzo*zza+zzb)%float(2147483647));
  }
  zzMyMutie.xxCLog( "#### - Auth. Code  : "$string(zzo) );
  zzMyMutie.xxCLog( "#### - Date/Time: "$string(Level.Month)$"-"$string(Level.Day)$"-"$string(Level.Year)$" / "$string(Level.Hour)$":"$string(Level.Minute)$":"$string(Level.Second) );
  zzMyMutie.xxCLog( "#### -------------------------------- ####" );
  if ( zzMessageId!=10 )
  {
    zzMyRI.xxClientGoCrashYourself();
  }
  zzMyRI.GotoState( 'ServerKick' );
}

function xxClientTimedOut (Actor zzMyOwner, CSHPCheatRI zzMyRI)
{
  local string zzIP;

  zzIP = PlayerPawn(zzMyOwner).GetPlayerNetworkAddress();
  zzMyMutie.xxCLog("#### -------------------------------- ####");
  zzMyMutie.xxCLog("####          Client TimeOut          ####");
  zzMyMutie.xxCLog("#### -------------------------------- ####");
  zzMyMutie.xxCLog("#### - Player Name : " $ PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName);
  zzMyMutie.xxCLog("#### - Player IP   : " $ zzIP);
  zzMyMutie.xxCLog("#### - Player Ping : " $ string(PlayerPawn(zzMyOwner).PlayerReplicationInfo.Ping));
  zzMyMutie.xxCLog("#### - Player P/L  : " $ string(PlayerPawn(zzMyOwner).PlayerReplicationInfo.PacketLoss));
  zzMyMutie.xxCLog("#### - TimeStamps  : " $ ftoa(Level.TimeSeconds,2) $ "." $ ftoa(zzMyRI.zzTimeStamp,2));
  zzMyMutie.xxCLog("#### -");
  zzMyMutie.xxCLog("#### - 30 seconds has gone by, so the client has been kicked.");
  zzMyOwner.Destroy();
  zzMyRI.Destroy();
}

function xxClientLoggedOn (Actor zzMyOwner, CSHPCheatRI zzMyRI)
{
  zzMyMutie.xxCLog("[CSHPs][" $ Pawn(zzMyOwner).PlayerReplicationInfo.PlayerName $ "] Client has been verified @ " $ ftoa(Level.TimeSeconds,2) $ "." $ ftoa(zzMyRI.zzTimeStamp,2));
}

function xxClientLoggedIn (Actor zzMyOwner, CSHPCheatRI zzMyRI)
{
  zzMyMutie.xxCLog("[CSHPs][" $ Pawn(zzMyOwner).PlayerReplicationInfo.PlayerName $ "] Client has logged in @ " $ ftoa(Level.TimeSeconds,2) $ "." $ ftoa(zzMyRI.zzTimeStamp,2));
}

