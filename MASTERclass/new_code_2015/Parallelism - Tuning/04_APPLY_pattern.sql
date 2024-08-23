USE AdventureWorks
GO



--Run each of the following with:
	-- Actual Execution Plan enabled
	-- Client statistics enabled
	-- Discard results after execution 



--A typical parallel query...
SELECT 
    p.ProductId, 
    p.ProductNumber,
    p.ReorderPoint,
    th.TransactionId,
    RANK() OVER 
    (
        PARTITION BY
            p.ProductId
        ORDER BY
            th.ActualCost DESC
    ) AS LineTotalRank,
    RANK() OVER
    (
        PARTITION BY
            p.ProductId
        ORDER BY 
            th.Quantity DESC
    ) AS OrderQtyRank
FROM bigProduct AS p
INNER JOIN bigTransactionHistory AS th ON
    th.ProductId = p.ProductId
WHERE
	p.ProductId BETWEEN 1001 AND 5001
GO




--Think about the query a different way...
SELECT 
    p.ProductId,
    p.ProductNumber,
    p.ReorderPoint,
    d.*
FROM bigProduct AS p
CROSS APPLY
(
    SELECT
		th.TransactionId,		
		RANK() OVER 
		(
			ORDER BY
				th.ActualCost DESC
		) AS LineTotalRank,
		RANK() OVER
		(
			ORDER BY 
				th.Quantity DESC
		) AS OrderQtyRank
	FROM bigTransactionHistory AS th
	WHERE
		th.ProductId = p.ProductId
) AS d
WHERE
	p.ProductId BETWEEN 1001 AND 5001
GO


--Take a look at actual rows/thread



--Repartition to avoid skew?
SELECT 
    p.ProductId,
    p.ProductNumber,
    p.ReorderPoint,
    d.*
FROM 
(
	SELECT TOP(2147483647)
	    p0.ProductId,
		p0.ProductNumber,
		p0.ReorderPoint
	FROM bigProduct AS p0
	WHERE
		p0.ProductId BETWEEN 1001 AND 5001
) AS p
CROSS APPLY
(
    SELECT
		th.TransactionId,		
		RANK() OVER 
		(
			ORDER BY
				th.ActualCost DESC
		) AS LineTotalRank,
		RANK() OVER
		(
			ORDER BY 
				th.Quantity DESC
		) AS OrderQtyRank
	FROM bigTransactionHistory AS th
	WHERE
		th.ProductId = p.ProductId
) AS d
GO




--Our slow scalar expression query...
SELECT
	p.ProductID,
	p.SellStartDate, 
	th.TransactionDate,
    DATENAME
    (
		dw, 
		DATEADD
		(
			dd, 
			0, 
			20 % 
				DATEDIFF
				(
					dd, 
					CONVERT(DATETIME, '20091125')-1, 
					DATEADD
					(
						dd, 
						DATEDIFF
						(
							dd, 
							0, 
							DATEADD
							(
								month, 
								DATEDIFF
								(
									dd, 
									p.SellStartDate, 
									th.TransactionDate
								), 
								DATEADD
								(
									month, 
									DATEDIFF
									(
										month, 
										th.TransactionDate, 
										p.SellStartDate
									), 
									0
								)
							)
						), 
						0
					)
				)
			)
		) AS SomeWeirdThing
FROM bigProduct AS p
INNER JOIN bigTransactionHistory AS th ON
    th.ProductId = p.ProductId
	AND th.ActualCost BETWEEN 0 AND 100000
WHERE
    p.ProductId BETWEEN 1001 AND 10001
GO



--Does it work with the APPLY pattern?
SELECT
	p.ProductID,
	p.SellStartDate, 
	d.TransactionDate,
    d.someweirdthing
