/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       window-functions.sql
Purpose:    Window functions and analytical queries in SQL Server
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. ROW_NUMBER
2. RANK
3. DENSE_RANK
4. NTILE
5. PARTITION BY
6. Running totals
7. Running averages
8. LAG
9. LEAD
10. FIRST_VALUE
11. LAST_VALUE
12. Department ranking
13. Top N per group
14. Pagination
15. Change detection
16. Trend analysis

===============================================================================
*/


/* ============================================================================
   1. ROW_NUMBER
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    ROW_NUMBER() OVER
    (
        ORDER BY Salary DESC
    ) AS RowNumber

FROM Demo.Employees;
GO


/* ============================================================================
   2. ROW_NUMBER with PARTITION BY
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary,

    ROW_NUMBER() OVER
    (
        PARTITION BY DepartmentID
        ORDER BY Salary DESC
    ) AS DepartmentRowNumber

FROM Demo.Employees;
GO


/* ============================================================================
   3. RANK
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    RANK() OVER
    (
        ORDER BY Salary DESC
    ) AS SalaryRank

FROM Demo.Employees;
GO


/*
RANK assigns the same ranking to tied values.

Example:

Salary    Rank

100000    1
100000    1
90000     3

Notice that rank 2 is skipped.
*/


/* ============================================================================
   4. DENSE_RANK
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    DENSE_RANK() OVER
    (
        ORDER BY Salary DESC
    ) AS SalaryRank

FROM Demo.Employees;
GO


/*
DENSE_RANK does not skip ranking numbers.

Example:

100000 -> 1
100000 -> 1
90000  -> 2
*/


/* ============================================================================
   5. NTILE
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    NTILE(4) OVER
    (
        ORDER BY Salary DESC
    ) AS SalaryQuartile

FROM Demo.Employees;
GO


/* ============================================================================
   6. Ranking employees by department
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary,

    RANK() OVER
    (
        PARTITION BY DepartmentID
        ORDER BY Salary DESC
    ) AS DepartmentSalaryRank

FROM Demo.Employees;
GO


/* ============================================================================
   7. Top 3 employees per department
   ============================================================================ */

WITH RankedEmployees AS
(
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        DepartmentID,
        Salary,

        ROW_NUMBER() OVER
        (
            PARTITION BY DepartmentID
            ORDER BY Salary DESC
        ) AS RowNumber

    FROM Demo.Employees
)

SELECT *
FROM RankedEmployees
WHERE RowNumber <= 3;
GO


/* ============================================================================
   8. Running total
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    SUM(Salary) OVER
    (
        ORDER BY EmployeeID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningTotalSalary

FROM Demo.Employees;
GO


/* ============================================================================
   9. Running average
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    AVG(Salary) OVER
    (
        ORDER BY EmployeeID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningAverageSalary

FROM Demo.Employees;
GO


/* ============================================================================
   10. Department running total
   ============================================================================ */

SELECT
    EmployeeID,
    DepartmentID,
    Salary,

    SUM(Salary) OVER
    (
        PARTITION BY DepartmentID
        ORDER BY EmployeeID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS DepartmentRunningTotal

FROM Demo.Employees;
GO


/* ============================================================================
   11. LAG
   ============================================================================ */

/*
LAG accesses a previous row.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    LAG(Salary, 1) OVER
    (
        ORDER BY EmployeeID
    ) AS PreviousSalary

FROM Demo.Employees;
GO


/* ============================================================================
   12. LEAD
   ============================================================================ */

/*
LEAD accesses a following row.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    LEAD(Salary, 1) OVER
    (
        ORDER BY EmployeeID
    ) AS NextSalary

FROM Demo.Employees;
GO


/* ============================================================================
   13. Compare current salary with previous salary
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    LAG(Salary) OVER
    (
        ORDER BY EmployeeID
    ) AS PreviousSalary,

    Salary
    -
    LAG(Salary) OVER
    (
        ORDER BY EmployeeID
    ) AS SalaryDifference

FROM Demo.Employees;
GO


/* ============================================================================
   14. FIRST_VALUE
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary,

    FIRST_VALUE(Salary) OVER
    (
        PARTITION BY DepartmentID
        ORDER BY Salary DESC
    ) AS HighestDepartmentSalary

FROM Demo.Employees;
GO


/* ============================================================================
   15. LAST_VALUE
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary,

    LAST_VALUE(Salary) OVER
    (
        PARTITION BY DepartmentID
        ORDER BY Salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS LowestDepartmentSalary

FROM Demo.Employees;
GO


/* ============================================================================
   16. Compare employee salary with department average
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary,

    AVG(Salary) OVER
    (
        PARTITION BY DepartmentID
    ) AS DepartmentAverageSalary,

    Salary
    -
    AVG(Salary) OVER
    (
        PARTITION BY DepartmentID
    ) AS DifferenceFromDepartmentAverage

FROM Demo.Employees;
GO


/* ============================================================================
   17. Percentage of department payroll
   ============================================================================ */

SELECT
    EmployeeID,
    DepartmentID,
    Salary,

    Salary * 100.0
    /
    NULLIF
    (
        SUM(Salary) OVER
        (
            PARTITION BY DepartmentID
        ),
        0
    ) AS PayrollPercentage

FROM Demo.Employees;
GO


/* ============================================================================
   18. Detect salary changes
   ============================================================================ */

/*
Assumes a salary history table exists.

Example structure:

EmployeeID
Salary
EffectiveDate
*/

SELECT
    EmployeeID,
    Salary,
    EffectiveDate,

    LAG(Salary) OVER
    (
        PARTITION BY EmployeeID
        ORDER BY EffectiveDate
    ) AS PreviousSalary

FROM Demo.EmployeeSalaryHistory;
GO


/* ============================================================================
   19. Detect salary increase or decrease
   ============================================================================ */

SELECT
    EmployeeID,
    Salary,
    EffectiveDate,

    CASE
        WHEN Salary >
            LAG(Salary) OVER
            (
                PARTITION BY EmployeeID
                ORDER BY EffectiveDate
            )
            THEN 'Increase'

        WHEN Salary <
            LAG(Salary) OVER
            (
                PARTITION BY EmployeeID
                ORDER BY EffectiveDate
            )
            THEN 'Decrease'

        ELSE 'No Change'
    END AS SalaryChange

FROM Demo.EmployeeSalaryHistory;
GO


/* ============================================================================
   20. Window functions best practices
   ============================================================================ */

/*
Important considerations:

- Always define a deterministic ORDER BY when ranking data.
- Use PARTITION BY to reset calculations by group.
- Be careful with window frame definitions.
- LAG and LEAD are useful for trend analysis.
- Window functions can reduce the need for self-joins.
- Review execution plans for large datasets.
- Index columns used in PARTITION BY and ORDER BY when appropriate.

===============================================================================
END OF FILE
===============================================================================
*/