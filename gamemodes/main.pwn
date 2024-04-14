/*

    This script is designed to help new PAWN scripters get started quickly.
    It's like a friendly guidebook that covers the basics of starting a very simple script using MYSQL and Bcrypt for password hashing.
    This can be used as a base for your new gamemode.
    
    I'll try my best to keep this script newbie-friendly and will comment things extensively to help everyone understand.
    But you should at least have a basic understanding of how Pawn works.

    CREDITS
    Mido - Creation
    blueG - MYSQL Plugin
    Sys - Bcrypt Plugin

*/

// We are going to define MAX_PLAYERS before including open.mp so we don't have to undef it.
// Change the value to the "Slots" you want.
#define MAX_PLAYERS     28

#include <open.mp>


// MySQL Plugin latest version (R41-4) https://github.com/pBlueG/SA-MP-MySQL/releases/tag/R41-4
#include <a_mysql>  

// Bcrypt for password hashing https://github.com/Sreyas-Sreelal/samp-bcrypt/releases/tag/0.4.0
#include <samp_bcrypt>


// main() is needed as the entry point, without it the mode won't start.
main() {}


// Forwards
forward OnPlayerAccountCheck(playerid);
forward OnPlayerHashPassword(playerid);
forward OnPlayerVerifyPassword(playerid, bool:success);
forward OnPlayerAccountLoad(playerid);
forward OnPlayerFinishRegisteration(playerid);
forward TIMER_DelayedKick(playerid);

// This is going to be our MYSQL connection handle.
new MySQL:dbHandle;

// Default spawn point we're gonna be using. Los Santos Airport.
#define     DEFAULT_POS_X       1643.7200
#define     DEFAULT_POS_Y       -2245.2900
#define     DEFAULT_POS_Z       13.4873
#define     DEFAULT_POS_A       187.2000

// Default skin
#define     DEFAULT_SKIN        188

// The maximum attempts a player has --> Kick the player at 3.
#define MAX_FAIL_LOGINS     3

// PLAYER DATA
enum E_PLAYER_DATA
{
    // Account variables
    pAccountID,
    pName[MAX_PLAYER_NAME + 1],
    PasswordHash[BCRYPT_HASH_LENGTH],
    pBadLogins,
    bool:pLoggedIn,

    // Player variables
    pSkin,
    pScore,
    pKills,
    pDeaths,
    Float:player_pos_x,
    Float:player_pos_y,
    Float:player_pos_z,
    Float:player_pos_angle
};
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];


// DIALOG DATA
enum 
{
    // IDs are automatically given.
    DIALOG_UNUSED,

    DIALOG_REGISTER,

    DIALOG_LOGIN
};


public OnGameModeInit()
{
    // We are going to be using mysql_connect_file to connect to our MySQL server and database,
    // using a INI-like file where all connection credentials and options are specified.
    // NOTE: You CANNOT specify any directories in the file name, the connection file HAS to and MUST be in the open.mp server root folder.
    dbHandle = mysql_connect_file("mysql.ini");


    if(dbHandle == MYSQL_INVALID_HANDLE || mysql_errno(dbHandle) != 0)
    {
        // Our MySQL connection failed.
        print("MYSQL CONNECTION FAILED! Server is shutting down.");

        // Close the server.
        SendRconCommand("exit");

        return 1;
    }

    // MySQL connection succeeded
    print("MYSQL CONNECTION succeeded");

    return 1;
}

public OnGameModeExit()
{
    // Let's not forgot to close our database connection.
    mysql_close(dbHandle);

    return 1;
}

public OnPlayerConnect(playerid)
{
    // Player name
    GetPlayerName(playerid, PlayerData[playerid][pName]);

    // Let's send a query to receive all the stored player data from the 'players' table.
    new szQuery[256];
    mysql_format(dbHandle, szQuery, sizeof (szQuery), "SELECT * FROM `players` WHERE `Name` = '%e' LIMIT 1", PlayerData[playerid][pName]);
    mysql_tquery(dbHandle, szQuery, "OnPlayerAccountCheck", "i", playerid);

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    // It is not possible to get the player's last position in OnPlayerDisconnect if the client crashed.
    // Now, we're gonna get the player's pos and angle before we save the player data.
    if(reason == 1)
    {
        GetPlayerPos(playerid, PlayerData[playerid][player_pos_x], PlayerData[playerid][player_pos_y], PlayerData[playerid][player_pos_z]);
        GetPlayerFacingAngle(playerid, PlayerData[playerid][player_pos_angle]);
    }

    PlayerData[playerid][pBadLogins] = 0;

    // Save the player data.
    SavePlayerData(playerid);

    return 1;
}

