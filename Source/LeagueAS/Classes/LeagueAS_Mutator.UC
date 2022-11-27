//================================================================================
// LeagueAS_Mutator.
//================================================================================

class LeagueAS_Mutator extends DMMutator;

var LeagueAssault LeagueAssaultGame;

function Mutate (string MutateString, PlayerPawn Sender)
{
  if ( MutateString ~= "EavyAssaultPlus" )
  {
    LeagueAssaultGame.PEFChangeTeams(Sender);
  }
  Super.Mutate(MutateString,Sender);
}

function MutatorTakeDamage (out int actualDamage, Pawn Victim, Pawn instigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType)
{
  local LeagueAS_Inventory i;

  i = LeagueAS_Inventory(Victim.FindInventoryType(Class'LeagueAS_Inventory'));
  if ( i != None )
  {
    i.InventoryTakeDamage(actualDamage,Victim,instigatedBy,HitLocation,Momentum,DamageType);
  }
}

event PreBeginPlay ()
{
  LeagueAssaultGame = LeagueAssault(Level.Game);
  Level.Game.RegisterDamageMutator(self);
  Level.Game.RegisterMessageMutator(self);
}

function bool MutatorTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
  local ClientOptions CO;

  if ( Sender!=None && Receiver!=None )
  {
    if ( Sender.IsA('PlayerPawn') && !Sender.IsA('Spectator') && Receiver.IsA('PlayerPawn') && !Receiver.IsA('Spectator') )
    {
      foreach AllActors( Class'ClientOptions', CO )
      {
        if ( Receiver==CO.Owner )
        {
          break;
        }
      }
      if ( int(PlayerPawn(Sender).PlayerReplicationInfo.Team)!=int(PlayerPawn(Receiver).PlayerReplicationInfo.Team) )
      {
        if ( CO.bMuteSay )
        {
          return false;
        }
        else if ( NextMessageMutator!=None )
        {
          return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
        }
        else
        {
          return true;
        }
      }
      else if ( CO.bMuteAll )
      {
        return false;
      }
      else if ( NextMessageMutator!=None )
      {
        return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
      }
      else
      {
        return true;
      }
    }
    else if ( NextMessageMutator!=None )
    {
      return NextMessageMutator.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
    }
    else
    {
      return true;
    }
  }
}
