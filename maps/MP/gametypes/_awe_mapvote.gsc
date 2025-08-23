//***********************************************************************************************************
// MAP VOTE PACKAGE
// ORIGINALLY MADE BY NC-17 (codam, powerserver), REWORKED BY wizard220, MODIFIED BY FrAnCkY55, Modified again by bell
//***********************************************************************************************************

Initialise()
{
       if(!level.awe_mapvote) return;

       if(getcvar("awe_mapvote_autopick") == "")
               setcvar("awe_mapvote_autopick", "0");
       autopick = getcvarint("awe_mapvote_autopick");

      // Use a consistent offset so vote counters line up correctly with the
      // printed map names across all game variants.  An offset of 0 caused the
      // counters to appear two rows below their maps in PAMUO Search & Destroy.
      level.awe_mapvotehudoffset = 0;

       // Small wait
       wait .5;

       // Cleanup some stuff to free up some resources
       CleanUp();

       if(autopick != 1)
       {
               // Create HUD
               CreateHud();
       }

       // Start mapvote thread
       thread RunMapVote();

       // Wait for voting to finish
       level waittill("VotingComplete");

       if(autopick != 1)
       {
               // Delete HUD
               DeleteHud();
       }
}

CleanUp()
{
	// Kill AWE threads
	level notify("awe_boot");
	// Wait for threads to die
	wait .05;
	// Delete some HUD elements
	if(isdefined(level.clock)) level.clock destroy();
	if(isdefined(level.awe_axisicon)) level.awe_axisicon destroy();
	if(isdefined(level.awe_axisnumber)) level.awe_axisnumber destroy();
	if(isdefined(level.awe_deadaxisicon)) level.awe_deadaxisicon destroy();
	if(isdefined(level.awe_deadaxisnumber)) level.awe_deadaxisnumber destroy();
	if(isdefined(level.awe_alliedicon)) level.awe_alliedicon destroy();
	if(isdefined(level.awe_alliednumber)) level.awe_alliednumber destroy();
	if(isdefined(level.awe_deadalliedicon)) level.awe_deadalliedicon destroy();
	if(isdefined(level.awe_deadalliednumber)) level.awe_deadalliednumber destroy();
	if(isdefined(level.awe_warmupmsg)) level.awe_warmupmsg destroy();
}

