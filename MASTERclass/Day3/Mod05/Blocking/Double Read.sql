

/* SESSION 1 PART 1 */
Use AdventureWorks2008;

BEGIN TRAN
UPDATE  Person.Person
SET     LastName    = 'Raheem_DOUBLE_READ_BLOCK'
WHERE   LastName    = 'Raheem'
AND     FirstName   = 'Kurt';
GO
-- Cut and paste this second half into another browser session and run it from there.

/* SESSION 2 */
USE     AdventureWorks2008;

SELECT   FirstName
        ,LastName
FROM    Person.Person
WHERE   LastName Like 'Raheem%';

/* SESSION 1 PART 2 */
UPDATE  Person.Person
SET     LastName    = 'Raheem_DOUBLE_READ_REAL'
WHERE   LastName    = 'Raheem'
AND     FirstName   = 'Bethany';

COMMIT TRAN;
