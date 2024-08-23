USE AdventureWorks
GO
ROLLBACK TRAN
BEGIN TRAN
UPDATE TOP (5000) Person.Contact
SET EmailPromotion = 0


BEGIN TRAN
UPDATE TOP (4900) Person.Contact
SET EmailPromotion = 0

--ROLLBACK TRAN
BEGIN TRAN
UPDATE TOP (4707) Person.Contact
SET EmailPromotion = 0



BEGIN TRAN
UPDATE TOP (4708) Person.Contact
SET EmailPromotion = 0


BEGIN TRAN
UPDATE TOP (4500) Person.Contact
SET EmailPromotion = 0

-- TRACE FLAG 1221 & 1224
-- trace flag 1221 disbales lock escalation comp;etely
-- traec flag 1224 disbales based on lock numbers

select resource_type,
resource_database_id,
resource_description,
resource_associated_entity_id,
request_mode,
request_type,
request_status
from sys.dm_tran_locks
where resource_database_id = DB_ID();



ROLLBACK