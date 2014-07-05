/* //////////////////////////////////////////
//
//
//           King of the Hill
//                     base.nut File
//
//
/* ////////////////////////////////////////// */

class Base {
	
	function createBase( x, y, z, base1x, base1y, base1z, base2x, base2y, base2z, name ) {
		
		Name 	 = name;
		Base1 	 = ::Vector( base1x, base1y, base1z );
		Base2 	 = ::Vector( base2x, base2y, base2z );
		Position = ::Vector( x, y, z );
		Interior = 0;
		ID 		 = ::CountIniSection( gDataPath + gBaseFile, "IDS" );
		
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "NAME", name.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "X", x.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "Y", y.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "Z", z.tostring() );
		
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "BASE1_X", Base1.x.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "BASE1_Y", Base1.y.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "BASE1_Z", Base1.z.tostring() );
		
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "BASE2_X", Base2.x.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "BASE2_Y", Base2.y.tostring() );
		::WriteIniString( gDataPath + gBaseFile, ID.tostring(), "BASE2_Z", Base2.z.tostring() );
		
		::WriteIniInteger( gDataPath + gBaseFile, ID.tostring(), "INTERIOR", Interior.tointeger() );
		
		::WriteIniString( gDataPath + gBaseFile, "IDS", ID.tostring(), name.tostring() );
		
		ID 			= null;
		Name 		= null;
		Position 	= null;
		Base1	 	= null;
		Base2		= null;
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
			  
		local b1x = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "BASE1_X" ).tofloat(),
			  b1y = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "BASE1_Y" ).tofloat(),
			  b1z = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "BASE1_Z" ).tofloat(),
			  b2x = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "BASE2_X" ).tofloat(),
			  b2y = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "BASE2_Y" ).tofloat(),
			  b2z = ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "BASE2_Z" ).tofloat();
			  
		Name 		= ::ReadIniString( gDataPath + gBaseFile, ID.tostring(), "NAME" );
		Position 	= ::Vector( x, y, z );
		Base1 		= ::Vector( b1x, b1y, b1z );
		Base2 		= ::Vector( b2x, b2y, b2z );
		Interior 	= ::ReadIniInteger( gDataPath + gBaseFile, ID.tostring(), "INTERIOR" );
			
		return true;
	}
	
	ID 			= null;
	Name 		= null;
	Position 	= null;
	Base1	 	= null;
	Base2		= null;
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
