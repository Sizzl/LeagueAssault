//=============================================================================
// ServerSideModule.
//=============================================================================
class ServerSideModule extends LeagueAS_SSMAbstract;

var bool MapsTweaked;
var name FortNames[30];

function TweakMaps()
{
	local Actor A;
	local string S, SA;
	local Miniammo MA;
	local vector V;
	local rotator R;
	local TeamTrigger t;
	local FortStandardTrigger FST;
	local TeamCannon TC;
	local ThighPads TP;
	local PlayerStart PS;
	local minigun2 MG;
	local int i;

	if ( MapsTweaked )
	{
		return;
	}
	i = 0;
	MapsTweaked = true;
	S = Left( string(Self), InStr(string(Self),".") );
	foreach AllActors( Class'Actor', A )
	{
		SA = Mid( string(A), InStr(string(A),".")+1 );
		if ( S~="AS-Frigate" )
		{
			if ( SA~="flakammo3" || SA~="flakammo2" )
			{
				FlakAmmo(A).RespawnTime = 10.0;
			}
			else if ( SA~="PlayerStart10" )
			{
				PlayerStart(A).bEnabled = false;
			}
		}
		else if ( S~="AS-Rook" )
		{
			if ( SA~="Mover13" )
			{
				Mover(A).MoverEncroachType = ME_CrushWhenEncroach;
			}
			else if ( A.IsA('Mover') )
			{
				Mover(A).MoverEncroachType = ME_IgnoreWhenEncroach;
			}
			else if ( SA~="FortStandard1" )
			{
				FortStandard(A).FortName = "Chain 1";
			}
			else if ( SA~="FortStandard0" )
			{
				FortStandard(A).FortName = "Chain 2";
			}
			else if ( SA~="FortStandard3" )
			{
				FortStandard(A).FortName = "Escape!";
			}
		}
		else if ( S~="AS-Overlord" )
		{
			if ( SA~="Mover6" || SA~="Mover7" )
			{
				Mover(A).MoverEncroachType = ME_CrushWhenEncroach;
			}
			else if ( SA~="PlayerStart25" || SA~="Trigger2" )
			{
				A.Destroy();
			}
			else if ( SA~="TeamTrigger3" )
			{
				A.SetCollisionSize( A.CollisionRadius*float(2)/float(3), A.CollisionHeight );
			}
			else if ( SA~="FortStandard3" )
			{
				FortStandard(A).bFlashing = false;
				FortStandard(A).FortName = "Main Gun Control";
			}
			else if ( SA~="FortStandard4" )
			{
				FortStandard(A).FortName = "The Boiler Room";
				FortStandard(A).DestroyedMessage = "has been breached.";
			}
			else if ( SA~="FortStandard0" )
			{
				FortStandard(A).FortName = "The Beachhead";
				FortStandard(A).DestroyedMessage = "has been breached.";
			}
			else if ( SA~="SniperRifle0" )
			{
				V.X = 450.0;
				V.Y = 1712.0;
				V.Z = -1744.0;
				MA = Spawn( Class'Miniammo', Self, , V, A.Rotation );
				MA.RespawnTime = 5.0;
				V.X = 235.0;
				V.Y = 1761.0;
				V.Z = -1744.0;
				MA = Spawn( Class'Miniammo', Self, , V, A.Rotation );
				MA.RespawnTime = 5.0;
			}
			else if ( SA~="MortarSpawner0" )
			{
				MortarSpawner(A).ShellSpeed = 500.0;
				MortarSpawner(A).RateOfFire = 8;
				MortarSpawner(A).ShellDamage = 100;
				MortarSpawner(A).Deviation = 800;
			}
		}
		else if ( S~="AS-Mazon" )
		{
			if ( SA~="Mover4" || SA~="Mover5" || SA~="Mover6" )
			{
				Mover(A).MoverEncroachType = ME_CrushWhenEncroach;
			}
			else if ( SA~="PlayerStart4" || SA~="PlayerStart3" || SA~="PlayerStart11" || SA~="PlayerStart12" || SA~="PlayerStart20" )
			{
				A.Destroy();
			}
		}
		else if ( S~="AS-HiSpeed" )
		{
			if ( SA~="Mover5" )
			{
				A.SetCollision( false );
			}
			else if ( SA~="Mover1" || SA~="Mover2" )
			{
				Mover(A).MoverEncroachType = ME_IgnoreWhenEncroach;
			}
		}
		else if ( S~="AS-Lavafort][" )
		{
			if ( SA~="FortStandard7" )
			{
				FortStandard(A).FortName = "The lava cave";
				FortStandard(A).DestroyedMessage = "has been entered!";
			}
			else if ( SA~="FortStandard6" )
			{
				FortStandard(A).FortName = "The fort";
				FortStandard(A).DestroyedMessage = "has been entered!";
			}
			else if ( SA~="FortStandard4" )
			{
				FortStandard(A).FortName = "The lift";
				FortStandard(A).DestroyedMessage = "has been passed!";
			}
			else if ( SA~="FortStandard3" )
			{
				FortStandard(A).FortName = "The entrance cave";
				FortStandard(A).DestroyedMessage = "has been breached!";
			}
			else if ( SA~="FortStandard5" )
			{
				FortStandard(A).Destroy();
			}
			else if ( SA~="FortStandard2" )
			{
				FortStandard(A).DefensePriority = 20;
			}
			else if ( SA~="MinigunCannon0" )
			{
				A.Destroy();
			}
		}
		else if ( S~="AS-Bridge" )
		{
			if ( SA~="FortStandard3" )
			{
				FortStandard(A).FortName = "The base";
				FortStandard(A).DestroyedMessage = "has been entered!";
			}
			else if ( SA~="FortStandard7" )
			{
				FortStandard(A).FortName = "The bridge";
				FortStandard(A).DestroyedMessage = "has been reached!";
			}
			else if ( SA~="FortStandard22" )
			{
				A.SetCollisionSize( A.CollisionRadius*float(2)/float(3), A.CollisionHeight );
				V.X = 2768.0;
				V.Y = -1255.0;
				V.Z = 1478.0;
				t = Spawn( Class'TeamTrigger', FortStandard(A), FortStandard(A).Tag, V, FortStandard(A).Rotation );
				t.Team = 0;
				t.Event = 'FF';
			}
			else if ( SA~="Mover16" || SA~="Mover17" || SA~="Mover18" || SA~="Mover19" )
			{
				A.SetCollision( false );
			}
		}
		else if ( S~="AS-Ballistic" )
		{
			if ( SA~="FortStandard3" )
			{
				FortStandard(A).FortName = "Nuclear strike";
				FortStandard(A).DestroyedMessage = "underway!";
				FortStandard(A).DefensePriority = 0;
			}
			if ( SA~="FortStandard1" )
			{
				A.SetCollisionSize( A.CollisionRadius, A.CollisionHeight*float(2)/float(3) );
			}
			if ( SA~="FortStandard2" )
			{
				FortStandard(A).DefensePriority = 10;
			}
			if ( SA~="Mover22" || SA~="Mover28" )
			{
				Mover(A).EncroachDamage = 1;
				Mover(A).MoverEncroachType = ME_IgnoreWhenEncroach;
			}
		}
		else if ( S~="AS-Asthenosphere" )
		{
			if ( SA~="Mover21" || SA~="Mover26" )
			{
				Mover(A).MoverEncroachType = ME_CrushWhenEncroach;
			}
			else if ( SA~="Mover0" || SA~="Mover2" || SA~="Mover3" || SA~="Mover4" || SA~="Mover17" || SA~="Mover18" || SA~="Mover19" || SA~="Mover20" || SA~="Mover32" || SA~="Mover35" )
			{
				Mover(A).MoverEncroachType = ME_IgnoreWhenEncroach;
			}
			else if ( SA~="ShockCore4" || SA~="ShockCore15" )
			{
				A.Destroy();
			}
			else if ( SA~="RocketPack9" || SA~="RocketPack11" )
			{
				A.Destroy();
			}
			else if ( SA~="ShockCore20" || SA~="ShockCore19" || SA~="ShockCore11" || SA~="ShockCore12" )
			{
				LeagueAssaultGame.BaseMutator.ReplaceWith( A, "BotPack.HealthVial" );
				A.Destroy();
			}
			else if ( SA~="FortStandard8" )
			{
				V.X = 0.0;
				V.Y = -5628.0;
				V.Z = 40.4;
				R.Pitch = 0;
				R.Roll = 0;
				R.Yaw = -16264;
				TC = Spawn( Class'TeamCannon', FortStandard(A), FortStandard(A).Tag, V, R );
				TC.MyTeam = 1;
				TC.ProjectileType = Class'ShockProj';
				V.Y = -4848.0;
				TC = Spawn( Class'TeamCannon', FortStandard(A), FortStandard(A).Tag, V, R );
				TC.ProjectileType = Class'RocketMk2';
				V.X = -336.0;
				V.Y = -11800.0;
				V.Z = -32.0;
				R.Pitch = 0;
				R.Roll = 0;
				R.Yaw = 0;
				TP = Spawn( Class'ThighPads', FortStandard(A), FortStandard(A).Tag, V, R );
				V.X = 336.0;
				V.Y = -11800.0;
				V.Z = -32.0;
				R.Pitch = 0;
				R.Roll = 0;
				R.Yaw = 0;
				TP = Spawn( Class'ThighPads', FortStandard(A), FortStandard(A).Tag, V, R );
			}
		}
		else if ( S~="AS-OceanFloor" )
		{
			if ( SA~="PAmmo0" || SA~="PAmmo1" )
			{
				LeagueAssaultGame.BaseMutator.ReplaceWith( A, "BotPack.ShockCore" );
				A.Destroy();
			}
			else if ( SA~="PulseGun0" )
			{
				V.X = 215.0;
				V.Y = -293.0;
				V.Z = 2053.0;
				MG = Spawn( Class'minigun2', A.Owner, A.Tag, V, A.Rotation );
				MG.bRotatingPickup = false;
				A.Destroy();
			}
			else if ( SA~="ShockCore1" || SA~="ShockCore2" )
			{
				LeagueAssaultGame.BaseMutator.ReplaceWith( A, "BotPack.Miniammo" );
				A.Destroy();
			}
		}
		else if ( S~="AS-OceanFloorAL" )
		{
			if ( A.IsA('Squid') || A.IsA('GiantManta') || A.IsA('Devilfish') )
			{
				A.Destroy();
			}
		}
		else if ( S~="AS-RiverbedAL" )
		{
			if ( SA~="SteelBox0" || SA~="SteelBox2" )
			{
				A.Destroy();
			}
			if ( SA~="FortStandard1" )
			{
				FortStandard(A).DefensePriority = 100;
			}
			if ( SA~="FortStandard0" )
			{
				FortStandard(A).DefensePriority = 50;
			}
		}
		else if ( S~="AS-Riverbed]l[AL" )
		{
			if ( SA~="FortStandard0" )
			{
				FortStandard(A).DefensePriority = 100;
			}
			if ( SA~="FortStandard1" )
			{
				FortStandard(A).DefensePriority = 90;
			}
			if ( SA~="FortStandard2" )
			{
				FortStandard(A).DefensePriority = 80;
			}
			if ( SA~="FortStandard6" )
			{
				FortStandard(A).DefensePriority = 70;
			}
			if ( SA~="FortStandard7" )
			{
				FortStandard(A).DefensePriority = 70;
			}
			if ( SA~="FortStandard3" )
			{
				FortStandard(A).DefensePriority = 60;
			}
			if ( SA~="FortStandard5" )
			{
				FortStandard(A).DefensePriority = 50;
			}
		}
		else if ( S~="AS-GuardiaAL" )
		{
			if ( A.IsA('FlakAmmo') )
			{
				A.Destroy();
			}
		}
		else if ( S~="AS-GolgothaAL" )
		{
			if ( A.IsA('PulseGun') )
			{
				LeagueAssaultGame.BaseMutator.ReplaceWith( A, "BotPack.MiniAmmo" );
				A.Destroy();
			}
		}
		else if ( S~="AS-AutoRIP" )
		{
			if ( SA~="TeamTrigger6" || SA~="TeamTrigger7" || SA~="TeamTrigger8" || SA~="TeamTrigger9" || SA~="TeamTrigger10" || SA~="TeamTrigger11" || SA~="TeamTrigger12" || SA~="TeamTrigger13" || SA~="TeamTrigger14" || SA~="TeamTrigger15" || SA~="TeamTrigger16" || SA~="TeamTrigger17" || SA~="TeamTrigger18" || SA~="TeamTrigger19" || SA~="TeamTrigger20" || SA~="TeamTrigger21" || SA~="TeamTrigger22" || SA~="TeamTrigger23" || SA~="PressureZone0" )
			{
				A.Destroy();
			}
			else if ( SA~="Mover4" )
			{
				A.Tag = 'HJDJSHTICHFK';
				Mover(A).DoOpen();
			}
		}
		if ( A.IsA('TeamCannon') )
		{
			TeamCannon(A).Health = 100;
		}
		if ( A.IsA('Mover') )
		{
			Mover(A).bUseTriggered = false;
		}
		if ( A.IsA('FortStandard') && FortStandard(A).bTriggerOnly )
		{
			FST = Spawn( Class'FortStandardTrigger', Self, , A.Location );
			FST.SetCollisionSize( FortStandard(A).CollisionRadius, FortStandard(A).CollisionHeight );
			FortStandard(A).SetCollisionSize( 0.0, 0.0 );
			FST.Tag = A.Tag;
			A.Tag = FortNames[i];
			FST.Event = FortNames[i];
			i++;
		}
	}
}

function OnStart()
{
	TweakMaps();
}

function OnTimer()
{
}

defaultproperties
{
    SubVersionStr=""
}
