---ABPSPR---
------------------





-- this does it all...(ABJK)

SELECT TOP 10
        wait_type ,
        max_wait_time_ms wait_time_ms ,
        signal_wait_time_ms ,
        wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms ,
        CASE WHEN wait_time_ms = 0 THEN 0 ELSE 100.0 * wait_time_ms / SUM(wait_time_ms) OVER ( ) END
                                    AS percent_total_waits ,
        CASE WHEN signal_wait_time_ms = 0 THEN 0 ELSE 100.0 * signal_wait_time_ms / SUM(signal_wait_time_ms) OVER ( ) END
                                    AS percent_total_signal_waits ,
        CASE WHEN wait_time_ms = 0 THEN 0 ELSE 100.0 * ( wait_time_ms - signal_wait_time_ms )
        / SUM(wait_time_ms) OVER ( ) END AS percent_total_resource_waits
FROM    sys.dm_os_wait_stats
WHERE   wait_time_ms > 0 -- remove zero wait_time
        AND wait_type NOT IN -- filter out additional irrelevant waits
( 'SLEEP_TASK', 'BROKER_TASK_STOP', 'BROKER_TO_FLUSH',
  'SQLTRACE_BUFFER_FLUSH','CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT', 
  'LAZYWRITER_SLEEP', 'SLEEP_SYSTEMTASK', 'SLEEP_BPOOL_FLUSH',
  'BROKER_EVENTHANDLER', 'XE_DISPATCHER_WAIT', 'FT_IFTSHC_MUTEX',
  'CHECKPOINT_QUEUE', 'FT_IFTS_SCHEDULER_IDLE_WAIT', 
  'BROKER_TRANSMITTER', 'FT_IFTSHC_MUTEX', 'KSOURCE_WAKEUP',
  'LAZYWRITER_SLEEP', 'LOGMGR_QUEUE', 'ONDEMAND_TASK_QUEUE',
  'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BAD_PAGE_PROCESS',
  'DBMIRROR_EVENTS_QUEUE', 'BROKER_RECEIVE_WAITFOR',
  'PREEMPTIVE_OS_GETPROCADDRESS', 'PREEMPTIVE_OS_AUTHENTICATIONOPS',
  'WAITFOR', 'DISPATCHER_QUEUE_SEMAPHORE', 'XE_DISPATCHER_JOIN',
  'RESOURCE_QUEUE' )
ORDER BY wait_time_ms DESC



--script 1

-- The following DMV query shows the top-ten waits encountered 
-- in your application:

SELECT TOP 10 wait_type, waiting_tasks_count AS tasks, 
              wait_time_ms, max_wait_time_ms AS max_wait,
              signal_wait_time_ms AS signal
FROM sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC;




------------------------------------------
-- ABIBG-TSQLquery
------------------------------------------

--- step 1 - analyze waits at the instance level
-- see all the waits, but you need to filter in the next step
SELECT
  wait_type,
  waiting_tasks_count,
  wait_time_ms,
  max_wait_time_ms,
  signal_wait_time_ms
FROM sys.dm_os_wait_stats
ORDER BY wait_type;

--------------------------------------------------
-- in case you want to clear DMV stats
--DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
--------------------------------------------------

-- -- Isolate top waits constituting 90%

WITH Waits AS
(
  SELECT
    wait_type,
    wait_time_ms / 1000. AS wait_time_s,
    100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
    ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
  FROM sys.dm_os_wait_stats
  WHERE wait_type NOT LIKE '%SLEEP%'
  -- filter out additional irrelevant waits
)
SELECT
  W1.wait_type, 
  CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
  CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
  CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
  JOIN Waits AS W2
    ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 90 OR W1.rn <= 15 -- percentage threshold
ORDER BY W1.rn;
GO

--- you can use this instead of the above query

SELECT TOP 10
        wait_type ,
        max_wait_time_ms wait_time_ms ,
        signal_wait_time_ms ,
        wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms ,
        CASE WHEN wait_time_ms = 0 THEN 0 ELSE 100.0 * wait_time_ms / SUM(wait_time_ms) OVER ( ) END
                                    AS percent_total_waits ,
        CASE WHEN signal_wait_time_ms = 0 THEN 0 ELSE 100.0 * signal_wait_time_ms / SUM(signal_wait_time_ms) OVER ( ) END
                                    AS percent_total_signal_waits ,
        CASE WHEN wait_time_ms = 0 THEN 0 ELSE 100.0 * ( wait_time_ms - signal_wait_time_ms )
        / SUM(wait_time_ms) OVER ( ) END AS percent_total_resource_waits
FROM    sys.dm_os_wait_stats
WHERE   wait_time_ms > 0 -- remove zero wait_time
        AND wait_type NOT IN -- filter out additional irrelevant waits
( 'SLEEP_TASK', 'BROKER_TASK_STOP', 'BROKER_TO_FLUSH',
  'SQLTRACE_BUFFER_FLUSH','CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT', 
  'LAZYWRITER_SLEEP', 'SLEEP_SYSTEMTASK', 'SLEEP_BPOOL_FLUSH',
  'BROKER_EVENTHANDLER', 'XE_DISPATCHER_WAIT', 'FT_IFTSHC_MUTEX',
  'CHECKPOINT_QUEUE', 'FT_IFTS_SCHEDULER_IDLE_WAIT', 
  'BROKER_TRANSMITTER', 'FT_IFTSHC_MUTEX', 'KSOURCE_WAKEUP',
  'LAZYWRITER_SLEEP', 'LOGMGR_QUEUE', 'ONDEMAND_TASK_QUEUE',
  'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BAD_PAGE_PROCESS',
  'DBMIRROR_EVENTS_QUEUE', 'BROKER_RECEIVE_WAITFOR',
  'PREEMPTIVE_OS_GETPROCADDRESS', 'PREEMPTIVE_OS_AUTHENTICATIONOPS',
  'WAITFOR', 'DISPATCHER_QUEUE_SEMAPHORE', 'XE_DISPATCHER_JOIN',
  'RESOURCE_QUEUE' )
