	IF OBJECT_ID('baseline..DMVcount') IS NULL
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
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_exec_requests' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_requests
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_exec_connections' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_connections
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_exec_sessions' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_sessions
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_exec_query_memory_grants' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_query_memory_grants
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_os_threads' as DMVName, COUNT(*) as Row_Count from sys.dm_os_threads
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_os_tasks' as DMVName, COUNT(*) as Row_Count from sys.dm_os_tasks
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_os_waiting_tasks' as DMVName, COUNT(*) as Row_Count from sys.dm_os_waiting_tasks
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_os_dm_os_workers' as DMVName, COUNT(*) as Row_Count from sys.dm_os_workers
)
	INSERT DMVcount
select * from dmv_count

END
ELSE
BEGIN
	
	with DMV_count as
(
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_exec_requests' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_requests
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_exec_connections' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_connections
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_exec_sessions' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_sessions
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_exec_query_memory_grants' as DMVName, COUNT(*) as Row_Count from sys.dm_exec_query_memory_grants
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_os_threads' as DMVName, COUNT(*) as Row_Count from sys.dm_os_threads
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_os_tasks' as DMVName, COUNT(*) as Row_Count from sys.dm_os_tasks
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_os_waiting_tasks' as DMVName, COUNT(*) as Row_Count from sys.dm_os_waiting_tasks
union
select 1 as collection_id, GETDATE() as collection_time, 'sys.dm_os_dm_os_workers' as DMVName, COUNT(*) as Row_Count from sys.dm_os_workers
)
	INSERT DMVcount
select (select max(DMVcount.collection_id)+1 from DMVcount),GETDATE(), DMVName, Row_Count from dmv_count

END
