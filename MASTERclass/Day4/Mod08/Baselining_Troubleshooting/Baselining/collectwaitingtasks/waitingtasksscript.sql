	IF OBJECT_ID('baseline..waitingtasks') IS NULL
BEGIN
	
CREATE TABLE [dbo].[waitingtasks]
(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[session_id] [smallint] NULL,
	[exec_context_id] [int] NULL,
	[wait_duration_ms] [bigint] NULL,
	[wait_type] [nvarchar](100) NULL,
	[blocking_session_id] [smallint] NULL,
	[resource_description] [nvarchar](3072) NULL,
	[program_name] [nvarchar](200) NULL,
	[text] [nvarchar](max) NULL,
	[dbid] [smallint] NULL,
	[query_plan] [xml] NULL,
	[cpu_time] [bigint] NOT NULL,
	[memory_usage] [bigint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	
	--DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR); 

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
END