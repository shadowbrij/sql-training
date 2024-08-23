--Indexing Scenario 2

USE AdventureWorks
GO

--DROP TABLE person.contact2

select * from Person.Contact


-- make a copy
select * INTO person.contact2
from person.Contact


-- create a clustered index
CREATE CLUSTERED INDEX [cl_idx_contactID] ON [Person].[contact2] 
(
	[ContactID]
)

-- Design an index for this query

SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE c.FirstName LIKE 'L%'
        AND c.EmailPromotion = 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go

-- Current indexes
EXEC sp_helpindex [person.contact2]
go

-- 2 most popular choices
-- let us compare performance

SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c WITH (INDEX(ContactComposite4))
WHERE c.FirstName LIKE 'L%'
        AND c.EmailPromotion = 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go

SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE c.FirstName LIKE 'L%'
        AND c.EmailPromotion = 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go

-- observe the statistics and histogram

DBCC SHOW_STATISTICS ('Person.contact2',ContactCOmposite4)

DBCC SHOW_STATISTICS ('Person.contact2',ContactCOmposite5)


-- what if we follow the advice?

SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE c.FirstName = 'L'
        AND c.EmailPromotion = 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go

SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c WITH (INDEX(COntactComposite4))
WHERE c.FirstName = 'L'
        AND c.EmailPromotion = 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go


-- drop composite 4



--Indexing Scenario 3

-- a new requirement (original query tweaked)


SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE c.FirstName = 'L'
        AND c.EmailPromotion < 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go

-- selectivity is the key here

SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE c.FirstName = 'Lucas'
        AND c.EmailPromotion < 3
        --AND c.ContactID < 10000
OPTION (MAXDOP 1)
go

-- but what if you had the composite4


-- create the required index again... (composite4)

-- record the update performance
-- drop the objects and re-create them


-- Current indexes
EXEC sp_helpindex [person.contact2]
go


-- clean up act

DROP INDEX ContactComposite5 ON Person.Contact2
DROP INDEX C2FirstName ON Person.Contact2

