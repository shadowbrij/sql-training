----------------------------------------------------------
-- Demo: Lock Wait Types
-- File: L5_LOCK_wait_types.sql
-- Summary: A quick glance at all the different lock wait types 
----------------------------------------------------------

USE master
GO

SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type like '%LCK%'
GO