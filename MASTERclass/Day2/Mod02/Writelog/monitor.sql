DBCC SQLPERF ('sys.dm_os_wait_stats', clear)
go

select * from sys.dm_os_wait_stats
where wait_type = 'writelog'