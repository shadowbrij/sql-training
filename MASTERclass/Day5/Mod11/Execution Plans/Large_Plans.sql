USE AdventureWorks
GO

DROP PROCEDURE [Sales].[uspGetDiscountRates] ;
GO
CREATE PROCEDURE [Sales].[uspGetDiscountRates]
(
@ContactId INT
,@SpecialOfferId INT
)
AS
BEGIN TRY
-- determine if sale using special offer exists
IF EXISTS ( SELECT *
FROM [Sales].[Individual] i
INNER JOIN [Sales].[Customer] c
ON i.CustomerID = c.CustomerID
INNER JOIN [Sales].[SalesOrderHeader] soh
ON soh.CustomerID = c.CustomerID
INNER JOIN [Sales].[SalesOrderDetail] sod
ON soh.[SalesOrderID] = sod.[SalesOrderID]
INNER JOIN [Sales].[SpecialOffer] spo
ON sod.[SpecialOfferID] = spo.[SpecialOfferID]
WHERE i.[ContactID] = @ContactId
AND spo.[SpecialOfferID] = @SpecialOfferId )
BEGIN
SELECT c.[LastName] + ', ' + c.[FirstName]
,c.[EmailAddress]
,i.[Demographics]
,spo.[Description]
,spo.[DiscountPct]
,sod.[LineTotal]
,p.[Name]
,p.[ListPrice]
,sod.[UnitPriceDiscount]
FROM [Person].[Contact] c
INNER JOIN [Sales].[Individual] i
ON c.[ContactID] = i.[ContactID]
INNER JOIN [Sales].[Customer] cu
ON i.[CustomerID] = cu.[CustomerID]
INNER JOIN [Sales].[SalesOrderHeader] soh
ON cu.[CustomerID] = soh.[CustomerID]
INNER JOIN [Sales].[SalesOrderDetail] sod
ON soh.[SalesOrderID] = sod.[SalesOrderID]
INNER JOIN [Sales].[SpecialOffer] spo
ON sod.[SpecialOfferID] = spo.[SpecialOfferID]
INNER JOIN [Production].[Product] p
ON sod.[ProductID] = p.[ProductID]
WHERE c.ContactID = @ContactId
AND sod.[SpecialOfferID] = @SpecialOfferId;
END
ELSE
BEGIN
SELECT c.[LastName] + ', ' + c.[FirstName]
,c.[EmailAddress]
,i.[Demographics]
,soh.SalesOrderNumber
,sod.[LineTotal]
,p.[Name]
,p.[ListPrice]
,sod.[UnitPrice]
,st.[Name] AS StoreName
,ec.[LastName] + ', ' + ec.[FirstName] AS SalesPersonName
FROM [Person].[Contact] c
INNER JOIN [Sales].[Individual] i
ON c.[ContactID] = i.[ContactID]
INNER JOIN [Sales].[SalesOrderHeader] soh
ON i.[CustomerID] = soh.[CustomerID]
INNER JOIN [Sales].[SalesOrderDetail] sod
ON soh.[SalesOrderID] = sod.[SalesOrderID]
INNER JOIN [Production].[Product] p
ON sod.[ProductID] = p.[ProductID]
LEFT JOIN [Sales].[SalesPerson] sp
ON soh.SalesPersonID = sp.SalesPersonID
LEFT JOIN [Sales].[Store] st
ON sp.SalesPersonID = st.SalesPersonID
LEFT JOIN [HumanResources].[Employee] e
ON sp.SalesPersonID = e.[EmployeeID]
LEFT JOIN Person.[Contact] ec
ON e.[ContactID] = ec.[ContactID]
WHERE i.[ContactID] = @ContactId;
END
--second result SET
IF @SpecialOfferId = 16
BEGIN
SELECT p.[Name]
,p.[ProductLine]
FROM [Sales].[SpecialOfferProduct] sop
INNER JOIN [Production].[Product] p
ON sop.[ProductID] = p.[ProductID]
WHERE sop.[SpecialOfferID] = 16;
END
END TRY
BEGIN CATCH
SELECT ERROR_NUMBER() AS ErrorNumber
,ERROR_MESSAGE() AS ErrorMessage ;
RETURN ERROR_NUMBER() ;
END CATCH
RETURN 0 ;
;

EXEC [Sales].[uspGetDiscountRates]
@ContactId = 12298, -- int
@SpecialOfferId = 16 -- int