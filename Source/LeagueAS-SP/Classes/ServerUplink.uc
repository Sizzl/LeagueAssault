//=============================================================================
// ServerUplink.
//=============================================================================
class ServerUplink extends UdpLink;

var() config bool DoUplink;
var() config int UpdateMinutes;
var() config string MasterServerAddress;
var() config int MasterServerPort;
var() config int Region;
var() name TargetQueryName;
var IpAddr MasterServerIpAddr;
var string HeartbeatMessage;
var ServerQuery Query;
var int CurrentQueryNum;


function PreBeginPlay()
{
	if ( !DoUplink )
	{
		Log( "DoUplink is not set.  Not connecting to Master Server.", 'LeagueAssault' );
		return;
	}
	if ( int(Level.NetMode)==int(ENetMode.NM_Standalone) )
	{
		Log( "This is a standalone game.  Not connecting to Master Server.", 'LeagueAssault' );
		return;
	}
	foreach AllActors( Class'ServerQuery', Query, TargetQueryName )
	{
		break;
	}
	if ( Query==None )
	{
		Log( "ServerUplink: Could not find a UdpServerQuery object, aborting.", 'LeagueAssault' );
		return;
	}
	if ( MasterServerAddress~="unreal.epicgames.com" )
	{
		HeartbeatMessage = "\\heartbeat\\" $ string(Query.Port) $ "\\gamename\\" $ Query.GameName $ "\\gamever\\" $ Level.EngineVersion;
	}
	else
	{
		HeartbeatMessage = "\\heartbeat\\" $ string(Query.Port) $ "\\gamename\\" $ Query.GameName;
	}
	MasterServerIpAddr.Port = MasterServerPort;
	if ( MasterServerAddress=="" )
	{
		MasterServerAddress = "master" $ string(Region) $ ".gamespy.com";
	}
	Resolve( MasterServerAddress );
}

function Resolved( IpAddr Addr )
{
	local bool Result;
	local int UplinkPort;

	MasterServerIpAddr.Addr = Addr.Addr;
	if ( MasterServerIpAddr.Addr==0 )
	{
		Log( "ServerUplink: Invalid master server address, aborting.", 'LeagueAssault' );
		return;
	}
	Log( "ServerUplink: Master Server is "$MasterServerAddress$":"$string(MasterServerIpAddr.Port), 'LeagueAssault' );
	UplinkPort = Query.Port+1;
	if ( BindPort(UplinkPort,true)==0 )
	{
		Log( "ServerUplink: Error binding port, aborting.", 'LeagueAssault' );
		return;
	}
	Log( "ServerUplink: Port "$string(UplinkPort)$" successfully bound.", 'LeagueAssault' );
	Resume();
}

function ResolveFailed()
{
	Log( "ServerUplink: Failed to resolve master server address, aborting.", 'LeagueAssault' );
}

function Timer()
{
	local bool Result;

	Result = SendText( MasterServerIpAddr, HeartbeatMessage );
	if ( !Result )
	{
		Log( "Failed to send heartbeat to master server.", 'LeagueAssault' );
	}
}

function Halt()
{
	SetTimer( 0.0, false );
}

function Resume()
{
	SetTimer( float(UpdateMinutes*60), true );
	Timer();
}

event ReceivedText( IpAddr Addr, string Text )
{
	local string Query;
	local bool QueryRemaining;
	local int QueryNum, PacketNum;

	CurrentQueryNum++;
	if ( CurrentQueryNum>100 )
	{
		CurrentQueryNum = 1;
	}
	QueryNum = CurrentQueryNum;
	Query = Text;
	if ( Query=="" )
	{
		QueryRemaining = false;
	}
	else
	{
		QueryRemaining = true;
	}
	while ( QueryRemaining )
	{
		Query = ParseQuery( Addr, Query, QueryNum, PacketNum );
		if ( Query=="" )
		{
			QueryRemaining = false;
		}
		else
		{
			QueryRemaining = true;
		}
	}
}

function bool ParseNextQuery( string Query, out string QueryType, out string QueryValue, out string QueryRest, out string FinalPacket )
{
	local string TempQuery;
	local int ClosingSlash;

	if ( Query=="" )
	{
		return false;
	}
	if ( Left(Query,1)=="\\" )
	{
		ClosingSlash = InStr( Right(Query,Len(Query)-1), "\\" );
		if ( ClosingSlash==0 )
		{
			return false;
		}
		TempQuery = Query;
		QueryType = Right( Query, Len(Query)-1 );
		QueryType = Left( QueryType, ClosingSlash );
		QueryRest = Right( Query, Len(Query)-(Len(QueryType)+2) );
		if ( QueryRest=="" || Len(QueryRest)==1 )
		{
			FinalPacket = "final";
			return true;
		}
		else if ( Left(QueryRest,1)=="\\" )
		{
			return true;
		}
		ClosingSlash = InStr( QueryRest, "\\" );
		if ( ClosingSlash>=0 )
		{
			QueryValue = Left( QueryRest, ClosingSlash );
		}
		else
		{
			QueryValue = QueryRest;
		}
		QueryRest = Right( Query, Len(Query)-(Len(QueryType)+Len(QueryValue)+3) );
		if ( QueryRest=="" )
		{
			FinalPacket = "final";
			return true;
		}
		else
		{
			return true;
		}
	}
	else
	{
		return false;
	}
}

function string ParseQuery( IpAddr Addr, coerce string QueryStr, int QueryNum, out int PacketNum )
{
	local string QueryType, QueryValue, QueryRest, ValidationString;
	local bool Result;
	local string FinalPacket;

	Result = ParseNextQuery( QueryStr, QueryType, QueryValue, QueryRest, FinalPacket );
	if ( !Result )
	{
		return "";
	}
	if ( QueryType=="basic" )
	{
		Result = true;
	}
	else if ( QueryType=="secure" )
	{
		ValidationString = "\\validate\\" $ Validate( QueryValue, Query.GameName );
		Result = SendQueryPacket( Addr, ValidationString, QueryNum, ++PacketNum, FinalPacket );
	}
	return QueryRest;
}

function bool SendQueryPacket( IpAddr Addr, coerce string SendString, int QueryNum, int PacketNum, string FinalPacket )
{
	local bool Result;

	if ( FinalPacket=="final" )
	{
		SendString = SendString $ "\\final\\";
	}
	SendString = SendString $ "\\queryid\\" $ string(QueryNum) $ "." $ string(PacketNum);
	Result = SendText( Addr, SendString );
	return Result;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    DoUplink=True
    UpdateMinutes=1
    MasterServerAddress=""
    MasterServerPort=27900
    TargetQueryName="MasterUplink"
    RemoteRole=ROLE_None
}
