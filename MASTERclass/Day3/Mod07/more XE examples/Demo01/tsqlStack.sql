SELECT
	event_id,
	level,
	handle,
	line,
	DB_NAME(sqlText.dbid) AS DBName,
	OBJECT_NAME(sqlText.objectid, sqlText.dbid) AS objName,
	SUBSTRING(sqlText.text, (offset_start / 2) + 1,
		((CASE offset_end
			WHEN -1 THEN DATALENGTH(sqlText.text)
			ELSE offset_end
			END - offset_start) / 2) + 1) AS sqlStatement
FROM
(
	SELECT
		event_id,
		frame.value('(@level)[1]', 'int') AS [level],
		frame.value('xs:hexBinary(substring((@handle)[1],3))', 'varbinary(max)') AS [handle],
		frame.value('(@line)[1]', 'int') AS [line],
		frame.value('(@offsetStart)[1]', 'int') AS [offset_start],
		frame.value('(@offsetEnd)[1]', 'int') AS [offset_end]
	FROM
	(
		SELECT 
			ROW_NUMBER() OVER (ORDER BY XEvent.value('(event/@timestamp)[1]', 'datetime2')) AS event_id,
			XEvent.query('(action[@name="tsql_stack"]/value/frames)[1]') AS tsqlStack
		FROM
		(
			SELECT CAST(target_data AS XML) AS TrgtData
			FROM sys.dm_xe_session_targets xst
			JOIN sys.dm_xe_sessions xs
				ON xs.address = xst.event_session_address
			WHERE name = N'Demo01'
				AND target_name = N'ring_buffer'
		) AS Data
		CROSS APPLY TrgtData.nodes ('RingBufferTarget/event') AS XEventData(XEvent)
	) AS tab1
	CROSS APPLY tsqlStack.nodes ('(frames/frame)') AS stack(frame)
) AS tab2
CROSS APPLY sys.dm_exec_sql_text(handle) AS sqlText