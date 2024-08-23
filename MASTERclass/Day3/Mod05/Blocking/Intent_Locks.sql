-- Intent Locks

USE AdventureWorks2008;
/* SESSION 1 */

BEGIN TRANSACTION;
UPDATE  Production.Product 
SET     SafetyStockLevel = SafetyStockLevel
WHERE   ProductID =1;
--ROLLBACK TRAN;

SELECT   resource_type
        ,resource_subtype 
        ,resource_description
        ,resource_associated_entity_id
        ,request_mode
        ,request_status
FROM    sys.dm_tran_locks
WHERE   request_session_id = @@spid;
GO
-- Cut and paste this second half into another browser session and run it from there.

USE AdventureWorks2008;

/* SESSION 2 */

BEGIN TRANSACTION; 
ALTER TABLE Production.Product
ADD TESTCOLUMN INT NULL;
--ROLLBACK TRANSACTION;
