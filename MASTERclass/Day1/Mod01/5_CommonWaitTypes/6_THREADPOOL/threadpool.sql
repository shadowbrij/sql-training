select * from sys.dm_os_waiting_tasks
where wait_type like '%thread%'

select count(*) from sys.dm_os_threads
select count (*) from sys.dm_os_workers


-- Stop Workload
USE [master];
GO

ALTER DATABASE [AdventureWorks2014] SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE [AdventureWorks2014] SET MULTI_USER
WITH ROLLBACK IMMEDIATE;
GO