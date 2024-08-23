-------------------------------------------------------------------------
-- Troubleshooting Memory
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--– Query to find the Buffer Pool usage per each Database 
--– Each of these pages are present in the Buffer Cache, meaning they are IN_RAM pages.
-------------------------------------------------------------------------
DECLARE @total_buffer INT; 
SELECT @total_buffer = cntr_value 
   FROM sys.dm_os_performance_counters 
   WHERE RTRIM([object_name]) LIKE'%Buffer Manager' 
   AND counter_name = 'Total Pages';

;WITH BufCount AS 
( 
  SELECT 
       database_id, db_buffer_pages = COUNT_BIG(*) 
       FROM sys.dm_os_buffer_descriptors 
       WHERE database_id BETWEEN 5 AND 32766 
       GROUP BY database_id 
) 
SELECT 
   [Database_Name] = CASE [database_id] WHEN 32767 
       THEN 'MSSQL System Resource DB'
       ELSE DB_NAME([database_id]) END, 
   [Database_ID], 
   db_buffer_pages as [Buffer Count (8KB Pages)], 
   [Buffer Size (MB)] = db_buffer_pages / 128, 
   [Buffer Size (%)] = CONVERT(DECIMAL(6,3), 
       db_buffer_pages * 100.0 / @total_buffer) 
FROM BufCount 
ORDER BY [Buffer Size (MB)] DESC; 

-------------------------------------------------------------------------
-- Query to identify objects that are taking up most of that memory in Buffer Pool.
-- This is only for the current database context. Please prefix <USE DBNAME> as per your requirement
-------------------------------------------------------------------------
SELECT TOP 25 
 DB_NAME(bd.database_id) as DBNAME,
 obj.[name] as [Object Name],
 sysobj.type_desc as [Object Type],
 i.[name]   as [Index Name],
 i.[type_desc] as [Index Type],
 count(*)AS Buffered_Page_Count ,
 count(*) * 8192 / (1024 * 1024) as Buffer_MB,
 bd.page_type as [Page Type] -- ,obj.name ,obj.index_id, i.[name]
FROM sys.dm_os_buffer_descriptors AS bd 
    INNER JOIN 
    (
        SELECT object_name(object_id) AS name 
            ,index_id ,allocation_unit_id, object_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND (au.type = 1 OR au.type = 3)
        UNION ALL
        SELECT object_name(object_id) AS name   
            ,index_id, allocation_unit_id, object_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND au.type = 2
    ) AS obj 
        ON bd.allocation_unit_id = obj.allocation_unit_id
LEFT JOIN sys.indexes i on i.object_id = obj.object_id AND i.index_id = obj.index_id
LEFT JOIN sys.objects sysobj on i.object_id = sysobj.object_id
WHERE database_id = DB_ID()
and sysobj.type not in ('S','IT')
GROUP BY DB_NAME(bd.database_id), obj.name, obj.index_id , i.[name],i.[type_desc],bd.page_type,sysobj.type_desc
ORDER BY Buffered_Page_Count DESC

-------------------------------------------------------------------------
-- Query to show current memory requests, grants and execution plan for each active session
-- This shows memory granted & requested for currently active sessions on the instance level
-- This can be used in a script to capture information over a period of time.
-------------------------------------------------------------------------
SELECT mg.session_id, mg.requested_memory_kb, mg.granted_memory_kb, mg.used_memory_kb, t.text, qp.query_plan 
FROM sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
ORDER BY 1 DESC OPTION (MAXDOP 1)

-------------------------------------------------------------------------
-- Query to search plan cache for queries with memory grants completed
-------------------------------------------------------------------------
SELECT top 50 t.text, cp.objtype ,qp.query_plan, cp.usecounts, cp.size_in_bytes as [Bytes Used in Cache]
FROM sys.dm_exec_cached_plans AS cp
JOIN sys.dm_exec_query_stats AS qs ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS t
WHERE qp.query_plan.exist('declare namespace n="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; //n:MemoryFractions') = 1
order by cp.size_in_bytes desc
OPTION (MAXDOP 1)

-------------------------------------------------------------------------
-- Queries that have requested memory or waiting for memory to be granted
-------------------------------------------------------------------------
SELECT  DB_NAME(st.dbid) AS [DatabaseName] ,
        mg.requested_memory_kb ,
        mg.ideal_memory_kb ,
        mg.request_time ,
        mg.grant_time ,
        mg.query_cost ,
        mg.dop ,
        st.[text]
FROM    sys.dm_exec_query_memory_grants AS mg
        CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE   mg.request_time < COALESCE(grant_time, '99991231')
ORDER BY mg.requested_memory_kb DESC ;

