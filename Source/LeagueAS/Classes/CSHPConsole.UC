//================================================================================
// CSHPConsole.
//================================================================================

class CSHPConsole extends UTConsole;

var UTConsole zzOldConsole;
var CSHPCheatRI zzMyCheatRI;
var int zzMyState;

event PreRender (Canvas Canvas);

function PostRender (Canvas C)
{
  local rotator zzVR;
  local int YStart, YEnd, Y, i, j, Line, iLine;
  local bool zzbCheckVR;

  zzVR = Normalize( Viewport.Actor.ViewRotation );
  if ( zzMyState==1 )
  {
    xxWindowPostRender( C );
  }
  else
  {
    if ( bNoDrawWorld )
    {
      C.SetPos( 0.0, 0.0 );
      C.DrawPattern( Texture'Engine.Border', C.ClipX, C.ClipY, 1.0 );
    }
    if ( bTimeDemo )
    {
      TimeDemoCalc();
      TimeDemoRender( C );
    }
    DrawLevelAction( C );
    if ( ConsoleLines>0 )
    {
      C.SetOrigin( 0.0, float(ConsoleLines)-FrameY*0.6 );
      C.SetPos( 0.0, 0.0 );
      C.DrawTile( ConBackground, FrameX, FrameY*0.6, C.CurX, C.CurY, FrameX, FrameY );
    }
    if ( BorderLines>0 || BorderPixels>0 )
    {
      YStart = BorderLines+ConsoleLines;
      YEnd = int(FrameY-float(BorderLines));
      if ( BorderLines>0 )
      {
        C.SetOrigin( 0.0, 0.0 );
        C.SetPos( 0.0, 0.0 );
        C.DrawPattern( Border, FrameX, float(BorderLines), 1.0 );
        C.SetPos( 0.0, float(YEnd) );
        C.DrawPattern( Border, FrameX, float(BorderLines), 1.0 );
      }
      if ( BorderPixels>0 )
      {
        C.SetOrigin( 0.0, 0.0 );
        C.SetPos( 0.0, float(YStart) );
        C.DrawPattern( Border, float(BorderPixels), float(YEnd-YStart), 1.0 );
        C.SetPos( FrameX-float(BorderPixels), float(YStart) );
        C.DrawPattern( Border, float(BorderPixels), float(YEnd-YStart), 1.0 );
      }
    }
    C.SetOrigin( 0.0, 0.0 );
    if ( ConsoleLines>0 )
    {
      DrawConsoleView( C );
    }
    else
    {
      DrawSingleView( C );
    }
    if ( bShowSpeech || bShowMessage )
    {
      RenderUWindow( C );
    }
  }
  zzbCheckVR = Normalize( Viewport.Actor.ViewRotation )!=zzVR;
  zzMyCheatRI.zzbGlobalVRCheck = zzMyCheatRI.zzbGlobalVRCheck || zzbCheckVR;
  if ( zzbCheckVR )
  {
    zzMyCheatRI.xxLogAimbot( "(PR)" );
  }
  else
  {
    zzMyCheatRI.xxCheckVR( C, 0.01 );
  }
  Viewport.Actor.bDelayedCommand = false;
}

final function xxWindowPostRender (Canvas Canvas)
{
  if ( bTimeDemo )
  {
    TimeDemoCalc();
    TimeDemoRender(Canvas);
  }
  if ( Root != None )
  {
    Root.bUWindowActive = True;
  }
  RenderUWindow(Canvas);
}

event bool KeyType (EInputKey Key)
{
  local Rotator zzVR;

  if ( zzMyState == 0 )
  {
    return False;
  }
  if ( zzMyState == 1 )
  {
    if ( Root == None )
    {
      return False;
    }
    zzVR = Normalize(Viewport.Actor.ViewRotation);
    Root.WindowEvent(8,None,MouseX,MouseY,Key);
    if ( Normalize(Viewport.Actor.ViewRotation) != zzVR )
    {
      if ( zzMyCheatRI != None )
      {
        zzMyCheatRI.xxLogAimbot("(WT)");
      } else {
        Log("KeyType: Invalid VR Detected with CheatRI = None");
        Viewport.Actor.ConsoleCommand("disconnect");
      }
    }
    return True;
  }
  if ( bNoStuff )
  {
    bNoStuff = False;
    return True;
  }
  if ( (Key >= 32) && (Key < 256) && (Key != Asc("~")) && (Key != Asc("`")) )
  {
    TypedStr = TypedStr $ Chr(Key);
    Scrollback = 0;
    return True;
  }
}

event NotifyLevelChange ()
{
  local int i;
  local string kstr;

  xxrevert();
  Log("CSHP Console UnHooked");
  zzOldConsole.NotifyLevelChange();
}

