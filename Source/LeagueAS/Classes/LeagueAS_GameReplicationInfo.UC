//================================================================================
// LeagueAS_GameReplicationInfo.
//================================================================================

class LeagueAS_GameReplicationInfo extends TournamentGameReplicationInfo;

var int StartTimeRemaining;
var int TimeElapsed;
var int TimeRemaining;
var string FortName[20];
var string FortCompleted[20];
var string MatchScore;
var bool bMatchModeEnabled;
var LeagueAS_ExtPlayerReplicationInfo ePRIArray[32];

replication
{
  reliable if ( Role == 4 )
    StartTimeRemaining,TimeElapsed,TimeRemaining,FortName,FortCompleted,MatchScore,bMatchModeEnabled,ePRIArray;
}

simulated function Timer()
{
  local LeagueAS_ExtPlayerReplicationInfo ePRI;
  local PlayerReplicationInfo PRI;
  local int i, FragAcc, Difference;

  if ( int(Level.NetMode)==int(ENetMode.NM_Client) )
  {
    Difference = TimeElapsed-ElapsedTime;
    if ( Difference<0 )
    {
      ElapsedTime += Difference/2-1;
    }
    else if ( Difference>0 )
    {
      ElapsedTime += Difference/2+1;
    }
    Difference = TimeRemaining-RemainingTime;
    if ( Difference<0 )
    {
      RemainingTime += Difference/2-1;
    }
    else if ( Difference>0 )
    {
      RemainingTime += Difference/2+1;
    }
  }
  for ( i=0; i<32; i++ )
  {
    PRIArray[i] = None;
  }
  i = 0;
  foreach AllActors( Class'PlayerReplicationInfo', PRI )
  {
    if ( i<32 )
    {
      PRIArray[i++] = PRI;
    }
  }
  UpdateTimer = 0.0;
  for ( i=0; i<32; i++ )
  {
    if ( PRIArray[i]!=None )
    {
      FragAcc += int(PRIArray[i].Score);
    }
  }
  SumFrags = FragAcc;
  if ( Level.Game!=None )
  {
    NumPlayers = Level.Game.NumPlayers;
  }
  for ( i=0; i<32; i++ )
  {
    ePRIArray[i] = None;
  }
  i = 0;
  foreach AllActors( Class'LeagueAS_ExtPlayerReplicationInfo', ePRI )
  {
    if ( i<32 )
    {
      ePRIArray[i++] = ePRI;
    }
  }
}

