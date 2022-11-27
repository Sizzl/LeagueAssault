//================================================================================
// LeagueAS_Scoreboard.
//================================================================================

class LeagueAS_Scoreboard extends AssaultScoreboard;

function string PadOut( string InText )
{
  local string Text;

  Text = InText;
  while ( Len(Text)<4 )
  {
    Text = " " $ Text;
  }
  return Text;
}

function ShowScores( Canvas Canvas )
{
  local PlayerReplicationInfo PRI;
  local int PlayerCount, i;
  local float LoopCountTeam[4];
  local float XL, YL, YB, XOffset, YOffset, XStart, Y, StartTop;
  local int PlayerCounts[4];
  local int LongLists[4];
  local int BottomSlot[4];
  local Font CanvasFont;
  local bool bCompressed, Left;
  local float R;
  local int TeamPings[4];
  local int TeamPLs[4];

  OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
  OwnerGame = LeagueAS_GameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
  Canvas.Style = 1;
  CanvasFont = Canvas.Font;
  for ( i=0; i<4; i++ )
  {
    TeamName[i] = OwnerGame.Teams[i].TeamName;
  }
  DrawHeader( Canvas );
  for ( i=0; i<32; i++ )
  {
    Ordered[i] = None;
  }
  for ( i=0; i<32; i++ )
  {
    if ( PlayerPawn(Owner).GameReplicationInfo.PRIArray[i]!=None )
    {
      PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
      if ( !PRI.bIsSpectator || PRI.bWaitingPlayer || int(PRI.Team)!=255 )
      {
        Ordered[PlayerCount] = PRI;
        PlayerCount++;
        PlayerCounts[int(PRI.Team)]++;
      }
    }
  }
  SortScores( PlayerCount );
  Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
  Canvas.StrLen( "TEXT", XL, YL );
  ScoreStart = Canvas.CurY+YL*float(2);
  if ( ScoreStart+float(PlayerCount)*YL+float(2)>Canvas.ClipY )
  {
    bCompressed = true;
    CanvasFont = Canvas.Font;
    Canvas.Font = Font'Engine.SmallFont';
    R = YL;
    Canvas.StrLen( "TEXT", XL, YL );
    R = YL/R;
    Canvas.Font = CanvasFont;
  }
  for ( i=0; i<PlayerCount; i++ )
  {
    if ( int(Ordered[i].Team)<4 )
    {
      if ( float(Ordered[i].Team)%float(2)==float(0) )
      {
        XOffset = Canvas.ClipX/float(4)-Canvas.ClipX/float(8);
      }
      else
      {
        XOffset = Canvas.ClipX/float(4)*float(3)-Canvas.ClipX/float(8);
      }
      Canvas.StrLen( "TEXT", XL, YL );
      Canvas.DrawColor = AltTeamColor[int(Ordered[i].Team)];
      YOffset = ScoreStart+LoopCountTeam[int(Ordered[i].Team)]*(YL-float(8))+float(2);
      if ( int(Ordered[i].Team)<2 && BottomSlot[int(Ordered[i].Team)]==0 && PlayerCounts[int(Ordered[i].Team)+2]==0 )
      {
        LongLists[int(Ordered[i].Team)] = 1;
        DrawNameAndPing( Canvas, Ordered[i], XOffset, YOffset, bCompressed );
        TeamPings[int(Ordered[i].Team)] += Ordered[i].Ping;
        TeamPLs[int(Ordered[i].Team)] += int(Ordered[i].PacketLoss);
      }
      else if ( LoopCountTeam[int(Ordered[i].Team)]<float(8) )
      {
        DrawNameAndPing( Canvas, Ordered[i], XOffset, YOffset, bCompressed );
        TeamPings[int(Ordered[i].Team)] += Ordered[i].Ping;
        TeamPLs[int(Ordered[i].Team)] += int(Ordered[i].PacketLoss);
      }
      if ( bCompressed )
      {
        LoopCountTeam[int(Ordered[i].Team)] += float(1);
      }
      else
      {
        LoopCountTeam[int(Ordered[i].Team)] += float(2);
      }
    }
  }
  for ( i=0; i<4; i++ )
  {
    Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
    if ( PlayerCounts[i]>0 )
    {
      if ( float(i)%float(2)==float(0) )
      {
        XOffset = Canvas.ClipX/float(4)-Canvas.ClipX/float(8);
      }
      else
      {
        XOffset = Canvas.ClipX/float(4)*float(3)-Canvas.ClipX/float(8);
      }
      YOffset = ScoreStart-YL+float(2);
      if ( i>1 )
      {
        if ( PlayerCounts[i-2]>0 )
        {
          YOffset = ScoreStart+YL*float(10);
        }
      }
      Canvas.DrawColor = TeamColor[i];
      Canvas.SetPos( XOffset, YOffset );
      Canvas.StrLen( TeamName[i], XL, YL );
      Canvas.DrawText( TeamName[i], false );
      Canvas.Font = Font'Engine.SmallFont';
      Canvas.DrawColor = WhiteColor;
      Canvas.StrLen( "Ping:0000", XL, YB );
      Canvas.SetPos( XOffset+Canvas.ClipX/float(4)-XL, YOffset );
      Canvas.DrawText( "Ping:"$PadOut(string(TeamPings[i]/PlayerCounts[i])), false );
      Canvas.SetPos( XOffset+Canvas.ClipX/float(4)-XL, YOffset+float(8) );
      Canvas.DrawText( "P/L:"$PadOut(string(TeamPLs[i]/PlayerCounts[i]))$"%", false );
    }
  }
  if ( Canvas.ClipX>float(512) )
  {
    StartTop = Canvas.ClipY/float(5)*float(3);
    Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
    Canvas.DrawColor = GoldColor;
    Canvas.StrLen( "Objectives", XL, YL );
    Canvas.SetPos( (Canvas.ClipX-XL)/float(2), StartTop );
    Canvas.DrawText( "Objectives" );
    Y = StartTop+YL+float(6);
    Left = true;
    Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
    for ( i=0; i<20; i++ )
    {
      if ( LeagueAS_GameReplicationInfo(OwnerGame).FortName[i]!="" )
      {
        Canvas.StrLen( LeagueAS_GameReplicationInfo(OwnerGame).FortName[i], XL, YL );
        if ( Left )
        {
          Canvas.SetPos( (Canvas.ClipX/float(2)-XL)/float(2), Y );
        }
        else
        {
          Canvas.SetPos( (Canvas.ClipX/float(2)-XL)/float(2)+Canvas.ClipX/float(2), Y );
        }
        Canvas.DrawColor = GoldColor;
        Canvas.DrawText( LeagueAS_GameReplicationInfo(OwnerGame).FortName[i] );
        Y = Y+YL;
        Canvas.StrLen( LeagueAS_GameReplicationInfo(OwnerGame).FortCompleted[i], XL, YL );
        if ( Left )
        {
          Canvas.SetPos( (Canvas.ClipX/float(2)-XL)/float(2), Y );
        }
        else
        {
          Canvas.SetPos( (Canvas.ClipX/float(2)-XL)/float(2)+Canvas.ClipX/float(2), Y );
        }
        if ( LeagueAS_GameReplicationInfo(OwnerGame).FortCompleted[i]=="Not Complete!" )
        {
          Canvas.DrawColor = RedColor;
        }
        else
        {
          Canvas.DrawColor = GreenColor;
        }
        Canvas.DrawText( LeagueAS_GameReplicationInfo(OwnerGame).FortCompleted[i] );
        if ( Left )
        {
          Y = Y-YL;
        }
        else
        {
          Y = Y+YL+float(1);
        }
        Left = !Left;
      }
    }
  }
  if ( !Level.bLowRes )
  {
    Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
    DrawTrailer( Canvas );
  }
  Canvas.Font = CanvasFont;
  Canvas.DrawColor = WhiteColor;
  AssaultHUD(OwnerHUD).DrawTimeAt( Canvas, 0.5*Canvas.ClipX-float(80)*Canvas.ClipX/float(1280), 4.0 );
}

