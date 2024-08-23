--Create Procedures
USE AdventureWorks2014
GO
CREATE PROCEDURE Call3
AS
BEGIN
	SELECT 'In third'
END
GO

CREATE PROCEDURE Call2
AS
BEGIN
	EXEC AdventureWorks2014.dbo.Call3
END
GO

CREATE PROCEDURE Call1
AS
BEGIN
	EXEC AdventureWorks2014.dbo.Call2
END
GO

--Call Procedures
EXEC AdventureWorks2014.dbo.Call1
EXEC AdventureWorks2014.dbo.Call2

--Cleanup
USE AdventureWorks2014
GO
DROP PROCEDURE Call1
DROP PROCEDURE Call2
DROP PROCEDURE Call3