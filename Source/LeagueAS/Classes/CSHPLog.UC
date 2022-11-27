//================================================================================
// CSHPLog.
//================================================================================

class CSHPLog extends StatLogFile;

function StartLog ()
{
  local string Filename;
  local string Str;
  local string str2;
  local int i;

  Str = Level.Game.GameReplicationInfo.ServerName;
  str2 = "";
  for ( i=0; i<Len( Str ); i++ )
  {
    if ( InStr("\\/*?:<>\"|",Mid(Str,i,1))!=-1 )
    {
      str2 = str2 $ "_";
    }
    else
    {
      str2 = str2 $ Mid( Str, i, 1 );
    }
  }
  Filename = "../Logs/CSHP" $ str2 $ "." $ GetShortAbsoluteTime();
  StatLogFile = Filename $ ".tmp";
  StatLogFinal = Filename $ ".log";
  OpenLog();
}

function Timer ()
{
}

defaultproperties
{
    StatLogFile="./CSHP.log"
}
