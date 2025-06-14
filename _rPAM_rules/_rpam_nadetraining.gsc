main()
{
	logprint(self.name + " nade_training::main()\n");
	self endon("player_disconnected");
	self thread nade_Training();
	logprint(self.name + " nade_Training self thread started\n");
	self thread mainsavepos();
	logprint(self.name + " mainsavepos self thread started\n");
	self thread _Start_Timer();
	logprint(self.name + " start_timer self thread started\n");
	logprint(self.name + " nade_training::main() end\n");
}

/// Settings for STRAT Mode Below (Do_Strat_Waring(), nade_Training())
Do_Strat_Warning()
{
	if(isdefined(level.rpam_branding))
			level.rpam_branding destroy();

	level.pamlogo = newHudElem();
	level.pamlogo.x = 630;
	level.pamlogo.y = 20;
	level.pamlogo.alignX = "right";
	level.pamlogo.alignY = "middle";
	level.pamlogo.fontScale = 1;
	level.pamlogo.color = (1, 1, 1);
	level.pamlogo setText(game["pamstring"]);

	level.pammode = newHudElem();
	level.pammode.x = 10;
	level.pammode.y = 20;
	level.pammode.alignX = "left";
	level.pammode.alignY = "middle";
	level.pammode.fontScale = 1;
	level.pammode.color = (1, 1, 1);
	level.pammode setText(game["leaguestring"]);

	level.stratstring = newHudElem();
	level.stratstring.x = 146;
	level.stratstring.y = 467;
	level.stratstring.alignX = "left";
	level.stratstring.alignY = "bottom";
	level.stratstring.fontScale = .75;
	level.stratstring.color = (1, 1, 1);
	level.stratstring setText(game["stratstring"]);

	level.stratwarning = newHudElem();
	level.stratwarning.alignX = "center";
	level.stratwarning.alignY = "bottom";
	level.stratwarning.color = (1, 1, 1);
	level.stratwarning.x = 320;
	level.stratwarning.y = 390;
	level.stratwarning.fontScale = 1.5;
	level.stratwarning setText(game["stratwarning"]);

	level.nadetraining = newHudElem();
	level.nadetraining.x = 630;
	level.nadetraining.y = 60;
	level.nadetraining.alignX = "right";
	level.nadetraining.alignY = "middle";
	level.nadetraining.fontScale = 1.1;
	level.nadetraining.color = (1, 1, 1);
	level.nadetraining setText(game["nadetraining"]);

	//PLEASE LEAVE BE. TOOK A LOT OF WORK ON MAKING THIS TRAINER
	level.anglhz = newHudElem();
	level.anglhz.x = 630;
	level.anglhz.y = 75;
	level.anglhz.alignX = "right";
	level.anglhz.alignY = "middle";
	level.anglhz.fontScale = 0.55;
	level.anglhz.color = (1, 1, 1);
	level.anglhz setText(game["anglhz"]);

	level.enablefollow = newHudElem();
	level.enablefollow.x = 630;
	level.enablefollow.y = 90;
	level.enablefollow.alignX = "right";
	level.enablefollow.alignY = "middle";
	level.enablefollow.fontScale = .80;
	level.enablefollow.color = (1, 1, 1);
	level.enablefollow setText(game["enablefollow"]);

	level.stopfollow = newHudElem();
	level.stopfollow.x = 630;
	level.stopfollow.y = 110;
	level.stopfollow.alignX = "right";
	level.stopfollow.alignY = "middle";
	level.stopfollow.fontScale = .80;
	level.stopfollow.color = (1, 1, 1);
	level.stopfollow setText(game["stopfollow"]);

	level.position = newHudElem();
	level.position.x = 630;
	level.position.y = 130;
	level.position.alignX = "right";
	level.position.alignY = "middle";
	level.position.fontScale = 1.1;
	level.position.color = (1, 1, 1);
	level.position setText(game["position"]);

	level.positionsave = newHudElem();
	level.positionsave.x = 630;
	level.positionsave.y = 150;
	level.positionsave.alignX = "right";
	level.positionsave.alignY = "middle";
	level.positionsave.fontScale = .80;
	level.positionsave.color = (1, 1, 1);
	level.positionsave setText(game["positionsave"]);
	
	level.positionload = newHudElem(self);
	level.positionload.x = 630;
	level.positionload.y = 170;
	level.positionload.alignX = "right";
	level.positionload.alignY = "middle";
	level.positionload.fontScale = .80;
	level.positionload.color = (1, 1, 1);
	level.positionload setText(game["positionload"]);

	level.strattimer = newHudElem();
	level.strattimer.x = 630;
	level.strattimer.y = 190;
	level.strattimer.alignX = "right";
	level.strattimer.alignY = "middle";
	level.strattimer.fontScale = 1.1;
	level.strattimer.color = (1, 1, 1);
	level.strattimer setText(game["strattimer"]);

	level.strattimerdir = newHudElem(self);
	level.strattimerdir.x = 630;
	level.strattimerdir.y = 210;
	level.strattimerdir.alignX = "right";
	level.strattimerdir.alignY = "middle";
	level.strattimerdir.fontScale = .80;
	level.strattimerdir.color = (1, 1, 1);
	level.strattimerdir setText(game["strattimerdir"]);
}

