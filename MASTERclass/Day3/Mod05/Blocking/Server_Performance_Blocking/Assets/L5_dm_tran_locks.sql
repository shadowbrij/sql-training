----------------------------------------------------------
-- Demo: Identifying blocking using sys.dm_tran_locks
-- File: L5_dm_tran_locks.sql
-- Summary: After creating a locking scenario, various DMVs are run to retrieve locking information. Each DMV can be run with different various and/or could be joined with other DMVs to retrieve additional information.
----------------------------------------------------------

-- note: your session ids could be different

-- step 1
-- Connection 1
USE AdventureWorks2008R2
GO

BEGIN TRAN
  UPDATE Person.Person
  SET FirstName = 'Amit'
  WHERE BusinessEntityID = 1;
GO  

-- step 2
-- Connection 2

USE AdventureWorks2008R2
GO

SELECT * from Person.Person
WHERE BusinessEntityID=1;
GO


-- step 3
-- connection 3

-- all Lock info
SELECT
  request_session_id            AS spid,
  resource_type                 AS restype,
  resource_database_id          AS dbid,
  resource_description          AS res,
  resource_associated_entity_id AS resid,
  request_mode                  AS mode,
  request_status                AS status,
  *
FROM sys.dm_tran_locks dtl
INNER JOIN
sys.dm_exec_sessions dess
ON dtl.request_session_id = dess.session_id
WHERE dess.is_user_process = 1


-- step 4
-- connection 3
-- get Lock info for the table in question
SELECT
  request_session_id            AS spid,
  resource_type                 AS restype,
  OBJECT_NAME(resource_associated_entity_id) AS Object_Name,
  resource_database_id          AS dbid,
  resource_description          AS res,
  resource_associated_entity_id AS resid,
  request_mode                  AS mode,
  request_status                AS status,
  *
FROM sys.dm_tran_locks dtl
INNER JOIN
sys.dm_exec_sessions dess
ON dtl.request_session_id = dess.session_id
WHERE dess.is_user_process = 1
AND resource_associated_entity_id IN (select object_id from sys.objects)


-- step 5
-- connection 3
-- get Lock info for the statement in question
SELECT
  request_session_id            AS spid,
  resource_type                 AS restype,
  resource_database_id          AS dbid,
  resource_description          AS res,
  resource_associated_entity_id AS resid,
  request_mode                  AS mode,
  request_status                AS status,
  ST.text						AS SQLText,
  *
FROM sys.dm_tran_locks 
INNER JOIN
sys.dm_exec_connections
ON sys.dm_tran_locks.request_session_id = sys.dm_exec_connections.session_id
CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) AS ST
WHERE ST.text LIKE N'%(@1 tinyint)%'
OR
ST.text LIKE N'%Person.Person%'


-- step 6
-- Connection 1
ROLLBACK TRAN
GO