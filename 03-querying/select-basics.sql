/*
===============================================================================
MSSQL Server Management Toolkit

SELECT BASICS
===============================================================================

Purpose:
    Practical examples of SELECT queries in Microsoft SQL Server.

Topics Covered:
    1. Basic SELECT
    2. Selecting specific columns
    3. Column aliases
    4. Calculated columns
    5. String concatenation
    6. DISTINCT
    7. TOP
    8. TOP with PERCENT
    9. TOP with TIES
    10. ORDER BY
    11. Sorting by multiple columns
    12. Sorting by column position
    13. Sorting by expressions
    14. NULL handling
    15. ISNULL
    16. COALESCE
    17. CAST and CONVERT
    18. String expressions
    19. Date expressions
    20. Conditional expressions
    21. OFFSET and FETCH
    22. SELECT INTO
    23. DISTINCT with multiple columns
    24. Querying system metadata
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
1. BASIC SELECT
===============================================================================
*/

SELECT *
FROM Demo.Employees;


/*
===============================================================================
2. SELECT SPECIFIC COLUMNS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Demo.Employees;


/*
===============================================================================
3. COLUMN ALIASES
===============================================================================
*/

SELECT
    EmployeeID AS EmployeeNumber,
    FirstName AS GivenName,
    LastName AS FamilyName,
    Salary AS AnnualSalary
FROM Demo.Employees;


/*
===============================================================================
4. CALCULATED COLUMNS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    Salary * 1.10 AS SalaryAfterRaise
FROM Demo.Employees;


/*
===============================================================================
5. STRING CONCATENATION
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName + ' ' + LastName AS FullName
FROM Demo.Employees;


/*
===============================================================================
6. CONCAT FUNCTION
===============================================================================
*/

SELECT
    EmployeeID,
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM Demo.Employees;


/*
===============================================================================
7. DISTINCT VALUES
===============================================================================
*/

SELECT DISTINCT
    DepartmentID
FROM Demo.Employees;


/*
===============================================================================
8. DISTINCT WITH MULTIPLE COLUMNS
===============================================================================
*/

SELECT DISTINCT
    DepartmentID,
    Salary
FROM Demo.Employees
ORDER BY DepartmentID, Salary;


/*
===============================================================================
9. TOP N RECORDS
===============================================================================
*/

SELECT TOP 10
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
ORDER BY Salary DESC;


/*
===============================================================================
10. TOP WITH PERCENT
===============================================================================
*/

SELECT TOP 25 PERCENT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
ORDER BY Salary DESC;


/*
===============================================================================
11. TOP WITH TIES
===============================================================================
*/

SELECT TOP 10 WITH TIES
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
ORDER BY Salary DESC;


/*
===============================================================================
12. ORDER BY
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
ORDER BY Salary DESC;


/*
===============================================================================
13. ORDER BY MULTIPLE COLUMNS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Demo.Employees
ORDER BY
    DepartmentID ASC,
    Salary DESC;


/*
===============================================================================
14. ORDER BY COLUMN POSITION
===============================================================================

Note:
    Ordering by column position is supported but generally less maintainable
    than using explicit column names.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
ORDER BY 4 DESC;


/*
===============================================================================
15. ORDER BY EXPRESSION
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
ORDER BY Salary * 1.10 DESC;


/*
===============================================================================
16. NULL HANDLING WITH ISNULL
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    ISNULL(Email, 'No email available') AS EmailAddress
FROM Demo.Employees;


/*
===============================================================================
17. NULL HANDLING WITH COALESCE
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    COALESCE(Email, 'No email available') AS EmailAddress
FROM Demo.Employees;


/*
===============================================================================
18. NULL HANDLING WITH CONCAT
===============================================================================

CONCAT automatically converts NULL values to empty strings.
*/

SELECT
    EmployeeID,
    CONCAT(
        FirstName,
        ' ',
        LastName,
        ' - ',
        Email
    ) AS EmployeeSummary
FROM Demo.Employees;


/*
===============================================================================
19. CAST
===============================================================================
*/

SELECT
    EmployeeID,
    Salary,
    CAST(Salary AS INT) AS SalaryAsInteger
FROM Demo.Employees;


/*
===============================================================================
20. CONVERT
===============================================================================
*/

SELECT
    EmployeeID,
    Salary,
    CONVERT(INT, Salary) AS SalaryAsInteger
FROM Demo.Employees;


/*
===============================================================================
21. FORMAT NUMERIC VALUES
===============================================================================

Note:
    FORMAT is convenient for presentation but can be slower than native
    conversion functions for large datasets.
*/

SELECT
    EmployeeID,
    Salary,
    FORMAT(Salary, 'C', 'en-US') AS FormattedSalary
FROM Demo.Employees;


/*
===============================================================================
22. DATE EXPRESSIONS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,
    YEAR(HireDate) AS HireYear,
    MONTH(HireDate) AS HireMonth,
    DAY(HireDate) AS HireDay
FROM Demo.Employees;


/*
===============================================================================
23. DATE DIFFERENCE
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsOfService
FROM Demo.Employees;


/*
===============================================================================
24. CONDITIONAL EXPRESSION WITH CASE
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    CASE
        WHEN Salary >= 100000 THEN 'High'
        WHEN Salary >= 75000 THEN 'Medium'
        ELSE 'Standard'
    END AS SalaryCategory
FROM Demo.Employees;


/*
===============================================================================
25. SIMPLE CASE EXPRESSION
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    CASE DepartmentID
        WHEN 1 THEN 'Sales'
        WHEN 2 THEN 'IT'
        WHEN 3 THEN 'Human Resources'
        WHEN 4 THEN 'Finance'
        ELSE 'Other'
    END AS DepartmentCategory
FROM Demo.Employees;


/*
===============================================================================
26. SELECT WITH TABLE ALIAS
===============================================================================
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.Salary
FROM Demo.Employees AS e;


/*
===============================================================================
27. SELECT WITH JOIN
===============================================================================
*/

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID;


