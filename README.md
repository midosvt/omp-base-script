# Introduction
Hi.  Lots of people want to create their first SA-MP/open.mp gamemode but don't know where to begin - I was exactly the same. When I first started with SA-MP, I really wished I had a solid base gamemode to analyze, tweak, and learn Pawn from.

After searching around, I couldn't find many good options (at least from what I saw).  So... I decided to make one myself.

# The Goal
My main focus with this project is keeping things *simple* and beginner-friendly. The whole point is to help newcomers understand and modify the code easily. For example, someone might look at basic MySQL callbacks and think "*Why not use inline_mysql?*" - but that would defeat the purpose of making it accessible, wouldn't it?

# Installation
Here's everything you need to get this gamemode up and running.  

## Downloads
You'll need to grab these files first:

- **[open.mp server (latest version)](https://github.com/openmultiplayer/open.mp/releases/latest)**
- **[MySQL plugin (R41-4)](https://github.com/pBlueG/SA-MP-MySQL/releases/tag/R41-4)**  
- **[Bcrypt plugin (0.4.1)](https://github.com/Sreyas-Sreelal/samp-bcrypt/releases/tag/0.4.1)**  

## Setup  
1. **open.mp server** → Extract this into your server's *root folder* (main directory).  
2. **MySQL & Bcrypt plugins**:  
   - `.dll`/`.so` files → Place in `plugins/`  
   - Include files (`.inc`) → Place in `qawno/include/`  
3. **MySQL dependencies** (`libmariadb.dll`, `log-core.dll`, etc.) → Drop these directly in your *root folder*.  

## Database
This gamemode uses [`mysql_connect_file`](https://github.com/pBlueG/SA-MP-MySQL/wiki#mysql_connect_file) to establish the database connection through an INI-style configuration file containing all necessary credentials and settings.

An example configuration file can be found here:  
https://github.com/midosvt/omp-base-script/blob/master/db_credentials.ini

Refer to the MySQL plugin documentation (linked above) for all available configuration fields and options.

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
└── main.pwn                   # Main file```

## Style