CreateHud()
{
	level.vote_hud_bgnd = newHudElem();
	level.vote_hud_bgnd.archived = false;
	level.vote_hud_bgnd.alpha = .7;
	level.vote_hud_bgnd.x = 205;
	level.vote_hud_bgnd.y = level.awe_mapvotehudoffset + 17;
	level.vote_hud_bgnd.sort = 9000;
	level.vote_hud_bgnd.color = (0,0,0);
	level.vote_hud_bgnd setShader("white", 260, 140);
	
	level.vote_header = newHudElem();
	level.vote_header.archived = false;
	level.vote_header.alpha = .3;
	level.vote_header.x = 208;
	level.vote_header.y = level.awe_mapvotehudoffset + 19;
	level.vote_header.sort = 9001;
	level.vote_header setShader("white", 254, 21);
	
	level.vote_headerText = newHudElem();
	level.vote_headerText.archived = false;
	level.vote_headerText.x = 210;
	level.vote_headerText.y = level.awe_mapvotehudoffset + 21;
	level.vote_headerText.sort = 9998;
	level.vote_headerText.label = level.mapvotetext["MapVoteHeader"];
	level.vote_headerText.fontscale = 1.3;

	level.vote_leftline = newHudElem();
	level.vote_leftline.archived = false;
	level.vote_leftline.alpha = .3;
	level.vote_leftline.x = 207;
	level.vote_leftline.y = level.awe_mapvotehudoffset + 19;
	level.vote_leftline.sort = 9001;
	level.vote_leftline setShader("white", 1, 135);
	
	level.vote_rightline = newHudElem();
	level.vote_rightline.archived = false;
	level.vote_rightline.alpha = .3;
	level.vote_rightline.x = 462;
	level.vote_rightline.y = level.awe_mapvotehudoffset + 19;
	level.vote_rightline.sort = 9001;
	level.vote_rightline setShader("white", 1, 135);
	
	level.vote_bottomline = newHudElem();
	level.vote_bottomline.archived = false;
	level.vote_bottomline.alpha = .3;
	level.vote_bottomline.x = 207;
	level.vote_bottomline.y = level.awe_mapvotehudoffset + 154;
	level.vote_bottomline.sort = 9001;
	level.vote_bottomline setShader("white", 256, 1);

/*	level.vote_hud_votestext = newHudElem();
	level.vote_hud_votestext.archived = false;
	level.vote_hud_votestext.x = 435;
	level.vote_hud_votestext.y = level.awe_mapvotehudoffset + 56;
	level.vote_hud_votestext.sort = 9998;
	level.vote_hud_votestext.fontscale = 0.8;
	level.vote_hud_votestext.label = level.mapvotetext["Votes"];*/
	
	level.vote_hud_timeleft = newHudElem();
	level.vote_hud_timeleft.archived = false;
	level.vote_hud_timeleft.x = 400;
	level.vote_hud_timeleft.y = level.awe_mapvotehudoffset + 26;
	level.vote_hud_timeleft.sort = 9998;
	level.vote_hud_timeleft.fontscale = .8;
	level.vote_hud_timeleft.label = level.mapvotetext["TimeLeft"];
	level.vote_hud_timeleft setValue( level.awe_mapvotetime );	
	
	level.vote_hud_instructions = newHudElem();
	level.vote_hud_instructions.archived = false;
	level.vote_hud_instructions.x = 340;
	level.vote_hud_instructions.y = level.awe_mapvotehudoffset + 56;
	level.vote_hud_instructions.sort = 9998;
	level.vote_hud_instructions.fontscale = 1;
	level.vote_hud_instructions.label = level.mapvotetext["MapVote"];
	level.vote_hud_instructions.alignX = "center";
	level.vote_hud_instructions.alignY = "middle";
	
	level.vote_map1 = newHudElem();
	level.vote_map1.archived = false;
	level.vote_map1.x = 434;
	level.vote_map1.y = level.awe_mapvotehudoffset + 69;
	level.vote_map1.sort = 9998;
		
	level.vote_map2 = newHudElem();
	level.vote_map2.archived = false;
	level.vote_map2.x = 434;
	level.vote_map2.y = level.awe_mapvotehudoffset + 85;
	level.vote_map2.sort = 9998;
		
	level.vote_map3 = newHudElem();
	level.vote_map3.archived = false;
	level.vote_map3.x = 434;
	level.vote_map3.y = level.awe_mapvotehudoffset + 101;
	level.vote_map3.sort = 9998;	

	level.vote_map4 = newHudElem();
	level.vote_map4.archived = false;
	level.vote_map4.x = 434;
	level.vote_map4.y = level.awe_mapvotehudoffset + 117;
	level.vote_map4.sort = 9998;	

	level.vote_map5 = newHudElem();
	level.vote_map5.archived = false;
	level.vote_map5.x = 434;
	level.vote_map5.y = level.awe_mapvotehudoffset + 133;
	level.vote_map5.sort = 9998;	
}

