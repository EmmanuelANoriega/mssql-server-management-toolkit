/*
===============================================================================
MSSQL Server Management Toolkit
Module:     02 - Table Management
File:       indexes.sql
Purpose:    SQL Server index creation, maintenance, and performance examples
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. Clustered indexes
2. Nonclustered indexes
3. Unique indexes
4. Composite indexes
5. Included columns
6. Covering indexes
7. Filtered indexes
8. Index management
9. Index metadata
10. Index fragmentation
11. Index rebuild
12. Index reorganize
13. Statistics maintenance
14. Missing index analysis
15. Index usage statistics
16. Unused indexes
17. Index maintenance strategy
18. Production best practices

IMPORTANT:

Indexes can significantly improve SELECT performance, but they also introduce
additional storage requirements and write overhead.

Every index should have a clear purpose and should be evaluated against the
actual workload.

===============================================================================
*/


/* ============================================================================
   1. Clustered index
   ============================================================================ */

/*
A clustered index determines the physical order of data pages in a table.

A table can have only one clustered index.
*/

CREATE TABLE Demo.ClusteredEmployees
(
    EmployeeID INT NOT NULL,

    EmployeeName NVARCHAR(100) NOT NULL,

    DepartmentID INT NOT NULL,

    HireDate DATE NOT NULL
);
GO


CREATE CLUSTERED INDEX IX_ClusteredEmployees_EmployeeID
ON Demo.ClusteredEmployees(EmployeeID);
GO


/* ============================================================================
   2. Nonclustered index
   ============================================================================ */

/*
A nonclustered index stores indexed values separately from the table data.

A table can have multiple nonclustered indexes.
*/

CREATE NONCLUSTERED INDEX IX_ClusteredEmployees_DepartmentID
ON Demo.ClusteredEmployees(DepartmentID);
GO


/* ============================================================================
   3. Unique index
   ============================================================================ */

CREATE TABLE Demo.UniqueCustomers
(
    CustomerID INT IDENTITY(1,1)
        CONSTRAINT PK_UniqueCustomers
        PRIMARY KEY,

    Email NVARCHAR(150) NOT NULL
);
GO


CREATE UNIQUE INDEX IX_UniqueCustomers_Email
ON Demo.UniqueCustomers(Email);
GO


/*
The unique index prevents duplicate values.

Example:

customer1@example.com  -> allowed
customer2@example.com  -> allowed

customer1@example.com  -> duplicate, rejected
*/


/* ============================================================================
   4. Composite index
   ============================================================================ */

/*
A composite index contains multiple columns.

Column order is important.

The following index is useful for queries filtering by:

DepartmentID

or:

DepartmentID + HireDate
*/

CREATE NONCLUSTERED INDEX IX_Employees_Department_HireDate
ON Demo.ClusteredEmployees
(
    DepartmentID,
    HireDate
);
GO


/*
The index is generally less useful for queries filtering only by:

HireDate

because HireDate is the second key column.
*/


/* ============================================================================
   5. Index with INCLUDE columns
   ============================================================================ */

/*
Included columns are stored at the leaf level of the index.

They can help avoid Key Lookups for frequently executed queries.
*/

CREATE NONCLUSTERED INDEX IX_Employees_Department
ON Demo.ClusteredEmployees(DepartmentID)
INCLUDE
(
    EmployeeName,
    HireDate
);
GO


/* ============================================================================
   6. Covering index
   ============================================================================ */

/*
A covering index contains all columns required by a query.

Example query:

SELECT EmployeeName, HireDate
FROM Demo.ClusteredEmployees
WHERE DepartmentID = 10;
*/

CREATE NONCLUSTERED INDEX IX_Employees_Department_Covering
ON Demo.ClusteredEmployees(DepartmentID)
INCLUDE
(
    EmployeeName,
    HireDate
);
GO


/*
The index can potentially allow SQL Server to satisfy the query
without accessing the base table.

Always validate execution plans before assuming an index is beneficial.
*/


/* ============================================================================
   7. Filtered index
   ============================================================================ */

/*
Filtered indexes contain only rows that meet a specific condition.

They can be useful for selective queries.
*/

CREATE TABLE Demo.ActiveEmployees
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_ActiveEmployees
        PRIMARY KEY,

    EmployeeName NVARCHAR(100) NOT NULL,

    Email NVARCHAR(150) NULL,

    IsActive BIT NOT NULL
);
GO


CREATE NONCLUSTERED INDEX IX_ActiveEmployees_Email
ON Demo.ActiveEmployees(Email)
WHERE IsActive = 1;
GO


/*
This index contains only active employees.

Potential use case:

SELECT EmployeeID, EmployeeName, Email
FROM Demo.ActiveEmployees
WHERE IsActive = 1
AND Email = 'employee@example.com';
*/


