/*
What is the purpose of this file?

    sqflite data tables:

    CREATE TABLE apps (
        package_name TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        custom_category TEXT,
        is_system_app INTEGER,
        last_synced INTEGER,
    )

    Hive data base:

    "yesterday's_total_usage" int
     

This file is a collection of rough code snippets and ideas that were 
*/