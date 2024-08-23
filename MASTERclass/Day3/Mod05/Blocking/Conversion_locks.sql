-- conversion locks

USE AdventureWorks2008;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION; 

SELECT  BusinessEntityID
        ,FirstName
        ,MiddleName
        ,LastName
        ,Suffix
FROM   Person.Person;

SELECT   resource_type
        ,resource_subtype 
        ,resource_description
        ,resource_associated_entity_id
        ,request_mode
        ,request_status
FROM    sys.dm_tran_locks
WHERE   request_session_id = @@SPID;

UPDATE  Person.Person
SET     Suffix      = 'Junior'
WHERE   FirstName   = 'Syed'
AND     LastName    = 'Abbas';

SELECT   resource_type
        ,resource_subtype 
        ,resource_description
        ,resource_associated_entity_id
        ,request_mode
        ,request_status
FROM    sys.dm_tran_locks
WHERE   request_session_id = @@SPID;


-- ROLLBACK TRAN