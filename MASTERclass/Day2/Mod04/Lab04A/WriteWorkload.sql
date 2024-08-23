USE AdventureWorks2014
GO

EXEC [HumanResources].[uspUpdateEmployeeHireInfo]
	@BusinessEntityID = 10, 
    @JobTitle = 'Research and Development Manager', 
    @HireDate = '2009-05-03', 
    @RateChangeDate = '2014-01-01', 
    @Rate = 20000, 
    @PayFrequency = 10, 
    @CurrentFlag = 1
GO

EXEC [HumanResources].[uspUpdateEmployeeLogin]
    @BusinessEntityID = 10, 
    @OrganizationNode = 0x5AE178,
    @LoginID  = 'adventure-works\michael6',
    @JobTitle = 'Research and Development Manager',
    @HireDate = '2009-05-03',
    @CurrentFlag = 1
GO

EXEC [HumanResources].[uspUpdateEmployeePersonalInfo]
    @BusinessEntityID = 10, 
    @NationalIDNumber = '879342154', 
    @BirthDate = '1984-11-30', 
    @MaritalStatus = 'M', 
    @Gender = 'F'