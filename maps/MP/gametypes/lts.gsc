/*
	Last Team Standing
	Objective: Kill the other team
	Round ends:	When one team is eliminated or roundlength time is reached
	Map ends:	When one team reaches the score limit, or time limit or round limit is reached
	Respawning:	Players remain dead for the round and will respawn at the beginning of the next round

	Level requirements
	------------------
		Allied Spawnpoints:
			classname		mp_searchanddestroy_spawn_allied
			Allied players spawn from these. Place atleast 16 of these relatively close together.

		Axis Spawnpoints:
			classname		mp_searchanddestroy_spawn_axis
			Axis players spawn from these. Place atleast 16 of these relatively close together.

		Spectator Spawnpoints:
			classname		mp_searchanddestroy_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

					
	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "american";
			game["axis"] = "german";
			This sets the nationalities of the teams. Allies can be american, british, or russian. Axis can be german.
	
			game["attackers"] = "allies";
			game["defenders"] = "axis";
			This sets which team is attacking and which team is defending. Attackers plant the bombs. Defenders protect the targets.

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

		Exploder Effects:
			Setting script_noteworthy on a bombzone trigger to an exploder group can be used to trigger additional effects.

	Note
	----
		Setting "script_gameobjectname" to "bombzone" on any entity in a level will cause that entity to be removed in any gametype that
		does not explicitly allow it. This is done to remove unused entities when playing a map in other gametypes that have no use for them.
*/

/*QUAKED mp_searchanddestroy_spawn_allied (0.0 1.0 0.0) (-16 -16 0) (16 16 72)
defaultmdl="xmodel/airborne"
Allied players spawn randomly at one of these positions at the beginning of a round.
*/

/*QUAKED mp_searchanddestroy_spawn_axis (1.0 0.0 0.0) (-16 -16 0) (16 16 72)
defaultmdl="xmodel/wehrmacht_soldier"
Axis players spawn randomly at one of these positions at the beginning of a round.
*/

/*QUAKED mp_searchanddestroy_intermission (1.0 0.0 1.0) (-16 -16 -16) (16 16 16)
Intermission is randomly viewed from one of these positions.
Spectators spawn randomly at one of these positions.
*/

main()
{
	spawnpointname = "mp_searchanddestroy_spawn_allied";
	spawnpoints = getentarray(spawnpointname, "classname");
	
	// Get retrieval spawn points if SD does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_retrieval_spawn_allied";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	// Get teamdeathmatch spawn points if RE does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_teamdeathmatch_spawn";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	// Get deathmatch spawn points if TDM does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_deathmatch_spawn";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	spawnpointname = "mp_searchanddestroy_spawn_axis";
	spawnpoints = getentarray(spawnpointname, "classname");

	// Get retrieval spawn points if SD does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_retrieval_spawn_axis";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	if(spawnpoints.size)
	{
		for(i = 0; i < spawnpoints.size; i++)
			spawnpoints[i] PlaceSpawnpoint();
	}

	level.callbackStartGameType = ::Callback_StartGameType;
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;

	maps\mp\gametypes\_callbacksetup::SetupCallbacks();

	level._effect["bombexplosion"] = loadfx("fx/explosions/mp_bomb.efx");

	allowed[0] = "tdm";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	maps\mp\gametypes\_rank_gmi::InitializeBattleRank();
	maps\mp\gametypes\_secondary_gmi::Initialize();
	
	if(getCvar("scr_lts_timelimit") == "")		// Time limit per map
		setCvar("scr_lts_timelimit", "0");
	else if(getCvarFloat("scr_lts_timelimit") > 1440)
		setCvar("scr_lts_timelimit", "1440");
	level.timelimit = getCvarFloat("scr_lts_timelimit");
//	setCvar("ui_lts_timelimit", level.timelimit);
//	makeCvarServerInfo("ui_lts_timelimit", "0");

	if(!isDefined(game["timepassed"]))
		game["timepassed"] = 0;

	if(getCvar("scr_lts_scorelimit") == "")		// Score limit per map
		setCvar("scr_lts_scorelimit", "10");
	level.scorelimit = getCvarInt("scr_lts_scorelimit");
//	setCvar("ui_lts_scorelimit", level.scorelimit);
//	makeCvarServerInfo("ui_lts_scorelimit", "10");

	if(getCvar("scr_lts_roundlimit") == "")		// Round limit per map
		setCvar("scr_lts_roundlimit", "0");
	level.roundlimit = getCvarInt("scr_lts_roundlimit");
//	setCvar("ui_lts_roundlimit", level.roundlimit);
//	makeCvarServerInfo("ui_lts_roundlimit", "0");

	if(getCvar("scr_lts_roundlength") == "")		// Time length of each round
		setCvar("scr_lts_roundlength", "4");
	else if(getCvarFloat("scr_lts_roundlength") > 10)
		setCvar("scr_lts_roundlength", "10");
	level.roundlength = getCvarFloat("scr_lts_roundlength");

	if(getCvar("scr_lts_graceperiod") == "")		// Time at round start where spawning and weapon choosing is still allowed
		setCvar("scr_lts_graceperiod", "15");
	else if(getCvarFloat("scr_lts_graceperiod") > 60)
		setCvar("scr_lts_graceperiod", "60");
	level.graceperiod = getCvarFloat("scr_lts_graceperiod");

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

	if(getCvar("scr_drophealth") == "")		// Free look spectator
		setCvar("scr_drophealth", "1");

	killcam = getCvar("scr_killcam");
	if(killcam == "")				// Kill cam
		killcam = "1";
	setCvar("scr_killcam", killcam, true);
	level.killcam = getCvarInt("scr_killcam");
	
	if(getCvar("scr_teambalance") == "")		// Auto Team Balancing
		setCvar("scr_teambalance", "0");
	level.teambalance = getCvarInt("scr_teambalance");
	level.lockteams = false;

	if(getCvar("scr_freelook") == "")		// Free look spectator
		setCvar("scr_freelook", "1");
	level.allowfreelook = getCvarInt("scr_freelook");
	
	if(getCvar("scr_spectateenemy") == "")		// Spectate Enemy Team
		setCvar("scr_spectateenemy", "1");
	level.allowenemyspectate = getCvarInt("scr_spectateenemy");
	
	if(getCvar("scr_drawfriend") == "")		// Draws a team icon over teammates
		setCvar("scr_drawfriend", "1");
	level.drawfriend = getCvarInt("scr_drawfriend");

	if(!isDefined(game["state"]))
		game["state"] = "playing";
	if(!isDefined(game["roundsplayed"]))
		game["roundsplayed"] = 0;
	if(!isDefined(game["matchstarted"]))
		game["matchstarted"] = false;
		
	if(!isDefined(game["alliedscore"]))
		game["alliedscore"] = 0;
	setTeamScore("allies", game["alliedscore"]);

	if(!isDefined(game["axisscore"]))
		game["axisscore"] = 0;
	setTeamScore("axis", game["axisscore"]);

	// turn off ceasefire
	level.ceasefire = 0;
	setCvar("scr_ceasefire", "0");

	level.roundstarted = false;
	level.roundended = false;
	level.mapended = false;
	
	if (!isdefined (game["BalanceTeamsNextRound"]))
		game["BalanceTeamsNextRound"] = false;
	
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;
	level.exist["teams"] = false;
	level.didexist["allies"] = false;
	level.didexist["axis"] = false;

	level.healthqueue = [];
	level.healthqueuecurrent = 0;

	if(level.killcam >= 1)
		setarchive(true);
}

