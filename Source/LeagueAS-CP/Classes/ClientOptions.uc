//=============================================================================
// ClientOptions.
//=============================================================================
class ClientOptions extends ReplicationInfo
	config(User);

//-----------------------------------------------------------------------------
// Properties.
//-----------------------------------------------------------------------------

var() config string PlayerName;
var() config string ClanName;
var() config string PlayerPassword;
var() config bool bClanTagBefore;
var() config bool bMuteSay;
var() config bool bMuteAll;
var() config bool bExtHudEnabled;
var() config bool bExtHudShowGameInfo;
var() config bool bExtHudShowConnInfo;
var() config bool bExtHudShowTime;
var() config bool bExtHudShowTeamInfo;
var() config bool bExtHudShowObjInfo;
var() config bool bExtHudLargeFont;
var() config bool bExtHudShowElapsedTime;
var string IRCIdent;

//-----------------------------------------------------------------------------
// Network replication.
//-----------------------------------------------------------------------------

replication
{
	reliable if ( int(Role)==int(ENetRole.ROLE_Authority) )
		CopyMuteOption, CopyOptionsToServer;

	reliable if ( int(Role)<int(ENetRole.ROLE_Authority) )
		SendOptionsToServer;
}

//-----------------------------------------------------------------------------
// Global Functions.
//-----------------------------------------------------------------------------

simulated function CopyOptionsToServer()
{
	SendOptionsToServer( PlayerName, ClanName, PlayerPassword, bClanTagBefore, bMuteSay, bMuteAll, Class'UBrowserIRCSystemPage'.default.UserIdent );
	Class'enforcer'.default.PickupMessage = "";
}

function SendOptionsToServer( string NewPlayerName, string NewClanName, string NewPlayerPassword, bool NewClanTagBefore, bool NewMuteSay, bool NewMuteAll, string NewIRCIdent )
{
	PlayerName = NewPlayerName;
	ClanName = NewClanName;
	PlayerPassword = NewPlayerPassword;
	bClanTagBefore = NewClanTagBefore;
	bMuteSay = NewMuteSay;
	bMuteAll = NewMuteAll;
	IRCIdent = NewIRCIdent;
	LeagueAS_LAAbstract(Level.Game).PlayerDetailsRecieved( PlayerPawn(Owner), Self );
}

simulated function CopyMuteOption( bool NewMuteSay, bool NewMuteAll )
{
	bMuteSay = NewMuteSay;
	bMuteAll = NewMuteAll;
	SaveConfig();
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    bClanTagBefore=True
    bExtHudShowGameInfo=True
    bExtHudShowConnInfo=True
    bExtHudShowTime=True
    bExtHudShowTeamInfo=True
    bExtHudShowObjInfo=True
    IRCIdent=""
    RemoteRole=ROLE_SimulatedProxy
    NetPriority=5.000000
    NetUpdateFrequency=1.000000
}
