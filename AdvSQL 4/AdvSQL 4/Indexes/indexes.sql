USE ADVENTUREWORKS 
GO
SELECT CAST(DB_NAME(database_id) AS varchar(20)) AS [Database Name],
CAST(OBJECT_NAME(object_id) AS varchar(20)) AS [TABLE NAME], index_id, index_type_desc, avg_fragmentation_in_percent,
avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID('AdventureWorks'),
NULL,NULL,NULL,'Detailed')


sp_helpindex 'sales'

select * from sys.index_columns where object_id =object_id('sales')

select * from sys.dm_db_index_physical_stats(DB_ID('practice'),object_id('sales'),null,null,null)