
--script 1
-- Now query the total worker time
SELECT TOP 10
    total_worker_time/execution_count AS avg_cpu_cost,
    execution_count,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
      (CASE WHEN statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max), text)) * 2
            ELSE statement_end_offset
       END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM sys.dm_exec_query_stats
ORDER BY [avg_cpu_cost] DESC;


----script 2
-- Another way to detect CPU pressure is by counting the number of 
-- workers in the RUNNABLE state. You can get this information by 
-- executing the following DMV query:

SELECT COUNT(*) AS workers_waiting_for_cpu, t2.Scheduler_id
FROM sys.dm_os_workers AS t1, sys.dm_os_schedulers AS t2
WHERE t1.state = 'RUNNABLE' AND
    t1.scheduler_address = t2.scheduler_address AND
    t2.scheduler_id < 255
GROUP BY t2.scheduler_id;


--script 3
-- You can also use the time spent by workers in RUNNABLE state 
-- by executing the following query:

SELECT SUM(signal_wait_time_ms)
FROM sys.dm_os_wait_stats;


--script 4
-- Here is a DMV query that can be used to get the top ten queries
-- that are taking the most CPU per execution. It also lists 
-- the SQL statement, its query plan, and the number of times 
-- this plan was executed. If an expensive query is executed 
-- very infrequently, it may not be of that much concern.

SELECT TOP 10
    total_worker_time/execution_count AS avg_cpu_cost, 
    plan_handle, execution_count,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
       (CASE WHEN statement_end_offset = -1
               THEN LEN(CONVERT(nvarchar(max), text)) * 2
               ELSE statement_end_offset
        END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM sys.dm_exec_query_stats
ORDER BY [avg_cpu_cost] DESC;


--script 5
-- To find the most frequently executed queries in your workload, 
-- you can execute the following DMV query, a slight variant of 
-- the previous DMV query:

SELECT TOP 10 total_worker_time, plan_handle,execution_count,
      (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
          (CASE WHEN statement_end_offset = -1
                  THEN LEN(CONVERT(nvarchar(max),text)) * 2
                  ELSE statement_end_offset
           END - statement_start_offset)/2)
       FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM sys.dm_exec_query_stats
ORDER BY execution_count DESC;


--script 6
-- It is also useful to know how much time SQL Server is spending 
-- in optimizing the query plans. You can use the following 
-- DMV query to get this information:

SELECT *
FROM sys.dm_exec_query_optimizer_info
WHERE counter = 'optimizations' OR counter = 'elapsed time';



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



--------TShootPerf2k8


--script 8
--The following query against sys.dm_exec_query_stats is an efficient way --to determine which query is using the most cumulative CPU. 

select 
    highest_cpu_queries.plan_handle, 
    highest_cpu_queries.total_worker_time,
    q.dbid,
    q.objectid,
    q.number,
    q.encrypted,
    q.[text]
from 
    (select top 50 
        qs.plan_handle, 
        qs.total_worker_time
    from 
        sys.dm_exec_query_stats qs
    order by qs.total_worker_time desc) as highest_cpu_queries
    cross apply sys.dm_exec_sql_text(plan_handle) as q
order by highest_cpu_queries.total_worker_time desc









-- CPU waits...by amit


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

select * from sys.dm_os_memory_objects

SELECT MO.memory_object_address, MO.type, MO.pages_allocated_count, page_size_in_bytes 
FROM sys.dm_os_memory_objects MO
inner join sys.dm_os_workers OW on
MO.memory_object_address = OW.memory_object_address
inner join sys.dm_os_tasks OT
on OW.worker_address = OT.worker_address
inner join sys.dm_exec_requests ER
on OT.task_address = ER.task_address
where ER.session_id > 50



SELECT SUM (pages_allocated_count * page_size_in_bytes) as 'Bytes Used', type 
FROM sys.dm_os_memory_objects
GROUP BY type 
ORDER BY 1 DESC;
GO


--latest by AMit
-- see the test, plan handle and plan


SELECT
    total_worker_time/execution_count AS avg_cpu_cost, 
    plan_handle, execution_count,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
       (CASE WHEN statement_end_offset = -1
               THEN LEN(CONVERT(nvarchar(max), text)) * 2
               ELSE statement_end_offset
        END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text, QP.query_plan
	 --INTO query_details
FROM sys.dm_exec_query_stats QS
CROSS APPLY sys.dm_exec_query_plan (QS.plan_handle) QP
ORDER BY [avg_cpu_cost] DESC;