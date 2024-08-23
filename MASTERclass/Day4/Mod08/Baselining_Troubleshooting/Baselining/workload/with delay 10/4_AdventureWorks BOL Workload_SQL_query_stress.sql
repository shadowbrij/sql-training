
/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
S. Using SELECT with GROUP BY, COMPUTE, and ORDER BY clauses 
The following example returns only those orders whose unit 
price is less than $5, and then computes the line total sum 
by product and the grand total. All computed columns appear 
within the select list.
*/

USE AdventureWorks2012;

SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
--COMPUTE SUM(SUM(LineTotal)) BY ProductID, OrderQty
--COMPUTE SUM(SUM(LineTotal));




declare @val27 int = RAND() *10
waitfor delay @val27



------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
T. Using the INDEX optimizer hint 
The following example shows two ways to use the INDEX 
optimizer hint. The first example shows how to force the 
optimizer to use a nonclustered index to retrieve rows from 
a table, and the second example forces a table scan by using 
an index of 0.
*/

USE AdventureWorks2012;

SELECT pp.FirstName, pp.LastName, e.NationalIDNumber
FROM HumanResources.Employee AS e
JOIN Person.Person AS pp on e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson';



declare @val28 int = RAND() *10
waitfor delay @val28



-- Force a table scan by using INDEX = 0.
USE AdventureWorks2012;

SELECT pp.LastName, pp.FirstName, e.JobTitle
FROM HumanResources.Employee AS e WITH (INDEX = 0) JOIN Person.Person AS pp
ON e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson';



declare @val29 int = RAND() *10
waitfor delay @val29



------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
U. Using OPTION and the GROUP hints 
The following example shows how the OPTION (GROUP) clause
is used with a GROUP BY clause.
*/

USE AdventureWorks2012;

SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
OPTION (HASH GROUP, FAST 10);



declare @val30 int = RAND() *10
waitfor delay @val30


------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
--V. Using the UNION query hint 
--The following example uses the MERGE UNION query hint.
*/

USE AdventureWorks2012;

SELECT *
FROM HumanResources.Employee AS e1
UNION
SELECT *
FROM HumanResources.Employee AS e2
OPTION (MERGE UNION);


------