event bool KeyEvent (EInputKey Key, EInputAction Action, float Delta)
{
  local bool zzretval;
  local Rotator zzVR;

  zzVR = Normalize(Viewport.Actor.ViewRotation);
  zzretval = xxKeyEvent(Key,Action,Delta);
  if ( Normalize(Viewport.Actor.ViewRotation) != zzVR )
  {
    if ( zzMyCheatRI != None )
    {
      zzMyCheatRI.xxLogAimbot("(KT)");
    } else {
      Log("KeyEvent: Invalid VR Detected with CheatRI = None");
      Viewport.Actor.ConsoleCommand("disconnect");
    }
  }
  return zzretval;
}

final function bool xxKeyEvent (EInputKey Key, EInputAction Action, float Delta)
{
  local ManagerWindowStub zzManagerMenu;
  local byte zzk;
  local bool zzcustomwin;

  if ( zzMyState != 0 )
  {
    if ( (zzMyState == 1) && (Key != 120) )
    {
      return xxWinKeyEvent(Key,Action,Delta);
    }
    if ( (zzMyState == 2) && (Key == 27) )
    {
      return xxTypingKeyEvent(Key,Action,Delta);
    }
  }
  if ( Action != 1 )
  {
    return False;
  }
  if ( Key == SpeechKey )
  {
    if (  !bShowSpeech &&  !bTyping )
    {
      ShowSpeech();
      bQuickKeyEnable = True;
      LaunchUWindow();
    }
    return True;
  }
  zzk = Key;
  switch (Action)
  {
    case 1:
    switch (zzk)
    {
      case 27:
      if ( bLocked )
      {
        return True;
      }
      bQuickKeyEnable = False;
      LaunchUWindow();
      return True;
      case ConsoleKey:
      if ( bLocked )
      {
        return True;
      }
      bQuickKeyEnable = True;
      LaunchUWindow();
      if (  !bShowConsole )
      {
        ShowConsole();
      }
      return True;
      default:
    }
    break;
    default:
  }
  if ( zzMyState == 2 )
  {
    return xxTypingKeyEvent(Key,Action,Delta);
  }
  return False;
}

final function bool xxWinKeyEvent (EInputKey Key, EInputAction Action, float Delta)
{
  local byte zzk;

  if ( (Action == 3) && (Key == SpeechKey) )
  {
    if ( bShowSpeech )
    {
      HideSpeech();
    }
    return True;
  }
  if ( bShowSpeech && (SpeechWindow != None) )
  {
    if ( SpeechWindow.KeyEvent(Key,Action,Delta) )
    {
      return True;
    }
  }
  zzk = Key;
  switch (Action)
  {
    case 3:
    switch (zzk)
    {
      case 1:
      if ( Root != None )
      {
        Root.WindowEvent(1,None,MouseX,MouseY,zzk);
      }
      break;
      case 2:
      if ( Root != None )
      {
        Root.WindowEvent(5,None,MouseX,MouseY,zzk);
      }
      break;
      case 4:
      if ( Root != None )
      {
        Root.WindowEvent(3,None,MouseX,MouseY,zzk);
      }
      break;
      default:
      if ( Root != None )
      {
        Root.WindowEvent(6,None,MouseX,MouseY,zzk);
      }
      break;
    }
    break;
    case 1:
    switch (zzk)
    {
      case ConsoleKey:
      if ( bShowConsole )
      {
        HideConsole();
        if ( bQuickKeyEnable )
        {
          CloseUWindow();
        }
      } else {
        if ( Root.bAllowConsole )
        {
          ShowConsole();
        } else {
          Root.WindowEvent(7,None,MouseX,MouseY,zzk);
        }
      }
      break;
      case 27:
      if ( Root != None )
      {
        Root.CloseActiveWindow();
      }
      break;
      case 1:
      if ( Root != None )
      {
        Root.WindowEvent(0,None,MouseX,MouseY,zzk);
      }
      break;
      case 2:
      if ( Root != None )
      {
        Root.WindowEvent(4,None,MouseX,MouseY,zzk);
      }
      break;
      case 4:
      if ( Root != None )
      {
        Root.WindowEvent(2,None,MouseX,MouseY,zzk);
      }
      break;
      default:
      if ( Root != None )
      {
        Root.WindowEvent(7,None,MouseX,MouseY,zzk);
      }
      break;
    }
    break;
    case 4:
    switch (Key)
    {
      case 228:
      MouseX = MouseX + MouseScale * Delta;
      break;
      case 229:
      MouseY = MouseY - MouseScale * Delta;
      break;
      default:
    }
    default:
    break;
  }
  return True;
}

