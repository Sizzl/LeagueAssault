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
  reliable if ( Role == 4 )
    PlayerName,Team,bMuteSay,bMuteAll,bModerator,Health,Armour,Location,WeaponName,AmmoAmount,bReadyToPlay;
}

defaultproperties
{
    RemoteRole=2
    NetPriority=10.00
}
