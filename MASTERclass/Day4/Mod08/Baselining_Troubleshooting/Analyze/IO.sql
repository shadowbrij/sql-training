--script 1
-- Similarly, it will be useful if you have files from different 
-- file groups share the same physical disk and you want to know
-- if object(s) mapped to a particular file are the reason of I/O 
-- bottleneck. Using this information, you can choose to remap 
-- your objects to different physical disks to minimize I/O latency.

-- Here is the DMV query that can be used to identify such file(s). 
-- The two columns io_stall_read_ms and io_stall_write_ms 
-- represent the time SQL Server waited for Reads and Writes 
-- issued on the file since the start of SQL Server. 
-- To get meaningful data, you will need to snapshot these numbers
-- for small duration and then compare it to compare these numbers
-- with baseline numbers. If you see that there are significant 
-- differences, it will need to be analyzed.

SELECT database_id, file_id, io_stall_read_ms, io_stall_write_ms
FROM sys.dm_io_virtual_file_stats(NULL, NULL);


--script 2
-- The following DMV query can be used to find 
-- I/O latch wait statistics:

SELECT wait_type, waiting_tasks_count, wait_time_ms, signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGEIOLATCH%'
ORDER BY wait_type;



--script 3
-- The following DMV query returns the top-ten queries/batches 
-- that are  generating the most I/Os.You can also use a 
-- variation of this query to find the top-ten queries that do 
-- the most I/Os per execution.

SELECT TOP 10
 (total_logical_reads/execution_count) AS avg_logical_reads,
 (total_logical_writes/execution_count) AS avg_logical_writes,
 (total_physical_reads/execution_count) AS avg_phys_reads,
  execution_count,plan_handle, 
  (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
    (CASE WHEN statement_end_offset = -1
          THEN LEN(CONVERT(nvarchar(MAX),text)) * 2
          ELSE statement_end_offset
     END - statement_start_offset)/2)
   FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM sys.dm_exec_query_stats
ORDER BY (total_logical_reads + total_logical_writes) DESC;







---tshoot2k8

--script 4

Select  wait_type, 
        waiting_tasks_count, 
        wait_time_ms
from	sys.dm_os_wait_stats  
where	wait_type like 'PAGEIOLATCH%'  
order by wait_type



--script 5
--You can use the following DMV query to find currently pending I/O --requests. You can execute this query periodically to check the health of --I/O subsystem and to isolate physical disk(s) that are involved in the --I/O bottlenecks.

select 
    database_id, 
    file_id, 
    io_stall,
    io_pending_ms_ticks,
    scheduler_address 
from	sys.dm_io_virtual_file_stats(NULL, NULL)t1,
        sys.dm_io_pending_io_requests as t2
where	t1.file_handle = t2.io_handle


--script 6
--use the following DMV query to examine the queries that generate the most --I/Os 

SELECT TOP 5 
    (total_logical_reads/execution_count) AS avg_logical_reads,
    (total_logical_writes/execution_count) AS avg_logical_writes,
    (total_physical_reads/execution_count) AS avg_phys_reads,
    execution_count, 
    statement_start_offset as stmt_start_offset, 
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
        (CASE WHEN statement_end_offset = -1 
            THEN LEN(CONVERT(nvarchar(MAX),text)) * 2 
                ELSE statement_end_offset 
            END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text, 
      (SELECT query_plan from sys.dm_exec_query_plan(plan_handle)) as query_plan
FROM sys.dm_exec_query_stats  
ORDER BY (total_logical_reads + total_logical_writes)/execution_count DESC



----waitstatsqueues

--script 7

select database_id, file_id
    ,io_stall_read_ms
    ,num_of_reads
    ,cast(io_stall_read_ms/(1.0+num_of_reads) as numeric(10,1)) as 'avg_read_stall_ms'
    ,io_stall_write_ms
    ,num_of_writes
    ,cast(io_stall_write_ms/(1.0+num_of_writes) as numeric(10,1)) as 'avg_write_stall_ms'
    ,io_stall_read_ms + io_stall_write_ms as io_stalls
    ,num_of_reads + num_of_writes as total_io
    ,cast((io_stall_read_ms+io_stall_write_ms)/(1.0+num_of_reads + num_of_writes) as numeric(10,1)) as 'avg_io_stall_ms'
from sys.dm_io_virtual_file_stats(null,null)
order by avg_io_stall_ms desc



--script 8
--- top 50 statements by IO
SELECT TOP 50
        (qs.total_logical_reads + qs.total_logical_writes) /qs.execution_count as [Avg IO],
        substring (qt.text,qs.statement_start_offset/2, 
         (case when qs.statement_end_offset = -1 
        then len(convert(nvarchar(max), qt.text)) * 2 
        else qs.statement_end_offset end -    qs.statement_start_offset)/2) 
        as query_text,
    qt.dbid,
    qt.objectid 
FROM sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text (qs.sql_handle) as qt
ORDER BY [Avg IO] DESC


-- the best of all(ABJK)

SELECT  DB_NAME(vfs.database_id) AS database_name ,
        vfs.database_id ,
        vfs.FILE_ID ,
        io_stall_read_ms / NULLIF(num_of_reads, 0) AS avg_read_latency ,
        io_stall_write_ms / NULLIF(num_of_writes, 0)
                                               AS avg_write_latency ,
        io_stall / NULLIF(num_of_reads + num_of_writes, 0)
                                               AS avg_total_latency ,
        num_of_bytes_read / NULLIF(num_of_reads, 0)
                                               AS avg_bytes_per_read ,
        num_of_bytes_written / NULLIF(num_of_writes, 0)
                                               AS avg_bytes_per_write ,
        vfs.io_stall ,
        vfs.num_of_reads ,
        vfs.num_of_bytes_read ,
        vfs.io_stall_read_ms ,
        vfs.num_of_writes ,
        vfs.num_of_bytes_written ,
        vfs.io_stall_write_ms ,
        size_on_disk_bytes / 1024 / 1024. AS size_on_disk_mbytes ,
        physical_name
FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
        JOIN sys.master_files AS mf ON vfs.database_id = mf.database_id
                                       AND vfs.FILE_ID = mf.FILE_ID
ORDER BY avg_total_latency DESC 

