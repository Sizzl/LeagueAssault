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
	Level.Game.RegisterMessageMutator(Self);
}
//************************************************************************************************
function bool MutatorTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
	local LeagueAS_ClientOptions CO;
	
	if ( (Sender != None) && (Receiver != None) )
		{
		if ( Sender.IsA('PlayerPawn') && !Sender.IsA('Spectator') && Receiver.IsA('PlayerPawn') && !Receiver.IsA('Spectator') )
			{
			foreach AllActors(class'LeagueAS_ClientOptions', CO)
				if (Receiver == CO.Owner)
					break;

			if ( PlayerPawn(Sender).PlayerReplicationInfo.Team != PlayerPawn(Receiver).PlayerReplicationInfo.Team )
				{
				if ( CO.bMuteSay )
					return false;
				else
					{
					if ( NextMessageMutator != None )
						return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
					else
						return true;
					}
				}
			else
				{
				if ( CO.bMuteAll )
					return false;
				else
					{
					if ( NextMessageMutator != None )
						return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
					else
						return true;
					}
				}
			}
		else
			{
			if ( NextMessageMutator != None )
				return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
			else
				return true;
			}
		}
}
//************************************************************************************************

defaultproperties
{
      LeagueAssaultGame=None
}
