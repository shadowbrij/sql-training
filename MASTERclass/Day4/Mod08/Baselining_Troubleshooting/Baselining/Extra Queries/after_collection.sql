-- run before tests

use baseline
GO

create table DiskSpaceUsage_AfterTests
(
    name nvarchar(128),
    [rows] char(11),
    reserved varchar(18),
    data varchar(18),
    index_size varchar(18),
    unused varchar(18)
)

use AdventureWorks2012
GO


insert into baseline.dbo.DiskSpaceUsage_AfterTests
    exec sp_msforeachtable 'sp_spaceused ''?'''

--select * from baseline.dbo.DiskSpaceUsage_AfterTests order by cast(replace(reserved,' kb','') as int) desc

use baseline
GO

select * into queryStats
from sys.dm_exec_query_stats
GO

SELECT
    total_worker_time/execution_count AS avg_cpu_cost, 
    plan_handle, execution_count,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
       (CASE WHEN statement_end_offset = -1
               THEN LEN(CONVERT(nvarchar(max), text)) * 2
               ELSE statement_end_offset
        END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text, QP.query_plan
	 INTO query_details
FROM sys.dm_exec_query_stats QS
CROSS APPLY sys.dm_exec_query_plan (QS.plan_handle) QP
ORDER BY [avg_cpu_cost] DESC;
