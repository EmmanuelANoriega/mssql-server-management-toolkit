/*
===============================================================================
MSSQL Server Management Toolkit
Module:     01 - Database Management
File:       database-files.sql
Purpose:    Database data and transaction log file management
Author:     Emmanuel Alejandro Noriega
===============================================================================
*/

USE CompanyDB;
GO


/* ============================================================================
   1. View database files
   ============================================================================ */

SELECT
    name AS LogicalName,
    physical_name AS PhysicalName,
    type_desc AS FileType,
    state_desc AS State,
    size * 8.0 / 1024 AS SizeMB,
    max_size,
    growth,
    is_percent_growth
FROM sys.database_files
ORDER BY type;
GO


/* ============================================================================
   2. View master file information
   ============================================================================ */

SELECT
    DB_NAME(database_id) AS DatabaseName,
    name AS LogicalName,
    physical_name AS PhysicalName,
    type_desc AS FileType,
    size * 8.0 / 1024 AS SizeMB
FROM sys.master_files
WHERE database_id = DB_ID()
ORDER BY type;
GO


/* ============================================================================
   3. Add a secondary data file
   ============================================================================ */

/*
ALTER DATABASE CompanyDB
ADD FILE
(
    NAME = CompanyDB_Data02,
    FILENAME = 'D:\MSSQL\Data\CompanyDB_Data02.ndf',
    SIZE = 100MB,
    MAXSIZE = 5GB,
    FILEGROWTH = 100MB
);
*/


/* ============================================================================
   4. Modify file size
   ============================================================================ */

/*
ALTER DATABASE CompanyDB
MODIFY FILE
(
    NAME = CompanyDB_Data02,
    SIZE = 500MB
);
*/


/* ============================================================================
   5. Modify file growth
   ============================================================================ */

/*
ALTER DATABASE CompanyDB
MODIFY FILE
(
    NAME = CompanyDB_Data02,
    FILEGROWTH = 100MB
);
*/


/* ============================================================================
   6. Remove secondary file
   ============================================================================ */

/*
WARNING:
The file must be empty before it can be removed.

DBCC SHRINKFILE
may be required to empty the file before removal.
*/

/*
ALTER DATABASE CompanyDB
REMOVE FILE CompanyDB_Data02;
*/


/* ============================================================================
   7. File space usage
   ============================================================================ */

SELECT
    DB_NAME() AS DatabaseName,
    name AS LogicalName,
    type_desc AS FileType,
    size * 8.0 / 1024 AS AllocatedSizeMB,
    FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 AS UsedSpaceMB,
    (
        size - FILEPROPERTY(name, 'SpaceUsed')
    ) * 8.0 / 1024 AS FreeSpaceMB
FROM sys.database_files;
GO


/* ============================================================================
   8. Database space usage
   ============================================================================ */

EXEC sp_spaceused;
GO


/* ============================================================================
   9. Object-level space usage
   ============================================================================ */

EXEC sp_MSforeachtable
    @command1 = 'EXEC sp_spaceused ''?''';
GO