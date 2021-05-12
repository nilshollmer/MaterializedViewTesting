/*
2021-03-15
Populate database
*/

-- Set database to use --
USE RadonovaDB;
GO

-- Clear and populate --
DELETE FROM Access.RegularRegular;
DELETE FROM Access.WebUserRegular;
DELETE FROM Access.WorkOrderRegular;
DELETE FROM Access.WebUserCommission;
DELETE FROM Access.WebUserFolder;
DELETE FROM Access.FolderCommission;

DELETE FROM Production.Commission;
DELETE FROM Production.Folder;
DELETE FROM Production.WorkOrder;
DELETE FROM Customer.Regular;
DELETE FROM Customer.WebUser;

GO
-- Customer WebCustomer --
DELETE FROM Customer.WebUser;

DECLARE @UserID int;
SET @UserID = 1;

WHILE @UserID <= 10000
BEGIN 
	INSERT INTO Customer.WebUser VALUES (
              'WebUser' + CAST(FORMAT(@UserID, 'D5') AS nvarchar(10)) + '@mail.com');
	--PRINT ('WebUser ' + CAST(@UserID AS VARCHAR))
	SET @UserID = @UserID + 1;
END
GO

SELECT * FROM Customer.WebUser;

-- Customer Regular --
DELETE FROM Customer.Regular;

DECLARE @RegularID int;
SET @RegularID = 1;

WHILE @RegularID <= 50000
BEGIN 
   INSERT INTO Customer.Regular VALUES ('Regular ' + CAST(@RegularID AS VARCHAR));
   SET @RegularID = @RegularID + 1;
END
GO

SELECT * FROM Customer.Regular;

-- Production WorkOrder --

DROP SEQUENCE IF EXISTS Production.Count60;



CREATE SEQUENCE Production.Count60
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 60
	CYCLE;

DELETE FROM Production.WorkOrder;

DECLARE @RegularID int;
DECLARE @OrderCount int;
DECLARE @DateMod int;
DECLARE @OrderDate datetime;

DECLARE @CommissionCount int;

SET @RegularID = 1;
SET @OrderCount = 1;

WHILE @RegularID <= 50000
BEGIN
	SET @DateMod = NEXT VALUE FOR Production.Count60;
	SET @OrderDate = DATEADD(day, @DateMod - (@DateMod * 2),GETDATE());

	WHILE @OrderCount <= 6
	BEGIN

		INSERT INTO Production.WorkOrder VALUES (
			@RegularID,
			@OrderDate
		);

		
		SET @OrderCount = @OrderCount + 1;
	END

	SET @OrderCount = 1;
	SET @RegularID = @RegularID + 1;
END

GO

SELECT * FROM Production.WorkOrder;

-- Production Commission --

DELETE FROM Production.Commission;

DECLARE @OrderID int;
DECLARE @CommissionCount int;

SET @OrderID = 1;
SET @CommissionCount = 1;

WHILE @OrderID <= 300000
BEGIN
	WHILE @CommissionCount <= 10
	BEGIN
		INSERT INTO Production.Commission VALUES (
			@OrderID
		);

		SET @CommissionCount = @CommissionCount + 1;
	END

	SET @CommissionCount = 1;
	SET @OrderID = @OrderID + 1;
END

SELECT * FROM Production.Commission;
-- Production Folder --

DELETE FROM Production.Folder;

DECLARE @FolderID int;
DECLARE @FolderCount int;
DECLARE @RegularID int;

SET @FolderID = 1;
SET @FolderCount = 1;
SET @RegularID = 1;

WHILE @RegularID <= 50000
BEGIN
	WHILE @FolderCount <= 6
	BEGIN

		INSERT INTO Production.Folder VALUES (
			@RegularID,
			'Folder' + CAST(FORMAT(@FolderID, 'D6') AS nvarchar(10))
		);

		
		SET @FolderID = @FolderID + 1;
		SET @FolderCount = @FolderCount + 1;
	END

	SET @FolderCount = 1;
	SET @RegularID = @RegularID + 1;
END
GO

SELECT * FROM Production.Folder;
GO

-- Access Folder Commission --

DELETE FROM Access.FolderCommission; 

DECLARE @FolderID int;
DECLARE @CommissionID int;
DECLARE @CommissionCount int;

SET @FolderID = 1;
SET @CommissionID = 1;
SET @CommissionCount = 1;

WHILE @FolderID <= 300000
BEGIN
	WHILE @CommissionCount <= 10
	BEGIN

		INSERT INTO Access.FolderCommission VALUES (
			@FolderID,
			@CommissionID
		);

		
		SET @CommissionID = @CommissionID + 1;
		SET @CommissionCount = @CommissionCount + 1;
	END

	SET @CommissionCount = 1;
	SET @FolderID = @FolderID + 1;
END
GO

SELECT * FROM Access.FolderCommission;
GO
-- Access Regular Regular --

DELETE FROM Access.RegularRegular;

DROP SEQUENCE IF EXISTS Access.Toggle01;

CREATE SEQUENCE Access.Toggle01
	START WITH 0
	INCREMENT BY 1
	MINVALUE 0
	MAXVALUE 1
	CYCLE;

DECLARE @PrimaryReg int;
DECLARE @SecondaryReg int;

