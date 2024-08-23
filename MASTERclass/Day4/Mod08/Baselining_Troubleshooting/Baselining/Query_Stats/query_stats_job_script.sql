USE [msdb]
GO

/****** Object:  Job [Query_stats]    Script Date: 7/11/2013 10:08:46 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 7/11/2013 10:08:46 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Query_stats', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'WIN2K8R2\Administrator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [query_stats_collection]    Script Date: 7/11/2013 10:08:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'query_stats_collection', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'	IF OBJECT_ID(''baseline..query_stats'') IS NULL
BEGIN
	
CREATE TABLE [dbo].[query_stats](
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[sql_handle] [varbinary](64) NOT NULL,
	[statement_start_offset] [int] NOT NULL,
	[statement_end_offset] [int] NOT NULL,
	[plan_generation_num] [bigint] NOT NULL,
	[plan_handle] [varbinary](64) NOT NULL,
	[creation_time] [datetime] NOT NULL,
	[last_execution_time] [datetime] NOT NULL,
	[execution_count] [bigint] NOT NULL,
	[total_worker_time] [bigint] NOT NULL,
	[last_worker_time] [bigint] NOT NULL,
	[min_worker_time] [bigint] NOT NULL,
	[max_worker_time] [bigint] NOT NULL,
	[total_physical_reads] [bigint] NOT NULL,
	[last_physical_reads] [bigint] NOT NULL,
	[min_physical_reads] [bigint] NOT NULL,
	[max_physical_reads] [bigint] NOT NULL,
	[total_logical_writes] [bigint] NOT NULL,
	[last_logical_writes] [bigint] NOT NULL,
	[min_logical_writes] [bigint] NOT NULL,
	[max_logical_writes] [bigint] NOT NULL,
	[total_logical_reads] [bigint] NOT NULL,
	[last_logical_reads] [bigint] NOT NULL,
	[min_logical_reads] [bigint] NOT NULL,
	[max_logical_reads] [bigint] NOT NULL,
	[total_clr_time] [bigint] NOT NULL,
	[last_clr_time] [bigint] NOT NULL,
	[min_clr_time] [bigint] NOT NULL,
	[max_clr_time] [bigint] NOT NULL,
	[total_elapsed_time] [bigint] NOT NULL,
	[last_elapsed_time] [bigint] NOT NULL,
	[min_elapsed_time] [bigint] NOT NULL,
	[max_elapsed_time] [bigint] NOT NULL,
	[query_hash] [binary](8) NOT NULL,
	[query_plan_hash] [binary](8) NOT NULL,
	[total_rows] [bigint] NOT NULL,
	[last_rows] [bigint] NOT NULL,
	[min_rows] [bigint] NOT NULL,
	[max_rows] [bigint] NOT NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N''sys.dm_os_wait_stats'', CLEAR); 

	INSERT query_stats WITH (TABLOCK)
	SELECT 1,GETDATE(),
	[sql_handle]
           ,[statement_start_offset]
           ,[statement_end_offset]
           ,[plan_generation_num]
           ,[plan_handle]
           ,[creation_time]
           ,[last_execution_time]
           ,[execution_count]
           ,[total_worker_time]
           ,[last_worker_time]
           ,[min_worker_time]
           ,[max_worker_time]
           ,[total_physical_reads]
           ,[last_physical_reads]
           ,[min_physical_reads]
           ,[max_physical_reads]
           ,[total_logical_writes]
           ,[last_logical_writes]
           ,[min_logical_writes]
           ,[max_logical_writes]
           ,[total_logical_reads]
           ,[last_logical_reads]
           ,[min_logical_reads]
           ,[max_logical_reads]
           ,[total_clr_time]
           ,[last_clr_time]
           ,[min_clr_time]
           ,[max_clr_time]
           ,[total_elapsed_time]
           ,[last_elapsed_time]
           ,[min_elapsed_time]
           ,[max_elapsed_time]
           ,[query_hash]
           ,[query_plan_hash]
           ,[total_rows]
           ,[last_rows]
           ,[min_rows]
           ,[max_rows]
FROM sys.dm_exec_query_stats
END
ELSE
BEGIN
	
	INSERT Query_Stats WITH (TABLOCK)
	SELECT (select ISNULL (max(Query_stats.collection_id),0)+1 from Query_Stats),GETDATE(),

				[sql_handle]
           ,[statement_start_offset]
           ,[statement_end_offset]
           ,[plan_generation_num]
           ,[plan_handle]
           ,[creation_time]
           ,[last_execution_time]
           ,[execution_count]
           ,[total_worker_time]
           ,[last_worker_time]
           ,[min_worker_time]
           ,[max_worker_time]
           ,[total_physical_reads]
           ,[last_physical_reads]
           ,[min_physical_reads]
           ,[max_physical_reads]
           ,[total_logical_writes]
           ,[last_logical_writes]
           ,[min_logical_writes]
           ,[max_logical_writes]
           ,[total_logical_reads]
           ,[last_logical_reads]
           ,[min_logical_reads]
           ,[max_logical_reads]
           ,[total_clr_time]
           ,[last_clr_time]
           ,[min_clr_time]
           ,[max_clr_time]
           ,[total_elapsed_time]
           ,[last_elapsed_time]
           ,[min_elapsed_time]
           ,[max_elapsed_time]
           ,[query_hash]
           ,[query_plan_hash]
           ,[total_rows]
           ,[last_rows]
           ,[min_rows]
           ,[max_rows]
FROM sys.dm_exec_query_stats
END
	', 
		@database_name=N'baseline', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every_1_min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130711, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'364d498e-a837-4c57-98b6-770683d84a64'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


