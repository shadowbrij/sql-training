-- sample database (download from codeplex.com)
USE AdventureWorks
GO

--DROP TABLE person.contact2
--DROP TABLE person.contact3

select * from Person.Contact


-- make a copy
select * INTO person.contact2
from person.Contact

-- make another copy
select * INTO person.contact3
from person.Contact


-- create a clustered index
CREATE CLUSTERED INDEX [cl_idx_contactID] ON [Person].[contact2] 
(
	[ContactID]
)

-- create a clustered index
CREATE CLUSTERED INDEX [cl_idx_contactID] ON [Person].[contact3] 
(
	[ContactID]
)

-- Design an index for this query

SELECT c2.FirstName
FROM person.Contact2 AS c2
INNER JOIN
person.contact3 c3
ON C2.FirstName = c3.FirstName

-- vs

SELECT c2.FirstName
FROM person.Contact2 AS c2
INNER JOIN
person.contact3 c3
ON C2.FirstName = c3.FirstName
ORDER BY C3.FirstName

-- vs

SELECT c2.FirstName
FROM person.Contact2 AS c2
INNER JOIN
person.contact3 c3
ON C2.FirstName = c3.FirstName
ORDER BY C3.FirstName
OPTION (HASH JOIN)



-- before creating indexes, record the update performance
-- after update performance is recorded, re-create the table

-- NCI on Contact2
CREATE INDEX C2FirstName
ON Person.Contact2(firstname)
-- NCI on Contact3
CREATE INDEX C3FirstName 
ON Person.Contact3(firstname)

-- compare the performance

SELECT c2.FirstName
FROM person.Contact2 AS c2
INNER JOIN
person.contact3 c3
ON C2.FirstName = c3.FirstName
ORDER BY C3.FirstName

-- vs

SELECT c2.FirstName
FROM person.Contact2 AS c2 WITH (INDEX(0))
INNER JOIN
person.contact3 c3 WITH (INDEX(0))
ON C2.FirstName = c3.FirstName
ORDER BY C2.FirstName




-- clean up
--DROP INDEX C2FirstName ON Person.Contact2
--DROP INDEX C3FirstName ON Person.Contact3
