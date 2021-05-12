USE RadonovaDB;
GO

DBCC SHRINKDATABASE(RadonovaDB);
GO

IF OBJECT_ID('tempdb.dbo.#space') IS NOT NULL
    DROP TABLE #space

CREATE TABLE #space (
      database_id INT PRIMARY KEY
    , data_used_size DECIMAL(18,2)
    , log_used_size DECIMAL(18,2)
)

DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = STUFF((
    SELECT '
    USE [' + d.name + ']
    INSERT INTO #space (database_id, data_used_size, log_used_size)
    SELECT
          DB_ID()
        , SUM(CASE WHEN [type] = 0 THEN space_used END)
        , SUM(CASE WHEN [type] = 1 THEN space_used END)
    FROM (
        SELECT s.[type], space_used = SUM(FILEPROPERTY(s.name, ''SpaceUsed'') * 8. / 1024)
        FROM sys.database_files s
        GROUP BY s.[type]
    ) t;'
    FROM sys.databases d
    WHERE d.[state] = 0
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')

EXEC sys.sp_executesql @SQL
use master;
SELECT
      d.database_id
    , d.name
	, t.total_size as total_size_mb
    , d.state_desc
    , d.recovery_model_desc
    , t.data_size as data_size_mb
    , s.data_used_size as data_used_size_mb
    , t.log_size as log_size_mb
    , s.log_used_size as log_used_size_mb
    , bu.full_last_date backup_full_last_date
    , bu.full_size as backup_full_size_mb
    , bu.log_last_date as backup_log_last_date
    , bu.log_size as backup_log_size_mb
FROM (
    SELECT
          database_id
        , log_size = CAST(SUM(CASE WHEN [type] = 1 THEN size END) * 8. / 1024 AS DECIMAL(18,2))
        , data_size = CAST(SUM(CASE WHEN [type] = 0 THEN size END) * 8. / 1024 AS DECIMAL(18,2))
        , total_size = CAST(SUM(size) * 8. / 1024 AS DECIMAL(18,4))
    FROM sys.master_files
    GROUP BY database_id
) t
JOIN sys.databases d ON d.database_id = t.database_id
LEFT JOIN #space s ON d.database_id = s.database_id
LEFT JOIN (
    SELECT
          database_name
        , full_last_date = MAX(CASE WHEN [type] = 'D' THEN backup_finish_date END)
        , full_size = MAX(CASE WHEN [type] = 'D' THEN backup_size END)
        , log_last_date = MAX(CASE WHEN [type] = 'L' THEN backup_finish_date END)
        , log_size = MAX(CASE WHEN [type] = 'L' THEN backup_size END)
    FROM (
        SELECT
              s.database_name
            , s.[type]
            , s.backup_finish_date
            , backup_size =
                        CAST(CASE WHEN s.backup_size = s.compressed_backup_size
                                    THEN s.backup_size
                                    ELSE s.compressed_backup_size
                        END / 1048576.0 AS DECIMAL(18,2))
            , RowNum = ROW_NUMBER() OVER (PARTITION BY s.database_name, s.[type] ORDER BY s.backup_finish_date DESC)
        FROM msdb.dbo.backupset s
        WHERE s.[type] IN ('D', 'L')
    ) f
    WHERE f.RowNum = 1 
    GROUP BY f.database_name
) bu ON d.name = bu.database_name
WHERE d.name = 'RadonovaDB'
ORDER BY t.total_size DESC
GO

USE RadonovaDB;
GO


SELECT 
    v.NAME AS view_name,
	CAST(SUM(a.total_pages) * 8. / 1024 AS DECIMAL(18,4)) AS total_size_mb, 
	p.rows AS row_counts
FROM 
    sys.views v
INNER JOIN      
    sys.indexes i ON v.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
	sys.allocation_units a ON p.partition_id = a.container_id
GROUP BY 
    v.NAME, 
	p.Rows
