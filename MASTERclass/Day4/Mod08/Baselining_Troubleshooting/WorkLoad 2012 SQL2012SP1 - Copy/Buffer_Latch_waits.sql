USE MASTER
GO

SELECT TOP(20000)
	a.*
INTO #x
FROM master..spt_values a, master..spt_values b
