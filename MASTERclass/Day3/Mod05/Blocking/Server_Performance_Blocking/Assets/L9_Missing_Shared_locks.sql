----------------------------------------------------------
-- Demo: Missing Shared Locks
----------------------------------------------------------

USE AdventureWorks2008R2
GO


-- step 1
-- Connection 1

USE AdventureWorks2008R2
GO

CREATE TABLE
        dbo.TestTable
        (
        test_key    INTEGER PRIMARY KEY,
        test_value  INTEGER NOT NULL,
        );
GO

INSERT  INTO
        dbo.TestTable (Test_key, Test_value)
VALUES  (1, 50);
GO

-- step 2
-- Connection 1


BEGIN   TRAN

SELECT  Test_key,
        Test_value
FROM    dbo.TestTable WITH (XLOCK);
 
-- step 3
-- Connection 1

 
SELECT  TL.resource_type,
        TL.request_mode,
        TL.request_status,
        TL.resource_description,
        TL.resource_associated_entity_id
FROM    sys.dm_tran_current_transaction TCT
JOIN    sys.dm_tran_locks TL
        ON  TL.request_owner_id = TCT.transaction_id;


-- step 4
-- Connection 2

USE AdventureWorks2008R2
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

SELECT * from TestTable
GO

-- step 5
-- Connection 1
ROLLBACK TRAN
GO

-- step 6
-- clean up

DROP TABLE TestTable
GO
