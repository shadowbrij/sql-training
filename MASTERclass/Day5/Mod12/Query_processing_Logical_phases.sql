--Code Snippet 1.1 (Setup)
create database peoplewareindia
Go

USE peoplewareindia;
GO
IF OBJECT_ID('dbo.Orders') IS NOT NULL
  DROP TABLE dbo.Orders;
GO
IF OBJECT_ID('dbo.Customers') IS NOT NULL
  DROP TABLE dbo.Customers;
GO
CREATE TABLE dbo.Customers
(
  customerid  CHAR(5)     NOT NULL PRIMARY KEY,
  city        VARCHAR(10) NOT NULL
);

INSERT INTO dbo.Customers(customerid, city) VALUES('SATYA', 'Hyderabad');
INSERT INTO dbo.Customers(customerid, city) VALUES('INFY', 'Hyderabad');
INSERT INTO dbo.Customers(customerid, city) VALUES('TCSS', 'Hyderabad');
INSERT INTO dbo.Customers(customerid, city) VALUES('WIP', 'Mumbai');

CREATE TABLE dbo.Orders
(
  orderid    INT        NOT NULL PRIMARY KEY,
  customerid CHAR(5)    NULL     REFERENCES Customers(customerid)
);

INSERT INTO dbo.Orders(orderid, customerid) VALUES(1, 'INFY');
INSERT INTO dbo.Orders(orderid, customerid) VALUES(2, 'INFY');
INSERT INTO dbo.Orders(orderid, customerid) VALUES(3, 'TCSS');
INSERT INTO dbo.Orders(orderid, customerid) VALUES(4, 'TCSS');
INSERT INTO dbo.Orders(orderid, customerid) VALUES(5, 'TCSS');
INSERT INTO dbo.Orders(orderid, customerid) VALUES(6, 'WIP');
INSERT INTO dbo.Orders(orderid, customerid) VALUES(8, NULL);




--Code Snippet 1.2 (Setup)
--The query returns customers from Hyderabad that made fewer than three orders (including zero orders), along with their order counts. The result is sorted by order count, from smallest to largest.

set nocount on
SELECT C.customerid, COUNT(O.orderid) AS numorders
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid
WHERE C.city = 'Hyderabad'
GROUP BY C.customerid
HAVING COUNT(o.orderid) < 3
ORDER BY numorders;

--Both SATYA & INFY are from HYD who made fewer than 3 orders
--Go back to ppt and try to match it with logical phases



--Lets try to break down the query (Following are the steps under code snippet 1.3)

--Step 1 - Performing a Cartesian Product (Cross Join)
--(a cross join, or an unrestricted join) is performed between the first two tables that appear in the FROM clause. VT1 is generated. VT1 will contain n x m rows. Note the prefis as well

SELECT C.*, O.*
FROM dbo.Customers AS C
  CROSS JOIN dbo.Orders AS O
  
  

--Step 2 - Applying the ON Filter (Join Condition)
-- First of three possible filters (ON, WHERE, and HAVING). ON filter applied to VT1. Only rows for which the <join_condition> is TRUE are returned as VT2.


SELECT C.*, O.*
FROM dbo.Customers AS C
  INNER JOIN dbo.Orders AS O
ON C.customerid = O.customerid

--Lets discuss Three valued logic
--run the step1 query again and see NULLs in customer id that evaluate to UNKNOWN.


--Step 3 - Outer Join
--This step is relevant only for an outer join.
--(LEFT, RIGHT, or FULL). Marking a table as preserved
----The added rows are referred to as outer rows.
--NULLs are assigned to the attributes (column values) of the nonpreserved table
--VT3 is generated



SELECT C.*, O.*
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
ON C.customerid = O.customerid

--rememebr, if mroe than 2 tables are joined, step 1 to 3 will repeat.


-- step 4 - where clause
--VT4 is generated, only rows tht evaluate to true

SELECT C.*, O.*
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid 
    WHERE C.city = 'Hyderabad'
    
--lets do a simple trick here:
--first compare the 2 query, notice the difference in the query
--now run the query and notice the difference in the resultset


