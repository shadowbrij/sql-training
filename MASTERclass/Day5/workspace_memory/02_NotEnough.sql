USE AdventureWorks
GO

--Enable Profiler, Hash/Sort/Exchange warning/spill events
--Watch task_space_usage or session_space_usage DMVs for spill size
--Watch sys.dm_os_waiting_tasks for IO_COMPLETION


--Sort Spill -- not a very nice thing
SELECT TOP(1000)
	*
FROM
(
	--Top 668936 for spill
	SELECT TOP(668935)
		*
	FROM bigTransactionHistory
) AS x
ORDER BY
	x.ActualCost DESC
GO



--Hash Spill -- much better control
SELECT COUNT(*)
FROM 
(
	--4000000 for a spill
	SELECT TOP(3800000)
		* 
	FROM bigTransactionHistory
) AS bth
INNER HASH JOIN 
(
	SELECT TOP(10000)
		* 
	FROM bigTransactionHistory
) AS bth1 ON
	bth.ProductId = bth1.ProductId
GO



--Exchange Spill 
--
--Many thanks to Paul White
--@sql_kiwi
USE AdventureWorks
GO


/*
-- Test table
CREATE  TABLE dbo.ExchangeTest 
(
    id          INTEGER IDENTITY (1, 1) NOT NULL,
    value       INTEGER NOT NULL,
    padding     CHAR(999) NOT NULL,

    CONSTRAINT [PK dbo.Test (id)]
        PRIMARY KEY CLUSTERED (id),
)
GO

-- Insert 1,000,000 rows
INSERT dbo.ExchangeTest WITH (TABLOCK)
    (value, padding)
SELECT TOP (1000000)
    value = CONVERT(INTEGER, Data.n),
    padding = REPLICATE(CHAR(65 + (Data.n % 26)), 999)
FROM
(
    SELECT TOP (1000000)
        n = ROW_NUMBER() OVER (ORDER BY (SELECT 0))
    FROM master.sys.columns C1
    CROSS JOIN master.sys.columns C2
    CROSS JOIN master.sys.columns C3
    ORDER BY 
        n ASC
) AS Data
ORDER BY
    Data.n ASC
OPTION (RECOMPILE)
GO
*/


-- Parallel deadlock and exchange spills
-- Trace: Deadlock Chain (note resource type exchange) and Exchange Spill Event
DECLARE 
    @a INTEGER,
    @b INTEGER

SELECT
    @a = a, 
    @b = b
FROM    
(
    SELECT TOP (2000000)
        a = T1.id % 80, 
        b = CHECKSUM(REVERSE(T1.padding))
    FROM dbo.ExchangeTest AS T1
    JOIN dbo.ExchangeTest AS T2 ON
        T2.id = T1.id
    WHERE
        T1.id BETWEEN 1 AND 200000
    ORDER BY 
        a, b
        
    UNION ALL
    
    SELECT TOP (2000000)
        a = T1.id % 80, 
        b = CHECKSUM(REVERSE(T1.padding))
    FROM dbo.ExchangeTest AS T1
    JOIN dbo.ExchangeTest AS T2 ON 
        T2.id = T1.id
    WHERE
        T1.id BETWEEN 1 AND 200000
    ORDER BY 
        a, b
) AS x
ORDER BY 
    x.a
OPTION (RECOMPILE, MAXDOP 0)
GO

