--Cleanup
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'Lab07A')
    DROP EVENT SESSION [Lab07A] ON SERVER
GO

--mapkey value for NETWORK_IO wait type
DECLARE @waitType INT,
		@SessionCMD NVARCHAR(4000)

SELECT @waitType =  map_key 
FROM sys.dm_xe_map_values
WHERE map_value = N'NETWORK_IO'
	AND name = N'wait_types'

SET @SessionCMD = 'CREATE EVENT SESSION [Lab07A] ON SERVER

ADD EVENT sqlos.wait_info
(
	ACTION(sqlos.scheduler_id, sqlserver.client_app_name)
	WHERE
		(opcode = 1
		 AND duration > 0 AND (wait_type = ' + CAST(@waitType AS NVARCHAR(5)) + ')
		)
)

ADD TARGET [package0].histogram
(
    SET filtering_event_name = ''sqlos.wait_info'',
		source_type = 1,
		source = ''sqlserver.client_app_name''
)'

EXEC sp_executesql @SessionCMD
GO


GO

--start the extended event session
ALTER EVENT SESSION [Lab07A] ON SERVER STATE = START;
GO