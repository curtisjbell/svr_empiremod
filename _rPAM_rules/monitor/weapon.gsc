// All credits of the monitoring scripts goes to vPAM and Walrus. I take no credit at all into making theese scripts. 
// Adapted to fit rPAMv1.11 by Anglhz<3

start(fastshoot, aimrun)
{
	self endon("spawned");
	
	slots[0] = "primary";
	slots[1] = "primaryb";
	if (level._allow_pistol) {
		slots[2] = "pistol";
	}
	if (level._allow_nades) {
		slots[slots.size] = "grenade";
	}

	// Save current clip ammo of all slots.
	for (i = 0; i < slots.size; i++) {
		clip[slots[i]] = self getWeaponSlotClipAmmo(slots[i]);
	}

	shot_last_i = 0; // Slot (index) that last fired a shot.
	shot_last_time = 0; // Time of last shot.

	do {
		for (i = 0; i < slots.size; i++) {
			clip_new = self getWeaponSlotClipAmmo(slots[i]);

			// Check if shot fired.
			if (clip_new < clip[slots[i]]) {
				shot_new_time = getTime();

				if (fastshoot) {
					thread _check_fast_shot(shot_new_time - shot_last_time, slots[shot_last_i], slots[i]);
				}

				shot_last_i = i;
				shot_last_time = shot_new_time;
			} else if (clip_new > clip[slots[i]]) {
				if (aimrun) {
					thread _check_aim_run(slots[i]);
				}
			}

			clip[slots[i]] = clip_new;
		}

		wait .05;
	} while (self.sessionstate == "playing");
}

_check_fast_shot(ms, slot_1, slot_2)
{
	weapon_1 = self getWeaponSlotWeapon(slot_1);
	weapon_2 = self getWeaponSlotWeapon(slot_2);

	ms_threshold = 0;

	if (slot_1 == slot_2) {
		switch (weapon_1) {
		case "enfield_mp": // fireTime + rechamberTime = 0.33 + 1.1 = 1.43
		case "kar98k_mp": // fireTime + rechamberTime = 0.33 + 1 = 1.33
		case "kar98k_sniper_mp": // fireTime + rechamberTime = 0.33 + 1 = 1.33
		case "mosin_nagant_mp": // fireTime + rechamberTime = 0.33 + 1 = 1.33
		case "springfield_mp": // fireTime + rechamberTime = 0.33 + 0.95 = 1.28
			ms_threshold = 1250;
			break;
		case "mosin_nagant_sniper_mp": // fireTime + rechamberTime = 0.5 + 1 = 1.5
		case "fraggrenade_mp": // fireTime + holdFireTime = 1 + 0.5 = 1.5
		case "mk1britishfrag_mp": // fireTime + holdFireTime = 1 + 0.6 = 1.6
		case "rgd-33russianfrag_mp": // fireTime + holdFireTime = 1 + 0.5 = 1.5
		case "stielhandgranate_mp": // fireTime + holdFireTime = 1 + 0.5 = 1.5
			ms_threshold = 1400;
			break;
		case "colt_mp": // fireTime = 0.135
		case "luger_mp": // fireTime = 0.135
			ms_threshold = 100;
//			break;
//		case "bar_mp": // fireTime = 0.11
//		case "bren_mp": // fireTime = 0.12
//		case "mp44_mp": // fireTime = 0.12
//			ms_threshold = 100;
		}

		// The last thrown nade will be gone, thus we check the slot.
		if (weapon_1 == "none" && slot_1 == "grenade") {
			ms_threshold = 1400;
		}
	} else {
		// Fast weapon switch.

		// fireTime + dropTime + raiseTime = 0.33 + 0.4 + 0.5 = 1.22
		if ((weapon_1 == "kar98k_mp" && weapon_2 == "mosin_nagant_mp")
		|| (weapon_2 == "kar98k_mp" && weapon_1 == "mosin_nagant_mp")) {
			ms_threshold = 1150;
		}
	}

	if (ms < ms_threshold) {
		if (slot_2 == "pistol" || slot_2 == "grenade") {
			extra_info = " (^3" + slot_2 + "^7)";
		} else {
			extra_info = "";
		}
		iPrintLn(level._prefix + "^1FASTSHOOT^7" + extra_info + ": " + self.name);
	}
}

_check_aim_run(slot)
{
	// Aim running is done with a bolt action rifle by holding the attack button at reloading.
	// While holding the attack button after reloading, a player can aim while maintaining regular speed.

	if (slot != "primary" && slot != "primaryb") {
		return;
	}

	weapon = self getWeaponSlotWeapon(slot);

	if (
		weapon != "enfield_mp" &&
		weapon != "m1garand_mp" &&
		weapon != "m1carbine_mp" &&
		weapon != "kar98k_mp" &&
		weapon != "kar98k_sniper_mp" &&
		weapon != "mosin_nagant_mp" &&
		weapon != "mosin_nagant_sniper_mp" &&
		weapon != "springfield_mp" &&
		weapon != "luger_mp" &&
		weapon != "colt_mp"
	) {
		return;
	}

	// Roughly 1 second after clip count is increased, weapon can fire again.
	// We will check for the attack button being pressed during a small window.
	// If inside the window a bullet is fired, the window ends.
	ammo = self getWeaponSlotClipAmmo(slot);

	// Wait for reloading animation to progress.
	wait 0.9;

	// Check during the next 0.5 second window for holding it.
	for (tick = 0; tick < 10 && self.sessionstate == "playing"; tick++) {
		// If a shot was fired (by pressing attack), aimrunning isn't relevant anymore.
		if (self getWeaponSlotClipAmmo(slot) != ammo) {
			break;
		}

		if (self attackButtonPressed()) {
			self disableWeapon();
		}

		wait 0.05;
		self enableWeapon();
	}
}

