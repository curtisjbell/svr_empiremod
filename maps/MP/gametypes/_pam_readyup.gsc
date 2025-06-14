/*	** rPAM Ready Up (_pam_readyup.gsc) **
	
	REISSUE Project Ares Mod version 1.11 by zyquist
	
	original script by Garetjax (V1.08)
	edit by zyquist (aka reissue_)

>>>	VERSION: SRC27
>>>	REL-TIMESTAMP: 20:00 13.06.2015
>>>	SRC-TIMESTAMP: 16:05 12.06.2015

*** DO NOT REMOVE ANY FUNCTION; PLEASE RESPECT THE MOD ***
*/

PAM_Ready_UP()
{
	wait 0;
	
	// Set ready up and warmup flags.
	level.rdyup = 1;
	level.warmup = 1;
	level.playersready = false;
	if (!isdefined(game["firstreadyupdone"]))
		game["firstreadyupdone"] = 0;
	
	// Create the waiting HUD element.
	level.waiting = newHudElem();
	level.waiting.alignX = "center";
	level.waiting.alignY = "middle";
	level.waiting.color = (1, 0, 0);
	level.waiting.x = 320;
	level.waiting.y = 390;
	level.waiting.fontScale = 1.5;
	level.waiting setText(game["waiting"]);
	
	setClientNameMode("manual_change");
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		player.pers["killer"] = false;
		lpselfnum = player getEntityNumber();
		player.statusicon = game["br_hudicons_allies_0"];
		level.R_U_Name[lpselfnum] = player.name;
		level.R_U_State[lpselfnum] = "notready";
		player.R_U_Looping = 0;
		
		// Fully qualify readyup() so it’s found in _pam_readyup.gsc.
		player thread maps\mp\gametypes\_pam_readyup::readyup(lpselfnum);
	}
	
	Waiting_On_Players();  // Wait until all players are ready.
	
	if (isdefined(level.waiting))
		level.waiting destroy();
	
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		if (level.battlerank)
			player.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(player);
		else
			player.statusicon = "";
		logprint(player.name + " ending grenade flying thread\n");
		player notify("end_Watch_Grenade_Throw");
	}
	
	setClientNameMode("auto_change");
	game["dolive"] = 1;
	level.rdyup = 0;
	level.warmup = 1;
	game["firstreadyupdone"] = 1;
	
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		if (level.battlerank)
			player.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(player);
		else
			player.statusicon = "";
		logprint(player.name + " ending grenade flying thread [2nd for safety?]\n");
		player notify("end_Watch_Grenade_Throw");
	}
}


Waiting_On_Players()
{
	wait 0;
	wait_on_timer = 0;
	
	level.waitingon = newHudElem(self);
	level.waitingon.x = 575;
	level.waitingon.y = 52;
	level.waitingon.alignX = "center";
	level.waitingon.alignY = "middle";
	level.waitingon.fontScale = 1.1;
	level.waitingon.color = (0.8, 1, 1);
	level.waitingon setText(game["waitingon"]);
	
	level.playerstext = newHudElem(self);
	level.playerstext.x = 575;
	level.playerstext.y = 92;
	level.playerstext.alignX = "center";
	level.playerstext.alignY = "middle";
	level.playerstext.fontScale = 1.1;
	level.playerstext.color = (0.8, 1, 1);
	level.playerstext setText(game["playerstext"]);
	
	level.notreadyhud = newHudElem(self);
	level.notreadyhud.x = 575;
	level.notreadyhud.y = 72;
	level.notreadyhud.alignX = "center";
	level.notreadyhud.alignY = "middle";
	level.notreadyhud.fontScale = 1.2;
	level.notreadyhud.color = (0.98, 0.98, 0.60);
	
	while (!level.playersready)
	{
		notready = 0;
		players = getentarray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			lpselfnum = player getEntityNumber();
			if (level.R_U_State[lpselfnum] == "notready")
			{
				notready++;
			}
		}
		level.notreadyhud setValue(notready);
		wait 1;
	}
	
	if (isdefined(level.notreadyhud))
		level.notreadyhud destroy();
	if (isdefined(level.waitingon))
		level.waitingon destroy();
	if (isdefined(level.playerstext))
		level.playerstext destroy();
}


