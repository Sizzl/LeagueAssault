//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_GameReplicationInfo extends TournamentGameReplicationInfo;

var int StartTimeRemaining;
var string FortName[20];
var string FortCompleted[20];
var string MatchScore;
var bool bMatchModeEnabled;

var LeagueAS_ExtPlayerReplicationInfo ePRIArray[32];

//************************************************************************************************
replication {

    reliable if ( Role==ROLE_Authority )
		StartTimeRemaining, FortName, FortCompleted, MatchScore, bMatchModeEnabled, ePRIArray;

}
//************************************************************************************************
simulated function Timer()
{
	local LeagueAS_ExtPlayerReplicationInfo ePRI;
	local int i;

	Super.Timer();
		
	for (i=0; i<32; i++)
		ePRIArray[i] = None;
	
	i=0;
	foreach AllActors(class'LeagueAS_ExtPlayerReplicationInfo', ePRI)
		if ( i < 32 )
			ePRIArray[i++] = ePRI;

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
      ePRIArray(0)=None
      ePRIArray(1)=None
      ePRIArray(2)=None
      ePRIArray(3)=None
      ePRIArray(4)=None
      ePRIArray(5)=None
      ePRIArray(6)=None
      ePRIArray(7)=None
      ePRIArray(8)=None
      ePRIArray(9)=None
      ePRIArray(10)=None
      ePRIArray(11)=None
      ePRIArray(12)=None
      ePRIArray(13)=None
      ePRIArray(14)=None
      ePRIArray(15)=None
      ePRIArray(16)=None
      ePRIArray(17)=None
      ePRIArray(18)=None
      ePRIArray(19)=None
      ePRIArray(20)=None
      ePRIArray(21)=None
      ePRIArray(22)=None
      ePRIArray(23)=None
      ePRIArray(24)=None
      ePRIArray(25)=None
      ePRIArray(26)=None
      ePRIArray(27)=None
      ePRIArray(28)=None
      ePRIArray(29)=None
      ePRIArray(30)=None
      ePRIArray(31)=None
}
