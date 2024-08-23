select status from sys.dm_exec_sessions
where session_id = 64

select * from sys.dm_exec_sessions
where session_id = 64

select * from sys.dm_os_tasks
where session_id = 64

select * from sys.dm_os_threads

select state from sys.dm_os_workers osw
inner join sys.dm_os_tasks ost
on ost.task_address = osw.task_address
where ost.session_id = 64

where session_id = 64

