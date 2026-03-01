//***********************************************************************************************************
// MAP VOTE PACKAGE
// ORIGINALLY MADE BY NC-17 (codam, powerserver), REWORKED BY wizard220, MODIFIED BY FrAnCkY55, Modified again by bell
//***********************************************************************************************************

Initialise()
{
	if(!level.awe_mapvote) return;

	// Small wait
	wait .5;

	// Cleanup some stuff to free up some resources
	CleanUp();

	// Start automatic next-map selection thread
	thread RunMapVote();

	// Wait for selection to finish
	level waittill("VotingComplete");
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
	history = getRotationHistory();
	gthistory = getGametypeHistory();
 
       x = getRandomMapRotation();
	if(isdefined(x))
	{
		if(isdefined(x.maps))
			maps = x.maps;
		x delete();
	}

	if(isdefined(maps))
		maps = buildCandidatePool(maps, currentmap, currentgt, history, gthistory, 5);

	// Any maps?
	if(!isdefined(maps))
	{
		wait 0.05;
		// Keep end-of-round state consistent with normal vote completion.
		level.mapended = true;
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
	i = 0;
	for(j=0;j<5;j++)
	{
		// Skip current map and gametype combination
		if(maps[i]["map"] == currentmap && maps[i]["gametype"] == currentgt)
			i++;

		// Any maps left?
		if(!isdefined(maps[i]))
			break;

		level.mapcandidate[j]["map"] = maps[i]["map"];
		level.mapcandidate[j]["mapname"] = maps\mp\gametypes\_awe::getMapName(maps[i]["map"]);
		level.mapcandidate[j]["gametype"] = maps[i]["gametype"];
		level.mapcandidate[j]["exec"] = maps[i]["exec"];
		level.mapcandidate[j]["jeep"] = maps[i]["jeep"];
		level.mapcandidate[j]["tank"] = maps[i]["tank"];
		level.mapcandidate[j]["votes"] = 0;

		i++;

		// Any maps left?
		if(!isdefined(maps[i]))
			break;

		// Keep current map as last alternative?
		if(level.awe_mapvotereplay && j>2)
			break;
	}
	
	newmapnum = getBestCandidateIndex(currentmap, currentgt);

	SetMapWinner(newmapnum);

	//Take a breath for players to restart with the map
	wait 0.1;
	level.mapended = true;
}

getBestCandidateIndex(currentmap, currentgt)
{
	history = getRotationHistory();
	gthistory = getGametypeHistory();

	bestindex = 0;
	bestscore = -9999;

	for(i=0;i<5;i++)
	{
		// Avoid replaying current map+gametype unless no alternative exists
		if(level.mapcandidate[i]["map"] == currentmap && level.mapcandidate[i]["gametype"] == currentgt)
			score = -500;
		else
			score = 100;

		score -= getMapHistoryPenalty(level.mapcandidate[i]["map"], level.mapcandidate[i]["gametype"], history);
		score -= getMapCooldownPenalty(level.mapcandidate[i]["map"], history);
		score -= getMapFrequencyPenalty(level.mapcandidate[i]["map"], history);
		score -= getScaledGametypePenalty(level.mapcandidate[i]["gametype"], gthistory);
		score += randomInt(7); // Keep selection non-deterministic when scores tie

		if(score > bestscore)
		{
			bestscore = score;
			bestindex = i;
		}
	}

	return bestindex;
}

buildCandidatePool(maps, currentmap, currentgt, history, gthistory, targetsize)
{
	if(!isdefined(maps) || maps.size <= targetsize)
		return maps;

	for(i=0; i<maps.size; i++)
	{
		maps[i]["score"] = getCandidateScore(maps[i], currentmap, currentgt, history, gthistory);
	}

	for(i=0; i<maps.size-1; i++)
	{
		best = i;
		for(j=i+1; j<maps.size; j++)
		{
			if(maps[j]["score"] > maps[best]["score"])
				best = j;
		}

		if(best != i)
		{
			temp = maps[i];
			maps[i] = maps[best];
			maps[best] = temp;
		}
	}

	selected = [];
	for(i=0; i<maps.size && selected.size < targetsize; i++)
	{
		selected[selected.size] = maps[i];
	}

	return shuffleArray(selected);
}

getCandidateScore(entry, currentmap, currentgt, history, gthistory)
{
	if(entry["map"] == currentmap && entry["gametype"] == currentgt)
		score = -500;
	else
		score = 100;

	score -= getMapHistoryPenalty(entry["map"], entry["gametype"], history);
	score -= getMapCooldownPenalty(entry["map"], history);
	score -= getMapFrequencyPenalty(entry["map"], history);
	score -= getScaledGametypePenalty(entry["gametype"], gthistory);
	score += randomInt(5);

	return score;
}

getMapHistoryPenalty(map, gametype, history)
{
	if(!isdefined(history) || history.size <= 0)
		return 0;

	for(i=history.size-1;i>=0;i--)
	{
		if(history[i]["map"] == map && history[i]["gametype"] == gametype)
		{
			recency = history.size - i;
			return (history.size - recency + 1) * 25;
		}
	}

	return 0;
}

getGametypeHistoryPenalty(gametype, gthistory)
{
	if(!isdefined(gthistory) || gthistory.size <= 0)
		return 0;

	for(i=gthistory.size-1;i>=0;i--)
	{
		if(gthistory[i] == gametype)
		{
			recency = gthistory.size - i;
			return (gthistory.size - recency + 1) * 10;
		}
	}

	return 0;
}

getScaledGametypePenalty(gametype, gthistory)
{
	scale = getcvarint("awe_gametype_penalty_scale");
	if(!isdefined(scale) || scale <= 0)
		scale = 100;

	penalty = getGametypeHistoryPenalty(gametype, gthistory);
	return (penalty * scale) / 100;
}

getMapCooldownPenalty(map, history)
{
	window = getcvarint("awe_map_cooldown_window");
	if(!isdefined(window) || window <= 0)
		window = 8;

	base = getcvarint("awe_map_cooldown_penalty");
	if(!isdefined(base) || base <= 0)
		base = 20;

	if(!isdefined(history) || history.size <= 0)
		return 0;

	penalty = 0;
	for(i=history.size-1; i>=0; i--)
	{
		recency = history.size - i;
		if(recency > window)
			break;

		if(history[i]["map"] == map)
		{
			step = window - recency + 1;
			penalty += (base * step) / window;
		}
	}

	return penalty;
}

getMapFrequencyPenalty(map, history)
{
	window = getcvarint("awe_map_frequency_window");
	if(!isdefined(window) || window <= 0)
		window = 16;

	scale = getcvarint("awe_map_frequency_penalty");
	if(!isdefined(scale) || scale <= 0)
		scale = 14;

	if(!isdefined(history) || history.size <= 0)
		return 0;

	start = history.size - window;
	if(start < 0)
		start = 0;

	counts = 0;
	entries = 0;
	for(i=start; i<history.size; i++)
	{
		entries++;
		if(history[i]["map"] == map)
			counts++;
	}

	if(entries <= 0)
		return 0;

	return (counts * scale * 10) / entries;
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

	level notify( "VotingComplete" );
}

getRandomMapRotation()
{
	baseRotation = strip(getcvar("sv_maprotation"));
	poolRotation = getMapRotationPool();

	if(baseRotation == "" && poolRotation == "")
		return undefined;

	x = spawn("script_origin",(0,0,0));
	history = getRotationHistory();
	count = getActivePlayerCount();

	poolmaps = parseRotationPoolString(poolRotation);
	poolmaps = mergeRotationCandidates([], poolmaps, history, false);
	basemaps = parseRotationString(baseRotation);
	poolmaps = mergeRotationCandidates(poolmaps, basemaps, history, false);

	// Never offer recently played maps, regardless of gametype.
	poolmaps = filterMapsByHistory(poolmaps, history);
	if(poolmaps.size <= 0)
	{
		x.maps = [];
		return x;
	}

	prevCount = getcvarint("awe_prev_player_count");
	if(!isdefined(prevCount))
		prevCount = count;
	trend = clampInt(count - prevCount, -4, 4);

	x.maps = rankPoolByPopulation(poolmaps, count, trend, getCandidatePoolSize());

	setcvar("awe_prev_player_count", "" + count);

	return x;
}

getMapRotationPool()
{
	poolRotation = strip(getcvar("sv_maprotationpool"));
	index = 0;
	emptyStreak = 0;

	while(emptyStreak < 2)
	{
		namedRotation = strip(getcvar("svmaprotation" + index));
		legacyRotation = strip(getcvar("sv_maprotation" + index));

		found = false;

		if(namedRotation != "")
		{
			poolRotation = strip(poolRotation + " " + namedRotation);
			found = true;
		}

		if(legacyRotation != "")
		{
			poolRotation = strip(poolRotation + " " + legacyRotation);
			found = true;
		}

		if(found)
			emptyStreak = 0;
		else
			emptyStreak++;

		index++;
	}

	return poolRotation;
}

rankPoolByPopulation(poolmaps, count, trend, targetsize)
{
	ranked = [];
	local = [];

	for(i=0; i<poolmaps.size; i++)
		local[local.size] = poolmaps[i];

	while(local.size > 0 && ranked.size < targetsize)
	{
		winner = 0;
		winnerscore = -99999;
		for(i=0; i<local.size; i++)
		{
			score = getPoolEntryScore(local[i], count, trend);
			if(score > winnerscore)
			{
				winnerscore = score;
				winner = i;
			}
		}

		ranked[ranked.size] = local[winner];
		local = removeRotationIndex(local, winner);
	}

	return ranked;
}

getPoolEntryScore(entry, count, trend)
{
	minsize = getPoolInt(entry, "minsize", 0);
	maxsize = getPoolInt(entry, "maxsize", 64);

	if(maxsize < minsize)
	{
		tmp = minsize;
		minsize = maxsize;
		maxsize = tmp;
	}

	target = clampInt(count + trend, 0, 64);
	distTarget = distanceToRange(target, minsize, maxsize);
	distCurrent = distanceToRange(count, minsize, maxsize);

	score = 120;
	score -= distTarget * 14;
	score -= distCurrent * 8;
	score += randomInt(35);

	return score;
}

distanceToRange(value, minvalue, maxvalue)
{
	if(value < minvalue)
		return minvalue - value;

	if(value > maxvalue)
		return value - maxvalue;

	return 0;
}

clampInt(value, minvalue, maxvalue)
{
	if(value < minvalue)
		return minvalue;
	if(value > maxvalue)
		return maxvalue;
	return value;
}

parseRotationPoolString(rot)
{
	maps = parseRotationString(rot);
	tokens = explode(strip(rot), " ");

	if(!isdefined(maps) || maps.size <= 0)
		return [];

	mapindex = 0;
	for(i=0; i<tokens.size && mapindex < maps.size; i++)
	{
		if(tokens[i] == "map" && isdefined(tokens[i+1]))
		{
			maps[mapindex]["minsize"] = 0;
			maps[mapindex]["maxsize"] = 64;
			i += 2;
			while(i < tokens.size)
			{
				if(tokens[i] == "minsize" && isdefined(tokens[i+1]))
				{
					maps[mapindex]["minsize"] = (int)tokens[i+1];
					i += 2;
					continue;
				}

				if(tokens[i] == "maxsize" && isdefined(tokens[i+1]))
				{
					maps[mapindex]["maxsize"] = (int)tokens[i+1];
					i += 2;
					continue;
				}

				if(tokens[i] == "map" || tokens[i] == "gametype" || tokens[i] == "exec" || tokens[i] == "allow_jeeps" || tokens[i] == "allow_tanks")
				{
					i--;
					break;
				}

				i++;
			}

			mapindex++;
		}
	}

	return maps;
}

mergeRotationCandidates(basemaps, addmaps, history, applyhistory)
{
	for(j=0; j<addmaps.size; j++)
	{
		if(applyhistory && isMapBlockedByHistory(addmaps[j], history))
			continue;

		exists = false;
		for(k=0; k<basemaps.size; k++)
		{
			if(basemaps[k]["map"] == addmaps[j]["map"] && basemaps[k]["gametype"] == addmaps[j]["gametype"])
			{
				exists = true;
				break;
			}
		}

		if(!exists)
		{
			if(!isdefined(addmaps[j]["minsize"]))
				addmaps[j]["minsize"] = 0;
			if(!isdefined(addmaps[j]["maxsize"]))
				addmaps[j]["maxsize"] = 64;
			basemaps[basemaps.size] = addmaps[j];
		}
	}

	return basemaps;
}

getCandidatePoolSize()
{
	size = getcvarint("awe_map_candidate_pool_size");
	if(!isdefined(size) || size <= 0)
		size = 10;

	if(size < 5)
		size = 5;
	if(size > 12)
		size = 12;

	return size;
}

isMapBlockedByHistory(mapentry, history)
{
	if(!isdefined(history) || history.size <= 0)
		return false;

	for(h=0; h<history.size; h++)
	{
		if(mapentry["map"] == history[h]["map"])
			return true;
	}

	return false;
}

filterMapsByHistory(maps, history)
{
	if(!isdefined(maps) || maps.size <= 0)
		return maps;

	if(!isdefined(history) || history.size <= 0)
		return maps;

	filtered = [];
	for(i=0; i<maps.size; i++)
	{
		if(!isMapBlockedByHistory(maps[i], history))
			filtered[filtered.size] = maps[i];
	}

	return filtered;
}


getActivePlayerCount()
{
	count = 0;
	
	players = getentarray("player", "classname"); 
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i]))
		{
			continue;
		}

		if(!isdefined(players[i].pers) || !isdefined(players[i].pers["team"]) || players[i].pers["team"] == "")
		{
			continue;
		}

		if(isdefined(players[i].sessionstate) && players[i].sessionstate != "playing")
		{
			continue;
		}

		if(players[i].pers["team"] == "spectator")
		{
			continue;
		}

		count++;
	}
	
	return count;
	
}

getPoolInt(entry, key, fallback)
{
	if(!isdefined(entry[key]))
		return fallback;

	return (int)entry[key];
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
