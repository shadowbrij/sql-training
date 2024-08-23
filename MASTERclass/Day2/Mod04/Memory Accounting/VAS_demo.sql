
-- put the dll in c drive of the VM

-- Create  an extended stored procedure in SQL Server

exec sp_addextendedproc  'HeapLeak','C:\HeapLeak.dll'

	
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
-- open the dll execution file