/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       pivot-unpivot.sql
Purpose:    Transforming rows into columns and columns into rows
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics Covered:
    1. PIVOT Basics
    2. SUM with PIVOT
    3. COUNT with PIVOT
    4. AVG with PIVOT
    5. Multiple Aggregations
    6. PIVOT using CASE
    7. Dynamic PIVOT (Concept)
    8. UNPIVOT Basics
    9. Performance Considerations
    10. Common Mistakes
    11. Best Practices

Prerequisites:
    - Demo.Sales
    - Demo.Employees
    - Demo.Departments

Note:
    These examples use demonstration objects. Refer to the project README
    for additional information regarding the sample schema.

===============================================================================
*/

-- ============================================================================
-- 1. PIVOT Basics
-- ============================================================================

/*
Scenario

Display total sales by department.
*/

SELECT *
FROM
(
    SELECT
        DepartmentID,
        SalesAmount
    FROM Demo.Sales
) AS SourceTable
PIVOT
(
    SUM(SalesAmount)
    FOR DepartmentID IN ([1],[2],[3],[4])
) AS PivotTable;

-- ============================================================================
-- 2. SUM with PIVOT
-- ============================================================================

SELECT *
FROM
(
    SELECT
        DepartmentID,
        SalesAmount
    FROM Demo.Sales
) AS SalesData
PIVOT
(
    SUM(SalesAmount)
    FOR DepartmentID IN ([1],[2],[3],[4])
) AS p;

-- ============================================================================
-- 3. COUNT with PIVOT
-- ============================================================================

SELECT *
FROM
(
    SELECT
        DepartmentID,
        EmployeeID
    FROM Demo.Employees
) AS EmployeeData
PIVOT
(
    COUNT(EmployeeID)
    FOR DepartmentID IN ([1],[2],[3],[4])
) AS p;

-- ============================================================================
-- 4. AVG with PIVOT
-- ============================================================================

SELECT *
FROM
(
    SELECT
        DepartmentID,
        Salary
    FROM Demo.Employees
) AS EmployeeData
PIVOT
(
    AVG(Salary)
    FOR DepartmentID IN ([1],[2],[3],[4])
) AS p;

-- ============================================================================
-- 5. Multiple Aggregations
-- ============================================================================

/*
PIVOT supports a single aggregate.

To display multiple aggregates,
execute separate PIVOT queries or
combine them with JOINs or CTEs.
*/

WITH SalarySummary AS
(
    SELECT
        DepartmentID,
        AVG(Salary) AS AverageSalary,
        SUM(Salary) AS TotalSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
)

SELECT *
FROM SalarySummary
ORDER BY DepartmentID;

-- ============================================================================
-- 6. PIVOT using CASE
-- ============================================================================

/*
Equivalent result without PIVOT.
*/

SELECT
    SUM(CASE WHEN DepartmentID = 1 THEN SalesAmount END) AS Department1,
    SUM(CASE WHEN DepartmentID = 2 THEN SalesAmount END) AS Department2,
    SUM(CASE WHEN DepartmentID = 3 THEN SalesAmount END) AS Department3,
    SUM(CASE WHEN DepartmentID = 4 THEN SalesAmount END) AS Department4
FROM Demo.Sales;

-- ============================================================================
-- 7. Dynamic PIVOT (Concept)
-- ============================================================================

/*
Dynamic PIVOT is useful when the
column list is unknown.

Typical steps:

1. Build the column list.
2. Generate dynamic SQL.
3. Execute using sp_executesql.
*/

-- ============================================================================
-- 8. UNPIVOT Basics
-- ============================================================================

/*
Scenario

Convert quarterly sales columns
into rows.
*/

SELECT
    Department,
    Quarter,
    Sales
FROM
(
    SELECT
        Department,
        Q1,
        Q2,
        Q3,
        Q4
    FROM Demo.MonthlySales
) AS SourceData
UNPIVOT
(
    Sales FOR Quarter IN
    (
        Q1,
        Q2,
        Q3,
        Q4
    )
) AS UnpivotTable;

-- ============================================================================
-- 9. Performance Considerations
-- ============================================================================

/*
Performance Tips

• Filter rows before PIVOT.
• Index grouping columns.
• Avoid dynamic SQL unless required.
• Review execution plans.
• Consider CASE expressions for
  simple transformations.
*/

-- ============================================================================
-- 10. Common Mistakes
-- ============================================================================

/*
Common Mistakes

1. Forgetting to aggregate.

2. Duplicate values causing
unexpected totals.

3. Using PIVOT when CASE
is simpler.

4. Hardcoding column names
without documentation.

5. Pivoting excessively large datasets.
*/

-- ============================================================================
-- 11. Best Practices
-- ============================================================================

/*
Best Practices

✓ Keep source queries simple.

✓ Filter data before pivoting.

✓ Document expected output.

✓ Prefer CASE for small reports.

✓ Use Dynamic PIVOT only when
necessary.

✓ Format PIVOT clauses clearly.

✓ Review execution plans on
large datasets.
*/

-- ============================================================================
-- Summary
-- ============================================================================

/*
PIVOT
    Converts rows into columns.

UNPIVOT
    Converts columns into rows.

Use PIVOT for reporting,
cross-tab analysis and dashboards.

Use UNPIVOT when normalizing
wide datasets for further processing.
*/