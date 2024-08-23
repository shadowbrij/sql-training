--build version store
SET NOCOUNT ON;
USE AdventureWorks2014;
GO
DECLARE @i INT
SET @i = 1
WHILE (@i < 10000)
BEGIN
  UPDATE dbo.T1 SET col2 = 'Version 3' WHERE keycol = 2;
  SET @i = @i + 1;
END
GO

SET NOCOUNT ON;
USE AdventureWorks2014;
GO
  BEGIN TRAN
  UPDATE dbo.T1 SET col2 = 'Version 4' WHERE keycol = 2;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

-- commit transaction
--COMMIT
-- ROLLBACK