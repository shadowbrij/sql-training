----------------------------------------------------------
-- Demo: Snapshot (1)
-- File: L4_Snapshot.sql
-- Summary: In this example, SNAPSHOT ISOLATION is enabled for AdvetureWorks2008R2 database. Connection 1 fires an update locking the row exclusively. Connection 2 can read the last committed value since it is running under Snapshot Isolation. This is optimistic concurrency – writers do not block readers. The last committed value is stored in the version store in tempdb database. Connection 2 continues to read the last committed value from the version store even after connection 1 commits. This behavior ensures that the read is repeatable for connection 2. After connection 2 transaction is committed or rolled back, it can read the new value committed by connection 1.
----------------------------------------------------------

USE master
GO

-- step 1
-- enable SNAPSHOT ISOLATION
ALTER DATABASE AdventureWorks2008R2 SET ALLOW_SNAPSHOT_ISOLATION ON;
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

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRAN
SELECT * FROM Production.Product
WHERE ProductID = 1;
GO


-- step 5
-- connection 1 - commit the transaction and verify that this transaction continues read the updated data
COMMIT TRAN

SELECT * FROM Production.Product
WHERE ProductID = 1
GO


-- step 6
-- Connection 2 - continues to read the last committed value from the version store even after connection 1 commits
-- This behavior ensures that the read is repeatable for connection 2

SELECT * FROM Production.Product
WHERE ProductID = 1
GO

-- step 7
-- Connection 2
-- After connection 2 transaction is committed or rolled back, it can read the new value committed by connection 1

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
-- close all connections except this one
USE master
GO

ALTER DATABASE AdventureWorks2008R2 SET ALLOW_SNAPSHOT_ISOLATION OFF;