Callback_StartGameType()
{

/////////////// Added by AWE ////////////////////
	maps\mp\gametypes\_awe::Callback_StartGameType();
/////////////////////////////////////////////////

	// if this is a fresh map start, set nationalities based on cvars, otherwise leave game variable nationalities as set in the level script
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

//		game["menu_serverinfo"] = "serverinfo_" + getCvar("g_gametype");
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

		precacheString(&"MPSCRIPT_PRESS_ACTIVATE_TO_SKIP");
		precacheString(&"MPSCRIPT_KILLCAM");
		precacheString(&"SD_MATCHSTARTING");
		precacheString(&"SD_MATCHRESUMING");
		precacheString(&"SD_ROUNDDRAW");
		precacheString(&"SD_TIMEHASEXPIRED");
		precacheString(&"SD_ALLIESHAVEBEENELIMINATED");
		precacheString(&"SD_AXISHAVEBEENELIMINATED");
		precacheString(&"GMI_MP_CEASEFIRE");

//		precacheMenu(game["menu_serverinfo"]);
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
		precacheShader("white");
		precacheShader("hudScoreboard_mp");
		precacheShader("gfx/hud/hud@mpflag_spectator.tga");
		precacheStatusIcon("gfx/hud/hud@status_dead.tga");
		precacheStatusIcon("gfx/hud/hud@status_connecting.tga");

		precacheItem("item_health");
	
	
		maps\mp\gametypes\_teams::precache();
		maps\mp\gametypes\_teams::scoreboard();

		//thread addBotClients();
	}
	
	maps\mp\gametypes\_teams::modeltype();
	maps\mp\gametypes\_teams::initGlobalCvars();
	maps\mp\gametypes\_teams::initWeaponCvars();
	maps\mp\gametypes\_teams::restrictPlacedWeapons();
	thread maps\mp\gametypes\_teams::updateGlobalCvars();
	thread maps\mp\gametypes\_teams::updateWeaponCvars();

	game["gamestarted"] = true;
	
	setClientNameMode("manual_change");

	thread startGame();
	thread updateGametypeCvars();
	//thread addBotClients();
}

Callback_PlayerConnect()
{
	self.statusicon = "gfx/hud/hud@status_connecting.tga";
	self waittill("begin");
	self.statusicon = "";
	self.pers["teamTime"] = 1000000;

	if(!isDefined(self.pers["team"]))
		iprintln(&"MPSCRIPT_CONNECTED", self);

	lpselfnum = self getEntityNumber();
	lpselfguid = self getGuid();
	logPrint("J;" + lpselfguid + ";" + lpselfnum + ";" + self.name + "\n");

	// set the cvar for the map quick bind
	self setClientCvar("g_scriptQuickMap", game["menu_viewmap"]);
	
	// make sure that the rank variable is initialized
	if ( !isDefined( self.pers["rank"] ) )
		self.pers["rank"] = 0;

	if(game["state"] == "intermission")
	{
		spawnIntermission();
		return;
	}
	
	level endon("intermission");
	
	if(isDefined(self.pers["team"]) && self.pers["team"] != "spectator")
	{
		self setClientCvar("ui_weapontab", "1");

		if(self.pers["team"] == "allies")
			self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
		else
			self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);

		if(isDefined(self.pers["weapon"]))
			spawnPlayer();
		else
		{
			self.sessionteam = "spectator";

			spawnSpectator();

			if(self.pers["team"] == "allies")
				self openMenu(game["menu_weapon_allies"]);
			else
				self openMenu(game["menu_weapon_axis"]);
		}
	}
	else
	{
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);
		self setClientCvar("ui_weapontab", "0");

