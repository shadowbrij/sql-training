-- query window 1/connection 1
USE AdventureWorks
GO

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRAN

SELECT * from Person.Contact
WHERE ContactID = 1



-- query window 3

select resource_type,
request_session_id,
resource_database_id,
resource_description,
resource_associated_entity_id,
request_mode,
request_type,
request_status
from sys.dm_tran_locks
where request_session_id>50


-- query window 2/connection 2

USE AdventureWorks
GO

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRAN

SELECT * from Person.Contact
WHERE ContactID = 1


--ROLLBACK TRAN

-- query window 3

select resource_type,
resource_database_id,
resource_description,
resource_associated_entity_id,
request_mode,
request_type,
request_status
from sys.dm_tran_locks


-- query window 1/connection 1


UPDATE Person.Contact
SET LastName = 'BANSAL'
WHERE ContactID = 1

--ROLLBACK TRAN

-- query window 3

select resource_type,
resource_database_id,
resource_description,
resource_associated_entity_id,
request_mode,
request_type,
request_status
from sys.dm_tran_locks
