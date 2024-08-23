create table products
(prodid int primary key,
prodname char(10),prodqty int)
go

insert into products values(1,'P1',200),(2,'P2',400),(3,'P3',600)
go

--ex:1. procedure to insert a record into products table

create procedure pAddProduct(@pid int,@pn varchar(10),
	@pqty int)
as
begin
	insert into products values(@pid,@pn,@pqty)
end

execution:
1. exec pAddproduct 1,'P1',200
	--inserted successfully

2. exec pAddproduct 1,'P2',400
	--returns a runtime error

--ex: Procedure with error handling and output parameter

alter procedure pAddProduct
	(@pid int,@pn varchar(10),@pqty int,@msg char(50) output)
as
begin
  begin try
	insert into products values(@pid,@pn,@pqty)
	set @msg='Record inserted Successfully!!'
  end try
  begin catch
	if ERROR_NUMBER()=2627
	      set @msg='Producutid already exist.Enter another value'
	else
		set @msg= error_message()
  end catch
end

Execution :
1. 
declare @m char(50)
exec paddproduct 3,'P3',250,@m output
select @m
	--Displays a message as "Record inserted Successfully!!"
2.
declare @m char(50)
exec paddproduct 3,'P4',250,@m output
select @m
	--Displays a message as "Producutid already exist.Enter another value"