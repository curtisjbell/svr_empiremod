/*
	Wawa
	Objective: 	Win a Won Against Won Arena game. First to the round win limit or most wins at round limit wins
	Map ends:	When one player reaches the win limit, or round limit is reached
	Respawning:	No wait / Away from other players

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_deathmatch_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of enemies at the time of spawn.
			Players generally spawn away from enemies.

		Spectator Spawnpoints:
			classname		mp_deathmatch_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "american";
			game["axis"] = "german";
			Because Deathmatch doesn't have teams with regard to gameplay or scoring, this effectively sets the available weapons.
	
		If using minefields or exploders:
			maps\mp\_load::main();
		
	Optional level script settings
	------------------------------
		Soldier Type and Variation:
			game["american_soldiertype"] = "airborne";
			game["american_soldiervariation"] = "normal";
			game["german_soldiertype"] = "wehrmacht";
			game["german_soldiervariation"] = "normal";
			This sets what models are used for each nationality on a particular map.
			
			Valid settings:
				american_soldiertype		airborne
				american_soldiervariation	normal, winter
				
				british_soldiertype		airborne, commando
				british_soldiervariation	normal, winter
				
				russian_soldiertype		conscript, veteran
				russian_soldiervariation	normal, winter
				
				german_soldiertype		waffen, wehrmacht, fallschirmjagercamo, fallschirmjagergrey, kriegsmarine
				german_soldiervariation		normal, winter

		Layout Image:
			game["layoutimage"] = "yourlevelname";
			This sets the image that is displayed when players use the "View Map" button in game.
			Create an overhead image of your map and name it "hud@layout_yourlevelname".
			Then move it to main\levelshots\layouts. This is generally done by taking a screenshot in the game.
			Use the outsideMapEnts console command to keep models such as trees from vanishing when noclipping outside of the map.
*/

/*QUAKED mp_deathmatch_spawn (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies at one of these positions.
*/

/*QUAKED mp_deathmatch_intermission (1.0 0.0 1.0) (-16 -16 -16) (16 16 16)
Intermission is randomly viewed from one of these positions.
Spectators spawn randomly at one of these positions.
*/