function bool xxTypingKeyEvent (EInputKey Key, EInputAction Action, float Delta)
{
  local string temp;

  bNoStuff = false;
  if ( Key==IK_Escape )
  {
    if ( Scrollback!=0 )
    {
      Scrollback = 0;
    }
    else if ( TypedStr!="" )
    {
      TypedStr = "";
    }
    else
    {
      ConsoleDest = 0.0;
      bTyping = false;
      Viewport.Actor.Typing( bTyping );
      zzMyState = 0;
    }
    Scrollback = 0;
  }
  else if ( Key==IK_Enter )
  {
    if ( Scrollback!=0 )
    {
      Scrollback = 0;
    }
    else
    {
      if ( TypedStr!="" )
      {
        if ( ConsoleLines!=0 )
        {
          Message( None, "(>"@TypedStr, 'Console' );
        }
        History[int(float(HistoryCur++)%float(16))] = TypedStr;
        if ( HistoryCur>HistoryBot )
        {
          HistoryBot++;
        }
        if ( HistoryCur-HistoryTop>=16 )
        {
          HistoryTop = HistoryCur-16+1;
        }
        temp = TypedStr;
        TypedStr = "";
        if ( !ConsoleCommand(temp) )
        {
          Message( None, Localize("Errors","Exec","Core"), 'Console' );
        }
        Message( None, "", 'Console' );
      }
      if ( ConsoleDest==0.0 )
      {
        zzMyState = 0;
        bTyping = false;
        Viewport.Actor.Typing( false );
      }
      Scrollback = 0;
    }
  }
  else if ( Key==IK_Up )
  {
    if ( HistoryCur>HistoryTop )
    {
      History[int(float(HistoryCur)%float(16))] = TypedStr;
      TypedStr = History[int(float(--HistoryCur)%float(16))];
    }
    Scrollback = 0;
  }
  else if ( Key==IK_Down )
  {
    History[int(float(HistoryCur)%float(16))] = TypedStr;
    if ( HistoryCur<HistoryBot )
    {
      TypedStr = History[int(float(++HistoryCur)%float(16))];
    }
    else
    {
      TypedStr = "";
    }
    Scrollback = 0;
  }
  else if ( Key==IK_PageUp )
  {
    if ( ++Scrollback>=64 )
    {
      Scrollback = 64-1;
    }
  }
  else if ( Key==IK_PageDown )
  {
    if ( --Scrollback<0 )
    {
      Scrollback = 0;
    }
  }
  else if ( Key==IK_Backspace || Key==IK_Left )
  {
    if ( Len(TypedStr)>0 )
    {
      TypedStr = Left( TypedStr, Len(TypedStr)-1 );
    }
    Scrollback = 0;
  }
  return true;
}

event Tick (float Delta)
{
  local Rotator zzVR;

  zzVR = Normalize(Viewport.Actor.ViewRotation);
  MsgTickTime += Delta;
  if ( ConsolePos < ConsoleDest )
  {
    ConsolePos = FMin(ConsolePos + Delta,ConsoleDest);
  } else {
    if ( ConsolePos > ConsoleDest )
    {
      ConsolePos = FMax(ConsolePos - Delta,ConsoleDest);
    }
  }
  if ( ((MsgTime -= Delta) <= 0.0) && (TextLines > 0) )
  {
    TextLines--;
  }
  if ( bLevelChange && (Root != None) && (string(Viewport.Actor.Level) != OldLevel) )
  {
    OldLevel = string(Viewport.Actor.Level);
    if ( Viewport.Actor.Level != Viewport.Actor.GetEntryLevel() )
    {
      bLevelChange = False;
    }
    Root.NotifyAfterLevelChange();
  }
  if ( (Root != None) && (bShowMessage || (zzMyState == 1)) )
  {
    Root.DoTick(Delta);
    if ( Normalize(Viewport.Actor.ViewRotation) != zzVR )
    {
      if ( zzMyCheatRI != None )
      {
        zzMyCheatRI.xxLogAimbot("(RT)");
      } else {
        Viewport.Actor.ConsoleCommand("disconnect");
      }
    }
  }
  if ( (zzMyState == 1) && (Root != None) && (Viewport.Actor.Song == None) )
  {
    Viewport.Actor.ClientSetMusic(Music(DynamicLoadObject("utmenu23.utmenu23",Class'Music')),0,0,3);
  }
}

