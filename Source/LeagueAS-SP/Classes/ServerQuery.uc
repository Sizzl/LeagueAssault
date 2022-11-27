//=============================================================================
// ServerQuery.
//=============================================================================
class ServerQuery extends UdpLink;

var() name QueryName;
var int CurrentQueryNum;
var globalconfig string GameName;
var string ReplyData;
var globalconfig int MinNetVer;
var globalconfig int OldQueryPortNumber;
var globalconfig bool bRestartServerOnPortSwap;

function PreBeginPlay()
{
	local int boundport;

	Tag = QueryName;
	boundport = BindPort( Level.Game.GetServerPort(), true );
	if ( boundport==0 )
	{
		Log( "ServerQuery: Port failed to bind.", 'LeagueAssault' );
		return;
	}
	Log( "ServerQuery: Port "$string(boundport)$" successfully bound.", 'LeagueAssault' );
	if ( bRestartServerOnPortSwap )
	{
		if ( OldQueryPortNumber!=0 )
		{
			assert(OldQueryPortNumber==boundport);
		}
		OldQueryPortNumber = boundport;
		SaveConfig();
	}
}

function PostBeginPlay()
{
	local UdpBeacon Beacon;

	foreach AllActors( Class'UdpBeacon', Beacon )
	{
		Beacon.UdpServerQueryPort = Port;
	}
	Super.PostBeginPlay();
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
	PacketNum = 0;
	ReplyData = "";
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

function bool ParseNextQuery( string Query, out string QueryType, out string QueryValue, out string QueryRest, out int bFinalPacket )
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
			bFinalPacket = 1;
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
			bFinalPacket = 1;
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

function string ParseQuery( IpAddr Addr, coerce string Query, int QueryNum, out int PacketNum )
{
	local string QueryType, QueryValue, QueryRest, ValidationString;
	local bool Result;
	local int bFinalPacket;

	bFinalPacket = 0;
	Result = ParseNextQuery( Query, QueryType, QueryValue, QueryRest, bFinalPacket );
	if ( !Result )
	{
		return "";
	}
	if ( QueryType=="basic" )
	{
		Result = SendQueryPacket( Addr, GetBasic(), QueryNum, PacketNum, bFinalPacket );
	}
	else if ( QueryType=="info" )
	{
		Result = SendQueryPacket( Addr, GetInfo(), QueryNum, PacketNum, bFinalPacket );
	}
	else if ( QueryType=="rules" )
	{
		Result = SendQueryPacket( Addr, GetRules(), QueryNum, PacketNum, bFinalPacket );
	}
	else if ( QueryType=="players" )
	{
		if ( Level.Game.NumPlayers>0 )
		{
			Result = SendPlayers( Addr, QueryNum, PacketNum, bFinalPacket );
		}
		else
		{
			Result = SendQueryPacket( Addr, "", QueryNum, PacketNum, bFinalPacket );
		}
	}
	else if ( QueryType=="status" )
	{
		Result = SendQueryPacket( Addr, GetBasic(), QueryNum, PacketNum, 0 );
		Result = SendQueryPacket( Addr, GetInfo(), QueryNum, PacketNum, 0 );
		if ( Level.Game.NumPlayers==0 )
		{
			Result = SendQueryPacket( Addr, GetRules(), QueryNum, PacketNum, bFinalPacket );
		}
		else
		{
			Result = SendQueryPacket( Addr, GetRules(), QueryNum, PacketNum, 0 );
			Result = SendPlayers( Addr, QueryNum, PacketNum, bFinalPacket );
		}
	}
	else if ( QueryType=="echo" )
	{
		Result = SendQueryPacket( Addr, "\\echo\\"$QueryValue, QueryNum, PacketNum, bFinalPacket );
	}
	else if ( QueryType=="secure" )
	{
		ValidationString = "\\validate\\" $ Validate( QueryValue, GameName );
		Result = SendQueryPacket( Addr, ValidationString, QueryNum, PacketNum, bFinalPacket );
	}
	else if ( QueryType=="level_property" )
	{
		Result = SendQueryPacket( Addr, GetLevelProperty(QueryValue), QueryNum, PacketNum, bFinalPacket );
	}
	else if ( QueryType=="game_property" )
	{
		Result = SendQueryPacket( Addr, GetGameProperty(QueryValue), QueryNum, PacketNum, bFinalPacket );
	}
	else if ( QueryType=="player_property" )
	{
		Result = SendQueryPacket( Addr, GetPlayerProperty(QueryValue), QueryNum, PacketNum, bFinalPacket );
	}
	return QueryRest;
}

function bool SendAPacket( IpAddr Addr, int QueryNum, out int PacketNum, int bFinalPacket )
{
	local bool Result;

	ReplyData = ReplyData $ "\\queryid\\" $ string(QueryNum) $ "." $ string(++PacketNum);
	if ( bFinalPacket==1 )
	{
		ReplyData = ReplyData $ "\\final\\";
	}
	Result = SendText( Addr, ReplyData );
	ReplyData = "";
	return Result;
}

function bool SendQueryPacket( IpAddr Addr, coerce string SendString, int QueryNum, out int PacketNum, int bFinalPacket )
{
	local bool Result;

	Result = true;
	if ( Len(ReplyData)+Len(SendString)>1000 )
	{
		Result = SendAPacket( Addr, QueryNum, PacketNum, 0 );
	}
	ReplyData = ReplyData $ SendString;
	if ( bFinalPacket==1 )
	{
		Result = SendAPacket( Addr, QueryNum, PacketNum, bFinalPacket );
	}
	return Result;
}

function string GetBasic()
{
	local string ResultSet;

	ResultSet = "\\gamename\\" $ GameName;
	ResultSet = ResultSet $ "\\gamever\\" $ Level.EngineVersion;
	if ( MinNetVer>=int(Level.MinNetVersion) && MinNetVer<=int(Level.EngineVersion) )
	{
		ResultSet = ResultSet $ "\\minnetver\\" $ string(MinNetVer);
	}
	else
	{
		ResultSet = ResultSet $ "\\minnetver\\" $ Level.MinNetVersion;
	}
	ResultSet = ResultSet $ "\\location\\" $ string(Level.Game.GameReplicationInfo.Region);
	return ResultSet;
}

function string GetInfo()
{
	local string ResultSet;

	ResultSet = "\\hostname\\" $ Level.Game.GameReplicationInfo.ServerName;
	ResultSet = ResultSet $ "\\hostport\\" $ string(Level.Game.GetServerPort());
	ResultSet = ResultSet $ "\\maptitle\\" $ Level.Title;
	ResultSet = ResultSet $ "\\mapname\\" $ Left( string(Level), InStr(string(Level),".") );
	if ( Level.Game.IsA('LeagueAssault') )
	{
		ResultSet = ResultSet $ "\\gametype\\Assault";
	}
	else
	{
		ResultSet = ResultSet $ "\\gametype\\" $ GetItemName( string(Level.Game.Class) );
	}
	ResultSet = ResultSet $ "\\numplayers\\" $ string(Level.Game.NumPlayers);
	ResultSet = ResultSet $ "\\maxplayers\\" $ string(Level.Game.MaxPlayers);
	ResultSet = ResultSet $ "\\gamemode\\openplaying";
	ResultSet = ResultSet $ "\\gamever\\" $ Level.EngineVersion;
	if ( MinNetVer>=int(Level.MinNetVersion) && MinNetVer<=int(Level.EngineVersion) )
	{
		ResultSet = ResultSet $ "\\minnetver\\" $ string(MinNetVer);
	}
	else
	{
		ResultSet = ResultSet $ "\\minnetver\\" $ Level.MinNetVersion;
	}
	ResultSet = ResultSet $ Level.Game.GetInfo();
	return ResultSet;
}

function string GetRules()
{
	local string ResultSet;

	ResultSet = Level.Game.GetRules();
	if ( Level.Game.GameReplicationInfo.AdminName!="" )
	{
		ResultSet = ResultSet $ "\\AdminName\\" $ Level.Game.GameReplicationInfo.AdminName;
	}
	if ( Level.Game.GameReplicationInfo.AdminEmail!="" )
	{
		ResultSet = ResultSet $ "\\AdminEMail\\" $ Level.Game.GameReplicationInfo.AdminEmail;
	}
	return ResultSet;
}

function string GetPlayer( PlayerPawn P, int PlayerNum )
{
	local string ResultSet, SkinName, FaceName;

	ResultSet = "\\player_" $ string(PlayerNum) $ "\\" $ P.PlayerReplicationInfo.PlayerName;
	ResultSet = ResultSet $ "\\frags_" $ string(PlayerNum) $ "\\" $ string(int(P.PlayerReplicationInfo.Score));
	ResultSet = ResultSet $ "\\ping_" $ string(PlayerNum) $ "\\" $ P.ConsoleCommand( "GETPING" );
	ResultSet = ResultSet $ "\\team_" $ string(PlayerNum) $ "\\" $ string(P.PlayerReplicationInfo.Team);
	ResultSet = ResultSet $ "\\mesh_" $ string(PlayerNum) $ "\\" $ P.MenuName;
	if ( P.Skin==None )
	{
		P.GetMultiSkin( P, SkinName, FaceName );
		ResultSet = ResultSet $ "\\skin_" $ string(PlayerNum) $ "\\" $ SkinName;
		ResultSet = ResultSet $ "\\face_" $ string(PlayerNum) $ "\\" $ FaceName;
	}
	else
	{
		ResultSet = ResultSet $ "\\skin_" $ string(PlayerNum) $ "\\" $ string(P.Skin);
		ResultSet = ResultSet $ "\\face_" $ string(PlayerNum) $ "\\None";
	}
	if ( P.PlayerReplicationInfo.bIsABot )
	{
		ResultSet = ResultSet $ "\\ngsecret_" $ string(PlayerNum) $ "\\bot";
	}
	else if ( P.ReceivedSecretChecksum )
	{
		ResultSet = ResultSet $ "\\ngsecret_" $ string(PlayerNum) $ "\\true";
	}
	else
	{
		ResultSet = ResultSet $ "\\ngsecret_" $ string(PlayerNum) $ "\\false";
	}
	return ResultSet;
}

function bool SendPlayers( IpAddr Addr, int QueryNum, out int PacketNum, int bFinalPacket )
{
	local Pawn P;
	local int i;
	local bool Result, SendResult;

	Result = false;
	P = Level.PawnList;
	while ( i<Level.Game.NumPlayers )
	{
		if ( P.IsA('PlayerPawn') )
		{
			if ( i==Level.Game.NumPlayers-1 && bFinalPacket==1 )
			{
				SendResult = SendQueryPacket( Addr, GetPlayer(PlayerPawn(P),i), QueryNum, PacketNum, 1 );
			}
			else
			{
				SendResult = SendQueryPacket( Addr, GetPlayer(PlayerPawn(P),i), QueryNum, PacketNum, 0 );
			}
			Result = SendResult || Result;
			i++;
		}
		P = P.nextPawn;
	}
	return Result;
}

function string GetLevelProperty( string Prop )
{
	local string ResultSet;

	ResultSet = "\\" $ Prop $ "\\" $ Level.GetPropertyText( Prop );
	return ResultSet;
}

function string GetGameProperty( string Prop )
{
	local string ResultSet;

	ResultSet = "\\" $ Prop $ "\\" $ Level.Game.GetPropertyText( Prop );
	return ResultSet;
}

function string GetPlayerProperty( string Prop )
{
	local string ResultSet;
	local int i;
	local PlayerPawn P;

	foreach AllActors( Class'PlayerPawn', P )
	{
		i++;
		ResultSet = ResultSet $ "\\" $ Prop $ "_" $ string(i) $ "\\" $ P.GetPropertyText( Prop );
	}
	return ResultSet;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    QueryName="MasterUplink"
    CurrentQueryNum=0
    GameName="ut"
    ReplyData=""
    MinNetVer=0
    OldQueryPortNumber=0
    bRestartServerOnPortSwap=False
    RemoteRole=ROLE_None
}
