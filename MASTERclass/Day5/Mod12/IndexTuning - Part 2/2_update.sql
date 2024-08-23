USE AdventureWorks
GO


DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE


-- update query

DECLARE @Start_Time	datetime2, 
		@End_Time	datetime2,
		@Total_Time int,
		@Num_Rows int
SELECT @Start_Time = sysdatetime()
UPDATE Person.contact2
	SET FirstName = 'Amit'
SELECT @Num_Rows = @@ROWCOUNT
SELECT @End_Time = sysdatetime()
SELECT  @Total_Time = datediff (MILLISECOND, @Start_Time, @End_Time) 
SELECT @Num_Rows AS 'Rows_Modified', @Total_Time AS 'TOTAL_TIME (ms)'
go

-- Time taken before NC indexes are created				: 141 ms
-- Time taken after all NC indexes are created			: 1705 ms
-- Time taken after cleaning up redundant indexes		: 543 ms
