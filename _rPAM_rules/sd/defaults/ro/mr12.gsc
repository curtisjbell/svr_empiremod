LeagueRules()
{
//*==============================================================================================*//
//*================================== *** League Logo *** =======================================*//


	game["leaguestring"] = &"^7Rifles Only ^9MR 12 ^7Mode^3!";
	game["rpam_branding"] = &"^7www^3.^7CoDBase^3.^7eu";
	game["p_color"] = "^3";

//*==============================================================================================*//
//*=============================== *** Match Setup Options *** ==================================*//


	setcvar("scr_half_round", "12");		// Switch AFTER this round.
	setcvar("scr_half_score", "0");			// Switch AFTER this score.
	setcvar("scr_end_round", "24");			// End Map AFTER this round.
	setcvar("scr_end_score", "0");			// End Map AFTER this total score.
	setcvar("scr_end_half2score", "0");		// End Map AFTER this 2nd-half score.
	setcvar("scr_count_draws", "0");		// Re-play rounds that end in a draw
	setcvar("g_ot", "0");					// Overtime yes or no

// vPAM Settings
	setCvar("p_anti_aimrun", 1); 			// Make weapon unusable if aimrunning.
	setCvar("p_anti_fastshoot", 1); 		// Detect fast shooting (or throwing nades).
	setCvar("p_anti_speeding", 0); 			// Punish players that go too fast (A+D spamming).
	setCvar("g_debugDamage", "0"); 			// Only for strat

	if (getcvarint("g_ot_active") > 0)
		{
			setcvar("scr_half_round" , "3");		// Switch AFTER this round.
			setcvar("scr_end_round" , "6");			// End Map AFTER this round.
			setcvar("scr_end_score" , "4");			// End Map AFTER this total score.
		}

// S&D Settings
	setcvar("scr_sd_scorelimit", "0");		// Score limit per map
	setcvar("scr_sd_roundlimit", "0");		// Round limit per map
	setcvar("scr_sd_roundlength", "2.25");	// Time length of each round
	setcvar("scr_sd_timelimit", "0");		// Time limit per map

// Grace/Strat Period
	setcvar("scr_sd_graceperiod", "5");		// Grace Period
	setcvar("scr_strat_time", "0"); 		// Hold players still during Strat Time?

// Bomb Plant Settings
	setcvar("sv_BombPlantTime", "5");		// bomb plant time
	setcvar("sv_BombDefuseTime", "10");		// bomb defuse time
	setcvar("sv_BombTimer", "60");			// bomb timer

// Timeouts
	setcvar("g_timeoutsAllowed", "1");		// number of timeouts per side	
	setcvar("g_timeoutLength", "300000");		// length of timeouts
	setcvar("g_timeoutRecovery", "10000");		// counter before match resumes
	setcvar("g_timeoutBank", "600000");		// timeout bank


//*==============================================================================================*//
//*================================ *** rPAM Setup Options *** ==================================*//


// Rifles Only Mode (Forcing Two Bolt-Action Rifles & Hitblip & Fastshoot Messages System)
	setcvar("rpam_riflesonly", "1");

// Display Countdown Timer
	setcvar("rpam_countdownclock", "1");

// Do we enable killing while Ready-Up?
	setcvar("rpam_rdyupkilling", "0");

// Ambient sounds
	setcvar("rpam_ambientsounds", "0");

// Display informations to record demos while starting the first/second half
	setcvar("rpam_demorecordinfo", "1");

// Do we allow rPAM to check client cvars when spawning players and overwrite them?
	setcvar("rpam_checkclientcvars", "0");

// Do we force specs to blackout?
	setcvar("rpam_blackout_spec", "0");

// Do we force players to blackout?
	setcvar("rpam_blackout_player", "0");

// Do we force players and spectators to blackout?
	setcvar("sv_specblackout", "0");

// rPAM Strat Time
	setcvar("rpam_strat", "1");				// Hold Players with rPAM Strat Time
	setcvar("rpam_strat_time", "5");		// Strat Time / Grace Period

// rPAM HUD Items
	setcvar("sv_scoreboard", "default");	// Use PAM 108 Scoreboard
	setcvar("sv_playersleft", "1");			// PAM Players Left
	setcvar("rpam_playersleft", "0");		// rPAM Players Left
	setcvar("rpam_branding", "0");			//rPAM Branding on/off


//*==============================================================================================*//
//*============================== *** Weapon Setup Options *** ==================================*//


// Do we allow players to drop their secondary weapons?
	setcvar("scr_allow_weapon_drops", "0");

// Force Bolt-Action Rifles Only
	setcvar("scr_force_bolt_rifles", "0");

// Snipers
	setcvar("sv_noDropSniper", "1");		// can't drop sniper rifle
	setcvar("sv_SniperLimit", "1");			// sniper limit

	setcvar("scr_allow_springfield", "0");
	setcvar("scr_allow_kar98ksniper", "0");
	setcvar("scr_allow_nagantsniper", "0");
	setcvar("scr_allow_fg42", "0");

// Rifles
	setcvar("scr_allow_enfield", "1");
	setcvar("scr_allow_kar98k", "1");
	setcvar("scr_allow_m1carbine", "1");
	setcvar("scr_allow_m1garand", "0");
	setcvar("scr_allow_nagant", "1");

// SMGs
	setcvar("sv_SMGLimit", "99");			// smg limit
	setcvar("scr_allow_mp40", "0");
	setcvar("scr_allow_sten", "0");
	setcvar("scr_allow_thompson", "0");

// MGs
	setcvar("sv_MGLimit", "99");			// mg limit

	setcvar("scr_allow_bar", "0");
	setcvar("scr_allow_bren", "0");
	setcvar("scr_allow_mp44", "0");
	setcvar("scr_allow_ppsh", "0");

// MG42
	setcvar("scr_allow_mg42", "0");

// Nade Spawn Ammo Settings
	setcvar("scr_rifle_nade_count", "0");
	setcvar("scr_smg_nade_count", "0");
	setcvar("scr_mg_nade_count", "0");
	setcvar("scr_sniper_nade_count", "0");
	setcvar("scr_allow_smoke" , "0");

// Pistols
	setcvar("scr_allow_pistol", "0");

//*==============================================================================================*//
//*============================ *** PAM Default Setup Options *** ===============================*//


// Timers
	setcvar("g_matchwarmuptime", "3");			// match warmup time					
	setcvar("g_roundwarmuptime", "7");			// round warmup time
	setcvar("g_matchintermission", "0");		// match intermission

// Auto Screenshots / Console / Black Spec
	setcvar("g_autoscreenshot", "1");			// turns on autoscreenshot
	setcvar("g_disableClientConsole", "0");		// disable client console

// SVR Settings
// ** NOT Likely to ever change **
	setcvar("scr_friendlyfire", "0");		// Friendly fire
	setcvar("scr_drawfriend", "1");			// Draws a team icon over teammates
	setCvar("scr_killcam", "0");			// Kill Cam OFF
	setCvar("scr_teambalance", "0");		// Team Balance OFF
	setcvar("scr_freelook", "0");			// Free Spectate OFF
	setcvar("scr_spectateenemy", "0");		// Spectate Enemy OFF
	setcvar("sv_minPing", "0");				// No Minimum Ping	
	setcvar("sv_maxPing", "0");				// No Maximum Ping
	setcvar("sv_pure", "1");				// SV_Pure is ON
	setcvar("sv_cheats", "0");				// Cheats? Oh no!
	setcvar("g_speed", "190");				// Player Speed
	setcvar("g_gravity", "800");			// Cheats? Oh no!
	setcvar("g_deadchat", "1");				// Dead Speak to Living
setcvar("g_maxDroppedWeapons", "16");		// Max weapons allowed laying around
	setcvar("g_weaponrespawn", "5");		// How long before spawned weapons respawn

// ** Do NOT Touch This **
	game["mode"] = "match";
}