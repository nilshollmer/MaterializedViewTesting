
USE RadonovaDB;

SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON;

DROP VIEW IF EXISTS Access.vCommissionAccess;

DROP VIEW IF EXISTS Access.vRegularSharedOrderAccess;

DROP VIEW IF EXISTS Access.vSharedRegularOrderAccess;

DROP VIEW IF EXISTS Access.vSharedFolderAccess

DROP VIEW IF EXISTS Access.vFolderAccess;

DROP VIEW IF EXISTS Access.vRegularOrderAccess;

DROP VIEW IF EXISTS Access.vSharedCommissionAccess;


/*
Create Access.vRegularOrderAccess
*/

CREATE VIEW Access.vRegularOrderAccess
WITH SCHEMABINDING
AS
SELECT
	Commission.CommissionID				AS CommissionID,
	WebUserRegular.WebUserID			AS WebUserID,
	WorkOrder.OrderID					AS OrderID,
	WorkOrder.OrderDate					AS OrderDate,
	WebUserRegular.Access				AS Access
FROM
	Production.Commission				AS Commission
	INNER JOIN Production.WorkOrder		AS WorkOrder		ON Commission.OrderID = WorkOrder.OrderID
	INNER JOIN Customer.Regular			AS Regular			ON WorkOrder.RegularID = Regular.RegularID
	INNER JOIN Access.WebUserRegular	AS WebUserRegular	ON WebUserRegular.RegularID = Regular.RegularID
;

CREATE UNIQUE CLUSTERED INDEX IDX_vRegularOrderAccess ON Access.vRegularOrderAccess (WebUserID, CommissionID);
CREATE NONCLUSTERED INDEX IDX_vRegularOrderAccess_WebUserID ON Access.vRegularOrderAccess (WebUserID);
CREATE NONCLUSTERED INDEX IDX_vRegularOrderAccess_CommissionID ON Access.vRegularOrderAccess (CommissionID);
CREATE NONCLUSTERED INDEX IDX_vRegularOrderAccess_OrderID ON Access.vRegularOrderAccess (OrderID);
CREATE NONCLUSTERED INDEX IDX_vRegularOrderAccess_OrderDate ON Access.vRegularOrderAccess (OrderDate);
CREATE NONCLUSTERED INDEX IDX_vRegularOrderAccess_Access ON Access.vRegularOrderAccess (Access);


/*
Create Access.vFolderAccess
*/

CREATE VIEW Access.vFolderAccess
WITH SCHEMABINDING
AS
SELECT
	Commission.CommissionID				AS CommissionID,
	WebUserRegular.WebUserID			AS WebUserID,
	Folder.FolderID						AS FolderID,
	Folder.FolderName					AS FolderName,
	WorkOrder.OrderID					AS OrderID,
	WorkOrder.OrderDate					AS OrderDate,
	WebUserRegular.Access				AS Access
FROM
	Production.Commission				AS Commission
	INNER JOIN Access.FolderCommission	AS FolderCommission	ON Commission.CommissionID = FolderCommission.CommissionID
	INNER JOIN Production.Folder		AS Folder			ON FolderCommission.FolderID = Folder.FolderID
	INNER JOIN Production.WorkOrder		AS WorkOrder		ON Commission.OrderID = WorkOrder.OrderID
	INNER JOIN Customer.Regular			AS Regular			ON Folder.RegularID = Regular.RegularID
	INNER JOIN Access.WebUserRegular	AS WebUserRegular	ON WebUserRegular.RegularID = Regular.RegularID
;

CREATE UNIQUE CLUSTERED INDEX IDX_vFolderAccess ON Access.vFolderAccess (WebUserID, CommissionID);
CREATE NONCLUSTERED INDEX IDX_vFolderAccess_CommissionID ON Access.vFolderAccess (CommissionID);
CREATE NONCLUSTERED INDEX IDX_vFolderAccess_FolderID ON Access.vFolderAccess (FolderID);
CREATE NONCLUSTERED INDEX IDX_vFolderAccess_FolderName ON Access.vFolderAccess (FolderName);
CREATE NONCLUSTERED INDEX IDX_vFolderAccess_OrderID ON Access.vFolderAccess (OrderID);
CREATE NONCLUSTERED INDEX IDX_vFolderAccess_OrderDate ON Access.vFolderAccess (OrderDate);
CREATE NONCLUSTERED INDEX IDX_vFolderAccess_Access ON Access.vFolderAccess (Access);


/*
Create vSharedFoldersAccess
*/

