/*
===============================================================================
MSSQL Server Management Toolkit
Module:     01 - Database Management
File:       create-database.sql
Purpose:    Database creation and configuration examples
Author:     Emmanuel Alejandro Noriega
===============================================================================

This file contains examples for:

- Creating a database
- Creating a database with custom data/log files
- Configuring database options
- Configuring recovery models
- Setting database access modes
- Dropping databases safely

IMPORTANT:
These examples are intended for laboratory and development environments.

Never execute destructive operations against production without proper
change management, backups, and approval.
===============================================================================
*/


/* ============================================================================
   1. Create a basic database
   ============================================================================ */

CREATE DATABASE DemoDB;
GO


/* ============================================================================
   2. Create database with custom data and log files
   ============================================================================ */

CREATE DATABASE CompanyDemoDB
ON PRIMARY
(
    NAME = CompanyDemoDB_Data,
    FILENAME = 'D:\MSSQL\Data\CompanyDemoDB.mdf',
    SIZE = 100MB,
    MAXSIZE = 5GB,
    FILEGROWTH = 100MB
)
LOG ON
(
    NAME = CompanyDemoDB_Log,
    FILENAME = 'D:\MSSQL\Log\CompanyDemoDB.ldf',
    SIZE = 50MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 50MB
);
GO


/* ============================================================================
   3. Configure database options
   ============================================================================ */

ALTER DATABASE CompanyDemoDB
SET AUTO_CLOSE OFF;
GO

ALTER DATABASE CompanyDemoDB
SET AUTO_SHRINK OFF;
GO

ALTER DATABASE CompanyDemoDB
SET AUTO_CREATE_STATISTICS ON;
GO

ALTER DATABASE CompanyDemoDB
SET AUTO_UPDATE_STATISTICS ON;
GO


/* ============================================================================
   4. Change recovery model
   ============================================================================ */

ALTER DATABASE CompanyDemoDB
SET RECOVERY SIMPLE;
GO

/*
Other recovery models:

ALTER DATABASE CompanyDemoDB SET RECOVERY FULL;

ALTER DATABASE CompanyDemoDB SET RECOVERY BULK_LOGGED;
*/


/* ============================================================================
   5. Change database access mode
   ============================================================================ */

/*
Single-user mode:

ALTER DATABASE CompanyDemoDB
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
*/


/*
Multi-user mode:

ALTER DATABASE CompanyDemoDB
SET MULTI_USER;
*/


/* ============================================================================
   6. Set database to read-only
   ============================================================================ */

/*
ALTER DATABASE CompanyDemoDB
SET READ_ONLY
WITH ROLLBACK IMMEDIATE;
*/


/*
Return to read/write:

ALTER DATABASE CompanyDemoDB
SET READ_WRITE
WITH ROLLBACK IMMEDIATE;
*/


/* ============================================================================
   7. Rename database
   ============================================================================ */

/*
ALTER DATABASE CompanyDemoDB
MODIFY NAME = CompanyDemoDB_Renamed;
*/


/* ============================================================================
   8. Drop database safely
   ============================================================================ */

/*
WARNING:
This operation permanently deletes the database.

Always verify the target database before executing.
*/

/*
IF DB_ID(N'DemoDB') IS NOT NULL
BEGIN
    DROP DATABASE DemoDB;
END;
GO
*/


/* ============================================================================
   9. Verify database state
   ============================================================================ */

SELECT
    name AS DatabaseName,
    database_id,
    state_desc AS DatabaseState,
    recovery_model_desc AS RecoveryModel,
    user_access_desc AS UserAccess,
    is_read_only
FROM sys.databases
ORDER BY name;
GO