// AG Script based on lwsk1LL. Adapted, Edited/Changed by both Anglhz and xa1ruZ.

main()
{
	level thread reset_fastshot_counter();
}

getWeaponTotalAmmo(ply) {
	return ply getweaponslotammo("primary") + ply getweaponslotclipammo("primary") + ply getweaponslotammo("primaryb") + ply getweaponslotclipammo("primaryb");
}

monitoring()
{
	self endon("player_disconnected");
	self thread fastshoot_monitoring();
	self thread aimrun_monitoring();
	self thread weapon_switch_monitoring();
}

weapon_switch_monitoring()
{
	self endon("player_disconnected");
	previous_weapon = "";
	current_weapon = "";

	while(1) {
		while(!isAlive(self)) {
			wait 0.25;
		}

		while (previous_weapon == current_weapon) {
			current_weapon = self GetCurrentWeapon();
			wait 0.05;
		}

		self notify("weapon_switch");
		self notify("stop_aimrun_monitoring");
		previous_weapon = current_weapon;

		wait 0.20;
	}
}

reset_fastshot_counter() {
	while(1) {
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
                        if (isDefined(players[i])) {
                                players[i].fs_count = 1;
                                players[i].fs_shot_weapon = players[i] GetCurrentWeapon();
                                players[i].fs_shot_time = getTime();
                        }
		}
		level waittill("round_started");
	}
}

fastshoot_monitoring()
{
        self endon("player_disconnected");
        self.fs_count = 1;
        self.fs_shot_weapon = self GetCurrentWeapon();
        self.fs_shot_time = getTime();
	while(!isAlive(self))
	{
		wait 0.05;
	}

	total_ammo_previous = -1;

	while(1)
	{
		if (!isAlive(self)) {
			wait 0.05;
			continue;
		}
		total_ammo = getWeaponTotalAmmo(self);
                if (total_ammo < total_ammo_previous) {
                        self notify("stop_aimrun_monitoring");
                        self.fs_shot_weapon = self GetCurrentWeapon();
                        self.fs_shot_time = getTime();
                        self thread shotFired(total_ammo);
                }
		total_ammo_previous = total_ammo;

		wait 0.05;
	}
}

aimrun_monitoring_thread()
{
	self endon("player_disconnected");
	self endon("stop_aimrun_monitoring");

	current_weapon = self GetCurrentWeapon();

	if (
		current_weapon != "enfield_mp" &&
		current_weapon != "m1garand_mp" &&
		current_weapon != "m1carbine_mp" &&
		current_weapon != "kar98k_mp" &&
		current_weapon != "kar98k_sniper_mp" &&
		current_weapon != "mosin_nagant_mp" &&
		current_weapon != "mosin_nagant_sniper_mp" &&
		current_weapon != "springfield_mp" &&
		current_weapon != "luger_mp" &&
		current_weapon != "colt_mp"
	) {
		return;
	}

	primary = "primary";
	if (current_weapon != self getweaponslotweapon("primary")) {
		primary = "primaryb";
	}

	previous_clip_ammo = self getweaponslotclipammo(primary) + 1;
	current_clip_ammo = self getweaponslotclipammo(primary);

	// wait till full reloading
	while(current_clip_ammo < previous_clip_ammo) {
		current_clip_ammo = self getweaponslotclipammo(primary);
		wait 0.15;
	}

	previous_clip_ammo = current_clip_ammo;

	time = 0;
	wait 0.5;
	MAX = 40;

	while(time < MAX && current_clip_ammo == previous_clip_ammo) {
		count = 0;
		current_clip_ammo = self getweaponslotclipammo(primary);
		while (self AttackButtonPressed() && current_clip_ammo == previous_clip_ammo && count < 10) {
			self disableWeapon();
			wait 0.05;
			self enableWeapon();
			current_clip_ammo = self getweaponslotclipammo(primary);
			count++;
			time = time +5;
			wait 0.05;
		}
		time = time + 5;
		wait 0.05;
	}
}


aimrun_monitoring()
{
	self endon("player_disconnected");
	while(1) {
		while (!isAlive(self)) {
			wait 0.05;
		}

		self thread aimrun_monitoring_thread();
		self waittill("stop_aimrun_monitoring");

		wait 0.05;
	}
}

shotFired(total_ammo_previous) {
	self endon("player_disconnected");
	wait 1.20;
	total_ammo = getWeaponTotalAmmo(self);

	if (total_ammo < total_ammo_previous && isAlive(self))
	{
//	iprintln("^7" + self.name + " ^7FASTSHOOTING IS ^3NOT ^7ALLOWED^3!");
	self.fs_count++;	
	}
}