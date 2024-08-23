--------------------------------
--wait stats
--------------------------------

------------------
--let us begin by seeing the current waiting tasks
------------------

select * from sys.dm_os_tasks
where session_id >50
GO

select * from sys.dm_os_waiting_tasks
where session_id>50
GO


------------------
--ABPSPR - analyzing tasks
------------------

SELECT
	[ot].[scheduler_id],
	[task_state],
	COUNT (*) AS [task_count]
FROM
	sys.dm_os_tasks AS [ot]
INNER JOIN
	sys.dm_exec_requests AS [er]
    ON [ot].[session_id] = [er].[session_id]
INNER JOIN
	sys.dm_exec_sessions AS [es]
    ON [er].[session_id] = [es].[session_id]
WHERE
	[es].[is_user_process] = 1
GROUP BY
	[ot].[scheduler_id],
	[task_state]
ORDER BY
	[task_state],
	[ot].[scheduler_id];
GO







--script 4
--To look only at user sessions, which
--are typically the most common area of interest when looking at waiting --tasks, you can use a fi lter on
--the session_id column for values greater than 50:


SELECT session_id,
execution_context_id,
wait_duration_ms,
wait_type,
resource_description,
blocking_session_id
FROM sys.dm_os_waiting_tasks
WHERE session_id > 50
ORDER BY session_id



--script 5
--It can also be very useful to perform aggregate queries against this DMV --to fi nd information such as
--the number of tasks for each wait type:


SELECT wait_type,
COUNT(*) AS num_waiting_tasks,
SUM(wait_duration_ms) AS total_wait_time_ms
FROM sys.dm_os_waiting_tasks
WHERE session_id > 50
GROUP BY wait_type
ORDER BY wait_type




---------------
--Memory
---------------


--script 8
-- Similarly, you can use the sys.dm_os_sys_memory DMV in SQL Server 2008 --to assess the system state.


select 
	total_physical_memory_kb / 1024 as phys_mem_mb,
	available_physical_memory_kb / 1024 as avail_phys_mem_mb,
	system_cache_kb /1024 as sys_cache_mb,
	(kernel_paged_pool_kb+kernel_nonpaged_pool_kb) / 1024 
		as kernel_pool_mb,
	total_page_file_kb / 1024 as total_page_file_mb,
	available_page_file_kb / 1024 as available_page_file_mb,
	system_memory_state_desc
from sys.dm_os_sys_memory


-----------------

select physical_memory_in_use_kb/1024 as physical_memory_in_use_MB,
large_page_allocations_kb/1024 as large_page_allocations_MB,
locked_page_allocations_kb/1204 as locked_page_allocations_MB,
total_virtual_address_space_kb/1024 as total_virtual_address_space_MB,
virtual_address_space_reserved_kb/1024 as virtual_address_space_reserved_MB,
virtual_address_space_committed_kb/1024 as virtual_address_space_committed_MB,
virtual_address_space_available_kb/1024 as virtual_address_space_available_MB,
available_commit_limit_kb/1024 as available_commit_limit_MB 
from sys.dm_os_process_memory

---------------



--script 1
-- For example, you can use the following DMV query to find the 
-- total amount of memory consumed (including AWE) by 
-- the buffer pool:

SELECT  SUM(multi_pages_kb + virtual_memory_committed_kb 
            + shared_memory_committed_kb  
            + awe_allocated_kb) AS [Used by BPool, Kb]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';



--script 1.2

-- pages in BUffer Pool

SELECT count(*)*8/1024 AS 'Cached Size (MB)'
,CASE database_id
WHEN 32767 THEN 'ResourceDb'
ELSE db_name(database_id)
END AS 'Database'
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY 'Cached Size (MB)' DESC


--script 2

-- You can identify the internal components that have 
-- allocated memory outside of buffer pool by using 
--  multipage allocator with the following query:

SELECT type, SUM(multi_pages_kb) AS memory_allocated_KB
FROM sys.dm_os_memory_clerks
WHERE multi_pages_kb != 0
GROUP BY type;



-- Plan cache

SELECT count(*) AS 'Number of Plans',
sum(cast(size_in_bytes AS BIGINT))/1024/1024 AS 'Plan Cache Size (MB)'
FROM sys.dm_exec_cached_plans

-- breaking down the plan cache size

SELECT objtype AS 'Cached Object Type',
count(*) AS 'Number of Plans',
sum(cast(size_in_bytes AS BIGINT))/1024/1024 AS 'Plan Cache Size (MB)',
avg(usecounts) AS 'Avg Use Count'
FROM sys.dm_exec_cached_plans
GROUP BY objtype







------------------------------
--CPU
------------------------------

----script 1
-- Another way to detect CPU pressure is by counting the number of 
-- workers in the RUNNABLE state. You can get this information by 
-- executing the following DMV query:

SELECT COUNT(*) AS workers_waiting_for_cpu, t2.Scheduler_id
FROM sys.dm_os_workers AS t1, sys.dm_os_schedulers AS t2
WHERE t1.state = 'RUNNABLE' AND
    t1.scheduler_address = t2.scheduler_address AND
    t2.scheduler_id < 255
GROUP BY t2.scheduler_id;



--script 7
--The following query gives you a high-level view of which currently cached batches or procedures are using the most CPU

select top 50 
    sum(qs.total_worker_time) as total_cpu_time, 
    sum(qs.execution_count) as total_execution_count,
    count(*) as  number_of_statements, 
    qs.plan_handle 
from 
    sys.dm_exec_query_stats qs
group by qs.plan_handle
order by sum(qs.total_worker_time) desc




-- CPU waits by Amit
select runnable_tasks_count,work_queue_count,pending_disk_io_count, * from sys.dm_os_schedulers

select * from sys.dm_os_workers
select * from sys.dm_os_threads

select * from sys.dm_os_tasks
where session_id > 50

task_state = 'SUSPENDED' or task_state = 'PENDING'
AND
select * from sys.dm_os_waiting_tasks where session_id > 50

select * from sys.dm_exec_requests
where session_id > 50




-------------------------------------
--I/O
-------------------------------------

--script 5
--You can use the following DMV query to find currently pending I/O ----requests. You can execute this query periodically to check the health of --I/O subsystem and to isolate physical disk(s) that are involved in the --I/O bottlenecks.



select 
    database_id, 
    file_id, 
    io_stall,
    io_pending_ms_ticks,
    scheduler_address 
from	sys.dm_io_virtual_file_stats(NULL, NULL)t1,
        sys.dm_io_pending_io_requests as t2
where	t1.file_handle = t2.io_handle




---------------------------------------
--Locking/Blocking
---------------------------------------

--script 1
-- You can find out at any given times all the locks
-- that have been granted or waited upon by currently 
-- executing transactons using the following DMV query. 
-- This query provides a output similarly to the stored 
-- procedure sp_lock.


SELECT request_session_id AS spid, resource_type AS rt,
    resource_database_id AS rdb,
   (CASE resource_type
       WHEN 'OBJECT' 
          THEN object_name(resource_associated_entity_id)
       WHEN 'DATABASE' 
           THEN ' '
       ELSE (SELECT object_name(object_id)
             FROM sys.partitions
             WHERE hobt_id=resource_associated_entity_id)
    END) AS objname,
resource_description AS rd, request_mode AS rm, request_status AS rs
FROM sys.dm_tran_locks;




--script 2
-- If you want more details, you can combine the sys.dm_tran_locks 
-- DMV with other DMVs to get more detailed information such as 
-- duration of the block and the Transact-SQL statement being 
-- executed by the blocked transaction as follows:

