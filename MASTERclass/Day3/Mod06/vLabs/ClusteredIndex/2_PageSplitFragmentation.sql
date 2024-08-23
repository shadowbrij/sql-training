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
-- Exercise 2: Page Split & Fragmentaion
-------------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create Table2 table in SQLMaestros database
CREATE Table [SQLMaestros].[Table2](
   Column1 INT,
   Column2 VARCHAR(8000),
   Column3 DATETIME);
GO 


-- Insert 1000 records in Table2 table
DECLARE @COUNT INT;
SET @COUNT = 1;
WHILE @COUNT < 1001
BEGIN
INSERT INTO [SQLMaestros].[Table2] VALUES(@COUNT,'smalldata',GETDATE());
SET @COUNT = @COUNT + 1;
END
GO

---------------------
-- End: Setup
---------------------


-- Step 1: Create clustered index on Column1 column of Table2 table
CREATE CLUSTERED INDEX CL_Table1_Column1 ON [SQLMaestros].[Table2](Column1);
GO

-- Step 2: View clustered index details
SELECT index_id,index_type_desc,index_level,page_count,avg_record_size_in_bytes,avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
    (DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table2'), 1, NULL , 'DETAILED')
ORDER BY index_level DESC;
GO

-- Step 3: View page split details from log file
Select COUNT(1) AS NumberOfSplits, AllocUnitName , Context
From fn_dblog(NULL,NULL)
Where operation = 'LOP_DELETE_SPLIT'
Group By AllocUnitName, Context
Order by NumberOfSplits desc 


-- Step 4: Perform update operation to split the pages
DECLARE @DATA1 VARCHAR(4200)
SET @DATA1 = REPLICATE('bigdata',600)
UPDATE [SQLMaestros].[Table2] SET Column2 = @DATA1 
WHERE Column1 % 2 = 0

DECLARE @DATA2 VARCHAR(4200)
SET @DATA2 = REPLICATE('bigdata',600)
UPDATE [SQLMaestros].[Table2] SET Column2 = @DATA2 
WHERE Column1 % 2 = 1


-- Step 5: View page split details from log file
Select COUNT(1) AS NumberOfSplits, AllocUnitName , Context
From fn_dblog(NULL,NULL)
Where operation = 'LOP_DELETE_SPLIT'
Group By AllocUnitName, Context
Order by NumberOfSplits desc

-- Step 6: View clustered index details
SELECT index_id,index_type_desc,index_level,page_count,avg_record_size_in_bytes,avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
    (DB_ID(N'SQLMaestros'), OBJECT_ID(N'SQLMaestros.Table2'), 1, NULL , 'DETAILED')
ORDER BY index_level DESC;
GO


/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/