/*============================================================================================
  Copyright (C) 2014 SQLMaestros.com | eDominer Systems P Ltd.
  All rights reserved.
    
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
  
  For bugs, feedback & suggestions, email feedback@SQLMaestros.com
  For SQL Server health check, consulting & support services, visit http://www.SQLMaestros.com
=============================================================================================*/

-----------------------------------------------------------------------
-- Lab: SQL Server Non Clustered Index Intrenals
-- Exercise 1: Understanding B-Tree Structure of a Non-Clustered Index
-----------------------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

-- Create a database named SQLMaestros
USE master;
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name='SQLMaestros')
ALTER DATABASE [SQLMaestros] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE SQLMaestros;
CREATE DATABASE SQLMaestros;
GO


USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create a schema named SQLMaestros
CREATE SCHEMA [SQLMaestros] AUTHORIZATION [dbo];
GO

-- Create Table1 table in SQLMaestros database
CREATE Table [SQLMaestros].[Table1](
   Column1 INT,
   Column2 VARCHAR(8000),
   Column3 CHAR(10),
   Column4 INT);
GO 

-- Insert 200000 records in Table1 table
DECLARE @COUNT INT;
SET @COUNT = 1;
DECLARE @DATA1 VARCHAR(8000)
SET @DATA1 = 'data'
WHILE @COUNT < 200001
BEGIN
DECLARE @DATA2 INT;
SET @DATA2 = ROUND(10000000*RAND(),0);
INSERT INTO [SQLMaestros].[Table1] VALUES(@COUNT,@DATA1,'random',@DATA2);
SET @COUNT = @COUNT + 1;
END
GO

---------------------
-- End: Setup
---------------------


-- Step 1: Create non-clustered index on Column1 column of Table1 table
CREATE NONCLUSTERED INDEX NCL_Table1_Column1 ON [SQLMaestros].[Table1](Column1);
GO

-- Step 2: View index details of Table1 table
EXEC sp_helpindex 'SQLMaestros.Table1';
GO

-- Step 3: View statistics details of Table1 table
SELECT STATS.* FROM sys.stats AS STATS
INNER JOIN sys.objects AS OBJ
ON STATS.object_id = OBJ.object_id
WHERE OBJ.name = 'Table1';
GO

-- Step 4: View index details of non-clustered index on Table1 table
SELECT index_id,index_type_desc,index_level,page_count,avg_record_size_in_bytes,avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
    (DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table1'), 2, NULL , 'DETAILED')
ORDER BY index_level DESC;
GO

-- Step 5: View non-clustered index architecture
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table1'), 2, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO

-- Step 6: View memory dump of root page
DBCC TRACEON(3604)
DBCC PAGE('SQLMaestros',1,1208,3); -- Page ID will change in your case
GO

--Step 7: View memory dump of intermediate level page
DBCC PAGE('SQLMaestros',1,1312,3); -- Page ID will change in your case
GO

--Step 8: View memory dump of leaf level page
DBCC PAGE('SQLMaestros',1,1248,3); -- Page ID will change in your case
GO


/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/