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


--script 3
-- Here is one example that shows how the above DMV query 
-- can be used to identify a query that is generating the 
-- most allocations and deallocations in the tempdb:

CREATE TABLE t1 (c1 int PRIMARY KEY, c2 int, c3 char(8000));
GO
CREATE TABLE t2 (C4 int, c5 char(8000));
GO
-- load large number of rows into each of the tables
DECLARE @i int;
SELECT @i = 0;
WHILE (@i < 6000)
BEGIN
  INSERT INTO t1 VALUES (@i, @i + 1000, 'hello');
  INSERT INTO t2 VALUES (@i,'there');
  SET @i = @i + 1;
END;
-- Run a query with hash-join in a separate session
SELECT c1, c5
FROM t1 INNER HASH JOIN t2 ON t1.c1 = t2.c4
ORDER BY c2;

-- you can also look at the execution plan
SELECT * FROM sys.dm_exec_query_plan(<plan-handle>)



--script 4
-- You can use the following script to indentify if 
-- temporary objects are being cached or not in a stored 
-- procedure. It shows number of temporary objects created 
-- when you invoke a particular stored procedure ten times.

DECLARE @table_counter_before_test bigint;
SELECT @table_counter_before_test = cntr_value
FROM sys.dm_os_performance_counters 
WHERE counter_name = 'Temp Tables Creation Rate';

DECLARE @i int;
SELECT @i = 0;
WHILE (@i < 10)
BEGIN
  -- <execute your stored procedure>
   SELECT @i = @i+1;
END;

DECLARE @table_counter_after_test bigint;
SELECT @table_counter_after_test = cntr_value
FROM sys.dm_os_performance_counters 
WHERE counter_name = 'Temp Tables Creation Rate';

PRINT 'Temp tables created during the test: ' +
       CONVERT(varchar(100), @table_counter_after_test 
                             - @table_counter_before_test);


--script 5
-- Consider the following example. The stored procedure 
-- test_temptable_caching creates a #table inside it. 
-- We want to check if this temporary table is cached across 
-- multiple invocations using the script described above.

CREATE PROCEDURE test_temptable_caching
AS
CREATE TABLE #t1 (c1 int, c2 int, c3 char(5000))
--  CREATE UNIQUE CLUSTERED INDEX ci_t1 ON #t1(c1);
DECLARE @i int;
SELECT @i = 0;
WHILE (@i < 10)
BEGIN
  INSERT INTO #t1 VALUES (@i, @i + 1000, 'hello');
  SELECT @i = @i+1;
END;
PRINT 'done with the stored proc';
GO



-- tshoot2k8


--script 6
--The following query returns the tempdb space used by user and by internal --objects. Currently, it provides information for tempdb only.

Select
    SUM (user_object_reserved_page_count)*8 as user_objects_kb,
    SUM (internal_object_reserved_page_count)*8 as internal_objects_kb,
    SUM (version_store_reserved_page_count)*8  as version_store_kb,
    SUM (unallocated_extent_page_count)*8 as freespace_kb
From sys.dm_db_file_space_usage
Where database_id = 2


----script 7
--you can run the following script to enumerate all the tempdb objects.

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



--script 8
--You can use the following query to find the top sessions that are ----allocating internal objects. Note that this query includes only the tasks --that have been completed in the sessions.

select 
    session_id, 
    internal_objects_alloc_page_count, 
    internal_objects_dealloc_page_count
from sys.dm_db_session_space_usage
order by internal_objects_alloc_page_count DESC


--script
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



--script 10 
--After you have isolated the task or tasks that are generating a lot of --internal object allocations, you can find out which Transact-SQL ----statement it is and its query plan for a more detailed analysis.

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


--script 11
--You can use the sql_handle and plan_handle columns to get the SQL ----statement and the query plan as follows.

select text from sys.dm_exec_sql_text(@sql_handle)
select * from sys.dm_exec_query_plan(@plan_handle)