public OnPlayerAccountCheck(playerid)
{
    if(cache_num_rows() > 0)
    {
        // An account exists with that name.
        cache_get_value(0, "Hash", PlayerData[playerid][PasswordHash]);

        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Log in", "This account (%s) is registered. Please enter your password in the field below:", "Login", "Cancel", PlayerData[playerid][pName]);
    }
    else
    {
        // That name is not registered. Player needs to register.
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", "Welcome %s, you can register by entering your password in the field below:", "Register", "Cancel", PlayerData[playerid][pName]);
    }

    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_REGISTER:
        {
            // We kick the players that have clicked the 'Cancel' button.
            if(!response) return Kick(playerid);

            // the password must be greater than 5 characters.
            if(strlen(inputtext) <= 5)
            {
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration",
                "{FF0000}Your password must be longer than 5 characters!\n\
                {FFFFFF}Please enter your password in the field below:",
                "Register", "Cancel");
            }
            else
            {
                // Password is good. Hash it.
                bcrypt_hash(playerid, "OnPlayerHashPassword", inputtext, BCRYPT_COST);
            }
        }

        case DIALOG_LOGIN:
        {
            // We kick the players that have clicked the 'Cancel' button.
            if(!response) return Kick(playerid);

            // We're gonna check and see if the password is correct.
            bcrypt_verify(playerid, "OnPlayerVerifyPassword", inputtext, PlayerData[playerid][PasswordHash]);
        }
    }

    return 1;
}

public OnPlayerHashPassword(playerid)
{
    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash, sizeof (hash));

    CallLocalFunction("RegisterAccountForPlayer", "is", playerid, hash);

    return 1;
}

// 'stock' keyword is not needed. Unless, you're going to have this in it's own module.
stock RegisterAccountForPlayer(playerid, const hash[])
{
    new szQuery[256];
    mysql_format(dbHandle, szQuery, sizeof (szQuery), "INSERT INTO `players` (`Name`, `Hash`) VALUES ('%e', '%s')", PlayerData[playerid][pName], hash);
    mysql_tquery(dbHandle, szQuery, "OnPlayerFinishRegisteration", "i", playerid);

    return 1;
}

public OnPlayerFinishRegisteration(playerid)
{
    // Retrieves the ID generated for an AUTO_INCREMENT column by the sent query
    PlayerData[playerid][pAccountID] = cache_insert_id();

    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Registration", "Account successfully registered, and you have been automatically logged in.", "Close", "");

    PlayerData[playerid][pLoggedIn] = true;

    // It's the player's first spawn, so we're going to be using the default spawns we have defined.
    PlayerData[playerid][player_pos_x]      = DEFAULT_POS_X;
    PlayerData[playerid][player_pos_y]      = DEFAULT_POS_Y;
    PlayerData[playerid][player_pos_z]      = DEFAULT_POS_Z;
    PlayerData[playerid][player_pos_angle]  = DEFAULT_POS_A;

    // Default skin
    PlayerData[playerid][pSkin]             = DEFAULT_SKIN;

    // Set the player spawn info such as (Skin, pos, etc...)
    SetSpawnInfo(playerid, NO_TEAM, PlayerData[playerid][pSkin], PlayerData[playerid][player_pos_x], PlayerData[playerid][player_pos_y], PlayerData[playerid][player_pos_z], PlayerData[playerid][player_pos_angle], WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);

    // Spawn the player
    SpawnPlayer(playerid);

    return 1;
}

public OnPlayerVerifyPassword(playerid, bool:success)
{
    if(!success)
    {
        // Password is wrong.
        PlayerData[playerid][pBadLogins] ++;

        // Did the player exceed the maximum login attempts?
        if(PlayerData[playerid][pBadLogins] >= MAX_FAIL_LOGINS)
        {
            // Yes! Kick them.
            DelayedKick(playerid, "Exceed maximum login attempts");

            return 1;
        }

        new attemptsleft = MAX_FAIL_LOGINS - PlayerData[playerid][pBadLogins];
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Log in", "{FF0000}WRONG PASSWORD\n{FF0000}You have %i login attempts left\n\n{FFFFFF}Please enter the password for this account (%s) in the field below.", "Log in", "Close", attemptsleft, PlayerData[playerid][pName]);

    }
    else
    {
        // Password is valid.
        new szQuery[256];
        mysql_format(dbHandle, szQuery, sizeof (szQuery), "SELECT * FROM `players` WHERE `Name` = '%e' LIMIT 1", PlayerData[playerid][pName]);
        mysql_tquery(dbHandle, szQuery, "OnPlayerAccountLoad", "i", playerid);

    }

    return 1;
}

