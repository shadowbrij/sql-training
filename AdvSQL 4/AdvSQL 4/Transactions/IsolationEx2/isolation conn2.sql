--read uncommited
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT col2 FROM dbo.T1 WHERE keycol = 2;


--read commited

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT col2 FROM dbo.T1 WHERE keycol = 2;

--repeatable read/sereializable
UPDATE dbo.T1 SET col2 = 'Version x' WHERE keycol = 1;

2.
 insert into t1 values(2,'version2')

 ----