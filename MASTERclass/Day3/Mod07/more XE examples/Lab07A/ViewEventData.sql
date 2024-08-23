SELECT 
    slot.value('(value)[1]', 'NVARCHAR(100)') AS ClientAppName,
    slot.value('(@count)[1]', 'int') AS WaitCount
FROM
(
	 SELECT CAST(target_data AS XML) target_data
	 FROM sys.dm_xe_sessions AS s 
	 INNER JOIN sys.dm_xe_session_targets AS t
		 ON s.address = t.event_session_address
	 WHERE s.name = N'Lab07A'
	 AND t.target_name = N'histogram' 
 ) AS xData
CROSS APPLY target_data.nodes('HistogramTarget/Slot') AS x(slot);
GO