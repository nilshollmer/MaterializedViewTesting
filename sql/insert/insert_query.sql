USE RadonovaDB;
SET ARITHABORT ON;
CHECKPOINT;
DBCC DROPCLEANBUFFERS;  
DBCC FREEPROCCACHE;
DBCC FREESYSTEMCACHE('ALL');




DECLARE @userID int;
DECLARE @regID int;
DECLARE @orderID int;
DECLARE @folderID int;
DECLARE @comID int;

DECLARE @wur int;
DECLARE @rr int;
DECLARE @wor int;
DECLARE @fc int;
DECLARE @wuf int;
DECLARE @wuc int;

INSERT INTO Customer.WebUser (EmailAddress) VALUES ('new_user'); 
SET @userID = SCOPE_IDENTITY();

INSERT INTO Customer.Regular (RegularName) VALUES ('new_regular'); 
SET @regID = SCOPE_IDENTITY();

INSERT INTO Production.Folder (RegularID, FolderName) VALUES (@regID, 'new_folder');
SET @folderID = SCOPE_IDENTITY();

INSERT INTO Production.WorkOrder (RegularID, OrderDate) VALUES (@regID, GETDATE());
SET @orderID = SCOPE_IDENTITY();

INSERT INTO Production.Commission (OrderID) VALUES (@orderID);
SET @comID = SCOPE_IDENTITY();

INSERT INTO Access.WebUserRegular (WebUserID,RegularID, Access) VALUES (@userID, @regID, 1);
SET @wur = SCOPE_IDENTITY();

INSERT INTO Access.RegularRegular (PrimaryRegularID, SecondaryRegularID, Access) VALUES (100, @regID, 1);
SET @rr = SCOPE_IDENTITY();

INSERT INTO Access.WorkOrderRegular (OrderID, RegularID, Access) VALUES (@orderID, 200, 0);
SET @wor = SCOPE_IDENTITY();

INSERT INTO Access.FolderCommission (FolderID, CommissionID) VALUES (@folderID, @comID);
SET @fc = SCOPE_IDENTITY();

INSERT INTO Access.WebUserFolder (FolderID, WebUserID, Access) VALUES (@folderID, 100, 1);
SET @wuf = SCOPE_IDENTITY();

INSERT INTO Access.WebUserCommission (WebUserID, CommissionID, Access) VALUES (200, 300, 1);
SET @wuc = SCOPE_IDENTITY();

DELETE FROM Access.WebUserRegular WHERE WebUserRegularRelationID = @wur;
DELETE FROM Access.RegularRegular WHERE RegularRegularRelationID = @rr; 
DELETE FROM Access.WorkOrderRegular WHERE OrderRegularRelationID = @wor;
DELETE FROM Access.FolderCommission WHERE FolderCommissionRelationID = @fc;
DELETE FROM Access.WebUserFolder WHERE WebUserFolderRelationID = @wuf;
DELETE FROM Access.WebUserCommission WHERE WebUserCommissionRelationID = @wuc;

DELETE FROM Production.Commission WHERE CommissionID = @comID;
DELETE FROM Production.Folder WHERE FolderID = @folderID;
DELETE FROM Production.WorkOrder WHERE OrderID = @orderID
DELETE FROM Customer.Regular WHERE RegularID = @regID; 
DELETE FROM Customer.WebUser WHERE UserID = @userID; 




INSERT INTO Performance.Radonova.QueryPerformance
	SELECT
		   SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
							   ((CASE qs.statement_end_offset
											WHEN -1 THEN DATALENGTH(qt.TEXT)
											ELSE qs.statement_end_offset
							   END
							   - qs.statement_start_offset)/2)+1)
							   as query_text,
	qs.total_worker_time cpu_time ,
	qs.total_elapsed_time elapsed_time,
	qs.total_logical_reads,
	qs.total_physical_reads,
	qs.total_rows
	FROM sys.dm_exec_query_stats qs
		   CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
		   CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	ORDER BY query_text DESC -- CPU time
	;