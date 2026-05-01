Check_PB_Config()
{
	Success = Load_PB_Config();
}

Load_PB_Config()
{
	if (getcvar("pb_sv_config") == "")
		setcvar("pb_sv_config", "none");

	setcvar("pb_sv_loaded", 0);

	pam_mode = getcvar("pam_mode");
	pb_config = getcvar("pb_sv_config");

	switch (pam_mode)
	{

	//Default AW
	case "aw_mr10":
	case "aw_mr12":
	case "aw_bo3":
	
	//Default RO
	case "ro_mr10":
	case "ro_mr12":

	//UnitedBase
	case "ub_bo1_mr10":
	case "ub_bo1_mr12":
	case "ub_mr10":
	case "ub_mr12":
	case "ub_bo3":

/* 
	// CoDBase AW
	case "cb_mr10":
	case "cb_mr10_mix":
	case "cb_mr12":
	case "cb_mr13":
	case "cb_bo1_mr10":
	case "cb_bo1_mr12":
	case "cb_bo3":

	// CoDBase RO
	case "cb_ro_mr10":
	case "cb_ro_mr12":
	case "cb_ro_mr13":
	case "cb_ro_bo1_mr10":
	case "cb_ro_bo1_mr12":
	case "cb_ro_bo3":
*/

		if (pb_config == "cb") //pb_sv_config
			return true;
		else
		{
			Announce_PB_Loading();
			exec("_rPAM_rules/pb/PBConfigs/cb_pbsv.cfg");
		}

		correct_config = "cb";
		break;

	// Optional PUB PB Config
	case "nade_training":

		if (pb_config == "pub")
			return true;
		else
		{
			exec("_rPAM_rules/pb/PBConfigs/pubannounce.cfg");
			wait 3;
			exec("pub_pbsv.cfg");
			setcvar("pb_sv_config", "pub");
			setcvar("pb_sv_loaded", 1);
		}

		correct_config = "pub";
		break;
	
	}

	while (getcvar("pb_sv_loaded") == "0")
	{
		wait 1;
	}

	pb_config = getcvar("pb_sv_config");
	if (pb_config != correct_config)
	{
		iprintln(level._prefix + "ERROR Loading ^9" + correct_config + " ^7PB Config File!");
		wait 3;
		if (correct_config == "pub")
			return true;
		else
			return false;
	}
	else
		return true;
}

Announce_PB_Loading()
{
	exec("_rPAM_rules/pb/PBConfigs/announce.cfg");
	wait 3;
}



Change_Log()
{
	iprintln(level._prefix + "Starting new PB log file");
	exec("_rPAM_rules/pb/PBLog/pb_sv_newlog.cfg");
}

PB_Init_Thread_Flags()
{
	level.pam_pb_stop_threads = false;
	level.pam_pb_scriptchecker_running = false;
	level.pam_pb_joinwatcher_running = false;
	level.pam_pb_randomchecker_running = false;
	level.pam_pb_lifecycle_running = false;
}

PB_Stop_Threads()
{
	level.pam_pb_stop_threads = true;
	level.pam_pb_scriptchecker_running = false;
	level.pam_pb_joinwatcher_running = false;
	level.pam_pb_randomchecker_running = false;
	level.pam_pb_lifecycle_running = false;
}

PB_Should_Stop_Threads()
{
	if (isDefined(level.pam_pb_stop_threads) && level.pam_pb_stop_threads)
		return true;

	return false;
}


PB_Thread_Lifecycle_Manager()
{
	if (isDefined(level.pam_pb_lifecycle_running) && level.pam_pb_lifecycle_running)
		return;

	level.pam_pb_lifecycle_running = true;
	level waittill_any("game_ended", "map_restart", "disconnect");
	PB_Stop_Threads();
	level.pam_pb_lifecycle_running = false;
}

PB_Set_Player_Entity_Data(player)
{
	if (!isDefined(player))
		return false;

	if (!isDefined(player.pers) || !isDefined(player.pers["tk_count"]))
		return false;

	player.pers["CoD_Ent"] = player getEntityNumber();
	player.pers["PB_Ent"] = player.pers["CoD_Ent"] + 1;
	player.pers["CoD_GUID"] = player getGuid();

	return true;
}

