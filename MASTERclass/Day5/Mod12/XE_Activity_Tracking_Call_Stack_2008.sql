-- create the SP
use AdventureWorks2008
go


create proc XEProc
as
select * from Person.Person

select * from Production.Product

select * from HumanResources.Department
go


CREATE EVENT SESSION [Test2] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([duration]>(5000) AND [package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.error_reported(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(7)) AND [sqlserver].[session_id]>(50))) 
ADD TARGET package0.ring_buffer(SET max_memory=(10240))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

-- start the session

ALTER EVENT SESSION Test2
ON SERVER
STATE = START
GO


-- blocking scenario with SPs

-- connection 1

use AdventureWorks2008
go

begin tran
update Production.Product
set ListPrice = 10
where ProductID = 1
-- rollback

-- connection 2

use AdventureWorks2008
go

exec XEProc
go

-- this connection
--DROP TABLE #EventXML
--Pull the event XML into a temp table
SELECT
	CONVERT(xml, target_data) AS x
INTO #EventXML
FROM sys.dm_xe_session_targets st
JOIN sys.dm_xe_sessions s ON 
	s.address = st.event_session_address
WHERE
	s.name = 'Test2'

SELECT *
FROM #EventXML
GO

DROP TABLE #Events
--Shred the XML
SELECT
	node.value('./@name', 'varchar(4000)') AS event_name,
	CASE 
		WHEN node.value('./@name', 'varchar(4000)') = 'sp_statement_completed' THEN node.value('(./action)[5]', 'varchar(50)')
		ELSE  node.value('(./action)[5]', 'varchar(50)')
	END AS activity_id,
	CASE node.value('./@name', 'varchar(4000)')
		WHEN 'error_reported' THEN node.value('(./data)[5]', 'varchar(4000)')
		ELSE NULL
	END AS message,
	CASE 
		WHEN node.value('./@name', 'varchar(4000)') IN ('sp_statement_starting','sp_statement_completed', 'error_reported') THEN node.value('(./action)[4]', 'varchar(4000)')
		ELSE NULL
	END AS tsql_stack
INTO #Events
FROM #EventXML
CROSS APPLY #EventXML.x.nodes('//event') n (node)

SELECT *
FROM #Events
GO


--DROP TABLE #ConvertedEvents
--Pull out and convert the activity_id
SELECT
	event_name,
	CONVERT(uniqueidentifier, LEFT(activity_id, 36)) AS activity_guid,
	CONVERT(int, RIGHT(activity_id, LEN(activity_id) - 37)) AS activity_sequence,
	message,
	tsql_stack
INTO #ConvertedEvents
FROM #Events

SELECT *
FROM #ConvertedEvents
GO



-- DROP TABLE #ConvertedEvents_Count
--Which sequences include an error w/ message LIKE 'error_' ?
SELECT
	*,
	COUNT
	(
		CASE 
			WHEN event_name LIKE 'error_' THEN event_name 
			ELSE NULL 
		END
	) OVER 
		(
			PARTITION BY activity_guid
		) AS c
INTO #ConvertedEvents_Count
FROM #ConvertedEvents

SELECT *
FROM #ConvertedEvents_Count
GO

-- DROP TABLE #Event_Stack
--For all of the sequences we care about, convert the stack to XML
SELECT
	*,
	CONVERT(xml, tsql_stack) as stack
INTO #Event_Stack
FROM #ConvertedEvents_Count
--WHERE 
--	c > 0

SELECT *
FROM #Event_Stack
GO


--Get the SQL handles
SELECT 
	#Event_Stack.*,
	CONVERT(varbinary(1000), frame.node.value('@handle', 'varchar(1000)'), 1) AS handle,
	frame.node.value('@offsetStart', 'int') AS offsetstart,
	frame.node.value('@offsetEnd', 'int') AS offsetend
INTO #Handles
FROM #Event_Stack
OUTER APPLY #Event_Stack.stack.nodes('(/frame)[1]') frame (node)

SELECT *
FROM #Handles
GO


--For each handle, grab the SQL text!
--...and we're done!
SELECT
	SUBSTRING(t.text, (offsetstart/2) + 1, ((offsetend - offsetstart)/2) + 1) AS statement_text,
	#Handles.*	
FROM #Handles
OUTER APPLY sys.dm_exec_sql_text(#Handles.handle) t
ORDER BY 
	activity_guid, 
	activity_sequence
GO


SELECT
	t.text AS statement_text,
	#Handles.*	
FROM #Handles
OUTER APPLY sys.dm_exec_sql_text(#Handles.handle) t
ORDER BY 
	activity_guid, 
	activity_sequence
GO


--Clean up
DROP PROC OccasionalError
GO

DROP EVENT SESSION sql_text_and_errors
ON SERVER
GO