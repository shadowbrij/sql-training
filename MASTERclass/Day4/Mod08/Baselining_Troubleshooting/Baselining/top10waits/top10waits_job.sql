USE [msdb]
GO

/****** Object:  Job [top10waits]    Script Date: 4/1/2013 10:12:11 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 4/1/2013 10:12:11 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'top10waits', 
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
/****** Object:  Step [collect_top_10_waits]    Script Date: 4/1/2013 10:12:11 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'collect_top_10_waits', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'	IF OBJECT_ID(''baseline..top10waits'') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[top10waits]
	(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[wait_type] [nvarchar](100) NOT NULL,
	[wait_time_ms] [bigint] NOT NULL,
	[signal_wait_time_ms] [bigint] NOT NULL,
	[resource_wait_time_ms] [bigint] NULL,
	[percent_total_waits] [numeric](38, 15) NULL,
	[percent_total_signal_waits] [numeric](38, 15) NULL,
	[percent_total_resource_waits] [numeric](38, 15) NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N''sys.dm_os_wait_stats'', CLEAR); 

	INSERT top10waits WITH (TABLOCK)
	SELECT TOP 10 1,GETDATE(),
		wait_type ,
        max_wait_time_ms wait_time_ms ,
        signal_wait_time_ms ,
        wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms ,
        CASE WHEN wait_time_ms = 0 THEN 0 ELSE 100.0 * wait_time_ms / SUM(wait_time_ms) OVER ( ) END
                                    AS percent_total_waits ,
        CASE WHEN signal_wait_time_ms = 0 THEN 0 ELSE 100.0 * signal_wait_time_ms / SUM(signal_wait_time_ms) OVER ( ) END
                                    AS percent_total_signal_waits ,
        CASE WHEN wait_time_ms = 0 THEN 0 ELSE 100.0 * ( wait_time_ms - signal_wait_time_ms )
        / SUM(wait_time_ms) OVER ( ) END AS percent_total_resource_waits
FROM    sys.dm_os_wait_stats
WHERE   wait_time_ms > 0 -- remove zero wait_time
        AND wait_type NOT IN -- filter out additional irrelevant waits
( ''SLEEP_TASK'', ''BROKER_TASK_STOP'', ''BROKER_TO_FLUSH'',
  ''SQLTRACE_BUFFER_FLUSH'',''CLR_AUTO_EVENT'', ''CLR_MANUAL_EVENT'', 
  ''LAZYWRITER_SLEEP'', ''SLEEP_SYSTEMTASK'', ''SLEEP_BPOOL_FLUSH'',
  ''BROKER_EVENTHANDLER'', ''XE_DISPATCHER_WAIT'', ''FT_IFTSHC_MUTEX'',
  ''CHECKPOINT_QUEUE'', ''FT_IFTS_SCHEDULER_IDLE_WAIT'', 
  ''BROKER_TRANSMITTER'', ''FT_IFTSHC_MUTEX'', ''KSOURCE_WAKEUP'',
  ''LAZYWRITER_SLEEP'', ''LOGMGR_QUEUE'', ''ONDEMAND_TASK_QUEUE'',
  ''REQUEST_FOR_DEADLOCK_SEARCH'', ''XE_TIMER_EVENT'', ''BAD_PAGE_PROCESS'',
  ''DBMIRROR_EVENTS_QUEUE'', ''BROKER_RECEIVE_WAITFOR'',
  ''PREEMPTIVE_OS_GETPROCADDRESS'', ''PREEMPTIVE_OS_AUTHENTICATIONOPS'',
  ''WAITFOR'', ''DISPATCHER_QUEUE_SEMAPHORE'', ''XE_DISPATCHER_JOIN'',
  ''RESOURCE_QUEUE'' )
ORDER BY wait_time_ms DESC
END
ELSE
BEGIN
	INSERT top10waits WITH (TABLOCK)
	SELECT top 10 (select max(top10waits.collection_id)+1 from top10waits),GETDATE(),
	    wait_type ,
        max_wait_time_ms wait_time_ms ,
        signal_wait_time_ms ,
        wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms ,
        CASE WHEN wait_time_ms = 0 THEN 0 ELSE 100.0 * wait_time_ms / SUM(wait_time_ms) OVER ( ) END
                                    AS percent_total_waits ,
        CASE WHEN signal_wait_time_ms = 0 THEN 0 ELSE 100.0 * signal_wait_time_ms / SUM(signal_wait_time_ms) OVER ( ) END
                                    AS percent_total_signal_waits ,
        CASE WHEN wait_time_ms = 0 THEN 0 ELSE 100.0 * ( wait_time_ms - signal_wait_time_ms )
        / SUM(wait_time_ms) OVER ( ) END AS percent_total_resource_waits
FROM    sys.dm_os_wait_stats
WHERE   wait_time_ms > 0 -- remove zero wait_time
        AND wait_type NOT IN -- filter out additional irrelevant waits
( ''SLEEP_TASK'', ''BROKER_TASK_STOP'', ''BROKER_TO_FLUSH'',
  ''SQLTRACE_BUFFER_FLUSH'',''CLR_AUTO_EVENT'', ''CLR_MANUAL_EVENT'', 
  ''LAZYWRITER_SLEEP'', ''SLEEP_SYSTEMTASK'', ''SLEEP_BPOOL_FLUSH'',
  ''BROKER_EVENTHANDLER'', ''XE_DISPATCHER_WAIT'', ''FT_IFTSHC_MUTEX'',
  ''CHECKPOINT_QUEUE'', ''FT_IFTS_SCHEDULER_IDLE_WAIT'', 
  ''BROKER_TRANSMITTER'', ''FT_IFTSHC_MUTEX'', ''KSOURCE_WAKEUP'',
  ''LAZYWRITER_SLEEP'', ''LOGMGR_QUEUE'', ''ONDEMAND_TASK_QUEUE'',
  ''REQUEST_FOR_DEADLOCK_SEARCH'', ''XE_TIMER_EVENT'', ''BAD_PAGE_PROCESS'',
  ''DBMIRROR_EVENTS_QUEUE'', ''BROKER_RECEIVE_WAITFOR'',
  ''PREEMPTIVE_OS_GETPROCADDRESS'', ''PREEMPTIVE_OS_AUTHENTICATIONOPS'',
  ''WAITFOR'', ''DISPATCHER_QUEUE_SEMAPHORE'', ''XE_DISPATCHER_JOIN'',
  ''RESOURCE_QUEUE'' )
ORDER BY wait_time_ms DESC

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
		@active_start_date=20130401, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'1426771c-5da3-435d-8614-dcf0ef934e32'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