readyup(entity)
{
	self endon("disconnect");
	
	// Ensure only one readyup thread is running.
	self notify("readyup_thread_start");
	self endon("readyup_thread_start");
	
	wait 0.5; // required for proper sync
	
	lpselfnum = self getEntityNumber();
	logprint(self.name + "," + lpselfnum + " readyup thread started\n");
	
	if (game["halftimeflag"] == "0")
		_rPAM_rules\_rPAM_messages::rMESSAGEstart();
	else
		_rPAM_rules\_rPAM_messages::rMESSAGEhalf();
	
	// Announce team assignment. Or Not. LOL
	//if ((self.pers["team"] == "axis" && game["firstreadyupdone"] == 0) || (self.pers["team"] == "allies" && game["firstreadyupdone"] != 0))
	//self iprintlnbold("^7You are on ^3Team 1");
	//else
	//self iprintlnbold("^7You are on ^3Team 2");
	
	//self iprintlnbold("^1~^3empire ^2| ^3Hit the ^1-Use- ^3key to Ready-Up");

	autoReadyTime = getCvarFloat("g_autoReadyTime");
	if (!isdefined(autoReadyTime) || autoReadyTime <= 0)
		autoReadyTime = 30;
	self iprintlnbold("^1~^3empire ^2| ^3You will be automatically readied after ^1" + autoReadyTime + " ^3seconds. Hit the ^1-Use- ^3key to Ready-Up now.");
	
	maps\mp\gametypes\_pam_utilities::CheckPK3files();
	
	status = newClientHudElem(self);
	status.x = 575;
	status.y = 120;
	status.alignX = "center";
	status.alignY = "middle";
	status.fontScale = 1.1;
	status.color = (0.8, 1, 1);
	status setText(game["status"]);
	
	readyhud = newClientHudElem(self);
	readyhud.x = 575;
	readyhud.y = 135;
	readyhud.alignX = "center";
	readyhud.alignY = "middle";
	readyhud.fontScale = 1.2;
	readyhud.color = (1, 0.66, 0.66);
	readyhud setText(game["notready"]);
	self.hud_readyhud = readyhud;
	
	playername = level.R_U_Name[entity];
	
	self.R_U_Looping = 1;
	
	// Get the auto-ready delay from the external cvar.
	autoReadyTime = getCvarFloat("g_autoReadyTime");
	if (!isdefined(autoReadyTime) || autoReadyTime <= 0)
		autoReadyTime = 30;
	
	// Create a HUD element to display the countdown timer.
	timerHud = newClientHudElem(self);
	timerHud.x = 575;
	timerHud.y = 155;
	timerHud.alignX = "center";
	timerHud.alignY = "middle";
	timerHud.fontScale = 1.1;
	timerHud.color = (1, 1, 0);
	
	startTime = getTime();
	
	while(!level.playersready)
	{
		if (level.R_U_State[entity] == "disconnected")
		{
			self.R_U_Looping = 0;
			level.R_U_Name[entity] = "disconnected";
			if (isdefined(timerHud))
				timerHud destroy();
			return;
		}
		
		if (self useButtonPressed() == true)
		{
			if (level.R_U_State[entity] == "notready")
			{
				level.R_U_State[entity] = "ready";
				self.statusicon = game["br_hudicons_allies_4"];
				iPrintLn(level._prefix + playername + "^7 is ^2Ready");
				logPrint(self.name + "," + lpselfnum + "," + playername + ";" + " is Ready Logfile;" + "\n");
				
				readyhud.color = (0.73, 0.99, 0.73);
				readyhud setText(game["ready"]);
				// Reset the countdown timer only when manually readying up.
				startTime = getTime();
			}
			else if (level.R_U_State[entity] == "ready")
			{
				level.R_U_State[entity] = "notready";
				self.statusicon = game["br_hudicons_allies_0"];
				iPrintLn(level._prefix + playername + "^7 is ^1Not Ready");
				logPrint(self.name + "," + lpselfnum + "," + playername + ";" + " is Not Ready Logfile;" + "\n");
				
				readyhud.color = (1, 0.66, 0.66);
				readyhud setText(game["notready"]);
			}
			level thread Check_All_Ready();
			wait 0.25;
			while (self useButtonPressed())
				wait 0.05;
		}
		else
		{
			elapsed = (getTime() - startTime) / 1000.0;
			remaining = autoReadyTime - elapsed;
			if (remaining < 0)
				remaining = 0;
			timerHud setText("Auto ready in: " + remaining + " sec");
			if (remaining <= 0)
			{
				if (level.R_U_State[entity] == "notready")
				{
					level.R_U_State[entity] = "ready";
					self.statusicon = game["br_hudicons_allies_4"];
					iPrintLn(level._prefix + playername + "^7 is ^2Ready (Auto)");
					logPrint(self.name + "," + lpselfnum + "," + playername + ";" + " is Auto Ready Logfile;" + "\n");
					
					readyhud.color = (0.73, 0.99, 0.73);
					readyhud setText(game["ready"]);
				}
				level thread Check_All_Ready();
				break;
			}
		}
		wait 0.1;
	}
	
	if (isdefined(timerHud))
		timerHud destroy();
	if (isdefined(readyhud))
		readyhud destroy();
	if (isdefined(status))
		status destroy();
}