-------------------------------------------------------------------------
-- Top clerks ordered by memory used
-------------------------------------------------------------------------
SELECT TOP(20) [type] as [Memory Clerk Name], SUM(pages_kb) AS [SPA Memory (KB)],
SUM(pages_kb)/1024 AS [SPA Memory (MB)]
FROM sys.dm_os_memory_clerks
GROUP BY [type]
ORDER BY SUM(pages_kb) DESC;

---------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Bpool statistics
-------------------------------------------------------------------------
select
(cast(committed_kb as bigint) * 8192) /(1024*1024)  as bpool_committed_mb,
(cast(committed_target_kb as bigint) * 8192) / (1024*1024) as bpool_target_mb,
(cast(visible_target_kb as bigint)* 8192) / (1024*1024) as bpool_visible_mb
from sys.dm_os_sys_info
go
 
-------------------------------------------------------------------------
-- Get me physical RAM installed and size of user VAS
-------------------------------------------------------------------------
select physical_memory_kb/(1024) as phys_mem_mb,
virtual_memory_kb/(1024) as user_virtual_address_space_size
from sys.dm_os_sys_info
go

-------------------------------------------------------------------------
-- System memory information
-------------------------------------------------------------------------
select total_physical_memory_kb/(1024) as phys_mem_mb,
available_physical_memory_kb/(1024) as avail_phys_mem_mb,
system_cache_kb/(1024) as sys_cache_mb,
(kernel_paged_pool_kb+kernel_nonpaged_pool_kb)/(1024) as kernel_pool_mb,
total_page_file_kb/(1024) as total_virtual_memory_mb,
available_page_file_kb/(1024) as available_virtual_memory_mb,
system_memory_state_desc
from sys.dm_os_sys_memory
go

------------------------------------------------------------------------- 
-- Memory utilized by SQLSERVR process GetMemoryProcessInfo() API used for this
-------------------------------------------------------------------------
select physical_memory_in_use_kb/(1024) as sql_physmem_inuse_mb,
locked_page_allocations_kb/(1024) as awe_memory_mb,
total_virtual_address_space_kb/(1024) as max_vas_mb,
virtual_address_space_committed_kb/(1024) as sql_committed_mb,
memory_utilization_percentage as working_set_percentage,
virtual_address_space_available_kb/(1024) as vas_available_mb,
process_physical_memory_low as is_there_external_pressure,
process_virtual_memory_low as is_there_vas_pressure
from sys.dm_os_process_memory
go

-------------------------------------------------------------------------
-- Reosurce monitor ringbuffer
-------------------------------------------------------------------------
select * from sys.dm_os_ring_buffers
where ring_buffer_type like 'RING_BUFFER_RESOURCE%'
go

-------------------------------------------------------------------------
-- Memory in each node
-------------------------------------------------------------------------
select memory_node_id as node, virtual_address_space_reserved_kb/(1024) as VAS_reserved_mb,
virtual_address_space_committed_kb/(1024) as virtual_committed_mb,
locked_page_allocations_kb/(1024) as locked_pages_mb,
pages_kb/(1024) as pages_mb,
--multi_pages_kb/(1024) as multi_pages_mb,
shared_memory_committed_kb/(1024) as shared_memory_mb
from sys.dm_os_memory_nodes
where memory_node_id != 64
go

-------------------------------------------------------------------------
-- Vas summary
-------------------------------------------------------------------------
with vasummary(Size,reserved,free) as ( select size = vadump.size,
reserved = SUM(case(convert(int, vadump.base) ^ 0)  when 0 then 0 else 1 end),
free = SUM(case(convert(int, vadump.base) ^ 0x0) when 0 then 1 else 0 end)
from
(select CONVERT(varbinary, sum(region_size_in_bytes)) as size,
region_allocation_base_address as base
from sys.dm_os_virtual_address_dump
where region_allocation_base_address <> 0x0
group by region_allocation_base_address
UNION(
select CONVERT(varbinary, region_size_in_bytes),
region_allocation_base_address
from sys.dm_os_virtual_address_dump
where region_allocation_base_address = 0x0)
)
as vadump
group by size)
select * from vasummary
go

-------------------------------------------------------------------------
-- Clerks that are consuming memory
-------------------------------------------------------------------------
select * from sys.dm_os_memory_clerks
where (pages_kb > 0) 
or (virtual_memory_committed_kb > 0)
go

-------------------------------------------------------------------------
-- Get me stolen pages
-------------------------------------------------------------------------
select (SUM(pages_kb)*1024)/8192 as total_stolen_pages
from sys.dm_os_memory_clerks
go

-------------------------------------------------------------------------
-- Breakdown clerks with stolen pages
-------------------------------------------------------------------------
select type, name, sum((pages_kb*1024)/8192) as stolen_pages
from sys.dm_os_memory_clerks
where pages_kb > 0
group by type, name
order by stolen_pages desc
go