main()
{
	level.wawa_size = getCvarInt("scr_wawa_size");
	
	if(level.wawa_size == "" || level.wawa_size <= 0)
		level.wawa_size = 1250;
	
	level.mapname = getCvar("mapname");
	
	level.nowalls = level.mapname == "wawa_redux_american" || level.mapname == "wawa_redux_british" || level.mapname == "wawa_redux_russian" || level.mapname == "wawa_3daim_russian" || level.mapname == "wawa_3daim_american" || level.mapname == "wawa_3daim_british";
	
	//map specific settings take prioirty
	
	if(getCvar("scr_wawa_boundary_" + mapname) == "")
	{
	//map settings not set
		level.wawa_boundary = getCvar("scr_wawa_boundary");
		
		if(level.wawa_boundary == "0" || level.wawaboundary == "" || level.nowalls)
		{
			level.wawa_boundary = false;
		}
		else
		{
			level.wawa_boundary = true;
		}
	}
	else
	{
		level.wawa_boundary = getCvar("scr_wawa_boundary_" + mapname);
		
		if(level.wawa_boundary == "0")
		{
			level.wawa_boundary = false;
		}
		else
		{
			level.wawa_boundary = true;
		}
	}
	
	spawnpointname = "mp_deathmatch_spawn";
	level.wawa_origin = findBestSpawnSquare(spawnpointname, level.wawa_size);
	
	level.wawa_spawnpoints = getSpawnPointsInZone(level.wawa_origin, spawnpointname, level.wawa_size);
	
	if(!level.wawa_spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for(i = 0; i < level.wawa_spawnpoints.size; i++)
		level.wawa_spawnpoints[i] placeSpawnpoint();

	level.callbackStartGameType = ::Callback_StartGameType;
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;

	maps\mp\gametypes\_callbacksetup::SetupCallbacks();

	allowed[0] = "dm";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	maps\mp\gametypes\_rank_gmi::InitializeBattleRank();
	maps\mp\gametypes\_secondary_gmi::Initialize();
	
	if(getCvar("scr_wawa_debug") == "")		// Debug
		setCvar("scr_wawa_debug", "debug");
	level.wawa_debug = getCvar("scr_wawa_debug");
	
	if(getCvar("scr_wawa_timelimit") == "")		// Time limit per round
		setCvar("scr_wawa_timelimit", "30");
	else if(getCvarFloat("scr_wawa_timelimit") > 1440)
		setCvar("scr_wawa_timelimit", "1440");
	level.timelimit = getCvarFloat("scr_wawa_timelimit");
	setCvar("ui_wawa_timelimit", level.timelimit);
	makeCvarServerInfo("ui_wawa_timelimit", "30");
	
	if(getCvar("scr_wawa_roundtimelimit") == "")		// Time limit per round
		setCvar("scr_wawa_roundtimelimit", "30");
	else if(getCvarFloat("scr_wawa_roundtimelimit") > 1440)
		setCvar("scr_wawa_roundtimelimit", "1440");
	level.roundtimelimit = getCvarFloat("scr_wawa_roundtimelimit");
	setCvar("ui_wawa_roundtimelimit", level.roundtimelimit);
	makeCvarServerInfo("ui_wawa_roundtimelimit", "30");

	if(getCvar("scr_wawa_scorelimit") == "")		// Score limit per round
		setCvar("scr_wawa_scorelimit", "10");
	level.scorelimit = getCvarInt("scr_wawa_scorelimit");
	setCvar("ui_wawa_scorelimit", level.scorelimit);
	makeCvarServerInfo("ui_wawa_scorelimit", "10");
	
	if(getCvar("scr_wawa_roundlimit") == "")		// Number of round wins to win match
		setCvar("scr_wawa_roundlimit", "11");
	level.roundlimit = getCvarInt("scr_wawa_roundlimit");
	setCvar("ui_wawa_roundlimit", level.roundlimit);
	makeCvarServerInfo("ui_wawa_roundlimit", "11");
	
	if(getCvar("scr_wawa_queuetype") == "")		// Number of round wins to win match
		setCvar("scr_wawa_queuetype", "0"); //0 - first come, first serve, 1 round robin, 2 random
	level.queuetype = getCvarInt("scr_wawa_queuetype");
	setCvar("ui_wawa_queuetype", level.queuetype);
	makeCvarServerInfo("ui_wawa_queuetype", "0");
	
	if(getCvar("scr_wawa_rounds") == "")		// Total rounds per match
		setCvar("scr_wawa_rounds", "21");
	level.numrounds = getCvarInt("scr_wawa_rounds");
	setCvar("ui_wawa_rounds", level.numrounds);
	makeCvarServerInfo("ui_wawa_rounds", "21");
	if(level.numrounds < level.roundlimit)
		level.numrounds = level.roundlimit;
	
	if(getCvar("scr_forcerespawn") == "")		// Force respawning
		setCvar("scr_forcerespawn", "0");

	if(getCvar("scr_battlerank") == "")		
		setCvar("scr_battlerank", "1");	//default is ON
	level.battlerank = getCvarint("scr_battlerank"); 
	setCvar("ui_battlerank", level.battlerank);
	makeCvarServerInfo("ui_battlerank", "0");

	if(getCvar("scr_shellshock") == "")		// controls whether or not players get shellshocked from grenades or rockets
		setCvar("scr_shellshock", "1");
	setCvar("ui_shellshock", getCvar("scr_shellshock"));
	makeCvarServerInfo("ui_shellshock", "0");
			
	if(!isDefined(game["compass_range"]))		// set up the compass range.
		game["compass_range"] = 1024;		
	setCvar("cg_hudcompassMaxRange", game["compass_range"]);
	makeCvarServerInfo("cg_hudcompassMaxRange", "0");

	if(getCvar("scr_drophealth") == "")		// Free look spectator
		setCvar("scr_drophealth", "1");

	// turn off ceasefire
	level.ceasefire = 0;
	setCvar("scr_ceasefire", "0");

	killcam = getCvar("scr_killcam");
	if(killcam == "")				// Kill cam
		killcam = "1";
	setCvar("scr_killcam", killcam, true);
	level.killcam = getCvarInt("scr_killcam");
	
	if(!isDefined(game["state"]))
		game["state"] = "playing";
	if(!isDefined(game["matchstarted"]))
		game["matchstarted"] = false;
	if(!isDefined(game["matchstarting"]))
		game["matchstarting"] = false;
	if(!isDefined(game["timepassed"]))
		game["timepassed"] = 0;
	if(!isDefined(game["roundtimepassed"]))
		game["roundtimepassed"] = 0;
	// this is just to define this variable to other scripts that use it dont crash
	level.drawfriend = 0;
	
	level.QuickMessageToAll = true;
	level.mapended = false;
	level.healthqueue = [];
	level.healthqueuecurrent = 0;
	
	if(level.killcam >= 1)
		setarchive(true);

}

Callback_StartGameType()
{

////////// Added by AWE ///////////////
	maps\mp\gametypes\_awe::Callback_StartGameType();
///////////////////////////////////////

	level.awe_searchablebodies = 0;
	level.awe_teamplay = undefined;
	level.awe_spawnalliedname = "mp_deathmatch_spawn";
	level.awe_spawnaxisname = "mp_deathmatch_spawn";
	level.awe_spawnspectatorname = "mp_deathmatch_intermission";

	if(!isDefined(game["gamestarted"]))
	{
		
		// defaults if not defined in level script
		if(!isDefined(game["allies"]))
			game["allies"] = "american";
		if(!isDefined(game["axis"]))
			game["axis"] = "german";

		if(!isDefined(game["layoutimage"]))
			game["layoutimage"] = "default";
		layoutname = "levelshots/layouts/hud@layout_" + game["layoutimage"];
		precacheShader(layoutname);
		setCvar("scr_layoutimage", layoutname);
		makeCvarServerInfo("scr_layoutimage", "");

		// server cvar overrides
		if(getCvar("scr_allies") != "")
			game["allies"] = getCvar("scr_allies");
		if(getCvar("scr_axis") != "")
			game["axis"] = getCvar("scr_axis");

		game["menu_serverinfo"] = "serverinfo_dm";// + getCvar("g_gametype");
		game["menu_team"] = "team_" + game["allies"] + game["axis"];
		game["menu_weapon_allies"] = "weapon_" + game["allies"];
		game["menu_weapon_axis"] = "weapon_" + game["axis"];
		game["menu_viewmap"] = "viewmap";
		game["menu_callvote"] = "callvote";
		game["menu_quickcommands"] = "quickcommands";
		game["menu_quickstatements"] = "quickstatements";
		game["menu_quickresponses"] = "quickresponses";
		game["menu_quickvehicles"] = "quickvehicles";
		game["menu_quickrequests"] = "quickrequests";
		
		game["waitText"] = &"Waiting for challenger...";
		game["joinText"] = &"Press USE to join or MELEE to skip";
		game["rematchText"] = &"Press USE to play again or MELEE to skip";
		game["chooseText"] = &"Choose a new weapon or press USE to run it back";

		precacheString(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");
		precacheString(&"MPSCRIPT_KILLCAM");
		precacheString(&"GMI_MP_CEASEFIRE");
		precacheString(&"GMI_CTF_MATCHSTARTING");
		precacheString(game["waitText"]);
		precacheString(game["joinText"]);
		precacheString(game["rematchText"]);
		
		precacheMenu(game["menu_serverinfo"]);
		precacheMenu(game["menu_team"]);
		precacheMenu(game["menu_weapon_allies"]);
		precacheMenu(game["menu_weapon_axis"]);
		precacheMenu(game["menu_viewmap"]);
		precacheMenu(game["menu_callvote"]);
		precacheMenu(game["menu_quickcommands"]);
		precacheMenu(game["menu_quickstatements"]);
		precacheMenu(game["menu_quickresponses"]);
		precacheMenu(game["menu_quickvehicles"]);
		precacheMenu(game["menu_quickrequests"]);

		precacheShader("black");
		precacheShader("hudScoreboard_mp");
		precacheShader("gfx/hud/hud@mpflag_none.tga");
		precacheShader("gfx/hud/hud@mpflag_spectator.tga");
		precacheStatusIcon("gfx/hud/hud@status_dead.tga");
		precacheStatusIcon("gfx/hud/hud@status_connecting.tga");
		precacheItem("item_health");
		
		precacheShader("hudStopwatch");
		precacheShader("hudStopwatchNeedle");
		
		game["roundsplayed"] = 0;
		updateGameStatus("pregame");
		
		maps\mp\gametypes\_corrupt_killcam::corrupt_StartGameType();
		
	}
	game["gamestarted"] = true;

	maps\mp\gametypes\_teams::modeltype();
	maps\mp\gametypes\_teams::precache();
	
	maps\mp\gametypes\_teams::initGlobalCvars();
	maps\mp\gametypes\_teams::initWeaponCvars();
	maps\mp\gametypes\_teams::restrictPlacedWeapons();
	
	thread maps\mp\gametypes\_teams::updateGlobalCvars();
	thread maps\mp\gametypes\_teams::updateWeaponCvars();
	
	//Set up Smoke effect on invisble walls
	if(level.wawa_boundary)
	{
		level._boundaryFx = loadfx("fx/smoke/smoke_flamethrower.efx");
		level thread drawZoneSmoke(level.wawa_origin, level.wawa_size, 100); //"fx/smoke/smoke_flamethrower.efx"
	}

	setClientNameMode("auto_change");

	thread startGame();
	//thread addBotClients(); // For development testing
	thread updateGametypeCvars();
	thread checkActivePlayers();
	level thread updatePlayerQueue();

	if(!isDefined(game["queuepos"]) || level.queuetype == 0)
	{
		game["queuepos"] = 0;
	}
	else if(level.queuetype == 2)
	{
		game["queuepos"] = randomInt(level.playerqueue.size);
	}
	
}

Callback_PlayerConnect()
{
	self.statusicon = "gfx/hud/hud@status_connecting.tga";
	self waittill("begin");
	self.statusicon = "";

	iprintln(&"MPSCRIPT_CONNECTED", self);

	lpselfnum = self getEntityNumber();
	lpselfguid = self getGuid();
	logPrint("J;" + lpselfguid + ";" + lpselfnum + ";" + self.name + "\n");
	
	// set the cvar for the map quick bind
	self setClientCvar("g_scriptQuickMap", game["menu_viewmap"]);
	
	if(game["state"] == "intermission")
	{
		spawnIntermission();
		return;
	}

	level endon("intermission");

	// start the vsay thread
	self thread maps\mp\gametypes\_teams::vsay_monitor();
	
	if(!isdefined(self.pers["roundsWon"]))
		self.pers["roundsWon"] = 0;

	//Normal round started spawn
	/*if(isDefined(self.pers["team"]) && self.pers["team"] != "spectator")
	{
		self setClientCvar("ui_weapontab", "0");
		self.sessionteam = "none";

		spawnPlayer();
	
	} */
	if(game["starting"] || game["inprogress"]) //don't open menus on rounds in progess
	{
		if(isdefined(self.pers["weapon"]) && (self.pers["weapon"] == "player1" || self.pers["weapon"] == "player2"))
		{
			
			if( self.pers["weapon"] == "player1")
			{
				level.player1 = self;
				self.pers["weapon"] = game["weapon"];
				self.pers["team"] = game["team"];
				spawnPlayer("player1");
			}
			else if(self.pers["weapon"] == "player2")
			{
				level.player2 = self;
				self.pers["weapon"] = game["weapon"];
				self.pers["team"] = game["team"];
				spawnPlayer("player2");
			}
			self printDebug(level.player1.name + " and " + level.player2.name + " are wawaing","debug","self");
		}
		else
		{
			self.sessionteam = "spectator";

			SpawnSpectator();	
		}
		//updateGameStatus("inprogress");
	}
	else 
	{
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);
		self setClientCvar("ui_weapontab", "0");

		if(!isDefined(self.pers["skipserverinfo"]))
			self openMenu(game["menu_serverinfo"]);

		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";

		spawnSpectator();
	}
	
	level thread updatePlayerQueue();

	for(;;)
	{
		self waittill("menuresponse", menu, response);

		if(menu == game["menu_serverinfo"] && response == "close")
		{//Open the team menu if a wawa hasn't started yet
			self.pers["skipserverinfo"] = true;
			if(!game["starting"] && !game["inprogress"] && !game["searching"])
			{
				self openMenu(game["menu_team"]);
			}
			else //debug print game status otherwise
			{
				if(game["inprogress"])
					printDebug("wawa in progress...", "debug", "self");
				else if(game["searching"])
					printDebug("Awaiting challenger...", "debug", "self");
				else if(game["starting"])
					printDebug("round is about to start...","debug","self");
			}
		}

		if(response == "open" || response == "close")
			continue;

		if(menu == game["menu_team"])
		{
			switch(response)
			{
			case "allies":
			case "axis":
			case "autoassign":
				
				if(response == "autoassign")
				{
					teams[0] = "allies";
					teams[1] = "axis";
					response = teams[randomInt(2)];
				}

				if(response == self.pers["team"] && self.sessionstate == "playing")
					break;

				if(response != self.pers["team"] && self.sessionstate == "playing")
					self suicide();

				self notify("end_respawn");

				self.pers["team"] = response;
				self.pers["weapon"] = undefined;
				self.pers["savedmodel"] = undefined;

				// if there are weapons the user can select then open the weapon menu
				if ( isweaponavailable(response))
				{
					printDebug("Choosing Weapon...", "debug", "self");
					if(game["pregame"] || (game["postround"] && level.player1 == self))
					{
						if(response == "allies")
						{
							menu = game["menu_weapon_allies"];
						}
						else
						{
							menu = game["menu_weapon_axis"];
						}
				
						self setClientCvar("ui_weapontab", "1");
						self openMenu(menu);
					} else {
						printDebug("Awaiting challenger...", "debug", "self");
					}
				}
				else
				{
					self setClientCvar("ui_weapontab", "0");
					//self menu_spawn("none");
					continue;
				}
		
				self setClientCvar("g_scriptMainMenu", game["menu_team"]);
				break;

			case "spectator":
				if(self.pers["team"] != "spectator")
				{
					level thread updateActivePlayers();
					self.pers["team"] = "spectator";
					self.pers["weapon"] = undefined;
					self.pers["savedmodel"] = undefined;
					
					self.sessionteam = "spectator";
					self setClientCvar("g_scriptMainMenu", game["menu_team"]);
					self setClientCvar("ui_weapontab", "0");
					
					if(game["starting"] || game["pregame"])
					{
						if(isDefined(level.player1) && self == level.player1)
						{
							updateGameStatus("pregame");
						}
						if(isDefined(level.player2) && self == level.player2)
						{
							//Forfeit
							level.player2 = undefined;
							updateGameStatus("searching");
						}
						spawnSpectator();
					}
					else if(game["searching"])
					{
						if(isDefined(level.player1) && self == level.player1)
						{
							updateGameStatus("pregame");
						}
						if(isDefined(level.player2) && self == level.player2)
						{
							//Forfeit
							updateGameStatus("searching");
						}
					}
					
					spawnSpectator();
				}
				break;
				
			case "weapon":
				self.menuing = true;
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;

			case "viewmap":
				self openMenu(game["menu_viewmap"]);
				break;

			case "callvote":
				self openMenu(game["menu_callvote"]);
				break;
			}
		}
		
		else if(menu == game["menu_weapon_allies"] || menu == game["menu_weapon_axis"])
		{
			if(response == "team")
			{
				self.menuing = false;
				self openMenu(game["menu_team"]);
				continue;
			}
			else if(response == "viewmap")
			{
				self openMenu(game["menu_viewmap"]);
				continue;
			}
			else if(response == "callvote")
			{
				self openMenu(game["menu_callvote"]);
				continue;
			}

			if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
				continue;
			
			//if wawaing is in progress then don't bother with weapons, just announce wawaing is in progress and close menu
			if(game["inprogress"])
			{
				printDebug("wawa in progress...", "debug", "self");
			}
			else if(game["starting"] && isDefined(level.player1) && self != level.player1)
			{
				printDebug("round is about to start...", "debug", "self");
			}
			else if(game["searching"] && isDefined(level.player1) && self != level.player1 )
			{
				printDebug("Awaiting Challenger...", "debug", "self");
			}
			else if(game["postround"] && isDefined(level.player1) && level.player1 != self)
			{
				printDebug("round is over...", "debug", "self");
			}
			else			//mark player as menuing
			{
				
				self.menuing = true;
				
				weapon = self maps\mp\gametypes\_teams::restrict(response);

				if(weapon == "restricted")
				{
					self openMenu(menu);
					continue;
				}

				if(isDefined(self.pers["weapon"]) && self.pers["weapon"] == weapon)
					continue;

				menu_spawn(weapon);
			
			}
		}
		
		else if(menu == game["menu_viewmap"])
		{
			switch(response)
			{
			case "team":
				self openMenu(game["menu_team"]);
				break;

			case "weapon":
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;
				
			case "callvote":
				self openMenu(game["menu_callvote"]);
				break;
			}
		}
		else if(menu == game["menu_callvote"])
		{
			switch(response)
			{
			case "team":
				self openMenu(game["menu_team"]);
				break;
			
			case "weapon":
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;
				
			case "viewmap":
				self openMenu(game["menu_viewmap"]);
				break;
			}
		}
		else if(menu == game["menu_quickcommands"])
			maps\mp\gametypes\_teams::quickcommands(response);
		else if(menu == game["menu_quickstatements"])
			maps\mp\gametypes\_teams::quickstatements(response);
		else if(menu == game["menu_quickresponses"])
			maps\mp\gametypes\_teams::quickresponses(response);
		else if(menu == game["menu_quickvehicles"])
			maps\mp\gametypes\_teams::quickvehicles(response);
		else if(menu == game["menu_quickrequests"])
			maps\mp\gametypes\_teams::quickrequests(response);
	}
}

Callback_PlayerDisconnect()
{

	self cleanUpHud();
///// Added by AWE ////////
	self maps\mp\gametypes\_awe::PlayerDisconnect();
///////////////////////////

	iprintln(&"MPSCRIPT_DISCONNECTED", self);

	lpselfnum = self getEntityNumber();
	lpselfguid = self getGuid();
	logPrint("Q;" + lpselfguid + ";" + lpselfnum + ";" + self.name + "\n");
	
	self cleanupHud();
	
	if(self == level.player1)
	{
		updateGameStatus("pregame");
	}
	
	level thread updateActivePlayers();
}

cleanupHud()
{
	//destroy hud elements
	self.joinPrompt destroy();
    self.joinPrompt = undefined;
	self.waitPrompt destroy();
    self.waitPrompt = undefined;
	self.waitTimer destroy();
	self.waitTimer = undefined;
	self.choosePrompt destroy();
	self.choosePrompt = undefined;
	self.chooseTimer destroy();
	self.chooseTimer = undefined;
	p.joinTimer destroy();
	p.joinTimer = undefined;
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	
	if(self.sessionteam == "spectator")
		return;
	
	// dont take damage during ceasefire mode
	// but still take damage from ambient damage (water, minefields, fire)
	if(level.ceasefire && sMeansOfDeath != "MOD_EXPLOSIVE" && sMeansOfDeath != "MOD_WATER" && sMeansOfDeath != "MOD_TRIGGER_HURT")
		return;

	// Don't do knockback if the damage direction was not specified
	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	// Make sure at least 999 points of damage is done
	if(sWeapon == "colt_mp" || sWeapon == "tt33_mp" || sWeapon == "luger_mp" || sWeapon == "webley_mp")
	{
		if(sMeansOfDeath != "MOD_MELEE" || level.oitc_enhancedmelee )
			iDamage = 999;	
	}

	self maps\mp\gametypes\_shellshock_gmi::DoShellShock(sWeapon, sMeansOfDeath, sHitLoc, iDamage);

	// Do debug print if it's enabled
	if(getCvarInt("g_debugDamage"))
	{
		println("client:" + self getEntityNumber() + " health:" + self.health +
			" damage:" + iDamage + " hitLoc:" + sHitLoc);
	}

	// Apply the damage to the player
	self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);

////////////// Added by AWE //////////////////
	self maps\mp\gametypes\_awe::DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
//////////////////////////////////////////////

	if(self.sessionstate != "dead")
	{
		lpselfnum = self getEntityNumber();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpselfGuid = self getGuid();
		lpattackerteam = "";

		if(isPlayer(eAttacker))
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		logPrint("D;" + lpselfGuid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	}
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	self endon("spawned");

	if(self.sessionteam == "spectator")
		return;

/////////// Added by AWE ///////////
//	self thread maps\mp\gametypes\_awe::PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc);
////////////////////////////////////

	// If the player was killed by a head shot, let players know it was a head shot kill
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";

	// if this is a melee kill from a binocular then make sure they know that they are a loser
	if(sMeansOfDeath == "MOD_MELEE" && (sWeapon == "binoculars_artillery_mp" || sWeapon == "binoculars_mp") )
	{
		sMeansOfDeath = "MOD_MELEE_BINOCULARS";
	}
	
	// if this is a kill from the artillery binocs change the icon
	if(sMeansOfDeath != "MOD_MELEE_BINOCULARS" && sWeapon == "binoculars_artillery_mp" )
		sMeansOfDeath = "MOD_ARTILLERY";

	// send out an obituary message to all clients about the kill
////////// Removed by AWE ///////
	obituary(self, attacker, sWeapon, sMeansOfDeath);
/////////////////////////////////

	self.sessionstate = "dead";
	self.statusicon = "gfx/hud/hud@status_dead.tga";
	self.deaths++;

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpselfteam = "";
	lpselfguid = self getGuid();
	lpattackerteam = "";

	attackerNum = -1;
	if(isPlayer(attacker))
	{
		if(attacker == self) // killed himself
		{
			doKillcam = false;

			if(game["inprogress"])
				attacker.score--;
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;
			
			if(game["inprogress"])
			{
				attacker.score++;
				attacker checkScoreLimit();
			}
		}

		lpattacknum = attacker getEntityNumber();
		lpattackguid = attacker getGuid();
		lpattackname = attacker.name;
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;
		
		if(game["inprogress"])
			self.score--;

		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
	}
	
	logPrint("K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");

	// Stop thread if map ended on this death
	//if(level.mapended)
	//	return;
		
//	self updateDeathArray();

	// Make the player drop his weapon

///// Removed by AWE /////
//	self dropItem(self getcurrentweapon());
//////////////////////////

	// Make the player drop health
	if(game["inprogress"])
	{
		self dropHealth();

		self dropItem(self getcurrentweapon());
		
///// Removed by AWE /////
		body = self cloneplayer();
//////////////////////////
	}

	delay = 2;	// Delay the player becoming a spectator till after he's done dying
	wait delay;	// ?? Also required for Callback_PlayerKilled to complete before respawn/killcam can execute
	
	if((getCvarInt("scr_killcam") <= 0) || (getCvarInt("scr_forcerespawn") > 0) || level.roundended)
		doKillcam = false;
	
	if(doKillcam)
		self thread killcam(attackerNum, delay);
	else if(game["doFinalKillcam"])
	{
		if(!level.roundended)
		{
			self thread respawn();
		}
		else
		{
			//while(1)
			//{

				if(level.mapended)
					return;

				printDebug("doing final killcam", "info", "self");

				level endon("corrupt_killcam");

				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{	
					corruptPlayers = players[i];
					
					if(corruptPlayers == self)
						continue;

					corruptPlayers thread maps\mp\gametypes\_corrupt_killcam::corrupt_killcam(attackerNum, delay);

				}
			
				maps\mp\gametypes\_corrupt_killcam::corrupt_killcam(attackerNum, delay);
				level notify("corrupt_killcam_over");
			//}
		}
	}
}

// ----------------------------------------------------------------------------------
//	menu_spawn
//
// 		called from the player connect to spawn the player
// ----------------------------------------------------------------------------------
menu_spawn(weapon)
{
	
	printDebug("menu spawn", "debug", "self");
	if(isDefined(level.player1) && level.player1 != self)
	{
		weaponname = maps\mp\gametypes\_teams::getWeaponName(game["weapon"]);
		self iprintln(weaponname + " has been chosen as the current wawa weapon. Awaiting challenger...");
		return;
	}
	if(!isDefined(self.pers["weapon"]))
	{
		self.pers["weapon"] = weapon;
		game["weapon"] = weapon;
		level.player1 = self;
		printDebug("you are set to player 1", "debug", "self");
		printDebug("player 1 set to " + level.player1.name,"debug","level");
		game["team"] = self.pers["team"];
		spawnPlayer("player1");
		//find challenger
		//level thread findChallenger();
		updateGameStatus("searching");
		return;
	}
	self.pers["weapon"] = weapon;
	game["weapon"] = weapon;
	level.player1 = self;
	printDebug("you are set to player 1", "debug", "self");
	printDebug("player 1 set to " + level.player1.name,"debug","level");
	game["team"] = self.pers["team"];
	spawnPlayer("player1");
}

updateDeathArray()
{
	if(!isDefined(level.deatharray))
	{
		level.deatharray[0] = self.origin;
		level.deatharraycurrent = 1;
		return;
	}

	if(level.deatharraycurrent < 31)
		level.deatharray[level.deatharraycurrent] = self.origin;
	else
	{
		level.deatharray[0] = self.origin;
		level.deatharraycurrent = 1;
		return;
	}

	level.deatharraycurrent++;
}

spawnPlayer(playernum)
{
	self notify("spawned");
	self notify("end_respawn");

	resettimeout();

//	if(isDefined(self.shocked))
//	{
//		self stopShellshock();
//		self.shocked = undefined;
//	}

	self.sessionteam = "none";
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;
		
	// make sure that the client compass is at the correct zoom specified by the level
	self setClientCvar("cg_hudcompassMaxRange", game["compass_range"]);

	//spawnpointname = "mp_deathmatch_spawn";
	//spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM(level.wawa_spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

	self.statusicon = "";
	self.maxhealth = 100;
	self.health = self.maxhealth;

	self.pers["rank"] = maps\mp\gametypes\_rank_gmi::DetermineBattleRank(self);
	self.rank = self.pers["rank"];
	
	if(!isDefined(self.pers["savedmodel"]))
		maps\mp\gametypes\_teams::model();
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);

	// setup all the weapons
	if(self.pers["weapon"] == "player1" || self.pers["weapon"] == "player2")
		self.pers["weapon"] = game["weapon"];
	self maps\mp\gametypes\_loadout_gmi::PlayerSpawnLoadout();
	
	self.pers["weapon"] = playernum;
	
	self setClientCvar("cg_objectiveText", &"DM_KILL_OTHER_PLAYERS");

	// set the status icon if battlerank is turned on
	if(level.battlerank)
	{
		self.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(self);
	}	

	// setup the hud rank indicator
	self thread maps\mp\gametypes\_rank_gmi::RankHudInit();

	//monitor player to keep them in play area
	if(!level.nowalls)
		self thread monitorZone(level.wawa_origin, level.wawa_size);
}