nade_Training()
/* Nade Training updated 2024-03-25 */
/* Added smoke compability for UO */
{
    //logprint(self.name + " nade_training ingress\n");
    while (self.sessionstate == "playing") {
        level.nade_count = self getWeaponSlotAmmo("grenade");
        level.smoke_nade_count = self getWeaponSlotAmmo("smokegrenade");
		self setWeaponSlotAmmo("grenade", 999);
        self setWeaponSlotAmmo("smokegrenade", 999);
        
        while ((level.nade_count == self getWeaponSlotAmmo("grenade") && level.smoke_nade_count == self getWeaponSlotAmmo("smokegrenade")) && self.sessionstate == "playing") {
            wait 0.05;
        }

        if (self.sessionstate != "playing") {
            //logprint(self.name + " nade_count has changed but sessionstate is not playing: " + self.sessionstate + "\n");
            return;
        }

        self setWeaponSlotAmmo("grenade", 999);
        self setWeaponSlotAmmo("smokegrenade", 999);

        if (self meleeButtonPressed() == false) {
            continue;
        }

        level.nade = undefined;
        nades = getEntArray("grenade", "classname");
        for (i = 0; i < nades.size; i++) {
            if (distanceSquared(nades[i].origin, self.origin) < 100*100) {
                level.nade = nades[i];
                break;
            }
        }

        if (!isDefined(level.nade)) {
            continue;
        }

        if (self isOnGround() == false) {
            gap = bulletTrace(self.origin, self.origin + (0, 0, -100), false, undefined)["fraction"] * 100;
        } else {
            gap = 0;
        }
        
        saved_angles = self.angles;
        saved_origin = self.origin;

        self disableWeapon();

        m = spawn("script_model", self.origin);
        m.angles = self.angles;
        m linkTo(level.nade);

        self setOrigin(m.origin);
        self linkTo(m);
        self iprintln(level._prefix + "Following Nade" + level._p_color + "...");

        while (isDefined(level.nade) && self AttackButtonPressed() == false && self.sessionstate == "playing") {
            wait 0.05;
        }
        
        m unlink();
        m moveTo(saved_origin,0.1);
        wait 0.5;
        self unlink();
        self enableWeapon();
        if (isDefined(m)) 
        {
            m delete();
        }
    }
    //logprint(self.name + " nade_training egress\n");
}

/*
    This is ripped from Lev's 1.5 jump save mod.
    I take no credit for any of this -- it was just
    quicker than writing my own.
*/

mainsavepos()
{
	logprint(self.name + " mainsaveposs ingress\n");
	self thread _MeleeKey();
	self thread _UseKey();
	
	self endon("end_saveposition_threads");
	{
		wait 1;

		self iprintln(level._prefix + "Press^3 [{+melee}] ^7twice to save position^3.");
		wait 3;
		self iprintln(level._prefix + "Press^3 [{+activate}] ^7twice to load saved position^3.");
	}
	logprint(self.name + " mainsaveposs egress\n");
}
_MeleeKey()
{
	logprint(self.name + " meleekey ingress\n");
	self endon("end_saveposition_threads");
	self endon("spawned");

	for(;;)
	{
		if(self meleeButtonPressed())
		{
			catch_next = false;

			for(i=0; i<=0.30; i+=0.01)
			{
				if(catch_next && self meleeButtonPressed() && self isOnGround())
				{
					self thread savePos();
					wait 1;
					break;
				}
				else if(!(self meleeButtonPressed()))
					catch_next = true;

				wait 0.01;
			}
		}

		wait 0.05;
	}
	logprint(self.name + " meleekey egress\n");
}

_UseKey()
{
	logprint(self.name + " usekey ingress\n");
	self endon("end_saveposition_threads");
	self endon("spawned");

	for(;;)
	{
		if(self useButtonPressed())
		{
			catch_next = false;

			for(i=0; i<=0.30; i+=0.01)
			{
				if(catch_next && self useButtonPressed())
				{
					self thread checksave();
					wait 1;
					break;
				}
				else if(!(self useButtonPressed()))
					catch_next = true;

				wait 0.01;
			}
		}

		wait 0.05;
	}
	logprint(self.name + " usekey egress\n");
}
savePos()
{
	self.saved_origin = self.origin;
	self.saved_angles = self.angles;
	self iprintln(level._prefix + "Position ^3(^7" + (int)self.saved_origin[0] + "^7, ^7" + (int)self.saved_origin[1] + "^7, ^7" + (int)self.saved_origin[2] + "^3)^7 saved^3.");
}

