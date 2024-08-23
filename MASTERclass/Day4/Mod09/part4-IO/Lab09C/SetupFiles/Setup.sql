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

USE [AdventureWorksDW2014];
GO

SELECT * INTO FactProductInventory2
FROM FactProductInventory
GO

INSERT INTO [dbo].[FactProductInventory2]
           ([ProductKey]
           ,[DateKey]
		   ,[MovementDate]
           ,[UnitCost]
           ,[UnitsIn]
           ,[UnitsOut]
           ,[UnitsBalance])
SELECT		[ProductKey]
           ,[DateKey]
		   ,[MovementDate]
           ,[UnitCost]
           ,[UnitsIn]
           ,[UnitsOut]
           ,[UnitsBalance]
FROM [dbo].[FactProductInventory2];
GO 2


USE [AdventureWorksDW2014]
GO
CREATE NONCLUSTERED INDEX [idx_fpi_productkey1]
ON [dbo].[FactProductInventory2] ([ProductKey])
GO

USE [AdventureWorksDW2014]
GO
IF (OBJECT_ID('virtualFileStats') IS NOT NULL)
	DROP TABLE virtualFileStats
GO
SELECT 1 AS RunNo, 1 AS iteration, * INTO virtualFileStats
FROM sys.dm_io_virtual_file_stats(DB_ID('AdventureWorks2014'),NULL)
WHERE 1 = 0
