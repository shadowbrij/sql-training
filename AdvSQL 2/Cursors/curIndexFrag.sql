DECLARE @SchemaName varchar(255)
DECLARE @TableName varchar(255)
DECLARE @IndexName varchar(255)
DECLARE @Fragmentation float
DECLARE TableCursor CURSOR FOR
SELECT SCHEMA_NAME(CAST(OBJECTPROPERTYEX(i.object_id, 'SchemaId') AS int)),
OBJECT_NAME(i.object_id),
i.name,
ps.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS ps
JOIN sys.indexes AS i
ON ps.object_id = i.object_id
AND ps.index_id = i.index_id
WHERE avg_fragmentation_in_percent > 30
OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @SchemaName, @TableName, @IndexName,
@Fragmentation
WHILE @@FETCH_STATUS = 0
BEGIN
PRINT @SchemaName + '.' + @TableName + '.' +
@IndexName + ' is ' + CAST(@Fragmentation AS varchar) + '% Fragmentented'
FETCH NEXT FROM TableCursor INTO @SchemaName, @TableName, @IndexName,
@Fragmentation
END
CLOSE TableCursor
DEALLOCATE TableCursor