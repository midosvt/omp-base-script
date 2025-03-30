#include <YSI_Coding/y_hooks>

// -----------------------------------------------------------------------------
// Custom Callback Definitions
// -----------------------------------------------------------------------------

forward public OnPlayerRequestLogin(playerid);

forward public OnPlayerPasswordHash(playerid);
forward public OnPlayerRegister(playerid);

forward public OnPlayerCheckPassword(playerid, bool:correct);
forward public OnPlayerLogin(playerid);

// -----------------------------------------------------------------------------
// Hooked Callbacks
// -----------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
    // Initializing player data on connection is important.
    gPlayerLoginAttempts[playerid] = 0;
    SetPlayerLoggedIn(playerid, false);

    // When a player connects, we run a threaded database query
    // to check if their username exists.  If it's found, they'll
    // need to log in.  If not, they'll have to register an account first.
    new loginQuery[128];
    mysql_format(gDatabaseHandle, loginQuery, sizeof (loginQuery),
        "SELECT * FROM `accounts` \
        WHERE `player_name` = '%e'",
        ReturnPlayerName(playerid)
    );
    mysql_tquery(gDatabaseHandle, loginQuery, "OnPlayerRequestLogin", "i", playerid);

    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_REGISTRATION:
        {
            // Boot the player if they hit "Exit".
            if (!response)
                return Kick(playerid);

            // Make sure password length is valid.
            if (strlen(inputtext) < MIN_PASSWORD_LENGTH || strlen(inputtext) > MAX_PASSWORD_LENGTH)
            {
                // Tell them the requirements.
                SendClientMessage(playerid, COLOR_RED, "Password must be between %i and %i characters.", MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH);
                
                // Let them try again.
                return ShowPlayerRegistrationDialog(playerid);
            }

            // Password checks out - hash it.
            bcrypt_hash(playerid, "OnPlayerPasswordHash", inputtext, BCRYPT_COST);
        }

        case DIALOG_LOGIN:
        {
            // Boot the player if they hit "Exit".
            if (!response)
                return Kick(playerid);

            // Check if the password is correct.
            bcrypt_verify(playerid, "OnPlayerCheckPassword", inputtext, gPlayerPasswordHash[playerid]);
        }
    }

    return 1;
}

// -----------------------------------------------------------------------------
// Custom Callbacks
// -----------------------------------------------------------------------------

public OnPlayerRequestLogin(playerid)
{
    if (cache_num_rows())
    {
        // Retrieve the player's password hash so we can compare it later.
        cache_get_value_name(0, "player_password_hash", gPlayerPasswordHash[playerid]);

        // Show the login dialog since they're registered.
        ShowPlayerLoginDialog(playerid);
    }
    else
    {
        // Do you really want me to explain what this does?
        ShowPlayerRegistrationDialog(playerid);
    }

    return 1;
}

public OnPlayerPasswordHash(playerid)
{
    // Get the generated hash.
    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash, sizeof (hash));

    // Get the player's IP and GPCI.
    new playerIP[16], playerGPCI[41];
    GetPlayerIp(playerid, playerIP);
    GPCI(playerid, playerGPCI);

    // And now insert the account into the database.
    new registerQuery[256];
    mysql_format(gDatabaseHandle, registerQuery, sizeof registerQuery,
        "INSERT INTO `accounts` \
        (`player_name`, `player_password_hash`, `player_ip`, `player_gpci`) \
        VALUES ('%e', '%s', '%e', '%e')",
        ReturnPlayerName(playerid), hash, playerIP, playerGPCI
    );
    mysql_tquery(gDatabaseHandle, registerQuery, "OnPlayerRegister", "i", playerid);

    return 1;
}

public OnPlayerRegister(playerid)
{
    // Get the player's account ID.
    gPlayerAccountID[playerid] = cache_insert_id();

    // Update the player's login flag.
    SetPlayerLoggedIn(playerid, true);

    // Notify the player.
    SendClientMessage(playerid, COLOR_GREEN, "You've successfully registerd an account.");

    return 1;
}

public OnPlayerCheckPassword(playerid, bool:correct)
{
    if (correct)
    {
        // If the password is correct. Log the player in.
        new loginQuery[128];
        mysql_format(gDatabaseHandle, loginQuery, sizeof (loginQuery),
            "SELECT * FROM `accounts` \
            WHERE `player_name` = '%e'",
            ReturnPlayerName(playerid)
        );
        mysql_tquery(gDatabaseHandle, loginQuery, "OnPlayerLogin", "i", playerid);
    }
    else
    {
        // Increment failed login counter.
        gPlayerLoginAttempts[playerid]++;  

        // Check if player hit max allowed attempts.
        if (gPlayerLoginAttempts[playerid] >= MAX_LOGIN_ATTEMPTS)  
        {  
            // Too many fails - boot them.
            return Kick(playerid);
        }  
        else  
        {  
            // Show remaining attempts (with proper pluralization)  
            new triesLeft = MAX_LOGIN_ATTEMPTS - gPlayerLoginAttempts[playerid];  
            SendClientMessage(playerid, COLOR_RED, "You still have %i attempt%s left.", triesLeft, triesLeft == 1 ? ("") : ("s"));

            // Let them try logging in again  
            return ShowPlayerLoginDialog(playerid);  
        }
    }

    return 1;
}

public OnPlayerLogin(playerid)
{
    // Retrieve any data you want.
    cache_get_value_name_int(0, "account_id", gPlayerAccountID[playerid]);

    // Update the flag!
    SetPlayerLoggedIn(playerid, true);

    // Reset the player's login attempts variable.
    gPlayerLoginAttempts[playerid] = 0;

    // Not needed anymore.
    gPlayerPasswordHash[playerid][0] = (EOS);

    // Notify the player.
    SendClientMessage(playerid, COLOR_GREEN, "You've successfully logged in. Welcome back!");

    // Update the IP and GPCI
    new playerIP[16], playerGPCI[41];
    GetPlayerIp(playerid, playerIP);
    GPCI(playerid, playerGPCI);

    // And now insert the account into the database.
    new query[256];
    mysql_format(gDatabaseHandle, query, sizeof query,
        "UPDATE `accounts` SET \
        `player_ip` = '%e', \
        `player_gpci` = '%e' \
        WHERE `account_id` = %d",
        playerIP, playerGPCI, GetPlayerAccountID(playerid)
    );
    mysql_tquery(gDatabaseHandle, query);

    return 1;
}
