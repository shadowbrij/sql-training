

USE AdventureWorks2012;

SELECT ProductID, OrderQty, UnitPrice, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $2.00
--COMPUTE SUM(OrderQty), SUM(LineTotal);




--declare @val22 int = RAND() *10
--waitfor delay @val22







/*
You can use COMPUTE BY and COMPUTE without BY in the same query. 
The following query finds the sum of order quantities and line 
totals by product type, and then computes the grand total of 
order quantities and line totals.
*/

USE AdventureWorks2012;

SELECT ProductID, OrderQty, UnitPrice, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
--COMPUTE SUM(OrderQty), SUM(LineTotal) BY ProductID
--COMPUTE SUM(OrderQty), SUM(LineTotal);



--declare @val23 int = RAND() *10
--waitfor delay @val23




------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
P. Calculating computed sums on all rows 
The following example shows only three columns in the select 
list and gives totals based on all order quantities and all line 
totals at the end of the results.
*/

USE AdventureWorks2012;

SELECT ProductID, OrderQty, LineTotal
FROM Sales.SalesOrderDetail
--COMPUTE SUM(OrderQty), SUM(LineTotal);





--declare @val24 int = RAND() *10
--waitfor delay @val24




------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
Q. Using more than one COMPUTE clause 
The following example finds the sum of the prices of all orders 
whose unit price is less than $5 organized by product ID and order 
quantity, as well as the sum of the prices of all orders less than 
$5 organized by product ID only. You can use different aggregate 
functions in the same statement by including more than one COMPUTE 
BY clause.
*/

USE AdventureWorks2012;

SELECT ProductID, OrderQty, UnitPrice, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID, OrderQty, LineTotal
--COMPUTE SUM(LineTotal) BY ProductID, OrderQty
--COMPUTE SUM(LineTotal) BY ProductID;




--declare @val25 int = RAND() *10
--waitfor delay @val25



------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
R. Comparing GROUP BY with COMPUTE 
The first example that follows uses the COMPUTE clause to 
calculate the sum of all orders whose product's unit price 
is less than $5.00, by type of product. The second example 
produces the same summary information by using only GROUP BY.
*/

USE AdventureWorks2012;

SELECT ProductID, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
--COMPUTE SUM(LineTotal) BY ProductID;




--declare @val26 int = RAND() *10
--waitfor delay @val26




/*
This is the second query that uses GROUP BY.
*/

USE AdventureWorks2012;

SELECT ProductID, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID
ORDER BY ProductID;


------
