-- repeatable read & request status convert

USE ADVENTUREWORKS2008;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION;
SELECT	FirstName
        ,MiddleName
        ,LastName
        ,Suffix
FROM	Person.Person
WHERE	BusinessEntityID = 1;
--ROLLBACK TRANSACTION; 
GO
-- Cut and paste this second section into another browser session and run it from there.

/* Run in Session 2
*/
USE ADVENTUREWORKS2008;

SELECT  request_session_id              as [Session]
        ,DB_NAME(resource_database_id)  as [Database]
        ,Resource_Type                  as [Type]
        ,resource_subtype               as SubType
        ,resource_description           as [Description]
        ,request_mode                   as Mode
        ,request_owner_type             as OwnerType
        ,request_status
FROM    sys.dm_tran_locks
WHERE   request_session_id > 50
AND     resource_database_id = DB_ID('AdventureWorks2008')
AND     request_session_id <> @@SPID; 
GO
-- Cut and paste this third section into another browser session and run it from there.

/*SESSION 3
*/

USE AdventureWorks2008;

BEGIN TRANSACTION;

DECLARE @LastName table
        (   OldLastName nvarchar(50)
        ,   NewLastName nvarchar(50)
        );
        
UPDATE  Person.Person
SET     LastName = 'Rowland-Jones'
OUTPUT  DELETED.LastName 
       ,INSERTED.LastName
INTO    @LastName
WHERE   BusinessEntityID = 1;

SELECT  *
FROM    @LastName;

--ROLLBACK TRANSACTION
