-- Listing 1: Query to Identify Missing Indexes

select a.avg_user_impact * a.avg_total_user_cost * a.user_seeks, db_name(c.database_id), 
	OBJECT_NAME(c.object_id, c.database_id), c.equality_columns, c.inequality_columns, c.included_columns, c.statement,
	'USE [' + DB_NAME(c.database_id) + ']; 
	CREATE INDEX idx_' + replace(replace(replace(replace(ISNULL(equality_columns, '') + ISNULL(c.inequality_columns, ''), ', ', '_'), '[', ''), ']', ''), ' ', '') + ' ON [' + schema_name(d.schema_id) + '].[' + OBJECT_NAME(c.object_id, c.database_id) + ']
	(' + ISNULL(equality_columns, '') + CASE WHEN c.equality_columns IS NOT NULL AND c.inequality_columns IS NOT NULL THEN ', ' ELSE '' END + ISNULL(c.inequality_columns, '') + ')
	' + CASE WHEN included_columns IS NOT NULL THEN 'INCLUDE (' + included_columns + ')' ELSE '' END + '
	WITH (FILLFACTOR=70, ONLINE=ON)'
from sys.dm_db_missing_index_group_stats a
join sys.dm_db_missing_index_groups b on a.group_handle = b.index_group_handle 
join sys.dm_db_missing_index_details c on b.index_handle = c.index_handle 
join sys.objects d on c.object_id = d.object_id
where c.database_id = db_id()
order by DB_NAME(c.database_id), ISNULL(equality_columns, '') + ISNULL(c.inequality_columns, ''),
a.avg_user_impact * a.avg_total_user_cost * a.user_seeks desc
