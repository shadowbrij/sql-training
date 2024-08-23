USE [AdventureWorks2014];
GO

SET NOCOUNT ON;
GO

	DBCC DROPCLEANBUFFERS

	SELECT COUNT(*)
	FROM Sales.SalesOrderHeader SOH
	FULL JOIN Sales.SalesOrderDetail SOD ON SOH.rowguid = SOD.rowguid
	FULL JOIN Production.Product P ON P.rowguid = SOD.rowguid
	FULL JOIN Sales.Customer AS CUST ON CUST.rowguid = P.rowguid
	FULL JOIN Person.Address AS ADDR ON ADDR.rowguid = CUST.rowguid
	FULL JOIN Person.person AS PER ON PER.rowguid = ADDR.rowguid

GO 100