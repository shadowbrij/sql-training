-- make sure you have the 64 bit version of the dll

-- put the dll in c drive of the VM

-- Create  an extended stored procedure in SQL Server

exec sp_addextendedproc  'HeapLeak','C:\HeapLeak.dll'


dbcc traceon (2551,-1) -- 2551 is used to enable filter dump.
go

dbcc traceon (8004,-1) -- 8004 is used to take memory dump on first occurrence of OOM condition
go

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
 GO 10000

 -- check VAS again

 -- lets create a dump to analyaze memory...

--From inside SQL Server, you can create a dump using two different methods. 
--First, to create a manual dump immediately, use the following undocumented command:

-- DBCC STACKDUMP

-- This will create a memory dump in the LOG directory of your SQL Server instance installation.  To enable this method to create a FULL DUMP, you must turn on trace flags 2544 and 2546:

dbcc traceon(2544, -1) 
go 

dbcc traceon(2546, -1) 
go 

dbcc stackdump

-- To create only a minidump, enable trace flag 2546.  To create a full-filtered dump, use trace flag 2551.


--Step 1 (Load the memory dump file to debugger):

 

--Open Windbg .  Choose File menu –> select Open crash dump –>Select the Dump file (SQLDump000#.mdmp)

 

--Note : You will find SQLDump000#.mdmp in your SQL Server error log when you get the Exception or assertion.

 

--Step 2 (Set the symbol path to Microsoft symbols server):

 

--on command window type 

 

--.sympath srv*c:\Websymbols*http://msdl.microsoft.com/download/symbols;

 

--Step 3 (Load the symbols from Microsoft symbols server):

 

--Type .reload /f and hit enter. This will force debugger to immediately load all the symbols.

 

 

--Step 4 (check if symbols are loaded):

 

--Verify if symbols are loaded for  SQL Server by using the debugger command lmvm

 



--:028> lmvm sqlservr

--start    end        module name

--01000000 02ba8000   sqlservr   (pdb symbols)          c:\websymbols\sqlservr.pdb\93AACB610C614E1EBAB0FFB42031691D2\sqlservr.pdb

--    Loaded symbol image file: sqlservr.exe

--    Mapped memory image file: C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn\sqlservr.exe

--    Image path: C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn\sqlservr.exe

--    Image name: sqlservr.exe

--    Timestamp:        Fri Oct 14 15:35:29 2005 (434F82E9)

--    CheckSum:         01B73B9B

--    ImageSize:        01BA8000

--    File version:     2005.90.1399.0

--    Product version:  9.0.1399.0

--    File flags:       0 (Mask 3F)

--    File OS:          40000 NT Base

--    File type:        1.0 App

--    File date:        00000000.00000000

--    Translations:     0409.04e4

--    CompanyName:      Microsoft Corporation

--    ProductName:      Microsoft SQL Server

--    InternalName:     SQLSERVR

--    OriginalFilename: SQLSERVR.EXE

--    ProductVersion:   9.00.1399.06

--    FileVersion:      2005.090.1399.00

--    FileDescription:  SQL Server Windows NT

--    LegalCopyright:   © Microsoft Corp. All rights reserved.

--    LegalTrademarks:  Microsoft® is a registered trademark of Microsoft Corporation. Windows(TM) is a trademark of Microsoft Corporation

--    Comments:         NT INTEL X86

 

--Step 5 : (!address to display the memory information)

 

--Use !address command to display the memory information of the process from dump.

 

 

--0:028> !address -summary

 

--——————– Usage SUMMARY ————————–

--    TotSize (      KB)   Pct(Tots) Pct(Busy)   Usage

--   686a7000 ( 1710748) : 81.58%    81.80%    : RegionUsageIsVAD

--     579000 (    5604) : 00.27%    00.00%    : RegionUsageFree

--    4239000 (   67812) : 03.23%    03.24%    : RegionUsageImage

--     ea6000 (   15000) : 00.72%    00.72%    : RegionUsageStack

--      1e000 (     120) : 00.01%    00.01%    : RegionUsageTeb

---------   122d0000 (  297792) : 14.20%    14.24%    : RegionUsageHeap

--          0 (       0) : 00.00%    00.00%    : RegionUsagePageHeap

--       1000 (       4) : 00.00%    00.00%    : RegionUsagePeb

--       1000 (       4) : 00.00%    00.00%    : RegionUsageProcessParametrs

--       1000 (       4) : 00.00%    00.00%    : RegionUsageEnvironmentBlock

--       Tot: 7fff0000 (2097088 KB) Busy: 7fa77000 (2091484 KB)

 

--——————– Type SUMMARY ————————–

--    TotSize (      KB)   Pct(Tots)  Usage

--     579000 (    5604) : 00.27%   : <free>

--    4239000 (   67812) : 03.23%   : MEM_IMAGE

--     5fc000 (    6128) : 00.29%   : MEM_MAPPED

--   7b242000 ( 2017544) : 96.21%   : MEM_PRIVATE

 

--——————– State SUMMARY ————————–

--    TotSize (      KB)   Pct(Tots)  Usage

--   1b7bd000 (  450292) : 21.47%   : MEM_COMMIT

--     579000 (    5604) : 00.27%   : MEM_FREE

--   642ba000 ( 1641192) : 78.26%   : MEM_RESERVE

 

----------------Largest free region: Base 00000000 – Size 00010000 (64 KB)

 

 

--Look at the RegionUsageHeap it is around 297792 KB and largest free region is just 64KB. We know SQL Server doesn’t use Heap’s extensively so normally the heap allocated by SQL Server will not go beyond few MB. In this case it is consuming around 290 MB and so other components which use MTL can easily fail.



--Let us try to understand why the Heap is around 297792 KB and try to identify if there is  a pattern.

 

--Step 6: (Let us use !heap –s to display summary information about the heap)

 

 

--0:028> !heap -s

--LFH Key                   : 0x672ddb11

--  Heap     Flags   Reserv  Commit  Virt   Free  List   UCR  Virt  Lock  Fast 

--                    (k)     (k)    (k)     (k) length      blocks cont. heap 

--—————————————————————————–

--000d0000 00000002    1024    896    896      6     1     1    0      0   L  

--001d0000 00008000      64     12     12     10     1     1    0      0      

--002c0000 00001002    1088     96     96      2     1     1    0      0   L  

--002e0000 00001002      64     52     52      3     2     1    0      0   L  

--007c0000 00001002      64     64     64     56     1     0    0      0   L  

--00d10000 00001002     256     24     24      8     1     1    0      0   L  

--340b0000 00001002      64     28     28      1     0     1    0      0   L  

--340c0000 00041002     256     12     12      4     1     1    0      0   L  

--342a0000 00000002    1024     24     24      3     1     1    0      0   L  

--34440000 00001002      64     48     48     40     2     1    0      0   L  

--61cd0000 00011002     256     12     12      4     1     1    0      0   L  

--61d10000 00001002      64     16     16      7     1     1    0      0   L  

--61d20000 00001002      64     12     12      4     1     1    0      0   L  

--62a90000 00001002    1024   1024   1024   1016     2     0    0      0   L  

--62b90000 00001002    1024   1024   1024   1016     2     0    0      0   L  

--62c90000 00001002     256     40     40      7     1     1    0      0   LFH

--00770000 00001002      64     16     16      2     2     1    0      0   L  

--63820000 00001002      64     24     24      3     1     1    0      0   L  

-------63830000 00001001   10240  10240  10240    160    21     0    0    bad      

-------64230000 00001001   10240  10240  10240    160    21     0    0    bad      

--64c30000 00001001   10240  10240  10240    160    21     0    0    bad      

--65630000 00001001   10240  10240  10240    160    21     0    0    bad      

--66030000 00001001   10240  10240  10240    160    21     0    0    bad      

--66a30000 00001001   10240  10240  10240    160    21     0    0    bad      

--67430000 00001001   10240  10240  10240    160    21     0    0    bad      

--68130000 00001001   10240  10240  10240    160    21     0    0    bad      

--68b30000 00001001   10240  10240  10240    160    21     0    0    bad      

--69530000 00001001   10240  10240  10240    160    21     0    0    bad      

--69f30000 00001001   10240  10240  10240    160    21     0    0    bad      

--6a930000 00001001   10240  10240  10240    160    21     0    0    bad      

--6b330000 00001001   10240  10240  10240    160    21     0    0    bad      

--6bd30000 00001001   10240  10240  10240    160    21     0    0    bad      

--6c730000 00001001   10240  10240  10240    160    21     0    0    bad      

--6d130000 00001001   10240  10240  10240    160    21     0    0    bad      

--6db30000 00001001   10240  10240  10240    160    21     0    0    bad      

--6e530000 00001001   10240  10240  10240    160    21     0    0    bad      

--6ef30000 00001001   10240  10240  10240    160    21     0    0    bad      

--6f930000 00001001   10240  10240  10240    160    21     0    0    bad      

--70330000 00001001   10240  10240  10240    160    21     0    0    bad      

--70d30000 00001001   10240  10240  10240    160    21     0    0    bad      

--7a160000 00001001   10240  10240  10240    160    21     0    0    bad      

--7ab60000 00001001   10240  10240  10240    160    21     0    0    bad      

--7b560000 00001001   10240  10240  10240    160    21     0    0    bad      

--7d0d0000 00001001   10240  10240  10240    160    21     0    0    bad      

--7e030000 00001001   10240  10240  10240    160    21     0    0    bad      

--7ea30000 00001001   10240  10240  10240    160    21     0    0    bad      

--67f90000 00001003     256     16     16     14     1     1    0    bad      

--71850000 00001003     256      4      4      2     1     1    0    bad      

--71890000 00001003     256      4      4      2     1     1    0    bad      

--67fd0000 00001002      64     16     16      4     1     1    0      0   L  

--718d0000 00001003     256     40     40      3     1     1    0    bad      

--71910000 00001003     256      4      4      2     1     1    0    bad      

--71950000 00001003     256      4      4      2     1     1    0    bad      

--71990000 00001003     256      4      4      2     1     1    0    bad      

--67ff0000 00001002      64     16     16      4     1     1    0      0   L  

--719d0000 00001003    1792   1352   1352      5     2     1    0    bad      

--71a10000 00001003     256      4      4      2     1     1    0    bad      

--71a50000 00001003     256      4      4      2     1     1    0    bad      

--71a90000 00001002      64     16     16      1     0     1    0      0   L  

--—————————————————————————–

 

 

--If you look at the above out put you can clearly identify a pattern. There are multiple created and each of them is 10 MB. But how to identify who actually created them?

 

--Step 7:

 

--Let us pickup one of the heap which is 10 MB and display all the entries (allocations) with in this 10 MB heap using !heap with –h parameter

 

--Heap I have picked is 63830000.

 

 

--0:028> !heap -h 63830000

--Index   Address  Name      Debugging options enabled

--19:   63830000 

--    Segment at 63830000 to 64230000 (00a00000 bytes committed)

--    Flags:                00001001

--    ForceFlags:           00000001

--    Granularity:          8 bytes

--    Segment Reserve:      00100000

--    Segment Commit:       00002000

--    DeCommit Block Thres: 00000200

--    DeCommit Total Thres: 00002000

--    Total Free Size:      00005048

--    Max. Allocation Size: 7ffdefff

--    Lock Variable at:     00000000

--    Next TagIndex:        0000

--    Maximum TagIndex:     0000

--    Tag Entries:          00000000

--    PsuedoTag Entries:    00000000

--    Virtual Alloc List:   63830050

--    UCR FreeList:        63830588

--    FreeList Usage:      00000000 00000000 00000000 00000000

--    FreeList[ 00 ] at 63830178: 6422de88 . 638ad7e0      Unable to read nt!_HEAP_FREE_ENTRY structure at 638ad7e0

--(1 block )

--    Heap entries for Segment00 in Heap 63830000

--        63830608: 00608 . 00040 [01] – busy (40)

--        63830648: 00040 . 02808 [01] – busy (2800)

--        641b6698: 02808 . 02808 [01] – busy (2800)

--        ……………………………………

--        ……………………………………

--        ……………………………………

--        ……………………………………

        

--Step 8: (Let us pickup one of the heap entry (allocation) and try to identify what is in it)

 

 

--0:028> db 641b6698

--641b6698  01 05 01 05 93 01 08 00-49 61 6d 20 66 69 6c 69 ……..Iam fili

--641b66a8  6e 67 20 74 68 65 20 68-65 61 70 20 66 6f 72 20  ng the heap for 

--641b66b8  64 65 6d 6f 20 61 74 20-4d 53 53 51 4c 57 49 4b  demo at MSSQLWIK

--641b66c8  49 2e 43 4f 4d 00 00 00-00 00 00 00 00 00 00 00  I.COM………..

--641b66d8  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  …………….

--641b66e8  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  …………….

--641b66f8  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  …………….

--641b6708  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  …………….

 

--0:028> db 63830648

--63830648  01 05 08 00 89 01 08 00-49 61 6d 20 66 69 6c 69 ……..Iam fili

--63830658  6e 67 20 74 68 65 20 68-65 61 70 20 66 6f 72 20  ng the heap for 

--63830668  64 65 6d 6f 20 61 74 20-4d 53 53 51 4c 57 49 4b  demo at MSSQLWIK

--63830678  49 2e 43 4f 4d 00 00 00-00 00 00 00 00 00 00 00 ………..

--63830688  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 …………….

--63830698  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 …………….

--638306a8  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 …………….

--638306b8  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 …………….

 

 

--Similarly you can dump multiple heap allocations to identify a pattern.

 

--Now if you look at the memory dumped you see a string which might help you to identify the DLL which created the heap. There is a pattern in above heaps. All the heap allocations have below string 

--“Iam filing the heap for demo at MSSQLWI”

 

--Note : You can use L Size to dump more memory using db or dc command’s example db 63830648 L1500

 

--Step 9:

--Let us open the DLL which we loaded in SQL Server for testing using notepad and see if there is string which matches the pattern


-- Yes there is which proves that this DLL’s has caused the leak. In real time you may have to play with different heap allocations to identify the pattern.

 

-- This is one way to find the leaks from the memory dump after the leak has actually happened. It may not be always easy to find a pattern and identify the modules who allocated the memory, In such scenarios  you may have to track the leak using the tools like debug diagnostic tool, UMDH etc.


