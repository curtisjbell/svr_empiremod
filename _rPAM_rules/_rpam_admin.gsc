// Admin File to allow Users that have the rconpassword to burn orkill players, move them to spectate, disarm them, mortar them, make them to a cow and so on.
// rcon set explode # for example kills a player (similar to awe's g_smite function)

init()
{
	if (isDefined(game["gamestarted"]))	  // no changes between rounds..
	{
		if (isDefined(game["svrAdminCmd"]) && game["svrAdminCmd"])
			thread start();

		return;
	}

	name = getcvar("gamename");
	if (name == "Call of Duty")
		game["svrGameName"] = "cod";
	else if (name == "Call of Duty 2")
		game["svrGameName"] = "cod2";
	else
		game["svrGameName"] = "uo";

	game["svrAdminCmd"] = _rPAM_rules\_rpam_admin_utils::cvardef("rpam_admincommands", 0, 0, 1, "int");

	if (!game["svrAdminCmd"])	return;

	if (game["svrGameName"] == "cod2")
	{
		game["adminLocalMsg"]	= _rPAM_rules\_rpam_admin_utils::cvardef("svr_admin_localized", 1, 0, 1, "int");
		game["adminEffect"]["mortar"][0]	= loadfx("fx/explosions/mortarExp_beach.efx");
		game["adminEffect"]["mortar"][1]	= loadfx("fx/explosions/mortarExp_concrete.efx");
		game["adminEffect"]["mortar"][2]	= loadfx("fx/explosions/mortarExp_dirt.efx");
		game["adminEffect"]["mortar"][3]	= loadfx("fx/explosions/mortarExp_mud.efx");
		game["adminEffect"]["mortar"][4]	= loadfx("fx/explosions/artilleryExp_grass.efx");
		game["adminEffect"]["explode"]		= loadfx("fx/explosions/default_explosion.efx");
		game["adminEffect"]["burn"]			= loadfx("fx/fire/character_torso_fire.efx");
		game["adminEffect"]["smoke"]		= loadfx("fx/smoke/grenade_smoke.efx");
		game["deadCowModel"] = "xmodel/cow_dead_1";
	}
	else
	{
		game["adminLocalMsg"]	= false;
		game["adminEffect"]["mortar"][0]	= loadfx("fx/impacts/newimps/minefield.efx");
		game["adminEffect"]["mortar"][1]	= loadfx("fx/impacts/newimps/minefield.efx");
		game["adminEffect"]["mortar"][2]	= loadfx("fx/impacts/dirthit_mortar.efx");
		game["adminEffect"]["mortar"][3]	= loadfx("fx/impacts/newimps/blast_gen3.efx");
		game["adminEffect"]["mortar"][4]	= loadfx("fx/impacts/newimps/dirthit_mortar2daymarked.efx");
		game["adminEffect"]["burn"]			= loadfx("fx/fire/fireheavysmoke.efx");
		game["adminEffect"]["explode"]		= loadfx("fx/explosions/pathfinder_explosion.efx");
		game["adminEffect"]["smoke"]		= loadfx("fx/tagged/flameout.efx");
		game["deadCowModel"] = "xmodel/cow_dead";
		precachemodel("xmodel/cow_standing");
		precachemodel("xmodel/static_shipyacht_in_water");
		precacheshader("cinematic");
	}

	precachemodel(game["deadCowModel"]);

	thread start();
}

