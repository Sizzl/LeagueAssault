//================================================================================
// LeagueAS_AutoPauser.
//================================================================================

class LeagueAS_AutoPauser extends Actor
  NoNativeReplication;

var LeagueAssault LeagueAssaultGame;
var int StartCount;
var int CurrentCount;
var int TeamSize[2];
var bool bPausedBy0;
var bool bManualPaused;

event PostBeginPlay()
{
  if ( Level.Game.IsA('LeagueAssault') )
  {
    LeagueAssaultGame = LeagueAssault(Level.Game);
    SetTimer( 1.0*LeagueAssaultGame.Level.TimeDilation, true );
    StartCount = LeagueAssaultGame.PauseLeadInOutTime;
  }
  else
  {
    Destroy();
  }
}

function CheckPause()
{
  if ( LeagueAssaultGame.Teams[0].Size<TeamSize[0] )
  {
    if ( LeagueAssaultGame.PauseTimeRemaining[0]>StartCount )
    {
      bPausedBy0 = true;
      bManualPaused = false;
      GotoState( 'Pausing' );
    }
  }
  else
  {
    TeamSize[0] = LeagueAssaultGame.Teams[0].Size;
  }
  if ( LeagueAssaultGame.Teams[1].Size<TeamSize[1] )
  {
    if ( LeagueAssaultGame.PauseTimeRemaining[1]>StartCount )
    {
      bPausedBy0 = false;
      bManualPaused = false;
      GotoState( 'Pausing' );
    }
  }
  else
  {
    TeamSize[1] = LeagueAssaultGame.Teams[1].Size;
  }
}

function ClearProgress()
{
  local Pawn P;

  for ( P=LeagueAssaultGame.Level.PawnList; P!=None; P=P.nextPawn )
  {
    if ( P.IsA('PlayerPawn') )
    {
      PlayerPawn(P).SetProgressTime( 0.0 );
      PlayerPawn(P).ClearProgressMessages();
    }
  }
}

function ShowUnPausingMessage()
{
  local Pawn P;

  for ( P=LeagueAssaultGame.Level.PawnList; P!=None; P=P.nextPawn )
  {
    if ( P.IsA('TournamentPlayer') )
    {
      TournamentPlayer(P).SetProgressTime( 4.0 );
      TournamentPlayer(P).SetProgressMessage( "Resuming Game...", 3 );
    }
  }
}

function ShowPausingMessage()
{
  local Pawn P;

  for ( P=LeagueAssaultGame.Level.PawnList; P!=None; P=P.nextPawn )
  {
    if ( P.IsA('TournamentPlayer') )
    {
      TournamentPlayer(P).SetProgressTime( 4.0 );
      if ( bManualPaused )
      {
        if ( bPausedBy0 && int(P.PlayerReplicationInfo.Team)==0 || !bPausedBy0 && int(P.PlayerReplicationInfo.Team)==1 )
        {
          TournamentPlayer(P).SetProgressMessage( "Pausing (Type: 'CancelPause' to abort)...", 3 );
        }
        else
        {
          TournamentPlayer(P).SetProgressMessage( "Pause Requested...", 3 );
        }
      }
      else if ( bPausedBy0 && int(P.PlayerReplicationInfo.Team)==0 || !bPausedBy0 && int(P.PlayerReplicationInfo.Team)==1 )
      {
        TournamentPlayer(P).SetProgressMessage( "Auto Pausing (Type: 'CancelPause' to abort)...", 3 );
      }
      else
      {
        TournamentPlayer(P).SetProgressMessage( "Auto Pausing...", 3 );
      }
    }
  }
}

