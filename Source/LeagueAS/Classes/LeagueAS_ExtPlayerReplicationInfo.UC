//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_ExtPlayerReplicationInfo expands ReplicationInfo;

var string PlayerName;
var string ClanName;
var bool bClanTagBefore;
var bool bMuteSay;
var bool bMuteAll;
var bool bModerator;

replication
{
	reliable if ( Role == ROLE_Authority )
		PlayerName, ClanName, bClanTagBefore, bMuteSay, bMuteAll, bModerator;
}

defaultproperties
{
      PlayerName=""
      ClanName=""
      bClanTagBefore=False
      bMuteSay=False
      bMuteAll=False
      bModerator=False
      RemoteRole=ROLE_SimulatedProxy
      NetPriority=10.000000
}
