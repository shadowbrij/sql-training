-- READ UNCOMITTED honors locks

-- connection 1

USE ADVENTUREWORKS2008;

BEGIN TRANSACTION;
	ALTER TABLE Person.Person
	ADD Address2 nvarchar(100);
--ROLLBACK TRANSACTION;
GO

-- connection 2


USE ADVENTUREWORKS2008;

--DBCC TRACEON (-1,3604)-- OUTPUT TO THE CLIENT
--DBCC TRACEON(-1,1200) -- SHOWS ALL LOCK INFO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT *
FROM	Person.Person
WHERE	LastName = 'BANSAL';

--DBCC TRACEOFF (-1,3604)-- OUTPUT TO THE CLIENT
--DBCC TRACEOFF(-1,1200) -- SHOWS ALL LOCK INFO
GO


-- connection 3

USE [AdventureWorksDW2008];

SELECT   request_session_id
        ,resource_type
        ,resource_subtype 
        ,resource_description
        ,resource_associated_entity_id
        ,request_mode
        ,request_status
FROM    sys.dm_tran_locks
WHERE   request_session_id IN (54,55) 
--Substitute your own SPID's here for sessions 1&2
ORDER BY request_session_id;
