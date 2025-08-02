/*
	Gun Game
	Objective: 	Score points by eliminating other players, each elim awards a new weapon, melee demotions
	Map ends:	When one player reaches the score limit, or time limit is reached
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
	spawnpointname = "mp_deathmatch_spawn";
	spawnpoints = getentarray(spawnpointname, "classname");
	
	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	level.callbackStartGameType = ::Callback_StartGameType;
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;

	maps\mp\gametypes\_callbacksetup::SetupCallbacks();

	allowed[0] = "dm";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	//maps\mp\gametypes\_rank_gmi::InitializeBattleRank(); No rank
	maps\mp\gametypes\_secondary_gmi::Initialize();
	
	if(getCvar("scr_gg_timelimit") == "")		// Time limit per map
		setCvar("scr_gg_timelimit", "30");
	else if(getCvarFloat("scr_gg_timelimit") > 1440)
		setCvar("scr_gg_timelimit", "1440");
	level.timelimit = getCvarFloat("scr_gg_timelimit");
	setCvar("ui_gg_timelimit", level.timelimit);
	makeCvarServerInfo("ui_gg_timelimit", "30");

	if(getCvar("scr_gg_scorelimit") == "")		// Score limit per map
		setCvar("scr_gg_scorelimit", "20");
	else if(getCvarInt("scr_gg_scorelimit") > 100)
		setCvar("scr_gg_scorelimit", "100");
	level.scorelimit = getCvarInt("scr_gg_scorelimit");
	setCvar("ui_gg_scorelimit", level.scorelimit);
	makeCvarServerInfo("ui_gg_scorelimit", "20");
	
	level.gg_defaultrandom = getCvar("scr_gg_defaultrandom");

	if(getCvar("scr_forcerespawn") == "")		// Force respawning
		setCvar("scr_forcerespawn", "0");

/*	if(getCvar("scr_battlerank") == "")		
		setCvar("scr_battlerank", "1");	//default is ON
*/	level.battlerank = 0; //getCvarint("scr_battlerank"); No Rank
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

	game["menu_serverinfo"] = "serverinfo_" + getCvar("g_gametype");
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

	precacheString(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");
	precacheString(&"MPSCRIPT_KILLCAM");
	precacheString(&"GMI_MP_CEASEFIRE");

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

	maps\mp\gametypes\_teams::modeltype();
	maps\mp\gametypes\_teams::precache();
	//////////////////////////////////////////////
	// ADDED ALL WEAPONS PRECACHING 			//
	//////////////////////////////////////////////
	precacheAllWeapons();
	maps\mp\gametypes\_teams::initGlobalCvars();
	maps\mp\gametypes\_teams::initWeaponCvars();
	initGunGameWeaponCvars();
	maps\mp\gametypes\_teams::restrictPlacedWeapons();
	//////////////////////////////////////////////
	// REMOVE ALL WEAPONS						//
	//////////////////////////////////////////////
	removeAllPlacedWeapons();
	thread maps\mp\gametypes\_teams::updateGlobalCvars();
	thread maps\mp\gametypes\_teams::updateWeaponCvars();
	thread updateGunGameWeaponCvars();
	
	maps\mp\gametypes\_corrupt_killcam::corrupt_StartGameType();
	
	//////////////////////////////////////////////
	// SET WEAPON TIERS							//
	//////////////////////////////////////////////
	setWeaponTiers();

	setClientNameMode("auto_change");

	thread startGame();
	//thread addBotClients(); // For development testing
	thread updateGametypeCvars();
}

setWeaponTiers()
{
	scorelimit = level.scorelimit;
	if(scorelimit == 0) scorelimit = 100;
	for(i = 0; i < scorelimit; i++)
	{
		tier = i + 1;
		weapon = getCvar("scr_gg_weapon" + tier);
		if(self restrict(weapon) == "restricted")
		{
			if(weapon == "playerRandom")
			{
				level.weapons[i] = "playerRandom";
			}
			else if(weapon == "randomEverySpawn")
			{
				level.weapons[i] = "randomEverySpawn";
			}
			else
			{
				switch(getcvar("scr_gg_defaultrandom"))
				{
					case "playerRandom":
					level.weapons[i] = "playerRandom";
					break;
					case "randomEverySpawn":
					level.weapons[i] = "randomEverySpawn";
					break;
					default:
					if(isWeaponAvailable())
					{
						level.weapons[i] = getRandomWeapon();
					}
					else
					{
						level.weapons[i] = "binoculars_mp";
					}
				}
			}
		}
		else
		{
			level.weapons[i] = weapon;
		}
	}
}

