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

PB_ScriptChecker()
{
	if (getcvarint("pam_pb_scriptchecker") > 0)
	{
		// Give us some time before we start &
		// Allow players to join the server
		wait 20;

		// Lets begin, shall we
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			player.pers["CoD_Ent"] = player getEntityNumber();
			player.pers["PB_Ent"] = player.pers["CoD_Ent"] + 1;
			player.pers["CoD_GUID"] = player getGuid();

			if (isDefined(player.pers["tk_count"]) && isDefined(player.pers["PB_Ent"]))
			{
				// The above IF is just to make sure we dont catch someone that
				// is connecting, but not connected.
				Do_ScriptCheck(player.pers["PB_Ent"]);
			}

			wait 2;
		}

		thread ScriptChecker_Watch_for_New_Joins();

		if (getcvarint("pam_pb_scriptchecker") > 1)
			thread Random_Script_Checker();
	}
}

ScriptChecker_Watch_for_New_Joins()
{
	while (1)
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if (isDefined(player.pers["PB_Ent"]) )
			{
				// This is defined, so I know we have scanned this guy once already
				continue;
			}

			if (!isDefined(player.pers["tk_count"]) )
			{
				//Player is connecting, but not yet connected
				// Lets give the player some time
				wait 10;
				continue;
			}

			player.pers["CoD_Ent"] = player getEntityNumber();
			player.pers["PB_Ent"] = player.pers["CoD_Ent"] + 1;
			player.pers["CoD_GUID"] = player getGuid();

			Do_ScriptCheck(player.pers["PB_Ent"]);
			wait 3;
		}

		// lets only scan for new players every once in a while
		wait 10;
	}
}

Random_Script_Checker()
{
	//Set-up future variables
	last_checked_1 = -1;
	last_checked_2 = -1;
	last_checked_3 = -1;

	while (1)
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

		if (!isDefined(player.pers["tk_count"]) )
		{
			//Player is connecting, but not yet connected
			// Lets give the player some time
			wait 3;
			continue;
		}

		if (!isDefined(player.pers["PB_Ent"]) )
		{
			// This is not defined so hes never been scanned
			// we'll catch him on the connect scan.
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
}

Do_ScriptCheck(pb_ent)
{
	exec("_rPAM_rules/pb/PBScriptScan/pb_bindcheck_1_" + pb_ent);
	wait 1.5;
	exec("_rPAM_rules/pb/PBScriptScan/pb_bindcheck_2_" + pb_ent);
	wait 1.5;
	exec("_rPAM_rules/pb/PBScriptScan/pb_bindcheck_3_" + pb_ent);
	wait 1.5;

	// Log all user-changed cvars
	exec("_rPAM_rules/pb/CvarChanged/changed_" + pb_ent);
	wait 2;

	// Log all user-made cvars
	exec("_rPAM_rules/pb/CvarCreated/created_" + pb_ent);
}
