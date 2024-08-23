	IF OBJECT_ID('baseline..Analyzing_Tasks') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[Analyzing_Tasks]
	(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[scheduler_id] [int] NOT NULL,
	[task_state] [nvarchar](100) NULL,
	[task_count] [bigint] NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR); 

	INSERT Analyzing_Tasks WITH (TABLOCK)
	SELECT 1,GETDATE(),
	[ot].[scheduler_id],
	[task_state],
	COUNT (*) AS [task_count]
FROM
	sys.dm_os_tasks AS [ot]
INNER JOIN
	sys.dm_exec_requests AS [er]
    ON [ot].[session_id] = [er].[session_id]
INNER JOIN
	sys.dm_exec_sessions AS [es]
    ON [er].[session_id] = [es].[session_id]
WHERE
	[es].[is_user_process] = 1
GROUP BY
	[ot].[scheduler_id],
	[task_state]
ORDER BY
	[task_state],
	[ot].[scheduler_id]
END
ELSE
BEGIN
	INSERT Analyzing_Tasks WITH (TABLOCK)
	SELECT (select max(Analyzing_Tasks.collection_id)+1 from Analyzing_Tasks),GETDATE(),
		[ot].[scheduler_id],
		[task_state],
		COUNT (*) AS [task_count]
	FROM
		sys.dm_os_tasks AS [ot]
	INNER JOIN
		sys.dm_exec_requests AS [er]
		ON [ot].[session_id] = [er].[session_id]
	INNER JOIN
		sys.dm_exec_sessions AS [es]
		ON [er].[session_id] = [es].[session_id]
	WHERE
		[es].[is_user_process] = 1
	GROUP BY
		[ot].[scheduler_id],
		[task_state]
	ORDER BY
		[task_state],
		[ot].[scheduler_id]
END
