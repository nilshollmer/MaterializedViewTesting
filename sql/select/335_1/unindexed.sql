USE RadonovaDB;
SET ARITHABORT ON;
CHECKPOINT;  
DBCC DROPCLEANBUFFERS;  
DBCC FREEPROCCACHE;
DBCC FREESYSTEMCACHE('ALL');



SELECT 
	CommissionID,
	CASE 
		WHEN Access = 1 
			THEN 'EDIT' 
		WHEN Access = 0 
			THEN 'VIEW'
		ELSE 'NOACCESS' 
	END AS Access 
FROM Access.vSharedCommissionAccess
WHERE WebUserID = 269 AND OrderID = 55963
;



INSERT INTO Performance.Radonova.QueryPerformance
	SELECT
		qs.sql_handle query_name,
		qs.total_worker_time cpu_time,
		qs.total_elapsed_time elapsed_time,
		qs.total_logical_reads logical_reads,
		qs.total_physical_reads physical_reads,
		qs.total_rows rows_returned,
		qs.total_used_threads threads,
		qs.total_used_grant_kb used_kb,
		qp.query_plan query_plan
	FROM
		sys.dm_exec_query_stats qs
	    CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	ORDER BY qs.total_worker_time DESC -- CPU time
;
