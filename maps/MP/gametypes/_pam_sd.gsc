/*	** PAM SD main (_pam_sd.gsc) **

	REISSUE Project Ares Mod version 1.11 by zyquist
	
	original script by Garetjax (V1.08)
	edit by zyquist (aka reissue_)
	coduo adapted by Anglhz

>>>	VERSION: SRC27

>>>	REL-TIMESTAMP: 13:34 14.06.2015
>>>	SRC-TIMESTAMP: 17:15 12.06.2015

>>> Updated 25.03.2024

>>>	**   YOU AREN'T ALLOWED TO CHANGE SOMETHING HERE   **
	** PLEASE RESPECT THE ENERGY OF MAKING P.A.M V1.11 **

*/

PamMain()
{
	level.callbackStartGameType = ::Callback_StartGameType;
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;

	maps\mp\gametypes\_callbacksetup::SetupCallbacks();

	level.mapname = getcvar("mapname");

	//Server Admin Commands
	_rPAM_rules\_rpam_admin::init();

	// Start Ravirs admin tools
	//thread maps\mp\gametypes\_pam_admin::main();

	maps\mp\gametypes\_pam_utilities::NonstockPK3Check();

	level._effect["bombexplosion"] = loadfx("fx/explosions/mp_bomb.efx");

	allowed[0] = "sd";
	allowed[1] = "bombzone";
	allowed[2] = "blocker";
	maps\mp\gametypes\_gameobjects::main(allowed);

	maps\mp\gametypes\_rank_gmi::InitializeBattleRank();
	maps\mp\gametypes\_secondary_gmi::Initialize();
	
	
	level.warmup = 0;	// warmup time reset in case they restart map via menu

	if(getCvar("scr_sd_timelimit") == "")		// Time limit per map
		setCvar("scr_sd_timelimit", "0");
	else if(getCvarFloat("scr_sd_timelimit") > 1440)
		setCvar("scr_sd_timelimit", "1440");
	level.timelimit = getCvarFloat("scr_sd_timelimit");
	setCvar("ui_sd_timelimit", level.timelimit);
	makeCvarServerInfo("ui_sd_timelimit", "0");

	if(!isDefined(game["timepassed"]))
		game["timepassed"] = 0;

	if(getCvar("scr_sd_scorelimit") == "")		// Score limit per map
		setCvar("scr_sd_scorelimit", "0");
	level.scorelimit = getCvarInt("scr_sd_scorelimit");
	setCvar("ui_sd_scorelimit", level.scorelimit);
	makeCvarServerInfo("ui_sd_scorelimit", "10");

	if(getCvar("scr_sd_roundlimit") == "")		// Round limit per map
		setCvar("scr_sd_roundlimit", "0");
	level.roundlimit = getCvarInt("scr_sd_roundlimit");
	setCvar("ui_sd_roundlimit", level.roundlimit);
	makeCvarServerInfo("ui_sd_roundlimit", "0");

	if(getCvar("scr_sd_roundlength") == "")		// Time length of each round
		setCvar("scr_sd_roundlength", "4");
	else if(getCvarFloat("scr_sd_roundlength") > 10)
		setCvar("scr_sd_roundlength", "10");
	level.roundlength = getCvarFloat("scr_sd_roundlength");

	if(getCvar("scr_sd_graceperiod") == "")		// Time at round start where spawning and weapon choosing is still allowed
		setCvar("scr_sd_graceperiod", "15");
	else if(getCvarFloat("scr_sd_graceperiod") > 60)
		setCvar("scr_sd_graceperiod", "60");
	level.graceperiod = getCvarFloat("scr_sd_graceperiod");

	if(getCvar("scr_battlerank") == "")		
		setCvar("scr_battlerank", "1");	//default is ON
	level.battlerank = getCvarint("scr_battlerank");
	setCvar("ui_battlerank", level.battlerank);
	makeCvarServerInfo("ui_battlerank", "0");

	if(getCvar("scr_shellshock") == "")		// controls whether or not players get shellshocked from grenades or rockets
		setCvar("scr_shellshock", "1");
	level.sshock = getcvarint("scr_shellshock");
	setCvar("ui_shellshock", getCvar("scr_shellshock"));
	makeCvarServerInfo("ui_shellshock", "0");
			
	if(!isDefined(game["compass_range"]))		// set up the compass range.
		game["compass_range"] = 1024;		
	setCvar("cg_hudcompassMaxRange", game["compass_range"]);
	makeCvarServerInfo("cg_hudcompassMaxRange", "0");

	if(getCvar("scr_drophealth") == "")		// Free look spectator
		setCvar("scr_drophealth", "1");
	level.healthdrop = getCvar("scr_drophealth");

	if(getCvar("scr_killcam") == "")			//Kill Cam
		killcam = "1";
	level.killcam = getCvarInt("scr_killcam");
	
	if(getCvar("scr_teambalance") == "")		// Auto Team Balancing
		setCvar("scr_teambalance", "0");
	level.teambalance = getCvarInt("scr_teambalance");
	level.lockteams = false;

	if(getCvar("scr_freelook") == "")			// Free look spectator
		setCvar("scr_freelook", "1");
	level.allowfreelook = getCvarInt("scr_freelook");
	
	if(getCvar("scr_spectateenemy") == "")		// Spectate Enemy Team
		setCvar("scr_spectateenemy", "1");
	level.allowenemyspectate = getCvarInt("scr_spectateenemy");
	
	if(getCvar("scr_drawfriend") == "")			// Draws a team icon over teammates
		setCvar("scr_drawfriend", "0");

	if(getCvar("scr_friendlyfire") == "")
		setCvar("scr_friendlyfire", "1");

	if(getCvar("scr_roundswitch") == "")
		setCvar("scr_roundswitch", "0");

	if(getCvar("sv_pure") == "")
		setCvar("sv_pure", "0");

	if(getCvar("g_allowVote") == "")
		setCvar("g_allowVote", "0");

	if(getcvar("g_ot") == "")
		setcvar("g_ot", "0");

	if(getcvar("g_ot_active") == "")
		setcvar("g_ot_active", "0");

	if ( getcvar( "g_allowtie" ) == "" )
		setcvar("g_allowtie", "1");
	
	if(getCvar("sv_messagecenter") == "")
		setCvar("sv_messagecenter", "0");

	if(getCvar("pam_mode") == "")
		thread _rPAM_rules\_rPAM_rulesets_sd::rPAMMODEdefault();

	if(!isdefined(game["runonce"]))
	{

		/* Get Game Settings */
		level.scorelimit = getCvarInt("scr_sd_scorelimit");
		level.roundlimit = getCvarInt("scr_sd_roundlimit");

		thread _rPAM_rules\_rPAM_rulesets_sd::rPAMMODES();

		if(!isDefined(game["mode"]))
			game["mode"] = "match";

		setcvar("scr_numbots", "11");
		game["switchprevent"] = false; //Can't switch teams after this bit gets set and you are already on a team

		game["runonce"] = 1;
	}

	//garetcode
	if(getcvar("g_matchwarmuptime") == "")	// match warmup time
		setcvar("g_matchwarmuptime", "10");
	if(getcvar("g_roundwarmuptime") == "")	// round warmup time
		setcvar("g_roundwarmuptime", "5");
	if(getcvar("g_matchintermission") == "")		// match intermission
		setcvar("g_matchintermission", "10");

	if(getcvar("sv_playersleft") == "")			// display players left
		setcvar("sv_playersleft", "1");		

	if(getcvar("rpam_playersleft") == "")		// display rpam players left
		setcvar("rpam_playersleft", "0");	

//	if(getcvar("sv_axisgoat") == "")			// axis goat off/on
		setcvar("sv_axisgoat", "0");	
		
//	if(getcvar("sv_pamsounds") == "")			// pam sounds off/on
		setcvar("sv_pamsounds", "0");	

	if(getcvar("sv_warmupmines") == "")			// warmup mines off/on
		setcvar("sv_warmupmines", "0");	

	if(getcvar("sv_showshots") == "")			// display shots off/on
		setcvar("sv_showshots", "1");	

	if(getcvar("sv_showstats") == "")			// display stats after rounds off/on
		setcvar("sv_showstats", "1");

	if ( getcvar( "sv_BombPlantTime" ) == ""  )
		setcvar("sv_BombPlantTime", "5");

	if ( getcvar( "sv_BombDefuseTime" ) == "")
		setcvar("sv_BombDefuseTime", "10");

	if ( getcvar( "sv_BombTimer" ) == "" )
		setcvar("sv_BombTimer", "60");

	if ( getcvar( "sv_specblackout" ) == "" )
		setcvar("sv_specblackout", "0");

	if ( getcvar( "sv_teamwarmupdmg" ) == "" )
		setcvar("sv_teamwarmupdmg", "1");

	if ( getcvar( "rpam_streaming" ) == "" )
		setcvar("rpam_streaming", "0");

	if ( getcvar( "rpam_riflesonly" ) == "" )
		setcvar("rpam_riflesonly", "0");
	makeCvarServerInfo("rpam_riflesonly", "0");

	if ( getcvar( "rpam_countdownclock" ) == "" )
		setcvar("rpam_countdownclock", "0");
	makeCvarServerInfo("rpam_countdownclock", "0");

	if ( getcvar( "rpam_checkclientcvars" ) == "" )
		setcvar("rpam_checkclientcvars", "0");
	makeCvarServerInfo("rpam_checkclientcvars", "0");

	if ( getcvar( "sv_ambientsounds" ) == "" )
		setcvar("sv_ambientsounds", "0");
	makeCvarServerInfo("sv_ambientsounds", "0");

	if ( getcvar( "rpam_demorecordinfo" ) == "" )
		setcvar("rpam_demorecordinfo", "0");
	makeCvarServerInfo("rpam_demorecordinfo", "0");

	if ( getcvar( "rpam_rdyupkilling" ) == "" )
		setcvar("rpam_rdyupkilling", "1");
	makeCvarServerInfo("rpam_rdyupkilling", "0");

	if ( getcvar( "sv_disableClientConsole" ) == "1" )
		setcvar("sv_disableClientConsole", "0");
	makeCvarServerInfo("sv_disableClientConsole", "0");

	if ( getcvar( "rpam_blackout_spec" ) == "" )
		setcvar("rpam_blackout_spec", "0");
	makeCvarServerInfo("rpam_blackout_spec", "0");

	if ( getcvar( "rpam_blackout_player" ) == "" )
		setcvar("rpam_blackout_player", "0");
	makeCvarServerInfo("rpam_blackout_player", "0");

	if ( getcvar( "rpam_strat" ) == "" )
		setcvar("rpam_strat", "0");
	makeCvarServerInfo("rpam_strat", "0");

	if ( getcvar( "scr_strat_time" ) == "" )
		setcvar("scr_strat_time", "0");
	makeCvarServerInfo("scr_strat_time", "0");

	if ( getcvar( "rpam_strat_time" ) == "" )
		setcvar("rpam_strat_time", "off");
	makeCvarServerInfo("rpam_strat_time", "off");

	if(getcvar("rpam_branding") == "")
		setcvar("rpam_branding", "1"); 			// branding off/on
	makeCvarServerInfo("rpam_branding", "0");

	if ( getcvar( "rpam_uo_beta" ) == "" || getcvar( "rpam_uo_beta" ) == "0" )
		setcvar("rpam_uo_beta", "0");

	if(getCvar("sv_fog") == "")
		setCvar("sv_fog", "0");
	
	/*
	if(getCvar("rpam_sd_round_report") == "") {
		setCvar("rpam_sd_round_report", "1");
	}
	logprint("rpam_sd_round_report=1\n");
	makeCvarServerInfo("rpam_sd_round_report", "1");
	*/
	
	if (getCvar("scr_sd_readyup_nadetraining") == "")
		setCvar("scr_sd_readyup_nadetraining", 1);

	if ( getcvar( "reissuePAM" ) == "" || getcvar( "reissuePAM" ) == "0" )
		setcvar("reissuePAM", "0");

	/* Set up Level variables */
	/* Level Settings */
	level.timelimit = getCvarFloat("scr_sd_timelimit");
	level.roundlength = getCvarFloat("scr_sd_roundlength");
	level.graceperiod = getCvarFloat("scr_sd_graceperiod");
	level.killcam = getCvarInt("scr_killcam");
	level.teambalance = getCvarInt("scr_teambalance");
	level.allowfreelook = getCvarInt("scr_freelook");
	level.allowenemyspectate = getCvarInt("scr_spectateenemy");
	level.drawfriend = getCvarInt("scr_drawfriend");
	level.ffire = getCvarInt("scr_friendlyfire");
	level.pure = getCvarInt("sv_pure");
	level.vote = getCvarInt("g_allowVote");

	/* CoD UO Levels */
	level.sshock = getcvarint("scr_shellshock");
	level.drophealth = getcvarint("scr_drophealth");


	// Weapon Specific Settings
	level.faust = getcvarint("scr_allow_panzerfaust");
	level.fg42gun = getcvarint("scr_allow_fg42");
	level.mg30gun = getcvarint("scr_allow_mg30cal");
	level.dp28gun = getcvarint("scr_allow_dp28");
	level.bazookagun = getcvarint("scr_allow_bazooka"); 
	level.flamegun = getcvarint("scr_allow_flamethrower"); // TO DO
	level.nodropsniper = getcvar("sv_noDropSniper");
	level.axissnipelimit = getcvarint("sv_axisSniperLimit");
	level.allysnipelimit = getcvarint("sv_alliedSniperLimit");

	// Mod Specific Settings
	level.league = getcvar("pam_mode");
	level.playersleft = getcvarint("sv_playersleft");
	level.halfround = getcvarint("scr_half_round");
	level.halfscore = getcvarint("scr_half_score");
	level.matchround = getcvarint("scr_end_round");
	level.matchscore1 = getcvarint("scr_end_score");
	level.matchscore2 = getcvarint("scr_end_half2score");
	level.countdraws = getcvarint("scr_count_draws");
	level.planttime = getcvarFloat("sv_BombPlantTime");
	level.defusetime = getcvarFloat("sv_BombDefuseTime");
	level.countdowntime = getcvarFloat("sv_BombTimer");
	level.fog = getCvarInt("sv_fog");
	level.overtime = 0;	//Makes sure OT settings get loaded after defaults loaded
	level.ot_count = getcvarint("g_ot_count");
	level.hithalftime = 0;
	level.specmode = "";

	// rPAM Specific Settings
	level.z_rpam_countdownclock = getCvarint("rpam_countdownclock");
	level.z_rpam_riflesonly = getCvarint("rpam_riflesonly");
	level.z_rpam_sv_fps = getCvarFloat("sv_fps");
	level.z_rpam_checkclientcvars = getCvarint("rpam_checkclientcvars");
	level.z_sv_ambientsounds = getCvarint("sv_ambientsounds");
	level.z_rpam_demorecordinfo = getCvarint("rpam_demorecordinfo");
	level.z_rpam_rdyupkilling = getCvarint("rpam_rdyupkilling");
	level.z_rpam_blackout_player = getCvarint("rpam_blackout_player");
	level.z_rpam_blackout_spec = getCvarint("rpam_blackout_spec");
	level.z_rpam_sv_specblackout = getCvarint("sv_specblackout");
	level.z_rpam_rpam_streaming = getCvarint("rpam_streaming");
	level.z_rpam_strat = getCvarint("rpam_strat");
	level.z_rpam_scr_strat_time = getCvarint("scr_strat_time");
	level.z_rpam_strat_time = getCvarfloat("rpam_strat_time");
	level.z_rpam_scr_sd_graceperiod = getCvarfloat("scr_sd_graceperiod");
	level.z_rpam_playersleft = getCvarint("rpam_playersleft");
	level.z_rpam_branding = getCvarint("rpam_branding");
	level.z_rpam_player_specmode = "";
	level.z_rpam_spec_specmode = "";
	level.z_rpam_nade_training_shell = false;
	level.rpam_nade_training_dmg_info = 0;
	//level.rpam_sd_round_report = getCvarInt("rpam_sd_round_report");
	level.rpam_sd_round_report = 1;
	level.scr_sd_readyup_nadetraining = getCvarInt("scr_sd_readyup_nadetraining");
	level.rPAMstrat = false;
	level.instrattime = false;
	level.rPAMstrat = false;
	level.teamwarmupdmg = getcvar( "sv_teamwarmupdmg" );
	level.bashdamageonly = false;

	//Additions from vPAM
	level._p_color = game["p_color"];
	level._prefix = "rPAM UO " + game["p_color"] + "~ ^7";
	level._jumper = false;
	level._anti_aimrun = getCvarInt("p_anti_aimrun");
	level._anti_fastshoot = getCvarInt("p_anti_fastshoot");
	level._anti_speeding = getCvarFloat("p_anti_speeding");
	level._afk_to_spec = false;
	level._fence = false;
	level._sprint = false;
	level._sprint_time = 0;
	level._sprint_time_recover = 0;
	level._jumper = false;
	level._allow_drop_sniper = getCvarInt("p_allow_drop_sniper");
	level._allow_drop = getCvarInt("p_allow_drop");
	level._allow_pistol = getCvarInt("p_allow_pistol");
	level._allow_nades = getCvarInt("p_allow_nades");

	// Ready-Up
	level.rdyup = 0;
	level.R_U_Name = [];
	level.R_U_State = [];


	if(!isdefined(game["halftimeflag"]))
	{
		game["dolive"] = "0";
		game["halftimeflag"] = "0";
		game["round1alliesscore"] = 0;
		game["round1axisscore"] = 0; 
		game["round2alliesscore"] = 0;
		game["round2axisscore"] = 0;
		game["DoReadyUp"] = false;
		game["checkingmatchstart"] = false;
	}

	if(!isDefined(game["state"]))
		game["state"] = "playing";
	if(!isDefined(game["roundsplayed"]))
		game["roundsplayed"] = 0;
	if(!isDefined(game["matchstarted"])) {
		game["matchstarted"] = false;
		level.matchstarted = false;
	}

	// WEAPON EXPLOIT FIX
	if(!isDefined(game["dropsecondweap"]))
		game["dropsecondweap"] = false;

	if(!isDefined(game["alliedscore"]))
		game["alliedscore"] = 0;
	setTeamScore("allies", game["alliedscore"]);

	if(!isDefined(game["axisscore"]))
		game["axisscore"] = 0;
	setTeamScore("axis", game["axisscore"]);

	// turn off ceasefire
	level.ceasefire = 0;
	setCvar("scr_ceasefire", "0");

	level.readyname = [];
	level.readystate = [];
	level.playersready = false;

	level.bombplanted = false;
	level.bombexploded = false;
	level.roundstarted = false;
	level.roundended = false;
	level.mapended = false;
	
	if (!isdefined (game["BalanceTeamsNextRound"]))
		game["BalanceTeamsNextRound"] = false;
	
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;
	level.exist["teams"] = false;
	level.didexist["allies"] = false;
	level.didexist["axis"] = false;

	level.healthqueue = [];
	level.healthqueuecurrent = 0;

	if(game["mode"] != "match" && getCvar("sv_messagecenter") == "1")
		thread _rPAM_rules\_pam_messagecenter::messages();


        if(level.killcam >= 1)
                setarchive(true);

        // AWE map vote configuration
        level.awe_mapvote = getCvarInt("awe_map_vote");
        level.awe_mapvotetime = getCvarInt("awe_map_vote_time");
        level.awe_mapvotereplay = getCvarInt("awe_map_vote_replay");
        level.awe_spawnspectatorname = "mp_searchanddestroy_intermission";
        level.mapvotetext = [];
        level.mapvotetext["MapVote"]      = &"Press ^2FIRE^7 to vote   Votes";
        level.mapvotetext["TimeLeft"]     = &"Time Left: ";
        level.mapvotetext["MapVoteHeader"] = &"Next Map Vote";
        level.awe_mapvotehudoffset = 30;       // not UO
	
}

rRIFLEHITBLIP()
{
	if(isdefined(self.hitblip))
		self.hitblip destroy();

	self.hitblip = newClientHudElem(self);
	self.hitblip.alignX = "center";
	self.hitblip.alignY = "middle";
	self.hitblip.x = 320;
	self.hitblip.y = 240;
	self.hitblip.alpha = 0.5;
	self.hitblip setShader("gfx/hud/hud@fire_ready.tga", 32, 32);
	self.hitblip scaleOverTime(0.15, 64, 64);

	wait 0.15;

	if(isdefined(self.hitblip))
		self.hitblip destroy();
}

rSPAWNWITHCVARS()
{
	/*rSPAWNCLIENTWITHCVARS = getcvar("rpam_checkclientcvars");
	if (rpam_checkclientcvars == "1")
	{
		thread _rPAM_rules\_rPAM_clientcvars::rPAMclientcvars();	
	}*/

//	rSPAWNWITH_snaps = getcvarint("sv_fps");
//		self setClientCvar("snaps", rSPAWNWITH_snaps);
	if (getCvar("sv_fog") == "0")
		self setClientCvar("r_fog", "0");
	self setClientCvar("cg_hudstancehintprints", "0");
	self setClientCvar("cg_weaponCycleDelay", "0");
	self setClientCvar("cg_shadows", "0");
	self setClientCvar("introscreen", "0");
}

rDEMORECORDINFOtime()
{
	setcvar("g_roundwarmuptime", "10");
}

rDEMORECORDINFO()
{
	iprintln("^3Recording Demo is mandatory!");
	iprintln("^3Start recording with /record");
	iprintln("^3and name your demo accordingly.");
		wait 5;

	iprintln("^1Recording Demo is mandatory!");
	iprintln("^1Start recording with /record");
	iprintln("^1and name your demo accordingly.");
		wait 1;

	setcvar("g_roundwarmuptime", "5");
}

rFASHSHOOTmessage()
{
// Script by Megazor; info provided by Anglhz & Walrus
// This script is just for rifles only!
// Updated to better verision together with aimglitch script 2021. rPAM_rules\rpam_antiglitch.gsc

	while(self.sessionstate == "playing")
	{

//Get the clipammo
		oldA = self getWeaponSlotClipAmmo("primary");
		oldB = self getWeaponSlotClipAmmo("primaryb");

//Put it in variable to compare later
		newA = oldA;
		newB = oldB;

//While he's playing and while bullets didn't change
		while(self.sessionstate == "playing" && oldA == newA && oldB == newB)
		{
			newA = self getWeaponSlotClipAmmo("primary");
			newB = self getWeaponSlotClipAmmo("primaryb");
			wait .05;
		}

//Probably reloaded
		if(oldA < newA || oldB < newB)
			continue;

		if(oldA != newA)	a = 1;
		else			a = 0;

		if(a) old = self getWeaponSlotClipAmmo("primary");
		else  old = self getWeaponSlotClipAmmo("primaryb");

		for(i = 0;i < 24;i++)
		{
			if(self.sessionstate != "playing")
				return;
			wait .05;
		}

		if(a) new = self getWeaponSlotClipAmmo("primary");
		else  new = self getWeaponSlotClipAmmo("primaryb");

		if(self.sessionstate == "playing" && old > new)
		{
			if(!isDefined(self.rFASHSHOOTmessage))
			{
				self.rFASHSHOOTmessage = 0;
			}

			self.rFASHSHOOTmessage++;
			self iprintln("^1~^3empire ^2| ^1automod: ^3" + self.name + " ^1used fastshooting!^3 (" + self.rFASHSHOOTmessage + ")");
		}
	}
}

rSTRATEXPLOIT()
{
	rSTRATendwarmup = getCvarint("g_roundwarmuptime");
	if (rSTRATendwarmup == 5)
	{
		wait 3.5;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			setCvar("g_speed", "0");
			player.maxspeed = 0;
		}
	}
	else if (rSTRATendwarmup != 5)
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			setCvar("g_speed", "0");
			player.maxspeed = 0;
		}
	}
}

