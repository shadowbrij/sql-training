-- dropping the original table
DROP TABLE person.contact2


-- Check the physical stattistics of the index


DBCC FREEPROCCACHE


-- review the indexes on the table
EXEC sp_helpindex [person.contact2]
go

-- SET STATISTICS IO ON


-- check the physical stats

SELECT OBJECT_NAME(object_id),* 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('dbo.table2')
	, NULL
	, NULL
	, 'SAMPLED');
go