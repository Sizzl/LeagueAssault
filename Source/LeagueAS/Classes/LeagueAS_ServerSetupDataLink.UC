//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_ServerSetupDataLink extends LeagueAS_DataLink;

var() private config string LinkPassword;
var() config int LoggedInIP;

//************************************************************************************************
function SendString(string Data)
{
	ServerAddr.Addr = LoggedInIP;
	ServerAddr.Port = ListenPort;

	if ( bDoDataLink )
		{
		SendText( ServerAddr, Data );
		}
}
//************************************************************************************************
event ReceivedText( IpAddr Addr, string Text )
{
	local string Password, TeamName;

	Super.ReceivedText( Addr, Text );
	
	if ( Left(Text, 7) == "LOGIN::" ) //Login
		{
		log("Server Setup Datalink Login Request from IP: "$IpAddrToString(Addr)$". Supplied Password: "$Right(Text, (Len(Text) - 7))$". Required Password: "$LinkPassword$".", 'LeagueAssault');
		if ( Right(Text, (Len(Text) - 7)) == LinkPassword )
			{
			log("Server Setup Datalink Login Successful!", 'LeagueAssault');
			LoggedInIP = Addr.Addr;			
			SaveConfig();
			SendString("LOGGEDIN!");
			}
		}
	else if ( Addr.Addr == LoggedInIP	)
		{
		log("Server Setup Datalink Command Recieved: "$Text$". From IP: "$IpAddrToString(Addr), 'LeagueAssault');
		if ( Text == "LOGOUT!" )
			{
			SendString("LOGGEDOUT!");
			LoggedInIP = 0;
			SaveConfig();
			}
		else if ( Text == "RESTARTMAP!" ) //Restart the map
			{
			Level.ServerTravel( "?Restart", false );
			SendString("MAPRESTARTING!");
			}
		else if ( Left(Text, 16) == "SETREDTEAMNAME::" ) //Set red team name
			{
			TeamName = Right(Text, (Len(Text) - 16));
			LeagueAssault(Level.Game).TeamNameRed = TeamName;
			SendString("REDTEAMNAMESET!");
			}
		else if ( Left(Text, 17) == "SETBLUETEAMNAME::" ) //Set blue team name
			{
			TeamName = Right(Text, (Len(Text) - 17));
			LeagueAssault(Level.Game).TeamNameBlue = TeamName;
			SendString("BLUETEAMNAMESET!");
			}
		else if ( Left(Text, 17) == "SETGAMEPASSWORD::" ) //Set main game password
			{
			Password = Right(Text, (Len(Text) - 17));
			Level.ConsoleCommand("set engine.gameinfo GamePassword "$Password);
			SendString("GAMEPASSWORDSET!");
			}
		else if ( Left(Text, 16) == "SETREDPASSWORD::" ) //Set red team match password
			{
			Password = Right(Text, (Len(Text) - 16));
			LeagueAssault(Level.Game).SetPassword(0, Password);
			SendString("REDPASSWORDSET!");
			}
		else if ( Left(Text, 17) == "SETBLUEPASSWORD::" ) //Set red team match password
			{
			Password = Right(Text, (Len(Text) - 17));
			LeagueAssault(Level.Game).SetPassword(1, Password);
			SendString("BLUEPASSWORDSET!");
			}
		else if ( Left(Text, 22) == "SETMODERATORPASSWORD::" ) //Set moderator password
			{
			Password = Right(Text, (Len(Text) - 22));
			LeagueAssault(Level.Game).SetPassword(2, Password);
			SendString("MODERATORPASSWORDSET!");
			}
		else if ( Left(Text, 19) == "SETTOURNAMENTMODE::" )	//Set tournament mode
			{
			If ( Right(Text, (Len(Text) - 19)) ~= "TRUE" )
				LeagueAssault(Level.Game).bTournament = true;
			else
				LeagueAssault(Level.Game).bTournament = false;
			SendString("TOURNAMENTMODESET!");
			}
		else if ( Left(Text, 15) == "SETATTACKONLY::" )	//Set attack only
			{
			If ( Right(Text, (Len(Text) - 15)) ~= "TRUE" )
				LeagueAssault(Level.Game).bAttackOnly = true;
			else
				LeagueAssault(Level.Game).bAttackOnly = false;
			SendString("ATTACKONLYSET!");
			}
		else if ( Left(Text, 16) == "SETPLAYERLIMIT::" )	//Set num players
			{
				LeagueAssault(Level.Game).MaxPlayers = int(Right(Text, (Len(Text) - 16)));
				SendString("PLAYERLIMITSET!");
			}
		else if ( Left(Text, 14) == "SETSPECLIMIT::" )	//Set num specs
			{
				LeagueAssault(Level.Game).MaxSpectators = int(Right(Text, (Len(Text) - 14)));
				SendString("SPECLIMITSET!");
			}
		else if ( Left(Text, 12) == "SETMAPLIST::" )	//Set map list
			{
			if ( SetMapList( Right(Text, (Len(Text) - 11)) ) )
				SendString("MAPLISTSET!");
			}
		else if ( Left(Text, 11) == "STARTMATCH!" )	//Start a match
			{
			LeagueAssault(Level.Game).PEFStartMatch(None);
			SendString("STARTINGMATCH!");
			}
		else if	( Left(Text, 9) == "ENDMATCH!" ) //End a match
			{
			LeagueAssault(Level.Game).PEFEndMatch();
			SendString("ENDINGMATCH!");
			}

		Level.Game.SaveConfig();
		}

}
//************************************************************************************************
function bool GetMap( out string Maps, out string Map )
{

	if( Left(Maps,1)==":" )
	{
		Map = Mid(Maps,1);
		if( InStr(Map,":")>=0 )
			Map = Left( Map, InStr(Map,":") );

		Maps = Mid(Maps,1);
		if( InStr(Maps,":")>=0 )
			Maps = Mid( Maps, InStr(Maps,":") );
		else
			Maps = "";

		return true;
	}
	else return false;

}
//************************************************************************************************
function bool SetMapList( string MapList )
{
	local int i;
	local string Map;

	i = 0;

	while ( GetMap( MapList, Map ) )
	{
		class'ASMapList'.Default.Maps[i] = Map;
		i++;
	}
	while ( i < 32 )
		{
		class'ASMapList'.Default.Maps[i] = "";
		i++;
		}

   Level.ServerTravel(Map, false);

   return true;

}
//************************************************************************************************

defaultproperties
{
      LinkPassword="Default"
      LoggedInIP=0
      ListenPort=6558
      LinkName="Server Setup"
}
