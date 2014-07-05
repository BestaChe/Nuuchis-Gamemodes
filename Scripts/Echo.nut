/*
	Squirrel IRC Bot - Version 1
*/

const ICOL_WHITE    = "\x000300";
const ICOL_BLACK    = "\x000301";
const ICOL_BLUE     = "\x000302";
const ICOL_GREEN    = "\x000303";
const ICOL_RED      = "\x000304";
const ICOL_BROWN    = "\x000305";
const ICOL_PURPLE   = "\x000306";
const ICOL_ORANGE   = "\x000307";
const ICOL_YELLOW   = "\x000308";
const ICOL_LGREEN   = "\x000309";
const ICOL_CYAN     = "\x000310";
const ICOL_LCYAN    = "\x000311";
const ICOL_LBLUE    = "\x000312";
const ICOL_PINK     = "\x000313";
const ICOL_GREY     = "\x000314";
const ICOL_LGREY    = "\x000315";
const ICOL          = "\x0003";
const ICOL_BOLD     = "\x0002";
const ICOL_ULINE    = "\x0031";
const IWHITE    = "\x000300";
const IBLACK    = "\x000301";
const IBLUE     = "\x000302";
const IGREEN    = "\x000303";
const IRED      = "\x000304";
const IBROWN    = "\x000305";
const IPURPLE   = "\x000306";
const IORANGE   = "\x000307";
const IYELLOW   = "\x000308";
const ILGREEN   = "\x000309";
const ICYAN     = "\x000310";
const ILCYAN    = "\x000311";
const ILBLUE    = "\x000312";
const IPINK     = "\x000313";
const IGREY     = "\x000314";
const ILGREY    = "\x000315";
const ICOL      = "\x0003";
const IBOLD     = "\x0002";
const IULINE    = "\x0031";

const FBS_NICK 		= "Shauwau"; 	// The name of the echo bot
//const FBS_NICK2 	= "Bass"; 	// The name of the echo bot 2
const FBS_BPASS 	= ""; 		// The NickServ password of the echo bot
const FBS_SERVER 	= "5.135.152.192"; // The numerical ip of the irc server - this will join irc.nl.project-apollo.co.uk
const FBS_PORT 		= 6667;		// The port for that irc server
const FBS_CHAN 		= "#dnb"; 	// The channel that you wont your echo bot to join
const FBS_CPASS 	= ""; 		// The password for that channel, if there isnt one leave it as "".

//IRC_TURN <- 1;

alreadyProcessed <- false;

class FBSLIST
{
	// This is how we are going to store the user level information for each nick currently on the channel
	Name = null;
	Level = 1;
}

function FBSLIST::AddNick( szNick, iAdmin )
{
	Name = szNick;
	Level = iAdmin;
}

function ActivateEcho()
{
	print( "  - Confirming echo bot details..." );
	FBS_BOT <- NewSocket( "FBSProcess" );

	FBS_BOT.Connect( FBS_SERVER, FBS_PORT );
	FBS_BOT.SetNewConnFunc( "FBSLogin" );
	
	// FBS_BOT2 <- NewSocket( "FBSProcess" );

	// FBS_BOT2.Connect( FBS_SERVER, FBS_PORT );
	// FBS_BOT2.SetNewConnFunc( "FBSLogin" );
	print( "  - Bot details confirmed!" );
	
	FBS_NICKS <- array( 50, null );
}

function DisconnectBots()
{
	print( "  - Disconnecting bot from IRC..." );
	
	FBS_BOT.Send( "QUIT " + FBS_NICK + "\n" );
	FBS_BOT.Delete();
	
	// FBS_BOT2.Send( "QUIT " + FBS_NICK + "\n" );
	// FBS_BOT2.Delete();
	
	// print( FBS_NICK + " and " + FBS_NICK2 + " have succesfully disconnected from IRC." );
	print( FBS_NICK + " succesfully disconnected from IRC." );
}

