--View Lab07B1 Event Data
SELECT 
    DB_NAME(slot.value('(value)[1]', 'int')) AS DBName,
    slot.value('(@count)[1]', 'int') AS RecompileCount,
    slot.value('(@trunc)[1]', 'int') AS RecompileTrunc
FROM
(
	 SELECT CAST(target_data AS XML) target_data
	 FROM sys.dm_xe_sessions AS s 
	 INNER JOIN sys.dm_xe_session_targets AS t
		 ON s.address = t.event_session_address
	 WHERE s.name = N'Lab07B1'
	 AND t.target_name = N'histogram' 
 ) AS xData
CROSS APPLY target_data.nodes('HistogramTarget/Slot') AS x(slot);
GO


--View Lab07B2 Event Data
SELECT 
    OBJECT_NAME(slot.value('(value)[1]', 'int'), DB_ID('AdventureWorks2014')) AS ObjName,
    slot.value('(@count)[1]', 'int') AS RecompileCount,
    slot.value('(@trunc)[1]', 'int') AS RecompileTrunc
FROM
(
	 SELECT CAST(target_data AS XML) target_data
	 FROM sys.dm_xe_sessions AS s 
	 INNER JOIN sys.dm_xe_session_targets AS t
		 ON s.address = t.event_session_address
	 WHERE s.name = N'Lab07B2'
	 AND t.target_name = N'histogram' 
 ) AS xData
CROSS APPLY target_data.nodes('HistogramTarget/Slot') AS x(slot);
GO