start()
{
	level endon("svrKillThread");
	
	setcvar("rpam_forceready", "");
	setcvar("rpam_tospec", "");
	setcvar("rpam_toaxis", "");
	setcvar("rpam_toallies", "");
	setcvar("rpam_kill", "");

	for (;;)
	{
		wait 0.5;


		burn		= getCvar("rpam_burn");
	//	drug		= getCvar("drug");
		cow			= getCvar("rpam_cow");
		ship		= getCvar("rpam_ship");
		explode		= getCvar("rpam_kill");
		mortar		= getCvar("rpam_mortar");
		swapteam	= getCvar("rpam_swapteam");
		tospec		= getCvar("rpam_tospec");
		toaxis		= getCvar("rpam_toaxis");
		toallies	= getcvar("rpam_toallies");
		pam_list	= getCvar("rpam_list");
		forceready 	= getCvar("rpam_forceready");
		addbots		= getCvar("rpam_addbots");
		cvarStr		= _rPAM_rules\_rpam_admin_utils::cvardef("cvar", "none", "", "", "string");
		wait .20;

		crouch	= getCvar("rpam_crouch");
		disarm	= getCvar("rpam_disarm");
		lock	= getCvar("rpam_lock");
		say		= getCvar("rpam_say");
		saybold	= getCvar("rpam_saybold");
		wait .20;

		if (burn != "")				thread getPlayers(burn, "rpam_burn");
		else if (cow != "")			thread getPlayers(cow, "rpam_cow");
		else if (ship != "")		thread getPlayers(ship, "rpam_ship");
	//	else if (drug != "")		thread getPlayers(drug, "drug");
		else if (explode != "")		thread getPlayers(explode, "rpam_kill");
		else if (mortar != "")		thread getPlayers(mortar, "rpam_mortar");
		else if (swapteam != "")	thread getPlayers(swapteam, "rpam_swapteam");
		else if (tospec != "")		thread getPlayers(tospec, "rpam_tospec");
		else if (toaxis != "")		thread getPlayers(toaxis, "rpam_toaxis");
		else if (toallies != "")	thread getPlayers(toallies, "rpam_toallies");
	//	else if (cvarStr != "none")	thread cvarSet(cvarStr);
		else if (crouch != "")		thread getPlayers(crouch, "rpam_crouch");
		else if (disarm != "")		thread getPlayers(disarm, "rpam_disarm");
		else if (lock != "")		thread getPlayers(lock, "rpam_lock");
		else if (say != "")			thread sayMsg(say, false, "rpam_say");
		else if (saybold != "")		thread sayMsg(saybold, true, "rpam_saybold");
		else if (pam_list != "")	thread getPlayers(pam_list, "rpam_list");
		else if (forceready != "")	thread getPlayers(forceready, "rpam_forceready");
		else if (addbots != "")		thread getPlayers(addbots, "rpam_addbots");
	}
}

getPlayers(var, cmd)
{
	if (isDefined(level.inGetPlayers))		return;
	level.inGetPlayers = true;

	_t = undefined;

	if (var == "all" || ((var == "allies" || var == "axis") && !(cmd == "tospec" || cmd == "toaxis" || cmd == "toallies" || cmd == "swapteam")))
	{
		players = getentarray("player", "classname");
		for (i = 0; i < players.size; i++)
			if (isDefined(players[i]))
			{
				_p = players[i];
				_t = _p _rPAM_rules\_rpam_admin_utils::getTeam();

				if (isDefined(_t))
				{
					if (var == "all")
						_p threadCmd(cmd, true);
					else if (var == _t)
						_p threadCmd(cmd, false);
				}
			}
	}
	else if (var.size <= 2)	   // maximum player slots is only 2 digits..
	{
		for (i = 0; i < var.size; i++)
			if (!_rPAM_rules\_rpam_admin_utils::isNumeric(var[i]))	// prevent k3#a8p as input..
			{
				setCvar(cmd, "");
				level.inGetPlayers = undefined;
				return;
			}

		_i = (int)var;

		players = getentarray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			_p = players[i];
			_e = _p getEntityNumber();

			if (_e == _i)
				_p threadCmd(cmd, false);
		}
	}

	setCvar(cmd, "");
	level.inGetPlayers = undefined;
}

threadCmd(cmd, all)
{
	if (cmd == "rpam_burn")			self thread burn();
	else if (cmd == "rpam_cow")		self thread cow();
	else if (cmd == "rpam_ship")		self thread ship();
//	else if (cmd == "drug")		self thread drug();
	else if (cmd == "rpam_kill")	self thread explode();
	else if (cmd == "rpam_mortar")	self thread mortar();
	else if (cmd == "rpam_swapteam")	self thread swapteam(all);
	else if (cmd == "rpam_tospec")	self thread tospec(all);
	else if (cmd == "rpam_toaxis")	self thread toaxis(all);
	else if (cmd == "rpam_toallies")	self thread toallies(all);
	else if (cmd == "rpam_crouch")	self thread crouch();
	else if (cmd == "rpam_disarm")	self thread disarm();
	else if (cmd == "rpam_lock")		self thread lock();
	else if (cmd == "rpam_list")	self thread pam_list();
	else if (cmd == "rpam_forceready") self thread forceready();
	else if (cmd == "rpam_addbots") self thread addbots();
}

