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
-- Exercise 1: Understanding Allocation Units in a Heap
-------------------------------------------------------
---------------------
-- Begin: Setup
---------------------

-- Create a database named SQLMaestros
USE master;
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name='SQLMaestros')
ALTER DATABASE [SQLMaestros] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [SQLMaestros];
GO
CREATE DATABASE SQLMaestros;
GO


USE SQLMaestros;
SET NOCOUNT ON;
GO

-- Create a schema named SQLMaestros
CREATE SCHEMA [SQLMaestros] AUTHORIZATION [dbo];
GO 

---------------------
-- End: Setup
---------------------

-- Step 1: Create Table1 table in SQLMaestros database
CREATE TABLE [SQLMaestros].[Table1](
	Column1 INT,
	Column2 CHAR(9000));
GO

-- Step 2: Create Table1 table in SQLMaestros database
CREATE TABLE [SQLMaestros].[Table1](
	Column1 INT,
	Column2 CHAR(3000),
	Column3 CHAR(3000),
	Column4 CHAR(3000));
GO

-- Step 3: Create Table1 table in SQLMaestros database
CREATE TABLE [SQLMaestros].[Table1](
   Column1 INT,
   Column2 VARCHAR(3000),
   Column3 VARCHAR(3000),
   Column4 VARCHAR(3000),
   Column5 NTEXT);
GO 


-- Step 4: View allocation details for Table1 table
SELECT object_name(object_id) AS NAME
	,partition_id
	,partition_number AS pnum
	,rows
	,allocation_unit_id AS au_id
	,type_desc AS page_type_desc
	,total_pages AS pages
FROM sys.partitions p
INNER JOIN sys.allocation_units au ON p.partition_id = au.container_id
WHERE object_id = object_id('SQLMaestros.Table1');
GO

-- Step 5: Insert a single record in Table1 table
INSERT INTO [SQLMaestros].[Table1] VALUES(1,NULL,NULL,NULL,NULL);
GO

-- Step 6: View data page and IAM page allocation due to the above insert
SELECT extent_file_id AS file_id
	,allocated_page_page_id AS page_id
	,page_type_desc AS page_type
	,allocation_unit_type_desc AS allocation_unit
	,extent_page_id
	,allocated_page_iam_page_id AS iam_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('SQLMaestros.Table1'), NULL, NULL, 'DETAILED');
GO


-- Step 7: Insert a single record in Table1 table
DECLARE @data1 VARCHAR(3000)
SET @data1  = REPLICATE('A',3000)
INSERT INTO [SQLMaestros].[Table1] VALUES (2,@data1,@data1,@data1,NULL);
GO

-- Step 8: View data page and IAM page allocation due to the above insert
SELECT extent_file_id AS file_id
	,allocated_page_page_id AS page_id
	,page_type_desc AS page_type
	,allocation_unit_type_desc AS allocation_unit
	,extent_page_id
	,allocated_page_iam_page_id AS iam_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('SQLMaestros.Table1'), NULL, NULL, 'DETAILED');
GO

-- Step 9: Insert a single record in Table1 table
INSERT INTO [SQLMaestros].[Table1] VALUES (3,NULL,NULL,NULL,'TEXT');
GO

-- Step 10: View data page and IAM page allocation due to the above insert
SELECT extent_file_id AS file_id
	,allocated_page_page_id AS page_id
	,page_type_desc AS page_type
	,allocation_unit_type_desc AS allocation_unit
	,extent_page_id
	,allocated_page_iam_page_id AS iam_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('SQLMaestros.Table1'), NULL, NULL, 'DETAILED');
GO


/*===================================================================================================
For public classes on SQL Server & other Microsoft Technologies, visit http://www.PeoplewareIndia.com
Want to hire a trainer/consultant from us? email enquiry@peoplewareindia.com
====================================================================================================*/
