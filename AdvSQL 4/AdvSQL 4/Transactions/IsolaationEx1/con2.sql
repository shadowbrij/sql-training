set transaction isolation level read uncommitted;
select * from employees

set transaction isolation level read committed;
select * from employees

--begin tran
--update employees set title='Read Committed'
--if(@@ROWCOUNT>0)
--	rollback tran
--else
--	commit tran


update employees set title='Repeatable Read'
--invalid

insert into employees values(null,'v',null,'y','xyz',getdate(),10,30000)
--valid


update employees set title='serializable' where employeeid=1
--invalid

insert into employees values(null,'y',null,'z','xsadfz',getdate(),10,50000)
--invalid

select * from  sys.dm_tran_locks


dbcc useroptions