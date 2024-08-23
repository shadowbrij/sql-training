USE AdventureWorks2008R2
GO

--Query 1

SELECT BusinessEntityID ,
	PersonType ,
	FirstName ,
	MiddleName ,
	LastName ,
	EmailPromotion
FROM Person.Person AS p
WHERE FirstName = 'Carol'
	AND PersonType = 'SC'


-- Query 2
SELECT BusinessEntityID ,
	FirstName ,
	LastName
FROM Person.Person AS p
WHERE PersonType = 'GC'
	AND Title = 'Ms.'

-- Query 3

SELECT BusinessEntityID ,
	PersonType ,
	EmailPromotion
FROM Person.Person AS p
WHERE Title = 'Mr.'
	AND FirstName = 'Paul'
	AND LastName = 'Shakespear'


-- create the index

CREATE INDEX idx_Person_FirstNameLastNameTitleType
ON Person.Person (FirstName, LastName, Title, PersonType)