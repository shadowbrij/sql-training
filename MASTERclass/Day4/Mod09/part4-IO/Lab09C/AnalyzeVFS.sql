USE AdventureWorksDW2014
GO
SELECT Run = CASE WHEN V1.RunNo = 1 THEN 'Without Index' ELSE 'With Index' END, 
	DB_Name(V1.database_id) AS DBName,
	num_reads = V2.num_of_reads - V1.num_of_reads,
	KB_read = (V2.num_of_bytes_read - V1.num_of_bytes_read)/1024,
	io_stalls = V2.io_stall_read_ms - V1.io_stall_read_ms
FROM virtualFileStats V1
INNER JOIN virtualFileStats V2
	ON V1.database_id = V2.database_id
	AND V1.RunNo = V2.RunNo
	AND V1.iteration = 1 AND V2.iteration = 2
	AND V1.file_id = V2.file_id
	AND V1.file_id = 1
ORDER BY DBName
