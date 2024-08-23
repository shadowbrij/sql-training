-- Extended events benefits

--Events fire synchronously but can be processed synchronously or --asynchronously.
--Any target can consume any event and any action can be paired with any --event, allowing for an in-depth monitoring system.
--"Smart" predicates enable you to build complex rules using Boolean --logic.
--You can have complete control over Extended Events sessions using --Transact-SQL.
--You can monitor performance-critical code without impacting --performance.




-- what is an event?

--a defined point in code. 
--point at which a T-SQL statement finished executing
--the point at which acquiring a lock is completed.
-- 254 events as of 2k8, more to come
-- defined using ETW model

-- eg 1
SELECT xp.[name], xo.*
FROM sys.dm_xe_objects xo, sys.dm_xe_packages xp
WHERE xp.[guid] = xo.[package_guid]
  AND xo.[object_type] = 'event'
ORDER BY xp.[name];

-- eg 2

SELECT * FROM sys.dm_xe_objects
where [object_type] = 'event'
--and name like '%page%'



-- each event has a payload
--Each event has a defined payload (the set of columns that are returned by the event

SELECT * FROM sys.dm_xe_object_columns
  WHERE [object_name] = 'sql_statement_completed';
GO


-- what are predicates?
-- method used to filter events using a set of logical rules before the events are consumed
-- checking that one of the columns returned in the event payload is a certain value (for example, filtering lock-acquired events by object ID).
-- some advanced capabilities,(counting the number of times a specific event has occurred during the session and only allowing the event to be consumed after an occurrence or dynamically updating the predicate itself to suppress the consumption of events containing similar data.
-- can be written using Boolean logic


SELECT xp.[name], xo.*
FROM sys.dm_xe_objects xo, sys.dm_xe_packages xp
WHERE xp.[guid] = xo.[package_guid]
  AND xo.[object_type] = 'pred_compare'
ORDER BY xp.[name];


SELECT xp.[name], xo.*
FROM sys.dm_xe_objects xo, sys.dm_xe_packages xp
WHERE xp.[guid] = xo.[package_guid]
  AND xo.[object_type] = 'pred_source'
ORDER BY xp.[name];


-- what are actions?
-- set of commands that are performed synchronously before an event is consumed.
-- linked to any event. They typically gather more data to append to the event payload (such as a T-SQL stack or a query execution plan) or perform some calculation that is appended to the event payload.
-- some actions

SELECT xp.[name], xo.*
FROM sys.dm_xe_objects xo, sys.dm_xe_packages xp
WHERE xp.[guid] = xo.[package_guid]
  AND xo.[object_type] = 'action'
ORDER BY xp.[name];


-- what are targets?
-- way to consume events
--  any target can consume any event
-- Targets can consume events synchronously (for instance, the code that fired the event waits for the event to be consumed) or asynchronously
-- event files

select * from sys.dm_xe_objects
where object_type = 'target'

SELECT xp.[name], xo.*
FROM sys.dm_xe_objects xo, sys.dm_xe_packages xp
WHERE xp.[guid] = xo.[package_guid]
  AND xo.[object_type] = 'target'
ORDER BY xp.[name];



-- whats a package?
-- a container that defines Extended Events objects (such as events, actions, and targets)
-- A package is contained within the module (such as an executable or a DLL) it describes
-- When a package is registered with the Extended Events engine, all the objects defined by it are then available for use.

select * from sys.dm_xe_packages


--what is a session?
-- a way of linking together Extended Events objects for processing—an event with an action to be consumed by a target. A session can link objects from any registered packages, and any number of sessions can use the same event, action.
-- Sessions are created, dropped, altered, stopped, and started using T-SQL commands

select * from sys.dm_xe_sessions




--system catalogs
select * from sys.server_event_sessions
select * from sys.server_event_session_actions
select * from sys.server_event_session_events
select * from sys.server_event_session_fields
select * from sys.server_event_session_targets


--DMVs
select * from sys.dm_xe_packages
select * from sys.dm_xe_objects -- where name = 'wait_info'
select * from sys.dm_xe_object_columns where object_name = 'page_split';
select * from sys.dm_xe_map_values
select * from sys.dm_xe_sessions
select * from sys.dm_xe_session_targets
select * from sys.dm_xe_session_object_columns
select * from sys.dm_xe_session_events
select * from sys.dm_xe_session_event_actions






SELECT e.package, e.name, e.predicate
FROM sys.server_event_session_events e
JOIN sys.server_event_sessions s ON e.event_session_id = s.event_session_id
WHERE s.name = 'system_health'
AND e.name LIKE 'wait_info%'

-- maps
--Maps provide lookup information for the information that is available inside Extended Events.  Maps provide a key/value pairing for specific types of information that can be used in defining event sessions, and correlating the information captured by event sessions.  An example of a map would be the wait_types, which maps the engine key to logical name for all wait_types that can be fired inside of SQL Server. 


select * from sys.dm_xe_objects
where object_type IN ('TYPE', 'MAP');

select * from sys.dm_xe_map_values
where name like '%duration%'

SELECT name, map_key, map_value
FROM sys.dm_xe_map_values
WHERE name = 'wait_types'
AND ( (map_key < 22)
OR (map_key > 31 AND map_key < 38)
OR (map_key > 47 AND map_key < 54)
OR (map_key > 63 AND map_key < 70)
OR (map_key > 96 AND map_key < 100)
OR (map_key > 174 AND map_key < 177)
OR (map_key > 185 AND map_key < 188)
OR map_key = 107 OR map_key = 113
OR map_key = 120 OR map_key = 178
OR map_key = 186 OR map_key = 202
OR map_key = 207 OR map_key = 269
OR map_key = 283 OR map_key = 284)



SELECT map_key, map_value
FROM sys.dm_xe_map_values
WHERE name = 'wait_types'
AND map_value IN
('WRITELOG', 'PAGEIOLATCH_SH',
'PAGEIOLATCH_EX', 'CXPACKET',
'SOS_SCHEDULER_YIELD',
'ASYNC_IO_COMPLETION','LCK_M_S')


CREATE EVENT SESSION [track_wait_stats2]
ON SERVER
ADD EVENT sqlos.wait_info
(
ACTION
(
sqlserver.database_id,
sqlserver.client_app_name,
sqlserver.sql_text
)
WHERE
(
duration > 5000 AND
(wait_type = 3 OR wait_type = 66 OR wait_type = 68
OR wait_type = 98 OR wait_type = 120
OR wait_type = 178 OR wait_type = 187)
)
)
ADD TARGET package0.asynchronous_file_target
( SET filename = 'C:\Amit\track_wait_stats.xel',
metadatafile = 'C:\Amit\track_wait_stats.mta',
max_file_size = 10,
max_rollover_files = 10)



ALTER EVENT SESSION [track_wait_stats2]
ON SERVER
STATE=START



DECLARE @filename varchar(128) = 'C:\Amit\track_wait_stats_0_129594373747000000.xel'
DECLARE @metafilename varchar(128) = 'C:\Amit\track_wait_stats_0_129594373747000000.mta'

IF OBJECT_ID('tempdb..#File_Data') IS NOT NULL
DROP TABLE #File_Data

SELECT CONVERT(xml, event_data) as event_data
INTO #File_Data
FROM sys.fn_xe_file_target_read_file(@filename, @metafilename, NULL, NULL)



SELECT wait_type,
DB_name(database_id) as DBNAME,
SUM(duration) AS total_duration,
SUM(signal_duration) as signal_duration
FROM
(
SELECT
event_data.value('(event/data[1]/text)[1]', 'VARCHAR(100)') AS wait_type,
event_data.value('(event/action[1]/value)[1]', 'VARCHAR(100)')
AS database_id,
event_data.value('(event/data[3]/value)[1]', 'int') AS duration,
event_data.value('(event/data[6]/value)[1]', 'int') AS signal_duration
FROM #File_Data
) as tab
GROUP BY wait_type, database_id
ORDER BY database_id, total_duration desc


select * from #File_Data

ALTER EVENT SESSION [track_wait_stats2]
ON SERVER
STATE=STOP