//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_Scoreboard extends AssaultScoreBoard;

//************************************************************************************************
function string PadOut(string InText)
{
	local string Text;

	Text = InText;

	While (len(Text) < 4)
		Text = " "$Text;

	Return Text;

}
//************************************************************************************************
function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int PlayerCount, i;
	local float LoopCountTeam[4];
	local float XL, YL, YB, XOffset, YOffset, XStart, Y, StartTop;
	local int PlayerCounts[4];
	local int LongLists[4];
	local int BottomSlot[4];
	local font CanvasFont;
	local bool bCompressed, left;
	local float r;
	local int TeamPings[4];
	local int TeamPLs[4];

	OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
	OwnerGame = LeagueAS_GameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);	
	Canvas.Style = ERenderStyle.STY_Normal;
	CanvasFont = Canvas.Font;
	for ( i=0; i<4; i++ )
		TeamName[i] = OwnerGame.Teams[i].TeamName;

	// Header
	DrawHeader(Canvas);

	for ( i=0; i<32; i++ )
		Ordered[i] = None;

	for ( i=0; i<32; i++ )
	{
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
			{
				Ordered[PlayerCount] = PRI;
				PlayerCount++;
				PlayerCounts[PRI.Team]++;
			}
		}
	}

	SortScores(PlayerCount);
	Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
	Canvas.StrLen("TEXT", XL, YL);
	ScoreStart = Canvas.CurY + YL*2;
	if ( ScoreStart + PlayerCount * YL + 2 > Canvas.ClipY )
	{
		bCompressed = true;
		CanvasFont = Canvas.Font;
		Canvas.Font = font'SmallFont';
		r = YL;
		Canvas.StrLen("TEXT", XL, YL);
		r = YL/r;
		Canvas.Font = CanvasFont;
	}
	for ( I=0; I<PlayerCount; I++ )
	{
		if ( Ordered[I].Team < 4 )
		{
			if ( Ordered[I].Team % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);

			Canvas.StrLen("TEXT", XL, YL);
			Canvas.DrawColor = AltTeamColor[Ordered[I].Team];
			YOffset = ScoreStart + (LoopCountTeam[Ordered[I].Team] * (YL - 8)) + 2;

			// Draw Name and Ping
			if ( (Ordered[I].Team < 2) && (BottomSlot[Ordered[I].Team] == 0) && (PlayerCounts[Ordered[I].Team+2] == 0))
			{
				LongLists[Ordered[I].Team] = 1;
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);
				TeamPings[Ordered[I].Team] += Ordered[I].Ping;
				TeamPLs[Ordered[I].Team] += Ordered[I].PacketLoss;
			} 
			else if (LoopCountTeam[Ordered[I].Team] < 8)
			{
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);
				TeamPings[Ordered[I].Team] += Ordered[I].Ping;
				TeamPLs[Ordered[I].Team] += Ordered[I].PacketLoss;
			}
			if ( bCompressed )
				LoopCountTeam[Ordered[I].Team] += 1;
			else
				LoopCountTeam[Ordered[I].Team] += 2;
		}
	}

	for ( i=0; i<4; i++ )
	{
		Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
		if ( PlayerCounts[i] > 0 )
		{
			if ( i % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);
			YOffset = ScoreStart - YL + 2;

			if ( i > 1 )
				if (PlayerCounts[i-2] > 0)
					YOffset = ScoreStart + YL*10;

			Canvas.DrawColor = TeamColor[i];
			Canvas.SetPos(XOffset, YOffset);
			Canvas.StrLen(TeamName[i], XL, YL);
			Canvas.DrawText(TeamName[i], false);
			
			Canvas.Font = Font'SmallFont';
			Canvas.DrawColor = WhiteColor;
			
			Canvas.StrLen("Ping:0000", XL, YB);			
			Canvas.SetPos(XOffset + (Canvas.ClipX/4) - XL, YOffset);
			Canvas.DrawText("Ping:"$PadOut(string(TeamPings[i] / PlayerCounts[i])), false);
			Canvas.SetPos(XOffset + (Canvas.ClipX/4) - XL, YOffset + 8);
			Canvas.DrawText("P/L:"$PadOut(string(TeamPLs[i] / PlayerCounts[i]))$"%", false);

		}
	}

	//Objective Info
	if ( Canvas.ClipX > 512 )
		{
		StartTop = ((Canvas.ClipY / 5) * 3);
		Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
		Canvas.DrawColor = GoldColor;
		Canvas.StrLen("Objectives", XL, YL);
		Canvas.SetPos(((Canvas.ClipX - XL) / 2), StartTop);
		Canvas.DrawText("Objectives");	
		Y = StartTop + YL + 6;

		Left = true;
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		for (i=0; i<20; i++)
   			{
      		if ( LeagueAS_GameReplicationInfo(OwnerGame).FortName[i] != "" )
      			{
   				Canvas.StrLen(LeagueAS_GameReplicationInfo(OwnerGame).FortName[i], XL, YL);
				if ( Left )
					Canvas.SetPos((((Canvas.ClipX / 2) - XL) / 2), Y);   		
				else
					Canvas.SetPos(((((Canvas.ClipX / 2) - XL) / 2) + (Canvas.ClipX / 2)), Y);
  				Canvas.DrawColor = GoldColor;
				Canvas.DrawText(LeagueAS_GameReplicationInfo(OwnerGame).FortName[i]);
				Y = Y + YL;
			
				Canvas.StrLen(LeagueAS_GameReplicationInfo(OwnerGame).FortCompleted[i], XL, YL);
				if ( Left )
					Canvas.SetPos((((Canvas.ClipX / 2) - XL) / 2), Y);   		
				else
					Canvas.SetPos(((((Canvas.ClipX / 2) - XL) / 2) + (Canvas.ClipX / 2)), Y);
  				if ( LeagueAS_GameReplicationInfo(OwnerGame).FortCompleted[i] == "Not Complete!" )
					Canvas.DrawColor = RedColor;
				else
					Canvas.DrawColor = GreenColor;
			
				Canvas.DrawText(LeagueAS_GameReplicationInfo(OwnerGame).FortCompleted[i]);
				
				If ( Left )
					Y = Y - YL;
				else
					Y = Y + YL + 1;
				
				Left = !Left;
      			}
   			}
		}

	// Trailer
	if ( !Level.bLowRes )
	{
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		DrawTrailer(Canvas);
	}
	Canvas.Font = CanvasFont;
	Canvas.DrawColor = WhiteColor;

	AssaultHUD(OwnerHUD).DrawTimeAt(Canvas, 0.5 * Canvas.ClipX - 80 * Canvas.ClipX/1280, 4);
}
//************************************************************************************************
function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
	local float XL, YL, YB;
	local BotReplicationInfo BRI;
	local String S, O, L;
	local Font CanvasFont;
	local bool bAdminPlayer, bModeratorPlayer;
	local PlayerPawn PlayerOwner;
	local int Time, i;
	local LeagueAS_ExtPlayerReplicationInfo ePRI;

	PlayerOwner = PlayerPawn(Owner);
	
	//Find ePRI for player
	for (i=0; i<32; i++)
		{
		If ( (LeagueAS_GameReplicationInfo(OwnerGame).ePRIArray[i] != None) && (LeagueAS_GameReplicationInfo(OwnerGame).ePRIArray[i].Owner == PRI.Owner) )
			{
			ePRI = LeagueAS_GameReplicationInfo(OwnerGame).ePRIArray[i];
			break;
			}
		}
	
	bAdminPlayer = PRI.bAdmin;
	bModeratorPlayer = ePRI.bModerator;

	// Draw Name
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;

	if ( bModeratorPlayer )
		Canvas.DrawColor = GreenColor;
	if ( bAdminPlayer)
		Canvas.DrawColor = WhiteColor;

	Canvas.SetPos(XOffset, YOffset);
	
	If ( (ePRI != None) && (ePRI.PlayerName != "") && LeagueAS_GameReplicationInfo(OwnerGame).bMatchModeEnabled )
		{
		If ( ePRI.BClanTagBefore )
			Canvas.DrawText(ePRI.ClanName@ePRI.PlayerName, False);
		else
			Canvas.DrawText(ePRI.PlayerName@ePRI.ClanName, False);
		}
	else
		Canvas.DrawText(PRI.PlayerName, False);
	
	Canvas.StrLen(PRI.PlayerName, XL, YB);

	if ( Canvas.ClipX > 512 )
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';
		Canvas.DrawColor = WhiteColor;

		if (Level.NetMode != NM_Standalone)
		{
			// Draw Ping
			Canvas.StrLen(PingString$":     ", XL, YL);
			Canvas.SetPos(XOffset - XL - 6, YOffset);
			Canvas.DrawText(PingString$":"@PRI.Ping, false);

			// Draw Packetloss
			Canvas.StrLen(LossString$":    %", XL, YL);
			Canvas.SetPos(XOffset - XL - 6, YOffset + (YL+1));
			Canvas.DrawText(LossString$":"@PRI.PacketLoss$"%", false);

			if ( !bCompressed && (Canvas.ClipX > 640) )
			{
				If ((ePRI != None) && (ePRI.bMuteSay || ePRI.bMuteAll) )
					{
					Canvas.DrawColor = RedColor;
					Canvas.StrLen("          ", XL, YL);
					Canvas.SetPos(XOffset - XL - 6, YOffset + (YL+1)*2);
					If ( ePRI.bMuteAll )
						Canvas.DrawText("MUTE ALL", false);
					else
						Canvas.DrawText("MUTE ENEMY", false);
					Canvas.DrawColor = WhiteColor;
					}
			}

		}
		Canvas.Font = CanvasFont;
	}

	// Draw Score
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = TeamColor[PRI.Team];
	DrawScore(Canvas, PRI.Score, XOffset, YOffset);

	if (Canvas.ClipX < 512)
		return;

}
//************************************************************************************************

defaultproperties
{
}
