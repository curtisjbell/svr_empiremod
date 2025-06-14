/*
Ambient sounds made by Intuitive-Gaming.com
*/

main()
{
	setCullFog (0, 16500, 0.7, 0.85, 1.0, 0);
	thread pam_ambientsounds();

	maps\mp\_load::main();
	maps\mp\german_town_fx::main();

	game["allies"] = "american";
	game["axis"] = "german";

	game["russian_soldiertype"] = "conscript";
	game["russian_soldiervariation"] = "normal";
	game["german_soldiertype"] = "waffen";
	game["german_soldiervariation"] = "normal";

	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game["layoutimage"] = "german_town";
}

pam_ambientsounds()
{
	if (getcvar("sv_ambientsounds") != "0")
	{
		ambientPlay("ambient_mp_brecourt");
	}
}