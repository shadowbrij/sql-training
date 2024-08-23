
WITH EmpsCTE AS
(
  SELECT session_id from sys.dm_exec_sessions DES
  where session_id not in ( SELECT session_id from sys.dm_exec_requests DER1)
 
  UNION ALL

  SELECT DER2.session_id
  FROM EmpsCTE AS DER
    JOIN sys.dm_exec_requests AS DER2
      ON DER.session_id = DER2.blocking_session_id
)
SELECT * FROM EmpsCTE;