spawnSpectator(origin, angles)
{
	self notify("spawned");
	self notify("end_respawn");
	
	resettimeout();

//	if(isDefined(self.shocked))
//	{
//		self stopShellshock();
//		self.shocked = undefined;
//	}

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	
	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);
	else
	{
		spawnpointname = "mp_deathmatch_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		if(isDefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}

	self setClientCvar("cg_objectiveText", &"DM_KILL_OTHER_PLAYERS");
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");
	
	resettimeout();

//	if(isDefined(self.shocked))
//	{
//		self stopShellshock();
//		self.shocked = undefined;
//	}

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;

	spawnpointname = "mp_deathmatch_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

respawn()
{
	self endon("end_respawn");
	
	firsttime = 0;
	if(getCvarInt("scr_forcerespawn") > 0)
	{
		self thread waitForceRespawnTime();
		self thread waitRespawnButton();
		self waittill("respawn");
	}
	else
	{
		self thread waitRespawnButton();
		self waittill("respawn");
	}

	self thread spawnPlayer(self.pers["weapon"]);
}

waitForceRespawnTime()
{
	self endon("end_respawn");
	self endon("respawn");

	wait getCvarInt("scr_forcerespawn");
	self notify("respawn");
}

waitRespawnButton()
{
	self endon("end_respawn");
	self endon("respawn");

	wait 0; // Required or the "respawn" notify could happen before it's waittill has begun

	if ( getcvar("scr_forcerespawn") == "1" )
		return;
		
	self.respawntext = newClientHudElem(self);
	self.respawntext.alignX = "center";
	self.respawntext.alignY = "middle";
	self.respawntext.x = 320;
	self.respawntext.y = 70;
	self.respawntext.archived = false;
	self.respawntext setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");

	thread removeRespawnText();
	thread waitRemoveRespawnText("end_respawn");
	thread waitRemoveRespawnText("respawn");

	while(self useButtonPressed() != true)
		wait .05;

	self notify("remove_respawntext");

	self notify("respawn");
}

removeRespawnText()
{
	self waittill("remove_respawntext");

	if(isDefined(self.respawntext))
		self.respawntext destroy();
}

waitRemoveRespawnText(message)
{
	self endon("remove_respawntext");

	self waittill(message);
	self notify("remove_respawntext");
}

killcam(attackerNum, delay)
{
	self endon("spawned");

//	previousorigin = self.origin;
//	previousangles = self.angles;

	// killcam
	if(attackerNum < 0)
		return;

	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.archivetime = delay + 7;
	
	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait 0.05;

	if(self.archivetime <= delay)
	{
		self.spectatorclient = -1;
		self.archivetime = 0;
		self.sessionstate = "dead";
		
		self thread respawn();
		return;
	}

	if(!isDefined(self.kc_topbar))
	{
		self.kc_topbar = newClientHudElem(self);
		self.kc_topbar.archived = false;
		self.kc_topbar.x = 0;
		self.kc_topbar.y = 0;
		self.kc_topbar.alpha = 0.5;
		self.kc_topbar setShader("black", 640, 112);
	}

	if(!isDefined(self.kc_bottombar))
	{
		self.kc_bottombar = newClientHudElem(self);
		self.kc_bottombar.archived = false;
		self.kc_bottombar.x = 0;
		self.kc_bottombar.y = 368;
		self.kc_bottombar.alpha = 0.5;
		self.kc_bottombar setShader("black", 640, 112);
	}

	if(!isDefined(self.kc_title))
	{
		self.kc_title = newClientHudElem(self);
		self.kc_title.archived = false;
		self.kc_title.x = 320;
		self.kc_title.y = 40;
		self.kc_title.alignX = "center";
		self.kc_title.alignY = "middle";
		self.kc_title.sort = 1; // force to draw after the bars
		self.kc_title.fontScale = 3.5;
	}
	self.kc_title setText(&"MPSCRIPT_KILLCAM");

	if ( getcvar("scr_forcerespawn") != "1" )
	{
		if(!isDefined(self.kc_skiptext))
		{
			self.kc_skiptext = newClientHudElem(self);
			self.kc_skiptext.archived = false;
			self.kc_skiptext.x = 320;
			self.kc_skiptext.y = 70;
			self.kc_skiptext.alignX = "center";
			self.kc_skiptext.alignY = "middle";
			self.kc_skiptext.sort = 1; // force to draw after the bars
		}
		self.kc_skiptext setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");
	}
	
	if(!isDefined(self.kc_timer))
	{
		self.kc_timer = newClientHudElem(self);
		self.kc_timer.archived = false;
		self.kc_timer.x = 320;
		self.kc_timer.y = 428;
		self.kc_timer.alignX = "center";
		self.kc_timer.alignY = "middle";
		self.kc_timer.fontScale = 3.5;
		self.kc_timer.sort = 1;
	}
	self.kc_timer setTenthsTimer(self.archivetime - delay);

	self thread spawnedKillcamCleanup();
	self thread waitSkipKillcamButton();
	self thread waitKillcamTime();
	self waittill("end_killcam");

	self removeKillcamElements();

	self.spectatorclient = -1;
	self.archivetime = 0;
	self.sessionstate = "dead";
	
	//self thread spawnSpectator(previousorigin + (0, 0, 60), previousangles);
	self thread respawn();
}

waitKillcamTime()
{
	self endon("end_killcam");

	wait(self.archivetime - 0.05);
	self notify("end_killcam");
}

waitSkipKillcamButton()
{
	self endon("end_killcam");

	while(self useButtonPressed())
		wait .05;

	while(!(self useButtonPressed()))
		wait .05;

	self notify("end_killcam");
}

removeKillcamElements()
{
	if(isDefined(self.kc_topbar))
		self.kc_topbar destroy();
	if(isDefined(self.kc_bottombar))
		self.kc_bottombar destroy();
	if(isDefined(self.kc_title))
		self.kc_title destroy();
	if(isDefined(self.kc_skiptext))
		self.kc_skiptext destroy();
	if(isDefined(self.kc_timer))
		self.kc_timer destroy();
}

spawnedKillcamCleanup()
{
	self endon("end_killcam");

	self waittill("spawned");
	self removeKillcamElements();
}

/**
 * monitorZone
 *
 * Runs in a player’s thread, ends when they respawn again.
 * Teleports the player back inside the [zoneOrigin, zoneOrigin+squareSize] square
 * whenever they step outside, effectively creating invisible walls.
 *
 * @param zoneOrigin   Vector (X,Y,Z) of the lower-left corner of your zone
 * @param squareSize   Width/depth of the square in world units
 */
monitorZone(zoneOrigin, squareSize)
{
    self endon("disconnect");  // stop if they quit
    self endon("spawned");     // stop when they respawn

    // precompute zone extents
    minX = zoneOrigin[0];
    minY = zoneOrigin[1];
    maxX = minX + squareSize;
    maxY = minY + squareSize;
	i = 0;
    while (1)
    {
        wait 0.05;  // check 20 times a second

        pos = self.origin;
        x = pos[0]; y = pos[1]; z = pos[2];

        // clamp X/Y to the zone
        if(x < minX) 
			clampedX = minX;
		else if(x > maxX)
			clampedX = maxX;
		else
			clampedX = x;
		
        if(y < minY)
			clampedY = minY;
		else if(y > maxY)
			clampedY = maxY;
		else
			clampedY = y;

        // if they’ve stepped outside, teleport them back
        if (clampedX != x || clampedY != y)
        {
            self setorigin((clampedX, clampedY, z));
         	
			//dont spam notifications
			if(!isDefined(self.oobmessage))
			{
				self.oobmessage = "OOB X: " + x + " Y: " + y;
				printDebug(self.oobmessage, "debug", "self");
				i = 0;
			}
        }
		i++;
		if(i > 20)
			self.oobmessage = undefined;
    }
}


startGame()
{
	
	level.roundstarted = false;
	level.roundended = false; 
	
	if(!isdefined(game["starttime"]))
		game["starttime"] = getTime();
	game["roundstarttime"] = getTime();
	timepassed = (getTime() - game["starttime"]) / 1000;
	roundtimepassed = (getTime() - game["roundstarttime"]) / 1000;
	game["timepassed"] = timepassed / 60.0;
	game["roundtimepassed"] = roundtimepassed / 60.0;
	
	thread startRound();
	if(game["inprogress"])
	{
		if(level.roundtimelimit > 0)
		{
			level.clock = newHudElem();
			level.clock.x = 320;
			level.clock.y = 460;
			level.clock.alignX = "center";
			level.clock.alignY = "middle";
			level.clock.font = "bigfixed";
			level.clock setTimer(level.roundtimelimit * 60.0);
		}
		
		if(level.timelimit > 0)
		{
		
			level.gameclock = newHudElem();
			level.gameclock.x = 56;
			level.gameclock.y = 365;

			level.gameclock.alignX = "center";
			level.gameclock.alignY = "middle";
			level.gameclock.font = "bigfixed";
			level.gameclock setTimer((level.timelimit * 60.0) - (game["timepassed"] * 60));

			level.gameclock.color = (1, 1, 1);
			level.gameclock.alpha = 0.6;
		}
		
		for(;;)
		{
			if(level.roundended)
				return;
			checkRoundTimeLimit();
			checkTimeLimit();
			wait 1;
		}
	}
	else {
		if(level.timelimit > 0)
		{
			level.clock = newHudElem();
			level.clock.x = 320;
			level.clock.y = 460;
			level.clock.alignX = "center";
			level.clock.alignY = "middle";
			level.clock.font = "bigfixed";
			level.clock setTimer((level.timelimit * 60.0) - (game["timepassed"] * 60));
		}
		
		for(;;)
		{
			if(level.roundended)
				return;
			checkTimeLimit();
			wait 1;
		}
	}
}

endMap(method)
{

////// Added by AWE ///////////
	maps\mp\gametypes\_awe::endMap();
/////////////////////////////////

	level notify("End Map");
	level thread resetScores();
	game["state"] = "intermission";
	level.roundended = true;
	level notify("intermission");

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isDefined(player.pers["team"]) && player.pers["team"] == "spectator")
			continue;
		
		player.score = player.pers["roundsWon"];

		if(!isDefined(highscore))
		{
			highscore = player.score;
			playername = player;
			name = player.name;
			guid = player getGuid();
			continue;
		}

		if(player.score == highscore)
			tied = true;
		else if(player.score > highscore)
		{
			tied = false;
			highscore = player.score;
			playername = player;
			name = player.name;
			guid = player getGuid();
		}
	}

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player closeMenu();
		player setClientCvar("g_scriptMainMenu", "main");

		if(isDefined(tied) && tied == true)
			player setClientCvar("cg_objectiveText", &"MPSCRIPT_THE_GAME_IS_A_TIE");
		else if(isDefined(playername))
			player setClientCvar("cg_objectiveText", &"MPSCRIPT_WINS", playername);
		
		player spawnIntermission();
	}
	if(isDefined(name))
		logPrint("W;;" + guid + ";" + name + "\n");
	wait 10;
	exitLevel(false);
}

