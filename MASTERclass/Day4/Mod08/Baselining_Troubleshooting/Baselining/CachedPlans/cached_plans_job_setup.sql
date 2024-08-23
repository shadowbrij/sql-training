USE [msdb]
GO

/****** Object:  Job [Analyzing_Plans]    Script Date: 5/23/2013 3:04:13 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 5/23/2013 3:04:13 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Analyzing_Plans', 
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
/****** Object:  Step [collect_plans]    Script Date: 5/23/2013 3:04:13 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'collect_plans', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'	IF OBJECT_ID(''baseline..Analyzing_Plans'') IS NULL
BEGIN
	
CREATE TABLE [dbo].[Analyzing_Plans]
(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[size_in_bytes] [int] NOT NULL,
	[plan_handle] [varbinary](64) NOT NULL,
	[query_plan] [xml] NULL,
	[text] [nvarchar](max) NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N''sys.dm_os_wait_stats'', CLEAR); 

INSERT Analyzing_Plans WITH (TABLOCK)
	SELECT 1,GETDATE(),
CP.size_in_bytes, CP.plan_handle, QP.query_plan, ST.text
from 
sys.dm_exec_query_stats QS
INNER JOIN
sys.dm_exec_cached_plans CP
on QS.plan_handle = CP.plan_handle
CROSS APPLY
sys.dm_exec_query_plan (CP.plan_handle) QP
CROSS APPLY
sys.dm_exec_sql_text (QS.sql_handle) ST

END
ELSE
BEGIN
	
	INSERT Analyzing_Plans WITH (TABLOCK)
	SELECT (select max(Analyzing_Plans.collection_id)+1 from Analyzing_Plans),GETDATE(),
CP.size_in_bytes, CP.plan_handle, QP.query_plan, ST.text
from 
sys.dm_exec_query_stats QS
INNER JOIN
sys.dm_exec_cached_plans CP
on QS.plan_handle = CP.plan_handle
CROSS APPLY
sys.dm_exec_query_plan (CP.plan_handle) QP
CROSS APPLY
sys.dm_exec_sql_text (QS.sql_handle) ST
END
', 
		@database_name=N'baseline', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every_30_mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130523, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'a29886ef-af03-41a5-b9e0-caaf9a26bafb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


