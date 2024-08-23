--restart the event session
ALTER EVENT SESSION [system_health] ON SERVER STATE = STOP;
GO

ALTER EVENT SESSION [system_health] ON SERVER STATE = START;
GO

--Get deadlock data
SELECT 
    Nodes.query('(data[@name="xml_report"]/value/deadlock)[1]')AS deadlock
FROM    (SELECT CAST([target_data] AS XML) AS TgtData
         FROM sys.dm_xe_session_targets AS xst
         INNER JOIN sys.dm_xe_sessions AS xs 
            ON [xs].[address] = [xst].[event_session_address]
         WHERE [xs].[name] = N'system_health'
           AND [xst].[target_name] = N'ring_buffer') AS Data
CROSS APPLY TgtData.nodes ('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XData (Nodes);