burn(noMsg)
{
	if (!isPlayer(self) || !isAlive(self))
		return;

	self endon("svrKilledPlayer");

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
	if (!isDefined(noMsg))
		self thread printMsg("rpam_burn", &"ADMIN_BURN");
	self.burnedout = false;
	count = 0;
	self.health = 100;
	self thread burnDmg();

	while (self.burnedout == false)
	{
		if (count == 0)
		{
			count = 2.5;
			self thread painSounds();
		}
		else
			count -= .10;

		playfx(game["adminEffect"]["burn"], self.origin);
		wait .05;
		if (game["svrGameName"] == "cod2")
			playfx(game["adminEffect"]["burn"], self.origin);
		wait .05;
	}
	self notify("killTheFlame");

	return;
}

burnDmg()
{
	self endon("svrKilledPlayer");
	self endon("killTheFlame");

	wait 8;
	self.burnedout = true;

	if (self.sessionstate == "playing")
	{
		self.svrSpawnDelay = 0;
		self.svrSuicide = true;
		self suicide();
	}
}

cow()
{
	if (!isPlayer(self) || !isAlive(self))
		return;

	self endon("svrKilledPlayer");
	self endon("killTheFlame");

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
	self thread printMsg("rpam_cow", &"ADMIN_COW");

	if (game["svrGameName"] != "cod2")
		self setmodel("xmodel/cow_standing");

	self disableWeapon();
	self thread burn(true);
	wait 7.5;
	self setmodel(game["deadCowModel"]);
}

ship()
{
	if (!isPlayer(self) || !isAlive(self))
		return;

	self endon("svrKilledPlayer");
	self endon("killTheFlame");

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
	self thread printMsg("rpam_ship", &"ADMIN_SHIP");

	if (game["svrGameName"] != "cod2")
		self setmodel("xmodel/static_shipyacht_in_water");

	self disableWeapon();
	self setClientCvar("cg_thirdPerson", 1);
	self setClientCvar("cg_ThirdPersonRange", "500");
	//self thread burn(true);
	wait 20;
	self.svrSpawnDelay = 0;
	self.svrSuicide = true;
	self setClientCvar("cg_thirdPerson", 0);
	self setClientCvar("cg_ThirdPersonRange", "120");
	self setmodel("");
}

explode()
{
	if (isPlayer(self) && isAlive(self))
	{
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_kill", &"ADMIN_EXPLODE");

		playfx(game["adminEffect"]["explode"], self.origin);
		wait .10;

		self painSounds();
		self.svrSpawnDelay = 0;
		self.svrSuicide = true;
		self suicide();
	}
}

mortar()
{
	if (!isPlayer(self) || !isAlive(self))
		return;

	self endon("svrKilledPlayer");

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
	self thread printMsg("rpam_mortar", &"ADMIN_MORTAR");
	wait 1;

	self.health = 100;

	self thread playSoundAtLocation("mortar_incoming2", self.origin, 1);
	wait .75;

	while (isAlive(self) && self.sessionstate == "playing")
	{
		target = self.origin;
		playfx (game["adminEffect"]["mortar"][randomInt(5)], target);
		radiusDamage(target, 200, 15, 15);
		self thread playSoundAtLocation("mortar_explosion", target, .1 );

		if (self.health < 35)
			self setClientCvar("cl_stance", 2);	   // for cod/uo

		earthquake(0.3, 3, target, 850);
		wait 2;
	}
}

crouch()
{
	if (isPlayer(self) && !isDefined(self.adminCrouch))
	{
		self endon("disconnect");
		self notify("crouchoff");
		self endon("crouchoff");

		time = _rPAM_rules\_rpam_admin_utils::cvardef("svr_admincrouchtime", 10, 1, 9999, "int");
		count = 0;

		self.adminCrouch = true;
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_crouch", &"ADMIN_CROUCH");

		while (isDefined(self.adminCrouch))
		{
			while (isAlive(self) && self.sessionstate == "playing" && count < time && isDefined(self.adminCrouch))
			{
				if (self getStance() != "crouch")
					self setClientCvar("cl_stance", 1);

				count += .50;
				wait .50;
			}

			if (count >= time)
				break;

			wait .50;
		}

		self.adminCrouch = undefined;
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_crouchoff", &"ADMIN_CROUCHOFF");
	}
	else if (isPlayer(self) && isDefined(self.adminCrouch))
	{
		self.adminCrouch = undefined;
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_crouchoff", &"ADMIN_CROUCHOFF");
	}
}

