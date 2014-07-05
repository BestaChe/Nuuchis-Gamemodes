/* //////////////////////////////////////////
//
//
//           Nuuchis Gamemode
//                     Main.nut File
//
//
/* ////////////////////////////////////////// */

gGamemode <- null;

/* //////////////////////
//
// 		 Functions
//
/* ////////////////////// */

// ----------------------------------------------------
//	Description: Returns the gamemode's directory
//  Details:
//		@param 	  id = id of the gamemode
// 		@requires id = must be an integer 
//	Returns: string with the path of the directory
//
function getGamemodePathFromID( id ) {
	
	local path;
	
	switch(id) {
	case 0:
		path = "Gamemodes/AttackDefence/";
		break;
	case 1:
		path = "Gamemodes/KingOfTheHill/";
		break;
	case 2:
		path = "Gamemodes/TeamDeatchmach/";
		break;
	default:
		path = "Gamemodes/AttackDefence/";
	}
	
	return path;
}
// ----------------------------------------------------
//	Description: Returns the gamemode's real name
//  Details:
//		@param 	  id = id of the gamemode
// 		@requires id = must be an integer 
//	Returns: string of the gamemode's name
//
function getGamemodeNameFromID( id ) {
	
	local name;
	
	switch(id) {
	case 0:
		name = "Attack and Defence";
		break;
	case 1:
		name = "King of the Hill";
		break;
	case 2:
		name = "Team DeathMatch";
		break;
	case 3:
		name = "Team-LMS";
		break;
	case 4:
		name = "Capture the Flag";
		break;
	default:
		name = "Attack and Defence";
	}
	
	return name;
}
// ----------------------------------------------------
//	Description: Changes the Gamemode!
//  Details:
//		@param 	  id = id of the gamemode
// 		@requires id = must be an integer 
//	Returns: Nothing
//
function ChangeGamemode( id ) {
	
	print("[GAMEMODE] Gamemode has been changed to: " + getGamemodeNameFromID( id ) );
	WriteIniInteger( "INFO.ini", "GAMEMODE", "id", id );
	ReloadScripts();
	
	for( local i = 0; i <= GetMaxPlayers(); i++ ) {
		local plr = FindPlayer( i );
		if ( plr )
			plr.Health = 0;
	}
	
}
// ----------------------------------------------------
//	Description: Loads the Gamemode!
//  Details: Nothing
//	Returns: Nothing
//
function LoadGamemode() {

	local gamemodeID = ReadIniInteger("INFO.ini", "GAMEMODE", "id" );
	local scriptName = "gamemode.nut";
	
	if ( gamemodeID ) {
		
		print(" - Loading Gamemode || ID: [ " + gamemodeID + " ] || Name: " + getGamemodeNameFromID( gamemodeID ) );
		LoadNUT( getGamemodePathFromID( gamemodeID ) + scriptName );
		
	}
	else {
	
		gamemodeID = 0;
		WriteIniInteger( "INFO.ini", "GAMEMODE", "id", gamemodeID );
		
		print(" - Loading Gamemode || ID: [ " + gamemodeID + " ] || Name: " + getGamemodeNameFromID( gamemodeID ) );
		LoadNUT( getGamemodePathFromID( gamemodeID ) + scriptName );
		
	}
	
	gGamemode = gamemodeID;
	
}
// ----------------------------------------------------
//	Description: Generate a random integer from min to max!
//  Details:
//		@param		start = minimum value
//		@param		(optional) = maximum value
//		@requires 	min <= max
//	Returns: Random integer
//
function Random( start, ... )
{
    local end;
    if ( vargv.len() > 0 ) end = vargv[ 0 ];
    else { end = start; start = 1; }
    local ticks = GetTickCount();
    return start + ( ticks % ( end - start ) );
}
// ----------------------------------------------------
//	Description: Loads a .nut file, and checks for errors!
//  Details:
//		@param		file = path to the file
//		@requires 	file = must be a string
//	Returns: Nothing
//
function LoadNUT( file ) {
	
	local errors = false;
	print ( "Loading " + file );
	try {
		dofile ( file ); 
	} catch ( e )
	if ( e ) {
		errors = true;
		print ( " - " + e );
		print( " - Failed to load "+ file );
		
	}
	if( !errors )
		print( " - Successfully loaded " + file + "." );
}
// ----------------------------------------------------
//	Description: Loads all the modules, and checks for errors
//  Details:
//		@param		file = path to the file
//		@requires 	file = must be a string
//	Returns: Nothing
//
function LoadAllModules() {
	
	local errorINI = false, errorIRC = false;
	print( "Loading Modules...." );
	try {
		LoadModule("sq_ini");
	} catch( e )
	if ( e ) {
	
		errorINI = true;
		print( " - " + e );
		print( " - Failed to load INI module." );
		
	}
	
	try {
		LoadModule("sq_irc");
	} catch( e )
	if ( e ) {
	
		errorIRC = true;
		print( " - " + e );
		print( " - Failed to load IRC module." );
		
	}
	if ( !errorINI && !errorIRC )
		print( "Loaded all Modules!" );
}

function Distance(x1, y1, x2, y2)
{
	local dist = sqrt(((x2 - x1)*(x2 - x1)) + ((y2 - y1)*(y2 - y1)));
	return dist;
}

function Direction(x1, y1, x2, y2)
{
	//all values must be floats.
	x1 = x1.tofloat();
	x2 = x2.tofloat();
	y1 = y1.tofloat();
	y2 = y2.tofloat();
	// Added those ^ just in case you forget :P
	local m = (y2-y1)/(x2-x1);
	if ((m >= 6) || (m <= -6))
	{
		if (y2 > y1) return "North";
		else return "South";
	}
	if ((m < 6) && (m >= 0.5))
	{
		if (y2 > y1) return "North East";
		else return "South West";
	}
	else if ((m < 0.5) && (m > -0.5))
	{
		if (x2 > x1) return "East";
		else return "West";
	}
	else if ((m <= -0.5) && (m > -6))
	{
		if (y2 > y1) return "North West";
		else return "South East";
	}
}

function InRadius(x1, y1, x2, y2, rad)
{
	return (sqrt(((x2 - x1)*(x2 - x1)) + ((y2 - y1)*(y2 - y1))) < rad);
}

// ------------------------------------------------------------------- // ---------------------------------------------------------------------------------

/* //////////////////////
//
// 		 Events
//
/* ////////////////////// */

function onScriptLoad( ) {	

	// Module Loading
	LoadAllModules();
	
	print( "Loading Main.nut.... " );
	// Echo Loading
	LoadNUT( "Scripts/Echo.nut" );
	LoadNUT( "Scripts/EchoCommands.nut" );
	ActivateEcho(); // -> Initialize the Echo
	
	// Gamemode Loading
	LoadGamemode();
	InitializeGamemode();
	
	// Other Scripts
	LoadNUT( "Scripts/Commands.nut" );
	LoadNUT( "Scripts/Events.nut" );
	
}

function onScriptUnload( )
{
	DisconnectBots();
	print( "Script Main.nut has been unloaded." );
}

function onConsoleInput( cmd, text )
{
	if ( cmd == "players" )
	{
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
		if ( buffer ) print( buffer );
		print( "Total players: " + GetPlayers() );
	}
	
	else if ( cmd == "reload" )
	{
		ReloadScripts();
	}
}

function onServerStart() {

	print("Server has started successfully!");
	
}