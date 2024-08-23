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
-- Lab: SQL Server Non Clustered Index Internals
-- Exercise 4: Covering Index
-------------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create Table4 table in SQLMaestros database
CREATE TABLE [SQLMaestros].[Table4](
   Column1 INT,
   Column2 CHAR(30),
   Column3 VARCHAR(30),
   Column4 INT,
   Column5 INT);
GO 

-- Insert 100000 records in Table4 table
DECLARE @COUNT INT;
SET @COUNT = 1;
WHILE @COUNT < 100001
BEGIN
DECLARE @DATA2 INT;
SET @DATA2 = ROUND(10000000*RAND(),0);
DECLARE @RAND VARCHAR(30)
SET @RAND = (select char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65));
INSERT INTO [SQLMaestros].[Table4] VALUES(@COUNT,'data', @RAND, @DATA2, @COUNT);
SET @COUNT = @COUNT + 1;
END
GO

-- Create a clustered index on Column1 column of Table4 table
CREATE CLUSTERED INDEX CL_Table4_Column1 ON [SQLMaestros].[Table4](Column1);
GO

---------------------
-- End: Setup
---------------------


-- Step 1: Execute below select query with actual execution plan (Ctrl + M) 
SET STATISTICS IO ON; 
SELECT Column2,Column3 FROM [SQLMaestros].[Table4] WHERE Column5 = 1000;
GO

-- Step 2: Create a non-clustered index on Column5 column of Table4 table
CREATE NONCLUSTERED INDEX NCL_Table4_Column5 ON [SQLMaestros].[Table4](Column5);
GO

-- Step 3: Execute below select query with actual execution plan (Ctrl + M)
SELECT Column2,Column3 FROM [SQLMaestros].[Table4] WHERE Column5 = 1000;
GO

-- Step 4: Create a non-clustered index on Column5 column of Table4 table
CREATE NONCLUSTERED INDEX NCL_Table4_Column5_INCLUDE_Column2_Column3 ON [SQLMaestros].[Table4](Column5) INCLUDE(Column2, Column3);
GO

-- Step 5: Execute below select query with actual execution plan (Ctrl + M)
SELECT Column2,Column3 FROM [SQLMaestros].[Table4] WHERE Column5 = 1000;
GO

-- Step 6: Execute below query to find non-clustered index index_id
SELECT name,index_id FROM sys.indexes WHERE name = 'NCL_Table4_Column5_INCLUDE_Column2_Column3';
GO

-- Step 7: View pages allocated to non-clustered index NCL_Table4_Column5_INCLUDE_Column2_Column3
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table4'), <index_id>, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO


-- Step 8: View memory dump of root page of non-clustered index
DBCC TRACEON(3604)
DBCC PAGE('SQLMaestros',1,2576,3); -- Page ID will change in your case
GO

--Step 9: View memory dump of intermediate level non-clustered index
DBCC PAGE('SQLMaestros',1,3336,3); -- Page ID will change in your case
GO

--Step 10: View memory dump of leaf level non-clustered index
DBCC PAGE('SQLMaestros',1,3279,3); -- Page ID will change in your case
GO

--------------------
-- Begin: Cleanup
--------------------
USE [master]
GO
ALTER DATABASE [SQLMaestros] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE [SQLMaestros]
GO

--------------------
-- End: Cleanup
--------------------
/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/