disarm()
{
	if (isPlayer(self) && !isDefined(self.adminDisarm))
	{
		self endon("disconnect");
		self notify("disarmoff");
		self endon("disarmoff");

		time = _rPAM_rules\_rpam_admin_utils::cvardef("svr_admindisarmtime", 10, 1, 9999, "int");
		count = 0;

		self.adminDisarm = true;
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_disarm", &"ADMIN_DISARM");

		while (isDefined(self.adminDisarm))
		{
			slot = [];
			slot[0] = "primary";
			slot[1] = "primaryb";

			if (game["svrGameName"] != "cod2")
			{
				slot[2] = "pistol";
				slot[3] = "grenade";

				if (game["svrGameName"] == "uo")
				{
					slot[4] = "smokegrenade";
					slot[5] = "satchel";
					slot[6] = "binocular";
				}
			}

			while (isAlive(self) && self.sessionstate == "playing" && count < time && isDefined(self.adminDisarm))
			{
				_a = self.angles;

				for (i = 0; i < slot.size; i++)
				{
					_w = self getWeaponSlotWeapon(slot[i]);

					if (_w != "none")
						self dropItem(_w);

					self.angles = _a + (0,randomInt(30),0);
				}

				count += .50;
				wait .50;
			}

			if (count >= time)
				break;

			wait .50;
		}

		self.adminDisarm = undefined;
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_disarmoff", &"ADMIN_DISARMOFF");
	}
	else if (isPlayer(self) && isDefined(self.adminDisarm))
	{
		self.adminDisarm = undefined;
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_disarmoff", &"ADMIN_DISARMOFF");
	}
}

lock()
{
	if (isPlayer(self) && !isDefined(self.adminLock))
	{
		self endon("disconnect");
		self notify("lockoff");
		self endon("lockoff");

		time = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminlocktime", 10, 1, 9999, "int");
		count = 0;

		self.adminLock = true;
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_lock", &"ADMIN_LOCK");

		while (isDefined(self.adminLock))
		{
			self.anchor = spawn("script_origin", self.origin);
			self linkTo(self.anchor);
			self disableWeapon();

			while (isAlive(self) && self.sessionstate == "playing" && count < time && isDefined(self.adminLock))
			{
				count += .50;
				wait .50;
			}

			if (count >= time)
				break;

			while (self.sessionstate != "playing")
				wait .50;
		}

		self.adminLock = undefined;

		if (!isPlayer(self) || !isDefined(self.anchor))
			return;

		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_lockoff", &"ADMIN_LOCKOFF");

		self unlink();
		self.anchor delete();
		self enableWeapon();
	}
	else if (isPlayer(self) && isDefined(self.adminLock))
	{
		self.adminLock = undefined;

		if (!isDefined(self.anchor))
			return;

		self unlink();
		self.anchor delete();
		self enableWeapon();

		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_lockoff", &"ADMIN_LOCKOFF");
	}
}

adminSpec()
{
	if ((!isDefined(self.pers["svrIsAdmin"]) || !self.pers["svrIsAdmin"]) && (!isDefined(self.pers["svrIsClan"]) || !self.pers["svrIsClan"]))
		return;

	if (isPlayer(self) && !isDefined(self.svrAdminSpec))
	{
		if (!isDefined(self.pers["team"]) || self.pers["team"] == "spectator")
			return;

		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_hide", &"ADMIN_HIDE");

		self allowSpectateTeam("allies", true);
		self allowSpectateTeam("axis", true);
		self allowSpectateTeam("freelook", true);
		self allowSpectateTeam("none", true);

		self.svrAdminSpec = true;
		self.sessionstate = "spectator";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
	//	self.statusicon = "";
	}
	else if (isPlayer(self) && isDefined(self.svrAdminSpec))
	{
		self thread _rPAM_rules\_rpam_admin_utils::closeMenus();
		self thread printMsg("rpam_show", &"ADMIN_SHOW");

		self thread maps\mp\gametypes\_teams::SetSpectatePermissions();
		self.svrAdminSpec = undefined;

		if (isDefined(self.pers["team"]) && self.pers["team"] != "spectator")
		{
			self.svrSpawnDelay = 0;
			self thread [[level.spawnPlayer]]();
		}
	}
}

