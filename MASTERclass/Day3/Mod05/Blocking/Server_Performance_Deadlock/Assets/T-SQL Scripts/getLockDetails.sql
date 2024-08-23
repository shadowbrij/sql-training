-- getLockDetails.sql
-- this is a common script used in many demos/labs. This script outputs detailed locking/blocking information

USE AdventureWorks2008R2
GO

SELECT dm_tran_locks.request_session_id, 
       dm_tran_locks.resource_description, 
       dm_tran_locks.request_mode, 
       dm_tran_locks.request_status,
       [Database]=Db_name(dm_tran_locks.resource_database_id), 
       [Object]=CASE 
         WHEN resource_type = 'object' THEN 
         Object_name( 
         dm_tran_locks.resource_associated_entity_id) 
         ELSE Object_name(partitions.object_id) 
       END
FROM   sys.dm_tran_locks 
       LEFT JOIN sys.partitions 
         ON partitions.hobt_id = dm_tran_locks.resource_associated_entity_id 
       JOIN sys.indexes 
         ON indexes.object_id = partitions.object_id 
            AND indexes.index_id = partitions.index_id 
WHERE  resource_associated_entity_id > 0 
ORDER BY dm_tran_locks.request_status