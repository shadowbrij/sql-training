CREATE INDEX idx_Person_FirstNameLastNameTitleType
ON Person.Person (FirstName, LastName, Title, PersonType)

CREATE INDEX idx_Person_TypeTitle
ON Person.Person (PersonType, Title)


DROP INDEX idx_Person_FirstNameLastNameTitleType on Person.Person

DROP INDEX idx_Person_TypeTitle on Person.Person

DROP INDEX idx_Person_FirstNameLastNameTitleType on Person.Person