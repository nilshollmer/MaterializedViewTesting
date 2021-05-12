USE RadonovaDB;
SET ARITHABORT ON;
CHECKPOINT;  
DBCC DROPCLEANBUFFERS;  
DBCC FREEPROCCACHE;
DBCC FREESYSTEMCACHE('ALL');



SELECT 
	FolderID, 
	CASE 
		WHEN Access = 1 
			THEN 'EDIT' 
		WHEN Access = 0 
			THEN 'VIEW' 
		ELSE 'NOACCESS' 
	END AS Access 
FROM Access.vSharedFolderAccess WITH (NOEXPAND)	
WHERE WebUserID = 2575 AND FolderName LIKE '%der23842%'
GROUP BY FolderID, Access
;



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