rBLACKOUTspec( whyB )
{
// With some info by Walrus -thy

	if ( self.pers["team"] != "spectator" || level.warmup == 1 )
	{
		return;
	}

	while (self.pers["team"] == "spectator" || level.mapended != "true" )
	{
		level endon( "intermission" );

		self notify( "end_rBLACKOUTspec" );
		self endon( "end_rBLACKOUTspec" );
		self endon( "spawned" );

		if ( !isdefined( self.rpam_BLACKOUTspec ) )
		{
			self.rpam_BLACKOUTspec = newClientHudElem( self );
			self.rpam_BLACKOUTspec.archived = false;
			self.rpam_BLACKOUTspec.x = 0;
			self.rpam_BLACKOUTspec.y = 0;
			self.rpam_BLACKOUTspec.alpha = 1;
			self.rpam_BLACKOUTspec setShader( "black", 640, 480 );
		}

		if ( !isdefined( self.rpam_BLACKOUTspec_title ) )
		{
			self.rpam_BLACKOUTspec_title = newClientHudElem( self );
			self.rpam_BLACKOUTspec_title.archived = false;
			self.rpam_BLACKOUTspec_title.x = 320;
			self.rpam_BLACKOUTspec_title.y = 390; //200;
			self.rpam_BLACKOUTspec_title.alignX = "center";
			self.rpam_BLACKOUTspec_title.alignY = "middle";
			self.rpam_BLACKOUTspec_title.fontScale = 1.2;
			self.rpam_BLACKOUTspec_title.color = (0, 0.749, 1);
			self.rpam_BLACKOUTspec_title setText(game["rpam_blackout_spec"]);
		}

		if ( whyB != "death" )
		{
			self thread rBLACKOUTremove();
			self thread rBLACKOUTmsg( "spawned" );
		}

		for (;;)
		{
			self.spectatorclient = self getEntityNumber();
			wait( 0.05 );	// Stay put until next round
		}
	}
}

rBLACKOUTmsg( whyR )
{
		self endon( "end_rBLACKOUTspec" );
		self endon( "remove_rBLACKOUTspec" );

		self waittill( whyR );
		self notify( "remove_rBLACKOUTspec" );
		return;
}

rBLACKOUTremove()
{
		self endon( "end_rBLACKOUTspec" );

		self waittill( "remove_rBLACKOUTspec" );
		if ( isdefined( self.rpam_BLACKOUTspec ) )
			self.rpam_BLACKOUTspec destroy();
		if ( isdefined( self.rpam_BLACKOUTspec_title ) )
			self.rpam_BLACKOUTspec_title destroy();
		return;
}

rPAMstrat()
{
	level.rPAMstrat = true;

	level.rPAMstrattime = newHudElem();
	level.rPAMstrattime.x = 320;
	level.rPAMstrattime.y = 390; //440;
	level.rPAMstrattime.alignX = "center";
	level.rPAMstrattime.alignY = "middle";
	level.rPAMstrattime.fontScale = 1.4;
	level.rPAMstrattime.color = (0, 0.749, 1);
	level.rPAMstrattime setText(game["strattime"]);

	wait level.graceperiod;

	if(isdefined(level.rPAMstrattime))
		level.rPAMstrattime destroy();

	level.rPAMstrat = false;

	thread maps\mp\gametypes\_pam_teams::sayMoveIn();

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{ 
		player = players[i];
		player.maxspeed = getCvar("g_speed");
	}
}

rSTARTINGHALF(startinghalf)
{
	level.allready = newHudElem();
	level.allready.x = 320;
	level.allready.y = 390;
	level.allready.alignX = "center";
	level.allready.alignY = "middle";
	level.allready.fontScale = 1.35;
	level.allready.color = (0, 0.749, 1);
	level.allready setText(game["allready"]);

	if (startinghalf == "1")
	{
		level.halfstart = newHudElem();
		level.halfstart.x = 320;
		level.halfstart.y = 370;
		level.halfstart.alignX = "center";
		level.halfstart.alignY = "middle";
		level.halfstart.fontScale = 1.35;
		level.halfstart.color = (0, 0.749, 1);
		level.halfstart setText(game["start1sthalf"]);
	}
	else
	{
		level.halfstart = newHudElem();
		level.halfstart.x = 320;
		level.halfstart.y = 370;
		level.halfstart.alignX = "center";
		level.halfstart.alignY = "middle";
		level.halfstart.fontScale = 1.35;
		level.halfstart.color = (0, 0.749, 1);
		level.halfstart setText(game["start2ndhalf"]);
	}
}

rSTOPWATCHstart(time)
{
	if(isDefined(level.rSTOPWATCH))
		level.rSTOPWATCH destroy();
		
	level.rSTOPWATCH = newHudElem();
	level.rSTOPWATCH.archived = false;
	level.rSTOPWATCH.x = 590; // 590;
	level.rSTOPWATCH.y = 315; // 380;
	level.rSTOPWATCH.alignX = "center";
	level.rSTOPWATCH.alignY = "middle";
	level.rSTOPWATCH.sort = 9999;
	level.rSTOPWATCH setClock(time, 60, "hudStopwatch", 64, 64); // count down for 5 of 60 seconds, size is 64x64

	wait (time);

	if(isDefined(level.rSTOPWATCH)) 
		level.rSTOPWATCH destroy();
}

Callback_StartGameType()
{
	// if this is a fresh map start, set nationalities based on cvars, otherwise leave game variable nationalities as set in the level script
	if(!isDefined(game["gamestarted"]))
	{
		// defaults if not defined in level script
		if(!isDefined(game["allies"]))
			game["allies"] = "american";
		if(!isDefined(game["axis"]))
			game["axis"] = "german";

		if(!isDefined(game["layoutimage"]))
			game["layoutimage"] = "default";
		layoutname = "levelshots/layouts/hud@layout_" + game["layoutimage"];
		precacheShader(layoutname);
		setCvar("scr_layoutimage", layoutname);
		makeCvarServerInfo("scr_layoutimage", "");

		// server cvar overrides
		if(getCvar("scr_allies") != "")
			game["allies"] = getCvar("scr_allies");	
		if(getCvar("scr_axis") != "")
			game["axis"] = getCvar("scr_axis");

		game["menu_serverinfo"] = "serverinfo_" + getCvar("g_gametype");
		game["menu_team"] = "team_" + game["allies"] + game["axis"];
		game["menu_weapon_allies"] = "weapon_" + game["allies"];
		game["menu_weapon_axis"] = "weapon_" + game["axis"];
		game["menu_viewmap"] = "viewmap";
		game["menu_callvote"] = "callvote";
		game["menu_quickcommands"] = "quickcommands";
		game["menu_quickstatements"] = "quickstatements";
		game["menu_quickresponses"] = "quickresponses";
		game["menu_quickvehicles"] = "quickvehicles";
		game["menu_quickrequests"] = "quickrequests";

		/* PAM precacheStrings */
		// HUD Header Elements
		game["pamstring"] = &"^1~^3empire";
		precacheString(game["pamstring"]);
		game["rpam_uo_beta"] = &"BETA";
		precacheString(game["rpam_uo_beta"]);

		// Logo
		if (!isdefined(game["leaguestring"]))
			game["leaguestring"] = &"Unknown Pam_Mode Error";
		precacheString(game["leaguestring"]);
		game["overtimemode"] = &"Overtime";
		precacheString(game["overtimemode"]);

		// Brand Logo Display
		if (!isdefined(game["rpam_branding"]))
			game["rpam_branding"] = &"^1~^3empire";
		precacheString(game["rpam_branding"]);

		// Team Win Hud Elements
		game["team1win"] = &"Team 1 Wins!";
		precacheString(game["team1win"]);
		game["team2win"] = &"Team 2 Wins!";
		precacheString(game["team2win"]);
		game["dsptie"] = &"It's a TIE!";
		precacheString(game["dsptie"]);
		game["matchover"] = &"Match Over";
		precacheString(game["matchover"]);
		game["overtime"] = &"Going to OverTime";
		precacheString(game["overtime"]);

		game["halftime"] = &"Halftime";
		precacheString(game["halftime"]);

		//Round Starting Display
		game["round"] = &"Round";
		precacheString(game["round"]);
		game["starting"] = &"Starting";
		precacheString(game["starting"]);

		//Bomb Plant Announcement
		game["planted"] = &"Explosives Planted";
		precacheString(game["planted"]);

		// Time Expired Announcement
		game["timeexp"] = &"Time Expired";
		precacheString(game["timeexp"]);

		// Strat Time Announcement
		game["strattime"] = &"Strat Time";
		precacheString(game["strattime"]);

		//Teams Swithcing Announcement
		game["switching"] = &"Team Auto-Switch";
		precacheString(game["switching"]);	
		game["switching2"] = &"Please wait";
		precacheString(game["switching2"]);

		game["startingin"] = &"Starting In";
		precacheString(game["startingin"]);		
		game["matchstarting"] = &"Match Starting In";
		precacheString(game["matchstarting"]);	
		game["matchresuming"] = &"Match Resuming In";
		precacheString(game["matchresuming"]);	
		game["allready"] = &"All Players are Ready";
		precacheString(game["allready"]);
		game["start2ndhalf"] = &"Starting Second Half!";
		precacheString(game["start2ndhalf"]);
		game["start1sthalf"] = &"Starting the First Half!";
		precacheString(game["start1sthalf"]);
		game["livemsg"] = &"LIVE!";
		precacheString(game["livemsg"]);

		//Half Starting Display
		game["first"] = &"First";
		precacheString(game["first"]);
		game["second"] = &"Second";
		precacheString(game["second"]);
		game["half"] = &"Half";
		precacheString(game["half"]);
		game["starting"] = &"Starting";
		precacheString(game["starting"]);

		// Ready-Up Plugin Requires:
		game["waiting"] = &"Ready-Up Mode";
		precacheString(game["waiting"]);
		game["waitingon"] = &"Waiting on";
		precacheString(game["waitingon"]);
		game["playerstext"] = &"Players";
		precacheString(game["playerstext"]);
		game["status"] = &"Your Status";
		precacheString(game["status"]);
		game["ready"] = &"Ready";
		precacheString(game["ready"]);
		game["notready"] = &"Not Ready";
		precacheString(game["notready"]);
		//		game["headicon_carrier"] = "gfx/hud/headicon@re_objcarrier.tga";
		//		precacheStatusIcon(game["headicon_carrier"]);

		game["dspaxisleft"] = &"AXIS LEFT:";
		precacheString(game["dspaxisleft"]);		
		game["dspalliesleft"] = &"ALLIES LEFT:";
		precacheString(game["dspalliesleft"]);

		game["bashrnd"] = &"Starting Bash Round";
		precacheString(game["bashrnd"]);
		game["bashbegin"] = &"BEGIN!";
		precacheString(game["bashbegin"]);

		// Players Left Display		
		game["dspaxisleft"] = &"AXIS LEFT:";
		precacheString(game["dspaxisleft"]);		
		game["dspalliesleft"] = &"ALLIES LEFT:";
		precacheString(game["dspalliesleft"]);

		game["round"] = &"Round";
		precacheString(game["round"]);		
		game["startingin"] = &"Starting In";
		precacheString(game["startingin"]);		
		game["matchstarting"] = &"Match Starting In";
		precacheString(game["matchstarting"]);

		game["matchresuming"] = &"Match Resuming In";
		precacheString(game["matchresuming"]);

		// Scoreboard Text
		game["dspteam1"] = &"TEAM 1";
		precacheString(game["dspteam1"]);
		game["dspteam2"] = &"TEAM 2";
		precacheString(game["dspteam2"]);
		game["scorebd"] = &"Match Status";
		precacheString(game["scorebd"]);
		game["dspaxisscore"] = &"AXIS SCORE";
		precacheString(game["dspaxisscore"]);		
		game["dspalliesscore"] = &"ALLIES SCORE";
		precacheString(game["dspalliesscore"]);
		game["1sthalf"] = &"1st Half";
		precacheString(game["1sthalf"]);	
		game["2ndhalf"] = &"2nd Half";
		precacheString(game["2ndhalf"]);
		game["matchscore2"] = &"Match";
		precacheString(game["matchscore2"]);

		//rPAM Spec Blackout
		game["rpam_blackout_spec"] = &"Spectating as SPECTATOR is disabled, please join a TEAM.";
		precacheString(game["rpam_blackout_spec"]);
		game["rpam_blackout_player"] = &"Spectating as PLAYER is disabled during the round.";
		precacheString(game["rpam_blackout_player"]);
		game["rpam_planted"] = &"Explosives Planted";
		precacheString(game["rpam_planted"]);

		// Nade Training Warning
		if (!isdefined(game["stratstring"]))
		game["stratstring"] = &"^7WARNING^3: ^7CHEATS ENABLED^3!";
		precacheString(game["stratstring"]);
		game["stratwarning"] = &"^7STRAT MODE ENABLED^3!";
		precacheString(game["stratwarning"]);
		game["nadetraining"] = &"^7Nade Training^3.";
		precacheString(game["nadetraining"]);
		game["anglhz"] = &"^7BY   ANGLHZ^3.";
		precacheString(game["anglhz"]);
		game["enablefollow"] = &"^7Following^3: ^7Hold ^3[{+melee}] ^7Key";
		precacheString(game["enablefollow"]);
		game["stopfollow"] = &"^7Stop Following^3: ^7Press ^3[{+attack}] ^7Key";
		precacheString(game["stopfollow"]);
		game["position"] = &"Position^3.";
		precacheString(game["position"]);
		game["positionsave"] = &"^7Save^3: ^7Press ^3[{+melee}] ^7Twice";
		precacheString(game["positionsave"]);
		game["positionload"] = &"^7Load^3: ^7Press ^3[{+activate}] ^7Twice";
		precacheString(game["positionload"]);
		game["strattimer"] = &"Timer^3.";
		precacheString(game["strattimer"]);
		game["strattimerdir"] = &"^7Start^3: ^7Hold ^3[{+activate}] ^7Key";
		precacheString(game["strattimerdir"]);
		precacheString(&"Press [{+melee}] to respawn");

		// Streaming Mode
		game["streaming_status"] = &"^3Match Status:";
		precacheString(game["streaming_status"]);

		game["streaming_team1"] = &"ALLIES";
		precacheString(game["streaming_team1"]);
		game["score_board_team1"] = &"Rounds:";
		precacheString(game["score_board_team1"]);
		game["pleft_team1"] = &"Players Left:";
		precacheString(game["pleft_team1"]);

		game["streaming_team2"] = &"AXIS";
		precacheString(game["streaming_team2"]);
		game["score_board_team2"] = &"Rounds:";
		precacheString(game["score_board_team2"]);
		game["pleft_team2"] = &"Players Left:";
		precacheString(game["pleft_team2"]);

		// Random Team Announcements
		game["forOT"] = &"For OT";
		precacheString(game["forOT"]);
		game["sameteams"]=&"Same Sides";
		precacheString(game["sameteams"]);
		game["swapteams"]=&"Swap Sides";
		precacheString(game["swapteams"]);

		// Sudden Death
		game["suddendeath"]=&"Sudden Death Active";
		precacheString(game["suddendeath"]);

		// OLD Scoreboard
		/*
		game["1sthalfscore"] = &"1st Half Scores:";
		precacheString(game["1sthalfscore"]);	
		game["2ndhalfscore"] = &"2nd Half Scores:";
		precacheString(game["2ndhalfscore"]);	
		game["matchscore"] = &"Match Scores:";
		precacheString(game["matchscore"]);	
		*/

		//Clock
		precacheShader("hudStopwatch");
		precacheShader("hudStopwatchNeedle");
		/* end PAM precacheStrings */

		precacheString(&"MPSCRIPT_PRESS_ACTIVATE_TO_SKIP");
		precacheString(&"MPSCRIPT_KILLCAM");
		precacheString(&"SD_MATCHSTARTING");
		precacheString(&"SD_MATCHRESUMING");
		precacheString(&"SD_EXPLOSIVESPLANTED");
		precacheString(&"SD_EXPLOSIVESDEFUSED");
		precacheString(&"SD_ROUNDDRAW");
		precacheString(&"SD_TIMEHASEXPIRED");
		precacheString(&"SD_ALLIEDMISSIONACCOMPLISHED");
		precacheString(&"SD_AXISMISSIONACCOMPLISHED");
		precacheString(&"SD_ALLIESHAVEBEENELIMINATED");
		precacheString(&"SD_AXISHAVEBEENELIMINATED");
		precacheString(&"GMI_MP_CEASEFIRE");

		precacheMenu(game["menu_serverinfo"]);
		precacheMenu(game["menu_team"]);
		precacheMenu(game["menu_weapon_allies"]);
		precacheMenu(game["menu_weapon_axis"]);
		precacheMenu(game["menu_viewmap"]);
		precacheMenu(game["menu_callvote"]);
		precacheMenu(game["menu_quickcommands"]);
		precacheMenu(game["menu_quickstatements"]);
		precacheMenu(game["menu_quickresponses"]);
		precacheMenu(game["menu_quickvehicles"]);
		precacheMenu(game["menu_quickrequests"]);

		precacheShader("black");
		precacheShader("white");
		precacheShader("hudScoreboard_mp");
		precacheShader("gfx/hud/hud@mpflag_spectator.tga");
		precacheStatusIcon("gfx/hud/hud@status_dead.tga");
		precacheStatusIcon("gfx/hud/hud@status_connecting.tga");

		precacheShader("ui_mp/assets/hud@plantbomb.tga");
		precacheShader("ui_mp/assets/hud@defusebomb.tga");
		precacheShader("gfx/hud/hud@objectiveA.tga");
		precacheShader("gfx/hud/hud@objectiveA_up.tga");
		precacheShader("gfx/hud/hud@objectiveA_down.tga");
		precacheShader("gfx/hud/hud@objectiveB.tga");
		precacheShader("gfx/hud/hud@objectiveB_up.tga");
		precacheShader("gfx/hud/hud@objectiveB_down.tga");
		precacheShader("gfx/hud/hud@bombplanted.tga");
		precacheShader("gfx/hud/hud@bombplanted_up.tga");
		precacheShader("gfx/hud/hud@bombplanted_down.tga");
		precacheShader("gfx/hud/hud@bombplanted_down.tga");
		precacheShader("gfx/hud/hud@fire_ready.tga");

		precacheModel("xmodel/mp_bomb1_defuse");
		precacheModel("xmodel/mp_bomb1");

		precacheItem("item_health");
		
		maps\mp\gametypes\_pam_teams::precache();
		maps\mp\gametypes\_pam_teams::scoreboard();

		thread addBotClients();
	}
	
	maps\mp\gametypes\_pam_teams::modeltype();
	maps\mp\gametypes\_pam_teams::initGlobalCvars();
	maps\mp\gametypes\_pam_teams::initWeaponCvars();
	maps\mp\gametypes\_pam_teams::restrictPlacedWeapons();
	thread maps\mp\gametypes\_pam_teams::updateGlobalCvars();
	thread maps\mp\gametypes\_pam_teams::updateWeaponCvars();

	game["gamestarted"] = true;

	setClientNameMode("manual_change");

	thread bombzones();
	thread startGame();
	thread updateGametypeCvars();
	thread addBotClients();
}

