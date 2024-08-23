/*
	This script will create a stored procedure that can be run
	to list all values collected for a SQL Server performance monitor counter
*/


USE [Baseline];
GO

IF OBJECTPROPERTY(OBJECT_ID('usp_PerfMonReport'), 'IsProcedure') = 1
	DROP PROCEDURE usp_PerfMonReport;
GO

CREATE PROCEDURE dbo.usp_PerfMonReport 
(
	@Counter NVARCHAR(128) = '%'
)
AS

BEGIN;

	SELECT [Counter], [Value], [CaptureDate]
	FROM [dbo].[PerfMonData] 
	WHERE [Counter] like @Counter
	ORDER BY [Counter], [CaptureDate]

END;


/*
exec dbo.usp_PerfMonReport '%Page life expectancy%'
exec dbo.usp_PerfMonReport '%Batch Requests/sec%'
exec dbo.usp_PerfMonReport '%SQLServer:General Statistics:User Connections:%'
*/

