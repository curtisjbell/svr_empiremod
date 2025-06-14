/*	** rPAM SD ulitities (_pam_utilities.gsc) **

	REISSUE Project Ares Mod version 1.11 by zyquist
	
	original script by Garetjax (V1.08)
	edit by zyquist (aka reissue_)

>>>	VERSION: SRC27

>>>	REL-TIMESTAMP: 20:00 13.06.2015
>>>	SRC-TIMESTAMP: 16:05 12.06.2015

>>>	**   YOU AREN'T ALLOWED TO CHANGE SOMETHING HERE   **
	** PLEASE RESPECT THE ENERGY OF MAKING P.A.M V1.11 **

*/

//The below lines should be updated each new release:
Get_Stock_PK3()
{
	// List all Allowed PK3 file names HERE separated by a space.  DO NOT include '.pk3'
	level.stockPK3 = "pakb paka pak9 pak8 pak6 pak5 pak4 pak3 pak2 pak1 pak0 z_svr_rPAMv111";
}

// **********************************************************************
// Should not need to change anything below here!
// **********************************************************************

//Searches for unknown PK3 files for use with all gametype competition modes
NonstockPK3Check()
{
	Get_Stock_PK3();

	level.serverPK3 = [];
	level.serverPK3 = getCvar("sv_pakNames");
	
	foundCount = 0;
	level.PK3check = [];
	level.PK3check[0] = "none";

	foundPK3 = splitArray(level.serverPK3, " ", "", true);
	for (i=0; i < foundPK3.size ; i++)
	{
		found = findStr(foundPK3[i], level.stockPK3, "anywhere");
		if (found != -1)
			continue;
		else
		{
			foundCount++;
			level.PK3check[foundCount] = foundPK3[i];
		}
	}
}

CheckPK3files()
{
	level.serverPK3 = [];
	level.serverPK3 = getCvar("sv_pakNames");
	//self iprintln("^2Server PK3 Files:");
	//self iprintln("^2" + level.serverPK3);

	// Print Unknown PK3 Files
	if (level.PK3check.size > 1)
	{
		//self iprintln("^1Unknown PK3 files:");
		for (index = 1;index < level.PK3check.size; index++ )
		{
			//self iprintln("^1" + level.PK3check[index]);
			//wait .05;
		}
	}
	//self iprintln("^8.");
	//self iprintln("^8.");
	//self iprintln("^8.");
	//self iprintln("^8.");
	//self iprintln("^2Server PK3 Files in console");
	if (level.PK3check.size > 1)
	{
			//self iprintln("^1Warning: Unknown PK3 Files listed in console");
	}
}

Prevent_Map_Change()
{
	//mapname = getcvar("mapname");
	//setcvar("sv_mapRotationCurrent" , mapname);
}

PAMRestartMap()
{
	Prevent_Map_Change();

	pammode = getcvar("pam_mode");

	iprintlnbold(level._prefix + " Changed to ^9" + pammode);
	iprintlnbold("^9Please Wait");

	wait 3;
	exitLevel(false);
}

PAM_Auto_Demo_Start()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player setClientCvar("cg_autodemo", "1");
		wait .5;
		player autoDemoStart();
	}

	game["demosrecording"] = 1;

	level.demosrecording = newHudElem();
	level.demosrecording.x = 575;
	level.demosrecording.y = 410;
	level.demosrecording.alignX = "center";
	level.demosrecording.alignY = "middle";
	level.demosrecording.fontScale = 1.5;
	level.demosrecording.color = (1, 1, 0);
	level.demosrecording setText(game["hudrecording"]);
}

PAM_Auto_Demo_Stop()
{
	//Prepare Client Side Cvars
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (getCvar("g_autoscreenshot") == "1")
			player setClientCvar("cg_autoscreenshot", "1");
		if (game["demosrecording"] == 1)
			player setClientCvar("cg_autodemo", "1");
	}

	//Give Clients a chance to respond
	wait 1;

	// Stop the demo & Take screenshot
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (getCvar("g_autoscreenshot") == "1")
		{
			player autoScreenshot();
			player setClientCvar("cg_autoscreenshot", "0");
		}

		if (game["demosrecording"] == 1)
		{
			player autoDemoStop();
			player setClientCvar("cg_autodemo", "0");
		}
	}

	game["demosrecording"] = 0;
}

CheckValidTeam(temp_team)
{
	switch (temp_team)
	{
		case "american":
		case "british":
		case "russian":
		case "":
			return true;

		default:
			return false;
	}
}

StartPAMUO(reason)
{
	mapname = getcvar("mapname");
	mapname = "map " + mapname;
	if (mapname == "map mp_carentan")
		mapname = "map mp_dawnville";
	else
		mapname = "map mp_carentan";

	setcvar("sv_maprotationcurrent", mapname);

	if (reason == "enable")
	{
		iprintlnbold("^1~^3empire ^2| ^3PAM Enabled, Starting PAM");
		iprintlnbold("^3Please Wait");
		wait 3;
	}
	else if (reason == "modechange")
	{
		pammode = getcvar("pam_mode");
		iprintlnbold("^1~^3empire ^2| ^3PAM Mode Changed to " + pammode);
		iprintlnbold("^3Please Wait");
		wait 5;
	}
	else if (reason == "cvar")
	{
		iprintlnbold("^7PAM Has Detected a ^3CVAR Change^7 that");
		iprintlnbold("^1REQUIRES ^2the map to change");
		iprintlnbold("^3Please Wait");
		wait 5;
	}

	exitLevel(false);
}

