select * from employees
select * from sales

--explicit commit
begin transaction
	update sales
	set employeeid=(select managerid from employees where employeeid=sales.employeeid)
	where employeeid=2

	delete employees
	where employeeid=2
commit tran

--explicit rollback
select * from employees
select * from sales
begin transaction
	update sales
	set employeeid=(select managerid from employees where employeeid=sales.employeeid)
	where employeeid=1
	
	delete employees
	where employeeid=1
	select * from employees
	select * from sales
	if(@@ROWCOUNT!=0)
		rollback transaction
	else
		commit transaction
	select * from employees
	select * from sales

--naming  transactions
select * from employees
select * from sales
begin transaction 
	update sales
	set employeeid=(select managerid from employees where employeeid=sales.employeeid)
	where employeeid=3
	select * from employees
	select * from sales
	save transaction t1
	delete employees
	where employeeid=3	
	select * from employees
	select * from sales
	rollback tran t1
	select * from employees
	select * from sales
	rollback tran 
	select * from employees
	select * from sales

--distributed transactions

begin distributed transaction
	update sales
	set employeeid=(select managerid from employees where employeeid=sales.employeeid)
	where employeeid=3
	delete from [honey\SQL2012SECOND].db2.dbo.salesorders
	if (@@ROWCOUNT!=0)
		rollback tran
	else
		commit tran

--dcomcnfg
--set xact_abort on
