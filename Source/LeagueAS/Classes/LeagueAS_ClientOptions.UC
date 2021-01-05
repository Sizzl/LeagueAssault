//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_ClientOptions expands ReplicationInfo config(user);

var() config string PlayerName;
var() config string ClanName;
var() config string PlayerPassword;
var() config bool bClanTagBefore;
var() config bool bMuteSay;
var() config bool bMuteAll;

replication
{
     // Functions that Server calls on the Client
     reliable if ( Role == ROLE_Authority)
          CopyOptionsToServer, CopyMuteOption;

     // Function the Client calls on the Server
     reliable if ( Role < ROLE_Authority )
          SendOptionsToServer;
}

//************************************************************************************************
simulated function CopyOptionsToServer()
{
    //This runs on the client
	SendOptionsToServer(PlayerName, ClanName, PlayerPassword, bClanTagBefore, bMuteSay, bMuteAll);
}
//************************************************************************************************
function SendOptionsToServer(string NewPlayerName, string NewClanName, string NewPlayerPassword, bool NewClanTagBefore, bool NewMuteSay, bool NewMuteAll)
{
    // This runs on the server
	PlayerName = NewPlayerName;
	ClanName = NewClanName;
	PlayerPassword = NewPlayerPassword;
	bClanTagBefore = NewClanTagBefore;
	bMuteSay = NewMuteSay;
	bMuteAll = NewMuteAll;

	LeagueAssault(Level.Game).PlayerDetailsRecieved(PlayerPawn(Owner), Self);
}
//************************************************************************************************
simulated function CopyMuteOption(bool NewMuteSay, bool NewMuteAll)
{
	// This runs on the server
	bMuteSay = NewMuteSay;
	bMuteAll = NewMuteAll;

	SaveConfig();
}
//************************************************************************************************

defaultproperties
{
      PlayerName=""
      ClanName=""
      PlayerPassword=""
      bClanTagBefore=False
      bMuteSay=False
      bMuteAll=False
      RemoteRole=ROLE_SimulatedProxy
      NetPriority=10.000000
}
