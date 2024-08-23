USE [msdb]
GO

/****** Object:  Job [database_files]    Script Date: 4/4/2013 11:08:00 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 4/4/2013 11:08:00 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'database_files', 
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
/****** Object:  Step [collect]    Script Date: 4/4/2013 11:08:00 AM ******/
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
		@command=N'	IF OBJECT_ID(''baseline..database_files'') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[database_files]
	(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[Database Name] [nvarchar](200) NULL,
	[file_id] [int] NOT NULL,
	[name] [sysname] NOT NULL,
	[physical_name] [nvarchar](400) NOT NULL,
	[type_desc] [nvarchar](100) NULL,
	[state_desc] [nvarchar](100) NULL,
	[Total Size in MB] [bigint] NULL
) ON [PRIMARY]

	INSERT [database_files] WITH (TABLOCK)
	SELECT 1,GETDATE(),
		DB_NAME([database_id])AS [Database Name], 
       [file_id], name, physical_name, type_desc, state_desc, 
	          CONVERT( bigint, size/128.0) AS [Total Size in MB]
			  FROM sys.master_files WHERE [database_id] > 4 
			  AND [database_id] <> 32767
			  OR [database_id] = 2
			  ORDER BY DB_NAME([database_id]);
END
ELSE
BEGIN
	INSERT [database_files] WITH (TABLOCK)
	SELECT (select max([database_files].collection_id)+1 from [database_files]),GETDATE(),
				DB_NAME([database_id])AS [Database Name], 
       [file_id], name, physical_name, type_desc, state_desc, 
	          CONVERT( bigint, size/128.0) AS [Total Size in MB]
			  FROM sys.master_files WHERE [database_id] > 4 
			  AND [database_id] <> 32767
			  OR [database_id] = 2
			  ORDER BY DB_NAME([database_id]);

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
		@schedule_uid=N'301398f6-6612-4ef9-bf65-112d0978c9ab'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


