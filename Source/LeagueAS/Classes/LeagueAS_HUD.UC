//================================================================================
// LeagueAS_HUD.
//================================================================================

class LeagueAS_HUD extends AssaultHUD
  Config(User);

var ClientOptions MyClientOptions;
var LeagueAS_GameReplicationInfo LeagueASGameReplicationInfo;

function float DistanceFrom (Pawn P1, Pawn P2)
{
  local float DistanceX;
  local float DistanceY;
  local float ADistance;

  if ( (P1 == None) || (P2 == None) )
  {
    return -469762048.0;
  }
  if ( (P1.Location.X == 0) && (P1.Location.Y == 0) || (P2.Location.X == 0) && (P2.Location.Y == 0) )
  {
    return -1.0;
  } else {
    DistanceX = P1.Location.X - P2.Location.X;
    DistanceY = P1.Location.Y - P2.Location.Y;
    ADistance = Sqrt(Square(DistanceX) + Square(DistanceY));
    return ADistance;
  }
}

function PostRender (Canvas Canvas)
{
  local int i, j, Y, StartTop, ownerTeam, minsleft, secsleft, SelectedTime;
  local float FontHeight, StartRight;
  local Font CanvasFont;
  local PlayerReplicationInfo PRI;
  local LeagueAS_ExtPlayerReplicationInfo ePRI;
  local string OwnerName, TeamSizes, SelectedTimeString;
  local ClientOptions CO;

  Super.PostRender( Canvas );
  if ( MyClientOptions==None )
  {
    foreach AllActors( Class'ClientOptions', CO )
    {
      if ( CO.Owner==Owner )
      {
        MyClientOptions = CO;
      }
    }
    if ( MyClientOptions==None )
    {
      Log( "Cannot locate clients options, prepare for lots of errors!", 'LeagueAssault' );
    }
  }
  if ( !PlayerPawn(Owner).bShowScores && MyClientOptions.bExtHudEnabled )
  {
    if ( PlayerPawn(Owner)==None )
    {
      return;
    }
    if ( LeagueAS_GameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo)==None )
    {
      return;
    }
    if ( PlayerPawn(Owner).PlayerReplicationInfo==None )
    {
      return;
    }
    LeagueASGameReplicationInfo = LeagueAS_GameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
    ownerTeam = int(PlayerPawn(Owner).PlayerReplicationInfo.Team);
    OwnerName = PlayerPawn(Owner).PlayerReplicationInfo.PlayerName;
    StartTop = Canvas.SizeY/3;
    if ( MyClientOptions.bExtHudLargeFont )
    {
      Canvas.Font = Font'Engine.MedFont';
    }
    else
    {
      Canvas.Font = Font'Engine.SmallFont';
    }
    Canvas.StrLen( "1", StartRight, FontHeight );
    Canvas.DrawColor = GoldColor;
    Y = StartTop;
    if ( MyClientOptions.bExtHudShowGameInfo )
    {
      if ( LeagueASGameReplicationInfo.bMatchModeEnabled )
      {
        Canvas.SetPos( 5.0, float(Y) );
        Canvas.DrawText( "Score:"@LeagueASGameReplicationInfo.MatchScore );
        Y = int(float(Y)+FontHeight+float(14));
      }
      else
      {
        Canvas.SetPos( 5.0, float(Y) );
        if ( ownerTeam==0 )
        {
          TeamSizes = string(LeagueASGameReplicationInfo.Teams[0].Size) @ "v" @ string(LeagueASGameReplicationInfo.Teams[1].Size);
        }
        else
        {
          TeamSizes = string(LeagueASGameReplicationInfo.Teams[1].Size) @ "v" @ string(LeagueASGameReplicationInfo.Teams[0].Size);
        }
        Canvas.DrawText( "Team Sizes:"@TeamSizes );
        Y = int(float(Y)+FontHeight+float(14));
      }
    }
    if ( MyClientOptions.bExtHudShowConnInfo )
    {
      Canvas.SetPos( 5.0, float(Y) );
      Canvas.DrawText( "Ping:"@string(PlayerPawn(Owner).PlayerReplicationInfo.Ping)@"  P/L:"@string(PlayerPawn(Owner).PlayerReplicationInfo.PacketLoss)$"%" );
      Y = int(float(Y)+FontHeight+float(14));
    }
    if ( MyClientOptions.bExtHudShowTime )
    {
      Canvas.SetPos( 5.0, float(Y) );
      if ( LeagueASGameReplicationInfo.StartTimeRemaining==-1 )
      {
        if ( MyClientOptions.bExtHudShowElapsedTime )
        {
          SelectedTime = LeagueASGameReplicationInfo.ElapsedTime;
          SelectedTimeString = "Elapsed Time";
        }
        else
        {
          SelectedTime = LeagueASGameReplicationInfo.RemainingTime;
          SelectedTimeString = "Remaining Time";
        }
      }
      else
      {
        SelectedTime = LeagueASGameReplicationInfo.StartTimeRemaining;
        SelectedTimeString = "Time until Game Start";
      }
      minsleft = SelectedTime/60;
      secsleft = SelectedTime-SelectedTime/60*60;
      if ( secsleft<10 )
      {
        Canvas.DrawText( SelectedTimeString$":"@string(minsleft)$":0"$string(secsleft) );
      }
      else
      {
        Canvas.DrawText( SelectedTimeString$":"@string(minsleft)$":"$string(secsleft) );
      }
      Y = int(float(Y)+FontHeight+float(14));
    }
    if ( MyClientOptions.bExtHudShowTeamInfo )
    {
      Canvas.SetPos( 5.0, float(Y) );
      Canvas.DrawText( "Team:" );
      Y = int(float(Y)+FontHeight+float(11));
      for ( i=0; i<32; i++ )
      {
        if ( LeagueASGameReplicationInfo.ePRIArray[i]!=None )
        {
          ePRI = LeagueASGameReplicationInfo.ePRIArray[i];
          if ( ePRI.PlayerName!=PlayerOwner.PlayerReplicationInfo.PlayerName && ePRI.Team==int(PlayerOwner.PlayerReplicationInfo.Team) )
          {
            Canvas.DrawColor = GoldColor;
            Canvas.SetPos( 5.0, float(Y) );
            Canvas.DrawText( ePRI.PlayerName );
            Y = int(float(Y)+FontHeight+float(2));
            Canvas.SetPos( 5.0, float(Y) );
            if ( DistanceFrom(Pawn(ePRI.Owner),Pawn(Owner))<float(1000) )
            {
              Canvas.DrawColor = GreenColor;
            }
            else
            {
              Canvas.DrawColor = WhiteColor;
            }
            Canvas.DrawText( "Location:"@ePRI.Location );
            Y = int(float(Y)+FontHeight+float(2));
            Canvas.SetPos( 5.0, float(Y) );
            if ( ePRI.Health<25 )
            {
              Canvas.DrawColor = RedColor;
            }
            else
            {
              Canvas.DrawColor = WhiteColor;
            }
            Canvas.DrawText( "Health:"@string(ePRI.Health) );
            Y = int(float(Y)+FontHeight+float(2));
            Canvas.SetPos( 5.0, float(Y) );
            Canvas.DrawColor = WhiteColor;
            Canvas.DrawText( "Armour:"@string(ePRI.Armour) );
            Y = int(float(Y)+FontHeight+float(2));
            Canvas.DrawColor = WhiteColor;
            Canvas.SetPos( 5.0, float(Y) );
            Canvas.DrawText( "Weapon:"@ePRI.WeaponName@"("$string(ePRI.AmmoAmount)$")" );
            Y = int(float(Y)+FontHeight+float(6));
          }
        }
      }
    }
    if ( MyClientOptions.bExtHudShowObjInfo )
    {
      Canvas.DrawColor = GoldColor;
      Canvas.StrLen( "Objective Listing:", StartRight, FontHeight );
      Canvas.SetPos( float(Canvas.SizeX)-StartRight-float(5), float(StartTop) );
      Canvas.DrawText( "Objective Listing:" );
      Y = int(float(StartTop)+FontHeight+float(11));
      for ( i=0; i<20; i++ )
      {
        if ( LeagueASGameReplicationInfo.FortName[i]!="" )
        {
          Canvas.DrawColor = GoldColor;
          Canvas.StrLen( LeagueASGameReplicationInfo.FortName[i], StartRight, FontHeight );
          Canvas.SetPos( float(Canvas.SizeX)-StartRight-float(5), float(Y) );
          Canvas.DrawText( LeagueASGameReplicationInfo.FortName[i] );
          Y = int(float(Y)+FontHeight+float(2));
          if ( LeagueASGameReplicationInfo.FortCompleted[i]=="Not Complete!" )
          {
            Canvas.DrawColor = RedColor;
          }
          else
          {
            Canvas.DrawColor = GreenColor;
          }
          Canvas.StrLen( LeagueASGameReplicationInfo.FortCompleted[i], StartRight, FontHeight );
          Canvas.SetPos( float(Canvas.SizeX)-StartRight-float(5), float(Y) );
          Canvas.DrawText( LeagueASGameReplicationInfo.FortCompleted[i] );
          Y = int(float(Y)+FontHeight+float(6));
        }
      }
    }
  }
}