sayMsg(msg, bold, cvar)
{
	level endon ("svrKillThread");

	setCvar(cvar, "");

	if (bold)
	{
		iprintlnbold(msg + "^7");

		time = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminscroll", 0, 0, 6, "float");

		if (time)
		{
			wait time;
			iprintlnbold(" "); iprintlnbold(" "); iprintlnbold(" "); iprintlnbold(" "); iprintlnbold(" ");
		}
	}
	else
		iprintln(msg + "^7");
}

swapteam(all)
{
	self endon("disconnect");

	team = undefined;
	locStr = undefined;
	gt = getCvar("g_gametype");

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();

	if (self.pers["team"] == "axis")
	{
		team = "allies";
		locStr = (&"ADMIN_ALLIES");
	}
	else if (self.pers["team"] == "allies")
	{
		team = "axis";
		locStr = (&"ADMIN_AXIS");
	}

	if (all)
	{
		if (game["adminLocalMsg"])
			self iprintlnbold(&"ADMIN_SWAPTEAMS");
		else
			self iprintlnbold("^7Swapping Allies-to-Axis, Axis-to-Allies^7");
	}
	else
	{
		if (game["adminLocalMsg"])
			self iprintlnbold(&"ADMIN_MOVING", locStr);
		else
			self iprintlnbold("^7You are being moved to ^9" + team + "^7");
	}

	wait 3;

	if (self.sessionstate != "dead")
	{
		self.svrSpawnDelay = undefined;		// my mod
		self.autobalance = true;			// for uo
		self.switching_teams = true;			// for cod-2
		self.joining_team = team;				// for cod-2
		self.leaving_team = self.pers["team"];	// for cod-2
		self suicide();
	}

	self notify("end_respawn");
	self.pers["team"] = team;
	self.sessionteam = self.pers["team"];

	if (game["svrGameName"] == "uo")
		self.pers["teamTime"] = (gettime() / 1000);

	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["spawnweapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self.nextroundweapon = undefined;

	// this function is different depending on game-version..
	if (game["svrGameName"] == "uo" && (gt == "hq" || gt == "re" || gt == "sd"))
		_rPAM_rules\_rpam_admin_utils::specPermissions();

	self setClientCvar("ui_weapontab", "1");			// for uo
	self setClientCvar("ui_allow_weaponchange", "1");	// for cod-2
	self setClientCvar("g_scriptMainMenu", game["menu_weapon_" + team]);
	self openMenu(game["menu_weapon_" + team]);

	if (!all)
	{
		if (game["adminLocalMsg"])
			iprintln(&"ADMIN_MOVED", self, locStr);
		else
			iprintln(self.name + "^7 is being moved to^9 " + team + "^7");
	}
}

toSpec(all)
{
	self endon("disconnect");

	if (isDefined(self.pers["svrIsBot"]))
	{
		self notify("svrBotSpectate");
		setCvar("svr_bots", 0);
	}

	if (!isDefined(self.pers["team"]) || self.pers["team"] == "spectator")
		return;

	locStr = undefined;

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();

	if (game["adminLocalMsg"])
	{
		locStr = (&"ADMIN_SPEC");
		self iprintlnbold(&"ADMIN_MOVING", locStr);
	}
	else
		self iprintlnbold(level._prefix + "^7You are being moved to ^9Spectator^7");

	wait 3;

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();

	// this function is different depending on game-version..
	self _rPAM_rules\_rpam_admin_utils::spawnSpectator();

	if (!isDefined(level.noGtSupport) && !all)
	{
		if (game["adminLocalMsg"])
			iprintln(&"ADMIN_MOVED", self, locStr);
		else
			iprintln(level._prefix + self.name + "^7 was moved to ^9Spectator^7");
	}
}

toaxis(all)
{
	self endon("disconnect");

	team = undefined;
	locStr = undefined;
	gt = getCvar("g_gametype");

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();

	if (self.pers["team"] == "axis")
		return;

	if (self.pers["team"] == "allies" || self.pers["team"] == "spectator")
	{
		team = "axis";
		locStr = (&"ADMIN_AXIS");
	}

	if (all)
	{
		if (game["adminLocalMsg"])
			self iprintlnbold(&"ADMIN_SWAPTEAMS");
		else
			self iprintlnbold(level._prefix + "^7Swapping Allies-to-Axis, Axis-to-Allies^7");
	}
	else
	{
		if (game["adminLocalMsg"])
			self iprintlnbold(&"ADMIN_MOVING", locStr);
		else
			self iprintlnbold(level._prefix + "^7You are being moved to ^9Allies");
			//self iprintlnbold("^7You are being moved to ^9" + team + "^7");
	}

	wait 3;

	if (self.sessionstate != "dead")
	{
		self.svrSpawnDelay = undefined;		// my mod
		self.autobalance = true;			// for uo
		self.switching_teams = true;			// for cod-2
		self.joining_team = team;				// for cod-2
		self.leaving_team = self.pers["team"];	// for cod-2
		self suicide();
	}
	

	self notify("end_respawn");
	self.pers["team"] = team;
	self.sessionteam = self.pers["team"];

	if (game["svrGameName"] == "uo")
		self.pers["teamTime"] = (gettime() / 1000);

	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["spawnweapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self.nextroundweapon = undefined;

	// this function is different depending on game-version..
	if (game["svrGameName"] == "uo" && (gt == "hq" || gt == "re" || gt == "sd"))
		_rPAM_rules\_rpam_admin_utils::specPermissions();
		
	if(getCvar("scr_force_bolt_rifles") == "1")
	{
		//self _rPAM_rules\_rpam_admin_utils::spawnSpectator();
		self setClientCvar("ui_weapontab", "1");			// for uo
		self setWeaponSlotWeapon("primary", "kar98k_mp");
		self setWeaponSlotWeapon("primaryb", "mosin_nagant_mp");
		self setClientCvar("g_scriptMainMenu", game["menu_weapon_" + team]);
		self maps\mp\gametypes\_pam_sd::spawnPlayer();
	}
	else if(getCvar("scr_force_bolt_rifles") == "0")
	{
		//self _rPAM_rules\_rpam_admin_utils::spawnSpectator();
		self setClientCvar("ui_weapontab", "1");			// for uo
		self setClientCvar("g_scriptMainMenu", game["menu_weapon_" + team]);
		self openMenu(game["menu_weapon_" + team]);
	}

	if (!isDefined(level.noGtSupport) && !all)
	{
		if (game["adminLocalMsg"])
			iprintln(&"ADMIN_MOVED", self, locStr);
		else
			iprintln(level._prefix + self.name + "^7 was moved to ^9Axis^7");
	}
}

toallies(all)
{
	self endon("disconnect");

	team = undefined;
	locStr = undefined;
	gt = getCvar("g_gametype");

	self thread _rPAM_rules\_rpam_admin_utils::closeMenus();

	if (self.pers["team"] == "allies")
		return;

	if (self.pers["team"] == "axis" || self.pers["team"] == "spectator")
	{
		team = "allies";
		locStr = (&"ADMIN_ALLIES");
	}
	else
	{
		if (game["adminLocalMsg"])
			self iprintlnbold(&"ADMIN_MOVING", locStr);
		else
			self iprintlnbold(level._prefix + "^7You are being moved to ^9Allies");
	}

	wait 3;

	if (self.sessionstate != "dead")
	{
		self.svrSpawnDelay = undefined;		// my mod
		self.autobalance = true;			// for uo
		self.switching_teams = true;			// for cod-2
		self.joining_team = team;				// for cod-2
		self.leaving_team = self.pers["team"];	// for cod-2
		self suicide();
	}
	

	self notify("end_respawn");
	self.pers["team"] = team;
	self.sessionteam = self.pers["team"];

	if (game["svrGameName"] == "uo")
		self.pers["teamTime"] = (gettime() / 1000);

	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["spawnweapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self.nextroundweapon = undefined;

	// this function is different depending on game-version..
	if (game["svrGameName"] == "uo" && (gt == "hq" || gt == "re" || gt == "sd"))
		_rPAM_rules\_rpam_admin_utils::specPermissions();
		
	if(getCvar("scr_force_bolt_rifles") == "1")
	{
		self setClientCvar("ui_weapontab", "1");			// for uo
		self setWeaponSlotWeapon("primary", "mosin_nagant_mp");
		self setWeaponSlotWeapon("primaryb", "kar98k_mp");
		self setClientCvar("g_scriptMainMenu", game["menu_weapon_" + team]);
		self maps\mp\gametypes\_pam_sd::spawnPlayer();
	}
	else if(getCvar("scr_force_bolt_rifles") == "0")
	{
		self setClientCvar("ui_weapontab", "1");			// for uo
		self setClientCvar("g_scriptMainMenu", game["menu_weapon_" + team]);
		self openMenu(game["menu_weapon_" + team]);
	}

	if (!isDefined(level.noGtSupport) && !all)
	{
		if (game["adminLocalMsg"])
			iprintln(&"ADMIN_MOVED", self, locStr);
		else
			self iprintlnbold(level._prefix + "^7You are being moved to ^9Allies");
			iprintln(level._prefix + self.name + "^7 was moved to ^9Allies^7");
	}
}

painSounds()
{
	team = self _rPAM_rules\_rpam_admin_utils::getTeam();

	if (!isDefined(team))
	{
	//	self iprintln("in admin::painSounds, team is undefined");
		return;
	}

	if (team == "axis")
		nat = "german";
	else
		nat = "american";

	self playSound("generic_pain_" + nat + "_1");
}

printMsg(cmd, loc)
{
	if (game["adminLocalMsg"] && isDefined(loc))
		msg = loc;
	else
	{
		switch (cmd)
		{
		case "burn":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "n", "", "", "string");		break;
		case "drug":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");		break;
		case "cow":		msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");		break;
		case "ship":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");		break;
		case "explode":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");		break;
		case "mortar":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");		break;
		case "pam_list":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");		break;
		case "forceready": msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");		break;
		//
		case "crouch":		msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");	break;
		case "crouchoff":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");	break;
		case "disarm":		msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");	break;
		case "disarmoff":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");	break;
		case "lock":		msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");	break;
		case "lockoff":		msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "", "", "", "string");	break;
		//
		case "hide":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "^7You are a hidden spectator", "", "", "string");	break;
		case "show":	msg = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessage_" + cmd, "^7You are no longer hidden", "", "", "string");	break;
		}
	}

	if (isDefined(msg) && msg != "none")
	{
		var = _rPAM_rules\_rpam_admin_utils::cvardef("svr_adminmessagetype", 1, 1, 2, "int");

		if (var == 1)	self iprintln(msg);
		else			self iprintlnbold(msg);
	}
}

