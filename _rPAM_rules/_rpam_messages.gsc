/*	** rPAM V1.11 messages (_rpam_rulesets_messages.gsc) **

	REISSUE Project Ares Mod version 1.11 by zyquist
	
	
	created by zyquist (aka reissue_)

>>>	V1.11 -- V1

>>>	REL-TIMESTAMP: 18:09 12.06.2015
>>>	SRC-TIMESTAMP: 18:09 12.06.2015



rMESSAGEatstart/ rMESSAGEathalf			== GET THEMESSAGES FOR THE RULESETS
CYBERGAMERstartmatch/ CYBERGAMERmatchhalf	== ## MESSAGES FOR CYBERGAMER ##
rDEVMESSAGESstart/ rDEVMESSAGEShalf		== Testing


*/
/////////////////////////////////////////////////////////////

// rMESSAGEatstart
rMESSAGEstart()
{
	self CYBERGAMERstartmatch();
	self rMESSAGEfirsthalf();
}

// rMESSAGEathalf
rMESSAGEhalf()
{
	self CYBERGAMERmatchhalf();
	self rMESSAGEsecondhalf();
}


// ## MESSAGES FOR CYBERGAMER ##

// CYBERGAMERstartmatch
CYBERGAMERstartmatch()
{
	mode = getcvar("pam_mode");
	switch (mode)
	{
		// Default AW
		case "aw_mr10":
		case "aw_mr12":
		case "aw_mr13":
		case "aw_bo3":

			
		// CoDBase AW
		case "cb_mr10":
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

		// Default RO
		case "ro_mr10":
		case "ro_mr12":
		case "ro_mr13":
		case "ro_bo3":

		x = 1;
		break;

	default:
		x = 0;
		break;
	}
	if (x)
	{
		self iprintlnbold("^7By Readying-Up, you have ^2CHECKED^3 all conditions");
		self iprintlnbold("^7on this server and you are ^3AGREEING ^7to them.");
		// FAST MESSAGES
		wait 3.5;
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		wait 0.1;
		self iprintlnbold("^2CHECKLIST:");
		self iprintlnbold("^5CoDBase ^6PB^7cvar, ^5CODBase ^6PB^7stream, ^5running^7 MOSS, ^3recording DEMOs");
		// FAST MESSAGES
		wait 3.5;
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		wait 0.1;
		self iprintlnbold("^3ANY ^7concerns, so please contact an");
		self iprintlnbold("^5CoDBase^7 admin on Discord.");
		self iprintlnbold("^3ISSUES ^1after ^7the match are ^1non^7-^1disputable^7!");
		// FAST MESSAGES
		wait 3.5;
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		wait 0.1;
		// RDYUP YET
	}
}

// CYBERGAMERmatchhalf
CYBERGAMERmatchhalf()
{
	mode = getcvar("pam_mode");
	switch (mode)
	{
		// Default AW
		case "aw_mr10":
		case "aw_mr12":
		case "aw_mr13":
		case "aw_bo3":

			
		// CoDBase AW
		case "cb_mr10":
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

		// Default RO
		case "ro_mr10":
		case "ro_mr12":
		case "ro_mr13":
		case "ro_bo3":

		x = 1;
		break;

	default:
		x = 0;
		break;
	}
	if (x)
	{
		self iprintlnbold("^3BEFORE ^7Readying-Up, check the ^2CHECKLIST^7 again:");
		self iprintlnbold("^5CoDBase ^6PB^7cvar, ^5CODBase ^6PB^7stream, ^5running^7 MOSS, ^3recording DEMO");
		// FAST MESSAGES
		wait 3.5;
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		wait 0.1;
		self iprintlnbold("^3ANY ^7concerns, so please contact an");
		self iprintlnbold("^5CoDBase^7 admin on Discord.");
		// FAST MESSAGES
		wait 3.5;
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");
		wait 0.1;
		// RDYUP YET
	}
}

// rDEVMESSAGESstart
rMESSAGEfirsthalf()
{
	mode = getcvar("pam_mode");
	switch (mode)
	{
		case "_rDEVTEST":

		x = 1;
		break;

	default:
		x = 0;
		break;
	}
	if (x)
	{
		self iprintlnbold("TESTMESSAGE FIRST HALF");
		wait 2;
		self iprintlnbold("TESTMESSAGE NUMBER 2 FIRST HALF");
		wait 3;
	}
}

// rDEVMESSAGEShalf
rMESSAGEsecondhalf()
{
	mode = getcvar("pam_mode");
	switch (mode)
	{
		case "_rDEVTEST":

		x = 1;
		break;

	default:
		x = 0;
		break;
	}
	if (x)
	{
		self iprintlnbold("TESTMESSAGE SECOND HALF");
		wait 2;
		self iprintlnbold("TESTMESSAGE NUMBER 2 SECOND HALF");
		wait 3;
	}
}
// END OF FILE