final function xxGetValues ()
{
  local int i;

  ConsoleWindow = zzOldConsole.ConsoleWindow;
  Viewport = zzOldConsole.Viewport;
  Root = zzOldConsole.Root;
  Root.Console = self;
  SpeechWindow = zzOldConsole.SpeechWindow;
  MessageWindow = zzOldConsole.MessageWindow;
  bTyping = zzOldConsole.bTyping;
  TypedStr = zzOldConsole.TypedStr;
  bShowSpeech = zzOldConsole.bShowSpeech;
  bCreatedRoot = zzOldConsole.bCreatedRoot;
  bShowConsole = zzOldConsole.bShowConsole;
  MouseX = zzOldConsole.MouseX;
  MouseY = zzOldConsole.MouseY;
  bUWindowType = zzOldConsole.bUWindowType;
  bUWindowActive = zzOldConsole.bUWindowActive;
  bLocked = zzOldConsole.bLocked;
  bQuickKeyEnable = zzOldConsole.bQuickKeyEnable;
  ShowDesktop = zzOldConsole.ShowDesktop;
  bTimeDemo = zzOldConsole.bTimeDemo;
  bSaveTimeDemoToFile = zzOldConsole.bSaveTimeDemoToFile;
  HistoryCur = zzOldConsole.HistoryCur;
  HistoryTop = zzOldConsole.HistoryTop;
  for ( i=0; i<16; i++ )
  {
    History[i] = zzOldConsole.History[i];
  }
  switch (zzOldConsole.GetStateName())
  {
    case 'UWindow':
    zzMyState = 1;
    break;
    case 'Typing':
    zzMyState = 2;
    break;
    default:
    zzMyState = 0;
  }
}

final function xxrevert ()
{
  local int i;

  zzOldConsole.ConsoleWindow = ConsoleWindow;
  zzOldConsole.Root = Root;
  zzOldConsole.Root.Console = zzOldConsole;
  zzOldConsole.SpeechWindow = SpeechWindow;
  zzOldConsole.MessageWindow = MessageWindow;
  zzOldConsole.bTyping = bTyping;
  zzOldConsole.TypedStr = TypedStr;
  zzOldConsole.bShowSpeech = bShowSpeech;
  zzOldConsole.bCreatedRoot = bCreatedRoot;
  zzOldConsole.bShowConsole = bShowConsole;
  zzOldConsole.MouseX = MouseX;
  zzOldConsole.MouseY = MouseY;
  zzOldConsole.bUWindowType = bUWindowType;
  zzOldConsole.bUWindowActive = bUWindowActive;
  zzOldConsole.bLocked = bLocked;
  zzOldConsole.bQuickKeyEnable = bQuickKeyEnable;
  zzOldConsole.ShowDesktop = ShowDesktop;
  zzOldConsole.bTimeDemo = bTimeDemo;
  zzOldConsole.bSaveTimeDemoToFile = bSaveTimeDemoToFile;
  zzOldConsole.HistoryCur = HistoryCur;
  zzOldConsole.HistoryTop = HistoryTop;
  for ( i=0; i<16; i++ )
  {
    zzOldConsole.History[i] = History[i];
  }
  switch (zzMyState)
  {
    case 1:
    zzOldConsole.GotoState('UWindow');
    break;
    case 2:
    zzOldConsole.GotoState('Typing');
    break;
    default:
    zzOldConsole.GotoState('None');
  }
  Viewport.Console = zzOldConsole;
}

exec function Type ()
{
  TypedStr = "";
  if ( zzMyState == 2 )
  {
    zzMyState = 0;
    bTyping = False;
    Viewport.Actor.Typing(bTyping);
    ConsoleDest = 0.0;
    return;
  }
  zzMyState = 2;
  bTyping = True;
  Viewport.Actor.Typing(bTyping);
}

exec function Talk ()
{
  TypedStr = "Say ";
  bNoStuff = True;
  zzMyState = 2;
  bTyping = True;
  Viewport.Actor.Typing(bTyping);
}

exec function TeamTalk ()
{
  TypedStr = "TeamSay ";
  bNoStuff = True;
  zzMyState = 2;
  bTyping = True;
  Viewport.Actor.Typing(bTyping);
}

exec function ViewUp ();

exec function ViewDown ();

function ShowConsole ()
{
  bShowConsole = True;
  if ( bCreatedRoot )
  {
    ConsoleWindow.ShowWindow();
  }
}

function HideConsole ()
{
  ConsoleLines = 0;
  bShowConsole = False;
  if ( ConsoleWindow != None )
  {
    ConsoleWindow.HideWindow();
  }
}

