--clear wait stats
DBCC SQLPERF("sys.dm_os_wait_stats", CLEAR)


--check wait stats
SELECT wait_type,
	waiting_tasks_count,
	wait_time_ms 
FROM sys.dm_os_wait_stats
WHERE wait_type IN ('PAGELATCH_SH', 'PAGELATCH_UP', 'PAGELATCH_EX')
