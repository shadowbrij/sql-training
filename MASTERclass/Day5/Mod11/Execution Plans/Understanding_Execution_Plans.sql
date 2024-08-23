--Understanding Execution plans

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


---

USE AdventureWorks
GO



-- table scan

select * from 
dbo.DatabaseLog



-- clustered index scan

SELECT *
FROM Person.Contact


-- clustered index seek

SELECT *
FROM Person.Contact
where ContactID = 1


-- non clustered index seek

SELECT ContactID
FROM Person.Contact
WHERE EmailAddress LIKE 'sab'


-- key lookup

SELECT ContactID,
LastName, Phone
FROM Person.Contact
WHERE EmailAddress LIKE 'sab%'


-- RID lookup

SELECT *
FROM [dbo].[DatabaseLog]
WHERE DatabaseLogID = 1


-- table joins
-- nested loop

SELECT  e.[Title] ,
        a.[City] ,
        c.[LastName] + ',' + c.[FirstName] AS EmployeeName
FROM    [HumanResources].[Employee] e
        INNER JOIN [HumanResources].[EmployeeAddress] ed ON e.[EmployeeID] = ed.[EmployeeID]
        INNER JOIN [Person].[Address] a ON [ed].[AddressID] = [a].[AddressID]
        INNER JOIN [Person].[Contact] c ON e.[ContactID] = c.[ContactID];
        
        
-- table joins
-- merge joins

SELECT c.CustomerID
FROM Sales.SalesOrderDetail od
JOIN Sales.SalesOrderHeader oh
ON od.SalesOrderID = oh.SalesOrderID
JOIN Sales.Customer c
ON oh.CustomerID = c.CustomerID


-- adding a where clause

SELECT  e.[Title] ,
        a.[City] ,
        c.[LastName] + ',' + c.[FirstName] AS EmployeeName
FROM    [HumanResources].[Employee] e
        INNER JOIN [HumanResources].[EmployeeAddress] ed ON e.[EmployeeID] = ed.[EmployeeID]
        INNER JOIN [Person].[Address] a ON [ed].[AddressID] = [a].[AddressID]
        INNER JOIN [Person].[Contact] c ON e.[ContactID] = c.[ContactID]
WHERE   e.[Title] = 'Production Technician – WC20' ;



-- Hash Joins
use adventureworks
GO

SELECT e.[Title],
a.[City],
c.[LastName] + ', ' + c.[FirstName] AS EmployeeName
FROM [HumanResources].[Employee] e
JOIN [HumanResources].[EmployeeAddress] ed ON e.[EmployeeID] = ed.[EmployeeID]
JOIN [Person].[Address] a ON [ed].[AddressID] = [a].[AddressID]
JOIN [Person].[Contact] c ON e.[ContactID] = c.[ContactID];


-- sort


SELECT *
FROM [Production].[ProductInventory]
ORDER BY [Shelf]


-- aggregates

SELECT [City],
COUNT([City]) AS CityCount
FROM [Person].[Address]
GROUP BY [City]


-- having


SELECT [City],
COUNT([City]) AS CityCount
FROM [Person].[Address]
GROUP BY [City]
HAVING COUNT([City]) > 1



-- Insert plans

INSERT  INTO [AdventureWorks].[Person].[Address]
        ( [AddressLine1] ,
          [AddressLine2] ,
          [City] ,
          [StateProvinceID] ,
          [PostalCode] ,
          [rowguid] ,
          [ModifiedDate]
        )
VALUES  ( '1313 Mockingbird Lane' ,
          'Basement' ,
          'Springfield' ,
          24 ,
          '02134' ,
          newid() ,
          getdate()
        ) ;
        
        
-- update plans

UPDATE [Person].[Address]
SET [City] = 'Munro',
[ModifiedDate] = GETDATE()
WHERE [City] = 'Monroe' ;


-- delete plans

DELETE FROM [Person].[Address]
WHERE [AddressID] = 52;



--- ASSERT

 --The Assert operator verifies a condition. For example, it validates referential integrity or ensures that a scalar subquery returns one row. For each input row, the Assert operator evaluates the expression in the Argument column of the execution plan. If this expression evaluates to NULL, the row is passed through the Assert operator and the query execution continues. If this expression evaluates to a nonnull value, the appropriate error will be raised. The Assert operator is a physical operator.

 
IF OBJECT_ID('Tab1') IS NOT NULL
DROP TABLE Tab1
GO
CREATE TABLE Tab1(ID Integer, Gender CHAR(1))
GO
ALTER TABLE TAB1 ADD CONSTRAINT ck_Gender_M_F CHECK(Gender IN('M','F'))
GO
INSERT INTO Tab1(ID, Gender) VALUES(1,'X')
GO



-- Distribute Streams 
-- The Distribute Streams operator is used only in parallel query plans. The Distribute Streams operator takes a single input stream of records and produces multiple output streams. The record contents and format are not changed. Each record from the input stream appears in one of the output streams. This operator automatically preserves the relative order of the input records in the output streams. Usually, hashing is used to decide to which output stream a particular input record belongs.

