main()
{
	if ( self.pers["team"] != "spectator")
	{
		return;
	}

	self endon("player_disconnected");
	level endon( "intermission" );
	self endon( "spawned" );

	self thread Streaming_Hud();
}

/// Settings for Streaming Mode
Streaming_Hud()
{
	self.rpam_rSTREAMINGMode_status = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_status.archived = false;
	self.rpam_rSTREAMINGMode_status.x = 10;
	self.rpam_rSTREAMINGMode_status.y = 130; //200;
	self.rpam_rSTREAMINGMode_status.alignX = "left";
	self.rpam_rSTREAMINGMode_status.alignY = "middle";
	self.rpam_rSTREAMINGMode_status.fontScale = 1.2;
	self.rpam_rSTREAMINGMode_status.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_status setText(game["streaming_status"]);

	self.rpam_rSTREAMINGMode_team1 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_team1.archived = false;
	self.rpam_rSTREAMINGMode_team1.x = 10;
	self.rpam_rSTREAMINGMode_team1.y = 150; //200;
	self.rpam_rSTREAMINGMode_team1.alignX = "left";
	self.rpam_rSTREAMINGMode_team1.alignY = "middle";
	self.rpam_rSTREAMINGMode_team1.fontScale = 1;
	self.rpam_rSTREAMINGMode_team1.color = (.73, .99, .73);
	self.rpam_rSTREAMINGMode_team1 setText(game["streaming_team1"]);
	
	self.rpam_rSTREAMINGMode_scoreboard_team1 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_scoreboard_team1.archived = false;
	self.rpam_rSTREAMINGMode_scoreboard_team1.x = 10;
	self.rpam_rSTREAMINGMode_scoreboard_team1.y = 170; //200;
	self.rpam_rSTREAMINGMode_scoreboard_team1.alignX = "left";
	self.rpam_rSTREAMINGMode_scoreboard_team1.alignY = "middle";
	self.rpam_rSTREAMINGMode_scoreboard_team1.fontScale = 0.8;
	self.rpam_rSTREAMINGMode_scoreboard_team1.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_scoreboard_team1 setText(game["score_board_team1"]);

	self.rpam_rSTREAMINGMode_score_team1 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_score_team1.archived = false;
	self.rpam_rSTREAMINGMode_score_team1.x = 50;
	self.rpam_rSTREAMINGMode_score_team1.y = 170; //200;
	self.rpam_rSTREAMINGMode_score_team1.alignX = "left";
	self.rpam_rSTREAMINGMode_score_team1.alignY = "middle";
	self.rpam_rSTREAMINGMode_score_team1.fontScale = 0.8;
	self.rpam_rSTREAMINGMode_score_team1.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_score_team1 setValue(game["alliedscore"]);
/*		
	self.rpam_rSTREAMINGMode_player_left_team1 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_player_left_team1.archived = false;
	self.rpam_rSTREAMINGMode_player_left_team1.x = 10;
	self.rpam_rSTREAMINGMode_player_left_team1.y = 190; //200;
	self.rpam_rSTREAMINGMode_player_left_team1.alignX = "left";
	self.rpam_rSTREAMINGMode_player_left_team1.alignY = "middle";
	self.rpam_rSTREAMINGMode_player_left_team1.fontScale = 0.8;
	self.rpam_rSTREAMINGMode_player_left_team1.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_player_left_team1 setText(game["pleft_team1"]);
	

	self.rpam_rSTREAMINGMode_player_left_value_team1 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_player_left_value_team1.x = 65;
	self.rpam_rSTREAMINGMode_player_left_value_team1.y = 190; //200;
	self.rpam_rSTREAMINGMode_player_left_value_team1.alignX = "left";
	self.rpam_rSTREAMINGMode_player_left_value_team1.alignY = "middle";
	self.rpam_rSTREAMINGMode_player_left_value_team1.fontScale = 0.8;
	self.rpam_rSTREAMINGMode_player_left_value_team1.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_player_left_value_team1.alpha = 1;
	self.rpam_rSTREAMINGMode_player_left_value_team1 setValue(level.exist["allies"]);

*/
	self.rpam_rSTREAMINGMode_team2 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_team2.archived = false;
	self.rpam_rSTREAMINGMode_team2.x = 10;
	self.rpam_rSTREAMINGMode_team2.y = 190; //210;
	self.rpam_rSTREAMINGMode_team2.alignX = "left";
	self.rpam_rSTREAMINGMode_team2.alignY = "middle";
	self.rpam_rSTREAMINGMode_team2.fontScale = 1;
	self.rpam_rSTREAMINGMode_team2.color = (.85, .99, .99);
	self.rpam_rSTREAMINGMode_team2 setText(game["streaming_team2"]);

	self.rpam_rSTREAMINGMode_scoreboard_team2 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_scoreboard_team2.archived = false;
	self.rpam_rSTREAMINGMode_scoreboard_team2.x = 10;
	self.rpam_rSTREAMINGMode_scoreboard_team2.y = 210; //230;
	self.rpam_rSTREAMINGMode_scoreboard_team2.alignX = "left";
	self.rpam_rSTREAMINGMode_scoreboard_team2.alignY = "middle";
	self.rpam_rSTREAMINGMode_scoreboard_team2.fontScale = 0.8;
	self.rpam_rSTREAMINGMode_scoreboard_team2.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_scoreboard_team2 setText(game["score_board_team2"]);
	
	self.rpam_rSTREAMINGMode_score_team2 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_score_team2.archived = false;
	self.rpam_rSTREAMINGMode_score_team2.x = 50;
	self.rpam_rSTREAMINGMode_score_team2.y = 210; //230;
	self.rpam_rSTREAMINGMode_score_team2.alignX = "left";
	self.rpam_rSTREAMINGMode_score_team2.alignY = "middle";
	self.rpam_rSTREAMINGMode_score_team2.fontScale = 0.8;
	self.rpam_rSTREAMINGMode_score_team2.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_score_team2 setValue(game["axisscore"]);
/*
	self.rpam_rSTREAMINGMode_player_left_team2 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_player_left_team2.archived = false;
	self.rpam_rSTREAMINGMode_player_left_team2.x = 10;
	self.rpam_rSTREAMINGMode_player_left_team2.y = 250; //200;
	self.rpam_rSTREAMINGMode_player_left_team2.alignX = "left";
	self.rpam_rSTREAMINGMode_player_left_team2.alignY = "middle";
	self.rpam_rSTREAMINGMode_player_left_team2.fontScale = 0.8;
	self.rpam_rSTREAMINGMode_player_left_team2.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_player_left_team2 setText(game["pleft_team2"]);

	self.rpam_rSTREAMINGMode_player_left_value_team2 = newClientHudElem( self );
	self.rpam_rSTREAMINGMode_player_left_value_team2.x = 65;
	self.rpam_rSTREAMINGMode_player_left_value_team2.y = 250; //200;
	self.rpam_rSTREAMINGMode_player_left_value_team2.alignX = "left";
	self.rpam_rSTREAMINGMode_player_left_value_team2.alignY = "middle";
	self.rpam_rSTREAMINGMode_player_left_value_team2.fontScale = 0.8;
	self.rpam_rSTREAMINGMode_player_left_value_team2.color = (1, 1, 1);
	self.rpam_rSTREAMINGMode_player_left_value_team2.alpha = 1;
	self.rpam_rSTREAMINGMode_player_left_value_team2 setValue(level.exist["axis"]);
*/

}

