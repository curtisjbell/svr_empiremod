/*	** rPAM V1.11 rulesets(_rpam_rulesets_sd.gsc) **

	REISSUE Project Ares Mod version 1.11 by zyquist
	
	
	created by zyquist (aka reissue_)

>>>	V1.11 -- V1

>>>	REL-TIMESTAMP: 20:16 13.06.2015
>>>	SRC-TIMESTAMP: 20:16 13.06.2015

>>>	** THIS FILE IS FOR ALL RULESETS OF P.A.M. **


rPAMMODEdefault		== Starting by default
rPAMMODES		== All modes with path
rCHECKPAMMODES		== Valid all modes (sd)


*/
/////////////////////////////////////////////////////////////

// rPAMMODEdefault
rPAMMODEdefault()
{
	setCvar("pam_mode", "ub_mr10");
}

// rPAMMODES()
rPAMMODES()
{
	ruleset = getCvar("pam_mode");
	switch(ruleset)
	{
	
	// Default AW
	case "aw_mr10":
		thread _rPAM_rules\sd\defaults\aw\mr10::LeagueRules();
		break;
	case "aw_mr12":
		thread _rPAM_rules\sd\defaults\aw\mr12::LeagueRules();
		break;
	case "aw_mr13":
		thread _rPAM_rules\sd\defaults\aw\mr13::LeagueRules();
		break;
	case "aw_bo3":
		thread _rPAM_rules\sd\defaults\aw\bo3::LeagueRules();
		break;

	// CoDBase AW
/* 
	case "cb_mr10":
		thread _rPAM_rules\sd\codbase\aw\cb_mr10::LeagueRules();
		break;
	case "cb_mr10_mix":
		thread _rPAM_rules\sd\codbase\aw\cb_mr10_mix::LeagueRules();
		break;
	case "cb_mr12":
		thread _rPAM_rules\sd\codbase\aw\cb_mr12::LeagueRules();
		break;
	case "cb_mr13":
		thread _rPAM_rules\sd\codbase\aw\cb_mr13::LeagueRules();
		break;
	case "cb_bo1_mr10":
		thread _rPAM_rules\sd\codbase\aw\cb_bo1_mr10::LeagueRules();
		break;
	case "cb_bo1_mr12":
		thread _rPAM_rules\sd\codbase\aw\cb_bo1_mr12::LeagueRules();
		break;
	case "cb_bo3":
		thread _rPAM_rules\sd\codbase\aw\cb_bo3::LeagueRules();
		break;
*/

	// Default RO
	case "ro_mr10":
		thread _rPAM_rules\sd\defaults\ro\mr10::LeagueRules();
		break;
	case "ro_mr12":
		thread _rPAM_rules\sd\defaults\ro\mr12::LeagueRules();
		break;
	case "ro_mr13":
		thread _rPAM_rules\sd\defaults\ro\mr13::LeagueRules();
		break;
	case "ro_bo3":
		thread _rPAM_rules\sd\defaults\ro\bo3::LeagueRules();
		break;

/*
	// CoDBase RO
	case "cb_ro_mr10":
		thread _rPAM_rules\sd\codbase\ro\cb_mr10::LeagueRules();
		break;
	case "cb_ro_mr12":
		thread _rPAM_rules\sd\codbase\ro\cb_mr12::LeagueRules();
		break;
	case "cb_ro_mr13":
		thread _rPAM_rules\sd\codbase\ro\cb_mr13::LeagueRules();
		break;
	case "cb_ro_bo1_mr10":
		thread _rPAM_rules\sd\codbase\ro\cb_bo1_mr10::LeagueRules();
		break;
	case "cb_ro_bo1_mr12":
		thread _rPAM_rules\sd\codbase\ro\cb_bo1_mr12::LeagueRules();
		break;
	case "cb_ro_bo3":
		thread _rPAM_rules\sd\codbase\ro\cb_bo3::LeagueRules();
		break;
*/

	// UnitedBase AW
	case "ub_mr10":
		thread _rPAM_rules\sd\unitedbase\aw\ub_mr10::LeagueRules();
		break;
	case "ub_mr10_mix":
		thread _rPAM_rules\sd\unitedbase\aw\ub_mr10_mix::LeagueRules();
		break;
	case "ub_mr12":
		thread _rPAM_rules\sd\unitedbase\aw\ub_mr12::LeagueRules();
		break;
	case "ub_mr13":
		thread _rPAM_rules\sd\unitedbase\aw\ub_mr13::LeagueRules();
		break;
	case "ub_bo1_mr10":
		thread _rPAM_rules\sd\unitedbase\aw\ub_bo1_mr10::LeagueRules();
		break;
	case "ub_bo1_mr12":
		thread _rPAM_rules\sd\unitedbase\aw\ub_bo1_mr12::LeagueRules();
		break;
	case "ub_bo3":
		thread _rPAM_rules\sd\unitedbase\aw\ub_bo3::LeagueRules();
		break;

	// Public Modes
	case "aw_pub":
		thread _rPAM_rules\sd\defaults\pub\_public::LeagueRules();
		break;
	case "ro_pub":
		thread _rPAM_rules\sd\defaults\pub\_public_rifles::LeagueRules();
		break;
	case "nade_training":
		thread _rPAM_rules\sd\defaults\pub\_nade_training::LeagueRules();
		break;

	// Dsefault mode by pam
	default:
		thread _rPAM_rules\sd\unitedbase\aw\ub_mr10::LeagueRules();
		setCvar("pam_mode", "ub_mr10");
		break;

// rTEST (as default mode for development)
/*
	default:
		thread _rPAM_rules\sd\__rDEVTEST::LeagueRules();
		setCvar("pam_mode", "_rDEVTEST");
		break;
*/
		}
}

// rCHECKPAMMODES
rCHECKPAMMODES(pammode)
{
	gametype = getcvar("g_gametype");

	if (gametype == "sd")
	{
		switch (pammode)
		{
		// Default AW
		case "aw_mr10":
		case "aw_mr12":
		case "aw_mr13":
		case "aw_bo3":

/*			
		// CoDBase AW
		case "cb_mr10":
		case "cb_mr10_mix":
		case "cb_mr12":
		case "cb_mr13":
		case "cb_bo1_mr10":
		case "cb_bo1_mr12":
		case "cb_bo3":

		// CoDBase RO
		case "cb_ro_mr10":
		case "cb_ro_mr12":
		case "cb_ro_mr13":
		case "cb_ro_bo1_mr10":
		case "cb_ro_bo1_mr12":
		case "cb_ro_bo3":
*/

		// Default RO
		case "ro_mr10":
		case "ro_mr12":
		case "ro_mr13":
		case "ro_bo3":

		// UnitedBase AW
		case "ub_mr10":
		case "ub_mr10_mix":
		case "ub_mr12":
		case "ub_mr13":
		case "ub_bo1_mr10":
		case "ub_bo1_mr12":
		case "ub_bo3":

		//Public Modes
		case "aw_pub":
		case "ro_pub":
			level.rpam_nade_training_dmg_info = 0;
			return 1;
		case "nade_training":
			level.rpam_nade_training_dmg_info = 1;
			return 1;

		default:
			level.rpam_nade_training_dmg_info = 0;
			return 0;
		}
	}

	iprintln("^1Gametype ^3" + gametype + " ^1 not supported by PAM");
	return 0;
}
// END OF FILE