// -----------------------------------------------------------------------------
// Definitions
// -----------------------------------------------------------------------------

// Password length requirements (6-60 characters)
#define MIN_PASSWORD_LENGTH (6) 
#define MAX_PASSWORD_LENGTH (60)

// Maximum allowed failed login attempts before kick
#define MAX_LOGIN_ATTEMPTS (3)

// -----------------------------------------------------------------------------
// Data Declarations
// -----------------------------------------------------------------------------

new
    // The player's account database ID
    gPlayerAccountID[MAX_PLAYERS],

    // Contains the player's hashed password
    gPlayerPasswordHash[MAX_PLAYERS][BCRYPT_HASH_LENGTH],

    // Tracks failed login attempts per player
    gPlayerLoginAttempts[MAX_PLAYERS],

    // Login status flag
    bool:gIsPlayerLoggedIn[MAX_PLAYERS]
;