Callback_PlayerConnect()
{
	self.statusicon = "gfx/hud/hud@status_connecting.tga";
	self waittill("begin");
	self.statusicon = "";
	self.pers["teamTime"] = 1000000;

	self.pers["killer"] = false; // Used for Ready-up Killing
	self.bombinteraction = false;

	if(!isDefined(self.pers["team"]))
		iprintln(&"MPSCRIPT_CONNECTED", self);
	
	logprint(self.name + " connected\n");

	if (!isDefined(self.pers["tk_count"]))
		self.pers["tk_count"] = 0;

	lpselfnum = self getEntityNumber();

	level.R_U_Name[lpselfnum] = self.name;
	level.R_U_State[lpselfnum] = "notready";
	self.R_U_Looping = 0;
	
	self thread maps\mp\gametypes\_pam_round_report::onConnected();

	if(level.rdyup == 1)
	{
		self.statusicon = game["br_hudicons_allies_0"];
		self thread maps\mp\gametypes\_pam_readyup::readyup(lpselfnum);
	}

	self thread _rPAM_rules\monitor\weapon::monitoring();

	lpselfguid = self getGuid();
	logPrint("J;" + lpselfguid + ";" + lpselfnum + ";" + self.name + "\n");

	// set the cvar for the map quick bind
	self setClientCvar("g_scriptQuickMap", game["menu_viewmap"]);
	
	// make sure that the rank variable is initialized
	if ( !isDefined( self.pers["rank"] ) )
		self.pers["rank"] = 0;

	if(game["state"] == "intermission")
	{
		spawnIntermission();
		return;
	}
	
	level endon("intermission");

	// start the vsay thread
	//self thread maps\mp\gametypes\_pam_teams::vsay_monitor();
	
	if(isDefined(self.pers["team"]) && self.pers["team"] != "spectator")
	{
		self setClientCvar("ui_weapontab", "1");

		maps\mp\gametypes\_pam_weaponlimits::CheckLimits();
		if(self.pers["team"] == "allies")
		{
			self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
		}
		else
		{
			self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
		}

		if(isDefined(self.pers["weapon"]))
			spawnPlayer();
		else
		{
			self.sessionteam = "spectator";

			spawnSpectator();

			maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

			if(self.pers["team"] == "allies")
				self openMenu(game["menu_weapon_allies"]);
			else
				self openMenu(game["menu_weapon_axis"]);
		}
	}
	else
	{
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);
		self setClientCvar("ui_weapontab", "0");

		if(!isDefined(self.pers["skipserverinfo"]))
			self openMenu(game["menu_serverinfo"]);

		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";

		spawnSpectator();
	}

	if (getcvar("scr_allow_weapon_drops") == "1")
		self thread Monitor_Weapon_Drop();

	if (level.instrattime)
		self.maxspeed = 0;

	if (level.rPAMstrat)
	{
		self.maxspeed = 0;
	}

        for(;;)
        {
                self waittill("menuresponse", menu, response);
                maps\mp\gametypes\_awe::NotAFK();

		if(menu == game["menu_serverinfo"] && response == "close")
		{
			self.pers["skipserverinfo"] = true;
			self openMenu(game["menu_team"]);
		}	


		if(response == "open" || response == "close")
			continue;

		if(menu == game["menu_team"])
		{
			switch(response)
			{
			case "allies":
			case "axis":
			case "autoassign":
				if (level.lockteams || level.instrattime)
					break;
				if (game["switchprevent"] && self.sessionteam != "spectator")
					break;

				if(response == "autoassign")
				{
					numonteam["allies"] = 0;
					numonteam["axis"] = 0;

					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						player = players[i];
					
						if(!isDefined(player.pers["team"]) || player.pers["team"] == "spectator" || player == self)
							continue;
			
						numonteam[player.pers["team"]]++;
					}
					
					// if teams are equal return the team with the lowest score
					if(numonteam["allies"] == numonteam["axis"])
					{
						if(getTeamScore("allies") == getTeamScore("axis"))
						{
							teams[0] = "allies";
							teams[1] = "axis";
							response = teams[randomInt(2)];
						}
						else if(getTeamScore("allies") < getTeamScore("axis"))
							response = "allies";
						else
							response = "axis";
					}
					else if(numonteam["allies"] < numonteam["axis"])
						response = "allies";
					else
						response = "axis";
					skipbalancecheck = true;
				}
				
				if(response == self.pers["team"] && self.sessionstate == "playing")
					break;

				//Check if the teams will become unbalanced when the player goes to this team...
				//------------------------------------------------------------------------------
				if ( (level.teambalance > 0) && (!isdefined (skipbalancecheck)) )
				{
					//Get a count of all players on Axis and Allies
					players = maps\mp\gametypes\_pam_teams::CountPlayers();
					
					if (self.sessionteam != "spectator")
					{
						if (((players[response] + 1) - (players[self.pers["team"]] - 1)) > level.teambalance)
						{
							if (response == "allies")
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_RUSSIAN");
							}
							else
								self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_GERMAN");
							break;
						}
					}
					else
					{
						if (response == "allies")
							otherteam = "axis";
						else
							otherteam = "allies";
						if (((players[response] + 1) - players[otherteam]) > level.teambalance)
						{
							if (response == "allies")
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_RUSSIAN");
							}
							else
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_RUSSIAN");
							}
							break;
						}
					}
				}
				skipbalancecheck = undefined;
				//------------------------------------------------------------------------------
				
				if(response != self.pers["team"] && self.sessionstate == "playing")
					self suicide();
	                        
				self.pers["team"] = response;
				self.pers["teamTime"] = (gettime() / 1000);
				self.pers["weapon"] = undefined;
				self.pers["weapon1"] = undefined;
				self.pers["weapon2"] = undefined;
				self.pers["spawnweapon"] = undefined;
				self.pers["savedmodel"] = undefined;
				self.grenadecount = undefined;

				// update spectator permissions immediately on change of team
				maps\mp\gametypes\_pam_teams::SetSpectatePermissions();

				self setClientCvar("ui_weapontab", "1");

				if(self.pers["team"] == "allies")
				{
					self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
					self openMenu(game["menu_weapon_allies"]);
				}
				else
				{
					self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
					self openMenu(game["menu_weapon_axis"]);
				}
				break;

			case "spectator":
				if (level.lockteams || level.instrattime)
					break;
				if(self.pers["team"] != "spectator")
				{
					if(isAlive(self))
						self suicide();

					self.pers["team"] = "spectator";
					self.pers["teamTime"] = 1000000;
					self.pers["weapon"] = undefined;
					self.pers["weapon1"] = undefined;
					self.pers["weapon2"] = undefined;
					self.pers["spawnweapon"] = undefined;
					self.pers["savedmodel"] = undefined;
					self.grenadecount = undefined;

					self.sessionteam = "spectator";
					self setClientCvar("g_scriptMainMenu", game["menu_team"]);
					self setClientCvar("ui_weapontab", "0");
					spawnSpectator();
				}
				break;

			case "weapon":
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;

			case "viewmap":
				self openMenu(game["menu_viewmap"]);
				break;
			
			case "callvote":
				self openMenu(game["menu_callvote"]);
				break;
			}
		}		
		else if(menu == game["menu_weapon_allies"] || menu == game["menu_weapon_axis"])
		{
			if(response == "team")
			{
				self openMenu(game["menu_team"]);
				continue;
			}
			else if(response == "viewmap")
			{
				self openMenu(game["menu_viewmap"]);
				continue;
			}
			else if(response == "callvote")
			{
				self openMenu(game["menu_callvote"]);
				continue;
			}
			
			if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
				continue;

			weapon = self maps\mp\gametypes\_pam_teams::restrict(response);

			if(weapon == "restricted")
			{
				self openMenu(menu);
				continue;
			}
			
			self.pers["selectedweapon"] = weapon;

			if(isDefined(self.pers["weapon"]) && self.pers["weapon"] == weapon && !isDefined(self.pers["weapon1"]))
				continue;
			
			if(!game["matchstarted"])
			{
				if(isDefined(self.pers["weapon"]))
				{
			 		self.pers["weapon"] = weapon;
					self.pers["weapon1"] = weapon;

					self maps\mp\gametypes\_pam_loadout_gmi::PlayerSpawnLoadout();
					self setWeaponSlotWeapon("primary", weapon);
					self switchToWeapon(weapon);
				}
				else
				{
					self.pers["weapon"] = weapon;
					self.pers["weapon1"] = weapon;
					self.spawned = undefined;
					spawnPlayer();
					self thread printJoinedTeam(self.pers["team"]);
					level thread checkMatchStart();
				}
			}
			else if(!level.roundstarted && !self.usedweapons)
			{
			 	if(isDefined(self.pers["weapon"]))
			 	{
			 		self.pers["weapon"] = weapon;
					self.pers["weapon1"] = weapon;
					
					self maps\mp\gametypes\_pam_loadout_gmi::PlayerSpawnLoadout();
					self setWeaponSlotWeapon("primary", weapon);
					self switchToWeapon(weapon);
				}
			 	else
				{			 	
					self.pers["weapon"] = weapon;
					if(!level.exist[self.pers["team"]])
					{
						self.spawned = undefined;
						spawnPlayer();
						self thread printJoinedTeam(self.pers["team"]);
						level thread checkMatchStart();
					}
					else
					{
						spawnPlayer();
						self thread printJoinedTeam(self.pers["team"]);
					}
				}
			}
			else
			{
				if(isDefined(self.pers["weapon"]))
					self.oldweapon = self.pers["weapon"];

				self.pers["weapon"] = weapon;
				self.sessionteam = self.pers["team"];

				if(self.sessionstate != "playing")
					self.statusicon = "gfx/hud/hud@status_dead.tga";
			
				if(self.pers["team"] == "allies")
					otherteam = "axis";
				else if(self.pers["team"] == "axis")
					otherteam = "allies";
					
				// if joining a team that has no opponents, just spawn
				if(!level.didexist[otherteam] && !level.roundended)
				{
					self.spawned = undefined;
					spawnPlayer();
					self thread printJoinedTeam(self.pers["team"]);
				}				
				else if(!level.didexist[self.pers["team"]] && !level.roundended)
				{
					self.spawned = undefined;
					spawnPlayer();
					self thread printJoinedTeam(self.pers["team"]);
					level thread checkMatchStart();
				}
				else
				{
					weaponname = maps\mp\gametypes\_pam_teams::getWeaponName(self.pers["weapon"]);

					if(self.pers["team"] == "allies")
					{
						if(maps\mp\gametypes\_pam_teams::useAn(self.pers["weapon"]))
							self iprintln(&"MPSCRIPT_YOU_WILL_SPAWN_ALLIED_WITH_AN_NEXT_ROUND", weaponname);
						else
							self iprintln(&"MPSCRIPT_YOU_WILL_SPAWN_ALLIED_WITH_A_NEXT_ROUND", weaponname);
					}
					else if(self.pers["team"] == "axis")
					{
						if(maps\mp\gametypes\_pam_teams::useAn(self.pers["weapon"]))
							self iprintln(&"MPSCRIPT_YOU_WILL_SPAWN_AXIS_WITH_AN_NEXT_ROUND", weaponname);
						else
							self iprintln(&"MPSCRIPT_YOU_WILL_SPAWN_AXIS_WITH_A_NEXT_ROUND", weaponname);
					}
				}
			}

			self thread maps\mp\gametypes\_pam_teams::SetSpectatePermissions();
			if (isdefined (self.autobalance_notify))
				self.autobalance_notify destroy();

			rGOTWEAPON = getcvar("rpam_blackout_spec");
			if (rGOTWEAPON == "1")
			{
				if( self.pers["team"] == "allies" || self.pers["team"] == "axis" )
				{
					if ( isdefined( self.rpam_BLACKOUTspec ) )
						self.rpam_BLACKOUTspec destroy();
					if ( isdefined( self.rpam_BLACKOUTspec_title ) )
						self.rpam_BLACKOUTspec_title destroy();
				}
				else
				{
					return;
				}
			}
			streaming_on = getcvar("rpam_streaming");
			if (streaming_on == "1")
			{
				if( self.pers["team"] == "allies" || self.pers["team"] == "axis" )
				{
					_rPAM_rules\streaming\streaming::Streaming_Hud_Destroy();
				}
				else
				{
					return;
				}
			}
		}
		else if(menu == game["menu_viewmap"])
		{
			switch(response)
			{
			case "team":
				self openMenu(game["menu_team"]);
				break;
				
			case "weapon":
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;

			case "callvote":
				self openMenu(game["menu_callvote"]);
				break;
			}
		}
		else if(menu == game["menu_callvote"])
		{
			switch(response)
			{
			case "team":
				self openMenu(game["menu_team"]);
				break;
				
			case "weapon":
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;

			case "viewmap":
				self openMenu(game["menu_viewmap"]);
				break;
			}
		}
		else if(menu == game["menu_quickcommands"])
			maps\mp\gametypes\_pam_teams::quickcommands(response);
		else if(menu == game["menu_quickstatements"])
			maps\mp\gametypes\_pam_teams::quickstatements(response);
		else if(menu == game["menu_quickresponses"])
			maps\mp\gametypes\_pam_teams::quickresponses(response);
		else if(menu == game["menu_quickvehicles"])
			maps\mp\gametypes\_pam_teams::quickvehicles(response);
		else if(menu == game["menu_quickrequests"])
			maps\mp\gametypes\_pam_teams::quickrequests(response);
	}
}

Callback_PlayerDisconnect()
{
	iprintln(&"MPSCRIPT_DISCONNECTED", self);
	
	lpselfnum = self getEntityNumber();

	level.R_U_Name[lpselfnum] = "disconnected";
	level.R_U_State[lpselfnum] = "disconnected";
	self.R_U_Looping = 0;

	if(level.rdyup == 1)
		thread maps\mp\gametypes\_pam_readyup::Check_All_Ready();

	lpselfguid = self getGuid();
	logPrint("Q;" + lpselfguid + ";" + lpselfnum + ";" + self.name + "\n");

	if(game["matchstarted"])
		level thread updateTeamStatus();
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	if(level.rdyup)
	{
		rRDYUPKILLINGattacker = getcvar("rpam_rdyupkilling");
		if (rRDYUPKILLINGattacker == "1")
		{
			if (isPlayer(eAttacker) && self != eAttacker)
				eAttacker.pers["killer"] = true;
		
			if (!self.pers["killer"])
				return;
		}
		else
		{
			return;
		}
	}

	if(level.warmup) {
		if (level.rpam_nade_training_dmg_info == 1) {
			if (sWeapon == "fraggrenade_mp" || sWeapon == "mk1britishfrag_mp" || sWeapon == "rgd-33russianfrag_mp" || sWeapon == "stielhandgranate_mp") {
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				// old 2_3
				// iprintln(eAttacker.name + " ^received damage: " + iDamage);
				
				// Print damage
				if(isDefined(eAttacker) && isPlayer(eAttacker))
				{
					if (eAttacker == self)
					{
						// You inflicted 28 damage to yourself
						self iprintln("^7You inflicted ^1" + iDamage + "^7 damage to yourself");
						//self iprintln("^1Hit by-self for ^3" + iDamage + " ^1 damage^7"); // Hit Player damage notice
					}
					else
					{
						// You inflicted 28 damage to BOT1
						eAttacker iprintln("^7You inflicted ^2" + iDamage + "^7 damage to " + self.name);

						// Bot1 inflicted 12 damage to you
						self iprintln(eAttacker.name + "^7 inflicted ^1" + iDamage + "^7 damage to you");
					}
				}
				
				// not really needed here but imported from eyza code
				// Prevent damage if flaying is enabled
				//if (self.flaying_enabled)
				//	return true;
			}
		}
		return;
	}

	if (level.instrattime)
		return;

	if (level.rPAMstrat)
		return;

	if(level.roundended && !level.warmup && !level.rdyup)
		return;

	if(self.sessionteam == "spectator")
		return;

	if (level.bashdamageonly && sMeansOfDeath != "MOD_MELEE")
		return;

	// Don't do knockback if the damage direction was not specified
	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	rSHOWHITS = getcvar("rpam_riflesonly");
	if (rSHOWHITS == "1")
	{	
		if (isPlayer(eAttacker) && self != eAttacker && eAttacker.pers["team"] != self.pers["team"])
		{
			eAttacker thread rRIFLEHITBLIP();
		}
	}

	rRIFLEDAMAGE = getcvar("rpam_riflesonly");
	if (rRIFLEDAMAGE == "1")
	{
		if(sWeapon == "mosin_nagant_mp" || sWeapon == "kar98k_mp")
		{
			iDamage = 1000;
		}
	}
	
	self thread maps\mp\gametypes\_pam_round_report::onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);

	// check for completely getting out of the damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
		{
			if(level.friendlyfire == "0")
			{
				return;
			}
			else if(level.friendlyfire == "1")
			{
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
			}
			else if(level.friendlyfire == "2")
			{
				eAttacker.friendlydamage = true;
		
				iDamage = iDamage * .5;

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker.friendlydamage = undefined;
				
				friendly = true;
			}
			else if(level.friendlyfire == "3")
			{
				eAttacker.friendlydamage = true;

				iDamage = iDamage * .5;

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker.friendlydamage = undefined;
				
				friendly = true;
			}
		}
		else
		{
			// Make sure at least one point of damage is done
			if(iDamage < 1)
				iDamage = 1;

			self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
		}
//		end else if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
	}

	self maps\mp\gametypes\_shellshock_gmi::DoShellShock(sWeapon, sMeansOfDeath, sHitLoc, iDamage);

	// Do debug print if it's enabled
	if(getCvarInt("g_debugDamage"))
	{
		iprintln(level._prefix + "Name^9:^7 " + self.name);
		iprintln(level._prefix + "Gun^9:^7 " + sWeapon);
		iprintln(level._prefix + "Damage^9:^7 " + iDamage);
		iprintln(level._prefix + "Hit Location^9:^7 " + sHitLoc);
		iprintln(level._prefix + "Total Health^9:^7 " + self.health);
		//iprintln("client:" + self getEntityNumber() + " health:" + self.health + " damage:" + iDamage + " hitLoc:" + sHitLoc);
		wait 5;
	}

	if(self.sessionstate != "dead")
	{
		lpselfnum = self getEntityNumber();
		lpselfguid = self getGuid();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpattackerteam = "";

		if(isPlayer(eAttacker))
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackguid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackguid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		if(isDefined(friendly))
		{  
			lpattacknum = lpselfnum;
			lpattackname = lpselfname;
			lpattackguid = lpselfguid;
		}

		logPrint("D;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	}
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	self endon("spawned");

	//if(level.rdyup && !self.pers["killer"])
		//return;

	if(level.warmup)
		return;

	if(level.roundended && !level.warmup && !level.rdyup)
		return;

	if(self.sessionteam == "spectator")
		return;

	// If the player was killed by a head shot, let players know it was a head shot kill
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";

	// if this is a melee kill from a binocular then make sure they know that they are a loser
	if(sMeansOfDeath == "MOD_MELEE" && (sWeapon == "binoculars_artillery_mp" || sWeapon == "binoculars_mp") )
	{
		sMeansOfDeath = "MOD_MELEE_BINOCULARS";
	}

	// if this is a kill from the artillery binocs change the icon
	if(sMeansOfDeath != "MOD_MELEE_BINOCULARS" && sWeapon == "binoculars_artillery_mp" )
		sMeansOfDeath = "MOD_ARTILLERY";
	
	self thread maps\mp\gametypes\_pam_round_report::onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc);

	//garetcode
	if(sMeansOfDeath == "MOD_MELEE" && 	getcvar("sv_axisgoat") == "1")
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{ 
			player = players[i];
			player playsound("axisgoat");
		}
	}

	// send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);

	if(level.rdyup)
	{
		self.sessionstate = "dead";
		self.headicon = "";
		self.grenadecount = undefined;

		updateTeamStatus();
		wait 6;

		self thread spawnPlayer();
		return;
	}

	self.sessionstate = "dead";
	self.statusicon = "gfx/hud/hud@status_dead.tga";
	self.headicon = "";
	self.grenadecount = undefined;

	if(!level.warmup)
	{
		if (!isdefined (self.autobalance))
		{
			self.pers["deaths"]++;
			self.deaths = self.pers["deaths"];
		}
	}
	lpselfnum = self getEntityNumber();
	lpselfguid = self getGuid();
	lpselfname = self.name;
	lpselfteam = self.pers["team"];
	lpattackerteam = "";

	attackerNum = -1;

	if(isPlayer(attacker))
	{
		if(attacker == self) // killed himself
		{
			doKillcam = false;
			if(!level.warmup)
			{
				if (!isdefined (self.autobalance))
				{
					attacker.pers["score"]--;
					attacker.score = attacker.pers["score"];
				}
			}
			if(isDefined(attacker.friendlydamage))
				clientAnnouncement(attacker, &"MPSCRIPT_FRIENDLY_FIRE_WILL_NOT"); 
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;

			if(!level.warmup)
			{
				if(self.pers["team"] == attacker.pers["team"]) // killed by a friendly
				{
					//attacker.pers["score"]--; //Comment out for -1 teamkill
					attacker.score = attacker.pers["score"];
					//attacker.pers["tk_count"]++; //Comment out for -1 teamkill
				}
				else
				{
					attacker.pers["score"]++;
					attacker.score = attacker.pers["score"];
					//attacker.pers["pamstats_kills"]++;
					//self.pers["pamstats_deaths"]++;
				}
			}
		}
		
		lpattacknum = attacker getEntityNumber();
		lpattackguid = attacker getGuid();
		lpattackname = attacker.name;
		lpattackerteam = attacker.pers["team"];
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;
		if(!level.warmup)
		{
			self.pers["score"]--;
			self.score = self.pers["score"];
		}
		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackerteam = "world";
	}
	if(!level.warmup)
		logPrint("K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");

	// Make the player drop his weapon
	maps\mp\gametypes\_pam_weaponlimits::NoDropWeapon();

	// Make the player drop health
	self dropHealth();
	
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["spawnweapon"] = undefined;
	
	if (!isdefined (self.autobalance))
		body = self cloneplayer();
	self.autobalance = undefined;

	updateTeamStatus();

	// TODO: Add additional checks that allow killcam when the last player killed wouldn't end the round (bomb is planted)
	if((getCvarInt("scr_killcam") <= 0) || !level.exist[self.pers["team"]]) // If the last player on a team was just killed, don't do killcam
		doKillcam = false;

	delay = 2;	// Delay the player becoming a spectator till after he's done dying
	wait delay;	// ?? Also required for Callback_PlayerKilled to complete before killcam can execute

	/*if(level.warmup != "0")
		self thread spawnPlayer();*/

	if(doKillcam && !level.roundended)
		self thread killcam(attackerNum, delay);
	else
	{
		currentorigin = self.origin;
		currentangles = self.angles;
		level.specmode = "death";
		level.z_rpam_player_specmode = "death";
		level.z_rpam_spec_specmode = "death";

		self thread spawnSpectator(currentorigin + (0, 0, 60), currentangles);
	}
}

spawnPlayer()
{
	thread rSPAWNWITHCVARS();
	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	self notify("spawned");
	self notify ("lev_spawned");

	resettimeout();
	

	self.sessionteam = self.pers["team"];
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;
	self.noInactivityKick = 0;

	self.sessionstate = "playing";
		
	if(self.pers["team"] == "allies")
		spawnpointname = "mp_searchanddestroy_spawn_allied";
	else
		spawnpointname = "mp_searchanddestroy_spawn_axis";

	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	
	self.spawned = true;
	// if(level.rdyup != 1 || self.pers["killer"] != true)
	if(level.rdyup != 1)
		self.statusicon = "";
	self.maxhealth = 100;
	self.health = self.maxhealth;
	
	updateTeamStatus();

	if(!isDefined(self.pers["score"]))
		self.pers["score"] = 0;
	self.score = self.pers["score"];
	
	if(!isDefined(self.pers["deaths"]))
		self.pers["deaths"] = 0;
	self.deaths = self.pers["deaths"];
	
	if(!isDefined(self.pers["savedmodel"]))
		maps\mp\gametypes\_pam_teams::model();
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);
	
	rWEAPONS = getcvar("rpam_riflesonly");
	if (rWEAPONS == "0")
	{
		// setup all the weapons
		self maps\mp\gametypes\_pam_loadout_gmi::PlayerSpawnLoadout();
		maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

			self.usedweapons = false;
		thread maps\mp\gametypes\_pam_teams::watchWeaponUsage();
	}
	else if (rWEAPONS == "1")
	{
		if(self.pers["team"] == "allies")
		{
			self setWeaponSlotWeapon("primary", "mosin_nagant_mp");
			self setWeaponSlotAmmo("primary", 999);
			self setWeaponSlotClipAmmo("primary", 999);

			self setWeaponSlotWeapon("primaryb", "kar98k_mp");
			self setWeaponSlotAmmo("primaryb", 999);
			self setWeaponSlotClipAmmo("primaryb", 999);

			self setSpawnWeapon("mosin_nagant_mp");
		}
		else
		{
			self setWeaponSlotWeapon("primary", "kar98k_mp");
			self setWeaponSlotAmmo("primary", 999);
			self setWeaponSlotClipAmmo("primary", 999);

			self setWeaponSlotWeapon("primaryb", "mosin_nagant_mp");
			self setWeaponSlotAmmo("primaryb", 999);
			self setWeaponSlotClipAmmo("primaryb", 999);

			self setSpawnWeapon("kar98k_mp");
		}
	}

	if (getcvar("pam_mode") == "nade_training")
	{
		level.rpam_nade_training_dmg_info = 1;
		self thread _rPAM_rules\_rpam_nadetraining::main();
	} else {
		level.rpam_nade_training_dmg_info = 0;
		if (level.rdyup == 1 && level.scr_sd_readyup_nadetraining == 1)
		{
			logprint("enabling nade_training for spawned player because rdyup and nadetraining cvar are 1\n");
			self thread _rPAM_rules\_rpam_nadetraining::nade_Training();
		}
		else
		{
			logprint("disablin nade_training for spawned player because rdyup and nadetraining cvar are 0\n");
			self notify("end_Watch_Grenade_Throw");
		}
	}

	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();
	maps\mp\gametypes\_pam_teams::givePistol();
	maps\mp\gametypes\_pam_teams::giveGrenades(self.pers["selectedweapon"]);
	
	self.usedweapons = false;

	thread maps\mp\gametypes\_pam_teams::watchWeaponUsage();

	if(self.pers["team"] == game["attackers"])
		self setClientCvar("cg_objectiveText", &"SD_OBJ_ATTACKERS");
	else if(self.pers["team"] == game["defenders"])
		self setClientCvar("cg_objectiveText", &"SD_OBJ_DEFENDERS");
		
	if(level.drawfriend)
{
		if(level.battlerank)
		{
			if(level.rdyup != 1)
				self.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(self);
			self.headicon = maps\mp\gametypes\_rank_gmi::GetRankHeadIcon(self);
			self.headiconteam = self.pers["team"];
		}
		else
	{
		if(self.pers["team"] == "allies")
		{
			self.headicon = game["headicon_allies"];
			self.headiconteam = "allies";
		}
		else
		{
			self.headicon = game["headicon_axis"];
			self.headiconteam = "axis";
		}
	}
}
	else if(level.battlerank && level.rdyup != 1)
	{
		self.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(self);
	}	

	// setup the hud rank indicator
	self thread maps\mp\gametypes\_rank_gmi::RankHudInit();

	// setup anti fast shoot and anti aimglitch
	thread _rPAM_rules\_rpam_monitor::start();
}

spawnSpectator(origin, angles)
{
	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	self notify("spawned");

	resettimeout();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

	// if(self.pers["team"] == "spectator")
	if(self.pers["team"] == "spectator" && level.rdyup != 1)
		self.statusicon = "";
		
	maps\mp\gametypes\_pam_teams::SetSpectatePermissions();

	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);
	else
	{
 		spawnpointname = "mp_searchanddestroy_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		if(isDefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}

	updateTeamStatus();

	self.usedweapons = false;

	if(game["attackers"] == "allies")
		self setClientCvar("cg_objectiveText", &"SD_OBJ_SPECTATOR_ALLIESATTACKING");
	else if(game["attackers"] == "axis")
		self setClientCvar("cg_objectiveText", &"SD_OBJ_SPECTATOR_AXISATTACKING");

	if ( getcvar( "sv_specblackout" ) == "1" )
		self thread _specToBlack( level.specmode );

	if ( getcvar( "rpam_blackout_spec" ) == "1" )
		self thread rBLACKOUTspec( level.z_rpam_spec_specmode );

	if ( getcvar( "rpam_blackout_player" ) == "1" )
	{
		iprintln("^1rpam_blackout_player ^7is not available yet^5^7!");
		iprintln("^7Set ^1rpam_blackout_player ^7to ^10^7 please.");
	}

	if ( getcvar( "rpam_streaming" ) == "1" )
	{
		setCvar("rpam_blackout_spec", "0");
		self thread _rPAM_rules\streaming\streaming::main();
	}
	else if ( getCvar ("rpam_streaming") == "0")
	{
		_rPAM_rules\streaming\streaming::Streaming_Hud_Destroy();
	}
}

