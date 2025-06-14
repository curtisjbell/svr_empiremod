LeagueRules()
{
//*==============================================================================================*//
//*================================== *** League Logo *** =======================================*//


	game["leaguestring"] = &"^7Nade Training^3!";
	game["p_color"] = "^3";
	//game["rpam_branding"] = &"www^3.^7CoDBase^3.^7eu";


//*==============================================================================================*//
//*=============================== *** STRAT Setup Options *** ==================================*//

	
// Bomb Plant Settings
	setcvar("sv_BombPlantTime", "600");		// bomb plant time
	setcvar("sv_BombDefuseTime", "600");		// bomb defuse time
	setcvar("sv_BombTimer", "600");			// bomb timer

// vPAM Settings
	setCvar("p_anti_aimrun", 0); // Make weapon unusable if aimrunning.
	setCvar("p_anti_fastshoot", 0); // Detect fast shooting (or throwing nades).
	setCvar("p_anti_speeding", 0); // Punish players that go too fast (A+D spamming).
	setCvar ("g_debugDamage", "1"); // Only for strat

// Nades
	setcvar("scr_rifle_nade_count", "999");
	setcvar("scr_smg_nade_count", "999");
	setcvar("scr_mg_nade_count", "999");
	setcvar("scr_sniper_nade_count", "999");

// Cheats ON for Strat Mode
	setcvar("sv_pure", "1");			// SV_Pure is OFF
	setcvar("sv_cheats", "1");			// Cheats? Oh no!


//*==============================================================================================*//
//*================================ *** rPAM Setup Options *** ==================================*//


// Rifles Only Mode (Forcing Two Bolt-Action Rifles & Hitblip & Fastshoot Messages System)
	setcvar("rpam_riflesonly", "0");

// Display Countdown Timer
//	setcvar("rpam_countdownclock", "0");

// Do we enable killing while Ready-Up?
//	setcvar("rpam_rdyupkilling", "1");

// Ambient sounds
//	setcvar("rpam_ambientsounds", "1");

// Display informations to record demos while starting the first/second half
//	setcvar("rpam_demorecordinfo", "0");

// Do we allow rPAM to check client cvars and overwrite them?
//	setcvar("rpam_checkclientcvars", "0");

// Do we force SV_FPS 30 for better latency?
// (z_pam_checkclientcvars will set snaps 30 automatically)
//	setcvar("sv_fps", "30");

// Do we force specs to blackout?
//	setcvar("rpam_blackout_spec", "0");

// Do we force players to blackout?
//	setcvar("rpam_blackout_player", "0");

// Do we force players and spectators to blackout?
//	setcvar("sv_specblackout", "0");

// rPAM Strat Time
//	setcvar("rpam_strat", "0");			// Hold Players with rPAM Strat Time
//	setcvar("rpam_strat_time", "off");		// Strat Time / Grace Period

// rPAM HUD Items
	if ( getcvar( "sv_scoreboard" ) == "" )
		setcvar("sv_scoreboard", "default");	// Use PAM 108 Scoreboard

//	setcvar("rpam_playersleft", "0");		// rPAM Players Left
//	setcvar("sv_playersleft", "1");			// PAM Players Left
	setcvar("rpam_branding", "0");


//*==============================================================================================*//
//*============================ *** PAM Default Setup Options *** ===============================*//


// HUD Items
//	setcvar("sv_scoreboard", "big");		// Use BIG Scoreboard
//	setcvar("sv_playersleft", "1");			// players left

// Timers
	setcvar("g_matchwarmuptime", "10");		// match warmup time					
	setcvar("g_roundwarmuptime", "5");		// round warmup time
	setcvar("g_matchintermission", "20");		// match intermission

// Auto Screenshots / Console / Black Spec
	setcvar("g_autoscreenshot", "1");		// turns on autoscreenshot
	setcvar("g_disableClientConsole", "0");		// disable client console
//	setcvar("sv_specblackout", "0");		// blackout for specs

// SVR Settings
// ** NOT Likely to ever change **
	setcvar("scr_friendlyfire", "0");		// Friendly fire
	setcvar("scr_drawfriend", "1");			// Draws a team icon over teammates
	setCvar("scr_killcam", "0");			// Kill Cam OFF
	setCvar("scr_teambalance", "0");		// Team Balance OFF
	setcvar("scr_freelook", "0");			// Free Spectate OFF
	setcvar("scr_spectateenemy", "0");		// Spectate Enemy OFF
	setcvar("sv_minPing", "0");			// No Minimum Ping	
	setcvar("sv_maxPing", "0");			// No Maximum Ping


	setcvar("g_speed", "190");			// Player Speed
	setcvar("g_gravity", "800");			// Cheats? Oh no!
	setcvar("g_deadchat", "1");			// Dead Speak to Living
	setcvar("g_maxDroppedWeapons", "16");		// Max weapons allowed laying around
	setcvar("g_weaponrespawn", "5");		// How long before spawned weapons respawn

// PAM Sounds	
	setcvar("sv_pamsounds", "0");			// pamsounds
	setcvar("sv_axisgoat", "0");			// axis goat sound when bashed

// ** Do NOT Touch This **
	game["mode"] = "match";
}