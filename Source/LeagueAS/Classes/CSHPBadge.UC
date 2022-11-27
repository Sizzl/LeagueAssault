//================================================================================
// CSHPBadge.
//================================================================================

class CSHPBadge extends Mutator;
#exec TEXTURE IMPORT FILE="Textures\CSHPShield.pcx" NAME="CSHPShield" MIPS=OFF FLAGS=2

var string StrTab[255];
var string zzDECSTRTAB[255];
var string encoding_table[64];
var int zzKeyNdx;
var float FadeOut;
var float TotalTime;
var CSHPCheatRI zzMyCheatRI;
var Canvas zzMyCanvas;
var Canvas zzFakeCanvas;
var HUD zzMyHud;
var float zzFadeTimer;
var bool zzbHudOff;
var bool zzbInitialized;
var Mutator zzNextHud;
var string zzS1;
var string zzS2;
var string zzS3;
var string zzS4;
var string zzS5;
var string zzS6;
var string zzS7;
var string VersionStr;
var string LeagueASVersionStr;

function xxPreDecrypt ()
{
}

simulated function Tick (float Delta)
{
  if (  !zzbInitialized )
  {
    return;
  }
  if ( zzFadeTimer >= 0.0 )
  {
    zzFadeTimer -= Delta;
  }
  else
  {
    zzbHudOff = True;
  }
  Super.Tick(Delta);
}

simulated function PostRender (Canvas C)
{
  local float zzx, zzy, zzFadeValue;
  local string zzMsg, zzC1, zzC2, zzC3;
  local int zzi;
  local Pawn zzP;

  zzMyCanvas = C;
  zzMyHud = zzMyCheatRI.zzMyPlayer.myHUD;
  if ( !zzbInitialized )
  {
    zzMsg = "Connecting to Server...";
    zzFadeTimer = TotalTime;
  }
  else
  {
    zzMsg = "Client Verified and Connected";
  }
  if ( !zzbHudOff && zzFadeTimer>float(0) )
  {
    zzx = 10.0;
    zzy = C.ClipY-float(128);
    if ( zzFadeTimer<=FadeOut )
    {
      zzFadeValue = zzFadeTimer/FadeOut;
    }
    else
    {
      zzFadeValue = 1.0;
    }
    C.Style = 3;
    C.DrawColor = ChallengeHUD(zzMyHud).WhiteColor*zzFadeValue;
    C.SetPos( zzx, zzy );
    C.DrawIcon( Texture'CSHPShield', 1.0 );
    C.DrawColor = ChallengeHUD(zzMyHud).GoldColor*zzFadeValue;
    C.SetPos( zzx+float(70), zzy+float(3) );
    C.Font = ChallengeHUD(zzMyHud).MyFonts.GetSmallestFont( C.ClipX );
    C.DrawText( Class'LeagueAssault'.default.GameName@"(Version"@LeagueASVersionStr$")" );
    C.SetPos( zzx+float(70), zzy+float(20) );
    C.DrawText( "Incorporating"@VersionStr );
    C.SetPos( zzx+float(70), zzy+float(38) );
    C.Font = ChallengeHUD(zzMyHud).MyFonts.GetBigFont( C.ClipX );
    C.DrawText( zzMsg );
    C.Style = 1;
  }
  if ( !zzMyCheatRI.zzMyPlayer.IsA('Spectator') && zzMyCheatRI.zzMyPlayer.Player.Console!=zzMyCheatRI.zzMyConsole )
  {
    zzMyCheatRI.xxDoClientMsg( 1, 9, "" );
  }
  if ( zzNextHud!=None && zzNextHud!=Self )
  {
    zzNextHud.PostRender( C );
  }
}

function xxInit ()
{
  zzbInitialized = True;
}

auto state TimeBomb
{
Begin:
  zzFadeTimer = TotalTime;
}

defaultproperties
{
    FadeOut=10.00
    TotalTime=20.00
    VersionStr="Enhanced CSHP"
}
