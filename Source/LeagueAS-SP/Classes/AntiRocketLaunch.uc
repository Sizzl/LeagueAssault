//=============================================================================
// AntiRocketLaunch.
//=============================================================================
class AntiRocketLaunch extends Mutator;

var int Charge;

event PreBeginPlay()
{
	Level.Game.RegisterDamageMutator( Self );
	SetTimer( 0.1, true );
}

function MutatorTakeDamage( out int actualDamage, Pawn Victim, Pawn instigatedBy, out vector HitLocation, out vector Momentum, name DamageType )
{
	if ( DamageType=='RocketDeath' )
	{
		if ( Charge>0 )
		{
			Momentum = vect(0.0,0.0,0.0);
		}
		else
		{
			Charge = 1;
		}
	}
	Super.MutatorTakeDamage( actualDamage, Victim, instigatedBy, HitLocation, Momentum, DamageType );
}

function Timer()
{
	if ( Charge>0 && Charge++>10 )
	{
		Charge = 0;
	}
}

defaultproperties
{
    Charge=0
}
