-- Monitor Task Status
SELECT
	[OTAB].session_id,
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
	[OTAB].session_id,
	[OTAB].[scheduler_id],
	[task_state]
ORDER BY
	[OTAB].session_id
GO

-- Monitor Scheduler Pressure
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
	[OTAB].scheduler_id
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