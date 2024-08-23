USE AdventureWorks2014
GO
IF (OBJECT_ID('timeout_gen') IS NOT NULL)
	DROP PROCEDURE dbo.timeout_gen
GO
CREATE PROCEDURE dbo.timeout_gen @delay NVARCHAR(100) = '00:00:01.000'
AS
BEGIN
	WAITFOR DELAY @delay
END