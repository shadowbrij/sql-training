SELECT c.ContactID, c.FirstName, c.EmailPromotion
FROM person.Contact2 AS c
WHERE c.FirstName LIKE 'L%'
        AND c.EmailPromotion = 1
        AND c.ContactID < 10000
OPTION (MAXDOP 1)
go
