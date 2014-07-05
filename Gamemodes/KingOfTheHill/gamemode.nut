/* //////////////////////////////////////////
//
//
//           King of the Hill
//                     gamemode.nut File
//
//
/* ////////////////////////////////////////// */

const ORANGE_TEAM = 1;
const PURPLE_TEAM = 2;
const CAPTURE_MAXTIME = 15000;
const ROUND_TIME = 450000;

gDataPath <- ( getGamemodePathFromID( 1 ) + "Data/");
gPath	  <- getGamemodePathFromID( 1 );
gBaseNUT  <- "base.nut";
gBaseFile <- "Bases.ini";

purpleBase <- null;
redBase    <- null;

/* //////////////////////
//
// 		 Events
//
/* ////////////////////// */

class Game {

	function decrementPurpleTime() {
		TeamPurple_Time -= 1000;
	}
		
	function decrementRedTime() {
		TeamRed_Time -= 1000;
	}
	
	
	
	Round 				= 1;
	Started 			= false;
	TeamPurple_Time 	= 0;
	TeamRed_Time 		= 0;
	TeamPurple_Timer 	= null;
	TeamRed_Timer 		= null;
	Winner				= null;
	
}

class Capturable {
	
	function create( pos, radius ) {
	
		Pickup = ::CreatePickup( 382, pos );
		PickupRadius = radius;
		PickupPos = pos;
		CapturingTime = CAPTURE_MAXTIME;
		GlobalTimer = ::NewTimer( "checkForCap", 500, 0 );
	}

	function decrementCapturingTime() {
		CapturingTime -= 1000;
	}
	
	Pickup 			= null;
	PickupRadius  	= 0;
	PickupPos 		= null;
	CapturingTime 	= 0;
	Team			= null;
	PlayerID		= null;
	GlobalTimer 	= null;

}

function InitializeGamemode() {
	
	// Game
	KOTH <- Game();
	
	// Pickup
	Point <- Capturable();
	
	// Bases
	LoadNUT( gPath + gBaseNUT );
	BaseClass <- Base();

}

