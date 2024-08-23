----------------------------------------------------------
-- Demo: Key Locks
-- File: L1_KEY_locks.sql
-- Summary: This simple demo demonstrates key locks in SQL Server. In step 1, product number AR-5381 from Production.Product table is being updated within a transaction. A single row is being updated. Thus, SQL Server acquires a key lock (resource_type) on the row in question. The lock is being held for the entire duration of the transaction since it’s an exclusive lock (X). In step 2, you can observe the lock using sys.dm_tran_locks DMVs. Step 3 rolls back the transaction. In step 4, %%lockres%% function is being used to identify the row. 
----------------------------------------------------------

USE AdventureWorks2012
GO

-- step 1
-- product number AR-5381 from Production.Product table is being updated within a transaction. A single row is being updated. Thus, SQL Server acquires a key lock (resource_type) on the row in question. The lock is being held for the entire duration of the transaction since it’s an exclusive lock (X)

BEGIN TRAN
UPDATE Production.Product
SET SafetyStockLevel = 1500
WHERE ProductNumber = 'AR-5381'
GO

-- step 2
-- observe the lock using sys.dm_tran_locks DMVs

SELECT resource_type, resource_description, request_mode, request_status, *
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
GO

-- step 3
ROLLBACK TRAN
GO

-- step 4
-- %%lockres%% function is being used to identify the row
SELECT * FROM production.product
WHERE %%lockres%% = '(8194443284a0)'                                                                                   
GO