//		if(!isDefined(self.pers["skipserverinfo"]))
//			self openMenu(game["menu_serverinfo"]);

		if(!isdefined(self.pers["team"]))
			self openMenu(game["menu_team"]);

		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";

		spawnSpectator();
	}

	// start the vsay thread
	self thread maps\mp\gametypes\_teams::vsay_monitor();

        for(;;)
        {
                self waittill("menuresponse", menu, response);
                maps\mp\gametypes\_awe::NotAFK();
		
/*		if(menu == game["menu_serverinfo"] && response == "close")
		{
			self.pers["skipserverinfo"] = true;
			self openMenu(game["menu_team"]);
		}
*/
		if(response == "open" || response == "close")
			continue;

		if(menu == game["menu_team"])
		{
			switch(response)
			{
			case "allies":
			case "axis":
			case "autoassign":
				if (level.lockteams)
					break;
				if(response == "autoassign")
				{
					numonteam["allies"] = 0;
					numonteam["axis"] = 0;

					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						player = players[i];
					
						if(!isDefined(player.pers["team"]) || player.pers["team"] == "spectator" || player == self)
							continue;
			
						numonteam[player.pers["team"]]++;
					}
					
					// if teams are equal return the team with the lowest score
					if(numonteam["allies"] == numonteam["axis"])
					{
						if(getTeamScore("allies") == getTeamScore("axis"))
						{
							teams[0] = "allies";
							teams[1] = "axis";
							response = teams[randomInt(2)];
						}
						else if(getTeamScore("allies") < getTeamScore("axis"))
							response = "allies";
						else
							response = "axis";
					}
					else if(numonteam["allies"] < numonteam["axis"])
						response = "allies";
					else
						response = "axis";
					skipbalancecheck = true;
				}
				
				if(response == self.pers["team"] && self.sessionstate == "playing")
					break;
				
				//Check if the teams will become unbalanced when the player goes to this team...
				//------------------------------------------------------------------------------
				if ( (level.teambalance > 0) && (!isdefined (skipbalancecheck)) )
				{
					//Get a count of all players on Axis and Allies
					players = maps\mp\gametypes\_teams::CountPlayers();
					
					if (self.sessionteam != "spectator")
					{
						if (((players[response] + 1) - (players[self.pers["team"]] - 1)) > level.teambalance)
						{
							if (response == "allies")
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_RUSSIAN");
							}
							else
								self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_GERMAN");
							break;
						}
					}
					else
					{
						if (response == "allies")
							otherteam = "axis";
						else
							otherteam = "allies";
						if (((players[response] + 1) - players[otherteam]) > level.teambalance)
						{
							if (response == "allies")
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_RUSSIAN");
							}
							else
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_RUSSIAN");
							}
							break;
						}
					}
				}
				skipbalancecheck = undefined;
				//------------------------------------------------------------------------------
				
				if(response != self.pers["team"] && self.sessionstate == "playing")
					self suicide();
	                        
				self.pers["team"] = response;
				self.pers["teamTime"] = (gettime() / 1000);
				self.pers["weapon"] = undefined;
				self.pers["weapon1"] = undefined;
				self.pers["weapon2"] = undefined;
				self.pers["spawnweapon"] = undefined;
				self.pers["savedmodel"] = undefined;

				// update spectator permissions immediately on change of team
				maps\mp\gametypes\_teams::SetSpectatePermissions();

				// if there are weapons the user can select then open the weapon menu
				if ( maps\mp\gametypes\_teams::isweaponavailable(self.pers["team"]) )
				{
					if(self.pers["team"] == "allies")
					{
						menu = game["menu_weapon_allies"];
					}
					else
					{
						menu = game["menu_weapon_axis"];
					}
				
					self setClientCvar("ui_weapontab", "1");
					self openMenu(menu);
				}
				else
				{
					self setClientCvar("ui_weapontab", "0");
					self menu_spawn("none");
				}
		
				self setClientCvar("g_scriptMainMenu", menu);
				break;

			case "spectator":
				if (level.lockteams)
					break;
				if(self.pers["team"] != "spectator")
				{
					if(isAlive(self))
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
					spawnSpectator();
				}
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
			
			case "callvote":
				self openMenu(game["menu_callvote"]);
				break;
			}
		}		
		else if(menu == game["menu_weapon_allies"] || menu == game["menu_weapon_axis"])
		{
			if(response == "team")
			{
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

			weapon = self maps\mp\gametypes\_teams::restrict(response);

			if(weapon == "restricted")
			{
				self openMenu(menu);
				continue;
			}
			
			self.pers["selectedweapon"] = weapon;

			if(isDefined(self.pers["weapon"]) && self.pers["weapon"] == weapon && !isDefined(self.pers["weapon1"]))
				continue;
				
			menu_spawn(weapon);
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

///// Added by AWE ////////
	self maps\mp\gametypes\_awe::PlayerDisconnect();
///////////////////////////

	iprintln(&"MPSCRIPT_DISCONNECTED", self);
	
	lpselfnum = self getEntityNumber();
	lpselfguid = self getGuid();
	logPrint("Q;" + lpselfguid + ";" + lpselfnum + ";" + self.name + "\n");

	if(game["matchstarted"])
		level thread updateTeamStatus();
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	if(self.sessionteam == "spectator")
		return;

	// dont take damage during ceasefire mode
	// but still take damage from ambient damage (water, minefields, fire)
	if(level.ceasefire && sMeansOfDeath != "MOD_EXPLOSIVE" && sMeansOfDeath != "MOD_WATER")
		return;

	// Don't do knockback if the damage direction was not specified
	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	// check for completely getting out of the damage
//	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
		{
///////////// Changed by AWE ///////////////
			if( level.friendlyfire == "1" && !isdefined(eAttacker.pers["awe_teamkiller"]) && !(sMeansOfDeath == "MOD_CRUSH_TANK" || sMeansOfDeath == "MOD_CRUSH_JEEP") )
////////////////////////////////////////////
			{
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

//////////// Added by AWE /////////////////////
				eAttacker maps\mp\gametypes\_awe::teamdamage(self, iDamage);
///////////////////////////////////////////////

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);

////////////// Added by AWE //////////////////
				self maps\mp\gametypes\_awe::DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
//////////////////////////////////////////////

			}
////////////// Changed by AWE /////////
			else if(level.friendlyfire == "0" && !(sMeansOfDeath == "MOD_CRUSH_TANK" || sMeansOfDeath == "MOD_CRUSH_JEEP"))
///////////////////////////////////////
			{
				return;
			}
////////////// Changed by AWE /////////
			else if( (level.friendlyfire == "2" && !(sMeansOfDeath == "MOD_CRUSH_TANK" || sMeansOfDeath == "MOD_CRUSH_JEEP")) || isdefined(eAttacker.pers["awe_teamkiller"]))
///////////////////////////////////////
			{
				eAttacker.friendlydamage = true;
		
				iDamage = iDamage * .5;

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker.friendlydamage = undefined;
				
				friendly = true;
			}
////////////// Changed by AWE /////////
			else if(level.friendlyfire == "3" || sMeansOfDeath == "MOD_CRUSH_TANK" || sMeansOfDeath == "MOD_CRUSH_JEEP" )
///////////////////////////////////////
			{
				eAttacker.friendlydamage = true;

				iDamage = iDamage * .5;

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker.friendlydamage = undefined;
				
				friendly = true;
			}
		}
		else
		{
			// Make sure at least one point of damage is done
			if(iDamage < 1)
				iDamage = 1;

			self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);

////////////// Added by AWE //////////////////
			self maps\mp\gametypes\_awe::DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
//////////////////////////////////////////////

		}
	}

	self maps\mp\gametypes\_shellshock_gmi::DoShellShock(sWeapon, sMeansOfDeath, sHitLoc, iDamage);

	// Do debug print if it's enabled
	if(getCvarInt("g_debugDamage"))
	{
		println("client:" + self getEntityNumber() + " health:" + self.health +
			" damage:" + iDamage + " hitLoc:" + sHitLoc);
	}

	if(self.sessionstate != "dead")
	{
		lpselfnum = self getEntityNumber();
		lpselfguid = self getGuid();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpattackerteam = "";

		if(isPlayer(eAttacker))
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackguid = self getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackguid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		if(isDefined(friendly))
		{  
			lpattacknum = lpselfnum;
			lpattackname = lpselfname;
			lpattackguid = lpselfguid;
		}

		logPrint("D;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	}
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	self endon("spawned");

	if(self.sessionteam == "spectator")
		return;

/////////// Added by AWE ///////////
	self thread maps\mp\gametypes\_awe::PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc);
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
//	obituary(self, attacker, sWeapon, sMeansOfDeath);
/////////////////////////////////

	self.sessionstate = "dead";
	self.statusicon = "gfx/hud/hud@status_dead.tga";
	self.headicon = "";
	if (!isdefined (self.autobalance))
	{
		self.pers["deaths"]++;
		self.deaths = self.pers["deaths"];
	}

	lpselfnum = self getEntityNumber();
	lpselfguid = self getGuid();
	lpselfname = self.name;
	lpselfteam = self.pers["team"];
	lpattackerteam = "";

	attackerNum = -1;

	if(isPlayer(attacker))
	{
		if(attacker == self) // killed himself
		{
			doKillcam = false;
			if (!isdefined (self.autobalance))
			{
				attacker.pers["score"]--;
				attacker.score = attacker.pers["score"];
			}
			
			if(isDefined(attacker.friendlydamage))
				clientAnnouncement(attacker, &"MPSCRIPT_FRIENDLY_FIRE_WILL_NOT"); 
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;

			if(self.pers["team"] == attacker.pers["team"]) // killed by a friendly
			{
				attacker.pers["score"]--;

//////////// Added by AWE /////////////////////
				attacker maps\mp\gametypes\_awe::teamkill();
///////////////////////////////////////////////

				attacker.score = attacker.pers["score"];
			}
			else
			{
				attacker.pers["score"]++;
				attacker.score = attacker.pers["score"];
			}
		}
		
		lpattacknum = attacker getEntityNumber();
		lpattackguid = attacker getGuid();
		lpattackname = attacker.name;
		lpattackerteam = attacker.pers["team"];
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;

		self.pers["score"]--;
		self.score = self.pers["score"];

		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackerteam = "world";
	}

	logPrint("K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");

	// Make the player drop his weapon
	if (!isdefined (self.autobalance))
	{

///// Removed by AWE /////
//		self dropItem(self getcurrentweapon());
//////////////////////////		

		// Make the player drop health
		self dropHealth();
	}

	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["spawnweapon"] = undefined;
	
///// Removed by AWE /////
//	if (!isdefined (self.autobalance))
//		body = self cloneplayer();
//////////////////////////

	self.autobalance = undefined;

	updateTeamStatus();

	// TODO: Add additional checks that allow killcam when the last player killed wouldn't end the round (bomb is planted)
	if((getCvarInt("scr_killcam") <= 0) || !level.exist[self.pers["team"]]) // If the last player on a team was just killed, don't do killcam
		doKillcam = false;

	delay = 2;	// Delay the player becoming a spectator till after he's done dying
	wait delay;	// ?? Also required for Callback_PlayerKilled to complete before killcam can execute

	if(doKillcam && !level.roundended)
		self thread killcam(attackerNum, delay);
	else
	{
		currentorigin = self.origin;
		currentangles = self.angles;

		self thread spawnSpectator(currentorigin + (0, 0, 60), currentangles);
	}
}

