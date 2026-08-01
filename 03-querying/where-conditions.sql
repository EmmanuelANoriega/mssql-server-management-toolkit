/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       where-conditions.sql
Purpose:    Filtering and conditional expressions in SQL Server
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics Covered:
    1. Basic WHERE conditions
    2. Comparison operators
    3. AND / OR operators
    4. Operator precedence
    5. IN operator
    6. NOT IN operator
    7. BETWEEN operator
    8. NOT BETWEEN operator
    9. LIKE operator
    10. Wildcards
    11. NOT LIKE
    12. NULL handling
    13. IS NULL
    14. IS NOT NULL
    15. Multiple conditions
    16. Date filtering
    17. Numeric filtering
    18. String filtering
    19. CASE-based filtering
    20. EXISTS
    21. NOT EXISTS
    22. Filtering with JOINs
    23. Filtering with calculated values
    24. Dynamic filtering with variables
    25. Best practices

Prerequisites:
    - Demo.Employees
    - Demo.Departments
    - Demo.Sales

Note:
    These examples assume the demonstration objects referenced above
    are available in the target SQL Server environment.

===============================================================================
*/


/*
===============================================================================
1. BASIC WHERE CONDITION
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary > 75000;


/*
===============================================================================
2. EQUAL TO
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID
FROM Demo.Employees
WHERE DepartmentID = 1;


/*
===============================================================================
3. NOT EQUAL TO
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID
FROM Demo.Employees
WHERE DepartmentID <> 1;


/*
===============================================================================
4. GREATER THAN
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary > 100000;


/*
===============================================================================
5. GREATER THAN OR EQUAL TO
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary >= 100000;


/*
===============================================================================
6. LESS THAN
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary < 50000;


/*
===============================================================================
7. LESS THAN OR EQUAL TO
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary <= 50000;


/*
===============================================================================
8. AND OPERATOR
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Demo.Employees
WHERE DepartmentID = 1
  AND Salary > 75000;


/*
===============================================================================
9. OR OPERATOR
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID
FROM Demo.Employees
WHERE DepartmentID = 1
   OR DepartmentID = 2;


/*
===============================================================================
10. AND / OR WITH PARENTHESES
===============================================================================

Parentheses make the intended logical evaluation explicit.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Demo.Employees
WHERE
    (DepartmentID = 1 OR DepartmentID = 2)
    AND Salary >= 75000;


/*
===============================================================================
11. OPERATOR PRECEDENCE
===============================================================================

SQL Server evaluates AND before OR.

Use parentheses when combining multiple logical operators.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Demo.Employees
WHERE DepartmentID = 1
   OR DepartmentID = 2
  AND Salary >= 75000;


/*
===============================================================================
12. IN OPERATOR
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID
FROM Demo.Employees
WHERE DepartmentID IN (1, 2, 3);


/*
===============================================================================
13. NOT IN OPERATOR
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID
FROM Demo.Employees
WHERE DepartmentID NOT IN (1, 2, 3);


/*
===============================================================================
14. BETWEEN OPERATOR
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary BETWEEN 50000 AND 100000;


/*
===============================================================================
15. NOT BETWEEN
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary NOT BETWEEN 50000 AND 100000;


/*
===============================================================================
16. DATE FILTERING WITH BETWEEN
===============================================================================

WARNING:
    BETWEEN with datetime values can unintentionally exclude records later
    on the final day when the column contains a time component.

    Prefer half-open date ranges for datetime columns.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate
FROM Demo.Employees
WHERE HireDate BETWEEN '2025-01-01' AND '2025-12-31';


/*
===============================================================================
17. RECOMMENDED DATETIME RANGE FILTER
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate
FROM Demo.Employees
WHERE HireDate >= '2025-01-01'
  AND HireDate < '2026-01-01';


/*
===============================================================================
18. LIKE - STARTS WITH
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE LastName LIKE 'S%';


/*
===============================================================================
19. LIKE - ENDS WITH
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email
FROM Demo.Employees
WHERE Email LIKE '%@company.com';


/*
===============================================================================
20. LIKE - CONTAINS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE LastName LIKE '%son%';


/*
===============================================================================
21. LIKE - SINGLE CHARACTER WILDCARD
===============================================================================

The underscore (_) represents exactly one character.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE FirstName LIKE 'J_n';


/*
===============================================================================
22. LIKE - CHARACTER LIST
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE LastName LIKE '[SM]%';


/*
===============================================================================
23. LIKE - CHARACTER RANGE
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE LastName LIKE '[A-F]%';


/*
===============================================================================
24. LIKE - NEGATED CHARACTER LIST
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE LastName LIKE '[^A-F]%';


/*
===============================================================================
25. NOT LIKE
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE LastName NOT LIKE 'S%';


/*
===============================================================================
26. IS NULL
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email
FROM Demo.Employees
WHERE Email IS NULL;


/*
===============================================================================
27. IS NOT NULL
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email
FROM Demo.Employees
WHERE Email IS NOT NULL;


/*
===============================================================================
28. NULL COMPARISON - INCORRECT APPROACH
===============================================================================

Do not use:

    WHERE Email = NULL

NULL must be evaluated using IS NULL or IS NOT NULL.
*/


