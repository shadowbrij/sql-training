use Northwind2
go

-- free the proccache
DBCC FREEPROCCACHE

-- plan caching and recompilation


--Demo: Plan cache metadata
SELECT * FROM Orders WHERE CustomerID = 'HANAR'
-- This is the query we use, which we refer to as the usecount query:


-- to viewe the cached plans
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';


--Demo: Adhoc query caching
-- three queries are executed in the Northwind2 database, the first
-- and the third query use the same plan, but the second one new plan is generated:
-- run the three queries and then run the cached plan query mentioned above


USE Northwind2;
DBCC FREEPROCCACHE;
GO
SELECT * FROM Orders WHERE CustomerID = 'HANAR';
GO
SELECT * FROM Orders WHERE CustomerID = 'CHOPS';
GO
SELECT * FROM Orders WHERE CustomerID = 'HANAR';
GO


SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';


-- try running this and observe the plan cache (first free the plan cache)

USE Northwind2;
DBCC FREEPROCCACHE;
GO

SELECT * FROM Orders WHERE CustomerID = 'HANAR';
SELECT * FROM Orders WHERE CustomerID = 'CHOPS';
SELECT * FROM Orders WHERE CustomerID = 'HANAR';
--

SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';


-- what difference do you observe between the 2 previous queries

--An easy way to detect applications that submit lots of ad hoc queries
--is by grouping on the sys.dm_exec_query_stats.query_hash column as follows.

select q.query_hash, 
	q.number_of_entries, 
	t.text as sample_query, 
	p.query_plan as sample_plan
from (select top 20 query_hash, 
			count(*) as number_of_entries, 
			min(sql_handle) as sample_sql_handle, 
			min(plan_handle) as sample_plan_handle
		from sys.dm_exec_query_stats
		group by query_hash
		having count(*) > 1
		order by count(*) desc) as q
	cross apply sys.dm_exec_sql_text(q.sample_sql_handle) as t
	cross apply sys.dm_exec_query_plan(q.sample_plan_handle) as p
go


--You can use the query_hash and query_plan_hash values together to determine whether a set of ad hoc queries with the same query_hash value --resulted in query plans with the same or different query_plan_hash values, or access path. This is done via a small modification to the earlier --query.

select q.query_hash, 
	q.number_of_entries, 
	q.distinct_plans,
	t.text as sample_query, 
	p.query_plan as sample_plan
from (select top 20 query_hash, 
			count(*) as number_of_entries, 
			count(distinct query_plan_hash) as distinct_plans,
			min(sql_handle) as sample_sql_handle, 
			min(plan_handle) as sample_plan_handle
		from sys.dm_exec_query_stats
		group by query_hash
		having count(*) > 1
		order by count(*) desc) as q
	cross apply sys.dm_exec_sql_text(q.sample_sql_handle) as t
	cross apply sys.dm_exec_query_plan(q.sample_plan_handle) as p
go





-- to reuse the chached plans for adhoc queries, subsequent queries need to be identical, character by character


USE Northwind2;
DBCC FREEPROCCACHE;
GO
SELECT * FROM orders WHERE customerID = 'HANAR'
GO
SELECT * FROM orders
WHERE customerID = 'HANAR';
GO
SELECT * FROM Orders WHERE CustomerID = 'HANAR'
GO
select * from orders where customerid = 'HANAR'
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';


-- Demo: The compiled plan stub

EXEC sp_configure 'show advanced options', 1
RECONFIGURE;
Go

EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;
GO

USE Northwind2;
DBCC FREEPROCCACHE;
GO
SELECT * FROM Orders WHERE CustomerID = 'HANAR';
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype LIKE 'Compiled Plan%'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';
GO
SELECT * FROM Orders WHERE CustomerID = 'HANAR';
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype LIKE 'Compiled Plan%'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';
GO


-- turn off the Optimize for Ad Hoc Workloads option

EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE;
GO


-- Demo: Parameterization
--Auto parameterization
USE Northwind2;
GO
DBCC FREEPROCCACHE;
GO
SELECT FirstName, LastName, Title FROM Employees 
WHERE EmployeeID = 6;
GO
SELECT FirstName, LastName, Title FROM Employees 
WHERE EmployeeID = 2;
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
   CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
  AND [text] NOT LIKE '%dm_exec_cached_plans%';
GO


-- auto parameteization with another example

DBCC FREEPROCCACHE;
Go

SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = N'05022'


--simple query with a constant 83720
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = N'83720'


-- see the plan cache
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
   CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
  AND [text] NOT LIKE '%dm_exec_cached_plans%';
GO

----- set the autoparameterization to forced

alter database northwind2 set parameterization forced

--- go back and run the same queries again

----- set the autoparameterization to simple

alter database northwind2 set parameterization simple


-- DEmo: Recompilation

--Recompilation

DBCC FREEPROCCACHE

use AdventureWorks2008
go

