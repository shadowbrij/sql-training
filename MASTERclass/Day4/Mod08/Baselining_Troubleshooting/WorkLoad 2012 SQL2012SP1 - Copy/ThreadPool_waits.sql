USE AdventureWorks2008R2
GO

SELECT
	*
FROM
(
	SELECT
		sh.*,
		sd.ProductId,
		ROW_NUMBER() OVER 
		(
			PARTITION BY sd.SalesOrderDetailId
			ORDER BY sd.ProductId
		) AS r
	FROM
	(
		SELECT TOP(1000) 
			*
		FROM Sales.SalesOrderDetail
		ORDER BY
			SalesOrderDetailId DESC
	) AS sd
	INNER JOIN Sales.SalesOrderHeader AS sh ON
		sh.SalesOrderId = sd.SalesOrderId
) AS s
WHERE
	s.r = 1
GO 1000