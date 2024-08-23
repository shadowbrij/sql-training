--script 1
-- Let us consider an example to show how DMVs can be used 
-- to identify missing indexes. Assume we have a table t_sample 
-- that has five columns. We first load 1,000 rows into this 
-- table followed by creating two indexes; one clustererd index 
-- on column c1 and a nonclustered index on columnn c4. 
-- Here is the script:

CREATE TABLE t_sample (c1 int, c2 int, c3 int, c4 int, c5 char(5000))
GO
-- insert the data and create the indexes
DECLARE @i int;
SELECT @i = 0;
WHILE (@i < 1000)
BEGIN
  INSERT INTO t_sample
       VALUES (@i, @i + 1000, @i+2000, @i+3000, 'hello');
  SET @i = @i + 1;
END;


--script 2
-- create the indexes
CREATE CLUSTERED INDEX t_sample_ci ON t_sample(c1);
CREATE NONCLUSTERED INDEX t_sample_nci_c4 ON t_sample(c4);


--script 3
-- Now, we run multiple selects in a loop as follows:
DECLARE @i int;
SELECT @i = 0;
WHILE (@i < 100)
  BEGIN
    SELECT SUM(c1 + c2 + c3) FROM t_sample
      WHERE c1 BETWEEN @i AND @i+50;
    SELECT SUM(c2) FROM t_sample 
      WHERE c2 BETWEEN @i+1000 AND @i + 1100;
    SELECT SUM(c3) FROM t_sample
      WHERE c3 BETWEEN @i +2000 AND @i+2400;
    SET @i = @i + 1;
  END  ;


----script 4
-- Here is a DMV query that you can execute to identify the 
-- missing indexes and their usefulness:

SELECT t1.object_id, t2.user_seeks, t2.user_scans,
       t1.equality_columns, t1.inequality_columns
FROM sys.dm_db_missing_index_details AS t1,
     sys.dm_db_missing_index_group_stats AS t2,
     sys.dm_db_missing_index_groups AS t3
WHERE database_id = DB_ID()
     AND object_id = OBJECT_ID('t_sample')
     AND t1.index_handle = t3.index_handle
     AND t2.group_handle = t3.index_group_handle;

-- The following DMV query shows the operational statistics on 
-- all the indexes on a table called employee:

SELECT index_id, range_scan_count, 
       row_lock_count, page_lock_count
FROM sys.dm_db_index_operational_stats(DB_ID('<db-name>'),
OBJECT_ID('employee'), NULL, NULL);




--------tshoot2k8


--script 5
--The following DMV query can be used to obtain useful information about --index usage for all objects in all databases.

select object_id, index_id, user_seeks, user_scans, user_lookups 
from sys.dm_db_index_usage_stats 
order by object_id, index_id


--script 6
--To get information about the indexes of a specific table that has not --been used since the last start of SQL Server, this query can be executed --in the context of the database that owns the object.

select i.name
from sys.indexes i 
where i.object_id=object_id('<table_name>') and
    i.index_id NOT IN  (select s.index_id 
                        from sys.dm_db_index_usage_stats s 
                        where s.object_id=i.object_id and 	
                        i.index_id=s.index_id and
                        database_id = <dbid> )


--script 7
--All indexes that haven’t been used yet can be retrieved with the --following statement.

select object_name(object_id), i.name 
from sys.indexes i 
where  i.index_id NOT IN (select s.index_id 
                          from sys.dm_db_index_usage_stats s 
                          where s.object_id=i.object_id and 
                          i.index_id=s.index_id and 
                          database_id = <dbid> )
order by object_name(object_id) asc



--- waitsstatsqueues


-- Potentially Useful Indexes
select d.*
        , s.avg_total_user_cost
        , s.avg_user_impact
        , s.last_user_seek
        ,s.unique_compiles
from sys.dm_db_missing_index_group_stats s
        ,sys.dm_db_missing_index_groups g
        ,sys.dm_db_missing_index_details d
where s.group_handle = g.index_group_handle
and d.index_handle = g.index_handle
order by s.avg_user_impact desc
go
--- suggested index columns and usage
declare @handle int

select @handle = d.index_handle
from sys.dm_db_missing_index_group_stats s
        ,sys.dm_db_missing_index_groups g
        ,sys.dm_db_missing_index_details d
where s.group_handle = g.index_group_handle
and d.index_handle = g.index_handle

select * 
from sys.dm_db_missing_index_columns(@handle)
order by column_id

