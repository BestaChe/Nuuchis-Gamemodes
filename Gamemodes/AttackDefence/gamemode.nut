/* //////////////////////////////////////////
//
//
//           Attack and Defence
//                     gamemode.nut File
//
//
/* ////////////////////////////////////////// */

const ORANGE_TEAM = 1;
const PURPLE_TEAM = 2;
const CAPTURE_MAXTIME = 30000;
const ROUND_TIME = 450000;

gDataPath <- ( getGamemodePathFromID( 0 ) + "Data/");
gPath	  <- getGamemodePathFromID( 0 );
gBaseNUT  <- "base.nut";
gBaseFile <- "Bases.ini";

MAX_PLAYERS <- ceil( GetMaxPlayers()/2 );

class Teams {
	
	/* Methods */
	function setTeams( atk, def ) {
		AttackersTeam = atk;
		DefendersTeam = def;
	}
	
	function swapTeams() {
		local temp = AttackersTeam;
		AttackersTeam = DefendersTeam;
		DefendersTeam = temp;
	}
	
	function addAttacker( id ) {
	
		while( Attackers[AttackersPointer] != null )
			AttackersPointer++;
			
		Attackers[AttackersPointer] = id;
		AttackersCount++;
		AttackersPointer++;
	}
	
	function addDefender( id ) {
	
		while( Defenders[DefendersPointer] != null )
			DefendersPointer++;
			
		Defenders[DefendersPointer] = id;
		DefendersCount++;
		DefendersPointer++;
	}
	
	function removePlayer( id ) {
		if ( ::FindPlayer( id ).Team == AttackersTeam ) {
			for( local i = 0; i <= AttackersCount-1; i++ ) {
				if ( Attackers[i] == id ) {
					Attackers[i] = null;
					AttackersPointer = i;
					AttackersCount--;
					break;
				}
			}
		}
		else {
			for( local i = 0; i <= DefendersCount-1; i++ ) {
				if ( Defenders[i] == id ) {
					Defenders[i] = null;
					DefendersPointer = i;
					DefendersCount--;
					break;
				}
			}
		}
	}
	
	function isInGame( id ) {
		local isIt = false;
		if ( ::FindPlayer( id ).Team == AttackersTeam ) {
			for( local i = 0; i <= AttackersCount-1; i++ ) {
				if ( Attackers[i] == id ) {
					isIt = true;
				}
			}
		}
		else {
			for( local i = 0; i <= DefendersCount-1; i++ ) {
				if ( Defenders[i] == id ) {
					isIt = true;
				}
			}
		}
		return isIt;
	}
	
		/* Atributes */
	AttackersTeam 		= null;
	Attackers 			= array( ::GetMaxPlayers(), null );
	AttackersCount 		= 0;
	AttackersPointer	= 0;
	
	DefendersTeam 		= null;
	Defenders 			= array( ::GetMaxPlayers(), null );
	DefendersCount 		= 0;
	DefendersPointer	= 0;

}

class Game {
	
	function decrementTime() {
		Time -= 1000;
	}
	
	function decrementPreparingTime() {
		PreparingTime -= 1000;
	}
	
	function isInGame( id ) {
		return PlayerArray[id];
	}
	
	function addPlayer( id ) {
		PlayerArray[id] = true;
	}
	
	function removePlayer( id ) {
		PlayerArray[id] = false;
	}
	
	function clearPlayerArray() {
	
		for( local i = 0; i <= ::GetMaxPlayers() - 1; i++ )
			PlayerArray[i] = false;
			
	}
	
	Round 			= 1;
	Started 		= false;
	Time			= 0;
	Timer   		= null;
	Winner 			= null;
	PreparingTime 	= 0;
	PreparingTimer 	= null;
	Preparing 		= false;
	
	AttackersCount 	= 0;
	DefendersCount 	= 0;
	
	PlayerArray 	= array( ::GetMaxPlayers(), false );

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
	PlayerID		= null;
	
	GlobalTimer 	= null;

}

