--run transaction with snapshot isolation
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
SET NOCOUNT ON;
USE AdventureWorks2014;
GO
BEGIN TRAN
	SELECT col2 FROM dbo.T1 WHERE keycol = 2;

--run select
	SELECT col2 FROM dbo.T1 WHERE keycol = 2;

--rollback
ROLLBACK