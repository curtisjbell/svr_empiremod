main()
{
   setCullFog (0, 5000, .32, .36, .40, 0 );
   thread pam_ambientsounds();
   maps\mp\_load::main();
   game["allies"] = "british";
   game["axis"] = "german";

   game["british_soldiertype"] = "airborne";
   game["british_soldiervariation"] = "normal";
   game["german_soldiertype"] = "fallschirmjagergrey";
   game["german_soldiervariation"] = "normal";
   game["layoutimage"] = "mp_vacant";
 
   game["attackers"] = "allies";
   game["defenders"] = "axis";


}

pam_ambientsounds()
{
	if (getcvar("sv_ambientsounds") != "0")
	{
		ambientPlay("ambient_np_hurtgen");
	}
}
  
 