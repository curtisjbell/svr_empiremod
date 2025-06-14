onConnected()
{
	self endon("disconnect");

	self.round_report_array = [];
	self.round_report_myKill = undefined;

	/*
	self.round_report_debug = [];

	// Set default value
	if (!isDefined(self.pers["round_report_debug_init"]))
	{
		logprint("_round_report::onConnected set round_report_debug_init before\n");
		wait 1 * 5;
		self setClientCvarIfChanged("pam_damage_debug", "");
		self setClientCvarIfChanged("pam_damage_debug2", "");
		self setClientCvarIfChanged("pam_damage_debug3", "");
		self setClientCvarIfChanged("pam_damage_debug4", "");
		self.pers["round_report_debug_init"] = true;
		logprint("_round_report::onConnected set round_report_debug_init after\n");
	}
	*/
}

/*
Called when player has taken damage.
self is the player that took damage.
*/
onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	//logprint("_round_report::onPlayerDamaged ingress\n");
	
	if(iDamage < 1) {
		iDamage = 1;
	}
	
	if (isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self && level.roundstarted && !level.roundended)
	{
		//logprint("_round_report::onPlayerDamaged eAttacker is defined and round in progress\n");
		updateIndex = -1;
		for (i = eAttacker.round_report_array.size-1; i >= 0; i--)
		{
			lastRecord = eAttacker.round_report_array[i];

			timeAgo = gettime() - lastRecord.time;

			if (timeAgo > 5000) break; // look only for hits in last 5 sec

			// Find record with the same guy
			if (isDefined(lastRecord.enemy) && lastRecord.enemy == self)
			{
				// Shotgun hits (with different time) save as separated records
				//if (lastRecord.sWeapon == "shotgun_mp" && lastRecord.firstTime != gettime())
					//continue;

				// Grenade hits save as separated records
				if (lastRecord.sMeansOfDeath == "MOD_GRENADE_SPLASH") {
					logprint("Grenade hit found\n");
					continue;
				}

				updateIndex = i;
				break;
			}
		}

		/*
		// Debug information
		if (sMeansOfDeath == "MOD_RIFLE_BULLET" || sWeapon == "shotgun_mp" || sMeansOfDeath == "MOD_GRENADE_SPLASH")
		{
			xyz_hit = "?";
			if (isDefined(vPoint)) xyz_hit = vPoint;

			damageDebug = getTimeString(gettime(), level.bombplanted) +
				"|" + gettime() +
				"|dmg:" + (int)((iDamage*10)/10) +
				"|health:" + self.health +
				"|xyz_my:" + eAttacker.origin +
				"|xyz_enemy:" + self.origin +
				//"|dist:" + distance(eAttacker.origin, self.origin) +
				"|" + sWeapon +
				"|" + sHitLoc +
				"|xyz_hit:" + xyz_hit //+
				//"|head:" + self.headTag getOrigin() +
				//"|pelvis:" + self.pelvisTag getOrigin()
				;

			eAttacker.round_report_debug[eAttacker.round_report_debug.size] = damageDebug;
		}
		*/

		// Update previus record
		if (updateIndex != -1)
		{
			//eAttacker iprintln("update damage " + updateIndex);
			eAttacker.round_report_array[updateIndex].hitLoc = sHitLoc;
			eAttacker.round_report_array[updateIndex].sMeansOfDeath = sMeansOfDeath;
			eAttacker.round_report_array[updateIndex].sWeapon = sWeapon;
			eAttacker.round_report_array[updateIndex].bombPlanted = level.bombplanted;
			eAttacker.round_report_array[updateIndex].time = gettime();

			// Hits that came in same time (shotgun) count together
			if (eAttacker.round_report_array[updateIndex].firstTime == gettime())
			{
				eAttacker.round_report_array[updateIndex].firstDamageValue += iDamage;
				//eAttacker.round_report_array[updateIndex].pellets++;
			}
			else
			{
				eAttacker.round_report_array[updateIndex].multipleDamage = true; // different time, it means its second shot
			}

		}
		// Add new record
		else
		{
			//eAttacker iprintln("add new damage to " + eAttacker.round_report_array.size);
			lastDamage = spawnstruct();
			lastDamage.enemy = self;
			lastDamage.hitLoc = sHitLoc;
			lastDamage.sMeansOfDeath = sMeansOfDeath;
			lastDamage.sWeapon = sWeapon;
			lastDamage.firstHitLoc = sHitLoc;
			lastDamage.sFirstMeansOfDeath = sMeansOfDeath;
			lastDamage.sFirstWeapon = sWeapon;
			lastDamage.firstDamageValue = iDamage;
			lastDamage.multipleDamage = false;
			//lastDamage.pellets = 1;
			lastDamage.wasKilled = false;
			lastDamage.teamkill = (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]);
			lastDamage.bombPlanted = level.bombplanted;
			//lastDamage.adjustedBy = eAttacker.hitData[self getEntityNumber()].adjustedBy;
			//lastDamage.shotgun_distance = eAttacker.hitData[self getEntityNumber()].shotgun_distance;
			lastDamage.time = gettime();
			lastDamage.firstTime = gettime();

			eAttacker.round_report_array[eAttacker.round_report_array.size] = lastDamage;
		}

		//eAttacker printDebug();
		//logprint("_round_report::onPlayerDamaged egress\n");
	}
}

onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	//logprint("_round_report::onPlayerKilled ingress\n");
	if (isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self && level.roundstarted && !level.roundended)
	{
		// Remove this player if was hited 5 sec before
		for (i = eAttacker.round_report_array.size-1; i >= 0; i--)
		{
			if (isDefined(eAttacker.round_report_array[i].enemy) && eAttacker.round_report_array[i].enemy == self && (eAttacker.round_report_array[i].time + 5000) > gettime())
			{
				// Set as kill
				eAttacker.round_report_array[i].wasKilled = true;
				eAttacker.round_report_array[i].sWeapon = sWeapon; // update also weapon, because its different when using MG
				break;
			}
		}

		//eAttacker printDebug();
	}

	// If there was some hits/kills in this round, add also my death info
	if (self.round_report_array.size > 0)
	{
		myKill = spawnstruct();

		myKill.hitLoc = sHitLoc;
		myKill.sMeansOfDeath = sMeansOfDeath;
		myKill.sWeapon = sWeapon;
		myKill.time = gettime();
		myKill.bombPlanted = level.bombplanted;


		self.round_report_myKill = myKill;
	}
	//logprint("_round_report::onPlayerKilled egress\n");
}

printToAll()
{
	if (!level.rpam_sd_round_report)
		return;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] thread print();
}

