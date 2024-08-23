----------------------------------------------------------
-- Demo: Disabling Lock Escalation
-- File: L3_Disabling_Lock_Escalation.sql
-- Summary: In this example, lock escalation has been disabled for the customer table. Attempt 3 tries to update 10000 rows which originally would have triggered a lock escalation. Since lock escalation is disabled, SQL Server acquires 10000 RID locks. This demo is similar to previous demo but attempt 1 & attempt 2 have been ommitted.
----------------------------------------------------------

-- lets create a new database for testing purpose
create database LockEscalation
GO

--Use the new database:
use LockEscalation
GO

-- Create a test table
CREATE TABLE dbo.Customer
(COLA int IDENTITY (1,1), COLB INT)
GO

-- Disable Lock Escalation
ALTER TABLE dbo.customer
SET (LOCK_ESCALATION = DISABLE);

--Insert 10000 records
while 1=1
BEGIN
	INSERT dbo.Customer DEFAULT VALUES
	If @@IDENTITY = 10000
	BREAK;
END

-- verify data

SELECT * FROM dbo.Customer

-- attempt 3 (earlier 2 attempts not required)
-- connection 1 (note: we are not closing the transaction)
-- Since lock escalation is disabled, SQL Server acquires 10000 RID locks.

BEGIN TRAN
UPDATE dbo.Customer
SET COLB = COLA
WHERE COLA >=1 AND COLA <=10000

--In connection 2 (query window 2), observe the locks
-- observe that 10000 RID locks have been acquired

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
