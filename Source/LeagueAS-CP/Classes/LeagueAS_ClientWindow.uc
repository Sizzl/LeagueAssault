//=============================================================================
// LeagueAS_ClientWindow.
//=============================================================================
class LeagueAS_ClientWindow extends UWindowDialogClientWindow;

//-----------------------------------------------------------------------------
// Properties.
//-----------------------------------------------------------------------------

var UWindowEditControl PlayerName;
var UWindowEditControl ClanName;
var UWindowEditControl PlayerPassword;
var UWindowComboControl TagMode;
var UWindowComboControl MuteMode;
var UWindowCheckbox ExtHudEnabled;
var UWindowCheckbox ExtHudShowGameInfo;
var UWindowCheckbox ExtHudShowConnInfo;
var UWindowCheckbox ExtHudShowTime;
var UWindowCheckbox ExtHudShowTeamInfo;
var UWindowCheckbox ExtHudShowObjInfo;
var UWindowCheckbox ExtHudLargeFont;
var UWindowComboControl TimeMode;
var string TagModes[2];
var string MuteModes[3];
var string TimeModes[2];

//-----------------------------------------------------------------------------
// Global Functions.
//-----------------------------------------------------------------------------

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight, CenterWidth, CenterPos, ControlOffset;

	Super.Created();
	ControlWidth = int(WinWidth/2.5);
	ControlLeft = int(WinWidth/float(2)-float(ControlWidth))/2;
	ControlRight = int(WinWidth/float(2)+float(ControlLeft));
	CenterWidth = int(WinWidth/float(4))*3;
	CenterPos = int(WinWidth-float(CenterWidth))/2;
	ControlOffset = 20;
	PlayerName = UWindowEditControl(CreateControl(Class'UWindowEditControl',float(CenterPos),float(ControlOffset),float(CenterWidth),1.0));
	PlayerName.SetText( "Registered Player Name:" );
	PlayerName.SetFont( 0 );
	PlayerName.Align = TA_Left;
	PlayerName.SetDelayedNotify( true );
	PlayerName.SetValue( Class'ClientOptions'.default.PlayerName );
	ControlOffset += 30;
	ClanName = UWindowEditControl(CreateControl(Class'UWindowEditControl',float(CenterPos),float(ControlOffset),float(CenterWidth),1.0));
	ClanName.SetText( "Registered Clan Tag:" );
	ClanName.SetFont( 0 );
	ClanName.Align = TA_Left;
	ClanName.SetDelayedNotify( true );
	ClanName.SetValue( Class'ClientOptions'.default.ClanName );
	ControlOffset += 30;
	PlayerPassword = UWindowEditControl(CreateControl(Class'UWindowEditControl',float(CenterPos),float(ControlOffset),float(CenterWidth),1.0));
	PlayerPassword.SetText( "Registered Player Password:" );
	PlayerPassword.SetFont( 0 );
	PlayerPassword.Align = TA_Left;
	PlayerPassword.SetDelayedNotify( true );
	PlayerPassword.SetValue( Class'ClientOptions'.default.PlayerPassword );
	ControlOffset += 30;
	TagMode = UWindowComboControl(CreateControl(Class'UWindowComboControl',float(CenterPos),float(ControlOffset),float(CenterWidth),1.0));
	TagMode.SetText( "Clan Tag Format:" );
	TagMode.SetFont( 0 );
	TagMode.SetEditable( false );
	TagMode.AddItem( TagModes[0] );
	TagMode.AddItem( TagModes[1] );
	if ( Class'ClientOptions'.default.bClanTagBefore )
	{
		TagMode.SetValue( TagModes[0] );
	}
	else
	{
		TagMode.SetValue( TagModes[1] );
	}
	ControlOffset += 30;
	MuteMode = UWindowComboControl(CreateControl(Class'UWindowComboControl',float(CenterPos),float(ControlOffset),float(CenterWidth),1.0));
	MuteMode.SetText( "Mute Mode:" );
	MuteMode.SetFont( 0 );
	MuteMode.SetEditable( false );
	MuteMode.AddItem( MuteModes[0] );
	MuteMode.AddItem( MuteModes[1] );
	MuteMode.AddItem( MuteModes[2] );
	if ( Class'ClientOptions'.default.bMuteAll )
	{
		MuteMode.SetValue( MuteModes[2] );
	}
	else if ( Class'ClientOptions'.default.bMuteSay )
	{
		MuteMode.SetValue( MuteModes[1] );
	}
	else
	{
		MuteMode.SetValue( MuteModes[0] );
	}
	ControlOffset += 30;
	ExtHudEnabled = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',float(CenterPos),float(ControlOffset),float(CenterWidth),1.0));
	ExtHudEnabled.SetText( "Enable Extended HUD" );
	ExtHudEnabled.SetFont( 0 );
	ExtHudEnabled.Align = TA_Left;
	ExtHudEnabled.bChecked = Class'ClientOptions'.default.bExtHudEnabled;
	ControlOffset += 30;
	ExtHudShowGameInfo = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',float(ControlLeft),float(ControlOffset),float(ControlWidth),1.0));
	ExtHudShowGameInfo.SetText( "Show Game Information" );
	ExtHudShowGameInfo.SetFont( 0 );
	ExtHudShowGameInfo.Align = TA_Left;
	ExtHudShowGameInfo.bChecked = Class'ClientOptions'.default.bExtHudShowGameInfo;
	ExtHudShowConnInfo = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',float(ControlRight),float(ControlOffset),float(ControlWidth),1.0));
	ExtHudShowConnInfo.SetText( "Show Connection Info" );
	ExtHudShowConnInfo.SetFont( 0 );
	ExtHudShowConnInfo.Align = TA_Left;
	ExtHudShowConnInfo.bChecked = Class'ClientOptions'.default.bExtHudShowConnInfo;
	ControlOffset += 20;
	ExtHudShowTime = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',float(ControlLeft),float(ControlOffset),float(ControlWidth),1.0));
	ExtHudShowTime.SetText( "Show Time Information" );
	ExtHudShowTime.SetFont( 0 );
	ExtHudShowTime.Align = TA_Left;
	ExtHudShowTime.bChecked = Class'ClientOptions'.default.bExtHudShowTime;
	ExtHudShowTeamInfo = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',float(ControlRight),float(ControlOffset),float(ControlWidth),1.0));
	ExtHudShowTeamInfo.SetText( "Show Team Information" );
	ExtHudShowTeamInfo.SetFont( 0 );
	ExtHudShowTeamInfo.Align = TA_Left;
	ExtHudShowTeamInfo.bChecked = Class'ClientOptions'.default.bExtHudShowTeamInfo;
	ControlOffset += 20;
	ExtHudShowObjInfo = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',float(ControlLeft),float(ControlOffset),float(ControlWidth),1.0));
	ExtHudShowObjInfo.SetText( "Show Objective Information" );
	ExtHudShowObjInfo.SetFont( 0 );
	ExtHudShowObjInfo.Align = TA_Left;
	ExtHudShowObjInfo.bChecked = Class'ClientOptions'.default.bExtHudShowObjInfo;
	ExtHudLargeFont = UWindowCheckbox(CreateControl(Class'UWindowCheckbox',float(ControlRight),float(ControlOffset),float(ControlWidth),1.0));
	ExtHudLargeFont.SetText( "Use Large HUD Font" );
	ExtHudLargeFont.SetFont( 0 );
	ExtHudLargeFont.Align = TA_Left;
	ExtHudLargeFont.bChecked = Class'ClientOptions'.default.bExtHudLargeFont;
	ControlOffset += 30;
	TimeMode = UWindowComboControl(CreateControl(Class'UWindowComboControl',float(CenterPos),float(ControlOffset),float(CenterWidth),1.0));
	TimeMode.SetText( "Time Display Format:" );
	TimeMode.SetFont( 0 );
	TimeMode.SetEditable( false );
	TimeMode.AddItem( TimeModes[0] );
	TimeMode.AddItem( TimeModes[1] );
	if ( Class'ClientOptions'.default.bExtHudShowElapsedTime )
	{
		TimeMode.SetValue( TimeModes[1] );
	}
	else
	{
		TimeMode.SetValue( TimeModes[0] );
	}
}

