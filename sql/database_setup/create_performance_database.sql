USE master;
GO

--Delete RadonovaOriginalDB if it exists--
--DROP DATABASE IF EXISTS Performance;
--GO

--Create and use database--

CREATE DATABASE Performance;
GO

USE Performance;
GO

DROP TABLE IF EXISTS Radonova.QueryPerformance;
GO

DROP SCHEMA IF EXISTS Radonova;
GO

CREATE SCHEMA Radonova;
GO

CREATE TABLE Radonova.QueryPerformance
	(
	query_text nvarchar(max),
	cpu_time int,
	elapsed_time int,
	total_logical_reads int,
	total_physical_reads int,
	total_rows int
	);
GO
