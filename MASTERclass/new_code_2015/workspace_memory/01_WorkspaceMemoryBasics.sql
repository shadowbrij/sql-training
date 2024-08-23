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
	SELECT TOP(2000000)
		*
	FROM dbo.bigTransactionHistory
) AS x
ORDER BY
	ActualCost DESC
OPTION (MAXDOP 1)
GO



--memory grant ==
	--(184000) / 8 == 23000 pages
--total available grant for large queries ==
	--144353
--How many of these things can run concurrently?
	--23000 * 6 == 138000
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
	request_memory_grant_timeout_sec=20
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

