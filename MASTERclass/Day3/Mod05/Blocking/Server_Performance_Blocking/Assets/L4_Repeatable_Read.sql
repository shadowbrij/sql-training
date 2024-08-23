----------------------------------------------------------
-- Demo: REPEATABLE READ
-- FILE: L4_Repeatable_Read.sql
-- Summary: In this example, connection 2 cannot update the record unless connection 1 rolls back or commits the transaction, since connection 1 is running under REPEATABLE READ isolation level which holds the lock for the entire duration of the transaction, providing higher isolation but lower concurrency.
----------------------------------------------------------

-- step 1
-- connection 1
-- a SELECT statment is being fired under ISOLATION LEVEL REPEATABLE READ to make sure that the shared lock is held for the entire duration of the transaction

USE AdventureWorks2008R2
GO

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
GO

BEGIN TRAN
	SELECT * FROM Person.Person
	WHERE BusinessEntityID = 1
GO


-- step 2
-- connection 2
-- simulatiing another user, this connection tries to update the same record and is forced to wait

USE AdventureWorks2008R2
GO

UPDATE Person.Person
SET FirstName = 'AMIT'
WHERE BusinessEntityID = 1


-- step 3
-- Connection 1
-- this step verifies that the value has not changed and commits the transaction allowing the other user to execute its update statement.
	SELECT * FROM Person.Person
	WHERE BusinessEntityID = 1
	
COMMIT TRAN
GO


-- step 4
-- connection 2
-- reset the original value

USE AdventureWorks2008R2
GO


UPDATE Person.Person
SET FirstName = 'Ken'
WHERE BusinessEntityID = 1