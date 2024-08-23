----------------------------------------------------------
-- Demo: Key-Range Locks
-- File: L1_KEY_Range_Locks.sql
-- Summary: This code demonstrates key-range locks in SQL Server. In step 1, under SERIALIZABLE isolation level, products from Production.Product table are being updated where the reorder point is 600. Since, the transaction is running under SERIALIZABLE isolation level, SQL Server acquires key-range locks (resource_mode) on all the 25 rows that qualify the criteria. The lock is being held for the entire duration of the transaction and will avoid phantoms (another transaction cannot insert or update a record in this table with reorder point value of 600).
-- In Step 2, the locks can be monitored.
-- Another interesting observation is: if you run the code in step 3, sys.dm_tran_locks SELECT statement where request_mode is filtered on RangeS-U lock, you will observe that remaining rows in the table are locked with RangeS-U lock mode. This will be discussed in the Isolation Level section.
-- In step 4, the transaction is rolled back to undo the changes
----------------------------------------------------------

USE AdventureWorks2008R2
GO

-- step 1
-- nder SERIALIZABLE isolation level, products from Production.Product table are being updated where the reorder point is 600. Since, the transaction is running under SERIALIZABLE isolation level, SQL Server acquires key-range locks (resource_mode) on all the 25 rows that qualify the criteria. The lock is being held for the entire duration of the transaction and will avoid phantoms (another transaction cannot insert or update a record in this table with reorder point value of 600)

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
GO

BEGIN TRAN
UPDATE Production.Product
SET ReorderPoint = 1000
WHERE ReorderPoint = 600
GO

-- step 2
-- the locks can be monitored (RangeX-X)

SELECT resource_type, resource_description, request_mode, request_status, *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
AND request_mode = 'RangeX-X'
GO

-- step 3
-- request_mode is filtered on RangeS-U lock, you will observe that remaining rows in the table are locked with RangeS-U lock mode. This will be discussed in the Isolation Level section

SELECT resource_type, resource_description, request_mode, request_status, *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
AND request_mode = 'RangeS-U'
GO

-- step 4
ROLLBACK TRAN
GO