spawnIntermission()
{
	self notify("spawned");
	
	resettimeout();

	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

	spawnpointname = "mp_searchanddestroy_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

killcam(attackerNum, delay)
{
	self endon("spawned");
	
	// killcam
	if(attackerNum < 0)
		return;

	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.archivetime = delay + 7;

	maps\mp\gametypes\_pam_teams::SetKillcamSpectatePermissions();

	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait 0.50;

	if(self.archivetime <= delay)
	{
		self.spectatorclient = -1;
		self.archivetime = 0;
	
		maps\mp\gametypes\_pam_teams::SetSpectatePermissions();
		return;
	}

	self.killcam = true;

	if(!isDefined(self.kc_topbar))
	{
		self.kc_topbar = newClientHudElem(self);
		self.kc_topbar.archived = false;
		self.kc_topbar.x = 0;
		self.kc_topbar.y = 0;
		self.kc_topbar.alpha = 0.5;
		self.kc_topbar setShader("black", 640, 112);
	}

	if(!isDefined(self.kc_bottombar))
	{
		self.kc_bottombar = newClientHudElem(self);
		self.kc_bottombar.archived = false;
		self.kc_bottombar.x = 0;
		self.kc_bottombar.y = 368;
		self.kc_bottombar.alpha = 0.5;
		self.kc_bottombar setShader("black", 640, 112);
	}

	if(!isDefined(self.kc_title))
	{
		self.kc_title = newClientHudElem(self);
		self.kc_title.archived = false;
		self.kc_title.x = 320;
		self.kc_title.y = 40;
		self.kc_title.alignX = "center";
		self.kc_title.alignY = "middle";
		self.kc_title.sort = 1; // force to draw after the bars
		self.kc_title.fontScale = 3.5;
	}
	self.kc_title setText(&"MPSCRIPT_KILLCAM");

	if(!isDefined(self.kc_skiptext))
	{
		self.kc_skiptext = newClientHudElem(self);
		self.kc_skiptext.archived = false;
		self.kc_skiptext.x = 320;
		self.kc_skiptext.y = 70;
		self.kc_skiptext.alignX = "center";
		self.kc_skiptext.alignY = "middle";
		self.kc_skiptext.sort = 1; // force to draw after the bars
	}
	self.kc_skiptext setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_SKIP");

	if(!isDefined(self.kc_timer))
	{
		self.kc_timer = newClientHudElem(self);
		self.kc_timer.archived = false;
		self.kc_timer.x = 320;
		self.kc_timer.y = 428;
		self.kc_timer.alignX = "center";
		self.kc_timer.alignY = "middle";
		self.kc_timer.fontScale = 3.5;
		self.kc_timer.sort = 1;
	}
	self.kc_timer setTenthsTimer(self.archivetime - delay);

	self thread spawnedKillcamCleanup();
	self thread waitSkipKillcamButton();
	self thread waitKillcamTime();
	self waittill("end_killcam");

	self removeKillcamElements();

	self.spectatorclient = -1;
	self.archivetime = 0;
	self.killcam = undefined;
	
	maps\mp\gametypes\_pam_teams::SetSpectatePermissions();
}

waitKillcamTime()
{
	self endon("end_killcam");
	
	wait(self.archivetime - 0.05);
	self notify("end_killcam");
}

waitSkipKillcamButton()
{
	self endon("end_killcam");
	
	while(self useButtonPressed())
		wait .05;

	while(!(self useButtonPressed()))
		wait .05;
	
	self notify("end_killcam");	
}

removeKillcamElements()
{
	if(isDefined(self.kc_topbar))
		self.kc_topbar destroy();
	if(isDefined(self.kc_bottombar))
		self.kc_bottombar destroy();
	if(isDefined(self.kc_title))
		self.kc_title destroy();
	if(isDefined(self.kc_skiptext))
		self.kc_skiptext destroy();
	if(isDefined(self.kc_timer))
		self.kc_timer destroy();
}

spawnedKillcamCleanup()
{
	self endon("end_killcam");

	self waittill("spawned");
	self removeKillcamElements();
}

startGame()
{

	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	level.starttime = getTime();
	thread startRound();
	
	if ( (level.teambalance > 0) && (!game["BalanceTeamsNextRound"]) )
		level thread maps\mp\gametypes\_pam_teams::TeamBalance_Check_Roundbased();
}

startRound()
{
	// WEAPON EXPLOIT FIX
	if (game["dropsecondweap"])
		DropSecWeapon();

	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	level endon("bomb_planted");

	if(game["matchstarted"])
	{
		if (game["mode"] == "match")
			game["switchprevent"] = true;

		maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

		/* This will be later changed to pistol round */
		if (getcvar("pam_mode") == "bash" || getcvar("pam_mode") == "bash_round")
		{
			thread Bash_Round();
			return;
		}

		// STRAT Time
		level.clock = newHudElem();
		level.clock.x = 320;
		level.clock.y = 460;
		level.clock.alignX = "center";
		level.clock.alignY = "middle";
		level.clock.font = "bigfixed";
		level.clock setTimer(level.graceperiod);

		if ( level.z_rpam_strat == 1 ) 
		{
			level.clock setTimer(level.graceperiod);
			thread rPAMstrat();

			level.clock.color = (0, 0.749, 1);
		}
		else if ( level.z_rpam_scr_strat_time == 1 )
		{
			level.clock setTimer(level.graceperiod);
			thread Hold_All_Players();

			level.clock.color = (0, 1, 0);
		}
		else
		{
			level.clock setTimer(level.roundlength * 60);
			thread maps\mp\gametypes\_pam_teams::sayMoveIn();

			level.clock.color = (0, 1, 0);
		}

		wait level.graceperiod;
		
		setCvar("g_speed", 190);

		// START MATCH ROUND HERE!
		level notify("round_started");
		level.roundstarted = true; //THIS stops players from being able to choose new weapons

		level.clock.color = (1, 1, 1);

		if ( level.z_rpam_strat == 1 ||  level.z_rpam_scr_strat_time == 1 )
			level.clock setTimer(level.roundlength * 60);

		if(isdefined(level.livemsg))
			level.livemsg destroy();

		// Players on a team but without a weapon show as dead since they can not get in this round
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if(player.sessionteam != "spectator" && !isDefined(player.pers["weapon"]))
				player.statusicon = "gfx/hud/hud@status_dead.tga";
		}

		if ( level.z_rpam_scr_strat_time == 1 || level.z_rpam_strat == 1 )
		{
			wait(level.roundlength * 60);
		}
		else
		{
			wait((level.roundlength * 60) - level.graceperiod);
		}
	}
	else	
	{
		level.clock = newHudElem();
		level.clock.x = 320;
		level.clock.y = 460;
		level.clock.alignX = "center";
		level.clock.alignY = "middle";
		level.clock.font = "bigfixed";
		level.clock setTimer(1);

		return;
	}

	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	if(level.roundended)
		return;

	if (level.warmup)
		return;

	if(!level.exist[game["attackers"]] || !level.exist[game["defenders"]])
	{
		if(level.warmup)
			return;

		announcement(&"SD_TIMEHASEXPIRED");
		level thread endRound("draw");
		return;
	}
	if(!level.warmup)
	{
		announcement(&"SD_TIMEHASEXPIRED");
		level thread endRound(game["defenders"]);
	}
}

checkMatchStart()
{
	if (game["matchstarted"])
		return;

	level.warmup = 1;

	if (game["checkingmatchstart"])
		return;

	game["checkingmatchstart"] = true;

	if (getcvar("pam_mode") == "nade_training")
	{
		level.rpam_nade_training_dmg_info = 1;
		_rPAM_rules\_rpam_nadetraining::Do_Strat_Warning();
		return;
	} else {
		level.rpam_nade_training_dmg_info = 0;
	}

	//Check to see if we even have 2 teams to start
	level.exist["teams"] = 0; // Put 1 for RUP w/o 2 players. Only for DEV
	maps\mp\gametypes\_pam_teams::deletePlacedEntity("misc_mg42"); // Removes MGs during Warmup.

	while(!level.exist["teams"])
	{
		level.exist["allies"] = 0;
		level.exist["axis"] = 0;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			
			if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
				level.exist[player.pers["team"]]++;
		}

		if (level.exist["allies"] && level.exist["axis"])
			level.exist["teams"] = 1;

		if (getcvar("scr_debug_sd") == "1")
			level.exist["teams"] = 1;

		wait 1;
	}

	if(!level.roundended)
	{

		Create_HUD_Header();

		if( game["mode"] == "match")
		{
			level.warmup = 0;

			//Load correct PB Config
			if (getcvar("pam_mode") != "bash"){
			_rPAM_rules\_rpam_pb_utils::Check_PB_Config();
			}

			Do_Ready_Up();

			level.warmup = 1;

			// get rid of warmup weapons
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{ 
				//drop other weapons
				player = players[i];

				if (!isdefined(player.pers["selectedweapon"]) )
					player.pers["selectedweapon"] = undefined;

				player.pers["weapon1"] = undefined;
				player.pers["weapon2"] = undefined;
				player.pers["weapon"] = player.pers["selectedweapon"];
				player.pers["spawnweapon"] = player.pers["selectedweapon"];

				player unlink();
			}

			game["matchstarted"] = true;
			level.matchstarted = true;

			resetScores();

			map_restart(true);

			return;
		}

		else
			wait 3;

		Destroy_HUD_Header();

		maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

		level notify("kill_endround");
		level.roundended = false;
		level thread endRound("reset");
	}
	else
	{
		announcement(&"SD_MATCHRESUMING");

		level notify("kill_endround");
		level.roundended = false;
		level thread endRound("draw");
	}

	return;
}

resetScores()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player.pers["score"] = 0;
		player.pers["deaths"] = 0;
	}

	game["alliedscore"] = 0;
	setTeamScore("allies", game["alliedscore"]);
	game["axisscore"] = 0;
	setTeamScore("axis", game["axisscore"]);
	game["round1alliesscore"] = 0;
	game["round1axisscore"] = 0; 
	game["round2alliesscore"] = 0;
	game["round2axisscore"] = 0;

	if (level.battlerank)
	{
		maps\mp\gametypes\_rank_gmi::ResetPlayerRank();
	}
}

endRound(roundwinner)
{
	level endon("kill_endround");

	if(level.roundended)
		return;
	level.roundended = true;

	// End bombzone threads and remove related hud elements and objectives
	level notify("round_ended");

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];		

		if(isDefined(player.planticon))
			player.planticon destroy();

		if(isDefined(player.defuseicon))
			player.defuseicon destroy();

		if(isDefined(player.progressbackground))
			player.progressbackground destroy();

		if(isDefined(player.progressbar))
			player.progressbar destroy();

		player unlink();
		player enableWeapon();
	}

	objective_delete(0);
	objective_delete(1);

	if (!isdefined(roundwinner))
		roundwinner = "reset";

	/*if(roundwinner == "allies")
	{
		/*
		pamsounds = getcvar("sv_pamsounds");
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
		player = players[i];
		if(!isDefined(player.pers["pamsounds"]))
		{
			player.pers["pamsounds"] = 1;
		}

			if (player.pers["pamsounds"] == "0")
				player playLocalSound("MP_announcer_allies_win");
			else
				player playLocalSound("pam_MP_announcer_allies_win");
		}
		*//*
		player playLocalSound("MP_announcer_allies_win");
	}
	else if(roundwinner == "axis")
	{
		/*
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{		
		player = players[i];
		if(!isDefined(player.pers["pamsounds"]))
		{
			player.pers["pamsounds"] = 1;
		}

			if (player.pers["pamsounds"] == "0")
				player playLocalSound("MP_announcer_axis_win");
			else
				player playLocalSound("pam_MP_announcer_axis_win");
		}
		*//*
		player playLocalSound("MP_announcer_axis_win");
	}
	else if(roundwinner == "draw")
	{
		/*
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if(!isDefined(player.pers["pamsounds"]))
			{
				player.pers["pamsounds"] = 1;
			}

			if (player.pers["pamsounds"] == "0")
				player playLocalSound("MP_announcer_round_draw");
			else
				player playLocalSound("pam_MP_announcer_round_draw");
		}
		*//*
		player playLocalSound("MP_announcer_round_draw");
	}*/

		if(roundwinner == "allies" || roundwinner == "axis" || roundwinner == "draw")
	{
		play_sound = "MP_announcer_round_draw";
		if (roundwinner == "allies") {
			play_sound = "MP_announcer_allies_win";
		} else if (roundwinner == "axis") {
			play_sound = "MP_announcer_axis_win";
		}

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			player playLocalSound(play_sound);
		}
	}

	wait 5;

	winners = "";
	losers = "";

	if(roundwinner == "allies")
	{
		game["alliedscore"]++;
		setTeamScore("allies", game["alliedscore"]);
		
		if(game["halftimeflag"] == "1")
		{
			game["round2alliesscore"]++;
			halftimeflag = game["halftimeflag"];
		}
		else if(game["matchstarted"])
			game["round1alliesscore"]++;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			lpGuid = players[i] getGuid();
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
				winners = (winners + ";" + lpGuid + ";" + players[i].name);
			else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
				losers = (losers + ";" + lpGuid + ";" + players[i].name);
		}
		logPrint("W;allies" + winners + "\n");
		logPrint("L;axis" + losers + "\n");
	}
	else if(roundwinner == "axis")
	{
		game["axisscore"]++;
		setTeamScore("axis", game["axisscore"]);

		if(game["halftimeflag"] == "1")
		{
			game["round2axisscore"]++;
			halftimeflag = game["halftimeflag"];
		}
		else if(game["matchstarted"])
			game["round1axisscore"]++;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			lpGuid = players[i] getGuid();
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
				winners = (winners + ";" + lpGuid + ";" + players[i].name);
			else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
				losers = (losers + ";" + lpGuid + ";" + players[i].name);
		}
		logPrint("W;axis" + winners + "\n");
		logPrint("L;allies" + losers + "\n");
	}
	
	// Print damage stats
	maps\mp\gametypes\_pam_round_report::printToAll();

	if(game["matchstarted"])
	{
		if (level.countdraws == 1)
			game["roundsplayed"]++;
		else if(roundwinner != "draw")
			game["roundsplayed"]++;
		checkMatchRoundLimit();
		checkMatchScoreLimit();
	}

	if(!game["matchstarted"] && roundwinner == "reset")
	{
		game["matchstarted"] = true;
		level.matchstarted = true;
		thread resetScores();
		game["roundsplayed"] = 0;
	}

	game["timepassed"] = game["timepassed"] + ((getTime() - level.starttime) / 1000) / 60.0;

//	checkTimeLimit(); //NO TIME LIMIT RIGHT NOW!

	if (level.hithalftime)
		return;

	if(level.mapended)
		return;
	level.mapended = true;

	// for all living players store their weapons
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
		{
			primary = player getWeaponSlotWeapon("primary");
			primaryb = player getWeaponSlotWeapon("primaryb");

			// If a menu selection was made let's check pam rules first
			if(getCvar("rpam_riflesonly") == "0")
			{
				if(isDefined(player.oldweapon))
				{
					// If a new weapon has since been picked up (this fails when a player picks up a weapon the same as his original)
					if(player.oldweapon != primary && player.oldweapon != primaryb && primary != "none")
					{
						player.pers["weapon1"] = primary;
						player.pers["weapon2"] = primaryb;
						player.pers["spawnweapon"] = player getCurrentWeapon();
					} // If the player's menu chosen weapon is the same as what is in the primaryb slot, swap the slots
					else if(player.pers["weapon"] == primaryb)
					{
						player.pers["weapon1"] = primaryb;
						player.pers["weapon2"] = primary;
						player.pers["spawnweapon"] = player.pers["weapon1"];
					} // Give them the weapon they chose from the menu
					else
					{
						player.pers["weapon1"] = player.pers["weapon"];
						player.pers["weapon2"] = primaryb;
						player.pers["spawnweapon"] = player.pers["weapon1"];
					}
				} // No menu choice was ever made, so keep their weapons and spawn them with what they're holding, unless it's a pistol or grenade
				else
				{
					if(primary == "none")
						player.pers["weapon1"] = player.pers["weapon"];
					else
						player.pers["weapon1"] = primary;
						
					player.pers["weapon2"] = primaryb;

					spawnweapon = player getCurrentWeapon();
					if ( (spawnweapon == "none") && (isdefined (primary)) ) 
						spawnweapon = primary;

					if(!maps\mp\gametypes\_pam_teams::isPistolOrGrenade(spawnweapon))
						player.pers["spawnweapon"] = spawnweapon;
					else
						player.pers["spawnweapon"] = player.pers["weapon1"];
				}
			}
			else if(getCvar("rpam_riflesonly") == "1")
			{
				if(isDefined(player.oldweapon))
				{
					// If a new weapon has since been picked up (this fails when a player picks up a weapon the same as his original)
					if(player.oldweapon != primary && player.oldweapon != primaryb && primary != "none")
					{
						player.pers["weapon1"] = kar98k_mp;
						player.pers["weapon2"] = mosin_nagant_mp;
						player.pers["spawnweapon"] = player getCurrentWeapon();
					} // If the player's menu chosen weapon is the same as what is in the primaryb slot, swap the slots
					else if(player.pers["weapon"] == primaryb)
					{
						player.pers["weapon1"] = kar98k_mp;
						player.pers["weapon2"] = mosin_nagant_mp;
						player.pers["spawnweapon"] = player.pers["weapon1"];
					} // Give them the weapon they chose from the menu
					else
					{
						player.pers["weapon1"] = player.pers["weapon"];
						player.pers["weapon2"] = primaryb;
						player.pers["spawnweapon"] = player.pers["weapon1"];
					}
				} // No menu choice was ever made, so keep their weapons and spawn them with what they're holding, unless it's a pistol or grenade
				else
				{
					if(primary == "none")
						player.pers["weapon1"] = player.pers["weapon"];
					else
						player.pers["weapon1"] = primary;
						
					player.pers["weapon2"] = primaryb;

					spawnweapon = player getCurrentWeapon();
					if ( (spawnweapon == "none") && (isdefined (primary)) ) 
						spawnweapon = primary;

					if(!maps\mp\gametypes\_pam_teams::isPistolOrGrenade(spawnweapon))
						player.pers["spawnweapon"] = spawnweapon;
					else
						player.pers["spawnweapon"] = player.pers["weapon1"];
				}
			}
		}
	}
//	maps\mp\gametypes\_pam_weaponlimits::CheckLimits(); Remove for now

	if ( (level.teambalance > 0) && (game["BalanceTeamsNextRound"]) )
	{
		level.lockteams = true;
		level thread maps\mp\gametypes\_pam_teams::TeamBalance();
		level waittill ("Teams Balanced");
		wait 4;
	}
	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	if((getcvar("g_roundwarmuptime") != "0") && (game["roundsplayed"] != "0" ) && level.hithalftime == 0)
	{
		level.warmup = 1;

		rSTRATcheck = getcvarint("rpam_strat");
		if (rSTRATcheck == 1)
		{
			thread rSTRATEXPLOIT();
		}

		//display scores
		Create_HUD_Header();

		Create_HUD_Scoreboard();

		warmup = getcvarint("g_roundwarmuptime");
		Create_HUD_NextRound(warmup);

		/* Remove match countdown text */
		
		Destroy_HUD_Header();

		Destroy_HUD_Scoreboard();

		Destroy_HUD_NextRound();
	}
	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	map_restart(true);
}

endMap()
{
        if(level.awe_mapvote)
                maps\mp\gametypes\_awe_mapvote::Initialise();

        game["state"] = "intermission";
        level notify("intermission");
	
	if(isdefined(level.bombmodel))
		level.bombmodel stopLoopSound();

	if(game["alliedscore"] == game["axisscore"])
		text = &"MPSCRIPT_THE_GAME_IS_A_TIE";
	else if(game["alliedscore"] > game["axisscore"])
		text = &"MPSCRIPT_ALLIES_WIN";
	else
		text = &"MPSCRIPT_AXIS_WIN";


	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player closeMenu();
		player setClientCvar("g_scriptMainMenu", "main");
		player setClientCvar("cg_objectiveText", text);
		player spawnIntermission();
	}

	wait 1;

	if (game["mode"] == "match")
		maps\mp\gametypes\_pam_utilities::Prevent_Map_Change();

	if (getCvar("g_autoscreenshot") == "1")
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];	
			player setClientCvar("cg_autoscreenshot", "1");			
			player autoScreenshot();
		}
	}

	wait 9;

	exitLevel(false);
}

checkTimeLimit()
{
	if(level.warmup)
		return;

	if(level.timelimit <= 0)
		return;
	
	if(game["timepassed"] < level.timelimit)
		return;
	
	if(level.mapended)
		return;
	level.mapended = true;

	iprintln(&"MPSCRIPT_TIME_LIMIT_REACHED");
	level thread endMap();
}

checkMatchRoundLimit()
{
	if(level.warmup)
		return;
		
	/*  Is it a round-base halftime? */
	if (level.halfround != 0  && game["halftimeflag"] == "0")
	{
		if(game["roundsplayed"] >= level.halfround)
		{ 
			Do_Half_Time();
			return;
		}
	}

	/*  End of Map Roundlimit! */
	if (level.matchround != 0)
	{
		if (game["roundsplayed"] >= level.matchround)
		{
			if(game["alliedscore"] == game["axisscore"] && getcvar("g_ot") == "1")  // have a tie and overtime mode is on
				Prepare_map_Tie();
			else
				setCvar("g_ot_active", "0");

			Create_HUD_Matchover();

			Create_HUD_TeamWin();

			Create_HUD_Header();
				
			Create_HUD_Scoreboard();

			wait 10;

			Destroy_HUD_Header();

			Destroy_HUD_Scoreboard();

			Destroy_HUD_TeamWin();

			if(isdefined(level.matchover))
				level.matchover destroy();

			if(level.mapended)
				return;
			level.mapended = true;

			endMap();
		}
	}
}

checkMatchScoreLimit()
{
	if(level.warmup)
		return;

	/* Is it a score-based Halftime? */
	if(game["halftimeflag"] == "0" && level.halfscore != 0)
	{
		if(game["alliedscore"] >= level.halfscore || game["axisscore"] >= level.halfscore)
		{ 
			Do_Half_Time();
			return;
		}
	}

	/* 2nd-Half Score Limit Check */
	if (level.matchscore2 != 0)
	{
		if ( game["round2axisscore"] >= level.matchscore2 || game["round2alliesscore"] >= level.matchscore2)
		{

			if(game["alliedscore"] == game["axisscore"] && getcvar("g_ot") == "1")  // have a tie and overtime mode is on
				Prepare_map_Tie();
			else
				setCvar("g_ot_active", "0");

			Create_HUD_Matchover();

			Create_HUD_TeamWin();

			Create_HUD_Header();
				
			Create_HUD_Scoreboard();

			wait 10;

			Destroy_HUD_Header();

			Destroy_HUD_Scoreboard();

			Destroy_HUD_TeamWin();

			if(isdefined(level.matchover))
				level.matchover destroy();

			if(level.mapended)
			return;
			level.mapended = true;

			endMap();
		}
	}

	/* Match Score Check */
	if (level.matchscore1 != 0)
	{
		if(game["alliedscore"] < level.matchscore1 && game["axisscore"] < level.matchscore1)
			return;

		if(game["alliedscore"] == game["axisscore"] && getcvar("g_ot") == "1")  // have a tie and overtime mode is on
				Prepare_map_Tie();
			else
				setCvar("g_ot_active", "0");

		Create_HUD_Matchover();

		Create_HUD_TeamWin();

		Create_HUD_Header();
			
		Create_HUD_Scoreboard();

		wait 10;

		Destroy_HUD_Header();

		Destroy_HUD_Scoreboard();

		Destroy_HUD_TeamWin();

		if(isdefined(level.matchover))
			level.matchover destroy();

		if(level.mapended)
		return;
		level.mapended = true;

		endMap();
	}
}