RunMapVote()
{
	currentgt = getcvar("g_gametype");
	currentmap = getcvar("mapname");
 
       x = getRandomMapRotation();
	if(isdefined(x))
	{
		if(isdefined(x.maps))
			maps = x.maps;
		x delete();
	}

	// Any maps?
	if(!isdefined(maps))
	{
		wait 0.05;
		level notify("VotingComplete");
		return;
	}

	// Fill all alternatives with the current map in case there is not enough unique maps
	for(j=0;j<5;j++)
	{
		level.mapcandidate[j]["map"] = currentmap;
		level.mapcandidate[j]["mapname"] = "Replay this map";
		level.mapcandidate[j]["gametype"] = currentgt;
		level.mapcandidate[j]["exec"] = undefined;
		level.mapcandidate[j]["jeep"] = undefined;
		level.mapcandidate[j]["tank"] = undefined;
		level.mapcandidate[j]["votes"] = 0;
	}
	
	//get candidates
	if (!isdefined(maps) || maps.size <= 0)
		return;
	
       // Extra single shuffle is fine (optional since we sample randomly anyway)
       shuffleArray(maps);

       if(getcvarint("awe_mapvote_autopick") == 1)
       {
               idxs = sampleRandomCandidateIndices(maps, 1, currentmap, currentgt);
               if(idxs.size > 0)
               {
                       i = idxs[0];
                       level.mapcandidate[0]["map"] = maps[i]["map"];
                       level.mapcandidate[0]["mapname"] = maps\mp\gametypes\_awe::getMapName(maps[i]["map"]);
                       level.mapcandidate[0]["gametype"] = maps[i]["gametype"];
                       level.mapcandidate[0]["exec"] = maps[i]["exec"];
                       level.mapcandidate[0]["jeep"] = maps[i]["jeep"];
                       level.mapcandidate[0]["tank"] = maps[i]["tank"];
               }
               SetMapWinner(0);
               return;
       }

       // Pick 5 unique random indices, skipping current map+gt
       idxs = sampleRandomCandidateIndices(maps, 5, currentmap, currentgt);
	
	// Assign candidates
	for (j = 0; j < idxs.size; j++)
	{
		i = idxs[j];
		
		level.mapcandidate[j]["map"] = maps[i]["map"];
		level.mapcandidate[j]["mapname"] = maps\mp\gametypes\_awe::getMapName(maps[i]["map"]);
		level.mapcandidate[j]["gametype"] = maps[i]["gametype"];
		level.mapcandidate[j]["exec"] = maps[i]["exec"];
		level.mapcandidate[j]["jeep"] = maps[i]["jeep"];
		level.mapcandidate[j]["tank"] = maps[i]["tank"];
		level.mapcandidate[j]["votes"] = 0;
	}
	
	if (getcvarint("awe_map_vote_debug") == 1)
	{
		s = "Vote candidates: ";
		for (k = 0; k < 5 && isdefined(level.mapcandidate[k]); k++)
		{
			if (isdefined(level.mapcandidate[k]["map"]) && isdefined(level.mapcandidate[k]["gametype"]))
			s += level.mapcandidate[k]["map"] + "(" + level.mapcandidate[k]["gametype"] + ") ";
		}
		iprintlnbold(s);
	}
	
	thread DisplayMapChoices();
	
	game["menu_team"] = "";

	//start a voting thread per player
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] thread PlayerVote();
	
	thread VoteLogic();
	
	//Take a breath for players to restart with the map
	wait 0.1;	
	level.mapended = true;	
}

DeleteHud()
{
	level.vote_headerText destroy();
//	level.vote_hud_votestext destroy();
	level.vote_hud_timeleft destroy();	
	level.vote_hud_instructions destroy();
	level.vote_map1 destroy();
	level.vote_map2 destroy();
	level.vote_map3 destroy();
	level.vote_map4 destroy();
	level.vote_map5 destroy();
	level.vote_hud_bgnd destroy();
	level.vote_header destroy();
	level.vote_leftline destroy();
	level.vote_rightline destroy();
	level.vote_bottomline destroy();

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		if(isdefined(players[i].vote_indicator))
			players[i].vote_indicator destroy();
}

