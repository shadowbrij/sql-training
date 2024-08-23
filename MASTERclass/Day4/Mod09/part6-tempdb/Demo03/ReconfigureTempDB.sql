use tempdb
go

--Add 7 data files to tempdb
DECLARE @path NVARCHAR(100), @filepath NVARCHAR(100), @size NVARCHAR(10), @cmd NVARCHAR(400)
SELECT TOP 1 @path = REVERSE(SUBSTRING(REVERSE(physical_name), CHARINDEX('\',REVERSE(physical_name),1), LEN(physical_name) - CHARINDEX('\',REVERSE(physical_name),1) + 1)),
	@size = CAST(size * 8 AS NVARCHAR(10)) 
FROM sys.master_files
WHERE database_id = 2
AND type_desc = 'ROWS'

DBCC SHRINKFILE(tempdev,1)

DECLARE @i INT = 2
WHILE (@i <= 8)
BEGIN
	SET @filepath = @path + 'tempdev' + CAST(@i AS NVARCHAR(2))

	SET @cmd = 'ALTER DATABASE tempdb
	ADD FILE (name = ''tempdev' + CAST(@i AS NVARCHAR(2)) + ''', filename = ''' + @filepath + ''', size = ' + @size + ' KB )'
	EXEC sp_executesql @cmd
	SET @i = @i + 1

END


/*
--cleanup
DBCC SHRINKFILE(tempdev2,EMPTYFILE)
DBCC SHRINKFILE(tempdev3,EMPTYFILE)
DBCC SHRINKFILE(tempdev4,EMPTYFILE)
DBCC SHRINKFILE(tempdev5,EMPTYFILE)
DBCC SHRINKFILE(tempdev6,EMPTYFILE)
DBCC SHRINKFILE(tempdev7,EMPTYFILE)
DBCC SHRINKFILE(tempdev8,EMPTYFILE)

ALTER DATABASE tempdb
REMOVE FILE tempdev2
ALTER DATABASE tempdb
REMOVE FILE tempdev3
ALTER DATABASE tempdb
REMOVE FILE tempdev4
ALTER DATABASE tempdb
REMOVE FILE tempdev5
ALTER DATABASE tempdb
REMOVE FILE tempdev6
ALTER DATABASE tempdb
REMOVE FILE tempdev7
ALTER DATABASE tempdb
REMOVE FILE tempdev8
*/