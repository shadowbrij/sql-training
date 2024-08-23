USE Northwind2
GO

-- For example, these two queries run in the Northwind2 database can use the same plan:

SELECT FirstName, LastName, Title FROM Employees
WHERE EmployeeID = 6;
SELECT FirstName, LastName, Title FROM Employees
WHERE EmployeeID = 2;


-- You can observe this behavior by running the following code and observing the output of the 
-- usecount query:

USE Northwind2
GO
DBCC FREEPROCCACHE;
GO
SELECT FirstName, LastName, Title FROM Employees WHERE EmployeeID = 6;
GO
SELECT FirstName, LastName, Title FROM Employees WHERE EmployeeID = 2;
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';
GO


-- A database option called PARAMETERIZATION FORCED can be enabled with the following command:

ALTER DATABASE <database_name> SET PARAMETERIZATION FORCED; 


-- As strange as it may seem, even if you switch the order of the queries and use the bigger value 
-- first, you get two prepared queries with two different parameter datatypes:

USE Northwind2;
GO
DBCC FREEPROCCACHE;
GO
SELECT FirstName, LastName, Title FROM Employees WHERE EmployeeID = 6;
GO
SELECT FirstName, LastName, Title FROM Employees WHERE EmployeeID = 622;
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';
GO


-- However, with PARAMETERIZATION FORCED, that’s not what we get, as you can see when you run 
-- the following code:

USE Northwind2;
GO
ALTER DATABASE Northwind2 SET PARAMETERIZATION FORCED;
GO
SET STATISTICS IO ON;
GO
DBCC FREEPROCCACHE;
GO
SELECT * FROM BigOrders WHERE CustomerID = 'CENTC'
GO
SELECT * FROM BigOrders WHERE CustomerID = 'SAVEA'
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
         CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';
GO
ALTER DATABASE Northwind2 SET PARAMETERIZATION SIMPLE;
GO


-- The same cached plan can be used for all the following queries:

EXEC sp_executesql N'SELECT FirstName, LastName, Title
       FROM Employees
       WHERE EmployeeID = @p', N'@p tinyint', 6;
EXEC sp_executesql N'SELECT FirstName, LastName, Title
       FROM Employees
       WHERE EmployeeID = @p', N'@p tinyint', 2;
EXEC sp_executesql N'SELECT FirstName, LastName, Title
       FROM Employees
       WHERE EmployeeID = @p', N'@p tinyint', 6;


-- If we take the same example used earlier when we set the database to PARAMETERIZATION FORCED, 
-- we can see that using sp_executesql is just as inappropriate.

USE Northwind2;
GO
SET STATISTICS IO ON;
GO
DBCC FREEPROCCACHE;
GO
EXEC sp_executesql N'SELECT * FROM BigOrders
        WHERE CustomerID = @p', N'@p nvarchar(10)', 'CENTC';
GO
EXEC sp_executesql N'SELECT * FROM BigOrders
        WHERE CustomerID = @p', N'@p nvarchar(10)', 'SAVEA';
GO
SELECT usecounts, cacheobjtype, objtype, [text]
FROM sys.dm_exec_cached_plans P
        CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cacheobjtype = 'Compiled Plan'
        AND [text] NOT LIKE '%dm_exec_cached_plans%';
GO
SET STATISTICS IO OFF;
GO


-- Here is an example in the Northwind2 database of forcing recompilation for a stored procedure:

USE Northwind2;
GO
CREATE PROCEDURE P_Customers
  @cust nvarchar(10)
AS
  SELECT RowNum, CustomerID, OrderDate, ShipCountry
  FROM BigOrders
WHERE CustomerID = @cust;
GO
DBCC FREEPROCCACHE;
GO
SET STATISTICS IO ON;
GO
EXEC P_Customers 'CENTC';
GO
EXEC P_Customers 'SAVEA';
GO
EXEC P_Customers 'SAVEA' WITH RECOMPILE;

