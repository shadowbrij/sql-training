--Workspace Memory
--Every query requires some amount of memory
--•Infrastructure
--•Iterator state
--•Rows being processed
--Some iterators make a query need more
--•Memory consuming iterators
--When a query needs more memory it asks for a workspace memory grant


---- what takes memory

--Hash Match
--Sort
--Exchange


--Workspace memory is obtained from the buffer pool
--•Maximum utilization of approximately 75% (<2012, about 60% in >=2012)
--Each query’s ideal grant is determined by the query optimizer
--•(if the query uses memory-consuming iterators)
--If the ideal amount is too high, it gets scaled back depending on resource pool settings


--Compile-Time: What’s the Grant?
--Using available statistics, the query optimizer creates row count and row size estimates
--Each memory-consuming iterator has certain memory size requirements
--•Overhead
--•Size of input set (row count and row size)
--Iterators can share some or all of the total query memory grant



--Memory Fractions
--Sort and hash each have a build phase followed by a utilization phase (scan or probe)
--Typically the build phase uses more memory than the utilization phase
--Total memory grant assumes that a certain amount of memory – a fraction of the build amount – can be used by the next iterator



--When a Query is Ready to Run…
--1
--•The query is categorized based on the importance of the session’s workload group
--2
--•The query is further categorized based on cost and grant size
--3
--•These categories are queues inside of a gateway known as the resource semaphore
--4
--•The query must wait for both memory and the completion of more important queries



--Resource Semaphore Queues
--Each resource pool has two resource semaphores
--•Small semaphore, for queries with a cost of < 3 and a grant size of < 5MB
--•Large semaphore, for everything else
--Each semaphore has three sets of queues
--•Low / Medium / High importance sets
--The large semaphore has five queues per set
--•Query cost <10, 10-99, 100-999, 1000-9999, 10,000+



--Semaphore Queue Interaction
--The semaphore queues are designed to favor lower-cost, more important queries
--Example:
--•10 queries are queued in a 100-999 cost medium-importance queue
--•A query in the 10,000-cost queue will have to wait for all 10 queries, even if its memory requirement can be immediately satisfied
--Max wait time is determined by query timeout


--Headroom and Timeouts
--Queries will not start unless available query memory is 150% of requested query memory
--•Goal: Leave some room for concurrency
--Exception: Timeouts
--•When a query times out, its grant can be reduced to the minimum required grant for the plan
--•If even that can’t be done, you’ll see error 8645
--•Default timeout: 25x query cost, in seconds
--•(max 86400 == 24 hours)



--Configuration Options
--•max server memory (MB)
--•query wait (s)
--•min memory per query (KB)
--sp_configure
--•min_memory_percent
--•max_memory_percent
--Resource Governor – Resource Pool
--•importance
--•request_memory_grant_timeout_sec
--•request_max_memory_grant_percent



--Monitoring Query Memory
--DBCC MEMORYSTATUS
--•Small Query Memory Objects (pool_name)
--•Query Memory Objects (pool_name)
--sys.dm_exec_query_resource_semaphores
--sys.dm_exec_query_memory_grants
--sys.dm_os_waiting_tasks
--•RESOURCE_SEMAPHORE wait






USE AdventureWorks
GO


--set the bpool commit to a decent size
sp_configure 'show advanced options',1
RECONFIGURE

EXEC sp_configure 'max server memory', 2000
RECONFIGURE
GO



--verify:
	--Buffer Pool / Target == 256000 (this only workd prior to 2012)
	--Memory Pool (default) / Target == 256000	
	--Query Memory Objects (default) / Available == 144353
	--Small Query Memory Objects (default) / Available == 7597
	--show the above pools in the output of DBBCC MEmorySTatus

DBCC MEMORYSTATUS
GO



-- where are the numbers coming from?
select (144353 + 7597)/256000.0

-- 60%?? this was 75% of the BPool earlier...

--Examine actual plan
-- check the memory grant on the select operator, check the dataszie
-- the maths.. estimated data size * 2 + overhead = total memory grant.
--Note input size for sort, total memory grant (> 200%)
SELECT TOP(1000)
	*