-------------------------------------------------------------------------
-- Will not work in SQL Server 2012
-------------------------------------------------------------------------
---- Non-Bpool allocation from SQL Server clerks
 
--select SUM(multi_pages_kb)/1024 as total_multi_pages_mb
--from sys.dm_os_memory_clerks
--go
-- Who are Non-Bpool consumers
--
--select type, name, sum(multi_pages_kb)/1024 as multi_pages_mb
--from sys.dm_os_memory_clerks
--where multi_pages_kb > 0
--group by type, name
--order by multi_pages_mb desc
--go

-------------------------------------------------------------------------
-- Let's now get the total consumption of virtual allocator
-------------------------------------------------------------------------
select SUM(virtual_memory_committed_kb)/1024 as total_virtual_mem_mb
from sys.dm_os_memory_clerks
go

-------------------------------------------------------------------------
-- Breakdown the clerks who use virtual allocator
-------------------------------------------------------------------------
select type, name, sum(virtual_memory_committed_kb)/1024 as virtual_mem_mb
from sys.dm_os_memory_clerks
where virtual_memory_committed_kb > 0
group by type, name
order by virtual_mem_mb desc
go

-------------------------------------------------------------------------
-- memory allocated by AWE allocator API'S
-------------------------------------------------------------------------
select SUM(awe_allocated_kb)/1024 as total_awe_allocated_mb
from sys.dm_os_memory_clerks
go

-------------------------------------------------------------------------
-- Who clerks consumes memory using AWE
-------------------------------------------------------------------------
select type, name, sum(awe_allocated_kb)/1024 as awe_allocated_mb
from sys.dm_os_memory_clerks
where awe_allocated_kb > 0
group by type, name
order by awe_allocated_mb desc
go

-------------------------------------------------------------------------
-- What is the total memory used by the clerks?
-------------------------------------------------------------------------
select (sum(pages_kb)+
SUM(virtual_memory_committed_kb)+
SUM(awe_allocated_kb))/1024
from sys.dm_os_memory_clerks
go

-------------------------------------------------------------------------
-- Does this sync up with what the node thinks?
-------------------------------------------------------------------------
select SUM(virtual_address_space_committed_kb)/1024 as total_node_virtual_memory_mb,
SUM(locked_page_allocations_kb)/1024 as total_awe_memory_mb,
SUM(pages_kb)/1024 as total_single_pages_mb
--SUM(multi_pages_kb)/1024 as total_multi_pages_mb
from sys.dm_os_memory_nodes
where memory_node_id != 64
go

-------------------------------------------------------------------------
-- Will not work in SQL Server 2012
-------------------------------------------------------------------------
-- Total memory used by SQL Server through SQLOS memory nodes
-- including DAC node
-- What takes up the rest of the space?
--select (SUM(virtual_address_space_committed_kb)+
--SUM(locked_page_allocations_kb)+
----SUM(multi_pages_kb))/1024 as total_sql_memusage_mb
--from sys.dm_os_memory_nodes
--go
--
-- Who are the biggest cache stores?
--select name, type, (SUM(pages_kb)+SUM(multi_pages_kb))/1024
--as cache_size_mb
--from sys.dm_os_memory_cache_counters
--where type like 'CACHESTORE%'
--group by name, type
--order by cache_size_mb desc
--go
--
---- Who are the biggest user stores?
--select name, type, (SUM(pages_kb)+SUM(multi_pages_kb))/1024
--as cache_size_mb
--from sys.dm_os_memory_cache_counters
--where type like 'USERSTORE%'
--group by name, type
--order by cache_size_mb desc
--go
--
---- Who are the biggest object stores?
--select name, type, (SUM(pages_kb)+SUM(multi_pages_kb))/1024
--as cache_size_mb
--from sys.dm_os_memory_clerks
--where type like 'OBJECTSTORE%'
--group by name, type
--order by cache_size_mb desc
--go
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Which object is really consuming from clerk
-------------------------------------------------------------------------
select * from sys.dm_os_memory_clerks a
,sys.dm_os_memory_objects b
where a.page_allocator_address = b.page_allocator_address
--group by a.type, b.type
order by a.type, b.type
go

-------------------------------------------------------------------------
-- To get the list of 3rd party DLL loaded inside SQL server memory
-------------------------------------------------------------------------
select * from sys.dm_os_loaded_modules where company <> 'Microsoft Corporation'
go

-------------------------------------------------------------------------
-- Which database page is in my memory
-------------------------------------------------------------------------
select db_name(database_id),(cast(count(*) as bigint)*8192)/1024/1024 as "size in mb" from sys.dm_os_buffer_descriptors
group by db_name(database_id)

