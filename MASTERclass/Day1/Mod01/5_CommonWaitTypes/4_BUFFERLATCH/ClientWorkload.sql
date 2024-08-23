USE AdventureWorks2014;
GO

while (1=1)
begin
DBCC DROPCLEANBUFFERS
SELECT TOP(20000)
	a.*
INTO #x
FROM master..spt_values a, master..spt_values b
DROP TABLE #x
end;
GO