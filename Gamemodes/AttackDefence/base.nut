/* //////////////////////////////////////////
//
//
//           Attack and Defence
//                     base.nut File
//
//
/* ////////////////////////////////////////// */

class Base {
	
	function createBase( x, y, z, atkbase, name ) {
		
		Name = name;
		AttackBase = atkbase;
		Position = ::Vector( x, y, z );
		Interior = 0;
		ID = ::CountIniSection( gDataPath + gBaseFile, "IDS" );
		
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "NAME", name.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "X", x.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "Y", y.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "Z", z.tostring() );
		::WriteIniInteger( gDataPath + gBaseFile, ID.tostring(), "ATTACK", AttackBase.tointeger() );
		::WriteIniInteger( gDataPath + gBaseFile, ID.tostring(), "INTERIOR", Interior.tointeger() );
		
		::WriteIniString( gDataPath + gBaseFile, "IDS", ID.tostring(), name.tostring() );
		
		ID 			= null;
		Name 		= null;
		Position 	= null;
		AttackBase 	= 0;
		Interior 	= 0;
	
	}
	
	function loadBase( id ) {
	
		if ( id > ( ::CountIniSection( gDataPath + gBaseFile, "IDS" ) - 1 ) ) {
			print( "Error - Attempted to load a base that does not exist!" );
			return false;
		}
		
		ID 			= id;
		local x = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "X" ).tofloat(),
		      y = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "Y" ).tofloat(),
			  z = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "Z" ).tofloat();
			  
		Name 		= ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "NAME" );
		Position 	= ::Vector( x, y, z );
		AttackBase 	= ::ReadIniInteger( gDataPath + gBaseFile, ID.tostring(), "ATTACK" );
		Interior 	= ::ReadIniInteger( gDataPath + gBaseFile, ID.tostring(), "INTERIOR" );
			
		return true;
	}
	
	ID 			= null;
	Name 		= null;
	Position 	= null;
	AttackBase 	= 0;
	Interior 	= 0;

}

/* //////////////////////
//
// 		 Events
//
/* ////////////////////// */




// ------------------------------------------------------------------- // ---------------------------------------------------------------------------------

/* //////////////////////
//
// 		 Functions
//
/* ////////////////////// */
