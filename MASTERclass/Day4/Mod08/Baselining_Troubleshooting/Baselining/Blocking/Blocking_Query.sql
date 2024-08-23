	IF OBJECT_ID('baseline..Blocking') IS NULL
BEGIN
	
	CREATE TABLE [dbo].[Blocking]
(
	[collection_id] [bigint] NOT NULL,
	[collection_time] [DateTime] NOT NULL,
	[session_id] [smallint] NULL,
	[host_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[original_login_name] [nvarchar](128) NOT NULL,
	[reads] [bigint] NULL,
	[writes] [bigint] NULL,
	[cpu_time] [int] NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_time] [int] NULL,
	[wait_resource] [nvarchar](256) NULL,
	[blocking_session_id] [smallint] NULL,
	[text] [nvarchar](max) NULL
) ON [PRIMARY]
	
	--DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR); 

	INSERT Blocking WITH (TABLOCK)
	SELECT 1,GETDATE(),
	er.session_id ,
host_name , program_name , original_login_name , er.reads ,
er.writes ,er.cpu_time , wait_type , wait_time , wait_resource ,
blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE blocking_session_id > 0
UNION
SELECT es.session_id , host_name , program_name , original_login_name ,
es.reads , es.writes , es.cpu_time , wait_type , wait_time ,
wait_resource , blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE es.session_id IN ( SELECT blocking_session_id
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0 )
END
ELSE
BEGIN
	INSERT Blocking WITH (TABLOCK)
	SELECT (select ISNULL (max(Blocking.collection_id),0)+1 from Blocking),GETDATE(),
	er.session_id ,
host_name , program_name , original_login_name , er.reads ,
er.writes ,er.cpu_time , wait_type , wait_time , wait_resource ,
blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE blocking_session_id > 0
UNION
SELECT es.session_id , host_name , program_name , original_login_name ,
es.reads , es.writes , es.cpu_time , wait_type , wait_time ,
wait_resource , blocking_session_id , st.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er
ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE es.session_id IN ( SELECT blocking_session_id
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0 )
END
