corrupt_StartGameType()
{
	precacheString(&"WINNING KILLCAM");
	//precacheString(&"Powered By corrupt"); Original String
	precacheString(&"Powered By corrupt. Perfected by ^1~^3empire");
	precacheShader("black");
	setarchive(true);
	
	game["doFinalKillcam"] = getCvar("scr_final_killcam");
}

corrupt_killcam(attackerNum, delay)
{
	self endon("spawned");
	
	// killcam
	if(attackerNum < 0)
		return;

	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.archivetime = delay + 7;
	
	extradelay = delay - 2;

	maps\mp\gametypes\_teams::SetKillcamSpectatePermissions();

	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait 0.05;

	if(self.archivetime <= delay)
	{
		self.spectatorclient = -1;
		self.archivetime = 0;
	
		maps\mp\gametypes\_teams::SetSpectatePermissions();
		return;
	}

	self.killcam = true;

	if(!isDefined(self.corrupt_topbar))
	{
		self.corrupt_topbar = newClientHudElem(self);
		self.corrupt_topbar.archived = false;
		self.corrupt_topbar.x = 0;
		self.corrupt_topbar.y = 0;
		self.corrupt_topbar.alpha = 0.5;
		self.corrupt_topbar setShader("black", 640, 112);
	}

	if(!isDefined(self.corrupt_bottombar))
	{
		self.corrupt_bottombar = newClientHudElem(self);
		self.corrupt_bottombar.archived = false;
		self.corrupt_bottombar.x = 0;
		self.corrupt_bottombar.y = 368;
		self.corrupt_bottombar.alpha = 0.5;
		self.corrupt_bottombar setShader("black", 640, 112);
	}

	if(!isDefined(self.corrupt_title))
	{
		self.corrupt_title = newClientHudElem(self);
		self.corrupt_title.archived = false;
		self.corrupt_title.x = 320;
		self.corrupt_title.y = 40;
		self.corrupt_title.alignX = "center";
		self.corrupt_title.alignY = "middle";
		self.corrupt_title.sort = 1; // force to draw after the bars
		self.corrupt_title.fontScale = 3.5;
	}
	self.corrupt_title setText(&"WINNING KILLCAM");
/* ORIGINAL SETTINGS 
	if(!isDefined(self.corrupt_powertext))
	{
		self.corrupt_powertext = newClientHudElem(self);
		self.corrupt_powertext.archived = false;
		self.corrupt_powertext.x = 320;
		self.corrupt_powertext.y = 70;
		self.corrupt_powertext.alignX = "center";
		self.corrupt_powertext.alignY = "middle";
		self.corrupt_powertext.sort = 1; // force to draw after the bars
	}
	self.corrupt_powertext setText(&"Powered By corrupt");
*/
	if(!isDefined(self.corrupt_powertext))
	{
		self.corrupt_powertext = newClientHudElem(self);
		self.corrupt_powertext.archived = false;
		self.corrupt_powertext.x = 638;
		self.corrupt_powertext.y = 106;
		self.corrupt_powertext.alignX = "right";
		self.corrupt_powertext.alignY = "middle";
		self.corrupt_powertext.sort = 1; // force to draw after the bars
		self.corrupt_powertext.fontScale = .8;
	}
	self.corrupt_powertext setText(&"Powered By corrupt. Perfected by ^1~^3empire");
	if(!isDefined(self.corrupt_timer))
	{
		self.corrupt_timer = newClientHudElem(self);
		self.corrupt_timer.archived = false;
		self.corrupt_timer.x = 320;
		self.corrupt_timer.y = 428;
		self.corrupt_timer.alignX = "center";
		self.corrupt_timer.alignY = "middle";
		self.corrupt_timer.fontScale = 3.5;
		self.corrupt_timer.sort = 1;
	}
	self.corrupt_timer setTenthsTimer(self.archivetime - delay);

	self thread corrupt_spawnedKillcamCleanup();
	self thread corrupt_waitKillcamTime(extradelay);
	/*
	if(getCvar("dedicated") == 0)
	{
		wait slowmo;
		self setClientCvar("timescale", "0.5");
		wait self.archivetime - slowmo - 0.5;
		self setClientCvar("timescale", "1");
	}
	*/

	self waittill("corrupt_killcam");
	
	self corrupt_removeKillcamElements();

	self.spectatorclient = -1;
	self.archivetime = 0;
	self.killcam = undefined;
	
	maps\mp\gametypes\_teams::SetSpectatePermissions();
	
}

corrupt_waitKillcamTime(extradelay)
{
	self endon("corrupt_killcam");
	
	wait(self.archivetime - extradelay - 0.05);
	self notify("corrupt_killcam");
}

corrupt_removeKillcamElements()
{
	if(isDefined(self.corrupt_topbar))
		self.corrupt_topbar destroy();
	if(isDefined(self.corrupt_bottombar))
		self.corrupt_bottombar destroy();
	if(isDefined(self.corrupt_title))
		self.corrupt_title destroy();
	if(isDefined(self.corrupt_powertext))
		self.corrupt_powertext destroy();
	if(isDefined(self.corrupt_timer))
		self.corrupt_timer destroy();
}

corrupt_spawnedKillcamCleanup()
{
	self endon("corrupt_killcam");

	self waittill("spawned");
	self corrupt_removeKillcamElements();
}