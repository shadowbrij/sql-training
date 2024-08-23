------------------------------------------------------------------
-- Demo: Queries get blocked while reading data that is not locked
------------------------------------------------------------------

USE AdventureWorks2008R2
GO


-- step 1
-- Connection 1

USE AdventureWorks2008R2
GO


BEGIN TRAN

SELECT * FROM DatabaseLog WITH (XLOCK)
WHERE [SCHEMA] = 'dbo'
 
-- step 2
-- Connection 1

 
SELECT  TL.resource_type,
        TL.request_mode,
        TL.request_status,
        TL.resource_description,
        TL.resource_associated_entity_id
FROM    sys.dm_tran_current_transaction TCT
JOIN    sys.dm_tran_locks TL
        ON  TL.request_owner_id = TCT.transaction_id;


-- step 3
-- Connection 2

USE AdventureWorks2008R2
GO

SELECT * FROM DatabaseLog
WHERE [SCHEMA] = 'production'
GO

-- step 4
-- Connection 1
ROLLBACK TRAN
GO