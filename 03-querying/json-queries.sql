/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       pivot-unpivot.sql
Purpose:    PIVOT and UNPIVOT operations for data transformation
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. Basic PIVOT
2. PIVOT with aggregates
3. PIVOT with multiple columns
4. Dynamic PIVOT
5. PIVOT with dates
6. PIVOT for reporting
7. Basic UNPIVOT
8. UNPIVOT for normalization
9. PIVOT and UNPIVOT best practices

===============================================================================
*/


/* ============================================================================
   1. Basic PIVOT
   ============================================================================ */

/*
Transform rows into columns.

Example source data:

DepartmentID | HireYear | EmployeeCount
--------------|----------|--------------
1             | 2023     | 5
1             | 2024     | 8
2             | 2023     | 3
2             | 2024     | 7

Result:

DepartmentID | [2023] | [2024]
--------------|--------|-------
1             | 5      | 8
2             | 3      | 7
*/

SELECT
    DepartmentID,
    [2023],
    [2024],
    [2025]
FROM
(
    SELECT
        DepartmentID,
        YEAR(HireDate) AS HireYear,
        EmployeeID
    FROM Demo.Employees
) AS SourceData
PIVOT
(
    COUNT(EmployeeID)
    FOR HireYear IN ([2023], [2024], [2025])
) AS PivotTable
ORDER BY DepartmentID;
GO


/* ============================================================================
   2. PIVOT with salary aggregation
   ============================================================================ */

SELECT
    DepartmentID,
    [2023],
    [2024],
    [2025]
FROM
(
    SELECT
        DepartmentID,
        YEAR(HireDate) AS HireYear,
        Salary
    FROM Demo.Employees
) AS SourceData
PIVOT
(
    AVG(Salary)
    FOR HireYear IN ([2023], [2024], [2025])
) AS PivotTable
ORDER BY DepartmentID;
GO


/* ============================================================================
   3. PIVOT with SUM
   ============================================================================ */

/*
This example assumes a Demo.Sales table with:

SaleID
DepartmentID
SaleYear
Amount
*/

SELECT
    DepartmentID,
    [2023],
    [2024],
    [2025]
FROM
(
    SELECT
        DepartmentID,
        SaleYear,
        Amount
    FROM Demo.Sales
) AS SourceData
PIVOT
(
    SUM(Amount)
    FOR SaleYear IN ([2023], [2024], [2025])
) AS PivotTable
ORDER BY DepartmentID;
GO


/* ============================================================================
   4. PIVOT for employee counts by department and year
   ============================================================================ */

SELECT
    DepartmentID,
    [2023] AS Employees2023,
    [2024] AS Employees2024,
    [2025] AS Employees2025
FROM
(
    SELECT
        DepartmentID,
        YEAR(HireDate) AS HireYear,
        EmployeeID
    FROM Demo.Employees
) AS SourceData
PIVOT
(
    COUNT(EmployeeID)
    FOR HireYear IN ([2023], [2024], [2025])
) AS PivotTable;
GO


/* ============================================================================
   5. PIVOT using conditional aggregation
   ============================================================================ */

/*
PIVOT is not always required.

Conditional aggregation can be easier to read and maintain.
*/

SELECT
    DepartmentID,

    COUNT(
        CASE
            WHEN YEAR(HireDate) = 2023
            THEN EmployeeID
        END
    ) AS Employees2023,

    COUNT(
        CASE
            WHEN YEAR(HireDate) = 2024
            THEN EmployeeID
        END
    ) AS Employees2024,

    COUNT(
        CASE
            WHEN YEAR(HireDate) = 2025
            THEN EmployeeID
        END
    ) AS Employees2025

FROM Demo.Employees

GROUP BY DepartmentID

ORDER BY DepartmentID;
GO


/* ============================================================================
   6. PIVOT with multiple aggregate calculations
   ============================================================================ */

/*
A single PIVOT supports one aggregate expression.

For multiple metrics, conditional aggregation is often simpler.
*/

SELECT
    DepartmentID,

    COUNT(
        CASE
            WHEN YEAR(HireDate) = 2025
            THEN EmployeeID
        END
    ) AS EmployeeCount2025,

    AVG(
        CASE
            WHEN YEAR(HireDate) = 2025
            THEN Salary
        END
    ) AS AverageSalary2025,

    MAX(
        CASE
            WHEN YEAR(HireDate) = 2025
            THEN Salary
        END
    ) AS MaximumSalary2025

FROM Demo.Employees

GROUP BY DepartmentID;
GO


/* ============================================================================
   7. PIVOT with date ranges
   ============================================================================ */

SELECT
    DepartmentID,
    [Q1],
    [Q2],
    [Q3],
    [Q4]
FROM
(
    SELECT
        DepartmentID,

        CONCAT(
            'Q',
            DATEPART(
                QUARTER,
                HireDate
            )
        ) AS HireQuarter,

        EmployeeID

    FROM Demo.Employees

) AS SourceData

PIVOT
(
    COUNT(EmployeeID)

    FOR HireQuarter IN
    (
        [Q1],
        [Q2],
        [Q3],
        [Q4]
    )

) AS PivotTable

ORDER BY DepartmentID;
GO


/* ============================================================================
   8. Dynamic PIVOT
   ============================================================================ */

/*
Dynamic PIVOT is useful when column values are not known in advance.

WARNING:
Dynamic SQL must be handled carefully.

Always validate dynamic identifiers and avoid concatenating
untrusted user input.
*/

DECLARE @Columns NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);

SELECT
    @Columns =
        STRING_AGG(
            QUOTENAME(YEAR(HireDate)),
            ','
        )
