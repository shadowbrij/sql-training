-- first set the max memory to say, 256 MB (just for the demo)
-- restart SQL if required

-- run this code in a new window
-- and keep monitoring
-- the first one is most important


select type, sum(pages_in_bytes)/1024/1024 as current_total_MB, sum(max_pages_in_bytes)/1024/1024 as max_total_MB from sys.dm_os_memory_objects 
group by type
order by current_total_MB desc
go

select  * from sys.dm_os_memory_objects
where type like '%xml%'

select * from sys.dm_os_memory_clerks
order by pages_kb desc

-- now take this code and run on another window
-- adjust the GO counter if required...
--- OOM errors will start popping up.. keep reviewinf the code in the other window..
-- observe total memory column and max total memory column..
--- you can also run this using SQLCMD...

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