CREATE VIEW Access.vSharedFolderAccess
WITH SCHEMABINDING
AS
SELECT
	Commission.CommissionID				AS CommissionID,
	SharedFolder.WebUserID				AS WebUserID,
	Folder.FolderID						AS FolderID,
	Folder.FolderName					AS FolderName,
	WorkOrder.OrderID					AS OrderID,
	WorkOrder.OrderDate					AS OrderDate,
	SharedFolder.Access					AS Access
FROM
	Production.Commission				AS Commission
	INNER JOIN Access.FolderCommission	AS FolderCommission	ON Commission.CommissionID = FolderCommission.CommissionID
	INNER JOIN Production.Folder		AS Folder			ON FolderCommission.FolderID = Folder.FolderID
	INNER JOIN Production.WorkOrder		AS WorkOrder		ON Commission.OrderID = WorkOrder.OrderID
	INNER JOIN Access.WebUserFolder		AS SharedFolder		ON Folder.RegularID = SharedFolder.FolderID
;

CREATE UNIQUE CLUSTERED INDEX IDX_vSharedFolderAccess ON Access.vSharedFolderAccess (WebUserID, CommissionID);
CREATE NONCLUSTERED INDEX IDX_vSharedFolderAccess_WebUserID ON Access.vSharedFolderAccess (WebUserID);
CREATE NONCLUSTERED INDEX IDX_vSharedFolderAccess_CommissionID ON Access.vSharedFolderAccess (CommissionID);
CREATE NONCLUSTERED INDEX IDX_vSharedFolderAccess_FolderID ON Access.vSharedFolderAccess (FolderID);
CREATE NONCLUSTERED INDEX IDX_vSharedFolderAccess_FolderName ON Access.vSharedFolderAccess (FolderName);
CREATE NONCLUSTERED INDEX IDX_vSharedFolderAccess_OrderID ON Access.vSharedFolderAccess (OrderID);
CREATE NONCLUSTERED INDEX IDX_vSharedFolderAccess_OrderDate ON Access.vSharedFolderAccess (OrderDate);
CREATE NONCLUSTERED INDEX IDX_vSharedFolderAccess_Access ON Access.vSharedFolderAccess (Access);


/*
Create Access.vSharedRegularOrderAccess
*/

CREATE VIEW Access.vSharedRegularOrderAccess
WITH SCHEMABINDING
AS
SELECT
	Commission.CommissionID		AS CommissionID,
	WebUserRegular.WebUserID	AS WebUserID,
	WorkOrder.OrderID			AS OrderID,
	WorkOrder.OrderDate			AS OrderDate,
	CASE 
		WHEN WebUserRegular.Access > RegularRegular.Access
			THEN WebUserRegular.Access
		ELSE RegularRegular.Access
	END AS Access
FROM
	Production.Commission				AS Commission
	INNER JOIN Production.WorkOrder		AS WorkOrder		ON Commission.OrderID = WorkOrder.OrderID
	INNER JOIN Access.RegularRegular	AS RegularRegular	ON RegularRegular.SecondaryRegularID = WorkOrder.RegularID
	INNER JOIN Access.WebUserRegular	AS WebUserRegular	ON WebUserRegular.RegularID = RegularRegular.PrimaryRegularID
;


CREATE UNIQUE CLUSTERED INDEX IDX_vSharedRegularOrderAccess ON Access.vSharedRegularOrderAccess (WebUserID, CommissionID);
CREATE NONCLUSTERED INDEX IDX_vSharedRegularOrderAccess_WebUserID ON Access.vSharedRegularOrderAccess (WebUserID);
CREATE NONCLUSTERED INDEX IDX_vSharedRegularOrderAccess_CommissionID ON Access.vSharedRegularOrderAccess (CommissionID);
CREATE NONCLUSTERED INDEX IDX_vSharedRegularOrderAccess_OrderID ON Access.vSharedRegularOrderAccess (OrderID);
CREATE NONCLUSTERED INDEX IDX_vSharedRegularOrderAccess_OrderDate ON Access.vSharedRegularOrderAccess (OrderDate);
CREATE NONCLUSTERED INDEX IDX_vSharedRegularOrderAccess_Access ON Access.vSharedRegularOrderAccess (Access);


/*
Create Access.vRegularSharedOrderAccess
*/

