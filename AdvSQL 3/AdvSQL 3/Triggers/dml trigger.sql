create database dbtest
go

use dbtest
go

ex:1:

create table stock(ino char(3),idesc varchar(20),qty int)
go

--insert following data

ino	idesc	qty
--------------------
I1	Item1	400
I2	Item2	300

create table orders
(ono int,odate date,custno int,ino char(3),qty int)
go


create trigger trgmodifystock
on orders
for insert
as
begin
	begin tran
	declare @id char(2),@qtyStock int,@qtyOrd int

	select @id=ino from inserted
	select @qtyStock=qty from stock where ino=@id
	select @qtyOrd=qty from inserted

	if(@qtyOrd>@qtyStock)
	     begin
		print 'Quantity ordered should not exceed stock limit'
		rollback tran
	     end
	else
		begin
			update stock set qty=qty-@qtyOrd where ino=@id
			commit tran
		end
end
-----------------------------
ex:2

CREATE TABLE sal_info(grade char(1), bsal numeric(18,0))

INSERT INTO sal_info
SELECT 'A',1000 UNION ALL
SELECT 'B',2000 UNION ALL
SELECT 'C',3000

CREATE TABLE emp(emp_no int,emp_name varchar(10),dept_no int,
grade char(1),bsal numeric(18,0),doj datetime)

alter TRIGGER tr_emp ON emp
FOR INSERT,UPDATE
AS
DECLARE  @sal numeric(18,0)
SELECT @sal=sal_info.bsal from sal_info,inserted 
Where inserted.grade=sal_info.grade

UPDATE emp set bsal=@sal from inserted
Where emp.emp_no=inserted.emp_no

INSERT INTO emp VALUES(100,'Arvind',30,'B',null,getdate())

select * from emp

update emp set grade='C' where emp_no=100
-----------------------


