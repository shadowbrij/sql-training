USE AdventureWorks
GO


--Scalar Expressions can cost... a LOT

--Run with:
	--Include Client Statistics
	--Discard Query Results
	--Actual Query Plan 

SELECT
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
