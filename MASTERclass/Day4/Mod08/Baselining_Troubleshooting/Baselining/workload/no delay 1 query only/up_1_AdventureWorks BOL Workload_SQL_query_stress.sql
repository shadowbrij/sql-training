

USE AdventureWorks2012;

UPDATE Person.Address
SET ModifiedDate = GETDATE()
where address.AddressID % 10 = 0;
