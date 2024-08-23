--First create a test database:

-- lets create a new database for testing purpose
create database PartitionLockTest
GO

--Use the new database:

use PartitionLockTest
GO

--Create a partition a function. Using this partition function, we shall create 3 partitions n based on an integer column. Values will be: upto 9999, 10000 to 19999 and 20000 & beyond…

-- Create a partition function
CREATE PARTITION FUNCTION CustPF (int)
AS RANGE RIGHT FOR VALUES (10000,20000)
GO

--Create a partition scheme based on the above function and store all the partitions to PRIMARY filegroup:

-- Create partition scheme
CREATE PARTITION SCHEME CustPS
AS PARTITION CustPF ALL TO ([PRIMARY])
GO

--Next, create a partition table based on the above scheme. The table has 2 columns, COLA & COLB.


-- Create partitioned table
CREATE TABLE dbo.Customer
(COLA int IDENTITY (1,1), COLB INT)
ON CustPS (COLA)
GO

--Next, let us insert 30000 records.

-- Insert data
while 1=1
BEGIN
	INSERT dbo.Customer DEFAULT VALUES
	If @@IDENTITY = 30000
	BREAK;
END

--After the data is inserted, you can very partition details & the data using the following script. It gives you the number of records in each partition.

-- verify parition details

select count(*) from dbo.Customer where $Partition.CustPF(COLA)=1
select count(*) from dbo.Customer where $Partition.CustPF(COLA)=2
select count(*) from dbo.Customer where $Partition.CustPF(COLA)=3



--It is time to test the locking behavior. I suggest you can use 2 separate connections, to test things neatly. (2 query windows). In connection 1 (query window 1), update all records in partition 1. Note that we are not committing the transaction so the locks will be held.

-- in connection 1 (note: we are not closing the transaction)

BEGIN TRAN
UPDATE dbo.Customer
SET COLB = COLA
WHERE COLA <=9999

--In connection 2 (query window 2), observe the locks.

select resource_type,
DB_NAME(resource_database_id) as DBName,
OBJECT_NAME(resource_associated_entity_id) as OjectName,
request_mode,
request_status
from sys.dm_tran_locks

--You shall observe the following output that Customer table has been exclusively (X) locked.

 

--Now, if you try to read any record, from any partition, your query has to wait until the transaction in connection 1 is committed or rolled back.

-- if you try reading from any of the partitions now, the query will wait
-- from connection 2

select * from Customer where COLA = 5000
select * from Customer where COLA = 15000
select * from Customer where COLA = 25000


--Go back to connection 1 and roll back the transaction.

-- roll back the tran
ROLLBACK TRAN

--Now, let us change the default escalation behavior to partition level locking. You can execute the following script in connection 1

-- enable partition level locking
ALTER TABLE dbo.customer
SET (LOCK_ESCALATION = AUTO);


-------------------------------------
-- From books online
-----------------------------------------------
--SET ( LOCK_ESCALATION = { AUTO | TABLE | DISABLE } )
--Specifies the allowed methods of lock escalation for a table.

--AUTO
--This option allows SQL Server Database Engine to select the lock escalation granularity that is appropriate for the table schema.

--If the table is partitioned, lock escalation will be allowed to partition. After the lock is escalated to the partition level, the lock will not be escalated later to TABLE granularity.


--If the table is not partitioned, the lock escalation will be done to the TABLE granularity.


--TABLE
--Lock escalation will be done at table-level granularity regardless whether the table is partitioned or not partitioned. This behavior is the same as in SQL Server 2005. TABLE is the default value.

--DISABLE
--Prevents lock escalation in most cases. Table-level locks are not completely disallowed. For example, when you are scanning a table that has no clustered index under the serializable isolation level, Database Engine must take a table lock to protect data integrity.

-----------------------------------------------


--Let us try the same thing again:

--In connection 1, update all the records in partition 1:

-- in connection 1 (note: we are not closing the transaction)

BEGIN TRAN
UPDATE dbo.Customer
SET COLB = COLA
WHERE COLA <=9999

--In connection 2, observe the locking behavior:

select resource_type,
DB_NAME(resource_database_id) as DBName,
resource_associated_entity_id,
request_mode,
request_status
from sys.dm_tran_locks

--You will observe that exclusive lock is placed on partition this time (HOBT) and IX lock has been placed on the table.


 

--You can always tally the partition number using sys.partitions catalog view

select * from sys.partitions
where OBJECT_ID = OBJECT_ID('customer')

 

--The partitions numbers match.

--Now, if you try to read data from the other 2 partitions that are not locked, your query will go through. Execute this from connection 2.

select * from Customer where COLA = 15000
select * from Customer where COLA = 25000

--Rollback the transaction in connection 1.

-- conenction 1
ROLLBACK TRAN

--That’s it :) – you can clean up by dropping the database.



--If you liked this post, do like us on FaceBook at http://www.FaceBook.com/SQLServerGeeks


--Regards
--@A_Bansal
--@SQLServerGeeks
--http://www.amitbansal.net