// ----------------------------------------------------------------------------------
//	menu_spawn
//
// 		called from the player connect to spawn the player
// ----------------------------------------------------------------------------------
menu_spawn(weapon)
{
	if(!game["matchstarted"])
	{
		if(isDefined(self.pers["weapon"]))
		{
	 		self.pers["weapon"] = weapon;

			// setup all the weapons
			self maps\mp\gametypes\_loadout_gmi::PlayerSpawnLoadout();
	 		self setWeaponSlotWeapon("primary", weapon);
//			self setWeaponSlotAmmo("primary", 999);
//			self setWeaponSlotClipAmmo("primary", 999);
			self switchToWeapon(weapon);

//			maps\mp\gametypes\_teams::givePistol();
//			maps\mp\gametypes\_teams::giveGrenades(self.pers["selectedweapon"]);
		}
		else
		{
			self.pers["weapon"] = weapon;
			self.spawned = undefined;
			spawnPlayer();
			self thread printJoinedTeam(self.pers["team"]);
			level checkMatchStart();
		}
	}
	else if(!level.roundstarted && !self.usedweapons)
	{
	 	if(isDefined(self.pers["weapon"]))
	 	{
	 		self.pers["weapon"] = weapon;
			// setup all the weapons
			self maps\mp\gametypes\_loadout_gmi::PlayerSpawnLoadout();
	 		self setWeaponSlotWeapon("primary", weapon);
//			self setWeaponSlotAmmo("primary", 999);
//			self setWeaponSlotClipAmmo("primary", 999);
			self switchToWeapon(weapon);

//			maps\mp\gametypes\_teams::givePistol();
//			maps\mp\gametypes\_teams::giveGrenades(self.pers["selectedweapon"]);
		}
	 	else
		{			 	
			self.pers["weapon"] = weapon;
			if(!level.exist[self.pers["team"]])
			{
				self.spawned = undefined;
				spawnPlayer();
				self thread printJoinedTeam(self.pers["team"]);
				level checkMatchStart();
			}
			else
			{
				spawnPlayer();
				self thread printJoinedTeam(self.pers["team"]);
			}
		}
	}
	else
	{
		if(isDefined(self.pers["weapon"]))
			self.oldweapon = self.pers["weapon"];

		self.pers["weapon"] = weapon;
		self.sessionteam = self.pers["team"];

		if(self.sessionstate != "playing")
			self.statusicon = "gfx/hud/hud@status_dead.tga";
	
		if(self.pers["team"] == "allies")
			otherteam = "axis";
		else if(self.pers["team"] == "axis")
			otherteam = "allies";
			
		// if joining a team that has no opponents, just spawn
		if(!level.didexist[otherteam] && !level.roundended)
		{
			self.spawned = undefined;
			spawnPlayer();
			self thread printJoinedTeam(self.pers["team"]);
		}				
		else if(!level.didexist[self.pers["team"]] && !level.roundended)
		{
			self.spawned = undefined;
			spawnPlayer();
			self thread printJoinedTeam(self.pers["team"]);
			level checkMatchStart();
		}
		else
		{
			weaponname = maps\mp\gametypes\_teams::getWeaponName(self.pers["weapon"]);

			if(self.pers["team"] == "allies")
			{
				if(maps\mp\gametypes\_teams::useAn(self.pers["weapon"]))
					self iprintln(&"MPSCRIPT_YOU_WILL_SPAWN_ALLIED_WITH_AN_NEXT_ROUND", weaponname);
				else
					self iprintln(&"MPSCRIPT_YOU_WILL_SPAWN_ALLIED_WITH_A_NEXT_ROUND", weaponname);
			}
			else if(self.pers["team"] == "axis")
			{
				if(maps\mp\gametypes\_teams::useAn(self.pers["weapon"]))
					self iprintln(&"MPSCRIPT_YOU_WILL_SPAWN_AXIS_WITH_AN_NEXT_ROUND", weaponname);
				else
					self iprintln(&"MPSCRIPT_YOU_WILL_SPAWN_AXIS_WITH_A_NEXT_ROUND", weaponname);
			}
		}
	}
	self thread maps\mp\gametypes\_teams::SetSpectatePermissions();
	if (isdefined (self.autobalance_notify))
		self.autobalance_notify destroy();
}