//Displays the map candidates
DisplayMapChoices()
{
	level endon("VotingDone");
	for(;;)
	{
		iprintlnbold(level.mapcandidate[0]["mapname"] + " (" + level.mapcandidate[0]["gametype"] +")");
		iprintlnbold(level.mapcandidate[1]["mapname"] + " (" + level.mapcandidate[1]["gametype"] +")");
		iprintlnbold(level.mapcandidate[2]["mapname"] + " (" + level.mapcandidate[2]["gametype"] +")");
		iprintlnbold(level.mapcandidate[3]["mapname"] + " (" + level.mapcandidate[3]["gametype"] +")");
		iprintlnbold(level.mapcandidate[4]["mapname"] + " (" + level.mapcandidate[4]["gametype"] +")");
		wait 7.8;
	}	
}

//Changes the players vote as he hits the attack button and updates HUD
PlayerVote()
{
	level endon("VotingDone");
	
	// No voting for spectators
	if(self.pers["team"] == "spectator")
		novote = true;

	// Spawn player as spectator
	self maps\mp\gametypes\_awe::spawnSpectator();
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	resettimeout();
	
	//remove the scoreboard
	self setClientCvar("g_scriptMainMenu", "");
	self closeMenu();

	self allowSpectateTeam("allies", false);
	self allowSpectateTeam("axis", false);
	self allowSpectateTeam("freelook", false);
	self allowSpectateTeam("none", true);

	if(isdefined(novote))
		return;

	self.votechoice = 0;

	colors[0] = (0  ,  0,  1);
	colors[1] = (0  ,0.5,  1);
	colors[2] = (0  ,  1,  1);
	colors[3] = (0  ,  1,0.5);
	colors[4] = (0  ,  1,  0);
	
	self.vote_indicator = newClientHudElem( self );
	self.vote_indicator.alignY = "middle";
	self.vote_indicator.x = 208;
	self.vote_indicator.y = level.awe_mapvotehudoffset + 75;
	self.vote_indicator.archived = false;
	self.vote_indicator.sort = 9998;
	self.vote_indicator.alpha = .3;
	self.vote_indicator.color = colors[0];
	self.vote_indicator setShader("white", 254, 17);
	
	for (;;)
	{
		wait .01;								
		if(self attackButtonPressed() == true)
		{
			self.votechoice++;

			if (self.votechoice == 5)
				self.votechoice = 0;

			self iprintln("You have voted for ^2" + level.mapcandidate[self.votechoice]["mapname"]);
			self.vote_indicator.y = level.awe_mapvotehudoffset + 77 + self.votechoice * 16;			
			self.vote_indicator.color = colors[self.votechoice];

			self playLocalSound("hq_score");
		}					
		while(self attackButtonPressed() == true)
			wait.01;

		self.sessionstate = "spectator";
		self.spectatorclient = -1;
	}
}

//Determines winning map and sets rotation
VoteLogic()
{
	//Vote Timer
	for (;level.awe_mapvotetime>=0;level.awe_mapvotetime--)
	{
		for(j=0;j<10;j++)
		{
			// Count votes
			for(i=0;i<5;i++)	level.mapcandidate[i]["votes"] = 0;
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
				if(isdefined(players[i].votechoice))
					level.mapcandidate[players[i].votechoice]["votes"]++;

			// Update HUD
			level.vote_map1 setValue( level.mapcandidate[0]["votes"] );
			level.vote_map2 setValue( level.mapcandidate[1]["votes"] );
			level.vote_map3 setValue( level.mapcandidate[2]["votes"] );
			level.vote_map4 setValue( level.mapcandidate[3]["votes"] );
			level.vote_map5 setValue( level.mapcandidate[4]["votes"] );
			wait .1;
		}
		level.vote_hud_timeleft setValue( level.awe_mapvotetime );
	}	

	wait 0.2;
	
	newmapnum = 0;
	topvotes = 0;
	for(i=0;i<5;i++)
	{
		if (level.mapcandidate[i]["votes"] > topvotes)
		{
			newmapnum = i;
			topvotes = level.mapcandidate[i]["votes"];
		}
	}

	SetMapWinner(newmapnum);
}

