Rules()
{
	// Logo
	game["leaguestring"] = &"^9Overtime^4!"; 				//NOTE!!! NEVER REMOVE THE & SYMBOL OR SERVER WILL CRASH
	//game["brandstring"] = &"^7www^4.^7UnitedBase^4.^7eu"; 	// Branding Text # out for now
	game["p_color"] = "^3";

	/*========================================================*/
	/* ================== Pam Mode Options ========================*/
	/*========================================================*/

	// Match Setup Options
	setcvar("scr_sd_half_round" , "3");	// Switch AFTER this round.
	setcvar("scr_sd_half_score" , "0");	// Switch AFTER this score.
	setcvar("scr_sd_end_round" , "6");	// End Map AFTER this round.
	setcvar("scr_sd_end_score" , "4");		// End Map AFTER this total score.
	setcvar("scr_sd_end_half2score" , "0");// End Map AFTER this 2nd-half score.
	setcvar("scr_sd_count_draws", "0");	// Re-play rounds that end in a draw
	setcvar("scr_sd_roundlength" , "2.25"); // Round Lenght

		// Draws & OT settings
	setcvar("g_ot", "1");				// Are there Overtime rules for this match? 0=No / 1=Yes
	setCvar("scr_randomsides", "0");	// Choose Random Sides for us if we need OT - Not implemented in SD yet

	//Bomb Plant Settings
	setcvar("sv_BombPlantTime", "5");		// bomb plant time
	setcvar("sv_BombDefuseTime", "10");		// bomb defuse time
	setcvar("sv_BombTimer", "60");			// bomb timer

	// HUD Items
	setcvar("sv_scoreboard", "tiny");			// Use BIG Scoreboard
	setcvar("sv_playersleft", "1");				// players left

	// Timers
	setcvar("g_matchwarmuptime", "3");			// match warmup time					
	setcvar("g_roundwarmuptime", "7");			// round warmup time
	setcvar("g_matchintermission", "0");		// match intermission

	//Timeouts
	setcvar("g_timeoutsAllowed", "2"); 			//The number of timeouts allowed per side. 
	setcvar("g_timeoutLength", "300000"); 		//The length of each timeout. 
	setcvar("g_timeoutRecovery", "10000"); 		//The length of the preparation period which occurs after a time-in is called, or after a timeout expires.  This recovery period is used to alert all players that play is about to begin. 
	setcvar("g_timeoutBank", "600000"); 		//The total amount of time a team can spend in timeout.


	// Strat & Weapon Drop
	setcvar("scr_sd_graceperiod", "10");			// Grace Period
	setcvar("scr_strat_time", "1"); 			// 1 = On, 2 = Off
	setcvar("scr_allow_weapon_drops", "1");    	//Do we allow players to drop their secondary weapons?
	

	//Auto Screenshots / Console 
	setcvar("g_autoscreenshot", "1");			// turns on autoscreenshot
	setcvar("g_autodemo", "0"); 				// turns on autodemo
	setcvar("g_disableClientConsole", "0");		// disable client console

	// NOT Likely to ever change
	setcvar("scr_friendlyfire", "1");	// Friendly fire
	setcvar("scr_drawfriend", "1");		// Draws a team icon over teammates
	setCvar("scr_killcam", "0");		// Kill Cam OFF
	setCvar("scr_teambalance", "0");	// Team Balance OFF
	setcvar("scr_freelook", "1");		// Free Spectate OFF
	setcvar("scr_spectateenemy", "1");	// Spectate Enemy OFF
	setcvar("scr_shellshock" , "1");	// Shellshock after nade hit
	setcvar("scr_drophealth" , "1");	// Drops health at death
	setcvar("sv_minPing", "0");			// No Minimum Ping	
	setcvar("sv_maxPing", "0");			// No Maximum Ping
	setcvar("g_speed", "190");			// Player Speed
	setcvar("g_gravity", "800");		// Cheats? Oh no!
	setcvar("g_deadchat", "1");			// Dead Speak to Living
	setcvar("g_maxDroppedWeapons", "16");	// Max weapons allowed laying around
	setcvar("g_weaponrespawn", "5");	// How long before spawned weapons respawn

	// Battleranks 
	setcvar("scr_battlerank" , "1");
	setcvar("scr_forcerank", "0");
	setcvar("scr_rank_ppr" , "10"); 	//Sets the Points Per Rank

	// Cheats ON for Strat Mode
	setcvar("sv_pure", "1");			// SV_Pure is OFF
	setcvar("sv_cheats", "0");			// Cheats? Oh no!

	// Allow Voting 
	setcvar("scr_allow_vote" , "0");
	setcvar("g_allowvote" , "0");
	setcvar("g_allowvotetempbanuser" , "0");
	setcvar("g_allowvotetempbanclient" , "0");
	setcvar("g_allowvotekick" , "0");
	setcvar("g_allowvoteclientkick" , "0");
	setcvar("g_allowvotegametype" , "0");
	setcvar("g_allowvotetypemap" , "0");
	setcvar("g_allowvotemap" , "0");
	setcvar("g_allowvotemaprotate" , "0");
	setcvar("g_allowvotemaprestart" , "0");

	/*========================================================*/
	/* ============== Weapon Setup Options ===================*/
	/*========================================================*/

	// Map-Placed Weapon Respawns
	setcvar("g_weaponrespawn", "5"); 				// Weapons on the ground in maps will respawn after this many seconds

	// Force Bolt-Action Rifles Only
	setcvar("scr_force_bolt_rifles" , "0");

	// Rifles 
	setcvar("scr_allow_enfield" , "1");
	setcvar("scr_allow_kar98k" , "1");
	setcvar("scr_allow_m1garand" , "1");
	setcvar("scr_allow_nagant" , "1");
	setcvar("scr_allow_gewehr43" , "1");
	setcvar("scr_allow_svt40" , "1");

	//Snipers
	setcvar("sv_noDropSniper", "1");			// 1=can't drop sniper rifle, 0=Sniper Rifle Drops
	setcvar("sv_SniperLimit", "1");				// sniper limit

	setcvar("scr_allow_kar98ksniper" , "1");
	setcvar("scr_allow_nagantsniper" , "1");
	setcvar("scr_allow_springfield" , "1");
	setcvar("scr_allow_fg42" , "0");

	// MGs
	setcvar("sv_MGLimit", "99");				// mg limit

	setcvar("scr_allow_bar" , "1");
	setcvar("scr_allow_bren" , "1");
	setcvar("scr_allow_mp44" , "1");
	setcvar("scr_allow_ppsh" , "1");

	//SMGs
	setcvar("sv_SMGLimit", "99");				// smg limit

	setcvar("scr_allow_sten" , "1");
	setcvar("scr_allow_mp40" , "1");
	setcvar("scr_allow_thompson" , "1");
	setcvar("scr_allow_m1carbine" , "1");

	// Rockets
	setcvar("scr_allow_panzerfaust" , "0");
	setcvar("scr_allow_panzerschreck", "0");
	setcvar("scr_allow_bazooka" , "0");

	// Deployable Machine Guns
	setcvar("sv_noDropDMG", "1");				// 1=can't drop Deployable MG, 0=DMG Drops
	setcvar("sv_DMGLimit", "1"); 				// deployable mg limit

	setcvar("scr_allow_mg34" , "1");
	setcvar("scr_allow_dp28" , "1");
	setcvar("scr_allow_mg30cal" , "1");

	// MG42 (Stationary MG positions)
	setCvar("scr_allow_mg42", "1");

	// Pistols
	setcvar("scr_allow_pistols" , "1");

	// Nades and Satchels
	setcvar("scr_allow_smoke" , "1");
	setcvar("scr_allow_grenades" , "1");
	setcvar("scr_allow_satchel" , "0");
	setCvar("scr_allow_binoculars", "1");

	// Vehicles 
	setcvar("scr_allow_jeeps" , "0");
	setcvar("scr_allow_jeep_gunner" , "0");
	setcvar("scr_allow_tanks" , "0");

	setcvar("scr_allow_flak88" , "0");
	setcvar("scr_allow_su152" , "0");
	setcvar("scr_allow_elefant" , "0");
	setcvar("scr_allow_panzeriv" , "0");
	setcvar("scr_allow_t34" , "0");
	setcvar("scr_allow_sherman" , "0");
	setcvar("scr_allow_horch" , "0");
	setcvar("scr_allow_gaz67b" , "0");
	setcvar("scr_allow_willyjeep" , "0");

	//Vehicle Limits & Timers
	setcvar("scr_jeep_spawn_limit", "0"); // 0 is disabled
	setcvar("scr_tank_spawn_limit", "0"); // 0 is disabled
	setcvar("scr_vehicle_limit_jeep", "50");
	setcvar("scr_vehicle_limit_medium_tank", "50");
	setcvar("scr_vehicle_limit_heavy_tank", "50");
	setcvar("scr_jeep_respawn_wait" , "5");
	setcvar("scr_tank_respawn_wait" , "10");

	// Vehicle Self Destruct Times
	setCvar("scr_selfDestructTankTime", "180");
	setCvar("scr_selfDestructJeepTime", "90");
	setcvar("g_vehicleBurnTime" , "10"); // Time in seconds a vehicle burns before blowing up

	// HTTP Setup 
	setcvar("sv_wwwDownload" , "1");
	setcvar("sv_wwwBaseURL" , "http://144.76.91.254/downloads/unitedbase/coduo"); 
	setcvar("sv_wwwDlDisconnected", "0");
	setcvar("sv_allowdownload", "1");

	/* Do NOT Touch These */
	game["mode"] = "match";
}
