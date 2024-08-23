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




--script 3.1
-- custom


declare @dbid int
select @dbid = db_id()
declare @objectid int
select @objectid = OBJECT_ID('HumanResources.Department')

select * from sys.dm_db_index_operational_stats (@dbid, @objectid, NULL, NULL)



--script 3.2
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