//change the map rotation to represent the current selection
SetMapWinner(winner)
{
	map		= level.mapcandidate[winner]["map"];
	mapname	= level.mapcandidate[winner]["mapname"];
	gametype	= level.mapcandidate[winner]["gametype"];
	exec		= level.mapcandidate[winner]["exec"];
	jeep		= level.mapcandidate[winner]["jeep"];
	tank		= level.mapcandidate[winner]["tank"];

	//write to cvars
	if(!isdefined(exec))
		exec = "";
	else
		exec = " exec " + exec;

	if(!isdefined(jeep))
		jeep = "";
	else
		jeep = " allow_jeeps " +jeep;

	if(!isdefined(tank))
		tank = "";
	else
		tank = " allow_tanks " + tank;	

	setcvar("sv_maprotationcurrent", exec + jeep + tank + " gametype " + gametype + " map " + map);

	wait 0.1;

	// Stop threads
	level notify( "VotingDone" );

	// Wait for threads to die
	wait 0.05;

	// Announce winner
	iprintlnbold(" ");
	iprintlnbold(" ");
	iprintlnbold(" ");
	iprintlnbold("The winner is");
	iprintlnbold("^2" + mapname);
	iprintlnbold("^2" + maps\mp\gametypes\_awe::getGametypeName(gametype));

	if(getcvarint("awe_mapvote_autopick") != 1)
	{
	// Fade HUD elements
	level.vote_headerText fadeOverTime (1);
//	level.vote_hud_votestext fadeOverTime (1);
	level.vote_hud_timeleft fadeOverTime (1);	
	level.vote_hud_instructions fadeOverTime (1);
	level.vote_map1 fadeOverTime (1);
	level.vote_map2 fadeOverTime (1);
	level.vote_map3 fadeOverTime (1);
	level.vote_map4 fadeOverTime (1);
	level.vote_map5 fadeOverTime (1);
	level.vote_hud_bgnd fadeOverTime (1);
	level.vote_header fadeOverTime (1);
	level.vote_leftline fadeOverTime (1);
	level.vote_rightline fadeOverTime (1);
	level.vote_bottomline fadeOverTime (1);

	level.vote_headerText.alpha = 0;
//	level.vote_hud_votestext.alpha = 0;
	level.vote_hud_timeleft.alpha = 0;	
	level.vote_hud_instructions.alpha = 0;
	level.vote_map1.alpha = 0;
	level.vote_map2.alpha = 0;
	level.vote_map3.alpha = 0;
	level.vote_map4.alpha = 0;
	level.vote_map5.alpha = 0;
	level.vote_hud_bgnd.alpha = 0;
	level.vote_header.alpha = 0;
	level.vote_leftline.alpha = 0;
	level.vote_rightline.alpha = 0;
	level.vote_bottomline.alpha = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].vote_indicator))
		{
			players[i].vote_indicator fadeOverTime (1);
			players[i].vote_indicator.alpha = 0;
		}
	}
	}

	// Show winning map for a few seconds
	wait 4;
	level notify( "VotingComplete" );
}

