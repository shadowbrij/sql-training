-- make sure you have the 32 bit version of the dll

-- put the dll in c drive of the VM

-- Create  an extended stored procedure in SQL Server

exec sp_addextendedproc  'HeapLeak','C:\HeapLeak.dll'


--dbcc traceon (2551,-1) -- 2551 is used to enable filter dump.
--go

--dbcc traceon (8004,-1) -- 8004 is used to take memory dump on first occurrence of OOM condition
--go

-- Note: Both the trace flags are un-documented

-- MTL/MTR errors:
--SQL Server 2000 
--WARNING: Failed to reserve contiguous memory of Size= 65536. 
--WARNING: Clearing procedure cache to free contiguous memory. 
--Error: 17802 ?Could not create server event thread.? 
--SQL Server could not spawn process_loginread thread.
--SQL Server 2005/2008 
--Failed Virtual Allocate Bytes: FAIL_VIRTUAL_RESERVE 122880

	
-- check VAS
--VAS summary

WITH VASummary(Size,Reserved,Free) AS 
(SELECT 
    Size = VaDump.Size, 
    Reserved =  SUM(CASE(CONVERT(INT, VaDump.Base)^0) 
    WHEN 0 THEN 0 ELSE 1 END), 
    Free = SUM(CASE(CONVERT(INT, VaDump.Base)^0) 
    WHEN 0 THEN 1 ELSE 0 END) 
FROM 
( 
    SELECT  CONVERT(VARBINARY, SUM(region_size_in_bytes)) 
    AS Size, region_allocation_base_address AS Base 
    FROM sys.dm_os_virtual_address_dump  
    WHERE region_allocation_base_address <> 0x0 
    GROUP BY region_allocation_base_address  
 UNION   
    SELECT CONVERT(VARBINARY, region_size_in_bytes), region_allocation_base_address 
    FROM sys.dm_os_virtual_address_dump 
    WHERE region_allocation_base_address  = 0x0 
) 
AS VaDump 
GROUP BY Size)

SELECT SUM(CONVERT(BIGINT,Size)*Free)/1024/1024 AS [Total avail mem, MB] ,CAST(MAX(Size) AS BIGINT)/1024/1024 AS [Max free size, MB]  
FROM VASummary  
WHERE Free <> 0 



-- execute this Extended SP 30 times and leak memory.

exec HeapLeak
go 300

-- check VAS memory again and notice the diffeence

-- Note: 1. SQL Server memory dump will be generated in SQL Server error log folder. 
-- Size of MTL is 256 MB + Max worker threads *.5  in 32-Bit SQL Server.  So approximately 384 MB unless modified using –g switch.

 

DECLARE @idoc int
DECLARE @doc varchar(1000)
SET @doc ='<ROOT>
<Customer CustomerID="VINET" ContactName="Paul Henriot">
 <Order CustomerID="VINET" EmployeeID="5" OrderDate="1996-07-04T00:00:00">
	<OrderDetail OrderID="10248" ProductID="11" Quantity="12"/>
	<OrderDetail OrderID="10248" ProductID="42" Quantity="10"/>
 </Order>
</Customer>
  <Customer CustomerID="LILAS" ContactName="Carlos Gonzlez">
  <Order CustomerID="LILAS" EmployeeID="3" OrderDate="1996-08-16T00:00:00">
  <OrderDetail OrderID="10283" ProductID="72" Quantity="3"/>
 </Order>
 </Customer>
 </ROOT>'
 
 EXEC sp_xml_preparedocument @idoc OUTPUT, @doc
 GO 1000

 -- check VAS again