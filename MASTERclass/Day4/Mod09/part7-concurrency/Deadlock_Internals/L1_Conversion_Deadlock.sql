-- L1_Conversion_Deadlock.sql
-- Conversion deadlock
-- Run the below query in 2 different connections, quickly !
-- one of the connections will terminate with a deadlock error, ROLLBACK the other transaction
-- Summary: In the above example, the same transaction runs in two different sessions, 52 and 53 (your session ids may be different). At first, shared(key) lock is acquired by both sessions on Sales.SalesOrderDetail table and then try to update a single row with SalesOrderId=57024 and SalesOrderDetailID=60591. Thus, both the sessions try to exclusively lock the same row and one of the sessions fails with deadlock error. A key point to note above is that the deadlock involves only a single resource i.e. Sales.SalesOrderDetail table.


-- Run the entire workload below in 2 different connections, quickly !

Use AdventureWorks2008R2
GO

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRAN
SELECT OrderQty,LineTotal 
FROM Sales.SalesOrderDetail 
WHERE SalesOrderID=57024 
AND SalesOrderDetailID=60591 

WAITFOR DELAY '00:00:05'

UPDATE Sales.SalesOrderDetail 
SET OrderQty=10 
WHERE SalesOrderID=57024 
AND SalesOrderDetailID=60591 


-- execute the rollback statement for the connection that wasn't the rollback victim
--ROLLBACK TRAN

