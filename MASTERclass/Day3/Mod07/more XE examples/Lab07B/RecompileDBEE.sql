--Cleanup
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'Lab07B1')
    DROP EVENT SESSION [Lab07B1] ON SERVER
GO

--Create Extended Event Session
DECLARE @state INT,
		@SessionCMD NVARCHAR(4000)

SELECT @state = map_key FROM sys.dm_xe_map_values
WHERE name = 'statement_starting_state'
AND map_value = 'Recompiled'

SET @SessionCMD = 'CREATE EVENT SESSION [Lab07B1] ON SERVER

ADD EVENT sqlserver.sp_statement_starting
(
	ACTION(sqlserver.database_id)
	WHERE(state = ' + CAST(@state AS NVARCHAR(3)) + ')
)
ADD TARGET package0.histogram
(
	SET filtering_event_name = N''sqlserver.sp_statement_starting'',
		source_type = 1, -- Action
		source = N''sqlserver.database_id''
)'

EXEC sp_executesql @SessionCMD
GO
		
--Start the event session
ALTER EVENT SESSION [Lab07B1] ON SERVER STATE = START;
GO