/********************
SETUP
*********************/

---------------------
--STEP 1 
---------------------

---------------------
--STEP 2
---------------------
--Create table tempTAB 
USE [tempdb]
GO
CREATE TABLE [dbo].[tempTAB](
	[SID] [bigint] NOT NULL,
	[PID] [int] NOT NULL,
	[FNAME] [varchar](50) NOT NULL,
	[LNAME] [varchar](50) NOT NULL,
	[ADDRESS] [varchar](max) NOT NULL,
	[SALARY] [int] NOT NULL)
GO

----------------------
--STEP 3
----------------------
--Create Stored Procedure to populate data on tempTAB
USE [tempdb];
GO
CREATE PROCEDURE [dbo].[sp_populate_data]
@TAB AS NVARCHAR(50), @ROW AS INT
AS
SET NOCOUNT ON
DECLARE @RowCount INT 
DECLARE @RowMax INT
DECLARE @RowString INT 
DECLARE @SQL1 NVARCHAR(200)
SET @SQL1 = N'SELECT @RowCount1=COUNT(1) FROM '+@TAB
EXEC sp_executesql @SQL1, N'@RowCount1 INT OUTPUT', @RowCount1 = @RowCount OUTPUT
SET @RowMax = @RowCount + @ROW
WHILE @RowCount < @RowMax 
BEGIN
SET @RowString = CAST(@RowCount AS INT) 
DECLARE @FNAME VARCHAR(30)
SET @FNAME = (SELECT CAST(CAST(newid() as binary(16)) as varchar(8)))
DECLARE @num1 VARCHAR(20)
SET @num1 = (SELECT CONVERT(INT, (2000+1)*RAND()))
DECLARE @name1 VARCHAR(50)
SET @name1 = @FNAME +'_'+ @num1;
--SELECT @name1;
DECLARE @LNAME VARCHAR(30)
SET @LNAME = (SELECT CAST(CAST(newid() as binary(16)) as varchar(8)))
DECLARE @num2 VARCHAR(20)
SET @num2 = (SELECT CONVERT(INT, (2000+1)*RAND()))
DECLARE @name2 VARCHAR(50)
SET @name2 = @LNAME +'_'+ @num2;
--SELECT @name2;
DECLARE @ADDRESS VARCHAR(200)
SET @ADDRESS = (SELECT CAST(CAST(newid() as binary(16)) as varchar(50)))
--SELECT @ADDRESS
DECLARE @SID INT
SET @SID = (REPLICATE('0', 10 - DATALENGTH(@RowString)) + @RowString)
--SELECT @SID;
DECLARE @PID INT
SET @PID = (SELECT CONVERT(INT, (200000+1)*RAND()))
--SELECT @PID;
DECLARE @SALARY INT
SET @SALARY = (SELECT CONVERT(INT, (200000+1)*RAND()))
DECLARE @SQL2 NVARCHAR(MAX)
SET @SQL2 = N'INSERT INTO '+@TAB+ N' VALUES(
@SID11,@PID11,@name11,@name22,@ADDRESS11,@SALARY11);'
DECLARE @PARAM NVARCHAR(MAX)
SET @PARAM = N'@SID11 INT,@PID11 INT,@name11 VARCHAR(50),@name22 VARCHAR(50),@ADDRESS11 VARCHAR(50),@SALARY11 INT'
EXEC sp_executesql @SQL2, @PARAM, @SID11 = @SID, @PID11 = @PID, 
@name11 = @name1, @name22 = @name2, @ADDRESS11 = @ADDRESS, @SALARY11 = @SALARY 
--EXEC sp_executesql @SQL2
SET @RowCount = @RowCount + 1 
END
GO
