----------------------------------------------------------
-- Demo: Read Uncommitted (2)
-- File: L4_Read_Uncommitted_2.sql
-- Summary: Under some cases, READ UNCOMMITTED does honor locks. In this example; connection 1 is performing a DDL operation on Person table and connection 2 is attempting to read data from the same table. Despite running under READ UNCOMMITTED isolation level, connection 2 is forced to wait. Observing the output of sys.dm_tran_locks, connection 2 (spid 56) wants to acquire Schema-Stability (Sch-S) lock before reading the data, but it being forced to wait because connection 1 (spid 57) holds the Schema-Modification lock (Sch-M). Please note that your SPIDs could be different.
----------------------------------------------------------

-- step 1
-- connection 1
-- ALTER TABLE statement is executed
USE ADVENTUREWORKS2008;
GO

BEGIN TRANSACTION;
	ALTER TABLE Person.Person
	ADD Address2 nvarchar(100);
--ROLLBACK TRANSACTION;
GO

-- step 2
-- connection 2
-- simulating anothe user, this connection tries to read from the table under READ UNCOMMITTED ISOLATION LEVEL
USE ADVENTUREWORKS2008;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT *
FROM	Person.Person
WHERE	LastName = 'BANSAL';
GO

-- step 3
-- connection 3
-- verify the locks
SELECT   request_session_id
        ,resource_type
        ,resource_subtype 
        ,resource_description
        ,resource_associated_entity_id
        ,request_mode
        ,request_status
FROM    sys.dm_tran_locks
GO

-- step 4
-- Connection 1
ROLLBACK TRAN
GO