FROM
(
    SELECT DISTINCT
        YEAR(HireDate) AS HireYear
    FROM Demo.Employees
) AS Years;

SET @SQL = N'
SELECT
    DepartmentID,
    ' + @Columns + N'
FROM
(
    SELECT
        DepartmentID,
        YEAR(HireDate) AS HireYear,
        EmployeeID
    FROM Demo.Employees
) AS SourceData

PIVOT
(
    COUNT(EmployeeID)
    FOR HireYear IN (' + @Columns + N')
) AS PivotTable

ORDER BY DepartmentID;
';

EXEC sys.sp_executesql @SQL;
GO


/* ============================================================================
   9. Basic UNPIVOT
   ============================================================================ */

/*
UNPIVOT transforms columns into rows.

Example:

EmployeeID | January | February | March
-----------|---------|----------|-------
1          | 100     | 200      | 300

Becomes:

EmployeeID | Month    | Amount
-----------|----------|-------
1          | January  | 100
1          | February | 200
1          | March    | 300
*/


/*
Example table structure:

Demo.MonthlySales

EmployeeID
JanuarySales
FebruarySales
MarchSales
*/

SELECT
    EmployeeID,
    SalesMonth,
    SalesAmount

FROM
(
    SELECT
        EmployeeID,
        JanuarySales,
        FebruarySales,
        MarchSales
    FROM Demo.MonthlySales
) AS SourceData

UNPIVOT
(
    SalesAmount
    FOR SalesMonth IN
    (
        JanuarySales,
        FebruarySales,
        MarchSales
    )
) AS UnpivotTable;
GO


/* ============================================================================
   10. UNPIVOT with employee metrics
   ============================================================================ */

/*
Example source:

EmployeeID | TicketsResolved | TicketsEscalated | TicketsClosed
*/

SELECT
    EmployeeID,
    MetricName,
    MetricValue

FROM
(
    SELECT
        EmployeeID,
        TicketsResolved,
        TicketsEscalated,
        TicketsClosed

    FROM Demo.EmployeeMetrics
) AS SourceData

UNPIVOT
(
    MetricValue
    FOR MetricName IN
    (
        TicketsResolved,
        TicketsEscalated,
        TicketsClosed
    )
) AS UnpivotTable;
GO


/* ============================================================================
   11. UNPIVOT with reporting data
   ============================================================================ */

SELECT
    DepartmentID,
    Metric,
    MetricValue

FROM
(
    SELECT
        DepartmentID,
        TotalEmployees,
        AverageSalary,
        MaximumSalary

    FROM Demo.DepartmentMetrics
) AS SourceData

UNPIVOT
(
    MetricValue
    FOR Metric IN
    (
        TotalEmployees,
        AverageSalary,
        MaximumSalary
    )
) AS UnpivotTable;
GO


/* ============================================================================
   12. PIVOT and NULL handling
   ============================================================================ */

SELECT
    DepartmentID,

    ISNULL([2023], 0) AS Employees2023,
    ISNULL([2024], 0) AS Employees2024,
    ISNULL([2025], 0) AS Employees2025

FROM
(
    SELECT
        DepartmentID,
        YEAR(HireDate) AS HireYear,
        EmployeeID

    FROM Demo.Employees

) AS SourceData

PIVOT
(
    COUNT(EmployeeID)

    FOR HireYear IN
    (
        [2023],
        [2024],
        [2025]
    )

) AS PivotTable;
GO


/* ============================================================================
   13. PIVOT vs Conditional Aggregation
   ============================================================================ */

/*
PIVOT:

Advantages:
- Convenient for fixed column transformations.
- Useful for reporting.
- Easy to understand when the output structure is known.

Disadvantages:
- Can become difficult to maintain with many columns.
- Dynamic PIVOT requires dynamic SQL.
- Multiple aggregates can be awkward.

Conditional Aggregation:

Advantages:
- Flexible.
- Easy to add multiple metrics.
- Often easier to maintain.
- Works well with complex reporting queries.

Example:
*/

SELECT
    DepartmentID,

    SUM(
        CASE
            WHEN YEAR(HireDate) = 2023
            THEN Salary
            ELSE 0
        END
    ) AS Salary2023,

    SUM(
        CASE
            WHEN YEAR(HireDate) = 2024
            THEN Salary
            ELSE 0
        END
    ) AS Salary2024

FROM Demo.Employees

GROUP BY DepartmentID;
GO


/* ============================================================================
   14. Practical reporting example
   ============================================================================ */

/*
Generate a department hiring report by year.
*/

SELECT
    DepartmentID,

    COUNT(
        CASE
            WHEN YEAR(HireDate) = YEAR(GETDATE())
            THEN EmployeeID
        END
    ) AS HiredThisYear,

    COUNT(
        CASE
            WHEN YEAR(HireDate) = YEAR(GETDATE()) - 1
            THEN EmployeeID
        END
    ) AS HiredLastYear,

    COUNT(*) AS TotalEmployees

FROM Demo.Employees

GROUP BY DepartmentID;
GO


/* ============================================================================
   15. Best practices
   ============================================================================ */

/*
Recommended practices:

- Use PIVOT when the output columns are known and stable.
- Use conditional aggregation for multiple metrics.
- Use dynamic PIVOT only when necessary.
- Always use QUOTENAME() when generating dynamic column identifiers.
- Never concatenate untrusted user input into dynamic SQL.
- Consider query complexity and performance with large datasets.
- Test PIVOT queries with NULL values.
- Use meaningful aliases for generated columns.
- Avoid PIVOT when a simple GROUP BY provides the required result.

===============================================================================
END OF FILE
===============================================================================
*/