-------------------------------------
--Physical Query Processing
-------------------------------------


--Code Snippet 2.1
--This query returns the ID (CustomerID) and number of orders placed (NumOrders) for all customers from London that placed more than five orders

USE Northwind;

SELECT C.CustomerID, COUNT(O.OrderID) AS NumOrders
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.CustomerID = O.CustomerID
WHERE C.City = 'London'
GROUP BY C.CustomerID
HAVING COUNT(O.OrderID) > 5
ORDER BY NumOrders;

----check EP: Things to note in the EP
--grey arrows, input, output, thinckness, index seek (london),inner index seek (see the predicates), stream aggregate, compute scalar, filter, all rows stops at sort and then sorted (coz the last rows returned could be the first one)  


--Code Snippet 2.2
-- optimization
-- plans are created even for indexes / optimization is done here
use peoplewareindia

CREATE TABLE dbo.T(a INT, b INT, c INT, d INT);
INSERT INTO dbo.T VALUES(1, 1, 1, 1);
SET STATISTICS PROFILE ON; -- forces producing showplan from execution
CREATE INDEX i ON dbo.T(a, b) INCLUDE(c, d);
SET STATISTICS PROFILE OFF; -- reverse showplan setting
DROP TABLE dbo.T; -- remove the table


--Code Snippet 2.3
-- Grouping Binding

SELECT C.customerid, orderid
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid
WHERE C.city = 'Hyderabad'
GROUP BY C.customerid


--Code Snippet 2.4

-- simplification

USE Northwind;
SELECT
  [Order Details].OrderID,
  Products.ProductName,
  [Order Details].Quantity,
  [Order Details].UnitPrice
FROM dbo.[Order Details]
  LEFT OUTER JOIN dbo.Products
    ON [Order Details].ProductID = Products.ProductID
WHERE Products.UnitPrice > 10;


--Code Snippet 2.5
-- simpler example of simplification
select * from Customers
select * from Orders

select o.*, c.* from orders o
left outer join Customers c
on o.customerid = c.customerid
where c.customerid is not null




--Code Snippet 2.6
-- cost threshold of parallelism

sp_configure 'show advanced options',1
reconfigure


--Code Snippet 2.7
select * from sys.dm_exec_query_optimizer_info
select top 10 * from Customers

-- ******** Query Plans ************



--Code Snippet 2.8
-- SET SHOWPLAN_TEXT ON

SET NOCOUNT ON;
USE Northwind;
GO
SET SHOWPLAN_TEXT ON;
GO
SELECT ProductName, Products.ProductID
FROM dbo.[Order Details]
  JOIN dbo.Products
    ON [Order Details].ProductID = Products.ProductID
WHERE Products.UnitPrice > 100;
GO
SET SHOWPLAN_TEXT OFF;
GO

--Code Snippet 2.9
-- SET SHOWPLAN_ALL ON

USE Northwind;
GO
SET SHOWPLAN_ALL ON;
GO
SELECT ProductName, Products.ProductID
FROM dbo.[Order Details]
  JOIN dbo.Products
    ON [Order Details].ProductID = Products.ProductID
WHERE Products.UnitPrice > 100;
GO
SET SHOWPLAN_ALL OFF;
GO


--Code Snippet 2.10
-- SET SHOWPLAN_XML ON

USE Northwind;
GO
SET SHOWPLAN_XML ON;
GO
SELECT ProductName, Products.ProductID
FROM dbo.[Order Details]
  JOIN dbo.Products
    ON [Order Details].ProductID = Products.ProductID
WHERE Products.UnitPrice > 100;
GO
SET SHOWPLAN_XML OFF;
GO


-- **** Extracting the Showplan from the Procedure Cache
--Code Snippet 2.11
use master
go

SELECT qplan.query_plan AS [Query Plan]
FROM sys.dm_exec_query_stats AS qstats
 CROSS APPLY sys.dm_exec_query_plan(qstats.plan_handle) AS qplan;



--different combinations by Amit


use master
go

SELECT qplan.query_plan AS [Query Plan]
FROM sys.dm_exec_query_stats AS qstats
 CROSS APPLY sys.dm_exec_query_plan(qstats.plan_handle) AS qplan;
 
 SELECT qplan.query_plan AS [Query Plan],qtext.text
FROM sys.dm_exec_query_stats AS qstats
 CROSS APPLY sys.dm_exec_query_plan(qstats.plan_handle) AS qplan
 cross apply sys.dm_exec_sql_text(qstats.plan_handle) as qtext
 where text like 'select * from%';


select * from sys.dm_exec_query_stats
select * from sys.dm_exec_query_plan(0x030005006986D97CC8DF01002A9D00000100000000000000)
select * from sys.dm_exec_sql_text(0x030005006986D97CC8DF01002A9D00000100000000000000)

select * from sys.dm_exec_query_stats as qstats
cross apply sys.dm_exec_sql_text (qstats.plan_handle)

select * from sys.dm_exec_query_plan(0x060009005345D222B8407E0A000000000000000000000000)
