
USE [Lab09E];
GO

SET NOCOUNT ON

DROP INDEX [nci_big_tbl_colInt1] ON [big_tbl]
GO

CREATE NONCLUSTERED INDEX [nci_big_tbl_colInt1] 
ON [big_tbl] ([colInt1])
INCLUDE ([colInt2])
GO

DECLARE @colInt1 INT, @colInt2 INT, @i INT = 1;

WHILE (@i <= 1000) 
BEGIN
    
	SELECT @colInt1 = [colInt1], @colInt2 = [colInt2] 
	FROM [big_tbl] 
	WHERE [colInt1] BETWEEN 10 AND 11;

	SET @i = @i + 1

END
GO
