//-----------------------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------------------

// Password length limits for account creation.
#define ACCOUNT_MIN_PASSWORD_LENGTH (6)
#define ACCOUNT_MAX_PASSWORD_LENGTH (60)

// Invalid database account ID.
#define INVALID_ACCOUNT_ID          (0)

// Player account data variables.
static
        s_PlayerAccountID[MAX_PLAYERS]       = { INVALID_ACCOUNT_ID, ... },
        bool:s_IsPlayerLoggedIn[MAX_PLAYERS] = { false, ...              };

//-----------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------

// Checks whether an account with the player's name already exists in the database.
// This function is used to determine if the player should register or log in.
Account_Check(playerid)
{
    // Initialize the variables here.
    s_PlayerAccountID[playerid] = INVALID_ACCOUNT_ID;
    SetPlayerLoggedIn(playerid, false);    

    new 
        query[128];
    
    mysql_format(g_DatabaseHandle, query, sizeof (query), "SELECT `password_hash` FROM `player_accounts` WHERE `username` = '%e' LIMIT 1;", ReturnPlayerName(playerid));
    mysql_tquery(g_DatabaseHandle, query, "OnPlayerAccountCheck", "d", playerid);

    return 1;
}

// Shows the registration dialog to the player.
Account_ShowRegistrationDialog(playerid, bool:badpass = false)
{
    // Show the dialog.
    ShowPlayerDialog(
        playerid,
        DIALOG_REGISTRATION,
        DIALOG_STYLE_PASSWORD,
        "Registration",
        "Create a password for your new account.\n\n\
        The password must be between %d and %d characters long:",
        "Register",
        "Quit",
        ACCOUNT_MIN_PASSWORD_LENGTH, ACCOUNT_MAX_PASSWORD_LENGTH
    );

    // If `badpass` is true, it means the player's password didn't meet the length
    // requirements, so we show a warning explaining what went wrong.
    if (badpass)
    {
        SendClientMessage(playerid, COLOR_RED, "Sorry, something went wrong. The password you chose is probably too short or too weak.");
        SendClientMessage(playerid, COLOR_RED, "Please choose a stronger password and try again.");
    }

    return 1;
}

// Shows the login dialog to the player.
Account_ShowLoginDialog(playerid)
{
    // Show the dialog.
    ShowPlayerDialog(
        playerid,
        DIALOG_LOGIN,
        DIALOG_STYLE_PASSWORD,
        "Login",
        "Type your password below to login.",
        "Login",
        "Quit"
    );

    return 1;
}

// Validates the player's password length and format.
bool:IsValidPassword(const password[])
{
    // Check if password length is within allowed limits.
    if (!(ACCOUNT_MIN_PASSWORD_LENGTH <= strlen(password) && strlen(password) <= ACCOUNT_MAX_PASSWORD_LENGTH))
    {
        // Password length invalid.
        return false;
    }

    // Additional validations can be added here in the future, such as checking
    // for symbols, uppercase, lowercase letters, etc.

    // Password is valid.
    return true;
}

// Hashes the given password for the specified player.
HashPassword(playerid, const password[])
{
    bcrypt_hash(playerid, "OnPasswordHash", password, BCRYPT_COST);
}

// Creates a new player account in the database.
Account_Create(playerid, const hash[])
{
    new
        query[256];

    mysql_format(g_DatabaseHandle, query, sizeof(query),
        "INSERT INTO `player_accounts` (\
            `username`, \
            `password_hash` \
        ) VALUES ('%e', '%e');",
        ReturnPlayerName(playerid), hash
    );
    mysql_tquery(g_DatabaseHandle, query, "OnPlayerRegister", "d", playerid);
    
    return 1;        
}

// Sets the account ID for the specified player.
SetPlayerAccountID(playerid, accountid)
{
    s_PlayerAccountID[playerid] = accountid;

    return 1;
}

// Returns the player's account ID.
stock GetPlayerAccountID(playerid)
{
    return IsPlayerConnected(playerid)
    ? s_PlayerAccountID[playerid]
    : INVALID_ACCOUNT_ID
    ;
}

// Sets the player's logged-in state.
SetPlayerLoggedIn(playerid, bool:set)
{
    // Ensure the player is connected before modifying state.
    if (!IsPlayerConnected(playerid))
    {
        return 0;
    }

    // Update the player's login state.
    s_IsPlayerLoggedIn[playerid] = set;

    return 1;
}