updateWeaponTier(cvar)
{
	tier = cvar[cvar.size - 1];
	i = tier - 1;
	
	weapon = getCvar("scr_gg_weapon" + tier);
	if(level.weapons[i] == weapon)
	{
		return;
	}
	if(self restrict(weapon) == "restricted")
	{
		if(weapon == "playerRandom")
			{
				level.weapons[i] = "playerRandom";
			}
			else if(weapon == "randomEverySpawn")
			{
				level.weapons[i] = "randomEverySpawn";
			}
			else
			{
				switch(getcvar("scr_gg_defaultrandom"))
				{
					case "playerRandom":
					level.weapons[i] = "playerRandom";
					break;
					case "randomEverySpawn":
					level.weapons[i] = "randomEverySpawn";
					break;
					default:
					if(isWeaponAvailable())
					{
						level.weapons[i] = getRandomWeapon();
					}
					else
					{
						level.weapons[i] = "binoculars_mp";
					}
				}
			}
	}
	else
	{
		level.weapons[i] = weapon;
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

	if(isDefined(self.pers["team"]) && self.pers["team"] != "spectator")
	{
		self setClientCvar("ui_weapontab", "0");
		self.sessionteam = "none";

		spawnPlayer();
	
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

	for(;;)
	{
		self waittill("menuresponse", menu, response);

		if(menu == game["menu_serverinfo"] && response == "close")
		{
			self.pers["skipserverinfo"] = true;
			self openMenu(game["menu_team"]);
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
				self spawnPlayer();
				break;

			case "spectator":
				if(self.pers["team"] != "spectator")
				{
					self.pers["team"] = "spectator";
					self.pers["weapon"] = undefined;
					self.pers["savedmodel"] = undefined;
					
					self.sessionteam = "spectator";
					self setClientCvar("g_scriptMainMenu", game["menu_team"]);
					self setClientCvar("ui_weapontab", "0");
					spawnSpectator();
				}
				break;

			case "viewmap":
				self openMenu(game["menu_viewmap"]);
				break;

			case "callvote":
				self openMenu(game["menu_callvote"]);
				break;
			}
		}
		else if(menu == game["menu_viewmap"])
		{
			switch(response)
			{
			case "team":
				self openMenu(game["menu_team"]);
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

	// Make sure at least one point of damage is done
	if(iDamage < 1)
		iDamage = 1;

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
	
	//demote on melee kils
	if(sMeansOfDeath == "MOD_MELEE")
		self thread demoted(self.score);
	
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

			attacker thread demoted(attacker.score); //demote
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;
			
			if(attacker.tierweapon == sWeapon && (sMeansOfDeath != "MOD_MELEE" || (sMeansOfDeath == "MOD_MELEE" && (sWeapon == "binoculars_mp" || sWeapon == "smokegrenade_mp" || sWeapon == "flashgrenade_mp"))))
				attacker thread promoted(attacker.score); //promote on non melee
			attacker checkScoreLimit();
		}

		lpattacknum = attacker getEntityNumber();
		lpattackguid = attacker getGuid();
		lpattackname = attacker.name;
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;

		self thread demoted(self.score);

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
	self dropHealth();

///// Removed by AWE /////
	body = self cloneplayer();
//////////////////////////

	delay = 2;	// Delay the player becoming a spectator till after he's done dying
	wait delay;	// ?? Also required for Callback_PlayerKilled to complete before respawn/killcam can execute
	
	if((getCvarInt("scr_killcam") <= 0) || (getCvarInt("scr_forcerespawn") > 0) || level.mapended)
		doKillcam = false;
	
	if(doKillcam)
		self thread killcam(attackerNum, delay);
	else if(game["doFinalKillcam"])
	{
		if(!level.mapended)
		{
			self thread respawn();
		}
		else
		{
			//while(1)
			//{

				//if(level.mapended)
				//	return;

				printDebug("doing final kill cam","info","level");

				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{	
					corruptPlayers = players[i];
					
					if(corruptPlayers == self)
					{
						printDebug(self.name + " is the corrupt player","info","level");
						continue;
					}
					corruptPlayers thread maps\mp\gametypes\_corrupt_killcam::corrupt_killcam(attackerNum, delay);

				}
				printDebug(self.name + " doing kilcam","info","level");
				maps\mp\gametypes\_corrupt_killcam::corrupt_killcam(attackerNum, delay);
				printDebug("final kill cam done","info","level");
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
	if(!isDefined(self.pers["weapon"]))
	{
		self.pers["weapon"] = weapon;
		spawnPlayer();
	}
	else
	{
		self.pers["weapon"] = weapon;
		
		weaponname = maps\mp\gametypes\_teams::getWeaponName(self.pers["weapon"]);
		
		if(maps\mp\gametypes\_teams::useAn(self.pers["weapon"]))
			self iprintln(&"MPSCRIPT_YOU_WILL_RESPAWN_WITH_AN", weaponname);
		else
			self iprintln(&"MPSCRIPT_YOU_WILL_RESPAWN_WITH_A", weaponname);
	}
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

spawnPlayer()
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

	spawnpointname = "mp_deathmatch_spawn";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM(spawnpoints);

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
	//self maps\mp\gametypes\_loadout_gmi::PlayerSpawnLoadout();
	
	self setClientCvar("cg_objectiveText", &"DM_KILL_OTHER_PLAYERS");

	// set the status icon if battlerank is turned on
	if(level.battlerank)
	{
		self.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(self);
	}	

	// setup the hud rank indicator
	self thread maps\mp\gametypes\_rank_gmi::RankHudInit();

////////////// Added by AWE /////////////////
	self maps\mp\gametypes\_awe::spawnPlayer();
/////////////////////////////////////////////

	self thread updateweapon(self.score, "spawn");
	
	self printDebug("player spawned", "debug", "self");
	
	self printDebug("player team = " + self.pers["team"], "debug", "self");
	
	self printDebug("player old team = " + self.awe_oldteam, "debug", "self");
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

	self thread spawnPlayer();
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

startGame()
{
	level.starttime = getTime();

	if(level.timelimit > 0)
	{
		level.clock = newHudElem();
		level.clock.x = 320;
		level.clock.y = 460;
		level.clock.alignX = "center";
		level.clock.alignY = "middle";
		level.clock.font = "bigfixed";
		level.clock setTimer(level.timelimit * 60);
	}

	for(;;)
	{
		checkTimeLimit();
		wait 1;
	}
}

endMap(method)
{

	if(!isdefined(method))
	{
		method = "none";
	}
	
	if(method == "kill")
	{
		printDebug("waiting for final killcam to finish","info","level");
		level waittill("corrupt_killcam_over");
	}
	
////// Added by AWE ///////////
	maps\mp\gametypes\_awe::endMap();
/////////////////////////////////

	game["state"] = "intermission";
	level.roundended = true;
	level notify("intermission");

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isDefined(player.pers["team"]) && player.pers["team"] == "spectator")
			continue;

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

checkTimeLimit()
{
	if(level.timelimit <= 0)
		return;

	timepassed = (getTime() - level.starttime) / 1000;
	timepassed = timepassed / 60.0;

	if(timepassed < level.timelimit)
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

	if(self.score < level.scorelimit)
		return;

	if(level.mapended)
		return;
	level.mapended = true;

	iprintln(&"MPSCRIPT_SCORE_LIMIT_REACHED");
	level thread endMap("kill");
}
initGunGameWeaponCvars()
{
	level.gg_allow_m1carbine = getCvar("scr_gg_allow_m1carbine");
	setCvar("scr_gg_allow_m1carbine", level.gg_allow_m1carbine);

	level.gg_allow_m1garand = getCvar("scr_gg_allow_m1garand");
	setCvar("scr_gg_allow_m1garand", level.gg_allow_m1garand);

	level.gg_allow_thompson = getCvar("scr_gg_allow_thompson");
	setCvar("scr_gg_allow_thompson", level.gg_allow_thompson);

	level.gg_allow_bar = getCvar("scr_gg_allow_bar");
	setCvar("scr_gg_allow_bar", level.gg_allow_bar);

	level.gg_allow_springfield = getCvar("scr_gg_allow_springfield");
	setCvar("scr_gg_allow_springfield", level.gg_allow_springfield);

	level.gg_allow_mg30cal = getCvar("scr_gg_allow_mg30cal");
	setCvar("scr_gg_allow_mg30cal", level.gg_allow_mg30cal);
//added 1903a3
	level.gg_allow_m1903a3 = getCvar("scr_gg_allow_m1903a3");
	setCvar("scr_gg_allow_m1903a3", level.gg_allow_m1903a3);

	level.gg_allow_enfield = getCvar("scr_gg_allow_enfield");
	setCvar("scr_gg_allow_enfield", level.gg_allow_enfield);

	level.gg_allow_sten = getCvar("scr_gg_allow_sten");
	setCvar("scr_gg_allow_sten", level.gg_allow_sten);

	level.gg_allow_bren = getCvar("scr_gg_allow_bren");
	setCvar("scr_gg_allow_bren", level.gg_allow_bren);

	level.gg_allow_nagant = getCvar("scr_gg_allow_nagant");
	setCvar("scr_gg_allow_nagant", level.gg_allow_nagant);
	
	level.gg_allow_svt40 = getCvar("scr_gg_allow_svt40");
	setCvar("scr_gg_allow_svt40", level.gg_allow_svt40);

	level.gg_allow_ppsh = getCvar("scr_gg_allow_ppsh");
	setCvar("scr_gg_allow_ppsh", level.gg_allow_ppsh);

	level.gg_allow_nagantsniper = getCvar("scr_gg_allow_nagantsniper");
	setCvar("scr_gg_allow_nagantsniper", level.gg_allow_nagantsniper);

	level.gg_allow_dp28 = getCvar("scr_gg_allow_dp28");
	setCvar("scr_gg_allow_dp28", level.gg_allow_dp28);

	level.gg_allow_kar98k = getCvar("scr_gg_allow_kar98k");
	setCvar("scr_gg_allow_kar98k", level.gg_allow_kar98k);

	level.gg_allow_gewehr43 = getCvar("scr_gg_allow_gewehr43");
	setCvar("scr_gg_allow_gewehr43", level.gg_allow_gewehr43);

	level.gg_allow_mp40 = getCvar("scr_gg_allow_mp40");
	setCvar("scr_gg_allow_mp40", level.gg_allow_mp40);

	level.gg_allow_mp44 = getCvar("scr_gg_allow_mp44");
	setCvar("scr_gg_allow_mp44", level.gg_allow_mp44);

	level.gg_allow_kar98ksniper = getCvar("scr_gg_allow_kar98ksniper");
	setCvar("scr_gg_allow_kar98ksniper", level.gg_allow_kar98ksniper);

	level.gg_allow_mg34 = getCvar("scr_gg_allow_mg34");
	setCvar("scr_gg_allow_mg34", level.gg_allow_mg34);

	level.gg_allow_fg42 = getCvar("scr_gg_allow_fg42");
	setCvar("scr_gg_allow_fg42", level.gg_allow_fg42);

	level.gg_allow_panzerfaust = getCvar("scr_gg_allow_panzerfaust");
	setCvar("scr_gg_allow_panzerfaust", level.gg_allow_panzerfaust);

	level.gg_allow_bazooka = getCvar("scr_gg_allow_bazooka");
	setCvar("scr_gg_allow_bazooka", level.gg_allow_bazooka);

	level.gg_allow_panzerschreck = getCvar("scr_gg_allow_panzerschreck");
	setCvar("scr_gg_allow_panzerschreck", level.gg_allow_panzerschreck);

	level.gg_allow_flamethrower = getCvar("scr_gg_allow_flamethrower");
	setCvar("scr_gg_allow_flamethrower", level.gg_allow_flamethrower);

	level.gg_allow_binoculars = getCvar("scr_gg_allow_binoculars");
	setCvar("scr_gg_allow_binoculars", level.gg_allow_binoculars);

	level.gg_allow_artillery = getCvar("scr_gg_allow_artillery");
	setCvar("scr_gg_allow_artillery", level.gg_allow_artillery);
	
	level.gg_allow_satchel = getCvar("scr_gg_allow_satchel");
	setCvar("scr_gg_allow_satchel", level.gg_allow_satchel);

	level.gg_allow_grenades = getCvar("scr_gg_allow_grenades");
	setCvar("scr_gg_allow_grenades", level.gg_allow_grenades);

	level.gg_allow_smoke = getCvar("scr_gg_allow_smoke");
	setCvar("scr_gg_allow_smoke", level.gg_allow_smoke);

	level.gg_allow_pistols = getCvar("scr_gg_allow_pistols");
	setCvar("scr_gg_allow_pistols", level.gg_allow_pistols);

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

		timelimit = getCvarFloat("scr_gg_timelimit");
		if(level.timelimit != timelimit)
		{
			if(timelimit > 1440)
			{
				timelimit = 1440;
				setCvar("scr_gg_timelimit", "1440");
			}

			level.timelimit = timelimit;
			level.starttime = getTime();

			if(level.timelimit > 0)
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
				level.clock setTimer(level.timelimit * 60);
			}
			else
			{
				if(isDefined(level.clock))
					level.clock destroy();
			}

			checkTimeLimit();
		}

		scorelimit = getCvarInt("scr_gg_scorelimit");
		if(level.scorelimit != scorelimit)
		{
			level.scorelimit = scorelimit;

			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
				players[i] checkScoreLimit();
		}

		gg_defaultrandom = getCvar("scr_gg_defaultrandom");
		if(level.gg_defaultrandom != gg_defaultrandom)
		{
			for(i = 0; i < scorelimit; i++)
			{
				tier = i + 1;
				updateWeaponTier("scr_gg_weapon" + tier);
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
		
/*		battlerank = getCvarint("scr_battlerank");
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
		} */
		
		scorelimit = level.scorelimit;
		if(scorelimit == 0) scorelimit = 100;
		for(i = 0; i < scorelimit; i++)
		{
			tier = i + 1;
			updateWeaponTier("scr_gg_weapon" + tier);
		}
		wait 1;
	}
}
updateGunGameWeaponCvars()
{
	for(;;)
	{
		scr_gg_allow_m1carbine = getCvar("scr_gg_allow_m1carbine");
		if(level.gg_allow_m1carbine != scr_gg_allow_m1carbine)
		{
			level.gg_allow_m1carbine = scr_gg_allow_m1carbine;
		}

		scr_gg_allow_m1garand = getCvar("scr_gg_allow_m1garand");
		if(level.gg_allow_m1garand != scr_gg_allow_m1garand)
		{
			level.gg_allow_m1garand = scr_gg_allow_m1garand;
		}
		
		scr_gg_allow_thompson = getCvar("scr_gg_allow_thompson");
		if(level.gg_allow_thompson != scr_gg_allow_thompson)
		{
			level.gg_allow_thompson = scr_gg_allow_thompson;
		}

		scr_gg_allow_bar = getCvar("scr_gg_allow_bar");
		if(level.gg_allow_bar != scr_gg_allow_bar)
		{
			level.gg_allow_bar = scr_gg_allow_bar;
		}

		scr_gg_allow_springfield = getCvar("scr_gg_allow_springfield");
		if(level.gg_allow_springfield != scr_gg_allow_springfield)
		{
			level.gg_allow_springfield = scr_gg_allow_springfield;
		}

		scr_gg_allow_mg30cal = getCvar("scr_gg_allow_mg30cal");
		if(level.gg_allow_mg30cal != scr_gg_allow_mg30cal)
		{
			level.gg_allow_mg30cal = scr_gg_allow_mg30cal;
		}

//added 1903a3
		scr_gg_allow_m1903a3 = getCvar("scr_gg_allow_m1903a3");
		if(level.gg_allow_m1903a3 != scr_gg_allow_m1903a3)
		{
			level.gg_allow_m1903a3 = scr_gg_allow_m1903a3;
		}

		scr_gg_allow_enfield = getCvar("scr_gg_allow_enfield");
		if(level.gg_allow_enfield != scr_gg_allow_enfield)
		{
			level.gg_allow_enfield = scr_gg_allow_enfield;
		}

		scr_gg_allow_sten = getCvar("scr_gg_allow_sten");
		if(level.gg_allow_sten != scr_gg_allow_sten)
		{
			level.gg_allow_sten = scr_gg_allow_sten;
		}

		scr_gg_allow_bren = getCvar("scr_gg_allow_bren");
		if(level.gg_allow_bren != scr_gg_allow_bren)
		{
			level.gg_allow_bren = scr_gg_allow_bren;
		}

		scr_gg_allow_nagant = getCvar("scr_gg_allow_nagant");
		if(level.gg_allow_nagant != scr_gg_allow_nagant)
		{
			level.gg_allow_nagant = scr_gg_allow_nagant;
		}

		scr_gg_allow_svt40 = getCvar("scr_gg_allow_svt40");
		if(level.gg_allow_svt40 != scr_gg_allow_svt40)
		{
			level.gg_allow_svt40 = scr_gg_allow_svt40;
		}

		scr_gg_allow_ppsh = getCvar("scr_gg_allow_ppsh");
		if(level.gg_allow_ppsh != scr_gg_allow_ppsh)
		{
			level.gg_allow_ppsh = scr_gg_allow_ppsh;
		}

		scr_gg_allow_nagantsniper = getCvar("scr_gg_allow_nagantsniper");
		if(level.gg_allow_nagantsniper != scr_gg_allow_nagantsniper)
		{
			level.gg_allow_nagantsniper = scr_gg_allow_nagantsniper;
		}

		scr_gg_allow_dp28 = getCvar("scr_gg_allow_dp28");
		if(level.gg_allow_dp28 != scr_gg_allow_dp28)
		{
			level.gg_allow_dp28 = scr_gg_allow_dp28;
		}

		scr_gg_allow_kar98k = getCvar("scr_gg_allow_kar98k");
		if(level.gg_allow_kar98k != scr_gg_allow_kar98k)
		{
			level.gg_allow_kar98k = scr_gg_allow_kar98k;
		}

		scr_gg_allow_gewehr43 = getCvar("scr_gg_allow_gewehr43");
		if(level.gg_allow_gewehr43 != scr_gg_allow_gewehr43)
		{
			level.allow_gewehr43 = scr_allow_gewehr43;
		}

		scr_gg_allow_mp40 = getCvar("scr_gg_allow_mp40");
		if(level.gg_allow_mp40 != scr_gg_allow_mp40)
		{
			level.gg_allow_mp40 = scr_gg_allow_mp40;
		}

		scr_gg_allow_mp44 = getCvar("scr_gg_allow_mp44");
		if(level.gg_allow_mp44 != scr_gg_allow_mp44)
		{
			level.gg_allow_mp44 = scr_gg_allow_mp44;
		}

		scr_gg_allow_kar98ksniper = getCvar("scr_gg_allow_kar98ksniper");
		if(level.gg_allow_kar98ksniper != scr_gg_allow_kar98ksniper)
		{
			level.gg_allow_kar98ksniper = scr_gg_allow_kar98ksniper;
		}

		scr_gg_allow_mg34 = getCvar("scr_gg_allow_mg34");
		if(level.gg_allow_mg34 != scr_gg_allow_mg34)
		{
			level.gg_allow_mg34 = scr_gg_allow_mg34;
		}

		scr_gg_allow_fg42 = getCvar("scr_gg_allow_fg42");
		if(level.gg_allow_fg42 != scr_gg_allow_fg42)
		{
			level.gg_allow_fg42 = scr_gg_allow_fg42;
		}

		scr_gg_allow_panzerfaust = getCvar("scr_gg_allow_panzerfaust");
		if(level.gg_allow_panzerfaust != scr_gg_allow_panzerfaust)
		{
			level.gg_allow_panzerfaust = scr_gg_allow_panzerfaust;
		}

		scr_gg_allow_panzerschreck = getCvar("scr_gg_allow_panzerschreck");
		if(level.gg_allow_panzerschreck != scr_gg_allow_panzerschreck)
		{
			level.gg_allow_panzerschreck = scr_gg_allow_panzerschreck;
		}

		scr_gg_allow_bazooka = getCvar("scr_gg_allow_bazooka");
		if(level.gg_allow_bazooka != scr_gg_allow_bazooka)
		{
			level.gg_allow_bazooka = scr_gg_allow_bazooka;
		}

		scr_gg_allow_flamethrower = getCvar("scr_gg_allow_flamethrower");
		if(level.gg_allow_flamethrower != scr_gg_allow_flamethrower)
		{
			level.gg_allow_flamethrower = scr_gg_allow_flamethrower;
		}

		scr_gg_allow_binoculars = getCvar("scr_gg_allow_binoculars");
		if(level.gg_allow_binoculars != scr_gg_allow_binoculars)
		{
			level.gg_allow_binoculars = scr_gg_allow_binoculars;
		}

		scr_gg_allow_artillery = getCvar("scr_gg_allow_artillery");
		if(level.gg_allow_artillery != scr_gg_allow_artillery)
		{
			level.gg_allow_artillery = scr_gg_allow_artillery;
		}

		scr_gg_allow_satchel = getCvar("scr_gg_allow_satchel");
		if(level.gg_allow_satchel != scr_gg_allow_satchel)
		{
			level.gg_allow_satchel = scr_gg_allow_satchel;
		}

		scr_gg_allow_smoke = getCvar("scr_gg_allow_smoke");
		if(level.gg_allow_smoke != scr_gg_allow_smoke)
		{
			level.gg_allow_smoke = scr_gg_allow_smoke;
		}

		scr_gg_allow_grenades = getCvar("scr_gg_allow_grenades");
		if(level.gg_allow_grenades != scr_gg_allow_grenades)
		{
			level.gg_allow_grenades = scr_gg_allow_grenades;
		}

		scr_gg_allow_pistols = getCvar("scr_gg_allow_pistols");
		if(level.gg_allow_pistols != scr_gg_allow_pistols)
		{
			level.gg_allow_pistols = scr_gg_allow_pistols;
		}

		wait 5;
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
				ent[i] notify("menuresponse", game["menu_weapon_axis"], "kar98k_mp");
			}
			else
			{
				ent[i] notify("menuresponse", game["menu_team"], "allies");
				wait 0.5;
				ent[i] notify("menuresponse", game["menu_weapon_allies"], "springfield_mp");
			}
		}
	}
}

precacheAllWeapons()
{
	maps\mp\gametypes\_awe::awePrecacheItem("fraggrenade_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("smokegrenade_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("flashgrenade_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("colt_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("m1carbine_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("m1garand_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("thompson_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("bar_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("springfield_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("mg30cal_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("binoculars_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("binoculars_artillery_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("satchelcharge_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("mosin_nagant_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("m1903a3_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("mk1britishfrag_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("webley_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("enfield_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("sten_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("bren_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("rgd-33russianfrag_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("tt33_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("mosin_nagant_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("svt40_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("ppsh_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("mosin_nagant_sniper_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("dp28_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("stielhandgranate_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("luger_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("kar98k_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("gewehr43_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("mp40_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("mp44_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("kar98k_sniper_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("mg34_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("panzerfaust_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("panzerschreck_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("bazooka_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("flamethrower_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("sten_silenced_mp");
	maps\mp\gametypes\_awe::awePrecacheItem("fg42_mp");
}

removeAllPlacedWeapons()
{
	deletePlacedEntity("mpweapon_m1carbine");
	deletePlacedEntity("mpweapon_m1garand");
	deletePlacedEntity("mpweapon_thompson");
	deletePlacedEntity("mpweapon_bar");
	deletePlacedEntity("mpweapon_springfield");
	deletePlacedEntity("mpweapon_mg30cal");
	deletePlacedEntity("mpweapon_m1903a3");
	deletePlacedEntity("mpweapon_enfield");
	deletePlacedEntity("mpweapon_sten");
	deletePlacedEntity("mpweapon_bren");
	deletePlacedEntity("mpweapon_mosinnagant");
	deletePlacedEntity("mpweapon_svt40");
	deletePlacedEntity("mpweapon_ppsh");
	deletePlacedEntity("mpweapon_mosinnagantsniper");
	deletePlacedEntity("mpweapon_dp28");
	deletePlacedEntity("mpweapon_kar98k");
	deletePlacedEntity("mpweapon_gewehr43");
	deletePlacedEntity("mpweapon_mp40");
	deletePlacedEntity("mpweapon_mp44");
	deletePlacedEntity("mpweapon_kar98ksniper");
	deletePlacedEntity("mpweapon_mg34");
	deletePlacedEntity("mpweapon_fg42");
	deletePlacedEntity("mpweapon_panzerfaust");
	deletePlacedEntity("mpweapon_panzerschreck");
	deletePlacedEntity("mpweapon_bazooka");
	deletePlacedEntity("mpweapon_flamethrower");
	deletePlacedEntity("mpweapon_binoculars");
	deletePlacedEntity("mpweapon_binoculars_artillery");
	deletePlacedEntity("mpweapon_satchelcharge");
	deletePlacedEntity("mpweapon_sten_silenced");
	// Need to not automatically give these to players if I allow restricting them
	// colt_mp
	// luger_mp
	// fraggrenade_mp
	// mk1britishfrag_mp
	// rgd-33russianfrag_mp
	// stielhandgranate_mp
	// smokegrenade_mp
	// flashgrenade_mp
	// binoculars_mp
}

deletePlacedEntity(entity)
{
	entities = getentarray(entity, "classname");
	for(i = 0; i < entities.size; i++)
	{
		//println("DELETED: ", entities[i].classname);
		entities[i] delete();
	}
}

updateweapon(score, how)
{
	printDebug("weapon tier" + score + " = " + level.weapons[score], "debug", "self");
	switch(level.weapons[score])
	{
		case "playerRandom":
			if(!isDefined(self.tierweapon))
			{
				if(isWeaponAvailable())
				{
					self.tierweapon = getRandomWeapon();
				}
				else
				{
					self.tierweapon = "binoculars_mp";
				}
			}
			break;
		case "randomEverySpawn":
			if(isWeaponAvailable())
				{
					self.tierweapon = getRandomWeapon();
				}
				else
				{
					self.tierweapon = "binoculars_mp";
				}
			break;
		default:
			self.tierweapon = level.weapons[score];
	}
	weapon = self.tierweapon;
	//Take previous weapon
	self takeWeapon(how);
	//Take others just in case
	gw = self getWeaponSlotWeapon("primary");
	self takeWeapon(gw);
	gw = self getWeaponSlotWeapon("primaryb");
	self takeWeapon(gw);
	gw = self getWeaponSlotWeapon("pistol");
	self takeWeapon(gw);
	gw = self getWeaponSlotWeapon("grenade");
	self takeWeapon(gw);
	gw = self getWeaponSlotWeapon("smokegrenade");
	self takeWeapon(gw);
	gw = self getWeaponSlotWeapon("satchel");
	self takeWeapon(gw);
	gw = self getWeaponSlotWeapon("binocular");
	self takeWeapon(gw);
	
	slot = getSlotFromWeapon(weapon);
	
	//Give weapon- fill up ammo twice just to make sure
	self giveMaxAmmo(weapon);
	self giveWeapon(weapon);
	self giveMaxAmmo(weapon);

	weaponname = getWeaponName(weapon);
	self iprintlnbold("Tier " + (score+1));
	self iprintlnbold(weaponname);
	if(how != "spawn")
		while(self attackButtonPressed())
			wait(0.05);
	self switchtoWeapon( weapon );
	self setSpawnWeapon( weapon );
	self notify("gg_newweapon");
	self thread ammoRefill(slot);
}	
	
ammoRefill(slot)
{
	self endon("awe_died");
	self endon("gg_newweapon");
	for(;;)
	  {
		if(self.sessionstate == "dead")
			return;
		if(self getWeaponSlotWeapon(slot) != self.tierweapon)
		{
			self giveWeapon(self.tierweapon);
			self switchtoWeapon(self.tierweapon);
		}
		self giveMaxAmmo(self.tierweapon);
		//self setWeaponSlotAmmo("pistol", 999);
		wait (3);
	  }
}
promoted(score, weapon)
{
	if(level.mapended)
		return;
	self.score++;
	if(self.score >= level.scorelimit)
	{
		announceMessage(self.name + " Wins!", "level", true);
		level.mapended = true;
		endMap("kill");
		return;
	}
	self iprintlnbold("Promoted");
	self.weapkill = 0;
	self.tierweapon = undefined;
	updateweapon(self.score, weapon);
	
}
demoted(score)
{
	self iprintlnbold("^1Demoted");
	self.score--;
	self.tierweapon = undefined;
	if(self.score<0)
		self.score = 0;
}
getRandomWeapon()
{
	weap = "restricted";
	while(true)
	{
		switch(randomInt(40))
		{
		case 0: weap = "fraggrenade_mp"; break;
		case 1: weap = "smokegrenade_mp";  break;
		case 2: weap = "flashgrenade_mp"; break;
		case 3: weap = "colt_mp"; break;
		case 4: weap = "m1carbine_mp"; break;
		case 5: weap = "m1garand_mp"; break;
		case 6: weap = "thompson_mp"; break;
		case 7: weap = "bar_mp"; break;
		case 8: weap = "springfield_mp"; break;
		case 9: weap = "mg30cal_mp"; break;
		case 10: weap = "binoculars_mp"; break;
		case 11: weap = "binoculars_artillery_mp"; break;
		case 12: weap = "satchelcharge_mp"; break;
		case 13: weap = "mosin_nagant_mp"; break;
		case 14: weap = "m1903a3_mp"; break;
		case 15: weap = "mk1britishfrag_mp"; break;
		case 16: weap = "webley_mp"; break;
		case 17: weap = "enfield_mp"; break;
		case 18: weap = "sten_mp"; break;
		case 19: weap = "bren_mp"; break;
		case 20: weap = "rgd-33russianfrag_mp"; break;
		case 21: weap = "tt33_mp"; break;
		case 22: weap = "svt40_mp"; break;
		case 23: weap = "ppsh_mp"; break;
		case 24: weap = "mosin_nagant_sniper_mp"; break;
		case 25: weap = "dp28_mp"; break;
		case 26: weap = "stielhandgranate_mp"; break;
		case 27: weap = "luger_mp"; break;
		case 28: weap = "kar98k_mp"; break;
		case 29: weap = "gewehr43_mp"; break;
		case 30: weap = "mp40_mp"; break;
		case 31: weap = "mp44_mp"; break;
		case 32: weap = "kar98k_sniper_mp"; break;
		case 33: weap = "mg34_mp"; break;
		case 34: weap = "panzerfaust_mp"; break;
		case 35: weap = "panzerschreck_mp"; break;
		case 36: weap = "bazooka_mp"; break;
		case 37: weap = "flamethrower_mp"; break;
		case 38: weap = "sten_silenced_mp"; break;
		case 39: weap = "fg42_mp"; break;
		}
		
		if(restrict(weap) != "restricted")
		{
			return weap;
		}
	}
}
isWeaponAvailable()
{
	weap = "restricted";
	for(count = 0; count < 40; count++)
	{
		switch(count)
		{
		case 0: weap = "fraggrenade_mp"; break;
		case 1: weap = "smokegrenade_mp";  break;
		case 2: weap = "flashgrenade_mp"; break;
		case 3: weap = "colt_mp"; break;
		case 4: weap = "m1carbine_mp"; break;
		case 5: weap = "m1garand_mp"; break;
		case 6: weap = "thompson_mp"; break;
		case 7: weap = "bar_mp"; break;
		case 8: weap = "springfield_mp"; break;
		case 9: weap = "mg30cal_mp"; break;
		case 10: weap = "binoculars_mp"; break;
		case 11: weap = "binoculars_artillery_mp"; break;
		case 12: weap = "satchelcharge_mp"; break;
		case 13: weap = "mosin_nagant_mp"; break;
		case 14: weap = "m1903a3_mp"; break;
		case 15: weap = "mk1britishfrag_mp"; break;
		case 16: weap = "webley_mp"; break;
		case 17: weap = "enfield_mp"; break;
		case 18: weap = "sten_mp"; break;
		case 19: weap = "bren_mp"; break;
		case 20: weap = "rgd-33russianfrag_mp"; break;
		case 21: weap = "tt33_mp"; break;
		case 22: weap = "svt40_mp"; break;
		case 23: weap = "ppsh_mp"; break;
		case 24: weap = "mosin_nagant_sniper_mp"; break;
		case 25: weap = "dp28_mp"; break;
		case 26: weap = "stielhandgranate_mp"; break;
		case 27: weap = "luger_mp"; break;
		case 28: weap = "kar98k_mp"; break;
		case 29: weap = "gewehr43_mp"; break;
		case 30: weap = "mp40_mp"; break;
		case 31: weap = "mp44_mp"; break;
		case 32: weap = "kar98k_sniper_mp"; break;
		case 33: weap = "mg34_mp"; break;
		case 34: weap = "panzerfaust_mp"; break;
		case 35: weap = "panzerschreck_mp"; break;
		case 36: weap = "bazooka_mp"; break;
		case 37: weap = "flamethrower_mp"; break;
		case 38: weap = "sten_silenced_mp"; break;
		case 39: weap = "fg42_mp"; break;
		}
		
		if(restrict(weap) != "restricted")
		{
			return true;
		}
	}
	return false;
}
getWeaponName(weapon)
{
	switch(weapon)
	{
	case "m1carbine_mp":
		weaponname = &"WEAPON_M1A1CARBINE";
		break;
		
	case "m1garand_mp":
		weaponname = &"WEAPON_M1GARAND";
		break;
		
	case "thompson_mp":
	case "thompson_semi_mp":
		weaponname = &"WEAPON_THOMPSON";
		break;
		
	case "bar_mp":
	case "bar_slow_mp":
		weaponname = &"WEAPON_BAR";
		break;
		
	case "springfield_mp":
		weaponname = &"WEAPON_SPRINGFIELD";
		break;

	case "mg30cal_mp":
		weaponname = &"GMI_WEAPON_30CAL";
		break;
//added 1903a3
	case "m1903a3_mp":
		weaponname = &"M1903A3";
		break;
	case "enfield_mp":
		weaponname = &"WEAPON_LEEENFIELD";
		break;
		
	case "sten_mp":
		weaponname = &"WEAPON_STEN";
		break;
	
	case "sten_silenced_mp":
		weaponname = &"GMI_WEAPON_SILENCED_STEN";
		break;
	
	case "bren_mp":
		weaponname = &"WEAPON_BREN";
		break;
		
	case "mosin_nagant_mp":
		weaponname = &"WEAPON_MOSINNAGANT";
		break;

	case "svt40_mp":
		weaponname = &"GMI_WEAPON_SVT40";
		break;
		
	case "ppsh_mp":
	case "ppsh_semi_mp":
		weaponname = &"WEAPON_PPSH";
		break;
		
	case "mosin_nagant_sniper_mp":
		weaponname = &"WEAPON_SCOPEDMOSINNAGANT";
		break;
		
	case "dp28_mp":
		weaponname = &"GMI_WEAPON_DP28";
		break;

	case "kar98k_mp":
		weaponname = &"WEAPON_KAR98K";
		break;
		
	case "gewehr43_mp":
		weaponname = &"GMI_WEAPON_GEWEHR43";
		break;

	case "mp40_mp":
		weaponname = &"WEAPON_MP40";
		break;
		
	case "mp44_mp":
	case "mp44_semi_mp":
		weaponname = &"WEAPON_MP44";
		break;
		
	case "mg34_mp":
		weaponname = &"GMI_WEAPON_MG34";
		break;
		
	case "kar98k_sniper_mp":
		weaponname = &"WEAPON_SCOPEDKAR98K";
		break;
		
	case "fg42_mp":
		weaponname = &"WEAPON_FG42";
		break;
	
	case "bazooka_mp":
		weaponname = &"GMI_WEAPON_BAZOOKA";
		break;
		
	case "panzerfaust_mp":
		weaponname = &"WEAPON_PANZERFAUST";
		break;
		
	case "panzerschreck_mp":
		weaponname = &"GMI_WEAPON_PANZERSCHRECK";
		break;	
		
	case "flamethrower_mp":
		weaponname = &"GMI_WEAPON_FLAMETHROWER";
		break;
	
	case "colt_mp":
		weaponname = &"WEAPON_COLT45";
		break;
		
	case "luger_mp":
		weaponname = &"WEAPON_LUGER";
		break;
		
	case "tt33_mp":
		weaponname = &"GMI_WEAPON_TT33";
		break;
		
	case "webley_mp":
		weaponname = &"GMI_WEAPON_WEBLEY";
		break;
	
	case "fraggrenade_mp":
		weaponname = &"WEAPON_M2FRAGGRENADE";
		break;
		
	case "mk1britishfrag_mp":
		weaponname = &"WEAPON_MK2FRAGGRENADE";
		break;
		
	case "rgd-33russianfrag_mp":
		weaponname = &"WEAPON_RUSSIANGRENADE";
		break;
	
	case "stielhandgranate_mp":
		weaponname = &"WEAPON_GERMANGRENADE";
		break;	
		
	case "smokegrenade_mp":
		weaponname = &"GMI_WEAPON_SMOKEGRENADE";
		break;
		
	case "flashgrenade_mp":
		weaponname = &"Flash Grenade";
		break;
		
	case "satchelcharge_mp":
		weaponname = &"GMI_WEAPON_SATCHEL";
		break;
		
	case "binoculars_mp":
		weaponname = &"GMI_WEAPON_BINOCULARS";
		break;
		
	case "binoculars_artillery_mp":
		weaponname = &"GMI_WEAPON_BINOCULARS_ARTILLERY";
		break;
		
	default:
		weaponname = &"WEAPON_UNKNOWNWEAPON";
		break;
	}

	return weaponname;
}
getSlotFromWeapon(weapon)
{
	switch(weapon)
	{
	case "m1carbine_mp":
	case "m1garand_mp":
	case "thompson_mp":
	case "thompson_semi_mp":
	case "bar_mp":
	case "bar_slow_mp":
	case "springfield_mp":
	case "mg30cal_mp":
	case "m1903a3_mp":
	case "enfield_mp":
	case "sten_mp":
	case "sten_silenced_mp":
	case "bren_mp":
	case "mosin_nagant_mp":
	case "svt40_mp":	
	case "ppsh_mp":
	case "ppsh_semi_mp":
	case "mosin_nagant_sniper_mp":
	case "dp28_mp":
	case "kar98k_mp":
	case "gewehr43_mp":
	case "mp40_mp":
	case "mp44_mp":
	case "mp44_semi_mp":
	case "mg34_mp":
	case "kar98k_sniper_mp":
	case "fg42_mp":
	case "bazooka_mp":
	case "panzerfaust_mp":
	case "panzerschreck_mp":
	case "flamethrower_mp":
		slot = "primary";
		break;
	case "colt_mp":
	case "luger_mp":
	case "tt33_mp":
	case "webley_mp":
		slot = "pistol";
		break;
	case "fraggrenade_mp":
	case "mk1britishfrag_mp":
	case "rgd-33russianfrag_mp":
	case "stielhandgranate_mp":
		slot = "grenade";
		break;	
	case "smokegrenade_mp":
	case "flashgrenade_mp":
		slot = "smokegrenade";
		break;
	case "satchelcharge_mp":
		slot = "satchel";
		break;
	case "binoculars_mp":
	case "binoculars_artillery_mp":
		slot = "binocular";
		break;
	default:
		slot = "primary";
		break;
	}

	return slot;
}
restrict(response)
{
	switch(response)
	{
		case "m1carbine_mp":
			if(getcvar("scr_gg_allow_m1carbine") == 0 || (getcvar("scr_gg_allow_m1carbine") == "" && !getcvar("scr_allow_m1carbine")))
			{
				self iprintln(&"MPSCRIPT_M1A1_CARBINE_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;
			
		case "m1garand_mp":
			if(getcvar("scr_gg_allow_m1garand") == 0 || (getcvar("scr_gg_allow_m1garand") == "" && !getcvar("scr_allow_m1garand")))
			{
				self iprintln(&"MPSCRIPT_M1_GARAND_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;
			
		case "thompson_mp":
			if(getcvar("scr_gg_allow_thompson") == 0 || (getcvar("scr_gg_allow_thompson") == "" && !getcvar("scr_allow_thompson")))
			{
				self iprintln(&"MPSCRIPT_THOMPSON_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;
			
		case "bar_mp":
			if(getcvar("scr_gg_allow_bar") == 0 || (getcvar("scr_gg_allow_bar") == "" && !getcvar("scr_allow_bar")))
			{
				self iprintln(&"MPSCRIPT_BAR_IS_A_RESTRICTED_WEAPON");
				response = "restricted";
			}
			break;
			
		case "springfield_mp":
			if(getcvar("scr_gg_allow_springfield") == 0 || (getcvar("scr_gg_allow_springfield") == "" && !getcvar("scr_allow_springfield")))
			{
				self iprintln(&"MPSCRIPT_SPRINGFIELD_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;
			
		case "mg30cal_mp":
			if(getcvar("scr_gg_allow_mg30cal") == 0 || (getcvar("scr_gg_allow_mg30cal") == "" && !getcvar("scr_allow_mg30cal")))
			{
				self iprintln(&"GMI_WEAPON_30CAL_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;
//added 1903a3
		case "m1903a3_mp":
			if(getcvar("scr_gg_allow_m1903a3") == 0 || (getcvar("scr_gg_allow_m1903a3") == "" && !getcvar("scr_allow_m1903a3")))
			{
				self iprintln(&"GMI_WEAPON_1903a3_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "enfield_mp":
			if(getcvar("scr_gg_allow_enfield") == 0 || (getcvar("scr_gg_allow_enfield") == "" && !getcvar("scr_allow_enfield")))
			{
				self iprintln(&"MPSCRIPT_LEEENFIELD_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "sten_mp":
		case "sten_silenced_mp":
			if(getcvar("scr_gg_allow_sten") == 0 || (getcvar("scr_gg_allow_sten") == "" && !getcvar("scr_allow_sten")))
			{
				self iprintln(&"MPSCRIPT_STEN_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "bren_mp":
			if(getcvar("scr_gg_allow_bren") == 0 || (getcvar("scr_gg_allow_bren") == "" && !getcvar("scr_allow_bren")))
			{
				self iprintln(&"MPSCRIPT_BREN_LMG_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;
			
		case "mosin_nagant_mp":
			if(getcvar("scr_gg_allow_nagant") == 0 || (getcvar("scr_gg_allow_nagant") == "" && !getcvar("scr_allow_nagant")))
			{
				self iprintln(&"MPSCRIPT_MOSINNAGANT_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "svt40_mp":
			if(getcvar("scr_gg_allow_svt40") == 0 || (getcvar("scr_gg_allow_svt40") == "" && !getcvar("scr_allow_svt40")))
			{
				self iprintln(&"GMI_WEAPON_SVT40_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "ppsh_mp":
			if(getcvar("scr_gg_allow_ppsh") == 0 || (getcvar("scr_gg_allow_ppsh") == "" && !getcvar("scr_allow_ppsh")))
			{
				self iprintln(&"MPSCRIPT_PPSH_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "mosin_nagant_sniper_mp":
			if(getcvar("scr_gg_allow_nagantsniper") == 0 || (getcvar("scr_gg_allow_nagantsniper") == "" && !getcvar("scr_allow_nagantsniper")))
			{
				self iprintln(&"MPSCRIPT_SCOPED_MOSINNAGANT_IS");
				response = "restricted";
			}
			break;

		case "dp28_mp":
			if(getcvar("scr_gg_allow_dp28") == 0 || (getcvar("scr_gg_allow_dp28") == "" && !getcvar("scr_allow_dp28")))
			{
				self iprintln(&"GMI_WEAPON_DP28_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;
			
		case "kar98k_mp":
			if(getcvar("scr_gg_allow_kar98k") == 0 || (getcvar("scr_gg_allow_kar98k") == "" && !getcvar("scr_allow_kar98k")))
			{
				self iprintln(&"MPSCRIPT_KAR98K_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "gewehr43_mp":
			if(getcvar("scr_gg_allow_gewehr43") == 0 || (getcvar("scr_gg_allow_gewehr43") == "" && !getcvar("scr_allow_gewehr43")))
			{
				self iprintln(&"GMI_WEAPON_GEWEHR43_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "mp40_mp":
			if(getcvar("scr_gg_allow_mp40") == 0 || (getcvar("scr_gg_allow_mp40") == "" && !getcvar("scr_allow_mp40")))
			{
				self iprintln(&"MPSCRIPT_MP40_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "mp44_mp":
			if(getcvar("scr_gg_allow_mg44") == 0 || (getcvar("scr_gg_allow_mg44") == "" && !getcvar("scr_allow_mp44")))
			{
				self iprintln(&"MPSCRIPT_MP44_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "kar98k_sniper_mp":
			if(getcvar("scr_gg_allow_kar98ksniper") == 0 || (getcvar("scr_gg_allow_kar98ksniper") == "" && !getcvar("scr_allow_kar98ksniper")))
			{
				self iprintln(&"MPSCRIPT_SCOPED_KAR98K_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;

		case "mg34_mp":
			if(getcvar("scr_gg_allow_mg34") == 0 || (getcvar("scr_gg_allow_mg34") == "" && !getcvar("scr_allow_mg34")))
			{
				self iprintln(&"GMI_WEAPON_MG34_IS_A_RESTRICTED");
				response = "restricted";
			}
			break;
		case "panzerfaust_mp":
			if(getcvar("scr_gg_allow_panzerfaust") == 0 || (getcvar("scr_gg_allow_panzerfaust") == "" && !getcvar("scr_allow_panzerfaust")))
			{
				response = "restricted";
			}
			break;
		case "bazooka_mp":
			if(getcvar("scr_gg_allow_bazooka") == 0 || (getcvar("scr_gg_allow_bazooka") == "" && !getcvar("scr_allow_bazooka")))
			{
				response = "restricted";
			}
			break;
		case "panzerschreck_mp":
			if(getcvar("scr_gg_allow_panzerschreck") == 0 || (getcvar("scr_gg_allow_panzerschreck") == "" && !getcvar("scr_allow_panzerschreck")))
			{
				response = "restricted";
			}
			break;
		case "flamethrower_mp":
			if(getcvar("scr_gg_allow_flamethrower") == 0 || (getcvar("scr_gg_allow_flamethrower") == "" && !getcvar("scr_allow_flamethrower")))
			{
				response = "restricted";
			}
			break;
		case "fg42_mp":
			if(getcvar("scr_gg_allow_fg42") == 0 || (getcvar("scr_gg_allow_fg42") == "" && !getcvar("scr_allow_fg42")))
			{
				response = "restricted";
			}
			break;
		case "binoculars_mp":
			if(getcvar("scr_gg_allow_binoculars") == 0 || (getcvar("scr_gg_allow_binoculars") == "" && !getcvar("scr_allow_binoculars")))
			{
				response = "restricted";
			}
			break;
		case "binoculars_artillery_mp":
			if(getcvar("scr_gg_allow_artillery") == 0 || (getcvar("scr_gg_allow_artillery") == "" && !getcvar("scr_allow_artillery")))
			{
				response = "restricted";
			}
			break;
		case "satchelcharge_mp":
			if(getcvar("scr_gg_allow_satchel") == 0 || (getcvar("scr_gg_allow_satchel") == "" && !getcvar("scr_allow_satchel")))
			{
				response = "restricted";
			}
			break;
		case "fraggrenade_mp":
		case "mk1britishfrag_mp":
		case "rgd-33russianfrag_mp":
		case "stielhandgranate_mp":
			if(getcvar("scr_gg_allow_grenades") == 0 || (getcvar("scr_gg_allow_grenades") == "" && !getcvar("scr_allow_grenades")))
			{
				response = "restricted";
			}
			break;
		case "smokegrenade_mp":
		case "flashgrenade_mp":
			if(getcvar("scr_gg_allow_smoke") == 0 || (getcvar("scr_gg_allow_smoke") == "" && !getcvar("scr_allow_smoke")))
			{
				response = "restricted";
			}
			break;
		case "tt33_mp":
		case "colt_mp":
		case "webley_mp":
		case "luger_mp":
			if(getcvar("scr_gg_allow_pistols") == 0 || (getcvar("scr_gg_allow_pistols") == "" && !getcvar("scr_allow_pistols")))
			{
				response = "restricted";
			}
			break;
		default:
			response = "restricted";
	}
		
	return response;
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
	if(!level.awe_debug)
		return;
	
	debuglevel = "info";
	
	//check log level against debug level
	switch(debuglevel)
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