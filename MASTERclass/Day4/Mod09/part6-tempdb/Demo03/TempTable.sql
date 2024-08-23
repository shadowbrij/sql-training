DECLARE @i INT = 1
WHILE (@i < 10)
BEGIN
	CREATE TABLE #temp (SalesOrderDetailID INT, 
				SalesOrderID INT, 
				CarrierTrackingNumber NVARCHAR(50), 
				UnitPrice money, 
				rowguid uniqueidentifier)

	INSERT INTO #temp
	select SalesOrderDetailID, SalesOrderID, CarrierTrackingNumber, UnitPrice, rowguid 
	from AdventureWorks2014.Sales.SalesOrderDetail

	DROP TABLE #temp

	SET @i = @i + 1
END