# Introduction

This is a simple yet practical base script designed for anyone looking to develop gamemodes for [open.mp](https://open.mp/) or SA:MP.  Whether you're a beginner starting from scratch or a returning developer familiar with the platform, this script offers a clean foundation to build on.

It uses [MySQL](https://github.com/pBlueG/SA-MP-MySQL) for handling data and [BCrypt](https://github.com/Sreyas-Sreelal/samp-bcrypt) for secure password hashing.  While the script itself is straightforward, it does assume you have at least a basic understanding of Pawn scripting and SQL.  If you're willing to learn and explore how each part works, this base will be a solid starting point for your own projects.

# Installation

This section provides a step-by-step guide to get the gamemode running properly on your setup.

## Downloads

Download the following files before proceeding:
* **[open.mp server (latest version)](https://github.com/openmultiplayer/open.mp/releases/latest)**
* **[YSI includes (latest version)](https://github.com/pawn-lang/YSI-Includes/releases/latest)**
* **[MySQL plugin (R41-4)](https://github.com/pBlueG/SA-MP-MySQL/releases/tag/R41-4)**
* **[BCrypt plugin (v0.4.1)](https://github.com/Sreyas-Sreelal/samp-bcrypt/releases/tag/0.4.1)**

## Setup Instructions

**1. open.mp server**
- Extract the open.mp server files into the **root folder** of your server.

**2. YSI Library**
- Extract the contents of the archive into `qawno/include/`.

**3. MySQL and BCrypt Plugins**
- Place the plugin files (`.dll` for Windows or `.so` for Linux) inside the `plugins/` directory.
- Move the corresponding `.inc` include files to `qawno/include/`.

**4. MySQL Dependencies**
- Files like `libmariadb.dll`, `log-core.dll`, or any additional libraries should be placed directly in the server's **root folder**.

> [!NOTE]
> Ensure that all plugin names are correctly listed in your `config.json` file under the `plugins` setting.

## Database

This gamemode uses [`mysql_connect_file`](https://github.com/pBlueG/SA-MP-MySQL/wiki#mysql_connect_file) to connect to the database through an INI-style configuration file.  This file contains all the necessary credentials and settings needed to establish a connection.

Example configuration file:
**[mysql.ini](https://github.com/midosvt/omp-base-script/blob/master/mysql.ini)**

Please refer to the [MySQL plugin documentation](https://github.com/pBlueG/SA-MP-MySQL/wiki#mysql_connect_file) for details on all available fields and options.

Download the database structure:
**[database_structure.sql](https://github.com/midosvt/omp-base-script/blob/master/database_structure.sql)**

> [!NOTE]
> Make sure to import the `.sql` structure into your database before launching the server, otherwise account registration and login features will not function properly.

# Structure

This gamemode follows a modular structure to keep the codebase clean, organized, and easy to maintain.  If you're not familiar with modular programming, check out [this tutorial](https://sampforum.blast.hk/showthread.php?tid=597338&highlight=Modular+programming) before making any changes.  It's highly recommended to stick with this approach, as it makes development, debugging, and future updates much easier.

# Contributing

Everyone is welcome to contribute - whether it's advice, pull requests, or suggestions.

If you notice any bugs, issues, or have ideas to make things better, feel free to open an issue or join the discussion on [our Discord](https://discord.gg/samp).

# Special Thanks to
- SA:MP and open.mp teams (past, present, and future).
- Myself for developing this gamemode.
- BlueG and maddinat0r for the MySQL plugin.
- Sys for the bcrypt plugin.
- Y_Less for the YSI library.
- Kevin for his highly constructive suggestions and insights.
- itsneufox for testing this script.