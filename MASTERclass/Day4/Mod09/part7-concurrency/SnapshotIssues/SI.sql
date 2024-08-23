--- connection 1
SET NOCOUNT ON;
USE testdb;
GO
  UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO
-- rollback

--- connection 2
SET NOCOUNT ON;
USE testdb;
GO
  UPDATE dbo.T1 SET col2 = 'Version 3' WHERE keycol = 2;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO
-- rollback


--- connection 3
SET NOCOUNT ON;
USE testdb;
GO
  BEGIN TRAN
  UPDATE dbo.T1 SET col2 = 'Version 4' WHERE keycol = 2;
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO
-- COMMIT

-- connection 4

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
SET NOCOUNT ON;
USE testdb;
GO
BEGIN TRAN
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
GO

--rollback