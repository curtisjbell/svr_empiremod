/*

_empire.gsc by Bell

http://www.empire_mod.com/
http://forums.empire_mod.com/

Version 2.1 (for Call of Duty and United Offensive)

	Credits:
	Mortars, hitblip, cvardef, firstaid,	- Ravir (http://demolition.codcity.org/)
	spawnmodel and admin tool functions.

	Bomber planes 					- Pharao_FS (http://www.pharao-fs.de.vu/)

	Parachutes, tracers, skyflashes code	- Parts (http://www.vs-uk.net/)
	laserdot and welcome message are based
	on Total War 2.3a

	Painscreen, bloodyscreen, bleeding,		- Chris P (http://www.mercilessmod.com)
	taunts, and the bleeding effect are based
	on Merciless Blood Mod.

	Mobile MG42 and mobile PTRS41 is based on	- RedMercury, Hellspawn
	RedMercury and Hellspawns mobileMG42 mod

	Drop Weapon on arm/hand hit is based on	- Poolmaster (http://ediv.codfiles.com)
	Merciless but propably origins from
	Poolmasters Realism Mod (PRM)

	Alternate position for team status		- Pethron

	Reflection formula in bounceObject()	- Hellspawn
	
	Searching for useable sounds in stock CoD	- Vicool

	Code to disable secondary weapon		- Zeus[BTY]

	Snow effect is loosely based on the one	- 
	used in the map FU-Flint

	Jeep respawn wait time, basehealth fix	- #7 (Number 7)

	Tank limiting					- [MW]gitman

	British taunts					- DirtyRat

	Enhanced parachuting and stuka sounds	- DetPak

	Conquest TDM gametype				- Innocent Bystander

	Map exploit fixes					- Innocent Bystander and all the people who report exploits

	Selectable UO weapons based on mod by	- Scrumby

	RSD fixes						- Groundpounder
	
	Cold breath is based on forums posts by	- Frenchy Daddy and [MW]gitman
	
	Map voting based on code by			- NC-17(codam, powerserver) (REWORKED BY wizard220, MODIFIED BY FrAnCkY55)

	Spanish fix for client and listen servers	- CEAL mod-team
	
	Some stock UO bug fixes				- Bits
	
	The rest						- Bell (http://www.empire_mod.com/)


	Problems
	--------
	
	Done
	----

	In the works
	------------

	Todo
	----

	
	Ideas (for later or never)
	--------------------------
	
*/

Callback_StartGameType()
{
	level.empire_uo = maps\mp\gametypes\_empire_uncommon::isUo();

	if(!isdefined(level.empire_uo))
		level.awe = true;

	// Check global empire_mod cvar
	level.empire_disable = cvardef("empire_disable",0,0,1,"int");
	if(level.empire_disable) return;

        // Set up variables
        maps\mp\gametypes\_empire_nextmap::UpdateMapHistory();
        maps\mp\gametypes\_empire_nextmap::UpdateGametypeHistory();
        setupVariables();

	// Find map limits
	findmapdimensions();

	// Find play area by checking all the spawnpoints
	findPlayArea();

	// Show empire_mod logo under compass
	showlogo();

	// Precache
	if(!isdefined(game["gamestarted"]))
		doPrecaching();

	// Warm up round
	warmupround();

	// Start threads
	thread startThreads();
}

startThreads()
{

	level notify("empire_boot");
	
	// Limit bases in Base Assault
	if(level.empire_limitbases && (getcvar("g_gametype") == "bas" || getcvar("g_gametype") == "mc_bas") )
		thread limitBases();

	// Wait for threads to die
	wait 0.05;

	// Override falldamage
//  setcvar("bg_fallDamageMaxHeight", 10*12);
//  setcvar("bg_fallDamageMinHeight", 14*12);

/*	if(level.empire_falldamage != 100)
	{
		setcvar("bg_fallDamageMinHeight", 256 * 100 / level.empire_falldamage);
		setcvar("bg_fallDamageMaxHeight", 480 * 100 / level.empire_falldamage);
	}*/

	// Override fog settings
	overridefog();

	// Start Ravirs admin tools
	thread maps\mp\gametypes\_user_Ravir_admin::main();

	// Update team status and global player array
	thread updateteamstatus();

	// Start mortar threads
	if(level.empire_mortar && !isdefined(level.empire_classbased))
		for(i = 0; i < level.empire_mortar; i++)
			thread incoming();
	
	// Stukas
	if(level.empire_stukas)
		thread stukas();
	
	// Bombers
      if(level.empire_bombers)
	{
		// Calculate start positions for C47 planes
		iX = (int)(level.empire_vMax[0] + level.empire_vMin[0])/2;
	
		if(level.empire_bombers_distance)
			iY = level.empire_bombers_distance;
		else
			iY = level.empire_vMin[1];	
	
		if(level.empire_bombers_altitude)
			iZ = level.empire_bombers_altitude;
		else
			iZ = level.empire_vMax[2];	
	
		// Loop effect
		maps\mp\_fx::loopfx("bombers", (iX - 500, iY, iZ), level.empire_bombers_delay);
		thread C47sounds( (iX - 500, iY, iZ), level.empire_bombers_delay);
		maps\mp\_fx::loopfx("bombers", (iX + 500, iY, iZ), level.empire_bombers_delay + 10);
		thread C47sounds( (iX + 500, iY, iZ), level.empire_bombers_delay + 10);

      }	
	
	//Ambient tracers
	if(level.empire_tracers)
		for(i = 0; i < level.empire_tracers; i++)
			thread tracers();
	
	// Ambient sky flashes
	if(level.empire_skyflashes)
		for(i = 0; i < level.empire_skyflashes; i++)
			thread skyflashes();

	// Fix corrupt maprotations
	if(level.empire_fixmaprotation && !level.empire_mapvote)
		fixMapRotation();

	// Do maprotation randomization
	thread randomMapRotation();

	// Announce next map and display server messages
	if(!level.empire_messageindividual)
		thread serverMessages();

	// Setup turrets
	thread turretStuff();

	// Rain/snow
	if(isdefined(level.empire_rainfx))
		thread rain();

	// Bots
	thread maps\mp\gametypes\_empire_bots::addBotClients();

	// Start thread that rotates map if server is empty
	if(level.empire_rotateifempty)
		thread rotateIfEmpty();

	if(level.empire_riflelimit || level.empire_boltriflelimit || level.empire_semiriflelimit || level.empire_smglimit || level.empire_assaultlimit || level.empire_sniperlimit || level.empire_lmglimit)
		thread checkLimitedWeapons();

	// Start thread for updating variables from cvars
	thread updateGametypeCvars(false);
}

setupVariables()
{
	// Override callbackPlayerDamage
	level.empire_orignalPlayerDamage = level.callbackPlayerDamage;		// Save old
	level.callbackPlayerDamage = ::Callback_PlayerDamage;			// Set new

	// defaults if not defined in level script
	if(!isDefined(game["allies"]))
		game["allies"] = "american";
	if(!isDefined(game["axis"]))
		game["axis"] = "german";

	level.empire_uomap = checkUOmaps();

	// Setup time counter
	if(!isdefined(game["empire_emptytime"]))
		game["empire_emptytime"] = 0;

	// Set up the number of available punishments
	level.empire_punishments = 3;

	// Set up object queues
	level.empire_objectQ["head"] = [];
	level.empire_objectQcurrent["head"] = 0;
	level.empire_objectQsize["head"] = 4;

	level.empire_objectQ["helmet"] = [];
	level.empire_objectQcurrent["helmet"] = 0;
	level.empire_objectQsize["helmet"] = 8;

	// Setup variables depending on gametypes
	switch(getCvar("g_gametype"))
	{
		case "dm":
			level.empire_spawnalliedname = "mp_deathmatch_spawn";
			level.empire_spawnaxisname = "mp_deathmatch_spawn";
			level.empire_spawnspectatorname = "mp_deathmatch_intermission";
			break;
		case "mc_dm":
			level.empire_merciless = true;
			level.empire_spawnalliedname = "mp_deathmatch_spawn";
			level.empire_spawnaxisname = "mp_deathmatch_spawn";
			level.empire_spawnspectatorname = "mp_deathmatch_intermission";
			break;

		case "re":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_spawnalliedname = "mp_retrieval_spawn_allied";
			level.empire_spawnaxisname = "mp_retrieval_spawn_axis";
			level.empire_spawnspectatorname = "mp_retrieval_intermission";
			break;
		case "mc_re":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_merciless = true;
			level.empire_spawnalliedname = "mp_retrieval_spawn_allied";
			level.empire_spawnaxisname = "mp_retrieval_spawn_axis";
			level.empire_spawnspectatorname = "mp_retrieval_intermission";
			break;

		case "dem":
		case "rsd":
		case "sd":
		case "lts":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.empire_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			level.empire_spawnspectatorname = "mp_searchanddestroy_intermission";
			break;
		case "mc_dem":
		case "mc_rsd":
		case "mc_sd":
		case "mc_lts":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_merciless = true;
			level.empire_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.empire_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			level.empire_spawnspectatorname = "mp_searchanddestroy_intermission";
			break;


		case "mc_tdom":
			level.empire_teamplay = true;
//			level.empire_roundbased = true;
			level.empire_merciless = true;
			level.empire_classbased = true;
			level.empire_tdom = true;
			level.empire_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.empire_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			level.empire_spawnspectatorname = "mp_searchanddestroy_intermission";
			break;

		case "ctf":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_alternatehud = true;
			level.empire_spawnalliedname = "mp_uo_spawn_allies";
			level.empire_spawnaxisname	= "mp_uo_spawn_axis";
			level.empire_spawnspectatorname = "mp_ctf_intermission";
			break;
		case "mc_ctf":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_alternatehud = true;
			level.empire_merciless = true;
			level.empire_spawnalliedname = "mp_uo_spawn_allies";
			level.empire_spawnaxisname	= "mp_uo_spawn_axis";
			level.empire_spawnspectatorname = "mp_ctf_intermission";
			break;

		case "ad":
		case "dom":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_alternatehud = true;
			level.empire_spawnalliedname = "mp_uo_spawn_allies";
			level.empire_spawnaxisname	= "mp_uo_spawn_axis";
			level.empire_spawnspectatorname = "mp_dom_intermission";
			break;
		case "mc_ad":
		case "mc_dom":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_alternatehud = true;
			level.empire_merciless = true;
			level.empire_spawnalliedname = "mp_uo_spawn_allies";
			level.empire_spawnaxisname	= "mp_uo_spawn_axis";
			level.empire_spawnspectatorname = "mp_dom_intermission";
			break;

		case "bas":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_alternatehud = true;
			level.empire_spawnalliedname = "mp_gmi_bas_allies_spawn";
			level.empire_spawnaxisname	= "mp_gmi_bas_axis_spawn";
			level.empire_spawnspectatorname = "mp_gmi_bas_intermission";
			break;
		case "mc_bas":
			level.empire_teamplay = true;
			level.empire_roundbased = true;
			level.empire_alternatehud = true;
			level.empire_merciless = true;
			level.empire_spawnalliedname = "mp_gmi_bas_allies_spawn";
			level.empire_spawnaxisname	= "mp_gmi_bas_axis_spawn";
			level.empire_spawnspectatorname = "mp_gmi_bas_intermission";
			break;

		case "cnq":
		case "tdm":
		case "bel":
		case "hq":
		case "actf":
			level.empire_teamplay = true;
			level.empire_spawnalliedname = "mp_teamdeathmatch_spawn";
			level.empire_spawnaxisname = "mp_teamdeathmatch_spawn";
			level.empire_spawnspectatorname = "mp_teamdeathmatch_intermission";
			break;
		case "mc_cnq":
		case "mc_tdm":
		case "mc_bel":
		case "mc_hq":
		case "mc_actf":
			level.empire_teamplay = true;
			level.empire_merciless = true;
			level.empire_spawnalliedname = "mp_teamdeathmatch_spawn";
			level.empire_spawnaxisname = "mp_teamdeathmatch_spawn";
			level.empire_spawnspectatorname = "mp_teamdeathmatch_intermission";
			break;

		default:
			level.empire_teamplay = true;
			level.empire_spawnalliedname = "mp_teamdeathmatch_spawn";
			level.empire_spawnaxisname = "mp_teamdeathmatch_spawn";
			level.empire_spawnspectatorname = "mp_teamdeathmatch_intermission";
			break;
	}

	// Set up number of voices
	level.empire_voices["german"] = 3;
	level.empire_voices["american"] = 7;
	level.empire_voices["russian"] = 4;
	level.empire_voices["british"] = 5;

	// Set up grenade voices
	level.empire_grenadevoices["german"][0]="german_grenade";
	level.empire_grenadevoices["german"][1]="generic_grenadeattack_german_1";
	if(!isdefined(level.empire_uo))
	{
		level.empire_grenadevoices["german"][2]="generic_grenadeattack_german_2";
		level.empire_grenadevoices["german"][3]="generic_grenadeattack_german_3";	
	}

	level.empire_grenadevoices["american"][0]="american_grenade";
	level.empire_grenadevoices["american"][1]="generic_grenadeattack_american_1";
	if(!isdefined(level.empire_uo))
	{
		level.empire_grenadevoices["american"][2]="generic_grenadeattack_american_2";
		level.empire_grenadevoices["american"][3]="generic_grenadeattack_american_3";
		level.empire_grenadevoices["american"][4]="generic_grenadeattack_american_4";
		level.empire_grenadevoices["american"][5]="generic_grenadeattack_american_5";
		level.empire_grenadevoices["american"][6]="generic_grenadeattack_american_6";	
	}

	level.empire_grenadevoices["russian"][0]="russian_grenade";
	level.empire_grenadevoices["russian"][1]="generic_grenadeattack_russian_3";
	if(!isdefined(level.empire_uo))
	{
		level.empire_grenadevoices["russian"][2]="generic_grenadeattack_russian_4";
		level.empire_grenadevoices["russian"][3]="generic_grenadeattack_russian_5";
		level.empire_grenadevoices["russian"][4]="generic_grenadeattack_russian_6";	
	}

	level.empire_grenadevoices["british"][0]="british_grenade";
	level.empire_grenadevoices["british"][1]="generic_grenadeattack_british_1";
	if(!isdefined(level.empire_uo))
	{
		level.empire_grenadevoices["british"][2]="generic_grenadeattack_british_2";
		level.empire_grenadevoices["british"][3]="generic_grenadeattack_british_4";
		level.empire_grenadevoices["british"][4]="generic_grenadeattack_british_5";
		level.empire_grenadevoices["british"][5]="generic_grenadeattack_british_6";	
	}

	// Reserve objective 6 to 15 for all gametypes but BEL and DEM
	if(getCvar("g_gametype") != "dem" && getCvar("g_gametype") != "mc_dem"  && getCvar("g_gametype") != "dom" && getCvar("g_gametype") != "mc_dom" && getCvar("g_gametype") != "bel" && getCvar("g_gametype") != "mc_bel")
		level.empire_objnum_min = 6;
	else							// Reserve only the last 5 objectives for BEL and DEM
		level.empire_objnum_min = 11;		// (requires modification of bel.gsc)
	level.empire_objnum_cur = level.empire_objnum_min;
	level.empire_objnum_max = 15;

	// Initialize variables from cvars
	updateGametypeCvars(true);	

	// Reset weapon limiting cvars
	level.empire_allplayers = getentarray("player", "classname");
	limitWeapons("allies");
	limitWeapons("axis");

	if(isdefined(level.empire_teamplay) && level.empire_firstaid)
		game["firstaid"] = "gfx/icons/hint_health.tga";

	if(isdefined(level.empire_teamplay))
	{
		level.empire_tripwires["axis"] = 0;
		level.empire_tripwires["allies"] = 0;
		level.empire_satchels["axis"] = 0;
		level.empire_satchels["allies"] = 0;
	}
	else
	{
		level.empire_tripwires = 0;
		level.empire_satchels = 0;
	}
		
	if(isdefined(game["german_soldiervariation"]) && game["german_soldiervariation"] == "winter")
		level.empire_wintermap = true;

	overrideteams();

	if(level.empire_spawnprotection)
		game["headicon_protect"] = "gfx/hud/hud@health_cross.tga";

	if( level.empire_anticamptime && !level.empire_anticampmethod && !isdefined(level.empire_tdom) )
	{
		game["headicon_star"]	= "gfx/hud/headicon@re_objcarrier.dds";
		if(!isdefined(level.empire_teamplay))
			game["headicon_crosshair"]="gfx/hud/hud@fire_ready.tga";
		game["objective_default"]="gfx/hud/objective.dds";
	}

	if( isdefined(level.empire_teamplay) && level.empire_anticamptime && !level.empire_anticampmethod && !isdefined(level.empire_tdom) )
	{
		// Precache radio objectives
		game["radio_axis"] = "gfx/hud/hud@objective_german.tga";
		game["headicon_axis"] = "gfx/hud/headicon@german.tga";

		switch(game["allies"])
		{
			case "american":
				game["radio_allies"] = "gfx/hud/hud@objective_american.tga";
				game["headicon_allies"] = "gfx/hud/headicon@american.tga";
				break;
	
			case "british":
				game["radio_allies"] = "gfx/hud/hud@objective_british.tga";
				game["headicon_allies"] = "gfx/hud/headicon@british.tga";
				break;
	
			case "russian":
				game["radio_allies"] = "gfx/hud/hud@objective_russian.tga";
				game["headicon_allies"] = "gfx/hud/headicon@russian.tga";
				break;
		}
	}

	if(isdefined(level.empire_teamplay) && level.empire_showteamstatus == 1)
	{
		game["radio_axis"] = "gfx/hud/hud@objective_german.tga";
		switch(game["allies"])
		{
			case "american":
				game["radio_allies"] = "gfx/hud/hud@objective_american.tga";
				break;
	
			case "british":
				game["radio_allies"] = "gfx/hud/hud@objective_british.tga";
				break;
	
			case "russian":
				game["radio_allies"] = "gfx/hud/hud@objective_russian.tga";
				break;
		}
	}

	if(isdefined(level.empire_teamplay) && level.empire_showteamstatus == 2)
	{
		game["headicon_axis"] = "gfx/hud/headicon@german.tga";
		switch(game["allies"])
		{
			case "american":
				game["headicon_allies"] = "gfx/hud/headicon@american.tga";
				break;
	
			case "british":
				game["headicon_allies"] = "gfx/hud/headicon@british.tga";
				break;
	
			case "russian":
				game["headicon_allies"] = "gfx/hud/headicon@russian.tga";
				break;
		}
	}

	// Setup mortars
	if(level.empire_mortar && !isdefined(level.empire_classbased))
	{
		level.empire_mortarmodel = "xmodel/105";

		level.empire_mortars = [];
		level.empire_mortars[level.empire_mortars.size]["incoming"] = "mortar_incoming2";
		level.empire_mortars[level.empire_mortars.size-1]["delay"] = 0.65;
		level.empire_mortars[level.empire_mortars.size]["incoming"] = "mortar_incoming1";
		level.empire_mortars[level.empire_mortars.size-1]["delay"] = 1.05;
		level.empire_mortars[level.empire_mortars.size]["incoming"] = "mortar_incoming3";
		level.empire_mortars[level.empire_mortars.size-1]["delay"] = 1.5;
		level.empire_mortars[level.empire_mortars.size]["incoming"] = "mortar_incoming4";
		level.empire_mortars[level.empire_mortars.size-1]["delay"] = 2.1;
		level.empire_mortars[level.empire_mortars.size]["incoming"] = "mortar_incoming5";
		level.empire_mortars[level.empire_mortars.size-1]["delay"] = 3.0;

		if(isdefined(level.empire_uo))
		{
			level.empire_mortarfx["generic"] = loadfx("fx/weapon/explosions/mortar_generic.efx");
//			level.empire_mortarfx["brick"]	= loadfx("fx/weapon/explosions/artillery_brick.efx");
//			level.empire_mortarfx["concrete"]= loadfx("fx/weapon/explosions/artillery_concrete.efx");
//			level.empire_mortarfx["dirt"]	= loadfx("fx/weapon/explosions/artillery_dirt.efx");
//			level.empire_mortarfx["grass"]	= loadfx("fx/weapon/explosions/artillery_grass.efx");
//			level.empire_mortarfx["gravel"]	= loadfx("fx/weapon/explosions/artillery_gravel.efx");
//			level.empire_mortarfx["metal"]	= loadfx("fx/weapon/explosions/artillery_metal.efx");
			level.empire_mortarfx["snow"]	= loadfx("fx/weapon/explosions/artillery_snow.efx");
			level.empire_mortarfx["water"]	= loadfx("fx/weapon/explosions/artillery_water.efx");
//			level.empire_mortarfx["wood"]	= loadfx("fx/weapon/explosions/artillery_wood.efx");
		}
		else
		{
			level.empire_mortarfx["generic"] = loadfx("fx/impacts/dirthit_mortar.efx");
//			level.empire_mortarfx["snow"]	= loadfx("fx/surfacehits/mortarimpact_snow.efx");
			level.empire_mortarfx["snow"]	= loadfx("fx/impacts/snow_mortar.efx");
			level.empire_mortarfx["water"]	= loadfx("fx/surfacehits/mortarhit_water.efx");
		}
	}
	// C47 planes
      if(level.empire_bombers)
		level._effect["bombers"] 	= loadfx ("fx/atmosphere/c47flyover2d.efx");
	
	// Load effect for bomb explosion (used by anticamp, antiteamkill, antiteamdamage and grenade cooking)
//	level.empire_effect["bombexplosion"]= loadfx("fx/explosions/pathfinder_explosion.efx");
	if(isdefined(level.empire_uo))
		level.empire_effect["bombexplosion"]= loadfx("fx/weapon/explosions/grenade_generic.efx");
	else
	{
		if(isdefined(level.empire_wintermap))
			level.empire_effect["bombexplosion"]= loadfx("fx/explosions/grenade_snow.efx");
		else
			level.empire_effect["bombexplosion"]= loadfx("fx/explosions/grenade3.efx");
	}

	//Ambient tracers
	if(level.empire_tracers)
		level._effect["empire_tracers"] = loadfx("fx/atmosphere/antiair_tracers.efx");
	
	// Ambient sky flashes
	if(level.empire_skyflashes)
	{
		level.empire_skyeffects = [];
		level.empire_skyeffects[level.empire_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/cloudflash1.efx");
		level.empire_skyeffects[level.empire_skyeffects.size-1]["delay"]	= 0.0;
		level.empire_skyeffects[level.empire_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/longrangeflash_altocloud.efx");
		level.empire_skyeffects[level.empire_skyeffects.size-1]["delay"]	= 0.0;
		level.empire_skyeffects[level.empire_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/antiair_tracerscloseup.efx");
		level.empire_skyeffects[level.empire_skyeffects.size-1]["delay"]	= 6.5;
		level.empire_skyeffects[level.empire_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/thunderhead.efx");
		level.empire_skyeffects[level.empire_skyeffects.size-1]["delay"]	= 0;
		level.empire_skyeffects[level.empire_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/lowlevelburst.efx");
		level.empire_skyeffects[level.empire_skyeffects.size-1]["delay"]	= 0;
	}

	// Effect for burning & no bodies
	if(isdefined(level.empire_uo) && (level.empire_burningbodies || level.empire_nobodies == 2))
	{
		level.empire_burningbodies_smokefx = loadfx("fx/smoke/smoke_flamethrower.efx");
	}

	// Effect for no bodies
	if(!isdefined(level.empire_uo) && level.empire_nobodies == 2)
	{
		level.empire_burningbodies_smokefx = loadfx("fx/impacts/newimps/v_blast1.efx");
	}

	// Effect for burning bodies
	if(isdefined(level.empire_uo) && level.empire_burningbodies)
	{
		level.empire_burningbodies_burnfx = loadfx("fx/fire/barreloil_fire.efx");
	}

	// Flesh hit effect used by bouncing heads
	if(level.empire_pophead && !isdefined(level.empire_merciless))
		level.empire_popheadfx = loadfx("fx/impacts/flesh_hit.efx");

	if(level.empire_bleeding && !isdefined(level.empire_merciless))
		level.empire_bleedingfx = loadfx("fx/atmosphere/drop1.efx");

	if(isdefined(level.empire_wintermap) && randomInt(100)<level.empire_snow )
		level.empire_rainfx = loadfx("fx/atmosphere/rainstorm.efx");

	if(!isdefined(level.empire_wintermap) && randomInt(100)<level.empire_rain)
		level.empire_rainfx = loadfx("fx/atmosphere/chateau_rain.efx");

	if(level.empire_turretmobile)
	{
		level.empire_turretpickupmessage	= &"^7Hold MELEE [{+melee}] to pick up";
		level.empire_turretplacemessage	= &"^7Hold MELEE [{+melee}] to place";
		if(level.empire_turretpicktime)
			level.empire_turretpickingmessage= &"^7Picking up...";
		if(level.empire_turretplanttime)
			level.empire_turretplacingmessage= &"^7Placing...";
	}

	if(level.empire_tripwire)
	{
//		level.empire_tripwireplacemessage = &"^7Hold MELEE [{+melee}] to place tripwire";
//		level.empire_tripwirepickupmessage= &"^7Hold MELEE [{+melee}] to defuse tripwire";
		level.empire_tripwirepickupmessage	= &"^7Hold MELEE [{+melee}] to pick up";
		level.empire_tripwireplacemessage	= &"^7Hold MELEE [{+melee}] to place";
		if(level.empire_tripwirepicktime)
			level.empire_turretpickingmessage= &"^7Picking up...";
		if(level.empire_tripwireplanttime)
			level.empire_turretplacingmessage= &"^7Placing...";
	}

	if(level.empire_satchel)
	{
//		level.empire_satchelplacemessage = &"^7Hold MELEE [{+melee}] to place satchel";
//		level.empire_satchelpickupmessage= &"^7Hold MELEE [{+melee}] to defuse satchel";
		level.empire_satchelpickupmessage= &"^7Hold MELEE [{+melee}] to pick up";
		level.empire_satchelplacemessage	= &"^7Hold MELEE [{+melee}] to place";
		if(level.empire_satchelpicktime)
			level.empire_turretpickingmessage= &"^7Picking up...";
		if(level.empire_satchelplanttime)
			level.empire_turretplacingmessage= &"^7Placing...";
	}

	if(level.empire_searchablebodies)
	{
		level.empire_bodysearchmessage = &"^7Hold MELEE [{+melee}] to search body";
		level.empire_bodysearchingmessage= &"^7Searching...";
	}

	if(
		level.empire_secondaryweapon["default"] == "select"	|| level.empire_secondaryweapon["default"] == "selectother"	||
		level.empire_secondaryweapon["american"] == "select"	|| level.empire_secondaryweapon["american"] == "selectother"	||
		level.empire_secondaryweapon["british"] == "select"	|| level.empire_secondaryweapon["british"] == "selectother"	||
		level.empire_secondaryweapon["german"] == "select"		|| level.empire_secondaryweapon["german"] == "selectother"	||
		level.empire_secondaryweapon["russian"] == "select"	|| level.empire_secondaryweapon["russian"] == "selectother"
	  )
	{
		level.empire_secondaryweapontext = &"Select your secondary weapon";
	}

	if(level.empire_mapvote)
	{
		level.mapvotetext["MapVote"]	= &"Press ^2FIRE^7 to vote                           Votes";
//		level.mapvotetext["Votes"]	= &"Votes";
		level.mapvotetext["TimeLeft"] = &"Time Left: ";
		level.mapvotetext["MapVoteHeader"] = &"Next Map Selection";
//		game["objective_default"]="gfx/hud/objective.dds";
	}

	// Load breath fx
	if(isdefined(level.empire_uo) && isdefined(level.empire_wintermap) && level.empire_coldbreath)
		level.empire_breathfx = loadfx ("fx/atmosphere/cold_breath.efx");

	// Disable minefields?
	if(level.empire_disableminefields)
	{
		minefields = getentarray( "minefield", "targetname" );
		if(minefields.size)
			for(i=0;i< minefields.size;i++)
				if(isdefined(minefields[i]))
					minefields[i] delete();
	}

	if(isdefined(level.empire_merciless))
	{
		level.empire_logotext = &"^1Merciless ^5/ ^6empire_mod ^52.1";
	}
	else
	{
		level.empire_logotext = &"^6empire_mod ^52.1";
	}

	if(level.empire_showserverlogo)
		server_logo\_empire_server_logo::logo();
}

awePrecacheShader(shader)
{
	if(!isdefined(level.empire_precachedshaders))
		level.empire_precachedshaders = [];

	if(isInArray(level.empire_precachedshaders, shader)) return;
	level.empire_precachedshaders[level.empire_precachedshaders.size] = shader;
	precacheShader(shader);
}

awePrecacheHeadIcon(icon)
{
	if(!isdefined(level.empire_precachedheadicons))
		level.empire_precachedheadicons = [];

	if(isInArray(level.empire_precachedheadicons, icon)) return;
	level.empire_precachedheadicons[level.empire_precachedheadicons.size] = icon;
	precacheHeadIcon(icon);
}

awePrecacheModel(model)
{
	if(!isdefined(level.empire_precachedmodels))
		level.empire_precachedmodels = [];

	if(isInArray(level.empire_precachedmodels, model)) return;
	level.empire_precachedmodels[level.empire_precachedmodels.size] = model;
	precacheModel(model);
}

awePrecacheItem(item)
{
	if(!isdefined(level.empire_precacheditems))
		level.empire_precacheditems = [];

	if(isInArray(level.empire_precacheditems, item)) return;
	level.empire_precacheditems[level.empire_precacheditems.size] = item;
	precacheItem(item);
}

awePrecacheString(element)
{
	if(!isdefined(level.empire_precachedstrings))
		level.empire_precachedstrings = [];

	if(isInArray(level.empire_precachedstrings, element)) return;
	level.empire_precachedstrings[level.empire_precachedstrings.size] = element;
	precacheString(element);
}

isInArray(array, element)
{
	if(!isdefined(array) || !array.size)
		return false;

	for(i=0;i<array.size;i++)
	{
		if(array[i] == element)
			return true;
	}

	return false;
}

doPrecaching()
{
	if(level.empire_debug)
	{
		awePrecacheModel("xmodel/vehicle_plane_stuka");
		awePrecacheModel("xmodel/cow_standing");
	}

	if(isdefined(level.empire_teamplay) && level.empire_firstaid)
		precacheShader(game["firstaid"]);

	if(level.empire_sprint && level.empire_sprinthud == 1)
	{
		awePrecacheShader("gfx/hud/hud@health_back.dds");
		awePrecacheShader("gfx/hud/hud@health_bar.dds");
	}

	if(level.empire_sprint && level.empire_sprinthud == 2)
	{
		awePrecacheShader("white");
	}

	if(level.empire_sprint && level.empire_sprinthudhint)
	{
		awePrecacheString(&"^7Hold USE [{+activate}] to sprint");
	}

	if(!isdefined(level.empire_uo))
		precacheShellshock("default");

	if(level.empire_deathshock)
		precacheShellshock("death");

	if(level.empire_laserdot)
		awePrecacheShader("white");

	// Precache stukas
	if(level.empire_stukas)
		awePrecacheModel("xmodel/vehicle_plane_stuka");
	if(level.empire_stukascrash)
		awePrecacheModel("xmodel/vehicle_plane_stuka_d");

	if(level.empire_mortar && !isdefined(level.empire_classbased) )
		awePrecacheModel(level.empire_mortarmodel);

	if(level.empire_turretmobile)
	{
		awePrecacheString( level.empire_turretpickupmessage );
		awePrecacheString( level.empire_turretplacemessage );
		if(level.empire_turretpicktime)
			awePrecacheString( level.empire_turretpickingmessage );
		if(level.empire_turretplanttime)
			awePrecacheString( level.empire_turretplacingmessage );
	}

	if(!isdefined(level.empire_uo) && level.empire_showcooking)
	{
		// Precache shaders for progressbar
		awePrecacheString(&"Cooking grenade");
		awePrecacheShader("white");
	}	

	if(level.empire_mapvote)
	{
		//shader used as icon for selection
//		awePrecacheShader(game["objective_default"]);	
		awePrecacheString(level.mapvotetext["MapVote"]);
//		awePrecacheString(level.mapvotetext["Votes"]);
		awePrecacheString(level.mapvotetext["TimeLeft"]);
		awePrecacheString(level.mapvotetext["MapVoteHeader"]);
		awePrecacheShader("white");
	}

	if(level.empire_tripwire)
	{
		awePrecacheString( level.empire_tripwirepickupmessage );
		awePrecacheString( level.empire_tripwireplacemessage );
		if(level.empire_tripwirepicktime)
			awePrecacheString( level.empire_turretpickingmessage );
		if(level.empire_tripwireplanttime)
			awePrecacheString( level.empire_turretplacingmessage );

		switch(game["allies"])
		{
			case "american":
				awePrecacheShader("gfx/hud/hud@death_us_grenade.tga");
				break;

			case "british":
				awePrecacheShader("gfx/hud/hud@death_british_grenade.tga");
				break;

			case "russian":
				awePrecacheShader("gfx/hud/hud@death_russian_grenade.tga");
				break;
		}
		awePrecacheShader("gfx/hud/hud@death_steilhandgrenate.tga");
	}

	if(level.empire_satchel)
	{
		awePrecacheString( level.empire_satchelpickupmessage );
		awePrecacheString( level.empire_satchelplacemessage );
		if(level.empire_satchelpicktime)
			awePrecacheString( level.empire_turretpickingmessage );
		if(level.empire_satchelplanttime)
			awePrecacheString( level.empire_turretplacingmessage );
		awePrecacheShader("gfx/icons/hud@satchel.dds");
	}

	if(level.empire_searchablebodies)
	{
		awePrecacheString(level.empire_bodysearchmessage);
		awePrecacheString(level.empire_bodysearchingmessage);
		awePrecacheShader("white");
	}

	if(level.empire_turretmobile && (level.empire_turretplanttime || level.empire_turretpicktime))
		awePrecacheShader("white");

	if(level.empire_tripwire && (level.empire_tripwireplanttime || level.empire_tripwirepicktime))
		awePrecacheShader("white");

	if(level.empire_satchel && (level.empire_satchelplanttime || level.empire_satchelpicktime))
		awePrecacheShader("white");

	// Precache MG42
	if(level.empire_mg42spawnextra)
		awePrecacheModel("xmodel/mg42_bipod");

	// Precache PTRS41
	if(level.empire_ptrs41spawnextra) 
		awePrecacheModel("xmodel/weapon_antitankrifle");
	
	// Precache turrets
	if(level.empire_turretmobile || cvardef("empire_turret_w0", "", "", "", "string") != "")
	{
		// MG42
		awePrecacheModel("xmodel/mg42_bipod");
		awePrecacheItem("mg42_bipod_stand_mp");
		awePrecacheItem("mg42_bipod_prone_mp");
		awePrecacheItem("mg42_bipod_duck_mp");
		precacheTurret("mg42_bipod_duck_mp");
		precacheTurret("mg42_bipod_prone_mp");
		precacheTurret("mg42_bipod_stand_mp");

		// PTRS41
		awePrecacheModel("xmodel/weapon_antitankrifle");
		awePrecacheItem("PTRS41_Antitank_Rifle_mp");
		precacheTurret("PTRS41_Antitank_Rifle_mp");

		// Preache shaders used by turret code
		if(isdefined(level.empire_uo))
		{
			awePrecacheShader("gfx/hud/hud@health_bar.dds");
			awePrecacheShader("gfx/hud/hud@vehiclehealth.dds");
		}

	}

	if(level.empire_turretmobile)
	{
		awePrecacheShader("gfx/hud/hud@death_mg42.tga");
		awePrecacheShader("gfx/hud/hud@death_antitank.tga");
	}

	// Bloodscreen
	if(level.empire_bloodyscreen && !isdefined(level.empire_merciless))
	{
		awePrecacheShader("gfx/impact/flesh_hit1.tga");
		awePrecacheShader("gfx/impact/flesh_hit2.tga");
		awePrecacheShader("gfx/impact/flesh_hitgib.tga");
	}
	
	// Precache parachute
	if(level.empire_parachutes)
		awePrecacheModel("xmodel/parachute_animrig");

	// Precache bullethole
	if(level.empire_bulletholes)
	{
		awePrecacheShader("gfx/impact/bullethit_glass.tga");
		awePrecacheShader("gfx/impact/bullethit_glass2.tga");
	}
	
	// Precache hit blip
	if(level.empire_showhit)
		awePrecacheShader("gfx/hud/hud@fire_ready.tga");

	// Precache weapons
	if(!isdefined(level.empire_classbased))
	{
		precacheForcedWeapon(level.empire_primaryweapon["default"]);
		precacheForcedWeapon(level.empire_primaryweapon["american"]);
		precacheForcedWeapon(level.empire_primaryweapon["british"]);
		precacheForcedWeapon(level.empire_primaryweapon["german"]);
		precacheForcedWeapon(level.empire_primaryweapon["russian"]);

		precacheForcedWeapon(level.empire_secondaryweapon["default"]);
		precacheForcedWeapon(level.empire_secondaryweapon["american"]);
		precacheForcedWeapon(level.empire_secondaryweapon["british"]);
		precacheForcedWeapon(level.empire_secondaryweapon["german"]);
		precacheForcedWeapon(level.empire_secondaryweapon["russian"]);	
	
		precacheForcedWeapon(level.empire_pistoltype["default"]);
		precacheForcedWeapon(level.empire_pistoltype["american"]);
		precacheForcedWeapon(level.empire_pistoltype["british"]);
		precacheForcedWeapon(level.empire_pistoltype["german"]);
		precacheForcedWeapon(level.empire_pistoltype["russian"]);

		precacheForcedWeapon(level.empire_grenadetype["default"]);
		precacheForcedWeapon(level.empire_grenadetype["american"]);
		precacheForcedWeapon(level.empire_grenadetype["british"]);
		precacheForcedWeapon(level.empire_grenadetype["german"]);
		precacheForcedWeapon(level.empire_grenadetype["russian"]);

		precacheForcedWeapon(level.empire_smokegrenadetype["default"]);
		precacheForcedWeapon(level.empire_smokegrenadetype["american"]);
		precacheForcedWeapon(level.empire_smokegrenadetype["british"]);
		precacheForcedWeapon(level.empire_smokegrenadetype["german"]);
		precacheForcedWeapon(level.empire_smokegrenadetype["russian"]);
	}

	if(level.empire_spawnprotection)
	{
		awePrecacheHeadIcon(game["headicon_protect"]);
		awePrecacheShader(game["headicon_protect"]);
	}

	// Precache suicide icon for teamstatus usage
	if((isdefined(level.empire_teamplay) && level.empire_showteamstatus) || level.empire_searchablebodies)
		awePrecacheShader("gfx/hud/death_suicide.dds");

	if(level.empire_painscreen && !isdefined(level.empire_merciless) )
		awePrecacheShader("white");

	if(
		level.empire_secondaryweapon["default"] == "select"	|| level.empire_secondaryweapon["default"] == "selectother"	||
		level.empire_secondaryweapon["american"] == "select"	|| level.empire_secondaryweapon["american"] == "selectother"	||
		level.empire_secondaryweapon["british"] == "select"	|| level.empire_secondaryweapon["british"] == "selectother"	||
		level.empire_secondaryweapon["german"] == "select"		|| level.empire_secondaryweapon["german"] == "selectother"	||
		level.empire_secondaryweapon["russian"] == "select"	|| level.empire_secondaryweapon["russian"] == "selectother"
	  )
	{
		awePrecacheString(level.empire_secondaryweapontext);
	}

	if( level.empire_anticamptime && !level.empire_anticampmethod && !isdefined(level.empire_tdom) )
	{
		// Precache headicons and shaders
		awePrecacheHeadIcon(game["headicon_star"]);
		if(!isdefined(level.empire_teamplay))
			awePrecacheHeadIcon(game["headicon_crosshair"]);
		// Precache compass shaders
		awePrecacheShader("gfx/hud/objective.dds");
		awePrecacheShader("gfx/hud/objective_down.dds");
		awePrecacheShader("gfx/hud/objective_up.dds");	
	}

	if(isdefined(level.empire_teamplay) && level.empire_anticamptime && !level.empire_anticampmethod && !isdefined(level.empire_tdom) )
	{
		awePrecacheShader(game["radio_allies"]);
		awePrecacheShader(game["radio_axis"]);
		awePrecacheShader("gfx/hud/hud@objective_german_up.tga");
		awePrecacheShader("gfx/hud/hud@objective_german_down.tga");
		switch(game["allies"])
		{
			case "russian":
				awePrecacheShader("gfx/hud/hud@objective_russian_up.tga");
				awePrecacheShader("gfx/hud/hud@objective_russian_down.tga");
				break;

			case "british":
				awePrecacheShader("gfx/hud/hud@objective_british_up.tga");
				awePrecacheShader("gfx/hud/hud@objective_british_down.tga");
				break;

			case "american":
				awePrecacheShader("gfx/hud/hud@objective_american_up.tga");
				awePrecacheShader("gfx/hud/hud@objective_american_down.tga");
				break;
		}
	}

	if(isdefined(level.empire_teamplay) && level.empire_showteamstatus == 1)
	{
		awePrecacheShader(game["radio_allies"]);
		awePrecacheShader(game["radio_axis"]);
	}
	if(isdefined(level.empire_teamplay) && level.empire_showteamstatus == 2)
	{
		awePrecacheShader(game["headicon_allies"]);
		awePrecacheShader(game["headicon_axis"]);
	}
}

fixMapRotation()
{
	x = GetPlainMapRotation();
	if(isdefined(x))
	{
		if(isdefined(x.maps))
			maps = x.maps;
		x delete();
	}

	if(!isdefined(maps) || !maps.size)
		return;

	// Built new maprotation string
	newmaprotation = "";
	newmaprotationcurrent = "";
	for(i = 0; i < maps.size; i++)
	{
		if(!isdefined(maps[i]["exec"]))
			exec = "";
		else
			exec = " exec " + maps[i]["exec"];

		if(!isdefined(maps[i]["jeep"]))
			jeep = "";
		else
			jeep = " allow_jeeps " + maps[i]["jeep"];

		if(!isdefined(maps[i]["tank"]))
			tank = "";
		else
			tank = " allow_tanks " + maps[i]["tank"];

		if(!isdefined(maps[i]["gametype"]))
			gametype = "";
		else
			gametype = " gametype " + maps[i]["gametype"];

		newmaprotation += exec + jeep + tank + gametype + " map " + maps[i]["map"];

		if(i>0)
			newmaprotationcurrent += exec + jeep + tank + gametype + " map " + maps[i]["map"];
	}

	// Set the new rotation
	setCvar("sv_maprotation", strip(newmaprotation));

	// Set the new rotationcurrent
	setCvar("sv_maprotationcurrent", newmaprotationcurrent);

	// Set empire_fix_maprotation to "0" to indicate that initial fixing has been done
	setCvar("empire_fix_maprotation", "0");
}
	
randomMapRotation()
{
	level endon("empire_boot");

	// Do random maprotation?
	if(!level.empire_randommaprotation || level.empire_mapvote)
		return;

	// Randomize maps of maprotationcurrent is empty or on a fresh start
	if( strip(getcvar("sv_maprotationcurrent")) == "" || level.empire_randommaprotation == 1)
	{
		x = GetRandomMapRotation();
		if(isdefined(x))
		{
			if(isdefined(x.maps))
				maps = x.maps;
			x delete();
		}

		if(!isdefined(maps) || !maps.size)
			return;

		lastexec = "";
		lastjeep = "";
		lasttank = "";
		lastgt = "";

		// Built new maprotation string
		newmaprotation = "";
		for(i = 0; i < maps.size; i++)
		{
			if(!isdefined(maps[i]["exec"]) || lastexec == maps[i]["exec"])
				exec = "";
			else
			{
				lastexec = maps[i]["exec"];
				exec = " exec " + maps[i]["exec"];
			}

			if(!isdefined(maps[i]["jeep"]) || lastjeep == maps[i]["jeep"])
				jeep = "";
			else
			{
				lastjeep = maps[i]["jeep"];
				jeep = " allow_jeeps " + maps[i]["jeep"];
			}

			if(!isdefined(maps[i]["tank"]) || lasttank == maps[i]["tank"])
				tank = "";
			else
			{
				lasttank = maps[i]["tank"];
				tank = " allow_tanks " + maps[i]["tank"];	
			}

			if(!isdefined(maps[i]["gametype"]) || lastgt == maps[i]["gametype"])
				gametype = "";
			else
			{
				lastgt = maps[i]["gametype"];
				gametype = " gametype " + maps[i]["gametype"];	
			}

			newmaprotation += exec + jeep + tank + gametype + " map " + maps[i]["map"];
		}

		// Set the new rotation
		setCvar("sv_maprotationcurrent", newmaprotation);

		// Set empire_random_maprotation to "2" to indicate that initial randomizing is done
		setCvar("empire_random_maprotation", "2");
	}
}

randomizeArray(arr)
{
	if(arr.size)
	{
		// Shuffle the array 10 times
		for(k = 0; k < 10; k++)
		{
			for(i = 0; i < arr.size; i++)
			{
				j = randomInt(arr.size);
				element = arr[i];
				arr[i] = arr[j];
				arr[j] = element;
			}
		}
	}
	return arr;
}

showWelcomeMessages()
{
	self endon("empire_spawned");
	self endon("empire_died");

	if(isdefined(self.pers["empire_welcomed"])) return;
	self.pers["empire_welcomed"] = true;

	wait 2;

	count = 0;
	message = cvardef("empire_welcome" + count, "", "", "", "string");
	while(message != "")
	{
		self iprintlnbold(message);
		count++;
		message = cvardef("empire_welcome" + count, "", "", "", "string");
		wait level.empire_welcomedelay;
	}
}

serverMessages()
{
	level endon("empire_boot");
	if(level.empire_messageindividual)
	{
		// Check if thread has allready been called.
		if(isdefined(self.pers["empire_serverMessages"]))
			return;

		self endon("empire_spawned");
		self endon("empire_died");
	}
	else
	{
		// Check if thread has allready been called.
		if(isdefined(game["serverMessages"]))
			return;
	}

	wait level.empire_messagedelay;

	for(;;)
	{
		if( !level.empire_mapvote && level.empire_messagenextmap && !(level.empire_messageindividual && isdefined(self.pers["empire_messagecount"])) )
		{
			x = GetCurrentMapRotation(1);
			if(isdefined(x))
			{
				if(isdefined(x.maps))
					maps = x.maps;
				x delete();
			}

			if(isdefined(maps) && maps.size)
			{
				// Get next map
				if(isdefined(maps[0]["gametype"]))
					nextgt=maps[0]["gametype"];
				else
					nextgt=getcvar("g_gametype");

				nextmap=maps[0]["map"];

				if(level.empire_messagenextmap == 4)
				{
					if(level.empire_randommaprotation)
					{
						if(level.empire_messageindividual)
							self iprintln("^3This server uses ^5random ^3maprotation.");
						else
							iprintln("^3This server uses ^5random ^3maprotation.");
					}
					else
					{
						if(level.empire_messageindividual)
							self iprintln("^3This server uses ^5normal ^3maprotation.");
						else
							iprintln("^3This server uses ^5normal ^3maprotation.");
					}	
				
					wait 1;
				}

				if(level.empire_messagenextmap > 2)
				{
					if(level.empire_messageindividual)
						self iprintln("^3Next gametype: ^5" + getGametypeName(nextgt) );
					else
						iprintln("^3Next gametype: ^5" + getGametypeName(nextgt) );
					wait 1;
				}

				if(level.empire_messagenextmap > 2 || level.empire_messagenextmap == 1)
				{
					if(level.empire_messageindividual)
						self iprintln("^3Next map: ^5" + getMapName(nextmap) );
					else
						iprintln("^3Next map: ^5" + getMapName(nextmap) );
				}

				if(level.empire_messagenextmap == 2)
				{
					if(level.empire_messageindividual)
						self iprintln("^1~^3empire ^2| ^3Next: ^1" + getMapName(nextmap) + "^3/^1" + getGametypeName(nextgt) );
					else
						iprintln("^1~^3empire ^2| ^3Next: ^1" + getMapName(nextmap) + "^3/^1" + getGametypeName(nextgt) );
					wait 1;
				}

				// Set next message
				if(level.empire_messageindividual)
					self.pers["empire_messagecount"] = 0;

				wait level.empire_messagedelay;
			}
		}
	
		// Get first message
		if(level.empire_messageindividual && isdefined(self.pers["empire_messagecount"]))
			count = self.pers["empire_messagecount"];
		else
			count = 0;

		message = cvardef("empire_message" + count, "", "", "", "string");

		// Avoid infinite loop
		if(message == "" && !(isdefined(maps) && maps.size))
			wait level.empire_messagedelay;

		// Announce messages
		while(message != "")
		{
			if(level.empire_messageindividual)
				self iprintln(message);
			else
				iprintln(message);
			count++;
			// Set next message
			if(level.empire_messageindividual)
				self.pers["empire_messagecount"] = count;

			wait level.empire_messagedelay;

			message = cvardef("empire_message" + count, "", "", "", "string");
		}

		if(level.empire_messageindividual)
			self.pers["empire_messagecount"] = undefined;

		// Loop?
		if(!level.empire_messageloop)
			break;
	}
	// Set flag to indicate that this thread has been called and run all through once
	if(level.empire_messageindividual)
		self.pers["empire_serverMessages"] = true;
	else
		game["serverMessages"] = true;
}

getGametypeName(gt)
{
	switch(gt)
	{
		case "dm":
		case "mc_dm":
			gtname = "Deathmatch";
			break;
		
		case "tdm":
		case "mc_tdm":
			gtname = "Team Deathmatch";
			break;

		case "sd":
		case "mc_sd":
			gtname = "Search & Destroy";
			break;

		case "re":
		case "mc_re":
			gtname = "Retrieval";
			break;

		case "hq":
		case "mc_hq":
			gtname = "Headquarters";
			break;

		case "bel":
		case "mc_bel":
			gtname = "Behind Enemy Lines";
			break;
		
		case "cnq":
		case "mc_cnq":
			gtname = "Conquest TDM";
			break;

		case "lts":
		case "mc_lts":
			gtname = "Last Team Standing";
			break;

		case "ctf":
		case "mc_ctf":
			gtname = "Capture The Flag";
			break;

		case "dom":
		case "mc_dom":
			gtname = "Domination";
			break;

		case "ad":
		case "mc_ad":
			gtname = "Attack and Defend";
			break;

		case "bas":
		case "mc_bas":
			gtname = "Base assault";
			break;

		case "actf":
		case "mc_actf":
			gtname = "empire_mod Capture The Flag";
			break;

		case "htf":
		case "mc_htf":
			gtname = "Hold The Flag";
			break;

		case "asn":
		case "mc_asn":
			gtname = "Assassin";
			break;

		case "mc_tdom":
			gtname = "Team Domination";
			break;
		
		default:
			gtname = gt;
			break;
	}

	return gtname;
}

getMapName(map)
{
	switch(map)
	{
		case "mp_arnhem":
			mapname = "Arnhem";
			break;

		case "mp_berlin":
			mapname = "Berlin";
			break;

		case "mp_bocage":
			mapname = "Bocage";
			break;
		
		case "mp_brecourt":
			mapname = "Brecourt";
			break;

		case "mp_carentan":
			mapname = "Carentan";
			break;

		case "mp_uo_carentan":
			mapname = "Carentan(UO)";
			break;
		
		case "mp_cassino":
			mapname = "Cassino";
			break;

		case "mp_chateau":
			mapname = "Chateau";
			break;
		
		case "mp_dawnville":
			mapname = "Dawnville";
			break;

		case "mp_uo_dawnville":
			mapname = "Dawnville(UO)";
			break;
		
		case "mp_depot":
			mapname = "Depot";
			break;
		
		case "mp_uo_depot":
			mapname = "Depot(UO)";
			break;
		
		case "mp_foy":
			mapname = "Foy";
			break;

		case "mp_harbor":
			mapname = "Harbor";
			break;
		
		case "mp_uo_harbor":
			mapname = "Harbor(UO)";
			break;
		
		case "mp_hurtgen":
			mapname = "Hurtgen";
			break;
		
		case "mp_uo_hurtgen":
			mapname = "Hurtgen(UO)";
			break;
		
		case "mp_italy":
			mapname = "Italy";
			break;

		case "mp_kharkov":
			mapname = "Kharkov";
			break;

		case "mp_kursk":
			mapname = "Kursk";
			break;

		case "mp_neuville":
			mapname = "Neuville";
			break;
		
		case "mp_pavlov":
			mapname = "Pavlov";
			break;
		
		case "mp_peaks":
			mapname = "Peaks";
			break;

		case "mp_ponyri":
			mapname = "Ponyri";
			break;

		case "mp_powcamp":
			mapname = "P.O.W Camp";
			break;

		case "mp_uo_powcamp":
			mapname = "P.O.W Camp(UO)";
			break;
		
		case "mp_railyard":
			mapname = "Railyard";
			break;

		case "mp_rhinevalley":
			mapname = "Rhine Valley";
			break;

		case "mp_rocket":
			mapname = "Rocket";
			break;
		
		case "mp_ship":
			mapname = "Ship";
			break;

		case "mp_streets":
			mapname = "Streets";
			break;
		
		case "mp_sicily":
			mapname = "Sicily";
			break;

		case "mp_stalingrad":
			mapname = "Stalingrad";
			break;
		
		case "mp_tigertown":
			mapname = "Tigertown";
			break;

		case "mp_uo_stanjel":
			mapname = "Stanjel(UO)";
			break;

		case "DeGaulle_beta2":
			mapname = "DeGaulle Beta2";
			break;

		case "mp_bellicourt":
			mapname = "Bellicourt";
			break;

		case "mp_offensive":
			mapname = "Offensive";
			break;

		case "mp_rzgarena":
			mapname = "Rezorg Arena";
			break;

		case "mp_venicedock":
			mapname = "Venicedock";
			break;

		case "nuenen":
			mapname = "Nuenen";
			break;

		case "Outlaw_Bridge":
			mapname = "Outlaw Bridge";
			break;

		case "Outlaws_SFrance":
			mapname = "Outlaws France";
			break;

		case "the_hunt":
			mapname = "The Hunt";
			break;

		case "mp_streetwar":
			mapname = "Streetwar";
			break;

		case "mp_subharbor_night":
			mapname = "Subharbor Night";
			break;

		case "mp_subharbor_day":
			mapname = "Subharbor Day";
			break;

		case "mp_landsitz":
			mapname = "Landsitz";
			break;

		case "Hafen_beta":
			mapname = "Hafen";
			break;

		case "mp_hollenberg":
			mapname = "Hollenberg";
			break;

		case "viaduct":
			mapname = "Viaduct";
			break;

		case "mp_oase":
			mapname = "Oase";
			break;

		case "mp_v2_ver3":
			mapname = "V2 Rocket";
			break;

		case "arcville":
			mapname = "Arcville";
			break;

		case "arkov4":
			mapname = "Arkov";
			break;

		case "mp_saint-lo":
			mapname = "Saint-Lo";
			break;

		case "second_coming":
			mapname = "The Second Coming";
			break;

		case "mp_westwall":
			mapname = "Westwall";
			break;

		case "mp_maaloy":
			mapname = "Maaloy";
			break;

		case "dufresne":
			mapname = "Dufresne";
			break;

		case "dufresne_winter":
			mapname = "Dufresne Winter";
			break;

		case "gorges_du_wet":
			mapname = "Les Gorges du Wet";
			break;

		case "d-day+7":
			mapname = "D-Day";
			break;

		case "mp_wolfsquare_final":
			mapname = "Wolfsquare Public";
			break;

		case "the_bridge":
			mapname = "The Bridge";
			break;

		case "mp_amberville":
		case "mc_amberville":
			mapname = "Amberville";
			break;

		case "mp_stanjel":
		case "mc_stanjel":
			mapname = "Stanjel";
			break;

		case "mp_bazolles":
		case "mc_bazolles":
			mapname = "Bazolles";
			break;

		case "townville_beta":
		case "mp_townville":
		case "mc_townville":
			mapname = "Townville";
			break;

		case "german_town":
		case "mp_german_town":
		case "mc_german_town":
			mapname = "German Town";
			break;
		
		case "mp_drumfergus2":
			mapname = "Drum Fergus 2";
			break;
			
		case "mp_uo_vaddhe":
			mapname = "V2 Base";
			break;

		default:
			mapname = map;
			break;
	}

	return mapname;
}

explode(s,delimiter)
{
	j=0;
	temparr[j] = "";	

	for(i=0;i<s.size;i++)
	{
		if(s[i]==delimiter)
		{
			j++;
			temparr[j] = "";
		}
		else
			temparr[j] += s[i];
	}
	return temparr;
}


// Add a helper function to normalize the rotation string
normalizeRotation(s)
{
	// Replace all occurrences of "g_gametype" with "gametype"
	return strReplace(s, "g_gametype", "gametype");
}

// Add helper function to check if 'target' matches s starting at 'index'
matchAt(s, target, index)
{
	if (index + target.size > s.size)
		return false;
	for (j = 0; j < target.size; j++)
	{
		if (s[index+j] != target[j])
			return false;
	}
	return true;
}

// Add custom string replacement function
strReplace(s, target, replacement)
{
	newstr = "";
	i = 0;
	while(i < s.size)
	{
		if(matchAt(s, target, i))
		{
			newstr += replacement;
			i += target.size;
		}
		else
		{
			newstr += s[i];
			i++;
		}
	}
        return newstr;
}

// Format a message by replacing placeholders with provided values
formatMessage(msg, player, time)
{
        if (isdefined(time))
        {
                tstr = "^" + getcvar("ui_BrandColorSecondary") + time + " ^" + getcvar("ui_BrandColorPrimary");
                msg = strReplace(msg, "{{TIME}}", tstr);
        }

        if (isdefined(player))
                msg = strReplace(msg, "{{PLAYER}}", player.name);

        return msg;
}

// Strip blanks at start and end of string
strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(i<s.size && s[i]==" ")
		i++;

	// String is just blanks?
	if(i==s.size)
		return "";
	
	for(;i<s.size;i++)
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
	{
		s3 += s2[j];
	}
		
	return s3;
}


updateGametypeCvars(init)
{
	level endon("empire_boot");

	// Debug
	level.empire_debug = cvardef("empire_debug", 0, 0, 1, "int");
	level.empire_debugentities = cvardef("empire_debug_entities", 0, 0, 1, "int");

	// Limit bases
	level.empire_limitbases = cvardef("empire_limit_bases", 0, 0, 2, "int");

	// Disable minefields
	level.empire_disableminefields = cvardef("empire_disable_minefields", 0, 0, 1, "int");

	// Rain/Snow 0-100%
	level.empire_rain	= cvardef("empire_rain", 0, 0, 100, "int");
	level.empire_snow	= cvardef("empire_snow", 0, 0, 100, "int");

	// Laserdot
	level.empire_laserdot	= cvardef("empire_laserdot", 0, 0, 1, "float");		// 0 = don't show, 1 = solid
	level.empire_laserdotsize	= cvardef("empire_laserdot_size", 2, 0.5, 5, "float");	// size
	level.empire_laserdotred	= cvardef("empire_laserdot_red", 1, 0, 1, "float");		// amount of red in dot
	level.empire_laserdotgreen	= cvardef("empire_laserdot_green", 0, 0, 1, "float");	// amount of green in dot
	level.empire_laserdotblue	= cvardef("empire_laserdot_blue", 0, 0, 1, "float");		// amount of blue in dot

	// Show team status on hud
	level.empire_showteamstatus = cvardef("empire_show_team_status", 0, 0, 2, "int");

	// Show hit blip
	level.empire_showhit = cvardef("empire_showhit", 0, 0, 1, "int");

	// Painscreen
	level.empire_painscreen = cvardef("empire_painscreen", 0, 0, 100, "int");

	// Bloodyscreen
	level.empire_bloodyscreen = cvardef("empire_bloodyscreen", 0, 0, 1, "int");

	// Bulletholes
	level.empire_bulletholes = cvardef("empire_bulletholes", 0, 0, 2, "int");
	
	// shell & death shock
	level.empire_shellshock = cvardef("scr_shellshock", 0, 0, 1, "int");
	level.empire_deathshock = cvardef("empire_deathshock", 0, 0, 1, "int");

	// Weapon options
	level.empire_primaryweapon["default"]  = cvardef("empire_primary_weapon", "", "", "", "string");
	level.empire_primaryweapon["american"]  = cvardef("empire_primary_weapon_american", "", "", "", "string");
	level.empire_primaryweapon["british"]  = cvardef("empire_primary_weapon_british", "", "", "", "string");
	level.empire_primaryweapon["german"]  = cvardef("empire_primary_weapon_german", "", "", "", "string");
	level.empire_primaryweapon["russian"]  = cvardef("empire_primary_weapon_russian", "", "", "", "string");

	level.empire_secondaryweaponkeepold	= cvardef("empire_secondary_weapon_keepold", 1, 0, 1, "int");
	level.empire_secondaryweapon["default"]= cvardef("empire_secondary_weapon", "", "", "", "string");
	level.empire_secondaryweapon["american"]=cvardef("empire_secondary_weapon_american", "", "", "", "string");
	level.empire_secondaryweapon["british"]= cvardef("empire_secondary_weapon_british", "", "", "", "string");
	level.empire_secondaryweapon["german"]	= cvardef("empire_secondary_weapon_german", "", "", "", "string");
	level.empire_secondaryweapon["russian"]= cvardef("empire_secondary_weapon_russian", "", "", "", "string");

	level.empire_pistoltype["default"]  = cvardef("empire_pistol_type", "", "", "", "string");
	level.empire_pistoltype["american"]  = cvardef("empire_pistol_type_american", "", "", "", "string");
	level.empire_pistoltype["british"]  = cvardef("empire_pistol_type_british", "", "", "", "string");
	level.empire_pistoltype["german"]  = cvardef("empire_pistol_type_german", "", "", "", "string");
	level.empire_pistoltype["russian"]  = cvardef("empire_pistol_type_russian", "", "", "", "string");

	level.empire_grenadetype["default"]  = cvardef("empire_grenade_type", "", "", "", "string");
	level.empire_grenadetype["american"]  = cvardef("empire_grenade_type_american", "", "", "", "string");
	level.empire_grenadetype["british"]  = cvardef("empire_grenade_type_british", "", "", "", "string");
	level.empire_grenadetype["german"]  = cvardef("empire_grenade_type_german", "", "", "", "string");
	level.empire_grenadetype["russian"]  = cvardef("empire_grenade_type_russian", "", "", "", "string");

	level.empire_smokegrenadetype["default"]  = cvardef("empire_smokegrenade_type", "", "", "", "string");
	level.empire_smokegrenadetype["american"]  = cvardef("empire_smokegrenade_type_american", "", "", "", "string");
	level.empire_smokegrenadetype["british"]  = cvardef("empire_smokegrenade_type_british", "", "", "", "string");
	level.empire_smokegrenadetype["german"]  = cvardef("empire_smokegrenade_type_german", "", "", "", "string");
	level.empire_smokegrenadetype["russian"]  = cvardef("empire_smokegrenade_type_russian", "", "", "", "string");

	// Parachuting
	level.empire_parachutes = cvardef("empire_parachutes", 0, 0, 2, "int");
	level.empire_parachutesonlyattackers = cvardef("empire_parachutes_only_attackers", 1, 0, 1, "int");
	level.empire_parachutesprotection = cvardef("empire_parachutes_protection", 1, 0, 1, "int");
	level.empire_parachuteslimitaltitude = cvardef("empire_parachutes_limit_altitude", 1700, 0, 50000, "int");

	// Turret options
	level.empire_turretmobile		= cvardef("empire_turret_mobile", 0, 0, 2, "int");
	level.empire_turretplanttime	= cvardef("empire_turret_plant_time", 2, 0, 30, "float");
	level.empire_turretpicktime	= cvardef("empire_turret_pick_time", 1, 0, 30, "float");
	level.empire_mg42spawnextra	= cvardef("empire_mg42_spawn_extra", 0, 0, 20, "int");
	level.empire_ptrs41spawnextra	= cvardef("empire_ptrs41_spawn_extra", 0, 0, 20, "int");

	// Tripwire options
	level.empire_tripwire		= cvardef("empire_tripwire", 0, 0, 3, "int");
	level.empire_tripwirelimit		= cvardef("empire_tripwire_limit", 5, 1, 20, "int");
	level.empire_tripwirewarning	= cvardef("empire_tripwire_warning", 1, 0, 1, "int");
	level.empire_tripwireplanttime	= cvardef("empire_tripwire_plant_time", 3, 0, 30, "float");
	level.empire_tripwirepicktime	= cvardef("empire_tripwire_pick_time", 5, 0, 30, "float");

	// Remote detonable satchel options
	level.empire_satchel			= cvardef("empire_satchel", 0, 0, 1, "int");
	level.empire_satchellimit		= cvardef("empire_satchel_limit", 5, 1, 20, "int");
	level.empire_satchelplanttime	= cvardef("empire_satchel_plant_time", 3, 0, 30, "float");
	level.empire_satchelpicktime	= cvardef("empire_satchel_pick_time", 5, 0, 30, "float");

	// Stick nades options
	level.empire_stickynades		= cvardef("empire_sticky_nades", 0, 0, 2, "int");

	// Spawn protection
	level.empire_spawnprotection	= cvardef("empire_spawn_protection", 0, 0, 99, "int");

	// Stukas
	level.empire_stukas			= cvardef("empire_stukas", 0, 0, 99, "int");
	level.empire_stukascrash		= cvardef("empire_stukas_crash", 20, 0, 100, "int");
	level.empire_stukascrashsafety	= cvardef("empire_stukas_crash_safety", 0, 0, 1, "int");
	level.empire_stukascrashquake	= cvardef("empire_stukas_crash_quake", 1, 0, 1, "int");
	level.empire_stukascrashstay	= cvardef("empire_stukas_crash_stay", 30, 0, 10000, "int");
	level.empire_stukasdelay		= cvardef("empire_stukas_delay", 500, 1, 10000, "int"); 

	// Dead body handling
	level.empire_nobodies		= cvardef("empire_no_bodies", 0, 0, 2, "int");
	level.empire_burningbodies		= cvardef("empire_burning_bodies", 5, 0, 99, "float");
	level.empire_searchablebodies	= cvardef("empire_searchable_bodies", 1, 0, 99, "float");
	level.empire_searchablebodieshealth = cvardef("empire_searchable_bodies_health", 1, 0, 1, "int");

	// Pop head
	level.empire_pophead		= cvardef("empire_pophead", 0, 0, 100, "int");

	// Anticamping
	level.empire_anticamptime = cvardef("empire_anticamp_time", 0, 0, 1440, "int");
	level.empire_anticampmethod = cvardef("empire_anticamp_method", 0, 0, level.empire_punishments + 1, "int");
	level.empire_afk_detection = cvardef("empire_afk_detection", 1, 0, 1, "int");

	// Cold breath
	level.empire_coldbreath = cvardef("empire_cold_breath", 0, 0, 1, "int");

        // Map voting
        level.empire_mapvote = cvardef("empire_map_vote", 0, 0, 1, "int");
        level.empire_mapvotetime = cvardef("empire_map_vote_time", 30, 10, 180, "int");
        level.empire_mapvotereplay = cvardef("empire_map_vote_replay",0,0,1,"int");
        // Map rotation history
        level.empire_maphistory = cvardef("empire_map_history", "", "", "", "string");
        level.empire_maphistorysize = cvardef("empire_map_history_size", 5, 1, 20, "int");
        // Gametype rotation
        level.empire_gametypemode = cvardef("empire_gametype_mode", 1, 1, 3, "int");
        level.empire_allowedgametypes = cvardef("empire_allowed_gametypes", "", "", "", "string");
        level.empire_gametypehistory = cvardef("empire_gametype_history", "", "", "", "string");
        level.empire_gametypehistorysize = cvardef("empire_gametype_history_size", 5, 1, 20, "int");
        level.empire_gametypeplayercountlimits = cvardef("empire_gametype_playercount_limits", "", "", "", "string");
        level.empire_mapcandidatepoolsize = cvardef("empire_map_candidate_pool_size", 10, 5, 12, "int");
        level.empire_mapcooldownwindow = cvardef("empire_map_cooldown_window", 8, 1, 40, "int");
        level.empire_mapcooldownpenalty = cvardef("empire_map_cooldown_penalty", 20, 1, 200, "int");
        level.empire_mapfrequencywindow = cvardef("empire_map_frequency_window", 16, 5, 60, "int");
        level.empire_mapfrequencypenalty = cvardef("empire_map_frequency_penalty", 14, 1, 200, "int");
        level.empire_gametypepenaltyscale = cvardef("empire_gametype_penalty_scale", 100, 25, 300, "int");

        // Show grenade cooking
        level.empire_showcooking = cvardef("empire_show_cooking", 1, 0, 1, "int");
	
	// First aid
	level.empire_firstaid	= cvardef("empire_firstaid",0,0,1,"int");

	// UO Sprinting
	level.empire_uosprint	= cvardef("empire_uo_sprint",1,0,3,"int");

	// empire_mod Sprinting
	level.empire_sprint 		= cvardef("empire_sprint",0,0,3,"int");
	level.empire_sprinthud 	= cvardef("empire_sprint_hud",1,0,2,"int");
	level.empire_sprinthudhint = cvardef("empire_sprint_hud_hint",1,0,1,"int");

	// Override falldamage
//	level.empire_falldamage = cvardef("empire_falldamage",100,1,99999,"int");

	for(;;)
	{
		// First aid
		level.empire_firstaidkits	= cvardef("empire_firstaid_kits",1,1,99,"int");
		level.empire_firstaidhealth= cvardef("empire_firstaid_health",25,1,100,"int");
		level.empire_firstaiddelay	= cvardef("empire_firstaid_delay",10,0,999,"int");

		// Stick nades options
		level.empire_stickynadesgrenadefuse	= cvardef("empire_sticky_nades_grenade_fuse", 4, 1, 99, "int");
		level.empire_stickynadessatchelfuse	= cvardef("empire_sticky_nades_satchel_fuse", 6, 1, 99, "int");

		// Damage blocking
		level.empire_blockdamagespectator = cvardef("empire_block_damage_spectator", 1, 0, 1, "int");
		level.empire_blockdamageteamswitch= cvardef("empire_block_damage_team_switch", 1, 0, 1, "int");

		// Sprinting
		level.empire_sprintspeed = (float)1 + cvardef("empire_sprint_speed",60,0,9999,"float")*(float)0.01;
		level.empire_sprinttime = cvardef("empire_sprint_time",3,1,999,"int") * 20;
		level.empire_sprintrecovertime = cvardef("empire_sprint_recover_time",2,0,999,"int") * 20;

		// UO Sprinting
		level.empire_uosprintspeed		= (float)cvardef("empire_uo_sprint_speed",100,0,9999,"float")*(float)0.01;
		level.empire_uosprinttime		= (float)100 / (float)cvardef("empire_uo_sprint_time",100,1,9999,"int");
		level.empire_uosprintrecovertime	= (float)100 / (float)cvardef("empire_uo_sprint_recover_time",100,1,9999,"int");

		// Unlimted ammo
		level.empire_unlimitedammo = cvardef("empire_unlimited_ammo", 0, 0, 2, "int");
		level.empire_unlimitedgrenades = cvardef("empire_unlimited_grenades", 0, 0, 1, "int");
		level.empire_unlimitedsmokegrenades = cvardef("empire_unlimited_smokegrenades", 0, 0, 1, "int");

		// head popping controls
		level.empire_popheadbullet	= cvardef("empire_pophead_bullet", 1, 0, 1, "int");
		level.empire_popheadmelee	= cvardef("empire_pophead_melee", 1, 0, 1, "int");
		level.empire_popheadexplosion= cvardef("empire_pophead_explosion", 1, 0, 1, "int");

		// Zombie mode
		level.empire_zombie	= cvardef("empire_zombie",0,0,1,"int");

		// Player max speed
		level.empire_playerspeed = cvardef("empire_player_speed",100,0,9999,"float");

		// Override gravity?
		gravity = cvardef("empire_gravity",100,0,9999,"float");
		if(!isdefined(level.empire_gravity) || gravity != level.empire_gravity)
		{
			level.empire_gravity = gravity;
			setcvar("g_gravity", 8 * gravity);
			if(level.empire_debug)
				iprintln("Gravity set to:" + 8 * gravity);
		}

		// Unknown Soldiers handling
		level.empire_unknownreflect = cvardef("empire_unknown_reflect",1,0,1,"int");
		level.empire_unknownmethod = cvardef("empire_unknown_method",0,0,3,"int");
		level.empire_unknownrenamemsg = cvardef("empire_unknown_rename_msg","Unknown Soldier is not a valid name! You have been renamed by the server.","","","string");

		// Vsay dropping
		level.empire_vsaydropweapon = cvardef("empire_vsay_drop_weapon",1,0,1,"int");
		level.empire_vsaydrophealth = cvardef("empire_vsay_drop_health",0,0,1,"int");

		// Use bots (for debugging)
		level.empire_bots = cvardef("empire_bots", 0, 0, 99, "int");

		// Disable crosshair?
		level.empire_nocrosshair = cvardef("empire_no_crosshair", 0, 0, 2, "int");

		if(!init) wait 0.5;

		// turn on ambient mortars
		level.empire_mortar = cvardef("empire_mortar", 3, 0, 10, "int");
		// quake?
		level.empire_mortar_quake = cvardef("empire_mortar_quake", 1, 0, 1, "int");
		// random?
		level.empire_mortar_random = cvardef("empire_mortar_random", 0, 0, 1, "int");
		// make them safe for players
		level.empire_mortar_safety = cvardef("empire_mortar_safety", 1, 0, 1, "int");
		// minimum delay between mortars
		level.empire_mortar_delay_min = cvardef("empire_mortar_delay_min", 20, 5, 179, "int");
		// maximum delay between mortars
		level.empire_mortar_delay_max = cvardef("empire_mortar_delay_max", 60, level.empire_mortar_delay_min+1, 180, "int");
	
		// warm up round for round based gametypes
		level.empire_warmupround 	= cvardef("empire_warmup_round", 0, 0, 1, "int");

		// team overriding
		level.empire_teamallies	= cvardef("empire_team_allies","","","","string");
		level.empire_teamswap	= cvardef("empire_team_swap", 0, 0, 1,"int");

		if(!init) wait 0.5;

		// fog options
		cfogstr = cvardef("empire_cfog", "none", "", "", "string");
		if(cfogstr != "none" && (!isdefined(level.empire_cfogstr) || level.empire_cfogstr != cfogstr))
		{
			level.empire_cfogstr	= cfogstr;
			cfogstr = strip(level.empire_cfogstr);
			if(cfogstr!="")
			{
				cfog = explode(cfogstr," ");
				if(cfog.size == 6)
				{
					level.empire_cfog		= (int)cfog[0];
					level.empire_cfogdistance	= (int)cfog[1];
					level.empire_cfogdistance2	= (int)cfog[2];
					level.empire_cfogred		= (float)cfog[3];
					level.empire_cfoggreen	= (float)cfog[4];
					level.empire_cfogblue	= (float)cfog[5];
				}
			}
		}
		efogstr = cvardef("empire_efog", "none", "", "", "string");
		if(efogstr != "none" && (!isdefined(level.empire_efogstr) || level.empire_efogstr != efogstr))
		{
			level.empire_efogstr	= efogstr;
			efogstr = strip(level.empire_efogstr);
			if(efogstr!="")
			{
				efog = explode(efogstr," ");
				if(efog.size == 6)
				{
					level.empire_efog 		= (int)efog[0];
					level.empire_efogdensity	= (float)efog[1];
					level.empire_efogdensity2	= (float)efog[2];
					level.empire_efogred		= (float)efog[3];
					level.empire_efoggreen	= (float)efog[4];
					level.empire_efogblue	= (float)efog[5];
				}
			}
		}

		if(!init) wait 0.5;

		// Damage modifiers
		// American 
		level.empire_dmgmod["m1carbine_mp"]		= (float)cvardef("empire_dmgmod_m1carbine_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["m1garand_mp"]		= (float)cvardef("empire_dmgmod_m1garand_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["thompson_mp"]		= (float)cvardef("empire_dmgmod_thompson_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["bar_mp"]			= (float)cvardef("empire_dmgmod_bar_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["springfield_mp"]		= (float)cvardef("empire_dmgmod_springfield_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["fraggrenade_mp"]		= (float)cvardef("empire_dmgmod_fraggrenade_mp",183,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["colt_mp"]			= (float)cvardef("empire_dmgmod_colt_mp",100,0,9999,"float")*(float)0.01;

		// British
		level.empire_dmgmod["enfield_mp"]		= (float)cvardef("empire_dmgmod_enfield_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["sten_mp"]			= (float)cvardef("empire_dmgmod_sten_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["bren_mp"]			= (float)cvardef("empire_dmgmod_bren_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["mk1britishfrag_mp"]	= (float)cvardef("empire_dmgmod_mk1britishfrag_mp",183,0,9999,"float")*(float)0.01;

		// German
		level.empire_dmgmod["kar98k_mp"]			= (float)cvardef("empire_dmgmod_kar98k_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["mp40_mp"]			= (float)cvardef("empire_dmgmod_mp40_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["mp44_mp"]			= (float)cvardef("empire_dmgmod_mp44_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["kar98k_sniper_mp"]	= (float)cvardef("empire_dmgmod_kar98k_sniper_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["stielhandgranate_mp"]	= (float)cvardef("empire_dmgmod_stielhandgranate_mp",183,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["luger_mp"]			= (float)cvardef("empire_dmgmod_luger_mp",100,0,9999,"float")*(float)0.01;

		// Russian
		level.empire_dmgmod["mosin_nagant_mp"]		= (float)cvardef("empire_dmgmod_mosin_nagant_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["ppsh_mp"]			= (float)cvardef("empire_dmgmod_ppsh_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["mosin_nagant_sniper_mp"]= (float)cvardef("empire_dmgmod_mosin_nagant_sniper_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["rgd-33russianfrag_mp"]	= (float)cvardef("empire_dmgmod_rgd-33russianfrag_mp",183,0,9999,"float")*(float)0.01;

		// Turrets
		level.empire_dmgmod["mg42_bipod_duck_mp"]	= (float)cvardef("empire_dmgmod_mg42_bipod_duck_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["mg42_bipod_prone_mp"]	= (float)cvardef("empire_dmgmod_mg42_bipod_prone_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["mg42_bipod_stand_mp"]	= (float)cvardef("empire_dmgmod_mg42_bipod_stand_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["ptrs41_antitank_rifle_mp"]= (float)cvardef("empire_dmgmod_ptrs41_antitank_rifle_mp",100,0,9999,"float")*(float)0.01;

		// "Common"
		level.empire_dmgmod["fg42_mp"]			= (float)cvardef("empire_dmgmod_fg42_mp",100,0,9999,"float")*(float)0.01;
		level.empire_dmgmod["panzerfaust_mp"]		= (float)cvardef("empire_dmgmod_panzerfaust_mp",100,0,9999,"float")*(float)0.01;

		if(isdefined(level.empire_uo))
		{
			// American
			level.empire_dmgmod["mg30cal_mp"]		= (float)cvardef("empire_dmgmod_mg30cal_mp",100,0,9999,"float")*(float)0.01;

			// British
			level.empire_dmgmod["webley_mp"]			= (float)cvardef("empire_dmgmod_webley_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["sten_silenced_mp"]	= (float)cvardef("empire_dmgmod_sten_silenced_mp",100,0,9999,"float")*(float)0.01;

			// German
			level.empire_dmgmod["gewehr43_mp"]		= (float)cvardef("empire_dmgmod_gewehr43_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["mg34_mp"]			= (float)cvardef("empire_dmgmod_mg34_mp",100,0,9999,"float")*(float)0.01;

			// Russian
			level.empire_dmgmod["tt33_mp"]			= (float)cvardef("empire_dmgmod_tt33_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["svt40_mp"]			= (float)cvardef("empire_dmgmod_svt40_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["dp28_mp"]			= (float)cvardef("empire_dmgmod_dp28_mp",100,0,9999,"float")*(float)0.01;

			// "Common"
			level.empire_dmgmod["flamethrower_mp"]		= (float)cvardef("empire_dmgmod_flamethrower_mp",50,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["bazooka_mp"]		= (float)cvardef("empire_dmgmod_bazooka_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["panzerschreck_mp"]	= (float)cvardef("empire_dmgmod_panzerschreck_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["satchelcharge_mp"]	= (float)cvardef("empire_dmgmod_satchelcharge_mp",100,0,9999,"float")*(float)0.01;

			// Tanks & Turrets
			level.empire_dmgmod["30cal_tank_mp"]		= (float)cvardef("empire_dmgmod_30cal_tank_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["50cal_tank_mp"]		= (float)cvardef("empire_dmgmod_50cal_tank_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["elefant_turret_mp"]	= (float)cvardef("empire_dmgmod_elefant_turret_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["mg34_tank_mp"]		= (float)cvardef("empire_dmgmod_mg34_tank_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["mg42_tank_mp"]		= (float)cvardef("empire_dmgmod_mg42_tank_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["panzeriv_turret_mp"]	= (float)cvardef("empire_dmgmod_panzeriv_turret_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["sg43_tank_mp"]		= (float)cvardef("empire_dmgmod_sg43_tank_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["sherman_turret_mp"]	= (float)cvardef("empire_dmgmod_sherman_turret_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["su152_turret_mp"]		= (float)cvardef("empire_dmgmod_su152_turret_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["flak88_turret_mp"]	= (float)cvardef("empire_dmgmod_flak88_turret_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["mg42_turret_mp"]		= (float)cvardef("empire_dmgmod_mg42_turret_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["mg50cal_tripod_stand_mp"]= (float)cvardef("empire_dmgmod_mg50cal_tripod_stand_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["mg_sg43_stand_mp"]	= (float)cvardef("empire_dmgmod_mg_sg43_stand_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["sg43_turret_mp"]		= (float)cvardef("empire_dmgmod_sg43_turret_mp",100,0,9999,"float")*(float)0.01;
			level.empire_dmgmod["t34_turret_mp"]		= (float)cvardef("empire_dmgmod_t34_turret_mp",100,0,9999,"float")*(float)0.01;
			level.empire_flamethrowerhitrate			= cvardef("empire_flamethrower_hitrate",100,0,100,"int");
		}

		if(!init) wait 0.5;

		// welcome message
		level.empire_welcomedelay		= cvardef("empire_welcome_delay", 1, 0.05, 30, "float");

		// Server messages
		level.empire_messagedelay		= cvardef("empire_message_delay", 30, 1, 1440, "int");
		level.empire_messagenextmap	= cvardef("empire_message_next_map", 2, 0, 4, "int");
		level.empire_messageloop		= cvardef("empire_message_loop", 1, 0, 1, "int");
		level.empire_messageindividual	= cvardef("empire_message_individual", 0, 0, 1, "int");

		// Weapon limiting
		level.empire_riflelimit	= cvardef("empire_rifle_limit", 0, 0, 100, "int");
		level.empire_boltriflelimit= cvardef("empire_boltrifle_limit", 0, 0, 100, "int");
		level.empire_semiriflelimit= cvardef("empire_semirifle_limit", 0, 0, 100, "int");
		level.empire_smglimit	= cvardef("empire_smg_limit", 0, 0, 100, "int");
		level.empire_assaultlimit	= cvardef("empire_assault_limit", 0, 0, 100, "int");
		level.empire_sniperlimit	= cvardef("empire_sniper_limit", 0, 0, 100, "int");
		level.empire_lmglimit	= cvardef("empire_lmg_limit", 0, 0, 100, "int");
		level.empire_ftlimit		= cvardef("empire_ft_limit", 0, 0, 100, "int");
		level.empire_rllimit		= cvardef("empire_rl_limit", 0, 0, 100, "int");
		level.empire_fg42limit	= cvardef("empire_fg42_limit", 0, 0, 100, "int");

		// Drop weapon options
		level.empire_droponarmhit	= cvardef("empire_droponarmhit", 0, 0, 100, "int");
		level.empire_droponhandhit = cvardef("empire_droponhandhit", 0, 0, 100, "int");
		level.empire_dropondeath	= cvardef("empire_dropondeath", 1, 0, 2, "int");

		if(!init) wait 0.5;

		// Display Obituary Messages.
		level.empire_obituary = cvardef("empire_obituary", 1,0,2, "int");
		level.empire_obituarydeath = cvardef("empire_obituary_death", 1,0,1, "int");

		// Trip on foot/leg hit
		level.empire_triponleghit	= cvardef("empire_triponleghit", 0, 0, 100, "int");
		level.empire_triponfoothit	= cvardef("empire_triponfoothit", 0, 0, 100, "int");
			
		// Pop helmet
		level.empire_pophelmet = cvardef("empire_pophelmet", 50, 0, 100, "int");

	     	// pain & death sounds
		level.empire_painsound	= cvardef("empire_painsound", 1, 0, 1, "int");

	      // C47 planes
		level.empire_bombers = cvardef("empire_bombers", 0, 0, 1, "int");
      	// C47 planes delay
		level.empire_bombers_delay = cvardef("empire_bombers_delay", 300, 1, 1440, "int");	

		if(!init) wait 0.5;

	      // Override altitude?
		level.empire_bombers_altitude = cvardef("empire_bombers_altitude", 0, 0, 10000, "int");
	      // Override distance?
		level.empire_bombers_distance = cvardef("empire_bombers_distance", 0, -25000, 25000, "int");

		// Ambient tracers
		level.empire_tracers			= cvardef("empire_tracers", 0, 0, 100, "int");
		level.empire_tracersdelaymin	= cvardef("empire_tracers_delay_min", 5, 1, 1440, "int");
		level.empire_tracersdelaymax	= cvardef("empire_tracers_delay_max", 15, level.empire_tracersdelaymin + 1, 1440, "int");

		// Ambient skyflashes
		level.empire_skyflashes		= cvardef("empire_skyflashes", 5, 0, 100, "int");
		level.empire_skyflashesdelaymin	= cvardef("empire_skyflashes_delay_min", 5, 1, 1440, "int");
		level.empire_skyflashesdelaymax	= cvardef("empire_skyflashes_delay_max", 15, level.empire_skyflashesdelaymin + 1, 1440, "int");

		if(!init) wait 0.5;

		// Anti teamkilling
		level.empire_teamkillmax = cvardef("empire_teamkill_max", 3, 0, 99, "int");
		level.empire_teamkillwarn = cvardef("empire_teamkill_warn", 1, 0, 99, "int");
		level.empire_teamkillmethod = cvardef("empire_teamkill_method", 0, 0, level.empire_punishments + 1, "int");
		level.empire_teamkillreflect = cvardef("empire_teamkill_reflect", 1, 0, 1, "int");
		level.empire_teamkillmsg = cvardef("empire_teamkill_msg","^6Good damnit! ^7Learn the difference between ^4friend ^7and ^1foe ^7you bastard!.","","","string");

		// Anti teamdamage
		level.empire_teamdamagemax = cvardef("empire_teamdamage_max", 0, 0, 10000, "int");
		level.empire_teamdamagewarn = cvardef("empire_teamdamage_warn", 0, 0, 10000, "int");
		level.empire_teamdamagemethod = cvardef("empire_teamdamage_method", 0, 0, level.empire_punishments + 1, "int");
		level.empire_teamdamagereflect = cvardef("empire_teamdamage_reflect", 1, 0, 1, "int");
		level.empire_teamdamagemsg = cvardef("empire_teamdamage_msg","^6Good damnit! ^7Learn the difference between ^4friend ^7and ^1foe ^7you bastard!.","","","string");

		if(!init) wait 0.5;

		// Anticamping
		level.empire_anticampmarktime = cvardef("empire_anticamp_marktime", 90, 0, 1440, "int");
		level.empire_anticampfun = cvardef("empire_anticamp_fun", 0, 0, 1440, "int");
		level.empire_anticampmsgsurvived = cvardef("empire_anticamp_msg_survived", "^6Congratulations! ^7You are no longer marked and still alive.", "", "", "string");
                level.empire_anticampmsgdied = cvardef("empire_anticamp_msg_died", "A ^1dead ^7camper is a ^2good ^7camper!", "", "", "string");

                // Grenade options
		level.empire_fusetime = cvardef("empire_fuse_time", 4, 1, 99, "int");
		level.empire_grenadewarning = cvardef("empire_grenade_warning", 100, 0, 100, "int");
		level.empire_grenadewarningrange = cvardef("empire_grenade_warning_range", 500, 0, 100000, "int");
		level.empire_grenadecount = cvardef("empire_grenade_count", 0, 0, 999, "int");
		level.empire_grenadecountrandom = cvardef("empire_grenade_count_random", 0, 0, 2, "int");
		level.empire_smokegrenadecount = cvardef("empire_smokegrenade_count", 0, 0, 999, "int");
		level.empire_smokegrenadecountrandom = cvardef("empire_smokegrenade_count_random", 0, 0, 2, "int");
		level.empire_satchelcount = cvardef("empire_satchel_count", 0, 0, 999, "int");
		
		if(!init) wait 0.5;

		// Ammo limiting
		level.empire_ammomin = cvardef("empire_ammo_min",100,0,100,"int");
		level.empire_ammomax = cvardef("empire_ammo_max",100,level.empire_ammomin,100,"int");

		// Hud
		level.empire_showlogo = cvardef("empire_show_logo", 1, 0, 1, "int");	
		level.empire_showserverlogo = cvardef("empire_show_server_logo", 0, 0, 2, "int");	
		level.empire_serverlogotext = cvardef("empire_server_logo_text", "", "", "", "string");	
		level.empire_showsdtimer_cvar = cvardef("empire_show_sd_timer", 0, 0, 1, "int");	
		if(level.empire_showsdtimer_cvar)
			level.empire_showsdtimer = true;
		else
			level.empire_showsdtimer = undefined;

		// Fix corrupt maprotations
		level.empire_fixmaprotation = cvardef("empire_fix_maprotation", 0, 0, 1, "int");	

		// Use random maprotation?
		level.empire_randommaprotation = cvardef("empire_random_maprotation", 0, 0, 2, "int");	

		// Optional gametype weighting for random map rotation.
		// Format example: "ctf:60,dm:20,tdm:10,hq:5,bel:5"
		level.empire_randomgametypeweights = cvardef("empire_random_gametype_weights", "", "", "", "string");

		// Rotate map if server is empty?
		level.empire_rotateifempty = cvardef("empire_rotate_if_empty", 30, 0, 1440, "int");

		if(!init) wait 0.5;

		// Spawn protection
		level.empire_spawnprotectionrange= cvardef("empire_spawn_protection_range", 50, 0, 10000, "int");
		level.empire_spawnprotectionhud	= cvardef("empire_spawn_protection_hud", 1, 0, 2, "int");
		level.empire_spawnprotectionheadicon = cvardef("empire_spawn_protection_headicon", 1, 0, 1, "int");
		level.empire_spawnprotectiondropweapon = cvardef("empire_spawn_protection_dropweapon",0,0,1,"int");
		level.empire_spawnprotectiondisableweapon = cvardef("empire_spawn_protection_disableweapon",0,0,1,"int");

		// Turret stuff
		level.empire_mg42disable 		= cvardef("empire_mg42_disable", 0, 0, 1, "int");
		level.empire_ptrs41disable 	= cvardef("empire_ptrs41_disable", 0, 0, 1, "int");
		level.empire_turretpenalty 	= cvardef("empire_turret_penalty", 1, 0, 1, "int");
		level.empire_turretrecover		= cvardef("empire_turret_recover", 1, 0, 1, "int");

		// Bleeding & taunts
		level.empire_bleeding	= cvardef("empire_bleeding", 0, 0, 100, "int");
		level.empire_taunts		= cvardef("empire_taunts", 0, 0, 1, "int");

		if(!init) wait 0.5;

		// If we are initializing variables, break here
		if(init) break;

//		if(getcvar("let_it_all_pour_down")=="1" && !isdefined(level.empire_raining))
//			thread letItRain();
		
		if(!isdefined(level.empire_tdom))
		{
			// Delete all stale objectives
			for(i=level.empire_objnum_min;i<=level.empire_objnum_max;i++)	// Set up array and flag all as unused
				objectives[i]=false;

//			allplayers = getentarray("player", "classname");		// Get all players and flag all used objectives
			
			for(i = 0; i < level.empire_allplayers.size; i++)
				if(isdefined(level.empire_allplayers[i]))
					if( level.empire_allplayers[i].sessionstate == "playing" && isdefined(level.empire_allplayers[i].empire_objnum) )
						objectives[level.empire_allplayers[i].empire_objnum]=true;

			for(i=level.empire_objnum_min;i<=level.empire_objnum_max;i++)	// Delete unused objectives
				if(!objectives[i])
					objective_delete(i);
		}
	
		wait 0.5;
	}
}

incoming()
{
	level endon("empire_boot");

	if(level.empire_bombers_altitude)
		maxz = level.empire_bombers_altitude;
	else
		maxz = level.empire_vMax[2];	

	surfaces = [];
//	surfaces[surfaces.size] = "brick";
//	surfaces[surfaces.size] = "concrete";
//	surfaces[surfaces.size] = "dirt";
	surfaces[surfaces.size] = "generic";
//	surfaces[surfaces.size] = "grass";
//	surfaces[surfaces.size] = "gravel";
//	surfaces[surfaces.size] = "metal";
//	surfaces[surfaces.size] = "wood";

	for(;;)
	{
		range = (int)(level.empire_mortar_delay_max - level.empire_mortar_delay_min);
		delay = randomInt(range);
		delay = delay + level.empire_mortar_delay_min;
		wait delay;

		mortar = spawn("script_model", (0,0,0));
		mortar setModel(level.empire_mortarmodel);
		mortar hide();

		distance = -1;
		// if the safety is on for mortars, make sure they don't hit a player
		range = 1000000;
		while(distance < level.empire_mortar_safety * range * 2)
		{
			// Get a random mortar incoming sound
			m = randomInt(level.empire_mortars.size);

			// Random strength
			pc = randomInt(100);

			// Get it's damage range
			range = 200 + pc*360*0.01;

			// Get players
			players = [];
			for(i=0;i<level.empire_allplayers.size;i++)
				if(isdefined(level.empire_allplayers[i]))
					if(level.empire_allplayers[i].sessionstate == "playing")
						players[players.size] = level.empire_allplayers[i];
	
			if(!level.empire_mortar_random && players.size)
			{
				// Get a random player
				p = randomInt(players.size);
				// Get a random angle			
				angle = (0,randomInt(360),0);
				// Convert to vector
				vector = anglesToForward(angle);
				// Scale vector differently depending on safety
				variance = maps\mp\_utility::vectorScale(vector, range*level.empire_mortar_safety*2 + randomInt(range*3) );
				// Set mortar origin;
				endorigin = players[p].origin + variance;
			}
			else
			{
				x = level.empire_vMin[0] + randomInt(level.empire_vMax[0]-level.empire_vMin[0]);
				y = level.empire_vMin[1] + randomInt(level.empire_vMax[1]-level.empire_vMin[1]);
				trace = bulletTrace((x,y,maxz),(x,y,level.empire_vMin[2]), false, undefined);
				if(trace["fraction"] != 1)
					z = trace["position"][2];
				else
					z = level.empire_vMin[2];
				endorigin = (x,y,z);
			}

			// Check if any other player is within range
			if(level.empire_mortar_safety && players.size)
			{
				bplayers = sortByDist(players, mortar);
				distance = distance(endorigin, bplayers[0].origin);
			}
			else
				break;

			wait 0.2;  // in case it has to loop a lot because of safety
		}

		// find the impact point
		trace = bulletTrace((endorigin[0],endorigin[1],maxz),(endorigin[0],endorigin[1],level.empire_vMin[2]), false, undefined);
		surface = trace["surfacetype"];
		if(trace["fraction"] != 1)
			endorigin = trace["position"];

		// Start point for mortar
		startpoint = ( (endorigin[0] - 200 + randomInt(400)) , (endorigin[1] - 200 + randomInt(400)) ,maxz);

		mortar.origin = startpoint;

		wait .05;

		// play the incoming sound
		mortar playsound(level.empire_mortars[m]["incoming"]);

		// Make closest player yell warning
		if(isdefined(level.empire_teamplay) && !level.empire_mortar_safety)
		{
//			allplayers = getentarray("player", "classname");
			players = [];
			for(i=0;i<level.empire_allplayers.size;i++)
				if(isdefined(level.empire_allplayers[i]))
					if(level.empire_allplayers[i].sessionstate == "playing")
						players[players.size] = level.empire_allplayers[i];

			if(players.size)
			{
				bplayers = sortByDist(players, mortar);
				distance = distance(mortar.origin, bplayers[0].origin);
				if(distance<range*2 && randomInt(2) && bplayers[0] teamMateInRange(range*2))
					bplayers[0] playsound("empire_" + game[bplayers[0].sessionteam] + "_incoming");
			}
		}

		falltime = .5;

		// wait for it to hit
		wait level.empire_mortars[m]["delay"] - 0.05 - falltime;

		// Show visible mortar object
		mortar.angles = vectortoangles(vectornormalize(mortar.origin - startpoint)) + (90,0,0);
		mortar show();
		wait .05;

		// Move visible mortar
		mortar moveto(endorigin, falltime);

		// wait for it to hit
		wait falltime;

		// play the visual effect
		if(isdefined(level.empire_mortarfx[surface]))
		{
			playfx(level.empire_mortarfx[surface], endorigin);
		}
		else
		{
			if(isdefined(level.empire_wintermap))
				playfx(level.empire_mortarfx["snow"], endorigin);
			else
				playfx(level.empire_mortarfx[surfaces[randomInt(surfaces.size)]], endorigin);
		}

		if(isdefined(level.empire_uo))
		{
			// play the hit sound
			if (surface == "none")
				surface = "default";
			mortar playsound("mortar_explode_" + surface);
		}
		else
		{
			mortar playsound("mortar_explosion" + (randomInt(5) + 1));
		}

		// Hide visible mortar
		mortar hide();

		// just to be extra safe, since a player MIGHT move in range during the "incoming" sound
		if(!level.empire_mortar_safety)
		{
			// do the damage
			max = 200 + 200*pc*0.01;
			min = 10;
			radiusDamage(endorigin + (0,0,12), range, max, min);
		}

		if(level.empire_mortar_quake)
		{
			// rock their world
			strength = 0.5 + 0.5 * pc * 0.01;
			length = 1 + 3*pc*0.01;;
			range = 600 + 600*pc*0.01;
			earthquake(strength, length, endorigin, range); 
		}

		mortar delete();
	}
}

/*
USAGE OF "cvardef"
cvardef replaces the multiple lines of code used repeatedly in the setup areas of the script.
The function requires 5 parameters, and returns the set value of the specified cvar
Parameters:
	varname - The name of the variable, i.e. "scr_teambalance", or "scr_dem_respawn"
		This function will automatically find map-sensitive overrides, i.e. "src_dem_respawn_mp_brecourt"

	vardefault - The default value for the variable.  
		Numbers do not require quotes, but strings do.  i.e.   10, "10", or "wave"

	min - The minimum value if the variable is an "int" or "float" type
		If there is no minimum, use "" as the parameter in the function call

	max - The maximum value if the variable is an "int" or "float" type
		If there is no maximum, use "" as the parameter in the function call

	type - The type of data to be contained in the vairable.
		"int" - integer value: 1, 2, 3, etc.
		"float" - floating point value: 1.0, 2.5, 10.384, etc.
		"string" - a character string: "wave", "player", "none", etc.
*/
cvardef(varname, vardefault, min, max, type)
{
	mapname = getcvar("mapname");		// "mp_dawnville", "mp_rocket", etc.
	gametype = getcvar("g_gametype");	// "tdm", "bel", etc.

	tempvar = varname + "_" + gametype;	// i.e., scr_teambalance becomes scr_teambalance_tdm
	if(getcvar(tempvar) != "") 		// if the gametype override is being used
		varname = tempvar; 		// use the gametype override instead of the standard variable

	tempvar = varname + "_" + mapname;	// i.e., scr_teambalance becomes scr_teambalance_mp_dawnville
	if(getcvar(tempvar) != "")		// if the map override is being used
		varname = tempvar;		// use the map override instead of the standard variable


	// get the variable's definition
	switch(type)
	{
		case "int":
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvarint(varname);
			break;
		case "float":
			if(getcvar(varname) == "")	// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvarfloat(varname);
			break;
		case "string":
		default:
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvar(varname);
			break;
	}

	// if it's a number, with a minimum, that violates the parameter
	if((type == "int" || type == "float") && min != "" && definition < min)
		definition = min;

	// if it's a number, with a maximum, that violates the parameter
	if((type == "int" || type == "float") && max != "" && definition > max)
		definition = max;

	return definition;
}

spawn_model(model,name,origin,angles)
{
	if (!isdefined(model) || !isdefined(name) || !isdefined(origin))
		return undefined;

	if (!isdefined(angles))
		angles = (0,0,0);

	spawn = spawn ("script_model",(0,0,0));
	spawn.origin = origin;
	spawn setmodel (model);
	spawn.targetname = name;
	spawn.angles = angles;

	return spawn;
}

// sort a list of entities with ".origin" properties in ascending order by their distance from the "startpoint"
// "points" is the array to be sorted
// "startpoint" (or the closest point to it) is the first entity in the returned list
// "maxdist" is the farthest distance allowed in the returned list
// "mindist" is the nearest distance to be allowed in the returned list
sortByDist(points, startpoint, maxdist, mindist)
{
	if(!isdefined(points))
		return undefined;
	if(!isdefineD(startpoint))
		return undefined;

	if(!isdefined(mindist))
		mindist = -1000000;
	if(!isdefined(maxdist))
		maxdist = 1000000; // almost 16 miles, should cover everything.

	sortedpoints = [];

	max = points.size-1;
	for(i = 0; i < max; i++)
	{
		nextdist = 1000000;
		next = undefined;

		for(j = 0; j < points.size; j++)
		{
			thisdist = distance(startpoint.origin, points[j].origin);
			if(thisdist <= nextdist && thisdist <= maxdist && thisdist >= mindist)
			{
				next = j;
				nextdist = thisdist;
			}
		}

		if(!isdefined(next))
			break; // didn't find one that fit the range, stop trying

		sortedpoints[i] = points[next];

		// shorten the list, fewer compares
		points[next] = points[points.size-1]; // replace the closest point with the end of the list
		points[points.size-1] = undefined; // cut off the end of the list
	}

	sortedpoints[sortedpoints.size] = points[0]; // the last point in the list

	return sortedpoints;
}

painsound()
{
	if(isdefined(level.empire_teamplay))
		team = self.sessionteam;
	else
		team = self.pers["team"];

	nationality = game[team];
	num =  randomInt(level.empire_voices[nationality]) + 1;

	if(isdefined(level.empire_uo))
	{
		num = 1;
		if(team == "axis")
			nationality = "german";
		else
			nationality = "american";
	}

	scream = "generic_pain_" + nationality + "_" + num; // i.e. "generic_pain_german_2"
	self playSound(scream);
}

taunts(victim)
{
	self notify("empire_taunts");
	self endon("empire_taunts");
	self endon("empire_spawned");
	self endon("empire_died");

	if(isdefined(level.empire_teamplay))
	{
		if(isPlayer(self) && self != victim && self.sessionteam != victim.sessionteam )
			self.empire_killspree++;
		else
			return;
	}
	else
	{
		if (isPlayer(self) && self != victim)
			self.empire_killspree++;
		else
			return;
	}

	rn = randomint(16);

	if(self.empire_killspree == 2 || self.empire_killspree == 3)
		rn = randomint(10);
	if(self.empire_killspree == 4 || self.empire_killspree == 5)
		rn = randomint(8);
	if(self.empire_killspree > 5)
		rn = randomint(5);

	if(isdefined(level.empire_teamplay))
	{
		team = self.sessionteam;
		otherteam = victim.sessionteam;
	}
	else
	{
		team = self.pers["team"];
		otherteam = victim.pers["team"];
	}

	wait (.5);

	if(self.sessionstate == "playing")
	{
		nationality = game[team];
		
		if (rn == 1 || rn == 2)
			self playsound("empire_" + nationality + "_taunt");
		if (rn == 3)
		{
			if((game[team] == "russian") && (game[team] == "german"))
				self playsound ("empire_RvG");
			else if ((game[team] == "german") && (game[team] == "american"))
				self playsound ("empire_GvA");
			else if ((game[team] == "german") && (game[team] == "russian"))
				self playsound ("empire_GvR");
			else 
				self playsound("empire_" + nationality + "_taunt");
		}
	}	
}


PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	// Update old team on death
	if(isdefined(level.empire_teamplay))
		self.empire_oldteam = self.sessionteam;
	else
		self.empire_oldteam = self.pers["team"];

	if(level.empire_disable)
	{
		if(!isdefined(self.autobalance))
		{
			body = self cloneplayer();
			self dropItem(self getcurrentweapon());
			self aweObituary(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc);
		}
		return;
	}

	self notify("empire_died");

	self cleanupPlayer1();

	if(!isdefined(level.empire_merciless) && level.empire_taunts)
		attacker thread taunts(self);

	dropTurret(undefined, sMeansOfDeath);

	// Check for headpopping
	switch(sHitLoc)
	{
		case "head":
		case "helmet":
			if( level.empire_popheadbullet && sMeansOfDeath != "MOD_MELEE" && (isWeaponType("rifle",sWeapon) || isWeaponType("sniper",sWeapon) || isWeaponType("turret",sWeapon)) )
				dopop = true;
			break;
		default:
			break;
	}
	switch(sMeansOfDeath)
	{
		case "MOD_MELEE":
			if(level.empire_popheadmelee && iDamage>=100 )
				dopop = true;
			break;
		case "MOD_PROJECTILE":
		case "MOD_PROJECTILE_SPLASH":
		case "MOD_GRENADE_SPLASH":
		case "MOD_EXPLOSIVE":
		case "MOD_ARTILLERY":
		case "MOD_ARTILLERY_SPLASH":
			if(level.empire_popheadexplosion && iDamage>=100 )
				dopop = true;
			break;
		default:
			break;
	}

	if(isdefined(dopop))
	{
		if(randomInt(100) < level.empire_pophead && !isdefined(self.empire_headpopped) )
			self popHead( vDir, iDamage);
		else if(randomInt(100) < level.empire_pophelmet && !isdefined(self.empire_helmetpopped) )
			self popHelmet( vDir, iDamage);
	}

	// Deathshock
	if(level.empire_deathshock && !isdefined(level.empire_merciless) )
	{
		self shellshock("death", 2);
	}

	if(!isdefined(self.autobalance))
	{
		// Drop weapon
		switch(level.empire_dropondeath)
		{
			case 1:
				self dropItem(self getcurrentweapon());
				break;
			case 2:
				angles = self.angles;
				self dropitem(self getWeaponSlotWeapon("primary"));
				self.angles = angles + (0,30,0);
				self dropitem(self getWeaponSlotWeapon("pistol"));
				self.angles = angles + (0,-30,0);
				self dropitem(self getWeaponSlotWeapon("grenade"));
				self.angles = angles + (0,60,0);
				self dropitem(self getWeaponSlotWeapon("primaryb"));
				if(!isdefined(level.empire_uo))
					break;
				self.angles = angles + (0,-60,0);
				self dropitem(self getWeaponSlotWeapon("smokegrenade"));
				self.angles = angles + (0,90,0);
				self dropitem(self getWeaponSlotWeapon("binocular"));
				self.angles = angles + (0,-90,0);
				self dropitem(self getWeaponSlotWeapon("satchel"));
				self.angles = angles;
				break;
			default:
				break;
		}
		// Handle body
		switch(level.empire_nobodies)
		{
			case 0:
				level thread handleBody(self,sMeansOfDeath);
				break;
			case 2:
				playfx(level.empire_burningbodies_smokefx,self.origin);
				break;
			default:
				break;
		}
	}

//	MonitorKills(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc);

	// Show obituarys?
	if(level.empire_obituary)
		self aweObituary(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc);
}

teamkill()
{
	if(level.empire_disable) return;

	if (!level.empire_teamkillmax)
		return;

	// Increase value
	self.pers["empire_teamkills"]++;

	// Check if it reached or passed the max level
	if (self.pers["empire_teamkills"]>=level.empire_teamkillmax)
	{
		if(level.empire_teamkillmethod)
			iprintln(self.name + " ^7has killed ^1" + self.pers["empire_teamkills"] + " ^7teammate(s) and will be punished.");
		if(level.empire_teamkillreflect)
			iprintln(self.name + " ^7has killed ^1" + self.pers["empire_teamkills"] + " ^7teammate(s) and will reflect damage.");

		self iprintlnbold(level.empire_teamkillmsg);
		self thread punishme(level.empire_teamkillmethod, "teamkilling");
		if(level.empire_teamkillreflect)
			self.pers["empire_teamkiller"] = true;
	}
	// Check if it reached or passed the warning level
	else if (self.pers["empire_teamkills"]>=level.empire_teamkillwarn)
	{
		if(level.empire_teamkillmethod)
			self iprintlnbold(level.empire_teamkillmax - self.pers["empire_teamkills"] + " ^7more teamkill(s) and you will be ^1punished^7!");
		else if(level.empire_teamkillreflect)
			self iprintlnbold(level.empire_teamkillmax - self.pers["empire_teamkills"] + " ^7more teamkill(s) and you will reflect damage!");
		else 
			self iprintlnbold(level.empire_teamkillmax - self.pers["empire_teamkills"] + " ^7more teamkill(s) and nothing will happen!");
	}
}

teamdamagedialog(victim)
{
	self notify("empire_teamdamagedialog");
	self endon("empire_teamdamagedialog");
	self endon("empire_died");
	self endon("empire_spawned");

	wait(0.25 + randomFloat(0.5));	// 0.25 - 0.75 second delay

	if(!isAlive(victim))
		return;

	if(randomInt(2))		// 50% chance
	{
		if(isdefined(level.empire_tdom)) 
			nationality = victim.nationality;
		else
		{
			team = victim.sessionteam;
			nationality = game[team];
		}

		if(randomInt(2))	// 50% chance
			scream = nationality + "_hold_fire";
		else			// 50% chance
		{
			if(nationality == "german")
				scream = nationality + "_are_you_crazy";
			else
				scream = nationality + "_youre_crazy";
		}
		victim playSound(scream);

		wait(1.25 + randomFloat(0.5));	// 1.25 - 1.75 second delay

		if(!isAlive(self))
			return;

		if(isdefined(level.empire_tdom)) 
			nationality = self.nationality;
		else
		{
			team = self.sessionteam;
			nationality = game[team];
		}
		scream = nationality + "_sorry";
		self playSound(scream);
	}
}

teamdamage(victim, damage)
{
	if(level.empire_disable) return;

	if(damage <= victim.health)
		self thread teamdamagedialog(victim);

	// Check if team damage is disabled
	if (!level.empire_teamdamagemax)
		return;

	// If damage is more than health left on victim, use health left.
	if(damage > victim.health)
		damage = victim.health;

	// Limit damage to 100
	if(damage>100)
		damage=100;

	// Increase value
	self.pers["empire_teamdamage"] += damage;

	// Check if it reached or passed the max level
	if (self.pers["empire_teamdamage"]>=level.empire_teamdamagemax)
	{
		if(level.empire_teamdamagemethod)
			iprintln(self.name + " ^7has caused ^1" + self.pers["empire_teamdamage"] + " ^7points of teamdamage and will be punished.");
		if(level.empire_teamdamagereflect)
			iprintln(self.name + " ^7has caused ^1" + self.pers["empire_teamdamage"] + " ^7points of teamdamage and will reflect damage.");

		self iprintlnbold(level.empire_teamdamagemsg);
		self thread punishme(level.empire_teamdamagemethod, "shooting teammates");
		if(level.empire_teamdamagereflect)
			self.pers["empire_teamkiller"] = true;
	}
	// Check if it reached or passed the warning level
	else if (self.pers["empire_teamdamage"]>=level.empire_teamdamagewarn)
	{
		if(level.empire_teamdamagemethod)
			self iprintlnbold(level.empire_teamdamagemax - self.pers["empire_teamdamage"] + " ^7points more teamdamage and you will be ^1punished^7!");
		else if(level.empire_teamdamagereflect)
			self iprintlnbold(level.empire_teamdamagemax - self.pers["empire_teamdamage"] + " ^7points more teamdamage and you will reflect damage!");
		else 
			self iprintlnbold(level.empire_teamdamagemax - self.pers["empire_teamdamage"] + " ^7points more teamdamage and nothing will happen!");
	}
}

punishme(iMethod, sReason)
{
	self endon("empire_spawned");
	self endon("empire_died");

	if(iMethod == 1)
		iMethod = 2 + randomInt(level.empire_punishments);

	switch (iMethod)
	{
		case 2:
			self suicide();
			sMethodname = "killed";
			break;

		case 3:
			wait 0.5;
			// play the hit sound
			self playsound("grenade_explode_default");
			// explode 
			playfx(level.empire_effect["bombexplosion"], self.origin);
			wait .05;
			self suicide();
			sMethodname = "blown up";
			break;
		
		case 4:
			// Drop weapon and get 15 seconds of spanking
			time = 15;

			self thread punishtimer(time,(0,1,0));

			self thread maps\mp\gametypes\_empire_uncommon::aweShellshock(time);
			self thread spankme(time);

			sMethodname = "spanked";
			break;

		default:
			break;
	}
	if(iMethod)
		iprintln(self.name + "^7 is being " + sMethodname + " ^7for " + sReason + "^7.");
}

punishtimer(time,color)
{
	// Remove timer if it exists
	if(isdefined(self.empire_punishtimer))
		self.empire_punishtimer destroy();

	// Set up timer
	self.empire_punishtimer = newClientHudElem(self);
	self.empire_punishtimer.archived = true;
	self.empire_punishtimer.x = 420;
	if(isdefined(level.empire_alternatehud))
		self.empire_punishtimer.y = 420;
	else
		self.empire_punishtimer.y = 460;
	self.empire_punishtimer.alignX = "center";
	self.empire_punishtimer.alignY = "middle";
	self.empire_punishtimer.alpha = 1;
	self.empire_punishtimer.sort = -3;
	self.empire_punishtimer.font = "bigfixed";
	self.empire_punishtimer.color = color;
	self.empire_punishtimer setTimer(time - 1);

	// Wait
	wait time;

	// Remove timer
	if(isdefined(self.empire_punishtimer))
		self.empire_punishtimer destroy();
}

spankme(time)
{
	self notify("empire_spankme");
	self endon("empire_spankme");
	self endon("empire_spawned");	
	self endon("empire_died");	

	for(i=0;i<(time*5);i++)
	{
		self setClientCvar("cl_stance", "2");
		self dropItem(self getcurrentweapon());
		wait 0.2;
	}
}

GetNextObjNum()
{
	num = level.empire_objnum_cur;
	level.empire_objnum_cur++;
	if(level.empire_objnum_cur > level.empire_objnum_max)
	{
		level.empire_objnum_cur = level.empire_objnum_min;
	}
	return num;
}

markme(icon, obj, time)
{
	self endon("empire_spawned");
	self endon("empire_died");
	self endon("not_afk");

	// Do not mark a player twice
	if(isdefined(self.empire_objnum))
		return;

	// gametype dm does not initialize level.drawfriend
	if(!isdefined(level.drawfriend))
		level.drawfriend = 0;

	if(obj == "camper" && isdefined(level.empire_teamplay))	// Check if we are marking a camper and it's team play
	{
		// Set up the headicon	
		headicon = "headicon_" + self.pers["team"];
		if(self.pers["team"] == "allies")
		{
			if(level.drawfriend)				// if scr_drawfriend=1 show headicon to all
				headiconteam = "none";	
			else							// Show only to other team
				headiconteam = "axis";

			objective = "radio_allies";			// Use radio objective
			objectiveteam = "axis";				// Show objective for other team
		}
		else
		{
			if(level.drawfriend)				// if scr_drawfriend=1 show headicon to all
				headiconteam = "none";	
			else
				headiconteam = "allies";		// Show only to other team

			objective = "radio_axis";
			objectiveteam = "allies";
		}
	}
	else
	{
		// Set up the headicon	
		headicon = "headicon_" + icon;
		headiconteam = "none";					// Show for both teams

		// Set up the objective	
		if (obj == "camper")					// If a camper in DM use default objective
			objective = "objective_default";
		else
			objective = "objective_" + obj;
		objectiveteam = "none";
	}

	self.headiconteam = headiconteam;

	// Mark player on compass
	objnum = GetNextObjNum();
	self.empire_objnum = objnum;
	objective_add(objnum, "current", self.origin, game[objective]);
	objective_team(objnum, objectiveteam);
	if(time)										// Time != 0 
	{
		for(i=0;( i<time && isPlayer(self) && isAlive(self) );i++)
		{
			// Update objective 20 times/second
			for(j=0;( j<20 && isPlayer(self) && isAlive(self) );j++)
			{
				// Flash objective and headicon for campers
				if((j==10) && obj == "camper")
				{
					self.headicon = game["headicon_star"];
					objective_icon(objnum, game["objective_default"]);
				}
				if((j==0) && obj == "camper")
				{
					self.headicon = game[headicon];
					objective_icon(objnum, game[objective]);
				}

				// Move objective
				objective_position(objnum, self.origin);		
				wait 0.05;
			}
		}
	}
	else											// If no time, mark forever
	{
		while( isPlayer(self) && isAlive(self) )
		{
			// Update objective 10 times/second
			for(j=0;( j<20 && isPlayer(self) && isAlive(self) );j++)
			{
				// Flash objective and headicon for campers
				if((j==10) && obj == "camper")
				{
					self.headicon = game["headicon_star"];
					objective_icon(objnum, game["objective_default"]);
				}
				if((j==0) && obj == "camper")
				{
					self.headicon = game[headicon];
					objective_icon(objnum, game[objective]);
				}

				// Move objective
				objective_position(objnum, self.origin);		
				wait 0.05;
			}
		}
	}

	if(isdefined(self.empire_objnum))
	{
		objective_delete(objnum);
		self.empire_objnum = undefined;
	}

	self restoreHeadicon(game["headicon_star"]);
}

findPlayArea()
{
	// Get all spawnpoints
	spawnpoints = [];
	temp = getentarray("mp_deathmatch_spawn", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_teamdeathmatch_spawn", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_searchanddestroy_spawn_allied", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_searchanddestroy_spawn_axis", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_retrieval_spawn_allied", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_retrieval_spawn_axis", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_uo_spawn_allies", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_uo_spawn_axis", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_gmi_bas_allies_spawn", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_gmi_bas_axis_spawn", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	// Initialize
	iMaxX = spawnpoints[0].origin[0];
	iMinX = iMaxX;
	iMaxY = spawnpoints[0].origin[1];
	iMinY = iMaxY;
	iMaxZ = spawnpoints[0].origin[2];
	iMinZ = iMaxZ;

	// Loop through the rest
	for(i = 1; i < spawnpoints.size; i++)
	{
		// Find max values
		if (spawnpoints[i].origin[0]>iMaxX)
			iMaxX = spawnpoints[i].origin[0];

		if (spawnpoints[i].origin[1]>iMaxY)
			iMaxY = spawnpoints[i].origin[1];

		if (spawnpoints[i].origin[2]>iMaxZ)
			iMaxZ = spawnpoints[i].origin[2];

		// Find min values
		if (spawnpoints[i].origin[0]<iMinX)
			iMinX = spawnpoints[i].origin[0];

		if (spawnpoints[i].origin[1]<iMinY)
			iMinY = spawnpoints[i].origin[1];

		if (spawnpoints[i].origin[2]<iMinZ)
			iMinZ = spawnpoints[i].origin[2];
	}

	level.empire_playAreaMin = (iMinX,iMinY,iMinZ);
	level.empire_playAreaMax = (iMaxX,iMaxX,iMaxZ);
}

findmapdimensions()
{
	// Get entities
	entitytypes = getentarray();

	// Initialize
	iMaxX = entitytypes[0].origin[0];
	iMinX = iMaxX;
	iMaxY = entitytypes[0].origin[1];
	iMinY = iMaxY;
	iMaxZ = entitytypes[0].origin[2];
	iMinZ = iMaxZ;

	// Loop through the rest
	for(i = 1; i < entitytypes.size; i++)
	{
		// Find max values
		if (entitytypes[i].origin[0]>iMaxX)
			iMaxX = entitytypes[i].origin[0];

		if (entitytypes[i].origin[1]>iMaxY)
			iMaxY = entitytypes[i].origin[1];

		if (entitytypes[i].origin[2]>iMaxZ)
			iMaxZ = entitytypes[i].origin[2];

		// Find min values
		if (entitytypes[i].origin[0]<iMinX)
			iMinX = entitytypes[i].origin[0];

		if (entitytypes[i].origin[1]<iMinY)
			iMinY = entitytypes[i].origin[1];

		if (entitytypes[i].origin[2]<iMinZ)
			iMinZ = entitytypes[i].origin[2];
	}

	// Get middle of map
	iX = (int)(iMaxX + iMinX)/2;
	iY = (int)(iMaxY + iMinY)/2;
	iZ = (int)(iMaxZ + iMinZ)/2;

      // Find iMaxZ
	iTraceend = iZ;
	iTracelength = 50000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iX,iY,iTracestart),(iX,iY,iTraceend), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMaxZ = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 
	
	if(level.empire_debug)
	{
		// Spawn stukas to mark center and corners that we got from the entities.
		stuka1 = spawn_model("xmodel/vehicle_plane_stuka","stuka1",(iX,iY,iMaxZ),(0,90,0));
		stuka11 = spawn_model("xmodel/vehicle_plane_stuka","stuka11",(iX,iY,iMaxZ - 200),(0,90,0));
		stuka12 = spawn_model("xmodel/vehicle_plane_stuka","stuka12",(iX,iY,iMaxZ - 400),(0,90,0));
		stuka4 = spawn_model("xmodel/vehicle_plane_stuka","stuka4",(iMaxX,iMaxY,iMaxZ),(0,90,0));
		stuka5 = spawn_model("xmodel/vehicle_plane_stuka","stuka5",(iMinX,iMinY,iMaxZ),(0,90,0));
		stuka6 = spawn_model("xmodel/vehicle_plane_stuka","stuka6",(iMaxX,iMinY,iMaxZ),(0,90,0));
		stuka7 = spawn_model("xmodel/vehicle_plane_stuka","stuka7",(iMinX,iMaxY,iMaxZ),(0,90,0));
	}

	// Find iMaxX
	iTraceend = iX;
	iTracelength = 100000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iTracestart,iY,iZ),(iTraceend,iY,iZ), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMaxX = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 
	
	// Find iMaxY
	iTraceend = iY;
	iTracelength = 100000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iX,iTracestart,iZ),(iX,iTraceend,iZ), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMaxY = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 

	// Find iMinX
	iTraceend = iX;
	iTracelength = 100000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iTracestart,iY,iZ),(iTraceend,iY,iZ), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMinX = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 
	
	// Find iMinY
	iTraceend = iY;
	iTracelength = 100000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iX,iTracestart,iZ),(iX,iTraceend,iZ), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMinY = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 

	// Find iMinZ
	iTraceend = iZ;
	iTracelength = 50000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iX,iY,iTracestart),(iX,iY,iTraceend), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMinZ = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 
	if(level.empire_debug)
	{
		// Spawn stukas to mark the corner we got from bulletTracing
		stuka14 = spawn_model("xmodel/vehicle_plane_stuka","stuka14",(iMaxX,iMaxY,iMaxZ-200),(0,90,0));
		stuka15 = spawn_model("xmodel/vehicle_plane_stuka","stuka15",(iMinX,iMinY,iMaxZ-200),(0,90,0));
		stuka16 = spawn_model("xmodel/vehicle_plane_stuka","stuka16",(iMaxX,iMinY,iMaxZ-200),(0,90,0));
		stuka17 = spawn_model("xmodel/vehicle_plane_stuka","stuka17",(iMinX,iMaxY,iMaxZ-200),(0,90,0));
	}
	level.empire_vMax = (iMaxX, iMaxY, iMaxZ);
	level.empire_vMin = (iMinX, iMinY, iMinZ);
}

// Done on death/spawn and disconnect
cleanupPlayer1()
{
	// Destroy hud elements
	if(isdefined(self.empire_turretmessage))	self.empire_turretmessage destroy();
	if(isdefined(self.empire_turretmessage2))	self.empire_turretmessage2 destroy();
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
	if(isdefined(self.empire_pickbarbackground))	self.empire_pickbarbackground destroy();
	if(isdefined(self.empire_pickbar))		self.empire_pickbar destroy();
	if(isdefined(self.empire_plantbarbackground))	self.empire_plantbarbackground destroy();
	if(isdefined(self.empire_plantbar))		self.empire_plantbar destroy();
	if(isdefined(self.empire_weaponselectmsg))	self.empire_weaponselectmsg destroy();
	if(isdefined(self.empire_laserdot))		self.empire_laserdot destroy();
	if(isdefined(self.empire_punishtimer))		self.empire_punishtimer destroy();
	if(isdefined(self.empire_camptimer))		self.empire_camptimer destroy();
	if(isdefined(self.empire_cookbar))		self.empire_cookbar destroy();
	if(isdefined(self.empire_cookbarbackground))	self.empire_cookbarbackground destroy();
	if(isdefined(self.empire_cookbartext))		self.empire_cookbartext destroy();
	if(isdefined(self.empire_hitblip))		self.empire_hitblip destroy();
	if(isdefined(self.empire_spawnprotection))	self.empire_spawnprotection destroy();
	if(isdefined(self.empire_sprinthud))		self.empire_sprinthud destroy();
	if(isdefined(self.empire_sprinthud_back))	self.empire_sprinthud_back destroy();
	if(isdefined(self.empire_sprinthud_hint))	self.empire_sprinthud_hint destroy();
	if(isdefined(self.empire_dropfirstaid))	self.empire_dropfirstaid destroy();
	if(isdefined(self.empire_gettingfirstaid))	self.empire_gettingfirstaid destroy();
	if(isdefined(self.empire_firstaidicon))	self.empire_firstaidicon destroy();
	if(isdefined(self.empire_firstaidkits)) 	self.empire_firstaidkits destroy();		

	// Remove compass objective if present
	if(isdefined(self.empire_objnum))
	{
		objective_delete(self.empire_objnum);
		self.empire_objnum = undefined;
	}

	// Remove parachute if present
	if(isdefined(self.empire_parachute))
		self.empire_parachute delete();
	if(isdefined(self.empire_anchor))
		self.empire_anchor delete();
}

// Done on spawn and disconnect
cleanupPlayer2()
{
	// Remove painscreen and bloodyscreen if present
	if (isDefined(self.empire_painscreen))
		self.empire_painscreen destroy();
	if (isDefined(self.empire_bloodyscreen))
		self.empire_bloodyscreen destroy();
	if (isDefined(self.empire_bloodyscreen1))
		self.empire_bloodyscreen1 destroy();
	if (isDefined(self.empire_bloodyscreen2))
		self.empire_bloodyscreen2 destroy();
	if (isDefined(self.empire_bloodyscreen3))
		self.empire_bloodyscreen3 destroy();

	// Remove bulletholes if present
	if(isdefined(self.empire_bulletholes))
		if(self.empire_bulletholes.size)
			for(i=0;i<self.empire_bulletholes.size;i++)
				if(isdefined(self.empire_bulletholes[i]))
					self.empire_bulletholes[i] destroy();
}

spawnPlayer()
{
	// Needed for MercilessUO if empire_mod has been disabled.
	self.empire_helmetpopped = undefined;

	if(level.empire_disable) return;

	self notify("empire_spawned");

	dropTurret(undefined, undefined);	// Just in case...

	if(!isdefined(self.pers["empire_teamkills"]))
		self.pers["empire_teamkills"] = 0;

	if(!isdefined(self.pers["empire_teamdamage"]))
		self.pers["empire_teamdamage"] = 0;

	if(!isdefined(self.empire_pace))
		self.empire_pace = 0;

	self.empire_killspree = 0;

	// Reset flags
	self.empire_disableprimaryb = undefined;
	self.empire_invulnerable = undefined;
	self.empire_isparachuting = undefined;
	self.empire_helmetpopped = undefined;
	self.empire_headpopped = undefined;
	self.empire_usingturret = undefined;
	self.empire_touchingturret = undefined;
	self.empire_placingturret = undefined;
	self.empire_pickingturret = undefined;
	self.empire_cooking = undefined;
	self.empire_tripwirewarning = undefined;
	self.empire_checkdefusetripwire = undefined;
	self.empire_checkdefusesatchel = undefined;
	self.empire_checkbodysearch = undefined;
	self.empire_checkstickyplacement = undefined;
	self.empire_camper = undefined;
	self.empire_nohealthpack = undefined;
	self.empire_body = undefined;
	self.empire_sprinting = undefined;

	self cleanupPlayer1();
	self cleanupPlayer2();

	// Force weapons
	if(!isdefined(level.empire_classbased))
		self forceWeapons(game[self.pers["team"]]);
	
	// Limit/Randomize ammo
	self ammoLimiting();

	// Parachute?
	if( level.empire_parachutes && !isdefined(self.empire_haveparachuted) && ( !level.empire_parachutesonlyattackers || game["attackers"] == self.pers["team"] ) )
		self thread PlayerParachute();

        self thread monitorme();
        self thread monitorInput();
        self thread monitorWeaponSwitch();
        self thread monitorMenuResponse();
        self thread monitorStanceChange();

	if(level.empire_grenadewarning || level.empire_turretmobile || level.empire_tripwire || level.empire_satchel || level.empire_stickynades || level.empire_showcooking)
		self thread whatscooking();

	if(level.empire_sprint)
		self thread monitorsprinting();
	else if(isdefined(level.empire_uo) && level.empire_uosprint == 3)
		self thread monitoruosprinting();

	// Announce next map and display server messages
	if(level.empire_messageindividual)
		self thread serverMessages();

	if(getcvar("empire_welcome0") != "")
		self thread showWelcomeMessages();

	// Cold breath
	if(isdefined(level.empire_uo) && isdefined(level.empire_wintermap) && level.empire_coldbreath)
		self thread breath_fx();	

	// Laserdot
	if(level.empire_laserdot)
	{
		if(!isdefined(self.empire_laserdot))
		{
			self.empire_laserdot = newClientHudElem(self);
			self.empire_laserdot.x = 320;
			self.empire_laserdot.y = 240;
			self.empire_laserdot.alignX = "center";
			self.empire_laserdot.alignY = "middle";
			self.empire_laserdot.alpha = level.empire_laserdot;
			self.empire_laserdot.color = (level.empire_laserdotred, level.empire_laserdotgreen, level.empire_laserdotblue);
			self.empire_laserdot setShader("white", level.empire_laserdotsize, level.empire_laserdotsize );
		}
	}

	// Check if player is using a private slot
	if(!isdefined(self.empire_privateplayer))
	{
		privateslots = getcvarint("sv_privateclients");
		if(isdefined(privateslots) && privateslots)
		{
			if(self getEntityNumber() < privateslots)
				self.empire_privateplayer = true;
		}
	}

	// Wait for threads to die
	wait .05;
	// Make sure the invulnerable flag is clear
	self.empire_invulnerable = undefined;

	if(level.empire_spawnprotection)
		self thread spawnprotection();

	// Handle the Unknown Soldiers
	if(self.name == "Unknown Soldier")
	{
		// Rename Unknown Soldiers
		// Get names
		names = [];
		count = 0;
		name = cvardef("empire_unknown_name" + count, "", "", "", "string");
		while(name != "")
		{
			names[names.size] = name;
			count++;
			name = cvardef("empire_unknown_name" + count, "", "", "", "string");
			wait .05; // Avoid infinite loop complaints.
		}
		if(names.size)
		{
			self.pers["empire_unknown_name"] = names[randomInt(names.size)] + " " + randomInt(1000);
			self setClientCvar("name", self.pers["empire_unknown_name"]);
			if(level.empire_unknownrenamemsg != "none")
				self iprintlnbold(level.empire_unknownrenamemsg);
		}

		// Make sure an unknown player can't do much damage
		if(level.empire_unknownreflect)
			self.pers["empire_teamkiller"] = true;
	}

	if(isdefined(level.empire_teamplay) && level.empire_firstaid)
		self thread firstaid();

	if(!isdefined(level.empire_merciless) && level.empire_zombie && level.empire_pophead)
		self thread zombie();

	// Track old team to be able to detect team changes
	if(!isdefined(self.empire_oldteam))
		self.empire_oldteam = self.pers["team"];
	else if(self.empire_oldteam != self.pers["team"])
		self thread delayoldteam();
}

delayoldteam()
{
	self endon("empire_spawned");
	self endon("empire_died");

	// Wait longer for uo since they may have thrown a satchel before switching teams
	if(isdefined(level.empire_uo))
		wait 6;
	else
		wait 4;
	if(isdefined(level.empire_teamplay))
		self.empire_oldteam = self.sessionteam;
	else
		self.empire_oldteam = self.pers["team"];
}

// First Aid kits
firstaid()
{
	self endon("empire_spawned");
	self endon("empire_died");

	if(isdefined(self.empire_firstaidicon))
		return;

	if(getcvar("g_gametype") == "bel" || getcvar("g_gametype") == "mc_bel")
	{
		xoff = -80;
		yoff = 0;
	}
	else if(getcvar("g_gametype") == "hq" || getcvar("g_gametype") == "mc_hq")
	{
		xoff = 0;
		yoff = -18;
	}
	else
	{
		xoff = 0;
		yoff = 0;
	}


	for(j=0;j<level.empire_firstaidkits;)
	{
		self.empire_firstaidicon = newClientHudElem(self);
		self.empire_firstaidicon.alignX = "center";
		self.empire_firstaidicon.alignY = "middle";
		self.empire_firstaidicon.x = 560+xoff;
		self.empire_firstaidicon.y = 410+yoff;
		self.empire_firstaidicon.alpha = 1;
		self.empire_firstaidicon setShader(game["firstaid"], 32, 32);

		if(level.empire_firstaidkits>1 && !isdefined(self.empire_firstaidkits))
		{
			self.empire_firstaidkits = newClientHudElem(self);
			self.empire_firstaidkits.alignX = "center";
			self.empire_firstaidkits.alignY = "middle";
			self.empire_firstaidkits.x = 567+xoff;
			self.empire_firstaidkits.y = 415+yoff;
			self.empire_firstaidkits.alpha = 1;
			self.empire_firstaidkits.color = (1,1,1);
			self.empire_firstaidkits.fontscale = 0.8;
			self.empire_firstaidkits setValue(level.empire_firstaidkits);
		}

		while(isalive(self) && self.sessionstate == "playing" && isdefined(self.empire_firstaidicon))
		{
			wait 0.05;

			// wait for player to press the USE key (while on ground and not sprinting)
			while(isalive(self) && self.sessionstate == "playing")
			{
				if(!self.empire_pace && self useButtonPressed() && self isOnGround())
					break;
				wait 0.05;
			}

			if(!(isalive(self) && self.sessionstate == "playing")) // if they've been killed
				break;

			for(i = 0; i < level.empire_allplayers.size; i++)
			{
				if(isdefined(level.empire_allplayers[i]))
				{
					if(level.empire_allplayers[i] == self)
						continue;	// can't heal yourself

					if(level.empire_allplayers[i].sessionteam == self.sessionteam			// teammate
						&& isalive(level.empire_allplayers[i])						// who is playing
						&& level.empire_allplayers[i].health <= 80					// and is injured
						&& !isdefined(level.empire_allplayers[i].empire_gettingfirstaid)		// and is not currently being treated
						&& distance(level.empire_allplayers[i].origin, self.origin) < 48	// and within 4 feet of player
					){
						targetPlayer = level.empire_allplayers[i];
						break;
					}
				}
			}

			if(!isdefined(targetPlayer))
				continue;  // not in range of any friendlies that need healing

			// all systems go, commence healing

			// wait 0.5 seconds (make sure they mean it, are holding USE)
			holdtime = 0;
			while(self useButtonPressed() && holdtime < 0.5
				&& self isOnGround()
				&& targetPlayer isOnGround()
			){
				holdtime += 0.05;
				wait 0.05;
			}
			if(holdtime < 0.5)
				continue;

			if(!isalive(self) || !isalive(targetPlayer))
				continue;	

			if(isdefined(self.defuseicon)) // can't heal while defusing a bomb
				continue;

			healamount = (level.empire_firstaidhealth + randomInt(15));	// (25 to 40 health)
			healtime = (float)healamount * .1;

			// set up the healing icon on the target
			targetPlayer.empire_gettingfirstaid = newClientHudElem(targetPlayer);
			targetPlayer.empire_gettingfirstaid .alignX = "center";
			targetPlayer.empire_gettingfirstaid.alignY = "middle";
			targetPlayer.empire_gettingfirstaid.x = 320;
			targetPlayer.empire_gettingfirstaid.y = 240;
			targetPlayer.empire_gettingfirstaid.alpha = 0;
			targetPlayer.empire_gettingfirstaid setShader(game["firstaid"], 1, 1);

			targetPlayer.empire_gettingfirstaid scaleOverTime(0.5, 64, 64);
			targetPlayer.empire_gettingfirstaid fadeOverTime(0.5);
			targetPlayer.empire_gettingfirstaid.alpha = 0.5;

			// spawn a script origin, and lock the players in place
			origin = spawn("script_origin", self.origin);
			self linkTo(origin);
			targetPlayer linkTo(origin);

			self.empire_dropfirstaid = newClientHudElem(self);
			self.empire_dropfirstaid.alignX = "center";
			self.empire_dropfirstaid.alignY = "middle";
			self.empire_dropfirstaid.x = 560+xoff;
			self.empire_dropfirstaid.y = 240+yoff;
			self.empire_dropfirstaid.alpha = 0;
			self.empire_dropfirstaid setShader(game["firstaid"], 32, 32);

			self.empire_dropfirstaid fadeOverTime(0.5);
			self.empire_dropfirstaid.alpha = 0.25;
			self.empire_dropfirstaid scaleOverTime(0.5, 64, 64);

			self.empire_firstaidicon moveOverTime(healtime);
			self.empire_firstaidicon.y = 240+yoff;
			self.empire_firstaidicon scaleOverTime(healtime, 64, 64);


			healnow = 0;
			holdtime = 0;
			while(self useButtonPressed()					// still holding the USE key
				&& !(self meleeButtonPressed())			// player hasn't melee'd
				&& !(targetPlayer meleeButtonPressed())		// target hasn't melee'd
				&& !(self attackButtonPressed())			// player hasn't fired
				&& !(targetPlayer attackButtonPressed())		// target hasn't fired
				&& isalive(self) && isalive(targetPlayer) 	// both still alive
				&& targetPlayer.health < 100 				// hasn't filled target's health
				&& healamount > 0						// hasn't run out of healamount
			){
				if(healnow == 1)
				{
					targetPlayer.health++;  // 10 health per second, 1 point every other 1/20th of a second (server frame)
										// had to do that 'cause of integer rounding issues
					healamount--;
					healnow = -1;
				}
				healnow++;

				holdtime += 0.05;
				wait 0.05;
			}

			if((healamount == 0 || targetPlayer.health == 100) && isalive(targetPlayer) && isalive(self))
			{
				iprintln(self.name + "^7 patched up " + targetPlayer.name);
				if(isdefined(self.pers["score"]))
					self.pers["score"]++;
				self.score++;
			}

			// release from script origin, delete script origin
			self unlink();
			targetPlayer unlink();
			origin delete();

			// explode and fade-out firstaid kit (and the drop marker), destroy shader
			if(isdefined(targetPlayer) && isdefined(targetPlayer.empire_gettingfirstaid))
			{
				targetPlayer.empire_gettingfirstaid scaleOverTime(0.5, 1, 1);
				targetPlayer.empire_gettingfirstaid fadeOverTime(0.5);
				targetPlayer.empire_gettingfirstaid.alpha = 0;
			}

			if(isdefined(self) && isdefined(self.empire_dropfirstaid))
			{
				self.empire_dropfirstaid fadeOverTime(0.5);
				self.empire_dropfirstaid.alpha = 0;
			}

			if(isdefined(self) && isdefined(self.empire_firstaidicon))
			{
				self.empire_firstaidicon scaleOverTime(0.5, 128, 128);
				self.empire_firstaidicon fadeOverTime(0.5);
				self.empire_firstaidicon.alpha = 0;
			}

			wait 0.5;

			if(isdefined(self))
			{
				if(isdefined(self.empire_firstaidicon))
					self.empire_firstaidicon destroy();		
				if(isdefined(self.empire_dropfirstaid))
					self.empire_dropfirstaid destroy();
				if(isdefined(targetPlayer.empire_gettingfirstaid))
					targetPlayer.empire_gettingfirstaid destroy();
			}
		}

		if(isdefined(self.empire_firstaidicon)) // in case they were killed, but not healing a teammate, or got a bomb
			self.empire_firstaidicon destroy();		

		j++;

		if(isdefined(self.empire_firstaidkits)) 
			self.empire_firstaidkits setValue(level.empire_firstaidkits - j);

		if(j<level.empire_firstaidkits)
			wait level.empire_firstaiddelay;
		else
			break;

//		if(isdefined(self.empire_firstaidkits)) 
//			self.empire_firstaidkits destroy();		

		if(!(isalive(self) && self.sessionstate == "playing")) // if they've been killed
			break;

	}
	if(isdefined(self.empire_firstaidkits)) 
		self.empire_firstaidkits destroy();		
}

zombie()
{
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");

	wait 5+randomInt(10);

	self popHead( (-0.2 + randomFloat(0.4),-0.2 + randomFloat(0.4),1) , 100 + randomInt(100));

	while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" )
	{
		wait 2+randomInt(5);
		playfxontag(level.empire_popheadfx,self,"Bip01 Head");
	}
}

isUnknown()
{
	if(self.name == "Unknown Soldier" || (isdefined(self.pers["empire_unknown_name"]) && self.name == self.pers["empire_unknown_name"]) )
		return true;
	else
		return false;
}

/*
timedLine(from, to, time)
{
	for(i=(float)0;i<time;i+=.05)
	{
		line(from,to,(1,0,0));
		wait .05;
	}
}
*/

rain()
{
	level endon("empire_boot");

	radius = 2000;
	radius2 = radius + 1732;

	if(getcvar("mapname")!="mp_pavlov")
	{	// Find center of spawnarea
		x = level.empire_playAreaMin[0] + (level.empire_playAreaMax[0] - level.empire_playAreaMin[0]) / 2;
		y = level.empire_playAreaMin[1] + (level.empire_playAreaMax[1] - level.empire_playAreaMin[1]) / 2;
		z = level.empire_playAreaMin[2] + (level.empire_playAreaMax[2] - level.empire_playAreaMin[2]) / 2;
		zoffset = level.empire_vMax[2] - z;
		if(zoffset > 1000) zoffset = 1000;
		center = (x,y,z + zoffset);
	}
	else
	{
		center = (-9518,10260,909);
	}

//	plane = spawn("script_model",center);
//	plane setModel("xmodel/vehicle_plane_stuka");
//	plane show();

	delay = 0.35;
	for(;;)
	{
		angle = randomInt(60);
		for(i=0;i<3;i++)
		{
			offset = maps\mp\_utility::vectorScale(anglestoforward((0,angle + i*60,0)),radius);
			origin = center + offset;
			playfx(level.empire_rainfx,origin);
			origin = center - offset;
			playfx(level.empire_rainfx,origin);
			wait .05;
		}				// 0.15s
		for(i=0;i<3;i++)
		{
			offset = maps\mp\_utility::vectorScale(anglestoforward((0,angle + i*60 + 30,0)),radius2);
			origin = center + offset;
			playfx(level.empire_rainfx,origin);
			origin = center - offset;
			playfx(level.empire_rainfx,origin);
			wait .05;
		}				// 0.15s (0.3s)
		playfx(level.empire_rainfx,center);
		wait .05;			// 0.05s (0.35s)
	}
}

limitAmmo(slot)
{
	if(level.empire_ammomin == 100)
		return;

	if(self getWeaponSlotWeapon(slot) == "panzerfaust_mp" || self getWeaponSlotWeapon(slot) == "flamethrower_mp")
		return;

	if(!level.empire_ammomax)
		ammopc = 0;
	else if(level.empire_ammomin == level.empire_ammomax)
		ammopc = level.empire_ammomin;
	else
		ammopc = level.empire_ammomin + randomInt(level.empire_ammomax - level.empire_ammomin + 1);

	iAmmo = self getWeaponSlotAmmo(slot) + self getWeaponSlotClipAmmo(slot);
	iAmmo = (int)(iAmmo * ammopc*0.01 + 0.5);
	
	// If no ammo, remove weapon
	if(!iAmmo)
		self setWeaponSlotWeapon(slot, "none");
	else
	{
		self setWeaponSlotClipAmmo(slot,iAmmo);
		iAmmo = iAmmo - self getWeaponSlotClipAmmo(slot);
		if(iAmmo < 0) iAmmo = 0;	// this should never happen
		self setWeaponSlotAmmo(slot, iAmmo);
	}
}

ammoLimiting()
{
	self limitAmmo("primary");
	self limitAmmo("primaryb");
	self limitAmmo("pistol");

	// Set weapon based grenade count
	if(!isdefined(level.empire_classbased))
	{
		if(level.empire_grenadecount)
			grenadecount = level.empire_grenadecount;
		else
		{
			if(isdefined(self.empire_grenadeforced))
				grenadecount = maps\mp\gametypes\_teams::getWeaponBasedGrenadeCount(self getWeaponSlotWeapon("primary"));
			else
			{
				grenadecount = self getWeaponSlotClipAmmo("grenade");
			}
		}
	}
	else
	{
		grenadecount = self getWeaponSlotClipAmmo("grenade");
	}

	// Randomize grenade count?
	if(grenadecount && level.empire_grenadecountrandom)
	{
		if(level.empire_grenadecountrandom == 1)
			grenadecount = randomInt(grenadecount) + 1;
		if(level.empire_grenadecountrandom == 2)
			grenadecount = randomInt(grenadecount + 1);
	}

	// If no grenades, remove weapon
	if(!grenadecount)
		self setWeaponSlotWeapon("grenade", "none");
	else
		self setWeaponSlotClipAmmo("grenade", grenadecount);

	// UO?
	if(!isdefined(level.empire_uo))
		return;

	// Set weapon based smokegrenade count
	if(!isdefined(level.empire_classbased))
	{
		if(level.empire_smokegrenadecount)
			smokegrenadecount = level.empire_smokegrenadecount;
		else
		{
			if(isdefined(self.empire_smokegrenadeforced))
				smokegrenadecount = maps\mp\gametypes\_empire_uncommon::aweGetWeaponBasedSmokeGrenadeCount(self getWeaponSlotWeapon("primary"));
			else
			{
				smokegrenadecount = self getWeaponSlotClipAmmo("smokegrenade");
			}
		}
	}
	else
	{
		smokegrenadecount = self getWeaponSlotClipAmmo("smokegrenade");
	}

	// Randomize smokegrenade count?
	if(smokegrenadecount && level.empire_smokegrenadecountrandom)
	{
		if(level.empire_smokegrenadecountrandom == 1)
			smokegrenadecount = randomInt(smokegrenadecount) + 1;
		if(level.empire_smokegrenadecountrandom == 2)
			smokegrenadecount = randomInt(smokegrenadecount + 1);
	}

	// If no smokegrenades, remove weapon
	if(!smokegrenadecount)
		self setWeaponSlotWeapon("smokegrenade", "none");
	else
	{
		if(self getWeaponSlotWeapon("smokegrenade") == "none")
			self setWeaponSlotWeapon("smokegrenade", "smokegrenade_mp");
		self setWeaponSlotClipAmmo("smokegrenade", smokegrenadecount);
	}

	// Give satchel
	if(level.empire_satchelcount)
	{
		if(self getWeaponSlotWeapon("satchel") == "none")
			self setWeaponSlotWeapon("satchel", "satchelcharge_mp");
		self setWeaponSlotClipAmmo("satchel", level.empire_satchelcount);
	}
}

randomWeapon(team)
{
	warray = [];
	primary = self getWeaponSlotWeapon("primary");
	switch(team)
	{
		case "american":
			if(level.allow_m1carbine=="1" && primary != "m1carbine_mp") 	warray[warray.size] = "m1carbine_mp";
			if(level.allow_m1garand=="1" && primary != "m1garand_mp")		warray[warray.size] = "m1garand_mp";
			if(level.allow_thompson=="1" && primary != "thompson_mp")		warray[warray.size] = "thompson_mp";
			if(level.allow_bar=="1" && primary != "bar_mp")				warray[warray.size] = "bar_mp";
			if(level.allow_springfield=="1" && primary != "springfield_mp")	warray[warray.size] = "springfield_mp";
			if(level.allow_mg30cal=="1" && primary != "mg30cal_mp")		warray[warray.size] = "mg30cal_mp";
			break;

		case "british":
			if(level.allow_enfield=="1" && primary != "enfield_mp")		warray[warray.size] = "enfield_mp";
			if(level.allow_sten=="1" && primary != "sten_mp")			warray[warray.size] = "sten_mp";
			if(level.allow_bren=="1" && primary != "bren_mp")			warray[warray.size] = "bren_mp";
			if(level.allow_springfield=="1" && primary != "springfield_mp")	warray[warray.size] = "springfield_mp";
			if(level.allow_mg30cal=="1" && primary != "mg30cal_mp")		warray[warray.size] = "mg30cal_mp";
			break;

		case "russian":
			if(level.allow_nagant=="1" && primary != "mosin_nagant_mp")				warray[warray.size] = "mosin_nagant_mp";
			if(level.allow_ppsh=="1" && primary != "ppsh_mp")					warray[warray.size] = "ppsh_mp";
			if(level.allow_nagantsniper=="1" && primary != "mosin_nagant_sniper_mp")	warray[warray.size] = "mosin_nagant_sniper_mp";
			if(level.allow_svt40=="1" && primary != "svt40_mp")					warray[warray.size] = "svt40_mp";
			if(level.allow_dp28=="1" && primary != "dp28_mp")					warray[warray.size] = "dp28_mp";
			break;

		default:
			if(level.allow_kar98k=="1" && primary != "kar98k_mp")				warray[warray.size] = "kar98k_mp";
			if(level.allow_mp40=="1" && primary != "mp40_mp")				warray[warray.size] = "mp40_mp";
			if(level.allow_mp44=="1" && primary != "mp44_mp")				warray[warray.size] = "mp44_mp";
			if(level.allow_kar98ksniper=="1" && primary != "kar98k_sniper_mp")	warray[warray.size] = "kar98k_sniper_mp";
			if(level.allow_gewehr43=="1" && primary != "gewehr43_mp")			warray[warray.size] = "gewehr43_mp";
			if(level.allow_mg34=="1" && primary != "mg34_mp")				warray[warray.size] = "mg34_mp";
			break;
	}
	if(warray.size)
		return warray[randomInt(warray.size)];
	else
		return "none";
}

forceWeapons(team)
{
	// Force primary
	if(level.empire_primaryweapon[team]!="")
		weapon = level.empire_primaryweapon[team];
	else
		weapon = level.empire_primaryweapon["default"];
	if(weapon != "")
	{
		if(!level.empire_uomap || isWeaponType(game["allies"],weapon)|| isWeaponType(game["axis"],weapon) || isWeaponType("common",weapon) || weapon == "none" )
		{
			self forceWeapon("primary", weapon);
			self setSpawnWeapon(weapon);
		}
	}

	// Force secondary
	if(level.empire_secondaryweapon[team]!="")
		weapon = level.empire_secondaryweapon[team];
	else
		weapon = level.empire_secondaryweapon["default"];
	if(weapon != "")
	{
		if(!level.empire_uomap || isWeaponType(game["allies"],weapon)|| isWeaponType(game["axis"],weapon) || isWeaponType("common",weapon) || weapon == "none" || weapon == "disable" || weapon == "select" || weapon == "selectother" || weapon == "random" || weapon == "randomother" )
		{
			switch(weapon)
			{
				case "disable":
					self.empire_disableprimaryb = true;
					weapon = "none";
					break;
				case "random":
					weapon = self randomWeapon(team);
					break;
				case "randomother":
					if(team == game["allies"])
						team = game["axis"];
					else
						team = game["allies"];
					weapon = self randomWeapon(team);
					break;
				default:
					break;
			}
			self forceWeapon("primaryb", weapon);
		}
	}

	// Force pistol
	if(level.empire_pistoltype[team]!="")
		weapon = level.empire_pistoltype[team];
	else
		weapon = level.empire_pistoltype["default"];
	if(weapon != "")
		if(!level.empire_uomap || isWeaponType(game["allies"],weapon)|| isWeaponType(game["axis"],weapon) || isWeaponType("common",weapon) || weapon == "none")
			self forceWeapon("pistol", weapon);

	// Force grenade
	if(level.empire_grenadetype[team]!="")
		weapon = level.empire_grenadetype[team];
	else
		weapon = level.empire_grenadetype["default"];
	if(weapon != "")
	{
		if(!level.empire_uomap || isWeaponType(game["allies"],weapon)|| isWeaponType(game["axis"],weapon) || isWeaponType("common",weapon) || weapon == "none")
		{
			self forceWeapon("grenade", weapon);
			self.empire_grenadeforced = true;
		}
	}
	else
		self.empire_grenadeforced = undefined;

	// Force smokegrenade
	if(level.empire_smokegrenadetype[team]!="")
		weapon = level.empire_smokegrenadetype[team];
	else
		weapon = level.empire_smokegrenadetype["default"];
	if(weapon != "")
	{
		self forceWeapon("smokegrenade", weapon);
		self.empire_smokegrenadeforced = true;
	}
	else
		self.empire_smokegrenadeforced = undefined;
}	

forceWeapon(slot, weapon)
{
	oldweapon = self getWeaponSlotWeapon(slot);

	// Keep existing secondary weapon, in roundbased gametypes.
	if(slot == "primaryb" && oldweapon != "none"  && level.empire_secondaryweaponkeepold)
		return;

	if(slot == "primaryb" && (weapon == "select" || weapon == "selectother") )
	{
		team = self.pers["team"];
		primaryweapon = self getWeaponSlotWeapon("primary");

		// Check if primary weapon has been changed
		if( isdefined(self.pers["empire_oldprimary_" + team]) && isdefined(self.pers["empire_oldprimaryb_" + team]) )
		{
			if(primaryweapon == self.pers["empire_oldprimary_" + team])
			{
				weapon = self.pers["empire_oldprimaryb_" + team];
				skipmenu = true;
			}
			else
				skipmenu = undefined;
		}

		if(!isdefined(skipmenu))
		{
			self setClientCvar("ui_weapontab", "1");

			self.empire_weaponselectmsg = newClientHudElem(self);
			self.empire_weaponselectmsg.archived = false;
			self.empire_weaponselectmsg.x = 320;
			self.empire_weaponselectmsg.y = 400;
			self.empire_weaponselectmsg.alignX = "center";
			self.empire_weaponselectmsg.alignY = "middle";
			self.empire_weaponselectmsg.fontScale = 2;
			self.empire_weaponselectmsg setText(level.empire_secondaryweapontext);

			if(self.pers["team"] == "allies")
			{
				if(weapon == "select")
					self openMenu(game["menu_weapon_allies"]);
				else
					self openMenu(game["menu_weapon_axis"]);
			}
			else
			{
				if(weapon == "select")
					self openMenu(game["menu_weapon_axis"]);
				else
					self openMenu(game["menu_weapon_allies"]);
			}
		
                        for(;;)
                        {
                                self waittill("menuresponse", menu, response);
                                NotAFK();

				if(response == "open")
					continue;	

				if(response == "close")
				{
					weapon = oldweapon;
					break;
				}	

				if(response == "callvote" || response == "team" || response == "viewmap" )
				{
					weapon = oldweapon;
					break;
				}

				weapon = self maps\mp\gametypes\_teams::restrict_anyteam(response);
				if(weapon == "restricted" || weapon == primaryweapon)
				{
					self openMenu(menu);
					continue;
				}
				else
					break;
			}
			// Clean up
			self closeMenu();
			wait .1;
			self closeMenu();

			// Restore primary in case it has been messed up by the menu handling in playerconnect.
			self.pers["weapon"] = primaryweapon;
		 	self setWeaponSlotWeapon("primary", primaryweapon);
			self setWeaponSlotAmmo("primary", 999);
			self setWeaponSlotClipAmmo("primary", 999);
			self setSpawnWeapon(primaryweapon);

			// Save values so that we can detect a weapon change
			self.pers["empire_oldprimary_" + team] = primaryweapon;
			self.pers["empire_oldprimaryb_" + team] = weapon;
		}
	}

	if(isdefined(self.empire_weaponselectmsg))
		self.empire_weaponselectmsg destroy();

	// Weapon change?
	if(oldweapon != weapon)
	{
		// Remove current weapon
		self takeWeaponSlotWeapon(slot);

		// Set new weapon
		if(weapon != "none")
		{
		 	self setWeaponSlotWeapon(slot, weapon);
			if(slot != "grenade")
			{
				self setWeaponSlotAmmo(slot, 999);
				self setWeaponSlotClipAmmo(slot, 999);
			}
			// Print message to player
			if(oldweapon == "none")
				self iprintln("You have been equipped with a " + getWeaponName(weapon) + ".");
			else
				self iprintln("Your " + getWeaponName(oldweapon) + " has been replaced with a " + getWeaponName(weapon) + ".");
		}
		else
			self iprintln("Your " + getWeaponName(oldweapon) + " has been removed." );
	}
}

getWeaponName(weapon)
{
	switch(weapon)
	{
		// Smoke/Flash grenades
		case "flashgrenade_mp":	return "Flash Grenade";
		case "smokegrenade_mp": return "Smoke Grenade";

		// Satchel
		case "satchelcharge_mp": return "Satchel Charge";
	
		// Common weapons
		case "fg42_mp":		return "FG42";
		case "panzerfaust_mp":	return "Panzerfaust 60";
		case "panzerschreck_mp":return "Panzerschreck";
		case "flamethrower_mp":	return "Flamethrower";
		case "bazooka_mp":	return "Bazooka";

		// Pistols		
		case "colt_mp":	return "Colt .45";
		case "luger_mp":	return "Luger";
		case "webley_mp":	return "Webley MK IV";
		case "tt33_mp":	return "Tokarev TT33";

		// Grenades		
		case "fraggrenade_mp":		return "M2 Frag Grenades";
		case "mk1britishfrag_mp":	return "MK1 Frag Grenades";
		case "rgd-33russianfrag_mp":	return "RGD-33 Stick Grenades";
		case "stielhandgranate_mp":	return "Stielhandgranates";

		// American
		case "m1carbine_mp":	return "M1A1 Carbine";
		case "m1garand_mp":	return "M1 Garand";
		case "thompson_mp":	return "Thompson";
		case "bar_mp":		return "BAR";
		case "springfield_mp":	return "Springfield";
		case "mg30cal_mp":	return "M1919A6 .30 cal";
		
		// British
		case "enfield_mp":	return "Lee-Enfield";
		case "sten_mp":		return "Sten";
		case "sten_silenced_mp":return "Silenced Sten";
		case "bren_mp":		return "Bren LMG";

		// Russian
		case "mosin_nagant_mp":		return "Mosin-Nagant";
		case "svt40_mp":			return "Tokarev SVT40";
		case "ppsh_mp":			return "PPSh";
		case "mosin_nagant_sniper_mp":return "Scoped Mosin-Nagant";
		case "dp28_mp":			return "Degtyarev DP28";

		// German		
		case "kar98k_mp":		return "Kar98k";
		case "gewehr43_mp":	return "Gewehr 43";
		case "mp40_mp":		return "MP40";
		case "mp44_mp":		return "MP44";
		case "kar98k_sniper_mp":return "Scoped Kar98k";
		case "mg34_mp":		return "MG34";

		case "binoculars_mp":			return "Binoculars";
		case "binoculars_artillery_mp":	return "Artillery";

		// Turrets & Tanks
		case "mg42_bipod_duck_mp":		return "MG42";
		case "mg42_bipod_prone_mp":		return "MG42";
		case "mg42_bipod_stand_mp":		return "MG42";
		case "mg42_tank_mp":			return "MG42";
		case "mg42_turret_mp":			return "MG42";

		case "mg34_tank_mp":			return "MG34";
		case "sg43_tank_mp":			return "SG43";
		case "mg_sg43_stand_mp":		return "SG43";
		case "sg43_turret_mp":			return "SG43";

		case "ptrs41_antitank_rifle_mp":	return "PTRS41";

		case "30cal_tank_mp":			return "Tank 30cal";
		case "50cal_tank_mp":			return "Tank 50cal";

		case "elefant_turret_mp":		return "Elefant";
		case "panzeriv_turret_mp":		return "Panzer IV";
		case "sherman_turret_mp":		return "Sherman";
		case "su152_turret_mp":			return "SU152";
		case "t34_turret_mp":			return "T34";

		case "mg50cal_tripod_stand_mp":	return "MG50";
		case "flak88_turret_mp":		return "Flak 88";
	
		default:
			weaponname = weapon;
			break;
	}

	return weaponname;
}

precacheForcedWeapon(weapon)
{
	if( level.empire_uomap && !isWeaponType(game["allies"],weapon) && !isWeaponType(game["axis"],weapon) && !isWeaponType("common",weapon) )
		return;

	if(	weapon == "none" || weapon == "" || weapon == "select" ||
		weapon == "selectother" || weapon == "random" || weapon == "randomother" ||
		weapon == "disable"
	  )
		return;

	awePrecacheItem(weapon);
}

takeWeaponSlotWeapon(slot)
{
	weapon = self getWeaponSlotWeapon(slot);
	if(weapon != "none")
	{
		self takeWeapon(weapon);
	}
}

/*
testModel(model)
{
	origin = self.origin + maps\mp\_utility::vectorScale(anglestoforward(self.angles),100) + (0,0,40);
	
	object = spawn("script_model",origin);
	object setModel(model);
	object.angles = vectortoangles( (0,0,-1) ) + (90,0,0);
	object show();
	wait 30;
	object delete();
}
*/

NotAFK()
{
    self notify("not_afk");
    if (isdefined(self.empire_camptimer))
    {
        self.empire_camptimer destroy();
        self.empire_camptimer = undefined;
        self iprintln(formatMessage(getcvar("ui_AutoAdmin_AFK_NotifyRemoved"), self));
    }

    // Reset AFK state and counter so camper() can be triggered again.
    self.empire_objnum = undefined;
    self.empire_camper = undefined;
    self.afk_count = 0;
}

monitorInput()
{
    self endon("empire_spawned");
    self endon("empire_died");
    self endon("disconnect");

    while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" )
    {
        // Check if the player is firing or using melee
        if (self attackButtonPressed() || self meleeButtonPressed() || self useButtonPressed())
        {
            // Reset AFK timer on any input
            self.afk_count = 0;

            //iprintln("DEBUG: monitorInput() detected input, calling NotAFK().");
            if (isdefined(self.empire_camper))
                NotAFK();
        }
        wait 0.10; // Poll every 100ms
    }
}

monitorWeaponSwitch()
{
    self endon("empire_spawned");
    self endon("empire_died");
    self endon("disconnect");

    previous_weapon = self GetCurrentWeapon();

    while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" )
    {
        current_weapon = self GetCurrentWeapon();

        if(current_weapon != previous_weapon)
        {
            self.afk_count = 0;
            if(isdefined(self.empire_camper))
                NotAFK();

            previous_weapon = current_weapon;
        }

        wait 0.05;
    }
}

monitorMenuResponse()
{
    self endon("empire_spawned");
    self endon("empire_died");
    self endon("disconnect");

    while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" )
    {
        self waittill("menuresponse");
        self.afk_count = 0;
        if(isdefined(self.empire_camper))
            NotAFK();
    }
}

monitorStanceChange()
{
    self endon("empire_spawned");
    self endon("empire_died");
    self endon("disconnect");

    previous_stance = aweGetStance(false);

    while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" )
    {
        current_stance = aweGetStance(false);

        if(current_stance != previous_stance)
        {
            self.afk_count = 0;
            if(isdefined(self.empire_camper))
                NotAFK();

            if(isdefined(self.p_speeding_reset))
                self.p_speeding_reset = true;

            previous_stance = current_stance;
        }

        wait 0.10;
    }
}

monitorme()
{
        self endon("empire_spawned");
        self endon("empire_died");
        self endon("disconnect");

        self.afk_count = 0;
        funcount = 0;
        ch_count = 0;

	while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" )
	{
		if(level.empire_sprint && level.empire_sprinthudhint)
		{
			if(!isdefined(sprinthudvisible) && isdefined(self.empire_sprinttime) && self.empire_sprinttime && !isdefined(self.empire_sprinting) && self.empire_pace && level.empire_sprint>self aweGetStance(false) && !self maps\mp\gametypes\_empire_uncommon::aweIsInVehicle())
			{
				if(isdefined(self.empire_sprinthud_hint))
				{
					self.empire_sprinthud_hint fadeOverTime (1); 
					self.empire_sprinthud_hint.alpha = 1;
					sprinthudvisible = true;
				}
			}
			else if(isdefined(sprinthudvisible) && (isdefined(self.empire_sprinting) || !self.empire_pace || level.empire_sprint<=self aweGetStance(false) || self maps\mp\gametypes\_empire_uncommon::aweIsInVehicle()))
			{
				{
					if(isdefined(self.empire_sprinthud_hint))
					{
						self.empire_sprinthud_hint fadeOverTime (1); 
						self.empire_sprinthud_hint.alpha = 0;
						sprinthudvisible = undefined;
					}
				}
			}
		}

		// Disable UO sprint?
		if(isdefined(level.empire_uo) && (!level.empire_uosprint || level.empire_sprint))
			self maps\mp\gametypes\_empire_uncommon::aweSetFatigue(0);

		// Eternal UO sprint?
		if(isdefined(level.empire_uo) && (level.empire_uosprint==2 && !level.empire_sprint))
			self maps\mp\gametypes\_empire_uncommon::aweSetFatigue(1);

		if(!isdefined(self.empire_sprinting))
			self.maxspeed = 1.9 * level.empire_playerspeed;

		if(level.empire_unlimitedammo)
		{
			self setWeaponSlotAmmo("primary", 999);
			self setWeaponSlotAmmo("primaryb", 999);
			self setWeaponSlotAmmo("pistol", 999);
			if(level.empire_unlimitedammo == 2)
			{
				self setWeaponSlotClipAmmo("primary", 999);
				self setWeaponSlotClipAmmo("primaryb", 999);
				self setWeaponSlotClipAmmo("pistol", 999);
			}
		}
		if(level.empire_unlimitedgrenades)
		{
			self setWeaponSlotAmmo("grenade", 999);
			self setWeaponSlotClipAmmo("grenade", 999);
		}
		if(level.empire_unlimitedsmokegrenades)
		{
			self setWeaponSlotAmmo("smokegrenade", 999);
			self setWeaponSlotClipAmmo("smokegrenade", 999);
		}

//		if(level.empire_debug)
//			self iprintln("Maxspeed: " + self.maxspeed);

		// Ugly fix to make sure self.headiconteam is not messed up
		if(isdefined(level.empire_teamplay))			// Check if it's team play
		{
			if(!isdefined(self.empire_objnum)) // Don't mess with marked players?
			{
				if(!isdefined(self.carrying) || !self.carrying ) // Don't mess with ACTF flag carriers
				{
					if(!isdefined(self.objs_held) || !self.objs_held)	// Don't mess with retrieval object carriers
					{
						self.headiconteam = self.sessionteam;
					}
				}
			}
		}

		// Be un-nice to Unknown Players?
		if(level.empire_unknownmethod && self isUnknown())
		{
			self iprintlnbold("^" + randomInt(8) + "Change your name!");
			switch(level.empire_unknownmethod)
			{
				case 1:
					self dropItem(self getcurrentweapon());
					break;
				case 2:
					self thread spankme(1);
					break;
				case 3:
					self thread maps\mp\gametypes\_empire_uncommon::aweShellshock(1);
					break;
				default:
					break;
			}
		}

		if(!isdefined(level.empire_merciless) && level.empire_nocrosshair)
		{
			if(ch_count>=10)
			{
				switch(level.empire_nocrosshair)
				{
					case 2:
						self setClientCvar("cg_drawcrosshair", "1");
						break;

					default:
						self setClientCvar("cg_drawcrosshair", "0");
						break;
				}
				ch_count=0;
			}
			ch_count++;
		}

		if( isdefined(self.empire_carryingturret) )
		{
			if(level.empire_turretpenalty)
			{
				w1 = self getWeaponSlotWeapon("primary");
				w2 = self getWeaponSlotWeapon("primaryb");
				cw = self getCurrentWeapon();
				if( w1 == cw || w2 == cw )
					self switchToWeapon(self getWeaponSlotWeapon("pistol"));
				if( w1 != "none" )
					self dropitem(w1);
				if( w2 != "none" )
					self dropitem(w2);
				if( w1 != "none" || w2 != "none")
				{
					if(level.empire_turrets[self.empire_carryingturret]["type"]=="misc_mg42")
						self iprintln("You cannot carry a primary weapon while carrying an MG42");
					else
						self iprintln("You cannot carry a primary weapon while carrying a PTRS41");
				}
			}
		}

		// Disable primaryb?		
		if(isdefined(self.empire_disableprimaryb))
		{
			primaryb = self getWeaponSlotWeapon("primaryb");
			if (primaryb != "none")
			{
				//player picked up a weapon
				primary = self getWeaponSlotWeapon("primary");
				if (primary != "none")
				{
					//drop primary weapon if he's carrying one already
					self dropItem(primary);
				}	

				//remove the weapon from the primary b slot
				self setWeaponSlotWeapon("primaryb", "none");
				self.pers["weapon2"] = undefined;

				//put the picked up weapon in primary slot
				self setWeaponSlotWeapon("primary", primaryb);
				self.pers["weapon1"] = primaryb;
				self switchToWeapon(primaryb);
			} 
		}

		// Calculate current speed
		oldpos = self.origin;
		wait 1;				// Wait 2 seconds
		newpos = self.origin;
		speed = distance(oldpos,newpos);

		if(level.empire_debug)
			self iprintln("Speed: " + speed);

		if (speed > 20) {
			self.empire_pace = 1;
			//iprintln("DEBUG: Movement detected, pace=" + self.empire_pace);
			NotAFK(); // Call our function to cancel AFK marking and remove the HUD timer.
			}
		else {
			self.empire_pace = 0;
			//iprintln("DEBUG: Movement not detected, pace=" + self.empire_pace);
			}

                if(level.empire_afk_detection && level.empire_anticamptime && !isdefined(self.empire_camper) && !isdefined(level.empire_tdom))
                {
                        if(isdefined(self.hasflag) || (isdefined(self.carrying) && self.carrying))
                        {
                                self.afk_count = 0;
                        }
                        else
                        {
                               // Check for campers - ignore players using LMGs
                               if(self.empire_pace == 0 && !isWeaponType("lmg", self GetCurrentWeapon()))
                                       self.afk_count++;
                               else
                                       self.afk_count = 0;

                                if(self.afk_count >= level.empire_anticamptime)
                                {
                                        self thread camper();
                                        self.afk_count = 0;
                                }
                        }
                }

		// Mess with the poor camper
		if(level.empire_anticampfun && isdefined(self.empire_camper))
		{
			if(funcount>=level.empire_anticampfun)
			{
				switch (randomInt(3))
				{
					// Scream
					case 0:
						self thread painsound();
						break;
				
					// Trip and drop weapon
					case 1:
						self thread spankme(1);
						break;

					// Shellshock for 5 seconds
					case 2:
						self thread maps\mp\gametypes\_empire_uncommon::aweShellshock(5);
						break;

					default:
						break;
				}
				funcount=0;
			}
                        else
                                funcount++;
                }

        }
}

camper()
{
    self endon("empire_spawned");
    self endon("empire_died");
    self endon("disconnect");
    self endon("not_afk");

    if(!level.empire_afk_detection)
            return;

    // Skip AFK punishment if player is carrying the flag
    if (isdefined(self.hasflag) || (isdefined(self.carrying) && self.carrying))
            return;
        
    // Ensure any previous timer is cleared.
    if(isdefined(self.empire_camptimer))
    {
        self.empire_camptimer destroy();
        self.empire_camptimer = undefined;
    }
    
    // Now set the flag so we know this thread is running.
    self.empire_camper = true;
    
    // Retrieve the marking period from the anticamp marktime cvar.
    // NOTE: the cvar value is stored in level.empire_anticampmarktime when
    //       _empire::Setup() initializes all mod cvars. Use that variable here
    //       so that user configured values (e.g. empire_anticamp_marktime) are
    //       respected.
    markTime = level.empire_anticampmarktime;
    if (!isdefined(markTime) || markTime <= 0)
        markTime = 30; // default to 30 seconds if not set
    
    // Inform only the affected player that they have been detected as AFK.
    self iprintlnbold(formatMessage(getcvar("ui_AutoAdmin_AFK_NotifyPlayer"), self, markTime));
    
    // Set up a HUD timer for feedback.
    self.empire_camptimer = newClientHudElem(self);
    self.empire_camptimer.archived = true;
    self.empire_camptimer.x = 220;
    if (isdefined(level.empire_alternatehud))
        self.empire_camptimer.y = 420;
    else
        self.empire_camptimer.y = 460;
    self.empire_camptimer.alignX = "center";
    self.empire_camptimer.alignY = "middle";
    self.empire_camptimer.alpha = 1;
    self.empire_camptimer.sort = -3;
    self.empire_camptimer.font = "bigfixed";
    self.empire_camptimer.color = (1, 1, 0);
    self.empire_camptimer setTimer(markTime - 1);
    
    // Mark the player on the HUD and update the objective.
    // Note: markme() will block for markTime seconds.
    self markme("crosshair", "afk", markTime);
    
    // Remove the HUD timer (should be at 0 when markme() completes).
    if (isdefined(self.empire_camptimer))
        self.empire_camptimer destroy();
    
    // Immediately force the player into spectator mode.
    self.pers["team"] = "spectator";
    self.sessionteam = "spectator";
    self setClientCvar("g_scriptMainMenu", game["menu_team"]);
    self setClientCvar("scr_showweapontab", "0");
    self thread maps\mp\gametypes\_empire::spawnSpectator();
    
    if (isAlive(self))	//"^1~^3empire ^2| ^1automod: ^3You have been detected as ^1AFK^3. You will be forced into spectator mode in ^1" + markTime + "^3 seconds."
                self iprintlnbold(formatMessage(getcvar("ui_AutoAdmin_AFK_NotifyActionTaken"), self));
    
    self.empire_camper = undefined;
}


PlayerParachute()
{
	self endon("empire_spawned");
	self endon("empire_died");

	// Do not parachute in roundbased gametypes unless match has been started.
	if(isdefined(level.empire_roundbased))
		if(!game["matchstarted"])
			return;
		

	if(level.empire_parachutes == 1)
		self.empire_haveparachuted = true;

	// Starting point for player
	ix = self.origin[0] - 150 + randomint(300);
	iy = self.origin[1] - 150 + randomint(300);

	// Calculate starting altitude
	if(level.empire_bombers_altitude)
		iz = level.empire_bombers_altitude - randomint(100);
	else
		iz = level.empire_vMax[2] - randomint(100);	

	// Endpoint for player is 24 units above spawn point (origin)
	endpoint = self.origin + ( 0, 0, 24);	// I use a low value here to avoid getting stuck

	// Check how high the path is clear
	trace = bulletTrace(endpoint, (endpoint + (0,0,iz)), false, undefined);
	pos = trace["position"];
	iz = pos[2];

	// Limit the altitude
	if(level.empire_parachuteslimitaltitude)
	{
		if((iz-endpoint[2])>level.empire_parachuteslimitaltitude)
			iz=endpoint[2] + level.empire_parachuteslimitaltitude - randomint(100);
	}

	// Starting point ready
	startpoint = ( ix, iy, iz);	

	// Calculate distance between start and end
	distance = distance(startpoint, endpoint);

	// Don't parachute distances below 350 units (3.5 seconds)
	if(distance < 350)
		return;

	// Now we are clear to parachute
	self.empire_isparachuting = 1;

	//create a model to attach everything to
	self.empire_anchor = spawn ("script_model",(0,0,0));
	self.empire_anchor.origin = self.origin;
	self.empire_anchor.angles = self.angles;
	
	self.empire_parachute = spawn_parachute();
	
	// Link player to self.empire_anchor
	self linkto (self.empire_anchor);

	self.empire_parachute linkto (self.empire_anchor,"",(24,-32,128),(0,-40,0));

	// Disable weapon & make player invulnerable
	if(level.empire_parachutesprotection)
	{
		self disableWeapon();
		self.empire_invulnerable = true;
	}

	// Get a random falltime
	falltime = distance*0.01 + randomint(6);
	
	// Move self.empire_anchor
	self.empire_anchor.origin = startpoint;
	self.empire_anchor moveto (endpoint, falltime);

	wait .05;

	// Play wind sound
	self.empire_anchor playLoopSound ("empire_Para_Wind");

	// Wait fall time - 3 seconds	
	for(i=0;(i<(falltime - 3)*20) && isPlayer(self) && isAlive(self);i++)
	{
		self setClientCvar("cl_stance", "0");
		self.empire_anchor.angles = self.angles;
		wait 0.05;
	}
	// Play landing sound for the last 3 seconds
	if(isPlayer(self) && isAlive(self))
		self playSound("empire_Para_Land");

	for(i=0;(i<3*20) && isPlayer(self) && isAlive(self);i++)
	{
		self setClientCvar("cl_stance", "0");
		self.empire_anchor.angles = self.angles;
		wait 0.05;
	}

	self.empire_anchor stopLoopSound();
	
	// Release player if he's dead
	if(!isPlayer(self) || !isAlive(self))
		self unlink();

	if(isPlayer(self) && isAlive(self))
	{
		// Make sure self.empire_anchor is on it's endpoint	
		self.empire_anchor.origin = endpoint;
		
		// Enabled weapon
		if(level.empire_parachutesprotection)
			self enableWeapon();

		// Release player
		self unlink();

		// Let him fall
		wait 0.15;

		// Rock his world
		earthquake(0.4, 1.2, self.origin, 70);
	}

	if(level.empire_parachutesprotection)
		self.empire_invulnerable = undefined;

	self.empire_isparachuting = undefined;

	// Remove parachute
	self.empire_parachute delete();
	self.empire_anchor delete();

	return;
}

#using_animtree("animation_rig_parachute");
spawn_parachute()
{
	parachute = spawn ("script_model",(0,0,0));
	parachute.animname = "parachute";
	parachute setmodel ("xmodel/parachute_animrig");
	//parachute setmodel ("xmodel/parachute_flat_A");
	parachute.animtree = #animtree;
	parachute.landing_anim = %parachute_landing_roll;
	parachute.player_anim = %player_landing_roll;
	//parachute useAnimTree (parachute.animtree);
	return parachute;
}

spawnprotection()
{
	self endon("empire_spawned");
	self endon("empire_died");

	if(!isdefined(level.drawfriend))
		level.drawfriend = 0;

	count = 0;
	startposition = self.origin;
	self iprintln("Spawn protection activated!");

	if(level.empire_spawnprotectiondisableweapon)
		self disableWeapon();

	// Set up HUD element
	if(level.empire_spawnprotectionhud == 1)
	{
		self.empire_spawnprotection = newClientHudElem(self);	
		self.empire_spawnprotection.x = 520;
		self.empire_spawnprotection.y = 410;
		self.empire_spawnprotection.alpha = 0.65;
		self.empire_spawnprotection.alignX = "center";
		self.empire_spawnprotection.alignY = "middle";
		self.empire_spawnprotection setShader(game["headicon_protect"],40,40);
	}

	if(level.empire_spawnprotectionhud == 2)
	{
		self.empire_spawnprotection = newClientHudElem(self);	
		self.empire_spawnprotection.x = 320;
		self.empire_spawnprotection.y = 240;
		self.empire_spawnprotection.alpha = 0.4;
		self.empire_spawnprotection.alignX = "center";
		self.empire_spawnprotection.alignY = "middle";
		self.empire_spawnprotection setShader(game["headicon_protect"],350,320);
	}

	while( isAlive(self) && self.sessionstate=="playing" && count < (level.empire_spawnprotection * 20) && !((self attackButtonPressed() || self meleeButtonPressed()) && self getCurrentWeapon()!="none" && !(isdefined(self.empire_isparachuting) && level.empire_parachutesprotection) ) )
	{
		self.empire_invulnerable = true;

		if(level.empire_spawnprotectionheadicon)
		{
			// Setup headicon
			self.headicon = game["headicon_protect"];
			self.headiconteam = "none";
		}

		if(level.empire_spawnprotectionrange && !isdefined(self.empire_isparachuting))
		{
			// Check moved range
			distance = distance(startposition, self.origin);
			if(distance > level.empire_spawnprotectionrange)
				count = level.empire_spawnprotection * 20;
		}

		// Don't count time while parachuting unless parachuter is unprotected
		if(!(isdefined(self.empire_isparachuting) && level.empire_parachutesprotection))
			count++;

		wait 0.05;
	}

	if(level.empire_spawnprotectiondisableweapon)
		self enableWeapon();

	self.empire_invulnerable = undefined;
	if(level.empire_spawnprotectionheadicon)
		self restoreHeadicon(game["headicon_protect"]);

	if( isAlive(self) && self.sessionstate=="playing" )
	{
		self iprintln("You are no longer protected!");

		// Fade HUD element
		if(isdefined(self.empire_spawnprotection))
		{
			self.empire_spawnprotection fadeOverTime (1); 
			self.empire_spawnprotection.alpha = 0;
		}

		wait 1;
	}

	// Remove HUD element
	if(isdefined(self.empire_spawnprotection))
		self.empire_spawnprotection destroy();
}

restoreHeadicon(oldicon)
{
	// Restore headicon
	if(level.drawfriend && self.pers["team"]!="spectator" )
	{
		if(isdefined(level.empire_uo) && level.battlerank)
		{
			self.headicon = maps\mp\gametypes\_empire_uncommon::aweGetRankHeadIcon(self);
		}
		else
		{
			headicon = "headicon_" + self.pers["team"];
			self.headicon = game[headicon];
		}
	
		if(isdefined(self.sessionteam))
			self.headiconteam = self.sessionteam;
		else
			self.headiconteam = self.pers["team"];

		if(isdefined(level.empire_classbased)) 	// Merciless v.6 classbased headicons
		{
			self.headicon = self.pers["hicon"];
		}
		else if(isdefined(self.carrying))
		{
			if(self.carrying)			// ACTF flag carrier
			{
				if(isdefined(game["headicon_carrier"]))		// ACTF
				{
					self.headicon = game["headicon_carrier"];
					if(getCvar("scr_ctf_showcarrier") == "1")
						self.headiconteam = "none";
				}
			}
		}
		else if(isdefined(self.objs_held))
		{
			if(self.objs_held)		// Retrieval object carrier
			{
				self.headicon = game["headicon_carrier"];
				if(getCvar("scr_re_showcarrier") == "0")
					self.headiconteam = game["re_attackers"];
				else
					self.headiconteam = "none";
			}
		}
	}
	else
	{
		self.headicon = "";
	}
	
	// Check if another function has saved the icon we marked with
	if(isdefined(self.oldheadicon))
		if(self.oldheadicon == oldicon)
			self.oldheadicon = self.headicon;
}

tracers()
{
	level endon("empire_boot");
	for(;;)
	{
		delay = level.empire_tracersdelaymin + randomint(level.empire_tracersdelaymax - level.empire_tracersdelaymin);
		wait delay;

		iSide = randomInt(4);
		switch (iSide)
		{
			case 0:
				ix = level.empire_vMin[0];
				iy = level.empire_vMin[1] + randomInt(level.empire_vMax[1] - level.empire_vMin[1]);
				break;

			case 1:
				ix = level.empire_vMax[0];
				iy = level.empire_vMin[1] + randomInt(level.empire_vMax[1] - level.empire_vMin[1]);
				break;
				
			case 2:
				ix = level.empire_vMin[0] + randomInt(level.empire_vMax[0] - level.empire_vMin[0]);
				iy = level.empire_vMin[1];
				break;
		
			case 3:
				ix = level.empire_vMin[0] + randomInt(level.empire_vMax[0] - level.empire_vMin[0]);
				iy = level.empire_vMax[1];
				break;
		}
			
		//set the height as the spawnpoint level - 100
		spawnpoints = getentarray("mp_deathmatch_spawn", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_teamdeathmatch_spawn", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_searchanddestroy_spawn_allied", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_searchanddestroy_spawn_axis", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_retrieval_spawn_allied", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_retrieval_spawn_axis", "classname");
		iz = spawnpoints[0].origin[2] - 100;
			
		playfx(level._effect["empire_tracers"], (ix, iy, iz));
	}
}

skyflashes()
{
	level endon("empire_boot");


	for(;;)
	{
		// wait a random delay
		delay = level.empire_skyflashesdelaymin + randomint(level.empire_skyflashesdelaymax - level.empire_skyflashesdelaymin);
		wait delay;
			
		// spawn object that is used to play sound
		skyflash = spawn ( "script_model", ( 0, 0, 0) );

		//get a random position
		xwidth = level.empire_vMax[0] - level.empire_vMin[0] - 100;
		ywidth = level.empire_vMax[1] - level.empire_vMin[1] - 100;
		xpos = level.empire_vMin[0] + 50 + randomint(xwidth);
		ypos = level.empire_vMin[1] + 50 + randomint(ywidth);
		if(level.empire_bombers_altitude)
			zpos = level.empire_bombers_altitude - 50;
		else
			zpos = level.empire_vMax[2] - 50;	
		
		position = ( xpos, ypos, zpos);

		// get a random effect
		s = randomInt(level.empire_skyeffects.size);

		skyflash.origin = position;
		wait .05;
		
		// play effect
		playfx(level.empire_skyeffects[s]["effect"], position);
		
		// play sound
		wait level.empire_skyeffects[s]["delay"];
		skyflash playsound("empire_skyflash");
		wait .05;
		skyflash delete();
	}
}

C47sounds(startpos, delay)
{
	level endon("empire_boot");
	for(;;)
	{
		wait delay;
		thread C47sound(startpos, delay);
	}
}

C47sound(startpos, delay)
{
	// start sound behind the effect
	startpos = startpos - (0,500,0);

	// spawn object that is used to play sound
	if(level.empire_debug)
		sndobject = spawn_model("xmodel/vehicle_plane_stuka", "stuka", startpos, ( 0, 90, 0) );
	else
		sndobject = spawn("script_model",startpos);
	wait 0.05;

	// Move the sound object a bit longer to get better fading of sound
	s = level.empire_vMax[1] - startpos[1] + 1000;
	v = 150;

	t = s / v;

	// play sound
	sndobject playloopsound("empire_planeloop");

	if(level.empire_debug)
	{
		iprintlnbold("distance: " + s);
		sndobject2 = spawn_model("xmodel/vehicle_plane_stuka", "stuka2", startpos + (0,s,0), ( 0, 90, 0) );
	}

	// move object
	sndobject moveto( startpos + (0,s,0) , t);
	wait t;
	sndobject stoploopsound();
	sndobject delete();
}

stukas()
{
	level endon("empire_boot");
	for(;;)
	{	
		wait level.empire_stukasdelay;
		stukas = level.empire_stukas + randomInt(3);
		offset = -2000 + randomInt(4000);
		angle = 90 * randomInt(4);
		for(i=0;i<stukas;i++)
			thread stuka( offset - (stukas * 500) + (i * 1000), angle);
	}
}

stuka(offset, angle)
{
	// Set height
	if(level.empire_bombers_altitude)
		iZ = level.empire_bombers_altitude;
	else
		iZ = level.empire_vMax[2];	

	iZstart 	= iZ + 1000 - randomInt(500);
	iZend 	= iZ + 1000 - randomInt(500);

	// Set X & Y depending on angle
	switch(angle)
	{
		case 0:
			iY 		= (int)(level.empire_vMax[1] + level.empire_vMin[1])/2 + offset;
			iYstart 	= iY - 200 + randomInt(400);
			iYend		= iY - 200 + randomInt(400);
			iXstart 	= level.empire_vMin[0] - 6000 - randomInt(1000);	
			iXend 	= level.empire_vMax[0] + 6000;
			break;

		case 90:
			iX 		= (int)(level.empire_vMax[0] + level.empire_vMin[0])/2 + offset;
			iXstart 	= iX - 200 + randomInt(400);
			iXend		= iX - 200 + randomInt(400);
			iYstart 	= level.empire_vMin[1] - 6000 - randomInt(1000);	
			iYend 	= level.empire_vMax[1] + 6000;
			break;

		case 180:
			iY 		= (int)(level.empire_vMax[1] + level.empire_vMin[1])/2 + offset;
			iYstart 	= iY - 200 + randomInt(400);
			iYend		= iY - 200 + randomInt(400);
			iXstart 	= level.empire_vMax[0] + 6000 + randomInt(1000);	
			iXend 	= level.empire_vMin[0] - 6000;
			break;

		case 270:
			iX 		= (int)(level.empire_vMax[0] + level.empire_vMin[0])/2 + offset;
			iXstart 	= iX - 200 + randomInt(400);
			iXend		= iX - 200 + randomInt(400);
			iYstart 	= level.empire_vMax[1] + 6000 + randomInt(1000);	
			iYend 	= level.empire_vMin[1] - 6000;
			break;
			break;
	}
	
	startpos 	= (iXstart, iYstart, iZstart);
	endpos 	= (iXend, iYend, iZend);


	s = (float)distance(startpos,endpos);
	v = (float)(2250 - 250 + randomInt(500));

	t = (float)(s / v);


	if(!(randomInt(100) < level.empire_stukascrash))
	{
		// spawn stuka
		stuka = spawn_model("xmodel/vehicle_plane_stuka", "stuka", startpos, ( 10, angle, 0) );
		wait 0.05;

		// play sound
		stuka playloopsound("empire_stukaloop");

		// move object
		stuka moveto( endpos , t);
		wait t/3;
		// 20% chance that it's going to roll after one third of the flight
		if(!randomInt(5))
		{
			if(randomInt(2))
				stuka rotateroll(360,4 + randomFloat(3),1,1);
			else
				stuka rotateroll(-360,4 + randomFloat(3),1,1);
		}
		wait 2*t/3;
		stuka stoploopsound();
		stuka delete();
	}
	else // This stuka will crash
	{
		startpos	= (startpos[0],startpos[1],iZ);
		endpos	= (endpos[0],endpos[1],iZ);
		// spawn stuka
		stuka = spawn_model("xmodel/vehicle_plane_stuka", "stuka", startpos, ( 10, angle, 0) );
		wait 0.05;

		// play sound
		stuka playloopsound("empire_stukaloop");
	
		fraction = 0.2 + randomfloat(0.4);

		deltax = (endpos[0]-startpos[0]) * fraction;
		deltay = (endpos[1]-startpos[1]) * fraction;
		deltaz = (endpos[2]-startpos[2]) * fraction;
		// move object
		stuka moveto( startpos + (deltax,deltay,deltaz) , t * fraction);
		wait t * fraction;
		stuka stoploopsound();
		stuka planeCrash(v);
	}
}

withinMap(origin)
{
	margin = 250;
	if(origin[0]<(level.empire_vMin[0]+margin)) return false;
	if(origin[1]<(level.empire_vMin[1]+margin)) return false;
	if(origin[2]<(level.empire_vMin[2]-margin)) return false;
	if(origin[0]>(level.empire_vMax[0]-margin)) return false;
	if(origin[1]>(level.empire_vMax[1]-margin)) return false;
	if(origin[2]>(level.empire_vMax[2]+margin)) return false;
	return true;
}

planeCrash(speed)
{
	level endon("empire_boot");

	self playloopsound("empire_stukahit");

	radius = 20;
	vVelocity = maps\mp\_utility::vectorScale(anglestoforward(self.angles), speed/20 );

	roll		= (float)0;
	deltaroll	= (float)(-5 + randomfloat(10))*(float)0.05;		// Roll/frame

	// Set gravity
	vGravity = (0,0,-0.75 + randomfloat(0.5));

	stopme = 0;
	ttl = level.empire_stukascrashstay;
	falloff = 0.05;

	bouncefx = level.empire_effect["bombexplosion"];
	finalfx = bouncefx;

	// play the hit sound
	self playsound("grenade_explode_default");
	playfx(bouncefx,self.origin);

	// Drop with gravity
	while(self.origin[2]>(level.empire_vMin[2] - 250))	// Exit if it missed the map
	{
		// Let gravity do, what gravity do best
		vVelocity +=vGravity;

		// Get destination origin
		neworigin = self.origin + vVelocity;

		if(withinMap(neworigin))	// Make sure it does not crash on invisible walls surrounding the map
		{
			// Check for impact, check for entities but not myself.
			trace=bulletTrace(self.origin,neworigin,true,self);
			if(trace["fraction"] != 1)	// Hit something
			{
				deltaroll = 0;
				roll = 0;
				self setModel("xmodel/vehicle_plane_stuka_d");
	
				// Place object at impact point - radius
				distance = distance(self.origin,trace["position"]);
				if(distance)
				{
					fraction = (distance - radius) / distance;
					delta = trace["position"] - self.origin;
					delta2 = maps\mp\_utility::vectorScale(delta,fraction);
					neworigin = self.origin + delta2;
				}
				else
					neworigin = self.origin;	

				// Play sound if defined
				if(isdefined(bouncesound)) self playSound(bouncesound);	
	
				// Test if we are hitting ground and if it's time to stop bouncing
				if(length(vVelocity) < 10) stopme++;
				if(stopme==1) break;	

				// Play effect if defined and it's a hard hit
				if(length(vVelocity) > 20)
				{
					// play the hit sound
					self playsound("grenade_explode_default");
					playfx(bouncefx,neworigin);
				}

				// Decrease speed for each bounce.
				vSpeed = length(vVelocity) * falloff;	

				// Calculate new direction (Thanks to Hellspawn this is finally done correctly)
				vNormal = trace["normal"];
				vDir = maps\mp\_utility::vectorScale(vectorNormalize( vVelocity ),-1);
				vNewDir = ( maps\mp\_utility::vectorScale(maps\mp\_utility::vectorScale(vNormal,2),vectorDot( vDir, vNormal )) ) - vDir;	

				// Scale vector
				vVelocity = maps\mp\_utility::vectorScale(vNewDir, vSpeed);

				// Add a small random distortion
				vVelocity += (randomFloat(1)-0.5,randomFloat(1)-0.5,randomFloat(1)-0.5);
			}
		}
		self.origin = neworigin;

		angles = vectortoangles(vectornormalize(vVelocity));
		pitch = angles[0] + 10;

		// Rotate roll
		roll +=deltaroll;
		a2 = self.angles[2] + roll;
		while(a2<0) a2 += 360;
		while(a2>359) a2 -=360;
		self.angles = (pitch,self.angles[1],a2);
	
		// Wait one frame
		wait .05;
		ttl -= .05;
		if(ttl<=0) break;
	}
	self stoploopsound();

	if(self.origin[2]>(level.empire_vMin[2]-250))
	{
		// Set origin to impactpoint	
		self.origin = neworigin;

		surface = trace["surfacetype"];
		if(isdefined(level.empire_mortarfx))
		{
			if(isdefined(level.empire_mortarfx[surface]))
			{
				playfx(level.empire_mortarfx[surface], self.origin);
			}
			else
			{
				if(isdefined(level.empire_wintermap) && isdefined(level.empire_mortarfx["snow"]) )
					playfx(level.empire_mortarfx["snow"], self.origin);
				else if(isdefined(level.empire_mortarfx["generic"]))
					playfx(level.empire_mortarfx["generic"], self.origin);
			}
			self playsound("mortar_explode_" + surface);
		}
		else
		{
			// play the hit sound
			self playsound("grenade_explode_default");
			playfx(finalfx,self.origin);
		}


		if(!level.empire_stukascrashsafety)
			self scriptedRadiusDamage(self, undefined, "none", 200, 200, 10, false);

		wait 1 + randomfloat(2);

		playfx(bouncefx,self.origin);
		if(!level.empire_stukascrashsafety)
			self scriptedRadiusDamage(self, undefined, "none", 500, 600, 10, false);
		if(level.empire_stukascrashquake)
			earthquake(0.8, 3, self.origin, 900); 

		// Stay for the specified amount of time
		if(ttl>0) wait ttl;
	}
	// Vanish
	self delete();
}

PlayerDisconnect()
{
	if(level.empire_disable) return;

	self notify("empire_died");
	self notify("empire_spawned");
	self notify("stop_turret_hud");

	self cleanupPlayer1();
	self cleanupPlayer2();

	// Restart turret think thread if one was used when disconnected
	if( isdefined(self.empire_usingturret) && isdefined(level.empire_turrets[self.empire_usingturret]["turret"]) )
		level.empire_turrets[self.empire_usingturret]["turret"] thread maps\mp\_empire_turret::turret_think(self.empire_usingturret);

	if(level.empire_nocrosshair)
		self setClientCvar("cg_drawcrosshair", "1");

	dropTurret(undefined, undefined);
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
//	if(level.empire_debug)
//	{
//		iprintln("sMOD:" + sMeansOfDeath);
//		iprintln("iDamage:" + iDamage);
//	}

	// Ignore damage from spectators
	if(level.empire_blockdamagespectator && isdefined(eAttacker) && isPlayer(eAttacker) && isdefined(eAttacker.sessionstate) && eAttacker.sessionstate == "spectator")
	{
//		eAttacker iprintlnbold("Blocked damage!");
		return;
	}
	// Ignore damage from players that switched teams the last 7 seconds
	if(level.empire_blockdamageteamswitch && isdefined(eAttacker) && isPlayer(eAttacker) && isdefined(eAttacker.empire_oldteam))
	{
		if(isdefined(level.empire_teamplay))
			team = eAttacker.sessionteam;
		else
			team = eAttacker.pers["team"];
		if(team != eAttacker.empire_oldteam)
		{
//			eAttacker iprintlnbold("Blocked damage!");
			return;
		}
	}

	// Protected or a headshot on a zombie player
	if(isdefined(self.empire_invulnerable) || (isdefined(self.empire_headpopped) && isdefined(sHitLoc) && sHitLoc == "head"))
		return;

	// Block friendly melee in some cases (body search, etc...)
	if(isdefined(level.empire_teamplay) && isPlayer(self) && isPlayer(eAttacker) && self.sessionteam == eAttacker.sessionteam && sMeansOfDeath == "MOD_MELEE")
	{
		if(isDefined(self.empire_tripwiremessage) || isDefined(self.empire_turretmessage))
			return;
	}

	// Block melee damage if grenade and sticky nades are allowed on players
	if(level.empire_stickynades == 2 && isPlayer(self) && isPlayer(eAttacker) && sMeansOfDeath == "MOD_MELEE" && (isWeaponType("grenade",sWeapon) || sWeapon == "satchelcharge_mp"))
		return;

	// Flamethrower hit rate
	if(isdefined(level.empire_uo) && sMeansOfDeath != "MOD_MELEE" && sWeapon == "flamethrower_mp" && level.empire_flamethrowerhitrate <= randomInt(100))
		return;

	// Damage modifiers
	if(sMeansOfDeath != "MOD_MELEE" && isdefined(level.empire_dmgmod[sWeapon]))
	{
		iDamage = iDamage * level.empire_dmgmod[sWeapon];
	}

	// Call original function
	[[level.empire_orignalPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
}

DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	if(level.empire_disable) return;

//	self iprintlnbold("sWeapon:" + sWeapon + " sHitLoc:" + sHitLoc + " sMeansOfDeath:" + sMeansOfDeath);

    // If this player is the attacker, cancel any AFK marking.
	if(isPlayer(eAttacker) && self == eAttacker)
	{
		NotAFK();
	}

	// Was the attacker a spawnprotected player?
	if(isPlayer(eAttacker) && eAttacker != self && isdefined(eAttacker.empire_invulnerable) && level.empire_spawnprotectiondropweapon)
	{
		eAttacker iprintlnbold("Don't abuse the spawnprotection!");
		eAttacker dropItem(eAttacker getcurrentweapon());
	}

	if(level.empire_bulletholes)
		if(sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET")
			self thread bullethole(sHitLoc);

	if(isPlayer(eAttacker) && eAttacker != self && level.empire_showhit)
		eAttacker thread showhit();

	if(isPlayer(eAttacker) && sMeansOfDeath != "MOD_FALLING")
	{
		if(sMeansOfDeath == "MOD_MELEE" || distance(eAttacker.origin , self.origin ) < 40 )
			eAttacker thread Splatter_View();
	}

	//PRM weapon drops on arm/hand hits and splatter view
	if(isAlive(self))
	{	
		switch(sHitLoc)
		{
			case "helmet":
			case "head":
				self thread Splatter_View();
				if( randomInt(100) < level.empire_pophelmet && !isdefined(self.empire_helmetpopped) )
					self thread popHelmet( vDir, iDamage );
				break;

			case "right_hand":
			case "left_hand":
			case "gun":
				if( !isdefined(level.empire_merciless) && randomInt(100)<level.empire_droponhandhit)
					self dropItem(self getcurrentweapon());
				break;
			
			case "right_arm_lower":
			case "left_arm_lower":
				if(!isdefined(level.empire_merciless) && randomInt(100)<level.empire_droponarmhit )
					self dropItem(self getcurrentweapon());
				break;
	
			case "right_foot":
			case "left_foot":
				if(randomInt(100)<level.empire_triponfoothit)
					self thread spankme(1);
				break;

			case "right_leg_lower":
			case "left_leg_lower":
				if(randomInt(100)<level.empire_triponleghit)
					self thread spankme(1);
				break;
		}
	}

	if(isalive(self))
	{	
		if(level.empire_shellshock && !isdefined(level.empire_merciless))
			self thread maps\mp\gametypes\_empire_uncommon::shockme(iDamage, sMeansOfDeath);
		// Pains sound
		if(level.empire_painsound && !isdefined(level.empire_merciless))
			self painsound();
		if(level.empire_bleeding && !isdefined(level.empire_merciless))
			self thread DoBleedingPain(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
		self thread DoPainScreen(iDamage);
	}	
}

//////////////////////////////////////////////////////////////////////////////////
// Bleed for a few seconds after a player gets hit...
//////////////////////////////////////////////////////////////////////////////////
DoBleedingPain(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	self endon("empire_spawned");
	self endon("empire_died");

	self notify("empire_dobleedingpain");	// Kill any previous bleeding
	self endon("empire_dobleedingpain");

	bLoc = getHitLocTag(sHitLoc);

	x = level.empire_bleeding;

	if ((self.health - x) < 1 )
		willdie = 1;
	else
		willdie = 0;
	
	oldhealth = self.health;

	for(i = 0 ; i < x ; i++)
	{
		// Exit if dead or if a healthpack has been used
		if(!isAlive(self) || self.health > oldhealth)
			break;
		
		self.health -- ;
		oldhealth = self.health;

		if (self.health <= 0)
			self finishPlayerDamage(eInflictor, eAttacker, 2 , iDFlags , sMeansOfDeath , sWeapon , (self.origin + (0,0,-300)), vDir, sHitLoc); 			//Kill the player
		
		if (willdie == 1)
		{
			if(self.health < 2)
			{
				self thread DoPainScreen(100);
				self setClientCvar("cl_stance", 2);
			}
			else if(self.health < 4 && self aweGetStance(false) < 1)
			{
				self thread DoPainScreen(75);
				self setClientCvar("cl_stance", 1);
			}
		}
			

		if(isdefined(level.empire_teamplay))
			team = self.sessionteam;
		else
			team = self.pers["team"];

		if ( (i == 4 || i == 6 || i == 8) && randomInt(4) )
		{
			if(randomInt(3))
				self playsound("empire_" + team + "_bleedpain"); 
			else
				self playsound("fatigue_breath");
		}

		s = 0;
		for(k = 0 ; k < 3 ; k++ )
		{
			p = (randomInt(2) *.1) + (randomInt(5) * .01);
			if(!self maps\mp\gametypes\_empire_uncommon::aweIsInVehicle())
				playfxontag(level.empire_bleedingfx, self ,bLoc );
			wait p;
			s = s + p;
		}
		wait (.75 - s);
	}
}

///////////////////////////////////////////////////////
// Draws a "pain" flash on the screen.
// The intensity and longevity of the flash is 
// dependant on both the weapon used & damage done.
//////////////////////////////////////////////////////
DoPainScreen(iDamage)
{
	self endon("empire_spawned");
	self notify("empire_dopainscreen");
	self endon("empire_dopainscreen");

	if(!level.empire_painscreen || isdefined(level.empire_merciless))
		return;

	// Wait for any previous painscreen thread to die
	wait 0.05;

	// Remove previous painscreen if present
	if (isDefined(self.empire_painscreen))
		self.empire_painscreen destroy();

	if (!isDefined(self.empire_painscreen))
	{
		self.empire_painscreen = newClientHudElem(self);
		self.empire_painscreen.alignX = "left";
		self.empire_painscreen.alignY = "top";
		self.empire_painscreen.x = 0;
		self.empire_painscreen.y = 0;	
		p = iDamage * .01;
		if (p >= 1 ) 
			P = .9;
		self.empire_painscreen.alpha = p * level.empire_painscreen / 100;
		t = self.empire_painscreen.alpha * .1;

		self.empire_painscreen.color = (1,0,0);
		self.empire_painscreen SetShader("white",640,480);	
		
		wait ((p * 10) * .15 );
		for(v = 0; v < 10; v++)
		{
			self.empire_painscreen.alpha = self.empire_painscreen.alpha - t;
			wait (.05);
		}
		// Remove painscreen if present
		if (isDefined(self.empire_painscreen))
			self.empire_painscreen destroy();
	}
}

teamMateInRange(range)
{
	if(!range)
		return true;

	// Get all players and pick out the ones that are playing and are in the same team
//	allplayers = getentarray("player", "classname");
	players = [];
	for(i = 0; i < level.empire_allplayers.size; i++)
	{
		if(isdefined(level.empire_allplayers[i]))
			if(level.empire_allplayers[i].sessionstate == "playing" && level.empire_allplayers[i].pers["team"] == self.pers["team"])
				players[players.size] = level.empire_allplayers[i];
	}

	// Get the players that are in range
	sortedplayers = sortByDist(players, self);

	// Need at least 2 players (myself + one team mate)
	if(sortedplayers.size<2)
		return false;

	// First player will be myself so check against second player
	distance = distance(self.origin, sortedplayers[1].origin);
	if( distance <= range )
		return true;
	else
		return false;
}

Splatter_View()
{
	self endon("empire_spawned");

	if (!level.empire_bloodyscreen || isdefined(level.empire_merciless))
		return;

	if(!isDefined(self.empire_bloodyscreen))
	{
		self.empire_bloodyscreen = newClientHudElem(self);
		self.empire_bloodyscreen1 = newClientHudElem(self);
		self.empire_bloodyscreen2 = newClientHudElem(self);
		self.empire_bloodyscreen3 = newClientHudElem(self);

		self.empire_bloodyscreen.alignX = "left";
		self.empire_bloodyscreen.alignY = "top";
	
		self.empire_bloodyscreen1.alignX = "left";
		self.empire_bloodyscreen1.alignY = "top";

		self.empire_bloodyscreen2.alignX = "left";
		self.empire_bloodyscreen2.alignY = "top";
		
		self.empire_bloodyscreen3.alignX = "left";
		self.empire_bloodyscreen3.alignY = "top";
		
		bs1 = (randomint(496));
		bs2 = (randomint(336));
		bs1a = (randomint(496));
		bs2a = (randomint(336));
		bs1b = (randomint(496));
		bs2b = (randomint(336));
		bs1c = (randomint(496));
		bs2c = (randomint(336));

		self.empire_bloodyscreen.x = bs1;
		self.empire_bloodyscreen.y = bs2;

		self.empire_bloodyscreen1.x = bs1a;
		self.empire_bloodyscreen1.y = bs2a;

		self.empire_bloodyscreen2.x = bs1b;
		self.empire_bloodyscreen2.y = bs2b;

		self.empire_bloodyscreen3.x = bs1c;
		self.empire_bloodyscreen3.y = bs2c;

		bs3 = randomint(48);
		bs3a = randomint(48);
		bs3b = randomint(48);
		bs3c = randomint(48);
		self.empire_bloodyscreen.color = (1,1,1);
		self.empire_bloodyscreen1.color = (1,1,1);
		self.empire_bloodyscreen2.color = (1,1,1);
		self.empire_bloodyscreen3.color = (1,1,1);
		self.empire_bloodyscreen.alpha = 1;
		self.empire_bloodyscreen1.alpha = 1;
		self.empire_bloodyscreen2.alpha = 1;
		self.empire_bloodyscreen3.alpha = 1;

		self.empire_bloodyscreen SetShader("gfx/impact/flesh_hit1.tga",96 + bs3 , 96 + bs3);
		self.empire_bloodyscreen1 SetShader("gfx/impact/flesh_hit2.tga",96 + bs3a , 96 + bs3a);
		self.empire_bloodyscreen2 SetShader("gfx/impact/flesh_hit1.tga",96 + bs3b , 96 + bs3b);
		self.empire_bloodyscreen3 SetShader("gfx/impact/flesh_hit2.tga",96 + bs3c , 96 + bs3c);

		wait (4);

		if(!isdefined(self.empire_bloodyscreen))
			return;

		self.empire_bloodyscreen fadeOverTime (2); 
		self.empire_bloodyscreen.alpha = 0;
		self.empire_bloodyscreen1 fadeOverTime (2);
		self.empire_bloodyscreen1.alpha = 0;
		self.empire_bloodyscreen2 fadeOverTime (2);
		self.empire_bloodyscreen2.alpha = 0;
		self.empire_bloodyscreen3 fadeOverTime (2);
		self.empire_bloodyscreen3.alpha = 0;
		wait(2);
		self.empire_bloodyscreen destroy();
		self.empire_bloodyscreen1 destroy();
		self.empire_bloodyscreen2 destroy();
		self.empire_bloodyscreen3 destroy();
	}
}

showhit()
{
	self notify("empire_showhit");
	self endon("empire_showhit");
	self endon("empire_spawned");
	self endon("empire_died");
	
	if(isdefined(self.empire_hitblip))
		self.empire_hitblip destroy();

	self.empire_hitblip = newClientHudElem(self);
	self.empire_hitblip.alignX = "center";
	self.empire_hitblip.alignY = "middle";
	self.empire_hitblip.x = 320;
	self.empire_hitblip.y = 240;
	self.empire_hitblip.alpha = 0.5;
	self.empire_hitblip setShader("gfx/hud/hud@fire_ready.tga", 32, 32);
	self.empire_hitblip scaleOverTime(0.15, 64, 64);

	wait 0.15;

	if(isdefined(self.empire_hitblip))
		self.empire_hitblip destroy();
}

// Check if a position is indoor(under a roof) or outdoor(not under a roof)
outdoor(origin)
{
	if(!isdefined(origin))
		return false;

	trace = bulletTrace(origin+(0,0,level.empire_vMax[2]), origin, false, undefined);

	// If it didn't hit ANYTHING, it's outdoor
	if(trace["fraction"] == 1)
		return true;
	else
		return false;
}

bullethole(sHitLoc)
{
	self endon("empire_spawned");

	if(level.empire_bulletholes == 1 && sHitLoc != "head")
		return;

	if(!isPlayer(self))
		return;

	if(!isdefined(self.empire_bulletholes))
		self.empire_bulletholes = [];

	hole = self.empire_bulletholes.size;
	
	self.empire_bulletholes[hole] = newClientHudElem(self);
	self.empire_bulletholes[hole].alignX = "center";
	self.empire_bulletholes[hole].alignY = "middle";
	self.empire_bulletholes[hole].x = 48 + randomInt(544);
	self.empire_bulletholes[hole].y = 48 + randomInt(304);
	self.empire_bulletholes[hole].color = (1,1,1);
	self.empire_bulletholes[hole].alpha = 0.8 + randomFloat(0.2);

	xsize = 64 + randomInt(32);
	ysize = 64 + randomInt(32);

	if(randomInt(2))
		self.empire_bulletholes[hole] setShader("gfx/impact/bullethit_glass.tga", xsize, ysize);
	else
		self.empire_bulletholes[hole] setShader("gfx/impact/bullethit_glass2.tga", xsize, ysize);

	self playLocalSound("bullet_large_glass");
}

updateteamstatus()
{
	level endon("empire_boot");

	for(;;)
	{
		wait 1;

		level.empire_allplayers = getentarray("player", "classname");

		if(level.empire_debugentities)
		{
			allents = getentarray();
			iprintln("Entities:" + allents.size);
		}

		if(!level.empire_showteamstatus || !isdefined(level.empire_teamplay))
			continue;

		if(level.empire_showteamstatus == 1)
		{
			color = (1,1,0);
			deadcolor = (1,0,0);
			if(!isdefined(level.empire_axisicon))
			{
				level.empire_axisicon = newHudElem();	
				level.empire_axisicon.x = 0;
				level.empire_axisicon.y = 16;
				level.empire_axisicon.alignX = "left";
				level.empire_axisicon.alignY = "middle";
				level.empire_axisicon.alpha = 0.7;
				level.empire_axisicon setShader(game["radio_axis"],32,32);
			}
			if(!isdefined(level.empire_axisnumber))
			{
				level.empire_axisnumber = newHudElem();	
				level.empire_axisnumber.x = 32;
				level.empire_axisnumber.y = 12;
				level.empire_axisnumber.alignX = "left";
				level.empire_axisnumber.alignY = "middle";
				level.empire_axisnumber.alpha = 1;
				level.empire_axisnumber.font = "bigfixed";
				level.empire_axisnumber.color = color;
				level.empire_axisnumber setValue(0);
			}
			if(!isdefined(level.empire_deadaxisicon))
			{
				level.empire_deadaxisicon = newHudElem();	
				level.empire_deadaxisicon.x = 64;
				level.empire_deadaxisicon.y = 16;
				level.empire_deadaxisicon.alignX = "left";
				level.empire_deadaxisicon.alignY = "middle";
				level.empire_deadaxisicon.alpha = 0.7;
				level.empire_deadaxisicon setShader("gfx/hud/death_suicide.dds",29,29);
			}
			if(!isdefined(level.empire_deadaxisnumber))
			{
				level.empire_deadaxisnumber = newHudElem();	
				level.empire_deadaxisnumber.x = 96;
				level.empire_deadaxisnumber.y = 12;
				level.empire_deadaxisnumber.alignX = "left";
				level.empire_deadaxisnumber.alignY = "middle";
				level.empire_deadaxisnumber.alpha = 1;
				level.empire_deadaxisnumber.font = "bigfixed";
				level.empire_deadaxisnumber.color = deadcolor;
				level.empire_deadaxisnumber setValue(0);
			}
			if(!isdefined(level.empire_alliedicon))
			{
				level.empire_alliedicon = newHudElem();	
				level.empire_alliedicon.x = 0;
				level.empire_alliedicon.y = 48;
				level.empire_alliedicon.alignX = "left";
				level.empire_alliedicon.alignY = "middle";
				level.empire_alliedicon.alpha = 0.7;
				level.empire_alliedicon setShader(game["radio_allies"],32,32);
			}
			if(!isdefined(level.empire_alliednumber))
			{
				level.empire_alliednumber = newHudElem();	
				level.empire_alliednumber.x = 32;
				level.empire_alliednumber.y = 44;
				level.empire_alliednumber.alignX = "left";
				level.empire_alliednumber.alignY = "middle";
				level.empire_alliednumber.alpha = 1;
				level.empire_alliednumber.font = "bigfixed";
				level.empire_alliednumber.color = color;
				level.empire_alliednumber setValue(0);
			}
			if(!isdefined(level.empire_deadalliedicon))
			{
				level.empire_deadalliedicon = newHudElem();	
				level.empire_deadalliedicon.x = 64;
				level.empire_deadalliedicon.y = 48;
				level.empire_deadalliedicon.alignX = "left";
				level.empire_deadalliedicon.alignY = "middle";
				level.empire_deadalliedicon.alpha = 0.7;
				level.empire_deadalliedicon setShader("gfx/hud/death_suicide.dds",29,29);
			}
			if(!isdefined(level.empire_deadalliednumber))
			{
				level.empire_deadalliednumber = newHudElem();	
				level.empire_deadalliednumber.x = 96;
				level.empire_deadalliednumber.y = 44;
				level.empire_deadalliednumber.alignX = "left";
				level.empire_deadalliednumber.alignY = "middle";
				level.empire_deadalliednumber.alpha = 1;
				level.empire_deadalliednumber.font = "bigfixed";
				level.empire_deadalliednumber.color = deadcolor;
				level.empire_deadalliednumber setValue(0);
			}
		}
		if(level.empire_showteamstatus == 2)
		{
			color = (1,1,0);
			deadcolor = (1,0,0);
			if(!isdefined(level.empire_axisicon))
			{
				level.empire_axisicon = newHudElem();	
				level.empire_axisicon.x = 624;
				level.empire_axisicon.y = 20;
				level.empire_axisicon.alignX = "center";
				level.empire_axisicon.alignY = "middle";
				level.empire_axisicon.alpha = 0.7;
				level.empire_axisicon setShader(game["headicon_axis"],16,16);
			}
			if(!isdefined(level.empire_axisnumber))
			{
				level.empire_axisnumber = newHudElem();	
				level.empire_axisnumber.x = 624;
				level.empire_axisnumber.y = 36;
				level.empire_axisnumber.alignX = "center";
				level.empire_axisnumber.alignY = "middle";
				level.empire_axisnumber.alpha = 0.8;
				level.empire_axisnumber.fontscale = 1.0;
				level.empire_axisnumber.color = color;
				level.empire_axisnumber setValue(0);
			}
			if(!isdefined(level.empire_deadaxisicon))
			{
				level.empire_deadaxisicon = newHudElem();	
				level.empire_deadaxisicon.x = 592;
				level.empire_deadaxisicon.y = 52;
				level.empire_deadaxisicon.alignX = "center";
				level.empire_deadaxisicon.alignY = "middle";
				level.empire_deadaxisicon.alpha = 0.7;
				level.empire_deadaxisicon setShader("gfx/hud/death_suicide.dds",16,16);
			}
			if(!isdefined(level.empire_deadaxisnumber))
			{
				level.empire_deadaxisnumber = newHudElem();	
				level.empire_deadaxisnumber.x = 624;
				level.empire_deadaxisnumber.y = 52;
				level.empire_deadaxisnumber.alignX = "center";
				level.empire_deadaxisnumber.alignY = "middle";
				level.empire_deadaxisnumber.alpha = 0.8;
				level.empire_deadaxisnumber.fontscale = 1.0;
				level.empire_deadaxisnumber.color = deadcolor;
				level.empire_deadaxisnumber setValue(0);
			}
			if(!isdefined(level.empire_alliedicon))
			{
				level.empire_alliedicon = newHudElem();	
				level.empire_alliedicon.x = 608;
				level.empire_alliedicon.y = 20;
				level.empire_alliedicon.alignX = "center";
				level.empire_alliedicon.alignY = "middle";
				level.empire_alliedicon.alpha = 0.7;
				level.empire_alliedicon setShader(game["headicon_allies"],16,16);
			}
			if(!isdefined(level.empire_alliednumber))
			{
				level.empire_alliednumber = newHudElem();	
				level.empire_alliednumber.x = 608;
				level.empire_alliednumber.y = 36;
				level.empire_alliednumber.alignX = "center";
				level.empire_alliednumber.alignY = "middle";
				level.empire_alliednumber.alpha = 0.8;
				level.empire_alliednumber.fontscale = 1.0;
				level.empire_alliednumber.color = color;
				level.empire_alliednumber setValue(0);
			}
			if(!isdefined(level.empire_deadalliednumber))
			{
				level.empire_deadalliednumber = newHudElem();	
				level.empire_deadalliednumber.x = 608;
				level.empire_deadalliednumber.y = 52;
				level.empire_deadalliednumber.alignX = "center";
				level.empire_deadalliednumber.alignY = "middle";
				level.empire_deadalliednumber.alpha = 0.8;
				level.empire_deadalliednumber.fontscale = 1.0;
				level.empire_deadalliednumber.color = deadcolor;
				level.empire_deadalliednumber setValue(0);
			}
		}
		allies = [];
		axis = [];
		deadallies = [];
		deadaxis = [];
		for(i = 0; i < level.empire_allplayers.size; i++)
		{
			if(level.empire_allplayers[i].sessionstate == "playing" && level.empire_allplayers[i].sessionteam == "allies")
				allies[allies.size] = level.empire_allplayers[i];
			if(level.empire_allplayers[i].sessionstate != "playing" && level.empire_allplayers[i].sessionteam == "allies")
				deadallies[deadallies.size] = level.empire_allplayers[i];
			if(level.empire_allplayers[i].sessionstate == "playing" && level.empire_allplayers[i].sessionteam == "axis")
				axis[axis.size] = level.empire_allplayers[i];
			if(level.empire_allplayers[i].sessionstate != "playing" && level.empire_allplayers[i].sessionteam == "axis")
				deadaxis[deadaxis.size] = level.empire_allplayers[i];
		}
		level.empire_axisnumber setValue(axis.size);
		level.empire_alliednumber setValue(allies.size);
		level.empire_deadaxisnumber setValue(deadaxis.size);
		level.empire_deadalliednumber setValue(deadallies.size);
	}
}

overrideteams()
{
	if(isdefined(level.empire_classbased) || level.empire_uomap)
		return;

	// It it's the same map and gametype, use old values to avoid non precached models
	if( getcvar("mapname") == getcvar("empire_oldmap") && getcvar("g_gametype") == getcvar("empire_oldgt") )
	{
		game["allies"] = getcvar("empire_allies");
		game[game["allies"] + "_soldiertype"] 	= getcvar("empire_soldiertype");
		game[game["allies"] + "_soldiervariation"]= getcvar("empire_soldiervariation");
		if(game["allies"] == "american" && game[game["allies"] + "_soldiervariation"] == "winter")
		{
			game["german_soldiertype"] = "wehrmacht";
			game["german_soldiervariation"] = "winter";
		}
		return;
	}

	// Override allies team
	switch(level.empire_teamallies)
	{
		case "american":
		case "british":
		case "german":
		case "russian":
			game["allies"] = level.empire_teamallies;
			break;

		case "random":
			allies = [];
			oldteam = getcvar("empire_allies");
			if(oldteam != "american")	allies[allies.size] = "american";
			if(oldteam != "british")	allies[allies.size] = "british";
			if(oldteam != "russian")	allies[allies.size] = "russian";
			game["allies"] = allies[randomInt(allies.size)];
			break;

		default:
			break;
	}

	if(!isdefined(game[ game["allies"] + "_soldiertype" ]))
	{
		switch(game["allies"])
		{
			case "american":
				if(isdefined(level.empire_wintermap))
				{
					game["american_soldiertype"] = "airborne";
					game["american_soldiervariation"] = "winter";
					game["german_soldiertype"] = "wehrmacht";
					game["german_soldiervariation"] = "winter";
				}
				else	
				{
					game["american_soldiertype"] = "airborne";
					game["american_soldiervariation"] = "normal";
				}
				break;

			case "british":
				if(isdefined(level.empire_wintermap))
				{
					game["british_soldiertype"] = "commando";
					game["british_soldiervariation"] = "winter";
				}
				else
				{
					switch(randomInt(2))
					{
						case 0:
							game["british_soldiertype"] = "airborne";
							game["british_soldiervariation"] = "normal";
							break;
	
						default:
							game["british_soldiertype"] = "commando";
							game["british_soldiervariation"] = "normal";
							break;
					}
				}
				break;

			case "russian":
				if(isdefined(level.empire_wintermap))
				{
					switch(randomInt(2))
					{
						case 0:
							game["russian_soldiertype"] = "conscript";
							game["russian_soldiervariation"] = "winter";
							break;

						default:
							game["russian_soldiertype"] = "veteran";
							game["russian_soldiervariation"] = "winter";
							break;
					}
				}
				else
				{
					switch(randomInt(2))
					{
						case 0:
							game["russian_soldiertype"] = "conscript";
							game["russian_soldiervariation"] = "normal";
							break;


						default:
							game["russian_soldiertype"] = "veteran";
							game["russian_soldiervariation"] = "normal";
							break;

					}
				}
				break;
		}
	}

	// Save stuff for reinitializing in roundbased gametypes
	setcvar("empire_oldgt",	getcvar("g_gametype") );
	setcvar("empire_oldmap",	getcvar("mapname") );
	setcvar("empire_allies",			game["allies"] );
	setcvar("empire_soldiertype", 		game[game["allies"] + "_soldiertype"] );
	setcvar("empire_soldiervariation",	game[game["allies"] + "_soldiervariation"] );
}

showlogo()
{
	if(level.empire_showserverlogo)
	{
		if(isdefined(level.empire_serverlogo))
			level.empire_serverlogo destroy();

		level.empire_serverlogo = newHudElem();	
		if(level.empire_showserverlogo == 1)
		{
			level.empire_serverlogo.x = 3;
			level.empire_serverlogo.alignX = "left";
		}
		else
		{
			level.empire_serverlogo.x = 320;
			level.empire_serverlogo.alignX = "center";
		}
		if(isdefined(level.empire_uo))
			level.empire_serverlogo.y = 474;
		else
			level.empire_serverlogo.y = 475;

		level.empire_serverlogo.alignY = "middle";
		level.empire_serverlogo.sort = -3;
		level.empire_serverlogo.alpha = 1;
		level.empire_serverlogo.fontScale = 0.7;
		level.empire_serverlogo.archived = true;
		level.empire_serverlogo setText(level.empire_serverlogotext);
	}

	if(level.empire_showlogo)
	{
		if(isdefined(level.empire_logo))
			level.empire_logo destroy();

		level.empire_logo = newHudElem();	
		level.empire_logo.x = 630;
		if(isdefined(level.empire_uo))
			level.empire_logo.y = 474;
		else
			level.empire_logo.y = 475;
		level.empire_logo.alignX = "right";
		level.empire_logo.alignY = "middle";
		level.empire_logo.sort = -3;
		level.empire_logo.alpha = 1;
		level.empire_logo.fontScale = 0.7;
		level.empire_logo.archived = true;
		level.empire_logo setText(level.empire_logotext);
	}
}

overridefog()
{
	if(isdefined(level.empire_cfog) && randomInt(100) < level.empire_cfog)
	{
		if(level.empire_cfogdistance2)
			thread fadeCullFog();
		else
			setCullFog(0, level.empire_cfogdistance, level.empire_cfogred, level.empire_cfoggreen, level.empire_cfogblue, 0);
	}
	else if(isdefined(level.empire_efog) && randomInt(100) < level.empire_efog)
	{
		if(level.empire_efogdensity2)
			thread fadeExpFog();
		else
			setExpFog(level.empire_efogdensity, level.empire_efogred, level.empire_efoggreen, level.empire_efogblue, 0);
	}
}

fadeCullFog()
{
	level endon("empire_boot");

	if(isdefined(level.empire_roundbased))
	{
		time = level.roundlength * 30;
		if(!time) time = 5 * 30;
	}
	else
	{
		time = level.timelimit * 30;
		if(!time) time = 20 * 30;
	}
	if(randomInt(2))
	{
		start = level.empire_cfogdistance;
		end = level.empire_cfogdistance2;
	}
	else
	{
		start = level.empire_cfogdistance2;
		end = level.empire_cfogdistance;
	}
	distance = start;
	delta = (end - start)/time;
	for(i=0;i<time;i++)
	{
		setCullFog(0, distance, level.empire_cfogred, level.empire_cfoggreen, level.empire_cfogblue, 0);
		distance = distance + delta;
		wait 1;
	}
	distance = end;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setCullFog(0, distance, level.empire_cfogred, level.empire_cfoggreen, level.empire_cfogblue, 0);
		distance = distance + delta;
		wait 1;
	}
	distance = start;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setCullFog(0, distance, level.empire_cfogred, level.empire_cfoggreen, level.empire_cfogblue, 0);
		distance = distance + delta;
		wait 1;
	}
	distance = end;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setCullFog(0, distance, level.empire_cfogred, level.empire_cfoggreen, level.empire_cfogblue, 0);
		distance = distance + delta;
		wait 1;
	}
}

fadeExpFog()
{
	level endon("empire_boot");

	if(isdefined(level.empire_roundbased))
	{
		time = level.roundlength * 30;
		if(!time) time = 5 * 30;
	}
	else
	{
		time = level.timelimit * 30;
		if(!time) time = 20 * 30;
	}
	if(randomInt(2))
	{
		start = level.empire_efogdensity;
		end = level.empire_efogdensity2;
	}
	else
	{
		start = level.empire_efogdensity2;
		end = level.empire_efogdensity;
	}
	density = (float)start;
	delta = (float)(end - start)/(float)time;
	for(i=0;i<time;i++)
	{
		setExpFog(density, level.empire_efogred, level.empire_efoggreen, level.empire_efogblue, 0);
		density = (float)density + (float)delta;
		wait 1;
	}
	density = (float)end;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setExpFog(density, level.empire_efogred, level.empire_efoggreen, level.empire_efogblue, 0);
		density = (float)density + (float)delta;
		wait 1;
	}
	density = (float)start;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setExpFog(density, level.empire_efogred, level.empire_efoggreen, level.empire_efogblue, 0);
		density = (float)density + (float)delta;
		wait 1;
	}
	density = (float)end;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setExpFog(density, level.empire_efogred, level.empire_efoggreen, level.empire_efogblue, 0);
		density = (float)density + (float)delta;
		wait 1;
	}
}

swapteams()
{
	if(level.empire_disable) return;

	if(game["roundsplayed"] == 0 || !game["matchstarted"])
		return;

	if(game["roundsplayed"] == 1 && level.empire_warmupround && !isdefined(game["empire_warmupdone"]) )
	{
		thread resetScores();
		game["roundsplayed"] = 0;
		game["empire_warmupdone"] = true;
		return;
	}

	if(!level.empire_teamswap)
		return;


	// Swap all players
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(level.empire_debug)
			iprintlnbold("Player:" + i + " Team:" + players[i].pers["team"]);

		// Only swap axis and allies, not spectators
		if(players[i].pers["team"] != "allies" && players[i].pers["team"] != "axis")
			continue;

		if(players[i].pers["team"] == "axis")
		{
			newTeam = "allies";
			if(isdefined(players[i].pers["weapon"]))	players[i].pers["empire_axisweapon"]	= players[i].pers["weapon"];
			if(isdefined(players[i].pers["weapon1"]))	players[i].pers["empire_axisweapon1"]	= players[i].pers["weapon1"];
			if(isdefined(players[i].pers["weapon2"]))	players[i].pers["empire_axisweapon2"]	= players[i].pers["weapon2"];
			if(isdefined(players[i].pers["spawnweapon"])) players[i].pers["empire_axisspawnweapon"] = players[i].pers["spawnweapon"];
		}
		if(players[i].pers["team"] == "allies")
		{
			newTeam = "axis";
			if(isdefined(players[i].pers["weapon"]))	players[i].pers["empire_alliedweapon"]	= players[i].pers["weapon"];
			if(isdefined(players[i].pers["weapon1"]))	players[i].pers["empire_alliedweapon1"]	= players[i].pers["weapon1"];
			if(isdefined(players[i].pers["weapon2"]))	players[i].pers["empire_alliedweapon2"]	= players[i].pers["weapon2"];
			if(isdefined(players[i].pers["spawnweapon"])) players[i].pers["empire_alliedspawnweapon"] = players[i].pers["spawnweapon"];
		}

		players[i].pers["team"] = newTeam;
		players[i].pers["weapon"] = undefined;
		players[i].pers["weapon1"] = undefined;
		players[i].pers["weapon2"] = undefined;
		players[i].pers["spawnweapon"] = undefined;
		players[i].pers["savedmodel"] = undefined;

		// update spectator permissions immediately on change of team
		players[i] maps\mp\gametypes\_teams::SetSpectatePermissions();
	
		if(players[i].pers["team"] == "allies")
		{
			// Set old allied weapon if available
			if(isdefined(players[i].pers["empire_alliedweapon"]))	players[i].pers["weapon"]	= players[i].pers["empire_alliedweapon"];
			if(isdefined(players[i].pers["empire_alliedweapon1"]))	players[i].pers["weapon1"]	= players[i].pers["empire_alliedweapon1"];
			if(isdefined(players[i].pers["empire_alliedweapon2"]))	players[i].pers["weapon2"]	= players[i].pers["empire_alliedweapon2"];
			if(isdefined(players[i].pers["empire_alliedspawnweapon"])) players[i].pers["spawnweapon"] = players[i].pers["empire_alliedspawnweapon"];

		}
		else
		{
			// Set old axis weapon if available
			if(isdefined(players[i].pers["empire_axisweapon"]))	players[i].pers["weapon"]	= players[i].pers["empire_axisweapon"];
			if(isdefined(players[i].pers["empire_axisweapon1"]))	players[i].pers["weapon1"]	= players[i].pers["empire_axisweapon1"];
			if(isdefined(players[i].pers["empire_axisweapon2"]))	players[i].pers["weapon2"]	= players[i].pers["empire_axisweapon2"];
			if(isdefined(players[i].pers["empire_axisspawnweapon"])) players[i].pers["spawnweapon"] = players[i].pers["empire_axisspawnweapon"];
		}

	}

	// Swap team scores
	tempscore =  game["alliedscore"];
	game["alliedscore"] = game["axisscore"];
	game["axisscore"] = tempscore;
	setTeamScore("allies", game["alliedscore"]);
	setTeamScore("axis", game["axisscore"]);
	
	if(level.empire_debug)
		iprintlnbold("Teams has been swapped.");
}

warmupround()
{
	if(!isdefined(level.empire_roundbased))
		return;

	if(isdefined(level.empire_warmupmsg))
		level.empire_warmupmsg destroy();

	if(game["roundsplayed"] == 0 && game["matchstarted"] && level.empire_warmupround && !isdefined(game["empire_warmupdone"]) )
	{
		if(!isdefined(level.empire_warmupmsg))
		{
			level.empire_warmupmsg = newHudElem();
			level.empire_warmupmsg.archived = false;
			level.empire_warmupmsg.x = 320;
			level.empire_warmupmsg.y = 80;
			level.empire_warmupmsg.alignX = "center";
			level.empire_warmupmsg.alignY = "middle";
			level.empire_warmupmsg.fontScale = 2;
			level.empire_warmupmsg setText(&"^1Warmup Round!!");
		}
	}
}

resetScores()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player.pers["score"] = 0;
		player.pers["deaths"] = 0;
		player.pers["empire_teamkills"] = 0;
		player.pers["empire_teamdamage"] = 0;
		player.pers["empire_teamkiller"] = undefined;
	}

	game["alliedscore"] = 0;
	setTeamScore("allies", game["alliedscore"]);
	game["axisscore"] = 0;
	setTeamScore("axis", game["axisscore"]);
}

turretStuff()
{
	level endon("empire_boot");

	// Wait a servercycle to make sure unwanted entities has been removed
	wait .05;

	// Count all turrets
	allent = getentarray();	// Get all entities

	numturrets=0;

	for(i=0;i<allent.size;i++)	// Loop through them
	{
		if(isdefined(allent[i]))		// Exist?
		{
			if(isdefined(allent[i].weaponinfo))		// Weapon?
			{
				switch(allent[i].weaponinfo)
				{
					case "mg42_bipod_prone_mp":
						if(level.empire_debug)
							iprintln("Turret Angles: " + allent[i].angles[0] + " " + allent[i].angles[1] + " " + allent[i].angles[2]);
					case "mg42_bipod_stand_mp":
					case "mg42_bipod_duck_mp":
					case "PTRS41_Antitank_Rifle":
						numturrets++;
						break;

					default:
						break;
				}
			}
		}
	}

	// Disable all MG42:s on the map	
	if(level.empire_mg42disable)
	{
		mgs=getEntArray("misc_mg42","classname");
		for (i=0;i<mgs.size;i++)
			if(isdefined(mgs[i]))
			{
				mgs[i] delete();				
				numturrets--;
			}

		mgs=getEntArray("misc_turret","classname");
		for (i=0;i<mgs.size;i++)
			if(isdefined(mgs[i]))
			{
				if(isdefined(mgs[i].weaponinfo))		// Weaponinfo?
				{
					switch(mgs[i].weaponinfo)
					{
						case "mg42_bipod_prone_mp":
						case "mg42_bipod_stand_mp":
						case "mg42_bipod_duck_mp":
							mgs[i] delete();				
							numturrets--;
							break;

						default:
							break;
					}
				}
			}
	}

	// Disable all PTRS41:s on the map	
	if(level.empire_ptrs41disable)
	{
		mgs=getEntArray("misc_ptrs","classname");
		for (i=0;i<mgs.size;i++)
			if(isdefined(mgs[i]))
			{
				mgs[i] delete();				
				numturrets--;
			}
	}	

	if(level.empire_mg42disable || level.empire_ptrs41disable)
		wait 0.05;	// Allow changes to happen

	// Spawn extra MG42s and/or PTRS41 at specific locations

	// Get first turret
	count = 0;
	x = cvardef("empire_turret_x" + count, 0, -50000, 50000, "int");
	y = cvardef("empire_turret_y" + count, 0, -50000, 50000, "int");
	z = cvardef("empire_turret_z" + count, 0, -50000, 50000, "int");
	a = cvardef("empire_turret_a" + count, 0, -50000, 50000, "int");
	w = cvardef("empire_turret_w" + count, "", "", "", "string");

	// spawn turrets
	while(w != "" && numturrets < 32)
	{
		switch(w)
		{
			case "mg42_bipod_stand_mp":
			case "mg42_bipod_duck_mp":
			case "mg42_bipod_prone_mp":
				name	= "misc_mg42";
				model	= "xmodel/mg42_bipod";
				break;

			default:
				name	= "misc_ptrs";
				model = "xmodel/weapon_antitankrifle"; 
				break;
		}

		position = (x,y,z);
		turret = spawnTurret (name, position, w);
 		turret setmodel (model);
		turret.weaponinfo = w;
		turret.angles = (0,a,0);
		turret.origin = position + (0,0,-1);	//do this LAST. It'll move the MG into a usable position
		turret show();

		numturrets++;		
		count++;

		x = cvardef("empire_turret_x" + count, 0, -50000, 50000, "int");
		y = cvardef("empire_turret_y" + count, 0, -50000, 50000, "int");
		z = cvardef("empire_turret_z" + count, 0, -50000, 50000, "int");
		a = cvardef("empire_turret_a" + count, 0, -50000, 50000, "int");
		w = cvardef("empire_turret_w" + count, "", "", "", "string");
	}

	// Spawn extra MG42s and/or PTRS41
	if(level.empire_mg42spawnextra || level.empire_ptrs41spawnextra)
	{
		spawnallied	= getentarray(level.empire_spawnalliedname, "classname");
		spawnaxis	= getentarray(level.empire_spawnaxisname, "classname");

		// Fall back to deatchmatch spawns, just in case. (Needed for LTS on non SD maps)
		if(!spawnallied.size)
			spawnallied	= getentarray("mp_deathmatch_spawn", "classname");
		if(!spawnallied.size)
			spawnallied	= getentarray("mp_teamdeathmatch_spawn", "classname");
		if(!spawnaxis.size)
			spawnaxis	= getentarray("mp_deathmatch_spawn", "classname");
		if(!spawnaxis.size)
			spawnaxis	= getentarray("mp_teamdeathmatch_spawn", "classname");

		oddeven=randomInt(2);
		for(i=0;i<level.empire_mg42spawnextra && numturrets<32;i++)
		{
			// Get a random spawn point
			if(oddeven)
			{
				spawn = spawnallied[randomInt(spawnallied.size)];
				oddeven=0;
			}
			else
			{
				spawn = spawnaxis[randomInt(spawnaxis.size)];
				oddeven=1;
			}

			position = spawn.origin - ( 15, 15, 0) + ( randomInt(31), randomInt(31), 0);
			trace=bulletTrace(position,position+(0,0,-1200),false,undefined);
			ground=trace["position"];
			turret = spawn("script_model", ground+(0,0,-10000));
			turret.targetname = "dropped_mg42";
			turret setmodel ( "xmodel/mg42_bipod"  );
			turret.angles = (0,randomInt(360),125);
			turret.origin = ground + (0,0,11);  //get the little feet into the terrain
			turret show();

			numturrets++;
		}
	
		oddeven=randomInt(2);
		for(i=0;i<level.empire_ptrs41spawnextra && numturrets<32;i++)
		{
			// Get a random spawn point
			if(oddeven)
			{
				spawn = spawnallied[randomInt(spawnallied.size)];
				oddeven=0;
			}
			else
			{
				spawn = spawnaxis[randomInt(spawnaxis.size)];
				oddeven=1;
			}

			position = spawn.origin - ( 15, 15, 0) + ( randomInt(31), randomInt(31), 0);
			trace=bulletTrace(position,position+(0,0,-1200),false,undefined);
			ground=trace["position"];
			turret = spawn("script_model", ground + (0,0,-10000));
			turret.targetname = "dropped_ptrs";
			turret setmodel ( "xmodel/weapon_antitankrifle"  );
			turret.angles = (0,randomInt(360),112);
			turret.origin = ground + (0,0,11);
			turret show();

			numturrets++;
		}
	}	

	wait 0.05;	// Allow changes to happen

	// Build turret array
	level.empire_turrets = [];

	allent = getentarray();	// Get all entities

	for(i=0;i<allent.size;i++)	// Loop through them
	{
		if(isdefined(allent[i]))		// Exist?
		{
			if(isdefined(allent[i].weaponinfo))		// Weapon?
			{
				switch(allent[i].weaponinfo)
				{
					case "mg42_bipod_stand_mp":
					case "mg42_bipod_duck_mp":
					case "mg42_bipod_prone_mp":
						level.empire_turrets[level.empire_turrets.size]["turret"] = allent[i];
						level.empire_turrets[level.empire_turrets.size - 1]["type"] = "misc_mg42";
						level.empire_turrets[level.empire_turrets.size - 1]["original_position"] = allent[i].origin;
						level.empire_turrets[level.empire_turrets.size - 1]["original_angles"] = allent[i].angles;
						level.empire_turrets[level.empire_turrets.size - 1]["original_weaponinfo"]= allent[i].weaponinfo;
						level.empire_turrets[level.empire_turrets.size - 1]["dropped"] = undefined;
						level.empire_turrets[level.empire_turrets.size - 1]["carried"] = undefined;
						break;

					case "PTRS41_Antitank_Rifle_mp":
						level.empire_turrets[level.empire_turrets.size]["turret"] = allent[i];
						level.empire_turrets[level.empire_turrets.size - 1]["type"] = "misc_ptrs";
						level.empire_turrets[level.empire_turrets.size - 1]["original_position"] = allent[i].origin;
						level.empire_turrets[level.empire_turrets.size - 1]["original_angles"]	= allent[i].angles;
						level.empire_turrets[level.empire_turrets.size - 1]["original_weaponinfo"]=allent[i].weaponinfo;
						level.empire_turrets[level.empire_turrets.size - 1]["dropped"] = undefined;
						level.empire_turrets[level.empire_turrets.size - 1]["carried"] = undefined;
						break;

					default:
						break;
				}
			}
		}
	}

	// Get dropped turrets
	mgs=getEntArray("dropped_mg42","targetname");
	for (i=0;i<mgs.size;i++)
	{
		if(isdefined(mgs[i]))
		{
			level.empire_turrets[level.empire_turrets.size]["turret"] = mgs[i];
			level.empire_turrets[level.empire_turrets.size - 1]["type"] = "misc_mg42";
			level.empire_turrets[level.empire_turrets.size - 1]["original_position"] = mgs[i].origin;
			level.empire_turrets[level.empire_turrets.size - 1]["original_angles"]	= mgs[i].angles;
			level.empire_turrets[level.empire_turrets.size - 1]["original_weaponinfo"]= undefined;
			level.empire_turrets[level.empire_turrets.size - 1]["dropped"] = true;
			level.empire_turrets[level.empire_turrets.size - 1]["carried"] = undefined;
		}
	}

	mgs=getEntArray("dropped_ptrs","targetname");
	for (i=0;i<mgs.size;i++)
	{
		if(isdefined(mgs[i]))
		{
			level.empire_turrets[level.empire_turrets.size]["turret"] = mgs[i];
			level.empire_turrets[level.empire_turrets.size - 1]["type"] = "misc_ptrs";
			level.empire_turrets[level.empire_turrets.size - 1]["original_position"] = mgs[i].origin;
			level.empire_turrets[level.empire_turrets.size - 1]["original_angles"]	= mgs[i].angles;
			level.empire_turrets[level.empire_turrets.size - 1]["original_weaponinfo"]=undefined;
			level.empire_turrets[level.empire_turrets.size - 1]["dropped"] = true;
			level.empire_turrets[level.empire_turrets.size - 1]["carried"] = undefined;
		}
	}

	// Kill original turret think threads
	for(i=0;i<level.empire_turrets.size;i++)
		if( !isdefined(level.empire_turrets[i]["dropped"]) && !isdefined(level.empire_turrets[i]["carried"]) )
			level.empire_turrets[i]["turret"] notify("death");

	wait .05;

	// Restore turret overheating threads
	for(i=0;i<level.empire_turrets.size;i++)
		if( !isdefined(level.empire_turrets[i]["dropped"]) && !isdefined(level.empire_turrets[i]["carried"]) )
			level.empire_turrets[i]["turret"] thread maps\mp\_empire_turret::turret_think(i);
}

cookgrenade()
{
	if(isdefined(self.empire_cooking)) return;
	self.empire_cooking = true;

	self endon("empire_spawned");
	self endon("empire_died");

	if(!isdefined(level.empire_uo) && level.empire_showcooking)		// Cookable grenades?
	{
		if(isdefined(self.empire_cookbar))
		{
			self.empire_cookbarbackground destroy();
			self.empire_cookbar destroy();
			self.empire_cookbartext destroy();
		}
			
		// Size of progressbar
		barsize = 288;
	
		// Time for progressbar	
		bartime = (float)level.empire_fusetime - 0.15;

		// Background
		self.empire_cookbarbackground = newClientHudElem(self);				
		self.empire_cookbarbackground.alignX = "center";
		self.empire_cookbarbackground.alignY = "middle";
		self.empire_cookbarbackground.x = 320;
		self.empire_cookbarbackground.y = 385;
		self.empire_cookbarbackground.alpha = 0.5;
		self.empire_cookbarbackground.color = (0,0,0);
		self.empire_cookbarbackground setShader("white", (barsize + 4), 12);			

		// Progress bar
		self.empire_cookbar = newClientHudElem(self);				
		self.empire_cookbar.alignX = "left";
		self.empire_cookbar.alignY = "middle";
		self.empire_cookbar.x = (320 - (barsize / 2.0));
		self.empire_cookbar.y = 385;
		self.empire_cookbar.color = (1,1,1);
		self.empire_cookbar.alpha = 0.7;
		self.empire_cookbar setShader("white", 0, 8);
		self.empire_cookbar scaleOverTime(bartime , barsize, 8);

		// Text
		self.empire_cookbartext = newClientHudElem(self);
		self.empire_cookbartext.alignX = "center";
		self.empire_cookbartext.alignY = "middle";
		self.empire_cookbartext.x = 320;
		self.empire_cookbartext.y = 384;
		self.empire_cookbartext.fontscale = 0.8;
		self.empire_cookbartext.color = (.5,.5,.5);
		self.empire_cookbartext settext (&"Cooking grenade");

		// Init counter for tick sound
		tickcounter=0;
		self playlocalsound("bomb_tick");

		// Cooktime is fusetime * 20 - 2 (Usually 79)
		cooktime = 4 * 20 - 2;

		// Cook
		for(i=0;i<cooktime;i++)
		{
			color = (float)i/(float)cooktime;
			self.empire_cookbar.color = (1,1-color,1-color);

			// Break if grenade is thrown
			if(!self attackButtonPressed() || !isWeaponType("grenade", self getCurrentWeapon() ) )
				break;
			else
			{
				// Play bomb_tick every second
				tickcounter++;
				if(tickcounter >=20) {
					self playlocalsound("bomb_tick");
					tickcounter=0;
				}
				wait .05;
			}
			if(!isAlive(self) || self.sessionstate != "playing")
				break;
		}

		// Remove hud elements
		if(isdefined(self.empire_cookbarbackground))
			self.empire_cookbarbackground destroy();
		if(isdefined(self.empire_cookbar))
			self.empire_cookbar destroy();
		if(isdefined(self.empire_cookbartext))
			self.empire_cookbartext destroy();

		if(i>=cooktime)
		{
			// !!! OVERCOOKED !!!	

			sWeapon = self getWeaponSlotWeapon("grenade");
			// Remove grenade before it goes off.
			self setWeaponSlotWeapon("grenade", "none");
			wait 0.05;	

			// play the hit sound
			self playsound("grenade_explode_default");
			// explode 
			playfxontag(level.empire_effect["bombexplosion"], self, "Bip01 R Hand");
			wait .05;

			iRange = 350;
			iMaxdamage = 120;
			iMindamage = 5;
			if(isdefined(level.empire_dmgmod[sWeapon]))
			{
				iMaxdamage = iMaxdamage * level.empire_dmgmod[sWeapon];
				iMindamage = iMindamage * level.empire_dmgmod[sWeapon];
			}

			self scriptedRadiusDamage(self, (0,0,32), sWeapon, iRange, iMaxdamage, iMindamage, false);

			self.empire_cooking = undefined;
			return;
		}
	}
	else // Normal grenade
		while(self attackButtonPressed() && isWeaponType("grenade", self getCurrentWeapon() ) && isAlive(self) && self.sessionstate == "playing")
			wait .05;

	// Thrown a grenade?
	if(isWeaponType("grenade",self getCurrentWeapon()) && !self attackButtonPressed() &&  isAlive(self) && self.sessionstate == "playing")
	{
		if( (randomInt(100) < level.empire_grenadewarning) && self teamMateInRange(level.empire_grenadewarningrange) )
		{
			// Yell "Grenade!"
			soundalias = level.empire_grenadevoices[ game[ self.pers["team"] ] ][randomInt(level.empire_grenadevoices[ game[ self.pers["team"] ] ].size)];
			self playsound(soundalias);
		}
	}
	self.empire_cooking = undefined;
}

checkStickyPlacement(sWeapon)
{
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");

	if(isdefined(self.empire_checkstickyplacement)) return;
	self.empire_checkstickyplacement = true;

	//stay here until player lets go of melee button
	while( isdefined(self) && isAlive( self ) && self.sessionstate=="playing" && self meleeButtonPressed() )
		wait( 0.1 );

	// Check existance and life signs
	if(!isdefined(self) || !isAlive(self) || self.sessionstate!="playing")
	{
		self.empire_checkstickyplacement = undefined;
		return;
	}

	// Make sure player has not gone prone
	stance = self aweGetStance(false);
	if(stance == 2)
	{
		self.empire_checkstickyplacement = undefined;
		return;
	}

	// Check slot
	if(sWeapon == "satchelcharge_mp")
	{
		model = "xmodel/w_us_grn_satchel_game";
		slot = "satchel";
		aOffset = (90,0,-90);
	}
	else
	{
		model = getGrenadeModel(sWeapon);
		slot = "grenade";
		aOffset = (0,0,0);
	}

	// Check ammo
	iAmmo = self getWeaponSlotClipAmmo(slot);
	if(!iAmmo)
	{
		self.empire_checkstickyplacement = undefined;
		return;
	}

	switch(stance)
	{
		case 1:
			offset = (0,0,40);
			break;
		default:
			offset = (0,0,60);
			break;
	}

	// Get position
	position = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles),50);

	// Check for surface
	roll = 0;
	voffset = 0;
	trace=bulletTrace(self.origin+offset,position+offset,true,self);


	if(trace["fraction"]==1)
	{
		position = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles),35);
		trace=bulletTrace(position+offset, position + offset - (0,0,20),true,self);
		if(trace["fraction"]==1 || (isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "player") )
		{
			self.empire_checkstickyplacement = undefined;
			return;
		}
		voffset = 0;
	}
	else if(level.empire_stickynades<2 && isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "player")
	{
		self.empire_checkstickyplacement = undefined;
		return;
	}

	// Decrease grenade ammo
	iAmmo--;
	if(iAmmo)
		self setWeaponSlotClipAmmo(slot, iAmmo);
	else
	{
		self setWeaponSlotClipAmmo(slot, iAmmo);
		self setWeaponSlotWeapon(slot, "none");
		newWeapon = self getWeaponSlotWeapon("primary");
		if(newWeapon=="none") newWeapon = self getWeaponSlotWeapon("primaryb");
		if(newWeapon=="none") newWeapon = self getWeaponSlotWeapon("pistol");
		if(newWeapon!="none") self switchToWeapon(newWeapon);
	}	


	// Spawn grenade/satchel
	stickybomb = spawn("script_model",trace["position"] + (0,0,voffset));
	antinormal = maps\mp\_utility::vectorscale(trace["normal"], -1);
	stickybomb.angles = vectortoangles(antinormal) + aOffset;
	stickybomb setModel(model);

	if(isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "script_vehicle")
	{
		stickybomb linkto(trace["entity"]);
		stickybomb.empire_linked = true;
	}
	else if(level.empire_stickynades==2 && isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "player")
	{
		stickybomb linkto(trace["entity"]);
		stickybomb.empire_linked = true;
		stickybomb.empire_linkedto = trace["entity"];
	}

	stickybomb thread monitorSticky(self, sWeapon);

	self.empire_checkstickyplacement = undefined;
}

waitForStickyDamage(maxDamage)
{
	if(!isdefined(level.empire_uo))
		return;

	level endon("empire_boot");
	self endon("empire_waitforstickydamage");

	self maps\mp\gametypes\_empire_uncommon::aweSetTakeDamage(true);
	self.damaged = undefined;

	for(;;)
	{
		self waittill ("damage", dmg, who, dir, point, mod);
		if(dmg>=maxDamage || isdefined(self.damaged)) break;
	}
	self.damaged = true;
}

monitorSticky(owner, sWeapon)
{
	level endon("empire_boot");
	self endon("empire_monitorsticky");

	// Save old team if teamplay
	if(isdefined(level.empire_teamplay))
		oldteam = owner.sessionteam;

	if(sWeapon == "satchelcharge_mp")
	{
		delay = level.empire_stickynadessatchelfuse;
		oDmg = 500;
		iDmg = 20;
		range = 450;
		self thread waitForStickyDamage(150);
	}
	else
	{
		delay = level.empire_stickynadesgrenadefuse;
		oDmg = 120;
		iDmg = 5;
		range = 350;
		self thread waitForStickyDamage(100);
	}

	if(isdefined(level.empire_dmgmod[sWeapon]))
	{
		oDmg = oDmg * level.empire_dmgmod[sWeapon];
		iDmg = iDmg * level.empire_dmgmod[sWeapon];
	}

	wait 0.05;

	self playsound("weap_fraggrenade_pin");

	for(i=1;i<delay*20;i++)
	{
		// Check if linked player has died
		if(isdefined(self.empire_linkedto) && !(isAlive(self.empire_linkedto) && self.empire_linkedto.sessionstate=="playing"))
		{
			self notify("empire_waitforstickydamage");
			if(isdefined(self.empire_linked)) self unlink();
				wait .05;
			self delete();
			return;
		}
		// Check for damage
		if(isdefined(self.damaged)) break;
		wait 0.05;
	}

	self notify("empire_waitforstickydamage");

	// Check that damage owner till exists
	if(isDefined(owner) && isPlayer(owner))
	{
		// I player has switched team and it's teamplay the tripwire is unowned.
		if(isdefined(oldteam) && oldteam == owner.sessionteam)
			eAttacker = owner;
		else if(!isdefined(oldteam))		//Not teamplay
			eAttacker = owner;
		else						//Player has switched team
			eAttacker = self;
	}
	else
		eAttacker = self;

	self setModel("xmodel/weapon_nebelhandgrenate");
	self hide();
	wait .05;
	// play the hit sound
	self playsound("grenade_explode_default");
	// Blow number one
	playfx(level.empire_effect["bombexplosion"], self.origin);
	self scriptedRadiusDamage(eAttacker, (0,0,0), sWeapon, range, oDmg, iDmg, false);
	if(isdefined(self.empire_linked)) self unlink();
	wait .05;
	self delete();
}

checkSatchelPlacement()
{
	self notify("empire_checksatchelplacement");
	self endon("empire_checksatchelplacement");
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");

	//stay here until player lets go of melee button
	//keeps mg from accidently being placed as soon as it is picked up
	while( isAlive( self ) && self.sessionstate=="playing" && self meleeButtonPressed() )
		wait( 0.1 );

	showSatchelMessage(level.empire_satchelplacemessage);

	while( isAlive( self ) && self.sessionstate=="playing" && !isdefined(self.empire_turretmessage) )
	{
		sWeapon = self getCurrentWeapon();
		if(sWeapon != "satchelcharge_mp") break;

		iAmmo	= self getWeaponSlotClipAmmo("satchel");
		if(iAmmo<1) break;

		stance = self aweGetStance(true);
		if(stance!=2) break;

		// Get position
		position = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles),15);

		// Check that there is room.
		trace=bulletTrace(self.origin+(0,0,10),position+(0,0,10),false,undefined);
		if(trace["fraction"]!=1) break;
	
		// Find ground
		trace=bulletTrace(position+(0,0,10),position+(0,0,-10),false,undefined);
		if(trace["fraction"]==1) break;
		vPos=trace["position"];

		if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() )
		{
			// Check satchel limit
			if(isdefined(level.empire_teamplay))
			{
				if(level.empire_satchels[self.sessionteam]>=level.empire_satchellimit)
				{
					self iprintlnbold("Sorry, the maximum number of remote detonables for your team has been reached.");
					// Remove hud elements
					if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
					if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
					if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
					if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
					return false;
				}
			}
			else
			{
				if(level.empire_satchels>=level.empire_satchellimit*2)
				{
					self iprintlnbold("Sorry, the maximum number of remote detonables has been reached.");
					// Remove hud elements
					if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
					if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
					if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
					if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
					return false;
				}
			}

			// Ok to plant, show progress bar
			origin = self.origin;
			angles = self.angles;

			if(level.empire_satchelplanttime)
				planttime = level.empire_satchelplanttime;
			else
				planttime = undefined;

			if(isdefined(planttime))
			{
				self disableWeapon();
				if(!isdefined(self.empire_plantbar))
				{
					barsize = 288;
					// Time for progressbar	
					bartime = (float)planttime;

					if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
					if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

					// Background
					self.empire_plantbarbackground = newClientHudElem(self);				
					self.empire_plantbarbackground.alignX = "center";
					self.empire_plantbarbackground.alignY = "middle";
					self.empire_plantbarbackground.x = 320;
					self.empire_plantbarbackground.y = 405;
					self.empire_plantbarbackground.alpha = 0.5;
					self.empire_plantbarbackground.color = (0,0,0);
					self.empire_plantbarbackground setShader("white", (barsize + 4), 12);			
					// Progress bar
					self.empire_plantbar = newClientHudElem(self);				
					self.empire_plantbar.alignX = "left";
					self.empire_plantbar.alignY = "middle";
					self.empire_plantbar.x = (320 - (barsize / 2.0));
					self.empire_plantbar.y = 405;
					self.empire_plantbar setShader("white", 0, 8);
					self.empire_plantbar scaleOverTime(bartime , barsize, 8);

					showSatchelMessage(level.empire_turretplacingmessage);

					// Play plant sound
					self playsound("moody_plant");
				}

				color = 1;
				for(i=0;i<planttime*20;i++)
				{
					if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
						break;
					self.empire_plantbar.color = (1,color,color);
					color -= 0.05 / planttime;
					wait 0.05;
				}

				// Remove hud elements
				if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
				if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
				if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
				if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
		
				self enableWeapon();
				if(i<planttime*20)
					return false;
			}

			// Check tripwire limit
			if(isdefined(level.empire_teamplay))
			{
				if(level.empire_satchels[self.sessionteam]>=level.empire_satchellimit)
				{
					self iprintlnbold("Sorry, the maximum number of remote detonables for your team has been reached.");
					return false;
				}
			}
			else
			{
				if(level.empire_satchels>=level.empire_satchellimit*2)
				{
					self iprintlnbold("Sorry, the maximum number of tripwires has been reached.");
					return false;
				}
			}

			if(isdefined(level.empire_teamplay))
				level.empire_satchels[self.sessionteam]++;
			else
				level.empire_satchels++;

			// Decrease grenade ammo
			iAmmo--;
			if(iAmmo)
				self setWeaponSlotClipAmmo("satchel", iAmmo);
			else
			{
				self setWeaponSlotClipAmmo("satchel", iAmmo);
				self setWeaponSlotWeapon("satchel", "none");
				newWeapon = self getWeaponSlotWeapon("primary");
				if(newWeapon=="none") newWeapon = self getWeaponSlotWeapon("primaryb");
				if(newWeapon=="none") newWeapon = self getWeaponSlotWeapon("pistol");
				if(newWeapon!="none") self switchToWeapon(newWeapon);
			}
	
			// Spawn tripwire
			satchel = spawn("script_model",vPos + (0,0,2.2) );
			satchel.angles = angles + (0,0,-89);
			satchel setModel("xmodel/w_us_grn_satchel_game");

			if(isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "script_vehicle")
			{
				satchel linkto(trace["entity"]);
				satchel.empire_linked = true;
			}

			satchel thread monitorSatchel(self);
			break;
		}
		wait( 0.2 );
	}
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
}

waitForSatchelDamage(maxDamage)
{
	level endon("empire_boot");
	self endon("empire_waitforsatcheldamage");

	self maps\mp\gametypes\_empire_uncommon::aweSetTakeDamage(true);
	self.damaged = undefined;

	for(;;)
	{
		self waittill ("damage", dmg, who, dir, point, mod);

		if(level.empire_debug && isdefined(mod))
			iprintlnbold("MOD: " + mod);

		if(isdefined(who) && isdefined(who.empire_checkdefusesatchel))
			continue;

		if(dmg>=maxDamage || isdefined(self.damaged)  )
			break;
	}
	self.damaged = true;
}

waitForSatchelDetonation(satchel)
{
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");
	satchel endon("empire_waitforsatcheldamage");

	while(isdefined(satchel) && !isdefined(satchel.damaged) && isdefined(self) && isAlive(self) && isPlayer(self))
	{
		if(!self meleeButtonPressed()) break;
		wait 0.05;
	}

	self iprintlnbold("^7Press MELEE and USE to detonate satchel.");
	
	while(isdefined(satchel) && !isdefined(satchel.damaged) && isdefined(self) && isAlive(self) && isPlayer(self))
	{
		if(self meleeButtonPressed() && self useButtonPressed() && !isdefined(self.empire_checkdefusesatchel)) break;
		wait 0.05;
	}
	
	if(isdefined(satchel))
	{
		satchel.damaged = true;
		satchel notify("empire_waitforsatcheldamage");
	}
}

monitorSatchel(owner)
{
	level endon("empire_boot");
	self endon("empire_monitorsatchel");

	wait .05;

	// Save old team if teamplay
	if(isdefined(level.empire_teamplay))
		self.oldteam = owner.sessionteam;

	self thread waitForSatchelDamage(150);

	owner thread waitForSatchelDetonation(self);

	range = 20;

	while(isDefined(owner) && isAlive(owner) && owner.sessionstate=="playing")
	{
		blow = undefined;

		// Blow if anyone of the nades has taken enough damage
		if(isdefined(self.damaged))
			blow = true;

		// Loop through players to find out if one has triggered the wire
		for(i=0;i<level.empire_allplayers.size && !isdefined(blow);i++)
		{
			// Check that player still exist
			if(isDefined(level.empire_allplayers[i]))
				player = level.empire_allplayers[i];
			else
				continue;

			// Player? Alive? Playing?
			if(!isPlayer(player) || !isAlive(player) || player.sessionstate != "playing")
				continue;
			
			// Within range?
			distance = distance(self.origin, player.origin);
			if(distance>=range)
				continue;

			// Check for defusal
			if(!isdefined(player.empire_checkdefusetripwire) && !player meleeButtonPressed())
				player thread checkDefuseSatchel(self);

			break;
		}
		// Time to blow?
		if(isdefined(blow)) break;
		wait .05;
	}

	if(isdefined(level.empire_teamplay))
		level.empire_satchels[self.oldteam]--;
	else
		level.empire_satchels--;

	self notify("empire_waitforsatcheldamage");

	if(isDefined(owner) && isAlive(owner) && owner.sessionstate=="playing")
	{
		self playsound("weap_fraggrenade_pin");
		wait(.05);

		wait(randomFloat(.5));

		// I player has switched team and it's teamplay the tripwire is unowned.
		if(isdefined(self.oldteam) && self.oldteam == owner.sessionteam)
			eAttacker = owner;
		else if(!isdefined(self.oldteam))		//Not teamplay
			eAttacker = owner;
		else						//Player has switched team
			eAttacker = self;

		self setModel("xmodel/weapon_nebelhandgrenate");
		self hide();
		wait .05;
		// play the hit sound
		self playsound("grenade_explode_default");
		// Blow number one
		playfx(level.empire_effect["bombexplosion"], self.origin);
		self scriptedRadiusDamage(eAttacker, (0,0,0), "satchelcharge_mp", 450, 500, 20, false);
	}

	if(isdefined(self.empire_linked)) self unlink();
	wait .05;
	self delete();
}

checkDefuseSatchel(satchel)
{
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");

	// Make sure to only run one instance
	if(isdefined(self.empire_checkdefusesatchel))
		return;

	range = 20;

	if(self aweGetStance(true) != "2") return;
	distance = distance(satchel.origin, self.origin);
	if(distance>=range) return;

	// Ok to defuse, kill checkTripwirePlacement and set up new hud message
	self notify("empire_checktripwireplacement");
	self notify("empire_checksatchelplacement");

	self.empire_checkdefusesatchel = true;

	// Remove hud elements
	if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
	if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	// Set up new
	showSatchelMessage(level.empire_satchelpickupmessage);

	// Loop
	for(;;)
	{
		if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() )
		{
			// Ok to plant, show progress bar
			origin = self.origin;
			angles = self.angles;

			if(level.empire_satchelpicktime)
				planttime = level.empire_satchelpicktime;
			else
				planttime = undefined;

			if(isdefined(planttime))
			{
				self disableWeapon();
				if(!isdefined(self.empire_plantbar))
				{
					barsize = 288;
					// Time for progressbar	
					bartime = (float)planttime;

					if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
					if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

					// Background
					self.empire_plantbarbackground = newClientHudElem(self);				
					self.empire_plantbarbackground.alignX = "center";
					self.empire_plantbarbackground.alignY = "middle";
					self.empire_plantbarbackground.x = 320;
					self.empire_plantbarbackground.y = 405;
					self.empire_plantbarbackground.alpha = 0.5;
					self.empire_plantbarbackground.color = (0,0,0);
					self.empire_plantbarbackground setShader("white", (barsize + 4), 12);			
					// Progress bar
					self.empire_plantbar = newClientHudElem(self);				
					self.empire_plantbar.alignX = "left";
					self.empire_plantbar.alignY = "middle";
					self.empire_plantbar.x = (320 - (barsize / 2.0));
					self.empire_plantbar.y = 405;
					self.empire_plantbar setShader("white", 0, 8);
					self.empire_plantbar scaleOverTime(bartime , barsize, 8);

					showSatchelMessage(level.empire_turretpickingmessage);

					// Play plant sound
					self playsound("moody_plant");
				}

				color = 1;
				for(i=0;i<planttime*20 && isdefined(satchel);i++)
				{
					if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
						break;

					if(isdefined(self.empire_plantbar))
						self.empire_plantbar.color = (color,1,color);

					color -= 0.05 / planttime;
					wait 0.05;
				}

				// Remove hud elements
				if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
				if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
				if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
				if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
		
				self enableWeapon();
				if(i<planttime*20)
				{
					self.empire_checkdefusesatchel = undefined;
					return;
				}
			}

			if(isdefined(level.empire_teamplay))
				level.empire_satchels[satchel.oldteam]--;
			else
				level.empire_satchels--;

			// Remove satchel
			satchel notify("empire_monitorsatchel");
			wait .05;
			if(isdefined(satchel))
				satchel delete();

			// Drop current satchel
			if(self getWeaponSlotClipAmmo("satchel"))
				self dropItem("satchelcharge_mp");
	
			// Pick up satchel
			self setWeaponSlotWeapon("satchel","satchelcharge_mp");
			self setWeaponSlotClipAmmo("satchel",1);

			self switchToWeapon("satchelcharge_mp");
			break;
		}
		wait .05;

		// Check prone
		if(self aweGetStance(true) != "2") break;
		// Check nades
		if(!isdefined(satchel))
			break;
		distance = distance(satchel.origin, self.origin);
		if(distance>=range) break;
	}

	// Clean up
	if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
	if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	self.empire_checkdefusesatchel = undefined;
}


//Thread to determine if a player can place grenades
checkTripwirePlacement()
{
	self notify("empire_checktripwireplacement");
	self endon("empire_checktripwireplacement");
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");

	//stay here until player lets go of melee button
	//keeps mg from accidently being placed as soon as it is picked up
	while( isAlive( self ) && self.sessionstate=="playing" && self meleeButtonPressed() )
		wait( 0.1 );

	showTripwireMessage(self getWeaponSlotWeapon("grenade"), level.empire_tripwireplacemessage);

	while( isAlive( self ) && self.sessionstate=="playing" && !isdefined(self.empire_turretmessage) )
	{
		sWeapon = self getCurrentWeapon();
		if(!isWeaponType("grenade",sWeapon)) break;

		iAmmo	= self getWeaponSlotClipAmmo("grenade");
		if(iAmmo<2) break;

		stance = self aweGetStance(true);
		if(stance!=2) break;

		// Get position
		position = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles),15);

		// Check that there is room.
		trace=bulletTrace(self.origin+(0,0,10),position+(0,0,10),false,undefined);
		if(trace["fraction"]!=1) break;
	
		// Find ground
		trace=bulletTrace(position+(0,0,10),position+(0,0,-10),false,undefined);
		if(trace["fraction"]==1) break;
		if(isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "script_vehicle") break;
		position=trace["position"];
		tracestart = position + (0,0,10);

		// Find position1
		traceend = tracestart + maps\mp\_utility::vectorScale(anglesToForward(self.angles + (0,90,0)),50);
		trace=bulletTrace(tracestart,traceend,false,undefined);
		if(trace["fraction"]!="1")
		{
			distance = distance(tracestart,trace["position"]);
			if(distance>5) distance = distance - 2;
			position1=tracestart + maps\mp\_utility::vectorScale(vectorNormalize(trace["position"]-tracestart),distance);
		}
		else
			position1 = trace["position"];

		// Find ground
		trace=bulletTrace(position1,position1+(0,0,-20),false,undefined);
		if(trace["fraction"]==1) break;
		vPos1=trace["position"] + (0,0,3);

		// Find position2
		traceend = tracestart + maps\mp\_utility::vectorScale(anglesToForward(self.angles + (0,-90,0)),50);
		trace=bulletTrace(tracestart,traceend,false,undefined);
		if(trace["fraction"]!="1")
		{
			distance = distance(tracestart,trace["position"]);
			if(distance>5) distance = distance - 2;
			position2=tracestart + maps\mp\_utility::vectorScale(vectorNormalize(trace["position"]-tracestart),distance);
		}
		else
			position2 = trace["position"];

		// Find ground
		trace=bulletTrace(position2,position2+(0,0,-20),false,undefined);
		if(trace["fraction"]==1) break;
		vPos2=trace["position"] + (0,0,3);

		if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() )
		{
			// Check tripwire limit
			if(isdefined(level.empire_teamplay))
			{
				if(level.empire_tripwires[self.sessionteam]>=level.empire_tripwirelimit)
				{
					self iprintlnbold("Sorry, the maximum number of tripwires for your team has been reached.");
					// Remove hud elements
					if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
					if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
					if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
					if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
					return false;
				}
			}
			else
			{
				if(level.empire_tripwires>=level.empire_tripwirelimit*2)
				{
					self iprintlnbold("Sorry, the maximum number of tripwires has been reached.");
					// Remove hud elements
					if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
					if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
					if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
					if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
					return false;
				}
			}

			// Ok to plant, show progress bar
			origin = self.origin;
			angles = self.angles;

			if(level.empire_tripwireplanttime)
				planttime = level.empire_tripwireplanttime;
			else
				planttime = undefined;

			if(isdefined(planttime))
			{
				self disableWeapon();
				if(!isdefined(self.empire_plantbar))
				{
					barsize = 288;
					// Time for progressbar	
					bartime = (float)planttime;

					if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
					if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

					// Background
					self.empire_plantbarbackground = newClientHudElem(self);				
					self.empire_plantbarbackground.alignX = "center";
					self.empire_plantbarbackground.alignY = "middle";
					self.empire_plantbarbackground.x = 320;
					self.empire_plantbarbackground.y = 405;
					self.empire_plantbarbackground.alpha = 0.5;
					self.empire_plantbarbackground.color = (0,0,0);
					self.empire_plantbarbackground setShader("white", (barsize + 4), 12);			
					// Progress bar
					self.empire_plantbar = newClientHudElem(self);				
					self.empire_plantbar.alignX = "left";
					self.empire_plantbar.alignY = "middle";
					self.empire_plantbar.x = (320 - (barsize / 2.0));
					self.empire_plantbar.y = 405;
					self.empire_plantbar setShader("white", 0, 8);
					self.empire_plantbar scaleOverTime(bartime , barsize, 8);

					showTripwireMessage(self getWeaponSlotWeapon("grenade"), level.empire_turretplacingmessage);

					// Play plant sound
					self playsound("moody_plant");
				}

				color = 1;
				for(i=0;i<planttime*20;i++)
				{
					if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
						break;
					self.empire_plantbar.color = (1,color,color);
					color -= 0.05 / planttime;
					wait 0.05;
				}

				// Remove hud elements
				if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
				if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
				if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
				if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
		
				self enableWeapon();
				if(i<planttime*20)
					return false;
			}

			// Check tripwire limit
			if(isdefined(level.empire_teamplay))
			{
				if(level.empire_tripwires[self.sessionteam]>=level.empire_tripwirelimit)
				{
					self iprintlnbold("Sorry, the maximum number of tripwires for your team has been reached.");
					return false;
				}
			}
			else
			{
				if(level.empire_tripwires>=level.empire_tripwirelimit*2)
				{
					self iprintlnbold("Sorry, the maximum number of tripwires has been reached.");
					return false;
				}
			}

			if(isdefined(level.empire_teamplay))
				level.empire_tripwires[self.sessionteam]++;
			else
				level.empire_tripwires++;

			// Calc new center
			x = (vPos1[0] + vPos2[0])/2;
			y = (vPos1[1] + vPos2[1])/2;
			z = (vPos1[2] + vPos2[2])/2;
			vPos = (x,y,z);

			// Decrease grenade ammo
			iAmmo--;
			iAmmo--;
			if(iAmmo)
				self setWeaponSlotClipAmmo("grenade", iAmmo);
			else
			{
				self setWeaponSlotClipAmmo("grenade", iAmmo);
				self setWeaponSlotWeapon("grenade", "none");
				newWeapon = self getWeaponSlotWeapon("primary");
				if(newWeapon=="none") newWeapon = self getWeaponSlotWeapon("primaryb");
				if(newWeapon=="none") newWeapon = self getWeaponSlotWeapon("pistol");
				if(newWeapon!="none") self switchToWeapon(newWeapon);
			}
	
			// Spawn tripwire
			tripwire = spawn("script_origin",vPos);
			tripwire.angles = angles;
			tripwire thread monitorTripwire(self, sWeapon, vPos1, vPos2);
			break;
		}
		wait( 0.2 );
	}
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
}

showSatchelMessage(which_message )
{
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	self.empire_tripwiremessage = newClientHudElem( self );
	self.empire_tripwiremessage.alignX = "center";
	self.empire_tripwiremessage.alignY = "middle";
	self.empire_tripwiremessage.x = 320;
	self.empire_tripwiremessage.y = 404;
	self.empire_tripwiremessage.alpha = 1;
	self.empire_tripwiremessage.fontScale = 0.80;
	if( 	(isdefined(level.empire_turretpickingmessage) && which_message == level.empire_turretpickingmessage) ||
		(isdefined(level.empire_turretplacingmessage) && which_message == level.empire_turretplacingmessage) )
		self.empire_tripwiremessage.color = (.5,.5,.5);
	self.empire_tripwiremessage setText( which_message );

	self.empire_tripwiremessage2 = newClientHudElem(self);
	self.empire_tripwiremessage2.alignX = "center";
	self.empire_tripwiremessage2.alignY = "top";
	self.empire_tripwiremessage2.x = 320;
	self.empire_tripwiremessage2.y = 415;
	self.empire_tripwiremessage2 setShader("gfx/icons/hud@satchel.dds",40,40);
}

showTripwireMessage(sWeapon, which_message )
{
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	self.empire_tripwiremessage = newClientHudElem( self );
	self.empire_tripwiremessage.alignX = "center";
	self.empire_tripwiremessage.alignY = "middle";
	self.empire_tripwiremessage.x = 320;
	self.empire_tripwiremessage.y = 404;
	self.empire_tripwiremessage.alpha = 1;
	self.empire_tripwiremessage.fontScale = 0.80;
	if( 	(isdefined(level.empire_turretpickingmessage) && which_message == level.empire_turretpickingmessage) ||
		(isdefined(level.empire_turretplacingmessage) && which_message == level.empire_turretplacingmessage) )
		self.empire_tripwiremessage.color = (.5,.5,.5);
	self.empire_tripwiremessage setText( which_message );

	self.empire_tripwiremessage2 = newClientHudElem(self);
	self.empire_tripwiremessage2.alignX = "center";
	self.empire_tripwiremessage2.alignY = "top";
	self.empire_tripwiremessage2.x = 320;
	self.empire_tripwiremessage2.y = 415;
	self.empire_tripwiremessage2 setShader(getGrenadeHud(sWeapon),40,40);
}

getGrenadeHud(sWeapon)
{
	switch(sWeapon)
	{
		case "fraggrenade_mp":
			model = "gfx/hud/hud@death_us_grenade.tga";
			break;

		case "mk1britishfrag_mp":
			model = "gfx/hud/hud@death_british_grenade.tga";
			break;

		case "rgd-33russianfrag_mp":
			model = "gfx/hud/hud@death_russian_grenade.tga";
			break;	

		default:
			model = "gfx/hud/hud@death_steilhandgrenate.tga";
			break;
	}
	return model;
}

tripwireWarning()
{
	if(isdefined(self.empire_tripwirewarning))
		return;
	self.empire_tripwirewarning = true;
	self iprintlnbold("^1WARNING! ^7Tripwire!");
	wait 5;
	self.empire_tripwirewarning = undefined;
}

waitForTripwireDamage(maxDamage)
{
	if(!isdefined(level.empire_uo))
		return;

	level endon("empire_boot");
	self endon("empire_waitfortripwiredamage");

	self maps\mp\gametypes\_empire_uncommon::aweSetTakeDamage(true);
	self.damaged = undefined;

	for(;;)
	{
		self waittill ("damage", dmg, who, dir, point, mod);

		if(level.empire_debug && isdefined(mod))
			iprintlnbold("MOD: " + mod);

		if(dmg>=maxDamage) break;
	}
	self.damaged = true;
}


monitorTripwire(owner, sWeapon, vPos1, vPos2)
{
	level endon("empire_boot");
	self endon("empire_monitortripwire");

	// Save old team if teamplay
	if(isdefined(level.empire_teamplay))
		self.oldteam = owner.sessionteam;

	wait .05;

	// Spawn nade one
	self.nade1 = spawn("script_model",vPos1);
	self.nade1 setModel(getGrenadeModel(sWeapon));
	self.nade1.angles = self.angles;
	self.nade1 thread waitForTripwireDamage(100);

	// Spawn nade two
	self.nade2 = spawn("script_model",vPos2);
	self.nade2 setModel(getGrenadeModel(sWeapon));
	self.nade2.angles = self.angles;
	self.nade2 thread waitForTripwireDamage(100);

	// Get detection spots
	vPos3 = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles),50);
	vPos4 = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles + (0,180,0)),50);

	// Get detection ranges
	range = distance(self.origin, vPos1) + 150;
	range2 = distance(vPos3,vPos1) + 2;

	if(isDefined(owner) && isAlive(owner) && owner.sessionstate == "playing")
		owner iprintlnbold("Tripwire activates in ^15 ^7seconds!");

	wait 5;

	for(;;)
	{
		blow = undefined;

		// Blow if anyone of the nades has taken enough damage
		if(isdefined(self.nade1.damaged) || isdefined(self.nade2.damaged))
			blow = true;

		// Loop through players to find out if one has triggered the wire
		for(i=0;i<level.empire_allplayers.size && !isdefined(blow);i++)
		{
			// Check that player still exist
			if(isDefined(level.empire_allplayers[i]))
				player = level.empire_allplayers[i];
			else
				continue;

			// Player? Alive? Playing?
			if(!isPlayer(player) || !isAlive(player) || player.sessionstate != "playing")
				continue;
			
			// Within range?
			distance = distance(self.origin, player.origin);
			if(distance>=range)
				continue;

			// Check for defusal
			if(!isdefined(player.empire_checkdefusetripwire))
				player thread checkDefuseTripwire(self, sWeapon);

			// Warm if same team?
			if(isDefined(self.oldteam) && self.oldteam == player.sessionteam && !isDefined(player.empire_tripwirewarning))
			{
				// Stop check if tripwire is safe for teammates.
				if(level.empire_tripwire==3)
					continue;
				else if(level.empire_tripwirewarning)
					player thread tripwireWarning();
			}

			// Within sphere one?
			distance = distance(vPos3, player.origin);
			if(distance>=range2)
				continue;

			// Within sphere two?
			distance = distance(vPos4, player.origin);
			if(distance>=range2)
				continue;

			// Time to blow
			blow = true;
			break;
		}
		// Time to blow?
		if(isdefined(blow)) break;
		wait .05;
	}

	if(isdefined(level.empire_teamplay))
		level.empire_tripwires[self.oldteam]--;
	else
		level.empire_tripwires--;

	self.nade1 notify("empire_waitfortripwiredamage");
	self.nade2 notify("empire_waitfortripwiredamage");

	if(isdefined(self.nade2.damaged))
	{
		self.nade2 playsound("weap_fraggrenade_pin");
		wait(.05);
		self.nade1 playsound("weap_fraggrenade_pin");
		wait(.05);
	}
	else
	{
		self.nade1 playsound("weap_fraggrenade_pin");
		wait(.05);
		self.nade2 playsound("weap_fraggrenade_pin");
		wait(.05);
	}
	wait(randomFloat(.5));

	// Check that damage owner till exists
	if(isDefined(owner) && isPlayer(owner))
	{
		// I player has switched team and it's teamplay the tripwire is unowned.
		if(isdefined(self.oldteam) && self.oldteam == owner.sessionteam)
			eAttacker = owner;
		else if(!isdefined(self.oldteam))		//Not teamplay
			eAttacker = owner;
		else						//Player has switched team
			eAttacker = self;
	}
	else
		eAttacker = self;

	iMaxdamage = 120;
	iMindamage = 5;

	if(isdefined(level.empire_dmgmod[sWeapon]))
	{
		iMaxdamage = iMaxdamage * level.empire_dmgmod[sWeapon];
		iMindamage = iMindamage * level.empire_dmgmod[sWeapon];
	}

	if(isdefined(self.nade2.damaged))
	{
		// play the hit sound
		self.nade2 playsound("grenade_explode_default");
		// Blow number two
		playfx(level.empire_effect["bombexplosion"], self.nade2.origin);
		self.nade2 scriptedRadiusDamage(eAttacker, (0,0,0), sWeapon, 350, iMaxdamage, iMindamage, (level.empire_tripwire>1) );
		wait .05;
		self.nade2 delete();

		// A small, random, delay between the nades
		wait(randomFloat(.25));

		// play the hit sound
		self.nade1 playsound("grenade_explode_default");
		// Blow number one
		playfx(level.empire_effect["bombexplosion"], self.nade1.origin);
		self.nade1 scriptedRadiusDamage(eAttacker, (0,0,0), sWeapon, 350, iMaxdamage, iMindamage, (level.empire_tripwire>1) );
		wait .05;
		self.nade1 delete();
	}
	else
	{
		// play the hit sound
		self.nade1 playsound("grenade_explode_default");
		// Blow number one
		playfx(level.empire_effect["bombexplosion"], self.nade1.origin);
		self.nade1 scriptedRadiusDamage(eAttacker, (0,0,0), sWeapon, 350, iMaxdamage, iMindamage, (level.empire_tripwire>1) );
		wait .05;
		self.nade1 delete();

		// A small, random, delay between the nades
		wait(randomFloat(.25));

		// play the hit sound
		self.nade2 playsound("grenade_explode_default");
		// Blow number two
		playfx(level.empire_effect["bombexplosion"], self.nade2.origin);
		self.nade2 scriptedRadiusDamage(eAttacker, (0,0,0), sWeapon, 350, iMaxdamage, iMindamage, (level.empire_tripwire>1) );
		wait .05;
		self.nade2 delete();
	}
	self delete();
}

checkDefuseTripwire(tripwire, sWeapon)
{
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");

	// Make sure to only run one instance
	if(isdefined(self.empire_checkdefusetripwire))
		return;

	range = 20;

	// Check prone
	if(self aweGetStance(true) != "2") return;
	// Check nades
	distance1 = distance(tripwire.nade1.origin, self.origin);
	distance2 = distance(tripwire.nade2.origin, self.origin);
	if(distance1>=range && distance2>=range) return;

	// Ok to defuse, kill checkTripwirePlacement and set up new hud message
	self notify("empire_checktripwireplacement");
	self notify("empire_checksatchelplacement");

	self.empire_checkdefusetripwire = true;

	// Remove hud elements
	if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
	if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	// Set up new
	showTripwireMessage(sWeapon, level.empire_tripwirepickupmessage);

	// Loop
	for(;;)
	{
		if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() )
		{
			// Ok to plant, show progress bar
			origin = self.origin;
			angles = self.angles;

			if(level.empire_tripwirepicktime)
				planttime = level.empire_tripwirepicktime;
			else
				planttime = undefined;

			if(isdefined(planttime))
			{
				self disableWeapon();
				if(!isdefined(self.empire_plantbar))
				{
					barsize = 288;
					// Time for progressbar	
					bartime = (float)planttime;

					if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
					if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

					// Background
					self.empire_plantbarbackground = newClientHudElem(self);				
					self.empire_plantbarbackground.alignX = "center";
					self.empire_plantbarbackground.alignY = "middle";
					self.empire_plantbarbackground.x = 320;
					self.empire_plantbarbackground.y = 405;
					self.empire_plantbarbackground.alpha = 0.5;
					self.empire_plantbarbackground.color = (0,0,0);
					self.empire_plantbarbackground setShader("white", (barsize + 4), 12);			
					// Progress bar
					self.empire_plantbar = newClientHudElem(self);				
					self.empire_plantbar.alignX = "left";
					self.empire_plantbar.alignY = "middle";
					self.empire_plantbar.x = (320 - (barsize / 2.0));
					self.empire_plantbar.y = 405;
					self.empire_plantbar setShader("white", 0, 8);
					self.empire_plantbar scaleOverTime(bartime , barsize, 8);

					showTripwireMessage(sWeapon, level.empire_turretpickingmessage);

					// Play plant sound
					self playsound("moody_plant");
				}

				color = 1;
				for(i=0;i<planttime*20 && isdefined(tripwire);i++)
				{
					if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
						break;

					if(isdefined(self.empire_plantbar))
						self.empire_plantbar.color = (color,1,color);

					color -= 0.05 / planttime;
					wait 0.05;
				}

				// Remove hud elements
				if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
				if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
				if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
				if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
		
				self enableWeapon();
				if(i<planttime*20 || !isdefined(tripwire))
				{
					self.empire_checkdefusetripwire = undefined;
					return;
				}
			}

			if(isdefined(level.empire_teamplay))
				level.empire_tripwires[tripwire.oldteam]--;
			else
				level.empire_tripwires--;
			// Remove tripwire
			tripwire notify("empire_monitortripwire");
			wait .05;
			if(isdefined(tripwire.nade1))
				tripwire.nade1 delete();
			if(isdefined(tripwire.nade2))
				tripwire.nade2 delete();
			if(isdefined(tripwire))
				tripwire delete();
			// Pick up grenades
			currentGrenade = self getWeaponSlotWeapon("grenade");
			if(currentGrenade == sWeapon)		// Same type, just increase ammo
			{
				iAmmo = self getWeaponSlotClipAmmo("grenade");
				self setWeaponSlotClipAmmo("grenade",iAmmo + 2);
			}
			else
			{
				// Drop current grenade if it exist and there is ammo
				if(isWeaponType("grenade",currentGrenade) && self getWeaponSlotClipAmmo("grenade") )
					self dropItem(currentGrenade);
				// Pick defused grenades
				self setWeaponSlotWeapon("grenade",sWeapon);
				self setWeaponSlotClipAmmo("grenade",2);
			}
			break;
		}
		wait .05;

		// Check prone
		if(self aweGetStance(true) != "2") break;
		// Check nades
		if(!isdefined(tripwire.nade1) || !isdefined(tripwire.nade2))
			break;
		distance1 = distance(tripwire.nade1.origin, self.origin);
		distance2 = distance(tripwire.nade2.origin, self.origin);
		if(distance1>=range && distance2>=range) break;
	}

	// Clean up
	if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
	if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	self.empire_checkdefusetripwire = undefined;
}

getGrenadeModel(sWeapon)
{
	switch(sWeapon)
	{
		case "fraggrenade_mp":
			model = "xmodel/weapon_MK2FragGrenade";
			break;

		case "mk1britishfrag_mp":
			model = "xmodel/weapon_british_handgrenade";
			break;

		case "rgd-33russianfrag_mp":
			model = "xmodel/weapon_russian_handgrenade";
			break;	

		default:
			model = "xmodel/weapon_nebelhandgrenate";
			break;
	}
	return model;
}

scriptedRadiusDamage(eAttacker, vOffset, sWeapon, iRange, iMaxDamage, iMinDamage, ignoreTK)
{
	if(!isdefined(vOffset))
		vOffset = (0,0,0);
	
	if(isdefined(sWeapon) && (isWeaponType("grenade",sWeapon) || sWeapon == "satchelcharge_mp") )
	{
		sMeansOfDeath = "MOD_GRENADE_SPLASH";
		iDFlags = 1;
	}
	else
	{
		sMeansOfDeath = "MOD_EXPLOSIVE";
		iDFlags = 1;
	}

	// Loop through players
	for(i=0;i<level.empire_allplayers.size;i++)
	{
		if(!isdefined(level.empire_allplayers[i]))
			continue;

		// Check that player is in range
		distance = distance((self.origin + vOffset), level.empire_allplayers[i].origin);
		if(distance>=iRange || level.empire_allplayers[i].sessionstate != "playing" || !isAlive(level.empire_allplayers[i]) )
			continue;

		if(level.empire_allplayers[i] != self && !(isdefined(self.empire_linkedto) && self.empire_linkedto == level.empire_allplayers[i]))
		{
			percent = (iRange-distance)/iRange;
			iDamage = iMinDamage + (iMaxDamage - iMinDamage)*percent;

			stance = level.empire_allplayers[i] aweGetStance(false);
			switch(stance)
			{
				case 2:
					offset = (0,0,5);
					break;
				case 1:
					offset = (0,0,35);
					break;
				default:
					offset = (0,0,55);
					break;
			}

			traceorigin = level.empire_allplayers[i].origin + offset;

			trace = bullettrace(self.origin + vOffset, traceorigin, true, self);
			// Damage blocked by entity, remove 40%
			if(isdefined(trace["entity"]) && trace["entity"] != level.empire_allplayers[i])
				iDamage = iDamage * .6;
			// Damage blocked by other stuff(walls etc...), remove 80%
			else if(!isdefined(trace["entity"]))
				iDamage = iDamage * .2;

			// Reduce damage with 80% if in a vehicle
			if(level.empire_allplayers[i] maps\mp\gametypes\_empire_uncommon::aweIsInVehicle())
				iDamage = iDamage * .2;

			vDir = vectorNormalize(traceorigin - (self.origin + vOffset));
		}
		else
		{
			iDamage = iMaxDamage;
			vDir=(0,0,1);
		}
		if(ignoreTK && isPlayer(eAttacker) && isdefined(level.empire_teamplay) && isdefined(eAttacker.sessionteam) && isdefined(level.empire_allplayers[i].sessionteam) && eAttacker.sessionteam == level.empire_allplayers[i].sessionteam)
			level.empire_allplayers[i] thread [[level.callbackPlayerDamage]](self, self, iDamage, iDFlags, sMeansOfDeath, sWeapon, undefined, vDir, "none");
		else
			level.empire_allplayers[i] thread [[level.callbackPlayerDamage]](self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, undefined, vDir, "none");
	}

	// Loop through all entities and cause damage
	entities = getentarray();
	for(i=0;i<entities.size;i++)
	{
		// Is it defined and not a player?
		if( !isdefined(entities[i]) || isPlayer(entities[i]) )
			continue;

		// Check that entity is in range
		distance = distance((self.origin + vOffset), entities[i].origin);
		if(distance>=iRange)
			continue;

		// Calculate damage
		if(entities[i] != self)
		{
			// bullet trace
			traceorigin = entities[i].origin;
			trace = bullettrace(self.origin + vOffset, traceorigin, true, self);

			// Nothing blocked the damage
			if(isdefined(trace["entity"]) && trace["entity"] == entities[i])
			{
				// get new distance and new damage position if we hit the entity directly
				pos = trace["position"];
				distance = distance((self.origin + vOffset), pos);

				// Calculate damage falloff
				percent = (iRange-distance)/iRange;
				iDamage = iMinDamage + (iMaxDamage - iMinDamage)*percent;

				// Increase damage for vehicles
				if(isdefined(entities[i].classname) && entities[i].classname == "script_vehicle")
					iDamage = iDamage * 2.2;

// For reference: radiusDamage( explosion_origin, 300, 80, 10, attacker, inflictor);

				// Cause a small radiusdamage
				if(iDamage > 0)
				{
					// Do radius damage at traced point
					if(isdefined(entities[i].health))
						oldhealth = entities[i].health;
					radiusDamage(pos, 5, iDamage, iDamage, eAttacker, self);
					// Fallback in case something blocked the damage on a vehicle
					if(isdefined(entities[i].health) && isdefined(entities[i].classname) && entities[i].classname == "script_vehicle" && entities[i].health == oldhealth)
						radiusDamage(entities[i].origin, 5, iDamage, iDamage, eAttacker, self);
				}
			}
			else  // Something blocked the damage
			{
				distance = distance((self.origin + vOffset), entities[i].origin);

				// Calculate damage falloff
				percent = (iRange-distance)/iRange;
				iDamage = iMinDamage + (iMaxDamage - iMinDamage)*percent;

				// Increase damage for vehicles
				if(isdefined(entities[i].classname) && entities[i].classname == "script_vehicle")
					iDamage = iDamage * 2.2;

				// Damage blocked by entity, remove 40%
				if(isdefined(trace["entity"]))
					iDamage = iDamage * .6;
				// Damage blocked by other stuff(walls etc...), remove 80%
				else
					iDamage = iDamage * .2;

				// Cause a small radiusdamage
				if(iDamage > 0)
					radiusDamage(entities[i].origin, 5, iDamage, iDamage, eAttacker, self);
			}
		}
	}
}


pickupTurret()
{
	self endon("empire_spawned");
	self endon("empire_died");

	if(isdefined(self.empire_pickingturret)) return;
	self.empire_pickingturret = self.empire_touchingturret;


	// Time for progressbar		
	if(!isdefined(level.empire_turrets[self.empire_pickingturret]["dropped"]))
		picktime = level.empire_turretpicktime;
	else
		picktime = 0;
	

	// Show progress bar
	if(!isdefined(self.empire_pickbar) && picktime)
	{
		barsize = 288;
		pickingtime = 0;
		bartime = (float)picktime;

		if(isdefined(self.empire_turretmessage))	self.empire_turretmessage destroy();
		if(isdefined(self.empire_turretmessage2))	self.empire_turretmessage2 destroy();

		// Background
		self.empire_pickbarbackground = newClientHudElem(self);				
		self.empire_pickbarbackground.alignX = "center";
		self.empire_pickbarbackground.alignY = "middle";
		self.empire_pickbarbackground.x = 320;
		self.empire_pickbarbackground.y = 405;
		self.empire_pickbarbackground.alpha = 0.5;
		self.empire_pickbarbackground.color = (0,0,0);
		self.empire_pickbarbackground setShader("white", (barsize + 4), 12);			

		// Progress bar
		self.empire_pickbar = newClientHudElem(self);				
		self.empire_pickbar.alignX = "left";
		self.empire_pickbar.alignY = "middle";
		self.empire_pickbar.x = (320 - (barsize / 2.0));
		self.empire_pickbar.y = 405;
		self.empire_pickbar setShader("white", 0, 8);
		self.empire_pickbar scaleOverTime(bartime , barsize, 8);
	
		self showTurretMessage(self.empire_pickingturret, level.empire_turretpickingmessage );

		// Play plant sound
		self playsound("moody_plant");

		for(i=0;i<picktime*20;i++)
		{
			if( !(	self meleeButtonPressed() && isAlive(self) && self.sessionstate=="playing" && 
					isdefined(self.empire_touchingturret) && self.empire_touchingturret == self.empire_pickingturret &&
					!isdefined(level.empire_turrets[self.empire_pickingturret]["carried"]) &&
					isdefined(level.empire_turrets[self.empire_pickingturret]["turret"])
				) )
				break;
			wait 0.05;
		}

		// Remove hud elements
		if(isdefined(self.empire_pickbarbackground))	self.empire_pickbarbackground destroy();
		if(isdefined(self.empire_pickbar))		self.empire_pickbar destroy();
		if(isdefined(self.empire_turretmessage))	self.empire_turretmessage destroy();
		if(isdefined(self.empire_turretmessage2))	self.empire_turretmessage2 destroy();

		self enableWeapon();
		if(i<picktime*20)
		{
			self.empire_pickingturret = undefined;
			return false;
		}
	}

	// Make sure turret is not carried(=just picked up) and that it still exist.
	if(!isdefined(level.empire_turrets[self.empire_pickingturret]["carried"]) && isdefined(level.empire_turrets[self.empire_pickingturret]["turret"]))
	{
		level.empire_turrets[self.empire_pickingturret]["carried"] = true;
		if(!isdefined(level.empire_turrets[self.empire_pickingturret]["dropped"]))
		{
			level.empire_turrets[self.empire_pickingturret]["turret"] notify("empire_turret_think");
			self notify("stop_turret_hud");
			self.empire_usingturret = undefined;
		}
		level.empire_turrets[self.empire_pickingturret]["turret"] delete();
		level.empire_turrets[self.empire_pickingturret]["dropped"] = undefined;
		self.empire_carryingturret = self.empire_pickingturret;
		self.empire_pickingturret = undefined;
		if(isdefined(self.empire_turretmessage))	self.empire_turretmessage destroy();
		if(isdefined(self.empire_turretmessage2))	self.empire_turretmessage2 destroy();

//		self notify("stop_turret_hud");
//		self.empire_usingturret = undefined;

		self showTurretIndicator();
		self thread checkTurretPlacement();
	}

	self.empire_pickingturret = undefined;
}

monitorsprinting()
{
	self endon("empire_spawned");
	self endon("empire_died");

	self.empire_sprinttime = level.empire_sprinttime;
	recovertime = 0;

	if(isdefined(level.empire_uo))
		maxwidth = 126;
	else
		maxwidth = 128;

	if(level.empire_sprinthud == 1)
	{
		self.empire_sprinthud_back = newClientHudElem( self );
		self.empire_sprinthud_back setShader("gfx/hud/hud@health_back.dds", maxwidth + 2, 5);
		self.empire_sprinthud_back.alignX = "left";
		self.empire_sprinthud_back.alignY = "top";
		self.empire_sprinthud_back.x = 488+13;
		self.empire_sprinthud_back.y = 454;

		self.empire_sprinthud = newClientHudElem( self );
		self.empire_sprinthud setShader("gfx/hud/hud@health_bar.dds", maxwidth, 3);
		self.empire_sprinthud.color = ( 0, 0, 1);
		self.empire_sprinthud.alignX = "left";
		self.empire_sprinthud.alignY = "top";
		self.empire_sprinthud.x = 488+14;
		self.empire_sprinthud.y = 455;
	}

	if(level.empire_sprinthud == 2)
	{
		self.empire_sprinthud_back = newClientHudElem( self );
		self.empire_sprinthud_back setShader("white", maxwidth + 2, 5);
		self.empire_sprinthud_back.color = (0.85,0.85,0.85);
		self.empire_sprinthud_back.alignX = "left";
		self.empire_sprinthud_back.alignY = "top";
		self.empire_sprinthud_back.alpha = 0.95;
		self.empire_sprinthud_back.x = 488+13;
		self.empire_sprinthud_back.y = 454;

		self.empire_sprinthud = newClientHudElem( self );
		self.empire_sprinthud setShader("white", maxwidth, 3);
		self.empire_sprinthud.color = ( 0, 0, 1);
		self.empire_sprinthud.alignX = "left";
		self.empire_sprinthud.alignY = "top";
		self.empire_sprinthud.alpha = 0.65;
		self.empire_sprinthud.x = 488+14;
		self.empire_sprinthud.y = 455;
	}

	if(level.empire_sprinthudhint)
	{
		self.empire_sprinthud_hint = newClientHudElem( self );
		self.empire_sprinthud_hint setText(&"^7Hold USE [{+activate}] to sprint");
		self.empire_sprinthud_hint.alignX = "right";
		self.empire_sprinthud_hint.alignY = "top";
		self.empire_sprinthud_hint.fontScale = 0.8;
		self.empire_sprinthud_hint.x = 488+10;
		self.empire_sprinthud_hint.y = 450;
		self.empire_sprinthud_hint.alpha = 0;
	}

	while (isAlive(self) && self.sessionstate == "playing")
	{
		sprint = (float)(level.empire_sprinttime-self.empire_sprinttime)/(float)level.empire_sprinttime;
		
		if(level.empire_sprinthud)
		{
			if(!self.empire_sprinttime)
			{
				self.empire_sprinthud.color = ( 1.0, 0.0, 0.0);
			}
			else	
			{
				self.empire_sprinthud.color = ( sprint, 0, 1.0-sprint);
			}
		
			hud_width = (1.0 - sprint) * maxwidth;
			
			if ( hud_width < 1 )
				hud_width = 1;
			
			if(level.empire_sprinthud == 1)
				self.empire_sprinthud setShader("gfx/hud/hud@health_bar.dds", hud_width, 3);
			else
				self.empire_sprinthud setShader("white", hud_width, 3);
		}

		oldorigin = self.origin;
		// Wait
		wait .05;

		// No sprinting if parchuting or under spawnprotection (with disabled weapon)
		if( (isdefined(self.empire_invulnerable) && level.empire_spawnprotectiondisableweapon) || isdefined(self.empire_isparachuting))
			continue;

		if((oldorigin != self.origin || self.empire_pace) && self.empire_sprinttime>0 && self useButtonPressed() && level.empire_sprint>self aweGetStance(false))
		{
			if(!isdefined(self.empire_sprinting))
			{
				self.maxspeed = 1.9 * level.empire_sprintspeed * level.empire_playerspeed;
				self disableWeapon();
				self.empire_sprinting = true;
			}
			self.empire_sprinttime--;
		}
		else
		{
			if(isdefined(self.empire_sprinting))
			{
				self.maxspeed = 1.9 * level.empire_playerspeed;
				self enableWeapon();
				self.empire_sprinting = undefined;
				recovertime = level.empire_sprintrecovertime;
				if(self.empire_sprinttime>0)
					recovertime = (int)(recovertime * sprint + 0.5);
			}
			if(self.empire_sprinttime<(level.empire_sprinttime) && !self useButtonPressed())
			{
				if(recovertime>0)
					recovertime--;
				else
					self.empire_sprinttime++;
			}
		}
	}
	if(isdefined(self.empire_sprinthud)) self.empire_sprinthud destroy();
	if(isdefined(self.empire_sprinthud_back)) self.empire_sprinthud_back destroy();
	if(isdefined(self.empire_sprinthud_hint)) self.empire_sprinthud_hint destroy();
}

monitoruosprinting()
{
	self endon("empire_spawned");
	self endon("empire_died");

	oldfat = self maps\mp\gametypes\_empire_uncommon::aweGetFatigue();

	while (isAlive(self) && self.sessionstate == "playing")
	{
		wait .05;		// Wait
		newfat = self maps\mp\gametypes\_empire_uncommon::aweGetFatigue();
		deltafat = newfat - oldfat;

		if(deltafat<0) // Sprinting
		{
			if(!isdefined(self.empire_sprinting))
			{
				self.maxspeed = 1.9 * level.empire_uosprintspeed * level.empire_playerspeed;
				self.empire_sprinting = true;
			}

			newfat = oldfat + deltafat * level.empire_uosprinttime;

			if(newfat<0) newfat = 0;

			self maps\mp\gametypes\_empire_uncommon::aweSetFatigue(newfat);
		}

		if(deltafat>0) // Recovering
		{
			newfat = oldfat + deltafat * level.empire_uosprintrecovertime;

			if(newfat>1) newfat = 1;

			self maps\mp\gametypes\_empire_uncommon::aweSetFatigue(newfat);
		}

		if(deltafat>=0) // Recovering and/or not sprinting
		{
			if(isdefined(self.empire_sprinting))
			{
				self.maxspeed = 1.9 * level.empire_playerspeed;
				self.empire_sprinting = undefined;
			}
		}

		oldfat = newfat;
	}
}

whatscooking()
{
	self endon("empire_spawned");
	self endon("empire_died");

	// Loop as long as the cooktimer has not reached zero	
	while (isAlive(self) && self.sessionstate == "playing")
	{
		// Wait
		wait .05;

		// Remove laserdot in ADS mode
		if(isdefined(self.empire_laserdot))
		{
			if(self maps\mp\gametypes\_empire_uncommon::aweIsAds() || self maps\mp\gametypes\_empire_uncommon::aweIsInVehicle())
				self.empire_laserdot.alpha = 0;
			else
				self.empire_laserdot.alpha = level.empire_laserdot;
		}

		// No need to check a lot of stuff if player is in a vehicle
		if(self maps\mp\gametypes\_empire_uncommon::aweIsInVehicle())
			continue;

		// get current weapon
		cw = self getCurrentWeapon();
		attackButton = self attackButtonPressed();
		stance = self aweGetStance(true);

		// Is the current weapon a grenade and is it being cooked?
		if(level.empire_grenadewarning && !isdefined(self.empire_cooking) && !isdefined(self.empire_usingturret) && attackButton && isWeaponType("grenade",cw))
			self thread cookgrenade();

		meleeButton = self meleeButtonPressed();

		if( level.empire_tripwire && isWeaponType("grenade",cw) && stance==2 && !isDefined(self.empire_turretmessage) && !isDefined(self.empire_tripwiremessage))
			self thread checkTripwirePlacement();

		if( isdefined(level.empire_uo) && level.empire_satchel && cw == "satchelcharge_mp" && stance==2 && !isDefined(self.empire_turretmessage) && !isDefined(self.empire_tripwiremessage))
			self thread checkSatchelPlacement();

		if( level.empire_stickynades && meleeButton && !isdefined(self.empire_checkstickyplacement) && !isDefined(self.empire_turretmessage) && !isDefined(self.empire_tripwiremessage) && (isWeaponType("grenade",cw) || cw == "satchelcharge_mp") && stance!=2)
			self thread checkStickyPlacement(cw);

		// Can I carry a turret?
		if(!level.empire_turretmobile || isdefined(self.cannotcarryturret))
			continue;

		if(isdefined(self.empire_touchingturret))
		{
			// Check for turrets to pick up
			// Make sure we have not placing a turret and is still holding meleebutton and that we are touching turret
			if(!isdefined(self.empire_carryingturret) && meleeButton && !isdefined(self.empire_placingturret) && !isdefined(self.pickingturret))
			{
				self thread pickupTurret();
				continue;
			}

			// Still using the same turret?
			if(isdefined(self.empire_usingturret) && self.empire_usingturret == self.empire_touchingturret)
			{
				if(!isdefined(self.empire_turretmessage) && !isdefined(self.empire_carryingturret) && !isdefined(self.empire_pickingturret) && !isdefined(self.empire_placingturret))
					self showTurretMessage(self.empire_touchingturret,level.empire_turretpickupmessage);
				continue;
			}

			// Do not recheck if we are still touching the same turret
			// Is it dropped?
			if( isdefined(level.empire_turrets[self.empire_touchingturret]["dropped"]) )
			{
				// Check so it has not been picked up
				if( isdefined(level.empire_turrets[self.empire_touchingturret]["turret"]) && !isdefined(level.empire_turrets[self.empire_touchingturret]["carried"]) )
				{
					if( distance(self.origin,level.empire_turrets[self.empire_touchingturret]["turret"].origin) < 50) // Within range?
					{
						if(!isdefined(self.empire_turretmessage) && !isdefined(self.empire_carryingturret) && !isdefined(self.empire_pickingturret) && !isdefined(self.empire_placingturret))
							self showTurretMessage(self.empire_touchingturret,level.empire_turretpickupmessage);
						continue;
					}
				}
			}
		}

		if(isdefined(self.empire_usingturret))
		{
			self.empire_touchingturret = self.empire_usingturret;
			if(!isdefined(self.empire_turretmessage) && !isdefined(self.empire_carryingturret) && !isdefined(self.empire_pickingturret) && !isdefined(self.empire_placingturret))
			{
				self showTurretMessage(self.empire_touchingturret,level.empire_turretpickupmessage);
				if(level.empire_debug)
				{
					self iprintlnbold("x:" + (int)(level.empire_turrets[self.empire_touchingturret]["turret"].origin[0] + 0.5) + 
								" y:" + (int)(level.empire_turrets[self.empire_touchingturret]["turret"].origin[1] + 0.5) +
								" z:" + (int)(level.empire_turrets[self.empire_touchingturret]["turret"].origin[2] + 0.5) +
//								" a0:" + (int)(level.empire_turrets[self.empire_touchingturret]["turret"].angles[0] + 0.5) +
								" a:" + (int)(level.empire_turrets[self.empire_touchingturret]["turret"].angles[1] + 0.5) +
//								" a2:" + (int)(level.empire_turrets[self.empire_touchingturret]["turret"].angles[2] + 0.5) +
								" w:" + level.empire_turrets[self.empire_touchingturret]["turret"].weaponinfo);
				}
			}
		}
		else
		{	
			// Check if we are touching any dropped turrets
			self.empire_touchingturret = undefined;
			for (i=0;i<level.empire_turrets.size;i++)
			{
				// Is it not a dropped one?
				if(!isdefined(level.empire_turrets[i]["dropped"])) continue;
				// Is it carried by someone?
				if(isdefined(level.empire_turrets[i]["carried"])) continue;
				// Make sure it exist
				if(!isdefined(level.empire_turrets[i]["turret"])) continue;					
				// Within range?
				if( distance(self.origin,level.empire_turrets[i]["turret"].origin) < 50)
				{
					self.empire_touchingturret = i;
					if(!isdefined(self.empire_turretmessage) && !isdefined(self.empire_carryingturret) && !isdefined(self.empire_pickingturret) && !isdefined(self.empire_placingturret))
						self showTurretMessage(i,level.empire_turretpickupmessage);
					break;	// don't check any more turrets.
				}
			}
		}
		if(!isdefined(self.empire_touchingturret) && !isdefined(self.empire_carryingturret) && !isdefined(self.empire_pickingturret))
		{
			if(isdefined(self.empire_turretmessage))	self.empire_turretmessage destroy();
			if(isdefined(self.empire_turretmessage2))	self.empire_turretmessage2 destroy();
		}
	}
	if(isdefined(self.empire_turretmessage))	self.empire_turretmessage destroy();
	if(isdefined(self.empire_turretmessage2))	self.empire_turretmessage2 destroy();
}

//Method to show the turret message passed by parameter
showTurretMessage( turret, which_message )
{
	if(isdefined(self.empire_turretmessage))	self.empire_turretmessage destroy();
	if(isdefined(self.empire_turretmessage2))	self.empire_turretmessage2 destroy();

	self.empire_turretmessage = newClientHudElem( self );
	self.empire_turretmessage.alignX = "center";
	self.empire_turretmessage.alignY = "middle";
	self.empire_turretmessage.x = 320;
	self.empire_turretmessage.y = 404;
	self.empire_turretmessage.alpha = 1;
	self.empire_turretmessage.fontScale = 0.80;
	if( 	(isdefined(level.empire_turretpickingmessage) && which_message == level.empire_turretpickingmessage) ||
		(isdefined(level.empire_turretplacingmessage) && which_message == level.empire_turretplacingmessage) )
		self.empire_turretmessage.color = (.5,.5,.5);
	self.empire_turretmessage setText( which_message );

	self.empire_turretmessage2 = newClientHudElem(self);
	self.empire_turretmessage2.alignX = "center";
	self.empire_turretmessage2.alignY = "top";
	self.empire_turretmessage2.x = 320;
	self.empire_turretmessage2.y = 415;
	if(level.empire_turrets[turret]["type"]=="misc_mg42")
		self.empire_turretmessage2 setShader("gfx/hud/hud@death_mg42.tga",90,30);
	else
		self.empire_turretmessage2 setShader("gfx/hud/hud@death_antitank.tga",90,30);
}

showTurretIndicator()
{
	if (!isdefined(self.empire_turretindicator)) {
		self.empire_turretindicator = newClientHudElem(self);
		self.empire_turretindicator.alignX = "left";
		self.empire_turretindicator.alignY = "top";
		self.empire_turretindicator.x = 570;
		self.empire_turretindicator.y = 350;
		if(level.empire_turrets[self.empire_carryingturret]["type"]=="misc_mg42")
			self.empire_turretindicator setShader("gfx/hud/hud@death_mg42.tga",60,20);
		else
			self.empire_turretindicator setShader("gfx/hud/hud@death_antitank.tga",60,20);
	}
}

removeTurretIndicator()
{
	if (isdefined(self.empire_turretindicator)) self.empire_turretindicator destroy();
}

//Drops a turret at player's feet if player had one. Called when player bites the dust.
dropTurret(position, sMeansOfDeath)
{
	if ( !isdefined(self.empire_carryingturret) ) return;

	if(!isdefined(position))
		position = self.origin;

	t 	= self.empire_carryingturret;
	type	= level.empire_turrets[t]["type"];

	// Harry Potter was here...
	if(level.empire_turretrecover)
	{
		// Check if player died in a minefield
		minefields = getentarray( "minefield", "targetname" );
		if( minefields.size > 0 )
		{
			for( i = 0; i < minefields.size; i++ )
			{
				if( minefields[i] istouching( self ) )
				{
					touching = true;
					break;
				}
			}
		}
		
		// If player died in minefield or was killed by a trigger, replace turret
		if( isdefined(touching) || (isdefined(sMeansOfDeath) && sMeansOfDeath == "MOD_TRIGGER_HURT") )
		{
			// If original position was a placed one, place a real turret
			if(isdefined(level.empire_turrets[t]["original_weaponinfo"]))
			{
				position	= level.empire_turrets[t]["original_position"];
				angles	= level.empire_turrets[t]["original_angles"];
				weaponinfo	= level.empire_turrets[t]["original_weaponinfo"];

				if(type == "misc_ptrs")
					model = "xmodel/weapon_antitankrifle";
				else
					model = "xmodel/mg42_bipod";

//				if(type == "misc_ptrs") type = "misc_turret";

				if(level.empire_turretmobile==2)		//the -10000 z offset is to spawn the MG off the map.   
					level.empire_turrets[t]["turret"] = spawnTurret( type, position + (0,0,-10000), weaponinfo );
				else
					level.empire_turrets[t]["turret"] = spawnTurret( type, position, weaponinfo );
				level.empire_turrets[t]["turret"] setmodel( model );
				level.empire_turrets[t]["turret"].weaponinfo = weaponinfo;
				level.empire_turrets[t]["turret"].angles = angles;
				if(level.empire_turretmobile==2) wait 0.2;
				level.empire_turrets[t]["turret"].origin = position;//do this LAST. It'll move the MG into a usable position
				level.empire_turrets[t]["dropped"] = undefined;
				level.empire_turrets[t]["carried"] = undefined;

				self.empire_carryingturret=undefined;
				removeTurretIndicator();
				return;	// Don't go further
			}
			else		// If it was a dropped one, just get the position and continue
				position = level.empire_turrets[self.empire_carryingturret]["original_position"];
		}
	}

	trace=bulletTrace(position+(0,0,10),position+(0,0,-1200),false,undefined); 
	ground=trace["position"];

	if(level.empire_turrets[self.empire_carryingturret]["type"] == "misc_ptrs")
	{
		angles = (0,randomInt(360),112);
		model = "xmodel/weapon_antitankrifle";
		type = "dropped_ptrs";
	}
	else
	{
		angles = (0,randomInt(360),125);
		model = "xmodel/mg42_bipod";
		type = "dropped_mg42";
	}	

	ground += (0,0,11);

	level.empire_turrets[self.empire_carryingturret]["turret"] = spawn ("script_model", ground);
	level.empire_turrets[self.empire_carryingturret]["turret"] . targetname = type;
 	level.empire_turrets[self.empire_carryingturret]["turret"] setmodel ( model );
	level.empire_turrets[self.empire_carryingturret]["turret"] . angles = angles;
	level.empire_turrets[self.empire_carryingturret]["turret"] . origin = ground;
	level.empire_turrets[self.empire_carryingturret]["dropped"] = true;
	level.empire_turrets[self.empire_carryingturret]["carried"] = undefined;
 
	self.empire_carryingturret=undefined;
	removeTurretIndicator();
}

//Thread to determine if a player can place a carried turret
checkTurretPlacement()
{
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");

	//stay here until player lets go of melee button
	//keeps mg from accidently being placed as soon as it is picked up
	while( isAlive( self ) && self meleeButtonPressed() )
		wait( 0.1 );

	while( isAlive( self ) && isDefined( self.empire_carryingturret )  && self.sessionstate=="playing")
	{
		//previous position and angles, in case player goes spec or changes team
		oldposition = self.origin;
		oldangles = self.angles;

		// Don't check placement if in a vehicle
		if(self maps\mp\gametypes\_empire_uncommon::aweIsInVehicle())
		{
			wait 0.2;
			continue;
		}

		stance = self aweGetStance(true);
		pos = getTurretPlacement(stance);
		//check if player can put down carried mg
		if( isdefined(pos) )
		{
			self showTurretMessage(self.empire_carryingturret, level.empire_turretplacemessage );

			//wait for melee button, death, or player movement
			while( isAlive( self ) && !self meleeButtonPressed() && isdefined(pos) )
			{
				oldposition = self.origin;
				oldangles = self.angles;
				wait( 0.1 );
				stance = self aweGetStance(true);
				pos = getTurretPlacement(stance);
			}

			if(isdefined(self.empire_turretmessage))	self.empire_turretmessage destroy();
			if(isdefined(self.empire_turretmessage2))	self.empire_turretmessage2 destroy();

			if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() && isdefined(pos) )
				if(self placeTurret(pos,stance)) return;	// End thread if placing was a success
		}
		wait( 0.2 );
	}

	//execution gets here if player died or went spectator
	if( isdefined( self.empire_carryingturret ) && self.sessionstate!="playing" )
	{
		dropTurret(oldposition, undefined);
	}
}

//Method to determine the possible position to place a carried MG42
getTurretPlacement(stance)
{
	if(!isdefined(stance))
		stance = self aweGetStance(true);

//// Temp "fix" ////
//	if( stance == 2 ) 
//		return undefined;
////////////////////

	if( stance == 0 )
		startheight = 66;//height from which to bullettrace downwards
	else if( stance == 1 )
		startheight = 42;
	else if( stance == 2 )
		startheight = 18;
	else
		return undefined;//jumping! Don't allow placement. This leads to abuse.

	type = level.empire_turrets[self.empire_carryingturret]["type"];

	// PTRS41 can only be mounted in prone.
	if(type == "misc_ptrs" && stance != 2)
		return undefined;

	//find the height of the ceiling
	trace = bulletTrace( self.origin, self.origin + ( 0, 0, 80 ), false, undefined );
	ceiling = trace[ "position" ];
	maxheight = ceiling[2] - self.origin[2];
	if( startheight > maxheight-1 )
		startheight = maxheight-1;//the -1 makes sure we start below the ceiling

	checkstart = self.origin;
	valid = false;

	if(type == "misc_ptrs")
		frontbarrellength=58;
	else
		frontbarrellength=16;		//estimates of the mg's size. Used to make sure mg doesn't stick through something
	rearbarrellength = 58;//actual gun is around 46, the extra inches make sure players don't stick through walls when using mg rotated
	gunheight = 12;

	gunforward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), frontbarrellength );
	gunbackward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), -1 * rearbarrellength );

	gunleftforward = ( -1 * gunforward[1], gunforward[0], 0 );//front part of gun when rotated 90 degrees left
	gunleftback = ( -1 * gunbackward[1], gunbackward[0], 0 );//back part of gun when rotated 90 degrees right

	pt1 = gunforward + ( 0, 0, gunheight );//front part point straight
	pt2 = gunbackward + ( 0, 0, gunheight );//back part pointed straight
	pt3 = maps\mp\_utility::vectorScale( gunforward + gunleftforward, 0.7 ) + ( 0, 0, gunheight );//front part 45 deg left
	pt4 = maps\mp\_utility::vectorScale( gunforward - gunleftforward, 0.7 ) + ( 0, 0, gunheight );//front part 45 deg right
	pt5 = maps\mp\_utility::vectorScale( gunbackward + gunleftback, 0.7 ) + ( 0, 0, gunheight );//back part pointed 45 right
	pt6 = maps\mp\_utility::vectorScale( gunbackward - gunleftback, 0.7 ) + ( 0, 0, gunheight );//back part pointed 45 left

	//first trace at 42 inches in front of player
	forward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 42 );
	trace = bulletTrace( checkstart + forward + ( 0, 0, startheight ), checkstart + forward + ( 0, 0, -60 ), false, undefined );
	pos = trace["position"];
	height = pos[2] + gunheight - checkstart[2];
	
	if(isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "script_vehicle")
		valid = false;
	else if( stance==0 && height >= 42 && height < startheight )
		valid = true;
	else if( stance == 1 && height >= 30 && height < startheight )
		valid = true;
	else if( stance == 2 && height < startheight && height > 0 )
		valid = true;

	//check if the gun would have enough space in front of bipod, to prevent placement abuse
	if( valid )
	{
		trace = bulletTrace( pos + pt1, pos + pt2, false, undefined );
		if( trace["fraction"] < 1 )
			valid = false;
		trace = bulletTrace( pos + pt3, pos + pt5, false, undefined );
		if( trace["fraction"] < 1 )
			valid = false;
		trace = bulletTrace( pos + pt6, pos + pt4, false, undefined );
		if( trace["fraction"] < 1 )
			valid = false;
		trace = bulletTrace( pos + pt6, pos + pt5, false, undefined );
		if( trace["fraction"] < 1 )
			valid = false;
	}

	if( !valid )
	{
		forward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 46 );

		//second trace at 46 inches in front of player
		trace = bulletTrace( checkstart + forward + ( 0, 0, startheight ), checkstart + forward + ( 0, 0, -60 ), false, undefined );
		pos=trace["position"];
   
		height = pos[2] + gunheight - checkstart[2];

		if(isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "script_vehicle")
			valid = false;
		else if( stance == 0 && height >= 42 && height < startheight )
			valid = true;
		else if( stance == 1 && height >= 30 && height < startheight )
			valid = true;
		else if( stance == 2 && height< startheight && height > 0 )
			valid = true;

		//check if the gun would have enough space in front of bipod, to prevent placement abuse
		if( valid )
		{
			trace = bulletTrace( pos + pt1, pos + pt2, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt3, pos + pt5, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt6, pos + pt4, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt6, pos + pt5, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
		}
	}
	if( !valid )
	{
		forward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 50 );

		//third trace at 50 inches in front of player
		trace = bulletTrace( checkstart + forward + ( 0, 0, startheight ), checkstart + forward + ( 0, 0, -60 ), false, undefined );
		pos = trace["position"];

		height = pos[2] + gunheight - checkstart[2];

		if(isdefined(trace["entity"]) && isdefined(trace["entity"].classname) && trace["entity"].classname == "script_vehicle")
			valid = false;
		else if( stance == 0 && height >= 42 && height < startheight )
			valid = true;
		else if( stance == 1 && height >= 30 && height < startheight )
			valid = true;
		else if( stance == 2 && height < startheight && height > 0 )
			valid = true;

		//check if the gun would have enough space in front of bipod, to prevent placement abuse
		if( valid )
		{
			trace = bulletTrace( pos + pt1, pos + pt2, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt3, pos + pt5, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt6, pos + pt4, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt6, pos + pt5, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
		}
	}

	// Make sure turret is not placed below player, autocorrect max 2 units
	if(pos[2] < self.origin[2])
	{
		if( (self.origin[2] - pos[2])>2 )
			valid = false;
		else
			pos = (pos[0], pos[1], self.origin[2]);
	}

	if( valid )
		return pos;

	return undefined;
}

//Method to determine a player's current stance
aweGetStance(checkjump)
{
	if( checkjump && !self isOnGround() ) 
		return 3;

	switch(self getStance())
	{
		case "prone":
			return 2;
		case "crouch":
			return 1;
		default:
		case "sprint":
		case "stand":
			return 0;
	}
}

//Method that returns the maximum of a, b, c, and d
getMax( a, b, c, d )
{
	if( a > b )
		ab = a;
	else
		ab = b;
	if( c > d )
		cd = c;
	else
		cd = d;
	if( ab > cd )
		m = ab;
	else
		m = cd;
	return m;
}

placeTurret(pos, stance)
{
	self endon("empire_spawned");
	self endon("empire_died");

	// If not carrying a turret, return and end thread
	if( !isDefined( self.empire_carryingturret ) )
		return true;

	if(!isdefined(stance)) stance = self aweGetStance(true);   
	

	type = level.empire_turrets[self.empire_carryingturret]["type"];

	// PTRS41 can only be mounted in prone.
	if(type == "misc_ptrs" && stance != 2)
		return false;

	if(!isdefined(pos)) pos = getTurretPlacement(stance);

	if( !isDefined( pos ) )
		return false;

	if( stance == 1 || stance == 0 )
	{
		//do a trace upward to see if we're in a porthole
		trace = bulletTrace( pos + ( 0, 0, 2 ), pos + ( 0, 0, 25 ), false, undefined );
		if( trace["fraction"] < 1 )
			pos = pos + ( 0, 0, -11 );
	}
	origin = self.origin;
	angles = self.angles;

	// Ok to plant, show progress bar
	if(level.empire_turretplanttime)
		planttime = level.empire_turretplanttime;
	else
		planttime = undefined;

	if(isdefined(planttime))
	{
		self disableWeapon();
		if(!isdefined(self.empire_plantbar))
		{
			barsize = 288;
			// Time for progressbar	
			bartime = (float)planttime;

			// Background
			self.empire_plantbarbackground = newClientHudElem(self);				
			self.empire_plantbarbackground.alignX = "center";
			self.empire_plantbarbackground.alignY = "middle";
			self.empire_plantbarbackground.x = 320;
			self.empire_plantbarbackground.y = 405;
			self.empire_plantbarbackground.alpha = 0.5;
			self.empire_plantbarbackground.color = (0,0,0);
			self.empire_plantbarbackground setShader("white", (barsize + 4), 12);			
			// Progress bar
			self.empire_plantbar = newClientHudElem(self);				
			self.empire_plantbar.alignX = "left";
			self.empire_plantbar.alignY = "middle";
			self.empire_plantbar.x = (320 - (barsize / 2.0));
			self.empire_plantbar.y = 405;
			self.empire_plantbar setShader("white", 0, 8);
			self.empire_plantbar scaleOverTime(bartime , barsize, 8);

			self showTurretMessage(self.empire_carryingturret, level.empire_turretplacingmessage );

			// Play plant sound
			self playsound("moody_plant");
		}

		for(i=0;i<planttime*20;i++)
		{
			if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
				break;
			wait 0.05;
		}

		// Remove hud elements
		if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
		if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
		if(isdefined(self.empire_turretmessage))	 self.empire_turretmessage destroy();
		if(isdefined(self.empire_turretmessage2))	 self.empire_turretmessage2 destroy();

		self enableWeapon();
		if(i<planttime*20)
			return false;
	}

	self removeTurretIndicator();
	self.empire_placingturret = true;

	if(level.empire_debug)
		iprintln("selfz:" + self.origin[2] + " posz:" + pos[2]);

//	placeTurretAt( pos + ( 0, 0, -1 ), angles, stance );
	placeTurretAt( pos + ( 0, 0, 0.5 ), angles, stance );
	self.empire_carryingturret = undefined;
	if(isdefined(self.empire_turretmessage))	 self.empire_turretmessage destroy();
	if(isdefined(self.empire_turretmessage2))	 self.empire_turretmessage2 destroy();
	while(self meleeButtonPressed())
		wait(0.05);
	self.empire_placingturret = undefined;
	return true;	// return and end thread
}

placeTurretAt( position, angles, stance )
{
//	iprintlnbold("Stance:" + stance);

	type = level.empire_turrets[self.empire_carryingturret]["type"];

	if(type == "misc_ptrs")
		model = "xmodel/weapon_antitankrifle";
	else
		model = "xmodel/mg42_bipod";

	if( stance == 2 && type == "misc_ptrs")
		weaponinfo = "PTRS41_Antitank_Rifle_mp";
	else if( stance == 2 )
		weaponinfo = "mg42_bipod_prone_mp";
	else if( stance == 1 )
		weaponinfo = "mg42_bipod_duck_mp";
	else if( stance == 0 )
		weaponinfo = "mg42_bipod_stand_mp";

//	if(type == "misc_ptrs")	type = "misc_turret";
	if(level.empire_turretmobile == 2)		//the -10000 z offset is to spawn the MG off the map.   
		level.empire_turrets[self.empire_carryingturret]["turret"] = spawnTurret( type, position + ( 0, 0, -10000 ), weaponinfo );
	else
		level.empire_turrets[self.empire_carryingturret]["turret"] = spawnTurret( type, position , weaponinfo );
	level.empire_turrets[self.empire_carryingturret]["turret"] setmodel( model );
	level.empire_turrets[self.empire_carryingturret]["turret"].weaponinfo = weaponinfo;
//	level.empire_turrets[self.empire_carryingturret]["turret"].angles = (359.987,angles[1],-0.329132);
	level.empire_turrets[self.empire_carryingturret]["turret"].angles = (0,angles[1],0);
	if(level.empire_turretmobile == 2)
		wait .2;	// Give turret time to initialize
	level.empire_turrets[self.empire_carryingturret]["turret"].origin = position;//do this LAST. It'll move the MG into a usable position
	level.empire_turrets[self.empire_carryingturret]["dropped"] = undefined;
	level.empire_turrets[self.empire_carryingturret]["carried"] = undefined;
	level.empire_turrets[self.empire_carryingturret]["turret"] thread maps\mp\_empire_turret::turret_think(self.empire_carryingturret);
}

popHead( damageDir, damage)
{
	self.empire_headpopped = true;

	if(isdefined(level.empire_merciless))
		return;

	if(!isdefined(self.empire_helmetpopped))
		self popHelmet( damageDir, damage );

	if(!isdefined(self.empire_headmodel))
		return;

	self detach( self.empire_headmodel , "");
	playfxontag (level.empire_popheadfx,self,"Bip01 Head");

	if(isPlayer(self))
	{
		switch(self aweGetStance(false))
		{
			case 2:
				headoffset = (0,0,15);
				break;
			case 1:
				headoffset = (0,0,44);
				break;
			default:
				headoffset = (0,0,64);
				break;
		}
	}
	else
		headoffset = (0,0,15);
	
	rotation = (randomFloat(540), randomFloat(540), randomFloat(540));
	offset = (0,-1.5,-18);
	radius = 6;
	velocity = maps\mp\_utility::vectorScale(damageDir, (damage/20 + randomFloat(5)) ) + (0,0,(damage/20 + randomFloat(5)) );

	head = spawn("script_model", self.origin + headoffset );
	head setmodel( self.empire_headmodel );
	head.angles = self.angles;
	head thread bounceObject(rotation, velocity, offset, (-90,0,-90), radius, 0.75, "bodyfall_flesh_large", level.empire_popheadfx, "head");
}

popHelmet( damageDir, damage)
{
	self.empire_helmetpopped = true;

	if(!isdefined(self.hatModel))
		return;

	self detach( self.hatModel , "");

	if(isPlayer(self))
	{
		switch(self aweGetStance(false))
		{
			case 2:
				helmetoffset = (0,0,15);
				break;
			case 1:
				helmetoffset = (0,0,44);
				break;
			default:
				helmetoffset = (0,0,64);
				break;
		}
	}
	else
		helmetoffset = (0,0,15);

	switch(self.hatModel)
	{
		case "xmodel/equipment_british_beret_green":
		case "xmodel/equipment_british_beret_red":
		case "xmodel/equipment_german_kriegsmarine_hat":
		case "xmodel/sovietequipment_sidecap":
			bounce = 0.2;
			impactsound = undefined;
			break;
		default:
			bounce = 0.7;
			impactsound = "grenade_bounce_default";
			break;
	}		

	rotation = (randomFloat(540), randomFloat(540), randomFloat(540));
	offset = (0,0,-6);
	radius = 6;
	velocity = maps\mp\_utility::vectorScale(damageDir, (damage/20 + randomFloat(5)) ) + (0,0,(damage/20 + randomFloat(5)) );

	helmet = spawn("script_model", self.origin + helmetoffset );
	helmet setmodel( self.hatModel );
	helmet.angles = self.angles;
	helmet thread bounceObject(rotation, velocity, offset, (-90,0,-90), radius, bounce, impactsound, undefined, "helmet");
}

//
// bounceObject
//
// rotation		(pitch, yaw, roll) degrees/seconds
// velocity		start velocity
// offset		offset between the origin of the object and the desired rotation origin.
// angles		angles offset between anchor and object
// radius		radius between rotation origin and object surfce
// falloff		velocity falloff for each bounce 0 = no bounce, 1 = bounce forever
// bouncesound	soundalias played at bounching
// bouncefx		effect to play on bounce
//
bounceObject(vRotation, vVelocity, vOffset, angles, radius, falloff, bouncesound, bouncefx, objecttype)
{
	level endon("empire_boot");
	self endon("empire_bounceobject");

	self thread putinQ(objecttype);

	// Hide until everthing is setup
	self hide();

	// Setup default values
	if(!isdefined(vRotation))	vRotation = (0,0,0);
	pitch = (float)vRotation[0]*(float)0.05;	// Pitch/frame
	yaw	= (float)vRotation[1]*(float)0.05;	// Yaw/frame
	roll	= (float)vRotation[2]*(float)0.05;	// Roll/frame

	if(!isdefined(vVelocity))	vVelocity = (0,0,0);
	if(!isdefined(vOffset))		vOffset = (0,0,0);
	if(!isdefined(falloff))		falloff = 0.5;
	if(!isdefined(ttl))		ttl = 30;

	// Spawn anchor (the object that we will rotate)
	self.anchor = spawn("script_model", self.origin );
	self.anchor.angles = self.angles;

	// Link to anchor
	self linkto( self.anchor, "", vOffset, angles );
	self show();
	self maps\mp\gametypes\_empire_uncommon::aweSetTakeDamage(true);

	wait .05;	// Let it happen

	if(isdefined(level.empire_gravity))
		gravity = level.empire_gravity;
	else
		gravity = 100;

	// Set gravity
	vGravity = (0,0,-0.02 * gravity);

	stopme = 0;
	// Drop with gravity
	for(;;)
	{
		// Let gravity do, what gravity do best
		vVelocity +=vGravity;

		// Get destination origin
		neworigin = self.anchor.origin + vVelocity;

		// Check for impact, check for entities but not myself.
		trace=bulletTrace(self.anchor.origin,neworigin,true,self); 
		if(trace["fraction"] != 1)	// Hit something
		{
			// Place object at impact point - radius
			distance = distance(self.anchor.origin,trace["position"]);
			if(distance)
			{
				fraction = (distance - radius) / distance;
				delta = trace["position"] - self.anchor.origin;
				delta2 = maps\mp\_utility::vectorScale(delta,fraction);
				neworigin = self.anchor.origin + delta2;
			}
			else
				neworigin = self.anchor.origin;


			// Play sound if defined
			if(isdefined(bouncesound)) self.anchor playSound(bouncesound);

			// Test if we are hitting ground and if it's time to stop bouncing
			if(vVelocity[2] <= 0 && vVelocity[2] > -10) stopme++;
			if(stopme==5)
			{
				stopme=0;
				// Set origin to impactpoint	
				self.anchor.origin = neworigin;
				// Wait for damage
				self waittill ("damage", dmg, who, dir, point, mod);
				vVelocity = maps\mp\_utility::vectorScale(dir, (dmg/15 + randomFloat(5)) ) + (0,0,(dmg/15 + randomFloat(5)) );
				continue;
			}
			// Play effect if defined and it's a hard hit
			if(isdefined(bouncefx) && length(vVelocity) > 20) playfx(bouncefx,trace["position"]);

			// Decrease speed for each bounce.
			vSpeed = length(vVelocity) * falloff;

			// Calculate new direction (Thanks to Hellspawn this is finally done correctly)
			vNormal = trace["normal"];
			vDir = maps\mp\_utility::vectorScale(vectorNormalize( vVelocity ),-1);
			vNewDir = ( maps\mp\_utility::vectorScale(maps\mp\_utility::vectorScale(vNormal,2),vectorDot( vDir, vNormal )) ) - vDir;

			// Scale vector
			vVelocity = maps\mp\_utility::vectorScale(vNewDir, vSpeed);
	
			// Add a small random distortion
			vVelocity += (randomFloat(1)-0.5,randomFloat(1)-0.5,randomFloat(1)-0.5);
		}

		self.anchor.origin = neworigin;

		// Rotate pitch
		a0 = self.anchor.angles[0] + pitch;
		while(a0<0) a0 += 360;
		while(a0>359) a0 -=360;

		// Rotate yaw
		a1 = self.anchor.angles[1] + yaw;
		while(a1<0) a1 += 360;
		while(a1>359) a1 -=360;

		// Rotate roll
		a2 = self.anchor.angles[2] + roll;
		while(a2<0) a2 += 360;
		while(a2>359) a2 -=360;
		self.anchor.angles = (a0,a1,a2);
		
		// Wait one frame
		wait .05;
	}
}

putinQ(type)
{
	index = level.empire_objectQcurrent[type];

	level.empire_objectQcurrent[type]++;
	if(level.empire_objectQcurrent[type] >= level.empire_objectQsize[type])
		level.empire_objectQcurrent[type] = 0;

	if(isDefined(level.empire_objectQ[type][index]))
	{
		level.empire_objectQ[type][index] notify("empire_bounceobject");
		wait .05; //Let thread die
		if(isDefined(level.empire_objectQ[type][index].anchor))
		{
			level.empire_objectQ[type][index] unlink();
			level.empire_objectQ[type][index].anchor delete();
		}
		level.empire_objectQ[type][index] delete();
	}
	
	level.empire_objectQ[type][index] = self;
}
/*
letItRain()
{
	level endon("empire_boot");

	if(isdefined(level.empire_raining)) return;
	level.empire_raining = true;
		
	while(getcvar("let_it_all_pour_down")=="1")
	{
//		allplayers = getentarray("player", "classname");
		for(i = 0; i < level.empire_allplayers.size; i++)
		{
			if(!isdefined(level.empire_allplayers[i]))
				continue;
			else
				player = level.empire_allplayers[i];
			if( isDefined(player) && isAlive(player) && player.sessionstate == "playing" )
			{
				offset = (-500 + randomInt(1000),-500 + randomInt(1000),700 + randomInt(100) );

				if(isdefined(level.empire_merciless))
				{
					if(isdefined(player.headshotModel))
						player.empire_headmodel = player.headshotModel;
					else if(isdefined(player.head_damage3))
						player.empire_headmodel = player.head_damage3;
					else if(isdefined(player.head_damage2))
						player.empire_headmodel = player.head_damage2;
					else if(isdefined(player.head_damage1))
						player.empire_headmodel = player.head_damage1;
					else if(isdefined(player.headmodel))
						player.empire_headmodel = player.headmodel;
				}

				if(level.empire_pophead && isdefined(player.empire_headmodel))
				{
					model = spawn("script_model", player.origin + offset );
					model.angles = ( 0, player.angles[1], 0 );
					rotation = ( randomFloat(540), randomFloat(540), randomFloat(540));
					model setmodel( player.empire_headmodel);
					offset = (0,-2.5,-18);
					radius = 6;
					model thread bounceObject( rotation, (0,0,0), offset, (-90,0,0), radius, 0.7, "bodyfall_flesh_large", level.empire_popheadfx, "head" );
				}
				else if(isdefined(player.hatmodel))
				{
					model = spawn("script_model", player.origin + offset );
					model.angles = ( 0, player.angles[1], 0 );
					rotation = ( randomFloat(540), randomFloat(540), randomFloat(540));
					model setmodel( player.hatmodel);
					offset = (0,0,-6);
					radius = 6;
					model thread bounceObject( rotation, (0,0,0), offset, (-90,0,0), radius, 0.7, "grenade_bounce_default", undefined, "helmet" );
				}
				else
				{
					wait .05;
					continue;
				}
			}
			wait .2;
		}
		wait .05;
	}
	level.empire_raining = undefined;
}
*/

getHitLocTag(hitloc)
{
	switch(hitloc)
		{
		case "right_hand":
			return "Bip01 R Hand";
			break;

		case "left_hand":
			return "Bip01 L Hand";
			break;
	
		case "right_arm_upper":	
			return "Bip01 R UpperArm";
			break;

		case "right_arm_lower":	
			return "Bip01 R Forearm";
			break;

		case "left_arm_upper":
			return "Bip01 L UpperArm";
			break;

		case "left_arm_lower":
			return "Bip01 L Forearm";
			break;

		case "head":
			return "Bip01 Head";
			break;

		case "neck":
			return "Bip01 Neck";
			break;
	
		
		case "right_foot":
			return "Bip01 R Foot";
			break;

		case "left_foot":
			return "Bip01 L Foot";
			break;

		case "right_leg_lower":
			return "TAG_SHIN_RIGHT";
			break;

		case "left_leg_lower":
			return "TAG_SHIN_left";
			break;

		case "right_leg_upper":
			return "Bip01 R Thigh";
			break;
					
		case "left_leg_upper":
			return "Bip01 L Thigh";
			break;
		case "torso_upper":
			return "TAG_BREASTPOCKET_LEFT";
			break;	
		
		case "torso_lower":
			return "TAG_BELT_FRONT";
			break;

		default:
			return "Bip01 Pelvis";
			break;	
	}
}

getHitLocName(hitloc)
{
	switch(hitloc)
		{
		case "right_hand":	return "Right  Hand";
		case "left_hand":		return "Left Hand";
		case "right_arm_upper":	return "Right Upper Arm";
		case "right_arm_lower":	return "Right Forearm";
		case "left_arm_upper":	return "Left Upper Arm";
		case "left_arm_lower":	return "Left Forearm";
		case "head":		return "Head";
		case "neck":		return "Neck";
		case "right_foot":	return "Right Foot";
		case "left_foot":		return "Left Foot";
		case "right_leg_lower":	return "Right Lower Leg";
		case "left_leg_lower":	return "Left Lower Leg";
		case "right_leg_upper":	return "Right Upper Leg";
		case "left_leg_upper":	return "Left Upper Leg";
		case "torso_upper":	return "Upper Torso";
		case "torso_lower":	return "Lower Torso";
		default:			return hitloc;
	}
}

checkUOmaps()
{
	switch(getcvar("mapname"))
	{
		case "mp_arnhem":
		case "mp_berlin":
		case "mp_cassino":
		case "mp_foy":
		case "mp_italy":
		case "mp_kharkov":
		case "mp_kursk":
		case "mp_ponyri":
		case "mp_rhinevalley":
		case "mp_varaville":
		case "mp_redoktober":
		case "GunAssault_v1.1":
		case "mp_peaks":
		case "mp_uo_hurtgen":
			return true;
	
		default:
			return false;
	}
}

isWeaponType(type,weapon)
{
	switch(type)
	{
		case "turret":
			switch(weapon)
			{
				case "mg42_bipod_duck_mp":
				case "mg42_bipod_prone_mp":
				case "mg42_bipod_stand_mp":
				case "mg42_tank_mp":
				case "mg42_turret_mp":
				case "30cal_tank_mp":
				case "50cal_tank_mp":
				case "mg34_tank_mp":
				case "mg50cal_tripod_stand_mp":
				case "mg_sg43_stand_mp":
				case "sg43_tank_mp":
				case "sg43_turret_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		case "rocket":
			switch(weapon)
			{
				case "panzerfaust_mp":
				case "panzerschreck_mp":
				case "bazooka_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;
			
		case "common":
			switch(weapon)
			{
				case "fg42_mp":
				case "panzerfaust_mp":
				case "panzerschreck_mp":
				case "flamethrower_mp":
				case "bazooka_mp":
				case "smokegrenade_mp":
				case "flashgrenade_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is a grenade
		case "grenade":
			switch(weapon)
			{
				case "fraggrenade_mp":
				case "mk1britishfrag_mp":
				case "rgd-33russianfrag_mp":
				case "stielhandgranate_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is smoke/flash grenade
		case "smokegrenade":
			switch(weapon)
			{
				case "smokegrenade_mp":
				case "flashgrenade_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is a rifle
		case "rifle":
			switch(weapon)
			{
				case "m1carbine_mp":
				case "m1garand_mp":
				case "mosin_nagant_mp":
				case "svt40_mp":
				case "kar98k_mp":
				case "gewehr43_mp":
				case "enfield_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is a bolt action rifle
		case "boltrifle":
			switch(weapon)
			{
				case "m1carbine_mp":
				case "mosin_nagant_mp":
				case "kar98k_mp":
				case "enfield_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is a semi automatic rifle
		case "semirifle":
			switch(weapon)
			{
				case "m1garand_mp":
				case "svt40_mp":
				case "gewehr43_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is smg
		case "smg":
			switch(weapon)
			{
				case "mp40_mp":
				case "sten_mp":
				case "thompson_mp":
				case "ppsh_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is assault
		case "assault":
			switch(weapon)
			{
				case "mp44_mp":
				case "bar_mp":
				case "bren_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is sniper
		case "sniper":
			switch(weapon)
			{
				case "mosin_nagant_sniper_mp":
				case "springfield_mp":
				case "kar98k_sniper_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is lmg
		case "lmg":
			switch(weapon)
			{
				case "dp28_mp":
				case "mg34_mp":
				case "mg30cal_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is flamethrower
		case "ft":
			switch(weapon)
			{
				case "flamethrower_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is rocket launcher
		case "rl":
			switch(weapon)
			{
				case "panzerschreck_mp":
				case "bazooka_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is an FG42
		case "fg42":
			switch(weapon)
			{
				case "fg42_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is pistol
		case "pistol":
			switch(weapon)
			{
				case "colt_mp":
				case "luger_mp":
				case "tt33_mp":
				case "webley_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is american
		case "american":
			switch(weapon)
			{
				case "fraggrenade_mp":
				case "colt_mp":
				case "m1carbine_mp":
				case "m1garand_mp":
				case "thompson_mp":
				case "bar_mp":
				case "springfield_mp":
				case "mosin_nagant_mp":
					return true;
					break;
				case "mg30cal_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is british
		case "british":
			switch(weapon)
			{
				case "mk1britishfrag_mp":
				case "webley_mp":
				case "enfield_mp":
				case "sten_mp":
				case "bren_mp":
				case "springfield_mp":
				case "mg30cal_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is russian
		case "russian":
			switch(weapon)
			{
				case "rgd-33russianfrag_mp":
				case "tt33_mp":
				case "mosin_nagant_mp":
				case "svt40_mp":
				case "ppsh_mp":
				case "mosin_nagant_sniper_mp":
				case "dp28_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		// Check if weapon is german
		case "german":
			switch(weapon)
			{
				case "stielhandgranate_mp":
				case "luger_mp":
				case "kar98k_mp":
				case "gewehr43_mp":
				case "mp40_mp":
				case "mp44_mp":
				case "mg34_mp":
				case "kar98k_sniper_mp":
					return true;
					break;
				default:
					return false;
					break;
			}
			break;

		default:
			return false;
			break;
	}
}

rotateIfEmpty()
{
	level endon("empire_boot");
	while(game["empire_emptytime"]<level.empire_rotateifempty)
	{
		wait 60;

		// Reset counter
		num = 0;

		// Count clients that are playing
		for(i=0;i<level.empire_allplayers.size;i++)
			if(isdefined(level.empire_allplayers[i]) && isPlayer(level.empire_allplayers[i]) && level.empire_allplayers[i].sessionstate=="playing")
				num++; 

		// Need at least 2 playing clients			
		if(num>1)
			game["empire_emptytime"] = 0;
		else
			game["empire_emptytime"]++;
	}
	exitLevel(false);
}

delayedbloodfx()
{
	if(isdefined(level.empire_merciless))
		return;

	x = 2 + randomint(4);
	for(i=0;i<x;i++)
	{
		wait 0.25 + randomfloat(i);
		if(isdefined(self))
			playfxontag (level.empire_popheadfx,self,"Bip01 Head");
	}

	x = 15 + randomint(10);
	if(isdefined(level.empire_bleedingfx))
	{
		for(i=0;i<x && isdefined(self);i++)
		{
			s = 0;
			for(k = 0 ; k < 3 ; k++ )
			{
				p = (randomInt(2) *.1) + (randomInt(5) * .01);
				if(isdefined(self))
					playfxontag(level.empire_bleedingfx, self ,"Bip01 Head" );
				wait p;
				s = s + p;
			}
			wait (.75 - s);
		}
	}
}

handleBody(owner, sMod)
{
	// Clone player
	body = owner cloneplayer();
	body setModel(owner.model);

	// Do an extra bloodfx for headpopped players
	if(isdefined(owner.empire_headpopped))
		body thread delayedbloodfx();

	// Make Merciless aware of the body
	if(isdefined(level.empire_merciless))
		owner.empire_body = body;

	// Burned bodies should burn & smoke
	if(sMod == "MOD_FLAME" && level.empire_burningbodies) 
		body thread burningBody();


	// Only meaningsful to search bodies if there is anything to search for
	if(!level.empire_searchablebodies || (level.empire_dropondeath == 2 && getcvar("scr_drophealth")==1) )
		return;

	// Build inventory
	body.inventory = [];
	if( level.empire_searchablebodieshealth && (!(isdefined(owner.empire_nohealthpack) || getcvar("scr_drophealth") == "1") || (isdefined(level.empire_merciless) && owner.hashealth>0)) )
	{
		body.inventory[body.inventory.size]["item"] = "health";
		body.inventory[body.inventory.size - 1]["slot"] = "none";
		body.inventory[body.inventory.size - 1]["ammo"] = 0;
		body.inventory[body.inventory.size - 1]["clip"] = 0;
	}

	if(owner getWeaponSlotWeapon("primary") != "none")
		body.inventory[body.inventory.size] = owner saveWeaponSlot("primary");
	if(owner getWeaponSlotWeapon("primaryb") != "none")
		body.inventory[body.inventory.size] = owner saveWeaponSlot("primaryb");
	if(owner getWeaponSlotWeapon("pistol") != "none")
		body.inventory[body.inventory.size] = owner saveWeaponSlot("pistol");
	if(owner getWeaponSlotWeapon("grenade") != "none")
		body.inventory[body.inventory.size] = owner saveWeaponSlot("grenade");

	if(isdefined(level.empire_uo))
	{
		if(owner getWeaponSlotWeapon("smokegrenade") != "none")
			body.inventory[body.inventory.size] = owner saveWeaponSlot("smokegrenade");
		if(owner getWeaponSlotWeapon("satchel") != "none")
			body.inventory[body.inventory.size] = owner saveWeaponSlot("satchel");
		if(owner getWeaponSlotWeapon("binocular") != "none")
			body.inventory[body.inventory.size] = owner saveWeaponSlot("binocular");
	}

	range = 30;

	// Body search detection
	while(isdefined(body))
	{
		// Loop through players to check if anyone is close enough to serach
		for(i=0;i<level.empire_allplayers.size;i++)
		{
			// Check that player still exist
			if(isDefined(level.empire_allplayers[i]))
				player = level.empire_allplayers[i];
			else
				continue;

			// Player? Alive? Playing?
			if(!isPlayer(player) || !isAlive(player) || player.sessionstate != "playing")
				continue;
			
			// Within range?
			distance = distance(body.origin, player.origin);
			if(distance>=range)
				continue;

			// Check for body search
			if(!isdefined(player.empire_checkbodysearch))
				player thread checkBodySearch(body);
		}
		wait 0.5;
	}
}

saveWeaponSlot(slot)
{
	temp["item"] = self getWeaponSlotWeapon(slot);	
	temp["slot"] = slot;
	temp["ammo"] = self getWeaponSlotAmmo(slot);	
	temp["clip"] = self getWeaponSlotClipAmmo(slot);	

	return temp;
}

restoreWeaponSlot(savedslot)
{
	self setWeaponSlotWeapon(savedslot["slot"],savedslot["item"]);
	self setWeaponSlotAmmo(savedslot["slot"],savedslot["ammo"]);
	self setWeaponSlotClipAmmo(savedslot["slot"],savedslot["clip"]);
}

burningBody()
{
	level endon("empire_boot");

	timeElapsed = (float)0;

	self playloopsound("smallfire");

	while(isdefined(self) && timeElapsed<level.empire_burningbodies)
	{
		playfx(level.empire_burningbodies_burnfx,self.origin + (-10 + randomInt(21),-10 + randomInt(21),-27) );
		delay = 0.1 + randomFloat(0.15);
		timeElapsed += delay;
		wait delay;
	}
	for(i=0;i<2 && isdefined(self);i++)
	{
		playfx(level.empire_burningbodies_smokefx,self.origin);
		wait (0.35 + randomFloat(0.4));
	}
	self stoploopsound();
}

checkBodySearch(body)
{
	level endon("empire_boot");
	self endon("empire_spawned");
	self endon("empire_died");

	// Make sure to only run one instance
	if(isdefined(self.empire_checkbodysearch))
		return;

	// Make sure we are not in defuse position of a tripwire
	if(isdefined(self.empire_checkdefusetripwire))
		return;

	range = 30;

	// Ok to search, kill checkTripwirePlacement and set up new hud message
	self notify("empire_checktripwireplacement");

	// Ok to search, kill checkSatchelPlacement and set up new hud message
	self notify("empire_checksatchelplacement");

	self.empire_checkbodysearch = true;

	// Remove hud elements
	if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
	if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	// Set up new
	showBodysearchMessage(level.empire_bodysearchmessage);

	// Loop
	for(;;)
	{
		if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() )
		{
			// Ok to plant, show progress bar
			origin = self.origin;
			angles = self.angles;

			planttime = level.empire_searchablebodies + randomFloat(1);

			self disableWeapon();
			if(!isdefined(self.empire_plantbar))
			{
				barsize = 288;
				// Time for progressbar	
				bartime = (float)planttime;
				if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
				if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
				// Background
				self.empire_plantbarbackground = newClientHudElem(self);				
				self.empire_plantbarbackground.alignX = "center";
				self.empire_plantbarbackground.alignY = "middle";
				self.empire_plantbarbackground.x = 320;
				self.empire_plantbarbackground.y = 405;
				self.empire_plantbarbackground.alpha = 0.5;
				self.empire_plantbarbackground.color = (0,0,0);
				self.empire_plantbarbackground setShader("white", (barsize + 4), 12);			
				// Progress bar
				self.empire_plantbar = newClientHudElem(self);				
				self.empire_plantbar.alignX = "left";
				self.empire_plantbar.alignY = "middle";
				self.empire_plantbar.x = (320 - (barsize / 2.0));
				self.empire_plantbar.y = 405;
				self.empire_plantbar setShader("white", 0, 8);
				self.empire_plantbar scaleOverTime(bartime , barsize, 8);
				showBodysearchMessage(level.empire_bodysearchingmessage);
				// Play plant sound
				self playsound("moody_plant");
			}
			color = 1;
			for(i=0;i<planttime*20 && isdefined(body);i++)
			{
				if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
					break;

				// Make sure player is in prone or crouch (do after 0.5 second to avoid unwanted crouching while trying to bash someone)
				if(i>10)
				{
					stance = self aweGetStance(true);
					if(!(stance == "2" || stance == "1")) self setClientCvar("cl_stance","1");
				}

				self.empire_plantbar.color = (color,color,1);
				color -= 0.05 / planttime;

				wait 0.05;
			}
			// Remove hud elements
			if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
			if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
			if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
			if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();
	
			if(i<planttime*20 || !isdefined(body))
			{
				self.empire_checkbodysearch = undefined;
				self enableWeapon();
				return;
			}

			// Is there anything left to find?
			if(body.inventory.size && randomInt(20))
			{
				// If injured, always get the health first
				if(self.health < 100 && body.inventory[0]["item"] == "health")
					found = body.inventory[0];
				else	// Get a random item from the inventory
					found = body.inventory[randomInt(body.inventory.size)];

				// Remove the found item from the inventory
				body.inventory = removeFromArray(body.inventory, found);

				// Health or weapon?
				if(found["item"] == "health")
				{
					self iprintlnbold("You found a healthpack.");
					body dropHealth();
				}
				else
				{					// Found a weapon
					self iprintlnbold("You found a " + getWeaponName(found["item"]) + ".");
					// Save old weapon
					temp = self saveWeaponSlot(found["slot"]);
					// Set new
					self restoreWeaponSlot(found);
					// Drop new weapon
					self dropItem(found["item"]);
					// Restore old weapon
					self restoreWeaponSlot(temp);
				}
			}
			else
			{
				nothing = [];
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "nothing";
				nothing[nothing.size] = "some stuff";
				nothing[nothing.size] = "clean underwear";
				nothing[nothing.size] = "pocket air";
				nothing[nothing.size] = "a dirty magazine";
				nothing[nothing.size] = "a deck of cards";
				nothing[nothing.size] = "a hamster";
				nothing[nothing.size] = "a new lifeform";
				nothing[nothing.size] = "Clintons cigar";
				nothing[nothing.size] = "a beer";
				nothing[nothing.size] = "clean socks";
				nothing[nothing.size] = "something you didn't want";
				nothing[nothing.size] = "the meaning of life";
				self iprintlnbold("You found " + nothing[randomInt(nothing.size)] + ".");
			}

			self enableWeapon();

			break;
		}
		wait .05;

		// Check body
		if(!isdefined(body)) break;

		// Check distance
		distance = distance(body.origin, self.origin);
		if(distance>=range) break;
	}

	// Clean up
	if(isdefined(self.empire_plantbarbackground)) self.empire_plantbarbackground destroy();
	if(isdefined(self.empire_plantbar))		 self.empire_plantbar destroy();
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	while(self meleeButtonPressed() && isAlive(self) && self.sessionstate=="playing")
		wait .05;

	self.empire_checkbodysearch = undefined;
}

showBodysearchMessage(which_message )
{
	if(isdefined(self.empire_tripwiremessage))	self.empire_tripwiremessage destroy();
	if(isdefined(self.empire_tripwiremessage2))	self.empire_tripwiremessage2 destroy();

	self.empire_tripwiremessage = newClientHudElem( self );
	self.empire_tripwiremessage.alignX = "center";
	self.empire_tripwiremessage.alignY = "middle";
	self.empire_tripwiremessage.x = 320;
	self.empire_tripwiremessage.y = 404;
	self.empire_tripwiremessage.alpha = 1;
	self.empire_tripwiremessage.fontScale = 0.80;
	if( (isdefined(level.empire_bodysearchingmessage) && which_message == level.empire_bodysearchingmessage) )
		self.empire_tripwiremessage.color = (.5,.5,.5);
	self.empire_tripwiremessage setText( which_message );

	self.empire_tripwiremessage2 = newClientHudElem(self);
	self.empire_tripwiremessage2.alignX = "center";
	self.empire_tripwiremessage2.alignY = "top";
	self.empire_tripwiremessage2.x = 320;
	self.empire_tripwiremessage2.y = 415;
	self.empire_tripwiremessage2 setShader("gfx/hud/death_suicide.dds",40,40);
}

// ----------------------------------------------------------------------------------
//	dropHealth
// ----------------------------------------------------------------------------------
dropHealth(alive)
{
	if(isdefined(self.empire_nohealthpack))
		return;
	self.empire_nohealthpack = true;

	if(isDefined(level.healthqueue[level.healthqueuecurrent]))
		level.healthqueue[level.healthqueuecurrent] delete();

	if(isdefined(alive))
		offset = maps\mp\_utility::vectorScale(anglestoforward(self.angles), 40 ) + (0,0,32);
	else
		offset = (0,0,1);
	
	level.healthqueue[level.healthqueuecurrent] = spawn("item_health", self.origin + offset);
	level.healthqueue[level.healthqueuecurrent].angles = (0, randomint(360), 0);

	level.healthqueuecurrent++;
	
	if(level.healthqueuecurrent >= 16)
		level.healthqueuecurrent = 0;
}

removeFromArray(array, element)
{
	newarray = [];
	for(i=0;i<array.size;i++)
		if(array[i]["item"] != element["item"]) newarray[newarray.size] = array[i];
	return newarray;
}

removeArrayIndex(array, index)
{
	newarray = [];
	for(i = 0; i < array.size; i++)
	{
		if(i == index)
			continue;

		newarray[newarray.size] = array[i];
	}

	return newarray;
}

limitWeapons(team)
{
	if(level.empire_disable) return;

	rifle = 0;
	boltrifle = 0;
	semirifle = 0;
	smg = 0;
	assault = 0;
	sniper = 0;
	lmg = 0;
	ft = 0;
	rl = 0;
	fg42 = 0;

	for(i = 0; i < level.empire_allplayers.size; i++)
	{
		if(isdefined(level.empire_allplayers[i]))
		{
			player = level.empire_allplayers[i];
			if( (isdefined(level.empire_teamplay) && team == player.sessionteam) || (!isdefined(level.empire_teamplay) && team == player.pers["team"]) )
			{
				if(player.sessionstate == "playing")
				{
					primary = player getWeaponSlotWeapon("primary");
					primaryb = player getWeaponSlotWeapon("primaryb");
					// Is player using other weapons than his spawnweapon?
					if(isdefined(player.pers["weapon"]) && primary != player.pers["weapon"] && primaryb != player.pers["weapon"])
						spawn = player.pers["weapon"];
					else
						spawn = "none";
					
				}
				else
				{
					primary = "none";
					primaryb = "none";
					if(isdefined(player.pers["weapon"]))
						spawn = player.pers["weapon"];
					else
						spawn = "none";
				}
				if(!isdefined(primary) || primary == "") primary = "none";
				if(!isdefined(primaryb) || primaryb == "") primaryb = "none";
				if(!isdefined(spawn) || spawn == "") spawn = "none";

				if(isWeaponType("rifle",primary) || isWeaponType("rifle",primaryb) || isWeaponType("rifle",spawn))
					rifle ++;
				if(isWeaponType("boltrifle",primary) || isWeaponType("boltrifle",primaryb) || isWeaponType("boltrifle",spawn))
					boltrifle ++;
				if(isWeaponType("semirifle",primary) || isWeaponType("semirifle",primaryb) || isWeaponType("semirifle",spawn))
					semirifle ++;
				if(isWeaponType("smg",primary) || isWeaponType("smg",primaryb) || isWeaponType("smg",spawn))
					smg ++;
				if(isWeaponType("assault",primary) || isWeaponType("assault",primaryb) || isWeaponType("assault",spawn))
					assault ++;
				if(isWeaponType("sniper",primary) || isWeaponType("sniper",primaryb) || isWeaponType("sniper",spawn))
					sniper ++;
				if(isdefined(level.empire_uo))
				{
					if(isWeaponType("lmg",primary) || isWeaponType("lmg",primaryb) || isWeaponType("lmg",spawn))
						lmg ++;
					if(isWeaponType("ft",primary) || isWeaponType("ft",primaryb) || isWeaponType("ft",spawn))
						ft ++;
					if(isWeaponType("rl",primary) || isWeaponType("rl",primaryb) || isWeaponType("rl",spawn))
						rl ++;
				}
				if(isWeaponType("fg42",primary) || isWeaponType("fg42",primaryb) || isWeaponType("fg42",spawn))
					fg42 ++;
			}
		}
	}

	if(level.empire_riflelimit && !(level.empire_boltriflelimit || level.empire_semiriflelimit))
	{
		if(level.empire_riflelimit>rifle)
			enableDisableWeaponType(team, "rifle", 1);
		else
			enableDisableWeaponType(team, "rifle", 0);
	}

	if(level.empire_boltriflelimit)
	{
		if(level.empire_boltriflelimit>boltrifle)
			enableDisableWeaponType(team, "boltrifle", 1);
		else
			enableDisableWeaponType(team, "boltrifle", 0);
	}

	if(level.empire_semiriflelimit)
	{
		if(level.empire_semiriflelimit>semirifle)
			enableDisableWeaponType(team, "semirifle", 1);
		else
			enableDisableWeaponType(team, "semirifle", 0);
	}

	if(level.empire_smglimit)
	{
		if(level.empire_smglimit>smg)
			enableDisableWeaponType(team, "smg", 1);
		else
			enableDisableWeaponType(team, "smg", 0);
	}

	if(level.empire_assaultlimit)
	{
		if(level.empire_assaultlimit>assault)
			enableDisableWeaponType(team, "assault", 1);
		else
			enableDisableWeaponType(team, "assault", 0);
	}

	if(level.empire_sniperlimit)
	{
		if(level.empire_sniperlimit>sniper)
			enableDisableWeaponType(team, "sniper", 1);
		else
			enableDisableWeaponType(team, "sniper", 0);
	}

	if(isdefined(level.empire_uo))
	{
		if(level.empire_lmglimit)
		{
			if(level.empire_lmglimit>lmg)
				enableDisableWeaponType(team, "lmg", 1);
			else
				enableDisableWeaponType(team, "lmg", 0);
		}

		if(level.empire_ftlimit)
		{
			if(level.empire_ftlimit>ft)
				enableDisableWeaponType(team, "ft", 1);
			else
				enableDisableWeaponType(team, "ft", 0);
		}

		if(level.empire_rllimit)
		{
			if(level.empire_rllimit>rl)
				enableDisableWeaponType(team, "rl", 1);
			else
				enableDisableWeaponType(team, "rl", 0);
		}
	}

	if(level.empire_fg42limit)
	{
		if(level.empire_fg42limit>fg42)
			enableDisableWeaponType(team, "fg42", 1);
		else
			enableDisableWeaponType(team, "fg42", 0);
	}
}

enableDisableWeaponType(team, type, value)
{
	switch(game[team])
	{
		case "american":
			switch(type)
			{
				case "rifle":
					aweSetCvar("scr_allow_m1carbine", value);
					aweSetCvar("scr_allow_m1garand", value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_m1carbine");
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_m1garand");
					}
					break;
				case "boltrifle":
					aweSetCvar("scr_allow_m1carbine", value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_m1carbine");
					}
					break;
				case "semirifle":
					aweSetCvar("scr_allow_m1garand", value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_m1garand");
					}
					break;
				case "smg":
					aweSetCvar("scr_allow_thompson",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_thompson");
					}
					break;
				case "assault":
					aweSetCvar("scr_allow_bar",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_bar");
					}
					break;
				case "sniper":
					aweSetCvar("scr_allow_springfield",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_springfield");
					}
					break;
				case "lmg":
					aweSetCvar("scr_allow_mg30cal",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_mg30cal");
					}
					break;
				case "ft":
					aweSetCvar("scr_allow_ft_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_flamethrower");
					}
					break;
				case "rl":
					aweSetCvar("scr_allow_rl_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_bazooka");
					}
					break;
				case "fg42":
					aweSetCvar("scr_allow_fg42_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_fg42");
					}
					break;
				default:
					break;
			}
			break;

		case "british":
			switch(type)
			{
				case "rifle":
					aweSetCvar("scr_allow_enfield", value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_enfield");
					}
					break;
				case "smg":
					aweSetCvar("scr_allow_sten",value);
					aweSetCvar("scr_allow_sten_silenced",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_sten");
						if(isdefined(level.empire_uo))
							maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_sten_silenced");
					}
					break;
				case "assault":
					aweSetCvar("scr_allow_bren",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_bren");
					}
					break;
				case "sniper":
					aweSetCvar("scr_allow_springfield",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_springfield");
					}
					break;
				case "lmg":
					aweSetCvar("scr_allow_mg30cal",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_mg30cal");
					}
					break;
				case "ft":
					aweSetCvar("scr_allow_ft_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_flamethrower");
					}
					break;
				case "rl":
					aweSetCvar("scr_allow_rl_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_bazooka");
					}
					break;
				case "fg42":
					aweSetCvar("scr_allow_fg42_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_fg42");
					}
					break;
				default:
					break;
			}
			break;

		case "russian":
			switch(type)
			{
				case "rifle":
					aweSetCvar("scr_allow_nagant", value);
					aweSetCvar("scr_allow_svt40", value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_mosinnagant");
						if(isdefined(level.empire_uo))
							maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_svt40");
					}
					break;
				case "boltrifle":
					aweSetCvar("scr_allow_nagant", value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_mosinnagant");
					}
					break;
				case "semirifle":
					aweSetCvar("scr_allow_svt40", value);
					if(!value)
					{
						if(isdefined(level.empire_uo))
							maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_svt40");
					}
					break;
				case "smg":
					aweSetCvar("scr_allow_ppsh",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_ppsh");
					}
					break;
				case "sniper":
					aweSetCvar("scr_allow_nagantsniper",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_mosinnagantsniper");
					}
					break;
				case "lmg":
					aweSetCvar("scr_allow_dp28",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_dp28");
					}
					break;
				case "ft":
					aweSetCvar("scr_allow_ft_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_flamethrower");
					}
					break;
				case "rl":
					aweSetCvar("scr_allow_rl_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_bazooka");
					}
					break;
				case "fg42":
					aweSetCvar("scr_allow_fg42_allies",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_fg42");
					}
					break;
				default:
					break;
			}
			break;

		default:
			switch(type)
			{
				case "rifle":
					aweSetCvar("scr_allow_kar98k", value);
					aweSetCvar("scr_allow_gewehr43", value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_kar98k");
						if(isdefined(level.empire_uo))
							maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_gewehr43");
					}
					break;
				case "boltrifle":
					aweSetCvar("scr_allow_kar98k", value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_kar98k");
					}
					break;
				case "semirifle":
					aweSetCvar("scr_allow_gewehr43", value);
					if(!value)
					{
						if(isdefined(level.empire_uo))
							maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_gewehr43");
					}
					break;
				case "smg":
					aweSetCvar("scr_allow_mp40",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_mp40");
					}
					break;
				case "assault":
					aweSetCvar("scr_allow_mp44",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_mp44");
					}
					break;
				case "sniper":
					aweSetCvar("scr_allow_kar98ksniper",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_kar98ksniper");
					}
					break;
				case "lmg":
					aweSetCvar("scr_allow_mg34",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_mg34");
					}
					break;
				case "ft":
					aweSetCvar("scr_allow_ft_axis",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_flamethrower");
					}
					break;
				case "rl":
					aweSetCvar("scr_allow_rl_axis",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_panzerschreck");
					}
					break;
				case "fg42":
					aweSetCvar("scr_allow_fg42_axis",value);
					if(!value)
					{
						maps\mp\gametypes\_teams::deletePlacedEntity("mpweapon_fg42");
					}
					break;
				default:
					break;
			}
			break;
	}
}

aweSetCvar(cvar, value)
{
	if(getcvar(cvar) != value) setcvar(cvar,value);
}

checkLimitedWeapons()
{
	level endon("empire_boot");

	for(;;)
	{
		limitWeapons("allies");
		wait 0.1;
		limitWeapons("axis");
		wait 0.1;
	}
}

breath_fx()
{
	self endon("empire_spawned");
	self endon("empire_died");

	wait (2 + randomint(3));

	while(isalive(self) && self.sessionstate == "playing")
	{
		if(!self maps\mp\gametypes\_empire_uncommon::aweIsInVehicle())
			playfxontag (level.empire_breathfx, self, "Bip01 Head");
		wait randomfloatrange(1.5,3.5);
	}
}

limitBases()
{
	bases = getentarray("gmi_base","targetname");
	bases = randomizeArray(bases);

	axis_bases = 0;
	allied_bases = 0;

	for(i=0;i<bases.size;i++)
	{
		if(!isdefined(bases[i].script_team))
			continue;

		if(bases[i].script_team == "axis")
		{
			axis_bases++;
			if(axis_bases<=level.empire_limitbases)
				continue;
		}
		else
		{
			allied_bases++;
			if(allied_bases<=level.empire_limitbases)
				continue;
		}


		bases[i].targetname = "gmi_base_disabled";
	
		if (isdefined(bases[i].target))
		{
			bases[i].attachedThings = getentarray(bases[i].target, "targetname");
			for (q=0;q<bases[i].attachedThings.size;q++)
			{
				if (isdefined(bases[i].attachedThings[q]))
				{
					if (!isdefined(bases[i].attachedThings[q].script_idnumber))	continue;

					if (	(bases[i].attachedThings[q].classname == "mp_gmi_bas_allies_spawn") ||
						(bases[i].attachedThings[q].classname == "mp_gmi_bas_axis_spawn"))
					{
						//	we could enable a spawn for the other team if we wanted to here 
						//	or swap the spawn team 
						bases[i].attachedThings[q] delete();
					}
					thing = bases[i].attachedThings[q];
				
					if((thing.classname == "script_model") ||
					   (thing.classname == "script_brushmodel") ||
					   (thing.classname == "script_origin"))
					{
						thing hide();
						if(thing.classname != "script_model")
							thing notsolid();
						thing delete();
					}
				}
			} 
		}
	}

	// Wait for damage model to be precached
	wait 1;

	bases = getentarray("gmi_base_disabled","targetname");

	for(i=0;i<bases.size;i++)
	{
		bases[i].rubble = spawn("script_model",bases[i].origin);
		bases[i].rubble.angles = bases[i].angles;
		if (bases[i].script_team == "axis")
		{
			bases[i] setmodel(game["bas_axis_destroyed"]);
			bases[i].rubble setmodel(game["bas_axis_rubble"]);
		}
		else
		{
			bases[i] setmodel(game["bas_allies_destroyed"]);
			bases[i].rubble setmodel(game["bas_allies_rubble"]);
		}
	}
}

GetPlainMapRotation(number)
{
	return GetMapRotation(false, false, number);
}

GetRandomMapRotation()
{
	return GetMapRotation(true, false, undefined);
}

GetCurrentMapRotation(number)
{
	return GetMapRotation(false, true, number);
}

GetMapRotation(random, current, number)
{
	maprot = "";

	if(!isdefined(number))
		number = 0;

	// Get current maprotation
	if(current)
		maprot = strip(getcvar("sv_maprotationcurrent"));	

	// Get maprotation if current empty or not the one we want
	if(level.empire_debug) iprintln("(cvar)maprot: " + getcvar("sv_maprotation").size);
	if(maprot == "")
		maprot = strip(getcvar("sv_maprotation"));	
	if(level.empire_debug) iprintln("(var)maprot: " + maprot.size);

	// No map rotation setup!
	if(maprot == "")
		return undefined;
	
	// Explode entries into an array
//	temparr2 = explode(maprot," ");
	j=0;
	temparr2[j] = "";	
	for(i=0;i<maprot.size;i++)
	{
		if(maprot[i]==" ")
		{
			j++;
			temparr2[j] = "";
		}
		else
			temparr2[j] += maprot[i];
	}

	// Remove empty elements (double spaces)
	temparr = [];
	for(i=0;i<temparr2.size;i++)
	{
		element = strip(temparr2[i]);
		if(element != "")
		{
			if(level.empire_debug) iprintln("maprot" + temparr.size + ":" + element);
			temparr[temparr.size] = element;
		}
	}

	// Spawn entity to hold the array
	x = spawn("script_origin",(0,0,0));

	x.maps = [];
	lastexec = undefined;
	lastjeep = undefined;
	lasttank = undefined;
	lastgt = getcvar("g_gametype");
	for(i=0;i<temparr.size;)
	{
		switch(temparr[i])
		{
			case "allow_jeeps":
				if(isdefined(temparr[i+1]))
					lastjeep = temparr[i+1];
				i += 2;
				break;

			case "allow_tanks":
				if(isdefined(temparr[i+1]))
					lasttank = temparr[i+1];
				i += 2;
				break;
	
			case "exec":
				if(isdefined(temparr[i+1]))
					lastexec = temparr[i+1];
				i += 2;
				break;

			case "gametype":
				if(isdefined(temparr[i+1]))
					lastgt = temparr[i+1];
				i += 2;
				break;

			case "map":
				if(isdefined(temparr[i+1]))
				{
					x.maps[x.maps.size]["exec"]		= lastexec;
					x.maps[x.maps.size-1]["jeep"]	= lastjeep;
					x.maps[x.maps.size-1]["tank"]	= lasttank;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i+1];
				}
				// Only need to save this for random rotations
				if(!random)
				{
					lastexec = undefined;
					lastjeep = undefined;
					lasttank = undefined;
					lastgt = undefined;
				}

				i += 2;
				break;

			// If code get here, then the maprotation is corrupt so we have to fix it
			default:
				iprintlnbold("ERROR IN MAPROTATION!!! Will try to fix.");
	
				if(isGametype(temparr[i]))
					lastgt = temparr[i];
				else if(isConfig(temparr[i]))
					lastexec = temparr[i];
				else
				{
					x.maps[x.maps.size]["exec"]		= lastexec;
					x.maps[x.maps.size-1]["jeep"]	= lastjeep;
					x.maps[x.maps.size-1]["tank"]	= lasttank;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i];
	
					// Only need to save this for random rotations
					if(!random)
					{
						lastexec = undefined;
						lastjeep = undefined;
						lasttank = undefined;
						lastgt = undefined;
					}
				}
					

				i += 1;
				break;
		}
		if(number && x.maps.size >= number)
			break;
	}

	if(random)
	{
		tuning = ParseGametypeRotationWeights();

		if(!isdefined(tuning) || !isdefined(tuning["enabled"]) || !tuning["enabled"])
		{
			// Shuffle the array 20 times
			for(k = 0; k < 20; k++)
			{
				for(i = 0; i < x.maps.size; i++)
				{
					j = randomInt(x.maps.size);
					element = x.maps[i];
					x.maps[i] = x.maps[j];
					x.maps[j] = element;
				}
			}
		}
		else
		{
			remainingmaps = [];
			for(i = 0; i < x.maps.size; i++)
				remainingmaps[remainingmaps.size] = x.maps[i];

			x.maps = [];
			while(remainingmaps.size)
			{
				availablegametypes = [];
				for(i = 0; i < remainingmaps.size; i++)
				{
					gt = remainingmaps[i]["gametype"];

					exists = false;
					for(j = 0; j < availablegametypes.size; j++)
					{
						if(availablegametypes[j] == gt)
						{
							exists = true;
							break;
						}
					}

					if(!exists)
						availablegametypes[availablegametypes.size] = gt;
				}

				totalweight = 0;
				for(i = 0; i < availablegametypes.size; i++)
				{
					gt = availablegametypes[i];
					weight = 0;
					if(isdefined(tuning[gt]))
						weight = tuning[gt];

					if(weight > 0)
						totalweight += weight;
				}

				selectedgt = undefined;
				if(totalweight > 0)
				{
					roll = randomInt(totalweight);
					bucket = 0;
					for(i = 0; i < availablegametypes.size; i++)
					{
						gt = availablegametypes[i];
						weight = 0;
						if(isdefined(tuning[gt]))
							weight = tuning[gt];

						if(weight <= 0)
							continue;

						bucket += weight;
						if(roll < bucket)
						{
							selectedgt = gt;
							break;
						}
					}
				}

				// Fallback when no weighted gametype is available in the remaining pool.
				if(!isdefined(selectedgt))
					selectedgt = availablegametypes[randomInt(availablegametypes.size)];

				candidates = [];
				for(i = 0; i < remainingmaps.size; i++)
				{
					if(remainingmaps[i]["gametype"] == selectedgt)
						candidates[candidates.size] = i;
				}

				if(!candidates.size)
					mapindex = randomInt(remainingmaps.size);
				else
					mapindex = candidates[randomInt(candidates.size)];

				x.maps[x.maps.size] = remainingmaps[mapindex];
				remainingmaps = removeArrayIndex(remainingmaps, mapindex);
			}
		}
	}

	return x;
}

ParseGametypeRotationWeights()
{
	parsed = [];
	parsed["enabled"] = false;

	weightsraw = cvardef("empire_random_gametype_weights", "", "", "", "string");
	weightsraw = strip(weightsraw);
	if(weightsraw == "")
		return parsed;

	entries = explode(weightsraw, ",");
	if(!isdefined(entries) || !entries.size)
		return parsed;

	validweights = 0;
	for(i = 0; i < entries.size; i++)
	{
		entry = strip(entries[i]);
		if(entry == "")
			continue;

		pair = explode(entry, ":");
		if(!isdefined(pair) || pair.size < 2)
			pair = explode(entry, "=");

		if(!isdefined(pair) || pair.size < 2)
			continue;

		gt = strip(pair[0]);
		if(gt == "" || !isGametype(gt))
			continue;

		weight = (int)strip(pair[1]);
		if(weight <= 0)
			continue;

		parsed[gt] = weight;
		validweights += weight;
	}

	if(validweights > 0)
		parsed["enabled"] = true;

	return parsed;
}

isConfig(cfg)
{
	temparr = explode(cfg,".");
	if(temparr.size == 2 && temparr[1] == "cfg")
		return true;
	else
		return false;
}

isGametype(gt)
{
	switch(gt)
	{
		case "dm":
		case "tdm":
		case "sd":
		case "re":
		case "hq":
		case "bel":
		case "bas":
		case "dom":
		case "ctf":
		case "actf":
		case "lts":
		case "cnq":
		case "rsd":
		case "tdom":
		case "ad":
		case "htf":
		case "asn":

		case "mc_dm":
		case "mc_tdm":
		case "mc_sd":
		case "mc_re":
		case "mc_hq":
		case "mc_bel":
		case "mc_bas":
		case "mc_dom":
		case "mc_ctf":
		case "mc_actf":
		case "mc_lts":
		case "mc_cnq":
		case "mc_rsd":
		case "mc_tdom":
		case "mc_ad":
		case "mc_htf":
		case "mc_asn":

			return true;

		default:
			return false;
	}
}

spawnSpectator(origin, angles)
{
	self notify("spawned");
	self notify("killed");
	self notify("end_respawn");

	resettimeout();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	
	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);
	else
	{
		spawnpointnames = [];
		spawnpointnames[spawnpointnames.size] = level.empire_spawnspectatorname;
		spawnpointnames[spawnpointnames.size] = "mp_teamdeathmatch_intermission";
		spawnpointnames[spawnpointnames.size] = "mp_deathmatch_intermission";
		spawnpointnames[spawnpointnames.size] = "mp_searchanddestroy_intermission";
		spawnpointnames[spawnpointnames.size] = "mp_retrieval_intermission";
		spawnpointnames[spawnpointnames.size] = "mp_ctf_intermission";
		spawnpointnames[spawnpointnames.size] = "mp_dom_intermission";
		spawnpointnames[spawnpointnames.size] = "mp_gmi_bas_intermission";
		spawnpointnames[spawnpointnames.size] = "mp_teamdeathmatch_spawn";
		spawnpointnames[spawnpointnames.size] = "mp_deathmatch_spawn";

		spawnpoint = undefined;
		for(i = 0; i < spawnpointnames.size; i++)
		{
			spawnpointname = spawnpointnames[i];

			if(!isDefined(spawnpointname) || spawnpointname == "")
				continue;

			spawnpoints = getentarray(spawnpointname, "classname");
			if(!isDefined(spawnpoints) || !spawnpoints.size)
				continue;

			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
			if(isDefined(spawnpoint))
			{
				if(spawnpointname != level.empire_spawnspectatorname)
					iprintln("^3empire_mod warning:^7 Missing spectator spawn classname '^1" + level.empire_spawnspectatorname + "^7', using fallback '^2" + spawnpointname + "^7'.");

				self spawn(spawnpoint.origin, spawnpoint.angles);
				return;
			}
		}

		maps\mp\_utility::error("NO SPECTATOR SPAWNPOINTS FOUND (TRIED " + level.empire_spawnspectatorname + " AND FALLBACK CLASSNAMES)");
	}
}

endMap()
{
	if(level.empire_disable)
		return;

	maps\mp\gametypes\_empire_nextmap::Initialise();
}

aweObituary(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	if(getcvar("g_gametype") == "rsd" || getcvar("g_gametype") == "mc_rsd")
	{
		if ( !isdefined(self.suicide) )
			self.suicide = false;
		if ( self.suicide == true )
			return;
	}
	if(getcvar("g_gametype") == "dem" || getcvar("g_gametype") == "mc_dem")
	{
		if(sMeansOfDeath == "MOD_MELEE")  // don't flood with redundant kill reports
			return;
	}

	// If the player was killed by a head shot, let players know it was a head shot kill
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";
		
	// if this is a melee kill from a binocular then make sure they know that they are a loser
	if(sMeansOfDeath == "MOD_MELEE" && (sWeapon == "binoculars_artillery_mp" || sWeapon == "binoculars_mp"))
		sMeansOfDeath = "MOD_MELEE_BINOCULARS";
	
	// if this is a kill from the artillery binocs change the icon
	if(sMeansOfDeath != "MOD_MELEE_BINOCULARS" && sWeapon == "binoculars_artillery_mp")
		sMeansOfDeath = "MOD_ARTILLERY";

	if(!level.empire_disable && level.empire_obituary == 2 && isdefined(attacker) && isplayer(attacker))
	{
		if (sMeansOfDeath == "MOD_MELEE")
			sWeapon = "Bash";
		else
		{
			if(isDefined(sWeapon))
				sWeapon = getWeaponName(sWeapon);
			else
				sWeapon = "UNKNOWN WEP";
		}

		range = distance(attacker.origin, self.origin);
		//range_sae = (int)(range * 0.02778);	// Range in FEET
		range_iso = (int)(range * 0.0254);	// Range in METERS

		if(isdefined(sHitLoc))
			sHitLoc = getHitLocName(sHitLoc);
		else
			sHitLoc = " ";

		//get sides
		if(isdefined(level.empire_teamplay))
		{
			selfteam = self.sessionteam;
			attackerteam = attacker.sessionteam;
		}
		else
		{
			selfteam = self.pers["team"];
			attackerteam = attacker.pers["team"];
		}

		if(selfteam == "allies")
			SelfColour = "^4";
		else
			SelfColour = "^1";

		if(attackerteam == "allies")
			AttackerColour = "^4";
		else
			AttackerColour = "^1";
			
		SelfName = maps\mp\_ahz_utility::monotone(self.name);
		AttackerName = maps\mp\_ahz_utility::monotone(attacker.name);
					
		if(attacker == self) // Suicide?
		{
			iprintln(SelfColour + SelfName + "^5 Has killed Himself");
			if(level.empire_obituarydeath)
				self iprintlnbold("You killed yourself");
		}
		else if(sHitLoc != "none") // Hitloc?
		{
			iprintln(AttackerColour + AttackerName + "^7 killed " + SelfColour + SelfName + "^7 / " + sWeapon + " / " + sHitLoc + " / " + range_iso + "m");
			if(level.empire_obituarydeath)
				self iprintlnbold("^7Killed by " + AttackerColour + AttackerName + "^7 /" + sWeapon + " / " + sHitLoc + " / " + range_iso + "m");
		}
		else // Catch the rest
		{
			iprintln(AttackerColour + AttackerName + "^7 killed " + SelfColour + SelfName + "^7 / " + sWeapon + " / " + range_iso + "m");
			if(level.empire_obituarydeath)
				self iprintlnbold("^7killed by " + AttackerColour + AttackerName + "^7 /" + sWeapon + " / " + range_iso + "m");
		}
	}
	else  // Normal obituarys
	{
		obituary(self, attacker, sWeapon, sMeansOfDeath);
	}
}

spawnradios()
{
	level.empire_disable = cvardef("empire_disable",0,0,1,"int");
	if(level.empire_disable)
		return;

	newradios	= cvardef("empire_hq_spawn_radios",8,3,20,"int");
	forcenew = cvardef("empire_hq_force_new_radios",0,0,1,"int");

	radios = getentarray ("hqradio","targetname");
	if ( (!radios.size) || (radios.size < 3) || forcenew)
	{
		spawnpointname = "mp_teamdeathmatch_spawn";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		for(i=0;i<newradios;i++)
		{
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
			radio = spawn ("script_model", (0,0,0));
			radio.origin = spawnpoint.origin;
			radio.angles = spawnpoint.angles;
			radio.targetname = "hqradio";
		}
	}
}
