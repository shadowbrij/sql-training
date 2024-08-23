
/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
K. Using the HAVING clause 
The first example that follows shows a HAVING clause with an 
aggregate function. It groups the rows in the SalesOrderDetail 
table by product ID and eliminates products whose average order 
quantities are five or less. The second example shows a HAVING 
clause without aggregate functions. 
*/

USE AdventureWorks2012;

SELECT ProductID 
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING AVG(OrderQty) > 5
ORDER BY ProductID;



declare @val15 int = RAND() *100
waitfor delay @val15



/*
This query uses the LIKE clause in the HAVING clause. 
*/

USE AdventureWorks2012 ;

SELECT SalesOrderID, CarrierTrackingNumber 
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID, CarrierTrackingNumber
HAVING CarrierTrackingNumber LIKE '4BD%'
ORDER BY SalesOrderID ;
  



declare @val16 int = RAND() *100
waitfor delay @val16



------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
L. Using HAVING and GROUP BY 
The following example shows using GROUP BY, HAVING, WHERE, and 
ORDER BY clauses in one SELECT statement. It produces groups and 
summary values but does so after eliminating the products with 
prices over $25 and average order quantities under 5. It also 
organizes the results by ProductID.
*/

USE AdventureWorks2012;

SELECT ProductID 
FROM Sales.SalesOrderDetail
WHERE UnitPrice < 25.00
GROUP BY ProductID
HAVING AVG(OrderQty) > 5
ORDER BY ProductID;



declare @val17 int = RAND() *100
waitfor delay @val17


------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
M. Using HAVING with SUM and AVG 
The following example groups the SalesOrderDetail table by product 
ID and includes only those groups of products that have orders 
totaling more than $1000000.00 and whose average order quantities 
are less than 3.
*/

USE AdventureWorks2012;

SELECT ProductID, AVG(OrderQty) AS AverageQuantity, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > $1000000.00
AND AVG(OrderQty) < 3;




declare @val18 int = RAND() *100
waitfor delay @val18



/*
To see the products that have had total sales greater than 
$2000000.00, use this query:
*/

USE AdventureWorks2012;

SELECT ProductID, Total = SUM(LineTotal)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > $2000000.00;



declare @val19 int = RAND() *100
waitfor delay @val19




/*
If you want to make sure there are at least one thousand five 
hundred items involved in the calculations for each product, use 
HAVING COUNT(*) > 1500 to eliminate the products that return totals 
for fewer than 1500 items sold. The query looks like this:
*/

USE AdventureWorks2012;

SELECT ProductID, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) > 1500;



declare @val20 int = RAND() *100
waitfor delay @val20




------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
N. Calculating group totals by using COMPUTE BY 
The following example uses two code examples to show the use 
of COMPUTE BY. The first code example uses one COMPUTE BY with 
one aggregate function, and the second code example uses one 
COMPUTE BY item and two aggregate functions.

This query calculates the sum of the orders, for products with 
prices less than $5.00, for each type of product.
*/

USE AdventureWorks2012;

SELECT ProductID, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID, LineTotal
--COMPUTE SUM(LineTotal) BY ProductID;




/*
This query retrieves the product type and order total for 
products with unit prices under $5.00. The COMPUTE BY 
clause uses two different aggregate functions.
*/

USE AdventureWorks2012;

SELECT ProductID, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID, LineTotal
--COMPUTE SUM(LineTotal), MAX(LineTotal) BY ProductID;


declare @val21 int = RAND() *100
waitfor delay @val21




------

/*  http://msdn.microsoft.com/en-us/library/ms187731.aspx
O. Calculating grand values by using COMPUTE without BY 
The COMPUTE keyword can be used without BY to generate grand 
totals, grand counts, and so on.

The following example finds the grand total of the prices and 
advances for all types of products les than $2.00.
*/

USE AdventureWorks2012;

SELECT ProductID, OrderQty, UnitPrice, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $2.00
--COMPUTE SUM(OrderQty), SUM(LineTotal);




declare @val22 int = RAND() *100
waitfor delay @val22







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



declare @val23 int = RAND() *100
waitfor delay @val23




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





declare @val24 int = RAND() *100
waitfor delay @val24




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




declare @val25 int = RAND() *100
waitfor delay @val25



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




declare @val26 int = RAND() *100
waitfor delay @val26




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
