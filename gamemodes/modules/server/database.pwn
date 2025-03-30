#include <YSI_Coding/y_hooks>

// -----------------------------------------------------------------------------
// Definitions
// -----------------------------------------------------------------------------

// This is the database connection handle.
new MySQL:gDatabaseHandle;

// -----------------------------------------------------------------------------
// Hooked Callbacks
// -----------------------------------------------------------------------------

hook OnGameModeInit()
{
    // The first thing we're going to do now is try and connect to the
    // MySQL server, using `mysql_connect_file` that connects to the MySQL
    // server and database using an INI-like file where all connection credentials
    // and options are specified.
    //
    // Note: you can't specify any directories in the file name, the
    // connection file has to be in the open.mp server root folder.
    gDatabaseHandle = mysql_connect_file("db_credentials.ini");

    // Check if the database connection was successful.
    // mysql_errno returns 0 for success, -1 for failure.
    if (mysql_errno(gDatabaseHandle) == 0) 
    {
        print("-----------------------------------------------");
        print("Successfully connected to database!");
        print("-----------------------------------------------");
    }
    else 
    {
        print("-----------------------------------------------");
        print("Failed to connect to database!");
        print("Please verify your db_credentials.ini settings");
        print("Server will be locked for maintenance...");
        print("-----------------------------------------------");
        
        // Lock down server - comment these lines out if not needed.
        SendRconCommand("password TvHRY2FmQjXEsCq");
        SendRconCommand("name Server is under maintenance!");
    }

    return 1;
}

hook OnGameModeExit()
{
    // Close the database connection when the gamemode "ends".
    mysql_close(gDatabaseHandle);

    return 1;   
}