DECLARE @RegRegRelID int;
SET @RegRegRelID = 1;

WHILE @RegRegRelID <= 1000
BEGIN
	SET @PrimaryReg = CAST(FLOOR(RAND()*(50000) + 1) AS INT);
	SET @SecondaryReg = CAST(FLOOR(RAND()*(50000) + 1) AS INT);

	WHILE @SecondaryReg = @PrimaryReg
	BEGIN
		SET @SecondaryReg = CAST(FLOOR(RAND()*(50000) + 1) AS INT);
	END

	INSERT INTO Access.RegularRegular VALUES (
		@PrimaryReg,
		@SecondaryReg,
		NEXT VALUE FOR Access.Toggle01
	)
	
	PRINT ('RegRegRel ' + CAST(@RegRegRelID AS VARCHAR))
	SET @RegRegRelID = @RegRegRelID + 1;
END

SELECT * FROM Access.RegularRegular;
GO

-- Access Order Regular--

DELETE FROM Access.WorkOrderRegular;

DROP SEQUENCE IF EXISTS Access.Toggle10;

CREATE SEQUENCE Access.Toggle10
	START WITH 1
	INCREMENT BY 1
	MINVALUE 0
	MAXVALUE 1
	CYCLE;

DECLARE @OrdRegRelID int;
DECLARE @TempOrderID int;
DECLARE @TempRegularID int;

SET @OrdRegRelID = 1;

WHILE @OrdRegRelID <= 50000
BEGIN
	SET @TempOrderID = CAST(FLOOR(RAND()*(300000) + 1) AS INT);
	SET @TempRegularID = CAST(FLOOR(RAND()*(50000) + 1) AS INT);

	WHILE (SELECT COUNT(*) FROM Production.WorkOrder WHERE OrderID = @TempOrderID AND RegularID = @TempRegularID) > 0
	BEGIN
		SET @TempRegularID = CAST(FLOOR(RAND()*(50000) + 1) AS INT);
	END

	PRINT @TempRegularID;
	PRINT @TempOrderID;

	INSERT INTO Access.WorkOrderRegular VALUES (
		--@OrdRegRelID,
		@TempOrderID,
		@TempRegularID,
		NEXT VALUE FOR Access.Toggle10
	)

	PRINT ('OrdRegRel ' + CAST(@OrdRegRelID AS VARCHAR))

	SET @OrdRegRelID = @OrdRegRelID + 1;
END

SELECT * FROM Access.WorkOrderRegular;
GO

-- Access WebUser Regular --

DELETE FROM Access.WebUserRegular;

DECLARE @TempWebUser int;
DECLARE @TempRegular int;
DECLARE @WebRegRelID int;

SET @WebRegRelID = 1;

WHILE @WebRegRelID <= 10000
BEGIN
	SET @TempWebUser = CAST(FLOOR(RAND()*(10000) + 1) AS INT);
	SET @TempRegular = CAST(FLOOR(RAND()*(50000) + 1) AS INT);

	INSERT INTO Access.WebUserRegular VALUES (
		--@WebRegRelID,
		@TempWebUser,
		@TempRegular,
		NEXT VALUE FOR Access.Toggle01
	)

	
	PRINT ('WebRegRel ' + CAST(@WebRegRelID AS VARCHAR))
	SET @WebRegRelID = @WebRegRelID + 1;
END

-- SELECT COUNT(*) FROM Access.WebUserRegular;

GO

-- Access WebUser Folder --

DELETE FROM Access.WebUserFolder;

DECLARE @TempWebUser int;
DECLARE @TempFolder int;
DECLARE @WebFolRelID int;
SET @WebFolRelID = 1;

WHILE @WebFolRelID <= 10000
BEGIN
	SET @TempFolder = CAST(FLOOR(RAND()*(300000) + 1) AS INT);
	SET @TempWebUser = CAST(FLOOR(RAND()*(10000) + 1) AS INT);

	INSERT INTO Access.WebUserFolder VALUES (
		--@FolWebRelID,
		@TempFolder,
		@TempWebUser,
		NEXT VALUE FOR Access.Toggle10
	);

	PRINT ('FolWebRel ' + CAST(@WebFolRelID AS VARCHAR))
	SET @WebFolRelID = @WebFolRelID + 1;
END

-- SELECT COUNT(*) FROM Access.WebUserFolder;
GO

-- Access WebUser Commission --


DELETE FROM Access.WebUserCommission;

DECLARE @TempWebUser int;
DECLARE @TempCommission int;
DECLARE @WebComRelID int;

SET @WebComRelID = 1;

WHILE @WebComRelID <= 50000
BEGIN
	SET @TempWebUser = CAST(FLOOR(RAND()*(10000) + 1) AS INT);
	SET @TempCommission = CAST(FLOOR(RAND()*(3000000) + 1) AS INT);

	INSERT INTO Access.WebUserCommission VALUES (
		--@WebComRelID,
		@TempWebUser,
		@TempCommission,
		NEXT VALUE FOR Access.Toggle01
	);
	
	PRINT ('WebComRelID ' + CAST(@WebComRelID AS VARCHAR))
	SET @WebComRelID = @WebComRelID + 1;
END

SELECT COUNT(*) FROM Access.WebUserCommission;
GO
