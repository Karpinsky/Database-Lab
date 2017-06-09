/*
 * ER/Studio Data Architect SQL Code Generation
 * Project :      Model1.DM1
 *
 * Date Created : Saturday, June 10, 2017 00:37:29
 * Target DBMS : Microsoft SQL Server 2014
 */

USE master
go
CREATE DATABASE DeviceDB
go
USE DeviceDB
go
/* 
 * TABLE: Dates 
 */

CREATE TABLE Dates(
    id             bigint    IDENTITY(1,1),
    lab_id         bigint    NOT NULL,
    employee_id    bigint    NOT NULL,
    return_date    date      NOT NULL,
    get_date       date      NOT NULL
                   CHECK (get_date > return_date),
    CONSTRAINT PK8 PRIMARY KEY NONCLUSTERED (id, lab_id, employee_id)
)
go



IF OBJECT_ID('Dates') IS NOT NULL
    PRINT '<<< CREATED TABLE Dates >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE Dates >>>'
go

/* 
 * TABLE: Device 
 */

CREATE TABLE Device(
    serial_number       bigint             IDENTITY(1,1),
    name                nvarchar(50)       NOT NULL,
    maker               nvarchar(50)       NOT NULL,
    inventory_number    nchar(18)          NOT NULL
                        CHECK (inventory_number LIKE 00inventory_number),
    image_binary        varbinary(2000)    NOT NULL,
    image_name          nvarchar(50)       NOT NULL,
    parameters          nvarchar(255)      NOT NULL,
    trade_mark          nvarchar(50)       NOT NULL,
    type                nvarchar(50)       NOT NULL,
    CONSTRAINT PK4 PRIMARY KEY NONCLUSTERED (serial_number, name)
)
go



IF OBJECT_ID('Device') IS NOT NULL
    PRINT '<<< CREATED TABLE Device >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE Device >>>'
go

/* 
 * TABLE: Employee 
 */

CREATE TABLE Employee(
    employee_id    bigint          IDENTITY(1,1),
    position       nvarchar(50)    NOT NULL,
    first_name     nvarchar(50)    NOT NULL,
    middle_name    varchar(50)     NULL,
    last_name      nvarchar(50)    NOT NULL,
    CONSTRAINT PK9 PRIMARY KEY NONCLUSTERED (employee_id)
)
go



IF OBJECT_ID('Employee') IS NOT NULL
    PRINT '<<< CREATED TABLE Employee >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE Employee >>>'
go

/* 
 * TABLE: Lab 
 */

CREATE TABLE Lab(
    lab_id    bigint          IDENTITY(1,1),
    name      nvarchar(50)    NOT NULL,
    CONSTRAINT PK7 PRIMARY KEY NONCLUSTERED (lab_id)
)
go



IF OBJECT_ID('Lab') IS NOT NULL
    PRINT '<<< CREATED TABLE Lab >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE Lab >>>'
go

/* 
 * TABLE: LabDevice 
 */

CREATE TABLE LabDevice(
    lab_id           bigint          NOT NULL,
    serial_number    bigint          NOT NULL,
    name             nvarchar(50)    NOT NULL,
    CONSTRAINT PK6 PRIMARY KEY NONCLUSTERED (lab_id, serial_number, name)
)
go



IF OBJECT_ID('LabDevice') IS NOT NULL
    PRINT '<<< CREATED TABLE LabDevice >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE LabDevice >>>'
go

/* 
 * TABLE: Maker 
 */

CREATE TABLE Maker(
    name            nvarchar(50)    NOT NULL,
    adress          nvarchar(50)    NOT NULL,
    phone_number    nchar(20)       NOT NULL,
    CONSTRAINT PK5 PRIMARY KEY NONCLUSTERED (name)
)
go



IF OBJECT_ID('Maker') IS NOT NULL
    PRINT '<<< CREATED TABLE Maker >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE Maker >>>'
go

/* 
 * TABLE: Dates 
 */

ALTER TABLE Dates ADD CONSTRAINT RefLab18 
    FOREIGN KEY (lab_id)
    REFERENCES Lab(lab_id)
go

ALTER TABLE Dates ADD CONSTRAINT RefEmployee19 
    FOREIGN KEY (employee_id)
    REFERENCES Employee(employee_id)
go


/* 
 * TABLE: Device 
 */

ALTER TABLE Device ADD CONSTRAINT RefMaker4 
    FOREIGN KEY (name)
    REFERENCES Maker(name)
go


/* 
 * TABLE: LabDevice 
 */

ALTER TABLE LabDevice ADD CONSTRAINT RefLab16 
    FOREIGN KEY (lab_id)
    REFERENCES Lab(lab_id)
go

ALTER TABLE LabDevice ADD CONSTRAINT RefDevice17 
    FOREIGN KEY (serial_number, name)
    REFERENCES Device(serial_number, name)
go