public OnPlayerAccountLoad(playerid)
{
    // Reset the bad login attempts
    PlayerData[playerid][pBadLogins] = 0;

    // Player is logged in now.
    PlayerData[playerid][pLoggedIn] = true;

    cache_get_value_name_int(0, "ID", PlayerData[playerid][pAccountID]);

    cache_get_value_name_int(0, "Skin", PlayerData[playerid][pSkin]);
    cache_get_value_name_int(0, "Score", PlayerData[playerid][pScore]);
    cache_get_value_name_int(0, "Kills", PlayerData[playerid][pKills]);
    cache_get_value_name_int(0, "Deaths", PlayerData[playerid][pDeaths]);

    cache_get_value_name_float(0, "x_pos", PlayerData[playerid][player_pos_x]);
    cache_get_value_name_float(0, "y_pos", PlayerData[playerid][player_pos_y]);
    cache_get_value_name_float(0, "z_pos", PlayerData[playerid][player_pos_z]);
    cache_get_value_name_float(0, "angle_pos", PlayerData[playerid][player_pos_angle]);

    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Login", "You have been successfully logged in.", "Close", "");

    // Player score
    SetPlayerScore(playerid, PlayerData[playerid][pScore]);

    // Set the player spawn info.
    SetSpawnInfo(playerid, NO_TEAM, PlayerData[playerid][pSkin], PlayerData[playerid][player_pos_x], PlayerData[playerid][player_pos_y], PlayerData[playerid][player_pos_z], PlayerData[playerid][player_pos_angle], WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
    
    // Spawn the player.
    SpawnPlayer(playerid);

    return 1;
}

public OnPlayerSpawn(playerid)
{
    // Set the player position to the last saved one
    SetPlayerPos(playerid, PlayerData[playerid][player_pos_x], PlayerData[playerid][player_pos_y], PlayerData[playerid][player_pos_z]);
    SetPlayerFacingAngle(playerid, PlayerData[playerid][player_pos_angle]);

    // Player skin
    SetPlayerSkin(playerid, PlayerData[playerid][pSkin]);

    return 1;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    // Increase deaths count.
    PlayerData[playerid][pDeaths] ++;

    // Increase kills count.
    if(killerid != INVALID_PLAYER_ID)
    {
        PlayerData[killerid][pKills] ++;
    }

    return 1;
}

stock SavePlayerData(playerid)
{
    if(PlayerData[playerid][pLoggedIn] == false) return 0;

    // Player skin
    PlayerData[playerid][pSkin] = GetPlayerSkin(playerid);

    // Player score
    PlayerData[playerid][pScore] = GetPlayerScore(playerid);

    // Pos and Angle
    GetPlayerPos(playerid, PlayerData[playerid][player_pos_x], PlayerData[playerid][player_pos_y], PlayerData[playerid][player_pos_z]);
    GetPlayerFacingAngle(playerid, PlayerData[playerid][player_pos_angle]);

    // Let's save the player data.
    new szQuery[256];
    mysql_format(dbHandle, szQuery, sizeof (szQuery), "UPDATE `players` SET \
    `Skin` = %i,      \
    `Score` = %i,     \
    `Kills` = %i,     \
    `Deaths` = %i,    \
    `x_pos` = %f,     \
    `y_pos` = %f,     \
    `z_pos` = %f,     \
    `angle_pos` = %f  \
    WHERE `ID` = %i",
    PlayerData[playerid][pSkin],
    PlayerData[playerid][pScore],
    PlayerData[playerid][pKills],
    PlayerData[playerid][pDeaths],
    PlayerData[playerid][player_pos_x],
    PlayerData[playerid][player_pos_y],
    PlayerData[playerid][player_pos_z],
    PlayerData[playerid][player_pos_angle],
    PlayerData[playerid][pAccountID]);
    mysql_tquery(dbHandle, szQuery);

    return 1;
}

DelayedKick(playerid, const reason[])
{
    SendClientMessage(playerid, 0xFF0000, "You have been kicked out of the server. Reason: %s.", reason);

    TogglePlayerSpectating(playerid, true);

    SetTimerEx("TIMER_DelayedKick", 2000, false, "i", playerid);

    return 1;

public TIMER_DelayedKick(playerid)
{
    Kick(playerid);

    return 1;
}