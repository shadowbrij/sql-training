--Lower max server memory
CREATE TABLE #memvalue (name NVARCHAR(100), minimum INT, maximum INT, config_value INT, run_value INT)
INSERT INTO #memvalue
EXEC sp_configure 'max server memory'
GO

SP_CONFIGURE 'MAX SERVER MEMORY', 256
GO
RECONFIGURE WITH OVERRIDE
GO

--Revert max server memory
DECLARE @mem BIGINT
SELECT @mem = config_value FROM #memvalue

EXEC SP_CONFIGURE 'MAX SERVER MEMORY', @mem
GO
RECONFIGURE WITH OVERRIDE
GO

DROP TABLE #memvalue