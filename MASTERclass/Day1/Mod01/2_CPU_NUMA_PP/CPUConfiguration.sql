-- View CPU configuration
SELECT * FROM sys.configurations 
WHERE name IN
	('affinity mask',
	'affinity64 mask',
	'cost threshold for parallelism',
	'lightweight pooling',
	'max degree of parallelism',
	'max worker threads',
	'priority boost')
ORDER BY name;
GO

-- View HyperThreading configuration
SELECT	cpu_count, hyperthread_ratio
FROM sys.dm_os_sys_info;
GO

-- View Schedulers
SELECT	* FROM sys.dm_os_schedulers
WHERE status LIKE 'VISIBLE ONLINE%';