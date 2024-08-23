	IF OBJECT_ID('baseline..waits') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[waits](
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[wait_type] [nvarchar](100) NOT NULL,
	[waiting_tasks_count] [bigint] NOT NULL,
	[wait_time_ms] [bigint] NOT NULL,
	[max_wait_time_ms] [bigint] NOT NULL,
	[signal_wait_time_ms] [bigint] NOT NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR); 

	INSERT waits WITH (TABLOCK)
	SELECT 1,GETDATE(),
		*
	FROM sys.dm_os_wait_stats
END
ELSE
BEGIN
	INSERT waits WITH (TABLOCK)
	SELECT (select max(waits.collection_id)+1 from waits),GETDATE(),
		*
	FROM sys.dm_os_wait_stats

END
