	IF OBJECT_ID('baseline..query_stats') IS NULL
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
	
	--DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR); 

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
	