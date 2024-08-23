----------------------------------------------------------
-- Demo: SNAPSHOT (2)
-- File: L4_Snapshot_2.sql
-- Summary: Snapshot Isolation level has the ability to detect conflicts. In this example, connection 1 begins a transaction and reads the data. Before it attempts to modify the data, connection 2 fires an update on the same data that connection 1 had read previously. Remember, this is optimistic concurrency. Before connection 2 commits, connection 1 attempts to update the same data raising a conflict error. 
----------------------------------------------------------

USE master
GO

-- step 1
-- enable SNAPSHOT_ISOLATION
ALTER DATABASE AdventureWorks2008R2 SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

USE AdventureWorks2008R2
GO

-- step 2
-- connection 1
-- starts a transaction and reads the data
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRAN

SELECT * FROM Production.Product
WHERE ProductID = 1

GO

-- step 3
-- Connection 2 - fires an update on the same data that connection 1 had read previously
USE AdventureWorks2008R2;
GO

UPDATE Production.Product
SET ReorderPoint = 1000
WHERE ProductID = 1
GO


-- step 4
-- connection 1
-- connection 1 attempts to update the same data raising a conflict error

UPDATE Production.Product
SET ReorderPoint = 2000
WHERE ProductID = 1

GO


-- step 5
-- Connection 1

ROLLBACK TRAN



-- step 6 (Clean up)
-- Connection 2
UPDATE Production.Product
SET ReorderPoint = 750
WHERE ProductID = 1
GO

-- Revert database options to default
-- close all connections except this one
USE master
GO

ALTER DATABASE AdventureWorks2008R2 SET ALLOW_SNAPSHOT_ISOLATION OFF;