--If the output is partitioned, then the Argument column contains a PARTITION COLUMNS:() predicate and the partitioning columns. Distribute Streams is a logical operator
 


 --Gather Streams 
 --The Gather Streams operator is only used in parallel query plans. The Gather Streams operator consumes several input streams and produces a single output stream of records by combining the input streams. The record contents and format are not changed. If this operator is order preserving, all input streams must be ordered. If the output is ordered, the Argument column contains an ORDER BY:() predicate and the names of columns being ordered. Gather Streams is a logical operator.
 
 
 --Repartition Streams 
 --The Repartition Streams operator consumes multiple streams and produces multiple streams of records. The record contents and format are not changed. If the query optimizer uses a bitmap filter, the number of rows in the output stream is reduced. Each record from an input stream is placed into one output stream. If this operator is order preserving, all input streams must be ordered and merged into several ordered output streams. If the output is partitioned, the Argument column contains a PARTITION COLUMNS:() predicate and the partitioning columns.If the output is ordered, the Argument column contains an ORDER BY:() predicate and the columns being ordered. Repartition Streams is a logical operator. The operator is used only in parallel query plans.
 
 
--Here is a query that uses parallel plan.

use AdventureWorks2008R2
GO

select * from sales.SalesOrderDetail
order by LineTotal DESC
GO


--Bitmap 
-- SQL Server uses the Bitmap operator to implement bitmap filtering in parallel query plans. Bitmap filtering speeds up query execution by eliminating rows with key values that cannot produce any join records before passing rows through another operator such as the Parallelism operator. A bitmap filter uses a compact representation of a set of values from a table in one part of the operator tree to filter rows from a second table in another part of the tree. By removing unnecessary rows early in the query, subsequent operators have fewer rows to work with, and the overall performance of the query improves. The optimizer determines when a bitmap is selective enough to be useful and in which operators to apply the filter. Bitmap is a physical operator.
 
--  Bitmap Create 
-- The Bitmap Create operator appears in the Showplan output where bitmaps are built. Bitmap Create is a logical operator.
 

USE TUNING
GO

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where tblorders.orderid > 100 AND tblorders.orderid < 10000
GO


-- concatenation
--The Concatenation operator scans multiple inputs, returning each row scanned. Concatenation is typically used to implement the Transact-SQL UNION ALL construct. The Concatenation physical operator has two or more inputs and one output. Concatenation copies rows from the first input stream to the output stream, then repeats this operation for each additional input stream. Concatenation is a logical and physical operator.



USE tempdb
GO
CREATE TABLE TABTeste(ID Int Identity(1,1) PRIMARY KEY,
Nome VarChar(250) DEFAULT NewID())
GO
SET NOCOUNT ON
GO
INSERT INTO TABTeste DEFAULT VALUES
GO 10000


SELECT *
FROM TABTeste a
INNER JOIN TABTeste b
ON a.ID = b.ID
INNER JOIN TABTeste c
ON b.ID = c.ID


SELECT * FROM TABTeste
UNION ALL
SELECT * FROM TABTeste
UNION ALL
SELECT * FROM TABTeste
UNION ALL
SELECT * FROM TABTeste


-- Eager Spool
--The Eager Spool operator takes the entire input, storing each row in a hidden temporary object stored in the tempdb database. If the operator is rewound (for example, by a Nested Loops operator) but no rebinding is needed, the spooled data is used instead of rescanning the input. If rebinding is needed, the spooled data is discarded and the spool object is rebuilt by rescanning the (rebound) input. The Eager Spool operator builds its spool file in an "eager" manner: when the spool's parent operator asks for the first row, the spool operator consumes all rows from its input operator and stores them in the spool. Eager Spool is a logical operator.



USE TempDB
GO
SET NOCOUNT ON
IF OBJECT_ID('Employees') IS NOT NULL
DROP TABLE Employees
GO
CREATE TABLE Employees(ID Int IDENTITY(1,1) PRIMARY KEY,
Nome VarChar(30),
Salary Numeric(18,2));
GO
DECLARE @I SmallInt
SET @I = 0
WHILE @I < 100
BEGIN
INSERT INTO Employees(Nome, Salary)
SELECT 'Amit', ABS(CONVERT(Numeric(18,2), (CheckSUM(NEWID()) / 500000.0)))
SET @I = @I + 1
END
CREATE NONCLUSTERED INDEX ix_Salary ON Employees(Salary)
GO


UPDATE Employees SET Salary = Salary * 1.1
FROM Employees
WHERE Salary < 2000


UPDATE Employees SET Salary = Salary * 1.1
FROM Employees WITH(INDEX=ix_Salary)
WHERE Salary < 2000




--Lazy Spool 
--The Lazy Spool logical operator stores each row from its input in a hidden temporary object stored in the tempdb database. If the operator is rewound (for example, by a Nested Loops operator) but no rebinding is needed, the spooled data is used instead of rescanning the input. If rebinding is needed, the spooled data is discarded and the spool object is rebuilt by rescanning the (rebound) input. The Lazy Spool operator builds its spool file in a "lazy" manner, that is, each time the spool's parent operator asks for a row, the spool operator gets a row from its input operator and stores it in the spool, rather than consuming all rows at once. Lazy Spool is a logical operator. 
 
 
 
 
 
 -- Index spool
-- The Index Spool physical operator contains a SEEK:() predicate in the Argument column. The Index Spool operator scans its input rows, placing a copy of each row in a hidden spool file (stored in the tempdb database and existing only for the lifetime of the query), and builds a nonclustered index on the rows. This allows you to use the seeking capability of indexes to output only those rows that satisfy the SEEK:() predicate. If the operator is rewound (for example, by a Nested Loops operator) but no rebinding is needed, the spooled data is used instead of rescanning the input.

 
USE AdventureWorks2008R2
GO

SELECT * INTO SOH
from sales.SalesOrderHeader
 
SELECT *
FROM SOH Ped1
WHERE Ped1.TotalDue > (
SELECT AVG(Ped2.TotalDue)
FROM SOH AS Ped2
WHERE Ped2.orderdate < Ped1.orderdate)

DROP TABLE SOH
