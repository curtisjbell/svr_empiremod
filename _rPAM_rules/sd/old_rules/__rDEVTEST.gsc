/*	** rDEVTEST RULESET FILE **

	R - Project Ares Mod version 1.11 by zyquist
	

	script by zyquist (aka reissue_) for P.A.M V1.11 DEVTEST

>>>	REL-TIMESTAMP: no timestamp here
>>>	SRC-TIMESTAMP: no timestamp here


*/
/*
>>> V1.11

rTESTING
	rPAM = new commands are:
		z_pam_riflesonly
		z_pam_countdownclock
		z_pam_rdyupkilling
		z_pam_checkclientcvars
		z_pam_ambientsounds
		z_pam_demorecordinfo

rDEV = should be tested

	matchintermission
	timeouts
	g_maxDroppedWeapons
	g_weaponrespawn

>>> V1.10 BUGGY CODE

	scr_force_bolt_rifles wasnt working anymore
	mosin and kar asw new rifle only option was implemented
	hitblip and damage of 1000 for new rifle only option was implemented
	a countdownclock was implemented wrongly for all modes
	.......

*/
/*	** PAM SD RULESET (_cb_custom.gsc) **
	
	original script by P.A.M. V1.08
	edit by zyquist (aka reissue_)

>>> V1.11
	renamed _cb_custom_rules.gsc > _cb_custom.gsc
	r1 = renamed "Custom Match Mode" > "Clanbase Custom Match Mode"
	zz2 = added sv_fps 30

rPAM
	rPAM = all new commands by P.A.M. V1.11

>>> V1.09
//	zz1 = added pamstring

	r1 = renamed the leaguestring "Clanbase custom" > "Custom Match Mode"

>>> V1.07/.08
	Project Ares Mod version 1.07 Beta
	by Michael Berkowitz aka "Garetjax"
*/

