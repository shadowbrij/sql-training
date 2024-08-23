-- in query window 1

set transaction isolation level read committed
begin tran
update Person.Contact
set FirstName = 'amit'
where ContactID = 4

-- rollback


-- in another query window

select * from sys.dm_tran_locks
where request_session_id = 55

select * from sys.dm_tran_locks
where request_session_id = 54

select * from sys.dm_tran_locks
where request_session_id = 60


-- in query window 2

set transaction isolation level read committed

--begin tran
--update Person.Contact
--set FirstName = 'amit'
--where ContactID in (1,2,3,4,5)
----rollback

----begin tran
--update Person.Contact
--set FirstName = 'amit'
--where ContactID < 6


-- in query windows 3

select * from Person.Contact
where ContactID = 2


begin tran
update Person.Contact
set FirstName = 'amit'
where ContactID = 2
--rollback