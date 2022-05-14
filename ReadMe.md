# kafka-docker-plain
 
https://github.com/vdesabou/kafka-docker-playground/tree/master/connect/connect-ibm-mq-sink

https://github.com/vdesabou/kafka-docker-playground/tree/master/connect/connect-ibm-mq-source

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

-- =========  
-- Enable a Table Specifying Filegroup Option Template  
-- =========  
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

EXEC sys.sp_cdc_start_job;  
GO  



SELECT name, is_cdc_enabled 
FROM sys.databases;

SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA;

SELECT * 
FROM sys.change_tracking_databases 
WHERE database_id=DB_ID('test');

SELECT s.name AS Schema_Name, tb.name AS Table_Name
, tb.object_id, tb.type, tb.type_desc, tb.is_tracked_by_cdc
FROM sys.tables tb
INNER JOIN sys.schemas s on s.schema_id = tb.schema_id
WHERE tb.is_tracked_by_cdc = 1;