/* //////////////////////
//
// 		 Events
//
/* ////////////////////// */

function InitializeGamemode() {
	
	SetGlobalPickupRespawnTime( 0 );
	SetWeatherRate( 0 );
	
	MainTeams <- Teams();
	MainTeams.setTeams( ORANGE_TEAM, PURPLE_TEAM );
	
	LoadNUT( gPath + gBaseNUT );
	BaseClass <- Base();
	
	AD <- Game();
	
	ADPickup <- Capturable();

}

function onPlayerGamemodeCommand( player, cmd, text, params ) {

	if ( ( cmd == "gamemodeinfo" ) || ( cmd == "gminfo" ) ) {
		Message("The current gamemode is: [Attack and Defence]!");
		Message("In A/D there are two teams. One that attacks and one that defends.");
		Message("The attackers must capture the base or kill all the defenders.");
		Message("The defenders will have to defend their base from the attacker's invasion!");
	}
	
	else if ( cmd == "addbase" ) {
		if ( !player.Name == "Nuuchis" ) PrivMessage( "Error - You must be Nuuchis!", player );
		else if ( params < 2 ) PrivMessage( "Error - Wrong syntax: /c addbase <attackersbase> <name>", player );
		else {
			local attackersBase = GetTok( text, " ", 1 );
			local name;
			switch( params ) {
			case 2:
				name = GetTok( text, " ", 2 );
				break;
			case 3:
				name = GetTok( text, " ", 2, 3 );
				break;
			case 4:
				name = GetTok( text, " ", 2, 3, 4 );
				break;
			default:
				name = GetTok( text, " ", 2, 3, 4 );
				break;
			}
			
			BaseClass.createBase( player.Pos.x, player.Pos.y, player.Pos.z, attackersBase.tointeger(), name.tostring() );
			gameMessage("Created base: [ " + name + " ] ID: [ " + CountIniSection( gDataPath + gBaseFile, "IDS" ) + " ]" +
						" District: [ " + GetDistrictName( player.Pos.x, player.Pos.y ) + " ]", player );
			
		}
	
	}
	
	else if ( ( cmd == "startbase" ) || ( cmd == "start" ) ) {
		if ( AD.Started ) PrivMessage( "Error - There's already a round going on!", player );
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
				EMessage( "Round [ " + AD.Round + " ]: Attackers [ " + getTeamName( MainTeams.AttackersTeam ) + 
						" ] Defenders [ " + getTeamName( MainTeams.DefendersTeam ) + " ]" );
				EMessage( "Base [ " + BaseClass.Name + " ] located in [ " + GetDistrictName( BaseClass.Position.x, BaseClass.Position.y ) + " ] loaded!" );
				PrivMessage( "Weapon sets: /c setslist", player );
				gameMessage( "Choose your set of weapons with: /c set <1/2/3/4/5>", player );
			}
		}
	}
	
	else if ( ( cmd == "endbase" ) || ( cmd == "end" ) ) {
		
		if ( !AD.Started ) PrivMessage( "Error - There's no round going on!", player );
		else {
			
			endRound( null );
			EMessage( "Round [ " + AD.Round + " ] has been ended by an admin!" );
			EMessage( "The teams have not been swapped!" );
			
		}
	
	}
	
	else if ( cmd == "set" ) {
		if ( !AD.Started ) PrivMessage( "Error - There's no round going on!", player );
		else if ( !AD.Preparing ) PrivMessage( "Error - You can only set your list during the preparing time!", player );
		else if ( !text ) PrivMessage( "Error - Wrong syntax: /c set <1/2/3/4/5>", player );
		else if ( !IsNum( text ) ) PrivMessage( "Error - Must be a number!", player );
		else if ( text.tointeger() > 5 || text.tointeger() == 0 ) PrivMessage( "Error - Wrong syntax: /c set <1/2/3/4/5>", player );
		else {
			
			setWeapons( player, text.tointeger() );
		}
	}
	
	else if ( ( cmd == "setslist" ) || ( cmd == "sets" ) ) {
		
		PrivMessage( "Sets:", player );
		PrivMessage( "1 - Python/Stubby/M4", player );
		PrivMessage( "2 - Uzi/Spaz/None", player );
		PrivMessage( "3 - Pistol/Shotgun/M60", player );
		PrivMessage( "4 - Python/Stubby/Grenades", player );
		PrivMessage( "5 - Uzi/Shotgun/Laser Sniper", player );
	
	}
	
	else if ( cmd == "base" ) {
		if ( !AD.Started ) PrivMessage( "Error - There's no round going on!", player );
		else if ( player.Team != MainTeams.AttackersTeam ) PrivMessage( "Error - You must be an attacker!", player );
		else {
		
			local attackersPos = ( BaseClass.AttackBase == 0 ? Vector( -1156.58, -994.363, 14.8677 ) : Vector( 373.851, 891.157, 14.7022 ) );
			
			MessageTeam( MainTeams.AttackersTeam, "Base Name: [ " + BaseClass.Name + " ] District: [ " + GetDistrictName( BaseClass.Position.x, BaseClass.Position.y ) + " ]" );
			MessageTeam( MainTeams.AttackersTeam, "Distance from your base: [ " + Distance( attackersPos.x, attackersPos.y, BaseClass.Position.x, BaseClass.Position.y ) + "m ] " +
					 " Direction: [ " + Direction( attackersPos.x, attackersPos.y, BaseClass.Position.x, BaseClass.Position.y ) + " ] " );
		}
	}
	
	else if ( ( cmd == "distance" ) || ( cmd == "dist" ) ) {
		if ( !AD.Started ) PrivMessage( "Error - There's no round going on!", player );
		else if ( player.Team != MainTeams.AttackersTeam ) PrivMessage( "Error - You must be an attacker!", player );
		else {
			gameMessage( "Your distance to base: [ " + Distance( player.Pos.x, player.Pos.y, BaseClass.Position.x, BaseClass.Position.y ) + "m ] " +
					 " Direction: [ " + Direction( player.Pos.x, player.Pos.y, BaseClass.Position.x, BaseClass.Position.y ) + " ] ", player );
		}
	}
	
	else return false;
	return true;
}

