
USE AdventureWorks2012;

SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
OPTION (HASH GROUP, FAST 10);



--declare @val30 int = RAND() *10
--waitfor delay @val30


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