SELECT     SUM(Sales.SalesOrderHeader.TotalDue) AS SumSales, Production.Product.Name, Sales.CreditCard.CardType, Person.Person.LastName
FROM         Sales.SalesOrderHeader INNER JOIN
                      Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID INNER JOIN
                      Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID INNER JOIN
                      Sales.CreditCard ON Sales.SalesOrderHeader.CreditCardID = Sales.CreditCard.CreditCardID AND 
                      Sales.SalesOrderHeader.CreditCardID = Sales.CreditCard.CreditCardID INNER JOIN
                      Person.Person ON Sales.SalesOrderHeader.CustomerID = Person.Person.BusinessEntityID AND Sales.SalesOrderHeader.CustomerID = Person.Person.BusinessEntityID 
GROUP BY Production.Product.Name, Sales.CreditCard.CardType, Person.Person.LastName



USE [AdventureWorks2008]
GO
CREATE NONCLUSTERED INDEX [Test2] ON [Sales].[SalesOrderHeader] 
(
	[DueDate] ASC,
	[ShipDate] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

drop INDEX [Test2] ON [Sales].[SalesOrderHeader]




-- To identify queries/batches that are being recompiled frequently, 
-- you can, of course, use SQL Profiler to get this information. 
-- However, it is not a preferred option for reasons we explained
-- earlier. In SQL Server 2005, you can use DMVs to find the 
-- top-ten query plans that have been recompiled the most.

SELECT TOP 10 plan_generation_num, execution_count,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
      (CASE WHEN statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max),text)) * 2
            ELSE statement_end_offset
       END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM sys.dm_exec_query_stats
WHERE plan_generation_num >1
ORDER BY plan_generation_num DESC;


-----------------------
--HINTS
------------------------

-- OPTIMIZE FOR & RECOMPILE


DBCC FREEPROCCACHE;
Go


SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = N'05022'


--simple query with a constant 83720
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = N'83720';


-------

--- simple query with a variable 05022
DECLARE @ShipCode nvarchar(20);
SET @ShipCode = N'05022';
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = @ShipCode;

--dbcc show_statistics ('dbo.orders','shippostalcode')

--- simple query with a variable 83720
DECLARE @ShipCode nvarchar(20);
SET @ShipCode = N'83720';
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = @ShipCode;


--simple query with OPTIMIZE FOR 05022
DECLARE @ShipCode nvarchar(20);
SET @ShipCode = N'05022';
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = @ShipCode
OPTION (OPTIMIZE FOR (@ShipCode = N'05022'));


--simple query with OPTIMIZE FOR 83720
DECLARE @ShipCode nvarchar(20);
SET @ShipCode = N'83720';
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = @ShipCode
OPTION (OPTIMIZE FOR (@ShipCode = N'05022'));


-- option RECOMPILE

DECLARE @ShipCode nvarchar(20);
SET @ShipCode = N'05022';
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = @ShipCode
OPTION (RECOMPILE);



DECLARE @ShipCode nvarchar(20);
SET @ShipCode = N'83720';
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = @ShipCode
OPTION (RECOMPILE);















--------------------
-- Submitting as ad hoc query
select * from Sales.SalesOrderHeader where SalesOrderID = 100

-- Submitting as parameterized
select * from Sales.SalesOrderHeader where SalesOrderID = ?

--You should use the appropriate APIs for your technology (ODBC, OLE DB, or SQLClient) to bind a value to the parameter marker. The client driver --or provider then submits the query in its parameterized form using sp_executesql.

exec sp_executesql N’select * from Sales.SalesOrderHeader where SalesOrderID = @P1’, N’@P1 int’, 100





-- to reuse the chached plans for adhoc queries, subsequent queries need to be identical, character by character


USE Northwind2;
DBCC FREEPROCCACHE;
GO
SELECT * FROM orders WHERE customerID = 'HANAR'
GO
SELECT * FROM orders
WHERE customerID = 'HANAR';
GO
SELECT * FROM Orders WHERE CustomerID = 'HANAR'
GO
select * from orders where customerid = 'HANAR'
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';
        
        
-- using Dynamic SQL

exec sp_executesql N'SELECT * FROM orders WHERE customerID = @P1', N'@P1 char(5)', 'HANAR'
exec sp_executesql N'SELECT * FROM Orders WHERE CustomerID = @P1', N'@P1 char(5)', 'HANAR'



-- reusing the plan


DBCC FREEPROCCACHE;
Go


SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = N'05022'


--simple query with a constant 83720
SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = N'83720';


exec sp_executesql
N'SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = @P1', N'@P1 char(5)', '05022'


exec sp_executesql
N'SELECT [OrderId], [OrderDate]
FROM [Orders]
WHERE [ShipPostalCode] = @P1', N'@P1 char(5)', '83720'




--- Fixing the application


cmd.CommandType = CommandType.Text;
cmd.CommandText = @"SELECT soh.SalesOrderNumber,
sod.ProductID
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesOrderNumber = '" + txtSalesOrderNo.Text + "'";
dtrSalesOrders = cmd.ExecuteReader();





dtrSalesOrders.Close();
cmd.CommandType = CommandType.Text;
cmd.CommandText = @"SELECT soh.SalesOrderNumber,
sod.ProductID
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.SalesOrderNumber = @SalesOrderNo";
cmd.Parameters.Add("@SalesOrderNo", SqlDbType.NVarChar, 50);
cmd.Parameters["@SalesOrderNo"].Value = txtSalesOrderNo.Text;
dtrSalesOrders = cmd.ExecuteReader();