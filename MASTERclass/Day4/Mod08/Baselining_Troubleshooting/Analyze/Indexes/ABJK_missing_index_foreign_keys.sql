SELECT fk.name AS CONSTRAINT_NAME ,
s.name AS SCHEMA_NAME ,
o.name AS TABLE_NAME ,
fkc_c.name AS CONSTRAINT_COLUMN_NAME
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc
ON fk.object_id = fkc.constraint_object_id
JOIN sys.columns AS fkc_c
ON fkc.parent_object_id = fkc_c.object_id
AND fkc.parent_column_id = fkc_c.column_id
LEFT JOIN sys.index_columns ic
JOIN sys.columns AS c ON ic.object_id = c.object_id
AND ic.column_id = c.column_id
ON fkc.parent_object_id = ic.object_id
AND fkc.parent_column_id = ic.column_id
JOIN sys.objects AS o ON o.object_id = fk.parent_object_id
JOIN sys.schemas AS s ON o.schema_id = s.schema_id
WHERE c.name IS NULL