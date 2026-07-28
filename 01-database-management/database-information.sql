/*
===============================================================================
MSSQL Server Management Toolkit
Module:     01 - Database Management
File:       database-information.sql
Purpose:    Database discovery, status, configuration, and metadata queries
Author:     Emmanuel Alejandro Noriega
===============================================================================
*/

USE CompanyDB;
GO


/* ============================================================================
   1. List all databases
   ============================================================================ */

SELECT
    name AS DatabaseName,
    database_id,
    create_date,
    state_desc AS State,
    recovery_model_desc AS RecoveryModel,
    user_access_desc AS UserAccess,
    is_read_only
FROM sys.databases
ORDER BY name;
GO


/* ============================================================================
   2. Get current database
   ============================================================================ */

SELECT
    DB_NAME() AS CurrentDatabase;
GO


/* ============================================================================
   3. Get database ID
   ============================================================================ */

SELECT
    DB_ID() AS CurrentDatabaseID,
    DB_ID(N'CompanyDB') AS CompanyDB_ID;
GO


/* ============================================================================
   4. Get database properties
   ============================================================================ */

SELECT
    DATABASEPROPERTYEX(DB_NAME(), 'Status') AS DatabaseStatus,
    DATABASEPROPERTYEX(DB_NAME(), 'Recovery') AS RecoveryModel,
    DATABASEPROPERTYEX(DB_NAME(), 'UserAccess') AS UserAccess,
    DATABASEPROPERTYEX(DB_NAME(), 'Updateability') AS Updateability;
GO


/* ============================================================================
   5. Get database compatibility level
   ============================================================================ */

SELECT
    name AS DatabaseName,
    compatibility_level
FROM sys.databases
WHERE name = DB_NAME();
GO


/* ============================================================================
   6. Get database size
   ============================================================================ */

SELECT
    DB_NAME(database_id) AS DatabaseName,
    SUM(size) * 8.0 / 1024 AS TotalSizeMB,
    SUM(size) * 8.0 / 1024 / 1024 AS TotalSizeGB
FROM sys.master_files
WHERE database_id = DB_ID()
GROUP BY database_id;
GO


/* ============================================================================
   7. Get database file information
   ============================================================================ */

SELECT
    name AS LogicalName,
    physical_name AS PhysicalName,
    type_desc AS FileType,
    size * 8.0 / 1024 AS SizeMB,
    max_size,
    growth,
    is_percent_growth
FROM sys.database_files
ORDER BY type;
GO


/* ============================================================================
   8. Get database owner
   ============================================================================ */

SELECT
    SUSER_SNAME(owner_sid) AS DatabaseOwner
FROM sys.databases
WHERE name = DB_NAME();
GO


/* ============================================================================
   9. Get database options
   ============================================================================ */

SELECT
    name AS DatabaseName,
    is_auto_close_on,
    is_auto_shrink_on,
    is_auto_create_stats_on,
    is_auto_update_stats_on,
    is_read_committed_snapshot_on,
    is_read_only
FROM sys.databases
WHERE name = DB_NAME();
GO


/* ============================================================================
   10. Get database creation date
   ============================================================================ */

SELECT
    name AS DatabaseName,
    create_date
FROM sys.databases
WHERE name = DB_NAME();
GO