function ShowPausedMessage()
{
  local Pawn P;
  local int minsleft, secsleft;
  local string TimeString;

  for ( P=LeagueAssaultGame.Level.PawnList; P!=None; P=P.nextPawn )
  {
    if ( P.IsA('TournamentPlayer') )
    {
      TournamentPlayer(P).SetProgressTime( 10000.0 );
      if ( bManualPaused )
      {
        if ( bPausedBy0 && int(P.PlayerReplicationInfo.Team)==0 || !bPausedBy0 && int(P.PlayerReplicationInfo.Team)==1 )
        {
          TournamentPlayer(P).SetProgressMessage( "Game Paused (Type: 'CancelPause' to resume game).", 1 );
        }
        else
        {
          TournamentPlayer(P).SetProgressMessage( "Game Paused.", 1 );
        }
      }
      else if ( bPausedBy0 && int(P.PlayerReplicationInfo.Team)==0 || !bPausedBy0 && int(P.PlayerReplicationInfo.Team)==1 )
      {
        TournamentPlayer(P).SetProgressMessage( "Game Auto Paused (Type: 'CancelPause' to resume game).", 1 );
      }
      else
      {
        TournamentPlayer(P).SetProgressMessage( "Game Auto Paused.", 1 );
      }
      TournamentPlayer(P).SetProgressColor( Class'ChallengeTeamHUD'.default.TeamColor[0], 2 );
      minsleft = LeagueAssaultGame.PauseTimeRemaining[0]/60;
      secsleft = LeagueAssaultGame.PauseTimeRemaining[0]-LeagueAssaultGame.PauseTimeRemaining[0]/60*60;
      if ( secsleft<10 )
      {
        TimeString = string(minsleft) $ ":0" $ string(secsleft);
      }
      else
      {
        TimeString = string(minsleft) $ ":" $ string(secsleft);
      }
      TournamentPlayer(P).SetProgressMessage( LeagueAssaultGame.Teams[0].TeamName@"pause time remaining:"@TimeString$".", 2 );
      TournamentPlayer(P).SetProgressColor( Class'ChallengeTeamHUD'.default.TeamColor[1], 3 );
      minsleft = LeagueAssaultGame.PauseTimeRemaining[1]/60;
      secsleft = LeagueAssaultGame.PauseTimeRemaining[1]-LeagueAssaultGame.PauseTimeRemaining[1]/60*60;
      if ( secsleft<10 )
      {
        TimeString = string(minsleft) $ ":0" $ string(secsleft);
      }
      else
      {
        TimeString = string(minsleft) $ ":" $ string(secsleft);
      }
      TournamentPlayer(P).SetProgressMessage( LeagueAssaultGame.Teams[1].TeamName@"pause time remaining:"@TimeString$".", 3 );
    }
  }
}

function Pause()
{
  LeagueAssaultGame.Level.Pauser = "League Assault AutoPauser";
}

function UnPause()
{
  LeagueAssaultGame.Level.Pauser = "";
}

function RequestPause( PlayerPawn Sender )
{
}

function RequestCancelPause( PlayerPawn Sender )
{
  if ( bPausedBy0 && int(Sender.PlayerReplicationInfo.Team)==0 )
  {
    bManualPaused = false;
    TeamSize[0] = LeagueAssaultGame.Teams[0].Size-1;
  }
  else if ( !bPausedBy0 && int(Sender.PlayerReplicationInfo.Team)==1 )
  {
    bManualPaused = false;
    TeamSize[1] = LeagueAssaultGame.Teams[1].Size-1;
  }
}

auto state Waiting
{
  event Timer()
  {
    if ( LeagueAssaultGame.bMapStarted )
    {
      GotoState( 'Playing' );
    }
  }
}