/*
===============================================================================
28. SELECT DISTINCT DEPARTMENT INFORMATION
===============================================================================
*/

SELECT DISTINCT
    d.DepartmentID,
    d.DepartmentName
FROM Demo.Employees AS e
INNER JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName;


/*
===============================================================================
29. OFFSET AND FETCH PAGINATION
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
ORDER BY EmployeeID
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;


/*
===============================================================================
30. SECOND PAGE WITH OFFSET AND FETCH
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
ORDER BY EmployeeID
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;


/*
===============================================================================
31. SELECT INTO - CREATE A NEW TABLE
===============================================================================

WARNING:
    SELECT INTO creates a physical table.

    Use only in a controlled development or laboratory environment.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
INTO Demo.EmployeeSalarySnapshot
FROM Demo.Employees;


/*
===============================================================================
32. SELECT INTO WITH FILTERING
===============================================================================

WARNING:
    This creates a new physical table.

    The destination table must not already exist.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
INTO Demo.HighSalaryEmployees
FROM Demo.Employees
WHERE Salary >= 100000;


/*
===============================================================================
33. SELECT WITH CONSTANT VALUES
===============================================================================
*/

SELECT
    'SQL Server' AS DatabasePlatform,
    'Microsoft' AS Vendor,
    GETDATE() AS ExecutionDate;


/*
===============================================================================
34. SELECT WITH VARIABLES
===============================================================================
*/

DECLARE @MinimumSalary DECIMAL(12,2) = 75000;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees
WHERE Salary >= @MinimumSalary
ORDER BY Salary DESC;


/*
===============================================================================
35. SELECT WITH CALCULATED BUSINESS METRICS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    Salary / 12.0 AS MonthlySalary,
    Salary / 26.0 AS BiWeeklySalary,
    Salary * 0.10 AS EstimatedBonus
FROM Demo.Employees;


/*
===============================================================================
36. SELECT WITH STRING FUNCTIONS
===============================================================================
*/

SELECT
    EmployeeID,
    UPPER(FirstName) AS FirstNameUpper,
    LOWER(LastName) AS LastNameLower,
    LEN(FirstName) AS FirstNameLength
FROM Demo.Employees;


/*
===============================================================================
37. SELECT WITH DATE FUNCTIONS
===============================================================================
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,
    DATEADD(YEAR, 1, HireDate) AS FirstAnniversary,
    EOMONTH(HireDate) AS HireMonthEnd
FROM Demo.Employees;


/*
===============================================================================
38. SELECT FROM MULTIPLE TABLES
===============================================================================
*/

SELECT
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    d.DepartmentName,
    d.Location
FROM Demo.Employees AS e
LEFT JOIN Demo.Departments AS d
    ON e.DepartmentID = d.DepartmentID;


/*
===============================================================================
39. SELECT WITH EXISTS
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
40. SELECT WITH A DERIVED TABLE
===============================================================================
*/

SELECT
    DepartmentID,
    EmployeeCount,
    AverageSalary
FROM
(
    SELECT
        DepartmentID,
        COUNT(*) AS EmployeeCount,
        AVG(Salary) AS AverageSalary
    FROM Demo.Employees
    GROUP BY DepartmentID
) AS DepartmentSummary
ORDER BY AverageSalary DESC;


/*
===============================================================================
41. SELECT WITH TABLE HINT
===============================================================================

WARNING:
    NOLOCK can return dirty, non-repeatable, or phantom reads.

    Do not use NOLOCK as a generic performance solution.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Demo.Employees WITH (NOLOCK);


/*
===============================================================================
42. QUERY SQL SERVER SYSTEM METADATA
===============================================================================
*/

SELECT
    name,
    object_id,
    type_desc,
    create_date,
    modify_date
FROM sys.objects
WHERE type = 'U'
ORDER BY name;


/*
===============================================================================
43. QUERY TABLE COLUMNS
===============================================================================
*/

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Demo'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;


/*
===============================================================================
44. QUERY PRIMARY KEY INFORMATION
===============================================================================
*/

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'PRIMARY KEY'
ORDER BY
    TABLE_SCHEMA,
    TABLE_NAME;


/*
===============================================================================
45. BEST PRACTICES
===============================================================================

1. Avoid SELECT * in production queries.

2. Select only the columns required by the application or report.

3. Use meaningful aliases for calculated columns.

4. Always use ORDER BY when result ordering matters.

5. Use TOP together with ORDER BY for deterministic results.

6. Prefer explicit column names over ORDER BY column positions.

7. Use CONCAT when NULL-safe string concatenation is required.

8. Use COALESCE when multiple fallback values are possible.

9. Avoid FORMAT for high-volume data processing when performance matters.

10. Be cautious with SELECT INTO because it creates physical tables.

11. Use NOLOCK only when dirty reads are acceptable.

12. Always test queries against realistic data volumes.

13. Review execution plans for performance-critical queries.

14. Use appropriate indexes to support filtering, joins, and ordering.

15. Use pagination carefully on large datasets and consider keyset
    pagination when OFFSET/FETCH becomes inefficient.

===============================================================================
END OF FILE
===============================================================================