//=============================================================================
// AS_Browser.
//=============================================================================
class AS_Browser extends UBrowserGSpyFact;

//-----------------------------------------------------------------------------
// Properties.
//-----------------------------------------------------------------------------

var() config string GameType;

//-----------------------------------------------------------------------------
// Global Functions.
//-----------------------------------------------------------------------------

function Query( optional bool bBySuperset, optional bool bInitial )
{
	Super(UBrowserServerListFactory).Query( bBySuperset, bInitial );
	Link = GetPlayerOwner().GetEntryLevel().Spawn( Class'GameSpyLink' );
	GameSpyLink(Link).GameType = GameType;
	Link.MasterServerAddress = MasterServerAddress;
	Link.MasterServerTCPPort = MasterServerTCPPort;
	Link.Region = Region;
	Link.MasterServerTimeout = MasterServerTimeout;
	Link.GameName = GameName;
	Link.OwnerFactory = Self;
	Link.Start();
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    GameType=""
    GameName="ut"
}
