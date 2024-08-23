create table testtable
(id int,name char(10))
go

insert into testtable values(1,'a'),(2,'b'),(3,'c'),(4,'d'),(5,'e'),(6,'f'),(7,'g'),(8,'h')
go

truncate table testtable
go


select * from testtable

--scope

declare mycursor cursor
local
scroll
for select id from testtable

open mycursor

declare @vid int,@counter int =1
fetch next from mycursor into @vid

while @@FETCH_STATUS=0 and @counter<=5
	begin
		print @vid
		fetch next from mycursor into @vid
		set @counter +=1
	end
-----
Declare @vid int
fetch first from mycursor into @vid
while @@FETCH_STATUS=0
begin
	print @vid
	fetch next from mycursor into @vid
end

close mycursor
deallocate mycursor

--------------------------------
--Static cursor
---------------------------------
select * from testtable

declare mycursor cursor
global
scroll
static
for select id,name from testtable

open mycursor

declare @vid int,@vname char(10)
fetch next from mycursor into @vid,@vname

while @@FETCH_STATUS=0 
	begin
		print Cast(@vid as char) + ' '  +@vname
		fetch next from mycursor into @vid,@vname
		
	end

update testtable set name='x' where  id=5

select * from testtable

fetch first from mycursor into @vid,@vname
while @@FETCH_STATUS=0 
	begin
		print Cast(@vid as char) + ' '  +@vname
		fetch next from mycursor into @vid,@vname
	end
close mycursor
deallocate mycursor
------------------------

--Keyset Cursor
-----------------
select * from testtable

declare mycursor cursor
global
scroll
keyset
for select id,name from testtable

open mycursor

declare @vid int,@vname char(10)
fetch next from mycursor into @vid,@vname

while @@FETCH_STATUS=0 
	begin
		print Cast(@vid as char) + ' '  +@vname
		fetch next from mycursor into @vid,@vname
	end

update testtable set name='x' where  id=5

delete from testtable where id=4

insert into testtable values(9,'i')

select * from testtable


fetch first from mycursor into @vid,@vname
WHILE @@FETCH_STATUS != -1
	BEGIN
		IF @@FETCH_STATUS = -2
			BEGIN
				PRINT ' MISSING! It probably was deleted.';
			END
		ELSE
			BEGIN
				print Cast(@vid as char) + ' '  +@vname
			end
		fetch next from mycursor into @vid,@vname			
	end
close mycursor
deallocate mycursor

alter table testtable
alter column id int not null

alter table testtable
add constraint pk1 primary key(id)