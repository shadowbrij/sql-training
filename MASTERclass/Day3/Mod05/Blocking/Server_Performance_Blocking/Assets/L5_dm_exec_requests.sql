----------------------------------------------------------
-- Demo: Identifying blocking using sys.dm_exec_requests
-- File: L5_dm_exec_requests.sql
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

SELECT session_id,
DB_NAME(database_id),
blocking_session_id,
wait_type,
wait_resource,
transaction_id,
* FROM SYS.dm_exec_requests
WHERE blocking_session_id > 0


-- step 4
-- request info
SELECT * FROM sys.dm_exec_requests
WHERE session_id IN(63, 66);

-- step 5
-- tasks info (SQLOS level)
SELECT * FROM sys.dm_os_tasks
WHERE session_id IN(63, 66);

-- step 5
-- Connection info
SELECT * FROM sys.dm_exec_connections
WHERE session_id IN(63, 66);

-- step 6
-- Session info (1 connection can have multiple sessions)
SELECT * FROM sys.dm_exec_sessions
WHERE session_id IN(63, 66);

-- step 7
-- SQL text
SELECT session_id, text 
FROM sys.dm_exec_connections
  CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) AS ST 
WHERE session_id IN(63, 66);
GO

-- step 8 (combine it all)

SELECT er.session_id ,
host_name , program_name , original_login_name , er.reads ,
er.writes ,er.cpu_time , wait_type , wait_time , wait_resource ,
blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE blocking_session_id > 0
UNION
SELECT es.session_id , host_name , program_name , original_login_name ,
es.reads , es.writes , es.cpu_time , wait_type , wait_time ,
wait_resource , blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE es.session_id IN ( SELECT blocking_session_id
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0 )

-- step 9
-- Connection 1
ROLLBACK TRAN
GO
