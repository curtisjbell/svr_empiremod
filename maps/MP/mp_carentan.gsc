/*
Ambient sounds made by Intuitive-Gaming.com
*/

main()
{
	setCullFog (0, 16500, 0.7, 0.85, 1.0, 0);
	thread pam_ambientsounds();
	
	// set the nighttime flag to be off
	setcvar("sv_night", "0" );

	maps\mp\_load::main();
	maps\mp\mp_carentan_fx::main();
	maps\mp\mp_carentan::layout_images();

	remove_me_ctf();

	game["allies"] = "american";
	game["axis"] = "german";

	game["american_soldiertype"] = "airborne";
	game["american_soldiervariation"] = "normal";
	game["german_soldiertype"] = "fallschirmjagergrey";
	game["german_soldiervariation"] = "normal";

	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game["hud_allies_victory_image"] = "gfx/hud/hud@mp_victory_carentan_us.dds";
	game["hud_axis_victory_image"] = "gfx/hud/hud@mp_victory_carentan_g.dds";
	
	game["layoutimage"] = "mp_carentan";

	//retrival settings
	level.obj["Code Book"] = (&"RE_OBJ_CODE_BOOK");
	level.obj["Field Radio"] = (&"RE_OBJ_FIELD_RADIO");
	game["re_attackers"] = "allies";
	game["re_defenders"] = "axis";
	game["re_attackers_obj_text"] = (&"RE_OBJ_CARENTAN_OBJ_ATTACKER");
	game["re_defenders_obj_text"] = (&"RE_OBJ_CARENTAN_OBJ_DEFENDER");
	game["re_spectator_obj_text"] = (&"RE_OBJ_CARENTAN_OBJ_SPECTATOR");
	game["re_attackers_intro_text"] = (&"RE_OBJ_CARENTAN_SPAWN_ATTACKER");
	game["re_defenders_intro_text"] = (&"RE_OBJ_CARENTAN_SPAWN_DEFENDER");
	
	//hq settings
	if (getcvar("g_gametype") == "hq")
	{
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (1198, 155, 18);
		radio.angles = (0, 257, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (100, 601, 0);
		radio.angles = (0, 352, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-678, 430, 6);
		radio.angles = (354, 234, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-842, 2084, 179);
		radio.angles = (0, 290, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (525, 1975, -118);
		radio.angles = (0, 267, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (1962, 2293, -24);
		radio.angles = (0, 245, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (837, 3637, -16);
		radio.angles = (0, 90, 0);
		radio.targetname = "hqradio";
	}
	
	// FOR BUILDING PAK FILES ONLY
	if (getcvar("fs_copyfiles") == "1")
	{
		precacheShader(game["dom_layoutimage"]);
		precacheShader(game["ctf_layoutimage"]);
//		precacheShader(game["bas_layoutimage"]);
		precacheShader(game["layoutimage"]);
		precacheShader(game["hud_allies_victory_image"]);
		precacheShader(game["hud_axis_victory_image"]);
	}
}

layout_images()
{
	game["ctf_layoutimage"] = "mp_carentan_ctf";
	game["layoutimage"] = "mp_carentan";
}

remove_me_ctf()
{
	if (getcvar("g_gametype") == "ctf")
	{
		mg42 = getent("remove_me_42","targetname");
		mg42 delete();
	}
}

pam_ambientsounds()
{
	if (getcvar("sv_ambientsounds") != "0")
	{
		ambientPlay("ambient_mp_carentan");
	}
}