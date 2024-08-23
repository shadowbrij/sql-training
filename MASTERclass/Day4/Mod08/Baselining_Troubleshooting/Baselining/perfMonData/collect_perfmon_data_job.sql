USE [msdb]
GO

/****** Object:  Job [perfMonData]    Script Date: 4/4/2013 7:30:41 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 4/4/2013 7:30:41 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'perfMonData', 
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
/****** Object:  Step [collect]    Script Date: 4/4/2013 7:30:41 AM ******/
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
		@command=N'

USE [Baseline];
GO

SET NOCOUNT ON;

DECLARE @PerfCounters TABLE (
	[Counter] NVARCHAR(770),
	[CounterType] INT,
	[FirstValue] DECIMAL(38,2),
	[FirstDateTime] DATETIME,
	[SecondValue] DECIMAL(38,2),
	[SecondDateTime] DATETIME,
	[ValueDiff] AS ([SecondValue] - [FirstValue]),
	[TimeDiff] AS (DATEDIFF(SS, FirstDateTime, SecondDateTime)),
	[CounterValue] DECIMAL(38,2)
	);

INSERT INTO @PerfCounters (
	[Counter], 
	[CounterType], 
	[FirstValue], 
	[FirstDateTime]
	)
SELECT 
	RTRIM([object_name]) + N'':'' + RTRIM([counter_name]) + N'':'' + RTRIM([instance_name]), 
	[cntr_type],
	[cntr_value], 
	GETDATE()
FROM sys.dm_os_performance_counters
WHERE [counter_name] IN (
	''Page life expectancy'', ''Lazy writes/sec'', ''Page reads/sec'', ''Page writes/sec'',''Free Pages'',
	''Free list stalls/sec'',''User Connections'', ''Lock Waits/sec'', ''Number of Deadlocks/sec'',
	''Transactions/sec'', ''Forwarded Records/sec'', ''Index Searches/sec'', ''Full Scans/sec'',
	''Batch Requests/sec'',''SQL Compilations/sec'', ''SQL Re-Compilations/sec'', ''Total Server Memory (KB)'',
	''Target Server Memory (KB)'', ''Latch Waits/sec''
	)
ORDER BY [object_name] + N'':'' + [counter_name] + N'':'' + [instance_name];

WAITFOR DELAY ''00:00:15'';

UPDATE @PerfCounters 
SET [SecondValue] = [cntr_value],
	[SecondDateTime] = GETDATE()
FROM sys.dm_os_performance_counters  
WHERE [Counter] =  RTRIM([object_name]) + N'':'' + RTRIM([counter_name]) + N'':'' + RTRIM([instance_name])
AND [counter_name] IN (
	''Page life expectancy'', ''Lazy writes/sec'', ''Page reads/sec'', ''Page writes/sec'',''Free Pages'',
	''Free list stalls/sec'',''User Connections'', ''Lock Waits/sec'', ''Number of Deadlocks/sec'',
	''Transactions/sec'', ''Forwarded Records/sec'', ''Index Searches/sec'', ''Full Scans/sec'',
	''Batch Requests/sec'',''SQL Compilations/sec'', ''SQL Re-Compilations/sec'', ''Total Server Memory (KB)'',
	''Target Server Memory (KB)'', ''Latch Waits/sec''
	);

UPDATE @PerfCounters 
SET [CounterValue] = [ValueDiff]/[TimeDiff]
WHERE [CounterType] = 272696576 ;

UPDATE @PerfCounters
SET [CounterValue] = [SecondValue]
WHERE [CounterType] <> 272696576;

INSERT INTO [dbo].[PerfMonData] (
	[Counter],
	[Value],
	[CaptureDate])
SELECT
	[Counter], 
	[CounterValue],
	[SecondDateTime]
FROM @PerfCounters;


', 
		@database_name=N'baseline', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every_1_sec', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130404, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'1f545fc1-8d91-436d-8494-1992f7385ce0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


