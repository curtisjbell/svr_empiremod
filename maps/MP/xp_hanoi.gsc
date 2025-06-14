/*
   Mapping, scripting and custom textures
   by George "Expert" Gelardos,  (c)2016.
   Email: expertiz4@hotmail.com 

 	"Art is the only way to run away
    	 without leaving home." 
   					-Twyla Tharp 	
						 		*/

main() 
{
	maps\mp\_load::main();
	thread searchlight();
	//thread cinema();
	thread noProne();

	setExpFog(0.00001, 0, 0, 0, 0);
	thread pam_ambientsounds();
	//The map's background sound was professionally recorded 	//by "DigitalDials" (Youtube channel).

	game["allies"] = "american";
	game["axis"] = "german";

	game["russian_soldiertype"] = "conscript";
	game["russian_soldiervariation"] = "normal";
	game["german_soldiertype"] = "wehrmacht";
	game["german_soldiervariation"] = "normal";

	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game["layoutimage"] = "xp_hanoi";

	//Retrival settings
	level.obj["Code Book"] = (&"RE_OBJ_CODE_BOOK");
	level.obj["Field Radio"] = (&"RE_OBJ_FIELD_RADIO");
	game["re_attackers"] = "allies";
	game["re_defenders"] = "axis";
	game["re_attackers_obj_text"] = (&"RE_OBJ_CARENTAN_OBJ_ATTACKER");
	game["re_defenders_obj_text"] = (&"RE_OBJ_CARENTAN_OBJ_DEFENDER");
	game["re_spectator_obj_text"] = (&"RE_OBJ_CARENTAN_OBJ_SPECTATOR");
	game["re_attackers_intro_text"] = (&"RE_OBJ_CARENTAN_SPAWN_ATTACKER");
	game["re_defenders_intro_text"] = (&"RE_OBJ_CARENTAN_SPAWN_DEFENDER");
} //END OF MAIN()

/* 
     Functions
			  */

searchlight()
{
	light = getent("light1","targetname");
	while(1)
	{
		light rotateyaw(70, 8.5);
		wait 4.5;
		light rotateyaw(-70, 8.5);
		wait 4.5;
	}

}

/*cinema()
{
	cinema3 = getent("cinema3","targetname");
	cinema2 = getent("cinema2","targetname");
	cinema1 = getent("cinema1","targetname");
	cinema0 = getent("cinema0","targetname");
	while(1)
	{
		cinema0 moveZ( 136, 0.001); 
		cinema3 moveZ(-136, 0.001); 
		wait 1.1;
		cinema2 moveZ(-136, 0.001);
		cinema3 moveZ( 136, 0.001);
		wait 1.1;
		cinema2 moveZ(136, 0.001);
		cinema1 moveZ(-136, 0.001);
		wait 1.1;
		cinema1 moveZ(136, 0.001);
		cinema0 moveZ(-136, 0.001);
		wait 1.1;
	}
}
*/
noprone() //Part of Roger Abrahamsson's _noprone.gsc script.
{
	trig = getent("noprone","targetname");
	while(true)
		{
			trig waittill("trigger",user);
			if (user istouching(trig))
			{
				user setClientCvar("cl_stance", 1);
			}
			wait 1.5;
		}
}

pam_ambientsounds()
{
	if (getcvar("sv_ambientsounds") != "0")
	{
		ambientPlay("ambient_xp_hanoi");
	}
}