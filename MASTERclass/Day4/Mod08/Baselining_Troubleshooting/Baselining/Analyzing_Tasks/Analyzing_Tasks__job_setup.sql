USE [msdb]
GO

/****** Object:  Job [Analyzing_Tasks]    Script Date: 4/4/2013 5:38:54 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 4/4/2013 5:38:54 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Analyzing_Tasks', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'CONTOSO\Administrator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [collect]    Script Date: 4/4/2013 5:38:54 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'collect', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'	IF OBJECT_ID(''baseline..Analyzing_Tasks'') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[Analyzing_Tasks]
	(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[scheduler_id] [int] NOT NULL,
	[task_state] [nvarchar](100) NULL,
	[task_count] [bigint] NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N''sys.dm_os_wait_stats'', CLEAR); 

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
', 
		@database_name=N'baseline', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every_15_sec', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130330, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd0040d59-d2ef-45bd-9f1b-ec9c4bee8b85'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