getRandomMapRotation()
{
	maprot = "";
	number = 0;	
	
	random = true;

	count = getActivePlayerCount();
	// Get maprotation if current empty or not the one we want
	if(maprot == "")
		maprot = strip(getPlayerBasedMapRotation(count));

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

        // Remove recently played maps
        history = getRotationHistory();
        if(isdefined(history))
        {
                for(h=0; h<history.size; h++)
                {
                        for(i=0; i<x.maps.size; i++)
                        {
                                if(x.maps[i]["map"] == history[h]["map"] && x.maps[i]["gametype"] == history[h]["gametype"])
                                {
                                        x.maps = removeRotationIndex(x.maps, i);
                                        i--;
                                }
                        }
                }
        }
	   count = getActivePlayerCount();
       if(x.maps.size < 5)
       {
               
               for(offset = 1; offset < 32 && x.maps.size < 5; offset++)
               {
                       rot = strip(getcvar("sv_maprotation" + (count + offset)));
                       if(rot != "")
                       {
                               addmaps = parseRotationString(rot);
                               if(isdefined(history))
                               {
                                       for(h=0; h<history.size; h++)
                                       {
                                               for(j=0; j<addmaps.size; j++)
                                               {
                                                       if(addmaps[j]["map"] == history[h]["map"] && addmaps[j]["gametype"] == history[h]["gametype"])
                                                       {
                                                               addmaps = removeRotationIndex(addmaps, j);
                                                               j--;
                                                       }
                                               }
                                       }
                               }
                               for(j=0; j<addmaps.size && x.maps.size < 5; j++)
                               {
                                       exists = false;
                                       for(k=0; k<x.maps.size; k++)
                                       {
                                               if(x.maps[k]["map"] == addmaps[j]["map"] && x.maps[k]["gametype"] == addmaps[j]["gametype"])
                                               {
                                                       exists = true;
                                                       break;
                                               }
                                       }
                                       if(!exists)
                                               x.maps[x.maps.size] = addmaps[j];
                               }
                       }

                       if(x.maps.size >= 5)
                               break;

                       below = count - offset;
                       if(below > 0)
                       {
                               rot = strip(getcvar("sv_maprotation" + below));
                               if(rot != "")
                               {
                                       addmaps = parseRotationString(rot);
                                       if(isdefined(history))
                                       {
                                               for(h=0; h<history.size; h++)
                                               {
                                                       for(j=0; j<addmaps.size; j++)
                                                       {
                                                               if(addmaps[j]["map"] == history[h]["map"] && addmaps[j]["gametype"] == history[h]["gametype"])
                                                               {
                                                                       addmaps = removeRotationIndex(addmaps, j);
                                                                       j--;
                                                               }
                                                       }
                                               }
                                       }
                                       for(j=0; j<addmaps.size && x.maps.size < 5; j++)
                                       {
                                               exists = false;
                                               for(k=0; k<x.maps.size; k++)
                                               {
                                                       if(x.maps[k]["map"] == addmaps[j]["map"] && x.maps[k]["gametype"] == addmaps[j]["gametype"])
                                                       {
                                                               exists = true;
                                                               break;
                                                       }
                                               }
                                               if(!exists)
                                                       x.maps[x.maps.size] = addmaps[j];
                                       }
                               }
                       }
               }
       }

	// Determine passes from cvar, default 3, clamp to [1..10]
	passes = getcvarint("awe_map_vote_shufflepasses");
	if (!isdefined(passes) || passes < 1) passes = 3;
	if (passes > 10) passes = 10;
	
	// Shuffle multiple times to decorrelate early PRNG states
	shuffleArrayNTimes(x.maps, passes);

	return x;
}

getActivePlayerCount()
{
	count = 0;
	
	players = getentarray("player", "classname"); 
    for(i=0;i<players.size;i++) {
		if(players[i].pers["team"] == "spectator"){
			continue;
		}
		count++;
	}
	
	return count;
	
}

getPlayerBasedMapRotation(count)
{
	if(!isDefined(count) || count <= 0)
	{
		return getcvar("sv_maprotation");
	}
	
	for(i = count; i > 0; i--)
	{
		if(getcvar("sv_maprotation" + i) == "")
		{
			continue;
		}
		return getcvar("sv_maprotation" + i);
	}
	return getcvar("sv_maprotation");
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

			return true;

		default:
			return false;
	}
}