ORDER BY wait_time_ms DESC


------------------------------------------------------------




--script 2
---- ebintperftshoot
--a temporary table and a WAITFOR DELAY can be used to track the changes --over a period of time to determine what waits are currently occurring:


IF OBJECT_ID(‘tempdb..#wait_stats’) IS NOT NULL
DROP TABLE #wait_stats

SELECT *
INTO #wait_stats
FROM sys.dm_os_wait_stats

WAITFOR DELAY ‘00:00:05’

SELECT ws1.wait_type,
ws2.waiting_tasks_count - ws1.waiting_tasks_count
AS waiting_tasks_count,
ws2.wait_time_ms - ws1.wait_time_ms AS wait_time_ms,
CASE WHEN ws2.max_wait_time_ms > ws1.max_wait_time_ms
THEN ws2.max_wait_time_ms
ELSE ws1.max_wait_time_ms
END AS max_wait_time_ms,
ws2.signal_wait_time_ms - ws1.signal_wait_time_ms
AS signal_wait_time_ms,
(ws2.wait_time_ms - ws1.wait_time_ms) - (ws2.signal_wait_time_ms -
ws1.signal_wait_time_ms) AS resource_wait_time_ms
FROM sys.dm_os_wait_stats AS ws2
JOIN #wait_stats AS ws1 ON ws1.wait_type = ws2.wait_type
WHERE ws2.wait_time_ms - ws1.wait_time_ms > 0
ORDER BY ws2.wait_time_ms - ws1.wait_time_ms DESC



--script 3
--it can be helpful to look at the percentage of total wait time that each --contributes, as shown in the following example. A high percentage of ----signal --waits can be a sign of CPU pressure or the need for faster --CPUs --on the --server.


SELECT SUM(signal_wait_time_ms) AS total_signal_wait_time_ms,
SUM(wait_time_ms - signal_wait_time_ms) AS resource_wait_time_ms,
SUM(signal_wait_time_ms) * 1.0 / SUM (wait_time_ms) * 100
AS signal_wait_percent,
SUM(wait_time_ms - signal_wait_time_ms) * 1.0 / SUM (wait_time_ms) * 100
AS resource_wait_percent
FROM sys.dm_os_wait_stats



--script 4
--To look only at user sessions, which
--are typically the most common area of interest when looking at waiting --tasks, you can use a fi lter on
--the session_id column for values greater than 50:


SELECT session_id,
execution_context_id,
wait_duration_ms,
wait_type,
resource_description,
blocking_session_id
FROM sys.dm_os_waiting_tasks
WHERE session_id > 50
ORDER BY session_id



--script 5
--It can also be very useful to perform aggregate queries against this DMV --to fi nd information such as
--the number of tasks for each wait type:


SELECT wait_type,
COUNT(*) AS num_waiting_tasks,
SUM(wait_duration_ms) AS total_wait_time_ms
FROM sys.dm_os_waiting_tasks
WHERE session_id > 50
GROUP BY wait_type
ORDER BY wait_type



---------------------------------
--ABPSPR
---------------------------------
WITH [Waits] AS
	(SELECT
		[wait_type],
		[wait_time_ms] / 1000.0 AS [WaitS],
		([wait_time_ms] - [signal_wait_time_ms]) / 1000.0
			AS [ResourceS],
		[signal_wait_time_ms] / 1000.0 AS [SignalS],
		[waiting_tasks_count] AS [WaitCount],
		100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER()
			AS [Percentage],
		ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC)
			AS [RowNum]
	FROM sys.dm_os_wait_stats
	WHERE [wait_type] NOT IN (
		N'CLR_SEMAPHORE',    N'LAZYWRITER_SLEEP',
		N'RESOURCE_QUEUE',   N'SQLTRACE_BUFFER_FLUSH',
		N'SLEEP_TASK',       N'SLEEP_SYSTEMTASK',
		N'WAITFOR',          N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
		N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'XE_TIMER_EVENT',   N'XE_DISPATCHER_JOIN',
		N'LOGMGR_QUEUE',     N'FT_IFTS_SCHEDULER_IDLE_WAIT',
		N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT',
		N'CLR_AUTO_EVENT',   N'DISPATCHER_QUEUE_SEMAPHORE',
		N'TRACEWRITE',       N'XE_DISPATCHER_WAIT',
		N'BROKER_TO_FLUSH',  N'BROKER_EVENTHANDLER',
		N'FT_IFTSHC_MUTEX',  N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
		N'DIRTY_PAGE_POLL')
	)
SELECT
	[W1].[wait_type] AS [WaitType], 
	CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
	CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
	CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
	[W1].[WaitCount] AS [WaitCount],
	CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
	CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4))
		AS [AvgWait_S],
	CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4))
		AS [AvgRes_S],
	CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4))
		AS [AvgSig_S]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]
	ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
	[W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount],
	[W1].[Percentage]
HAVING
	SUM ([W2].[Percentage]) - [W1].[Percentage] < 95; -- percentage
GO

-- Clear wait stats 
-- DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);

