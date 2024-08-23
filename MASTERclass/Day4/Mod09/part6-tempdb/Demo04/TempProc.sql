USE AdventureWorks2014
GO
IF (OBJECT_ID('use_getSalesOrderDetails_prc') IS NOT NULL)
	DROP PROCEDURE use_getSalesOrderDetails_prc
GO
CREATE PROCEDURE use_getSalesOrderDetails_prc
AS
BEGIN
	SELECT * 
	INTO #temp
	FROM sales.SalesOrderDetail

	--process data in temp table

	DROP TABLE #temp
END
GO