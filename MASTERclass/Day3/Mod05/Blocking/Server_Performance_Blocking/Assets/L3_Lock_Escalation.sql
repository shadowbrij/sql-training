----------------------------------------------------------
-- Demo: Lock Escalation
-- File: L3_Lock_Escalation.sql
-- Summary: In this example, 3 different attempts are made to update the table. In each attempt, different numbers of rows are updated in an increasing manner. In attempt 1, one row is updated, thus SQL Server acquires a single RID lock. In attemp2, 4000 rows are being updated, thus SQL Server acquires 4000 RID locks, which is still below the threshold of 5000 locks (as mentioned in Books Online). Attempt 3 tries to update 10000 rows which triggers a lock escalation since it crosses the threshold, thus SQL Server acquires a single table lock, instead of 10000 RID locks.
----------------------------------------------------------

-- create a new database for testing purpose
create database LockEscalation
GO

--Use the new database:
use LockEscalation
GO

-- Create a test table
CREATE TABLE dbo.Customer
(COLA int IDENTITY (1,1), COLB INT)
GO

--Insert 10000 records
while 1=1
BEGIN
	INSERT dbo.Customer DEFAULT VALUES
	If @@IDENTITY = 10000
	BREAK;
END

-- verify data

SELECT * FROM dbo.Customer

-- attempt 1
-- connection 1 (note: we are not closing the transaction)
-- we are updating only one record

BEGIN TRAN
UPDATE dbo.Customer
SET COLB = COLA
WHERE COLA = 1

--In connection 2 (query window 2), observe the locks
-- observe that one exclusive lock has been taken on the row (RID lock)

SELECT
  request_session_id            AS spid,
  resource_type                 AS restype,
  resource_database_id          AS dbid,
  resource_description          AS res,
  resource_associated_entity_id AS resid,
  request_mode                  AS mode,
  request_status                AS status,
  *
FROM sys.dm_tran_locks dtl
INNER JOIN
sys.dm_exec_sessions dess
ON dtl.request_session_id = dess.session_id
WHERE dess.is_user_process = 1
AND request_mode = 'X'

-- connection 1
-- roll back the tran
ROLLBACK TRAN


-- attempt 2
-- connection 1 (note: we are not closing the transaction)
-- This time, 4000 exclusive locks will be taken (4000 RID locks)

BEGIN TRAN
UPDATE dbo.Customer
SET COLB = COLA
WHERE COLA >=1 AND COLA <=4000

--In connection 2 (query window 2), observe the locks
-- observe that 4000 RID locks have been taken

SELECT
  request_session_id            AS spid,
  resource_type                 AS restype,
  resource_database_id          AS dbid,
  resource_description          AS res,
  resource_associated_entity_id AS resid,
  request_mode                  AS mode,
  request_status                AS status,
  *
FROM sys.dm_tran_locks dtl
INNER JOIN
sys.dm_exec_sessions dess
ON dtl.request_session_id = dess.session_id
WHERE dess.is_user_process = 1
AND request_mode = 'X'

-- connection 1
-- roll back the tran
ROLLBACK TRAN


-- attempt 3
-- connection 1 (note: we are not closing the transaction)
-- This time, since the number of ROW locks will cross the threshold, lock escalation will kick in. Table lock will be taken instead of 10000 RID locks.

BEGIN TRAN
UPDATE dbo.Customer
SET COLB = COLA
WHERE COLA >=1 AND COLA <=10000

--In connection 2 (query window 2), observe the locks
-- observe that one exclusive lock has been taken on the table object

SELECT
  request_session_id            AS spid,
  resource_type                 AS restype,
  resource_database_id          AS dbid,
  resource_description          AS res,
  resource_associated_entity_id AS resid,
  request_mode                  AS mode,
  request_status                AS status,
  *
FROM sys.dm_tran_locks dtl
INNER JOIN
sys.dm_exec_sessions dess
ON dtl.request_session_id = dess.session_id
WHERE dess.is_user_process = 1
AND request_mode = 'X'

-- connection 1
-- roll back the tran
ROLLBACK TRAN

-- clean up
USE master
GO

DROP DATABASE LockEscalation
GO