updateGametypeCvars()
{
	level endon("PAMRestart");
	enabling = 0;

	for(;;)
	{
		// WORM PAM Disable Check
		pamenable = getCvarint("svr_pamenable");
		if (pamenable != level.pamenable && pamenable == 0)
		{
			enabling = 1;
			level.pamenable = pamenable;

			maps\mp\gametypes\_pam_utilities::StopPAMUO();
			level notify("PAMRestart");
		}

		league = getCvar("pam_mode");
		if(league != level.league && !enabling)
		{
			ValidPamMode = _rPAM_rules\_rPAM_rulesets_sd::rCHECKPAMMODES(league);

			if (ValidPamMode)
			{
				wait .1;
				thread maps\mp\gametypes\_pam_utilities::PAMRestartMap();
				level notify("PAMRestart");
			}
			else
			{
				iprintln(level._prefix + "ERROR Loading ^9" + league);
				wait 1;
				iprintln(level._prefix + "Valid ^9Default ^7Modes^9:");
				wait 0.5; 
				iprintln(level._prefix + "^9AW: ^7aw_mr10^9,^7 aw_mr12^9,^7 aw_mr13^9, ^7aw_bo3");
				iprintln(level._prefix + "^9RO: ^7ro_mr10^9,^7 ro_mr12^9,^7 ro_mr13^9, ^7ro_bo3");
				wait 1;
				iprintln(level._prefix + "Valid ^9UnitedBase ^7Modes^9:");
				wait 0.5;
				iprintln(level._prefix + "^9AW: ^7ub_mr10^9, ^7ub_mr10_mix^9, ^7ub_mr12^9,^7 ub_mr13^9,^7 ub_bo3");
				wait 1;
				iprintln(level._prefix + "Valid ^9Public ^7Modes^9:");
				wait 0.5;
				iprintln(level._prefix + "^7aw_pub^9,^7 ro_pub^9,^7 nade_training");
				wait 1;
				iprintln(level._prefix + "^9map_restart ^7will return you to the default PAM Mode");
			}
			level.league = league;
		}

		ceasefire = getCvarint("scr_ceasefire");
		// if we are in cease fire mode display it on the screen
		if (ceasefire != level.ceasefire)
		{
			level.ceasefire = ceasefire;
			if ( ceasefire )
				level thread maps\mp\_util_mp_gmi::make_permanent_announcement(&"GMI_MP_CEASEFIRE", "end ceasefire", 220, (1.0,0.0,0.0));			
			else
				level notify("end ceasefire");
		}

		// check all the players for rank changes
		if ( getCvarint("scr_battlerank") )
			maps\mp\gametypes\_rank_gmi::CheckPlayersForRankChanges();

		halfround = getCvarInt("scr_half_round");
		if (halfround != level.halfround)
		{
			level.halfround = halfround;
			iprintln("^3scr_half_round ^7has been changed to ^3" + halfround);
		}

		halfscore = getCvarInt("scr_half_score");
		if (halfscore != level.halfscore)
		{
			level.halfscore = halfscore;
			iprintln("^3scr_half_score ^7has been changed to ^3" + halfscore);
		}

		matchround = getCvarInt("scr_end_round");
		if (matchround != level.matchround)
		{
			level.matchround = matchround;
			iprintln("^3scr_end_round ^7has been changed to ^3" + matchround);
		}

		matchscore = getCvarInt("scr_end_score");
		if (matchscore != level.matchscore1)
		{
			level.matchscore1 = matchscore;
			iprintln("^3scr_end_score ^7has been changed to ^3" + matchscore);
		}

		matchscore2 = getCvarInt("scr_end_half2score");
		if (matchscore2 != level.matchscore2)
		{
			level.matchscore2 = matchscore2;
			iprintln("^3scr_end_half2score ^7has been changed to ^3" + matchscore2);
		}

		countdraws = getCvarInt("scr_count_draws");
		if (countdraws != level.countdraws)
		{
			level.countdraws = countdraws;
			iprintln("^3scr_count_draws ^7has been changed to ^3" + countdraws);
			if (countdraws == 1)
				iprintln("Round Draws will not be replayed");
			else
				iprintln("Round Draws will be replayed");
		}

		timelimit = getCvarFloat("scr_sd_timelimit");
		if(level.timelimit != timelimit)
		{
			if(timelimit > 1440)
			{
				timelimit = 1440;
				setCvar("scr_sd_timelimit", "1440");
			}

			level.timelimit = timelimit;
			iprintln("^3TIMELIMIT has been changed to ^5" + timelimit);
			iprintln("^3TIMELIMIT is not used in this mod at this time");
		}

		roundlength = getCvarFloat("scr_sd_roundlength");
		if(roundlength > 10)
			setCvar("scr_sd_roundlength", "10");
		if (roundlength != level.roundlength)
		{
			level.roundlength = getCvarFloat("scr_sd_roundlength");
			iprintln("ROUNDLENGTH has been changed to ^5" + roundlength);
		}

		graceperiod = getCvarFloat("scr_sd_graceperiod");
		if(graceperiod > 60)
			setCvar("scr_sd_graceperiod", "60");

		drawfriend = getCvarFloat("scr_drawfriend");
		battlerank = getCvarint("scr_battlerank");
		if(level.battlerank != battlerank || level.drawfriend != drawfriend)
		{
			level.drawfriend = drawfriend;
			level.battlerank = battlerank;
			
			// battle rank has precidence over draw friend
			if(level.battlerank)
			{
				// for all living players, show the appropriate headicon
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
					{
						// setup the hud rank indicator
						player thread maps\mp\gametypes\_rank_gmi::RankHudInit();

						player.statusicon = maps\mp\gametypes\_rank_gmi::GetRankStatusIcon(player);
						if ( level.drawfriend )
						{
							player.headicon = maps\mp\gametypes\_rank_gmi::GetRankHeadIcon(player);
							player.headiconteam = player.pers["team"];
							iprintln("^3Draw Friend has been turned ^2ON!");
						}
						else
						{
							player.headicon = "";
							iprintln("^3Draw Friend has been turned ^1OFF!");
						}
					}
				}
			}
			else if(level.drawfriend)
			{
				iprintln("^3Draw Friend has been turned ^5ON!");
				// for all living players, show the appropriate headicon
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
					{
						if(player.pers["team"] == "allies")
						{
							player.headicon = game["headicon_allies"];
							player.headiconteam = "allies";
						}
						else
						{
							player.headicon = game["headicon_axis"];
							player.headiconteam = "axis";
						}
					}
				}
			}
			else
			{
				iprintln("^3Draw Friend has been turned ^1OFF!");
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
						player.headicon = "";
						player.statusicon = "";
				}
			}
		}

		killcam = getCvarInt("scr_killcam");
		if (level.killcam != killcam)
		{
			level.killcam = getCvarInt("scr_killcam");
			if(level.killcam >= 1)
			{
				setarchive(true);
				iprintln("^3Kill Cam ^5ON!");
			}
			else
			{
				setarchive(false);
				iprintln("^3Kill Cam ^1OFF!");
			}
		}
		
		freelook = getCvarInt("scr_freelook");
		if (level.allowfreelook != freelook)
		{
			level.allowfreelook = getCvarInt("scr_freelook");
			level maps\mp\gametypes\_pam_teams::UpdateSpectatePermissions();
			if (freelook == 0)
				iprintln("^3FREELOOK has been turned ^1OFF!");
			else
				iprintln("^3FREELOOK has been turned ^5ON!");
		}
		
		enemyspectate = getCvarInt("scr_spectateenemy");
		if (level.allowenemyspectate != enemyspectate)
		{
			level.allowenemyspectate = getCvarInt("scr_spectateenemy");
			level maps\mp\gametypes\_pam_teams::UpdateSpectatePermissions();
			if (enemyspectate == 0)
				iprintln("^3Spectate Enemies has been turned ^1OFF!");
			else
				iprintln("^3Spectate Enemies has been turned ^5ON!");
		}
		
		teambalance = getCvarInt("scr_teambalance");
		if (level.teambalance != teambalance)
		{
			level.teambalance = getCvarInt("scr_teambalance");
			if (level.teambalance > 0)
			{
				iprintln("^3TEAMBALANCE has been turned ^5ON!");
				level thread maps\mp\gametypes\_pam_teams::TeamBalance_Check_Roundbased();
			}
			else
				iprintln("^3TEAMBALANCE has been turned ^1OFF!");
		}

		ffire = getCvarInt("scr_friendlyfire");
		if (level.ffire != ffire)
		{
			level.ffire = getCvarInt("scr_friendlyfire");
			if (level.ffire == 0)
				iprintln("^3Friendly Fire has been turned ^1OFF!");
			else if (level.ffire == 1 || level.ffire > 3)
				iprintln("^3Friendly Fire has been turned ^1ON!");
			else if (level.ffire == 2)
				iprintln("^3Friendly Fire has been switched to ^1REFLECTION!");
			else if (level.ffire == 3)
				iprintln("^3Friendly Fire has been turned ^1ON with REFLECTION!");
		}

		pure = getCvarInt("sv_pure");
		if (pure != level.pure)
		{
			level.pure = getCvarInt("sv_pure");
			if (level.pure == 1)
				iprintln("^3SV_PURE has been turned ^5ON!");
			else
				iprintln("^3SV_PURE has been turned ^1OFF");
		}

		vote = getCvarInt("g_allowVote");
		if(vote != level.vote)
		{
			level.vote = getCvarInt("g_allowVote");
			if(level.vote == 0)
				iprintln("^3Voting has been turned ^1OFF!");
			else
				iprintln("^3Voting has been turned ^5ON!");
		}
		
		faust = getcvarint("scr_allow_panzerfaust");
		if (faust != level.faust)
		{
			level.faust = faust;
			if (faust == 0)
				iprintln("^3Rockets have been turned ^1OFF!");
			else
				iprintln("^3Rockets have been turned ^5ON!");
		}

		fg42gun = getcvarint("scr_allow_fg42");
		if (fg42gun != level.fg42gun)
		{
			level.fg42gun = fg42gun;
			if (fg42gun == 0)
				iprintln("^3The FG42 has been turned ^1OFF!");
			else
				iprintln("^3The FG42 has been turned ^5ON!");
		}


		nodropsniper = getcvarint("sv_noDropSniper");
		if (nodropsniper != level.nodropsniper)
		{
			level.nodropsniper = nodropsniper;
			if (nodropsniper == 1)
				iprintln("^3Sniper Rifle Drops have been turned ^5ON!");
			else
				iprintln("^3Sniper Rifle Drops have been turned ^1OFF!");
		}

		allysnipelimit = getcvarint("sv_alliedSniperLimit");
		if (allysnipelimit != level.allysnipelimit)
		{
			level.allysnipelimit = allysnipelimit;
			iprintln("^3Allied Sniper Rifles limited to ^5" + allysnipelimit);
		}

		axissnipelimit = getcvarint("sv_axisSniperLimit");
		if (axissnipelimit != level.axissnipelimit)
		{
			level.axissnipelimit = axissnipelimit;
			iprintln("^3Axis Sniper Rifles limited to ^5" + axissnipelimit);
		}

		bombplanttime = getcvarFloat("sv_BombPlantTime");
		if (bombplanttime != level.planttime)
		{
			level.bombplanttime = planttime;
			iprintln("^3Bomb Plant Time has been changed to ^5" + bombplanttime);
		}

		bombdefusetime = getcvarFloat("sv_BombDefuseTime");
		if (bombdefusetime != level.defusetime)
		{
			level.defusetime = bombdefusetime;
			iprintln("^3Bomb Defuse Time has been changed to ^5" + bombdefusetime);
		}

		countdowntime = getcvarFloat("sv_BombTimer");
		if (countdowntime != level.countdowntime)
		{
			level.countdowntime = countdowntime;
			iprintln("^3Bomb Timer has been changed to ^5" + countdowntime);
		}

		hdrop = getcvarint("scr_drophealth");
		if (hdrop != level.drophealth)
		{
			level.drophealth = hdrop;
			if (hdrop == 0)
				iprintln("^1Health Drop OFF");
			else
				iprintln("^2Health Drop ON");
		}

		sshock = getcvarint("scr_shellshock");
		if (sshock != level.sshock)
		{
			level.sshock = sshock;
			if (sshock == 0)
				iprintln("^1Shell Shock OFF");
			else
				iprintln("^2Shell Shock ON");
		}

		showcommand_countdownclock = getcvarint("rpam_countdownclock");
		if (showcommand_countdownclock != level.z_rpam_countdownclock)
		{
			level.z_rpam_countdownclock = showcommand_countdownclock;
			if (showcommand_countdownclock == 1)
			{
				iprintln("^5Countdown Clock ^7have been turned ^5ON");
				iprintln("^9rpam_countdownclock 1");
			}
			else
			{
				iprintln("^3Countdown Clock ^7have been turned ^1OFF");
				iprintln("^9rpam_countdownclock 0");
			}
		}

		showcommand_riflesonly = getcvarint("rpam_riflesonly");
		if (showcommand_riflesonly != level.z_rpam_riflesonly)
		{
			level.z_rpam_riflesonly = showcommand_riflesonly;
			if (showcommand_riflesonly == 1)
			{
				iprintln("^5Rifles Only Mode ^7have been turned ^5ON");
				iprintln("^9rpam_riflesonly 1");
			}
			else
			{
				iprintln("^3Rifles Only Mode ^7have been turned ^1OFF");
				iprintln("^9rpam_riflesonly 0");
			}
		}

		showcommand_sv_fps = getcvarfloat("sv_fps");
		if (showcommand_sv_fps != level.z_rpam_sv_fps)
		{
			level.z_rpam_sv_fps = showcommand_sv_fps;
			iprintln("^3SV_FPS ^7has been changed to ^5" + showcommand_sv_fps);
		}

		fog = getCvarInt("sv_fog");
		if (fog != level.fog)
		{
			level.fog = getCvarInt("sv_fog");
			if (level.fog == 1)
			{
				iprintln("^3SV_FOG has been turned ^2ON");
				iprintln("^3MAP_RESTART for changes to take effect");
			}
			else if (level.fog == 0)
			{
				iprintln("^3SV_FOG has been turned ^1OFF");
				iprintln("^3MAP_RESTART for changes to take effect");
			}
			else 
			{
				iprintln("^3SV_FOG must have a value of 1/0");
			}
		}

		showcommand_clientcvars = getcvarint("rpam_checkclientcvars");
		if (showcommand_clientcvars != level.z_rpam_checkclientcvars)
		{
			level.z_rpam_checkclientcvars = showcommand_clientcvars;
			if (showcommand_clientcvars == 1)
			{
				iprintln("^5Checking Client Cvars ^7has been turned ^5ON");
				iprintln("^9rpam_checkclientcvars 1");
			}
			else
			{
				iprintln("^3Checking Client Cvars ^7has been turned ^1OFF");
				iprintln("^9rpam_checkclientcvars 0");
			}
		}

		showcommand_ambientsounds = getcvarint("sv_ambientsounds");
		if (showcommand_ambientsounds != level.z_sv_ambientsounds)
		{
			level.z_sv_ambientsounds = showcommand_ambientsounds;
			if (showcommand_ambientsounds == 1 || showcommand_ambientsounds == 1.0)
			{
				iprintln("^3Ambient Sounds ^7has been turned ^2ON");
				iprintln("^9sv_ambientsounds 1, map/round restart required");
			}
			else if(showcommand_ambientsounds == 0)
			{
				iprintln("^5Ambient Sounds ^7has been turned ^1OFF");
				iprintln("^9sv_ambientsounds 0, map/round restart required");
			}
		}

		showcommand_demorecordinfo = getcvarint("rpam_demorecordinfo");
		if (showcommand_demorecordinfo != level.z_rpam_demorecordinfo)
		{
			level.z_rpam_demorecordinfo = showcommand_demorecordinfo;
			if (showcommand_demorecordinfo == 1)
			{
				iprintln("^5Demo Record Info ^7has been turned ^5ON");
				iprintln("^9rpam_demorecordinfo 1");
			}
			else
			{
				iprintln("^3Demo Record Info ^7has been turned ^1OFF");
				iprintln("^9rpam_demorecordinfo 0");
			}
		}

		showcommand_rdyupkilling = getcvarint("rpam_rdyupkilling");
		if (showcommand_rdyupkilling != level.z_rpam_rdyupkilling)
		{
			level.z_rpam_rdyupkilling = showcommand_rdyupkilling;
			if (showcommand_rdyupkilling == 1)
			{
				iprintln("^3Ready-Up Killing ^7has been turned ^5ON");
				iprintln("^9rpam_rdyupkilling 1");
			}
			else
			{
				iprintln("^5Ready-Up Killing ^7has been turned ^1OFF");
				iprintln("^9rpam_rdyupkilling 0");
			}
		}

		showcommand_blackout_spec = getcvarint("rpam_blackout_spec");
		if (showcommand_blackout_spec != level.z_rpam_blackout_spec)
		{
			level.z_rpam_blackout_spec = showcommand_blackout_spec;
			if (showcommand_blackout_spec == 1)
			{
				iprintln("^5Spectating as SPECTATOR ^7has been turned ^1OFF");
				iprintln("^9rpam_blackout_spec 1");
			}
			else
			{
				iprintln("^3Spectating as SPECTATOR ^7has been turned ^5ON");
				iprintln("^9rpam_blackout_spec 0");
			}
		}

		showcommand_blackout_player = getcvarint("rpam_blackout_player");
		if (showcommand_blackout_player != level.z_rpam_blackout_player)
		{
			level.z_rpam_blackout_player = showcommand_blackout_player;
			if (showcommand_blackout_player == 1)
			{
				iprintln("^5Spectating as PLAYER ^7has been turned ^1OFF");
				iprintln("^9rpam_blackout_player 1");
			}
			else
			{
				iprintln("^3Spectating as PLAYER ^7has been turned ^5ON");
				iprintln("^9rpam_blackout_player 0");
			}
		}

		showcommand_sv_specblackout = getcvarint("sv_specblackout");
		if (showcommand_sv_specblackout != level.z_rpam_sv_specblackout)
		{
			level.z_rpam_sv_specblackout = showcommand_sv_specblackout;
			if (showcommand_sv_specblackout == 1)
			{
				iprintln("^2Spectating as PLAYER & SPECTATOR ^7has been turned ^1OFF");
				iprintln("^9sv_specblackout 1");
			}
			else
			{
				iprintln("^3Spectating as PLAYER & SPECTATOR ^7has been turned ^5ON");
				iprintln("^9sv_specblackout 0");
			}
		}

		showcommand_rpam_strat = getcvarint("rpam_strat");
		if (showcommand_rpam_strat != level.z_rpam_strat)
		{
			level.z_rpam_strat = showcommand_rpam_strat;
			if (showcommand_rpam_strat == 1)
			{
				iprintln("^5rPAM's Strat Mode ^7has been turned ^5ON");
				iprintln("^9rpam_strat 1");
			}
			else
			{
				iprintln("^3rPAM's Strat Mode ^7has been turned ^1OFF");
				iprintln("^9rpam_strat 0");
			}
		}

		showcommand_pam_strat = getcvarint("scr_strat_time");
		if (showcommand_pam_strat != level.z_rpam_scr_strat_time)
		{
			level.z_rpam_scr_strat_time = showcommand_pam_strat;
			if (showcommand_pam_strat == 1)
			{
				iprintln("^2PAM's Strat Mode ^7has been turned ^5ON");
				iprintln("^9scr_strat_time 1");
			}
			else
			{
				iprintln("^3PAM's Strat Mode ^7has been turned ^1OFF");
				iprintln("^9scr_strat_time 0");
			}
		}

		if ( getcvar( "rpam_blackout_player" ) == "1" && getcvar( "rpam_blackout_spec" ) == "1" )
		{
			wait 0.25;

			setcvar("rpam_blackout_spec", "0");
			setcvar("rpam_blackout_player", "0");

			iprintln("^1rpam_blackout_player & rpam_blackout_spec ^7were set to ^11^7!");
			iprintln("^7Use sv_specblackout 1 ^7instead!");

			wait 0.15;
		}

		if ( getcvar( "rpam_blackout_player" ) == "1" && getcvar( "rpam_blackout_spec" ) == "0" )
		{
			wait 0.25;

			setcvar("rpam_blackout_player", "0");

			iprintln("^1rpam_blackout_player ^7is not available yet^5^7!");

			wait 0.25;
		}

		if ( getcvar( "scr_strat_time" ) == "1" && getcvar( "rpam_strat" ) == "1" )
		{
			wait 0.25;

			setcvar("scr_strat_time", "0");
			setcvar("rpam_strat", "1");

			iprintln("^1scr_strat_time & rpam_strat ^7were set to ^11^7!");
			iprintln("^5rPAM ^7is using ^5rpam_strat 1^7!");

			wait 0.25;
		}

		if ( getcvar( "sv_playersleft" ) == "1" && getcvar( "rpam_playersleft" ) == "1" )
		{
			wait 0.25;

			setcvar("sv_playersleft", "0");
			setcvar("rpam_playersleft", "1");

			iprintln("^1sv_playersleft & rpam_playersleft ^7were set to ^11^7!");
			iprintln("^5rPAM ^7is using ^5rpam_playersleft 1^7!");

			wait 0.25;
		}

		if ( getcvar( "scr_force_bolt_rifles" ) == "1" && getcvar( "rpam_riflesonly" ) == "1" )
		{
			wait 0.25;

			setcvar("scr_force_bolt_rifles", "0");
			setcvar("rpam_riflesonly", "1");

			iprintln("^1scr_force_bolt_rifles & rpam_riflesonly ^7were set to ^11^7!");
			iprintln("^5rPAM ^7is using ^5rpam_riflesonly 1^7!");

			wait 0.25;
		}

		showcommand_rpam_strat_time = getcvarint("rpam_strat_time");
		if (showcommand_rpam_strat_time != level.z_rpam_strat_time)
		{
			level.z_rpam_strat_time = showcommand_rpam_strat_time;
			if (showcommand_rpam_strat_time == "1" || showcommand_rpam_strat_time == "2" || showcommand_rpam_strat_time == "3")
			{
				setcvar("scr_sd_graceperiod", "3");
				iprintln("^5Strat Time ^7/^5 Grace Period ^7has been set to ^23");
				iprintln("^9rpam_strat_time 3");
			}
			else if (showcommand_rpam_strat_time == "4" || showcommand_rpam_strat_time == "5")
			{
				setcvar("scr_sd_graceperiod", "5");
				iprintln("^5Strat Time ^7/^5 Grace Period ^7has been set to ^25");
				iprintln("^9rpam_strat_time 5");
			}
			else if (showcommand_rpam_strat_time == "6" || showcommand_rpam_strat_time == "7" || showcommand_rpam_strat_time == "8")
			{
				setcvar("scr_sd_graceperiod", "8");
				iprintln("^5Strat Time ^7/^5 Grace Period ^7has been set to ^28");
				iprintln("^9rpam_strat_time 8");
			}
			else if (showcommand_rpam_strat_time == "9" || showcommand_rpam_strat_time == "10")
			{
				setcvar("scr_sd_graceperiod", "10");
				iprintln("^5Strat Time ^7/^5 Grace Period ^7has been set to ^210");
				iprintln("^9rpam_strat_time 10");
			}
			else if (showcommand_rpam_strat_time == "10" || showcommand_rpam_strat_time == "11" || showcommand_rpam_strat_time == "12" || showcommand_rpam_strat_time == "13" || showcommand_rpam_strat_time == "15")
			{
				setcvar("scr_sd_graceperiod", "15");
				iprintln("^5Strat Time ^7/^ 5Grace Period ^7has been set to ^215");
				iprintln("^9rpam_strat_time 15");
			}
			else if (showcommand_rpam_strat_time == "off")
			{
				iprintln("^9rpam_strat_time ^1off");
			}
			else
			{
				setcvar("scr_sd_graceperiod", "10");
				iprintln("^5Strat Time ^7/^5 Grace Period ^7has been set to ^2default");
				iprintln("^9rpam_strat_time 10");
			}
		}

		showcommand_rpam_playersleft = getcvarint("rpam_playersleft");
		if (showcommand_rpam_playersleft != level.z_rpam_playersleft)
		{
			level.z_rpam_playersleft = showcommand_rpam_playersleft;
			if (showcommand_rpam_playersleft == 1)
			{
				iprintln("^5rPAM's Players Left ^7has been turned ^5ON");
				iprintln("^9rpam_playersleft 1");
			}
			else
			{
				iprintln("^3rPAM's Players Left ^7has been turned ^1OFF");
				iprintln("^9rpam_playersleft 0");
			}
		}

		showcommand_pam_playersleft = getcvarint("sv_playersleft");
		if (showcommand_pam_playersleft != level.playersleft)
		{
			level.playersleft = showcommand_pam_playersleft;
			if (showcommand_pam_playersleft == 1)
			{
				iprintln("^2PAM's Players Left ^7has been turned ^5ON");
				iprintln("^9sv_playersleft 1");
			}
			else
			{
				iprintln("^3PAM's Players Left ^7has been turned ^1OFF");
				iprintln("^9pam_playersleft 0");
			}
		}

		showcommand_branding = getcvarint("rpam_branding");
		if (showcommand_branding != level.z_rpam_branding)
		{
			level.z_rpam_branding = showcommand_branding;
			if (showcommand_branding == 1)
			{
				iprintln("^3rPAM Branding ^7has been turned ^5ON");
				iprintln("^9rpam_branding 1");
			}
			else if (showcommand_branding == 0)
			{
				iprintln("^5rPAM Branding ^7has been turned ^1OFF");
				iprintln("^9rpam_branding 0");
			}
		}

		rpamstreaming = getcvarint("rpam_streaming");
		if (rpamstreaming != level.z_rpam_rpam_streaming)
		{
			level.z_rpam_rpam_streaming = rpamstreaming;
			if (rpamstreaming == 1)
			{
				iprintln("^3rPAM Streaming ^7has been turned ^5ON");
				iprintln("^9rpam_streaming 1");
			}
			else if (rpamstreaming == 0)
			{
				iprintln("^5rPAM Streaming ^7has been turned ^1OFF");
				iprintln("^9rpam_streaming 0");
			}
		}
		
		showcommand_sd_readyup_nadetraining = getCvarInt("scr_sd_readyup_nadetraining");
		if (showcommand_sd_readyup_nadetraining != level.scr_sd_readyup_nadetraining)
		{
			level.scr_sd_readyup_nadetraining = showcommand_sd_readyup_nadetraining;
			if (showcommand_sd_readyup_nadetraining == 1)
			{
				iprintln("^3scr_sd_readyup_nadetraining ^7has been turned ^5ON");
				iprintln("^9scr_sd_readyup_nadetraining 1");
				if (level.rdyup == 1) 
				{
					logprint("enabling nade_training thread via cvar change monitor\n");
					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						player = players[i];
						player thread _rPAM_rules\_rpam_nadetraining::nade_Training();
					}
				}
			}
			else if (showcommand_sd_readyup_nadetraining == 0)
			{
				iprintln("^5scr_sd_readyup_nadetraining ^7has been turned ^1OFF");
				iprintln("^9scr_sd_readyup_nadetraining 0");
				logprint("disabling nade_training thread via cvar change monitor\n");
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					player notify("end_Watch_Grenade_Throw");
				}
			}
		}
			
		/*
		showcommand_rpam_sd_round_report = getCvarInt("rpam_sd_round_report");
		if (showcommand_rpam_sd_round_report != level.rpam_sd_round_report)
		{
			level.rpam_sd_round_report = showcommand_rpam_sd_round_report;
			if (showcommand_rpam_sd_round_report == 1)
			{
				iprintln("^3rPAM rpam_sd_round_report ^7has been turned ^5ON");
				iprintln("^9rpam_sd_round_report 1");
			}
			else if (showcommand_rpam_sd_round_report == 0)
			{
				iprintln("^5rPAM rpam_sd_round_report ^7has been turned ^1OFF");
				iprintln("^9rpam_sd_round_report 0");
			}
		}
		*/
		
		wait 1;
	}
}

