//=============================================================================
// Phear (phear@utassault.net)
//=============================================================================
class LeagueAS_Mutator expands DMMutator;

var LeagueAssault LeagueAssaultGame;

//************************************************************************************************
function Mutate(string MutateString, PlayerPawn Sender)
{
	if ( MutateString ~= "EavyAssaultPlus" )
		LeagueAssaultGame.PEFChangeTeams(Sender);
	Super.Mutate(MutateString, Sender);
}
//************************************************************************************************
function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType)
{
	local LeagueAS_Inventory I;

	I = LeagueAS_Inventory(Victim.FindInventoryType(class'LeagueAS_Inventory'));
	if ( I != None )
		I.InventoryTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);

}
//************************************************************************************************
event PreBeginPlay()
{
	LeagueAssaultGame = LeagueAssault(Level.Game);
	Level.Game.RegisterDamageMutator(Self);
}
//************************************************************************************************

defaultproperties
{
      LeagueAssaultGame=None
}