StopPAMUO()
{
	mapname = getcvar("mapname");
	mapname = "map " + mapname;
	if (mapname == "map mp_carentan")
		mapname = "map mp_dawnville";
	else
		mapname = "map mp_carentan";

	setcvar("sv_maprotationcurrent", mapname);

	iprintlnbold("^1PAM Disabled, Starting Stock CoD");
	iprintlnbold("^3Please Wait");
	wait 3;

	exitLevel(false);
}


Team_Override(temp_allies)
{
	// Prevent new randomizations if we are not on the SAME map & gametype
	if( getcvar("mapname") == getcvar("pam_oldmap") && getcvar("g_gametype") == getcvar("pam_oldgt") )
	{
		game["allies"] = getcvar("pam_oldallies");
		game[game["allies"] + "_soldiertype"] 	= getcvar("pam_oldsoldiertype");
		game[game["allies"] + "_soldiervariation"]= getcvar("pam_oldsoldiervariation");
		
		return;
	}

	wintermap = false;
	if(isdefined(game["german_soldiervariation"]) && game["german_soldiervariation"] == "winter")
		wintermap = true;

	switch (temp_allies)
	{
		case "american":
			game["allies"] = "american";
			game["american_soldiertype"] = "airborne";
			if (wintermap)
				game["american_soldiervariation"] = "winter";
			else
				game["american_soldiervariation"] = "normal";
		break;

		
		case "british":
			game["allies"] = "british";
			if(wintermap)
			{
				game["british_soldiertype"] = "commando";
				game["british_soldiervariation"] = "winter";
			}
			else
			{
				switch(randomInt(2))
				{
					case 0:
						game["british_soldiertype"] = "airborne";
						game["british_soldiervariation"] = "normal";
						break;

					default:
						game["british_soldiertype"] = "commando";
						game["british_soldiervariation"] = "normal";
						break;
				}
			}
		break;


		case "russian":
			game["allies"] = "russian";
			if(wintermap)
			{
				switch(randomInt(2))
				{
					case 0:
						game["russian_soldiertype"] = "conscript";
						game["russian_soldiervariation"] = "winter";
						break;

					default:
						game["russian_soldiertype"] = "veteran";
						game["russian_soldiervariation"] = "winter";
						break;
				}
			}
			else
			{
				switch(randomInt(2))
				{
					case 0:
						game["russian_soldiertype"] = "conscript";
						game["russian_soldiervariation"] = "normal";
						break;


					default:
						game["russian_soldiertype"] = "veteran";
						game["russian_soldiervariation"] = "normal";
						break;

				}
			}
		break;

		default:
			break;
	}
}

// CODE BELOW ORIGINALLY FROM CoDAM
splitArray( str, sep, quote, skipEmpty )
{
	if ( !isdefined( str ) || ( str == "" ) )
		return ( [] );

	if ( !isdefined( sep ) || ( sep == "" ) )
		sep = ";";	// Default separator

	if ( !isdefined( quote ) )
		quote = "";

	skipEmpty = isdefined( skipEmpty );

	a = _splitRecur( 0, str, sep, quote, skipEmpty );

	return ( a );
}

_splitRecur( iter, str, sep, quote, skipEmpty )
{
	s = sep[ iter ];

	_a = [];
	_s = "";
	doQuote = false;
	for ( i = 0; i < str.size; i++ )
	{
		ch = str[ i ];
		if ( ch == quote )
		{
			doQuote = !doQuote;

			if ( iter + 1 < sep.size )
				_s += ch;
		}
		else
		if ( ( ch == s ) && !doQuote )
		{
			if ( ( _s != "" ) || !skipEmpty )
			{
				_l = _a.size;

				if ( iter + 1 < sep.size )
				{
					_x = _splitRecur( iter + 1, _s,	sep, quote, skipEmpty );

					if ( ( _x.size > 0 ) || !skipEmpty )
					{
						_a[ _l ][ "str" ] = _s;
						_a[ _l ][ "fields" ] = _x;
					}
				}
				else
					_a[ _l ] = _s;
			}

			_s = "";
		}
		else
			_s += ch;
	}

	if ( _s != "" )
	{
		_l = _a.size;

		if ( iter + 1 < sep.size )
		{
			_x = _splitRecur( iter + 1, _s, sep, quote, skipEmpty );
			if ( _x.size > 0 )
			{
				_a[ _l ][ "str" ] = _s;
				_a[ _l ][ "fields" ] = _x;
			}
		}
		else
			_a[ _l ] = _s;
	}

	return ( _a );
}

findStr( find, str, pos )
{
	if ( !isdefined( find ) || ( find == "" ) || 
		 !isdefined( str ) || 
		 !isdefined( pos ) || 
		 ( find.size > str.size ) )
		return ( -1 );

	fsize = find.size;
	ssize = str.size;

	switch ( pos )
	{
	  case "start": place = 0 ; break;
	  case "end":	place = ssize - fsize; break;
	  default:	place = 0 ; break;
	}

	for ( i = place; i < ssize; i++ )
	{
		if ( i + fsize > ssize )
			break;			// Too late to compare

		// Compare now ...
		for ( j = 0; j < fsize; j++ )
			if ( str[ i + j ] != find[ j ] )
				break;		// No match

		if ( j >= fsize )
			return ( i );		// Found it!

		if ( pos == "start" )
			break;			// Didn't find at start
	}

	return ( -1 );
}

InitClock(clock, time)
{
	clock.x = 590; // 590;
	clock.y = 315; // 380;
	clock.alignX = "center";
	clock.alignY = "middle";
	clock.sort = 9999;
	clock setClock(time, 60, "hudStopwatch", 64, 64); // count down for 5 of 60 seconds, size is 64x64
}