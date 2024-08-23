----script 1
-- To identify queries/batches that are being recompiled frequently, 
-- you can, of course, use SQL Profiler to get this information. 
-- However, it is not a preferred option for reasons we explained
-- earlier. In SQL Server 2005, you can use DMVs to find the 
-- top-ten query plans that have been recompiled the most.

SELECT TOP 10 plan_generation_num, execution_count,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
      (CASE WHEN statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max),text)) * 2
            ELSE statement_end_offset
       END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM sys.dm_exec_query_stats
WHERE plan_generation_num >1
ORDER BY plan_generation_num DESC;



---waitsstatsqueues


--script 2
--- DMV reports statements with lowest plan reuse
---
SELECT TOP 50
        qs.sql_handle
        ,qs.plan_handle
        ,cp.cacheobjtype
        ,cp.usecounts
        ,cp.size_in_bytes  
        ,qs.statement_start_offset
        ,qs.statement_end_offset
        ,qt.dbid
        ,qt.objectid
        ,qt.text
        ,SUBSTRING(qt.text,qs.statement_start_offset/2, 
             (case when qs.statement_end_offset = -1 
            then len(convert(nvarchar(max), qt.text)) * 2 
            else qs.statement_end_offset end -qs.statement_start_offset)/2) 
        as statement
FROM sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
inner join sys.dm_exec_cached_plans as cp on qs.plan_handle=cp.plan_handle
where cp.plan_handle=qs.plan_handle
and qt.dbid = db_id()    ----- put the database ID here
ORDER BY [Usecounts] ASC




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

-- Free the AD Hoc plans
DBCC FREESYSTEMCACHE('SQL Plans')

-- Query Memory / Workspace memory

USE AdventureWorks2008
GO
SELECT HireDate,LoginID
FROM HumanResources.Employee
ORDER BY HireDate

SELECT  SUM(multi_pages_kb + virtual_memory_committed_kb 
            + shared_memory_committed_kb  
            + awe_allocated_kb) AS [Used by BPool, Kb]
FROM sys.dm_os_memory_clerks
where [type] = 'MEMORYCLERK_SQLQERESERVATIONS'


-- ABJK
--This query will list the top ten statements
--based on the average number of physical reads that the statements performed as a part
--of their execution.


SELECT TOP 10
execution_count ,
statement_start_offset AS stmt_start_offset ,
sql_handle ,
plan_handle ,
total_logical_reads / execution_count AS avg_logical_reads ,
total_logical_writes / execution_count AS avg_logical_writes ,
total_physical_reads / execution_count AS avg_physical_reads ,
t.text
FROM sys.dm_exec_query_stats AS s
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS t
ORDER BY avg_physical_reads DESC