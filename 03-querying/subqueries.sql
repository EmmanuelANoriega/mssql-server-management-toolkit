/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       subqueries.sql
Purpose:    Using subqueries to retrieve and manipulate related data
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics Covered:
    1. Scalar subqueries
    2. Single-row subqueries
    3. Multi-row subqueries
    4. Correlated subqueries
    5. EXISTS
    6. NOT EXISTS
    7. IN
    8. NOT IN
    9. ANY
    10. ALL
    11. Subqueries in SELECT
    12. Subqueries in FROM
    13. Subqueries in WHERE
    14. Subqueries in HAVING
    15. Nested subqueries
    16. Best practices

Prerequisites:
    - Demo.Employees
    - Demo.Departments
    - Demo.Sales

Note:
    These examples use demonstration objects. Refer to the project README
    for additional information regarding the sample schema.

===============================================================================
*/

-- ============================================================================
-- 1. Scalar Subquery
-- ============================================================================

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    (
        SELECT AVG(Salary)
        FROM Demo.Employees
    ) AS CompanyAverageSalary
FROM Demo.Employees;

-- ============================================================================
-- 2. Single-row Subquery
-- ============================================================================

SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Demo.Employees
WHERE Salary >
(
    SELECT AVG(Salary)
    FROM Demo.Employees
);

-- ============================================================================
-- 3. Multi-row Subquery
-- ============================================================================

SELECT
    EmployeeID,
    FirstName,
    DepartmentID
FROM Demo.Employees
WHERE DepartmentID IN
(
    SELECT DepartmentID
    FROM Demo.Departments
);

-- ============================================================================
-- 4. Correlated Subquery
-- ============================================================================

SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Demo.Employees e
WHERE Salary >
(
    SELECT AVG(Salary)
    FROM Demo.Employees
    WHERE DepartmentID = e.DepartmentID
);

-- ============================================================================
-- 5. EXISTS
-- ============================================================================

SELECT
    DepartmentID,
    DepartmentName
FROM Demo.Departments d
WHERE EXISTS
(
    SELECT 1
    FROM Demo.Employees e
    WHERE e.DepartmentID = d.DepartmentID
);

-- ============================================================================
-- 6. NOT EXISTS
-- ============================================================================

SELECT
    DepartmentID,
    DepartmentName
FROM Demo.Departments d
WHERE NOT EXISTS
(
    SELECT 1
    FROM Demo.Employees e
    WHERE e.DepartmentID = d.DepartmentID
);

-- ============================================================================
-- 7. IN
-- ============================================================================

SELECT *
FROM Demo.Employees
WHERE DepartmentID IN
(
    SELECT DepartmentID
    FROM Demo.Departments
);

-- ============================================================================
-- 8. NOT IN
-- ============================================================================

SELECT *
FROM Demo.Employees
WHERE DepartmentID NOT IN
(
    SELECT DepartmentID
    FROM Demo.Departments
);-- ============================================================================
-- 9. ANY
-- ============================================================================

SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Demo.Employees
WHERE Salary > ANY
(
    SELECT Salary
    FROM Demo.Employees
    WHERE DepartmentID = 2
);

-- ============================================================================
-- 10. ALL
-- ============================================================================

SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Demo.Employees
WHERE Salary >= ALL
(
    SELECT Salary
    FROM Demo.Employees
    WHERE DepartmentID = 2
);

-- ============================================================================
-- 11. Subquery in SELECT
-- ============================================================================

SELECT
    e.EmployeeID,
    e.FirstName,
    (
        SELECT d.DepartmentName
        FROM Demo.Departments d
        WHERE d.DepartmentID = e.DepartmentID
    ) AS DepartmentName
FROM Demo.Employees e;

-- ============================================================================
-- 12. Subquery in FROM
-- ============================================================================

SELECT
    DepartmentID,
    AverageSalary
FROM
(
    SELECT
        DepartmentID,
        AVG(Salary) AS AverageSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
) AS DepartmentSummary
ORDER BY AverageSalary DESC;

-- ============================================================================
-- 13. Subquery in WHERE
-- ============================================================================

SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Demo.Employees
WHERE DepartmentID =
(
    SELECT DepartmentID
    FROM Demo.Departments
    WHERE DepartmentName = 'Sales'
);

-- ============================================================================
-- 14. Subquery in HAVING
-- ============================================================================

SELECT
    DepartmentID,
    AVG(Salary) AS AverageSalary
FROM Demo.Employees
GROUP BY DepartmentID
HAVING AVG(Salary) >
(
    SELECT AVG(Salary)
    FROM Demo.Employees
);

-- ============================================================================
-- 15. Nested Subqueries
-- ============================================================================

SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Demo.Employees
WHERE DepartmentID IN
(
    SELECT DepartmentID
    FROM Demo.Departments
    WHERE DepartmentID IN
    (
        SELECT DepartmentID
        FROM Demo.Employees
        GROUP BY DepartmentID
        HAVING COUNT(*) >= 5
    )
);

-- ============================================================================
-- 16. Best Practices
-- ============================================================================

/*
Best Practices

1. Prefer EXISTS over IN for large correlated datasets.
2. Keep subqueries as simple as possible.
3. Replace complex nested subqueries with CTEs when readability improves.
4. Ensure subqueries return the expected number of rows.
5. Avoid unnecessary nesting.
6. Review execution plans for correlated subqueries.
7. Use aliases consistently for readability.
*/