----------------------------------------------------------------------------------
-- SQL Server 2008 and R2 Memory Related Queries

-- Instance Level queries

-- Good basic information about memory amounts and state (SQL 2008 and 2008 R2)
SELECT total_physical_memory_kb, available_physical_memory_kb, 
       total_page_file_kb, available_page_file_kb, 
       system_memory_state_desc
FROM sys.dm_os_sys_memory;

-- You want to see "Available physical memory is high"


-- SQL Server Process Address space info (SQL 2008 and 2008 R2)
--(shows whether locked pages is enabled, among other things)
SELECT physical_memory_in_use_kb,locked_page_allocations_kb, 
       page_fault_count, memory_utilization_percentage, 
       available_commit_limit_kb, process_physical_memory_low, 
       process_virtual_memory_low
FROM sys.dm_os_process_memory;

-- You want to see 0 for process_physical_memory_low
-- You want to see 0 for process_virtual_memory_low


-- Page Life Expectancy (PLE) value for default instance (SQL 2005, 2008 and 2008 R2)
SELECT cntr_value AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters
WHERE OBJECT_NAME = N'SQLServer:Buffer Manager' -- Modify this if you have named instances
AND counter_name = N'Page life expectancy';

-- PLE is a good measurement of memory pressure.
-- Higher PLE is better. Below 300 is generally bad.
-- Watch the trend, not the absolute value.


-- Get total buffer usage by database for current instance (SQL 2005, 2008 and 2008 R2)
-- Note: This is a fairly expensive query
SELECT DB_NAME(database_id) AS [Database Name],
COUNT(*) * 8/1024.0 AS [Cached Size (MB)]
FROM sys.dm_os_buffer_descriptors
WHERE database_id > 4 -- system databases
AND database_id <> 32767 -- ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC;

-- Helps determine which databases are using the most memory on an instance


-- Memory Clerk Usage for instance
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
-- (SQL 2005, 2008 and 2008 R2)
SELECT TOP(20) [type], [name], SUM(pages_kb) AS [SPA Mem, Kb] 
FROM sys.dm_os_memory_clerks 
GROUP BY [type], [name]  
ORDER BY SUM(pages_kb) DESC;

-- CACHESTORE_SQLCP  SQL Plans         These are cached SQL statements or batches that aren't in 
--                                     stored procedures, functions and triggers
-- CACHESTORE_OBJCP  Object Plans      These are compiled plans for stored procedures, 
--                                     functions and triggers
-- CACHESTORE_PHDR   Algebrizer Trees  An algebrizer tree is the parsed SQL text that 
--                                     resolves the table and column names


-- Find single-use, ad-hoc queries that are bloating the plan cache
SELECT TOP(100) [text], cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
WHERE cp.cacheobjtype = N'Compiled Plan' 
AND cp.objtype = N'Adhoc' 
AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC;

-- Gives you the text and size of single-use ad-hoc queries that waste space in the plan cache
-- Enabling 'optimize for ad hoc workloads' for the instance can help (SQL Server 2008 and 2008 R2 only)
-- Enabling forced parameterization for the database can help, but test first!


-- Database level queries (switch to your database)
--USE YourDatabaseName;
--GO

-- Breaks down buffers used by current database by object (table, index) in the buffer cache
-- (SQL 2008 and 2008 R2) Note: This is a fairly expensive query
SELECT OBJECT_NAME(p.[object_id]) AS [ObjectName], 
p.index_id, COUNT(*)/128 AS [Buffer size(MB)],  COUNT(*) AS [BufferCount], 
p.data_compression_desc AS [CompressionType]
FROM sys.allocation_units AS a
INNER JOIN sys.dm_os_buffer_descriptors AS b
ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p
ON a.container_id = p.hobt_id
WHERE b.database_id = CONVERT(int,DB_ID())
AND p.[object_id] > 100
GROUP BY p.[object_id], p.index_id, p.data_compression_desc
ORDER BY [BufferCount] DESC;


-- Top Cached SPs By Total Logical Reads (SQL 2008 and 2008 R2). Logical reads relate to memory pressure
SELECT TOP(25) p.name AS [SP Name], qs.total_logical_reads AS [TotalLogicalReads], 
qs.total_logical_reads/qs.execution_count AS [AvgLogicalReads],qs.execution_count, 
ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, GETDATE()), 0) AS [Calls/Second], 
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count 
AS [avg_elapsed_time], qs.cached_time
FROM sys.procedures AS p
INNER JOIN sys.dm_exec_procedure_stats AS qs
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY qs.total_logical_reads DESC;

-- This helps you find the most expensive cached stored procedures from a memory perspective
-- You should look at this if you see signs of memory pressure