# kafka-docker-plain

## How to Run

- cd into the directory of this repo and run 
  `docker-compose up`
- Once the services will be up and running, you can check the status
  `docker ps`
- Connect to the mssql server pod using any of the GUI tool and execute the below commnds to create test data base and tables and insert some dummy data into it
also ebales the cdc on database and tables

```

## MSSQL 

Create database test;

Use test;
GO  
EXEC sys.sp_cdc_enable_db  
GO 

CREATE TABLE Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);


INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
VALUES (123, 'foo', 'bar', 'India', 'hyderabad');

INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
VALUES (456, 'raj', 'shekar', 'Germany', 'Hamburg');

CREATE TABLE Employees (
    Name varchar(255),
    Id Int,
    Manager varchar(255),
    Domain varchar(255)
);

INSERT INTO Employees (Name, Id, Manager, Domain)
VALUES ('Raj', '123', 'foo', 'data');

INSERT INTO Employees (Name, Id, Manager, Domain)
VALUES ('shekar', '456', 'foo', 'frontend');

INSERT INTO Employees (Name, Id, Manager, Domain)
VALUES ('foo', '456', 'bar', 'backend');

USE test;  
GO  
  
EXEC sys.sp_cdc_enable_table  
@source_schema = N'dbo',  
@source_name   = N'Employees',  
@role_name     = N'MyRole' 
GO

EXEC sys.sp_cdc_enable_table  
@source_schema = N'dbo',  
@source_name   = N'Persons',  
@role_name     = N'MyRole' 
GO

```
- Now its time to run the connectors
- there is a file named `kafkaconnect.rest` which is a visual studio code plugin to make REST calls. Install the rest client plugin in vs code.
- You need to make a rest call to kafka connect API to start the connector.
- Let me know if you face any issues or for any doubts