spawnPlayer()
{
	self notify("spawned");

	resettimeout();

	self.sessionteam = self.pers["team"];
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

	if(isDefined(self.spawned))
		return;

	self.sessionstate = "playing";
		
	if(self.pers["team"] == "allies")
		spawnpointname = "mp_searchanddestroy_spawn_allied";
	else
		spawnpointname = "mp_searchanddestroy_spawn_axis";

	spawnpoints = getentarray(spawnpointname, "classname");

	// Get retrieval spawn points if SD does not exist
	if(!spawnpoints.size)
	{
		if(self.pers["team"] == "allies")
			spawnpointname = "mp_retrieval_spawn_allied";
		else
			spawnpointname = "mp_retrieval_spawn_axis";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	// Get teamdeathmatch spawn points if RE does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_teamdeathmatch_spawn";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	// Get deathmatch spawn points if TDM does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_deathmatch_spawn";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	
	self.spawned = true;
	self.statusicon = "";
	self.maxhealth = 100;
	self.health = self.maxhealth;
	
	updateTeamStatus();
	
	if(!isDefined(self.pers["score"]))
		self.pers["score"] = 0;
	self.score = self.pers["score"];
	
	self.pers["rank"] = maps\mp\gametypes\_rank_gmi::DetermineBattleRank(self);
	self.rank = self.pers["rank"];
	
	if(!isDefined(self.pers["deaths"]))
		self.pers["deaths"] = 0;
	self.deaths = self.pers["deaths"];
	
	if(!isDefined(self.pers["savedmodel"]))
		maps\mp\gametypes\_teams::model();
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);
	
	// setup all the weapons
	self maps\mp\gametypes\_loadout_gmi::PlayerSpawnLoadout();

	self.usedweapons = false;
	thread maps\mp\gametypes\_teams::watchWeaponUsage();

	attackObj = "Last Team Standing\n\nKill all enemies.";
	defendObj = attackObj;
	if(self.pers["team"] == game["attackers"])
		self setClientCvar("cg_objectiveText", attackObj);
	else if(self.pers["team"] == game["defenders"])
		self setClientCvar("cg_objectiveText", defendObj);
		
	if(level.drawfriend)
	{
		if(level.battlerank)
		{
			self.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(self);
			self.headicon = maps\mp\gametypes\_rank_gmi::GetRankHeadIcon(self);
			self.headiconteam = self.pers["team"];
		}
		else
		{
			if(self.pers["team"] == "allies")
			{
				self.headicon = game["headicon_allies"];
				self.headiconteam = "allies";
			}
			else
			{
				self.headicon = game["headicon_axis"];
				self.headiconteam = "axis";
			}
		}
	}
	else if(level.battlerank)
	{
		self.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(self);
	}	

	// setup the hud rank indicator
	self thread maps\mp\gametypes\_rank_gmi::RankHudInit();

//////////// Added by AWE /////////////////////
	self maps\mp\gametypes\_awe::spawnPlayer();
///////////////////////////////////////////////

}