state Playing
{
  function RequestPause( PlayerPawn Sender )
  {
    if ( int(Sender.PlayerReplicationInfo.Team)==0 )
    {
      if ( LeagueAssaultGame.PauseTimeRemaining[0]>StartCount )
      {
        bPausedBy0 = true;
        bManualPaused = true;
        GotoState( 'Pausing' );
      }
    }
    else if ( int(Sender.PlayerReplicationInfo.Team)==1 )
    {
      if ( LeagueAssaultGame.PauseTimeRemaining[1]>StartCount )
      {
        bPausedBy0 = false;
        bManualPaused = true;
        GotoState( 'Pausing' );
      }
    }
  }

  event Tick( float Delta )
  {
    if ( LeagueAssaultGame.Level.Pauser!="" )
    {
      GotoState( 'Paused' );
      return;
    }
    if ( LeagueAssaultGame.bMapEnded )
    {
      GotoState( 'Ended' );
      return;
    }
    CheckPause();
  }
}

state Pausing
{
  function CheckPause()
  {
    local bool DontPause;

    DontPause = false;
    if ( bPausedBy0 && LeagueAssaultGame.Teams[0].Size>TeamSize[0] )
    {
      DontPause = true;
    }
    else if ( !bPausedBy0 && LeagueAssaultGame.Teams[1].Size>TeamSize[1] )
    {
      DontPause = true;
    }
    if ( DontPause )
    {
      ClearProgress();
      GotoState( 'Playing' );
    }
  }

  event Tick( float Delta )
  {
    if ( LeagueAssaultGame.Level.Pauser!="" )
    {
      ClearProgress();
      GotoState( 'Paused' );
      return;
    }
    if ( LeagueAssaultGame.bMapEnded )
    {
      ClearProgress();
      GotoState( 'Ended' );
      return;
    }
    if ( !bManualPaused )
    {
      CheckPause();
    }
  }

  event Timer()
  {
    local Pawn P;

    if ( CurrentCount<=0 )
    {
      for ( P=Level.PawnList; P!=None; P=P.nextPawn )
      {
        if ( P.IsA('MessagingSpectator') )
        {
          P.ClientMessage( "Game Auto Paused.", 'CriticalEvent' );
        }
      }
      GotoState( 'Paused' );
      return;
    }
    for ( P=LeagueAssaultGame.Level.PawnList; P!=None; P=P.nextPawn )
    {
      if ( P.IsA('TournamentPlayer') )
      {
        TournamentPlayer(P).TimeMessage( CurrentCount );
      }
    }
    CurrentCount--;
  }

  event BeginState()
  {
    TeamSize[0] = LeagueAssaultGame.Teams[0].Size;
    TeamSize[1] = LeagueAssaultGame.Teams[1].Size;
    ClearProgress();
    ShowPausingMessage();
    SetTimer( 1.0*LeagueAssaultGame.Level.TimeDilation, true );
    CurrentCount = StartCount;
  }
}

state Paused
{
  function CheckPause()
  {
    local bool UnPause;
    local Pawn P;

    UnPause = false;
    if ( !bManualPaused && (bPausedBy0 && LeagueAssaultGame.Teams[0].Size>TeamSize[0]) )
    {
      UnPause = true;
    }
    else if ( LeagueAssaultGame.PauseTimeRemaining[0]<=StartCount )
    {
      UnPause = true;
    }
    if ( !bManualPaused && (!bPausedBy0 && LeagueAssaultGame.Teams[1].Size>TeamSize[1]) )
    {
      UnPause = true;
    }
    else if ( LeagueAssaultGame.PauseTimeRemaining[1]<=StartCount )
    {
      UnPause = true;
    }
    if ( UnPause )
    {
      GotoState( 'Unpausing' );
    }
  }

  event Tick( float Delta )
  {
    if ( LeagueAssaultGame.Level.Pauser=="" )
    {
      ClearProgress();
      GotoState( 'Playing' );
      return;
    }
    if ( LeagueAssaultGame.bMapEnded )
    {
      ClearProgress();
      GotoState( 'Ended' );
      return;
    }
  }

  function Timer()
  {
    ShowPausedMessage();
    CheckPause();
    if ( bPausedBy0 )
    {
      LeagueAssaultGame.PauseTimeRemaining[0]--;
    }
    else
    {
      LeagueAssaultGame.PauseTimeRemaining[1]--;
    }
  }

  event BeginState()
  {
    TeamSize[0] = LeagueAssaultGame.Teams[0].Size;
    TeamSize[1] = LeagueAssaultGame.Teams[1].Size;
    ClearProgress();
    ShowPausedMessage();
    Pause();
    SetTimer( 1.0*LeagueAssaultGame.Level.TimeDilation, true );
  }
}

