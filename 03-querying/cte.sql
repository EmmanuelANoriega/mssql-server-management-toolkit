/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       cte.sql
Purpose:    Common Table Expressions (CTEs) in SQL Server
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. Basic CTE
2. CTE with filtering
3. CTE with aggregation
4. Multiple CTEs
5. CTE with JOIN
6. Recursive CTE
7. CTE with UPDATE
8. CTE with DELETE
9. CTE with ranking
10. CTE best practices

===============================================================================
*/


/* ============================================================================
   1. Basic CTE
   ============================================================================ */

WITH EmployeeList AS
(
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        DepartmentID,
        Salary
    FROM Demo.Employees
)
SELECT *
FROM EmployeeList;
GO


/* ============================================================================
   2. CTE with filtering
   ============================================================================ */

WITH HighSalaryEmployees AS
(
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        Salary
    FROM Demo.Employees
    WHERE Salary > 75000
)
SELECT *
FROM HighSalaryEmployees
ORDER BY Salary DESC;
GO


/* ============================================================================
   3. CTE with aggregation
   ============================================================================ */

WITH DepartmentStatistics AS
(
    SELECT
        DepartmentID,
        COUNT(*) AS EmployeeCount,
        AVG(Salary) AS AverageSalary,
        MIN(Salary) AS MinimumSalary,
        MAX(Salary) AS MaximumSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
)
SELECT *
FROM DepartmentStatistics
ORDER BY AverageSalary DESC;
GO


/* ============================================================================
   4. Multiple CTEs
   ============================================================================ */

WITH DepartmentStats AS
(
    SELECT
        DepartmentID,
        COUNT(*) AS EmployeeCount,
        AVG(Salary) AS AverageSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
),
HighValueDepartments AS
(
    SELECT *
    FROM DepartmentStats
    WHERE AverageSalary > 70000
)
SELECT *
FROM HighValueDepartments;
GO


/* ============================================================================
   5. CTE with JOIN
   ============================================================================ */

WITH EmployeeData AS
(
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Salary,
        d.DepartmentName
    FROM Demo.Employees e
    INNER JOIN Demo.Departments d
        ON e.DepartmentID = d.DepartmentID
)
SELECT *
FROM EmployeeData
ORDER BY DepartmentName, LastName;
GO


/* ============================================================================
   6. Recursive CTE - Organizational hierarchy
   ============================================================================ */

/*
Example structure:

EmployeeID
ManagerID
EmployeeName

The recursive CTE allows SQL Server to traverse an organizational hierarchy.
*/

WITH EmployeeHierarchy AS
(
    -- Anchor member
    SELECT
        EmployeeID,
        ManagerID,
        FirstName,
        LastName,
        0 AS HierarchyLevel
    FROM Demo.Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- Recursive member
    SELECT
        e.EmployeeID,
        e.ManagerID,
        e.FirstName,
        e.LastName,
        eh.HierarchyLevel + 1
    FROM Demo.Employees e
    INNER JOIN EmployeeHierarchy eh
        ON e.ManagerID = eh.EmployeeID
)
SELECT
    EmployeeID,
    ManagerID,
    FirstName,
    LastName,
    HierarchyLevel
FROM EmployeeHierarchy
ORDER BY
    HierarchyLevel,
    LastName
OPTION (MAXRECURSION 100);
GO


/* ============================================================================
   7. CTE with ROW_NUMBER
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
        ) AS SalaryRank
    FROM Demo.Employees
)
SELECT *
FROM RankedEmployees
WHERE SalaryRank <= 3;
GO


/* ============================================================================
   8. CTE with UPDATE
   ============================================================================ */

WITH EmployeesToUpdate AS
(
    SELECT
        EmployeeID,
        Salary
    FROM Demo.Employees
    WHERE DepartmentID = 1
)
UPDATE EmployeesToUpdate
SET Salary = Salary * 1.05;
GO


/* ============================================================================
   9. CTE with DELETE
   ============================================================================ */

WITH InactiveEmployees AS
(
    SELECT
        EmployeeID
    FROM Demo.Employees
    WHERE IsActive = 0
)
DELETE FROM InactiveEmployees;
GO


/* ============================================================================
   10. CTE for duplicate detection
   ============================================================================ */

WITH DuplicateEmails AS
(
    SELECT
        Email,
        COUNT(*) AS EmailCount
    FROM Demo.Employees
    WHERE Email IS NOT NULL
    GROUP BY Email
    HAVING COUNT(*) > 1
)
SELECT *
FROM DuplicateEmails;
GO


/* ============================================================================
   11. CTE for duplicate records with ROW_NUMBER
   ============================================================================ */

WITH DuplicateRecords AS
(
    SELECT
        EmployeeID,
        Email,
        ROW_NUMBER() OVER
        (
            PARTITION BY Email
            ORDER BY EmployeeID
        ) AS RowNumber
    FROM Demo.Employees
    WHERE Email IS NOT NULL
)
SELECT *
FROM DuplicateRecords
WHERE RowNumber > 1;
GO


/* ============================================================================
   12. CTE with calculated values
   ============================================================================ */

WITH EmployeeCompensation AS
(
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        Salary,
        Salary * 0.10 AS EstimatedBonus,
        Salary * 1.10 AS TotalCompensation
    FROM Demo.Employees
)
SELECT *
FROM EmployeeCompensation
ORDER BY TotalCompensation DESC;
GO


/* ============================================================================
   13. CTE for department salary comparison
   ============================================================================ */

WITH DepartmentAverage AS
(
    SELECT
        DepartmentID,
        AVG(Salary) AS AverageSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
)
SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.Salary,
    da.AverageSalary,
    e.Salary - da.AverageSalary AS SalaryDifference
FROM Demo.Employees e
INNER JOIN DepartmentAverage da
    ON e.DepartmentID = da.DepartmentID
ORDER BY
    SalaryDifference DESC;
GO


/* ============================================================================
   14. CTE best practices
   ============================================================================ */

/*
Recommended:

- Keep CTEs readable.
- Use meaningful names.
- Avoid unnecessary nesting.
- Validate execution plans.
- Be careful with recursive CTEs.
- Use MAXRECURSION where appropriate.
- Remember that a CTE is not automatically materialized.
- For complex workloads, consider temporary tables when intermediate results
  need to be reused multiple times.

===============================================================================
END OF FILE
===============================================================================
*/