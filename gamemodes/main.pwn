/*
 * Project:
 * This gamemode is designed to help newcomers get started with Pawn and SA-MP/open.mp in general.
 * It's a "simple" gamemode written by Mido in his free time.
 *
 * Using BlueG's MySQL plugin for data storage and management and Sys's bcrypt plugin for secure password hashing.
 *
 * For more details, check out the README:
 * https://github.com/midosvt/omp-base-script/blob/master/README.md
 *
 * Credits:
 * - SA-MP and open.mp teams (past, present, and future).
 * - Myself (Mido) for developing this gamemode.
 * - BlueG for the MySQL plugin.
 * - Sys for the bcrypt plugin.
 * - Y_Less for the YSI library.
 */

// -----------------------------------------------------------------------------
// Includes and Plugins
// -----------------------------------------------------------------------------

#include <open.mp>
#include <a_mysql>
#include <samp_bcrypt>
#include <YSI_Coding/y_hooks>

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

// Definitions & Utilities
#include "modules/defines/dialogs.pwn"
#include "modules/defines/colors.pwn"

// Server
#include "modules/server/database.pwn"

// Player Account
#include "modules/player/account/data.pwn"
#include "modules/player/account/utils.pwn"
#include "modules/player/account/core.pwn"
