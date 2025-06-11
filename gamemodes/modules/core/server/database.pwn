#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------------------

// Stores the current database connection handle.  This handle is used for
// executing all subsequent MySQL operations throughout the gamemode.
new MySQL:g_DatabaseHandle;

// -----------------------------------------------------------------------------
// Hooked Callbacks
// -----------------------------------------------------------------------------

hook OnGameModeInit()
{
    // Attempt to connect to the MySQL server using `mysql_connect_file`.
    // This reads credentials from a plaintext INI file named `mysql.ini`
    // located in the open.mp server root directory (no subfolders allowed).
    //
    // This method is ideal for separating database secrets from the codebase.
    g_DatabaseHandle = mysql_connect_file("mysql.ini");

    // `mysql_errno` returns 0 on success and -1 on failure.
    if (mysql_errno(g_DatabaseHandle) == 0) 
    {
        print("-----------------------------------------------");
        print("Successfully connected to database!");
        print("-----------------------------------------------");
    }
    else 
    {
        print("-----------------------------------------------");
        print("Failed to connect to database!");
        print("Please verify your mysql.ini settings");
        print("Server will be locked for maintenance...");
        print("-----------------------------------------------");

        // Lock down the server to prevent players from joining during DB failure.
        // You can comment these lines if you prefer the server to stay open.
        SendRconCommand("password TvHRY2FmQjXEsCq");
        SendRconCommand("name Server is under maintenance!");
    }

    return 1;
}

hook OnGameModeExit()
{
    // Safely close the database connection when the gamemode unloads.
    mysql_close(g_DatabaseHandle);

    return 1;
}