checkTimeLimit( endmap )
{
		
	if(!isdefined(endmap))
		endmap = false;
	
	if(level.timelimit <= 0)
		return;

	timepassed = (getTime() - game["starttime"]) / 1000;
	game["timepassed"] = timepassed / 60.0;

	if(game["timepassed"] < level.timelimit)
		return;

	if(level.mapended)
		return;
	
	if(!game["matchstarted"])
	{
		iprintln(&"MPSCRIPT_TIME_LIMIT_REACHED");
		level thread endMap("time");
	}
	
	if(endmap)
	{
		level.mapended = true;

		iprintln(&"MPSCRIPT_TIME_LIMIT_REACHED");
		level thread endMap("time");
	}
	else
	{
		level thread endRound("time");
	}
}

checkRoundTimeLimit()
{
	if(level.roundtimelimit <= 0)
		return;

	if(isDefined(level.roundended) && level.roundended == true)
		return;

	timepassed = (getTime() - game["roundstarttime"]) / 1000;
	game["roundtimepassed"] = timepassed / 60.0;

	if(game["roundtimepassed"] < level.roundtimelimit)
		return;

	if(level.mapended)
		return;
	//level.roundended = true;

	iprintln(&"MPSCRIPT_TIME_LIMIT_REACHED");
	level thread endRound("time");
}
checkScoreLimit()
{
	if(level.scorelimit <= 0)
		return;

	if(self.score < level.scorelimit)
		return;

	if(level.mapended)
		return;

	iprintln(&"MPSCRIPT_SCORE_LIMIT_REACHED");
	level thread endRound("score");
}