spawnSpectator(origin, angles)
{
	self notify("spawned");

	resettimeout();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
		
	maps\mp\gametypes\_teams::SetSpectatePermissions();

	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);
	else
	{
 		spawnpointname = "mp_searchanddestroy_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");

		// Get RE spawn points if SD does not exist
		if(!spawnpoints.size)
		{
			spawnpointname = "mp_retrieval_intermission";
			spawnpoints = getentarray(spawnpointname, "classname");
		}

		// Get teamdeathmatch spawn points if RE does not exist
		if(!spawnpoints.size)
		{
			spawnpointname = "mp_teamdeathmatch_intermission";
			spawnpoints = getentarray(spawnpointname, "classname");
		}

		// Get deathmatch spawn points if TDM does not exist
		if(!spawnpoints.size)
		{
			spawnpointname = "mp_deathmatch_intermission";
			spawnpoints = getentarray(spawnpointname, "classname");
		}

		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		if(isDefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}

	updateTeamStatus();

	self.usedweapons = false;

	if(game["attackers"] == "allies")
		self setClientCvar("cg_objectiveText", "Last Team Standing\n\nKill all enemies.");
	else if(game["attackers"] == "axis")
		self setClientCvar("cg_objectiveText", "Last Team Standing\n\nKill all enemies.");
}

spawnIntermission()
{
	self notify("spawned");
	
	resettimeout();

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

	spawnpointname = "mp_searchanddestroy_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");

	// Get RE spawn points if SD does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_retrieval_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	// Get teamdeathmatch spawn points if RE does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_teamdeathmatch_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	// Get deathmatch spawn points if TDM does not exist
	if(!spawnpoints.size)
	{
		spawnpointname = "mp_deathmatch_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

killcam(attackerNum, delay)
{
	self endon("spawned");
	
	// killcam
	if(attackerNum < 0)
		return;

	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.archivetime = delay + 7;

	maps\mp\gametypes\_teams::SetKillcamSpectatePermissions();

	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait 0.05;

	if(self.archivetime <= delay)
	{
		self.spectatorclient = -1;
		self.archivetime = 0;
	
		maps\mp\gametypes\_teams::SetSpectatePermissions();
		return;
	}

	self.killcam = true;

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
	self.kc_skiptext setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_SKIP");

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
	self.killcam = undefined;
	
	maps\mp\gametypes\_teams::SetSpectatePermissions();
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

startGame()
{
	level.starttime = getTime();
	thread startRound();
	
	if ( (level.teambalance > 0) && (!game["BalanceTeamsNextRound"]) )
		level thread maps\mp\gametypes\_teams::TeamBalance_Check_Roundbased();
}

startRound()
{
	thread maps\mp\gametypes\_teams::sayMoveIn();

	level.clock = newHudElem();
	level.clock.x = 320;
	level.clock.y = 460;
	level.clock.alignX = "center";
	level.clock.alignY = "middle";
	level.clock.font = "bigfixed";
	level.clock setTimer(level.roundlength * 60);

	if(game["matchstarted"])
	{
		level.clock.color = (0, 1, 0);

		if((level.roundlength * 60) > level.graceperiod)
		{
			wait level.graceperiod;

			level notify("round_started");
			level.roundstarted = true;
			level.clock.color = (1, 1, 1);

			// Players on a team but without a weapon show as dead since they can not get in this round
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				player = players[i];

				if(player.sessionteam != "spectator" && !isDefined(player.pers["weapon"]))
					player.statusicon = "gfx/hud/hud@status_dead.tga";
			}
		
			wait((level.roundlength * 60) - level.graceperiod);
		}
		else
			wait(level.roundlength * 60);
	}
	else	
	{
		level.clock.color = (1, 1, 1);
		wait(level.roundlength * 60);
	}
	
	if(level.roundended)
		return;

	// No players left = draw
	if(!level.exist[game["attackers"]] || !level.exist[game["defenders"]])
	{
		announcement(&"SD_TIMEHASEXPIRED");
		level thread endRound("draw");
		return;
	}

	// Both teams left = draw
	if(level.exist[game["attackers"]] || level.exist[game["defenders"]])
	{
		announcement(&"SD_TIMEHASEXPIRED");
		level thread endRound("draw");
		return;
	}

	// Only attackers left = attackers win
	if(level.exist[game["attackers"]] || !level.exist[game["defenders"]])
	{
		announcement(&"SD_TIMEHASEXPIRED");
		level thread endRound("draw");
		level thread endRound(game["attackers"]);
		return;
	}

	// Only defenders left = defenders win
	if(!level.exist[game["attackers"]] || level.exist[game["defenders"]])
	{
		announcement(&"SD_TIMEHASEXPIRED");
		level thread endRound("draw");
		level thread endRound(game["defenders"]);
		return;
	}

	// Just in case it gets here
	announcement(&"SD_TIMEHASEXPIRED");
	level thread endRound(game["draw"]);
}

checkMatchStart()
{
	oldvalue["teams"] = level.exist["teams"];
	level.exist["teams"] = false;

	// If teams currently exist
	if(level.exist["allies"] && level.exist["axis"])
		level.exist["teams"] = true;

	// If teams previously did not exist and now they do
	if(!oldvalue["teams"] && level.exist["teams"])
	{
		if(!game["matchstarted"])
		{
			announcement(&"SD_MATCHSTARTING");

			level notify("kill_endround");
			level.roundended = false;
			level thread endRound("reset");
		}
		else
		{
			announcement(&"SD_MATCHRESUMING");

			level notify("kill_endround");
			level.roundended = false;
			level thread endRound("draw");
		}

		return;
	}
}

resetScores()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player.pers["score"] = 0;
		player.pers["deaths"] = 0;
	}

	game["alliedscore"] = 0;
	setTeamScore("allies", game["alliedscore"]);
	game["axisscore"] = 0;
	setTeamScore("axis", game["axisscore"]);
	
	if (level.battlerank)
	{
		maps\mp\gametypes\_rank_gmi::ResetPlayerRank();
	}

}

