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