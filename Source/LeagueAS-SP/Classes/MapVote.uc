//=============================================================================
// MapVote. 
//=============================================================================
class MapVote extends Mutator;

var() config int MapVoteChangeLimit;
var() config int MapListType;
var private string VoteMapList[128];
var private int PlayerVote[63];
var int WelcomeMessageShown;

event PreBeginPlay()
{
	local int X;
	local Info MapListClass;

	for ( X=0; X<63; X++ )
	{
		PlayerVote[X] = -1;
	}
	if ( MapListType==1 )
	{
		MapListClass = Spawn( Class'AllMapsList' );
		AllMapsList(MapListClass).LoadMaps();
		for ( X=0; X<128; X++ )
		{
			VoteMapList[X] = AllMapsList(MapListClass).Maps[X];
		}
	}
	else if ( MapListType==2 )
	{
		MapListClass = Spawn( Class'CustomMapList' );
		for ( X=0; X<32; X++ )
		{
			VoteMapList[X] = CustomMapList(MapListClass).Maps[X];
		}
	}
	else
	{
		MapListClass = Spawn( Class'ASMapList' );
		for ( X=0; X<32; X++ )
		{
			VoteMapList[X] = ASMapList(MapListClass).Maps[X];
		}
	}
}

event Tick( float DeltaTime )
{
	if ( WelcomeMessageShown!=-1 )
	{
		if ( Level.TimeSeconds>float(20) && WelcomeMessageShown==0 )
		{
			BroadcastMessage( "Map Voting Enabled..." );
			WelcomeMessageShown = 1;
		}
		else if ( Level.TimeSeconds>float(22) && WelcomeMessageShown==1 )
		{
			BroadcastMessage( "To list the available maps, type: 'mutate ListMaps'." );
			WelcomeMessageShown = 2;
		}
		else if ( Level.TimeSeconds>float(24) && WelcomeMessageShown==2 )
		{
			BroadcastMessage( "To vote for a map, type: 'mutate VoteMap <MAP NUMBER>'." );
			WelcomeMessageShown = 3;
		}
		else if ( Level.TimeSeconds>float(26) && WelcomeMessageShown==3 )
		{
			BroadcastMessage( "Percentage of votes required to instigate a map change:"@string(MapVoteChangeLimit)$"%." );
			WelcomeMessageShown = -1;
		}
	}
}

function Mutate( string MutateString, PlayerPawn Sender )
{
	if ( MutateString~="ListMaps" )
	{
		ExecuteListMaps( Sender );
	}
	else if ( Left(Caps(MutateString),7)=="VOTEMAP" )
	{
		if ( Level.TimeSeconds>float(20) )
		{
			ExecuteVoteMap( int(Right(MutateString,Len(MutateString)-7)), Sender );
		}
		else
		{
			Sender.ClientMessage( "Please Wait 20 seconds to vote" );
		}
	}
	Super.Mutate( MutateString, Sender );
}

function ExecuteVoteMap( int MapNum, PlayerPawn Voter )
{
	local int PlayerIndex, X;
	local int VoteCount[32];

	PlayerIndex = Voter.PlayerReplicationInfo.PlayerID;
	MapNum--;
	if ( VoteMapList[MapNum]=="" )
	{
		return;
	}
	PlayerVote[PlayerIndex] = MapNum;
	BroadcastMessage( Voter.PlayerReplicationInfo.PlayerName$" voted for "$VoteMapList[MapNum], true, 'CriticalEvent' );
	for ( X=0; X<63; X++ )
	{
		if ( PlayerVote[X]>=0 )
		{
			VoteCount[PlayerVote[X]]++;
			if ( float(VoteCount[PlayerVote[X]])/float(Level.Game.NumPlayers)>float(MapVoteChangeLimit)/100.0 )
			{
				Log( "Changing map to"@VoteMapList[PlayerVote[X]]@"due to vote." );
				Level.ServerTravel( VoteMapList[PlayerVote[X]], false );
			}
		}
	}
}

function ExecuteListMaps( PlayerPawn Sender )
{
	local int X;

	for ( X=0; X<128; X++ )
	{
		if ( VoteMapList[X]!="" )
		{
			Sender.ClientMessage( string(X+1)$":"$VoteMapList[X] );
		}
	}
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    MapVoteChangeLimit=75
}
