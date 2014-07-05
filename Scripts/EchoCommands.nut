function onIRCCommand( user, cmd, text, level ) {

	if ( cmd == "say" ) {
		if ( !text ) EchoMessage( ICOL_RED + "Error - Syntax: !" + cmd + " <text> " );
		else
		{
			IrcSay( user, text );
		}
	}
	
	else if ( cmd == "me" ) {
		if ( !text ) EchoMessage( ICOL_RED + "Error - Syntax: !" + cmd + " <text> " );
		else ::EMessage( user + " " + text );	
	}
	
	else if ( cmd == "gamemode" ) {
		EchoMessage( ICOL_BLUE + " ->> Current gamemode: " + getGamemodeNameFromID( gGamemode ) );
	}
	
	else if ( cmd == "gamemodes" ) {
		EchoMessage( ICOL_BLUE + " ->> Gamemodes available: " );
		EchoMessage( ICOL_PURPLE + " -> 0. " + ICOL_CYAN + "Attack and Defence" );
		EchoMessage( ICOL_PURPLE + " -> 1. " + ICOL_CYAN + "King of the Hill" );
		EchoMessage( ICOL_PURPLE + " -> 2. " + ICOL_CYAN + "Team Deathmatch (NYI)" );
		EchoMessage( ICOL_PURPLE + " -> 3. " + ICOL_CYAN + "Team LMS (NYI)" );
	}
	
	else if ( cmd == "setgamemode" ) {
		if ( level < 3 ) EchoMessage( ICOL_RED + "Error - You must be an administrator to do this." );
		else if ( !text ) EchoMessage( ICOL_RED + "Error - Wrong syntax, !setgamemode <gamemode id>" );
		else {
			EchoMessage( ICOL_BLUE + " ->> Admin changed has changed the gamemode to: " + getGamemodeNameFromID( text.tointeger() ) );
			EMessage( " ->> Reloading scripts and loading new gamemode..." );
			AnnounceAll( "Loading new gamemode" );
			local params = text.tointeger();
			
			NewTimer( "ChangeGamemode", 2000, 1, params );
		}
	}
	
	else if ( cmd == "players" ) {
		// Lists a table of players currently in game
		local maxPlayers = GetMaxPlayers();
		local i = 0, ii = 0, iii = 0;
		local buffer = null;
		while ( ( i < maxPlayers ) && ( ii < GetPlayers() ) )
		{
			local plr = FindPlayer( i );
			if ( plr )
			{
				if ( !buffer ) 
				{
					buffer = plr.Name;
					iii++;
				}
				else if ( ++iii < 3 ) buffer = buffer + "     |     " + plr.Name;
				else
				{
					print( buffer );
					buffer = plr.Name;
					iii = 0;
				}
				ii++;
			}
			i++;
		}
		if ( buffer ) EchoMessage( buffer );
		EchoMessage( "Total players: " + GetPlayers() + "/" + GetMaxPlayers() );
	}
	
}