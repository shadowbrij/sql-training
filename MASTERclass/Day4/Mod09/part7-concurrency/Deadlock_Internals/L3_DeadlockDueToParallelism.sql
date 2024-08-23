-- L3_DeadlockDueToParallelism.sql
-- Run atleast 3 instance of the below query
-- change cost threshold of parallelism to force below query to run in parallel.

USE AdventureWorks2008R2
GO

DECLARE @var int 
WHILE 1=1
BEGIN
SET @var = (RAND() * 10)
SELECT  ProductID FROM Sales.SalesOrderDetail WITH(UPDLOCK)
WHERE OrderQty  = @var 
END