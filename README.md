# Introduction
Many players want to create their first SA-MP/open.mp gamemode but struggle to find a good starting point - I was exactly the same. When I first began with SA-MP, I desperately wanted a proper base gamemode to study, tweak, and learn Pawn through practical examples.

After extensive searching, I couldn't find any quality beginner-friendly bases (at least none that met my standards). So I decided to build my own.

# The Goal
My top priority was keeping this gamemode simple and accessible for newcomers. Every design decision was made with beginners in mind.

# Installation
Here's everything you need to get this gamemode up and running.  

## Downloads
You'll need to grab these files first:

- **[open.mp server (latest version)](https://github.com/openmultiplayer/open.mp/releases/latest)**
- **[YSI (latest version)](https://github.com/pawn-lang/YSI-Includes/releases/latest)**
- **[MySQL plugin (R41-4)](https://github.com/pBlueG/SA-MP-MySQL/releases/tag/R41-4)**  
- **[Bcrypt plugin (0.4.1)](https://github.com/Sreyas-Sreelal/samp-bcrypt/releases/tag/0.4.1)**  

## Setup  
1. **open.mp server** → Extract this into your server's *root folder* (main directory).  
2. **YSI library** → Extract this into`qawno/include/`.
3. **MySQL & Bcrypt plugins**:  
   - `.dll`/`.so` files → Place in `plugins/`  
   - Include files (`.inc`) → Place in `qawno/include/`  
4. **MySQL dependencies** (`libmariadb.dll`, `log-core.dll`, etc.) → Drop these directly in your *root folder*.  

## Database
This gamemode uses [`mysql_connect_file`](https://github.com/pBlueG/SA-MP-MySQL/wiki#mysql_connect_file) to establish the database connection through an INI-style configuration file containing all necessary credentials and settings.

An example configuration file can be found here:  
https://github.com/midosvt/omp-base-script/blob/master/db_credentials.ini

Refer to the MySQL plugin documentation (linked above) for all available configuration fields and options.

Download the database structure from here:   
https://github.com/midosvt/omp-base-script/blob/master/database_structure.ini

## Modules
This gamemode uses a modular structure to keep the code organized and manageable. If you're unfamiliar with modular programming, read [this tutorial](https://sampforum.blast.hk/showthread.php?tid=597338&highlight=Modular+programming) before making changes. Stick to this approach—it makes maintenance and editing far easier.

The file structure for this is as follows:

```gamemodes/
│
├── /modules/
│   ├── /defines/              # Definitions & Utilities
│   │   ├── dialogs.pwn        # Dialog IDs definitions
│   │   └── colors.pwn         # Color definitions
│   │
│   ├── /server/               # Server systems
│   │   └── database.pwn       # MySQL connection handler
│   │
│   ├── /player/               # Player systems
│   │   ├── /account/          # Account management
│   │   │   ├── data.pwn       # Player data definitions
│   │   │   ├── utils.pwn      # Helper functions
│   │   │   └── core.pwn       # Main logic (login/register)
│   └── 
│
└── main.pwn                   # Main file
```

# Contributing 
Everyone is welcome to contribute - whether through advice, pull requests, or suggestions. Honestly, there might be some mistakes since I wrote half of this while barely awake.  

If you spot any issues or have improvements to suggest open an issue or discuss it in https://discord.gg/samp

# Thanks
- SA-MP and open.mp teams (past, present, and future).
- Myself (Mido) for developing this gamemode.
- BlueG for the MySQL plugin.
- Sys for the bcrypt plugin.
- Y_Less for the YSI library.