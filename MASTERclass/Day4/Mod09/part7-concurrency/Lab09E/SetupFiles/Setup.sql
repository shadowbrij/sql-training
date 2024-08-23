USE master
GO

-- Drop and restore required databases from backups in the local folder
-- Move the database files to the folder where this script is stored

-- Drop and restore AdventureWorks2014
IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'AdventureWorks2014')
BEGIN
	DROP DATABASE AdventureWorks2014
END
GO
RESTORE DATABASE AdventureWorks2014 FROM  DISK = N'$(SUBDIR)SetupFiles\AdventureWorks2014.bak' WITH  REPLACE,
MOVE N'AdventureWorks2014_Data' TO N'$(SUBDIR)SetupFiles\AdventureWorks2014.mdf', 
MOVE N'AdventureWorks2014_Log' TO N'$(SUBDIR)SetupFiles\AdventureWorks2014.ldf'
GO
ALTER AUTHORIZATION ON DATABASE::AdventureWorks2014 TO [ADVENTUREWORKS\Student];
GO

-- Perform any other data modification tasks to prepare data for the demos


USE [master];
GO

IF DB_ID(N'Lab09E') IS NOT NULL
BEGIN
	ALTER DATABASE [Lab09E] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
	DROP DATABASE [Lab09E];
END
GO

-- Create the database
CREATE DATABASE [Lab09E];
GO
USE [Lab09E];
GO
SET NOCOUNT ON
GO

-- Create first table
CREATE TABLE [big_tbl] 
(	
	[id] INT,
	[colInt1] INT,
	[colInt2] INT,
	[colChar] CHAR(100) DEFAULT('Microsoft') NOT NULL
);
GO

DECLARE @i INT;
SET @i = 1;

-- Load data
WHILE (@i <= 1000) 
BEGIN
    INSERT INTO [big_tbl] 
		([id], [colInt1], [colInt2], [colChar])
	VALUES (@i, @i, @i, DEFAULT);
    SET @i = @i + 1;
END
GO

CREATE CLUSTERED INDEX [ci_big_tbl] 
ON [big_tbl] ([id]);

CREATE NONCLUSTERED INDEX [nci_big_tbl_colInt1] 
ON [big_tbl] ([colInt1]);
GO