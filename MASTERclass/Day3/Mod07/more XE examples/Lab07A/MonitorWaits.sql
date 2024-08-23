SELECT er.session_id, 
	er.wait_time,
	er.last_wait_type, 
	es.program_name
FROM sys.dm_exec_requests er
INNER JOIN sys.dm_exec_sessions es
	ON er.session_id = es.session_id
WHERE es.program_name = 'SQLCMD'