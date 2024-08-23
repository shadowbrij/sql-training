--Execute below query to find current size of tempdb.
USE [tempdb]
GO
SELECT name AS [Logical Name], size/128.0 AS [Total Size in MB],
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS [Available Space In MB]
FROM sys.database_files

--Execute and note the output of the below query
USE [tempdb];
GO
select getdate() AS runtime, SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage

----------------------
--STEP 4
----------------------

--Create a Global temp table 
USE [AdventureWorks2012]
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
EXEC sp_populate_data ##NewGlobalTempTable,10000


--Execute and note the output of the below query
USE [tempdb];
GO
select getdate() AS runtime, SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage

--- Internal Objects
USE AdventureWorks2014;
GO

while (1=1)
begin
DBCC DROPCLEANBUFFERS
SELECT TOP(100000)
	a.*
FROM master..spt_values a, master..spt_values b
ORDER BY 
	a.number DESC, b.number DESC
end;
GO


-- version store

------------------------
--STEP 6
------------------------


--Enable READ COMMITED SNAPSHOT on database PWI_TEMPDBFULL
USE [master]
GO
ALTER DATABASE [AdventureWorks2012] SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT
GO


--Open a new query window and execute below query
USE [AdventureWorks2012]
GO
CREATE TABLE OpenTran (NAME VARCHAR(50));
GO
INSERT INTO OpenTran VALUES('PWI');
GO

------------------------
--STEP 7
------------------------

USE [AdventureWorks2012]
GO
select * from OpenTran

begin tran
UPDATE [OpenTran]
SET [NAME] = 'TEST'

select * from sys.dm_tran_version_store

ROLLBACK TRAN
GO