function onPlayerGamemodeJoin( player ) {


}

function onPlayerGamemodePart( player, reason ) {

	if ( MainTeams.isInGame( player.ID ) )
		MainTeams.removePlayer( player.ID );
		
	if ( AD.isInGame( player.ID ) ) {
		if ( player.Team == MainTeams.AttackersTeam ) {
			if ( AD.AttackersCount > 1 ) {
				AD.AttackersCount--;
				AD.removePlayer( player.ID );
				EMessage( "Attackers left: [ " + AD.AttackersCount + " ] Defenders left: [ " + AD.DefendersCount + " ]" );
			}
			else {
				endRound( MainTeams.DefendersTeam );
				EMessage( "No attackers left! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
				EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
				EMessage( "Teams have been swapped!" );
			}
		}
		else if ( player.Team == MainTeams.DefendersTeam ) {
			if ( AD.DefendersCount > 1 ) {
				AD.DefendersCount--;
				AD.removePlayer( player.ID );
				EMessage( "Attackers left: [ " + AD.AttackersCount + " ] Defenders left: [ " + AD.DefendersCount + " ]" );
			}
			else {
				endRound( MainTeams.AttackersTeam );
				EMessage( "No defenders left! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
				EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
				EMessage( "Teams have been swapped!" );
			}
		}
	}
}

function onPlayerGamemodeKill( killer, player, reason, bodypart ) {
	
	if ( AD.isInGame( player.ID ) ) {
		if ( player.Team == MainTeams.AttackersTeam ) {
			if ( AD.AttackersCount > 1 ) {
				AD.AttackersCount--;
				AD.removePlayer( player.ID );
				EMessage( "Attackers left: [ " + AD.AttackersCount + " ] Defenders left: [ " + AD.DefendersCount + " ]" );
			}
			else {
				endRound( MainTeams.DefendersTeam );
				EMessage( "No attackers left! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
				EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
				EMessage( "Teams have been swapped!" );
			}
		}
		else if ( player.Team == MainTeams.DefendersTeam ) {
			if ( AD.DefendersCount > 1 ) {
				AD.DefendersCount--;
				AD.removePlayer( player.ID );
				EMessage( "Attackers left: [ " + AD.AttackersCount + " ] Defenders left: [ " + AD.DefendersCount + " ]" );
			}
			else {
				endRound( MainTeams.AttackersTeam );
				EMessage( "No defenders left! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
				EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
				EMessage( "Teams have been swapped!" );
			}
		}
	}
	
	MainTeams.removePlayer( player.ID );
	
}

function onPlayerGamemodeDeath( player, reason ) {
	
	if ( AD.isInGame( player.ID ) ) {
		if ( player.Team == MainTeams.AttackersTeam ) {
			if ( AD.AttackersCount > 1 ) {
				AD.AttackersCount--;
				AD.removePlayer( player.ID );
				EMessage( "Attackers left: [ " + AD.AttackersCount + " ] Defenders left: [ " + AD.DefendersCount + " ]" );
			}
			else {
				endRound( MainTeams.DefendersTeam );
				EMessage( "No attackers left! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
				EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
				EMessage( "Teams have been swapped!" );
			}
		}
		else if ( player.Team == MainTeams.DefendersTeam ) {
			if ( AD.DefendersCount > 1 ) {
				AD.DefendersCount--;
				AD.removePlayer( player.ID );
				EMessage( "Attackers left: [ " + AD.AttackersCount + " ] Defenders left: [ " + AD.DefendersCount + " ]" );
			}
			else {
				endRound( MainTeams.AttackersTeam );
				EMessage( "No defenders left! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
				EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
				EMessage( "Teams have been swapped!" );
			}
		}
	}
	
	MainTeams.removePlayer( player.ID );

}

function onPlayerRequestGamemodeClass( player, skinid, teamid, globalskinid ) {
    
	if ( MainTeams.AttackersTeam == teamid )
		Announce("~w~" + getTeamName( teamid ) + " \n " + MainTeams.AttackersCount + "/" + MAX_PLAYERS , player );
	else if ( MainTeams.DefendersTeam == teamid )
		Announce("~w~" + getTeamName( teamid ) + " \n " + MainTeams.DefendersCount + "/" + MAX_PLAYERS , player );
	else
		Announce("~w~" + getTeamName( teamid ), player );
		
}

function onPlayerGamemodeSpawn( player ) {
	
	local task = ( player.Team == MainTeams.AttackersTeam ? "Attack" : "Defend" );
	local otherTeam = ( player.Team == ORANGE_TEAM ? PURPLE_TEAM : ORANGE_TEAM );
	
	if ( MainTeams.AttackersTeam == player.Team ) {
		if ( MainTeams.AttackersCount < MAX_PLAYERS ) {
			if ( !MainTeams.isInGame( player.ID ) )
				MainTeams.addAttacker( player.ID );
				
			PrivMessage("You spawned in the [ " + getTeamName( player.Team ) + " ] team!", player );
			PrivMessage("You will [ " + task + " ] the/from [ " + getTeamName( otherTeam ) + " ] team, in this round!", player );
			PrivMessage("Number of players in [ " + getTeamName( player.Team ) + " ]: [ " + MainTeams.AttackersCount + "/" + MAX_PLAYERS + " ]", player );
		}
		else {
			player.Health = 0;
			PrivMessage("Sorry, you can't spawn in the [ " + getTeamName( player.Team ) + " ] team. It's full at the moment.", player );
		}
	}
	else if ( MainTeams.DefendersTeam == player.Team ) {
		if ( MainTeams.DefendersCount < MAX_PLAYERS ) {
			if ( !MainTeams.isInGame( player.ID ) )
				MainTeams.addDefender( player.ID );
			
			PrivMessage("You spawned in the [ " + getTeamName( player.Team ) + " ] team!", player );
			PrivMessage("You will [ " + task + " ] the/from [ " + getTeamName( otherTeam ) + " ] team, in this round!", player );
			PrivMessage("Number of players in [ " + getTeamName( player.Team ) + " ]: [ " + MainTeams.DefendersCount + "/" + MAX_PLAYERS + " ]", player );
		}
		else {
			player.Health = 0;
			PrivMessage("Sorry, you can't spawn in the [ " + getTeamName( player.Team ) + " ] team. It's full at the moment.", player );
		}
	}

}

// ------------------------------------------------------------------- // ---------------------------------------------------------------------------------

/* //////////////////////
//
// 		 Functions
//
/* ////////////////////// */

function createAttackersSouthBaseVehicles() {

	local col = getTeamColour( MainTeams.AttackersTeam ); // FOR NOW

	CreateVehicle( 217, Vector( -1178.74, -1008.67, 14.8499 ), 267.988, col, col );
	CreateVehicle( 143, Vector( -1182.3, -986.201, 15.0661 ), 269.043, col, col );
	CreateVehicle( 135, Vector( -1132.31, -1012.84, 14.6589 ), 89.9885, col, col );
	CreateVehicle( 135, Vector( -1132.6, -1022.36, 14.6968 ), 88.7451, col, col );
	CreateVehicle( 191, Vector( -1141.64, -993.67, 14.3938 ), 89.2723, col, col );
	CreateVehicle( 191, Vector( -1141.71, -996.76, 14.4154 ), 90.9798, col, col );
	CreateVehicle( 198, Vector( -1141.3, -990.412, 14.5022 ), 89.2551, col, col );
	CreateVehicle( 141, Vector( -1132.26, -984.096, 14.5594 ), 89.278, col, col );

}

function createAttackersNorthBaseVehicles() {

	local col = getTeamColour( MainTeams.AttackersTeam ); // FOR NOW

	CreateVehicle( 217, Vector( 355.179, 891.944, 25.4482 ), 173.668, col, col );
	CreateVehicle( 135, Vector( 353.26, 916.954, 14.5292 ), 260.549, col, col );
	CreateVehicle( 143, Vector( 352.42, 912.492, 14.9044 ), 262.554, col, col );
	CreateVehicle( 191, Vector( 369.355, 913.682, 14.2241 ), 81.06, col, col );
	CreateVehicle( 191, Vector( 368.967, 910.549, 14.2262 ), 83.8576, col, col );
	CreateVehicle( 198, Vector( 368.353, 907.705, 14.3351 ), 85.0032, col, col );
	CreateVehicle( 135, Vector( 353.253, 900.774, 14.5309 ), 262.403, col, col );
	CreateVehicle( 141, Vector( 353.448, 906.337, 14.3928 ), 264.871, col, col );

}

function deleteAllVehicles() {

	for( local i = 0; i <= 30; i++ ) {
		local vehicles = FindVehicle( i );
		if( vehicles ) {
			vehicles.Remove();
		}
	}
}

function startRound( baseid ) {
	

	BaseClass.loadBase( baseid );
	switch( BaseClass.AttackBase ) {
	case 0:
		createAttackersSouthBaseVehicles();
		break;
	case 1:
		createAttackersNorthBaseVehicles();
		break;
	}
	local attackersPos = ( BaseClass.AttackBase == 0 ? Vector( -1156.58, -994.363, 14.8677 ) : Vector( 373.851, 891.157, 14.7022 ) );
	local defendersPos = BaseClass.Position;
	
	AD.Time = ROUND_TIME;
	AD.Timer = NewTimer( "mainGameTimer", 1000, 0 );
	AD.Timer.Stop();
	
	teleportAllTeamPlayersTo( MainTeams.AttackersTeam, Vector( attackersPos.x + Random( -5, 5 ), attackersPos.y + Random( -5, 5 ), attackersPos.z ), 0 );
	teleportAllTeamPlayersTo( MainTeams.DefendersTeam, Vector( defendersPos.x + Random( -5, 5 ), defendersPos.y + Random( -5, 5 ), defendersPos.z ), BaseClass.Interior );
	prepareAllPlayers();
	
	AD.AttackersCount = MainTeams.AttackersCount;
	AD.DefendersCount = MainTeams.DefendersCount;
	
	AD.Preparing = true;
	AD.PreparingTime = 10*1000;
	AD.PreparingTimer = NewTimer( "preparingTimer", 1000, 0 );
	
	ADPickup.create( BaseClass.Position, 5 );
	
	AD.Winner = null;
	AD.Started = true;
	
}

function endRound( winner ) {
	
	resetAllPlayers();
	deleteAllVehicles();
	resetAnnounceTimer();
	
	AD.AttackersCount = 0;
	AD.DefendersCount = 0;
	AD.Time = 0;
	AD.Timer.Delete();
	AD.Timer = null;
	AD.PreparingTime = 0;
	AD.PreparingTimer.Delete();
	AD.PreparingTimer = null;
	AD.Started = false;
	
	removeAllPickups();
	ADPickup.Pickup = null;
	ADPickup.CapturingTime = 0;
	ADPickup.PickupRadius = 0;
	ADPickup.PickupPos = null;
	ADPickup.GlobalTimer.Delete();
	ADPickup.GlobalTimer = null;
	ADPickup.PlayerID = null;
	
	if ( winner ) {
		AD.Winner = winner;
		AD.Round++;
		MainTeams.swapTeams();
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
		if(  players ) {
			if ( players.IsSpawned ) {
				players.Health = 100;
				players.Armour = 100;
				players.IsFrozen = true;
				setWeapons( players, 1 );
				AD.addPlayer( players.ID );
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
	
	teleportAllTeamPlayersTo( MainTeams.AttackersTeam, Vector( -1090.78, 1322.52, 34.2411 ), 0 );
	teleportAllTeamPlayersTo( MainTeams.DefendersTeam, Vector( -1090.78, 1322.52, 34.2411 ), 0 );
	AD.clearPlayerArray();
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

function mainGameTimer() {
	
	local buffer;
	local seconds = ( AD.Time / 1000 ) % 60;
	local minutes = ( AD.Time / 1000 ) / 60;
	
	if ( AD.Time >= 0 ) {
		for( local i = 0; i <= GetMaxPlayers(); i++ ) {
			local players = FindPlayer( i );
			if(  players ) {
				if ( players.IsSpawned ) {
				
					if ( minutes.tointeger() < 10 )
						minutes = "0" + minutes;
					if ( seconds.tointeger() < 10 )
						seconds = "0" + seconds;
						
					buffer = minutes + ":" + seconds;
					
					if ( minutes.tointeger() > 0 )
						Announce( buffer, players, 1 );
					else
						Announce( "~y~" + buffer, players, 1 );
				}
			}
		}
		AD.decrementTime();
	}
	else {
	
		endRound( MainTeams.DefendersTeam );
		EMessage( "Defending time ended! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
		EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
		EMessage( "Teams have been swapped!" );
		
		resetAnnounceTimer();
	}
	
}

function preparingTimer() {

	local buffer;
	local seconds = ( AD.PreparingTime / 1000 ) % 60;
	local minutes = ( AD.PreparingTime / 1000 ) / 60;
	
	if ( AD.PreparingTime >= 0 ) {
		for( local i = 0; i <= GetMaxPlayers(); i++ ) {
			local players = FindPlayer( i );
			if(  players ) {
				if ( players.IsSpawned ) {
				
					if ( minutes.tointeger() < 10 )
						minutes = "0" + minutes;
					if ( seconds.tointeger() < 10 )
						seconds = "0" + seconds;
						
					buffer = ">" + minutes + ":" + seconds;
					Announce( "~b~" + buffer, players, 1 );
				}
			}
		}
		AD.decrementPreparingTime();
	}
	else {
	
		for( local i = 0; i <= GetMaxPlayers(); i++ ) {
			local players = FindPlayer( i );
			if(  players ) {
				if ( players.IsSpawned ) {
					players.IsFrozen = false;
				}
			}
		}
		
		AD.Preparing = false;
		AD.PreparingTimer.Stop();
		AD.Timer.Start();
		EMessage(" >>>> Round has started <<<< " );
	}

}

function setWeapons( player, id ) {

	switch( id ) {
	case 1:
		player.SetWeapon( 0, 0 );
		player.SetWeapon( 18, 100000 );
		player.SetWeapon( 21, 100000 );
		player.SetWeapon( 26, 100000 );
		gameMessage( "You are now using set 1 (Python/Stubby/M4)", player );
		break;
	case 2:
		player.SetWeapon( 0, 0 );
		player.SetWeapon( 23, 100000 );
		player.SetWeapon( 20, 150 );
		gameMessage( "You are now using set 2 (Uzi/Spaz)", player );
		break;
	case 3:
		player.SetWeapon( 0, 0 );
		player.SetWeapon( 17, 100000 );
		player.SetWeapon( 19, 100000 );
		player.SetWeapon( 32, 100000 );
		gameMessage( "You are now using set 3 (Pistol/Shotgun/M60)", player );
		break;
	case 4:
		player.SetWeapon( 0, 0 );
		player.SetWeapon( 18, 100000 );
		player.SetWeapon( 21, 100000 );
		player.SetWeapon( 12, 3 );
		gameMessage( "You are now using set 4 (Python/Stubby/Grenades)", player );
		break;
	case 5:
		player.SetWeapon( 0, 0 );
		player.SetWeapon( 23, 100000 );
		player.SetWeapon( 19, 100000 );
		player.SetWeapon( 29, 100000 );
		gameMessage( "You are now using set 5 (Uzi/Shotgun/Laser Sniper)", player );
		break;
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

	if ( AD.Started ) {
		
		// Capturing
		for( local i = 0; i <= GetMaxPlayers(); i++ ) {
			local players = FindPlayer( i );
			if(  players ) {
				if ( players.Team == MainTeams.AttackersTeam ) {
					if ( players.IsSpawned ) {
						if ( !ADPickup.PlayerID ) {
							if ( InRadius( players.Pos.x, players.Pos.y, ADPickup.PickupPos.x, ADPickup.PickupPos.y, ADPickup.PickupRadius ) && players.Health > 0 ) {
								if ( ADPickup.CapturingTime >= 0 ) {
									AD.Timer.Stop();
									ADPickup.PlayerID = players.ID;
									
									ADPickup.decrementCapturingTime();
									
									getCapturingBar( ADPickup.CapturingTime, CAPTURE_MAXTIME );
								}
								else {
									endRound( MainTeams.AttackersTeam );
									EMessage( "Base has been captured! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
									EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
									EMessage( "Teams have been swapped!" );
								}
							}
							else {
								AD.Timer.Start();
								ADPickup.PlayerID = null;
								ADPickup.CapturingTime = CAPTURE_MAXTIME;
							}
						}
						else {
							if ( ADPickup.PlayerID == players.ID ) {
								if ( InRadius( players.Pos.x, players.Pos.y, ADPickup.PickupPos.x, ADPickup.PickupPos.y, ADPickup.PickupRadius ) && players.Health > 0 ) {
									if ( ADPickup.CapturingTime >= 0 ) {
										AD.Timer.Stop();
									
										ADPickup.decrementCapturingTime();
									
										getCapturingBar( ADPickup.CapturingTime, CAPTURE_MAXTIME );
									}
									else {
										endRound( MainTeams.AttackersTeam );
										EMessage( "Base has been captured! Round [ " + ( AD.Round - 1 ) + " ] has been ended!" );
										EMessage( "The winners were: [ " + getTeamName( AD.Winner ) + " ]!" );
										EMessage( "Teams have been swapped!" );
									}
								}
								else {
									AD.Timer.Start();
									ADPickup.PlayerID = null;
									ADPickup.CapturingTime = CAPTURE_MAXTIME;
								}
							}
						}
					}
				}
			}
		}
	}
}