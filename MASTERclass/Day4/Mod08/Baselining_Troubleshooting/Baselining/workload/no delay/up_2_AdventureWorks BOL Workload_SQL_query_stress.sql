

USE AdventureWorks2012 ;

UPDATE Production.Product
SET ListPrice = ListPrice + 1
WHERE product.ProductID % @prodnum =0;


declare @val46 int = RAND() *10
waitfor delay @val46



USE AdventureWorks2012 ;

UPDATE Production.Product
SET ListPrice = ListPrice - 1
WHERE product.ProductID % @prodnum =0;



declare @val47 int = RAND() *10
waitfor delay @val47




USE AdventureWorks2012;

DECLARE @NewPrice int = 10;
UPDATE Production.Product
SET ListPrice += @NewPrice
WHERE Color = N'Red';


declare @val48 int = RAND() *10
waitfor delay @val48

USE AdventureWorks2012;

UPDATE Sales.SalesPerson
SET SalesYTD = SalesYTD + 
    (SELECT SUM(so.SubTotal) 
     FROM Sales.SalesOrderHeader AS so
     WHERE so.OrderDate = (SELECT MAX(OrderDate)
                           FROM Sales.SalesOrderHeader AS so2
                           WHERE so2.SalesPersonID = so.SalesPersonID)
     AND Sales.SalesPerson.BusinessEntityID = so.SalesPersonID
     GROUP BY so.SalesPersonID);



declare @val49 int = RAND() *10
waitfor delay @val49


USE AdventureWorks2012;

UPDATE Production.Location
SET CostRate = DEFAULT
WHERE CostRate > (select RAND()*100);


declare @val50 int = RAND() *10
waitfor delay @val50


USE AdventureWorks2012;

UPDATE Person.vStateProvinceCountryRegion
SET CountryRegionName = 'United States of America'
WHERE CountryRegionName = 'United States';


declare @val51 int = RAND() *10
waitfor delay @val51




USE AdventureWorks2012;

UPDATE Sales.SalesPerson
SET SalesYTD = SalesYTD + SubTotal
FROM Sales.SalesPerson AS sp
JOIN Sales.SalesOrderHeader AS so
    ON sp.BusinessEntityID = so.SalesPersonID
    AND so.OrderDate = (SELECT MAX(OrderDate)
                        FROM Sales.SalesOrderHeader
                        WHERE SalesPersonID = sp.BusinessEntityID);



declare @val52 int = RAND() *10
waitfor delay @val52



USE AdventureWorks2012;

UPDATE Sales.SalesPerson
SET SalesYTD = SalesYTD + 
    (SELECT SUM(so.SubTotal) 
     FROM Sales.SalesOrderHeader AS so
     WHERE so.OrderDate = (SELECT MAX(OrderDate)
                           FROM Sales.SalesOrderHeader AS so2
                           WHERE so2.SalesPersonID = so.SalesPersonID)
     AND Sales.SalesPerson.BusinessEntityID = so.SalesPersonID
     GROUP BY so.SalesPersonID);



declare @val53 int = RAND() *10
waitfor delay @val53



UPDATE Production.Document
SET DocumentSummary .WRITE (N' Appending data to the end of the column.', NULL, 0)
WHERE Title = N'Crank Arm and Tire Maintenance';


declare @val54 int = RAND() *10
waitfor delay @val54



UPDATE Production.Document
SET DocumentSummary .WRITE (NULL, 56, 0)
WHERE Title = N'Crank Arm and Tire Maintenance';


