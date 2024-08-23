
-------------------------------------
--I/O
-------------------------------------

--script 5
--You can use the following DMV query to find currently pending I/O ----requests. You can execute this query periodically to check the health of --I/O subsystem and to isolate physical disk(s) that are involved in the --I/O bottlenecks.

select 
    DB_Name(database_id) as DB_Name,
	io_pending, 
    file_id, 
    io_stall,
    io_pending_ms_ticks,
    scheduler_address 
from	sys.dm_io_virtual_file_stats(NULL, NULL)t1,
        sys.dm_io_pending_io_requests as t2
where	t1.file_handle = t2.io_handle

--select * from  sys.dm_io_pending_io_requests
--select * from sys.dm_os_schedulers
--select * from sys.dm_exec_requests

select scheduler_id, SUM (pending_disk_io_count) from sys.dm_os_schedulers
where status = 'VISIBLE ONLINE'
group by scheduler_id


select 
      r.session_id,
      s.login_name,
      s.program_name,
      r.start_time,
      r.status,
      r.command,
      r.wait_type,
      r.wait_time,
      r.last_wait_type,
      r.logical_reads,
      (r.logical_reads * 8192) as 'KB Read',
      r.writes,
      (r.writes * 8192) as 'KB Written',
      t.[text]
from sys.dm_exec_requests r
      cross apply sys.dm_exec_sql_text(sql_handle) t
      inner join sys.dm_exec_sessions s
      on r.session_id = s.session_id
      where s.is_user_process = 1 and
      (r.wait_type like 'PAGEIOLATCH%' or r.last_wait_type like 
 'PAGEIOLATCH%') and
      r.session_id != @@SPID


--------------------------------
--wait stats
--------------------------------

------------------
--let us begin by seeing the current waiting tasks
------------------

select * from sys.dm_os_waiting_tasks
where session_id>50
GO


------------------
--ABPSPR - analyzing tasks
------------------

SELECT
	[ot].[scheduler_id],
	[task_state],
	COUNT (*) AS [task_count]
FROM
	sys.dm_os_tasks AS [ot]
INNER JOIN
	sys.dm_exec_requests AS [er]
    ON [ot].[session_id] = [er].[session_id]
INNER JOIN
	sys.dm_exec_sessions AS [es]
    ON [er].[session_id] = [es].[session_id]
WHERE
	[es].[is_user_process] = 1
GROUP BY
	[ot].[scheduler_id],
	[task_state]
ORDER BY
	[task_state],
	[ot].[scheduler_id];
GO

--script 5
--It can also be very useful to perform aggregate queries against this DMV --to fi nd information such as
--the number of tasks for each wait type:


SELECT wait_type,
COUNT(*) AS num_waiting_tasks,
SUM(wait_duration_ms) AS total_wait_time_ms
FROM sys.dm_os_waiting_tasks
WHERE session_id > 50
GROUP BY wait_type
ORDER BY wait_type