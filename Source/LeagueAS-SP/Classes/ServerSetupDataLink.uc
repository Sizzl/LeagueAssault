//=============================================================================
// ServerSetupDataLink.
//=============================================================================
class ServerSetupDataLink extends LeagueAS_SSDAbstract;

var() config int ListenPort;
var() config bool bDoDataLink;
var() private config string LinkPassword;
var() config int LoggedInIP;
var() config int LoggedInPort;
var() config bool bNATCompliant;
var string mutators;

function Initialise()
{
	local IpAddr MyIPAddr;
	local string MyIP;
	local int boundport;

	if ( bDoDataLink )
	{
		GetLocalIP( MyIPAddr );
		MyIPAddr.Port = ListenPort;
		MyIP = IpAddrToString( MyIPAddr );
		boundport = BindPort( ListenPort, true );
		if ( boundport==0 )
		{
			Log( "Server Setup Datalink failed to bind datalink port.", 'LeagueAssault' );
			return;
		}
		else if ( bNATCompliant )
		{
			Log( "Server Setup Datalink initialised. NAT Complaint Mode. Listening on "$MyIP, 'LeagueAssault' );
		}
		else
		{
			Log( "Server Setup Datalink initialised. Listening on "$MyIP, 'LeagueAssault' );
		}
		SendString( "HELLO!" );
	}
}

function SendString( string Data )
{
	local IpAddr RemoteAddr;

	RemoteAddr.Addr = LoggedInIP;
	RemoteAddr.Port = LoggedInPort;
	if ( bDoDataLink )
	{
		SendText( RemoteAddr, Data );
	}
}