/*
===============================================================================
29. FILTERING ACTIVE RECORDS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Active = 1;


/*
===============================================================================
30. FILTERING INACTIVE RECORDS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Active = 0;


/*
===============================================================================
31. MULTIPLE CONDITIONS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary,
    Active
FROM Demo.Employees
WHERE Active = 1
  AND DepartmentID IN (1, 2, 3)
  AND Salary >= 75000;


/*
===============================================================================
32. FILTERING BY STRING VALUES
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE FirstName = 'John';


/*
===============================================================================
33. CASE-SENSITIVE FILTERING WITH COLLATION
===============================================================================

The behavior depends on the database/server collation.

This example forces a case-sensitive comparison.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE FirstName COLLATE Latin1_General_100_CS_AS = 'John';


/*
===============================================================================
34. CASE-INSENSITIVE FILTERING WITH COLLATION
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE FirstName COLLATE Latin1_General_100_CI_AS = 'john';


/*
===============================================================================
35. FILTERING WITH DATE FUNCTIONS
===============================================================================

Note:
    Applying functions directly to indexed columns can affect index usage.

    For large datasets, prefer range predicates when possible.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate
FROM Demo.Employees
WHERE YEAR(HireDate) = 2025;


/*
===============================================================================
36. SARGABLE DATE FILTER
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate
FROM Demo.Employees
WHERE HireDate >= '2025-01-01'
  AND HireDate < '2026-01-01';


/*
===============================================================================
37. FILTERING WITH ISNULL
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email
FROM Demo.Employees
WHERE ISNULL(Email, '') = '';


/*
===============================================================================
38. FILTERING WITH COALESCE
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email
FROM Demo.Employees
WHERE COALESCE(Email, 'unknown') = 'unknown';


/*
===============================================================================
39. EXISTS
===============================================================================
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


/*
===============================================================================
40. NOT EXISTS
===============================================================================
*/

SELECT
    d.DepartmentID,
    d.DepartmentName
FROM Demo.Departments AS d
WHERE NOT EXISTS
(
    SELECT 1
    FROM Demo.Employees AS e
    WHERE e.DepartmentID = d.DepartmentID
);


/*
===============================================================================
41. FILTERING WITH INNER JOIN
===============================================================================
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Sales';


/*
===============================================================================
42. FILTERING WITH LEFT JOIN
===============================================================================
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM Demo.Employees AS e
LEFT JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentID IS NULL;


/*
===============================================================================
43. FILTERING SALES BY DATE
===============================================================================
*/

SELECT
    SaleID,
    EmployeeID,
    SaleDate,
    TotalAmount
FROM Demo.Sales
WHERE SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';


/*
===============================================================================
44. FILTERING SALES BY AMOUNT
===============================================================================
*/

SELECT
    SaleID,
    EmployeeID,
    SaleDate,
    TotalAmount
FROM Demo.Sales
WHERE TotalAmount >= 1000
ORDER BY TotalAmount DESC;


/*
===============================================================================
45. FILTERING USING A VARIABLE
===============================================================================
*/

DECLARE @MinimumSalary DECIMAL(12,2) = 75000;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary >= @MinimumSalary;


/*
===============================================================================
46. MULTIPLE FILTER VARIABLES
===============================================================================
*/

