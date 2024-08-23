
-- ********** More strategic approach using tracing capabilites

--Define the trace

SET NOCOUNT ON;
USE Tuning;
GO

IF OBJECT_ID('dbo.sp_perfworkload_trace_start') IS NOT NULL
  DROP PROC dbo.sp_perfworkload_trace_start;
GO

CREATE PROC dbo.sp_perfworkload_trace_start
  @tracefile AS NVARCHAR(254),
  @traceid   AS INT OUTPUT
AS

-- Create a Queue
DECLARE @rc          AS INT;
DECLARE @maxfilesize AS BIGINT;

SET @maxfilesize = 5;

EXEC @rc = sp_trace_create @traceid OUTPUT, 0, @tracefile, @maxfilesize, NULL 
IF (@rc != 0) GOTO error;

-- Client side File and Table cannot be scripted

-- Set the events
DECLARE @on AS BIT;
SET @on = 1;
EXEC sp_trace_setevent @traceid, 10, 15, @on;
EXEC sp_trace_setevent @traceid, 10, 8, @on;
EXEC sp_trace_setevent @traceid, 10, 16, @on;
EXEC sp_trace_setevent @traceid, 10, 48, @on;
EXEC sp_trace_setevent @traceid, 10, 1, @on;
EXEC sp_trace_setevent @traceid, 10, 17, @on;
EXEC sp_trace_setevent @traceid, 10, 10, @on;
EXEC sp_trace_setevent @traceid, 10, 18, @on;
EXEC sp_trace_setevent @traceid, 10, 11, @on;
EXEC sp_trace_setevent @traceid, 10, 12, @on;
EXEC sp_trace_setevent @traceid, 10, 13, @on;
EXEC sp_trace_setevent @traceid, 10, 14, @on;
EXEC sp_trace_setevent @traceid, 45, 8, @on;
EXEC sp_trace_setevent @traceid, 45, 16, @on;
EXEC sp_trace_setevent @traceid, 45, 48, @on;
EXEC sp_trace_setevent @traceid, 45, 1, @on;
EXEC sp_trace_setevent @traceid, 45, 17, @on;
EXEC sp_trace_setevent @traceid, 45, 10, @on;
EXEC sp_trace_setevent @traceid, 45, 18, @on;
EXEC sp_trace_setevent @traceid, 45, 11, @on;
EXEC sp_trace_setevent @traceid, 45, 12, @on;
EXEC sp_trace_setevent @traceid, 45, 13, @on;
EXEC sp_trace_setevent @traceid, 45, 14, @on;
EXEC sp_trace_setevent @traceid, 45, 15, @on;
EXEC sp_trace_setevent @traceid, 41, 15, @on;
EXEC sp_trace_setevent @traceid, 41, 8, @on;
EXEC sp_trace_setevent @traceid, 41, 16, @on;
EXEC sp_trace_setevent @traceid, 41, 48, @on;
EXEC sp_trace_setevent @traceid, 41, 1, @on;
EXEC sp_trace_setevent @traceid, 41, 17, @on;
EXEC sp_trace_setevent @traceid, 41, 10, @on;
EXEC sp_trace_setevent @traceid, 41, 18, @on;
EXEC sp_trace_setevent @traceid, 41, 11, @on;
EXEC sp_trace_setevent @traceid, 41, 12, @on;
EXEC sp_trace_setevent @traceid, 41, 13, @on;
EXEC sp_trace_setevent @traceid, 41, 14, @on;

-- Set the Filters
DECLARE @intfilter AS INT;
DECLARE @bigintfilter AS BIGINT;

-- Application name filter
EXEC sp_trace_setfilter @traceid, 10, 0, 7, N'SQL Server Profiler%';
-- Database ID filter
--EXEC sp_trace_setfilter @traceid, 3, 0, 0, @dbid;

-- Set the trace status to start
EXEC sp_trace_setstatus @traceid, 1;

-- Print trace id and file name for future references
PRINT 'Trace ID: ' + CAST(@traceid AS VARCHAR(10))
  + ', Trace File: ''' + @tracefile + '.trc''';

GOTO finish;

error: 
PRINT 'Error Code: ' + CAST(@rc AS VARCHAR(10));

finish: 
GO

-- Start the trace
--DECLARE @dbid AS INT, @traceid AS INT;
--SET @dbid = DB_ID('Tuning');

EXEC dbo.sp_perfworkload_trace_start
  @tracefile = 'C:\workload2012',
  @traceid   = @traceid OUTPUT;
GO

--- now go and run the workloads

-- Stop the trace (assuming trace id was 2)
EXEC sp_trace_setstatus 2, 0; -- stop
EXEC sp_trace_setstatus 2, 2; -- close
GO

-- load the trace file in GUI

--What do we see??
--Some long-running queries that generate a lot of I/O.

--also observe rowcounts for some of the queries

-- load the trace data  in the table, use sys.fn_trace_gettable

--Note that this code loads only the TextData (T-SQL code) and Duration data columns to focus particularly on query run time. Typically, you would want to also load other data columns that are relevant to your analysisfor example, the I/O and CPU counters, row counts, host name, application name, and so on.


SET NOCOUNT ON;
USE Tuning;
GO
IF OBJECT_ID('dbo.Workload') IS NOT NULL
  DROP TABLE dbo.Workload;
GO

SELECT CAST(TextData AS NVARCHAR(MAX)) AS tsql_code,
  Duration AS duration
INTO dbo.Workload
FROM sys.fn_trace_gettable('C:\workload2012.trc', NULL) AS T
WHERE Duration IS NOT NULL;
GO


-- Aggregate trace data by query
SELECT
  tsql_code,
  SUM(duration) AS total_duration
FROM dbo.Workload
GROUP BY tsql_code;


-- Aggregate trace data by query prefix
SELECT
  SUBSTRING(tsql_code, 1, 100) AS tsql_code,
  SUM(duration) AS total_duration
FROM dbo.Workload
GROUP BY SUBSTRING(tsql_code, 1, 100);

-- Adjust substring length
SELECT
  SUBSTRING(tsql_code, 1, 94) AS tsql_code,
  SUM(duration) AS total_duration
FROM dbo.Workload
GROUP BY SUBSTRING(tsql_code, 1, 94);


--after analysis and shortlisting queries to be tuned, do the needful by tuning indexes or code revisions, etc.
