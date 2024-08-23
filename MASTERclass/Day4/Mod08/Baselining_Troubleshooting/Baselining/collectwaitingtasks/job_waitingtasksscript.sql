USE [msdb]
GO

/****** Object:  Job [waitingtasks]    Script Date: 4/1/2013 9:40:24 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 4/1/2013 9:40:24 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'waitingtasks', 
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
/****** Object:  Step [collection_script]    Script Date: 4/1/2013 9:40:24 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'collection_script', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'	IF OBJECT_ID(''baseline..waitingtasks'') IS NULL
BEGIN
	
CREATE TABLE [dbo].[waitingtasks]
(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[session_id] [int] NULL,
	[exec_context_id] [int] NULL,
	[wait_duration_ms] [bigint] NULL,
	[wait_type] [nvarchar](100) NULL,
	[blocking_session_id] [smallint] NULL,
	[resource_description] [nvarchar](3072) NULL,
	[program_name] [nvarchar](128) NULL,
	[text] [nvarchar](max) NULL,
	[dbid] [smallint] NULL,
	[query_plan] [xml] NULL,
	[cpu_time] [bigint] NOT NULL,
	[memory_usage] [bigint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	
	--DBCC SQLPERF (N''sys.dm_os_wait_stats'', CLEAR); 

	INSERT waitingtasks WITH (TABLOCK)
	SELECT 1,GETDATE(),
	[owt].[session_id],
	[owt].[exec_context_id],
	[owt].[wait_duration_ms],
	[owt].[wait_type],
	[owt].[blocking_session_id],
	[owt].[resource_description],
	[es].[program_name],
	[est].[text],
	[est].[dbid],
	[eqp].[query_plan],
	[es].[cpu_time],
	[es].[memory_usage]
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_exec_sessions [es] ON
	[owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON
	[es].[session_id] = [er].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE [es].[is_user_process] = 1
ORDER BY [owt].[session_id], [owt].[exec_context_id]
END
ELSE
BEGIN
	
	if (SELECT max(waitingtasks.collection_id)+1 from waitingtasks) IS NULL

	BEGIN

				INSERT waitingtasks WITH (TABLOCK)
				SELECT 1,GETDATE(),
				[owt].[session_id],
				[owt].[exec_context_id],
				[owt].[wait_duration_ms],
				[owt].[wait_type],
				[owt].[blocking_session_id],
				[owt].[resource_description],
				[es].[program_name],
				[est].[text],
				[est].[dbid],
				[eqp].[query_plan],
				[es].[cpu_time],
				[es].[memory_usage]
			FROM sys.dm_os_waiting_tasks [owt]
			INNER JOIN sys.dm_exec_sessions [es] ON
				[owt].[session_id] = [es].[session_id]
			INNER JOIN sys.dm_exec_requests [er] ON
				[es].[session_id] = [er].[session_id]
			OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
			OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
			WHERE [es].[is_user_process] = 1
			ORDER BY [owt].[session_id], [owt].[exec_context_id]
	END
	ELSE
	
	INSERT waitingtasks WITH (TABLOCK)
	SELECT (select max(waitingtasks.collection_id)+1 from waitingtasks),GETDATE(),
		[owt].[session_id],
	[owt].[exec_context_id],
	[owt].[wait_duration_ms],
	[owt].[wait_type],
	[owt].[blocking_session_id],
	[owt].[resource_description],
	[es].[program_name],
	[est].[text],
	[est].[dbid],
	[eqp].[query_plan],
	[es].[cpu_time],
	[es].[memory_usage]
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_exec_sessions [es] ON
	[owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON
	[es].[session_id] = [er].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE [es].[is_user_process] = 1
ORDER BY [owt].[session_id], [owt].[exec_context_id]
END', 
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


