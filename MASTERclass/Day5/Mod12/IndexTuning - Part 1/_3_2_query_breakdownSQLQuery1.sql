-- breakdown the queries

USE AdventureWorks
GO

--------------------------------------------------------------
SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE c.FirstName LIKE 'L%'				
        --AND c.c.EmailPromotion = 1
        --AND c.ContactID < 10000
OPTION (MAXDOP 1)
go


SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE
--WHERE c.FirstName LIKE 'L%'	
        c.EmailPromotion = 1
        --AND c.ContactID < 10000
OPTION (MAXDOP 1)
go


SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE
--WHERE c.FirstName LIKE 'L%'		
        --AND c.c.EmailPromotion = 1	
        c.ContactID < 10000	
OPTION (MAXDOP 1)
go