print()
{
	self endon("disconnect");
	
	//logprint(self.name + " print dmg ingress\n");

	hitLocTexts["head"] = "Head";
	hitLocTexts["neck"] = "Neck";

	hitLocTexts["torso_upper"] = "Torso Upper";
	hitLocTexts["torso_lower"] = "Torso Lower";

	hitLocTexts["left_arm_upper"] = "Shoulder";
	hitLocTexts["left_arm_lower"] = "Arm";
	hitLocTexts["left_hand"] = "Hand";

	hitLocTexts["right_arm_upper"] = "Shoulder";
	hitLocTexts["right_arm_lower"] = "Arm";
	hitLocTexts["right_hand"] = "Hand";

	hitLocTexts["left_leg_upper"] = "Leg";
	hitLocTexts["left_leg_lower"] = "Leg";
	hitLocTexts["left_foot"] = "Foot";

	hitLocTexts["right_leg_upper"] = "Leg";
	hitLocTexts["right_leg_lower"] = "Leg";
	hitLocTexts["right_foot"] = "Foot";

	wait 1 * 1;

	//self thread sendDebugInfo();


	if (self.round_report_array.size > 0)
	{
		self iprintln(" ");
		self iprintln(" ");
		self iprintln(" ");
		self iprintln(" ");
		self iprintln(" ");
		self iprintln(" ");
		self iprintln(" ");
		self iprintln(" ");
		self iprintln(level._prefix + "Round report:");
	}


	killNum = 1;
	for (i = 0; i < self.round_report_array.size; i++)
	{
		if (isDefined(self.round_report_array[i].enemy))
		{
			log = self.round_report_array[i];

			string = getTimeString(log.time, log.bombPlanted) + " ^9";

			if (log.wasKilled)
			{
				// Kill
				if (log.teamkill)
					string += "^1team kill " + killNum + "^9";
				else
					string += "^2kill " + killNum + "^9";
				killNum++;

				if (log.multipleDamage == false)
				{
					damage = (int)log.firstDamageValue; // damage = int(log.firstDamageValue);
					if (damage == 0) damage = 1;
					string += " " + damage + "hp";
				}

				// To
				/*if (log.sWeapon == "shotgun_mp" && log.sMeansOfDeath == "MOD_PISTOL_BULLET")
				{
					string += " with " + log.pellets + " pellet";
					if (log.pellets > 1) string += "s";
				}
				else
				{
					if (isDefined(hitLocTexts[log.hitLoc]))
						string += " to " + hitLocTexts[log.hitLoc];
					else if (log.hitLoc != "none")
						string += " to " + log.hitLoc;
				}*/
				
				if (isDefined(hitLocTexts[log.hitLoc]))
					string += " to " + hitLocTexts[log.hitLoc];
				else if (log.hitLoc != "none")
					string += " to " + log.hitLoc;

				// [Weapon]
				weapon = getWeapon(log.sMeansOfDeath, log.sWeapon);
				if (weapon != "")
					string += " ("+weapon+")";

				// Separate hit part in case of multiple damage
				if (log.multipleDamage)
					string += ", first ";
			}

			// Mutiple hit (damage+damage; damage+kill) | single damage without kill
			if (log.multipleDamage || (!log.multipleDamage && !log.wasKilled))
			{
				if (log.teamkill)
					string += "^1team^9 ";
				string += "hit";

				damage = (int)log.firstDamageValue;
				if (damage == 0) damage = 1;
				string += " " + damage + "hp";

				/*
				if (log.sFirstWeapon == "shotgun_mp" && log.sFirstMeansOfDeath == "MOD_PISTOL_BULLET")
				{
					string += " " + log.pellets + " pellet";
					if (log.pellets > 1) string += "s";

					if (log.shotgun_distance > 0)
					{
						string += " " + (((log.shotgun_distance) / 10) / 10) + "m";
					}

					if (log.adjustedBy == "consistent_shotgun_1_kill" || log.adjustedBy == "consistent_shotgun_1_hit")
						string += " range-1";
					else if (log.adjustedBy == "consistent_shotgun_2")
						string += " range-2";
					else if (log.adjustedBy == "consistent_shotgun_3")
						string += " range-3";
					else if (log.adjustedBy == "consistent_shotgun_4")
						string += " range-4";
				}
				*/

				if (log.sFirstWeapon != "shotgun_mp")
				{
					if (isDefined(hitLocTexts[log.firstHitLoc]))
						string += " to " + hitLocTexts[log.firstHitLoc];
					else if (log.firstHitLoc != "none")
						string += " to " + log.firstHitLoc;
				}

				// Show weapon if only hit is showed or weapons are different
				if (!log.wasKilled || log.sWeapon != log.sFirstWeapon)
				{
					weapon = getWeapon(log.sFirstMeansOfDeath, log.sFirstWeapon);
					if (weapon != "")
						string += " ("+weapon+")";
				}

			}

			/*
			// Hit was adjusted by fixes
			if (log.adjustedBy == "hand_hitbox_fix" || log.adjustedBy == "torso_hitbox_fix")
			{
				string += " ^1*";
			}
			*/


			self iprintln("" + string);
		}
	}

	if (self.round_report_array.size > 0 && isDefined(self.round_report_myKill))
	{
		string = getTimeString(self.round_report_myKill.time, self.round_report_myKill.bombPlanted) + " ^1killed";

		if (isDefined(hitLocTexts[self.round_report_myKill.hitLoc]))
			string += " to " + hitLocTexts[self.round_report_myKill.hitLoc];
		else if (self.round_report_myKill.hitLoc != "none")
			string += " to " + self.round_report_myKill.hitLoc;

		weapon = getWeapon(self.round_report_myKill.sMeansOfDeath, self.round_report_myKill.sWeapon);
		if (weapon != "")
			string += " via "+weapon+"";

		self iprintln("" + string);
	}

	//logprint(self.name + " print dmg egress\n");
}

getTimeString(time, bombPlanted)
{
	if (bombPlanted)
		return "B " + formatTime((int)(level.countdowntime - (int)((time - level.bombtimerstart)/1000)));
	else
		return formatTime(level.z_rpam_strat_time + (int)((level.roundlength * 60) - (int)((time - level.starttime)/1000)));
		//return formatTime(level.strat_time + ((level.roundlength * 60) - ((time - level.starttime)/1000)));
}

// Prints second in format 00:00:00 (hours are printed only if > 0)
formatTime(timeSec, separator)
{
	if (!isDefined(separator)) separator = ":";
	_timeSec = (int)timeSec; // to avoid unmatching types 'float' and 'int'
	str = "";
	min = (int)(_timeSec / 60);
	hour = (int)(min / 60);
	sec = _timeSec % 60;
	if (hour > 0)
	{
		if (hour < 10) hour = "0" + hour;
		min = min % 60;
		str += hour + separator;
	}
	if (min < 10) min = "0" + min;
	if (sec < 10) sec = "0" + sec;

	str += min + separator;
	str += sec;

	return str;
}