Check_All_Ready()
{
	wait 0.05;
	logprint("Check_All_Ready started\n");
	if (level.playersready)
	{
		logprint("Check_All_Ready - players are already ready!!!!\n");
		return;
	}
	if (areAllPlayersReady())
	{
		logprint("Check_All_Ready - playersready=true FIRST CHECK\n");
		wait 1.5;
		if (areAllPlayersReady())
		{
			logprint("Check_All_Ready - playersready=true SECOND CHECK\n");
			level.playersready = true;
		}
		else
		{
			logprint("Check_All_Ready - playersready=false SECOND CHECK\n");
		}
	}
	else
	{
		logprint("Check_All_Ready - playersready=false FIRST CHECK\n");
	}
	logprint("Check_All_Ready finished\n");
}

areAllPlayersReady()
{
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		lpselfnum = player getEntityNumber();
		logprint(player.name + "," + lpselfnum + " check is ready\n");
		if (!isdefined(player.R_U_Looping))
		{
			level.R_U_Name[lpselfnum] = "undefined readyup player";
			level.R_U_State[lpselfnum] = "notready";
			player.R_U_Looping = 0;
			logprint(player.name + "," + lpselfnum + " undefined looping - set notready\n");
		}
		if (player.R_U_Looping == 0)
		{
			player thread maps\mp\gametypes\_pam_readyup::readyup(lpselfnum);
			logprint(player.name + "," + lpselfnum + " not looping - start looping and set notready\n");
			return false;
		}
		if (level.R_U_State[lpselfnum] == "notready")
		{
			logprint(player.name + "," + lpselfnum + " found player that is not ready - breaking check\n");
			return false;
		}
	}
	return true;
}

Check_All_Ready_Forced()
{
	wait 0.1;
	checkready = true;
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		lpselfnum = player getEntityNumber();
		if (!isdefined(player.R_U_Looping))
		{
			level.R_U_Name[lpselfnum] = self.name;
			level.R_U_State[lpselfnum] = "notready";
			player.R_U_Looping = 0;
		}
		if (player.R_U_Looping == 0)
			return;
		if (level.R_U_State[lpselfnum] == "notready")
			checkready = false;
	}
	if (checkready == true)
		level.playersready = true;
}
