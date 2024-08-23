-- L3_Cyclic_Deadlock.sql
-- Cyclic deadlock

-- Step 1
-- Run the below script in connection 1

Use AdventureWorks2008R2
GO

BEGIN TRAN

UPDATE Sales.SalesOrderDetail 
SET OrderQty=10 
WHERE SalesOrderID=57024 
AND SalesOrderDetailID=60591 

WAITFOR DELAY '00:00:10'

UPDATE Person.Person SET Suffix='Mr.' WHERE BusinessEntityID=1 

-- ROLLBACK TRAN

-- Step 2
--Run the below script in connection 2
Use AdventureWorks2008R2
GO
BEGIN TRAN

UPDATE Person.Person SET Suffix='Mr.' WHERE BusinessEntityID=1 

WAITFOR DELAY '00:00:5'

UPDATE Sales.SalesOrderDetail 
SET OrderQty=10 
WHERE SalesOrderID=57024 
AND SalesOrderDetailID=60591 

-- ROLLBACK TRAN

-- Step 3: ROLLBACK the transaction that wasn't the victim