endRound(roundwinner)
{
	level endon("kill_endround");

	if(level.roundended)
		return;
	level.roundended = true;

	// End bombzone threads and remove related hud elements and objectives
	level notify("round_ended");

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player unlink();
		player enableWeapon();
	}

	if(roundwinner == "allies")
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
			players[i] playLocalSound("MP_announcer_allies_win");
	}
	else if(roundwinner == "axis")
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
			players[i] playLocalSound("MP_announcer_axis_win");
	}
	else if(roundwinner == "draw")
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
			players[i] playLocalSound("MP_announcer_round_draw");
	}

	wait 5;

	winners = "";
	losers = "";

	if(roundwinner == "allies")
	{
		if ( level.battlerank )
		{
			GivePointsToTeam( "allies", 3);
		}
		
		game["alliedscore"]++;
		setTeamScore("allies", game["alliedscore"]);
		
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			lpGuid = players[i] getGuid();
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
				winners = (winners + ";" + lpGuid + ";" + players[i].name);
			else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
				losers = (losers + ";" + lpGuid + ";" + players[i].name);
		}
		logPrint("W;allies" + winners + "\n");
		logPrint("L;axis" + losers + "\n");
	}
	else if(roundwinner == "axis")
	{
		if ( level.battlerank )
		{
			GivePointsToTeam( "axis", 3);
		}
		
		game["axisscore"]++;
		setTeamScore("axis", game["axisscore"]);

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			lpGuid = players[i] getGuid();
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
				winners = (winners + ";" + lpGuid + ";" + players[i].name);
			else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
				losers = (losers + ";" + lpGuid + ";" + players[i].name);
		}
		logPrint("W;axis" + winners + "\n");
		logPrint("L;allies" + losers + "\n");
	}

	if(game["matchstarted"])
	{
		checkScoreLimit();
		game["roundsplayed"]++;
		checkRoundLimit();
	}

	if(!game["matchstarted"] && roundwinner == "reset")
	{
		game["matchstarted"] = true;
		thread resetScores();
		game["roundsplayed"] = 0;
	}

	game["timepassed"] = game["timepassed"] + ((getTime() - level.starttime) / 1000) / 60.0;

	checkTimeLimit();

	if(level.mapended)
		return;
	level.mapended = true;

	// for all living players store their weapons
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
		{
			primary = player getWeaponSlotWeapon("primary");
			primaryb = player getWeaponSlotWeapon("primaryb");

			// If a menu selection was made
			if(isDefined(player.oldweapon))
			{
				// If a new weapon has since been picked up (this fails when a player picks up a weapon the same as his original)
				if(player.oldweapon != primary && player.oldweapon != primaryb && primary != "none")
				{
					player.pers["weapon1"] = primary;
					player.pers["weapon2"] = primaryb;
					player.pers["spawnweapon"] = player getCurrentWeapon();
				} // If the player's menu chosen weapon is the same as what is in the primaryb slot, swap the slots
				else if(player.pers["weapon"] == primaryb)
				{
					player.pers["weapon1"] = primaryb;
					player.pers["weapon2"] = primary;
					player.pers["spawnweapon"] = player.pers["weapon1"];
				} // Give them the weapon they chose from the menu
				else
				{
					player.pers["weapon1"] = player.pers["weapon"];
					player.pers["weapon2"] = primaryb;
					player.pers["spawnweapon"] = player.pers["weapon1"];
				}
			} // No menu choice was ever made, so keep their weapons and spawn them with what they're holding, unless it's a pistol or grenade
			else
			{
				if(primary == "none")
					player.pers["weapon1"] = player.pers["weapon"];
				else
					player.pers["weapon1"] = primary;
					
				player.pers["weapon2"] = primaryb;

				spawnweapon = player getCurrentWeapon();
				if ( (spawnweapon == "none") && (isdefined (primary)) ) 
					spawnweapon = primary;
				
				if(!maps\mp\gametypes\_teams::isPistolOrGrenade(spawnweapon))
					player.pers["spawnweapon"] = spawnweapon;
				else
					player.pers["spawnweapon"] = player.pers["weapon1"];
			}
		}
	}

	if ( (level.teambalance > 0) && (game["BalanceTeamsNextRound"]) )
	{
		level.lockteams = true;
		level thread maps\mp\gametypes\_teams::TeamBalance();
		level waittill ("Teams Balanced");
		wait 4;
	}

////////// Added by AWE //////////	
	maps\mp\gametypes\_awe::swapteams();
//////////////////////////////////

	map_restart(true);
}

endMap()
{
////// Added by AWE ///////////
	maps\mp\gametypes\_awe::endMap();
/////////////////////////////////
	game["state"] = "intermission";
	level notify("intermission");
	
	if(game["alliedscore"] == game["axisscore"])
		text = &"MPSCRIPT_THE_GAME_IS_A_TIE";
	else if(game["alliedscore"] > game["axisscore"])
		text = &"MPSCRIPT_ALLIES_WIN";
	else
		text = &"MPSCRIPT_AXIS_WIN";

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player closeMenu();
		player setClientCvar("g_scriptMainMenu", "main");
		player setClientCvar("cg_objectiveText", text);
		player spawnIntermission();
	}

	wait 10;
	exitLevel(false);
}

checkTimeLimit()
{
	if(level.timelimit <= 0)
		return;
	
	if(game["timepassed"] < level.timelimit)
		return;
	
	if(level.mapended)
		return;
	level.mapended = true;

	iprintln(&"MPSCRIPT_TIME_LIMIT_REACHED");
	level thread endMap();
}

checkScoreLimit()
{
	if(level.scorelimit <= 0)
		return;
	
	if(game["alliedscore"] < level.scorelimit && game["axisscore"] < level.scorelimit)
		return;

	if(level.mapended)
		return;
	level.mapended = true;

	iprintln(&"MPSCRIPT_SCORE_LIMIT_REACHED");
	level thread endMap();
}

