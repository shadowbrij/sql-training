USE [msdb]
GO

/****** Object:  Job [DMVCount]    Script Date: 4/4/2013 8:33:57 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 4/4/2013 8:33:57 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DMVCount', 
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
/****** Object:  Step [collect]    Script Date: 4/4/2013 8:33:57 AM ******/
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
		@command=N'	IF OBJECT_ID(''baseline..DMVcount'') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[DMVcount](
	[collection_id] [bigint] NOT NULL,
	[collection_time] [datetime] NOT NULL,
	[DMVName] [varchar](100) NOT NULL,
	[Row_Count] [bigint] NULL
) ON [PRIMARY];
	
	--select * from dmvcount 
	
	with DMV_count as
(
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_exec_requests'' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_requests
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_exec_connections'' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_connections
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_exec_sessions'' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_sessions
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_exec_query_memory_grants'' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_query_memory_grants
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_os_threads'' as DMVName, COUNT(*) as Row_Count from sys.dm_os_threads
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_os_tasks'' as DMVName, COUNT(*) as Row_Count from sys.dm_os_tasks
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_os_waiting_tasks'' as DMVName, COUNT(*) as Row_Count from sys.dm_os_waiting_tasks
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_os_dm_os_workers'' as DMVName, COUNT(*) as Row_Count from sys.dm_os_workers
)
	INSERT DMVcount
select * from dmv_count

END
ELSE
BEGIN
	
	with DMV_count as
(
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_exec_requests'' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_requests
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_exec_connections'' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_connections
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_exec_sessions'' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_sessions
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_exec_query_memory_grants'' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_query_memory_grants
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_os_threads'' as DMVName, COUNT(*) as Row_Count from sys.dm_os_threads
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_os_tasks'' as DMVName, COUNT(*) as Row_Count from sys.dm_os_tasks
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_os_waiting_tasks'' as DMVName, COUNT(*) as Row_Count from sys.dm_os_waiting_tasks
union
select 1 as collection_id, GETDATE() as collection_time, ''sys.dm_os_dm_os_workers'' as DMVName, COUNT(*) as Row_Count from sys.dm_os_workers
)
	INSERT DMVcount
select (select max(DMVcount.collection_id)+1 from DMVcount),GETDATE(), DMVName, Row_Count from dmv_count

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
		@active_start_date=20130404, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'3f4d5b4d-59bb-40e6-8a67-15fa16e9f75a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