function DrawConsoleView (Canvas C)
{
  local int Y, i, Line;
  local float XL, YL;

  Y = ConsoleLines-1;
  MsgText[int(float(TopLine+1+64)%float(64))] = "(>" @ TypedStr;
  for ( i=Scrollback; i<numLines+1; i++ )
  {
    Line = int(float(TopLine+64*2-(i-1))%float(64));
    C.Font = C.MedFont;
    if ( MsgType[Line]=='Say' || MsgType[Line]=='TeamSay' )
    {
      C.StrLen( MsgPlayer[Line].PlayerName$":"@MsgText[Line], XL, YL );
    }
    else
    {
      C.StrLen( MsgText[Line], XL, YL );
    }
    if ( YL==float(0) )
    {
      YL = 5.0;
    }
    Y -= int(YL);
    if ( float(Y)+YL<float(0) )
    {
      break;
    }
    C.SetPos( 4.0, float(Y) );
    C.Font = C.MedFont;
    if ( MsgType[Line]=='Say' || MsgType[Line]=='TeamSay' )
    {
      C.DrawText( MsgPlayer[Line].PlayerName$":"@MsgText[Line], false );
    }
    else
    {
      C.DrawText( MsgText[Line], false );
    }
  }
}

function DrawSingleView (Canvas C)
{
  local string TypingPrompt;
  local int i, j;
  local float XL, YL;
  local string ShortMessages[4];
  local int ExtraSpace;

  C.SetOrigin( 0.0, 0.0 );
  if ( Viewport.Actor.myHUD!=None && Viewport.Actor.myHUD.DisplayMessages(C) )
  {
    return;
  }
  if ( !Viewport.Actor.bShowMenu )
  {
    if ( bTyping )
    {
      TypingPrompt = "(>" @ TypedStr $ "_";
      C.Font = C.MedFont;
      C.StrLen( TypingPrompt, XL, YL );
      C.SetPos( 2.0, FrameY-float(ConsoleLines)-YL-float(1) );
      C.DrawText( TypingPrompt, false );
    }
  }
  if ( TextLines>0 && (!Viewport.Actor.bShowMenu || Viewport.Actor.bShowScores) )
  {
    j = TopLine;
    i = 0;
    while ( i<4 && j>=0 )
    {
      if ( MsgText[j]!="" && MsgTick[j]>0.0 && MsgTick[j]>MsgTickTime )
      {
        if ( MsgType[j]=='Say' )
        {
          ShortMessages[i] = string(MsgPlayer[j]) $ ":" @ MsgText[j];
        }
        else
        {
          ShortMessages[i] = MsgText[j];
        }
        i++;
      }
      j--;
    }
    j = 0;
    C.Font = C.MedFont;
    for ( i=0; i<4; i++ )
    {
      if ( ShortMessages[3-i]!="" )
      {
        C.SetPos( 4.0, 2.0+float(10*j)+float(10*ExtraSpace) );
        C.StrLen( ShortMessages[3-i], XL, YL );
        C.DrawText( ShortMessages[3-i], false );
        if ( YL==18.0 )
        {
          ExtraSpace++;
        }
        j++;
      }
    }
  }
}

exec function TimeDemo (bool bEnabled, optional bool bSaveToFile)
{
  bSaveTimeDemoToFile = bSaveToFile;
  if ( bEnabled )
  {
    StartTimeDemo();
  } else {
    StopTimeDemo();
  }
}

function TimeDemoRender (Canvas C)
{
  local string AText;
  local string LText;
  local float W;
  local float H;

  if ( TimeDemoFont == None )
  {
    TimeDemoFont = Class'FontInfo'.GetStaticSmallFont(C.ClipX);
  }
  C.Font = TimeDemoFont;
  C.DrawColor.R = 255;
  C.DrawColor.G = 255;
  C.DrawColor.B = 255;
  AText = AvgText @ FormatFloat(FrameCount / (Viewport.Actor.GetEntryLevel().TimeSeconds - StartTime - ExtraTime));
  LText = LastSecText @ FormatFloat(LastSecFPS);
  C.TextSize(AText,W,H);
  C.SetPos(C.ClipX - W,0.31 * C.ClipY);
  C.DrawText(AText);
  C.TextSize(LText,W,H);
  C.SetPos(C.ClipX - W,0.31 * C.ClipY + H);
  C.DrawText(LText);
}

function StartTimeDemo ()
{
  TimeDemoFont = None;
  if ( bTimeDemo )
  {
    return;
  }
  bTimeDemo = True;
  bStartTimeDemo = True;
}

function StopTimeDemo ()
{
  if (  !bTimeDemo )
  {
    return;
  }
  bTimeDemo = False;
  PrintTimeDemoResult();
}

