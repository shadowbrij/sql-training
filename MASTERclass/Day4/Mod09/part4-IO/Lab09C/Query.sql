SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

USE AdventureWorksDW2014
GO

DBCC DROPCLEANBUFFERS()
GO
DECLARE @runNo INT

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'idx_fpi_productkey2')
	SET @runNo = 1
ELSE
	SET @runNo = 2
PRINT @runNo
INSERT INTO virtualFileStats
SELECT @runNo, 1, * FROM sys.dm_io_virtual_file_stats(DB_ID('AdventureWorksDW2014'),NULL)

SELECT  p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear,
		AVG(fpi.UnitCost),
		SUM(fpi.UnitsOut)
FROM	dbo.FactProductInventory2 as fpi
INNER JOIN dbo.DimProduct as p ON
	fpi.ProductKey = p.ProductKey
INNER JOIN dbo.DimDate as d ON
	fpi.MovementDate = d.FullDateAlternateKey
where fpi.ProductKey = 486
GROUP BY p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear
ORDER BY p.EnglishProductName,
		 d.CalendarYear,
		 d.WeekNumberOfYear;

INSERT INTO virtualFileStats
SELECT @runNo, 2, * FROM sys.dm_io_virtual_file_stats(DB_ID('AdventureWorksDW2014'),NULL)