getWeapon(sMeansOfDeath, sWeapon)
{
	if (sMeansOfDeath == "MOD_MELEE")
		return "Bash";
	if (sMeansOfDeath == "MOD_GRENADE_SPLASH")
		return "Grenade";

	weaponsTexts["m1carbine_mp"] = "Carabine";
	weaponsTexts["m1garand_mp"] = "M1 Garand";
	weaponsTexts["thompson_mp"] = "Thompson";
	weaponsTexts["bar_mp"] = "Bar";
	weaponsTexts["springfield_mp"] = "Springfield";
	weaponsTexts["greasegun_mp"] = "Greasegun";
	weaponsTexts["shotgun_mp"] = "Shotgun";
	weaponsTexts["enfield_mp"] = "Enfield";
	weaponsTexts["sten_mp"] = "Sten";
	weaponsTexts["bren_mp"] = "Bren";
	weaponsTexts["enfield_scope_mp"] = "Enfield Scoped";
	weaponsTexts["mosin_nagant_mp"] = "Mosin Nagant";
	weaponsTexts["SVT40_mp"] = "SVT40";
	weaponsTexts["PPS42_mp"] = "PPS42";
	weaponsTexts["ppsh_mp"] = "PPSH";
	weaponsTexts["mosin_nagant_sniper_mp"] = "Mosin Nagant Scoped";
	weaponsTexts["kar98k_mp"] = "Kar98k";
	weaponsTexts["g43_mp"] = "Gewehr";
	weaponsTexts["mp40_mp"] = "MP40";
	weaponsTexts["mp44_mp"] = "MP44";
	weaponsTexts["kar98k_sniper_mp"] = "Kar98k Scoped";
	weaponsTexts["colt_mp"] = "Pistol";
	weaponsTexts["webley_mp"] = "Pistol";
	weaponsTexts["luger_mp"] = "Pistol";
	weaponsTexts["TT30_mp"] = "Pistol";
	weaponsTexts["mg42_bipod_stand_mp"] = "MG";
	weaponsTexts["30cal_stand_mp"] = "MG";

	if (isDefined(weaponsTexts[sWeapon]))
		return weaponsTexts[sWeapon];
	return "";
}

/*
sendDebugInfo()
{
	self endon("disconnect");

	// offset thread a litle bit
	wait 0.05 * (self getEntityNumber());

	buffer = "Hits from round " + game["roundsplayed"] + " (only rifle, scope and grenade hits are saved)\n";
	debugIndex = 1;
	for(i = 0; i < self.round_report_debug.size; i++)
	{
		buffer += self.round_report_debug[i] + "\n";

		if (buffer.size > 400)
		{
			self sendDebugInfoCvar(debugIndex, buffer);
			buffer = "";
			debugIndex++;
			wait 0.05;
		}
	}
	if (buffer != "")
		self sendDebugInfoCvar(debugIndex, buffer);

	// Empty other cvars
	for(i = debugIndex + 1; i <= 4; i++)
	{
		self sendDebugInfoCvar(i, "");
	}

}
sendDebugInfoCvar(debugIndex, buffer)
{
	if (debugIndex == 1)
		self setClientCvarIfChanged("pam_damage_debug", buffer);
	else
		self setClientCvarIfChanged("pam_damage_debug"+debugIndex, buffer);
}

// This function will remember the last value sended to client, so if the same value is used, nothing will be send to client
setClientCvarIfChanged(cvar, value)
{
	if (!isDefined(value)) // just safety
	{
		value = "";
	}

	valueStr = value + "";	// Convert value to string (to avoid wierd unmatching variable types errors)

	// Limit max size of cvar or server would crash "Attempted to overrun string in call to va"
	// Max len of overall command: 1024
	if (valueStr.size > 1000)
	{
		//value = getsubstr(value, 0, 1000);
	}


	//cvar = toLower(cvar);	// Convert to lower to match same cvars
	lastValue = self.pers["cvar_" + cvar]; // Get last value, may be undefined for first time

	// If value changed from last
	if (!isDefined(lastValue) || valueStr != lastValue)
	{
		self setClientCvar2(cvar, valueStr);
	}

	self.pers["cvar_" + cvar] = valueStr;
}

setClientCvar2(cvar, value, aaa, bbb, ccc)
{
	self setClientCvar(cvar, value, aaa, bbb, ccc);
}
*/