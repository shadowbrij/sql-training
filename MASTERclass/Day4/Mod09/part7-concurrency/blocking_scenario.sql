use AdventureWorks2008R2
go

-- connection 1

use AdventureWorks2008R2
go
begin tran
update Person.Person
set FirstName = 'amit'
where BusinessEntityID = 1


-- connection 2

use AdventureWorks2008R2
go

select * from Person.Person