function PrintTimeDemoResult ()
{
  local LevelInfo Entry;
  local float Avg;
  local float Delta;
  local string AvgString;
  local string temp;

  Entry = Viewport.Actor.GetEntryLevel();
  Delta = Entry.TimeSeconds - StartTime - ExtraTime;
  if ( Delta <= 0 )
  {
    Avg = 0.0;
  } else {
    Avg = FrameCount / Delta;
  }
  AvgString = string(FrameCount) @ FramesText @ FormatFloat(Delta) @ SecondsText @ MinText @ FormatFloat(MinFPS) @ MaxText @ FormatFloat(MaxFPS) @ AvgText @ FormatFloat(Avg) @ fpsText $ ".";
  Viewport.Actor.ClientMessage(AvgString);
  Log(AvgString);
  if ( bSaveTimeDemoToFile )
  {
    temp = FormatFloat(Avg) $ " Unreal " $ Viewport.Actor.Level.EngineVersion $ Chr(13) $ Chr(10) $ FormatFloat(MinFPS) $ " Min" $ Chr(13) $ Chr(10) $ FormatFloat(MaxFPS) $ " Max" $ Chr(13) $ Chr(10);
    SaveTimeDemo(temp);
  }
}

function TimeDemoCalc ()
{
  local LevelInfo Entry;
  local float Delta;

  Entry = Viewport.Actor.GetEntryLevel();
  if ( bRestartTimeDemo )
  {
    StopTimeDemo();
    StartTimeDemo();
    bRestartTimeDemo = False;
  }
  if ( bStartTimeDemo )
  {
    bStartTimeDemo = False;
    StartTime = Entry.TimeSeconds;
    ExtraTime = 0.0;
    LastFrameTime = StartTime;
    LastSecondStartTime = StartTime;
    FrameCount = 0;
    LastSecondFrameCount = 0;
    MinFPS = 0.0;
    MaxFPS = 0.0;
    LastSecFPS = 0.0;
    return;
  }
  Delta = Entry.TimeSeconds - LastFrameTime;
  if ( Delta > 0.5 )
  {
    ExtraTime += Delta;
    LastSecondStartTime = Entry.TimeSeconds;
    LastSecondFrameCount = 0;
    LastFrameTime = Entry.TimeSeconds;
    return;
  }
  FrameCount++;
  LastSecondFrameCount++;
  if ( Entry.TimeSeconds - LastSecondStartTime > 1 )
  {
    LastSecFPS = LastSecondFrameCount / (Entry.TimeSeconds - LastSecondStartTime);
    if ( (MinFPS == 0) || (LastSecFPS < MinFPS) )
    {
      MinFPS = LastSecFPS;
    }
    if ( LastSecFPS > MaxFPS )
    {
      MaxFPS = LastSecFPS;
    }
    LastSecondFrameCount = 0;
    LastSecondStartTime = Entry.TimeSeconds;
  }
  LastFrameTime = Entry.TimeSeconds;
}

function LaunchUWindow ()
{
  local int i;

  Viewport.bSuspendPrecaching = True;
  bUWindowActive =  !bQuickKeyEnable;
  Viewport.bShowWindowsMouse = True;
  if ( bQuickKeyEnable )
  {
    bNoDrawWorld = False;
  } else {
    if ( Viewport.Actor.Level.NetMode == 0 )
    {
      Viewport.Actor.SetPause(True);
    }
    bNoDrawWorld = ShowDesktop;
  }
  if ( Root != None )
  {
    Root.bWindowVisible = True;
  }
  if ( zzMyState == 2 )
  {
    bTyping = False;
    Viewport.Actor.Typing(bTyping);
  }
  zzMyState = 1;
}

function CloseUWindow ()
{
  if (  !bQuickKeyEnable )
  {
    Viewport.Actor.SetPause(False);
  }
  bNoDrawWorld = False;
  bQuickKeyEnable = False;
  bUWindowActive = False;
  Viewport.bShowWindowsMouse = False;
  if ( Root != None )
  {
    Root.bWindowVisible = False;
  }
  zzMyState = 0;
  Viewport.bSuspendPrecaching = False;
}

