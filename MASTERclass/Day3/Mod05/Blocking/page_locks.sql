
truncate table test
USE tempdb
set nocount on
--TEST 1
DECLARE @rows INT = 1000000
--TEST 2
--DECLARE @rows INT = 370000
--TEST 3
--DECLARE @rows INT = 375000
---- Create small table
IF EXISTS   (   SELECT  * 
                FROM    sys.tables 
                WHERE   name = 'Test'
            )
BEGIN
    DROP TABLE Test;
END;

CREATE TABLE Test 
(
    Column1 INT 
);

--CREATE TABLE Test 
--(
--    Column1 INT, Column2 INT, Column3 INT, Column4 INT, Column5 INT, Column6 INT, Column7 char(200) 
--);

---- insert data into a table, however you like.  Lots of it.  I started with a million rows.
DECLARE @counter INT = 1;

WHILE @counter < @rows
BEGIN
  INSERT INTO Test (Column1)
  VALUES (@counter);
  
  SET @counter += 1;
END;

-----------------
create clustered index cl_1 on test (column1)

---- begin a transaction to update all rows
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN;

SELECT * 
FROM TEST;

-- You should see page locks in the output from this query
SELECT  resource_type
        ,resource_subtype
        ,request_mode
        ,COUNT(*) lock_count
FROM    sys.dm_tran_locks
WHERE   request_session_id = @@SPID
GROUP BY resource_type
        ,resource_subtype
        ,request_mode;
COMMIT TRAN;

--Now truncate the table and try setting @rows to a smaller number
--On my system 370,000 rows (TEST 2) produced row locks (escalated to a table lock) but 375,000 rows (TEST 3) produced page locks