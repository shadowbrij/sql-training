----------------------------------------------------------
-- Demo: Read Committed Snapshot
-- File: L4_Read_Committed_Snapshot.sql
-- Summary: This example is very similar to the first example of snapshot isolation level. The key difference is: connection 2 can read the value committed by connection 1 even before connection 2 transaction is committed or rolled back. This is unlike snapshot isolation level.
----------------------------------------------------------

USE master
GO

-- step 1
-- Turn ON READ_COMMITTED_SNAPSHOT
ALTER DATABASE AdventureWorks2008R2 SET READ_COMMITTED_SNAPSHOT ON;
GO

USE AdventureWorks2008R2
GO

-- step 2
-- connection 1
-- fire an update locking the row exclusively
BEGIN TRAN
UPDATE Production.Product
SET ReorderPoint = 1000
WHERE ProductID = 1

SELECT * FROM Production.Product
WHERE ProductID = 1

GO

-- step 3
-- connection 1
-- Check row versions - The last committed value is stored in the version store in tempdb database

SELECT * FROM sys.dm_tran_version_store;
GO


-- step 4
-- Connection 2
-- Connection 2 can read the last committed value since it is running under Snapshot Isolation
USE AdventureWorks2008R2;
GO

BEGIN TRAN
SELECT * FROM Production.Product
WHERE ProductID = 1;
GO


-- step 5
-- connection 1
-- connection 1 - commit the transaction and verify that this transaction continues read the updated data
COMMIT TRAN

SELECT * FROM Production.Product
WHERE ProductID = 1
GO


-- step 6
-- Connection 2

SELECT * FROM Production.Product
WHERE ProductID = 1
GO

-- step 7
-- Connection 2

COMMIT TRAN

SELECT * FROM Production.Product
WHERE ProductID = 1
GO


-- step 8 (Clean up)
-- Connection 1
UPDATE Production.Product
SET ReorderPoint = 750
WHERE ProductID = 1
GO

-- Revert database options to default
ALTER DATABASE AdventureWorks2008R2 SET READ_COMMITTED_SNAPSHOT OFF;
GO
