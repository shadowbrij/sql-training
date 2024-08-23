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
-- Exercise 3: Troubleshooting Heap Page Modification
-------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create Table3 table in SQLMaestros database
CREATE TABLE [SQLMaestros].[Table3](
   Column1 INT,
   Column2 VARCHAR(4000),
   Column3 VARCHAR(4000),
   Column4 CHAR(9))
GO 

-- Insert 1000 records in Table3 table
DECLARE @COUNT INT;
SET @COUNT = 1;
WHILE @COUNT < 1001
BEGIN
	INSERT INTO [SQLMaestros].[Table3]
	VALUES (
		@COUNT
		,'smalldata'
		,'smalldata'
		,'smalldata'
		);
	SET @COUNT = @COUNT + 1;
END

---------------------
-- End: Setup
---------------------


-- Step 1: Execute a select statement on Table3 table
SET STATISTICS IO ON;
SELECT * FROM [SQLMaestros].[Table3];
GO

-- Step 2: Execute the following system stored procedure to find size of data in Table3 table
EXEC sp_spaceused 'SQLMaestros.Table3';
GO

-- Step 3: Update records in Column2 and Column3 column of Table3 table
DECLARE @DATA VARCHAR(4000)
SET @DATA = REPLICATE('bigdata',570);
UPDATE [SQLMaestros].[Table3] SET Column2 = @DATA, Column3 = @DATA;
GO

-- Step 4: Execute a select statement on Table3 table
SELECT * FROM [SQLMaestros].[Table3];
GO

-- Step 5: Execute the following system stored procedure to find size of data in Table3 table
EXEC sp_spaceused 'SQLMaestros.Table3';
GO

-- Step 6: Get forwarded record count
SELECT index_type_desc
	,forwarded_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table3'), NULL, NULL, 'DETAILED');
GO    

-- Step 7: Create a clustered index on Column1 of Table3 and then drop it
CREATE CLUSTERED INDEX CL_Table3_Column1 ON [SQLMaestros].[Table3](Column1);
GO
DROP INDEX CL_Table3_Column1 ON [SQLMaestros].[Table3];
GO

-- Step 8: Execute a select query on Table3
SELECT * FROM [SQLMaestros].[Table3];
GO

-- Step 9: Execute the following system stored procedure to find size of data in Table3 table
EXEC sp_spaceused 'SQLMaestros.Table3';
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

------------------
-- End: Cleanup
------------------

/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/
