/* :::::::::::::::::::::::::::::::::::::::::::::::::
	LAB - INVESTIGATE TEMPDB ABNORMAL GROWTH
	FILE - TEMPDBSHRINK.sql
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

--SIZE


----------------------
--STEP 3
----------------------
--Execute and note the output of the below query
USE [tempdb];
GO
select getdate() AS runtime, SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage

--runtime	usr_obj_kb	internal_obj_kb	version_store_kb	freespace_kb	mixedextent_kb

----------------------
--STEP 4
----------------------

--Create a Global temp table 
USE [PWI_TEMPDBFULL]
GO
CREATE TABLE ##NewGlobalTempTable(
	[SID] [bigint] NOT NULL,
	[PID] [int] NOT NULL,
	[FNAME] [varchar](50) NOT NULL,
	[LNAME] [varchar](50) NOT NULL,
	[ADDRESS] [varchar](max) NOT NULL,
	[SALARY] [int] NOT NULL)
GO

--Open setup.sql and execute script in STEP 3

--Execute below stored procedure to populate data in ##NewGlobalTempTable table
USE tempdb;
EXEC sp_populate_data ##NewGlobalTempTable,100000

----------------------
--STEP 5
----------------------
--Execute and note the output of the below query
USE [tempdb];
GO
select getdate() AS runtime, SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage

--runtime	usr_obj_kb	internal_obj_kb	version_store_kb	freespace_kb	mixedextent_kb

--Note: User Object (usr_obj_kb) is increased in size.

------------------------
--STEP 6
------------------------

--Open a new query window and execute below query
USE [PWI_TEMPDBFULL]
GO
CREATE TABLE OpenTran (NAME VARCHAR(50));
GO
BEGIN TRAN
GO
INSERT INTO OpenTran VALUES('PWI');
GO

------------------------
--STEP 7
------------------------

--Enable READ COMMITED SNAPSHOT on database PWI_TEMPDBFULL
USE [master]
GO
ALTER DATABASE [PWI_TEMPDBFULL] SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT
GO

------------------------
--STEP 8
------------------------

USE [PWI_TEMPDBFULL]
GO
UPDATE [TAB1]
SET [FNAME] = 'TEST', [LNAME] = 'TEST'


--While the above query is executing open a new query window and
--execute query in STEP 5.
--You will notice ROWVERSION (version_store_kb) to increase in size.

------------------------
--STEP 9
------------------------

--Execute below query to find current size of tempdb.
USE [tempdb]
GO
SELECT name AS [Logical Name], size/128.0 AS [Total Size in MB],
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS [Available Space In MB]
FROM sys.database_files

/******************TROUBLESHOOTING******************/

-----------------------
--STEP 10
-----------------------

--Execute below query to find what tempdb space used for?
USE [tempdb];
GO
select getdate() AS runtime, SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage

--User Objects??
--Row Version Store??

------------------------
--STEP 12
------------------------

--Remove any temp user objects from tempdb
DROP TABLE ##NewGlobalTempTable;
GO

------------------------
--STEP 13
------------------------

--Is there any open transaction?

SELECT
trans.session_id as [SPID],
trans.transaction_id as [Transaction ID],
tas.name as [Transaction Name],
tds.database_id as [Database ID]
FROM sys.dm_tran_active_transactions tas
INNER JOIN sys.dm_tran_database_transactions tds
ON (tas.transaction_id = tds.transaction_id )
INNER JOIN sys.dm_tran_session_transactions trans
ON (trans.transaction_id=tas.transaction_id)
WHERE trans.is_user_transaction = 1 -- user
AND tas.transaction_state = 2 --active
AND tds.database_transaction_begin_time IS NOT NULL

--Note the SPID

------------------------
--STEP 14
------------------------

KILL <SPID>

--Execute below query to find what tempdb space used for?
USE [tempdb];
GO
select getdate() AS runtime, SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage


-------------------------
--STEP 15
-------------------------

--Execute below DBCC command to shrink tempdb data file

DBCC SHRINKFILE('tempdev',10)

------------------------
--STEP 16
------------------------

--Execute below query to verify size.
USE [tempdb]
GO
SELECT name AS [Logical Name], size/128.0 AS [Total Size in MB],
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS [Available Space In MB]
FROM sys.database_files

/*************************
CLEANUP
**************************/

USE [master]
GO
DROP DATABASE [PWI_TEMPDBFULL]
GO