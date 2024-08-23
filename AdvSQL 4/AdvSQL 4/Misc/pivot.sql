use Northwind
go

WITH PivotData AS
(
SELECT
customerid , -- grouping column
shipvia, -- spreading column
freight -- aggregation column
FROM Orders
)
SELECT customerid, [1], [2], [3]
FROM PivotData
PIVOT(SUM(freight) FOR shipvia IN ([1],[2],[3]) ) AS P;
-------------

IF OBJECT_ID('FreightTotals') IS NOT NULL
	 DROP TABLE FreightTotals;
GO
WITH PivotData AS
(
SELECT
customerid , -- grouping column
shipvia, -- spreading column
freight -- aggregation column
FROM Orders
)
SELECT *
INTO FreightTotals
FROM PivotData
PIVOT( SUM(freight) FOR shipvia IN ([1],[2],[3]) ) AS P;
--SELECT * FROM FreightTotals;
SELECT customerid, shipvia, freight
FROM FreightTotals
UNPIVOT( freight FOR shipvia IN([1],[2],[3]) ) AS U;