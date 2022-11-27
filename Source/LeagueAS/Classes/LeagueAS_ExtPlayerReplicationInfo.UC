//================================================================================
// LeagueAS_ExtPlayerReplicationInfo.
//================================================================================

class LeagueAS_ExtPlayerReplicationInfo extends ReplicationInfo;

var string PlayerName;
var int Team;
var bool bMuteSay;
var bool bMuteAll;
var bool bModerator;
var int Health;
var int Armour;
var string Location;
var string WeaponName;
var int AmmoAmount;
var bool bReadyToPlay;

replication
{
  reliable if ( Role == ROLE_Authority )
    PlayerName,Team,bMuteSay,bMuteAll,bModerator,Health,Armour,Location,WeaponName,AmmoAmount,bReadyToPlay;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    NetPriority=10.00
}
