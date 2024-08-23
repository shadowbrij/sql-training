-- logical reads (6 vs 3)

USE AdventureWorks
GO


-- 2 most popular choices
-- let us compare performance

SET STATISTICS IO ON

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

-- here is my explanation...
-- what does the nonclustered index look like..?? how is the data arranged on pages..

-- in contactComposite4...

SELECT c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE FirstName LIKE 'L%'
ORDER BY FirstName, EmailPromotion


SELECT c.EmailPromotion, c.FirstName
FROM person.Contact2 AS c
WHERE FirstName LIKE 'L%'
ORDER BY EmailPromotion,FirstName

-- let us refer the diagram on the deck..


---- get the data into a new table:
-- simulate an index

--DROP TABLE table1
--DROP TABLE table2


SELECT c.FirstName, c.EmailPromotion, ContactID
INTO table1
FROM person.Contact2 AS c
WHERE FirstName LIKE 'L%'
ORDER BY FirstName, EmailPromotion


SELECT c.EmailPromotion, c.FirstName, ContactID
INTO table2
FROM person.Contact2 AS c
WHERE FirstName LIKE 'L%'
ORDER BY EmailPromotion,FirstName


-- now see how the data in the index looks like
-- SET STATISTICS IO ON

select * from table1

select * from table2

-- why 5 pages???
-- I forgot there is a root page :)


-- let us check the physical stats of the both the tables

SELECT OBJECT_NAME(object_id),* 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('dbo.table2')
	, NULL
	, NULL
	, 'SAMPLED');
go

SELECT OBJECT_NAME(object_id),* 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('dbo.table1')
	, NULL
	, NULL
	, 'SAMPLED');
go

-- in order to simulate the NC, we will create an index..

CREATE CLUSTERED INDEX idx_table1 on table1 (firstname, emailpromotion, contactID)
CREATE CLUSTERED INDEX idx_table2 on table2 (emailpromotion, firstname, COntactID)


--
-- Review your index list
EXEC sp_helpindex [dbo.table1]
EXEC sp_helpindex [dbo.table2]

go

select * from table1
WHERE 
--EmailPromotion = 1
--AND
FirstName LIKE 'L%'

select * from table2
WHERE 
EmailPromotion = 1
--AND
--FirstName LIKE 'L%'


--test the original query with table 1 & table 2

SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM table1 AS c
WHERE c.FirstName LIKE 'L%'
        AND c.EmailPromotion = 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go


SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM table2 AS c
WHERE c.FirstName LIKE 'L%'
        AND c.EmailPromotion = 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go

