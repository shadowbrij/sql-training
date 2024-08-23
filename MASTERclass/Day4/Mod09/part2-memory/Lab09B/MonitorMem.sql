SELECT [type], 
	SUM(pages_in_bytes)/1024/1024 AS current_total_MB, SUM(max_pages_in_bytes)/1024/1024 AS max_total_MB 
FROM sys.dm_os_memory_objects 
GROUP BY [type]
ORDER BY current_total_MB DESC
GO


SELECT * FROM sys.dm_os_memory_clerks
ORDER BY pages_kb DESC