PlaySoundAtLocation(sound, location, iTime)
{
	org = spawn("script_model", location);
	wait 0.05;
	org show();
	org playSound(sound);
	wait iTime;
	org delete();
}

pam_list()
{
	self iprintln("^7Valid Rifles Only Pam Modes^3:");
	self iprintln("^9vcodgg^3,^9 pub_ro^3.");
	wait 3;
	self iprintln("^7Valid All Weapons Pam Modes^3:");
	self iprintln("^9codbase^3, ^9codbase_bo3^3, ^9codbase_1v1^3, ^9pub_aw^3.");
	wait 3;
	self iprintln("^7Other Valid modes are^3:");
	self iprintln("^9strat^3, ^9bash^3.");
	wait 5;
	self iprintln("^7Rcon pam_mode ^9''mode''^7 will change the mode^3.");
}

forceready()
{
	wait 0.05;
	lpselfnum = self getEntityNumber();
	playername = level.R_U_Name[lpselfnum];
	
	logprint(playername + "," + lpselfnum + ", in forceready\n");
	
	if (level.R_U_State[lpselfnum] == "disconnected")
		{
			self.R_U_Looping = 0;
			level.R_U_Name[lpselfnum] = "disconnected";
			return;
		}
	
	if (level.R_U_State[lpselfnum] == "notready")
	{
		level.R_U_State[lpselfnum] = "ready";
		self.statusicon = game["br_hudicons_allies_4"];

		self iprintlnbold(level._prefix + "^7You are being Forced to ^2Ready-Up^7!");
		logPrint(self.name + "," + lpselfnum + "," + playername + ";" + " is FORCED Ready Logfile;" + "\n");
		iprintln(level._prefix + playername + "^7 was ^2Forced ^7to ^2Ready-Up");
		logPrint(playername + ";" + " is FORCED Ready Logfile;" + "\n");

		// change players hud to indicate player not ready
		self.hud_readyhud.color = (.73, .99, .73);
		self.hud_readyhud setText(game["ready"]);
	}
	else
	{
		iprintln(level._prefix + playername + "^7 is already ^2READY");
		logPrint(self.name + "," + lpselfnum + "," + playername + ";" + " is ALREADY Ready Logfile;" + "\n");
	}
	
	wait 0.05;
	
	level thread maps\mp\gametypes\_pam_readyup::Check_All_Ready();
		
	wait 0.25;
}

addbots()
{	

	thread maps\mp\gametypes\_pam_sd::addBotClients();

	//addtestclient();
}