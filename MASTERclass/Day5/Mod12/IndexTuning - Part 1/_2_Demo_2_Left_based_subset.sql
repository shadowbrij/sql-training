use AdventureWorks2012
GO

-- make a copy of person table
select * into Person.PersonCopy
from Person.Person

-- select * from person.personcopy

-- check for indexes and statistics
sp_helpindex 'Person.PersonCopy';
GO
sp_helpstats 'Person.PersonCopy';
GO


-- query 1
SELECT FirstName, MiddleName, LastName, EmailPromotion
FROM Person.PersonCopy WHERE FirstName = 'Lucas' AND LastName = 'Anderson'

-- query 2
SELECT BusinessEntityID, FirstName, LastName FROM Person.PersonCopy
WHERE EmailPromotion = 1 AND PersonType = 'GC'

-- query 3

SELECT FirstName, MiddleName, LastName, EmailPromotion, PersonType FROM Person.PersonCopy
WHERE PersonType = 'IN' AND FirstName = 'Lucas' AND LastName = 'Anderson'


-- what could you do?

CREATE INDEX idx_index1
ON Person.PersonCOPY (FirstName, LastName, PersonType, EmailPromotion)

-- what could you do?

CREATE INDEX idx_index2
ON Person.PersonCOPY ( EmailPromotion, FirstName, LastName, PersonType)

-- DROP INDEX idx_index2 on Person.PersonCOPY
-- DROP INDEX idx_index1 on Person.PersonCOPY


-- what you should do !

CREATE INDEX idx_index1
ON Person.PersonCOPY (FirstName, LastName, PersonType)

-- what you should do !

CREATE INDEX idx_index2
ON Person.PersonCOPY ( EmailPromotion, PersonType)

-- DROP INDEX idx_index2 on Person.PersonCOPY
-- DROP INDEX idx_index1 on Person.PersonCOPY