/* :::::::::::::::::::::::::::::::::::::::::::::::::
	LAB - TROUBLESHOOTING INSUFFICENT DISK SPACE IN tempdb
	FILE - TEMPDBFULL.sql
	PATH - C:\temp\module2\Labs\Lab2
::::::::::::::::::::::::::::::::::::::::::::::::::::*/

---------------------
--STEP 1 
---------------------

--Open setup.sql and execute script in STEP 1 to restore PWI_TEMPDBFULL

----------------------
--STEP 2 
----------------------
--Execute below query to find current size of tempdb.
USE [tempdb]
GO
SELECT name AS [Logical Name], size/128.0 AS [Total Size in MB],
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS [Available Space In MB]
FROM sys.database_files

--Current Size: 

/**********************
INCREASE TEMPDB SIZE
***********************/
-----------------------
--STEP 3
-----------------------
--Open setup.sql and execute STEP 2 and STEP 3 to create table tempTAB and stored procedure sp_populate_data in tempdb database.

--Execute to populate data
EXEC sp_populate_data tempTAB, 2000000


-----------------------
--STEP 4
-----------------------

--Execute below query to limit the tempdb size to 170 MB
USE [master]
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', MAXSIZE = 174080KB )
GO

-----------------------
--STEP 5
-----------------------
--Execute to populate data (This will make tempdb full as MAX size is 170 MB)
USE [tempdb];
EXEC sp_populate_data tempTAB, 200000

--Msg 1105, Level 17, State 2, Line 1
--Could not allocate space for object 'dbo.tempTAB' in database 'tempdb' because the 'PRIMARY' filegroup is full.


----------------------
--STEP 6
----------------------
--Execute below query to find current size of tempdb.
USE [tempdb]
GO
SELECT name AS [Logical Name], size/128.0 AS [Total Size in MB],
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS [Available Space In MB]
FROM sys.database_files

--tempdb current size:

/**************Some Side Effects of full tempdb******************/

----------------------
--Error 1101
----------------------
USE [PWI_TEMPDBFULL]
GO
DBCC CHECKDB

----------------------
--Error 1105
----------------------
USE [tempdb];
EXEC sp_populate_data tempTAB, 2000

/**************TROUBLESHOOTING*******************/
---------------------
--STEP 1
---------------------
--Note Logical Name and Path
USE [tempdb]
GO
SELECT name AS [Logical Name], physical_name AS [PATH]
FROM sys.database_files

--Logical Name
--Path

---------------------
--STEP 2
---------------------
--Execute below query to move tempdb database files in a different location.  
ALTER DATABASE tempdb MODIFY FILE ( NAME = tempdev , FILENAME = 'C:\temp\module2\Database Files\tempdb.mdf' )
ALTER DATABASE tempdb MODIFY FILE ( NAME = templog , FILENAME = 'C:\temp\module2\Database Files\templog.ldf')

---------------------
--STEP 3
---------------------
--Stop SQL Server Service from configuration manager or SSMS or Command Prompt or Using below command

--SHUTDOWN

---------------------
--STEP 4
---------------------
--Start SQL Server Service from configuration manager or SSMS or Command Prompt.

---------------------
--STEP 5
---------------------
--Verify changes by executing below query
USE [tempdb]
GO
SELECT name AS [Logical Name], physical_name AS [PATH]
FROM sys.database_files

----------------------
--STEP 6
----------------------

--Delete OLD tempdb files from the PATH obtained in STEP 1.

/***********************************************************/

--Execute below query to allow tempdb to grow unlimited in size
USE [master]
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', MAXSIZE = UNLIMITED )
GO