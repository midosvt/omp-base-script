// Set the player's login flag
SetPlayerLoggedIn(playerid, bool:set)
{
    if (!IsPlayerConnected(playerid))
    {    
        printf("Error: Cannot set login status for an invalid player!");
        return false;
    }

    // Set
    return gIsPlayerLoggedIn[playerid] = set;
}

// Returns 1 if the player is logged in, otherwise false
bool:IsPlayerLoggedIn(playerid)
{
    // IsPlayerConnected check here is necessary to prevent out
    // of bounds in case INVALID_PLAYER_ID is passed into this function
    return IsPlayerConnected(playerid) && gIsPlayerLoggedIn[playerid];
}

// Get the ID of the player's account in the database
GetPlayerAccountID(playerid)
{
    if (!IsPlayerConnected(playerid))
    {    
        printf("Error: Cannot get account ID of an invalid player!");
        return false;
    }

    return IsPlayerLoggedIn(playerid) ? gPlayerAccountID[playerid] : INVALID_ACCOUNT_ID;
}

// Show the registration dialog to a player
ShowPlayerRegistrationDialog(playerid)
{
    ShowPlayerDialog(playerid,
        DIALOG_REGISTRATION,
        DIALOG_STYLE_INPUT,
        "Registration",
        ""EC_WHITE"Hello, welcome "EC_RED"%s"EC_WHITE". Enter a password so you can register:",
        "Register", "Exit",
        ReturnPlayerName(playerid)
    );

    return 1;
}

// Show the login dialog to a player
ShowPlayerLoginDialog(playerid)
{
    ShowPlayerDialog(playerid,
        DIALOG_LOGIN,
        DIALOG_STYLE_PASSWORD,
        "Login",
        ""EC_WHITE"Hello, welcome back "EC_GREEN"%s"EC_WHITE". Enter your password so you can login:",
        "Login", "Exit",
        ReturnPlayerName(playerid)
    );

    return 1;
}