/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       joins.sql
Purpose:    Combining data from multiple tables using SQL Server JOIN operations
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics Covered:
    1. INNER JOIN
    2. LEFT JOIN
    3. RIGHT JOIN
    4. FULL OUTER JOIN
    5. CROSS JOIN
    6. SELF JOIN
    7. Multiple JOINs
    8. Table aliases
    9. Filtering JOIN results
    10. JOIN predicates
    11. JOIN with GROUP BY
    12. JOIN with HAVING
    13. JOIN with CASE
    14. INNER JOIN vs LEFT JOIN
    15. Anti JOIN
    16. EXISTS vs JOIN
    17. CROSS APPLY
    18. OUTER APPLY
    19. Joining derived tables
    20. Joining CTEs
    21. Joining aggregated data
    22. Performance considerations
    23. Common mistakes
    24. Best practices

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
-- 1. INNER JOIN
-- ============================================================================

/*
Scenario

Retrieve all employees together with the department
to which they belong.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
ORDER BY
    d.DepartmentName,
    e.LastName;

-- ============================================================================
-- 2. LEFT JOIN
-- ============================================================================

/*
Scenario

Return every employee, even if no department
has been assigned.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM Demo.Employees AS e
LEFT JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
ORDER BY
    e.EmployeeID;

-- ============================================================================
-- 3. RIGHT JOIN
-- ============================================================================

/*
Scenario

Display all departments including those
without employees.
*/

SELECT
    d.DepartmentID,
    d.DepartmentName,
    e.EmployeeID,
    e.FirstName
FROM Demo.Employees AS e
RIGHT JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
ORDER BY
    d.DepartmentName;

-- ============================================================================
-- 4. FULL OUTER JOIN
-- ============================================================================

/*
Scenario

Return every employee and every department,
including unmatched rows.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    d.DepartmentName
FROM Demo.Employees AS e
FULL OUTER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
ORDER BY
    d.DepartmentName;

-- ============================================================================
-- 5. CROSS JOIN
-- ============================================================================

/*
Scenario

Generate every possible combination of
employees and departments.
*/

SELECT
    e.FirstName,
    d.DepartmentName
FROM Demo.Employees AS e
CROSS JOIN Demo.Departments AS d;

-- ============================================================================
-- Performance Note
-- ============================================================================

/*
A CROSS JOIN returns the Cartesian product.

Number of rows returned:

Employees × Departments

Avoid using CROSS JOIN unless every possible
combination is actually required.
*/

-- ============================================================================
-- 6. SELF JOIN
-- ============================================================================

/*
Scenario

Display each employee together with
their manager.
*/

SELECT
    emp.EmployeeID,
    emp.FirstName AS Employee,
    mgr.FirstName AS Manager
FROM Demo.Employees AS emp
LEFT JOIN Demo.Employees AS mgr
    ON emp.ManagerID = mgr.EmployeeID
ORDER BY
    Employee;

-- ============================================================================
-- 7. Multiple JOINs
-- ============================================================================

/*
Scenario

Retrieve employees, departments
and their sales information.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    d.DepartmentName,
    s.SalesAmount
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
LEFT JOIN Demo.Sales AS s
    ON e.EmployeeID = s.EmployeeID
ORDER BY
    d.DepartmentName,
    e.LastName;

-- ============================================================================
-- 8. Using Table Aliases
-- ============================================================================

/*
Aliases improve readability,
especially when multiple tables
participate in the same query.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    d.DepartmentName
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID;

-- ============================================================================
-- Best Practice
-- ============================================================================

/*
Use short but meaningful aliases.

Recommended:

e = Employees
d = Departments
s = Sales

Avoid aliases such as:

A
B
T1
T2
*/

-- ============================================================================
-- 9. Filtering JOIN Results
-- ============================================================================