function FBSLogin()
{
	print( "  - Attempting to set user, nick and mode...." );
	// Set the bots name and real name
	FBS_BOT.Send( "USER " + FBS_NICK + " 0 * :FBS Squirrel - Version 1 Echo Bot\n" );
	// Set the nick that the bot will use on the irc server
	FBS_BOT.Send( "NICK " + FBS_NICK + "\n" );
	// Set it so that the network classes the bot as a bot
	FBS_BOT.Send( "MODE " + FBS_NICK + " +B\n" );
	
	// // Set the bots name and real name
	// FBS_BOT2.Send( "USER " + FBS_NICK2 + " 0 * :FBS Squirrel - Version 1 Echo Bot\n" );
	// // Set the nick that the bot will use on the irc server
	// FBS_BOT2.Send( "NICK " + FBS_NICK2 + "\n" );
	// // Set it so that the network classes the bot as a bot
	// FBS_BOT2.Send( "MODE " + FBS_NICK2 + " +B\n" );
	print( "  - Task completed successfully." );
}

function FBSProcess( sz )
{
	// This function is used to process the raw data that the bot is recieving from the irc server	
  local raw = split( sz, "\r\n" ), a, z = raw.len(), line;
	
	for ( a = 0; a < z; a++ )
	{
		line = raw[ a ];
		
		local FBS_PING = GetTok( line, " ", 1 ), FBS_EVENT = GetTok( line, " ", 2 ), FBS_CHANEVENT = GetTok( line, " ", 3 ), 
		Count = NumTok( line, " " ), Nick, Command, Prefix, Text;

		// The most important thing is making sure that the bot stays connected to IRC
		if ( FBS_PING ) { FBS_BOT.Send( "PONG " + FBS_PING + "\n" ); } // FBS_BOT2.Send( "PONG " + FBS_PING + "\n" ); }
		
		if ( FBS_EVENT == "001" )
		{
			if ( FBS_BOT )
			{
				// Identify the bot with services, comment this line if its not registered
				FBS_BOT.Send( "PRIVMSG NickServ IDENTIFY " + FBS_BPASS + "\n" ); 
				// Set it so that the network classes the bot as a bot
				FBS_BOT.Send( "MODE " + FBS_NICK + " +B\n" );
				// Make the bot join the specified channel
				FBS_BOT.Send( "JOIN " + FBS_CHAN + " " + FBS_CPASS + "\n" ); 
				// The bot now needs to collect information about users in the channel
				
				// // Identify the bot with services, comment this line if its not registered
				// FBS_BOT2.Send( "PRIVMSG NickServ IDENTIFY " + FBS_BPASS + "\n" ); 
				// // Set it so that the network classes the bot as a bot
				// FBS_BOT2.Send( "MODE " + FBS_NICK + " +B\n" );
				// // Make the bot join the specified channel
				// FBS_BOT2.Send( "JOIN " + FBS_CHAN + " " + FBS_CPASS + "\n" ); 
				// // The bot now needs to collect information about users in the channel
				print( "  - Succesfully joined " + FBS_CHAN + "!" );
			}
		}
		else if ( FBS_EVENT == "353" ) FBSSortNicks( sz );
		else if ( ( FBS_EVENT == "MODE" ) || ( FBS_EVENT == "NICK" ) || ( FBS_EVENT == "JOIN" ) || ( FBS_EVENT == "PART" ) || ( FBS_EVENT == "QUIT" ) ) FBS_BOT.Send( "NAMES :" + FBS_CHAN + "\n" );
		if ( FBS_CHANEVENT == FBS_CHAN )
		{
			// Grab the nick
			Nick = GetTok( line, "!", 1 ).slice( 1 );
			// Figure out what the command is
			Command = GetTok( line, " ", 4 );
			// Figure out what prefix was used
			Prefix = Command.slice( 1, 2 );
			Command = Command.slice( 2 );
			
			// Figure out the text after the command
			if ( NumTok( line, " " ) > 4 ) Text = GetTok( line, " ", 5, Count );
			else Command = split( Command, "\r\n" )[ 0 ];
		  
			if ( Prefix == "." ) {
				if ( Command && Text )
					IrcSay( Nick, Command +  " " + Text );
				else
					IrcSay( Nick, Command );
			}
			// Parse the command
			if ( ( Prefix == "!" ) && ( Count > 4 ) ) FBSIrcCommand( Nick, Command.tolower(), Text );
			else if ( ( Prefix == "!" ) && ( Count == 4 ) ) FBSIrcCommand( Nick, Command.tolower(), null );
		}
	}
}

function IrcSay( user, text ) {

	local NickInfo = FindNick( user ), level, tLevel;
	if ( NickInfo ) level = NickInfo.Level.tointeger();
	
	if ( level > 3 ) ::EMessage( "* Admin " + user + ": " + text );
	else if ( level == 3 ) ::EMessage( "* Moderator " + user + ": " + text );
	else ::EMessage( user + ": " + text );

}

