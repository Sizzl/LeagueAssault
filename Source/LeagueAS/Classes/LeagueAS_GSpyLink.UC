//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_GSpyLink extends UBrowserGSpyLink;

var string GameType;

state FoundSecretState 
{
Begin:
	Enable('Tick');
	SendBufferedData("\\list\\\\gametype\\"$GameType$"\\gamename\\"$GameName$"\\final\\");
	WaitFor("ip\\", 30, NextIP);
}

defaultproperties
{
      GameType=""
}
