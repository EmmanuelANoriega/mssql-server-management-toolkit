/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       aggregate-functions.sql
Purpose:    Aggregate functions for summarizing and analyzing data
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics Covered:
    1. COUNT
    2. COUNT(DISTINCT)
    3. SUM
    4. AVG
    5. MIN and MAX
    6. GROUP BY
    7. GROUP BY multiple columns
    8. HAVING
    9. WHERE vs HAVING
    10. Conditional aggregation
    11. Aggregate functions with JOINs
    12. Aggregate functions with CASE
    13. ROLLUP
    14. CUBE
    15. GROUPING SETS
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
-- 1. COUNT
-- ============================================================================

-- Count all employees
SELECT COUNT(*) AS TotalEmployees
FROM Demo.Employees;

-- Count employees with a department assigned
SELECT COUNT(DepartmentID) AS EmployeesWithDepartment
FROM Demo.Employees;

-- ============================================================================
-- 2. COUNT DISTINCT
-- ============================================================================

-- Count unique departments
SELECT COUNT(DISTINCT DepartmentID) AS TotalDepartments
FROM Demo.Employees;

-- ============================================================================
-- 3. SUM
-- ============================================================================

-- Total payroll
SELECT
    SUM(Salary) AS TotalPayroll
FROM Demo.Employees;

-- Total sales amount
SELECT
    SUM(SalesAmount) AS TotalSales
FROM Demo.Sales;

-- ============================================================================
-- 4. AVG
-- ============================================================================

-- Average employee salary
SELECT
    AVG(Salary) AS AverageSalary
FROM Demo.Employees;

-- Average sales amount
SELECT
    AVG(SalesAmount) AS AverageSale
FROM Demo.Sales;

-- ============================================================================
-- 5. MIN and MAX
-- ============================================================================

SELECT
    MIN(Salary) AS LowestSalary,
    MAX(Salary) AS HighestSalary
FROM Demo.Employees;

SELECT
    MIN(SalesAmount) AS SmallestSale,
    MAX(SalesAmount) AS LargestSale
FROM Demo.Sales;

-- ============================================================================
-- 6. GROUP BY
-- ============================================================================

SELECT
    DepartmentID,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AverageSalary
FROM Demo.Employees
GROUP BY DepartmentID
ORDER BY DepartmentID;

-- ============================================================================
-- 7. GROUP BY Multiple Columns
-- ============================================================================

SELECT
    DepartmentID,
    YEAR(HireDate) AS HireYear,
    COUNT(*) AS EmployeesHired
FROM Demo.Employees
GROUP BY
    DepartmentID,
    YEAR(HireDate)
ORDER BY
    DepartmentID,
    HireYear;

-- ============================================================================
-- 8. HAVING
-- ============================================================================

SELECT
    DepartmentID,
    COUNT(*) AS EmployeeCount
FROM Demo.Employees
GROUP BY DepartmentID
HAVING COUNT(*) >= 5;

-- ============================================================================
-- 9. WHERE vs HAVING
-- ============================================================================

-- WHERE filters rows before aggregation

SELECT
    DepartmentID,
    AVG(Salary) AS AverageSalary
FROM Demo.Employees
WHERE Salary > 50000
GROUP BY DepartmentID;

-- HAVING filters groups after aggregation

SELECT
    DepartmentID,
    AVG(Salary) AS AverageSalary
FROM Demo.Employees
GROUP BY DepartmentID
HAVING AVG(Salary) > 70000;

-- ============================================================================
-- 10. Conditional Aggregation
-- ============================================================================

SELECT
    COUNT(*) AS Employees,
    SUM(CASE WHEN Salary >= 80000 THEN 1 ELSE 0 END) AS HighSalaryEmployees,
    SUM(CASE WHEN Salary < 80000 THEN 1 ELSE 0 END) AS OtherEmployees
FROM Demo.Employees;

-- ============================================================================
-- 11. Aggregate Functions with JOIN
-- ============================================================================

SELECT
    d.DepartmentName,
    COUNT(e.EmployeeID) AS Employees,
    AVG(e.Salary) AS AverageSalary
FROM Demo.Departments AS d
LEFT JOIN Demo.Employees AS e
    ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName
ORDER BY d.DepartmentName;

-- ============================================================================
-- 12. Aggregate Functions with CASE
-- ============================================================================

SELECT
    DepartmentID,
    SUM(CASE WHEN Salary >= 75000 THEN Salary ELSE 0 END) AS SeniorPayroll,
    SUM(CASE WHEN Salary < 75000 THEN Salary ELSE 0 END) AS JuniorPayroll
FROM Demo.Employees
GROUP BY DepartmentID;

-- ============================================================================
-- 13. ROLLUP
-- ============================================================================

SELECT
    DepartmentID,
    COUNT(*) AS Employees
FROM Demo.Employees
GROUP BY ROLLUP (DepartmentID);

-- ============================================================================
-- 14. CUBE
-- ============================================================================

SELECT
    DepartmentID,
    YEAR(HireDate) AS HireYear,
    COUNT(*) AS Employees
FROM Demo.Employees
GROUP BY CUBE
(
    DepartmentID,
    YEAR(HireDate)
);

-- ============================================================================
-- 15. GROUPING SETS
-- ============================================================================

SELECT
    DepartmentID,
    YEAR(HireDate) AS HireYear,
    COUNT(*) AS Employees
FROM Demo.Employees
GROUP BY GROUPING SETS
(
    (DepartmentID),
    (YEAR(HireDate)),
    ()
);

-- ============================================================================
-- Best Practices
-- ============================================================================

/*
1. Prefer COUNT(*) when counting rows.
2. Use COUNT(column) to ignore NULL values.
3. Filter rows with WHERE before aggregation whenever possible.
4. Use HAVING only for aggregate filtering.
5. Index columns frequently used in GROUP BY.
6. Avoid unnecessary DISTINCT operations.
7. Use meaningful aliases for aggregated values.
*/
-- ============================================================================
-- 16. Aggregate by Year
-- ============================================================================

SELECT
    YEAR(HireDate) AS HireYear,
    COUNT(*) AS EmployeesHired,
    AVG(Salary) AS AverageSalary
FROM Demo.Employees
GROUP BY YEAR(HireDate)
ORDER BY HireYear;

-- ============================================================================
-- 17. Aggregate by Month
-- ============================================================================

SELECT
    YEAR(HireDate) AS HireYear,
    MONTH(HireDate) AS HireMonth,
    COUNT(*) AS EmployeesHired
FROM Demo.Employees
GROUP BY
    YEAR(HireDate),
    MONTH(HireDate)
ORDER BY
    HireYear,
    HireMonth;

-- ============================================================================
-- 18. Aggregate with Subquery
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
-- 19. Aggregate with Common Table Expression (CTE)
-- ============================================================================

WITH DepartmentTotals AS
(
    SELECT
        DepartmentID,
        COUNT(*) AS EmployeeCount,
        AVG(Salary) AS AverageSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
)
SELECT *
FROM DepartmentTotals
ORDER BY AverageSalary DESC;

-- ============================================================================
-- 20. Aggregate with NULL Handling
-- ============================================================================

SELECT
    COUNT(*) AS Employees,
    AVG(ISNULL(Salary, 0)) AS AverageSalary,
    SUM(ISNULL(Salary, 0)) AS TotalPayroll
FROM Demo.Employees;