exec function ToggleExtendedHUD ()
{
  MyClientOptions.bExtHudEnabled =  !MyClientOptions.bExtHudEnabled;
  MyClientOptions.SaveConfig();
}

function DrawStatus (Canvas Canvas)
{
  local float StatScale, ChestAmount, ThighAmount, H1, H2, X, Y, DamageTime;
  local int ArmorAmount, CurAbs, i;
  local Inventory Inv, BestArmor;
  local bool bChestArmor, bShieldbelt, bThighArmor, bJumpBoots, bHasDoll;
  local Bot BotOwner;
  local TournamentPlayer TPOwner;
  local Texture Doll, DollBelt;

  ArmorAmount = 0;
  CurAbs = 0;
  i = 0;
  BestArmor = None;
  for ( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
  {
    if ( Inv.bIsAnArmor )
    {
      if ( Inv.IsA('UT_ShieldBelt') )
      {
        bShieldbelt = true;
      }
      else if ( Inv.IsA('ThighPads') )
      {
        ThighAmount += float(Inv.Charge);
        bThighArmor = true;
      }
      else
      {
        bChestArmor = true;
        ChestAmount += float(Inv.Charge);
      }
      ArmorAmount += Inv.Charge;
    }
    else if ( Inv.IsA('UT_Jumpboots') )
    {
      bJumpBoots = true;
    }
    else
    {
      i++;
      if ( i>100 )
      {
        break;
      }
    }
  }
  if ( !bHideStatus )
  {
    TPOwner = TournamentPlayer(PawnOwner);
    if ( Canvas.ClipX<float(400) )
    {
      bHasDoll = false;
    }
    else if ( TPOwner!=None )
    {
      Doll = TPOwner.StatusDoll;
      DollBelt = TPOwner.StatusBelt;
      bHasDoll = true;
    }
    else
    {
      BotOwner = Bot(PawnOwner);
      if ( BotOwner!=None )
      {
        Doll = BotOwner.StatusDoll;
        DollBelt = BotOwner.StatusBelt;
        bHasDoll = true;
      }
    }
    if ( bHasDoll )
    {
      Canvas.Style = 3;
      StatScale = Scale*StatusScale;
      X = Canvas.ClipX-float(128)*StatScale;
      Canvas.SetPos( X, 0.0 );
      if ( PawnOwner.DamageScaling>2.0 )
      {
        Canvas.DrawColor = PurpleColor;
      }
      else
      {
        Canvas.DrawColor = HUDColor;
      }
      Canvas.DrawTile( Doll, 128.0*StatScale, 256.0*StatScale, 0.0, 0.0, 128.0, 256.0 );
      Canvas.DrawColor = HUDColor;
      if ( bShieldbelt )
      {
        Canvas.DrawColor = BaseColor;
        Canvas.DrawColor.B = 0;
        Canvas.SetPos( X, 0.0 );
        Canvas.DrawIcon( DollBelt, StatScale );
      }
      if ( bChestArmor )
      {
        ChestAmount = FMin( 0.01*ChestAmount, 1.0 );
        Canvas.DrawColor = HUDColor*ChestAmount;
        Canvas.SetPos( X, 0.0 );
        Canvas.DrawTile( Doll, 128.0*StatScale, 64.0*StatScale, 128.0, 0.0, 128.0, 64.0 );
      }
      if ( bThighArmor )
      {
        ThighAmount = FMin( 0.02*ThighAmount, 1.0 );
        Canvas.DrawColor = HUDColor*ThighAmount;
        Canvas.SetPos( X, 64.0*StatScale );
        Canvas.DrawTile( Doll, 128.0*StatScale, 64.0*StatScale, 128.0, 64.0, 128.0, 64.0 );
      }
      if ( bJumpBoots )
      {
        Canvas.DrawColor = HUDColor;
        Canvas.SetPos( X, 128.0*StatScale );
        Canvas.DrawTile( Doll, 128.0*StatScale, 64.0*StatScale, 128.0, 128.0, 128.0, 64.0 );
      }
      Canvas.Style = Style;
      if ( PawnOwner==PlayerOwner && Level.bHighDetailMode && !Level.bDropDetail )
      {
        for ( i=0; i<4; i++ )
        {
          DamageTime = Level.TimeSeconds-HitTime[i];
          if ( DamageTime<float(1) )
          {
            Canvas.SetPos( X+HitPos[i].X*StatScale, HitPos[i].Y*StatScale );
            if ( int(HUDColor.G)>100 || int(HUDColor.B)>100 )
            {
              Canvas.DrawColor = RedColor;
            }
            else
            {
              Canvas.DrawColor = (WhiteColor-HUDColor)*FMin( 1.0, 2.0*DamageTime );
            }
            Canvas.DrawColor.R = byte(float(255)*FMin(1.0,2.0*DamageTime));
            Canvas.DrawTile( Texture'Botpack.Icons.HudElements1', StatScale*hitdamage[i]*float(25), StatScale*hitdamage[i]*float(64), 0.0, 64.0, 25.0, 64.0 );
          }
        }
      }
    }
  }
  Canvas.DrawColor = HUDColor;
  if ( bHideStatus && bHideAllWeapons )
  {
    X = 0.5*Canvas.ClipX;
    Y = Canvas.ClipY-float(64)*Scale;
  }
  else
  {
    X = Canvas.ClipX-float(128)*StatScale-float(140)*Scale;
    Y = 64.0*Scale;
  }
  Canvas.SetPos( X, Y );
  if ( PawnOwner.Health<50 )
  {
    H1 = 1.5*TutIconBlink;
    H2 = 1.0-H1;
    Canvas.DrawColor = WhiteColor*H2+(HUDColor-WhiteColor)*H1;
  }
  else
  {
    Canvas.DrawColor = HUDColor;
  }
  Canvas.DrawTile( Texture'Botpack.Icons.HudElements1', 128.0*Scale, 64.0*Scale, 128.0, 128.0, 128.0, 64.0 );
  if ( PawnOwner.Health<50 )
  {
    H1 = 1.5*TutIconBlink;
    H2 = 1.0-H1;
    Canvas.DrawColor = Canvas.DrawColor*H2+(WhiteColor-Canvas.DrawColor)*H1;
  }
  else if ( int(PawnOwner.Style)==int(ERenderStyle.STY_Translucent) )
  {
    H1 = 1.5*TutIconBlink;
    H2 = 1.0-H1;
    Canvas.DrawColor = Canvas.DrawColor*H2+(GoldColor-Canvas.DrawColor)*H1;
  }
  else
  {
    Canvas.DrawColor = WhiteColor;
  }
  DrawBigNum( Canvas, Max(0,PawnOwner.Health), int(X+float(4)*Scale), int(Y+float(16)*Scale), 1.0 );
  Canvas.DrawColor = HUDColor;
  if ( bHideStatus && bHideAllWeapons )
  {
    X = 0.5*Canvas.ClipX-float(128)*Scale;
    Y = Canvas.ClipY-float(64)*Scale;
  }
  else
  {
    X = Canvas.ClipX-float(128)*StatScale-float(140)*Scale;
    Y = 0.0;
  }
  Canvas.SetPos( X, Y );
  Canvas.DrawTile( Texture'Botpack.Icons.HudElements1', 128.0*Scale, 64.0*Scale, 0.0, 192.0, 128.0, 64.0 );
  if ( bHideStatus && bShieldbelt )
  {
    Canvas.DrawColor = GoldColor;
  }
  else
  {
    Canvas.DrawColor = WhiteColor;
  }
  DrawBigNum( Canvas, Min(150,ArmorAmount), int(X+float(4)*Scale), int(Y+float(16)*Scale), 1.0 );
}

defaultproperties
{
    bAlwaysTick=True
}
