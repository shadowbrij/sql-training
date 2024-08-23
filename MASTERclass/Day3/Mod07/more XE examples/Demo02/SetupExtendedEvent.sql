--Cleanup
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'Demo02')
    DROP EVENT SESSION [Demo02] ON SERVER
GO

--create extended event session
CREATE EVENT SESSION [Demo02] ON SERVER

ADD EVENT sqlserver.sp_statement_starting
(
	ACTION(sqlserver.session_id, 
		   sqlserver.tsql_stack, 
		   sqlserver.sql_text, 
		   sqlserver.plan_handle)
	WHERE(state = 0)
),
ADD EVENT sqlserver.sp_statement_completed
(
	ACTION(sqlserver.session_id, 
		   sqlserver.tsql_stack)
)

ADD TARGET [package0].pair_matching
(
    SET begin_event = 'sqlserver.sp_statement_starting',
		begin_matching_actions = 'sqlserver.session_id, sqlserver.tsql_stack',
		end_event = 'sqlserver.sp_statement_completed',
		end_matching_actions = 'sqlserver.session_id, sqlserver.tsql_stack',
		respond_to_memory_pressure = 0
)
GO

--start the extended event session
ALTER EVENT SESSION [Demo02] ON SERVER STATE = START;
GO