function onPlayerGamemodeCommand( player, cmd, text, params ) {

	if ( ( cmd == "gamemodeinfo" ) || ( cmd == "gminfo" ) ) {
		Message( "The current gamemode is: [King of the Hill]!" );
		Message( "In KOTH there are two teams. Each team has to fight to" );
		Message( "capture the point. When they do, they must defend it," );
		Message( "until the timer reaches zero!" );
	}
	
	else if ( cmd == "addbase" ) {
		if ( !player.Name == "Nuuchis" ) PrivMessage( "Error - You must be Nuuchis!", player );
		else if ( !text ) PrivMessage( "Error - Wrong syntax: /c addbase <name>", player );
		else if ( ( !redBase ) || ( !purpleBase ) ) PrivMessage( "Error - You must set the other bases first!", player );
		else {
			
			local x   = player.Pos.x, y   = player.Pos.y, z   = player.Pos.z;
			local b1x = redBase.x,    b1y = redBase.y,    b1z = redBase.z;
			local b2x = purpleBase.x, b2y = purpleBase.y, b2z = purpleBase.z;
			
			BaseClass.createBase( x, y, z, b1x, b1y, b1z, b2x, b2y, b2z, text );
			gameMessage("Created base: [ " + text + " ] ID: [ " + CountIniSection( gDataPath + gBaseFile, "IDS" ) + " ]" +
						" District: [ " + GetDistrictName( player.Pos.x, player.Pos.y ) + " ]", player );
						
			redBase <- null;
			purpleBase <- null;
			
		}
	}
	
	else if ( cmd == "setredbase" ) {
		if ( !player.Name == "Nuuchis" ) PrivMessage( "Error - You must be Nuuchis!", player );
		else {
			redBase <- player.Pos;
			PrivMessage(">> Red base set!", player );
		}
	}
	
	else if ( cmd == "setpurplebase" ) {
		if ( !player.Name == "Nuuchis" ) PrivMessage( "Error - You must be Nuuchis!", player );
		else {
			purpleBase <- player.Pos;
			PrivMessage(">> Purple base set!", player );
		}
	}
	
	else if ( ( cmd == "startbase" ) || ( cmd == "start" ) ) {
		if ( KOTH.Started ) PrivMessage( "Error - There's already a round going on!", player );
		else {
		
			local baseID;
			
			if ( text ) {
				if ( IsNum( text ) ) {
					if ( BaseClass.loadBase( abs( text.tointeger() ) ) ) {
						baseID = text.tointeger();
					}
					else PrivMessage( "Error - Base ID [ " + abs( text.tointeger() ) + " ] not found!", player );
				}
				else PrivMessage( "Error - Base ID must be a number!", player );
			}
			else {
				baseID = Random( 0, (CountIniSection( gDataPath + gBaseFile, "IDS" )-1) );
			}
			
			if ( baseID ) {
				startRound( abs( baseID ) );
				EMessage( "Round [ " + KOTH.Round + " ] started!" );
				EMessage( "Base [ " + BaseClass.Name + " ] located in [ " + GetDistrictName( BaseClass.Position.x, BaseClass.Position.y ) + " ] loaded!" );
			}
		}
	}
	
	else if ( ( cmd == "endbase" ) || ( cmd == "end" ) ) {
		
		if ( !KOTH.Started ) PrivMessage( "Error - There's no round going on!", player );
		else {
			
			endRound( null );
			EMessage( "Round [ " + KOTH.Round + " ] has been ended by an admin!" );
			EMessage( "The teams have not been swapped!" );
			
		}
	
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
	Announce("~w~" + getTeamName( teamid ), player );
}

function onPlayerGamemodeSpawn( player ) {
	
	if ( KOTH.Started ) {
		player.Health = 100;
		player.Armour = 100;
		player.SetWeapon( 0, 0 );
		player.SetWeapon( 18, 100000 );
		player.SetWeapon( 21, 100000 );
		player.SetWeapon( 26, 100000 );
		
		if ( player.Team == ORANGE_TEAM ) {
			player.Pos = Vector( BaseClass.Base1.x + Random( -5, 5 ), BaseClass.Base1.y + Random( -5, 5 ), BaseClass.Base1.z );
		}
		else {
			player.Pos = Vector( BaseClass.Base2.x + Random( -5, 5 ), BaseClass.Base2.y + Random( -5, 5 ), BaseClass.Base2.z );
		}
		
	}
	else {
		PrivMessage("You spawned in the [ " + getTeamName( player.Team ) + " ] team!", player );
		PrivMessage("Round has not started yet, please wait!", player );
	}

}


// ------------------------------------------------------------------- // ---------------------------------------------------------------------------------

/* //////////////////////
//
// 		 Functions
//
/* ////////////////////// */

function startRound( baseid ) {
	
	BaseClass.loadBase( baseid );
	Point.create( BaseClass.Position, 5 );
	
	teleportAllTeamPlayersTo( ORANGE_TEAM, Vector( BaseClass.Base1.x + Random( -5, 5 ), BaseClass.Base1.y + Random( -5, 5 ), BaseClass.Base1.z ), BaseClass.Interior );
	teleportAllTeamPlayersTo( PURPLE_TEAM, Vector( BaseClass.Base2.x + Random( -5, 5 ), BaseClass.Base2.y + Random( -5, 5 ), BaseClass.Base2.z ), BaseClass.Interior );
	prepareAllPlayers();
	
	KOTH.TeamPurple_Time 	= 180000;
	KOTH.TeamRed_Time 		= 180000;
	KOTH.TeamPurple_Timer 	= NewTimer( "purpleTeamTimer", 1000, 0 );
	KOTH.TeamRed_Timer 		= NewTimer( "orangeTeamTimer", 1000, 0 );
	
	KOTH.TeamPurple_Timer.Stop();
	KOTH.TeamRed_Timer.Stop();
	
	KOTH.Winner				= null;
	KOTH.Started 			= true;
	
}

function endRound( winner ) {
	
	resetAllPlayers();
	resetAnnounceTimer();
	
	KOTH.Started 			= false;
	KOTH.TeamPurple_Time 	= 0;
	KOTH.TeamRed_Time 		= 0;
	
	KOTH.TeamPurple_Timer.Delete();
	KOTH.TeamRed_Timer.Delete();
	KOTH.TeamPurple_Timer 	= null;
	KOTH.TeamRed_Timer 		= null;
	
	removeAllPickups();
	Point.Pickup = null;
	Point.CapturingTime = 0;
	Point.PickupRadius = 0;
	Point.PickupPos = null;
	Point.GlobalTimer.Delete();
	Point.GlobalTimer = null;
	Point.Team = null;
	
	if ( winner ) {
		KOTH.Winner = winner;
		KOTH.Round++;
	}

}

function getTeamName( teamid ) {
	
	local name;
	switch( teamid ) {
	case ORANGE_TEAM:
		name = "Orange";
		break;
	case PURPLE_TEAM:
		name = "Purple";
		break;
	default:
		name = "Wtf";
		break;
	}
	return name;
}

function getTeamColour( teamid ) {

	local colour;
	switch( teamid ) {
	case ORANGE_TEAM:
		colour = 22;
		break;
	case PURPLE_TEAM:
		colour = 5;
		break;
	default:
		colour = 1;
		break;
	}
	return colour;
}

function MessageTeam( teamid, text ) {

	for( local i = 0; i <= GetMaxPlayers(); i++ ) {
		local players = FindPlayer( i );
		if ( players ) {
			if ( players.IsSpawned ) {
				if ( players.Team == teamid ) {
					gameMessage( "[TEAM] " + text, players );
				}
			}
		}
	}
}

function teleportAllTeamPlayersTo( teamid, pos, interior ) {

	for( local i = 0; i <= GetMaxPlayers(); i++ ) {
		local players = FindPlayer( i );
		if ( players ) {
			if ( players.IsSpawned ) {
				if ( players.Team == teamid ) {
					players.Pos = pos;
					players.SetInterior( interior );
				}
			}
		}
	}
}

function removeAllPickups() {

	for( local i = 0; i <= 5; i++ ) {
		local pickups = FindPickup( i );
		if ( pickups ) {
			pickups.Remove();
		}
	}
}

function prepareAllPlayers() {
	
	for( local i = 0; i <= GetMaxPlayers(); i++ ) {
		local players = FindPlayer( i );
		if ( players ) {
			if ( players.IsSpawned ) {
				players.Health = 100;
				players.Armour = 100;
				players.SetWeapon( 0, 0 );
				players.SetWeapon( 18, 100000 );
				players.SetWeapon( 21, 100000 );
				players.SetWeapon( 26, 100000 );
				
				Announce( "--:--", players, 1 );
			}
		}
	}

}

function resetAllPlayers() {
	
	for( local i = 0; i <= GetMaxPlayers(); i++ ) {
		local players = FindPlayer( i );
		if(  players ) {
			if ( players.IsSpawned ) {
			
				if ( players.Vehicle ) {
					players.Pos = players.Pos;
				}
				
				players.IsFrozen = false;
				players.Health = 100;
				players.Armour = 0;
				players.SetWeapon( 0 , 0 );
			}
		}
	}
	
	teleportAllTeamPlayersTo( ORANGE_TEAM, Vector( -1090.78, 1322.52, 34.2411 ), 0 );
	teleportAllTeamPlayersTo( PURPLE_TEAM, Vector( -1090.78, 1322.52, 34.2411 ), 0 );
}

function orangeTeamTimer() {
	
	local buffer;
	local seconds = ( KOTH.TeamRed_Time / 1000 ) % 60;
	local minutes = ( KOTH.TeamRed_Time / 1000 ) / 60;
	
	if ( KOTH.TeamRed_Time >= 0 ) {
		for( local i = 0; i <= GetMaxPlayers(); i++ ) {
			local players = FindPlayer( i );
			if(  players ) {
				if ( minutes.tointeger() < 10 )
					minutes = "0" + minutes;
				if ( seconds.tointeger() < 10 )
					seconds = "0" + seconds;
					
				buffer = minutes + ":" + seconds;
				
				Announce( "~y~" + buffer, players, 1 );
			}
		}
		KOTH.decrementRedTime();
	}
	else {
	
		endRound( ORANGE_TEAM );
		EMessage( "Round [ " + ( KOTH.Round - 1 ) + " ] has been ended!" );
		EMessage( "The winners were: [ " + getTeamName( KOTH.Winner ) + " ]!" );
		
		resetAnnounceTimer();
	}
	
}

function purpleTeamTimer() {
	
	local buffer;
	local seconds = ( KOTH.TeamPurple_Time / 1000 ) % 60;
	local minutes = ( KOTH.TeamPurple_Time / 1000 ) / 60;
	
	if ( KOTH.TeamPurple_Time >= 0 ) {
		for( local i = 0; i <= GetMaxPlayers(); i++ ) {
			local players = FindPlayer( i );
			if(  players ) {
				if ( minutes.tointeger() < 10 )
					minutes = "0" + minutes;
				if ( seconds.tointeger() < 10 )
					seconds = "0" + seconds;
					
				buffer = minutes + ":" + seconds;
				
				Announce( "~p~" + buffer, players, 1 );
			}
		}
		KOTH.decrementPurpleTime();
	}
	else {
	
		endRound( PURPLE_TEAM );
		EMessage( "Round [ " + ( KOTH.Round - 1 ) + " ] has been ended!" );
		EMessage( "The winners were: [ " + getTeamName( KOTH.Winner ) + " ]!" );
		
		resetAnnounceTimer();
	}
	
}

function resetAnnounceTimer() {

	for( local i = 0; i <= GetMaxPlayers(); i++ ) {
		local players = FindPlayer( i );
		if(  players ) {
			if ( players.IsSpawned ) {
				Announce( " ", players, 1 );
			}
		}
	}
}

function getCapturingBar( number, max ) {
	
	local value;
	local buffer;
		
	value = (100-(( number.tofloat() / max.tofloat() )*100));
	
	if ( ( value < 20 ) && ( value >= 0 ) )
		buffer = "-----";
	else if ( ( value < 40 ) && ( value >= 20 ) )
		buffer = "~o~>~y~----";
	else if ( ( value < 60 ) && ( value >= 40 ) )
		buffer = "~o~>>~y~---";
	else if ( ( value < 80 ) && ( value >= 60 ) )
		buffer = "~o~>>>~y~--";
	else if ( ( value < 100 ) && ( value >= 80 ) )
		buffer = "~o~>>>>~y~-";
	else
		buffer = "~o~>>>>>";
	
	for( local i = 0; i <= GetMaxPlayers(); i++ ) {
		local players = FindPlayer( i );
		if(  players ) {
			if ( players.IsSpawned ) {
				Announce( "~y~" + buffer, players, 1 );
			}
		}
	}
	
}

function checkForCap() {

	if ( KOTH.Started ) {
		
		// Capturing
		for( local i = 0; i <= GetMaxPlayers(); i++ ) {
			local players = FindPlayer( i );
			if(  players ) {
				if ( players.IsSpawned ) {
				
					// If there is no player memorized by the pickup
					if ( Point.PlayerID == null ) {
						// If there's someone in the pickup
						if ( InRadius( players.Pos.x, players.Pos.y, Point.PickupPos.x, Point.PickupPos.y, Point.PickupRadius ) && players.Health > 0 ) {
							if ( players.Team != Point.Team ) {
								if ( Point.CapturingTime >= 0 ) {
									KOTH.TeamRed_Timer.Stop();
									KOTH.TeamPurple_Timer.Stop();
									
									Point.PlayerID = players.ID;
									
									Point.decrementCapturingTime();
									
									getCapturingBar( Point.CapturingTime, CAPTURE_MAXTIME );
								}
								else {
									if ( players.Team == ORANGE_TEAM ) {
										KOTH.TeamRed_Timer.Start();
										KOTH.TeamPurple_Timer.Stop();
										Point.Team = ORANGE_TEAM;
									}
									else {
										KOTH.TeamPurple_Timer.Start();
										KOTH.TeamRed_Timer.Stop();
										Point.Team = PURPLE_TEAM;
									}
									EMessage( "Team: [ " + getTeamName( Point.Team ) + " ] has captured the point!" );
									EMessage( getTeamName( Point.Team ) + " countdown started!" );
									
									Point.PlayerID = null;
									Point.CapturingTime = CAPTURE_MAXTIME;
								}
							}
							else {
								Announce( "~w~Already captured", players );
							}
						}
						// else {
							// if ( Point.CapturingTime != CAPTURE_MAXTIME ) {
								// if ( Point.Team == ORANGE_TEAM ) {
									// KOTH.TeamRed_Timer.Start();
									// KOTH.TeamPurple_Timer.Stop();
								// }
								// else if ( Point.Team == PURPLE_TEAM ) {
									// KOTH.TeamPurple_Timer.Start();
									// KOTH.TeamRed_Timer.Stop();
								// }
								// else {
									// Announce( "~w~ --:--", players, 1 );
								// }
						
								// Message("running 2#");
								// Point.PlayerID = null;
								// Point.CapturingTime = CAPTURE_MAXTIME;
							// }
						// }
					}
					
					// There is someone memorized by the pickup
					else {
					
						// If the player's the one memorized by the pickup
						if ( Point.PlayerID == players.ID ) {
							
							// If he is at the pickup
							if ( InRadius( players.Pos.x, players.Pos.y, Point.PickupPos.x, Point.PickupPos.y, Point.PickupRadius ) && players.Health > 0 ) {
								// Pickup counter not 0
								if ( Point.CapturingTime >= 0 ) {
									KOTH.TeamRed_Timer.Stop();
									KOTH.TeamPurple_Timer.Stop();
								
									Point.PlayerID = players.ID;
									
									Point.decrementCapturingTime();
									
									getCapturingBar( Point.CapturingTime, CAPTURE_MAXTIME );
								}
								// Pickup counter is 0
								else {
									if ( players.Team == ORANGE_TEAM ) {
										KOTH.TeamRed_Timer.Start();
										KOTH.TeamPurple_Timer.Stop();
										Point.Team = ORANGE_TEAM;
									}
									else {
										KOTH.TeamPurple_Timer.Start();
										KOTH.TeamRed_Timer.Stop();
										Point.Team = PURPLE_TEAM;
									}
									EMessage( "Team: [ " + getTeamName( Point.Team ) + " ] has captured the point!" );
									EMessage( getTeamName( Point.Team ) + " countdown started!" );
									
									Point.PlayerID = null;
									Point.CapturingTime = CAPTURE_MAXTIME;
								}	
							}
							
							// If there is no player at the pickup
							else {
								if ( Point.CapturingTime != CAPTURE_MAXTIME ) {
									if ( Point.Team == ORANGE_TEAM ) {
										KOTH.TeamRed_Timer.Start();
										KOTH.TeamPurple_Timer.Stop();
									}
									else if ( Point.Team == PURPLE_TEAM ) {
										KOTH.TeamPurple_Timer.Start();
										KOTH.TeamRed_Timer.Stop();
									}
									else {
										Announce( "~w~ --:--", players, 1 );
									}
								
									Message("running 2#");
									Point.PlayerID = null;
									Point.CapturingTime = CAPTURE_MAXTIME;
								}
							}
						}
						else {
							Announce("~w~Someone's capturing", players );
						}
					}
				}
			}
		}
	}
}