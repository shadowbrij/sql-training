Note initial buffer pool usage

1.	Open SQL Server Configuration Manager and select SQL Server Services in the left pane.
2.	In the right pane, right click on SQL Server (MSSQLSERVER) and click restart. This will restart the SQL Server services and clears all memory.
3.	Open SQL Server Management Studio from start menu and connect to the default instance using windows authentication.
4.	Open the MonitorBufferPool.sql Transact-SQL file from the folder D:\LabFiles\Lab04\Lab04A\Ex01\Starter.
5.	Select the code under the comment Get buffer pool utilization by each database and click Execute. In the Results pane, note the memory utilization in the buffer pool for each database and specifically forAdventureWorks2014.



Run Workload and Monitor Buffer Pool

1.	In MonitorBufferPool.sql Query window, select the code under the comment Get buffer pool utilization by each object in a database and click Execute. 
2.	In the Results pane, observe the memory utilization in the buffer pool for each object in AdventureWorks2014 database.
3.	Select the code under the comment Get clean and dirty pages count in a database and click Execute. Note the output in the Results pane.
4.	Open the ReadWorkload.sql Transact-SQL file from the folder D:\LabFiles\Lab04\Lab04A\Ex01\Starter and click Execute. 
5.	In MonitorBufferPool.sql Query window, select the code under the comment Get clean and dirty pages count in a database and click Execute. Observe the Pages column value increases for the row where Page_Status column value is Clean.
6.	Open the WriteWorkload.sql Transact-SQL file from the folder D:\LabFiles\Lab04\Lab04A\Ex01\Starter and click Execute..
7.	In MonitorBufferPool.sql Query window, select the code under the comment Get clean and dirty pages count in a database and click Execute. 
8.	Observe the Pages column value increased for the row where Page_Status column value is Dirty.
9.	Select the code under the comment Get buffer pool utilization by each object in a database and click Execute. 
10.	In the Results pane, observe the output and compare with results from step 1.


Clear buffer pool usage for a database
1. In MonitorBufferPool.sql Query window, select the code under the comment Get clean and dirty pages count in a database and click Execute. Note the output in the Results pane.
2.	Select the code under the comment clear clean pages and click Execute..
3.	Select the code under the comment Get clean and dirty pages count in a database and click Execute. Observe the row with Page_Status value Clean does not exist in the output in the Results pane.
4.	Select the code under the comment Run Checkpoint and click Execute..
5.	Select the code under the comment Get clean and dirty pages count in a database and click Execute. Observe that the row with Page_Status value Clean now has some value for Pages column.
6.	Repeat step 2 to clear all pages of AdventureWorks2014 from the buffer pool.
7.	Select the code under the comment Get clean and dirty pages count in a database and click Execute. Observe that no rows will be returned in the output in the Results pane.
8.	Close SQL Server Management Studio without saving any changes.

