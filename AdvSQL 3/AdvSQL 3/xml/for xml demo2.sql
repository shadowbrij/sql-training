create table emp(empid int,firstname varchar(50),lastname varchar(50))
go

insert into emp values(100,'scott','tiger'),(101,'tata','mchill'),(102,'smith','john')
go

--raw
select empid,firstname,lastname
from emp
for xml raw

--raw element
select empid,firstname,lastname
from emp
for xml raw('Emp'),elements

--raw root
select empid,firstname,lastname
from emp
for xml raw('Emp'),root('Emps'),elements

--auto
select empid,firstname,lastname
from emp
for xml auto,root('Emps'),elements

--path
select empid,firstname,lastname
from emp
for xml path('Emp'),root('Emps')

--path root
select empid as "@Empid",firstname,lastname
from emp
for xml path('Emp'),root('Emps')

--explicit
select
	1 as Tag,
	null as parent,
	empid as [Emp!1!Empid],
	firstname as [Name!2!Firstname!element],
	lastname as [Name!2!Lastname!element]
from emp
union 
select
	2 as tag,
	1 as parent,
	empid,firstname,lastname
from emp
order by [Emp!1!Empid],[Name!2!LastName!element]
for xml explicit,root('Emps')

