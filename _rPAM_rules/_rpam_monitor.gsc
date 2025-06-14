// I take no credits in making this script. All credit goes to vPAM and Walrus.
// Adapted to rPAM by Anglhz<3

start()
{
	if (level._jumper) {
		thread _rPAM_rules\monitor\jumper::start();
	}
	
	if (level._afk_to_spec || level._fence) {
		thread _rPAM_rules\monitor\position::start(level._afk_to_spec, level._fence);
	}

	if (level._anti_fastshoot || level._anti_aimrun) {
		thread _rPAM_rules\monitor\weapon::start(level._anti_fastshoot, level._anti_aimrun);
	}

//	if (level._anti_speeding) {
//		thread _rPAM_rules\monitor\speed::start();
//	}

//	if (level._sprint) {
//		thread _rPAM_rules\monitor\sprint::start(level._sprint, level._sprint_time, level._sprint_time_recover);
//	}

	if (level._allow_drop) {
		thread _rPAM_rules\monitor\weapon_drop::start();
	}
}
