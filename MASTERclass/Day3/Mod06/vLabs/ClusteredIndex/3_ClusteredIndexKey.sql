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

-------------------------------------------------------------
-- Lab: SQL Server Clustered Index Internals
-- Exercise 3: Clustered Index Key
-------------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create Table3 table in SQLMaestros database
CREATE Table [SQLMaestros].[Table3](
	Column1 INT,
	Column2 CHAR(15),
	Column3 VARCHAR(100),
	Column4 UNIQUEIDENTIFIER,
	Column5 DATETIME,
	Column6 INT);
	
-- Insert 1000 records in Table3 table
DECLARE @COUNT INT;
SET @COUNT = 1;
DECLARE @DATA1 VARCHAR(100)
SET @DATA1 = REPLICATE('data',25)
WHILE @COUNT < 1001
BEGIN
DECLARE @DATA2 INT;
SET @DATA2 = ROUND(10000000*RAND(),0);
INSERT INTO [SQLMaestros].[Table3] VALUES(@COUNT, 'SQLMaestros', @DATA1, NEWID(), GETDATE(), @DATA2);
SET @COUNT = @COUNT + 1;
END
GO

-- Update Column6 column of Table3 table
UPDATE [SQLMaestros].[Table3] SET Column6 = 100 
WHERE Column1 % 5 = 0

---------------------
-- End: Setup
---------------------


-- Step 1: Create a clustered index on Column6 column of Table3 table
CREATE CLUSTERED INDEX CL_Table3_Column6 ON [SQLMaestros].[Table3](Column6);
GO

-- Step 2: View pages allocated to clustered index in Table3 table
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table3'), 1, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO

-- Step 3: View memory dump of the root page
DBCC TRACEON(3604);
GO
DBCC PAGE('SQLMaestros',1,1250,3); -- Page ID will change in your case
GO


-- Step 4: View memory dump of a particular leaf page (data page)
DBCC PAGE('SQLMaestros',1,1251,3); -- Page ID will change in your case
GO
 

-- Step 5: Create a non-clustered index on Column5 column of Table3 table
CREATE NONCLUSTERED INDEX NCL_Table3_Column5 ON [SQLMaestros].[Table3](Column5);
GO

-- Step 6: Find the index id of non-clustered index
SELECT name, index_id FROM sys.indexes
WHERE name = 'NCL_Table3_Column5';
GO



-- Step 7: View pages allocated to non-clustered index on Table3 table
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table3'), <index_id>, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO



-- Step 8: View non-clustered index leaf level page
DBCC PAGE('SQLMaestros',1,1226,3);   -- Page ID will change in your case
GO


-- Step 9: Drop Clustered Index on Table3 table
DROP INDEX CL_Table3_Column6 ON [SQLMaestros].[Table3];
GO

-- Step 10: Create clustered index on Column1 column of Table3 table
CREATE UNIQUE CLUSTERED INDEX UNCL_Table3_Column1 ON [SQLMaestros].[Table3](Column1);
GO

-- Step 11: View pages allocated to clustered index in Table3 table
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table3'), 1, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO

-- Step 12: View root page
DBCC PAGE('SQLMaestros',1,2318,3);  -- Page ID will change in your case
GO


-- Step 13: View pages allocated to non clustered index on Table3 table
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table3'),<index_id>, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO

-- Step 13: View non-clustered index leaf page 
DBCC PAGE('SQLMaestros',1,1243,3);  -- Page ID will change in your case
GO

------------------
-- Begin: Cleanup
------------------

USE [master]
GO
ALTER DATABASE [SQLMaestros] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE [SQLMaestros];
GO

----------------
-- End: Cleanup
----------------
/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/