function RenderUWindow( Canvas Canvas )
{
  local UWindowWindow NewFocusWindow;
  local rotator zzVR;

  zzVR = Normalize( Viewport.Actor.ViewRotation );
  Canvas.bNoSmooth = true;
  Canvas.Z = 1.0;
  Canvas.Style = 1;
  Canvas.DrawColor.R = byte(255);
  Canvas.DrawColor.G = byte(255);
  Canvas.DrawColor.B = byte(255);
  if ( Viewport.bWindowsMouseAvailable && Root!=None )
  {
    MouseX = Viewport.WindowsMouseX/Root.GUIScale;
    MouseY = Viewport.WindowsMouseY/Root.GUIScale;
  }
  if ( !bCreatedRoot )
  {
    CreateRootWindow( Canvas );
  }
  Root.bWindowVisible = true;
  Root.bUWindowActive = bUWindowActive;
  Root.bQuickKeyEnable = bQuickKeyEnable;
  if ( Canvas.ClipX!=OldClipX || Canvas.ClipY!=OldClipY )
  {
    OldClipX = Canvas.ClipX;
    OldClipY = Canvas.ClipY;
    Root.WinTop = 0.0;
    Root.WinLeft = 0.0;
    Root.WinWidth = Canvas.ClipX/Root.GUIScale;
    Root.WinHeight = Canvas.ClipY/Root.GUIScale;
    Root.RealWidth = Canvas.ClipX;
    Root.RealHeight = Canvas.ClipY;
    Root.ClippingRegion.X = 0;
    Root.ClippingRegion.Y = 0;
    Root.ClippingRegion.W = int(Root.WinWidth);
    Root.ClippingRegion.H = int(Root.WinHeight);
    Root.Resized();
  }
  if ( MouseX>Root.WinWidth )
  {
    MouseX = Root.WinWidth;
  }
  if ( MouseY>Root.WinHeight )
  {
    MouseY = Root.WinHeight;
  }
  if ( MouseX<float(0) )
  {
    MouseX = 0.0;
  }
  if ( MouseY<float(0) )
  {
    MouseY = 0.0;
  }
  NewFocusWindow = Root.CheckKeyFocusWindow();
  if ( NewFocusWindow!=Root.KeyFocusWindow )
  {
    Root.KeyFocusWindow.KeyFocusExit();
    Root.KeyFocusWindow = NewFocusWindow;
    Root.KeyFocusWindow.KeyFocusEnter();
  }
  Root.MoveMouse( MouseX, MouseY );
  Root.WindowEvent( WM_Paint, Canvas, MouseX, MouseY, 0 );
  if ( bUWindowActive || bQuickKeyEnable )
  {
    Root.DrawMouse( Canvas );
  }
  if ( Normalize(Viewport.Actor.ViewRotation)!=zzVR )
  {
    zzMyCheatRI.xxLogAimbot( "(WR)" );
  }
}

event Message( PlayerReplicationInfo PRI, coerce string Msg, name N )
{
  local string OutText;
  local rotator zzVR;

  zzVR = Normalize( Viewport.Actor.ViewRotation );
  if ( Msg!="" )
  {
    TopLine = int(float(TopLine+1)%float(64));
    numLines = Min( numLines+1, 64-1 );
    MsgType[TopLine] = N;
    MsgTime = 6.0;
    TextLines++;
    MsgText[TopLine] = Msg;
    MsgPlayer[TopLine] = PRI;
    MsgTick[TopLine] = MsgTickTime+MsgTime;
  }
  if ( Viewport.Actor==None )
  {
    return;
  }
  if ( Msg!="" )
  {
    if ( MsgType[TopLine]=='Say' || MsgType[TopLine]=='TeamSay' )
    {
      OutText = MsgPlayer[TopLine].PlayerName $ ": " $ MsgText[TopLine];
    }
    else
    {
      OutText = MsgText[TopLine];
    }
    if ( ConsoleWindow!=None )
    {
      UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText( OutText );
    }
  }
  if ( Normalize(Viewport.Actor.ViewRotation)!=zzVR )
  {
    zzMyCheatRI.xxLogAimbot( "(CW)" );
  }
}

event AddString( coerce string Msg )
{
  local rotator zzVR;

  zzVR = Normalize( Viewport.Actor.ViewRotation );
  if ( Msg!="" )
  {
    TopLine = int(float(TopLine+1)%float(64));
    numLines = Min( numLines+1, 64-1 );
    MsgType[TopLine] = 'Event';
    MsgTime = 6.0;
    TextLines++;
    MsgText[TopLine] = Msg;
    MsgPlayer[TopLine] = None;
    MsgTick[TopLine] = MsgTickTime+MsgTime;
    if ( ConsoleWindow!=None )
    {
      UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText( Msg );
    }
  }
  if ( Normalize(Viewport.Actor.ViewRotation)!=zzVR )
  {
    zzMyCheatRI.xxLogAimbot( "(CW)" );
  }
}

function UpdateHistory()
{
  History[int(float(HistoryCur++)%float(16))] = TypedStr;
  if ( HistoryCur>HistoryBot )
  {
    HistoryBot++;
  }
  if ( HistoryCur-HistoryTop>=16 )
  {
    HistoryTop = HistoryCur-16+1;
  }
}

function HistoryUp()
{
  if ( HistoryCur>HistoryTop )
  {
    History[int(float(HistoryCur)%float(16))] = TypedStr;
    TypedStr = History[int(float(--HistoryCur)%float(16))];
  }
}

