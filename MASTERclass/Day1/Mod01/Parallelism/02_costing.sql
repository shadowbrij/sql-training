USE AdventureWorks
GO

--costing issues
-- anti nested loop issue
-- nested loop are doing seek inside the loop, once for each outer row
--Find all "active" product time ranges:

--intervals during which the product has sold 
--within the prior N days

-- look at the plan cost
-- look at the subtree cost under nested loop

DECLARE @active_interval INT = 7
--DECLARE @i INT = 2147483647

SELECT DISTINCT
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
				t_e.ProductID = t_s.ProductID
				AND t_e.TransactionDate >= t_s.TransactionDate
				AND NOT EXISTS
				(
					SELECT *
					FROM dbo.BigTransactionHistory AS t_ae
					WHERE
						t_ae.ProductID = t_s.ProductID
						AND t_ae.TransactionDate BETWEEN DATEADD(dd, 1, t_e.TransactionDate) AND DATEADD(dd, @active_interval, t_e.TransactionDate)
				)
		)
	) AS EndDate
FROM 
(
	SELECT DISTINCT /*TOP(@i)*/
		ProductID,
		TransactionDate
	FROM dbo.BigTransactionHistory
	WHERE
		--Terminating at 3617 results in a parallel plan
		--Terminating at 3618 results in a serial plan
		ProductID BETWEEN 1001 AND 3618
) AS t_s
WHERE
	NOT EXISTS
	(
		SELECT *
		FROM dbo.BigTransactionHistory AS t_ps
		WHERE
			t_ps.ProductID = t_s.ProductID
			AND t_ps.TransactionDate BETWEEN DATEADD(dd, -@active_interval, t_s.TransactionDate) AND DATEADD(dd, -1, t_s.TransactionDate)
	)
--OPTION (QUERYTRACEON 8649)
GO




--UNDOCUMENTED - DO NOT USE THIS IN PRODUCTION!
--TF to help figure out whether a parallel plan is available
/*
OPTION (QUERYTRACEON 8649)
*/


--Mess with the row goals
--Use this in conjunction with top and @i declaration
/*
OPTION (OPTIMIZE FOR (@i = 50000))
*/



DECLARE @active_interval INT = 7
--DECLARE @i INT = 2147483647

SELECT DISTINCT
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
				t_e.ProductID = t_s.ProductID
				AND t_e.TransactionDate >= t_s.TransactionDate
				AND NOT EXISTS
				(
					SELECT *
					FROM dbo.BigTransactionHistory AS t_ae
					WHERE
						t_ae.ProductID = t_s.ProductID
						AND t_ae.TransactionDate BETWEEN DATEADD(dd, 1, t_e.TransactionDate) AND DATEADD(dd, @active_interval, t_e.TransactionDate)
				)
		)
	) AS EndDate
FROM 
(
	SELECT DISTINCT /*TOP(@i)*/
		ProductID,
		TransactionDate
	FROM dbo.BigTransactionHistory
	WHERE
		--Terminating at 3617 results in a parallel plan
		--Terminating at 3618 results in a serial plan
		ProductID BETWEEN 1001 AND 3618
) AS t_s
WHERE
	NOT EXISTS
	(
		SELECT *
		FROM dbo.BigTransactionHistory AS t_ps
		WHERE
			t_ps.ProductID = t_s.ProductID
			AND t_ps.TransactionDate BETWEEN DATEADD(dd, -@active_interval, t_s.TransactionDate) AND DATEADD(dd, -1, t_s.TransactionDate)
	)
	--OPTION (QUERYTRACEON 8649)
GO