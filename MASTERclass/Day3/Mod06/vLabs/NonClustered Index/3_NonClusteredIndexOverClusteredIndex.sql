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
-- Exercise 3: Non-Clustered Index Over a Clustered Index
-------------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create Table2 table in SQLMaestros database
CREATE TABLE [SQLMaestros].[Table3](
   Column1 INT,
   Column2 CHAR(30),
   Column3 VARCHAR(30),
   Column4 INT,
   Column5 INT);
GO 

-- Insert 100000 records in Table3 table
DECLARE @COUNT INT;
SET @COUNT = 1;
WHILE @COUNT < 100001
BEGIN
DECLARE @DATA2 INT;
SET @DATA2 = ROUND(10000000*RAND(),0);
DECLARE @RAND VARCHAR(30)
SET @RAND = (select char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65));
INSERT INTO [SQLMaestros].[Table3] VALUES(@COUNT,'data', @RAND, @DATA2, @COUNT);
SET @COUNT = @COUNT + 1;
END
GO

-- Create a clustered index on Column1 column of Table3 table
CREATE CLUSTERED INDEX CL_Table3_Column1 ON [SQLMaestros].[Table3](Column1);
GO

---------------------
-- End: Setup
---------------------

-- Step 1: Execute below select statement with actual execution plan (Ctrl + M) 
SET STATISTICS IO ON; 
SELECT * FROM [SQLMaestros].[Table3] WHERE Column5 = 1000;
GO

-- Step 2: Create a non-clustered index on Column5 column of Table3 table
CREATE NONCLUSTERED INDEX NCL_Table3_Column5 ON [SQLMaestros].[Table3](Column5);
GO

-- Step 3: Execute below select statement with actual execution plan (Ctrl + M)
SELECT * FROM [SQLMaestros].[Table3] WHERE Column5 = 1000;
GO

-- Step 4: Execute below statement to find non-clustered index index_id
SELECT name,index_id FROM sys.indexes WHERE name = 'NCL_Table3_Column5';
GO

-- Step 5: View pages allocated to non-clustered index
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table3'), <index_id>, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO


-- Step 6: View memory dump of root page
DBCC TRACEON(3604)
DBCC PAGE('SQLMaestros',1,2744,3); -- Page ID will change in your case
GO

--Step 7: View memory dump of leaf level page
DBCC PAGE('SQLMaestros',1,2601,3); -- Page ID will change in your case
GO

-- Step 8: View pages allocated to clustered index
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table3'), 1, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO


--Step 9: View memory dump of clustered index root page
DBCC PAGE('SQLMaestros',1,2583,3); -- Page ID will change in your case
GO

--Step 10: View memory dump of clustered index intermidiate level page
DBCC PAGE('SQLMaestros',1,3680,3); -- Page ID will change in your case
GO

--Step 11: View memory dump of clustered index leaf level page
DBCC PAGE('SQLMaestros',1,3624,3); -- Page ID will change in your case
GO

/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/