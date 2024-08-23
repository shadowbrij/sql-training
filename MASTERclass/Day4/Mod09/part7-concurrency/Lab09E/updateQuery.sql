USE [Lab09E];
GO
SET NOCOUNT ON
WHILE (1=1) 
BEGIN
    BEGIN
		UPDATE [big_tbl] 
		SET [colInt1] = [colInt1]+1 
		WHERE [id] = 10;

		UPDATE [big_tbl] 
		SET [colInt1] = [colInt1]-1 
		WHERE [id] = 10;
	END
END
GO