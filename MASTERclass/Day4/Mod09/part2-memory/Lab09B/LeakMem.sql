SET NOCOUNT ON;
GO
USE AdventureWorks2014
GO
IF (OBJECT_ID('idocs') IS NOT NULL)
	DROP TABLE idocs
CREATE TABLE idocs (idoc INT)
GO

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
 
 --uncomment next line
 --EXEC sp_xml_removedocument @idoc
 
 INSERT INTO idocs VALUES (@idoc)
 GO 10000

 SELECT * FROM idocs