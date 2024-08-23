--Collect initial stats
SELECT DB_NAME(ivfs.[database_id]) AS [DBName],
	   af.[name] AS [FileName],
	   af.[filename] AS [PhysicalFileName],
	   [num_of_reads], 
	   [io_stall_read_ms],
       [num_of_writes], 
	   [io_stall_write_ms], 
	   [io_stall],
       [num_of_bytes_read], 
	   [num_of_bytes_written]
INTO ##IOStats1
FROM sys.dm_io_virtual_file_stats (DB_ID('AdventureWorks2014'), NULL) AS ivfs
INNER JOIN sys.sysaltfiles AS af
	ON ivfs.database_id = af.dbid
	AND ivfs.file_id = af.fileid

--Run the read workload

--Collect final stats
SELECT DB_NAME(ivfs.[database_id]) AS [DBName],
	   af.[name] AS [FileName],
	   af.[filename] AS [PhysicalFileName],
	   [num_of_reads], 
	   [io_stall_read_ms],
       [num_of_writes], 
	   [io_stall_write_ms], 
	   [io_stall],
       [num_of_bytes_read], 
	   [num_of_bytes_written]
INTO ##IOStats2
FROM sys.dm_io_virtual_file_stats (DB_ID('AdventureWorks2014'), NULL) AS ivfs
INNER JOIN sys.sysaltfiles AS af
	ON ivfs.[database_id] = af.[dbid]
	AND ivfs.[file_id] = af.[fileid]

--Check the latency and throughput
SELECT IO1.DBName,
	   IO1.[FileName],
	   IO1.[PhysicalFileName],
	   IO2.[num_of_reads] - IO1.[num_of_reads] AS [reads],
	   CASE WHEN IO2.[num_of_reads] - IO1.[num_of_reads] = 0
		   THEN 0
		   ELSE (IO2.[io_stall_read_ms] - IO1.[io_stall_read_ms])/(IO2.[num_of_reads] - IO1.[num_of_reads]) 
		   END AS [read_latency],
	   IO2.[num_of_writes] - IO1.[num_of_writes] AS [writes],
	   CASE WHEN IO2.[num_of_writes] - IO1.[num_of_writes] = 0
		   THEN 0
		   ELSE (IO2.[io_stall_write_ms] - IO1.[io_stall_write_ms])/(IO2.[num_of_writes] - IO1.[num_of_writes]) 
		   END AS [write_latency],
	   CASE WHEN IO2.[num_of_writes] - IO1.[num_of_writes] = 0
		   THEN 0
		   ELSE (IO2.[num_of_bytes_read] - IO1.[num_of_bytes_read])/(IO2.[num_of_writes] - IO1.[num_of_writes]) 
		   END AS [Avg_BytesPerRead],
	   CASE WHEN IO2.[num_of_writes] - IO1.[num_of_writes] = 0
		   THEN 0
		   ELSE (IO2.[num_of_bytes_written] - IO1.[num_of_bytes_written])/(IO2.[num_of_writes] - IO1.[num_of_writes]) 
		   END AS [Avg_BytesPerWrites]
FROM ##IOStats1 IO1
INNER JOIN ##IOStats2 IO2
	ON IO1.DBName = IO2.DBName
	AND IO1.[FileName] = IO2.[FileName]