LeagueRules()
{
	// Logo
//r1
	game["leaguestring"] = &"_rDEVTEST (Clanbase Custom Match Mode)";


	/*========================================================*/
	/* ============== Match Setup Options ====================*/
	/*========================================================*/

	setcvar("scr_half_round" , "2");		// Switch AFTER this round.
	setcvar("scr_half_score" , "0");		// Switch AFTER this score.
	setcvar("scr_end_round" , "4");		// End Map AFTER this round.
	setcvar("scr_end_score" , "0");			// End Map AFTER this total score.
	setcvar("scr_end_half2score" , "0");		// End Map AFTER this 2nd-half score.
	setcvar("scr_count_draws", "0");		// Re-play rounds that end in a draw
	setcvar("g_ot", "1");				// Overtime yes or no

	setCvar("p_anti_aimrun", 1); // Make weapon unusable if aimrunning.
	setCvar("p_anti_fastshoot", 1); // Detect fast shooting (or throwing nades).
	setCvar("p_anti_speeding", 1); // Punish players that go too fast (A+D spamming).

	setCvar("g_debugAlloc", "0");
	setCvar("g_debuganim", "0");
	setCvar("g_debugBullets", "0");
	setCvar("g_debugDamage", "0");
	setCvar("g_debugLocDamage", "0");
	setCvar("g_debugMove", "0");
	setCvar("g_debugProneCheck", "0");
	setCvar("g_debugProneCheckDepthCheck", "1");
	setCvar("g_debugShowHit", "0");
	setCvar("g_dumpAnims", "-1");

	//OT Settings
	//setcvar("g_ot_active", "0");			// NEVER OT in this mode

	//vPAM Settings
	setCvar("p_anti_fastshoot", true); // Detect fast shooting (or throwing nades).


	/* S&D STOCK Settings */
	setcvar("scr_sd_scorelimit", "0");		// Score limit per map
	setcvar("scr_sd_roundlimit", "0");		// Round limit per map
	setcvar("scr_sd_roundlength", "2.25");		// Time length of each round
	setcvar("scr_sd_timelimit", "0");		// Time limit per map


	// Grace/Strat Period
	setcvar("scr_sd_graceperiod", "3");		// Grace Period
	setcvar("scr_strat_time", "1");			// Hold players still during Strat Time?

	//Bomb Plant Settings
	setcvar("sv_BombPlantTime", "5");		// bomb plant time
	setcvar("sv_BombDefuseTime", "10");		// bomb defuse time
	setcvar("sv_BombTimer", "60");			// bomb timer

	// Voting
	setcvar("scr_allow_vote", "0");			// No Voting in a mtach
	setcvar("g_allowVote", "0");			// No Voting in a match

	// Timeouts
	setcvar("g_timeoutsAllowed", "2");		// number of timeouts per side	
	setcvar("g_timeoutLength", "90000");		// length of timeouts
	setcvar("g_timeoutRecovery", "10000");		// counter before match resumes
	setcvar("g_timeoutBank", "180000");		// timeout bank


	/*========================================================*/
	/* ============== Weapon Setup Options ===================*/
	/*========================================================*/

//rPAM
	setcvar("z_pam_riflesonly", "0");		//Just Mosin and Kar?

	setcvar("z_pam_countdownclock", "0");		//Countdown Timer?

	setcvar("z_pam_rdyupkilling", "0");		//RDYUP Killing?

	setcvar("z_pam_checkclientcvars", "0");		//CHECK SOME CVARS?

	setcvar("z_pam_ambientsounds", "0");		//Ambient I SAY YES, NOOB ADMINS SAY NO

	setcvar("z_pam_demorecordinfo", "0");		//Info to record?
// --

	//Do we allow players to drop their secondary weapons?
	setcvar("scr_allow_weapon_drops", "1");

	//Force Bolt-Action Rifles Only
	setcvar("scr_force_bolt_rifles", "0");

	//Snipers
	setcvar("sv_noDropSniper", "1");		// can't drop sniper rifle
	setcvar("sv_SniperLimit", "1");			// sniper limit

	setcvar("scr_allow_springfield", "1");
	setcvar("scr_allow_kar98ksniper", "1");
	setcvar("scr_allow_nagantsniper", "1");
	setcvar("scr_allow_fg42", "0");


	//Rifles
	setcvar("scr_allow_enfield", "1");
	setcvar("scr_allow_kar98k", "1");
	setcvar("scr_allow_m1carbine", "1");
	setcvar("scr_allow_m1garand", "1");
	setcvar("scr_allow_nagant", "1");


	//SMGs
	setcvar("sv_SMGLimit", "99");			// smg limit

	setcvar("scr_allow_mp40", "1");
	setcvar("scr_allow_sten", "1");
	setcvar("scr_allow_thompson", "1");


	//MGs
	setcvar("sv_MGLimit", "99");			// mg limit

	setcvar("scr_allow_bar", "1");
	setcvar("scr_allow_bren", "1");
	setcvar("scr_allow_mp44", "1");
	setcvar("scr_allow_ppsh", "1");


	//Rockets
	setcvar("scr_allow_panzerfaust", "0");


	//MG42
	setcvar("scr_allow_mg42", "1");


	//Nade Spawn Ammo Settings
	setcvar("scr_rifle_nade_count", "2");
	setcvar("scr_smg_nade_count", "1");
	setcvar("scr_mg_nade_count", "1");
	setcvar("scr_sniper_nade_count", "1");

	//Pistols
	setcvar("scr_allow_pistol", "1");


	/*========================================================*/
	/* ================== PAM Options ========================*/
	/*========================================================*/

	/* HUD Items */
	setcvar("sv_scoreboard", "big");		// Use BIG Scoreboard
	setcvar("sv_playersleft", "1");			// players left

	// Timers
	setcvar("g_matchwarmuptime", "10");		// match warmup time					
	setcvar("g_roundwarmuptime", "5");		// round warmup time
	setcvar("g_matchintermission", "0");		// match intermission

	//Auto Screenshots / Console / Black Spec
	setcvar("g_autoscreenshot", "1");		// turns on autoscreenshot
	setcvar("g_disableClientConsole", "0");		// disable client console
	setcvar("sv_specblackout", "0");		// blackout for specs

	/* NOT Likely to ever change */
	setcvar("scr_friendlyfire", "1");		// Friendly fire
	setcvar("scr_drawfriend", "1");			// Draws a team icon over teammates
	setCvar("scr_killcam", "0");			// Kill Cam OFF
	setCvar("scr_teambalance", "0");		// Team Balance OFF
	setcvar("scr_freelook", "0");			// Free Spectate OFF
	setcvar("scr_spectateenemy", "0");		// Spectate Enemy OFF
//zz2
	setcvar("sv_fps", "30");			// SV_FPS 30 for better latency

	setcvar("sv_minPing", "0");			// No Minimum Ping	
	setcvar("sv_maxPing", "0");			// No Maximum Ping
	setcvar("sv_pure", "1");			// SV_Pure is ON
	setcvar("sv_cheats", "1");			// Cheats? Oh no!
	setcvar("g_speed", "190");			// Player Speed
	setcvar("g_gravity", "800");			// Cheats? Oh no!
	setcvar("g_deadchat", "1");			// Dead Speak to Living
	setcvar("g_maxDroppedWeapons", "16");		// Max weapons allowed laying around
	setcvar("g_weaponrespawn", "5");		// How long before spawned weapons respawn

	// PAM Sounds	
	setcvar("sv_pamsounds", "0");			// pamsounds
	setcvar("sv_axisgoat", "0");			// axis goat sound when bashed


	/* Do NOT Touch These */
	game["mode"] = "match";
}