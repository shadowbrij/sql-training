create table t1
(keycol int,col2 char(10))

insert into t1 values(1,'Version1'),(2,'Version2')

select * from t1

--read uncommited
--1. 
BEGIN TRAN
  UPDATE dbo.T1 SET col2 = 'Version x' WHERE keycol = 2;
  SELECT * from t1

--2. 
rollback tran

--read Committed
BEGIN TRAN
  UPDATE dbo.T1 SET col2 = 'Version x' WHERE keycol = 2;
  SELECT * from t1
  
--2.
COMMIT TRAN

--3.
UPDATE dbo.T1 SET col2 = 'Version 2' WHERE keycol = 2;


--repeatable read

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN
  SELECT col2 FROM dbo.T1 WHERE keycol = 2;
--2.
SELECT col2 FROM dbo.T1 WHERE keycol = 2;
COMMIT TRAN

--repeatable read 2

set transaction isolation level repeatable read 
begin tran
	delete from t1 where keycol=2

select * from t1

2.
rollback tran
select * from t1

--serializable

set transaction isolation level serializable
begin tran
	delete from t1 where keycol=2

select * from t1

2.
rollback tran
select * from t1