/* ============================================================================
   8. Filtered index for NULL values
   ============================================================================ */

CREATE NONCLUSTERED INDEX IX_ActiveEmployees_Email_NotNull
ON Demo.ActiveEmployees(Email)
WHERE Email IS NOT NULL;
GO


/* ============================================================================
   9. Index with DESC sort order
   ============================================================================ */

CREATE NONCLUSTERED INDEX IX_Employees_HireDate_DESC
ON Demo.ClusteredEmployees
(
    HireDate DESC
);
GO


/* ============================================================================
   10. Create index conditionally
   ============================================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Employees_DepartmentID'
    AND object_id = OBJECT_ID('Demo.ClusteredEmployees')
)
BEGIN

    CREATE NONCLUSTERED INDEX IX_Employees_DepartmentID
    ON Demo.ClusteredEmployees(DepartmentID);

END;
GO


/*
This pattern helps prevent errors caused by attempting to create
an index that already exists.
*/


/* ============================================================================
   11. View indexes for a table
   ============================================================================ */

EXEC sp_helpindex
    'Demo.ClusteredEmployees';
GO


/* ============================================================================
   12. View index metadata
   ============================================================================ */

SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint,
    i.is_disabled
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('Demo.ClusteredEmployees');
GO


/* ============================================================================
   13. View indexed columns
   ============================================================================ */

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    c.name AS ColumnName,
    ic.key_ordinal,
    ic.is_included_column
FROM sys.indexes i
INNER JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
    AND i.index_id = ic.index_id
INNER JOIN sys.columns c
    ON ic.object_id = c.object_id
    AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('Demo.ClusteredEmployees')
ORDER BY
    i.name,
    ic.key_ordinal;
GO


/* ============================================================================
   14. Disable an index
   ============================================================================ */

/*
Disabled indexes are not available to the query optimizer.

Use carefully.

ALTER INDEX IX_Employees_DepartmentID
ON Demo.ClusteredEmployees
DISABLE;
*/


/* ============================================================================
   15. Rebuild an index
   ============================================================================ */

ALTER INDEX IX_Employees_DepartmentID
ON Demo.ClusteredEmployees
REBUILD;
GO


/* ============================================================================
   16. Rebuild all indexes on a table
   ============================================================================ */

ALTER INDEX ALL
ON Demo.ClusteredEmployees
REBUILD;
GO


/* ============================================================================
   17. Reorganize an index
   ============================================================================ */

ALTER INDEX IX_Employees_Department_HireDate
ON Demo.ClusteredEmployees
REORGANIZE;
GO


/*
REORGANIZE is generally an online operation and is less resource intensive
than a full REBUILD.

It is often considered for moderate index fragmentation.
*/


/* ============================================================================
   18. Rebuild index with options
   ============================================================================ */

ALTER INDEX IX_Employees_Department_HireDate
ON Demo.ClusteredEmployees
REBUILD
WITH
(
    SORT_IN_TEMPDB = ON,
    ONLINE = OFF
);
GO


/*
ONLINE = ON availability depends on SQL Server Edition and version.

Always validate supported features in your environment.
*/


/* ============================================================================
   19. View index fragmentation
   ============================================================================ */

SELECT
    OBJECT_SCHEMA_NAME(ps.object_id) AS SchemaName,
    OBJECT_NAME(ps.object_id) AS TableName,
    i.name AS IndexName,
    ps.index_type_desc,
    ps.avg_fragmentation_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    NULL,
    NULL,
    NULL,
    'LIMITED'
) ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
    AND ps.index_id = i.index_id
WHERE ps.database_id = DB_ID()
AND i.name IS NOT NULL
ORDER BY
    ps.avg_fragmentation_in_percent DESC;
GO


/* ============================================================================
   20. Identify highly fragmented indexes
   ============================================================================ */

SELECT
    OBJECT_SCHEMA_NAME(ps.object_id) AS SchemaName,
    OBJECT_NAME(ps.object_id) AS TableName,
    i.name AS IndexName,
    ps.avg_fragmentation_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    NULL,
    NULL,
    NULL,
    'LIMITED'
) ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
    AND ps.index_id = i.index_id
WHERE ps.avg_fragmentation_in_percent >= 30
AND ps.page_count >= 1000
ORDER BY
    ps.avg_fragmentation_in_percent DESC;
GO


/*
Example maintenance guideline:

Fragmentation < 5%
    Usually no action.

Fragmentation 5% - 30%
    Consider REORGANIZE.

Fragmentation > 30%
    Consider REBUILD.

IMPORTANT:

These are general guidelines, not universal rules.

Always consider:

- Workload
- Page count
- Maintenance windows
- SQL Server version
- Storage performance
- Availability requirements
*/


