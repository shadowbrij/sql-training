-- UPDATE Query
SELECT @@spid as sessionid
GO -- Note the spid, we will use it later
USE AdventureWorks2014
GO
BEGIN TRAN
UPDATE Person.Person
SET FirstName = 'Ken'
WHERE BusinessEntityID = 1

-- ROLLBACK
ROLLBACK TRAN
