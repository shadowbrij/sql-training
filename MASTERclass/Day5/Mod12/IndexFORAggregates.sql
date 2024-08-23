use AdventureWorks
GO

select * from Sales.SalesOrderHeader

exec sp_helpindex [Sales.SalesOrderHeader]

SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	
GROUP BY SOH.CustomerID
OPTION (MAXDOP 1)
go


SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go


CREATE INDEX Covering1 
ON Sales.SalesOrderHeader(SubTotal, CustomerID) 
	-- Not in order by the Group By 
go

SET STATISTICS IO ON

SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go



SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	with (index(0))
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go


CREATE INDEX Covering2
ON Sales.SalesOrderHeader(CustomerID, SubTotal) 
	-- Not in order by the Group By 
go



SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go

SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	with (index(covering1))
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go

SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	with (index(0))
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go

--- try with include

CREATE INDEX Covering3
ON Sales.SalesOrderHeader(CustomerID)
INCLUDE (SubTotal) 
	-- Not in order by the Group By 
go







SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go

SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	with (index(covering2))
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go


SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	with (index(covering1))
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go


SELECT SOH.CustomerID, 
	sum(SOH.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS SOH	with (index(0))
GROUP BY SOH.CustomerID
ORDER BY SOH.CustomerID
OPTION (MAXDOP 1)
go



-- clean up
DROP INDEX Covering1 
ON Sales.SalesOrderHeader

DROP INDEX Covering2 
ON Sales.SalesOrderHeader

DROP INDEX Covering3 
ON Sales.SalesOrderHeader

