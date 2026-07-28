/*
===============================================================================
Project:    MSSQL Server Management Toolkit
File:       02-create-schemas.sql
Purpose:    Create application schemas for CompanyDB
Author:     Emmanuel Alejandro Noriega
===============================================================================
*/

USE CompanyDB;
GO


/* ============================================================================
   HR Schema
   ============================================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = N'HR'
)
BEGIN
    EXEC(N'CREATE SCHEMA HR');

    PRINT 'Schema HR created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema HR already exists.';
END;
GO


/* ============================================================================
   Sales Schema
   ============================================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = N'Sales'
)
BEGIN
    EXEC(N'CREATE SCHEMA Sales');

    PRINT 'Schema Sales created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema Sales already exists.';
END;
GO


/* ============================================================================
   Audit Schema
   ============================================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = N'Audit'
)
BEGIN
    EXEC(N'CREATE SCHEMA Audit');

    PRINT 'Schema Audit created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema Audit already exists.';
END;
GO


/* ============================================================================
   Validation
   ============================================================================ */

SELECT
    name AS SchemaName,
    schema_id
FROM sys.schemas
WHERE name IN
(
    N'HR',
    N'Sales',
    N'Audit'
)
ORDER BY name;
GO