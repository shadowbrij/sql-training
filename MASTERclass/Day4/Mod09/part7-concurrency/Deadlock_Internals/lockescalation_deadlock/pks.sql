USE [AdventureWorks2008R2]
GO

/****** Object:  Index [PK_Customer_CustomerID]    Script Date: 10/31/2012 14:01:09 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Sales].[Customer]') AND name = N'PK_Customer_CustomerID')
ALTER TABLE [Sales].[Customer] DROP CONSTRAINT [PK_Customer_CustomerID]
GO

USE [AdventureWorks2008R2]
GO

/****** Object:  Index [PK_Customer_CustomerID]    Script Date: 10/31/2012 14:01:09 ******/
ALTER TABLE [Sales].[Customer] ADD  CONSTRAINT [PK_Customer_CustomerID] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)ON psc_Customer(CustomerID)
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary key (clustered) constraint' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'CONSTRAINT',@level2name=N'PK_Customer_CustomerID'
GO


