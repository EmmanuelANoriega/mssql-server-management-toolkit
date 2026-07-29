/*
===============================================================================
MSSQL Server Management Toolkit
Module:     02 - Table Management
File:       alter-tables.sql
Purpose:    SQL Server table modification and schema migration examples
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. Add columns
2. Add multiple columns
3. Modify column data types
4. Change NULL / NOT NULL
5. Drop columns
6. Add PRIMARY KEY constraints
7. Add FOREIGN KEY constraints
8. Add UNIQUE constraints
9. Add CHECK constraints
10. Drop constraints
11. Enable and disable constraints
12. Rename columns
13. Rename tables
14. Add DEFAULT constraints
15. Drop DEFAULT constraints
16. Migration examples
17. Safe schema change patterns

IMPORTANT:

Always test schema changes in a development or staging environment before
applying them to production databases.

Schema changes can affect:

- Applications
- Stored procedures
- Views
- Functions
- Triggers
- Reports
- ETL processes
- Integrations
- Indexes
- Foreign key relationships

===============================================================================
*/


/* ============================================================================
   1. Add a single column
   ============================================================================ */

ALTER TABLE Demo.EmployeeRecords
ADD MiddleName NVARCHAR(50) NULL;
GO


/* ============================================================================
   2. Add multiple columns
   ============================================================================ */

ALTER TABLE Demo.EmployeeRecords
ADD
    PhoneNumber NVARCHAR(30) NULL,
    Email NVARCHAR(150) NULL,
    HireDate DATE NULL;
GO


/* ============================================================================
   3. Add a column with a DEFAULT value
   ============================================================================ */

ALTER TABLE Demo.EmployeeRecords
ADD IsActive BIT NOT NULL
    CONSTRAINT DF_EmployeeRecords_IsActive
    DEFAULT (1);
GO


/*
When adding a NOT NULL column to a table containing existing rows,
SQL Server requires a value for existing records.

A DEFAULT constraint can be used to populate existing rows.
*/


/* ============================================================================
   4. Modify a column data type
   ============================================================================ */

ALTER TABLE Demo.EmployeeRecords
ALTER COLUMN MiddleName NVARCHAR(100) NULL;
GO


/* ============================================================================
   5. Change a column from NULL to NOT NULL
   ============================================================================ */

/*
IMPORTANT:

This operation will fail if existing rows contain NULL values.

First identify NULL values:

SELECT *
FROM Demo.EmployeeRecords
WHERE Email IS NULL;
*/


/*
Example data cleanup:

UPDATE Demo.EmployeeRecords
SET Email = 'unknown@example.com'
WHERE Email IS NULL;
*/


/*
After cleaning the data:

ALTER TABLE Demo.EmployeeRecords
ALTER COLUMN Email NVARCHAR(150) NOT NULL;
*/


/* ============================================================================
   6. Change a column from NOT NULL to NULL
   ============================================================================ */

ALTER TABLE Demo.EmployeeRecords
ALTER COLUMN PhoneNumber NVARCHAR(30) NULL;
GO


/* ============================================================================
   7. Drop a column
   ============================================================================ */

ALTER TABLE Demo.EmployeeRecords
DROP COLUMN MiddleName;
GO


/*
Before dropping a column, check whether it is referenced by:

- Views
- Stored procedures
- Functions
- Triggers
- Application code
- Reports
*/


/* ============================================================================
   8. Add PRIMARY KEY constraint
   ============================================================================ */

CREATE TABLE Demo.UnkeyedEmployees
(
    EmployeeID INT NOT NULL,
    EmployeeName NVARCHAR(100) NOT NULL
);
GO


ALTER TABLE Demo.UnkeyedEmployees
ADD CONSTRAINT PK_UnkeyedEmployees
PRIMARY KEY (EmployeeID);
GO


/* ============================================================================
   9. Add FOREIGN KEY constraint
   ============================================================================ */

CREATE TABLE Demo.EmployeeDepartments
(
    EmployeeID INT NOT NULL,
    DepartmentID INT NOT NULL
);
GO