// ----------------------------------------------------------------------------------
//	checkRoundLimit
//
// 		Checks to see if the round limit has been hit and ends the map.
// ----------------------------------------------------------------------------------
checkRoundLimit()
{
	printDebug("checking round limits", "info", "level");
	flag = true;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isDefined(player.pers["team"]) && player.pers["team"] == "spectator")
			continue;
		
		if(player.pers["roundsWon"] >= level.roundlimit)
		{
			flag = false;
			break;
		}
	}
	
	if(game["roundsplayed"] >= level.numrounds)
		flag = false;
	
	if(flag)
		return;
	
	if(level.roundlimit <= 0)
		return;
	
	//if(game["roundsplayed"] < level.roundlimit)
	//	return;
	
	if(level.mapended)
		return;
	level.mapended = true;

	iprintln(&"MPSCRIPT_ROUND_LIMIT_REACHED");
	thread endMap();

	// dont return immediatly need time for the calling loop to be killed
	wait(1);
}

updateGametypeCvars()
{
	for(;;)
	{
		ceasefire = getCvarint("scr_ceasefire");

		// if we are in cease fire mode display it on the screen
		if (ceasefire != level.ceasefire)
		{
			level.ceasefire = ceasefire;
			if ( ceasefire )
			{
				level thread maps\mp\_util_mp_gmi::make_permanent_announcement(&"GMI_MP_CEASEFIRE", "end ceasefire", 220, (1.0,0.0,0.0));			
			}
			else
			{
				level notify("end ceasefire");
			}
		}

		// check all the players for rank changes
		if ( getCvarint("scr_battlerank") )
			maps\mp\gametypes\_rank_gmi::CheckPlayersForRankChanges();

		debug = getCvar("scr_wawa_debug");	// Debug
		if(level.wawa_debug != debug)
		{
			level.wawa_debug = debug;
			setCvar("scr_wawa_debug", level.wawa_debug);
		}

		timelimit = getCvarFloat("scr_wawa_timelimit");
		if(level.timelimit != timelimit)
		{
			if(timelimit > 1440)
			{
				timelimit = 1440;
				setCvar("scr_wawa_timelimit", "1440");
			}

			level.timelimit = timelimit;
			setCvar("ui_wawa_timelimit", level.timelimit);

			if(level.timelimit > 0)
			{
				if(game["inprogress"])
				{
					if(!isDefined(level.gameclock))
					{
						level.gameclock = newHudElem();
						level.gameclock.x = 56;
						level.gameclock.y = 365;

						level.gameclock.alignX = "center";
						level.gameclock.alignY = "middle";
						level.gameclock.font = "bigfixed";

						level.gameclock.color = (1, 1, 1);
						level.gameclock.alpha = 0.6;
					}
					level.gameclock setTimer((level.timelimit * 60.0) - (game["timepassed"] * 60));
				}
				else 
				{
					if(!isDefined(level.clock))
					{
						level.clock = newHudElem();
						level.clock.x = 320;
						level.clock.y = 460;
						level.clock.alignX = "center";
						level.clock.alignY = "middle";
						level.clock.font = "bigfixed";
					}
					level.clock setTimer((level.timelimit * 60.0) - (game["timepassed"] * 60));
				}
			}
			else
			{
				if(game["inprogress"])
				{
					if(isDefined(level.gameclock))
						level.gameclock destroy();
				}
				else
				{
					if(isDefined(level.clock))
						level.clock destroy();
				}
			}

			checkTimeLimit();
		}
		
		roundtimelimit = getCvarFloat("scr_wawa_roundtimelimit");
		if(level.roundtimelimit != roundtimelimit)
		{
			if(roundtimelimit > 1440)
			{
				roundtimelimit = 1440;
				setCvar("scr_wawa_roundtimelimit", "1440");
			}

			level.roundtimelimit = roundtimelimit;
			setCvar("ui_wawa_roundtimelimit", level.roundtimelimit);
			game["roundstarttime"] = getTime();

			if(level.roundtimelimit > 0)
			{
				if(game["inprogress"])
				{
					if(!isDefined(level.clock))
					{
						level.clock = newHudElem();
						level.clock.x = 320;
						level.clock.y = 440;
						level.clock.alignX = "center";
						level.clock.alignY = "middle";
						level.clock.font = "bigfixed";
					}
					level.clock setTimer(level.roundtimelimit * 60);
				}
			}
			else
			{
				if(game["inprogress"])
				{
					if(isDefined(level.clock))
						level.clock destroy();
				}
			}

			checkRoundTimeLimit();
		}

		scorelimit = getCvarInt("scr_wawa_scorelimit");
		if(level.scorelimit != scorelimit)
		{
			level.scorelimit = scorelimit;
			setCvar("ui_wawa_scorelimit", level.scorelimit);

			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
				players[i] checkScoreLimit();
		}
		
		roundlimit = getCvarInt("scr_wawa_roundlimit");
		if(level.roundlimit != roundlimit)
		{
			level.roundlimit = roundlimit;
			setCvar("ui_wawa_roundlimit", level.roundlimit);

			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
				players[i] checkRoundLimit();
		}
		
		numrounds = getCvarInt("scr_wawa_rounds");
		if(level.numrounds != numrounds)
		{
			level.numrounds = numrounds;
			setCvar("ui_wawa_rounds", level.numrounds);

			if(game["roundsplayed"] > level.numrounds)
			{
				iprintln(&"MPSCRIPT_ROUND_LIMIT_REACHED");
				endMap();
			}
		}

		killcam = getCvarInt("scr_killcam");
		if (level.killcam != killcam)
		{
			level.killcam = getCvarInt("scr_killcam");
			if(level.killcam >= 1)
				setarchive(true);
			else
				setarchive(false);
		}
		
		battlerank = getCvarint("scr_battlerank");
		if(level.battlerank != battlerank)
		{
			level.battlerank = battlerank;
			
			// battle rank has precidence over draw friend
			if(level.battlerank)
			{
				// for all living players, show the appropriate headicon
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
			{
					// setup the hud rank indicator
					player thread maps\mp\gametypes\_rank_gmi::RankHudInit();

					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
					{
						player.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(player);
					}
				}
			}
		}
		wait 1;
	}
}

dropHealth()
{
	if ( !getcvarint("scr_drophealth") )
		return;
		
//// Added by AWE ////
	if(isdefined(self.awe_nohealthpack))
		return;
	self.awe_nohealthpack = true;
//////////////////////

	if(isDefined(level.healthqueue[level.healthqueuecurrent]))
		level.healthqueue[level.healthqueuecurrent] delete();
	
	level.healthqueue[level.healthqueuecurrent] = spawn("item_health", self.origin + (0, 0, 1));
	level.healthqueue[level.healthqueuecurrent].angles = (0, randomint(360), 0);

	level.healthqueuecurrent++;
	
	if(level.healthqueuecurrent >= 16)
		level.healthqueuecurrent = 0;
}

addBotClients()
{
	wait 5;

	for(;;)
	{
		if(getCvarInt("scr_numbots") > 0)
			break;
		wait 1;
	}

	iNumBots = getCvarInt("scr_numbots");
	for(i = 0; i < iNumBots; i++)
	{
		ent[i] = addtestclient();
		wait 0.5;

		if(isPlayer(ent[i]))
		{
			if(i & 1)
			{
				ent[i] notify("menuresponse", game["menu_team"], "axis");
				wait 0.5;
				//ent[i] notify("menuresponse", game["menu_weapon_axis"], "kar98k_mp");
			}
			else
			{
				ent[i] notify("menuresponse", game["menu_team"], "allies");
				wait 0.5;
				//ent[i] notify("menuresponse", game["menu_weapon_allies"], "springfield_mp");
			}
		}
	}
}

checkActivePlayers()
{
	level endon("End Map");
	
	wait 1; //wait a second to let players join
	for(;;)
	{
		if(level.mapended)
			return;
		
		//printDebug("checking active players", "info","level");
		
		updateActivePlayers();
		
		if(level.roundstarted && !level.roundended)
		{
			//printDebug(level.activePlayers.size + " active players", "info", "level");
			
			if(level.activePlayers.size <= 1)
				level thread endRound("forfiet");
		}
		wait 1;
	}
	
}