event ReceivedText( IpAddr Addr, string Text )
{
	local string Password, TeamName;
	local IpAddr RelayAddr;

	RelayAddr.Addr = Addr.Addr;
	RelayAddr.Port = ListenPort;
	if ( Left(Text,6)=="HELLO?" )
	{
		SendText( RelayAddr, "HELLO!" );
	}
	else if ( Left(Text,7)=="RELAY::" )
	{
		SendText( RelayAddr, "RELAYING::"$Right(Text,Len(Text)-7) );
	}
	if ( Left(Text,7)=="LOGIN::" )
	{
		Log( "Server Setup Datalink Login Request from IP: "$IpAddrToString(Addr)$". Supplied Password: "$Right(Text,Len(Text)-7)$". Required Password: "$LinkPassword$".", 'LeagueAssault' );
		if ( Right(Text,Len(Text)-7)==LinkPassword )
		{
			Log( "Server Setup Datalink Login Successful!", 'LeagueAssault' );
			LoggedInIP = Addr.Addr;
			if ( bNATCompliant )
			{
				LoggedInPort = Addr.Port;
			}
			else
			{
				LoggedInPort = ListenPort;
			}
			SaveConfig();
			SendString( "LOGGEDIN!" );
		}
	}
	else if ( Addr.Addr==LoggedInIP )
	{
		LoggedInPort = ListenPort;
		Log( "Server Setup Datalink Command Recieved: "$Text$". From IP: "$IpAddrToString(Addr), 'LeagueAssault' );
		if ( Text=="LOGOUT!" )
		{
			SendString( "LOGGEDOUT!" );
			LoggedInIP = 0;
			LoggedInIP = 0;
			SaveConfig();
		}
		else if ( Text=="RESTARTMAP!" )
		{
			Level.ServerTravel( "?Restart", false );
			SendString( "MAPRESTARTING!" );
		}
		else if ( Left(Text,16)=="SETREDTEAMNAME::" )
		{
			TeamName = Right( Text, Len(Text)-16 );
			LeagueAssault(Level.Game).TeamNameRed = TeamName;
			SendString( "REDTEAMNAMESET!" );
		}
		else if ( Left(Text,17)=="SETBLUETEAMNAME::" )
		{
			TeamName = Right( Text, Len(Text)-17 );
			LeagueAssault(Level.Game).TeamNameBlue = TeamName;
			SendString( "BLUETEAMNAMESET!" );
		}
		else if ( Left(Text,17)=="SETGAMEPASSWORD::" )
		{
			Password = Right( Text, Len(Text)-17 );
			Level.ConsoleCommand( "set engine.gameinfo GamePassword "$Password );
			SendString( "GAMEPASSWORDSET!" );
		}
		else if ( Left(Text,16)=="SETREDPASSWORD::" )
		{
			Password = Right( Text, Len(Text)-16 );
			LeagueAssault(Level.Game).SetPassword( 0, Password );
			SendString( "REDPASSWORDSET!" );
		}
		else if ( Left(Text,17)=="SETBLUEPASSWORD::" )
		{
			Password = Right( Text, Len(Text)-17 );
			LeagueAssault(Level.Game).SetPassword( 1, Password );
			SendString( "BLUEPASSWORDSET!" );
		}
		else if ( Left(Text,22)=="SETMODERATORPASSWORD::" )
		{
			Password = Right( Text, Len(Text)-22 );
			LeagueAssault(Level.Game).SetPassword( 2, Password );
			SendString( "MODERATORPASSWORDSET!" );
		}
		else if ( Left(Text,22)=="SETSPECTATORPASSWORD::" )
		{
			Password = Right( Text, Len(Text)-22 );
			LeagueAssault(Level.Game).SetPassword( 3, Password );
			SendString( "SPECTATORPASSWORDSET!" );
		}
		else if ( Left(Text,19)=="SETTOURNAMENTMODE::" )
		{
			if ( Right(Text,Len(Text)-19)~="TRUE" )
			{
				LeagueAssault(Level.Game).bTournament = true;
			}
			else
			{
				LeagueAssault(Level.Game).bTournament = false;
			}
			SendString( "TOURNAMENTMODESET!" );
		}
		else if ( Left(Text,15)=="SETATTACKONLY::" )
		{
			if ( Right(Text,Len(Text)-15)~="TRUE" )
			{
				LeagueAssault(Level.Game).bAttackOnly = true;
			}
			else
			{
				LeagueAssault(Level.Game).bAttackOnly = false;
			}
			SendString( "ATTACKONLYSET!" );
		}
		else if ( Left(Text,16)=="SETPLAYERLIMIT::" )
		{
			LeagueAssault(Level.Game).MaxPlayers = int(Right(Text,Len(Text)-16));
			SendString( "PLAYERLIMITSET!" );
		}
		else if ( Left(Text,14)=="SETSPECLIMIT::" )
		{
			LeagueAssault(Level.Game).MaxSpectators = int(Right(Text,Len(Text)-14));
			SendString( "SPECLIMITSET!" );
		}
		else if ( Left(Text,16)=="SETMUTATORLIST::" )
		{
			if ( SetMutatorList(Right(Text,Len(Text)-15)) )
			{
				SendString( "MUTATORLISTSET!" );
			}
		}
		else if ( Left(Text,12)=="SETMAPLIST::" )
		{
			if ( SetMapList(Right(Text,Len(Text)-11)) )
			{
				SendString( "MAPLISTSET!" );
			}
		}
		else if ( Left(Text,11)=="STARTMATCH!" )
		{
			LeagueAssault(Level.Game).PEFStartMatch( None );
			SendString( "STARTINGMATCH!" );
		}
		else if ( Left(Text,9)=="ENDMATCH!" )
		{
			LeagueAssault(Level.Game).PEFEndMatch();
			SendString( "ENDINGMATCH!" );
		}
		else if ( Left(Text,17)=="SETFRIENDLYFIRE::" )
		{
			LeagueAssault(Level.Game).FriendlyFireScale = float(Right(Text,Len(Text)-17))/float(100);
			SendString( "FRIENDLYFIRESET!" );
		}
		else if ( Left(Text,18)=="ISMATCHINPROGRESS?" )
		{
			if ( LeagueAssault(Level.Game).bMatchMode )
			{
				SendString( "MATCHINPROGRESS::YES" );
			}
			else
			{
				SendString( "MATCHINPROGRESS::NO" );
			}
		}
		else if ( Left(Text,18)=="SERVERISPASSWORDED?" )
		{
			if ( LeagueAssault(Level.Game).ServerHasPass )
			{
				SendString( "SERVERISPASSWORDED::YES" );
			}
			else
			{
				SendString( "SERVERISPASSWORDED::NO" );
			}
		}
		else if ( Left(Text,14)=="SETMATCHMODE::" )
		{
			if ( Right(Text,Len(Text)-14)~="TRUE" )
			{
				LeagueAssault(Level.Game).bMatchMode = true;
			}
			else
			{
				LeagueAssault(Level.Game).bMatchMode = false;
			}
			SendString( "MATCHMODESET!" );
		}
		Level.Game.SaveConfig();
	}
}

function bool GetMap( out string Maps, out string Map )
{
	if ( Left(Maps,1)==":" )
	{
		Map = Mid( Maps, 1 );
		if ( InStr(Map,":")>=0 )
		{
			Map = Left( Map, InStr(Map,":") );
		}
		Maps = Mid( Maps, 1 );
		if ( InStr(Maps,":")>=0 )
		{
			Maps = Mid( Maps, InStr(Maps,":") );
		}
		else
		{
			Maps = "";
		}
		return true;
	}
	else
	{
		return false;
	}
}

function bool SetMapList( string MapList )
{
	local int i;
	local string Map;

	i = 0;
	while ( GetMap(MapList,Map) )
	{
		Class'ASMapList'.default.Maps[i] = Map;
		i++;
	}
	while ( i<32 )
	{
		Class'ASMapList'.default.Maps[i] = "";
		i++;
	}
	Level.ServerTravel( Map$"?mutator="$mutators, false );
	return true;
}

function bool SetMutatorList( string MutatorList )
{
	local string ThisMutator;

	while ( GetMap(MutatorList,ThisMutator) )
	{
		if ( ThisMutator!="" )
		{
			mutators = mutators $ ThisMutator $ ",";
		}
	}
	return true;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    ListenPort=6558
    bDoDataLink=False
    LinkPassword="Default"
    LoggedInIP=0
    LoggedInPort=0
    bNATCompliant=False
    mutators=""
}
