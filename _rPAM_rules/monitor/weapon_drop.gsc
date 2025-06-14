// All credits of the monitoring scripts goes to vPAM and Walrus. I take no credit at all into making theese scripts. 
// Adapted to fit rPAMv1.11 by Anglhz<3

start()
{
	self endon("spawned");

	while (self.sessionstate == "playing") {
		ticks = 0;

		while (
			self.sessionstate == "playing" && self useButtonPressed() &&
			// Prevent interference with bomb planting.
			!isDefined(self.progressbar) &&
			self getCurrentWeapon() == self getWeaponSlotWeapon("primaryb")
		) {
			ticks++;

			if (ticks > 32) {
				if (level._allow_drop_sniper == false) {
					switch (self getCurrentWeapon()) {
					case "kar98k_sniper_mp":
					case "mosin_nagant_sniper_mp":
					case "springfield_mp":
						ticks = 0;
						iPrintLn("^7rPAM^3 ~ ^1Snipers can not be dropped.");
						wait 0.05;
						continue;
					}
				}

				self dropItem(self getCurrentWeapon());
			}

			wait .05;
		}

		wait .25;
	}
}
