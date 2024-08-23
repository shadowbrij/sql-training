-- Monitor Sessions
select * from sys.dm_exec_sessions
where is_user_process = 1
AND [program_name] = 'SQLCMD'

-- Monitor Requests
select * from sys.dm_exec_requests ER
inner join sys.dm_exec_sessions ES
ON ER.session_id = ES.session_id
WHERE ES.is_user_process = 1

-- Monitor Tasks
select * from sys.dm_os_tasks OT
inner join sys.dm_exec_sessions ES
ON OT.session_id = ES.session_id
WHERE ES.is_user_process = 1

-- Monitor Schedulers
select scheduler_id, current_tasks_count, runnable_tasks_count
from sys.dm_os_schedulers
where status = 'VISIBLE ONLINE'

-- Combine all
SELECT
	[OTAB].[scheduler_id],
	[task_state],
	COUNT (*) AS [task_count]
FROM
	sys.dm_os_tasks AS [OTAB]
INNER JOIN
	sys.dm_exec_requests AS [ERAB]
    ON [OTAB].[session_id] = [ERAB].[session_id]
INNER JOIN
	sys.dm_exec_sessions AS [ESAB]
    ON [ERAB].[session_id] = [ESAB].[session_id]
WHERE
	[ESAB].[is_user_process] = 1
GROUP BY
	[OTAB].[scheduler_id],
	[task_state]
ORDER BY
	[task_state],
	[OTAB].[scheduler_id];
GO

-- Stop Workload
USE [master];
GO

ALTER DATABASE [AdventureWorks2014] SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE [AdventureWorks2014] SET MULTI_USER
WITH ROLLBACK IMMEDIATE;
GO