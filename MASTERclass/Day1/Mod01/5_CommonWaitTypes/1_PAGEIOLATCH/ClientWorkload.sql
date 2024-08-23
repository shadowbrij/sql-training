USE [AdventureWorks2014];
GO

SET NOCOUNT ON;
GO

WHILE (1 = 1)
BEGIN
DBCC DROPCLEANBUFFERS
SELECT
	COUNT(*) 
FROM Sales.SalesOrderHeader SOH
FULL OUTER JOIN Sales.SalesOrderDetail SOD
ON
	SOH.rowguid = SOD.rowguid
FULL OUTER JOIN Production.Product P
ON
	P.rowguid = SOD.rowguid
FULL OUTER JOIN Sales.Customer AS CUST
ON
	CUST.rowguid = P.rowguid
FULL OUTER JOIN Person.Address AS ADDR
ON
	ADDR.rowguid = CUST.rowguid
FULL OUTER JOIN Person.person AS PER
ON
	PER.rowguid = ADDR.rowguid
END;
GO