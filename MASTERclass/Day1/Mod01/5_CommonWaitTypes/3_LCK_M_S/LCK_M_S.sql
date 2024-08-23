-- Begin Transaction
USE AdventureWorks2014
GO
BEGIN TRAN
UPDATE Person.Person
SET LastName = 'Bansal'
WHERE BusinessEntityID = 1
GO

-- Monitor LCK_M_S
SELECT *
FROM sys.dm_os_waiting_tasks
WHERE
	wait_type LIKE '%LCK_M_S%'
GO

-- ROLLBACK Transaction
ROLLBACK TRAN

-- Monitor LCK_M_S
SELECT *
FROM sys.dm_os_waiting_tasks
WHERE
	wait_type LIKE '%LCK_M_S%'
GO
