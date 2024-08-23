----------------------------------------------------------
-- Demo: Read Uncommitted (1)
-- File: L4_Read_Uncommitted_1.sql
-- Summary: In this simple example of READ UNCOMMITTED, connection 2 can read dirty (uncommitted) data since its running under Read Uncommitted Isolation Level
----------------------------------------------------------

USE AdventureWorks2008R2
GO

-- step 1
-- Connection 1
-- update a record inside a transaction and leave the transaction open
USE AdventureWorks2008R2
GO

BEGIN TRAN
  UPDATE Person.Person
  SET FirstName = 'Amit'
  WHERE BusinessEntityID = 1;
GO  

-- step 2
-- connection 1
-- verify that the updated value is being shown
SELECT * from Person.Person
WHERE BusinessEntityID=1;
GO

-- step 3
-- Connection 2
-- simulating another user, the uncommitted value can be read under READ UNCOMMITTED isolation level
USE AdventureWorks2008R2
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT * from Person.Person
WHERE BusinessEntityID=1;
GO

-- step4
-- Connection 1
ROLLBACK TRAN
GO
