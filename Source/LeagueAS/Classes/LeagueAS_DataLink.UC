//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_DataLink expands UdpLink abstract;

var int ServerIP;
var int ListenPort;
var() config bool bDoDataLink;

var string LinkName;
var IpAddr ServerAddr;
var int boundport;
var int CurrentAckNo;
var string MyIP;

//************************************************************************************************
function Initialise()
{
	local IPAddr MyIPAddr;

	if ( bDoDataLink )
		{
		GetLocalIP(MyIPAddr);
		MyIPAddr.Port = ListenPort;
		MyIP = IpAddrToString(MyIPAddr);

		ServerAddr.Addr = ServerIP;
		ServerAddr.Port = ListenPort;

		Boundport = BindPort(ListenPort, True);
		if ( Boundport == 0 )
		{
			log("Failed to bind datalink port.", 'LeagueAssault' );
			return;
		}
		else
			log(LinkName@"Datalink initialised. Listening on "$MyIP, 'LeagueAssault' );

		SendString("HELLO!");
		}
}
//************************************************************************************************
function SendString(string Data)
{
	if ( bDoDataLink )
		{
		SendText( ServerAddr, Data );
		//log("Datalink Sent: "$Data, 'LeagueAssault');
		}
}
//************************************************************************************************
event ReceivedText( IpAddr Addr, string Text )
{
	local IpAddr RelayAddr;

	RelayAddr.Addr = Addr.Addr;
	RelayAddr.Port = ListenPort;

	If ( Left(Text, 6) == "HELLO?" ) //Query Server Alive
		SendText(RelayAddr, "HELLO!");
	else if ( Left(Text, 7) == "RELAY::" ) //Relay Text Back (Test Facility)
		SendText(RelayAddr, "RELAYING::"$Right(Text, (Len(Text) - 7)));		
}
//************************************************************************************************
function ShutDown()
{
	SaveConfig();
	Destroy();
}
//************************************************************************************************

defaultproperties
{
      ServerIP=0
      ListenPort=0
      bDoDataLink=False
      LinkName="Generic"
      ServerAddr=(Addr=0,Port=0)
      boundport=0
      CurrentAckNo=0
      MyIP=""
}
