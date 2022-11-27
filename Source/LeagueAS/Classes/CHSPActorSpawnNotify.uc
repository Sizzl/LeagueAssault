//=============================================================================
// CHSPActorSpawnNotify.
//=============================================================================
class CHSPActorSpawnNotify extends SpawnNotify;

var CSHPCheatRI MyRI;

simulated event Actor SpawnNotification( Actor Actor )
{
	if ( MyRI!=None )
	{
		MyRI.xxCheckActor( Actor, false );
	}
	return Actor;
}