updateTeamStatus()
{
	wait 0;	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	resettimeout();

	rPLANTED = getcvarint("rpam_countdownclock");

	oldvalue["allies"] = level.exist["allies"];
	oldvalue["axis"] = level.exist["axis"];
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;
	
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
			level.exist[player.pers["team"]]++;
	}

	if(getcvar("sv_playersleft") == "1")
	{	
		// destroy old huds so they can be refreshed
		if(isdefined(level.alliesleft))
			level.alliesleft destroy();
		if(isdefined(level.axisleft))
			level.axisleft destroy();
		if(isdefined(level.alliesleftnum))
			level.alliesleftnum destroy();
		if(isdefined(level.axisleftnum))
			level.axisleftnum destroy();
	
		// display allies left axis left
		level.alliesleft = newHudElem();
		level.alliesleft.x = 380;
		level.alliesleft.y = 460;
		level.alliesleft.alignX = "left";
		level.alliesleft.alignY = "bottom";
		level.alliesleft.fontScale = .75;
		level.alliesleft.color = (1, 1, 1);
		level.alliesleft.alpha = 1;
		level.alliesleft setText(game["dspalliesleft"]);
		
		level.alliesleftnum = newHudElem();
		level.alliesleftnum.x = 450;
		level.alliesleftnum.y = 460;
		level.alliesleftnum.alignX = "left";
		level.alliesleftnum.alignY = "bottom";
		level.alliesleftnum.fontScale = .75;
		level.alliesleftnum.color = (1, 1, 1);
		level.alliesleftnum.alpha = 1;
		level.alliesleftnum setValue(level.exist["allies"]);
			
		level.axisleft = newHudElem();
		level.axisleft.x = 380;
		level.axisleft.y = 470;
		level.axisleft.alignX = "left";
		level.axisleft.alignY = "bottom";
		level.axisleft.fontScale = .75;
		level.axisleft.color = (1, 1, 1);
		level.axisleft.alpha = 1;
		level.axisleft setText(game["dspaxisleft"]);
		
		level.axisleftnum = newHudElem();
		level.axisleftnum.x = 450;
		level.axisleftnum.y = 470;
		level.axisleftnum.alignX = "left";
		level.axisleftnum.alignY = "bottom";
		level.axisleftnum.fontScale = .75;
		level.axisleftnum.color = (1, 1, 1);
		level.axisleftnum.alpha = 1;
		level.axisleftnum setValue(level.exist["axis"]);
	}

	if(getcvar("rpam_playersleft") == "1")
	{	
		// destroy old huds so they can be refreshed
		if(isdefined(level.alliesleft))
			level.alliesleft destroy();
		if(isdefined(level.axisleft))
			level.axisleft destroy();
		if(isdefined(level.alliesleftnum))
			level.alliesleftnum destroy();
		if(isdefined(level.axisleftnum))
			level.axisleftnum destroy();

		level.alliesleft = newHudElem();
		level.alliesleft.x = 380;
		level.alliesleft.y = 460;
		level.alliesleft.alignX = "left";
		level.alliesleft.alignY = "bottom";
		level.alliesleft.fontScale = .84;
		level.alliesleft.color = (1, 1, 1);
		level.alliesleft.alpha = 1;
		level.alliesleft setText(game["dspalliesleft"]);
		
		level.alliesleftnum = newHudElem();
		level.alliesleftnum.x = 450;
		level.alliesleftnum.y = 460;
		level.alliesleftnum.alignX = "left";
		level.alliesleftnum.alignY = "bottom";
		level.alliesleftnum.fontScale = .84;
		level.alliesleftnum.color = (0.282, 0.819, 0.800);
		level.alliesleftnum.alpha = 1;
		level.alliesleftnum setValue(level.exist["allies"]);
			
		level.axisleft = newHudElem();
		level.axisleft.x = 380;
		level.axisleft.y = 470;
		level.axisleft.alignX = "left";
		level.axisleft.alignY = "bottom";
		level.axisleft.fontScale = .84;
		level.axisleft.color = (1, 1, 1);
		level.axisleft.alpha = 1;
		level.axisleft setText(game["dspaxisleft"]);
		
		level.axisleftnum = newHudElem();
		level.axisleftnum.x = 450;
		level.axisleftnum.y = 470;
		level.axisleftnum.alignX = "left";
		level.axisleftnum.alignY = "bottom";
		level.axisleftnum.fontScale = .84;
		level.axisleftnum.color = (1.000, 0.647, 0.309);
		level.axisleftnum.alpha = 1;
		level.axisleftnum setValue(level.exist["axis"]);
	}

	if(getcvar("rpam_branding") == "1")
	{
		if(isdefined(level.rpam_branding))
			level.rpam_branding destroy();

		level.rpam_branding = newHudElem();
		level.rpam_branding.x = 210;
		level.rpam_branding.y = 463;
		level.rpam_branding.alignX = "center";
		level.rpam_branding.alignY = "middle";
		level.rpam_branding.fontScale = .85;
		level.rpam_branding.color = (1, 1, 1);
		level.rpam_branding setText(game["rpam_branding"]);
	}

	if(level.exist["allies"])
		level.didexist["allies"] = true;
	if(level.exist["axis"])
		level.didexist["axis"] = true;

	if(level.warmup || level.rdyup)
		return;

	if(level.roundended)
		return;

	if(oldvalue["allies"] && !level.exist["allies"] && oldvalue["axis"] && !level.exist["axis"])
	{
		if(!level.bombplanted)
		{
			announcement(&"SD_ROUNDDRAW");
			level thread endRound("draw");
			return;
		}

		if(game["attackers"] == "allies")
		{
			announcement(&"SD_ALLIEDMISSIONACCOMPLISHED");
			level thread endRound("allies");
			return;
		}

		announcement(&"SD_AXISMISSIONACCOMPLISHED");
		level thread endRound("axis");
		return;
	}

	if(oldvalue["allies"] && !level.exist["allies"])
	{
		// no bomb planted, axis win
		if(!level.bombplanted)
		{
			announcement(&"SD_ALLIESHAVEBEENELIMINATED");
			level thread endRound("axis");
			return;
		}

		if(game["attackers"] == "allies")
			return;
		
		// allies just died and axis have planted the bomb
		if(level.exist["axis"])
		{
			announcement(&"SD_ALLIESHAVEBEENELIMINATED");
			level thread endRound("axis");

			if (rPLANTED == 1)
			{
				level.clock destroy();
			}
			return;
		}

		announcement(&"SD_AXISMISSIONACCOMPLISHED");
		level thread endRound("axis");

		if (rPLANTED == 1)
		{
			level.clock destroy();
		}
		return;
	}
	
	if(oldvalue["axis"] && !level.exist["axis"])
	{
		// no bomb planted, allies win
		if(!level.bombplanted)
		{
			announcement(&"SD_AXISHAVEBEENELIMINATED");
			level thread endRound("allies");
			return;
 		}
 		
 		if(game["attackers"] == "axis")
			return;
		
		// axis just died and allies have planted the bomb
		if(level.exist["allies"])
		{
			announcement(&"SD_AXISHAVEBEENELIMINATED");
			level thread endRound("allies");

			if (rPLANTED == 1)
			{
				level.clock destroy();
			}

			return;
		}
		
		announcement(&"SD_ALLIEDMISSIONACCOMPLISHED");
		level thread endRound("allies");

		if (rPLANTED == 1)
		{
			level.clock destroy();
		}
		return;
	}	
}

bombzones()
{
	level.barsize = 288;
	//level.planttime = 5;			// seconds to plant a bomb
	//level.defusetime = 10;		// seconds to defuse a bomb

	bombtrigger = getent("bombtrigger", "targetname");
	bombtrigger maps\mp\_utility::triggerOff();

	bombzone_A = getent("bombzone_A", "targetname");
	bombzone_B = getent("bombzone_B", "targetname");
	bombzone_A thread bombzone_think(bombzone_B);
	bombzone_B thread bombzone_think(bombzone_A);

	wait 1;	// TEMP: without this one of the objective icon is the default. Carl says we're overflowing something.
	objective_add(0, "current", bombzone_A.origin, "gfx/hud/hud@objectiveA.tga");
	objective_add(1, "current", bombzone_B.origin, "gfx/hud/hud@objectiveB.tga");
}

bombzone_think(bombzone_other)
{
	level endon("round_ended");

	level.barincrement = (level.barsize / (20.0 * level.planttime));
	
	for(;;)
	{
		self waittill("trigger", other);

		if(isDefined(bombzone_other.planting))
		{
			if(isDefined(other.planticon))
				other.planticon destroy();

			continue;
		}
		
		if(isPlayer(other) && (other.pers["team"] == game["attackers"]) && other isOnGround()  && !level.warmup)
		{
			if(!isDefined(other.planticon))
			{
				other.planticon = newClientHudElem(other);				
				other.planticon.alignX = "center";
				other.planticon.alignY = "middle";
				other.planticon.x = 320;
				other.planticon.y = 345;
				other.planticon setShader("ui_mp/assets/hud@plantbomb.tga", 64, 64);			
			}
			
			while(other istouching(self) && isAlive(other) && other useButtonPressed())
			{
				other notify("kill_check_bombzone");
				
				self.planting = true;

				if(!isDefined(other.progressbackground))
				{
					other.progressbackground = newClientHudElem(other);				
					other.progressbackground.alignX = "center";
					other.progressbackground.alignY = "middle";
					other.progressbackground.x = 320;
					other.progressbackground.y = 385;
					other.progressbackground.alpha = 0.5;
				}
				other.progressbackground setShader("black", (level.barsize + 4), 12);		

				if(!isDefined(other.progressbar))
				{
					other.progressbar = newClientHudElem(other);				
					other.progressbar.alignX = "left";
					other.progressbar.alignY = "middle";
					other.progressbar.x = (320 - (level.barsize / 2.0));
					other.progressbar.y = 385;
				}
				other.progressbar setShader("white", 0, 8);
				other.progressbar scaleOverTime(level.planttime, level.barsize, 8);

				other playsound("MP_bomb_plant");
				other linkTo(self);
				other disableWeapon();

				self.progresstime = 0;
				while(isAlive(other) && other useButtonPressed() && (self.progresstime < level.planttime))
				{
					other disableWeapon();
					self.bombinteraction = true;
					self.progresstime += 0.05;
					wait 0.05;
				}
	
				if(isDefined(other.progressbackground))
					other.progressbackground destroy();
				if(isDefined(other.progressbar))
					other.progressbar destroy();

				if(self.progresstime >= level.planttime)
				{
					if(isDefined(other.planticon))
						other.planticon destroy();

					other enableWeapon();

					level.bombexploder = self.script_noteworthy;
					
					bombzone_A = getent("bombzone_A", "targetname");
					bombzone_B = getent("bombzone_B", "targetname");
					bombzone_A delete();
					bombzone_B delete();
					objective_delete(0);
					objective_delete(1);
	
					//plant = other maps\mp\_utility::getPlant();
					plant = other maps\mp\_util_mp_gmi::getPlantGMI(); // For UO
					
					level.bombmodel = spawn("script_model", plant.origin);
					level.bombmodel.angles = plant.angles;
					level.bombmodel setmodel("xmodel/mp_bomb1_defuse");
					level.bombmodel playSound("Explo_plant_no_tick");
					
					bombtrigger = getent("bombtrigger", "targetname");
					bombtrigger.origin = level.bombmodel.origin;

					objective_add(0, "current", bombtrigger.origin, "gfx/hud/hud@bombplanted.tga");
		
					level.bombplanted = true;
					level.bombtimerstart = gettime();
					
					lpselfnum = other getEntityNumber();
					lpselfguid = other getGuid();
					logPrint("A;" + lpselfguid + ";" + lpselfnum + ";" + game["attackers"] + ";" + other.name + ";" + "bomb_plant" + "\n");
					
					//announcement(&"SD_EXPLOSIVESPLANTED");
					thread HUD_Bomb_Planted();
										
					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
						players[i] playLocalSound("MP_announcer_bomb_planted");
					
					bombtrigger thread bomb_think();
					bombtrigger thread bomb_countdown();
					
					level notify("bomb_planted");
					level.clock destroy();

					rSHOWCOUNT = getcvarint("rpam_countdownclock");
					if (rSHOWCOUNT != 0)
					{
						level.clock = newHudElem();
						level.clock.x = 320;
						level.clock.y = 460;
						level.clock.alignX = "center";
						level.clock.alignY = "middle";
						level.clock.font = "bigfixed";
						level.clock.color = (1, 1, 0);
						level.clock setTimer(level.countdowntime * 1);
					}
					self.bombinteraction = false;
					
					return;	//TEMP, script should stop after the wait .05
				}
				else
				{
					other unlink();
					other enableWeapon();
					self.bombinteraction = false;
				}
				
				wait .05;
			}
			
			self.planting = undefined;
			other thread check_bombzone(self);
		}
	}
}


check_bombzone(trigger)
{
	self notify("kill_check_bombzone");
	self endon("kill_check_bombzone");
	level endon("round_ended");

	while(isDefined(trigger) && !isDefined(trigger.planting) && self istouching(trigger) && isAlive(self))
		wait 0.05;

	if(isDefined(self.planticon))
		self.planticon destroy();
}

bomb_countdown()
{
	self endon("bomb_defused");
	level endon("intermission");
	
	level.bombmodel playLoopSound("bomb_tick");		

	wait level.countdowntime;

	rENDCOUNT = getcvarint("rpam_countdownclock");
	if (rENDCOUNT != 0)
	{
		if(isdefined(level.clock))
		level.clock.color = (1, 0, 0);
		wait 1;
	}

	// bomb timer is up
	objective_delete(0);
	
	level.bombexploded = true;
	self notify("bomb_exploded");

	// trigger exploder if it exists
	if(isDefined(level.bombexploder))
		maps\mp\_utility::exploder(level.bombexploder);

	// explode bomb
	origin = self getorigin();
	range = 500;
	maxdamage = 2000;
	mindamage = 1000;
		
	self delete(); // delete the defuse trigger
	level.bombmodel stopLoopSound();
	level.bombmodel delete();

	playfx(level._effect["bombexplosion"], origin);
	radiusDamage(origin, range, maxdamage, mindamage);
	
	level thread endRound(game["attackers"]);
}


bomb_think()
{
	self endon("bomb_exploded");
	level.barincrement = (level.barsize / (20.0 * level.defusetime));

	thread Destroy_HUD_Planted();

	for(;;)
	{
		self waittill("trigger", other);
		
		// check for having been triggered by a valid player
		if(isPlayer(other) && (other.pers["team"] == game["defenders"]) && other isOnGround())
		{
			if(!isDefined(other.defuseicon))
			{
				other.defuseicon = newClientHudElem(other);				
				other.defuseicon.alignX = "center";
				other.defuseicon.alignY = "middle";
				other.defuseicon.x = 320;
				other.defuseicon.y = 345;
				other.defuseicon setShader("ui_mp/assets/hud@defusebomb.tga", 64, 64);			
			}
			
			while(other islookingat(self) && distance(other.origin, self.origin) < 64 && isAlive(other) && other useButtonPressed())
			{
				other notify("kill_check_bomb");

				if(!isDefined(other.progressbackground))
				{
					other.progressbackground = newClientHudElem(other);				
					other.progressbackground.alignX = "center";
					other.progressbackground.alignY = "middle";
					other.progressbackground.x = 320;
					other.progressbackground.y = 385;
					other.progressbackground.alpha = 0.5;
				}
				other.progressbackground setShader("black", (level.barsize + 4), 12);		

				if(!isDefined(other.progressbar))
				{
					other.progressbar = newClientHudElem(other);				
					other.progressbar.alignX = "left";
					other.progressbar.alignY = "middle";
					other.progressbar.x = (320 - (level.barsize / 2.0));
					other.progressbar.y = 385;
				}
				other.progressbar setShader("white", 0, 8);			
				other.progressbar scaleOverTime(level.defusetime, level.barsize, 8);

				other playsound("MP_bomb_defuse");
				other linkTo(self);
				other disableWeapon();

				self.progresstime = 0;
				while(isAlive(other) && other useButtonPressed() && (self.progresstime < level.defusetime))
				{
					other disableWeapon();
					self.bombinteraction = true;
					self.progresstime += 0.05;
					wait 0.05;
				}

				if(isDefined(other.progressbackground))
					other.progressbackground destroy();
				if(isDefined(other.progressbar))
					other.progressbar destroy();

				if(self.progresstime >= level.defusetime)
				{
					if(isDefined(other.defuseicon))
						other.defuseicon destroy();

					objective_delete(0);

					self notify("bomb_defused");
					level.bombmodel setmodel("xmodel/mp_bomb1");
					level.bombmodel stopLoopSound();

					rDEFUSED = getcvarint("rpam_countdownclock");
					if (rDEFUSED != 0)
					{
						if(isdefined(level.clock))
						level.clock destroy();
					}

					self delete();

					announcement(&"SD_EXPLOSIVESDEFUSED");
					
					lpselfnum = other getEntityNumber();
					lpselfguid = other getGuid();
					logPrint("A;" + lpselfguid + ";" + lpselfnum + ";" + game["defenders"] + ";" + other.name + ";" + "bomb_defuse" + "\n");
					
					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
						players[i] playLocalSound("MP_announcer_bomb_defused");

					level thread endRound(game["defenders"]);
					self.bombinteraction = false;
					return;	//TEMP, script should stop after the wait .05
				}
				else
				{
					other unlink();
					other enableWeapon();
					self.bombinteraction = false;
				}
				
				wait .05;
			}

			self.defusing = undefined;
			other thread check_bomb(self);
		}
	}
}

check_bomb(trigger)
{
	self notify("kill_check_bomb");
	self endon("kill_check_bomb");

	while(isDefined(trigger) && !isDefined(trigger.defusing) && distance(self.origin, trigger.origin) < 32 && self islookingat(trigger) && isAlive(self))
		wait 0.05;

	if(isDefined(self.defuseicon))
		self.defuseicon destroy();
}

printJoinedTeam(team)
{
	if(team == "allies")
		iprintln(&"MPSCRIPT_JOINED_ALLIES", self);
	else if(team == "axis")
		iprintln(&"MPSCRIPT_JOINED_AXIS", self);
}


addBotClients()
{
	// take this out for now
	return;

	game_menu_team = "team_" + game["allies"] + game["axis"];
	wait 5;
	
	for(;;)
	{
		if(getCvarInt("scr_numbots") > 0)
			break;
		wait 1;
	}
	iNumBots = getCvarInt("scr_numbots");
	for(i = 0; i < 6; i++)
	{
		ent[i] = addtestclient();
		wait 0.5;

		if(isPlayer(ent[i]))
		{
			if(i == 1 || i == 3 || i == 5 )
			{
				ent[i] notify("menuresponse", game_menu_team, "axis");
				wait 0.5;
				ent[i] notify("menuresponse", game["menu_weapon_axis"], "kar98k_mp");
				//ent[i].pers["team"] = "axis";
				//ent[i].pers["weapon"] = "kar98k_mp";
			}
			else
			{
				ent[i] notify("menuresponse", game_menu_team, "allies");
				wait 0.5;
				ent[i] notify("menuresponse", game["menu_weapon_allies"], "m1garand_mp");
				//ent[i].pers["team"] = "allies";
				//ent[i].pers["weapon"] = "springfield_mp";
			}
		}
	}
}

dropHealth()
{
	if ( !getcvarint("scr_drophealth") )
		return;
		
	if(isDefined(level.healthqueue[level.healthqueuecurrent]))
		level.healthqueue[level.healthqueuecurrent] delete();
	
	level.healthqueue[level.healthqueuecurrent] = spawn("item_health", self.origin + (0, 0, 1));
	level.healthqueue[level.healthqueuecurrent].angles = (0, randomint(360), 0);

	level.healthqueuecurrent++;
	
	if(level.healthqueuecurrent >= 16)
		level.healthqueuecurrent = 0;
}

GivePointsToTeam( team, points )
{
	players = getentarray("player", "classname");
	
	// count up the people in the flag area
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isAlive(player) && player.pers["team"] == team)
		{
			player.pers["score"] += points;
			player.score = player.pers["score"];
		}
	}
}

