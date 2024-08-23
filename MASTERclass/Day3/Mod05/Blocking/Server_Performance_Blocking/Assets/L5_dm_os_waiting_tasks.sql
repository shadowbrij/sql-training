----------------------------------------------------------
-- Demo: Identifying blocking using sys.dm_os_waiting_tasks
-- File: L5_dm_os_waiting_tasks.sql
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
	session_id,
	wait_type,
	resource_address,
	blocking_session_id,
	resource_description,
	*
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id is NOT NULL


-- step 4
-- SQL text
SELECT session_id, text
FROM sys.dm_exec_connections EC
  CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) AS ST
WHERE session_id IN(53, 56);
GO

-- step 5
-- more detailing

SELECT blocking.session_id AS blocking_session_id ,
	blocked.session_id AS blocked_session_id ,
	waitstats.wait_type AS blocking_resource ,
	waitstats.wait_duration_ms ,
	waitstats.resource_description ,
	blocked_cache.text AS blocked_text ,
	blocking_cache.text AS blocking_text
FROM sys.dm_exec_connections AS blocking
	INNER JOIN sys.dm_exec_requests blocked
	ON blocking.session_id = blocked.blocking_session_id
	CROSS APPLY sys.dm_exec_sql_text(blocked.sql_handle)
	blocked_cache
	CROSS APPLY sys.dm_exec_sql_text(blocking.most_recent_sql_handle)
	blocking_cache
	INNER JOIN sys.dm_os_waiting_tasks waitstats
	ON waitstats.session_id = blocked.session_id


-- step 6
-- Connection 1
ROLLBACK TRAN
GO