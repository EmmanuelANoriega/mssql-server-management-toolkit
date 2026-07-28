/*
===============================================================================
MSSQL Server Management Toolkit
Module:     02 - Table Management
File:       create-tables.sql
Purpose:    SQL Server table creation examples and best practices
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. Basic table creation
2. Identity columns
3. Primary keys
4. NOT NULL and NULL constraints
5. DEFAULT constraints
6. UNIQUE constraints
7. CHECK constraints
8. Foreign keys
9. Composite primary keys
10. Computed columns
11. Temporary tables
12. Table variables
13. SELECT INTO
14. Creating tables from existing structures
15. Temporal tables
16. Table metadata inspection

IMPORTANT:
These examples are designed for learning and laboratory environments.

Always validate table design, constraints, indexing, and data types against
the requirements of the application and production workload.
===============================================================================
*/


/* ============================================================================
   1. Basic table creation
   ============================================================================ */

CREATE TABLE Demo.BasicEmployees
(
    EmployeeID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50)
);
GO


/* ============================================================================
   2. Table with IDENTITY column
   ============================================================================ */

CREATE TABLE Demo.IdentityEmployees
(
    EmployeeID INT IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL
);
GO


/*
IDENTITY syntax:

IDENTITY(seed, increment)

IDENTITY(1,1)
    First value = 1
    Increment = 1

Example values:

1
2
3
4
5
*/


/* ============================================================================
   3. Table with PRIMARY KEY
   ============================================================================ */

CREATE TABLE Demo.EmployeeRecords
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_EmployeeRecords
        PRIMARY KEY,

    FirstName NVARCHAR(50) NOT NULL,

    LastName NVARCHAR(50) NOT NULL
);
GO


/* ============================================================================
   4. Table with NULL and NOT NULL
   ============================================================================ */

CREATE TABLE Demo.EmployeeContact
(
    EmployeeID INT NOT NULL,

    FirstName NVARCHAR(50) NOT NULL,

    LastName NVARCHAR(50) NOT NULL,

    MiddleName NVARCHAR(50) NULL,

    PhoneNumber NVARCHAR(30) NULL,

    Email NVARCHAR(150) NOT NULL
);
GO


/*
NOT NULL:
    A value is required.

NULL:
    A value is optional and may be unknown or unavailable.
*/


/* ============================================================================
   5. DEFAULT constraints
   ============================================================================ */

CREATE TABLE Demo.EmployeeDefaults
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_EmployeeDefaults
        PRIMARY KEY,

    FirstName NVARCHAR(50) NOT NULL,

    LastName NVARCHAR(50) NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_EmployeeDefaults_IsActive
        DEFAULT (1),

    CreatedDate DATETIME2 NOT NULL
        CONSTRAINT DF_EmployeeDefaults_CreatedDate
        DEFAULT (SYSDATETIME())
);
GO


/* ============================================================================
   6. UNIQUE constraint
   ============================================================================ */

CREATE TABLE Demo.UniqueEmployees
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_UniqueEmployees
        PRIMARY KEY,

    Email NVARCHAR(150) NOT NULL
        CONSTRAINT UQ_UniqueEmployees_Email
        UNIQUE
);
GO


/*
The UNIQUE constraint prevents duplicate email addresses.
*/


/* ============================================================================
   7. CHECK constraint
   ============================================================================ */

CREATE TABLE Demo.EmployeeSalary
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_EmployeeSalary
        PRIMARY KEY,

    EmployeeName NVARCHAR(100) NOT NULL,

    Salary DECIMAL(12,2) NOT NULL
        CONSTRAINT CK_EmployeeSalary_Salary
        CHECK (Salary > 0)
);
GO


/*
Additional CHECK examples:

CHECK (Salary >= 10000)

CHECK (Salary BETWEEN 10000 AND 500000)

CHECK (DepartmentID > 0)
*/


/* ============================================================================
   8. FOREIGN KEY relationship
   ============================================================================ */

CREATE TABLE Demo.Departments
(
    DepartmentID INT IDENTITY(1,1)
        CONSTRAINT PK_DemoDepartments
        PRIMARY KEY,

    DepartmentName NVARCHAR(100) NOT NULL
        CONSTRAINT UQ_DemoDepartments_Name
        UNIQUE
);
GO


CREATE TABLE Demo.DepartmentEmployees
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_DepartmentEmployees
        PRIMARY KEY,

    EmployeeName NVARCHAR(100) NOT NULL,

    DepartmentID INT NOT NULL,

    CONSTRAINT FK_DepartmentEmployees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Demo.Departments(DepartmentID)
);
GO


/*
The FOREIGN KEY enforces referential integrity.

An employee cannot reference a department that does not exist.
*/


/* ============================================================================
   9. FOREIGN KEY with cascading actions
   ============================================================================ */

CREATE TABLE Demo.ProjectDepartments
(
    DepartmentID INT IDENTITY(1,1)
        CONSTRAINT PK_ProjectDepartments
        PRIMARY KEY,

    DepartmentName NVARCHAR(100) NOT NULL
);
GO


