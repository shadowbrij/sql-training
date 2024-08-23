CREATE TABLE Contact(
		ID int,
       FirstName nvarchar(80),
       LastName nvarchar(80),
       Phone nvarchar(20),
       Title nvarchar(20)
)
GO
-- Populate the table with a few rows.
INSERT INTO Contact
   VALUES(1,N'Amit',N'Bansal',N'917234852342',N'Mr')
INSERT INTO Contact
   VALUES(2, N'SarabPreet',N'Singh',N'759832758475',N'Mr')
INSERT INTO Contact
   VALUES(3, N'Sudhir',N'Rawat',N'729347283423',N'Mr')
INSERT INTO Contact
   VALUES(4,'Karthick',N'PK',N'659837598345',N'Dr')
INSERT INTO Contact
   VALUES(5,'Sandip',N'Pani',N'72348729834234',N'Mr')
GO

select * from Contact