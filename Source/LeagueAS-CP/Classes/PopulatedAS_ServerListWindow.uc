//=============================================================================
// PopulatedAS_ServerListWindow.
//=============================================================================
class PopulatedAS_ServerListWindow extends UTBrowserServerListWindow
	perobjectconfig;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    ServerListTitle="Assault - Populated"
    ListFactories(0)="UBrowser.UBrowserSubsetFact,SupersetTag=UBrowserAS,MinPlayers=1"
    PingingText="Pinging Assault Servers"
}