getGametypeName(gt)
{
	switch(gt)
	{
		case "dm":
			gtname = "Deathmatch";
			break;
		
		case "tdm":
			gtname = "Team Deathmatch";
			break;

		case "sd":
			gtname = "Search & Destroy";
			break;

		case "re":
			gtname = "Retrieval";
			break;

		case "hq":
			gtname = "Headquarters";
			break;

		case "bel":
			gtname = "Behind Enemy Lines";
			break;

		case "ctf":
		case "actf":
			gtname = "Capture The Flag";
			break;

		case "dom":
			gtname = "Domination";
			break;

		case "bas":
			gtname = "Base assault";
			break;
		
		default:
			gtname = gt;
			break;
	}

       return gtname;
}

shuffleArray(arr)
{
        for(i = arr.size - 1; i > 0; i--)
        {
                j = randomInt(i + 1);  // 0..i inclusive
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
        }
                return arr;
}

// Multi-shuffle wrapper: call the existing Fisher–Yates several times.
shuffleArrayNTimes(arr, n)
{
	if (!isdefined(arr) || !isdefined(n)) return;
	if (n < 1) n = 1;
	for (p = 0; p < n; p++)
		shuffleArray(arr);
}

// Return up to 'count' distinct random indices from 'maps'.
// Skips the current (map, gt). Falls back to a non-duplicate sweep if needed.
sampleRandomCandidateIndices(maps, count, currentmap, currentgt)
{
	picked = [];
	tries = 0;
	
	if (!isdefined(maps) || maps.size <= 0)
	return picked;
	
	// Random sampling phase
	while (picked.size < count && tries < 200)
	{
		idx = randomInt(maps.size); // 0..size-1
		
		// Skip current exact (map,gt)
		if (maps[idx]["map"] == currentmap && maps[idx]["gametype"] == currentgt)
		{
			tries++;
			continue;
		}
		
		// Unique index?
		dup = false;
		for (k = 0; k < picked.size; k++)
		{
			if (picked[k] == idx) { dup = true; break; }
		}
		if (dup) { tries++; continue; }
		
		picked[picked.size] = idx;
	}
	
	// Fallback sweep to fill any remaining slots (no duplicates, still skip current)
	if (picked.size < count)
	{
		for (i = 0; i < maps.size && picked.size < count; i++)
		{
			// Skip current
			if (maps[i]["map"] == currentmap && maps[i]["gametype"] == currentgt)
			continue;
			
			// Unique?
			dup = false;
			for (k = 0; k < picked.size; k++)
			{
				if (picked[k] == i) { dup = true; break; }
			}
			if (dup) continue;
			
			picked[picked.size] = i;
		}
	}
	
	return picked;
}

removeRotationIndex(arr, index)
{
        newarr = [];
        for(i=0;i<arr.size;i++)
        {
                if(i != index)
                        newarr[newarr.size] = arr[i];
        }
        return newarr;
}

getRotationHistory()
{
        histstr = strip(getcvar("awe_map_history"));
        if(histstr == "")
                return [];

        tokens = explode(histstr, " ");
        hist = [];
        lastgt = getcvar("g_gametype");
        for(i=0;i<tokens.size;)
        {
                if(tokens[i] == "gametype" && isdefined(tokens[i+1]))
                {
                        lastgt = tokens[i+1];
                        i += 2;
                }
                else if(tokens[i] == "map" && isdefined(tokens[i+1]))
                {
                        hist[hist.size] = [];
                        hist[hist.size-1]["gametype"] = lastgt;
                        hist[hist.size-1]["map"] = tokens[i+1];
                        i += 2;
                }
                else
                        i++;
        }
        return hist;
}

buildRotationString(arr)
{
        str = "";
        for(i=0; i<arr.size; i++)
                str += " gametype " + arr[i]["gametype"] + " map " + arr[i]["map"];
        return strip(str);
}

