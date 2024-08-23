create schema test
go

CREATE SEQUENCE Test.CountBy1
    START WITH 1
    INCREMENT BY 1 ;
GO

---
CREATE SEQUENCE Test.DecSeq
    AS decimal(3,0) 
    START WITH 125
    INCREMENT BY 25
    MINVALUE 100
    MAXVALUE 200
    CYCLE
    CACHE 3

----

SELECT NEXT VALUE FOR Test.DecSeq;


--------

-- Create a table
CREATE TABLE Test.Orders
    (OrderID int PRIMARY KEY,
    Name varchar(20) NOT NULL,
    Qty int NOT NULL);
GO

-- Create a sequence
CREATE SEQUENCE Test.CountBy1
    START WITH 1
    INCREMENT BY 1 ;
GO

-- Insert three records
INSERT Test.Orders (OrderID, Name, Qty)
    VALUES (NEXT VALUE FOR Test.CountBy1, 'Tire', 2) ;
INSERT test.Orders (OrderID, Name, Qty)
    VALUES (NEXT VALUE FOR Test.CountBy1, 'Seat', 1) ;
INSERT test.Orders (OrderID, Name, Qty)
    VALUES (NEXT VALUE FOR Test.CountBy1, 'Brake', 1) ;
GO

-- View the table
SELECT * FROM Test.Orders ;

-------------------------
use adventureworks
go

create schema sales
go

CREATE SEQUENCE Sales.SeqOrderIDs AS INT
MINVALUE 1
CYCLE;
go
SELECT NEXT VALUE FOR Sales.SeqOrderIDs;
go
ALTER SEQUENCE Sales.SeqOrderIDs
RESTART WITH 1;
go
IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders;
GO
CREATE TABLE Sales.MyOrders
(
orderid INT NOT NULL
CONSTRAINT PK_MyOrders_orderid PRIMARY KEY,
custid INT NOT NULL
CONSTRAINT CHK_MyOrders_custid CHECK(custid > 0),
empid INT NOT NULL
CONSTRAINT CHK_MyOrders_empid CHECK(empid > 0),
orderdate DATE NOT NULL
);

INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate) VALUES
(NEXT VALUE FOR Sales.SeqOrderIDs, 1, 2, '20120620'),
(NEXT VALUE FOR Sales.SeqOrderIDs, 1, 3, '20120620'),
(NEXT VALUE FOR Sales.SeqOrderIDs, 2, 2, '20120620');

INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate)
SELECT
NEXT VALUE FOR Sales.SeqOrderIDs  OVER(ORDER BY orderid),
custid, empid, orderdate
FROM Sales.myOrders
WHERE custid = 1;

SELECT * FROM Sales.MyOrders;