function DrawNameAndPing( Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed )
{
  local float XL, YL, YB;
  local BotReplicationInfo BRI;
  local string S, o, L;
  local Font CanvasFont;
  local bool bAdminPlayer, bModeratorPlayer;
  local PlayerPawn PlayerOwner;
  local int Time, i;
  local LeagueAS_ExtPlayerReplicationInfo ePRI;

  PlayerOwner = PlayerPawn(Owner);
  for ( i=0; i<32; i++ )
  {
    if ( LeagueAS_GameReplicationInfo(OwnerGame).ePRIArray[i]!=None && LeagueAS_GameReplicationInfo(OwnerGame).ePRIArray[i].PlayerName==PRI.PlayerName )
    {
      ePRI = LeagueAS_GameReplicationInfo(OwnerGame).ePRIArray[i];
      break;
    }
  }
  bAdminPlayer = PRI.bAdmin;
  bModeratorPlayer = ePRI.bModerator;
  if ( PRI.PlayerName==PlayerOwner.PlayerReplicationInfo.PlayerName )
  {
    Canvas.DrawColor = GoldColor;
  }
  if ( bModeratorPlayer )
  {
    Canvas.DrawColor = GreenColor;
  }
  if ( bAdminPlayer )
  {
    Canvas.DrawColor = WhiteColor;
  }
  Canvas.SetPos( XOffset, YOffset );
  if ( ePRI.bReadyToPlay )
  {
    Canvas.DrawText( "*"$PRI.PlayerName, false );
  }
  else
  {
    Canvas.DrawText( PRI.PlayerName, false );
  }
  Canvas.StrLen( PRI.PlayerName, XL, YB );
  if ( Canvas.ClipX>float(512) )
  {
    CanvasFont = Canvas.Font;
    Canvas.Font = Font'Engine.SmallFont';
    Canvas.DrawColor = WhiteColor;
    if ( int(Level.NetMode)!=int(ENetMode.NM_Standalone) )
    {
      Canvas.StrLen( PingString$":     ", XL, YL );
      Canvas.SetPos( XOffset-XL-float(6), YOffset );
      Canvas.DrawText( PingString$":"@string(PRI.Ping), false );
      Canvas.StrLen( LossString$":    %", XL, YL );
      Canvas.SetPos( XOffset-XL-float(6), YOffset+(YL+float(1)) );
      Canvas.DrawText( LossString$":"@string(PRI.PacketLoss)$"%", false );
      if ( !bCompressed && Canvas.ClipX>float(640) )
      {
        if ( ePRI!=None && (ePRI.bMuteSay || ePRI.bMuteAll) )
        {
          Canvas.DrawColor = RedColor;
          Canvas.StrLen( "          ", XL, YL );
          Canvas.SetPos( XOffset-XL-float(6), YOffset+(YL+float(1))*float(2) );
          if ( ePRI.bMuteAll )
          {
            Canvas.DrawText( "MUTE ALL", false );
          }
          else
          {
            Canvas.DrawText( "MUTE ENEMY", false );
          }
          Canvas.DrawColor = WhiteColor;
        }
      }
    }
    Canvas.Font = CanvasFont;
  }
  if ( PRI.PlayerName==PlayerOwner.PlayerReplicationInfo.PlayerName )
  {
    Canvas.DrawColor = GoldColor;
  }
  else
  {
    Canvas.DrawColor = TeamColor[int(PRI.Team)];
  }
  DrawScore( Canvas, PRI.Score, XOffset, YOffset );
  if ( Canvas.ClipX<float(512) )
  {
    return;
  }
}

