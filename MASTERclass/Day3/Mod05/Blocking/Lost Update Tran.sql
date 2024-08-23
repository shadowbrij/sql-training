
/* SESSION 1*/
USE AdventureWorks2008;

DECLARE @SafetyStockLevel   int = 0
        ,@Uplift            int = 5;

BEGIN TRAN;
SELECT  @SafetyStockLevel = SafetyStockLevel
FROM    Production.Product
WHERE   ProductID = 1;

SET     @SafetyStockLevel = @SafetyStockLevel + @Uplift;

WAITFOR DELAY '00:00:05.000';

UPDATE  Production.Product
SET     SafetyStockLevel = @SafetyStockLevel 
WHERE   ProductID = 1;

SELECT  SafetyStockLevel
FROM    Production.Product
WHERE   ProductID = 1;

COMMIT TRAN;
GO
-- Cut and paste this second half into another browser session and run it from there.

/* SESSION 2*/
USE AdventureWorks2008;

DECLARE @SafetyStockLevel   int = 0
        ,@Uplift            int = 100;

BEGIN TRAN;
SELECT  @SafetyStockLevel = SafetyStockLevel
FROM    Production.Product
WHERE   ProductID = 1;

SET     @SafetyStockLevel = @SafetyStockLevel + @Uplift;

UPDATE  Production.Product
SET     SafetyStockLevel = @SafetyStockLevel 
WHERE   ProductID = 1;

SELECT  SafetyStockLevel
FROM    Production.Product
WHERE   ProductID = 1;

COMMIT TRAN;
