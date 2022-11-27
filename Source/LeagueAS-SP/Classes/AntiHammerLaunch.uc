//=============================================================================
// AntiHammerLaunch. 
//=============================================================================
class AntiHammerLaunch extends Mutator;

event PreBeginPlay()
{
	Level.Game.RegisterDamageMutator( Self );
}

function MutatorTakeDamage( out int actualDamage, Pawn Victim, Pawn instigatedBy, out vector HitLocation, out vector Momentum, name DamageType )
{
	local ImpactHammer i;

	if ( DamageType=='impact' && Victim!=instigatedBy )
	{
		i = ImpactHammer(instigatedBy.FindInventoryType(Class'ImpactHammer'));
		if ( i!=None && i.ChargeSize>float(1) )
		{
			Momentum /= i.ChargeSize;
		}
	}
	Super.MutatorTakeDamage( actualDamage, Victim, instigatedBy, HitLocation, Momentum, DamageType );
}

defaultproperties
{
}
