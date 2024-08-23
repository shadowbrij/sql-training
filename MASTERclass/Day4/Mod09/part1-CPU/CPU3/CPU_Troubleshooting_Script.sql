-------------------------------------------------------------------------------------
-- Troubleshooting CPU
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
-- Q: How do I identify that it’s not an OS issue but SQL Server issue?

-- If high runnable tasks count is found by below query then we have is a 
-- symptom of a CPU bottleneck.

select scheduler_id,
current_tasks_count,
runnable_tasks_count
from sys.dm_os_schedulers
where scheduler_id < 255

-- Use below query to find Signal Waits (CPU waits) for instance(above 10-15% is 
-- usually a sign of CPU pressure)


SELECT      CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%signal (cpu) waits],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%resource waits]
FROM sys.dm_os_wait_stats WITH (NOLOCK) OPTION (RECOMPILE);

-- Use the below query to Get Average Task Counts (run multiple times, note 
-- highest values)

SELECT      AVG(current_tasks_count) AS [Avg Task Count],
AVG(runnable_tasks_count) AS [Avg Runnable Task Count],
AVG(pending_disk_io_count) AS [AvgPendingDiskIOCount]
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE scheduler_id < 255 OPTION (RECOMPILE);


-- Q: Yes its SQL Server….Now what?

--=============================================================================================
-- 1: Unnecessary Recompilation
--=============================================================================================
-- Check how much recompilations are happening on the box:


SELECT TOP 25 sql_text.text,
    sql_handle,
    plan_generation_num,
    execution_count,
    dbid,
    objectid
from sys.dm_exec_query_stats a
cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where plan_generation_num >1
      order by plan_generation_num desc

-- Monitor recompilation from performance counter
SELECT [OBJECT_NAME],COUNTER_NAME,INSTANCE_NAME,CNTR_VALUE 
FROM SYS.DM_OS_PERFORMANCE_COUNTERS
WHERE [OBJECT_NAME] = 'SQLServer:SQL Statistics' AND
      COUNTER_NAME in ('Batch Requests/sec','SQL Compilations/sec','SQL Re-compilations/sec')

--Q: How much CPU time we have used for recompilations (optimizations) of queries.
--A: Following query can help:

-- Total Optimization Performed from last restart
SELECT occurrence AS Optimizations FROM sys.dm_exec_query_optimizer_info
WHERE counter = 'optimizations';
 
-- Avergae elapsed time for Optimziation of main queries
SELECT ISNULL(value,0.0) AS ElapsedTimePerOptimization
FROM sys.dm_exec_query_optimizer_info WHERE counter = 'elapsed time'

-- Query recompilation
select * from sys.dm_exec_query_optimizer_info

--counter          occurrence           value                
------------------ -------------------- --------------------- 
--optimizations    81                   1.0
--elapsed time     81                   6.4547820702944486E-2 --Look at this value

select top 25
    sql_text.text,
    sql_handle,
    plan_generation_num,
    execution_count,
    dbid,
    objectid 
from 
    sys.dm_exec_query_stats a
    cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where 
    plan_generation_num >1
order by plan_generation_num desc

--=====================================================
-- Excessive Query Compilation and Optimization
--=====================================================
-- Q: Excessive Query Compilation and Optimization due to ad hoc query?

-- A: Below query detecs ad hoc queries
select q.query_hash, 
	q.number_of_entries, 
	t.text as sample_query, 
	p.query_plan as sample_plan
from (select top 20 query_hash, 
			count(*) as number_of_entries, 
			min(sql_handle) as sample_sql_handle, 
			min(plan_handle) as sample_plan_handle
		from sys.dm_exec_query_stats
		group by query_hash
		having count(*) > 1
		order by count(*) desc) as q
	cross apply sys.dm_exec_sql_text(q.sample_sql_handle) as t
	cross apply sys.dm_exec_query_plan(q.sample_plan_handle) as p
go

-- You can use the query_hash and query_plan_hash values together to determine whether a set of ad hoc queries with the same query_hash value resulted in query plans with the same or different query_plan_hash values, or access path
select q.query_hash, 
	q.number_of_entries, 
	q.distinct_plans,
	t.text as sample_query, 
	p.query_plan as sample_plan
from (select top 20 query_hash, 
			count(*) as number_of_entries, 
			count(distinct query_plan_hash) as distinct_plans,
			min(sql_handle) as sample_sql_handle, 
			min(plan_handle) as sample_plan_handle
		from sys.dm_exec_query_stats
		group by query_hash
		having count(*) > 1
		order by count(*) desc) as q
	cross apply sys.dm_exec_sql_text(q.sample_sql_handle) as t
	cross apply sys.dm_exec_query_plan(q.sample_plan_handle) as p
go

--=====================================================================================
-- Inefficiant query plan
--=====================================================================================
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

--=====================================================================================
-- Intraquery Parallelism
--=====================================================================================
select 
    r.session_id,
    r.request_id,
    max(isnull(exec_context_id, 0)) as number_of_workers,
    r.sql_handle,
    r.statement_start_offset,
    r.statement_end_offset,
    r.plan_handle
