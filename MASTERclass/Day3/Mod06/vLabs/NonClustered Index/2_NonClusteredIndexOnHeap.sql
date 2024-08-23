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
-- Exercise 2: Non Clustered Index Over a Heap
-------------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create Table2 table in SQLMaestros database
CREATE TABLE [SQLMaestros].[Table2](
   Column1 INT,
   Column2 CHAR(30),
   Column3 VARCHAR(30),
   Column4 INT,
   Column5 INT);
GO 

-- Insert 100000 records in Table2 table
DECLARE @COUNT INT;
SET @COUNT = 1;
WHILE @COUNT < 100001
BEGIN
DECLARE @DATA2 INT;
SET @DATA2 = ROUND(10000000*RAND(),0);
DECLARE @RAND VARCHAR(30)
SET @RAND = (select char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65)+char(rand()*26+65));
INSERT INTO [SQLMaestros].[Table2] VALUES(@COUNT,'data', @RAND, @DATA2, @COUNT + 1);
SET @COUNT = @COUNT + 1;
END
GO

---------------------
-- End: Setup
---------------------

-- Step 1: Execute below select statement with actual execution plan (Ctrl + M) 
SET STATISTICS IO ON; 
SELECT * FROM [SQLMaestros].[Table2] WHERE Column1 = 1000;
GO

-- Step 2: Create a non-clustered index on Column1 column of Table2 table
CREATE NONCLUSTERED INDEX NCL_Table2_Column1 ON [SQLMaestros].[Table2](Column1);
GO

-- Step 3: Execute below select statement with actual execution plan (Ctrl + M)
SELECT * FROM [SQLMaestros].[Table2] WHERE Column1 = 1000;
GO

-- Step 4: View index details of Table2 table
SELECT name,index_id FROM sys.indexes 
WHERE name = 'NCL_Table2_Column1';
GO

-- Step 5: View pages allocated to non-clustered index
SELECT allocated_page_page_id,page_type_desc,page_level,next_page_page_id,previous_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table2'), <index_id>, NULL, 'DETAILED')
WHERE page_type IN (1,2)
ORDER BY page_level DESC;
GO


-- Step 6: View memory dump of root page
DBCC TRACEON(3604)
DBCC PAGE('SQLMaestros',1,2608,3); -- Page ID will change in your case
GO

--Step 8: View memory dump of leaf level page
DBCC PAGE('SQLMaestros',1,2546,3); -- Page ID will change in your case
GO

--Step 9: View Heap Rid in 'Fileid:Pageid:slot' format
DECLARE @HeapRid BINARY(8)
SET @HeapRid = 0x3007000001001F00 -- Replace this with HEAP RID(key) from previous output WHERE Column1(key) = 1000
SELECT 
       CONVERT (VARCHAR(5),
                    CONVERT(INT, SUBSTRING(@HeapRid, 6, 1)
                               + SUBSTRING(@HeapRid, 5, 1)))
     + ':'
     + CONVERT(VARCHAR(10),
                    CONVERT(INT, SUBSTRING(@HeapRid, 4, 1)
                               + SUBSTRING(@HeapRid, 3, 1)
                               + SUBSTRING(@HeapRid, 2, 1)
                               + SUBSTRING(@HeapRid, 1, 1)))
     + ':'
          + CONVERT(VARCHAR(5),
                    CONVERT(INT, SUBSTRING(@HeapRid, 8, 1)
                               + SUBSTRING(@HeapRid, 7, 1)))
                               AS 'Fileid:Pageid:slot';
GO

--Step 10: View memory dump of data page
DBCC PAGE('SQLMaestros',1,1840,3); -- Page ID will change in your case
GO

/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/