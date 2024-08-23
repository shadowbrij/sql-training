-- common causes of cpu bottlenecks..

-- cause 1 - missing indexes

SET STATISTICS IO ON
SET STATISTICS TIME ON


USE AdventureWorks2008R2
GO

-- This query causes a table scan on the SalesOrderDetail table, as there is no index on
--the LineTotal column

SELECT per.FirstName ,
per.LastName ,
p.Name ,
p.ProductNumber ,
OrderDate ,
LineTotal ,
soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
INNER JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
INNER JOIN Person.Person AS per
ON c.PersonID = per.BusinessEntityID
WHERE LineTotal > 25000


-- remedy: create an index..

CREATE NONCLUSTERED INDEX idx_SalesOrderDetail_LineTotal
ON Sales.SalesOrderDetail (LineTotal)


-- clean up

DROP INDEX idx_SalesOrderDetail_LineTotal
ON Sales.SalesOrderDetail



-- stale statistics





-- Non-SARGable predicates

-- create an index first

USE [AdventureWorks2008R2]
GO
CREATE NONCLUSTERED INDEX [idx_sod_modifiedDate]
ON [Sales].[SalesOrderDetail] ([ModifiedDate])
INCLUDE ([SalesOrderID])
GO

------


SELECT soh.SalesOrderID ,
OrderDate ,
DueDate ,
ShipDate ,
Status ,
SubTotal ,
TaxAmt ,
Freight ,
TotalDue
FROM Sales.SalesOrderheader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE CONVERT(VARCHAR(10), sod.ModifiedDate, 101) = '01/01/2010'


-- Remedy

SELECT soh.SalesOrderID ,
OrderDate ,
DueDate ,
ShipDate ,
Status ,
SubTotal ,
TaxAmt ,
Freight ,
TotalDue
FROM Sales.SalesOrderheader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.
SalesOrderID
WHERE sod.ModifiedDate >= '2010/01/01'
AND sod.ModifiedDate < '2010/01/02'

-- clean up
USE [AdventureWorks2008R2]
GO
DROP INDEX [idx_sod_modifiedDate]
ON [Sales].[SalesOrderDetail]
GO


-- fun with ISNULL

WHERE ISNULL(SomeCol,0) > 0
WHERE SomeCol > 0

--In the first one, any row with a NULL value will be excluded because the NULL is
--converted to zero and the filter is for values greater than zero. In the second one, any
--row with a NULL value will be excluded because NULLs do not ever return true when
--compared to any value using the =, <>, <, > or any of the other comparison operators.
--They can only return true for IS NULL or IS NOT NULL checks. Hence, both predicates
--achieve the same result, but only the second one allows use of index seeks.


-- Implicit conversions

-- varchar to Nvarchar
SELECT p.FirstName ,
p.LastName ,
c.AccountNumber
FROM Sales.Customer AS c
INNER JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
WHERE AccountNumber = N'AW00029594'


-- remedy..

SELECT p.FirstName ,
p.LastName ,
c.AccountNumber
FROM Sales.Customer AS c
INNER JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
WHERE AccountNumber = 'AW00029594'

--The fix for implicit conversions is to ensure that columns used in joins are always of the
--same type and that, in the WHERE clause, any variables, parameters or constants are of the
--same type as the columns to which they are being compared. If they are not, make careful
--use of conversion functions (CAST, CONVERT) on the variables, parameters or constants so
--that they match the data type of the column.


-- paramter sniffing
-- see plan caching & recomplication demo by AMit Bansal for more knowledge



CREATE PROCEDURE user_GetCustomerShipDates
	(
	@ShipDateStart DATETIME ,
	@ShipDateEnd DATETIME
	)
AS
	SELECT CustomerID,
	SalesOrderNumber
	FROM Sales.SalesOrderHeader
	WHERE ShipDate BETWEEN @ShipDateStart AND @ShipDateEnd
GO



CREATE NONCLUSTERED INDEX IDX_ShipDate_ASC
ON Sales.SalesOrderHeader (ShipDate)
GO



DBCC FREEPROCCACHE
EXEC user_GetCustomerShipDates '2005/07/08', '2008/01/01'
EXEC user_GetCustomerShipDates '2005/07/10', '2005/07/20'

DBCC FREEPROCCACHE
EXEC user_GetCustomerShipDates '2005/07/10', '2005/07/20'
EXEC user_GetCustomerShipDates '2005/07/08', '2008/01/01'


-----------------

-- cause 4
--One_Wide_vs_multiple_narrow
-- run from E:\Training Resources\SQL Server 2008 - Katmai\Amit PPTs\Index Tuning\One_Wide_vs_multiple_narrow