/*
Scenario

Retrieve employees from the IT department
earning more than 60,000.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName,
    e.Salary
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
WHERE
    d.DepartmentName = 'IT'
    AND e.Salary > 60000
ORDER BY e.Salary DESC;

-- ============================================================================
-- 10. JOIN Predicates
-- ============================================================================

/*
Additional conditions can be placed
inside the ON clause.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    d.DepartmentName
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
   AND d.Active = 1;

-- ============================================================================
-- 11. JOIN with GROUP BY
-- ============================================================================

SELECT
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount,
    AVG(e.Salary) AS AverageSalary
FROM Demo.Departments AS d
LEFT JOIN Demo.Employees AS e
    ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName
ORDER BY EmployeeCount DESC;

-- ============================================================================
-- 12. JOIN with HAVING
-- ============================================================================

SELECT
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount
FROM Demo.Departments AS d
INNER JOIN Demo.Employees AS e
    ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName
HAVING COUNT(e.EmployeeID) >= 5;

-- ============================================================================
-- 13. JOIN with CASE
-- ============================================================================

SELECT
    e.FirstName,
    d.DepartmentName,
    CASE
        WHEN e.Salary >= 80000 THEN 'Senior'
        WHEN e.Salary >= 60000 THEN 'Mid-Level'
        ELSE 'Junior'
    END AS EmployeeLevel
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID;

-- ============================================================================
-- 14. INNER JOIN vs LEFT JOIN
-- ============================================================================

/*
INNER JOIN:
Returns only matching rows.

LEFT JOIN:
Returns every row from the left table,
including unmatched rows.
*/

-- INNER JOIN

SELECT
    e.EmployeeID,
    d.DepartmentName
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID;

-- LEFT JOIN

SELECT
    e.EmployeeID,
    d.DepartmentName
FROM Demo.Employees AS e
LEFT JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID;

-- ============================================================================
-- 15. Anti JOIN
-- ============================================================================

/*
Scenario

Find departments that currently have
no employees assigned.
*/

SELECT
    d.DepartmentID,
    d.DepartmentName
FROM Demo.Departments AS d
LEFT JOIN Demo.Employees AS e
    ON d.DepartmentID = e.DepartmentID
WHERE e.EmployeeID IS NULL;

-- ============================================================================
-- 16. EXISTS vs JOIN
-- ============================================================================

/*
Scenario

Return departments that have at least
one employee assigned.

EXISTS stops searching after finding the
first matching row, making it efficient
for existence checks.
*/

SELECT
    d.DepartmentID,
    d.DepartmentName
FROM Demo.Departments AS d
WHERE EXISTS
(
    SELECT 1
    FROM Demo.Employees AS e
    WHERE e.DepartmentID = d.DepartmentID
);

-- Equivalent JOIN

SELECT DISTINCT
    d.DepartmentID,
    d.DepartmentName
FROM Demo.Departments AS d
INNER JOIN Demo.Employees AS e
    ON d.DepartmentID = e.DepartmentID;

-- ============================================================================
-- 17. CROSS APPLY
-- ============================================================================

/*
Scenario

Retrieve the highest sale for each employee.

CROSS APPLY evaluates the right-side query
for every row from the left-side table.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    s.SalesAmount,
    s.SaleDate
FROM Demo.Employees AS e
CROSS APPLY
(
    SELECT TOP (1)
        SalesAmount,
        SaleDate
    FROM Demo.Sales
    WHERE EmployeeID = e.EmployeeID
    ORDER BY SalesAmount DESC
) AS s;

-- ============================================================================
-- 18. OUTER APPLY
-- ============================================================================

/*
Scenario

Return all employees even if they
have never made a sale.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    s.SalesAmount,
    s.SaleDate
FROM Demo.Employees AS e
OUTER APPLY
(
    SELECT TOP (1)
        SalesAmount,
        SaleDate
    FROM Demo.Sales
    WHERE EmployeeID = e.EmployeeID
    ORDER BY SaleDate DESC
) AS s;

-- ============================================================================
-- 19. Joining Derived Tables
-- ============================================================================

/*
Scenario

Join employees with departmental
salary statistics.
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    ds.AverageSalary
FROM Demo.Employees AS e
INNER JOIN
(
    SELECT
        DepartmentID,
        AVG(Salary) AS AverageSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
) AS ds
    ON e.DepartmentID = ds.DepartmentID;

-- ============================================================================
-- 20. Joining CTEs
-- ============================================================================

WITH DepartmentStatistics AS
(
    SELECT
        DepartmentID,
        COUNT(*) AS EmployeeCount,
        AVG(Salary) AS AverageSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
)

SELECT
    d.DepartmentName,
    ds.EmployeeCount,
    ds.AverageSalary
FROM Demo.Departments AS d
INNER JOIN DepartmentStatistics AS ds
    ON d.DepartmentID = ds.DepartmentID;

-- ============================================================================
-- 21. Joining Aggregated Data
-- ============================================================================

/*
Scenario

Combine aggregated departmental statistics
with department information.
*/

