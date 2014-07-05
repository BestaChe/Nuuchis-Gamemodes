/* //////////////////////////////////////////
//
//
//           Attack and Defence
//                     gamemode.nut File
//
//
/* ////////////////////////////////////////// */


/* //////////////////////
//
// 		 Events
//
/* ////////////////////// */

function InitializeGamemode() {



}

function onPlayerGamemodeCommand( player, cmd, text ) {

	if ( ( cmd == "gamemodeinfo" ) || ( cmd == "gminfo" ) ) {
		Message("blahblah");
	}
	
	else return false;
	return true;
}

function onPlayerGamemodeJoin( player ) {


}

function onPlayerGamemodePart( player, reason ) {


}

function onPlayerGamemodeKill( killer, player, reason, bodypart ) {


}

function onPlayerGamemodeDeath( player, reason ) {


}

function onPlayerRequestGamemodeClass( player, skinid, teamid, globalskinid ) {
    
	
	
}

function onPlayerGamemodeSpawn( player ) {


}

// ------------------------------------------------------------------- // ---------------------------------------------------------------------------------

/* //////////////////////
//
// 		 Functions
//
/* ////////////////////// */