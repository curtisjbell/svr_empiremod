/*	** rPAM SD RULESET (_cg_custom.gsc) **

	REISSUE Project Ares Mod version 1.11 by zyquist
	
	original script by CyberGamer P.A.M. V1.10 fixed2
	edit by zyquist (aka reissue_)

>>>	V1.11 -- V1

>>>	REL-TIMESTAMP: no timestamp here
>>>	SRC-TIMESTAMP: no timestamp here


*/

LeagueRules()
{
//*==============================================================================================*//
//*================================== *** League Logo *** =======================================*//


	game["leaguestring"] = &"CG Custom Match Mode";


//*==============================================================================================*//
//*=============================== *** Match Setup Options *** ==================================*//


	setcvar("scr_half_round", "10");		// Switch AFTER this round.
	setcvar("scr_half_score", "0");			// Switch AFTER this score.
	setcvar("scr_end_round", "20");			// End Map AFTER this round.
	setcvar("scr_end_score", "0");			// End Map AFTER this total score.
	setcvar("scr_end_half2score", "0");		// End Map AFTER this 2nd-half score.
	setcvar("scr_count_draws", "0");		// Re-play rounds that end in a draw
	setcvar("g_ot", "0");				// Overtime yes or no

// OT Settings
	setcvar("g_ot_active", "0");			// NEVER OT in this mode
	setcvar("g_allowtie" , "0");			// Allow tie after 1st overtime, 0 no ties,
                                                        // 1 allow tie after 1 ot

// S&D Settings
	setcvar("scr_sd_scorelimit", "0");		// Score limit per map
	setcvar("scr_sd_roundlimit", "0");		// Round limit per map
	setcvar("scr_sd_roundlength", "2.25");		// Time length of each round
	setcvar("scr_sd_timelimit", "0");		// Time limit per map

// Grace/Strat Period
	setcvar("scr_sd_graceperiod", "10");		// Grace Period
	setcvar("scr_strat_time", "1"); 		// Hold players still during Strat Time?

// Bomb Plant Settings
	setcvar("sv_BombPlantTime", "5");		// bomb plant time
	setcvar("sv_BombDefuseTime", "10");		// bomb defuse time
	setcvar("sv_BombTimer", "60");			// bomb timer

// Voting
	setcvar("scr_allow_vote", "0");			// No Voting in a mtach
	setcvar("g_allowVote", "0");			// No Voting in a match

// Timeouts
	setcvar("g_timeoutsAllowed", "1");		// number of timeouts per side	
	setcvar("g_timeoutLength", "300000");		// length of timeouts
	setcvar("g_timeoutRecovery", "10000");		// counter before match resumes
	setcvar("g_timeoutBank", "600000");		// timeout bank


//*==============================================================================================*//
//*================================ *** rPAM Setup Options *** ==================================*//


// Rifles Only Mode (Forcing Two Bolt-Action Rifles & Hitblip & Fastshoot Messages System)
	setcvar("rpam_riflesonly", "0");

// Display Countdown Timer
	setcvar("rpam_countdownclock", "0");

// Do we enable killing while Ready-Up?
	setcvar("rpam_rdyupkilling", "1");

// Ambient sounds
	setcvar("rpam_ambientsounds", "0.5");

// Display informations to record demos while starting the first/second half
	setcvar("rpam_demorecordinfo", "0");

// Do we allow rPAM to check client cvars and overwrite them?
	setcvar("rpam_checkclientcvars", "0");

// Do we force SV_FPS 30 for better latency?
// (rPAM will set snaps for clients automatically)
	setcvar("sv_fps", "30");

// Do we force specs to blackout?
	setcvar("rpam_blackout_spec", "0");

// Do we force players to blackout?
	setcvar("rpam_blackout_player", "0");

// Do we force players and spectators to blackout?
	setcvar("sv_specblackout", "0");

// rPAM Strat Time
	setcvar("scr_strat_time", "0");			// Turn this off for rPAM Strat Time
	setcvar("rpam_strat", "1");			// Hold Players with rPAM Strat Time
	setcvar("rpam_strat_time", "10");		// Strat Time / Grace Period

// rPAM HUD Items
	setcvar("sv_scoreboard", "default");		// Use PAM 108 Scoreboard
	setcvar("sv_playersleft", "0");			// PAM Players Left
	setcvar("rpam_playersleft", "1");		// rPAM Players Left


//*==============================================================================================*//
//*============================== *** Weapon Setup Options *** ==================================*//


// Do we allow players to drop their secondary weapons?
	setcvar("scr_allow_weapon_drops", "1");

// Force Bolt-Action Rifles Only
	setcvar("scr_force_bolt_rifles", "0");

// Snipers
	setcvar("sv_noDropSniper", "1");		// can't drop sniper rifle
	setcvar("sv_SniperLimit", "1");			// sniper limit

	setcvar("scr_allow_springfield", "1");
	setcvar("scr_allow_kar98ksniper", "1");
	setcvar("scr_allow_nagantsniper", "1");
	setcvar("scr_allow_fg42", "0");

// Rifles
	setcvar("scr_allow_enfield", "1");
	setcvar("scr_allow_kar98k", "1");
	setcvar("scr_allow_m1carbine", "1");
	setcvar("scr_allow_m1garand", "1");
	setcvar("scr_allow_nagant", "1");

// SMGs
	setcvar("sv_SMGLimit", "99");			// smg limit

	setcvar("scr_allow_mp40", "1");
	setcvar("scr_allow_sten", "1");
	setcvar("scr_allow_thompson", "1");

// MGs
	setcvar("sv_MGLimit", "99");			// mg limit

	setcvar("scr_allow_bar", "1");
	setcvar("scr_allow_bren", "1");
	setcvar("scr_allow_mp44", "1");
	setcvar("scr_allow_ppsh", "1");

// Rockets
	setcvar("scr_allow_panzerfaust", "0");

// MG42
	setcvar("scr_allow_mg42", "1");

// Nade Spawn Ammo Settings
	setcvar("scr_rifle_nade_count", "2");
	setcvar("scr_smg_nade_count", "1");
	setcvar("scr_mg_nade_count", "1");
	setcvar("scr_sniper_nade_count", "1");

// Pistols
	setcvar("scr_allow_pistol", "1");


//*==============================================================================================*//
//*============================ *** PAM Default Setup Options *** ===============================*//


// HUD Items
//	setcvar("sv_scoreboard", "big");		// Use BIG Scoreboard
//	setcvar("sv_playersleft", "1");			// players left

// Timers
	setcvar("g_matchwarmuptime", "10");		// match warmup time					
	setcvar("g_roundwarmuptime", "5");		// round warmup time
	setcvar("g_matchintermission", "0");		// match intermission

// Auto Screenshots / Console / Black Spec
	setcvar("g_autoscreenshot", "1");		// turns on autoscreenshot
	setcvar("g_disableClientConsole", "0");		// disable client console
//	setcvar("sv_specblackout", "0");		// blackout for specs

// SVR Settings
// ** NOT Likely to ever change **
	setcvar("scr_friendlyfire", "1");		// Friendly fire
	setcvar("scr_drawfriend", "1");			// Draws a team icon over teammates
	setCvar("scr_killcam", "0");			// Kill Cam OFF
	setCvar("scr_teambalance", "0");		// Team Balance OFF
	setcvar("scr_freelook", "0");			// Free Spectate OFF
	setcvar("scr_spectateenemy", "0");		// Spectate Enemy OFF
	setcvar("sv_minPing", "0");			// No Minimum Ping	
	setcvar("sv_maxPing", "0");			// No Maximum Ping
	setcvar("sv_pure", "1");			// SV_Pure is ON
	setcvar("sv_cheats", "0");			// Cheats? Oh no!
	setcvar("g_speed", "190");			// Player Speed
	setcvar("g_gravity", "800");			// Cheats? Oh no!
	setcvar("g_deadchat", "0");			// Dead Speak to Living
	setcvar("g_maxDroppedWeapons", "16");		// Max weapons allowed laying around
	setcvar("g_weaponrespawn", "5");		// How long before spawned weapons respawn

// ** Do NOT Touch This **
	game["mode"] = "match";
}