SELECT
    d.DepartmentName,
    stats.EmployeeCount,
    stats.AverageSalary
FROM Demo.Departments AS d
INNER JOIN
(
    SELECT
        DepartmentID,
        COUNT(*) AS EmployeeCount,
        AVG(Salary) AS AverageSalary,
        SUM(Salary) AS TotalPayroll
    FROM Demo.Employees
    GROUP BY DepartmentID
) AS stats
    ON d.DepartmentID = stats.DepartmentID
ORDER BY
    stats.TotalPayroll DESC;

-- ============================================================================
-- 22. Performance Considerations
-- ============================================================================

/*
Performance Tips

• Join columns should be indexed whenever possible.
• Avoid SELECT * in production queries.
• Filter rows as early as possible.
• Review execution plans for expensive joins.
• Prefer INNER JOIN when unmatched rows are unnecessary.
• Ensure matching data types between join columns.
• Avoid functions in JOIN predicates whenever possible.

Example (Less Efficient)

    ON YEAR(e.HireDate) = YEAR(s.SaleDate)

Preferred

    ON e.HireDate = s.SaleDate
*/

-- ============================================================================
-- 23. Common Mistakes
-- ============================================================================

/*
Common Mistakes

1. Missing JOIN predicates.

Example:

SELECT *
FROM Demo.Employees e
JOIN Demo.Departments d;

This creates an unintended Cartesian product.

------------------------------------------------------------

2. Mixing WHERE and JOIN logic incorrectly.

Incorrect

LEFT JOIN ...
WHERE DepartmentName = 'IT'

The WHERE clause removes NULL rows,
effectively converting the LEFT JOIN
into an INNER JOIN.

------------------------------------------------------------

3. Joining columns with different data types.

------------------------------------------------------------

4. Returning unnecessary columns.

Prefer

SELECT
    EmployeeID,
    FirstName

Instead of

SELECT *

------------------------------------------------------------

5. Forgetting indexes on Foreign Keys.
*/

-- ============================================================================
-- 24. Best Practices
-- ============================================================================

/*
Best Practices

✓ Always use explicit JOIN syntax.

✓ Use meaningful aliases.

✓ Keep JOIN predicates inside the ON clause.

✓ Filter data early whenever possible.

✓ Return only the columns you need.

✓ Verify execution plans for large datasets.

✓ Index Foreign Keys.

✓ Use EXISTS when only checking for existence.

✓ Use LEFT JOIN only when unmatched rows are required.

✓ Keep JOIN logic readable and properly formatted.
*/

-- ============================================================================
-- Summary
-- ============================================================================

/*
JOIN Selection Guide

INNER JOIN
    Matching rows only.

LEFT JOIN
    All rows from the left table.

RIGHT JOIN
    All rows from the right table.

FULL OUTER JOIN
    All matching and non-matching rows.

CROSS JOIN
    Cartesian product.

SELF JOIN
    Join a table to itself.

CROSS APPLY
    Execute a correlated table expression
    for each row.

OUTER APPLY
    Similar to LEFT JOIN for table-valued
    expressions.
*/