function FBSIrcCommand( user, cmd, text )
{
	// none of this needs to be touched, it is to do with getting channel levels
	local NickInfo = FindNick( user ), level, tLevel;
	
	if ( NickInfo ) level = NickInfo.Level.tointeger();
	//---------------------------------------------------------------------------
	
	onIRCCommand( user, cmd, text, level );
}

function EMessage( text )
{
	// EMessage is to be used when you want to send the Message function and have it echoed back to your echo channel
	Message( text );
	EchoMessage( ICOL_BLUE + text );
}

// function oneBotMessage( text, bot ) {

	// text = ( !text ? "" : text );
	// if ( bot == 1 )
		// FBS_BOT.Send( "PRIVMSG " + FBS_CHAN + " " + text + "\n" );
	// else
		// FBS_BOT2.Send( "PRIVMSG " + FBS_CHAN + " " + text + "\n" );
// }

function EchoMessage( text )
{
	// This is used for events such as a player joining
	// EchoMessage( "** [" + player.ID + "] " + player + " has joined the server." );
	text = ( !text ? "" : text );
	FBS_BOT.Send( "PRIVMSG " + FBS_CHAN + " " + text + "\n" );
	
	
	// switch( IRC_TURN ) {
	// case 1:
		// FBS_BOT.Send( "PRIVMSG " + FBS_CHAN + " " + text + "\n" );
		// IRC_TURN = 2;
		// break;
	// case 2:
		// FBS_BOT2.Send( "PRIVMSG " + FBS_CHAN + " " + text + "\n" );
		// IRC_TURN = 1;
		// break;
	// default:
		// FBS_BOT2.Send( "PRIVMSG " + FBS_CHAN + " " + text + "\n" );
		// IRC_TURN = 1;
		// break;
	// }
	
}

/*  The following functions below are to do with parsing nick information and levels
	DO NOT TOUCH ANYTHING BELOW THIS LINE.......EVER!
*/

function FBSSortNicks( szList )
{
	local a = NumTok( szList, " " );
	local NickList = GetTok( szList, " ", 6, a ), i = 1;
	
	FBS_NICKS <- array( 50, null );
	
	while( GetTok( NickList, " ", i ) != "366" )
	{
		local levelnick = GetTok( NickList, " ", i ), nick = levelnick.slice( 1 ), level = levelnick.slice( 0, 1 );
		
		if ( level == ":" ) { level = nick.slice( 0, 1 ); nick = nick.slice( 1 ); }
				
		if ( level == "+" ) AddNewNick( nick, 2 );
		else if ( level == "%" ) AddNewNick( nick, 3 );
		else if ( level == "@" ) AddNewNick( nick, 4 );
		else if ( level == "&" ) AddNewNick( nick, 5 );
		else if ( level == "~" ) AddNewNick( nick, 6 );
		else AddNewNick( nick, 1 );
		i ++;
	}
}

function AddNewNick( szName, iLevel )
{
	local i = FindFreeNickSlot();
	
	if ( i != -1 ) 
	{
		FBS_NICKS[ i ] = FBSLIST();
		FBS_NICKS[ i ].AddNick( szName, iLevel );
	}
}

function FindFreeNickSlot()
{
	for ( local i = 0; i < FBS_NICKS.len(); i++ )
	{
		if ( !FBS_NICKS[ i ] ) return i;
	}
	return -1;
}

function FindNick( szName )
{	
	for ( local i = 0; i < FBS_NICKS.len(); i++ )
	{
		if ( FBS_NICKS[ i ] )
		{
			if ( FBS_NICKS[ i ].Name == szName ) return FBS_NICKS[ i ];
		}
	}
	return null;
}

function GetTok(string, separator, n, ...)
{
	local m = vargv.len() > 0 ? vargv[0] : n,
		  tokenized = split(string, separator),
		  text = "";
	
	if (n > tokenized.len() || n < 1) return null;
	for (; n <= m; n++)
	{
		text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
	}
	return text;
}

function NumTok(string, separator)
{
	local tokenized = split(string, separator);
	return tokenized.len();
}

function getTeamIRCColour( teamid ) {
	switch( teamid ) {
	case 1:
		return ICOL_ORANGE;
	case 2:
		return ICOL_PURPLE;
	default:
		return ICOL_WHITE;
	}
}