PB_ScriptChecker()
{
	if (!isDefined(level.pam_pb_scriptchecker_running) || !isDefined(level.pam_pb_joinwatcher_running) || !isDefined(level.pam_pb_randomchecker_running) || !isDefined(level.pam_pb_stop_threads))
		PB_Init_Thread_Flags();

	if (isDefined(level.pam_pb_scriptchecker_running) && level.pam_pb_scriptchecker_running)
		return;

	level.pam_pb_scriptchecker_running = true;
	level.pam_pb_stop_threads = false;
	thread PB_Thread_Lifecycle_Manager();

	level endon("game_ended");
	level endon("map_restart");
	level endon("disconnect");

	if (getcvarint("pam_pb_scriptchecker") <= 0)
	{
		PB_Stop_Threads();
		return;
	}

	// Give us some time before we start &
	// Allow players to join the server
	wait 20;

	if (PB_Should_Stop_Threads())
	{
		PB_Stop_Threads();
		return;
	}

	// Lets begin, shall we
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if (PB_Should_Stop_Threads())
			break;

		player = players[i];

		if (!PB_Set_Player_Entity_Data(player))
		{
			wait 2;
			continue;
		}

		if (isDefined(player) && isDefined(player.pers) && isDefined(player.pers["PB_Ent"]))
			Do_ScriptCheck(player.pers["PB_Ent"]);

		wait 2;
	}

	if (!PB_Should_Stop_Threads())
		thread ScriptChecker_Watch_for_New_Joins();

	if (!PB_Should_Stop_Threads() && getcvarint("pam_pb_scriptchecker") > 1)
		thread Random_Script_Checker();

	level.pam_pb_scriptchecker_running = false;
}

ScriptChecker_Watch_for_New_Joins()
{
	if (isDefined(level.pam_pb_joinwatcher_running) && level.pam_pb_joinwatcher_running)
		return;

	level.pam_pb_joinwatcher_running = true;

	level endon("game_ended");
	level endon("map_restart");
	level endon("disconnect");

	while (!PB_Should_Stop_Threads())
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if (PB_Should_Stop_Threads())
				break;

			player = players[i];

			if (!isDefined(player) || !isDefined(player.pers))
				continue;

			if (isDefined(player.pers["PB_Ent"]) )
			{
				// This is defined, so I know we have scanned this guy once already
				continue;
			}

			if (!PB_Set_Player_Entity_Data(player))
			{
				//Player is connecting, but not yet connected
				// Lets give the player some time
				wait 10;
				continue;
			}

			if (isDefined(player) && isDefined(player.pers) && isDefined(player.pers["PB_Ent"]))
				Do_ScriptCheck(player.pers["PB_Ent"]);
			wait 3;
		}

		// lets only scan for new players every once in a while
		wait 10;
	}

	level.pam_pb_joinwatcher_running = false;
}

Random_Script_Checker()
{
	if (isDefined(level.pam_pb_randomchecker_running) && level.pam_pb_randomchecker_running)
		return;

	level.pam_pb_randomchecker_running = true;

	level endon("game_ended");
	level endon("map_restart");
	level endon("disconnect");

	//Set-up future variables
	last_checked_1 = -1;
	last_checked_2 = -1;
	last_checked_3 = -1;

	while (!PB_Should_Stop_Threads())
	{
		if (getcvar("pam_pb_scriptcheck_timer") == "")
			setcvar("pam_pb_scriptcheck_timer", 90);

		timer = getcvarint("pam_pb_scriptcheck_timer");
		if (timer < 30)
			timer = 30;

		if (timer > 300)
			timer = 300;

		players = getentarray("player", "classname");

		if (players.size < 2)
		{
			wait 15;
			continue;
		}

		checkplayer = randomInt(players.size);

		player = players[checkplayer];

		if (!PB_Set_Player_Entity_Data(player))
		{
			//Player is connecting, but not yet connected
			// Lets give the player some time
			wait 3;
			continue;
		}

		if (!isDefined(player) || !isDefined(player.pers) || !isDefined(player.pers["PB_Ent"]) || !isDefined(player.pers["CoD_Ent"]) || !isDefined(player.pers["CoD_GUID"]))
		{
			wait 3;
			continue;
		}

		if (last_checked_1 == player.pers["CoD_Ent"] || last_checked_2 == player.pers["CoD_Ent"] || last_checked_3 == player.pers["CoD_Ent"])
		{
			guid = player getGuid();
			if (player.pers["CoD_GUID"] == guid && players.size > 5)
			{
				// We've checked this guy recently, lets pull another out the bag
				wait 3;
				continue;
			}
		}

		Do_ScriptCheck(player.pers["PB_Ent"]);

		// Rotate last checked variables
		last_checked_3 = last_checked_2;
		last_checked_2 = last_checked_1;
		last_checked_1 = player.pers["CoD_Ent"];

		wait timer;
	}

	level.pam_pb_randomchecker_running = false;
	level.pam_pb_lifecycle_running = false;
}

Do_ScriptCheck(pb_ent)
{
	exec("_rPAM_rules/pb/PBScriptScan/pb_bindcheck_1_" + pb_ent);
	wait 1.5;
}
