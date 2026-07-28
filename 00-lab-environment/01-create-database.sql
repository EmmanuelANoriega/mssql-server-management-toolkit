/*
===============================================================================
Project:    MSSQL Server Management Toolkit
File:       01-create-database.sql
Purpose:    Create the CompanyDB laboratory database
Author:     Emmanuel Alejandro Noriega
Created:    2026
===============================================================================

IMPORTANT:
This script is intended for a development/laboratory environment.

WARNING:
The script drops CompanyDB if it already exists.
Do NOT execute this script against a production database.
===============================================================================
*/

USE master;
GO

/* ============================================================================
   Remove existing database
   ============================================================================ */

IF DB_ID(N'CompanyDB') IS NOT NULL
BEGIN
    PRINT 'CompanyDB already exists. Preparing to remove it...';

    ALTER DATABASE CompanyDB
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE CompanyDB;

    PRINT 'Existing CompanyDB removed successfully.';
END;
GO


/* ============================================================================
   Create database
   ============================================================================ */

CREATE DATABASE CompanyDB;
GO


/* ============================================================================
   Configure recovery model
   ============================================================================ */

ALTER DATABASE CompanyDB
SET RECOVERY SIMPLE;
GO


/* ============================================================================
   Database configuration
   ============================================================================ */

ALTER DATABASE CompanyDB
SET AUTO_CLOSE OFF;
GO

ALTER DATABASE CompanyDB
SET AUTO_SHRINK OFF;
GO

ALTER DATABASE CompanyDB
SET AUTO_CREATE_STATISTICS ON;
GO

ALTER DATABASE CompanyDB
SET AUTO_UPDATE_STATISTICS ON;
GO


/* ============================================================================
   Validation
   ============================================================================ */

IF DB_ID(N'CompanyDB') IS NOT NULL
BEGIN
    PRINT '==============================================';
    PRINT 'CompanyDB created successfully.';
    PRINT 'Recovery Model: SIMPLE';
    PRINT 'Auto Close: OFF';
    PRINT 'Auto Shrink: OFF';
    PRINT '==============================================';
END
ELSE
BEGIN
    THROW 50001, 'CompanyDB creation failed.', 1;
END;
GO