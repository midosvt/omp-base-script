## open.mp base script
Hello, this is a script I have created in my spare time. It is designed to help new PAWN scripters to get started quickly.
It's like a friendly guidebook that covers the basic of starting a very basic and simple script using MySQL for our database and Bcrypt for password hashing. This script can be used as a base for your new gamemode!

I'm going to try my best to keep this script newbie-friendly and will comment things extensively to help everyone understand.
But you must have at least a basic understanding of how Pawn works.


# MySQL Configuration
We are using `mysql_connect_file` to connect to our MySQL server and database, using a INI-like file where all connection credentials and options are specified.

Create a `mysql.ini` file in the server root folder. 
**NOTE:** You CANNOT specify any directories in the file name, the connection file HAS to and MUST be in the open.mp server root folder.


see [mysql_connect_file](https://github.com/pBlueG/SA-MP-MySQL/wiki#mysql_connect_file) for available fields you can use.

An example of mysql.ini file:
```ini
hostname = localhost
username = root
password = 123455
database = mns_database
```

# Plugins
__________________________________________
|dd
|
|

# Tables
Import the [database structure file](https://github.com/midosvt/omp-base-script/blob/master/database/database_structure.sql)