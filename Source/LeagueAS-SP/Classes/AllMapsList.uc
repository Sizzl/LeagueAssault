//=============================================================================
// AllMapsList.
//=============================================================================
class AllMapsList extends Info;

var string Maps[128];

function LoadMaps()
{
	local int i;
	local string FirstMap, NextMap, TestMap, MapName;

	i = 0;
	FirstMap = Level.GetMapName( "AS", "", 0 );
	NextMap = FirstMap;
	while ( !(FirstMap~=TestMap) )
	{
		MapName = NextMap;
		if ( !(Left(NextMap,Len(NextMap)-4)~="AS-Tutorial") )
		{
			Maps[i++] = MapName;
		}
		NextMap = Level.GetMapName( "AS", NextMap, 1 );
		TestMap = NextMap;
		if ( i>511 )
		{
			break;
		}
	}
}
