

USE AdventureWorks2012;

UPDATE Person.Address
SET ModifiedDate = GETDATE()
where address.AddressID % 10 = 0;

declare @val37 int = RAND() *10
waitfor delay @val37



USE AdventureWorks2012;

UPDATE Sales.SalesPerson
SET Bonus = 6000, CommissionPct = .10, SalesQuota = NULL
where SalesPerson.BusinessEntityID % 11 = 0 ;


declare @val38 int = RAND() *10
waitfor delay @val38



USE AdventureWorks2012;

DECLARE @prodnum int = (select RAND() *10)
UPDATE Production.Product
SET Color = N'Metallic Red'
WHERE product.ProductID % @prodnum =0


declare @val39 int = RAND() *10
waitfor delay @val39



USE AdventureWorks2012;

UPDATE TOP (10) HumanResources.Employee
SET VacationHours = VacationHours + 1;


declare @val40 int = RAND() *10
waitfor delay @val40



USE AdventureWorks2012;

UPDATE TOP (10) HumanResources.Employee
SET VacationHours = VacationHours - 1;


declare @val41 int = RAND() *10
waitfor delay @val41



UPDATE HumanResources.Employee
SET VacationHours = VacationHours + 8
FROM (SELECT TOP 10 BusinessEntityID FROM HumanResources.Employee
     ORDER BY HireDate ASC) AS th
WHERE HumanResources.Employee.BusinessEntityID = th.BusinessEntityID;


declare @val42 int = RAND() *10
waitfor delay @val42





UPDATE HumanResources.Employee
SET VacationHours = VacationHours - 8
FROM (SELECT TOP 10 BusinessEntityID FROM HumanResources.Employee
     ORDER BY HireDate ASC) AS th
WHERE HumanResources.Employee.BusinessEntityID = th.BusinessEntityID;



declare @val43 int = RAND() *10
waitfor delay @val43




USE AdventureWorks2012;

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
        b.EndDate, 0 AS ComponentLevel
    FROM Production.BillOfMaterials AS b
    WHERE b.ProductAssemblyID = 800
          AND b.EndDate IS NULL
    UNION ALL
    SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,
        bom.EndDate, ComponentLevel + 1
    FROM Production.BillOfMaterials AS bom 
        INNER JOIN Parts AS p
        ON bom.ProductAssemblyID = p.ComponentID
        AND bom.EndDate IS NULL
)
UPDATE Production.BillOfMaterials
SET PerAssemblyQty = c.PerAssemblyQty +1
FROM Production.BillOfMaterials AS c
JOIN Parts AS d ON c.ProductAssemblyID = d.AssemblyID
WHERE d.ComponentLevel = 0; 


declare @val44 int = RAND() *10
waitfor delay @val44



USE AdventureWorks2012;

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
        b.EndDate, 0 AS ComponentLevel
    FROM Production.BillOfMaterials AS b
    WHERE b.ProductAssemblyID = 800
          AND b.EndDate IS NULL
    UNION ALL
    SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,
        bom.EndDate, ComponentLevel + 1
    FROM Production.BillOfMaterials AS bom 
        INNER JOIN Parts AS p
        ON bom.ProductAssemblyID = p.ComponentID
        AND bom.EndDate IS NULL
)
UPDATE Production.BillOfMaterials
SET PerAssemblyQty = c.PerAssemblyQty -1
FROM Production.BillOfMaterials AS c
JOIN Parts AS d ON c.ProductAssemblyID = d.AssemblyID
WHERE d.ComponentLevel = 0; 


declare @val45 int = RAND() *10
waitfor delay @val45


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


