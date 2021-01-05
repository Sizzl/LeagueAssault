//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_GameReplicationInfo extends TournamentGameReplicationInfo;

var int StartTimeRemaining;
var string FortName[20];
var string FortCompleted[20];
var string MatchScore;
var bool bMatchModeEnabled;

//************************************************************************************************
replication {

    reliable if ( Role==ROLE_Authority )
		StartTimeRemaining, FortName, FortCompleted, MatchScore, bMatchModeEnabled;

}
//************************************************************************************************

defaultproperties
{
      StartTimeRemaining=0
      FortName(0)=""
      FortName(1)=""
      FortName(2)=""
      FortName(3)=""
      FortName(4)=""
      FortName(5)=""
      FortName(6)=""
      FortName(7)=""
      FortName(8)=""
      FortName(9)=""
      FortName(10)=""
      FortName(11)=""
      FortName(12)=""
      FortName(13)=""
      FortName(14)=""
      FortName(15)=""
      FortName(16)=""
      FortName(17)=""
      FortName(18)=""
      FortName(19)=""
      FortCompleted(0)=""
      FortCompleted(1)=""
      FortCompleted(2)=""
      FortCompleted(3)=""
      FortCompleted(4)=""
      FortCompleted(5)=""
      FortCompleted(6)=""
      FortCompleted(7)=""
      FortCompleted(8)=""
      FortCompleted(9)=""
      FortCompleted(10)=""
      FortCompleted(11)=""
      FortCompleted(12)=""
      FortCompleted(13)=""
      FortCompleted(14)=""
      FortCompleted(15)=""
      FortCompleted(16)=""
      FortCompleted(17)=""
      FortCompleted(18)=""
      FortCompleted(19)=""
      MatchScore=""
      bMatchModeEnabled=False
}