function Notify( UWindowDialogControl C, byte E )
{

  switch (E)
  {
    case 1:
    switch (C)
    {
      case PlayerName:
      Class'ClientOptions'.Default.PlayerName = PlayerName.GetValue();
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case ClanName:
      Class'ClientOptions'.Default.ClanName = ClanName.GetValue();
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case PlayerPassword:
      Class'ClientOptions'.Default.PlayerPassword = PlayerPassword.GetValue();
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case TagMode:
      switch (TagMode.GetSelectedIndex())
      {
        case 0:
        Class'ClientOptions'.Default.bClanTagBefore = True;
        Class'ClientOptions'.StaticSaveConfig();
        break;
        case 1:
        Class'ClientOptions'.Default.bClanTagBefore = False;
        Class'ClientOptions'.StaticSaveConfig();
        break;
        default:
        return;
      }
      break;
      case MuteMode:
      switch (MuteMode.GetSelectedIndex())
      {
        case 0:
        Class'ClientOptions'.Default.bMuteSay = False;
        Class'ClientOptions'.Default.bMuteAll = False;
        Class'ClientOptions'.StaticSaveConfig();
        break;
        case 1:
        Class'ClientOptions'.Default.bMuteSay = True;
        Class'ClientOptions'.Default.bMuteAll = False;
        Class'ClientOptions'.StaticSaveConfig();
        break;
        case 2:
        Class'ClientOptions'.Default.bMuteSay = True;
        Class'ClientOptions'.Default.bMuteAll = True;
        Class'ClientOptions'.StaticSaveConfig();
        break;
        default:
        return;
      }
      break;
      case ExtHudEnabled:
      Class'ClientOptions'.Default.bExtHudEnabled = ExtHudEnabled.bChecked;
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case ExtHudShowGameInfo:
      Class'ClientOptions'.Default.bExtHudShowGameInfo = ExtHudShowGameInfo.bChecked;
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case ExtHudShowConnInfo:
      Class'ClientOptions'.Default.bExtHudShowConnInfo = ExtHudShowConnInfo.bChecked;
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case ExtHudShowTime:
      Class'ClientOptions'.Default.bExtHudShowTime = ExtHudShowTime.bChecked;
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case ExtHudShowTeamInfo:
      Class'ClientOptions'.Default.bExtHudShowTeamInfo = ExtHudShowTeamInfo.bChecked;
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case ExtHudShowObjInfo:
      Class'ClientOptions'.Default.bExtHudShowObjInfo = ExtHudShowObjInfo.bChecked;
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case ExtHudLargeFont:
      Class'ClientOptions'.Default.bExtHudLargeFont = ExtHudLargeFont.bChecked;
      Class'ClientOptions'.StaticSaveConfig();
      break;
      case TimeMode:
      switch (TimeMode.GetSelectedIndex())
      {
        case 0:
        Class'ClientOptions'.Default.bExtHudShowElapsedTime = False;
        Class'ClientOptions'.StaticSaveConfig();
        break;
        case 1:
        Class'ClientOptions'.Default.bExtHudShowElapsedTime = True;
        Class'ClientOptions'.StaticSaveConfig();
        break;
        default:
        return;
      }
      break;
      default:
      return;
    }
    default:
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    PlayerName=None
    ClanName=None
    PlayerPassword=None
    TagMode=None
    MuteMode=None
    ExtHudEnabled=None
    ExtHudShowGameInfo=None
    ExtHudShowConnInfo=None
    ExtHudShowTime=None
    ExtHudShowTeamInfo=None
    ExtHudShowObjInfo=None
    ExtHudLargeFont=None
    TimeMode=None
    TagModes(0)="Before Name"
    TagModes(1)="After Name"
    MuteModes(0)="No Mute"
    MuteModes(1)="Mute Enemy Messages"
    MuteModes(2)="Mute ALL Messages"
    TimeModes(0)="Show Remaining Time"
    TimeModes(1)="Show Elapsed Time"
}
