SELECT OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName ,
OBJECT_NAME(i.object_id) AS TableName ,
i.name ,
ius.user_seeks ,
ius.user_scans ,
ius.user_lookups ,
ius.user_updates
FROM sys.dm_db_index_usage_stats AS ius
JOIN sys.indexes AS i ON i.index_id = ius.index_id
AND i.object_id = ius.object_id
WHERE ius.database_id = DB_ID()
AND i.is_unique_constraint = 0 -- no unique indexes
AND i.is_primary_key = 0
AND i.is_disabled = 0
AND i.type > 1 -- don't consider heaps/clustered index
AND ( ( ius.user_seeks + ius.user_scans +
ius.user_lookups ) < ius.user_updates
OR ( ius.user_seeks = 0
AND ius.user_scans = 0
)
)
