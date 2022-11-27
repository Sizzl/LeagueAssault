//=============================================================================
// LeagueAS_TimeMessage.
//=============================================================================
class LeagueAS_TimeMessage extends CriticalEventPlus;

var localized string TimeMessage[16];
var Sound TimeSound[16];

static function string GetString( optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	return default.TimeMessage[Switch];
}

static simulated function ClientReceive( PlayerPawn P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Super.ClientReceive( P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	if ( P.ViewTarget!=None )
	{
		P.ViewTarget.PlaySound( default.TimeSound[Switch], , 4.0 );
	}
	else
	{
		P.PlaySound( default.TimeSound[Switch], , 4.0 );
	}
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

defaultproperties
{
    TimeMessage(0)="5 minutes until game start!"
    TimeMessage(1)=""
    TimeMessage(2)="3 minutes until game start!"
    TimeMessage(3)="2 minutes until game start!"
    TimeMessage(4)="1 minutes until game start!"
    TimeMessage(5)="30 seconds until game start!"
    TimeMessage(6)="10 seconds until game start!"
    TimeMessage(7)="9..."
    TimeMessage(8)="8..."
    TimeMessage(9)="7..."
    TimeMessage(10)="6..."
    TimeMessage(11)="5 seconds and counting..."
    TimeMessage(12)="4..."
    TimeMessage(13)="3..."
    TimeMessage(14)="2..."
    TimeMessage(15)="1..."
    TimeSound(0)=Sound'Announcer.FunnyName1.cd5min'
    TimeSound(1)=None
    TimeSound(2)=Sound'Announcer.FunnyName1.cd3min'
    TimeSound(3)=None
    TimeSound(4)=Sound'Announcer.FunnyName1.cd1min'
    TimeSound(5)=None
    TimeSound(6)=Sound'Announcer.FunnyName1.cd10'
    TimeSound(7)=Sound'Announcer.FunnyName1.cd9'
    TimeSound(8)=Sound'Announcer.FunnyName1.cd8'
    TimeSound(9)=Sound'Announcer.FunnyName1.cd7'
    TimeSound(10)=Sound'Announcer.FunnyName1.cd6'
    TimeSound(11)=Sound'Announcer.FunnyName1.cd5'
    TimeSound(12)=Sound'Announcer.FunnyName1.cd4'
    TimeSound(13)=Sound'Announcer.FunnyName1.cd3'
    TimeSound(14)=Sound'Announcer.FunnyName1.cd2'
    TimeSound(15)=Sound'Announcer.FunnyName1.cd1'
    bBeep=False
}