SELECT t1.resource_type,
       'database' = DB_NAME(resource_database_id),
       'blk object' = t1.resource_associated_entity_id,
       t1.request_mode, t1.request_session_id,
       t2.blocking_session_id,
       t2.wait_duration_ms,
      (SELECT SUBSTRING(text, t3.statement_start_offset/2 + 1,
          (CASE WHEN t3.statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max),text)) * 2
            ELSE t3.statement_end_offset
           END - t3.statement_start_offset)/2)
       FROM sys.dm_exec_sql_text(sql_handle)) AS query_text,
t2.resource_description
FROM
   sys.dm_tran_locks AS t1,
   sys.dm_os_waiting_tasks AS t2,
   sys.dm_exec_requests AS t3
WHERE
   t1.lock_owner_address = t2.resource_address AND
   t1.request_request_id = t3.request_id AND
   t2.session_id = t3.session_id;



--script 3
--waitsstatsqueues

--In order to see the main objects of blocking contention, the following --code lists the table and index with most blocks:
----Find Row lock waits
declare @dbid int
select @dbid = db_id()
Select dbid=database_id, objectname=object_name(s.object_id)
, indexname=i.name, i.index_id	--, partition_number
, row_lock_count, row_lock_wait_count
, [block %]=cast (100.0 * row_lock_wait_count / (1 + row_lock_count) as numeric(15,2))
, row_lock_wait_in_ms
, [avg row lock waits in ms]=cast (1.0 * row_lock_wait_in_ms / (1 + row_lock_wait_count) as numeric(15,2))
from sys.dm_db_index_operational_stats (@dbid, NULL, NULL, NULL) s, 	sys.indexes i
where objectproperty(s.object_id,'IsUserTable') = 1
and i.object_id = s.object_id
and i.index_id = s.index_id
order by row_lock_wait_count desc


-----
-- step 8 (combine it all)

SELECT er.session_id ,
host_name , program_name , original_login_name , er.reads ,
er.writes ,er.cpu_time , wait_type , wait_time , wait_resource ,
blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE blocking_session_id > 0
UNION
SELECT es.session_id , host_name , program_name , original_login_name ,
es.reads , es.writes , es.cpu_time , wait_type , wait_time ,
wait_resource , blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE es.session_id IN ( SELECT blocking_session_id
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0 )



----------------------------------
--TempDB
----------------------------------




--script 1
-- This query finds out if one or more threads are waiting to 
-- acquire latch on pages in tempdb. Note, this DMV shows the 
-- current workers that are waiting. 
-- You will need to poll this DMV often to identify allocation 
-- bottleneck.

SELECT session_id, wait_duration_ms, resource_description
FROM sys.dm_os_waiting_tasks
WHERE wait_type LIKE 'PAGE%LATCH_%' 
      AND resource_description like '2:%';




--script 2
-- You can use the following DMV query to identify the currently 
-- executing query this is causing the most allocations and 
-- deallocations in tempdb.

SELECT TOP 10 t1.session_id, t1.request_id, t1.task_alloc,
              t1.task_dealloc, t2.plan_handle,
       (SELECT SUBSTRING (text, t2.statement_start_offset/2 + 1,
            (CASE WHEN statement_end_offset = -1
                  THEN LEN(CONVERT(nvarchar(MAX),text)) * 2
                  ELSE statement_end_offset
             END - t2.statement_start_offset)/2)
        FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM (SELECT session_id, request_id, 
         SUM(internal_objects_alloc_page_count +
                 user_objects_alloc_page_count) AS task_alloc,
          SUM(internal_objects_dealloc_page_count +
                  user_objects_dealloc_page_count) AS task_dealloc
       FROM sys.dm_db_task_space_usage
       GROUP BY session_id, request_id) AS t1,
  sys.dm_exec_requests AS t2
WHERE t1.session_id = t2.session_id AND
     (t1.request_id = t2.request_id) AND t1.session_id > 50
ORDER BY t1.task_alloc DESC;



--another short variation of the above query
--You can use the following query to find the top user sessions that are --allocating internal objects, including currently active tasks.
 
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