CREATE VIEW Access.vRegularSharedOrderAccess
WITH SCHEMABINDING
AS
SELECT
	Commission.CommissionID				AS CommissionID,
	WebUserRegular.WebUserID			AS WebUserID,
	WorkOrder.OrderID					AS OrderID,
	WorkOrder.OrderDate					AS OrderDate,
	CASE 
		WHEN WebUserRegular.Access >= SharedWorkOrder.Access
			THEN WebUserRegular.Access
		ELSE SharedWorkOrder.Access
	END AS Access
FROM
	Production.Commission				AS Commission
	INNER JOIN Production.WorkOrder		AS WorkOrder		ON Commission.OrderID = WorkOrder.OrderID
	INNER JOIN Access.WorkOrderRegular	AS SharedWorkOrder	ON WorkOrder.OrderID = SharedWorkOrder.OrderID
	INNER JOIN Access.WebUserRegular	AS WebUserRegular	ON SharedWorkOrder.RegularID = WebUserRegular.RegularID
;


CREATE UNIQUE CLUSTERED INDEX IDX_vRegularSharedOrderAccess ON Access.vRegularSharedOrderAccess (WebUserID, CommissionID);
CREATE NONCLUSTERED INDEX IDX_vRegularSharedOrderAccess_WebUserID ON Access.vRegularSharedOrderAccess (WebUserID);
CREATE NONCLUSTERED INDEX IDX_vRegularSharedOrderAccess_CommissionID ON Access.vRegularSharedOrderAccess (CommissionID);
CREATE NONCLUSTERED INDEX IDX_vRegularSharedOrderAccess_OrderID ON Access.vRegularSharedOrderAccess (OrderID);
CREATE NONCLUSTERED INDEX IDX_vRegularSharedOrderAccess_OrderDate ON Access.vRegularSharedOrderAccess (OrderDate);
CREATE NONCLUSTERED INDEX IDX_vRegularSharedOrderAccess_Access ON Access.vRegularSharedOrderAccess (Access);


/*
Create Access.vSharedCommissionAccess
*/

CREATE VIEW Access.vSharedCommissionAccess
WITH SCHEMABINDING
AS
SELECT
	Commission.CommissionID				AS CommissionID,
	SharedCommission.WebUserID			AS WebUserID,
	WorkOrder.OrderID					AS OrderID,
	WorkOrder.OrderDate					AS OrderDate,
	SharedCommission.Access				AS Access
FROM
	Production.Commission				AS Commission
	INNER JOIN Access.WebUserCommission AS SharedCommission ON Commission.CommissionID = SharedCommission.CommissionID
	INNER JOIN Production.WorkOrder		AS WorkOrder		ON Commission.OrderID = WorkOrder.OrderID
;

CREATE UNIQUE CLUSTERED INDEX IDX_vSharedCommissionAccess ON Access.vSharedCommissionAccess (WebUserID, CommissionID);
CREATE NONCLUSTERED INDEX IDX_vSharedCommissionAccess_WebUserID ON Access.vSharedCommissionAccess (WebUserID);
CREATE NONCLUSTERED INDEX IDX_vSharedCommissionAccess_CommissionID ON Access.vSharedCommissionAccess (CommissionID);
CREATE NONCLUSTERED INDEX IDX_vSharedCommissionAccess_OrderID ON Access.vSharedCommissionAccess (OrderID);
CREATE NONCLUSTERED INDEX IDX_vSharedCommissionAccess_OrderDate ON Access.vSharedCommissionAccess (OrderDate);
CREATE NONCLUSTERED INDEX IDX_vSharedCommissionAccess_Access ON Access.vSharedCommissionAccess (Access);


CREATE VIEW Access.vCommissionAccess
WITH SCHEMABINDING
AS
SELECT
	CommissionID,
	WebUserID,
	MAX(Access) AS 'Access'
FROM
	(
		
		SELECT CommissionID, WebUserID, Access FROM Access.vRegularOrderAccess WITH (NOEXPAND)

		UNION ALL

		SELECT CommissionID, WebUserID, Access FROM Access.vRegularSharedOrderAccess WITH (NOEXPAND)

		UNION ALL

		SELECT CommissionID, WebUserID, Access FROM Access.vSharedRegularOrderAccess WITH (NOEXPAND)

		UNION ALL

		SELECT CommissionID, WebUserID, Access FROM Access.vFolderAccess WITH (NOEXPAND)

		UNION ALL

		SELECT CommissionID, WebUserID, Access FROM Access.vSharedFolderAccess WITH (NOEXPAND)

		UNION ALL

		SELECT CommissionID, WebUserID, Access FROM Access.vSharedCommissionAccess WITH (NOEXPAND)
	) AS search

GROUP BY WebUserID, CommissionID
;
