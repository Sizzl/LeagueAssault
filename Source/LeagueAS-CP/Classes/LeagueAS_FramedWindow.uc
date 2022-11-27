//=============================================================================
// LeagueAS_FramedWindow.
//=============================================================================
class LeagueAS_FramedWindow extends UWindowFramedWindow;

//-----------------------------------------------------------------------------
// Global Functions.
//-----------------------------------------------------------------------------

function Created()
{
	Super.Created();
	WinLeft = float(int((Root.WinWidth-WinWidth)/float(2)));
	WinTop = float(int((Root.WinHeight-WinHeight)/float(2)));
}

function AfterCreate()
{
	local UWindowMessageBox WarningMessage;

	WarningMessage = MessageBox( "League Assault Settings", "WARNING: Changes to the following settings will not be applied to any games currently running. You should close any server connections or practice sessions which are currently active.", MB_OK, MR_Cancel, MR_No );
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    ClientClass=Class'LeagueAS-CP.LeagueAS_ClientWindow'
    WindowTitle="League Assault"
}
