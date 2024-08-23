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

-------------------------------------------------------
-- Lab: SQL Server Heap Internals 
-- Exercise 2: Forwarded & Forwarding Records
-------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create Table2 table in SQLMaestros database
CREATE TABLE [SQLMaestros].[Table2](
   Column1 INT,
   Column2 VARCHAR(4000),
   Column3 VARCHAR(4000),
   Column4 CHAR(10));
GO 

-- Insert 3 records in Table2 table
INSERT INTO [SQLMaestros].[Table2] VALUES(1,'smalldata','smalldata','smalldata');
INSERT INTO [SQLMaestros].[Table2] VALUES(2,'smalldata','smalldata','smalldata');
INSERT INTO [SQLMaestros].[Table2] VALUES(3,'smalldata','smalldata','smalldata');
GO
---------------------
-- End: Setup
---------------------


-- Step 1: View data pages allocated to Table2 table due to above insert
SELECT allocated_page_page_id
	,page_type_desc
	,*
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('SQLMaestros.Table2'), NULL, NULL, 'DETAILED')
WHERE page_type = 1;
GO

-- Step 2: View data page memory dump
DBCC TRACEON(3604);
DBCC PAGE('SQLMaestros',1,302,3); --Page ID will change in your case
GO


-- Step 3: Update a single record in Table2 table
DECLARE @DATA VARCHAR(4000)
SET @DATA = REPLICATE('bigdata',570);
UPDATE [SQLMaestros].[Table2] SET Column2 = @DATA, Column3 = @DATA WHERE Column1 = 2;
GO

-- Step 4: View data pages allocated after above update
SELECT allocated_page_page_id
	,page_type_desc
	,*
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('SQLMaestros.Table2'), NULL, NULL, 'DETAILED')
WHERE page_type = 1;
GO

-- Step 5: View old page memory dump
DBCC PAGE('SQLMaestros',1,302,3); --Page ID will change in your case
GO
                    

-- Step 6: View new page memory dump
DBCC PAGE('SQLMaestros',1,304,3); --Page ID will change in your case
GO       

/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/