Streaming_Hud_Destroy()
{
	if ( isdefined( self.rpam_rSTREAMINGMode_status ) )
			self.rpam_rSTREAMINGMode_status destroy();

	if ( isdefined( self.rpam_rSTREAMINGMode_team1 ) )
		self.rpam_rSTREAMINGMode_team1 destroy();

	if ( isdefined( self.rpam_rSTREAMINGMode_scoreboard_team1 ) )
		self.rpam_rSTREAMINGMode_scoreboard_team1 destroy();

	if ( isdefined( self.rpam_rSTREAMINGMode_score_team1 ) )
		self.rpam_rSTREAMINGMode_score_team1 destroy();

	if ( isdefined( self.rpam_rSTREAMINGMode_player_left_team1 ) )
		self.rpam_rSTREAMINGMode_player_left_team1 destroy();

	if ( isdefined( level.rpam_rSTREAMINGMode_player_left_value_team1 ) )
		level.rpam_rSTREAMINGMode_player_left_value_team1 destroy();

	if ( isdefined( self.rpam_rSTREAMINGMode_team2 ) )
		self.rpam_rSTREAMINGMode_team2 destroy();
	
	if ( isdefined( self.rpam_rSTREAMINGMode_scoreboard_team2 ) )
		self.rpam_rSTREAMINGMode_scoreboard_team2 destroy();
	
	if ( isdefined( self.rpam_rSTREAMINGMode_score_team2 ) )
		self.rpam_rSTREAMINGMode_score_team2 destroy();
	
	if ( isdefined( self.rpam_rSTREAMINGMode_player_left_team2 ) )
		self.rpam_rSTREAMINGMode_player_left_team2 destroy();

	if ( isdefined( level.rpam_rSTREAMINGMode_player_left_value_team2 ) )
		level.rpam_rSTREAMINGMode_player_left_value_team2 destroy();
}