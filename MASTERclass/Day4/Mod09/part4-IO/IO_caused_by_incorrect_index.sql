-- Create a supporting NCL
USE [AdventureWorksDW2014];
GO


SELECT * INTO FactProductInventory2
FROM FactProductInventory

-- select top 10 * from FactProductInventory2
select * from dimdate
-- blow up factproductinventory2

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

-- check the current record count & szie of the table

select count(*) from dbo.FactProductInventory
GO
sp_spaceused 'FactProductInventory'
GO


-- following index is created to support the query
-- but this index will not be used by the optimizer


USE [AdventureWorksDW2014]
GO
CREATE NONCLUSTERED INDEX [idx_fpi_productkey1]
ON [dbo].[FactProductInventory2] ([ProductKey])
GO


--- now the query

-- Let's view CPU, Elapsed time, I/O and the actual execution plan
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- include actual execution plan

-- after the query is run; watch table scan on FPI, IO stats, query stats and virtual file stats
-- 15372 logical reads for FPI

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

-- create the right index
USE [AdventureWorksDW2014]
GO
CREATE NONCLUSTERED INDEX [idx_fpi_productkey2]
ON [dbo].[FactProductInventory2] ([ProductKey])
INCLUDE (MovementDate, UnitCost, UnitsOut)
GO

-- drop the old index that is not been used
DROP INDEX [idx_fpi_productkey1]
ON [dbo].[FactProductInventory2]

--- run the query again and watch IO
-- now 25 logical reads for FPI
-- overall IO will reduce everywhere...

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