//-----------------------------------------------------------------------------
// state Unpausing.
//-----------------------------------------------------------------------------

state Unpausing
{
  function RequestPause( PlayerPawn Sender )
  {
    if ( int(Sender.PlayerReplicationInfo.Team)==0 )
    {
      if ( LeagueAssaultGame.PauseTimeRemaining[0]>StartCount )
      {
        bPausedBy0 = true;
        bManualPaused = true;
        GotoState( 'Paused' );
      }
    }
    else if ( int(Sender.PlayerReplicationInfo.Team)==1 )
    {
      if ( LeagueAssaultGame.PauseTimeRemaining[1]>StartCount )
      {
        bPausedBy0 = false;
        bManualPaused = true;
        GotoState( 'Paused' );
      }
    }
  }

  function CheckPause()
  {
    local bool DontUnPause;

    DontUnPause = false;
    if ( LeagueAssaultGame.Teams[0].Size<TeamSize[0] )
    {
      bPausedBy0 = true;
      bManualPaused = false;
      DontUnPause = true;
    }
    else if ( LeagueAssaultGame.Teams[1].Size<TeamSize[1] )
    {
      bPausedBy0 = false;
      bManualPaused = false;
      DontUnPause = true;
    }
    if ( DontUnPause )
    {
      GotoState( 'Paused' );
    }
  }

  event Tick( float Delta )
  {
    if ( LeagueAssaultGame.Level.Pauser=="" )
    {
      ClearProgress();
      GotoState( 'Playing' );
      return;
    }
    if ( LeagueAssaultGame.bMapEnded )
    {
      ClearProgress();
      GotoState( 'Ended' );
      return;
    }
    if ( !bManualPaused )
    {
      CheckPause();
    }
  }

  event Timer()
  {
    local Pawn P;

    if ( CurrentCount<=0 )
    {
      for ( P=Level.PawnList; P!=None; P=P.nextPawn )
      {
        if ( P.IsA('MessagingSpectator') )
        {
          P.ClientMessage( "Game Resumed.", 'CriticalEvent' );
        }
      }
      GotoState( 'Playing' );
      return;
    }
    for ( P=LeagueAssaultGame.Level.PawnList; P!=None; P=P.nextPawn )
    {
      if ( P.IsA('TournamentPlayer') )
      {
        TournamentPlayer(P).TimeMessage( CurrentCount );
      }
    }
    CurrentCount--;
  }

  event BeginState()
  {
    if ( bPausedBy0 )
    {
      LeagueAssaultGame.PauseTimeRemaining[0] = LeagueAssaultGame.PauseTimeRemaining[0]-(StartCount-2);
    }
    else
    {
      LeagueAssaultGame.PauseTimeRemaining[1] = LeagueAssaultGame.PauseTimeRemaining[1]-(StartCount-2);
    }
    ClearProgress();
    TeamSize[0] = LeagueAssaultGame.Teams[0].Size;
    TeamSize[1] = LeagueAssaultGame.Teams[1].Size;
    ShowUnPausingMessage();
    SetTimer( 1.0*LeagueAssaultGame.Level.TimeDilation, true );
    CurrentCount = StartCount;
  }

  event EndState()
  {
    TeamSize[0] = LeagueAssaultGame.Teams[0].Size;
    TeamSize[1] = LeagueAssaultGame.Teams[1].Size;
    ClearProgress();
    UnPause();
  }
}

state Ended
{
}

defaultproperties
{
    bHidden=True
    bAlwaysTick=True
}
