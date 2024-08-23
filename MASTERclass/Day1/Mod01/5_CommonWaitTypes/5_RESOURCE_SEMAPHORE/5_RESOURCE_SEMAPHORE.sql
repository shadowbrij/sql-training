--Look at the waits in sys.dm_os_waiting_tasks
SELECT *
FROM sys.dm_os_waiting_tasks
WHERE 
	wait_type = 'RESOURCE_SEMAPHORE'
GO


--Check out the memory grants DMV to find out what's wrong
SELECT *
FROM sys.dm_exec_query_memory_grants
GO


-- Stop Workload
USE [master];
GO

ALTER DATABASE [AdventureWorks2014] SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE [AdventureWorks2014] SET MULTI_USER
WITH ROLLBACK IMMEDIATE;
GO