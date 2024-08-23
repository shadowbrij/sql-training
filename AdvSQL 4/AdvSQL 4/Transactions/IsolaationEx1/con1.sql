--Read UNCOMMITTED: Dirty reads possible

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO

SELECT * FROM Employees

BEGIN TRANSACTION
  UPDATE employees
	set Title='All Titles Changed'
  waitfor delay '00:00:30'
  select * from employees

  if @@rowcount>0
	rollback
  else
	commit

select * from employees
GO
--READ COMMITTED: prevents dirty reads(default)
set transaction isolation level read committed;
go

--BEGIN TRANSACTION
--  select * from employees
--  waitfor delay '00:00:30'
--  select * from employees
--commit

	----update employees set title='x'

BEGIN TRANSACTION
  select * from employees
  UPDATE employees
	set Title='All Titles Changed'
  waitfor delay '00:00:30'
  select * from employees

  if @@rowcount>0
	rollback
  else
	commit
  select * from employees

--repeatable read

set transaction isolation level repeatable read;
go

BEGIN TRANSACTION
  select * from employees
  waitfor delay '00:00:30'
  select * from employees
commit

--serializable

set transaction isolation level serializable;
go

BEGIN TRANSACTION
  select * from employees
  waitfor delay '00:00:30'
  select * from employees
commit tran


dbcc useroptions

select * from  sys.dm_tran_locks