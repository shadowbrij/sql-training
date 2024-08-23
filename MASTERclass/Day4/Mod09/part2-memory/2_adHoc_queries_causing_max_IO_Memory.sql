/**********************************************************
*   top adhoc queries memory consumption total
***********************************************************/
SELECT TOP 100 *
FROM 
(
    SELECT
         plan_handle		= qs.plan_handle
		,DatabaseName       = DB_NAME(qt.dbid)
        ,QueryText          = qt.text       
        ,DiskReads          = SUM(qs.total_physical_reads)   -- The worst reads, disk reads
        ,MemoryReads        = SUM(qs.total_logical_reads)    --Logical Reads are memory reads
        ,Total_IO_Reads     = SUM(qs.total_physical_reads + qs.total_logical_reads)
        ,Executions         = SUM(qs.execution_count)
        ,IO_Per_Execution   = SUM((qs.total_physical_reads + qs.total_logical_reads) / qs.execution_count)
        ,CPUTime            = SUM(qs.total_worker_time)
        ,DiskWaitAndCPUTime = SUM(qs.total_elapsed_time)
        ,MemoryWrites       = SUM(qs.max_logical_writes)
        ,DateLastExecuted   = MAX(qs.last_execution_time)
        
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
    WHERE OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid) IS NULL
    GROUP BY qs.plan_handle,DB_NAME(qt.dbid), qt.text, OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
) T
ORDER BY Total_IO_Reads DESC

-- the culprit query
-- you can see plan by estimating

select tblOrders.*, tblCustomers.*, tblEmployees.* from tblOrders
inner join tblCustomers on tblOrders.custid=tblCustomers.custid
inner join tblEmployees on tblOrders.empid=tblEmployees.empid
where orderdate = '2005-01-12 00:00:00.000'

-- or
-- extracting the plan from the plan cache

select * from sys.dm_exec_query_plan
(0x06001900A086B930804788EF0100000001000000000000000000000000000000000000000000000000000000)