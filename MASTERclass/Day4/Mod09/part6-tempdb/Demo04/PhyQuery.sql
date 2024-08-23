USE AdventureWorks2014
GO
ALTER PROCEDURE use_getSalesOrderDetails_prc
AS
BEGIN
	DECLARE @rand NVARCHAR(100)
	DECLARE @cmd NVARCHAR(1000)
	SET @rand = 'temp' + CAST(RAND()*1000000 AS NVARCHAR(10))

	SET @cmd = '
	SELECT * 
	INTO [' + @rand + ']
	FROM sales.SalesOrderDetail'

	PRINT @cmd

	--process data in physical temp table

	SET @cmd = '
	DROP TABLE [' + @rand + ']'

	PRINT @cmd

END
GO