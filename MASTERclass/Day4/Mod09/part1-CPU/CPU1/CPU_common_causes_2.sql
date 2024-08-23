--Starting SQL Server 2008, SQL stores a query_hash value which represents queries that are “similar”.
--Let’s take an example of “similar” queries which are not being parameterized:
DBCC FREEPROCCACHE
use [AdventureWorks]
/*
Example of in-line literals in the query text which can lead to queries NOT being parameterized
and thus you would see "similar" query text in the proc cache each with its separate compiled plans
*/
DECLARE @SQLString nvarchar(500)
DECLARE @cnt INT
SET @cnt = 1
/* Build the SQL string several times by appending the @SQLString*/
While @cnt <= 100
begin
      SET @SQLString =
            N'SELECT EmployeeID, NationalIDNumber, Title, ManagerID
               FROM AdventureWorks.HumanResources.Employee WHERE ManagerID = ' + CAST(@cnt AS nvarchar(500))
      EXECUTE sp_executesql @SQLString
      SET @cnt = @cnt + 1
end

--You could run the below query which helps in identifying queries with same query_hash value:
select q.query_hash,
      q.number_of_entries,
      t.text as sample_query,
      p.query_plan as sample_plan
from (select top 20 query_hash,
                  count(*) as number_of_entries,
                  min(sql_handle) as sample_sql_handle,
                  min(plan_handle) as sample_plan_handle
            from sys.dm_exec_query_stats
            group by query_hash
            having count(*) > 1
            order by count(*) desc) as q
      cross apply sys.dm_exec_sql_text(q.sample_sql_handle) as t
      cross apply sys.dm_exec_query_plan(q.sample_plan_handle) as p
go

--Queries that have a number_of_entries value in the hundreds or thousands are excellent candidates for parameterization. If you look at the CompileTime and CompileCPU attributes under the <QueryPlan> tag of the sample XML query plan and multiply those values times the number_of_entries value for that query, you can get an estimate of how much compile time and CPU you can eliminate by parameterizing the query (which means that the query is compiled once, and then it is cached and reused for subsequent executions).
--You can use the query_hash and query_plan_hash values together to determine whether a set of ad hoc queries with the same query_hash value resulted in query plans with the same or different query_plan_hash values, or access path. This is done via a small modification to the earlier query.
select q.query_hash,
      q.number_of_entries,
      q.distinct_plans,
      t.text as sample_query,
      p.query_plan as sample_plan
from (select top 20 query_hash,
                  count(*) as number_of_entries,
                  count(distinct query_plan_hash) as distinct_plans,
                  min(sql_handle) as sample_sql_handle,
                  min(plan_handle) as sample_plan_handle
            from sys.dm_exec_query_stats
            group by query_hash
            having count(*) > 1
            order by count(*) desc) as q
      cross apply sys.dm_exec_sql_text(q.sample_sql_handle) as t
      cross apply sys.dm_exec_query_plan(q.sample_plan_handle) as p
go
--Note that this new query returns a count of the number of distinct query plans (query_plan_hash values) for a given query_hash value. Rows that return a large number for number_of_entries and a distinct_plans count of 1 are good candidates for parameterization. Even if the number of distinct plans is more than one, you can use sys.dm_exec_query_plan to retrieve the different query plans and examine them to see whether the difference is important and necessary for achieving optimal performance.

--Having identified the scope for parameterizing queries change should ideally be done on the application. For our example we could rewrite the batch using sp_executesql which will allow parameterizing our query:
use [AdventureWorks]
--DBCC FREEPROCCACHE
/* Example which makes use of the parameters (as placeholders) in the query which leads to parameterization and
plan reuse*/
DECLARE @SQLString nvarchar(500)
DECLARE @ParmDefinition nvarchar(500);
DECLARE @cnt INT
SET @cnt = 1
SET @SQLString =
     N'SELECT EmployeeID, NationalIDNumber, Title, ManagerID
       FROM AdventureWorks.HumanResources.Employee WHERE ManagerID = @ManagerID '
-------------------------------------------
SET @ParmDefinition = N'@ManagerID tinyint';
-------------------------------------------
/* Execute the same string with the different parameter value */
While @cnt <= 100
begin
      EXECUTE sp_executesql @SQLString, @ParmDefinition, @ManagerID = @cnt
      SET @cnt = @cnt + 1
end
--Run the same query above to get the number_of_entries value for the query_hash and you will now see the difference.
--Detection:
--You can look out for high ratio of SQL Statistics: SQL Compilations/sec to SQL Statistics: Batch Requests/sec as one indication of high compilations as an area to focus on.
--You can also check queries waiting for compile memory will show a wait type of "RESOURCE_SEMAPHORE_QUERY_COMPILE“
--SQL Server 2005 throttles the number of concurrent compiles that can happen at any one time.  Unlike 2000, which throttled solely based on the number of compiles, SQL 2005 throttles based on memory usage during the compile.  There are three gateways (semaphores) called the small, medium, and big gateway.  When a request is received that must be compiled it will start compilation.  There is a special function called to yield during optimization which also checks how much memory has been used by that compile.  Once the memory usage reaches the threshold for a given gateway it will then acquire that semaphore before continuing.



--Unnecessary Recompilation

--Detection:
--Performance Monitor
--SQL Statistics object:
--Counters:
--SQL Server: SQL Statistics: Batch Requests/sec
--SQL Server: SQL Statistics: SQL Recompilations/sec
--SQL Server Profiler trace provides that information along with the reason for the recompilation. You can use the following events to get this information.
--SP:Recompile/SQL:StmtRecompile Refer to http://technet.microsoft.com/en-us/library/ms179294.aspx
--Use sys.dm_exec_query_stats DMV:

select top 25
    sql_text.text,
    sql_handle,
    plan_generation_num, -- number of times the query has recompiled
    execution_count,
    dbid,
    objectid
from
    sys.dm_exec_query_stats a
    cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where
    plan_generation_num >1
order by plan_generation_num desc