DECLARE @DepartmentID INT = 1;
DECLARE @MinimumSalary DECIMAL(12,2) = 75000;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Demo.Employees
WHERE DepartmentID = @DepartmentID
  AND Salary >= @MinimumSalary;


/*
===============================================================================
47. OPTIONAL FILTER PATTERN
===============================================================================

This pattern can be useful for simple search procedures.

WARNING:
    OR-based optional filters may produce less efficient execution plans
    depending on data volume and parameter values.

    For complex production workloads, consider dynamic SQL with
    sp_executesql or OPTION (RECOMPILE), depending on the scenario.
*/

DECLARE @DepartmentID INT = NULL;
DECLARE @MinimumSalary DECIMAL(12,2) = NULL;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Demo.Employees
WHERE
    (@DepartmentID IS NULL OR DepartmentID = @DepartmentID)
    AND
    (@MinimumSalary IS NULL OR Salary >= @MinimumSalary);


/*
===============================================================================
48. FILTERING USING A TABLE VARIABLE
===============================================================================
*/

DECLARE @Departments TABLE
(
    DepartmentID INT PRIMARY KEY
);

INSERT INTO @Departments
(
    DepartmentID
)
VALUES
    (1),
    (2),
    (3);

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.DepartmentID
FROM Demo.Employees AS e
INNER JOIN @Departments AS d
    ON e.DepartmentID = d.DepartmentID;


/*
===============================================================================
49. FILTERING WITH NOT IN AND NULL WARNING
===============================================================================

NOT IN can produce unexpected results when the subquery contains NULL.

For anti-joins, NOT EXISTS is often safer.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID
FROM Demo.Employees
WHERE DepartmentID NOT IN
(
    SELECT DepartmentID
    FROM Demo.Departments
    WHERE DepartmentID IS NOT NULL
);


/*
===============================================================================
50. FILTERING WITH NOT EXISTS
===============================================================================
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.DepartmentID
FROM Demo.Employees AS e
WHERE NOT EXISTS
(
    SELECT 1
    FROM Demo.Departments AS d
    WHERE d.DepartmentID = e.DepartmentID
);


/*
===============================================================================
51. COMPLEX FILTERING EXAMPLE
===============================================================================
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.DepartmentID,
    e.Salary,
    e.HireDate
FROM Demo.Employees AS e
WHERE e.Active = 1
  AND
  (
        e.Salary >= 100000
        OR
        (
            e.DepartmentID IN (1, 2)
            AND e.Salary >= 75000
        )
  )
  AND e.HireDate < '2026-01-01'
ORDER BY e.Salary DESC;


/*
===============================================================================
52. FILTERING WITH CASE EXPRESSION
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE
    CASE
        WHEN Salary >= 100000 THEN 1
        WHEN Salary >= 75000 THEN 1
        ELSE 0
    END = 1;


/*
===============================================================================
53. FILTERING USING A DERIVED TABLE
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM
(
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        Salary
    FROM Demo.Employees
) AS EmployeeData
WHERE Salary >= 75000;


/*
===============================================================================
54. FILTERING WITH UNION
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary >= 100000

UNION

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE DepartmentID = 1;


/*
===============================================================================
55. BEST PRACTICES
===============================================================================

1. Use parentheses when combining AND and OR conditions.

2. Always remember that AND has higher logical precedence than OR.

3. Use IS NULL and IS NOT NULL for NULL comparisons.

4. Be careful with NOT IN when NULL values are possible.

5. Prefer NOT EXISTS for many anti-join scenarios.

6. Use half-open date ranges for datetime filtering.

7. Avoid applying functions directly to indexed columns when possible.

8. Prefer SARGable predicates for large datasets.

9. Use explicit column names instead of SELECT *.

10. Test optional filter patterns against realistic data volumes.

11. Review execution plans for performance-critical filtering.

12. Avoid unnecessary implicit conversions.

13. Use appropriate indexes for frequently filtered columns.

14. Be aware of database collation when comparing strings.

15. Validate user-supplied search values before building dynamic SQL.

16. Never concatenate untrusted user input directly into SQL statements.

17. Use sp_executesql for parameterized dynamic SQL.

===============================================================================
END OF FILE
===============================================================================
*/