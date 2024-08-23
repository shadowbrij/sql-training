
ALTER TABLE [Sales].[individual] 
  DROP CONSTRAINT [FK_Individual_Customer_CustomerID]; 

ALTER TABLE [Sales].[salesorderheader] 
  DROP CONSTRAINT [FK_SalesOrderHeader_Customer_CustomerID]; 

ALTER TABLE [Sales].[customeraddress] 
  DROP CONSTRAINT [FK_CustomerAddress_Customer_CustomerID]; 

ALTER TABLE [Sales].[store] 
  DROP CONSTRAINT [FK_Store_Customer_CustomerID]; 

ALTER TABLE [Sales].[individual] 
  WITH CHECK ADD CONSTRAINT [FK_Individual_Customer_CustomerID] FOREIGN KEY( 
  [customerid]) REFERENCES [Sales].[customer]([customerid]) ON DELETE CASCADE; 


ALTER TABLE [Sales].[salesorderheader] 
  WITH CHECK ADD CONSTRAINT [FK_SalesOrderHeader_Customer_CustomerID] FOREIGN 
  KEY([customerid]) REFERENCES [Sales].[customer]([customerid]) ON DELETE 
  CASCADE; 


ALTER TABLE [Sales].[customeraddress] 
  WITH CHECK ADD CONSTRAINT [FK_CustomerAddress_Customer_CustomerID] FOREIGN KEY 
  ([customerid]) REFERENCES [Sales].[customer]([customerid]) ON DELETE CASCADE; 


ALTER TABLE [Sales].[store] 
  WITH CHECK ADD CONSTRAINT [FK_Store_Customer_CustomerID] FOREIGN KEY( 
  [customerid]) REFERENCES [Sales].[customer]([customerid]) ON DELETE CASCADE; 