from 
    sys.dm_exec_requests r
    join sys.dm_os_tasks t on r.session_id = t.session_id
    join sys.dm_exec_sessions s on r.session_id = s.session_id
where 
    s.is_user_process = 0x1
group by 
    r.session_id, r.request_id, 
    r.sql_handle, r.plan_handle, 
    r.statement_start_offset, r.statement_end_offset
having max(isnull(exec_context_id, 0)) > 0


--
-- Find query plans that can run in parallel
-- Testing is due so i am comenting it
--
--select 
--    p.*, 
--    q.*,
--    cp.plan_handle
--from 
--    sys.dm_exec_cached_plans cp
--    cross apply sys.dm_exec_query_plan(cp.plan_handle) p
--    cross apply sys.dm_exec_sql_text(cp.plan_handle) as q
--where 
--    cp.cacheobjtype = 'Compiled Plan' and
--    p.query_plan.value('declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
--        max(//p:RelOp/@Parallel)', 'float') > 0

select 
    qs.sql_handle, 
    qs.statement_start_offset, 
    qs.statement_end_offset, 
    q.dbid,
    q.objectid,
    q.number,
    q.encrypted,
    q.text
from 
    sys.dm_exec_query_stats qs
    cross apply sys.dm_exec_sql_text(qs.plan_handle) as q
where 
    qs.total_worker_time > qs.total_elapsed_time

--=====================================================================================
-- Poor Cursor Usage
--=====================================================================================
select 
    cur.* 
from 
    sys.dm_exec_connections con
    cross apply sys.dm_exec_cursors(con.session_id) as cur
where
    cur.fetch_buffer_size = 1 
    and cur.properties LIKE 'API%'	-- API cursor (Transact-SQL cursors  always have a fetch buffer of 1)

--=====================================================================================
-- Most expensive query in terms of CPU
--=====================================================================================
--Q: Which queries are taking the most CPU time

--The following query gives you a high-level view of which currently cached batches or procedures are using the most CPU. 
--The query aggregates the CPU consumed by all statements with the same plan_handle (meaning that they are part of the same 
--batch or procedure). If a given plan_handle has more than one statement, you may have to drill in further to find the specific 
--query that is the largest contributor to the overall CPU usage. 

SELECT TOP 20 total_worker_time / execution_count AS AvgCPU ,
	total_worker_time AS TotalCPU ,
	total_elapsed_time / execution_count AS AvgDuration ,
	total_elapsed_time AS TotalDuration ,
	total_logical_reads / execution_count AS AvgReads ,
	total_logical_reads AS TotalReads ,
	execution_count ,
	qs.creation_time AS plan_creation_time,
	qs.last_execution_time,
	SUBSTRING(st.text, ( qs.statement_start_offset / 2 ) + 1, ( ( CASE qs.statement_end_offset
		WHEN -1 THEN DATALENGTH(st.text)
		ELSE qs.statement_end_offset
		END - qs.statement_start_offset ) / 2 ) + 1) AS QueryText, 
		query_plan
    FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
	/* Sorting options - uncomment the one you'd like to use: */
    --ORDER BY TotalReads DESC;
    ORDER BY TotalCPU DESC;
    --ORDER BY TotalDuration DESC;
    --ORDER BY execution_count DESC;
GO




--==============================================================================
-- Server Current CPU Activity 
--==============================================================================
SELECT es.session_id
    ,es.program_name
    ,es.login_name
    ,es.nt_user_name
    ,es.login_time
    ,es.host_name
    ,es.cpu_time
    ,es.total_scheduled_time
    ,es.total_elapsed_time
    ,es.memory_usage
    ,es.logical_reads
    ,es.reads
    ,es.writes
    ,st.text
FROM sys.dm_exec_sessions es
    LEFT JOIN sys.dm_exec_connections ec 
        ON es.session_id = ec.session_id
    LEFT JOIN sys.dm_exec_requests er
        ON es.session_id = er.session_id
    OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) st
WHERE es.session_id > 50    -- < 50 system sessions
ORDER BY es.cpu_time DESC

--====================================================================
-- Last 4 hours of CPU activity
--====================================================================
DECLARE @ts_now BIGINT
	SELECT @ts_now = cpu_ticks / CONVERT(FLOAT, cpu_ticks) FROM sys.dm_os_sys_info --cpu_ticks_in_ms in case of sql server 2005
	SELECT record_id,
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS EventTime, 
		SQLProcessUtilization,
		SystemIdle,
		100 - SystemIdle - SQLProcessUtilization AS OtherProcessUtilization
	FROM (
		SELECT 
			record.value('(./Record/@id)[1]', 'int') AS record_id,
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization,
			TIMESTAMP
		FROM (
			SELECT TIMESTAMP, CONVERT(XML, record) AS record 
			FROM sys.dm_os_ring_buffers 
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
			AND record LIKE '% %') AS x
		) AS y 
	ORDER BY record_id DESC