checksave()
{		
	loadPos();
}

loadPos()
{
	if(!isDefined(self.saved_origin))
		{
		self iprintln(level._prefix + "There is no previous position to load^7.");
		return;
		}
	else
		{
		self setPlayerAngles(self.saved_angles); // angles need to come first
		self setOrigin(self.saved_origin);
		self iprintln(level._prefix + "Previous position ^3(^7" + (int)self.saved_origin[0] + "^7, ^7" + (int)self.saved_origin[1] + "^7, ^7" + (int)self.saved_origin[2] + "^3)^7 loaded^3.");
		}
}

loadPossave()
{
	thread positions();
	if(!isDefined(self.saved_origin))
	{
		self iprintln(level._prefix + "There is no previous position to load^3.");
		return;
	}
	else
		if(self positions(70))
			{
			self iprintlnbold(level._prefix + "A player is currently standing on that location^3!");
			self iprintlnbold(level._prefix + "Try again in a few sec^3...");
			return;
			}

		else
			{
			self setPlayerAngles(self.saved_angles); // angles need to come first
			self setOrigin(self.saved_origin);
			self iprintln(level._prefix + "Previous position ^3(^7" + (int)self.saved_origin[0] + "^7, ^7" + (int)self.saved_origin[1] + "^7, ^7" + (int)self.saved_origin[2] + "^3)^7 loaded^3.");
			}
}

positions(range)
{
	if(!range)
		return true;

	// Get all players and pick out the ones that are playing
	allplayers = getentarray("player", "classname");
	players = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing")
			players[players.size] = allplayers[i];
	}

	// Get the players that are in range
	sortedplayers = sortByDist(players, self);

	// Need at least 2 players (myself + one team mate)
	if(sortedplayers.size<2)
		return false;

	// First player will be myself so check against second player
	distance = distance(self.saved_origin, sortedplayers[1].origin);
	if( distance <= range )
		return true;
	else
		return false;
}

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

/*_Start_Timer()
{
	if (self.sessionstate != "playing") {
            return;
	}

	if(catch_next && self meleeButtonPressed() && self isOnGround())
		self thread Create_Personal_Timer();
}*/
_Start_Timer()
{
	logprint(self.name + " start_timer ingress\n");
	self endon("disconnect");
	self endon("killed_player");
	self endon("spawned");
	if(self.sessionstate != "playing"){
		return;
	}
	while(self usebuttonpressed())
		wait 0.05;
	while(true)
	{
		while(!self usebuttonpressed())
			 wait 3;
		if(self.sessionstate == "playing")
		{
			self iprintln(level._prefix + "Starting Timer^3...");
			self Create_Personal_Timer();
			while(self usebuttonpressed())
				wait 0.05;
		}
		else
		{
			return;
		}
	}
	logprint(self.name + " start_timer egress\n");
}

Create_Personal_Timer()
{
	if(isdefined(self.timecountdown))
		self.timecountdown destroy();
	
	self.timecountdown = newClientHudElem( self );
	self.timecountdown.archived = false;
	self.timecountdown.x = 630;
	self.timecountdown.y = 230;
	self.timecountdown.alignX = "right";
	self.timecountdown.alignY = "middle";
	self.timecountdown.font = "bigfixed";
	self.timecountdown.fontScale = 1;
	self.timecountdown.color = (1, 1, 0);
	self.timecountdown setTimer(level.roundlength * 60);
	
}

/*nade_countdown()
{
	if(isdefined(level.nade_countdown))
		level.nade_countdown destroy();

	while (self.sessionstate == "playing") {
        nade_count = self getWeaponSlotAmmo("grenade");

        while (nade_count == self getWeaponSlotAmmo("grenade") && self.sessionstate == "playing") {
            wait 0.05;
        }

        if (self.sessionstate != "playing") {
            return;

		level.nade_countdown = newHudElem();
		level.nade_countdown .x = 630;
		level.nade_countdown .y = 235;
		level.nade_countdown .alignX = "right";
		level.nade_countdown .alignY = "middle";
		level.nade_countdown .font = "bigfixed";
		level.nade_countdown.fontScale = 1;
		level.nade_countdown.color = (1, 1, 0);
		level.nade_countdown setTimer(5);

		//wait level.nade_countdown(timer);
		if(isdefined(level.nade_countdown))
			level.nade_countdown destroy();
	}
}*/