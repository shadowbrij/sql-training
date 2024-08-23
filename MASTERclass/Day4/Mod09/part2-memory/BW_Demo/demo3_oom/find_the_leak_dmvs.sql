select type, sum(pages_in_bytes)/1024/1024 as total_MB from sys.dm_os_memory_objects 
group by type
order by total_MB desc
go

select  * from sys.dm_os_memory_objects
where type like '%cursor%'

select * from sys.dm_os_memory_clerks
order by pages_kb desc

--select * from sys.dm_os_memory_clerks
--where type like '%cur%'