waitRespawnButton()
{
	self endon("end_respawn");
	self endon("respawn");
	
	wait 0; // Required or the "respawn" notify could happen before it's waittill has begun
/*
	level.pathlist = [];
	level.pathlist = getCvar("sv_referencedPaknames");
	self iprintln("^2Server PK3 Files:");
	self iprintln("^2" + level.pathlist);
*/
	self iprintlnbold(self.name + "^7 Hit Your Use Key to Ready Up");



		if(!isDefined(self.pers["pamsounds"]))
		{
			self.pers["pamsounds"] = 1;
		}
		if (self.pers["pamsounds"] == "1")

		{
		self playsound("readyup");
		}


	wait 2;
	
	while (!level.playersready)
	{
		wait .5;
		if(self useButtonPressed() == true)
		{ //if	
		
		for (index=0;index<level.readyname.size;index++)
		{
			if (level.readyname[index] == self.name)
			{

				if (level.readystate[index] == "notready")
				{
					level.readystate[index] = "ready";
					iprintlnbold(self.name + "^3 is Ready");
					logPrint(self.name + ";" + " is Ready Logfile;" + "\n");
					wait 1;
				}
				else
				{
					level.readystate[index] = "notready";
					iprintlnbold(self.name + "^1 is Not Ready");
					logPrint(self.name + ";" + " is Not Ready Logfile;" + "\n");
					wait 1;
				} // end notready if
			} // end name = name if
		}  // end for

		} //if
	} //while

	self notify("remove_respawntext");

	self notify("respawn");	
}

Create_HUD_Header()
{
	level.pamlogo = newHudElem();
	level.pamlogo.x = 575;
	level.pamlogo.y = 25; // 10;
	level.pamlogo.alignX = "center";
	level.pamlogo.alignY = "middle";
	level.pamlogo.fontScale = 1;
	level.pamlogo.color = (.8, 1, 1);
	level.pamlogo setText(game["pamstring"]);

	rPAMUOBETA = getcvar("rpam_uo_beta");
	if (rPAMUOBETA == "1")
	{
		level.rpamuobeta = newHudElem();
		level.rpamuobeta.x = 566;
		level.rpamuobeta.y = 35; // 35
		level.rpamuobeta.alignX = "left";
		level.rpamuobeta.alignY = "middle";
		level.rpamuobeta.fontScale = 0.55;
		level.rpamuobeta.color = (.8, 1, 1);
		level.rpamuobeta setText(game["rpam_uo_beta"]);
	}

	level.pammode = newHudElem();
	level.pammode.x = 10;
	level.pammode.y = 25;
	level.pammode.alignX = "left";
	level.pammode.alignY = "middle";
	level.pammode.fontScale = 1;
	level.pammode.color = (1, 1, 1);
	level.pammode setText(game["leaguestring"]);

	if(getcvarint("g_ot_active") > 0)
	{
		level.overtimemode = newHudElem();
		level.overtimemode.x = 10;
		level.overtimemode.y = 45;
		level.overtimemode.alignX = "left";
		level.overtimemode.alignY = "middle";
		level.overtimemode.fontScale = 1;
		level.overtimemode.color = (1, 1, 1);
		level.overtimemode setText(game["overtimemode"]);
	}
}

Destroy_HUD_Header()
{
	if(isdefined(level.pammode))
		level.pammode destroy();
	if(isdefined(level.site))
		level.site destroy();
	if(isdefined(level.pammodeestring))
		level.pammodeestring destroy();
	if(isdefined(level.pamlogo))
		level.pamlogo destroy();
	if(isdefined(level.rpam))
		level.rpam destroy();
	if(isdefined(level.pammodee))
		level.pammodee destroy();
	if(isdefined(level.overtimemode))
		level.overtimemode destroy();
}

Create_HUD_Scoreboard()
{
	if (getcvar("sv_scoreboard") == "pam_small")
	{
		// Display TEAMS
		level.team1 = newHudElem();
		level.team1.x = 200;
		level.team1.y = 120;
		level.team1.alignX = "center";
		level.team1.alignY = "middle";
		level.team1.fontScale = 1;
		level.team1.color = (1, 1, 1);
		level.team1 setText(game["dspteam1"]);

		level.team2 = newHudElem();
		level.team2.x = 440;
		level.team2.y = 120;
		level.team2.alignX = "center";
		level.team2.alignY = "middle";
		level.team2.fontScale = 1;
		level.team2.color = (1, 1, 1);
		level.team2 setText(game["dspteam2"]);

		// Match Score Display
		level.matchscore = newHudElem();
		level.matchscore.x = 320;
		level.matchscore.y = 135;
		level.matchscore.alignX = "center";
		level.matchscore.alignY = "middle";
		level.matchscore.fontScale = 1;
		level.matchscore.color = (1, 1, 1);
		level.matchscore setText(game["matchscore"]);

		level.matchaxisscorenum = newHudElem();
		if(game["halftimeflag"] == "1")
		{
			level.matchaxisscorenum.x = 440;
			level.matchaxisscorenum.color = (1, 1, 1);
		}
		else
		{
			level.matchaxisscorenum.x = 200;
			level.matchaxisscorenum.color = (1, 1, 1);
		}
		level.matchaxisscorenum.y = 135;
		level.matchaxisscorenum.alignX = "center";
		level.matchaxisscorenum.alignY = "middle";
		level.matchaxisscorenum.fontScale = 1;
		level.matchaxisscorenum setValue(game["axisscore"]);

		level.matchalliesscorenum = newHudElem();
		if(game["halftimeflag"] == "1")
		{
			level.matchalliesscorenum.x = 200;
			level.matchalliesscorenum.color = (1, 1, 1);
		}
		else
		{
			level.matchalliesscorenum.x = 440;
			level.matchalliesscorenum.color = (1, 1, 1);
		}
		level.matchalliesscorenum.y = 135;
		level.matchalliesscorenum.alignX = "center";
		level.matchalliesscorenum.alignY = "middle";
		level.matchalliesscorenum.fontScale = 1;
		level.matchalliesscorenum setValue(game["alliedscore"]);
	}

	else if (getcvar("sv_scoreboard") == "pam_big")
	{
		// First Half Score Display
		level.firhalfscore = newHudElem();
		level.firhalfscore.x = 320;
		level.firhalfscore.y = 230;
		level.firhalfscore.alignX = "center";
		level.firhalfscore.alignY = "middle";
		level.firhalfscore.fontScale = 1;
		level.firhalfscore.color = (1, 1, 1);
		level.firhalfscore setText(game["1sthalfscore"]);

		level.firhalfaxisscore = newHudElem();
		level.firhalfaxisscore.x = 200;
		level.firhalfaxisscore.y = 230;
		level.firhalfaxisscore.alignX = "center";
		level.firhalfaxisscore.alignY = "middle";
		level.firhalfaxisscore.fontScale = 1;
		level.firhalfaxisscore.color = (1, 1, 1);
		level.firhalfaxisscore setText(game["dspaxisscore"]);
			
		level.firhalfaxisscorenum = newHudElem();
		level.firhalfaxisscorenum.x = 200;
		level.firhalfaxisscorenum.y = 245;
		level.firhalfaxisscorenum.alignX = "center";
		level.firhalfaxisscorenum.alignY = "middle";
		level.firhalfaxisscorenum.fontScale = 1;
		level.firhalfaxisscorenum.color = (1, 1, 1);
		level.firhalfaxisscorenum setValue(game["round1axisscore"]);

		level.firhalfalliesscore = newHudElem();
		level.firhalfalliesscore.x = 440;
		level.firhalfalliesscore.y = 230;
		level.firhalfalliesscore.alignX = "center";
		level.firhalfalliesscore.alignY = "middle";
		level.firhalfalliesscore.fontScale = 1;
		level.firhalfalliesscore.color = (1, 1, 1);
		level.firhalfalliesscore setText(game["dspalliesscore"]);
			
		level.firhalfalliesscorenum = newHudElem();
		level.firhalfalliesscorenum.x = 440;
		level.firhalfalliesscorenum.y = 245;
		level.firhalfalliesscorenum.alignX = "center";
		level.firhalfalliesscorenum.alignY = "middle";
		level.firhalfalliesscorenum.fontScale = 1;
		level.firhalfalliesscorenum.color = (1, 1, 1);
		level.firhalfalliesscorenum setValue(game["round1alliesscore"]);

		// Second Half Score Display
		level.sechalfscore = newHudElem();
		level.sechalfscore.x = 320;
		level.sechalfscore.y = 275;
		level.sechalfscore.alignX = "center";
		level.sechalfscore.alignY = "middle";
		level.sechalfscore.fontScale = 1.1;
		level.sechalfscore.color = (1, 1, 1);
		level.sechalfscore setText(game["2ndhalfscore"]);
				
		level.sechalfaxisscore = newHudElem();
		level.sechalfaxisscore.x = 440;
		level.sechalfaxisscore.y = 275;
		level.sechalfaxisscore.alignX = "center";
		level.sechalfaxisscore.alignY = "middle";
		level.sechalfaxisscore.fontScale = 1;
		level.sechalfaxisscore.color = (1, 1, 1);
		level.sechalfaxisscore setText(game["dspaxisscore"]);
			
		level.sechalfaxisscorenum = newHudElem();
		level.sechalfaxisscorenum.x = 440;
		level.sechalfaxisscorenum.y = 290;
		level.sechalfaxisscorenum.alignX = "center";
		level.sechalfaxisscorenum.alignY = "middle";
		level.sechalfaxisscorenum.fontScale = 1;
		level.sechalfaxisscorenum.color = (1, 1, 1);
		level.sechalfaxisscorenum setValue(game["round2axisscore"]);

		level.sechalfalliesscore = newHudElem();
		level.sechalfalliesscore.x = 200;
		level.sechalfalliesscore.y = 275;
		level.sechalfalliesscore.alignX = "center";
		level.sechalfalliesscore.alignY = "middle";
		level.sechalfalliesscore.fontScale = 1;
		level.sechalfalliesscore.color = (1, 1, 1);
		level.sechalfalliesscore setText(game["dspalliesscore"]);
			
		level.sechalfalliesscorenum = newHudElem();
		level.sechalfalliesscorenum.x = 200;
		level.sechalfalliesscorenum.y = 290;
		level.sechalfalliesscorenum.alignX = "center";
		level.sechalfalliesscorenum.alignY = "middle";
		level.sechalfalliesscorenum.fontScale = 1;
		level.sechalfalliesscorenum.color = (1, 1, 1);
		level.sechalfalliesscorenum setValue(game["round2alliesscore"]);
			
		// Display TEAMS
		level.team1 = newHudElem();
		level.team1.x = 200;
		level.team1.y = 200;
		level.team1.alignX = "center";
		level.team1.alignY = "middle";
		level.team1.fontScale = 1;
		level.team1.color = (1, 1, 1);
		level.team1 setText(game["dspteam1"]);

		level.team2 = newHudElem();
		level.team2.x = 440;
		level.team2.y = 200;
		level.team2.alignX = "center";
		level.team2.alignY = "middle";
		level.team2.fontScale = 1;
		level.team2.color = (1, 1, 1);
		level.team2 setText(game["dspteam2"]);

		// Match Score Display
		level.matchscore = newHudElem();
		level.matchscore.x = 320;
		level.matchscore.y = 320;
		level.matchscore.alignX = "center";
		level.matchscore.alignY = "middle";
		level.matchscore.fontScale = 1;
		level.matchscore.color = (1, 1, 1);
		level.matchscore setText(game["matchscore"]);

		level.matchaxisscorenum = newHudElem();
		if(game["halftimeflag"] == "1")
		{
			level.matchaxisscorenum.x = 440;
			level.matchaxisscorenum.color = (1, 1, 1);
		}
		else
		{
			level.matchaxisscorenum.x = 200;
			level.matchaxisscorenum.color = (1, 1, 1);
		}
		level.matchaxisscorenum.y = 320;
		level.matchaxisscorenum.alignX = "center";
		level.matchaxisscorenum.alignY = "middle";
		level.matchaxisscorenum.fontScale = 1;
		level.matchaxisscorenum setValue(game["axisscore"]);

		level.matchalliesscorenum = newHudElem();
		if(game["halftimeflag"] == "1")
		{
			level.matchalliesscorenum.x = 200;
			level.matchalliesscorenum.color = (1, 1, 1);
		}
		else
		{
			level.matchalliesscorenum.x = 440;
			level.matchalliesscorenum.color = (1, 1, 1);
		}
		level.matchalliesscorenum.y = 320;
		level.matchalliesscorenum.alignX = "center";
		level.matchalliesscorenum.alignY = "middle";
		level.matchalliesscorenum.fontScale = 1;
		level.matchalliesscorenum setValue(game["alliedscore"]);
	}	

	else if (getcvar("sv_scoreboard") == "rpam")
	{
		// First Half Score Display
		level.firhalfscore = newHudElem();
		level.firhalfscore.x = 320;
		level.firhalfscore.y = 230;
		level.firhalfscore.alignX = "center";
		level.firhalfscore.alignY = "middle";
		level.firhalfscore.fontScale = 1;
		level.firhalfscore.color = (1, 1, 1);
		level.firhalfscore setText(game["1sthalfscore"]);

		level.firhalfaxisscore = newHudElem();
		level.firhalfaxisscore.x = 200;
		level.firhalfaxisscore.y = 230;
		level.firhalfaxisscore.alignX = "center";
		level.firhalfaxisscore.alignY = "middle";
		level.firhalfaxisscore.fontScale = 1;
		level.firhalfaxisscore.color = (1, 1, 1);
		level.firhalfaxisscore setText(game["dspaxisscore"]);
			
		level.firhalfaxisscorenum = newHudElem();
		level.firhalfaxisscorenum.x = 200;
		level.firhalfaxisscorenum.y = 245;
		level.firhalfaxisscorenum.alignX = "center";
		level.firhalfaxisscorenum.alignY = "middle";
		level.firhalfaxisscorenum.fontScale = 1;
		level.firhalfaxisscorenum.color = (1, 1, 1);
		level.firhalfaxisscorenum setValue(game["round1axisscore"]);

		level.firhalfalliesscore = newHudElem();
		level.firhalfalliesscore.x = 440;
		level.firhalfalliesscore.y = 230;
		level.firhalfalliesscore.alignX = "center";
		level.firhalfalliesscore.alignY = "middle";
		level.firhalfalliesscore.fontScale = 1;
		level.firhalfalliesscore.color = (1, 1, 1);
		level.firhalfalliesscore setText(game["dspalliesscore"]);
			
		level.firhalfalliesscorenum = newHudElem();
		level.firhalfalliesscorenum.x = 440;
		level.firhalfalliesscorenum.y = 245;
		level.firhalfalliesscorenum.alignX = "center";
		level.firhalfalliesscorenum.alignY = "middle";
		level.firhalfalliesscorenum.fontScale = 1;
		level.firhalfalliesscorenum.color = (1, 1, 1);
		level.firhalfalliesscorenum setValue(game["round1alliesscore"]);

		// Second Half Score Display
		level.sechalfscore = newHudElem();
		level.sechalfscore.x = 320;
		level.sechalfscore.y = 275;
		level.sechalfscore.alignX = "center";
		level.sechalfscore.alignY = "middle";
		level.sechalfscore.fontScale = 1.1;
		level.sechalfscore.color = (1, 1, 1);
		level.sechalfscore setText(game["2ndhalfscore"]);
				
		level.sechalfaxisscore = newHudElem();
		level.sechalfaxisscore.x = 440;
		level.sechalfaxisscore.y = 275;
		level.sechalfaxisscore.alignX = "center";
		level.sechalfaxisscore.alignY = "middle";
		level.sechalfaxisscore.fontScale = 1;
		level.sechalfaxisscore.color = (1, 1, 1);
		level.sechalfaxisscore setText(game["dspaxisscore"]);
			
		level.sechalfaxisscorenum = newHudElem();
		level.sechalfaxisscorenum.x = 440;
		level.sechalfaxisscorenum.y = 290;
		level.sechalfaxisscorenum.alignX = "center";
		level.sechalfaxisscorenum.alignY = "middle";
		level.sechalfaxisscorenum.fontScale = 1;
		level.sechalfaxisscorenum.color = (1, 1, 1);
		level.sechalfaxisscorenum setValue(game["round2axisscore"]);

		level.sechalfalliesscore = newHudElem();
		level.sechalfalliesscore.x = 200;
		level.sechalfalliesscore.y = 275;
		level.sechalfalliesscore.alignX = "center";
		level.sechalfalliesscore.alignY = "middle";
		level.sechalfalliesscore.fontScale = 1;
		level.sechalfalliesscore.color = (1, 1, 1);
		level.sechalfalliesscore setText(game["dspalliesscore"]);
			
		level.sechalfalliesscorenum = newHudElem();
		level.sechalfalliesscorenum.x = 200;
		level.sechalfalliesscorenum.y = 290;
		level.sechalfalliesscorenum.alignX = "center";
		level.sechalfalliesscorenum.alignY = "middle";
		level.sechalfalliesscorenum.fontScale = 1;
		level.sechalfalliesscorenum.color = (1, 1, 1);
		level.sechalfalliesscorenum setValue(game["round2alliesscore"]);
			
		// Display TEAMS
		level.team1 = newHudElem();
		level.team1.x = 200;
		level.team1.y = 120;
		level.team1.alignX = "center";
		level.team1.alignY = "middle";
		level.team1.fontScale = 1;
		level.team1.color = (1, 1, 1);
		level.team1 setText(game["dspteam1"]);

		level.team2 = newHudElem();
		level.team2.x = 440;
		level.team2.y = 120;
		level.team2.alignX = "center";
		level.team2.alignY = "middle";
		level.team2.fontScale = 1;
		level.team2.color = (1, 1, 1);
		level.team2 setText(game["dspteam2"]);

		// Match Score Display
		level.matchscore = newHudElem();
		level.matchscore.x = 320;
		level.matchscore.y = 135;
		level.matchscore.alignX = "center";
		level.matchscore.alignY = "middle";
		level.matchscore.fontScale = 1;
		level.matchscore.color = (1, 1, 1);
		level.matchscore setText(game["matchscore"]);

		level.matchaxisscorenum = newHudElem();
		if(game["halftimeflag"] == "1")
		{
			level.matchaxisscorenum.x = 440;
			level.matchaxisscorenum.color = (1, 1, 1);
		}
		else
		{
			level.matchaxisscorenum.x = 200;
			level.matchaxisscorenum.color = (1, 1, 1);
		}
		level.matchaxisscorenum.y = 135;
		level.matchaxisscorenum.alignX = "center";
		level.matchaxisscorenum.alignY = "middle";
		level.matchaxisscorenum.fontScale = 1;
		level.matchaxisscorenum setValue(game["axisscore"]);

		level.matchalliesscorenum = newHudElem();
		if(game["halftimeflag"] == "1")
		{
			level.matchalliesscorenum.x = 200;
			level.matchalliesscorenum.color = (1, 1, 1);
		}
		else
		{
			level.matchalliesscorenum.x = 440;
			level.matchalliesscorenum.color = (1, 1, 1);
		}
		level.matchalliesscorenum.y = 135;
		level.matchalliesscorenum.alignX = "center";
		level.matchalliesscorenum.alignY = "middle";
		level.matchalliesscorenum.fontScale = 1;
		level.matchalliesscorenum setValue(game["alliedscore"]);
	}

	else
	{
		// Set up Scorboard Vertical Positioning
		// CHANGE ONLY SCOREBOARDY
		scoreboardy = 197;
		teamsy = scoreboardy + 15;
		half1y = scoreboardy + 28;
		half2y = scoreboardy + 45;
		matchy = scoreboardy + 65;

		// Display TEAMS
		level.scorebd = newHudElem();
		level.scorebd.x = 575;
		level.scorebd.y = scoreboardy;
		level.scorebd.alignX = "center";
		level.scorebd.alignY = "middle";
		level.scorebd.fontScale = 1;
		level.scorebd.color = (.99, .99, .75);
		level.scorebd setText(game["scorebd"]);

		level.team1 = newHudElem();
		level.team1.x = 535;
		level.team1.y = teamsy;
		level.team1.alignX = "center";
		level.team1.alignY = "middle";
		level.team1.fontScale = .75;
		level.team1.color = (.73, .99, .73);
		level.team1 setText(game["dspteam1"]);

		level.team2 = newHudElem();
		level.team2.x = 615;
		level.team2.y = teamsy;
		level.team2.alignX = "center";
		level.team2.alignY = "middle";
		level.team2.fontScale = .75;
		level.team2.color = (.85, .99, .99);
		level.team2 setText(game["dspteam2"]);

		// First Half Score Display
		level.firhalfscore = newHudElem();
		level.firhalfscore.x = 575;
		level.firhalfscore.y = half1y;
		level.firhalfscore.alignX = "center";
		level.firhalfscore.alignY = "middle";
		level.firhalfscore.fontScale = .75;
		level.firhalfscore.color = (.99, .99, .75);
		level.firhalfscore setText(game["1sthalf"]);

		level.firhalfaxisscorenum = newHudElem();
		level.firhalfaxisscorenum.x = 532;
		level.firhalfaxisscorenum.y = half1y;
		level.firhalfaxisscorenum.alignX = "center";
		level.firhalfaxisscorenum.alignY = "middle";
		level.firhalfaxisscorenum.fontScale = .75;
		level.firhalfaxisscorenum.color = (.73, .99, .75);
		level.firhalfaxisscorenum setValue(game["round1axisscore"]);

		level.firhalfalliesscorenum = newHudElem();
		level.firhalfalliesscorenum.x = 618;
		level.firhalfalliesscorenum.y = half1y;
		level.firhalfalliesscorenum.alignX = "center";
		level.firhalfalliesscorenum.alignY = "middle";
		level.firhalfalliesscorenum.fontScale = .75;
		level.firhalfalliesscorenum.color = (.85, .99, .99);
		level.firhalfalliesscorenum setValue(game["round1alliesscore"]);

		// Second Half Score Display
		level.sechalfscore = newHudElem();
		level.sechalfscore.x = 575;
		level.sechalfscore.y = half2y;
		level.sechalfscore.alignX = "center";
		level.sechalfscore.alignY = "middle";
		level.sechalfscore.fontScale = .75;
		level.sechalfscore.color = (.99, .99, .75);
		level.sechalfscore setText(game["2ndhalf"]);
			
		level.sechalfaxisscorenum = newHudElem();
		level.sechalfaxisscorenum.x = 618;
		level.sechalfaxisscorenum.y = half2y;
		level.sechalfaxisscorenum.alignX = "center";
		level.sechalfaxisscorenum.alignY = "middle";
		level.sechalfaxisscorenum.fontScale = .75;
		level.sechalfaxisscorenum.color = (.85, .99, .99);
		level.sechalfaxisscorenum setValue(game["round2axisscore"]);

		level.sechalfalliesscorenum = newHudElem();
		level.sechalfalliesscorenum.x = 532;
		level.sechalfalliesscorenum.y = half2y;
		level.sechalfalliesscorenum.alignX = "center";
		level.sechalfalliesscorenum.alignY = "middle";
		level.sechalfalliesscorenum.fontScale = .75;
		level.sechalfalliesscorenum.color = (.73, .99, .75);
		level.sechalfalliesscorenum setValue(game["round2alliesscore"]);
			
		// Match Score Display
		level.matchscore = newHudElem();
		level.matchscore.x = 575;
		level.matchscore.y = matchy;
		level.matchscore.alignX = "center";
		level.matchscore.alignY = "middle";
		level.matchscore.fontScale = .8;
		level.matchscore.color = (.99, .99, .75);
		level.matchscore setText(game["matchscore2"]);

		level.matchaxisscorenum = newHudElem();
		if(game["halftimeflag"] == "1")
		{
			level.matchaxisscorenum.x = 618;
			level.matchaxisscorenum.color = (.85, .99, .99);
		}
		else
		{
			level.matchaxisscorenum.x = 532;
			level.matchaxisscorenum.color = (.73, .99, .75);
		}
		level.matchaxisscorenum.y = matchy;
		level.matchaxisscorenum.alignX = "center";
		level.matchaxisscorenum.alignY = "middle";
		level.matchaxisscorenum.fontScale = 1;
		level.matchaxisscorenum setValue(game["axisscore"]);

		level.matchalliesscorenum = newHudElem();
		if(game["halftimeflag"] == "1")
		{
			level.matchalliesscorenum.x = 535;
			level.matchalliesscorenum.color = (.73, .99, .75);
		}
		else
		{
			level.matchalliesscorenum.x = 618;
			level.matchalliesscorenum.color = (.85, .99, .99);
		}
		level.matchalliesscorenum.y = matchy;
		level.matchalliesscorenum.alignX = "center";
		level.matchalliesscorenum.alignY = "middle";
		level.matchalliesscorenum.fontScale = 1;
		level.matchalliesscorenum setValue(game["alliedscore"]);
	}
}