/* ============================================================================
   21. Update statistics
   ============================================================================ */

UPDATE STATISTICS Demo.ClusteredEmployees;
GO


/* ============================================================================
   22. Update statistics with FULLSCAN
   ============================================================================ */

UPDATE STATISTICS Demo.ClusteredEmployees
WITH FULLSCAN;
GO


/*
FULLSCAN provides more accurate statistics but requires more resources.

Use carefully on large production tables.
*/


/* ============================================================================
   23. View statistics
   ============================================================================ */

SELECT
    name,
    auto_created,
    user_created,
    no_recompute
FROM sys.stats
WHERE object_id = OBJECT_ID('Demo.ClusteredEmployees');
GO


/* ============================================================================
   24. View missing index recommendations
   ============================================================================ */

SELECT
    migs.avg_total_user_cost,
    migs.avg_user_impact,
    migs.user_seeks,
    migs.user_scans,
    mid.statement AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_group_stats migs
INNER JOIN sys.dm_db_missing_index_groups mig
    ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid
    ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID()
ORDER BY
    migs.avg_user_impact DESC;
GO


/*
IMPORTANT:

Missing index DMVs are recommendations, not automatic instructions.

Before creating an index:

1. Check existing indexes.
2. Check query execution plans.
3. Analyze workload.
4. Consider write overhead.
5. Consider storage requirements.
6. Consolidate overlapping indexes.
*/


/* ============================================================================
   25. Index usage statistics
   ============================================================================ */

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ISNULL(ius.user_seeks, 0) AS UserSeeks,
    ISNULL(ius.user_scans, 0) AS UserScans,
    ISNULL(ius.user_lookups, 0) AS UserLookups,
    ISNULL(ius.user_updates, 0) AS UserUpdates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id
    AND i.index_id = ius.index_id
    AND ius.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY
    UserSeeks DESC;
GO


/* ============================================================================
   26. Identify potentially unused indexes
   ============================================================================ */

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ISNULL(ius.user_seeks, 0) AS UserSeeks,
    ISNULL(ius.user_scans, 0) AS UserScans,
    ISNULL(ius.user_lookups, 0) AS UserLookups,
    ISNULL(ius.user_updates, 0) AS UserUpdates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id
    AND i.index_id = ius.index_id
    AND ius.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
AND i.index_id > 0
AND ISNULL(ius.user_seeks, 0) = 0
AND ISNULL(ius.user_scans, 0) = 0
AND ISNULL(ius.user_lookups, 0) = 0
ORDER BY
    UserUpdates DESC;
GO


/*
WARNING:

Do not immediately delete indexes identified as "unused".

DMV statistics reset after:

- SQL Server restart
- Database detach/attach
- Certain maintenance operations
- Other lifecycle events

An index that appears unused may still be required periodically.
*/


/* ============================================================================
   27. Index size information
   ============================================================================ */

SELECT
    OBJECT_SCHEMA_NAME(ps.object_id) AS SchemaName,
    OBJECT_NAME(ps.object_id) AS TableName,
    i.name AS IndexName,
    ps.index_type_desc,
    ps.page_count,
    ps.avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    NULL,
    NULL,
    NULL,
    'DETAILED'
) ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
    AND ps.index_id = i.index_id
WHERE i.name IS NOT NULL
ORDER BY
    ps.page_count DESC;
GO


/* ============================================================================
   28. Drop an index
   ============================================================================ */

DROP INDEX IF EXISTS IX_Employees_HireDate_DESC
ON Demo.ClusteredEmployees;
GO


/* ============================================================================
   29. Example index strategy
   ============================================================================ */

/*
Scenario:

The application frequently executes:

SELECT
    EmployeeName,
    HireDate
FROM Demo.ClusteredEmployees
WHERE DepartmentID = 10
ORDER BY HireDate DESC;


Potential index:

CREATE NONCLUSTERED INDEX IX_Employees_Department_HireDate
ON Demo.ClusteredEmployees
(
    DepartmentID,
    HireDate DESC
)
INCLUDE
(
    EmployeeName
);


Always validate with an actual execution plan.
*/


/* ============================================================================
   30. Recommended production index review process
   ============================================================================ */

/*
Step 1:
Identify slow queries.

Step 2:
Review the actual execution plan.

Step 3:
Check for:

- Table scans
- Index scans
- Key lookups
- Missing index suggestions
- High logical reads

Step 4:
Review existing indexes.

Step 5:
Check index usage statistics.

Step 6:
Design the smallest useful index.

Step 7:
Test in development.

Step 8:
Test in staging.

Step 9:
Measure before and after performance.

Step 10:
Deploy during an approved change window.

Step 11:
Monitor production impact.

===============================================================================
END OF FILE
===============================================================================
*/