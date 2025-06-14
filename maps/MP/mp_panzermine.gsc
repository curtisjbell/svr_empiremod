main()
{
setCullFog (0, 24000, 0.8, 0.8, 0.8, 0);
thread pam_ambientsounds();

maps\mp\_load::main();
maps\mp\mp_panzermine_fx::main();
maps\mp\toilet::main();




game["allies"] = "american";
game["axis"] = "german";

game["american_soldiertype"] = "airborne";
game["american_soldiervariation"] = "winter";
game["german_soldiertype"] = "wehrmacht";
game["german_soldiervariation"] = "winter";

game["attackers"] = "allies";
game["defenders"] = "axis";

game["layoutimage"] = "mp_panzermine";

//retrival settings
	level.obj["1"] = (&"RE_OBJ_CODE_BOOK");					
	game["re_attackers"] = "allies";
	game["re_defenders"] = "axis";
	game["re_attackers_obj_text"] = "Capture the code book, and take it back to the gate.";
	game["re_defenders_obj_text"] = "Defend the code book at all cost. To die for our country, our honour shall be.";
	game["re_spectator_obj_text"] = "Americans: Must capture the code book";
	game["re_attackers_intro_text"] = "Capture the code book to confuse the German communication.";
	game["re_defenders_intro_text"] = "Defend the code book at all hazards for our Fatherland";

	
//hq settings
	if (getcvar("g_gametype") == "hq")
	{
		radio = [];
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-1444, -681, 77);
		radio.angles = (0, 0, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-408, 727, 85);
		radio.angles = (0, 90, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-1116, -977, 419);
		radio.angles = (0, 180, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-2961, 830, 90);
		radio.angles = (0, 180, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-3176, 2003, 96);
		radio.angles = (0, 360, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (316, -698, 591);
		radio.angles = (0, 45, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-324, -17, -23);
		radio.angles = (0, 180, 0);
		radio.targetname = "hqradio";
		radio = spawn ("script_model", (0,0,0));
		radio.origin = (-2304, -305, 445);
		radio.angles = (0, 180, 0);
		radio.targetname = "hqradio";
	}

}

pam_ambientsounds()
{
	if (getcvar("rpam_ambientsounds") != "0")
	{
		ambientPlay("ambient_panzermine");
	}
}