USE [Master];
GO

DBCC DROPCLEANBUFFERS
SELECT TOP(10000)
	a.*
FROM master..spt_values a, master..spt_values b
ORDER BY 
	a.number DESC, b.number DESC
GO

------

USE [AdventureWorks2014];
GO

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
FULL OUTER JOIN Production.TransactionHistory TAB
ON
	TAB.TransactionID = CUST.CustomerID
GO

------

USE [AdventureWorks2014];
GO

DBCC DROPCLEANBUFFERS
select * from sales.SalesOrderDetail
order by LineTotal DESC
GO

------

USE [AdventureWorks2014];
GO

BEGIN TRAN
UPDATE Person.Person
SET LastName = 'Bansal'
WHERE BusinessEntityID = 1
WAITFOR DELAY '00:00:05'
ROLLBACK TRAN
GO

------

USE [AdventureWorks2014];
GO

select * from person.person
GO