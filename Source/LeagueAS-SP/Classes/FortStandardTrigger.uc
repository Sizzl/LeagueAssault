//=============================================================================
// FortStandardTrigger.
//=============================================================================
class FortStandardTrigger extends TeamTrigger;

function Trigger( Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( Event!='' )
	{
		foreach AllActors( Class'Actor', A, Event )
		{
			A.Trigger( Other, EventInstigator );
		}
	}
}
