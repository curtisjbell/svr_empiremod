cvardef(varname, vardefault, min, max, type)
{
	mapname = getcvar("mapname");
	gametype = getcvar("g_gametype");
	gtmap = gametype + "_" + mapname;

	tempvar = varname + "_" + gametype;
	if(getcvar(tempvar) != "") 
		varname = tempvar; 

	tempvar = varname + "_" + mapname;
	if(getcvar(tempvar) != "")
		varname = tempvar;

	tempvar = varname + "_" + gtmap;
	if(getcvar(tempvar) != "")
		varname = tempvar;

	// get the variable's definition
	switch(type)
	{
		case "int":
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvarint(varname);
			break;
		case "float":
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvarfloat(varname);
			break;
		case "string":
		default:
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvar(varname);
			break;
	}

	// if it's a number, with a minimum, that violates the parameter
	if((type == "int" || type == "float") && min != "" && definition < min)
		definition = min;

	// if it's a number, with a maximum, that violates the parameter
	if((type == "int" || type == "float") && max != "" && definition > max)
		definition = max;

	return definition;
}

closeMenus()
{
	self closeMenu();
}

getTeam(team)
{
	if (self.sessionstate == "playing" && self.sessionteam == "none")
		return self.pers["team"];
	else if (self.sessionstate == "playing" && self.sessionteam != "none")
		return self.sessionteam;
	else
		return undefined;
}

isNumeric( str )	// from CoDaM mod
{
//	debug( 98, "isNumeric:: |", str, "|" );

	if ( !isdefined( str ) || ( str == "" ) )
		return ( false );

	str += "";
	for ( i = 0; i < str.size; i++ )
		switch ( str[ i ] )
		{
		  case "0": case "1": case "2": case "3": case "4":
		  case "5": case "6": case "7": case "8": case "9":
		  	break;
		  default:
		  	return ( false );
		}

	return ( true );
}

specPermissions()
{
	maps\mp\gametypes\_teams::SetSpectatePermissions();
}

spawnSpectator()
{
	gt = getCvar("g_gametype");

	if (gt == "bel")		level.spawnSpectator = maps\mp\gametypes\bel::spawnSpectator;
	else if (gt == "dm")	level.spawnSpectator = maps\mp\gametypes\dm::spawnSpectator;
	else if (gt == "hq")	level.spawnSpectator = maps\mp\gametypes\hq::spawnSpectator;
	else if (gt == "re")	level.spawnSpectator = maps\mp\gametypes\re::spawnSpectator;
	else if (gt == "sd")	level.spawnSpectator = maps\mp\gametypes\sd::spawnSpectator;
	else if (gt == "tdm")	level.spawnSpectator = maps\mp\gametypes\tdm::spawnSpectator;

	else level.noGtSupport = true;

	if (isDefined(level.noGtSupport))
		return;

	if (isAlive(self))
		self suicide();

	self.pers["team"] = "spectator";
	self.pers["teamTime"] = 1000000;
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["spawnweapon"] = undefined;
	self.pers["savedmodel"] = undefined;

	self.sessionteam = "spectator";
	self setClientCvar("g_scriptMainMenu", game["menu_team"]);
	self setClientCvar("ui_weapontab", "0");

	self thread [[level.spawnSpectator]]();

	if (gt == "bel")
	{
		if (isDefined(self.blackscreen))		self.blackscreen destroy();
		if (isDefined(self.blackscreentext))	self.blackscreentext destroy();
		if (isDefined(self.blackscreentext2))	self.blackscreentext2 destroy();
		if (isDefined(self.blackscreentimer))	self.blackscreentimer destroy();
		self.pers["LastAxisWeapon"] = undefined;
		self.pers["LastAlliedWeapon"] = undefined;
		maps\mp\gametypes\bel::CheckAllies_andMoveAxis_to_Allies();
	}
}
