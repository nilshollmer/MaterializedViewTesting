Materialized Views in SQL Server Testing program
============================================

This is a test program for the my thesis report at Software Engineering with emphasis in Web Programming at Blekinge Tekniska Högskola.

## Requirements
Python >= 3.5  
Pyodbc >= 4.*  
SQL Server 15.*  
SQL Server Management Studio

## Installation
In order to run the tests, a small setup is necessary.
+ Use SSMS to create the testing and performance database using scripts available in `sql/database_setup/`
+ Change server name in `query_functions.py`

## Commands

*INDEX LEVEL*
Create views and change index levels.  
`python3 change_index_level.py <index level>`

Available index levels 1 - 9.

*SIZE*  
Query to measure database and view size is located in `sql/size/db_and_view_size.sql`. This query shrinks the database before measuring size.

This query does not change index level, this needs to be done manually us

*SELECT*  
Test select queries, print result and create .csv file  
`python3 run_select_query.py <query> <iterations>`

Available queries:
+ 331_1, 331_2
+ 332_1, 332_2
+ 333_1, 333_2
+ 334_1, 334_2
+ 335_1, 335_2
+ 336
+ 337

The .csv files from this command can be found in `csv/select/`

*INSERT*  
Test insert queries and create .csv file  
`python3 run_insert_query.py <index_level> <iterations>`

The .csv file from this command can be found on `csv/insert/`. This command is not optimized to only save insert statements, so .csv files will also contain delete statements and sometimes other oddballs.

### Credits

Copyright (c) 2021 Nils Hollmer, n.hollmer@gmail.com
