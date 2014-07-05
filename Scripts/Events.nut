/* //////////////////////////////////////////
//
//
//           Main Scripts
//                     Commands.nut File
//
//
/* ////////////////////////////////////////// */


/* //////////////////////
//
// 		 Events
//
/* ////////////////////// */

function onPlayerJoin( player ) {
	
	// Echo Stuff
	EchoMessage( ICOL_BLUE + " >>> [" + ICOL_RED + player.ID + ICOL_BLUE + "] " + player.Name + " has joined the server." );
	
	gameMessage( "Welcome to the server " + player.Name + "!", player );
	gameMessage( "Be sure to check the rules (/c rules)!", player );
	gameMessage( "Current gamemode: [" + getGamemodeNameFromID( gGamemode ) + "]", player );
	
	// Gamemode Stuff
	onPlayerGamemodeJoin( player );

}

function onPlayerPart( player, reason ) {
	
	local sReason;
	switch( reason ) {
		case 0:
			sReason = "Crashed/Timeout";
			break;
		case 1:
			sReason = "Quit";
			break;
		case 2:
			sReason = "Kicked";
			break;
	}
	
	// Echo Stuff
	EchoMessage( ICOL_BLUE + " >>> [" + ICOL_RED + player.ID + ICOL_BLUE + "] " + getTeamIRCColour( player.Team ) + player.Name + ICOL_BLUE + " left the server. Reason: [" + sReason + "]" );
	
	// Gamemode Stuff
	onPlayerGamemodePart( player, reason );
}

function onPlayerKill( killer, player, reason, bodypart ) {
	
	// Echo Stuff
    EchoMessage( ICOL_BLUE + " >>> " + getTeamIRCColour( killer.Team ) + killer.Name + ICOL_BLUE + " [" + ICOL_RED + killer.ID + ICOL_BLUE + "] killed " + getTeamIRCColour( player.Team ) + 
	player.Name + ICOL_BLUE + " [" + ICOL_RED + player.ID + ICOL_BLUE + "] with a " + GetWeaponName( reason ) + " [" + getBodypartName( bodypart ) + "]" );
	
	// Gamemode Stuff
	onPlayerGamemodeKill( killer, player, reason, bodypart );
}

function onPlayerDeath( player, reason )
{
    EchoMessage( ICOL_BLUE + " >>> [" + ICOL_RED + player.ID + ICOL_BLUE + "] " + getTeamIRCColour( player.Team ) + player.Name + ICOL_BLUE + " died." );
	
	// Gamemode Stuff
	onPlayerGamemodeDeath( player, reason );
}

function onPlayerRequestClass( player, skinid, teamid, globalskinid ) {
    
	// Gamemode Stuff
	onPlayerRequestGamemodeClass( player, skinid, teamid, globalskinid );
}

function onPlayerSpawn( player ) {
	
	// Gamemode Stuff
	onPlayerGamemodeSpawn( player );
}

function onPlayerChat( player, text ) {
    
	EchoMessage( ICOL_BLUE + " >>> [" + ICOL_RED + player.ID + ICOL_BLUE + "] " + getTeamIRCColour( player.Team ) + player.Name + ICOL_BLUE + " >> " + ICOL_GREY + text );
	
}

function onPlayerTeamChat( player, team, text ) {
	
	if ( text )
		EchoMessage( getTeamIRCColour( player.Team ) + " >>> [TEAM " + getTeamName( team ).toupper() + "][" + player.ID + "] " + player.Name + " >> " + ICOL_GREY + text );
	
}

// ------------------------------------------------------------------- // ---------------------------------------------------------------------------------

/* //////////////////////
//
// 		 Functions
//
/* ////////////////////// */


function getBodypartName( bodypart ) {
	
	local part;
	
	switch( bodypart ) {
	case 0:
		part = "Body";
		break;
	case 1:
		part = "Torso";
		break;
	case 2:
		part = "Left Arm";
		break;
	case 3:
		part = "Right Arm";
		break;
	case 4:
		part = "Left Leg";
		break;
	case 5:
		part = "Right Leg";
		break;
	case 6:
		part = "Head";
		break;
	default:
		part = "Body";
		break;
	}
	
	return part;
}