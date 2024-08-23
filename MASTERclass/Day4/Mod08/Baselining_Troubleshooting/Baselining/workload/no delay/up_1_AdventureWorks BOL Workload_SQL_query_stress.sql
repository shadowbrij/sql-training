

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