SELECT C.*, O.*
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid 
    and C.city = 'Hyderabad'

-- whts the problem with the above query ??

--the above happens only in case of Outer joins, not INNER (so dont be confused as to where should you apply your filter, in ON condition or WHERE clause)



--step 5 - Group (VT5 is generated)
--Each unique combination of values in the column list that appears in the GROUP BY clause makes a group
--Each base row from the previous step is attached to one and only one group
--This phase considers NULLs as equal.

SELECT C.customerid,COUNT(O.orderid) as numorders
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid
    WHERE C.city = 'Hyderabad'
    GROUP BY C.customerid


--step 6 CUBE and ROLLUP (skipped)

--step 7 - HAVING clause (VT7 is returned)
--The HAVING filter is the first and only filter that applies to the grouped data

SELECT C.customerid, COUNT(O.orderid) AS numorders
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid
WHERE C.city = 'Hyderabad'
GROUP BY C.customerid
HAVING COUNT(o.orderid) < 3

--lets do another trick, change COUNT(O.orderid) in the above query to COUNT(*) and the run the query again. Wht happened? Why?


--select * from Orders


--step 8,9,10 (SELECT, DISTINCT, ORDER BY)
--Some important points to remember
--Remember, Aliases created by the SELECT list cannot be used by earlier steps
--In the ORDER BY clause, you can also specify ordinal positions of result columns from the SELECT list
--The ORDER BY step considers NULLs as equal. That is, NULLs are sorted together

SELECT C.customerid, COUNT(O.orderid) AS numorders
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid
WHERE C.city = 'Hyderabad'
GROUP BY C.customerid
HAVING COUNT(o.orderid) < 3
ORDER BY numorders;


--- Whts the difference between this query and the above query?

SELECT distinct C.customerid, COUNT(O.orderid) AS numorders
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid
WHERE C.city = 'Hyderabad'
GROUP BY C.customerid
HAVING COUNT(o.orderid) < 3
ORDER BY numorders;


--Step 11 - TOP clause

SELECT TOP(2) C.customerid, COUNT(O.orderid) AS numorders
FROM dbo.Customers AS C
  LEFT OUTER JOIN dbo.Orders AS O
    ON C.customerid = O.customerid
WHERE C.city = 'Hyderabad'
GROUP BY C.customerid
HAVING COUNT(o.orderid) < 3
ORDER BY numorders desc;

-- whts the output of the following query?

SELECT *
FROM (SELECT orderid, customerid
      FROM dbo.Orders
      ORDER BY orderid) AS Test;


CREATE VIEW dbo.VwSortedOrders
AS

SELECT orderid, customerid
FROM dbo.Orders
ORDER BY orderid
GO

--a query with an ORDER BY clause cannot be used as a table expression,that is, a view, inline table-valued function, subquery, derived table, or common table expression (CTE).

-- and this?

--step 11 - apply the TOP clause
--notes about top:
--this step relies on physical order of rows
--unique order by list (deterministic)
--non unique (non-deterministic)
--so how to gaurantee determinism (TOP with unique ORDER by list or WITH TIES)

SELECT *
FROM (SELECT TOP 100 PERCENT orderid, customerid
      FROM dbo.Orders
      ORDER BY orderid) AS Test;


Or:

CREATE VIEW dbo.VwSortedOrders
AS

SELECT TOP 100 PERCENT orderid, customerid
FROM dbo.Orders
ORDER BY orderid
GO

-- TOP & Order By together?? whts the big deal?
-- TOP with ties? How is this related to detminism & non-determinism??

USE AdventureWorks;
GO
SELECT TOP(10) PERCENT WITH TIES
c.FirstName, c.LastName, e.Title, e.Gender, r.Rate
FROM Person.Contact c 
    INNER JOIN HumanResources.Employee e
        ON c.ContactID = e.ContactID
    INNER JOIN HumanResources.EmployeePayHistory r
        ON r.EmployeeID = e.EmployeeID
ORDER BY Rate DESC;
