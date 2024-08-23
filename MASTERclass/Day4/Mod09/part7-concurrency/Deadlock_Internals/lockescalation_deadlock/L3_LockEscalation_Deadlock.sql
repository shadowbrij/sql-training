-- L3_LockEscalation_Deadlock.sql
-- Demo folder: Assets\lockescalation_deadlock

-- Step 1: run setup.sql to create the partition function and scheme
-- Step 2: run the fkeys.sql to drop the foreigh keys
-- STep 3: run pks.sql to drop and recreate the primary key (this time on the partition)
-- step 4: run the below code


-- Connection 1 
-- SELECT lock_escalation_desc FROM sys.tables WHERE name = 'Customer';
-- ALTER TABLE Sales.Customer SET (LOCK_ESCALATION = TABLE)
-- Access partition 1 

USE AdventureWorks2008R2
GO

ALTER TABLE Sales.Customer SET (LOCK_ESCALATION = AUTO)

BEGIN TRAN
UPDATE Sales.Customer SET TerritoryID=1 WHERE CustomerID < 18000

WAITFOR DELAY '00:00:05'

-- Access partition 2
SELECT TerritoryID FROM Sales.Customer WHERE CustomerID=19800
-- Rollback


-- Connection 2

USE AdventureWorks2008R2
GO

-- update partition 2
BEGIN TRAN
UPDATE Sales.Customer SET TerritoryID=1 WHERE CustomerID between 18500 and 26200

WAITFOR DELAY '00:00:05'

-- Access partition 1 
SELECT TerritoryID FROM Sales.Customer WHERE CustomerID=100
GO
--Rollback

-- ROLLBACK the transaction that wasn't the victim