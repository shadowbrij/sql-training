USE AdventureWorks2014
GO

--Cleanup
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'Demo01')
    DROP EVENT SESSION [Demo01] ON SERVER
GO

-- Create Extended Event
DECLARE @objid BIGINT,
		@SessionCMD NVARCHAR(4000)

SET @objid = OBJECT_ID('Call3')


SET @SessionCMD = 'CREATE EVENT SESSION [Demo01] ON SERVER

ADD EVENT sqlserver.module_start
(
	ACTION(sqlserver.tsql_stack)
	WHERE(object_id = ' + CAST(@objid AS NVARCHAR(20)) + ')
)

ADD TARGET [package0].ring_buffer'

EXEC sp_executesql @SessionCMD
GO


--start the extended event session
ALTER EVENT SESSION [Demo01] ON SERVER STATE = START;
GO