select * from sys.dm_exec_requests
where session_id > 50
order by session_id

select session_id, cpu_time, command from sys.dm_exec_requests
where session_id > 50
order by session_id
GO

sp_who2 60
GO

select * from sys.sysprocesses

-- see the thread id

SELECT * FROM sys.dm_os_threads DMOthreads
INNER JOIN sys.dm_os_workers DMOworkers
ON DMOthreads.worker_address = DMOworkers.worker_address
INNER JOIN sys.dm_os_tasks DMOtasks
ON DMOworkers.task_address = DMOtasks.task_address
WHERE DMOtasks.session_id
-- IN (53,54,55)
= 60


select ST.text from
sys.dm_exec_requests ER
cross apply
sys.dm_exec_sql_text(ER.sql_handle) ST
where ER.session_id = 60

