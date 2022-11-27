//================================================================================
// LeagueAS_AutoPauser.
//================================================================================

class LeagueAS_AutoPauser extends Actor
  NoNativeReplication;

var LeagueAssault LeagueAssaultGame;
var int PauseTimeRemaining[2];
var int CurrentCount;

auto state Waiting
{
  event Timer ()
  {
    if ( LeagueAssaultGame.bMapStarted )
    {
      GotoState('Playing');
    }
  }
  
}

state Playing
{
  event Tick (float Delta)
  {
    if ( LeagueAssaultGame.Level.Pauser != "" )
    {
      GotoState('Paused');
      return;
    }
    if ( LeagueAssaultGame.bMapEnded )
    {
      GotoState('Ended');
      return;
    }
    CheckPause();
  }
  
}

state Pausing
{
  function DoubleCheckPause ()
  {
    local bool DontPause;
  
    DontPause = True;
    if ( LeagueAssaultGame.Teams[0].Size < LeagueAssaultGame.Teams[1].Size )
    {
      if ( PauseTimeRemaining[0] > 0 )
      {
        DontPause = False;
      }
    }
    if ( LeagueAssaultGame.Teams[1].Size < LeagueAssaultGame.Teams[0].Size )
    {
      if ( PauseTimeRemaining[1] > 0 )
      {
        DontPause = False;
      }
    }
    if ( DontPause )
    {
      ClearProgress();
      GotoState('Playing');
    }
  }
  
  event Tick (float Delta)
  {
    if ( LeagueAssaultGame.Level.Pauser != "" )
    {
      ClearProgress();
      GotoState('Paused');
      return;
    }
    if ( LeagueAssaultGame.bMapEnded )
    {
      ClearProgress();
      GotoState('Ended');
      return;
    }
    DoubleCheckPause();
  }
  
  event Timer ()
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
  
  event BeginState ()
  {
    ClearProgress();
    ShowPausingMessage();
    SetTimer(1.0 * LeagueAssaultGame.Level.TimeDilation,True);
    CurrentCount = 3;
  }
  
}

state Paused
{
  event Tick (float Delta)
  {
    if ( LeagueAssaultGame.Level.Pauser == "" )
    {
      ClearProgress();
      GotoState('Playing');
      return;
    }
    if ( LeagueAssaultGame.bMapEnded )
    {
      ClearProgress();
      GotoState('Ended');
      return;
    }
  }
  
  function Timer ()
  {
    local bool UnPause;
    local Pawn P;
  
    ShowPausedMessage();
    UnPause = True;
    if ( LeagueAssaultGame.Teams[0].Size < LeagueAssaultGame.Teams[1].Size )
    {
      if ( PauseTimeRemaining[0] > 0 )
      {
        UnPause = False;
        PauseTimeRemaining[0]--;
      }
    }
    if ( LeagueAssaultGame.Teams[1].Size < LeagueAssaultGame.Teams[0].Size )
    {
      if ( PauseTimeRemaining[1] > 0 )
      {
        UnPause = False;
        PauseTimeRemaining[1]--;
      }
    }
    if ( UnPause )
    {
      GotoState('Unpausing');
    }
  }
  
  event BeginState ()
  {
    ClearProgress();
    ShowPausedMessage();
    Pause();
    SetTimer(1.0 * LeagueAssaultGame.Level.TimeDilation,True);
  }
  
}

state Unpausing
{
  event Tick (float Delta)
  {
    if ( LeagueAssaultGame.Level.Pauser == "" )
    {
      ClearProgress();
      GotoState('Playing');
      return;
    }
    if ( LeagueAssaultGame.bMapEnded )
    {
      ClearProgress();
      GotoState('Ended');
      return;
    }
    CheckPause();
  }
  
  event Timer ()
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
  
  event BeginState ()
  {
    ClearProgress();
    ShowUnPausingMessage();
    SetTimer(1.0 * LeagueAssaultGame.Level.TimeDilation,True);
    CurrentCount = 3;
  }
  
  event EndState ()
  {
    ClearProgress();
    UnPause();
  }
  
}

state Ended
{
}

event PostBeginPlay ()
{
  if ( Level.Game.IsA('LeagueAssault') )
  {
    LeagueAssaultGame = LeagueAssault(Level.Game);
    SetTimer(1.0 * LeagueAssaultGame.Level.TimeDilation,True);
    if ( LeagueAssaultGame.bMatchMode && LeagueAssaultGame.bAutoPausing )
    {
      PauseTimeRemaining[0] = LeagueAssaultGame.MaxPauseTime;
      PauseTimeRemaining[1] = LeagueAssaultGame.MaxPauseTime;
    }
  } else {
    Destroy();
  }
}

function CheckPause ()
{
  if ( LeagueAssaultGame.Teams[0].Size < LeagueAssaultGame.Teams[1].Size )
  {
    if ( PauseTimeRemaining[0] > 0 )
    {
      GotoState('Pausing');
    }
  }
  if ( LeagueAssaultGame.Teams[1].Size < LeagueAssaultGame.Teams[0].Size )
  {
    if ( PauseTimeRemaining[1] > 0 )
    {
      GotoState('Pausing');
    }
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
      TournamentPlayer(P).SetProgressMessage( "Teams uneven, Auto Pausing...", 3 );
    }
  }
}

function ShowPausedMessage()
{
  local Pawn P;

  for ( P=LeagueAssaultGame.Level.PawnList; P!=None; P=P.nextPawn )
  {
    if ( P.IsA('TournamentPlayer') )
    {
      TournamentPlayer(P).SetProgressTime( 10000.0 );
      TournamentPlayer(P).SetProgressMessage( "Game Auto Paused.", 1 );
      TournamentPlayer(P).SetProgressColor( Class'ChallengeTeamHUD'.default.TeamColor[0], 2 );
      TournamentPlayer(P).SetProgressMessage( LeagueAssaultGame.Teams[0].TeamName@"pause time remaining:"@string(PauseTimeRemaining[0])@"seconds.", 2 );
      TournamentPlayer(P).SetProgressColor( Class'ChallengeTeamHUD'.default.TeamColor[1], 3 );
      TournamentPlayer(P).SetProgressMessage( LeagueAssaultGame.Teams[1].TeamName@"pause time remaining:"@string(PauseTimeRemaining[1])@"seconds.", 3 );
    }
  }
}

function Pause ()
{
  LeagueAssaultGame.Level.Pauser = "League Assault AutoPauser";
}

function UnPause ()
{
  LeagueAssaultGame.Level.Pauser = "";
}

defaultproperties
{
    bHidden=True
    bAlwaysTick=True
}
