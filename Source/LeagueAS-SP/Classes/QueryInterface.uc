//=============================================================================
// QueryInterface. 
//=============================================================================
class QueryInterface extends Actor;

function string GetItemName( string FullName )
{
	if ( FullName=="MATCHMODE" )
	{
		if ( LeagueAssault(Level.Game).bMatchMode )
		{
			return "TRUE";
		}
		else
		{
			return "FALSE";
		}
	}
	else if ( FullName=="VERSION" )
	{
		return LeagueAssault(Level.Game).VersionStr $ LeagueAssault(Level.Game).SubVersionStr;
	}
	else if ( FullName=="GAMESTATUS" )
	{
		if ( LeagueAssault(Level.Game).bMapEnded )
		{
			return "ENDED";
		}
		else if ( LeagueAssault(Level.Game).bMapStarted )
		{
			return "INPROGRESS";
		}
		else
		{
			return "WAITING";
		}
	}
	else if ( FullName=="TEAMNAMERED" )
	{
		return LeagueAssault(Level.Game).TeamNameRed;
	}
	else if ( FullName=="TEAMNAMEBLUE" )
	{
		return LeagueAssault(Level.Game).TeamNameBlue;
	}
	else
	{
		return Super.GetItemName( FullName );
	}
}
