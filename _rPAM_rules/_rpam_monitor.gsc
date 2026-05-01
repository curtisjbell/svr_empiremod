// I take no credits in making this script. All credit goes to vPAM and Walrus.
// Adapted to rPAM by Anglhz<3

start()
{
	gametype = getdvar("g_gametype");
	if (gametype != "sd") {
		logprint("[rPAM] monitor startup skipped for non-SD gametype: " + gametype + "\n");
		return;
	}

	if (isDefined(level._rpam_monitor_started) && level._rpam_monitor_started) {
		return;
	}
	level._rpam_monitor_started = true;

	if (level._jumper && (!isDefined(level._rpam_monitor_jumper_started) || !level._rpam_monitor_jumper_started)) {
		level._rpam_monitor_jumper_started = true;
		thread _rPAM_rules\monitor\jumper::start();
	}
	
	if ((level._afk_to_spec || level._fence) && (!isDefined(level._rpam_monitor_position_started) || !level._rpam_monitor_position_started)) {
		level._rpam_monitor_position_started = true;
		thread _rPAM_rules\monitor\position::start(level._afk_to_spec, level._fence);
	}

	if ((level._anti_fastshoot || level._anti_aimrun) && (!isDefined(level._rpam_monitor_weapon_started) || !level._rpam_monitor_weapon_started)) {
		level._rpam_monitor_weapon_started = true;
		thread _rPAM_rules\monitor\weapon::start(level._anti_fastshoot, level._anti_aimrun);
	}

//	if (level._anti_speeding) {
//		thread _rPAM_rules\monitor\speed::start();
//	}

//	if (level._sprint) {
//		thread _rPAM_rules\monitor\sprint::start(level._sprint, level._sprint_time, level._sprint_time_recover);
//	}

	if (level._allow_drop && (!isDefined(level._rpam_monitor_weapon_drop_started) || !level._rpam_monitor_weapon_drop_started)) {
		level._rpam_monitor_weapon_drop_started = true;
		thread _rPAM_rules\monitor\weapon_drop::start();
	}
}