function HistoryDown()
{
  History[int(float(HistoryCur)%float(16))] = TypedStr;
  if ( HistoryCur<HistoryBot )
  {
    TypedStr = History[int(float(++HistoryCur)%float(16))];
  }
  else
  {
    TypedStr = "";
  }
}

exec function MenuCmd (int Menu, int Item)
{
  local Rotator zzVR;

  if ( bLocked || (zzMyState != 0) )
  {
    return;
  }
  zzVR = Normalize(Viewport.Actor.ViewRotation);
  bQuickKeyEnable = False;
  LaunchUWindow();
  if (  !bCreatedRoot )
  {
    CreateRootWindow(None);
  }
  UMenuRootWindow(Root).MenuBar.MenuCmd(Menu,Item);
  if ( Normalize(Viewport.Actor.ViewRotation) != zzVR )
  {
    if ( zzMyCheatRI != None )
    {
      zzMyCheatRI.xxLogAimbot("(MC)");
    } else {
      Log("MenuCmd ... zzMyCheatRI == None");
      Viewport.Actor.ConsoleCommand("disconnect");
    }
  }
}

exec function ShowObjectives ()
{
  local rotator zzVR;
  local GameReplicationInfo GRI;
  local Class<GameInfo> AssaultClass, GameClass;

  zzVR = Normalize( Viewport.Actor.ViewRotation );
  if ( !bCreatedRoot )
  {
    CreateRootWindow( None );
  }
  AssaultClass = Class<GameInfo>(DynamicLoadObject("Botpack.Assault",Class'Class'));
  foreach Viewport.Actor.AllActors( Class'GameReplicationInfo', GRI )
  {
    GameClass = Class<GameInfo>(DynamicLoadObject(GRI.GameClass,Class'Class'));
    if ( ClassIsChildOf(GameClass,AssaultClass) )
    {
      bLocked = true;
      bNoDrawWorld = true;
      UMenuRootWindow(Root).MenuBar.HideWindow();
      LaunchUWindow();
      Root.CreateWindow( Class<UWindowWindow>(DynamicLoadObject("UTMenu.InGameObjectives",Class'Class')), 100.0, 100.0, 100.0, 100.0 );
      Viewport.Actor.ViewRotation = zzVR;
    }
  }
  if ( Normalize(Viewport.Actor.ViewRotation)!=zzVR )
  {
    if ( zzMyCheatRI!=None )
    {
      zzMyCheatRI.xxLogAimbot( "(SO)" );
    }
    else
    {
      Log( "Console.Tick ... zzMyCheatRI == None" );
      Viewport.Actor.ConsoleCommand( "disconnect" );
    }
  }
}

function DrawLevelAction (Canvas C)
{
  local string BigMessage;

  if ( Viewport.Actor.Level.Pauser!="" && int(Viewport.Actor.Level.LevelAction)==int(ELevelAction.LEVACT_None) )
  {
    C.Font = C.MedFont;
    BigMessage = PausedMessage;
    PrintActionMessage( C, BigMessage );
    return;
  }
  if ( int(Viewport.Actor.Level.LevelAction)==int(ELevelAction.LEVACT_None) || Viewport.Actor.bShowMenu )
  {
    BigMessage = "";
    return;
  }
  else if ( int(Viewport.Actor.Level.LevelAction)==int(ELevelAction.LEVACT_Loading) )
  {
    BigMessage = LoadingMessage;
  }
  else if ( int(Viewport.Actor.Level.LevelAction)==int(ELevelAction.LEVACT_Saving) )
  {
    BigMessage = SavingMessage;
  }
  else if ( int(Viewport.Actor.Level.LevelAction)==int(ELevelAction.LEVACT_Connecting) )
  {
    BigMessage = ConnectingMessage;
  }
  else if ( int(Viewport.Actor.Level.LevelAction)==int(ELevelAction.LEVACT_Precaching) )
  {
    BigMessage = PrecachingMessage;
  }
  if ( BigMessage!="" )
  {
    C.Style = 1;
    C.Font = C.LargeFont;
    PrintActionMessage( C, BigMessage );
  }
}

exec function CheatKick ()
{
  Viewport.Actor.Mutate("CheatKick");
}

exec function CheatShow ()
{
  Viewport.Actor.Mutate("CheatShow");
}

exec function CheatInfo ()
{
  Viewport.Actor.Mutate("CheatInfo");
}

exec function CheatTest ()
{
  Viewport.Actor.Mutate("CheatTest");
}

exec function FixTeams ()
{
  Viewport.Actor.Mutate("FixTeams");
}

exec function NextTeam ()
{
  Viewport.Actor.Mutate("NextTeam");
}

exec function ChangeTeam (string NewTeam)
{
  Viewport.Actor.Mutate("ChangeTeam " $ NewTeam);
}

