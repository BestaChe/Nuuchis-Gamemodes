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


function onPlayerCommand( player, cmd, text ) {
	
	local params = ( text ? NumTok( text, " " ) : 0 );
	
	if ( cmd == "savepos" ) {
		if ( !player.Name == "Nuuchis" ) PrivMessage( "Error - You must be nuuchis x)", player );
		else if ( !text ) PrivMessage( "Error - Wrong syntax: /c savepos <name>", player );
		else {
			
			local x = player.Pos.x,
				  y = player.Pos.y,
				  z = player.Pos.z,
				  angle = player.Angle;
				  
			WriteIniString( "Scripts/Data/Positions.ini", text, "POSITION", "Vector( " + x + ", " + y + ", " + z + " );" );
			WriteIniString( "Scripts/Data/Positions.ini", text, "ANGLE", "" + angle );
			gameMessage( "Position [ " + text + " ] saved!", player );
		}
	}
	
	else if ( cmd == "addcar" ) {
		if ( !player.Name == "Nuuchis" ) PrivMessage( "Error - You must be nuuchis x)", player );
		else if ( !text ) PrivMessage( "Error - Wrong syntax: /c addcar <name>", player );
		else if ( !GetVehicleModelFromName( text ) ) PrivMessage( "Error - That vehicle does not exist!", player );
		else {
		
			local current = CreateVehicle( GetVehicleModelFromName( text ), Vector( player.Pos.x, player.Pos.y, player.Pos.z ), player.Angle, -1, -1 );
			player.Vehicle = FindVehicle( current.ID );
			gameMessage( "Added vehicle [ " + GetVehicleNameFromModel( current.Model ) + " ][ " + current.ID + " ]", player );
		}
	}
	
	else if ( cmd == "savecar" ) {
		if ( !player.Name == "Nuuchis" ) PrivMessage( "Error - You must be nuuchis x)", player );
		else if ( !player.Vehicle ) PrivMessage( "Error - You need to be inside a vehicle!", player );
		else {
			local x = player.Vehicle.Pos.x,
				  y = player.Vehicle.Pos.y,
				  z = player.Vehicle.Pos.z,
				  angle = player.Vehicle.Angle,
				  model = player.Vehicle.Model,
				  col1  = player.Vehicle.Colour1,
				  col2  = player.Vehicle.Colour2;
				  
			WriteIniString( "Scripts/Data/Vehicles.ini", "VEHICLES", "CreateVehicle( " + model + ", Vector( " + x + ", " + y + ", " + z + " )," +
							" " + angle + ", " + col1 + ", " + col2 + " ); ", GetVehicleNameFromModel( model ) );
			gameMessage( "Vehicle [ " + GetVehicleNameFromModel( model ) + " ] has been saved!", player );
		}
	
	}
	
	else if ( cmd == "gamemode" ) {
	
		Message( "Current Gamemode is: " + getGamemodeNameFromID( gGamemode ) );
		
	}
	
	else if ( cmd == "rules" ) {
	
		Message("Fak u");
	
	}
	
	
	else if ( onPlayerGamemodeCommand( player, cmd, text, params ) );
	else PrivMessage( "Error - Command not found!", player );

}


// ------------------------------------------------------------------- // ---------------------------------------------------------------------------------

/* //////////////////////
//
// 		 Functions
//
/* ////////////////////// */

function gameMessage( text, player ) {
	ClientMessage( text, player, 238, 59, 59 );
}

function getDistance( vector1, vector2 ) {
	return sqrt( ( (vector1.x-vector2.x) ^ 2 ) + ( (vector1.y-vector2.y) ^ 2 ) + ( (vector1.z-vector2.z) ^ 2 ) );
}