updateActivePlayers()
{
	activePlayers = [];
	
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isDefined(player.pers["team"]) && player.pers["team"] == "spectator")
			continue;

		activePlayers[activePlayers.size] = player;
	}
	level.activePlayers = activePlayers;
}

// ----------------------------------------------------------------------------------
//	
//
// 		Displays the match starting message and a timer.  Then when the timer
//		is done the map is restarted.
// ----------------------------------------------------------------------------------
RestartMap()
{
	level endon("kill_startround");
	
	// if the match is already starting then do not restart
	if (game["matchstarting"] || level.mapended)
		return;
		
	game["matchstarting"] = true;
	
	if(game["matchstarted"])
		announceMessage("Starting Next Round...","level",true);
	else
		announceMessage(&"GMI_CTF_MATCHSTARTING", "level", true);
	//level notify("cleanup match starting");

	if(!isDefined(level.clock))
	{
		level.clock = newHudElem();
		level.clock.x = 320;
		level.clock.y = 460;
		level.clock.alignX = "center";
		level.clock.alignY = "middle";
		level.clock.font = "bigfixed";
		level.clock setTimer((level.timelimit * 60.0) - (game["timepassed"] * 60));
	}
	
	
	time = 5;//getCvarInt("scr_ctf_startrounddelay");
	
	if ( time < 1 )
		time = 1;
/*
	if ( isDefined(level.victory_image) )
	{
		level.victory_image destroy();
		level.victory_image = undefined;
	}
	*/
	
	// give all of the players clocks to count down until the round starts
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		if ( isDefined(player.pers["team"]) && player.pers["team"] == "spectator")
			continue;
			
		player stopwatch_start("match_start", time);
	}
	
	wait (time);

	if ( level.mapended )
		return;
		
	game["matchstarted"] = true;
	updateGameStatus("inprogress");
	game["matchstarting"] = false;
	game["state"] = "playing";
	
	if ( !level.mapended )
	{
		thread resetScores();
	}

	level notify("cleanup match starting");
	map_restart(true);
}
// ----------------------------------------------------------------------------------
//	startRound
//
// 		Starts the round.  Initializes all of the players
// ----------------------------------------------------------------------------------
startRound()
{	
	// round does not start until the match starts
	if ( !game["matchstarted"] )
		return;
		
	level.roundstarted = true;
	level.roundended = false;
	
	thread maps\mp\gametypes\_teams::sayMoveIn(); 

}

// ----------------------------------------------------------------------------------
//	resetScores
//
// 		Resets all of the scores
// ----------------------------------------------------------------------------------
resetScores()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player.pers["score"] = 0;
		player.pers["deaths"] = 0;
	}
	
	if (level.battlerank)
	{
		maps\mp\gametypes\_rank_gmi::ResetPlayerRank();
	}
}
// ----------------------------------------------------------------------------------
//	endRound
//
// 		Ends the round
// ----------------------------------------------------------------------------------
endRound(winner)
{
	level endon("kill_endround");
	
	if(isDefined(level.clock))
		level.clock destroy();
				
	if(level.roundended)
		return;
		
	if ( game["matchstarted"] )
		level.roundended = true;


	if((winner != "time" && winner != "forfiet") && !level.mapended)
	{
		printDebug("all players eliminated","info","level");
		level waittill("corrupt_killcam_over");
		level.roundended = true;
	}
 
	level.roundstarted = false;
	
	// End threads and remove related hud elements and objectives
	level notify("End of Round");
	
	
	game["roundsplayed"]++;
	printDebug("rounds played = " + game["roundsplayed"], "info", "level");
	updateGameStatus("postround");
	if(game["matchstarted"])
	{
		
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if(isDefined(player.pers["team"]) && player.pers["team"] == "spectator")
				continue;
			else
				player.sessionstate = "spectator";
			

			if(!isDefined(highscore))
			{
				highscore = player.score;
				playername = player;
				name = player.name;
				guid = player getGuid();
				continue;
			}

			if(player.score == highscore)
				tied = true;
			else if(player.score > highscore)
			{
				tied = false;
				highscore = player.score;
				playername = player;
				name = player.name;
				guid = player getGuid();
			}
		}
		if(!tied)
		{
			playername.pers["roundsWon"]++;
			winner = playername;
			announceScores(playername);
		}
		else
		{
			announceMessage("Round Draw","level",true);
			if(!isDefined(level.player1))
				printDebug("why tf is player1 undefined", "info", "level");
			winner = level.player1;
		}
		
		if ( !level.mapended )
			checkRoundLimit();
	}
	
	if(winner != "time" && winner != "forfiet")
	{
		level.player1 = winner;
		printDebug("player 1 set to " + level.player1.name,"info","level");
	}
	
	printDebug("no one over the round limit yet", "info", "level");
	
	game["timepassed"] = game["timepassed"] + ((getTime() - game["starttime"]) / 1000) / 60.0;
	println("timepassed " + game["timepassed"]);
	
	// call these checks before calling the score resetting
	checkTimeLimit(true);
	
	printDebug("time and score limits not met", "info", "level");
	
	if(level.mapended)
		return;
		
	printDebug("restarting map in a sec or two", "info", "level");
	
	printDebug("going to ask " + winner + " for a rematch", "info", "level");
	
	if(!isDefined(winner))
		thread RestartMap();
	else
		askForRematch(winner);
}
// ----------------------------------------------------------------------------------
//	clock_start
//
// 	 	starts the hud clock for the player if the reason is good enough
// ----------------------------------------------------------------------------------
stopwatch_start(reason, time)
{
	make_clock = false;

	// if we are not waiting for a match start or another match start comes in go ahead and make a new one
	if ( !isDefined( self.stopwatch_reason ) || reason == "match_start" )
	{
		make_clock = true;
	}
	
	if ( make_clock )
	{
		if(isDefined(self.stopwatch))
		{
			thread stopwatch_delete("do_it");
		}
		
		self.stopwatch = newClientHudElem(self);
		maps\mp\_util_mp_gmi::InitClock(self.stopwatch, time);
		self.stopwatch.archived = false;
		
		self.stopwatch_reason = reason;
		
		self thread stopwatch_cleanup(reason, time);
		
		// if this is a match start
		if ( reason == "match_start" )
		{
			self thread stopwatch_waittill_killrestart(reason);
		}
	}
}

// ----------------------------------------------------------------------------------
//	stopwatch_delete
//
// 	 	destroys the hud stopwatch for the player if the reason is good enough
// ----------------------------------------------------------------------------------
stopwatch_delete(reason)
{
	self endon("stop stopwatch cleanup");

	if(!isDefined(self.stopwatch))
		return;
	
	delete_it = false;
	
	if (reason == "spectator" || reason == "do_it" || reason == self.stopwatch_reason)
	{
		self.stopwatch_reason = undefined;
		self.stopwatch destroy();
		self notify("stop stopwatch cleanup");
	}
}

// ----------------------------------------------------------------------------------
//	stopwatch_cleanup_respawn
//
// 	 	should only be called by stopwatch_start
// ----------------------------------------------------------------------------------
stopwatch_cleanup(reason, time)
{
	self endon("stop stopwatch cleanup");
	wait (time);

	stopwatch_delete(reason);
}

// ----------------------------------------------------------------------------------
//	stopwatch_cleanup_respawn
//
// 	 	should only be called by stopwatch_start
// ----------------------------------------------------------------------------------
stopwatch_waittill_killrestart(reason)
{
	self endon("stop stopwatch cleanup");
	level waittill("kill_startround");

	stopwatch_delete(reason);
}

/**
 * findBestSpawnSquare
 *
 * @param spawnPointClassname  The classname your gametype uses for spawns
 *                             (e.g. "mp_deathmatch_spawn", "mp_searchanddestroy_spawn_allied", etc.).
 * @param squareSize           The width/depth of the square in world units (default = 1250).
 * @return                     A vector (X,Y,Z) giving the lower-left corner of the densest square.
 */
findBestSpawnSquare(spawnPointClassname, squareSize)
{
    // default to 1250 if no size passed in
    if (!isDefined(squareSize) || squareSize <= 0)
        squareSize = 1250;

    // grab all of the spawn entities on this map
    spawnPoints = getentarray(spawnPointClassname, "classname");
    if (spawnPoints.size == 0)
        maps\mp\_utility::error("findBestSpawnSquare: no spawnpoints named "  + spawnPointClassname);

    // compute the bounding box of all spawn points
    minX = spawnPoints[0].origin[0]; maxX = spawnPoints[0].origin[0];
    minY = spawnPoints[0].origin[1]; maxY = spawnPoints[0].origin[1];
    for (i = 1; i < spawnPoints.size; i++)
    {
        pos = spawnPoints[i].origin;
        if (pos[0] < minX) minX = pos[0];
        if (pos[1] < minY) minY = pos[1];
        if (pos[0] > maxX) maxX = pos[0];
        if (pos[1] > maxY) maxY = pos[1];
    }

    bestCount  = -1;
    bestOrigin = (minX, minY, 0);

    // sweep a grid of squareSize × squareSize
    for (x = minX; x <= maxX; x += squareSize)
    {
        for (y = minY; y <= maxY; y += squareSize)
        {
            count = 0;
            // count how many spawns fall inside [x..x+size) × [y..y+size)
            for (j = 0; j < spawnPoints.size; j++)
            {
                p = spawnPoints[j].origin;
                if (p[0] >= x && p[0] <  x + squareSize
                 && p[1] >= y && p[1] <  y + squareSize)
                {
                    count++;
                }
            }

            // if this square is denser than any before, remember it
            if (count > bestCount)
            {
                bestCount  = count;
                bestOrigin = (x, y, 0);
            }
        }
    }

    return bestOrigin;
}

/**
 * getSpawnPointsInZone
 *
 * @param zoneOrigin             Vector (X,Y,Z) of the lower-left corner of your square
 * @param spawnPointClassname    The classname to look for (e.g. "mp_deathmatch_spawn")
 * @param squareSize             The width/depth of the square in world units (e.g. 1250)
 * @return                       An array of entities whose origin is within the square
 */
getSpawnPointsInZone(zoneOrigin, spawnPointClassname, squareSize)
{
    // grab all spawn entities of that classname
    allSpawns = getentarray(spawnPointClassname, "classname");
    inZone    = [];                     // start empty

    // define zone bounds
    minX = zoneOrigin[0];
    minY = zoneOrigin[1];
    maxX = minX + squareSize;
    maxY = minY + squareSize;

    // filter
    for (i = 0; i < allSpawns.size; i++)
    {
        pos = allSpawns[i].origin;
        if (pos[0] >= minX && pos[0] <  maxX
         && pos[1] >= minY && pos[1] <  maxY)
        {
            inZone[inZone.size] = allSpawns[i];
        }
    }

    return inZone;
}

