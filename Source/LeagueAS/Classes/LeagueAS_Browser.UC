//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_Browser extends UBrowserGSpyFact;

var() config string GameType;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	Super(UBrowserServerListFactory).Query(bBySuperset, bInitial);

	Link = GetPlayerOwner().GetEntryLevel().Spawn(class'LeagueAS_GSpyLink');
	LeagueAS_GSpyLink(Link).GameType = GameType;
	Link.MasterServerAddress = MasterServerAddress;
	Link.MasterServerTCPPort = MasterServerTCPPort;
	Link.Region = Region;
	Link.MasterServerTimeout = MasterServerTimeout;
	Link.GameName = GameName;
	Link.OwnerFactory = Self;
	Link.Start();
}

defaultproperties
{
      GameType="LeagueAssault"
      GameName="ut"
}
