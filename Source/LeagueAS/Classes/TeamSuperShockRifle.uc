//=============================================================================
// TeamSuperShockRifle.
//=============================================================================
class TeamSuperShockRifle extends SuperShockRifle;

function SetHand( float hand )
{
	if ( int(Pawn(Owner).PlayerReplicationInfo.Team)!=0 )
	{
		MultiSkins[0] = Texture'Botpack.Skins.ASMD_t1';
		MultiSkins[2] = Texture'Botpack.Skins.ASMD_t3';
		MultiSkins[3] = Texture'Botpack.Skins.ASMD_t4';
	}
	else
	{
		MultiSkins[0] = Texture'Botpack.Skins.SASMD_t1';
		MultiSkins[2] = Texture'Botpack.Skins.SASMD_t3';
		MultiSkins[3] = Texture'Botpack.Skins.SASMD_t4';
	}
	Super.SetHand( hand );
}

function SpawnEffect( vector HitLocation, vector SmokeLocation )
{
	local supershockbeam RedBeam;
	local ShockBeam BlueBeam;
	local vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation-SmokeLocation;
	NumPoints = int(VSize(DVector)/135.0);
	if ( NumPoints<1 )
	{
		return;
	}
	SmokeRotation = Rotator(DVector);
	SmokeRotation.Roll = Rand( 65535 );
	if ( int(Pawn(Owner).PlayerReplicationInfo.Team)==0 )
	{
		RedBeam = Spawn( Class'supershockbeam', , , SmokeLocation, SmokeRotation );
		RedBeam.MoveAmount = DVector/float(NumPoints);
		RedBeam.NumPuffs = NumPoints-1;
	}
	else
	{
		BlueBeam = Spawn( Class'ShockBeam', , , SmokeLocation, SmokeRotation );
		BlueBeam.MoveAmount = DVector/float(NumPoints);
		BlueBeam.NumPuffs = NumPoints-1;
	}
}

function ProcessTraceHit( Actor Other, vector HitLocation, vector HitNormal, vector X, vector Y, vector Z )
{
	if ( Other==None )
	{
		HitNormal = -X;
		HitLocation = Owner.Location+X*10000.0;
	}
	SpawnEffect( HitLocation, Owner.Location+CalcDrawOffset()+(FireOffset.X+float(20))*X+FireOffset.Y*Y+FireOffset.Z*Z );
	if ( int(Pawn(Owner).PlayerReplicationInfo.Team)==0 )
	{
		Spawn( Class'UT_Superring2', , , HitLocation+HitNormal*float(8), Rotator(HitNormal) );
	}
	else
	{
		Spawn( Class'UT_RingExplosion5', , , HitLocation+HitNormal*float(8), Rotator(HitNormal) );
	}
	if ( Other!=Self && Other!=Owner && Other!=None )
	{
		Other.TakeDamage( hitdamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType );
	}
}