ALTER TABLE Demo.EmployeeDepartments
ADD CONSTRAINT FK_EmployeeDepartments_Departments
FOREIGN KEY (DepartmentID)
REFERENCES Demo.Departments(DepartmentID);
GO


/* ============================================================================
   10. Add UNIQUE constraint
   ============================================================================ */

ALTER TABLE Demo.UnkeyedEmployees
ADD Email NVARCHAR(150) NULL;
GO


ALTER TABLE Demo.UnkeyedEmployees
ADD CONSTRAINT UQ_UnkeyedEmployees_Email
UNIQUE (Email);
GO


/* ============================================================================
   11. Add CHECK constraint
   ============================================================================ */

ALTER TABLE Demo.UnkeyedEmployees
ADD Salary DECIMAL(12,2) NULL;
GO


ALTER TABLE Demo.UnkeyedEmployees
ADD CONSTRAINT CK_UnkeyedEmployees_Salary
CHECK (Salary >= 0);
GO


/* ============================================================================
   12. Add DEFAULT constraint
   ============================================================================ */

ALTER TABLE Demo.UnkeyedEmployees
ADD CreatedDate DATETIME2 NULL;
GO


ALTER TABLE Demo.UnkeyedEmployees
ADD CONSTRAINT DF_UnkeyedEmployees_CreatedDate
DEFAULT (SYSDATETIME())
FOR CreatedDate;
GO


/* ============================================================================
   13. Drop a CHECK constraint
   ============================================================================ */

ALTER TABLE Demo.UnkeyedEmployees
DROP CONSTRAINT CK_UnkeyedEmployees_Salary;
GO


/* ============================================================================
   14. Drop a UNIQUE constraint
   ============================================================================ */

ALTER TABLE Demo.UnkeyedEmployees
DROP CONSTRAINT UQ_UnkeyedEmployees_Email;
GO


/* ============================================================================
   15. Drop a FOREIGN KEY constraint
   ============================================================================ */

ALTER TABLE Demo.EmployeeDepartments
DROP CONSTRAINT FK_EmployeeDepartments_Departments;
GO


/* ============================================================================
   16. Drop a DEFAULT constraint
   ============================================================================ */

ALTER TABLE Demo.UnkeyedEmployees
DROP CONSTRAINT DF_UnkeyedEmployees_CreatedDate;
GO


/* ============================================================================
   17. Disable a FOREIGN KEY constraint
   ============================================================================ */

ALTER TABLE Demo.EmployeeDepartments
NOCHECK CONSTRAINT FK_EmployeeDepartments_Departments;
GO


/* ============================================================================
   18. Re-enable and validate a FOREIGN KEY constraint
   ============================================================================ */

ALTER TABLE Demo.EmployeeDepartments
WITH CHECK CHECK CONSTRAINT FK_EmployeeDepartments_Departments;
GO


/*
The second CHECK tells SQL Server to validate existing rows.

This is preferable to simply enabling the constraint without validation.
*/


/* ============================================================================
   19. Disable all constraints on a table
   ============================================================================ */

ALTER TABLE Demo.EmployeeDepartments
NOCHECK CONSTRAINT ALL;
GO


/* ============================================================================
   20. Re-enable all constraints
   ============================================================================ */

ALTER TABLE Demo.EmployeeDepartments
WITH CHECK CHECK CONSTRAINT ALL;
GO


/* ============================================================================
   21. Rename a column
   ============================================================================ */

/*
SQL Server uses sp_rename for column renaming.

IMPORTANT:

Renaming a column does not automatically update all references
in application code, stored procedures, views, or other objects.

Example:

EXEC sp_rename
    'Demo.UnkeyedEmployees.EmployeeName',
    'FullName',
    'COLUMN';
*/


/* ============================================================================
   22. Rename a table
   ============================================================================ */

/*
Example:

EXEC sp_rename
    'Demo.UnkeyedEmployees',
    'Employees';
*/


/* ============================================================================
   23. Migration example - Version 1
   ============================================================================ */

CREATE TABLE Demo.CustomerAccounts
(
    CustomerID INT IDENTITY(1,1)
        CONSTRAINT PK_CustomerAccounts
        PRIMARY KEY,

    CustomerName NVARCHAR(100) NOT NULL
);
GO


