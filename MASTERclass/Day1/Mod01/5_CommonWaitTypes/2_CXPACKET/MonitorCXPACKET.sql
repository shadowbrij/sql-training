-- Monitor CXPACKET
SELECT *
FROM sys.dm_os_waiting_tasks
WHERE
	wait_type LIKE '%CXPACKET%'
GO