CREATE TABLE Demo.DepartmentProjects
(
    ProjectID INT IDENTITY(1,1)
        CONSTRAINT PK_DepartmentProjects
        PRIMARY KEY,

    ProjectName NVARCHAR(150) NOT NULL,

    DepartmentID INT NOT NULL,

    CONSTRAINT FK_DepartmentProjects_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Demo.ProjectDepartments(DepartmentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO


/*
WARNING:

ON DELETE CASCADE can delete child records automatically.

Use cascading deletes carefully in production systems.
*/


/* ============================================================================
   10. Composite PRIMARY KEY
   ============================================================================ */

CREATE TABLE Demo.EmployeeProjects
(
    EmployeeID INT NOT NULL,

    ProjectID INT NOT NULL,

    AssignedDate DATE NOT NULL
        CONSTRAINT DF_EmployeeProjects_AssignedDate
        DEFAULT (GETDATE()),

    CONSTRAINT PK_EmployeeProjects
        PRIMARY KEY
        (
            EmployeeID,
            ProjectID
        )
);
GO


/*
Composite keys are useful when the combination of multiple columns
uniquely identifies a record.

Example:

EmployeeID = 10
ProjectID  = 5

The combination is unique.
*/


/* ============================================================================
   11. COMPUTED column
   ============================================================================ */

CREATE TABLE Demo.Products
(
    ProductID INT IDENTITY(1,1)
        CONSTRAINT PK_DemoProducts
        PRIMARY KEY,

    ProductName NVARCHAR(100) NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    Quantity INT NOT NULL,

    TotalValue AS
    (
        UnitPrice * Quantity
    )
);
GO


/* ============================================================================
   12. PERSISTED computed column
   ============================================================================ */

CREATE TABLE Demo.ProductInventory
(
    ProductID INT IDENTITY(1,1)
        CONSTRAINT PK_ProductInventory
        PRIMARY KEY,

    ProductName NVARCHAR(100) NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    Quantity INT NOT NULL,

    TotalValue AS
    (
        UnitPrice * Quantity
    ) PERSISTED
);
GO


/*
PERSISTED:

The computed value is physically stored and automatically updated
when dependent columns change.

Persisted computed columns can be indexed when SQL Server requirements
are satisfied.
*/


/* ============================================================================
   13. Temporary table
   ============================================================================ */

CREATE TABLE #TempEmployees
(
    EmployeeID INT,

    EmployeeName NVARCHAR(100),

    Salary DECIMAL(12,2)
);
GO


INSERT INTO #TempEmployees
(
    EmployeeID,
    EmployeeName,
    Salary
)
VALUES
(1, N'John Smith', 75000),
(2, N'Jane Doe', 85000);
GO


SELECT *
FROM #TempEmployees;
GO


/*
Local temporary tables:

#TempEmployees

They are visible only to the current session and are automatically
removed when the session ends.
*/


/* ============================================================================
   14. Global temporary table
   ============================================================================ */

/*
WARNING:

Global temporary tables are visible to all sessions.

They are automatically removed when the creating session ends and
no other session is referencing them.

Use with caution.

CREATE TABLE ##GlobalTempEmployees
(
    EmployeeID INT,
    EmployeeName NVARCHAR(100)
);
*/


/* ============================================================================
   15. Table variable
   ============================================================================ */

DECLARE @EmployeeList TABLE
(
    EmployeeID INT,

    EmployeeName NVARCHAR(100),

    Salary DECIMAL(12,2)
);


INSERT INTO @EmployeeList
(
    EmployeeID,
    EmployeeName,
    Salary
)
VALUES
(1, N'John Smith', 75000),
(2, N'Jane Doe', 85000);


SELECT *
FROM @EmployeeList;
GO


/*
Table variables are useful for smaller intermediate result sets.

For larger datasets, temporary tables may provide better performance
and more optimizer statistics.
*/


/* ============================================================================
   16. SELECT INTO
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
INTO Demo.EmployeeArchive
FROM HR.Employees
WHERE Active = 0;
GO


/*
SELECT INTO:

- Creates a new table.
- Copies selected columns.
- Copies matching data.

IMPORTANT:

SELECT INTO does not automatically copy all indexes, constraints,
triggers, or other table objects from the source table.
*/


/* ============================================================================
   17. Create table from existing structure without data
   ============================================================================ */

SELECT *
INTO Demo.EmployeeStructure
FROM HR.Employees
WHERE 1 = 0;
GO


/*
The condition WHERE 1 = 0 prevents rows from being copied.

The resulting table contains the selected columns but no data.
*/


/* ============================================================================
   18. SQL Server temporal table
   ============================================================================ */

/*
Temporal tables maintain historical versions of records automatically.

This example requires SQL Server 2016 or later.

The following example creates:

- Current employee table
- System-versioned history table
*/

CREATE TABLE Demo.TemporalEmployees
(
    EmployeeID INT NOT NULL
        CONSTRAINT PK_TemporalEmployees
        PRIMARY KEY,

    EmployeeName NVARCHAR(100) NOT NULL,

    Salary DECIMAL(12,2) NOT NULL,

    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START
        CONSTRAINT DF_TemporalEmployees_ValidFrom
        DEFAULT (SYSUTCDATETIME()),

    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END
        CONSTRAINT DF_TemporalEmployees_ValidTo
        DEFAULT (CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999')),

    PERIOD FOR SYSTEM_TIME
    (
        ValidFrom,
        ValidTo
    )
)
WITH
(
    SYSTEM_VERSIONING = ON
    (
        HISTORY_TABLE = Demo.TemporalEmployeesHistory,
        DATA_CONSISTENCY_CHECK = ON
    )
);
GO


/* ============================================================================
   19. Table metadata
   ============================================================================ */

SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    t.create_date,
    t.modify_date
FROM sys.tables t
ORDER BY
    SchemaName,
    TableName;
GO


/* ============================================================================
   20. Column metadata
   ============================================================================ */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Demo'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;
GO


/* ============================================================================
   21. Primary keys and constraints
   ============================================================================ */

SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    kc.name AS ConstraintName,
    kc.type_desc AS ConstraintType
FROM sys.tables t
INNER JOIN sys.key_constraints kc
    ON t.object_id = kc.parent_object_id
ORDER BY
    SchemaName,
    TableName;
GO