/**
 * drawZoneSmoke
 *
 * @param zoneOrigin  lower-left of square
 * @param squareSize  side length
 * @param spacing     how far apart to place each puff
 * @param fxName      path to the .efx file (e.g. "fx/particles/mp_boundary_smoke.efx")
 */
drawZoneSmoke(zoneOrigin, squareSize, spacing)
{
    // preload once
    if (!isDefined(spacing) || spacing < 100)
        spacing = 100;

    minX = zoneOrigin[0];
    minY = zoneOrigin[1];
    maxX = minX + squareSize;
    maxY = minY + squareSize;
	
	while (true) //play effect on repeat for the whole time
	{
		// along each edge
		for (x = minX; x <= maxX; x += spacing)
		{
			z = getGroundHeight(x,minY);
			playfx(level._boundaryFx, (x,    minY, z));
			z = getGroundHeight(x,maxY);
			playfx(level._boundaryFx, (x,    maxY, z));
		}
		for (y = minY; y <= maxY; y += spacing)
		{
			z = getGroundHeight(minX, y);
			playfx(level._boundaryFx, (minX, y,    z));
			z = getGroundHeight(maxX, y);
			playfx(level._boundaryFx, (maxX, y,    z));
		}
		wait 1;
	}
}
/**
 * getGroundHeight
 *
 * @param xy            Vector (X,Y,?) — we'll ignore the Z component
 * @param startZ        How high above the tallest brush you want to start the trace
 * @param maxFallDist   How far down to trace (must exceed the deepest pit on your map)
 * @return              The Z coordinate of the first surface below (xy,startZ)
 */
getGroundHeight(x,y)
{
	startZ = 2000;
	maxFallDist = 4000;
    // build our start/end positions
    startPos = ( x, y, startZ );
    endPos   = ( x, y, startZ - maxFallDist );
    
    // fire a “bullet” straight down — false = don’t predict, undefined = hit anything
    trace = bulletTrace(startPos, endPos, false, undefined);
    
    if (trace["fraction"] < 1)
    {
        // we hit something — return the Z of the impact point
        return trace["position"][2];
    }
    else
    {
        // no hit (unlikely if maxFallDist is big enough) — just fall back to 40 (ground height for harbor)
        return 40;
    }
}

/**
 * updatePlayerQueue
 *
 * Builds/maintains level.playerqueue in connection order:
 *   1) Drops any players who have disconnected
 *   2) Appends any newly-connected players at the end
 * Sets level.playerqueue to the result and returns it.
 */
updatePlayerQueue()
{
    // initialize internal queue if needed
    if (!isDefined(level.playerqueue))
        level.playerqueue = [];

    // grab all currently connected players
    allPlayers = getentarray("player", "classname");

    // 1) keep in-order only those still connected
    newQueue = [];
    for (i = 0; i < level.playerqueue.size; i++)
    {
        p = level.playerqueue[i];
        // check if p is still in allPlayers
        for (j = 0; j < allPlayers.size; j++)
            if (allPlayers[j] == p)
            {
                newQueue[newQueue.size] = p;
                break;
            }
    }

    // 2) append any players not yet in newQueue
    for (i = 0; i < allPlayers.size; i++)
    {
        p = allPlayers[i];
		
        found = false;
        for (j = 0; j < newQueue.size; j++)
            if (newQueue[j] == p)
            {
                found = true;
                break;
            }
        if (!found)
            newQueue[newQueue.size] = p;
    }

    // store and expose
    level.playerqueue = newQueue;
    return newQueue;
}

/**
 * announcePlayerQueue
 *
 * Builds a human-readable list of names from level.playerqueue
 * (or notes that it’s empty), and prints it to every connected player.
 */
announcePlayerQueue()
{
	msg = "debug: no message set";
    // Ensure the queue exists
    if (!isDefined(level.playerqueue) || level.playerqueue.size == 0)
    {
        msg = "Player queue is empty.";
    }
    else
    {
        // Build a comma-separated list of player names
        msg = "Queue: ";
        for (i = 0; i < level.playerqueue.size; i++)
        {
            p = level.playerqueue[i];
            name = p.name;  // client’s in-game name
            if (i > 0)
                msg += ", ";
            msg += name;
        }
    }

    // Send the message to every connected client
    players = getentarray("player", "classname");
    for (i = 0; i < players.size; i++)
    {
       players[i] iprintlnbold(msg);
    }

    return msg;
}

runReccuringAnnouncement()
{

	level endon("endmap");
	
	while(true){
	
		wait 10;
		
		announcePlayerQueue();
	}
}

/**
 * closeAllMenus
 *
 * Iterates level.playerqueue and forces every client’s menu to close.
 */
closeAllMenus()
{
    for (i = 0; i < level.playerqueue.size; i++)
    {
        p = level.playerqueue[i];
        // wipe out the main-menu cvar to close any open menu
        p closeMenu();
    }
}
/**
 * openAllMenus
 *
 * Iterates level.playerqueue and forces every client’s menu to team menu.
 */
openAllMenus()
{
    for (i = 0; i < level.playerqueue.size; i++)
    {
        p = level.playerqueue[i];
        // wipe out the main-menu cvar to close any open menu
        p openMenu(game["menu_team"]);
    }
}
/**
 * findChallenger
 *
 * Walks the queue in order.  For each player:
 *   - Draws a HUD prompt
 *   - Waits for USE or SPRINT
 *   - If USE: assigns level.weapon and calls spawnPlayer()
 *   - Cleans up the prompt
 * After everyone’s been asked, notifies "round_start".
 */