FROM Production.TransactionHistory
ORDER BY
	ActualCost DESC
OPTION (MAXDOP 1)
GO



--memory fractions
--get into properties window and show memory fractions for all the sor operators from right to left
SELECT TOP(20)
	*
FROM
(
	SELECT TOP(50)
		*
	FROM
	(
		SELECT TOP(100)
			*
		FROM Production.TransactionHistory
		ORDER BY
			ActualCost DESC
	) x
	ORDER BY
		ActualCost
) y
ORDER BY
	ActualCost DESC
OPTION (MAXDOP 1)
GO



--bigger sets and grant limits
--query hits the wall with top (2000000) and then change to (3000000), then (4000000), then (5000000)
--monitor with select * from sys.dm_exec_query_memory_grants
SELECT TOP(1000)
	*
FROM
(
	SELECT TOP(5000000)
		*
	FROM dbo.bigTransactionHistory
) AS x
ORDER BY
	ActualCost DESC
OPTION (MAXDOP 1)
GO



--memory grant ==
	--(365512) / 8 == 45689 pages
--total available grant for large queries ==
	--182757
--How many of these things can run concurrently?
	--45689 * 4 == 182756
--Load up SQLQueryStress, headroom.sqlstress
--Monitor with sys.dm_exec_query_memory_grants and DBCC MEMORYSTATUS
--Also monitor with sys.dm_os_wait_stats for RESOURCE_SEMAPHORE



--Queue numbers and importance
-- skip this...
ALTER WORKLOAD GROUP [default] WITH
(
	--low == queues 0 - 4
	--medium == queues 5 - 9
	--high == queues 10 - 14
	importance=low
)
GO

ALTER RESOURCE GOVERNOR RECONFIGURE
GO



--Queue behavior with large cost queries?
--Run at the same time as headroom.sqlstress, monitor queues
-- show the cost, the queue, etc
-- show its memory in the semaphore dmv
-- show its cost
SELECT TOP(5000)
	*
FROM
(
	SELECT TOP(1000)
		p.*,
		b.ActualCost
	FROM dbo.bigProduct AS p
	CROSS APPLY
	(
		SELECT COUNT(*) as actualcost
		FROM dbo.bigTransactionHistory AS b
		WHERE
			b.actualcost BETWEEN p.productid - 1000 and p.productid + 1000
	) AS b
) AS x
ORDER BY
	name
OPTION (MAXDOP 1)
GO




--Reconfigure the query timeout
ALTER WORKLOAD GROUP [default] WITH
(
	--default 0
	request_memory_grant_timeout_sec=10
)
GO

ALTER RESOURCE GOVERNOR RECONFIGURE
GO



--Try again w/ 20-second timeout



--And once again, now with a high grant/high cost query
SELECT TOP(5000)
	*
FROM
(
	SELECT TOP(1000)
		p.*,
		b.theCount
	FROM 
	(
		SELECT TOP(1000000) 
			ProductId 
		FROM dbo.bigTransactionHistory 
		ORDER BY 
			ActualCost
	) AS p
	CROSS APPLY
	(
		SELECT 
			COUNT(*) AS theCount
		FROM dbo.bigTransactionHistory AS b
		WHERE
			b.actualcost BETWEEN p.productid - 1000 AND p.productid + 1000
	) AS b
	ORDER BY
		b.theCount DESC
) AS x
ORDER BY
	ProductId
OPTION (MAXDOP 1)
GO

-- do the trick to reduce memory grant


-- original query
SELECT TOP(1000)
	*
FROM
(
	SELECT TOP(2000000)
		*
	FROM dbo.bigTransactionHistory
) AS x
ORDER BY
	ActualCost DESC
OPTION (MAXDOP 1)
GO

--modified
-- original query
Declare @i int = 2000000

SELECT TOP(1000)
	*
FROM
(
	SELECT TOP(@i)
		*
	FROM dbo.bigTransactionHistory
) AS x
ORDER BY
	ActualCost DESC
OPTION (MAXDOP 1, OPTIMIZE FOR (@i=10000))
GO

