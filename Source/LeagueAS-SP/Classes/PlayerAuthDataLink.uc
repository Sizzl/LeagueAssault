//=============================================================================
// PlayerAuthDataLink.
//=============================================================================
class PlayerAuthDataLink extends LeagueAS_PADAbstract;

function Initialise()
{
}

function bool AuthorisePlayer( ClientOptions CO )
{
	if ( CO.PlayerName!="" && CO.ClanName!="" && CO.PlayerPassword!="" )
	{
		return true;
	}
	else
	{
		return false;
	}
}

function LogEvent( string EventText )
{
}