checkRoundLimit()
{
	if(level.roundlimit <= 0)
		return;
	
	if(game["roundsplayed"] < level.roundlimit)
		return;
	
	if(level.mapended)
		return;
	level.mapended = true;

	iprintln(&"MPSCRIPT_ROUND_LIMIT_REACHED");
	level thread endMap();
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

		timelimit = getCvarFloat("scr_lts_timelimit");
		if(level.timelimit != timelimit)
		{
			if(timelimit > 1440)
			{
				timelimit = 1440;
				setCvar("scr_lts_timelimit", "1440");
			}

			level.timelimit = timelimit;
//			setCvar("ui_lts_timelimit", level.timelimit);
		}

		scorelimit = getCvarInt("scr_lts_scorelimit");
		if(level.scorelimit != scorelimit)
		{
			level.scorelimit = scorelimit;
//			setCvar("ui_lts_scorelimit", level.scorelimit);

			if(game["matchstarted"])
				checkScoreLimit();
		}

		roundlimit = getCvarInt("scr_lts_roundlimit");
		if(level.roundlimit != roundlimit)
		{
			level.roundlimit = roundlimit;
//			setCvar("ui_lts_roundlimit", level.roundlimit);

			if(game["matchstarted"])
				checkRoundLimit();
		}

		roundlength = getCvarFloat("scr_lts_roundlength");
		if(roundlength > 10)
			setCvar("scr_lts_roundlength", "10");

		graceperiod = getCvarFloat("scr_lts_graceperiod");
		if(graceperiod > 60)
			setCvar("scr_lts_graceperiod", "60");

		drawfriend = getCvarint("scr_drawfriend");
		battlerank = getCvarint("scr_battlerank");
		if(level.battlerank != battlerank || level.drawfriend != drawfriend)
		{
			level.drawfriend = drawfriend;
			level.battlerank = battlerank;
			
			// battle rank has precidence over draw friend
			if(level.battlerank)
			{
				// for all living players, show the appropriate headicon
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
					{
						// setup the hud rank indicator
						player thread maps\mp\gametypes\_rank_gmi::RankHudInit();

						player.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(player);
						if ( level.drawfriend )
						{
							player.headicon = maps\mp\gametypes\_rank_gmi::GetRankHeadIcon(player);
							player.headiconteam = player.pers["team"];
						}
						else
						{
							player.headicon = "";
						}
					}
				}
			}
			else if(level.drawfriend)
			{
				// for all living players, show the appropriate headicon
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
					{
						if(player.pers["team"] == "allies")
						{
							player.headicon = game["headicon_allies"];
							player.headiconteam = "allies";
				
						}
						else
						{
							player.headicon = game["headicon_axis"];
							player.headiconteam = "axis";
						}
						
						player.statusicon = "";
					}
				}
			}
			else
			{
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
					{
						player.headicon = "";
						player.statusicon = "";
					}
				}
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
		
		freelook = getCvarInt("scr_freelook");
		if (level.allowfreelook != freelook)
		{
			level.allowfreelook = getCvarInt("scr_freelook");
			level maps\mp\gametypes\_teams::UpdateSpectatePermissions();
		}
		
		enemyspectate = getCvarInt("scr_spectateenemy");
		if (level.allowenemyspectate != enemyspectate)
		{
			level.allowenemyspectate = getCvarInt("scr_spectateenemy");
			level maps\mp\gametypes\_teams::UpdateSpectatePermissions();
		}
		
		teambalance = getCvarInt("scr_teambalance");
		if (level.teambalance != teambalance)
		{
			level.teambalance = getCvarInt("scr_teambalance");
			if (level.teambalance > 0)
				level thread maps\mp\gametypes\_teams::TeamBalance_Check_Roundbased();
		}

		wait 1;
	}
}

updateTeamStatus()
{
	wait 0;	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute
	
	resettimeout();
	
	oldvalue["allies"] = level.exist["allies"];
	oldvalue["axis"] = level.exist["axis"];
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;
	
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
			level.exist[player.pers["team"]]++;
	}

	if(level.exist["allies"])
		level.didexist["allies"] = true;
	if(level.exist["axis"])
		level.didexist["axis"] = true;

	if(level.roundended)
		return;

	if(oldvalue["allies"] && !level.exist["allies"] && oldvalue["axis"] && !level.exist["axis"])
	{
		announcement(&"SD_ROUNDDRAW");
		level thread endRound("draw");
		return;
	}

	if(oldvalue["allies"] && !level.exist["allies"])
	{
		announcement(&"SD_ALLIESHAVEBEENELIMINATED");
		level thread endRound("axis");
		return;
	}
	
	if(oldvalue["axis"] && !level.exist["axis"])
	{
		announcement(&"SD_AXISHAVEBEENELIMINATED");
		level thread endRound("allies");
		return;
	}	
}

printJoinedTeam(team)
{
	if(team == "allies")
		iprintln(&"MPSCRIPT_JOINED_ALLIES", self);
	else if(team == "axis")
		iprintln(&"MPSCRIPT_JOINED_AXIS", self);
}

addBotClients()
{
	wait 5;
	
	for(i = 0; i < 2; i++)
	{
		ent[i] = addtestclient();
		wait 0.5;
	
		if(isPlayer(ent[i]))
		{
			if(i & 1)
			{
				ent[i] notify("menuresponse", game["menu_team"], "axis");
				wait 0.5;
				ent[i] notify("menuresponse", game["menu_weapon_axis"], "kar98k_mp");
			}
			else
			{
				ent[i] notify("menuresponse", game["menu_team"], "allies");
				wait 0.5;
				ent[i] notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");
			}
		}
	}
}

// ----------------------------------------------------------------------------------
//	dropHealth
// ----------------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------------
//	GivePointsToTeam
//
// 		Gives points to everyone on a certain team
// ----------------------------------------------------------------------------------
GivePointsToTeam( team, points )
{
	players = getentarray("player", "classname");
	
	// count up the people in the flag area
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isAlive(player) && player.pers["team"] == team)
		{
			player.pers["score"] += points;
			player.score = player.pers["score"];
		}
	}
}