/* ============================================================================
   24. Migration example - Version 2
   Add Email and CreatedDate
   ============================================================================ */

ALTER TABLE Demo.CustomerAccounts
ADD
    Email NVARCHAR(150) NULL,
    CreatedDate DATETIME2 NOT NULL
        CONSTRAINT DF_CustomerAccounts_CreatedDate
        DEFAULT (SYSDATETIME());
GO


/* ============================================================================
   25. Migration example - Version 3
   Add Email uniqueness
   ============================================================================ */

ALTER TABLE Demo.CustomerAccounts
ADD CONSTRAINT UQ_CustomerAccounts_Email
UNIQUE (Email);
GO


/* ============================================================================
   26. Migration example - Version 4
   Add account status
   ============================================================================ */

ALTER TABLE Demo.CustomerAccounts
ADD AccountStatus NVARCHAR(20) NOT NULL
    CONSTRAINT DF_CustomerAccounts_AccountStatus
    DEFAULT ('ACTIVE');
GO


/* ============================================================================
   27. Migration example - Version 5
   Add CHECK constraint
   ============================================================================ */

ALTER TABLE Demo.CustomerAccounts
ADD CONSTRAINT CK_CustomerAccounts_AccountStatus
CHECK
(
    AccountStatus IN
    (
        'ACTIVE',
        'SUSPENDED',
        'CLOSED'
    )
);
GO


/* ============================================================================
   28. Safe migration pattern
   ============================================================================ */

/*
Scenario:

A production table currently contains:

CustomerName

We want to introduce:

CustomerStatus

Recommended approach:

1. Add the column as NULL or with a safe DEFAULT.
2. Populate existing records.
3. Validate the data.
4. Change the column to NOT NULL if required.
5. Add validation constraints.
*/


/* Step 1 - Add column */

ALTER TABLE Demo.CustomerAccounts
ADD CustomerStatus NVARCHAR(20) NULL;
GO


/* Step 2 - Populate existing data */

UPDATE Demo.CustomerAccounts
SET CustomerStatus = 'ACTIVE'
WHERE CustomerStatus IS NULL;
GO


/* Step 3 - Validate data */

SELECT *
FROM Demo.CustomerAccounts
WHERE CustomerStatus IS NULL;
GO


/* Step 4 - Change to NOT NULL */

ALTER TABLE Demo.CustomerAccounts
ALTER COLUMN CustomerStatus NVARCHAR(20) NOT NULL;
GO


/* Step 5 - Add validation */

ALTER TABLE Demo.CustomerAccounts
ADD CONSTRAINT CK_CustomerAccounts_CustomerStatus
CHECK
(
    CustomerStatus IN
    (
        'ACTIVE',
        'SUSPENDED',
        'CLOSED'
    )
);
GO


/* ============================================================================
   29. Inspect table columns after modifications
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
   30. Inspect table constraints
   ============================================================================ */

SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    kc.name AS ConstraintName,
    kc.type_desc AS ConstraintType
FROM sys.tables t
INNER JOIN sys.key_constraints kc
    ON t.object_id = kc.parent_object_id
WHERE SCHEMA_NAME(t.schema_id) = 'Demo'
ORDER BY
    t.name,
    kc.name;
GO


/* ============================================================================
   31. Inspect foreign keys
   ============================================================================ */

SELECT
    fk.name AS ForeignKeyName,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS ParentSchema,
    OBJECT_NAME(fk.parent_object_id) AS ParentTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id)
        AS ParentColumn,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS ReferencedSchema,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id)
        AS ReferencedColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = 'Demo';
GO


/* ============================================================================
   32. Production change checklist
   ============================================================================ */

/*
Before changing a production table:

[ ] Confirm change request approval
[ ] Validate change in development
[ ] Validate change in staging
[ ] Review dependencies
[ ] Check application compatibility
[ ] Check foreign key relationships
[ ] Check indexes
[ ] Check constraints
[ ] Estimate execution time
[ ] Review locking impact
[ ] Confirm backup availability
[ ] Define rollback strategy
[ ] Schedule maintenance window if required
[ ] Monitor application after deployment

===============================================================================
END OF FILE
===============================================================================
*/