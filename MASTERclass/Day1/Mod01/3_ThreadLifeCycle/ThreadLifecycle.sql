-- Monitor Session status
DECLARE @@SPID_UPD_Q int = 56  -- replace 0 with the session id of the UPDATE
DECLARE @@SPID_SEL_Q int = 60  -- replace 0 with the session id of the SELECT query
SELECT session_id, [status] FROM sys.dm_exec_sessions
WHERE session_id = @@SPID_UPD_Q
SELECT session_id, [status] FROM sys.dm_exec_sessions
WHERE session_id = @@SPID_SEL_Q
GO

-- Monitor Request status
DECLARE @@SPID_UPD_Q int = 56  -- replace 0 with the session id of the UPDATE
DECLARE @@SPID_SEL_Q int = 60  -- replace 0 with the session id of the SELECT query
SELECT session_id, [status] FROM sys.dm_exec_requests
WHERE session_id = @@SPID_UPD_Q
SELECT session_id, [status] FROM sys.dm_exec_requests
WHERE session_id = @@SPID_SEL_Q

-- Monitor Task status
DECLARE @@SPID_UPD_Q int = 56  -- replace 0 with the session id of the UPDATE
DECLARE @@SPID_SEL_Q int = 60  -- replace 0 with the session id of the SELECT query
SELECT session_id, task_state FROM sys.dm_os_tasks
WHERE session_id = @@SPID_UPD_Q
SELECT session_id,task_state FROM sys.dm_os_tasks
WHERE session_id = @@SPID_SEL_Q

-- Monitor workers
DECLARE @@SPID_UPD_Q int = 56  -- replace 0 with the session id of the UPDATE
DECLARE @@SPID_SEL_Q int = 60  -- replace 0 with the session id of the SELECT query
SELECT [state] FROM sys.dm_os_workers DMOworkers
INNER JOIN sys.dm_os_tasks DMOtasks
ON DMOworkers.task_address = DMOtasks.task_address
WHERE DMOtasks.session_id = @@SPID_UPD_Q

SELECT [state] FROM sys.dm_os_workers DMOworkers
INNER JOIN sys.dm_os_tasks DMOtasks
ON DMOworkers.task_address = DMOtasks.task_address
WHERE session_id = @@SPID_SEL_Q

-- SUSPENDED/RUNNABLE duration
-- How long a user worker has been in SUSPENDED OR RUNNABLE state?
SELECT 
    t1.session_id,
    CONVERT(varchar(10), t1.status) AS status,
    CONVERT(varchar(15), t1.command) AS command,
    CONVERT(varchar(10), t2.state) AS worker_state,
    w_suspended = 
      CASE t2.wait_started_ms_ticks
        WHEN 0 THEN 0
        ELSE 
          t3.ms_ticks - t2.wait_started_ms_ticks
      END,
    w_runnable = 
      CASE t2.wait_resumed_ms_ticks
        WHEN 0 THEN 0
        ELSE 
          t3.ms_ticks - t2.wait_resumed_ms_ticks
      END
  FROM sys.dm_exec_requests AS t1
  INNER JOIN sys.dm_os_workers AS t2
    ON t2.task_address = t1.task_address
  INNER JOIN sys.dm_exec_sessions AS t4
	ON t1.session_id = t4.session_id
  CROSS JOIN sys.dm_os_sys_info AS t3
  WHERE t1.scheduler_id IS NOT NULL
  AND t4.is_user_process=1


-- Monitor threads
DECLARE @@SPID_UPD_Q int = 56  -- replace 0 with the session id of the UPDATE
DECLARE @@SPID_SEL_Q int = 60  -- replace 0 with the session id of the SELECT query
SELECT state, * FROM sys.dm_os_threads DMOthreads
INNER JOIN sys.dm_os_workers DMOworkers
ON DMOthreads.worker_address = DMOworkers.worker_address
INNER JOIN sys.dm_os_tasks DMOtasks
ON DMOworkers.task_address = DMOtasks.task_address
WHERE DMOtasks.session_id = @@SPID_UPD_Q

SELECT state, * FROM sys.dm_os_threads DMOthreads
INNER JOIN sys.dm_os_workers DMOworkers
ON DMOthreads.worker_address = DMOworkers.worker_address
INNER JOIN sys.dm_os_tasks DMOtasks
ON DMOworkers.task_address = DMOtasks.task_address
WHERE DMOtasks.session_id = @@SPID_SEL_Q