Destroy_HUD_Scoreboard()
{
	if(isdefined(level.scorebd))
		level.scorebd destroy();
	if(isdefined(level.team1))
		level.team1 destroy();
	if(isdefined(level.team2))
		level.team2 destroy();

	if(isdefined(level.firhalfscore))
		level.firhalfscore destroy();
	if(isdefined(level.firhalfaxisscore))
		level.firhalfaxisscore destroy();
	if(isdefined(level.firhalfalliesscore))
		level.firhalfalliesscore destroy();
	if(isdefined(level.firhalfaxisscorenum))
		level.firhalfaxisscorenum destroy();
	if(isdefined(level.firhalfalliesscorenum))
		level.firhalfalliesscorenum destroy();

	if(isdefined(level.sechalfscore))
		level.sechalfscore destroy();
	if(isdefined(level.sechalfaxisscore))
		level.sechalfaxisscore destroy();
	if(isdefined(level.sechalfalliesscore))
		level.sechalfalliesscore destroy();
	if(isdefined(level.sechalfaxisscorenum))
		level.sechalfaxisscorenum destroy();
	if(isdefined(level.sechalfalliesscorenum))
		level.sechalfalliesscorenum destroy();

	if(isdefined(level.matchscore))
		level.matchscore destroy();
	if(isdefined(level.matchaxisscorenum))
		level.matchaxisscorenum destroy();
	if(isdefined(level.matchalliesscorenum))
		level.matchalliesscorenum destroy();
}

Create_HUD_NextRound(time)
{
	if ( time < 3 )
		time = 3;

	level.round = newHudElem();
	level.round.x = 540;
	level.round.y = 295;
	level.round.alignX = "center";
	level.round.alignY = "middle";
	level.round.fontScale = 1;
	level.round.color = (1, 1, 0);
	level.round setText(game["round"]);		
		
	level.roundnum = newHudElem();
	level.roundnum.x = 540;
	level.roundnum.y = 315;
	level.roundnum.alignX = "center";
	level.roundnum.alignY = "middle";
	level.roundnum.fontScale = 1;
	level.roundnum.color = (1, 1, 0);
	round = game["roundsplayed"] +1;
	level.roundnum setValue(round);

	level.starting = newHudElem();
	level.starting.x = 540;
	level.starting.y = 335;
	level.starting.alignX = "center";
	level.starting.alignY = "middle";
	level.starting.fontScale = 1;
	level.starting.color = (1, 1, 0);
	level.starting setText(game["starting"]);

	// Give all players a count-down stopwatch
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		if ( isDefined(player.pers["team"]) && player.pers["team"] == "spectator")
			continue;
	}
	level thread rSTOPWATCHstart(time);

	wait (time);

	if(isdefined(level.round))
		level.round destroy();
	if(isdefined(level.roundnum))
		level.roundnum destroy();
	if(isdefined(level.starting))
		level.starting destroy();
}

Destroy_HUD_NextRound()
{
	if(isdefined(level.round))
		level.round destroy();
	if(isdefined(level.roundnum))
		level.roundnum destroy();
	if(isdefined(level.startingin))
		level.startingin destroy();
	if(isdefined(level.warmupclock))
		level.warmupclock destroy();
}

Create_HUD_TeamWin()
{
	if (getcvar("sv_scoreboard") == "pam_small" || getcvar("sv_scoreboard") == "pam_big" || getcvar("sv_scoreboard") == "rpam")
	{
		if (game["axisscore"] > game["alliedscore"])
		{
			level.teamwin = newHudElem();
			level.teamwin.x = 320;
			level.teamwin.y = 300;
			level.teamwin.alignX = "center";
			level.teamwin.alignY = "middle";
			level.teamwin.fontScale = 1;

			if (game["halftimeflag"] == 1)
			{
				level.teamwin.color = (1, 1, 1);
				level.teamwin setText(game["team2win"]);
			}
			else
			{
				level.teamwin.color = (1, 1, 1);
				level.teamwin setText(game["team1win"]);
			}
		}
		else if (game["axisscore"] < game["alliedscore"])
		{
			level.teamwin = newHudElem();
			level.teamwin.x = 320;
			level.teamwin.y = 300;
			level.teamwin.alignX = "center";
			level.teamwin.alignY = "middle";
			level.teamwin.fontScale = 1;
 
			if (game["halftimeflag"] == 1)
			{
				level.teamwin.color = (1, 1, 1);
				level.teamwin setText(game["team1win"]);
			}
			else
			{
				level.teamwin.color = (1, 1, 1);
				level.teamwin setText(game["team2win"]);
			}
		}
		else
		{
			level.teamwin = newHudElem();
			level.teamwin.x = 320;
			level.teamwin.y = 300;
			level.teamwin.alignX = "center";
			level.teamwin.alignY = "middle";
			level.teamwin.fontScale = 1;
			level.teamwin.color = (1, 1, 1);
			level.teamwin setText(game["dsptie"]);
		}
	}
	else
	{
		level.teamwin = newHudElem();
		level.teamwin.x = 575;
		level.teamwin.y = 155;
		level.teamwin.alignX = "center";
		level.teamwin.alignY = "middle";
		level.teamwin.fontScale = 1.1;

		if (game["axisscore"] == game["alliedscore"])
		{
			level.teamwin.color = (1, 1, 0);
			level.teamwin setText(game["dsptie"]);
		}
		else if (game["axisscore"] > game["alliedscore"] && game["halftimeflag"] == "1")
		{
			level.teamwin.color = (.85, .99, .99);
			level.teamwin setText(game["team2win"]);
		}
		else if (game["axisscore"] < game["alliedscore"] && game["halftimeflag"] == "0")
		{
			level.teamwin.color = (.85, .99, .99);
			level.teamwin setText(game["team2win"]);
		}
		else
		{
			level.teamwin.color = (.73, .99, .75);
			level.teamwin setText(game["team1win"]);
		}
	}
}

Destroy_HUD_TeamWin()
{
	if(isdefined(level.teamwin))
		level.teamwin destroy();
}

DropSecWeapon()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{ 

		//drop weapons and make spec
		player = players[i];
		//players[i].pers["weapon"] = undefined;
		players[i].pers["weapon1"] = undefined;
		//players[i].pers["weapon2"] = undefined;
		//players[i].pers["spawnweapon"] = undefined;
	}

	game["dropsecondweap"] = false;
}

_specToBlack( whyHere )
{
	level endon( "intermission" );

	self notify( "end_spectoblack" );
	self endon( "end_spectoblack" );
	self endon( "spawned" );

	if ( whyHere == "kick" )
	{
		self closeMenu();
		self setClientCvar( "g_scriptMainMenu", "main" );
	}

	if ( !isdefined( self.spec_black ) )
	{
		self.spec_black = newClientHudElem( self );
		self.spec_black.archived = false;
		self.spec_black.x = 0;
		self.spec_black.y = 0;
		self.spec_black.alpha = 1;
		self.spec_black.sort = 9990;	// Clock is set to 9999
		self.spec_black setShader( "black", 640, 480 );
	}

	if ( whyHere != "kick" )
	{
		self thread _removeSpecBlack();
		self thread _msgSpecBlack( "spawned" );
	}

	for (;;)
	{
		self.spectatorclient = self getEntityNumber();
		wait( 0.05 );	// Stay put until next round
	}
}

_msgSpecBlack( msg )
{
	self endon( "end_spectoblack" );
	self endon( "remove_specblack" );

	self waittill( msg );
	self notify( "remove_specblack" );
	return;
}

_removeSpecBlack()
{
	self endon( "end_spectoblack" );

	self waittill( "remove_specblack" );
	if ( isdefined( self.spec_black ) )
		self.spec_black destroy();
	if ( isdefined( self.spec_title ) )
		self.spec_title destroy();
	return;
}

Prepare_map_Tie()
{
	otcount = getcvarint("g_ot_active");
	otcount = otcount + 1;
	setcvar("g_ot_active", otcount);
}

Bash_Round()
{
	level.bashdamageonly = true;

	wait 3;

	// get rid of weapons
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{ 
		//drop weapons
		player = players[i];

		player setWeaponSlotAmmo("pistol", 999);
		player setWeaponSlotClipAmmo("pistol", 999);

		if (isdefined(player.pers["weapon"]))
			player dropItem(player.pers["weapon"]);
		if (isdefined(player.pers["weapon1"]))
			player dropItem(player.pers["weapon1"]);
		if (isdefined(player.pers["weapon2"]))
			player dropItem(player.pers["weapon2"]);

		if (player.pers["team"] == "allies")
		{
			switch(game["allies"])		
			{
			case "american":
				grenadetype = "fraggrenade_mp";
				break;

			case "british":
				grenadetype = "mk1britishfrag_mp";
				break;

			case "russian":
				grenadetype = "rgd-33russianfrag_mp";
				break;
			}
		}
		else if(player.pers["team"] == "axis")
		{
			switch(game["axis"])
			{
			case "german":
				grenadetype = "stielhandgranate_mp";
				break;
			}			
		}

		player dropItem(grenadetype);
	}

	Delete_Dropped_Weapons();
}

Delete_Dropped_Weapons()
{
	deletePlacedEntity("mpweapon_bar");
	deletePlacedEntity("mpweapon_bren");
	deletePlacedEntity("mpweapon_ppsh");
	deletePlacedEntity("mpweapon_mp44");
	
	deletePlacedEntity("mpweapon_fraggrenade");
	deletePlacedEntity("mpweapon_mk1britishfrag");
	deletePlacedEntity("mpweapon_russiangrenade");
	deletePlacedEntity("mpweapon_stielhandgranate");

	deletePlacedEntity("mpweapon_fg42");
	deletePlacedEntity("mpweapon_panzerfaust");
}

deletePlacedEntity(entity)
{
	entities = getentarray(entity, "classname");
	for(i = 0; i < entities.size; i++)
	{
		//println("DELETED: ", entities[i].classname);
		entities[i] delete();
	}
}

Do_Ready_Up()
{
	//Create_HUD_Header();
	maps\mp\gametypes\_pam_readyup::PAM_Ready_UP();

	if (game["halftimeflag"] == 0)
	{
		rSTRATplayersready1 = getcvarint("rpam_strat");
		if (rSTRATplayersready1 == 1)
		{
			rSTARTINGHALF("1");
			Create_HUD_Header();
		}
		else
		{
			Create_HUD_PlayersReady("1");
		}
	}
	else
	{
		rSTRATplayersready2 = getcvarint("rpam_strat");
		if (rSTRATplayersready2 == 1)
		{
			rSTARTINGHALF("2");
			Create_HUD_Header();
		}
		else
		{
			Create_HUD_PlayersReady("2");
		}
	}
	wait 5;

	Destroy_HUD_Header();

	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	if(isdefined(level.allready))
		level.allready destroy();
	if(isdefined(level.halfstart))
		level.halfstart destroy();
	//end readyup

	rDEMOINFOstartingclock = getcvarint("rpam_demorecordinfo");
	if (rDEMOINFOstartingclock == 1)
	{
		thread rDEMORECORDINFOtime();
	}

	//Starting Round 1 Clock
	time = getCvarInt("g_roundwarmuptime");
	
	if ( time < 1 )
		time = 1;

	// give all of the players clocks to count down until the half starts
	if (game["halftimeflag"] == 0)
		Create_HUD_RoundStart(1);
	else
		Create_HUD_RoundStart(2);

	setCvar("g_speed", "0");
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player.maxspeed = getCvar("g_speed");
		if ( isDefined(player.pers["team"]) && player.pers["team"] == "spectator")
			continue;
	} // def endmarker

	level thread rSTOPWATCHstart(time);

	if (rDEMOINFOstartingclock == 1)
	{
		thread rDEMORECORDINFO();
	}

	wait (time);

	Destroy_HUD_RoundStart();

	game["readyup"] = 0;

	game["DoReadyUp"] = false;
}

stopwatch_start(reason, time)
{
	if(isDefined(self.stopwatch))
		self.stopwatch destroy();
		
	self.stopwatch = newClientHudElem(self);
	maps\mp\gametypes\_pam_utilities::InitClock(self.stopwatch, time);
	self.stopwatch.archived = false;

	wait (time);

	if(isDefined(self.stopwatch)) 
		self.stopwatch destroy();
}

Create_HUD_PlayersReady(startinghalf)
{

	level.allready = newHudElem();
	level.allready.x = 320;
	level.allready.y = 390;
	level.allready.alignX = "center";
	level.allready.alignY = "middle";
	level.allready.fontScale = 1.5;
	level.allready.color = (0, 1, 0);
	level.allready setText(game["allready"]);

	if (startinghalf == "1")
	{
		level.halfstart = newHudElem();
		level.halfstart.x = 320;
		level.halfstart.y = 370;
		level.halfstart.alignX = "center";
		level.halfstart.alignY = "middle";
		level.halfstart.fontScale = 1.5;
		level.halfstart.color = (0, 1, 0);
		level.halfstart setText(game["start1sthalf"]);
	}
	else
	{
		level.halfstart = newHudElem();
		level.halfstart.x = 320;
		level.halfstart.y = 370;
		level.halfstart.alignX = "center";
		level.halfstart.alignY = "middle";
		level.halfstart.fontScale = 1.5;
		level.halfstart.color = (0, 1, 0);
		level.halfstart setText(game["start2ndhalf"]);
	}
}

Create_HUD_RoundStart(half)
{
	level.round = newHudElem();
	level.round.x = 540;
	level.round.y = 295;
	level.round.alignX = "center";
	level.round.alignY = "middle";
	level.round.fontScale = 1;
	level.round.color = (1, 1, 0);
	if (half == 1)
		level.round setText(game["first"]);	
	else
		level.round setText(game["second"]);	
		
	level.roundnum = newHudElem();
	level.roundnum.x = 540;
	level.roundnum.y = 315;
	level.roundnum.alignX = "center";
	level.roundnum.alignY = "middle";
	level.roundnum.fontScale = 1;
	level.roundnum.color = (1, 1, 0);
	level.roundnum setText(game["half"]);

	level.starting = newHudElem();
	level.starting.x = 540;
	level.starting.y = 335;
	level.starting.alignX = "center";
	level.starting.alignY = "middle";
	level.starting.fontScale = 1;
	level.starting.color = (1, 1, 0);
	level.starting setText(game["starting"]);
}

Destroy_HUD_RoundStart()
{
	if(isdefined(level.round))
		level.round destroy();
	if(isdefined(level.roundnum))
		level.roundnum destroy();
	if(isdefined(level.starting))
		level.starting destroy();
}

Do_Half_Time()
{
	level.hithalftime = 1;
	level.warmup = 1;

	//maps\mp\gametypes\_pam_teams::deletePlacedEntity("misc_mg42"); // Removes MGs during Warmup.


	// Play Halftime Sounds
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{ 
		player = players[i];
		if(!isDefined(player.pers["pamsounds"]))
			player.pers["pamsounds"] = 1;
		if (player.pers["pamsounds"] == "1")
			player playsound("halftime");
	}

	//display scores
	Create_HUD_Header();

	level.halftime = newHudElem();
	level.halftime.x = 575;
	level.halftime.y = 175;
	level.halftime.alignX = "center";
	level.halftime.alignY = "middle";
	level.halftime.fontScale = 1.5;
	level.halftime.color = (1, 1, 0);
	level.halftime setText(game["halftime"]);
	
	Create_HUD_Scoreboard();
	
	wait 1;

	Create_HUD_TeamSwap();

	/* Remove match countdown text */

	wait 7;
		
	Destroy_HUD_TeamSwap();

	game["halftimeflag"] = 1;

	//switch scores
	axistempscore = game["axisscore"];
	game["axisscore"] = game["alliedscore"];
	setTeamScore("axis", game["alliedscore"]);
	game["alliedscore"] = axistempscore;
	setTeamScore("allies", game["alliedscore"]);

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{ 
		player = players[i];

		// Switch Teams
		if ( (isdefined (player.pers["team"])) && (player.pers["team"] == "axis") )
		{
			player.pers["team"] = "allies";
			axissavedmodel = player.pers["savedmodel"];
		}
		else if ( (isdefined (player.pers["team"])) && (player.pers["team"] == "allies") )
		{
			player.pers["team"] = "axis";
			alliedsavedmodel = player.pers["savedmodel"];
		}

		//Swap Models
		if ( (isdefined(player.pers["team"]) ) && (player.pers["team"] == "axis") )
			 player.pers["savedmodel"] = axissavedmodel;
		else if ( (isdefined(player.pers["team"])) && (player.pers["team"] == "allies") )
			player.pers["savedmodel"] = alliedsavedmodel;

		//drop weapons and make spec
		player.pers["weapon"] = undefined;
		player.pers["weapon1"] = undefined;
		player.pers["weapon2"] = undefined;
		player.pers["spawnweapon"] = undefined;
		player.pers["selectedweapon"] = undefined;
		player.sessionstate = "spectator";
		player.spectatorclient = -1;
		player.archivetime = 0;
		player.reflectdamage = undefined;

		player unlink();
		player enableWeapon();

		//change headicons
		if(level.drawfriend)
		{
			if(player.pers["team"] == "allies")
			{
				player.headicon = game["headicon_allies"];
				player.headiconteam = "allies";
			}
			else
			{
				player.headicon = game["headicon_axis"];
				player.headiconteam = "axis";
			}
		}
		
		//Respawn with new weapons
		player thread Halftimespawn();

	}  // end for loop
	maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

	/* READY UP */
	if( game["mode"] == "match")
	{
		level.warmup = 0;

		Do_Ready_Up();

		level.warmup = 1;

		// get rid of warmup weapons
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{ 
			player = players[i];

			if (!isdefined(player.pers["selectedweapon"]) )
				player.pers["selectedweapon"] = undefined;
			player.pers["weapon1"] = undefined;
			player.pers["weapon2"] = undefined;
			player.pers["weapon"] = player.pers["selectedweapon"];
			player.pers["spawnweapon"] = player.pers["selectedweapon"];

			player unlink();
		} //end for
	}
	else
		wait 3;

	// WEAPON EXPLOIT FIX
	game["dropsecondweap"] = true;

	Destroy_HUD_Header();

	map_restart(true);

	return;
}

HalftimeSpawn()
{
	if (self.pers["team"] == "spectator")
		return;

	myteam = self.pers["team"];

	self closeMenu();

	if(isDefined(self.pers["weapon"]))
		spawnPlayer();
	else
	{
		//self.sessionteam = "spectator";

		spawnSpectator();
		maps\mp\gametypes\_pam_weaponlimits::CheckLimits();

		if(self.pers["team"] == "allies")
		{
			self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
			self openMenu(game["menu_weapon_allies"]);
		}
		else
		{
			self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
			self openMenu(game["menu_weapon_axis"]);
		}
	}

	while (!isdefined(self.pers["weapon"]) )
	{
		if(self.pers["team"] != myteam && self.pers["team"] != "spectator")
		{
			self.pers["team"] = myteam;
			if(self.pers["team"] == "allies")
				self openMenu(game["menu_weapon_allies"]);
			else
				self openMenu(game["menu_weapon_axis"]);
		}

		if (self.pers["team"] == "spectator")
			return;

		wait .1;
	}

	if (isdefined(self.pers["weapon"]) )
		spawnPlayer();
}

HUD_Bomb_Planted()
{
	level.hudplanted = newHudElem();

	rPLANTINFO = getcvarint("rpam_countdownclock");
	if (rPLANTINFO == 0)
	{
		level.hudplanted.x = 320;
		level.hudplanted.y = 460; //390
		level.hudplanted.alignX = "center";
		level.hudplanted.alignY = "middle";
		level.hudplanted.color = (1, 1, 0);
		level.hudplanted setText(game["planted"]);
		level.hudplanted.fontScale = 1;
	}

	else
	{
		level.hudplanted.x = 234;
		level.hudplanted.y = 464;
		level.hudplanted.alignX = "center";
		level.hudplanted.alignY = "middle";
		level.hudplanted.color = (1, 1, 0);
		level.hudplanted setText(game["rpam_planted"]);
		level.hudplanted.fontScale = .84;
	}
}

Destroy_HUD_Planted()
{
	wait 6;
	level.hudplanted destroy();
}

Create_HUD_TeamSwap()
{
	level.switching = newHudElem();
	level.switching.x = 575;
	level.switching.y = 280;
	level.switching.alignX = "center";
	level.switching.alignY = "middle";
	level.switching.fontScale = 1;
	level.switching.color = (1, 1, 0);
	level.switching setText(game["switching"]);

	level.switching2 = newHudElem();
	level.switching2.x = 575;
	level.switching2.y = 300;
	level.switching2.alignX = "center";
	level.switching2.alignY = "middle";
	level.switching2.fontScale = 1;
	level.switching2.color = (1, 1, 0);
	level.switching2 setText(game["switching2"]);
}

Destroy_HUD_TeamSwap()
{
	if(isdefined(level.switching))
		level.switching destroy();
	if(isdefined(level.switching2))
		level.switching2 destroy();
}

Create_HUD_Matchover()
{
	level.matchover = newHudElem();
	level.matchover.x = 575;
	level.matchover.y = 175;
	level.matchover.alignX = "center";
	level.matchover.alignY = "middle";
	level.matchover.fontScale = 1;
	level.matchover.color = (1, 1, 0);
	if(getcvarint("g_ot_active") > 0)
		level.matchover setText(game["overtime"]);
	else
		level.matchover setText(game["matchover"]);
}

Hold_All_Players()
{
	// Allow damage or death yet
	level.instrattime = true;

	wait .5;

	// Strat Time HUD
	level.strattime = newHudElem();
	level.strattime.x = 320;
	level.strattime.y = 440;
	level.strattime.alignX = "center";
	level.strattime.alignY = "middle";
	level.strattime.fontScale = 2;
	level.strattime.color = (0, 1, 0);
	level.strattime setText(game["strattime"]);

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player.maxspeed = 0;
	}

	while (!level.roundstarted)
	{
		wait .2;
	}

	if(isdefined(level.strattime))
		level.strattime destroy();

	level.instrattime = false;

	thread maps\mp\gametypes\_pam_teams::sayMoveIn();
	
	setCvar("g_speed", "190");

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{ 
		player = players[i];
		player.maxspeed = getCvar("g_speed");
	}
}

Monitor_Weapon_Drop()
{
	primary = self getWeaponSlotWeapon("primary");

	while (1)
	{
		timer = 0;
		primaryb = self getWeaponSlotWeapon("primaryb");
		current = self getcurrentweapon();

		while (self UseButtonPressed() && primaryb == current && !self.bombinteraction)
		{
			timer = timer + .2;

			if (timer > 1.6)
				self dropItem(self getcurrentweapon());

			wait .2;
			current = self getcurrentweapon();
		}

		wait .5;
	}
}

Do_Strat_Warning()
{
	level.pammode = newHudElem();
	level.pammode.x = 10;
	level.pammode.y = 10;
	level.pammode.alignX = "left";
	level.pammode.alignY = "middle";
	level.pammode.fontScale = 1;
	level.pammode.color = (1, 1, 0);
	level.pammode setText(game["leaguestring"]);
}

Automatic_Nade_Refills()
{
	// Allow Clipping
	setcvar("sv_cheats", "1");			// Cheats? Oh no!

	while (1)
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{ 
			player = players[i];
			player setWeaponSlotClipAmmo("grenade", 2);
		}

		wait 0.5;
	}
}