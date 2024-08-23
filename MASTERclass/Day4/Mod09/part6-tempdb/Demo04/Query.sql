DECLARE @i INT = 1

WHILE (@i < 100)
BEGIN
	EXEC AdventureWorks2014.dbo.use_getSalesOrderDetails_prc
	SET @i = @i + 1
END