/*
2021-03-08
Setup Radonova Original database
*/

USE master;
GO

--Delete RadonovaOriginalDB if it exists--
DROP DATABASE IF EXISTS RadonovaDB;
GO

--Create and use database--

CREATE DATABASE RadonovaDB;
GO

USE RadonovaDB;
GO

--Drop all tables if they exist--
DROP TABLE IF EXISTS Access.RegularRegular;
GO

DROP TABLE IF EXISTS Access.WorkOrderRegular;
GO

DROP TABLE IF EXISTS Access.WebUserCommission;
GO

DROP TABLE IF EXISTS Access.WebUserRegular;
GO

DROP TABLE IF EXISTS Access.WebUserFolder;
GO

DROP TABLE IF EXISTS Access.FolderCommission;
GO

DROP TABLE IF EXISTS Production.Folder;
GO

DROP TABLE IF EXISTS Production.Commission;
GO

DROP TABLE IF EXISTS Production.WorkOrder;
GO

DROP TABLE IF EXISTS Customer.Regular;
GO

DROP TABLE IF EXISTS Customer.WebUser;
GO

--Delete and create the schemas if they exist and are empty--
DROP SCHEMA IF EXISTS Customer;
GO

DROP SCHEMA IF EXISTS Production;
GO

DROP SCHEMA IF EXISTS Access;
GO

--Create schemas--
CREATE SCHEMA Customer AUTHORIZATION dbo;
GO

CREATE SCHEMA Production AUTHORIZATION dbo;
GO

CREATE SCHEMA Access AUTHORIZATION dbo;
GO

--CREATE Customer Related Tables--
CREATE TABLE Customer.WebUser
	(UserID int IDENTITY(1,1) CONSTRAINT PKWebUser PRIMARY KEY,
	 EmailAddress nvarchar(50) NULL);
GO

CREATE TABLE Customer.Regular
	(RegularID int IDENTITY(1,1) CONSTRAINT PKRegular PRIMARY KEY,
	 RegularName nvarchar(20)
	);
GO

--CREATE Production Related Tables--

CREATE TABLE Production.WorkOrder
	(OrderID int IDENTITY(1,1) CONSTRAINT PKOrder PRIMARY KEY, 
	 RegularID int NOT NULL CONSTRAINT FKOrder_Regular FOREIGN KEY (RegularID) REFERENCES Customer.Regular(RegularID),
	 OrderDate datetime NOT NULL 
	);
GO

CREATE TABLE Production.Commission
	(CommissionID int IDENTITY(1,1) CONSTRAINT PKCommission PRIMARY KEY,
	 OrderID int NOT NULL CONSTRAINT FKCommission_Order FOREIGN KEY (OrderID) REFERENCES Production.WorkOrder(OrderID)
	);
GO


CREATE TABLE Production.Folder
	(FolderID int IDENTITY(1,1) CONSTRAINT PKFolder PRIMARY KEY,
	 RegularID int NOT NULL CONSTRAINT FKFolder_Regular FOREIGN KEY (RegularID) REFERENCES Customer.Regular(RegularID),
	 FolderName nvarchar(20) NULL
	 );
GO

--Create Relational Tables--

CREATE TABLE Access.WebUserRegular
	(WebUserRegularRelationID int IDENTITY(1,1) PRIMARY KEY,
	 WebUserID int NOT NULL CONSTRAINT FKWURR_WebUser FOREIGN KEY (WebUserID) REFERENCES Customer.WebUser(UserID),
	 RegularID int NOT NULL CONSTRAINT FKWURR_Regular FOREIGN KEY (RegularID) REFERENCES Customer.Regular(RegularID),
	 Access int,

	 CONSTRAINT UC_WebRegRel UNIQUE (WebUserID, RegularID)
	);
GO

CREATE TABLE Access.WorkOrderRegular
	(OrderRegularRelationID int IDENTITY(1,1) CONSTRAINT PKOrderRegular PRIMARY KEY,
	 OrderID int NOT NULL CONSTRAINT FKORR_Order FOREIGN KEY (OrderID) REFERENCES Production.WorkOrder(OrderID),
	 RegularID int NOT NULL CONSTRAINT FKORR_Regular FOREIGN KEY (RegularID) REFERENCES Customer.Regular(RegularID),
	 Access int NULL,

	 CONSTRAINT UC_OrdRegRel UNIQUE (OrderID,RegularID)
	);
GO

CREATE TABLE Access.RegularRegular
	(RegularRegularRelationID int IDENTITY(1,1) CONSTRAINT PKRegularRegular PRIMARY KEY,
	 PrimaryRegularID int NOT NULL CONSTRAINT FKRRR_Order FOREIGN KEY (PrimaryRegularID) REFERENCES Customer.Regular(RegularID),
	 SecondaryRegularID int NOT NULL CONSTRAINT FKRRR_Regular FOREIGN KEY (SecondaryRegularID) REFERENCES Customer.Regular(RegularID),
	 Access int NULL,

	 CONSTRAINT UC_RegRegRel UNIQUE (PrimaryRegularID, SecondaryRegularID)
	);
GO

CREATE TABLE Access.FolderCommission
	(FolderCommissionRelationID int IDENTITY(1,1) CONSTRAINT PKFolderCommission PRIMARY KEY,
	 FolderID int NOT NULL CONSTRAINT FKFCR_Folder FOREIGN KEY (FolderID) REFERENCES Production.Folder(FolderID),
	 CommissionID int NOT NULL CONSTRAINT FKFCR_Commission FOREIGN KEY (CommissionID) REFERENCES Production.Commission(CommissionID),

	 CONSTRAINT UC_FolComRel UNIQUE (FolderID, CommissionID)
	 );
GO

CREATE TABLE Access.WebUserFolder
	(WebUserFolderRelationID int IDENTITY(1,1) CONSTRAINT PKWebUserFolder PRIMARY KEY,
	 FolderID int NOT NULL CONSTRAINT FKWUFR_Folder FOREIGN KEY (FolderID) REFERENCES Production.Folder(FolderID),
	 WebUserID int NOT NULL CONSTRAINT FKWUFR_WebUser FOREIGN KEY (WebUserID) REFERENCES Customer.WebUser(UserID),
	 Access int NULL,

	 CONSTRAINT UC_WebFol UNIQUE (FolderID, WebUserID)
	 );
GO

CREATE TABLE Access.WebUserCommission
	(WebUserCommissionRelationID int IDENTITY(1,1) CONSTRAINT PKWebUserCommission PRIMARY KEY,
	 WebUserID int NOT NULL CONSTRAINT FKWUCR_WebUser FOREIGN KEY (WebUserID) REFERENCES Customer.WebUser(UserID),
	 CommissionID int NOT NULL CONSTRAINT FKWUCR_Commission FOREIGN KEY (CommissionID) REFERENCES Production.Commission(CommissionID),
	 Access int NULL,

	 CONSTRAINT UC_WebCom UNIQUE (WebUserID, CommissionID)
	 );
GO


