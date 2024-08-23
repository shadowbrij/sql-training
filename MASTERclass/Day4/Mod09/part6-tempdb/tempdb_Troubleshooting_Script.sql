----------------------------------------------------------------------
-- Troubleshooting tempdb
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Monitoring tempdb Space
----------------------------------------------------------------------
Select
    SUM (user_object_reserved_page_count)*8 as user_objects_kb,
    SUM (internal_object_reserved_page_count)*8 as internal_objects_kb,
    SUM (version_store_reserved_page_count)*8  as version_store_kb,
    SUM (unallocated_extent_page_count)*8 as freespace_kb
From sys.dm_db_file_space_usage
Where database_id = 2

-- This DMV query shows currently executing tasks and
-- tempdb space usage
-- Once you have isolated the task(s) that are generating lots
-- of internal object allocations,
-- you can even find out which TSQL statement and its query plan
-- for detailed analysis

----------------------------------------------------------------------
-- Monitoring tempdb Space (More detail analysis)
----------------------------------------------------------------------
select top 10
t1.session_id,
t1.request_id,
t1.task_alloc,
     t1.task_dealloc, 
    (SELECT SUBSTRING(text, t2.statement_start_offset/2 + 1,
          (CASE WHEN statement_end_offset = -1
              THEN LEN(CONVERT(nvarchar(max),text)) * 2
                   ELSE statement_end_offset
              END - t2.statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text,
 (SELECT query_plan from sys.dm_exec_query_plan(t2.plan_handle)) as query_plan
 
from      (Select session_id, request_id,
sum(internal_objects_alloc_page_count +   user_objects_alloc_page_count) as task_alloc,
sum (internal_objects_dealloc_page_count + user_objects_dealloc_page_count) as task_dealloc
       from sys.dm_db_task_space_usage
       group by session_id, request_id) as t1,
       sys.dm_exec_requests as t2
where t1.session_id = t2.session_id and
(t1.request_id = t2.request_id) and
      t1.session_id > 50
order by t1.task_alloc DESC

--tempdb Bottleneck
select  session_id, wait_duration_ms, resource_description
from sys.dm_os_waiting_tasks
where wait_type like 'PAGE%LATCH_%' and
    resource_description like '2:%'


----------------------------------------------------------------------
-- Troubleshooting Space Issues
----------------------------------------------------------------------
----------------------------------------------------------------------
-- User Objects
----------------------------------------------------------------------
DECLARE userobj_cursor CURSOR FOR 
select 
     sys.schemas.name + '.' + sys.objects.name 
from sys.objects, sys.schemas
where object_id > 100 and 
      type_desc = 'USER_TABLE'and 
      sys.objects.schema_id = sys.schemas.schema_id
go

open userobj_cursor
go

declare @name varchar(256)
fetch userobj_cursor into @name
while (@@FETCH_STATUS = 0) 
begin
    exec sp_spaceused @objname = @name
        fetch userobj_cursor into @name	
end
close userobj_cursor

----------------------------------------------------------------------
-- Version Store
----------------------------------------------------------------------

select top 2 
    transaction_id, 
    transaction_sequence_num, 
    elapsed_time_seconds 
from sys.dm_tran_active_snapshot_database_transactions
order by elapsed_time_seconds DESC

----------------------------------------------------------------------
-- Internal Objects
----------------------------------------------------------------------

select 
    session_id, 
    internal_objects_alloc_page_count, 
    internal_objects_dealloc_page_count
from sys.dm_db_session_space_usage
order by internal_objects_alloc_page_count DESC

--You can use the following query to find the top user sessions that are allocating internal objects, including currently active tasks.
SELECT 
    t1.session_id,
    (t1.internal_objects_alloc_page_count + task_alloc) as allocated,
    (t1.internal_objects_dealloc_page_count + task_dealloc) as	
    deallocated 
from sys.dm_db_session_space_usage as t1, 
    (select session_id, 
        sum(internal_objects_alloc_page_count)
            as task_alloc,
    sum (internal_objects_dealloc_page_count) as 
        task_dealloc 
      from sys.dm_db_task_space_usage group by session_id) as t2
where t1.session_id = t2.session_id and t1.session_id >50
order by allocated DESC


--After you have isolated the task or tasks that are generating a lot of internal object allocations, you can find out which Transact-SQL statement it is and its query plan for a more detailed analysis.
select 
    t1.session_id, 
    t1.request_id, 
    t1.task_alloc,
    t1.task_dealloc,
    t2.sql_handle, 
    t2.statement_start_offset, 
    t2.statement_end_offset, 
    t2.plan_handle
from (Select session_id, 
             request_id,
             sum(internal_objects_alloc_page_count) as task_alloc,
             sum (internal_objects_dealloc_page_count) as task_dealloc 
      from sys.dm_db_task_space_usage 
      group by session_id, request_id) as t1, 
      sys.dm_exec_requests as t2
where t1.session_id = t2.session_id and 
     (t1.request_id = t2.request_id)
order by t1.task_alloc DESC

--select text from sys.dm_exec_sql_text(@sql_handle)
--select * from sys.dm_exec_query_plan(@plan_handle)

----------------------------------------------------------------------
--Excessive DDL and Allocation Operations (Worktable and WorkFile)
----------------------------------------------------------------------
declare @now datetime 
select @now = getdate()
      select 
          session_id, 
          wait_duration_ms, 
          resource_description, 
          @now
      from sys.dm_os_waiting_tasks
      where wait_type like 'PAGE%LATCH_%' and
            resource_description like '2:%'

SELECT
    [owt].[session_id],
    [owt].[exec_context_id],
    [owt].[wait_duration_ms],
    [owt].[wait_type],
    [owt].[blocking_session_id],
    [owt].[resource_description],
    CASE [owt].[wait_type]
        WHEN N'CXPACKET' THEN
            RIGHT ([owt].[resource_description],
            CHARINDEX (N'=', REVERSE ([owt].[resource_description])) - 1)
        ELSE NULL
    END AS [Node ID],
    [es].[program_name],
    [est].text,
    [er].[database_id],
    [eqp].[query_plan],
    [er].[cpu_time]
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_exec_sessions [es] ON
    [owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON
    [es].[session_id] = [er].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE
    [es].[is_user_process] = 1
ORDER BY
    [owt].[session_id],
    [owt].[exec_context_id];
GO