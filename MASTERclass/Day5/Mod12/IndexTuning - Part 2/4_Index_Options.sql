USE AdventureWorks
GO
---------------------
--- Indexing Options
---------------------
-- Option 1
CREATE INDEX ContactInclude1 
ON Person.Contact2(FirstName)
INCLUDE (EmailPromotion, ContactID)
-- Option 2
CREATE INDEX ContactInclude2 
ON Person.Contact2(FirstName)
INCLUDE (EmailPromotion)
-- Option 3
CREATE INDEX ContactInclude3 
ON Person.Contact2(EmailPromotion)
INCLUDE (FirstName)
-- Option 4
CREATE INDEX ContactInclude4 
ON Person.Contact2(EmailPromotion)
INCLUDE (FirstName, ContactID)
-- Option 5
CREATE INDEX ContactInclude5 
ON Person.Contact2(ContactID)
INCLUDE (FirstName, EmailPromotion)
-- Option 6
CREATE INDEX ContactInclude6 
ON Person.Contact2(ContactID)
INCLUDE (EmailPromotion, FirstName)
-- Option 7
CREATE INDEX ContactInclude7 
ON Person.Contact2(FirstName, EmailPromotion)
INCLUDE (ContactID)
-- Option 8
CREATE INDEX ContactInclude8 
ON Person.Contact2(EmailPromotion, FirstName)
INCLUDE (ContactID)
-- Option 9
CREATE INDEX ContactComposite1
ON Person.Contact2(firstname, EmailPromotion, contactID)
-- Option 10
CREATE INDEX ContactComposite2 
ON Person.Contact2(EmailPromotion, firstname, contactID)
-- Option 11
CREATE INDEX ContactComposite3
ON Person.Contact2(contactID, EmailPromotion, firstname)
-- Option 12
CREATE INDEX ContactComposite4
ON Person.Contact2(firstname, EmailPromotion)
-- Option 13
CREATE INDEX ContactComposite5 
ON Person.Contact2(EmailPromotion, firstname)

--- drop
--DROP INDEX ContactComposite5 ON Person.Contact2
--DROP INDEX ContactComposite4 ON Person.Contact2
