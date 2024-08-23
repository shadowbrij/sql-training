USE AdventureWorks2012
GO

SELECT * INTO person.person2
from Person.Person
-- drop table person.person2

select * from Person.person2
where lastname = 'Duffy'

create index idx_person2_lastname on person.person2(lastname)
-- drop index idx_person2_lastname on person.person2

select * from Person.person2
where lastname = 'Duffy'


select * from Person.person2 with (index(0))
where lastname = 'Duffy'


select * from Person.person2
where lastname = 'Duffy' AND FirstName ='terri'

create index idx_person2_firstname on person.person2(firstname)
-- drop index idx_person2_firstname on person.person2


select * from Person.person2
where lastname = 'Duffy' AND FirstName ='terri'

create index idx_person2_firstname_lastname on person.person2(firstname,lastname)
-- drop index idx_person2_firstname_lastname on person.person2


select * from Person.person2
where lastname = 'Duffy' AND FirstName ='terri'

create index idx_person2_lastname_firstname on person.person2(lastname,firstname)
-- drop index idx_person2_lastname_firstname on person.person2

select * from Person.person2
where lastname = 'Duffy' AND FirstName ='terri'


-- switch to OR

select * from Person.person2
where lastname = 'Duffy' OR FirstName ='terri'

select * from Person.person2
WITH(INDEX(idx_person2_lastname_firstname))
where lastname = 'Duffy' AND FirstName ='terri'

select * from Person.person2
WITH(INDEX(idx_person2_firstname_lastname))
where lastname = 'Duffy' AND FirstName ='terri'

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