UpdateMapHistory()
{
        size = getcvarint("awe_map_history_size");
        if(!isdefined(size) || size <= 0)
                return;

        history = getRotationHistory();

        cur["map"] = getcvar("mapname");
        cur["gametype"] = getcvar("g_gametype");

        for(i=0;i<history.size;i++)
        {
                if(history[i]["map"] == cur["map"] && history[i]["gametype"] == cur["gametype"])
                {
                        history = removeRotationIndex(history, i);
                        break;
                }
        }

        while(history.size >= size)
                history = removeRotationIndex(history, 0);

        history[history.size] = cur;

        setcvar("awe_map_history", buildRotationString(history));
}

UpdateGametypeHistory()
{
        size = getcvarint("awe_gametype_history_size");
        if(!isdefined(size) || size <= 0)
                return;

        history = getGametypeHistory();

        cur = getcvar("g_gametype");

        for(i=0;i<history.size;i++)
        {
                if(history[i] == cur)
                {
                        history = removeRotationIndex(history, i);
                        break;
                }
        }

        while(history.size >= size)
                history = removeRotationIndex(history, 0);

        history[history.size] = cur;

        setcvar("awe_gametype_history", buildGametypeString(history));
}

getGametypeHistory()
{
        histstr = strip(getcvar("awe_gametype_history"));
        if(histstr == "")
                return [];

        return explode(histstr, " ");
}

buildGametypeString(arr)
{
        str = "";
        for(i=0; i<arr.size; i++)
                str += " " + arr[i];
        return strip(str);
}

parseRotationString(rot)
{
       j = 0;
       tokens[j] = "";
       for(i=0; i<rot.size; i++)
       {
               if(rot[i] == " ")
               {
                       j++;
                       tokens[j] = "";
               }
               else
                       tokens[j] += rot[i];
       }

       arr = [];
       for(i=0; i<tokens.size; i++)
       {
               element = strip(tokens[i]);
               if(element != "")
                       arr[arr.size] = element;
       }

       maps = [];
       lastexec = undefined;
       lastjeep = undefined;
       lasttank = undefined;
       lastgt = getcvar("g_gametype");
       for(i=0; i<arr.size; )
       {
               switch(arr[i])
               {
                       case "allow_jeeps":
                               if(isdefined(arr[i+1]))
                                       lastjeep = arr[i+1];
                               i += 2;
                               break;

                       case "allow_tanks":
                               if(isdefined(arr[i+1]))
                                       lasttank = arr[i+1];
                               i += 2;
                               break;

                       case "exec":
                               if(isdefined(arr[i+1]))
                                       lastexec = arr[i+1];
                               i += 2;
                               break;

                       case "gametype":
                               if(isdefined(arr[i+1]))
                                       lastgt = arr[i+1];
                               i += 2;
                               break;

                       case "map":
                               if(isdefined(arr[i+1]))
                               {
                                       maps[maps.size]["exec"] = lastexec;
                                       maps[maps.size-1]["jeep"] = lastjeep;
                                       maps[maps.size-1]["tank"] = lasttank;
                                       maps[maps.size-1]["gametype"] = lastgt;
                                       maps[maps.size-1]["map"] = arr[i+1];
                               }
                               lastexec = undefined;
                               lastjeep = undefined;
                               lasttank = undefined;
                               lastgt = undefined;
                               i += 2;
                               break;

                       default:
                               if(isGametype(arr[i]))
                                       lastgt = arr[i];
                               else if(isConfig(arr[i]))
                                       lastexec = arr[i];
                               else
                               {
                                       maps[maps.size]["exec"] = lastexec;
                                       maps[maps.size-1]["jeep"] = lastjeep;
                                       maps[maps.size-1]["tank"] = lasttank;
                                       maps[maps.size-1]["gametype"] = lastgt;
                                       maps[maps.size-1]["map"] = arr[i];
                                       lastexec = undefined;
                                       lastjeep = undefined;
                                       lasttank = undefined;
                                       lastgt = undefined;
                               }
                               i += 1;
                               break;
               }
       }

       return maps;
}