FROM bigProduct AS p
CROSS APPLY /*OUTER APPLY*/
(
    SELECT /*TOP(2147483647)*/
		th.TransactionDate,
        DATENAME
        (
			dw, 
			DATEADD
			(
				dd, 
				0, 
				20 % 
					DATEDIFF
					(
						dd, 
						CONVERT(DATETIME, '20091125')-1, 
						DATEADD
						(
							dd, 
							DATEDIFF
							(
								dd, 
								0, 
								DATEADD
								(
									month, 
									DATEDIFF
									(
										dd, 
										p.SellStartDate, 
										th.TransactionDate
									), 
									DATEADD
									(
										month, 
										DATEDIFF
										(
											month, 
											th.TransactionDate, 
											p.SellStartDate
										), 
										0
									)
								)
							), 
							0
						)
					)
				)
			) AS SomeWeirdThing
    FROM bigTransactionHistory AS th
    WHERE
        th.ProductId = p.ProductId
		AND th.ActualCost BETWEEN 0 AND 100000
) AS d
WHERE
    p.ProductId BETWEEN 1001 AND 10001
	/*AND d.SomeWeirdThing IS NOT NULL*/
GO





--Active intervals, rewritten with the APPLY pattern...

DECLARE @active_interval INT = 7
/*DECLARE @i INT = 2147483647*/

SELECT
	x.* 
FROM dbo.bigProduct AS bp /*(SELECT DISTINCT 0%ProductId+ProductId AS Productid FROM dbo.bigProduct) AS bp*/
OUTER APPLY
(
	SELECT DISTINCT /*TOP(@i)*/
		t_s.ProductID,
		t_s.TransactionDate AS StartDate,
		DATEADD
		(
			dd,
			@active_interval,
			(
				SELECT
					MIN(t_e.TransactionDate)
				FROM dbo.BigTransactionHistory AS t_e
				WHERE
					t_e.ProductID = bp.ProductID
					AND t_e.TransactionDate >= t_s.TransactionDate
					AND NOT EXISTS
					(
						SELECT *
						FROM dbo.BigTransactionHistory AS t_ae
						WHERE
							t_ae.ProductID = bp.ProductID
							AND t_ae.TransactionDate BETWEEN DATEADD(dd, 1, t_e.TransactionDate) AND DATEADD(dd, @active_interval, t_e.TransactionDate)
					)
			)
		) AS EndDate
	FROM 
	(
		SELECT DISTINCT
			ProductID,
			TransactionDate
		FROM dbo.BigTransactionHistory
		WHERE
			ProductID = bp.ProductID
	) AS t_s
	WHERE
		NOT EXISTS
		(
			SELECT *
			FROM dbo.BigTransactionHistory AS t_ps
			WHERE
				t_ps.ProductID = bp.ProductID
				AND t_ps.TransactionDate BETWEEN DATEADD(dd, -@active_interval, t_s.TransactionDate) AND DATEADD(dd, -1, t_s.TransactionDate)
		)
) AS x
WHERE
	bp.ProductID BETWEEN 1001 AND 3618
	AND x.ProductID IS NOT NULL
GO




--ORDER BY == BAD?
/*
ORDER BY
	bp.ProductId
*/
--OPTION (OPTIMIZE FOR (@i = 1))
/*
--Check out the TF to evaluate why ORDER BY is problematic...
OPTION (QUERYTRACEON 8649)
*/
--Fix by reducing estimate coming out of the loop...
/*
OPTION (OPTIMIZE FOR (@i = 1))
*/
GO




--Beware the spool!

--prep -- create a table of non-distinct product IDs
SELECT 
	ProductId
INTO #products
FROM bigProduct
CROSS APPLY 
(
	SELECT 
		1

	UNION ALL

	SELECT
		2
	WHERE
		ProductId % 5 = 0

	UNION ALL

	SELECT
		3
	WHERE
		ProductId % 7 = 0
) x(m)
GO



--The dreaded "performance spool"
SELECT
	p.ProductId,
	AVG(x.ActualCost) AS AvgCostTop40
FROM #products /*(SELECT DISTINCT ProductId FROM #products)*/ AS p
CROSS APPLY
(
	SELECT
		t.*,
		ROW_NUMBER() OVER (PARTITION BY p.ProductId ORDER BY t.ActualCost DESC) AS r
	FROM bigTransactionHistory AS t 
	WHERE
		p.ProductId = t.ProductId
) AS x
WHERE
	x.r BETWEEN 1 AND 40
GROUP BY
	p.ProductId
GO


--Two options:
	--Give the optimizer more information (yes!)
	--Use TF 8690 (last resort)

--Clean up
DROP TABLE #products
GO