findChallenger()
{
	level endon("end_findchallenger");
	level notify("end_findchallenger");
	
	//make sure player queue is uptodate
	level thread updatePlayerQueue();
	
    // 1) close menus first
    closeAllMenus();
	
	//tell the active player we are waiting for a challenger
	// draw a center-screen prompt
	p = level.player1;
	
	if (!isDefined(p.waitPrompt))
	{
		p.waitPrompt = newClientHudElem(p);
		p.waitPrompt.alignX     = "center";
		p.waitPrompt.alignY     = "middle";
		p.waitPrompt.x          = 320;
		p.waitPrompt.y          = 320;
		p.waitPrompt.archived   = false;
	}
	p.waitPrompt setText(game["waitText"]);
	//randomize queuepos
	
	if(level.queuetype == 2)
		game["queuepos"] = randomInt(level.playerqueue.size);
	
    // 2) ask each in queue
    for (i = game["queuepos"]; true; i++)
    {
		if(level.queuetype == 1)
			game["queuepos"] = i;
		// remove prompt
        p.joinPrompt destroy();
        p.joinPrompt = undefined;
		
		if(i == level.playerqueue.size){
			i = 0;
			if(level.queuetype == 1)
				game["queuepos"] = i;
		}
		
        p = level.playerqueue[i];
		
		if(p == level.player1)
		{
			//wait a server frame before asking next person
			wait 0.05;
			continue;
		}

		if(!isDefined(p.menuing))
		{
			p.menuing = true;
			//wait a server frame before asking the next person
			wait 0.05;
			continue;
		}	

        // draw a center-screen prompt
        if (!isDefined(p.joinPrompt))
        {
            p.joinPrompt = newClientHudElem(p);
            p.joinPrompt.alignX     = "center";
            p.joinPrompt.alignY     = "middle";
            p.joinPrompt.x          = 320;
            p.joinPrompt.y          = 320;
            p.joinPrompt.archived   = false;
        }
        p.joinPrompt setText(game["joinText"]);
		promptWidth = game["joinText"].length * 8 * p.joinPrompt.fontScale;
		promptLeftX  = p.joinPrompt.x ;// - (promptWidth * 0.5);
		
		// create the countdown timer HUD
		if (!isDefined(p.joinTimer))
		{
			p.joinTimer = newClientHudElem(p);
			p.joinTimer.alignX    = "left";
			p.joinTimer.alignY    = "middle";
			p.joinTimer.x         = promptLeftX; // + promptWidth + 10;
			p.joinTimer.y         = 300;
			p.joinTimer.fontScale = 0.8;
			p.joinTimer.archived  = false;
		}
		
		w = 0;
		waittime = 10/0.05;
		secondsLeft = 10;
        // wait for a decision
        for (w = 0; w < waittime; w++)
		{
			wait 0.05;

			// break out immediately if they press Use or Melee
			if (p useButtonPressed() || p meleeButtonPressed())
				break;

			// every 20 frames (~1 second), tick the display down
			if ( ((w + 1) % 20) == 0 )
			{
				secondsLeft--;
				p.joinTimer setValue(secondsLeft);
			}
		}
		
        // remove prompt
        p.joinPrompt destroy();
        p.joinPrompt = undefined;
		p.joinTimer destroy();
		p.joinTimer = undefined;

        // if they accepted, give them the chosen weapon and spawn
        if (p useButtonPressed())
        {
			p printDebug("challenge accepted", "debug", "self");
			level.player1 printDebug("challenge accepted", "debug", "self");
			level.player2 = p;
            p.pers["weapon"] = game["weapon"];
			p.pers["team"] = game["team"];
			level.player1.waitPrompt destroy();
			level.player1.waitPrompt = undefined;
            p spawnPlayer("player2");
			level notify("round_start");
			RestartMap();
			return;
        }
		
		//wait a server frame before asking next person
		wait 0.05;
    }
}
askForRematch(p)
{
	level endon("end_findchallenger");
	level notify("end_findchallenger");
	
	//make sure player queue is uptodate
	level thread updatePlayerQueue();
	
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if((isDefined(player.pers["team"]) && player.pers["team"] == "spectator"))
			continue;
		player spawnSpectator();
	}
	
	//tell the active player we are waiting for a challenger
	// draw a center-screen prompt
	p printDebug("you are the round winner", "debug", "self");
	
	p = level.player1;
	
	p.pers["team"] = "spectator";
	p.pers["weapon"] = undefined;
	
	p printDebug("you are the active player", "debug", "self");
	
	if (!isDefined(p.waitPrompt))
	{
		p.waitPrompt = newClientHudElem(p);
		p.waitPrompt.alignX     = "center";
		p.waitPrompt.alignY     = "middle";
		p.waitPrompt.x          = 320;
		p.waitPrompt.y          = 320;
		p.waitPrompt.archived   = false;
	}
	p.waitPrompt setText(game["rematchText"]);
	
	promptWidth = game["rematchText"].length * 8 * p.waitPrompt.fontScale;
	promptLeftX  = p.waitPrompt.x; // - (promptWidth * 0.5);
	
	 // create the countdown timer HUD
    if (!isDefined(p.waitTimer))
    {
        p.waitTimer = newClientHudElem(p);
        p.waitTimer.alignX    = "left";
        p.waitTimer.alignY    = "middle";
        p.waitTimer.x         = promptLeftX; // + promptWidth + 10;
        p.waitTimer.y         = 300;
        p.waitTimer.fontScale = 0.8;
        p.waitTimer.archived  = false;
    }

	//wait a server frame before asking next person
	wait 0.05;
		
	w = 0;
	waittime = 10/0.05;
	secondsLeft = 10;
	// wait for a decision
    for (w = 0; w < waittime; w++)
    {
        wait 0.05;

        // break out immediately if they press Use or Melee
        if (p useButtonPressed() || p meleeButtonPressed())
            break;

        // every 20 frames (~1 second), tick the display down
        if ( ((w + 1) % 20) == 0 )
        {
            secondsLeft--;
            p.waitTimer setValue(secondsLeft );
        }
    }
		
	// remove prompt
	p.waitPrompt destroy();
	p.waitPrompt = undefined;
	p.waitTimer destroy();
	p.waitTimer = undefined;
	
	w = 0;
	waittime = 10/0.05;
	secondsLeft = 10;
	// if they accepted, give them the chosen weapon and spawn
	if (p useButtonPressed())
	{
		while(p useButtonPressed())
			wait 0.5; //make them let off the button
		
		if (!isDefined(p.choosePrompt))
		{
			p.choosePrompt = newClientHudElem(p);
			p.choosePrompt.alignX     = "center";
			p.choosePrompt.alignY     = "middle";
			p.choosePrompt.x          = 320;
			p.choosePrompt.y          = 320;
			p.choosePrompt.archived   = false;
		}
		p.choosePrompt setText(game["chooseText"]);
		
		promptWidth = game["chooseText"].length * 8 * p.choosePrompt.fontScale;
		promptLeftX  = p.choosePrompt.x; // - (promptWidth * 0.5);
		
		if (!isDefined(p.chooseTimer))
		{
			p.chooseTimer = newClientHudElem(p);
			p.chooseTimer.alignX    = "left";
			p.chooseTimer.alignY    = "middle";
			p.chooseTimer.x         = promptLeftX; // + promptWidth + 10;
			p.chooseTimer.y         = 300;
			p.chooseTimer.fontScale = 0.8;
			p.chooseTimer.archived  = false;
		}
		
		p openMenu(game["menu_team"]);
		level.player1 = p;
		printDebug("player 1 set to " + level.player1.name,"info","level");
		
		for (w = 0; w < waittime; w++)
		{
			wait 0.05;
			
			if(p.pers["team"] != "spectator" && isdefined(p.pers["weapon"]))
			{
				p.choosePrompt destroy();
				p.choosePrompt = undefined;
				p.chooseTimer destroy();
				p.chooseTimer = undefined;
				updateGameStatus("searching");
				return;
			}

			// break out immediately if they press Use or Melee
			if (p useButtonPressed()){
				p.choosePrompt destroy();
				p.choosePrompt = undefined;
				p.chooseTimer destroy();
				p.chooseTimer = undefined;
				p.pers["team"] = game["team"];
				p.pers["weapon"] = game["weapon"];
				updateGameStatus("searching");
				return;
			}

			// every 20 frames (~1 second), tick the display down
			if ( ((w + 1) % 20) == 0 )
			{
				secondsLeft--;
				p.chooseTimer setValue(secondsLeft );
			}
		}
	}
	p.choosePrompt destroy();
	p.choosePrompt = undefined;
	p.chooseTimer destroy();
	p.chooseTimer = undefined;
	updateGameStatus("pregame");
	p spawnSpectator();
	
	level notify("end_findchallenger");
    
}
updateGameStatus(status)
{
	
	printDebug("new game status is " + status,"debug","level");

	switch(status)
	{
	
		case "pregame":
			game["pregame"] = true;
			game["searching"] = false;
			game["starting"] = false;
			game["inprogress"] = false;
			game["postround"] = false;
			
			if(!isDefined(game["gamestarted"]))
				return;
			
			level notify("kill_startround");
			
			level.player1 = undefined;
			printDebug("player 1 set to undefined","info","level");
			level.player2 = undefined;
			game["weapon"] = undefined;
			game["team"] = undefined;
			//clean up everyone’s hud and open the team menu for them
			players = getentarray("player", "classname");
			for (i = 0; i < players.size; i++)
			{
				player = players[i];
				player.pers["weapon"] = undefined;
				player.pers["team"] = undefined;
				player cleanupHud();
			}
			closeAllMenus();
			openAllMenus();
			break;
		case "searching":
			game["pregame"] = false;
			game["searching"] = true;
			game["starting"] = false;
			game["inprogress"] = false;
			game["postround"] = false;
			
			level.player2 = undefined;
			
			level updatePlayerQueue();
			level notify("end_findchallenger");
			level notify("kill_startround");
			level thread findChallenger();
			break;
		case "starting":
			game["pregame"] = false;
			game["searching"] = false;
			game["starting"] = true;
			game["inprogress"] = false;
			game["postround"] = false;
		
		case "inprogress":
			game["pregame"] = false;
			game["searching"] = false;
			game["starting"] = false;
			game["inprogress"] = true;
			game["postround"] = false;
			break;
		case "postround":
			game["pregame"] = false;
			game["searching"] = false;
			game["starting"] = false;
			game["inprogress"] = false;
			game["postround"] = true;
			break;
	}
	
}
isweaponavailable(team)
{
	if(team == "allies")
	{
		switch(game["allies"])		
		{
		case "american":
			if(level.allow_m1carbine == "1")
				return true;
			if(level.allow_m1garand == "1")
				return true;
			if(level.allow_thompson == "1")
				return true;
			if(level.allow_bar == "1")
				return true;
			if(level.allow_springfield == "1")
				return true;
			if(level.allow_mg30cal == "1")
				return true;
	
			return false;
			break;

		case "british":
			if(level.allow_enfield  == "1")
				return true;
			if(level.allow_sten == "1")
				return true;
			if(level.allow_bren == "1")
				return true;
			if(level.allow_springfield == "1")
				return true;
			if(level.allow_mg30cal == "1")
				return true;
	
			return false;
			break;
			
		case "russian":
			if(level.allow_nagant  == "1")
				return true;
			if(level.allow_svt40 == "1")
				return true;
			if(level.allow_ppsh == "1")
				return true;
			if(level.allow_nagantsniper == "1")
				return true;
			if(level.allow_dp28 == "1")
				return true;
	
			return false;
			break;
		}
	}
	else if(team == "axis")
	{
		switch(game["axis"])		
		{
		case "german":
			if(level.allow_kar98k  == "1")
				return true;
			if(level.allow_gewehr43 == "1")
				return true;
			if(level.allow_mp40 == "1")
				return true;
			if(level.allow_mp44 == "1")
				return true;
			if(level.allow_kar98ksniper == "1")
				return true;
			if(level.allow_mg34 == "1")
				return true;
	
			return false;
			break;
		}			
	}
	return false;
}
announceScores(winner)
{
	announceMessage(winner.name + " wins!", "level", true);
	wait 2;
	announceMessage("Leaderboard-", "level",true);
	wait 1;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		player.score = player.pers["roundsWon"];

		if(player.score > 0)
		{
			if(player.score == 1)
				announceMessage(player.name + ": " + player.score + " Win", "level", true);
			else
				announceMessage(player.name + ": " + player.score + " Wins", "level", true);
			wait 1;
		}
	}
	
}
// ------------------------------------------------------------------------------------------------------------
//	printDebug
//
// 		message = message to print
//		loglevel = severity level of the message (values = info, warning, error, debug)
//		scope = scope of the message (should it be printed to self or to whole server, values = self, server)
//		
//		if the appropriate debug level is set in server cfg then announces message to appropriate scope
// -----------------------------------------------------------------------------------------------------------
printDebug(message,loglevel,scope)
{
	
	//if debug not enabled do nothing
	if(level.wawa_debug == "")
		return;
	
	//check log level against debug level
	switch(level.wawa_debug)
	{
		case "debug":
			//print debug msgs ignore everything else
			switch(loglevel)
			{
				case "debug":
					announceMessage("^6DEBUG: " + "^7" + message, scope);
					break;
				default:
					return;
			}
			break;
		case "error":
			//print debug and error msgs, ignore everything else
			switch(loglevel)
			{
				case "debug":
					announceMessage("^6DEBUG: " + "^7" + message, scope);
					break;
				case "error":
					announceMessage("^1ERROR: " + "^7" + message, scope);
					break;
				default:
					return;
			}
			break;
		case "warning":
			//print debug warning and error msgs, ignore info
			switch(loglevel)
			{
				case "debug":
					announceMessage("^6DEBUG: " + "^7" + message, scope);
					break;
				case "warning":
					announceMessage("^3WARNING: " + "^7" + message, scope);
					break;
				case "error":
					announceMessage("^1ERROR: " + "^7" + message, scope);
					break;
				default:
					return;
			}
			break;
		case "info":
			//print everything
			switch(loglevel)
			{
				case "debug":
					announceMessage("^6DEBUG: " + "^7" + message, scope);
					break;
				case "warning":
					announceMessage("^3WARNING: " + "^7" + message, scope);
					break;
				case "error":
					announceMessage("^1ERROR: " + "^7" + message, scope);
					break;
				case "info":
				default:
					announceMessage("^5INFO: " + "^7" + message, scope);
			}
			break;
		default:
			return;
	}
}

// ------------------------------------------------------------------------------------------------------------
//	announceMessage
//
// 		message = message to print
//		scope = scope of the message (should it be printed to self or to whole server, values = self, server)
//		
//		announces message to appropriate scope
// -----------------------------------------------------------------------------------------------------------
announceMessage(message, scope, bold)
{
	if(!isDefined(bold))
		bold = false;
	//if scope is set to self then keep announcement to self, otherwise announce to whole server
	if(isdefined(scope) && scope == "self")
	{
		if(bold)
			self iprintlnbold(message);
		else
			self iprintln(message);
	}
	else
	{
		if(bold)
			iprintlnbold(message);
		else
			iprintln(message);
	}	
}