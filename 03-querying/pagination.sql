/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       pagination.sql
Purpose:    Pagination techniques for SQL Server queries and APIs
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. Basic OFFSET / FETCH
2. Pagination with variables
3. Pagination using page number
4. Pagination with total row count
5. Pagination with COUNT(*) OVER()
6. Pagination with ORDER BY
7. Pagination with filters
8. Keyset / Cursor Pagination
9. Pagination with multiple columns
10. API-style pagination
11. Pagination performance considerations

===============================================================================
*/


/* ============================================================================
   1. Basic OFFSET / FETCH
   ============================================================================ */

/*
Return the first 10 records.

OFFSET = Number of rows to skip
FETCH  = Number of rows to return
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary
FROM Demo.Employees
ORDER BY EmployeeID
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;
GO


/* ============================================================================
   2. Return the second page
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary
FROM Demo.Employees
ORDER BY EmployeeID
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;
GO


/* ============================================================================
   3. Pagination using variables
   ============================================================================ */

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary
FROM Demo.Employees
ORDER BY EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   4. Pagination with different page sizes
   ============================================================================ */

DECLARE @PageNumber INT = 3;
DECLARE @PageSize INT = 25;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary
FROM Demo.Employees
ORDER BY EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   5. Calculate total number of pages
   ============================================================================ */

DECLARE @PageSize INT = 10;

SELECT
    COUNT(*) AS TotalRows,

    CEILING(
        COUNT(*) * 1.0 / @PageSize
    ) AS TotalPages

FROM Demo.Employees;
GO


/* ============================================================================
   6. Pagination with total row count
   ============================================================================ */

/*
COUNT(*) OVER() returns the total number of matching rows
without requiring a separate COUNT query.
*/

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary,

    COUNT(*) OVER() AS TotalRows

FROM Demo.Employees

ORDER BY EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   7. Calculate total pages in the result
   ============================================================================ */

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,

    COUNT(*) OVER() AS TotalRows,

    CEILING(
        COUNT(*) OVER() * 1.0 / @PageSize
    ) AS TotalPages

FROM Demo.Employees

ORDER BY EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   8. Pagination with filtering
   ============================================================================ */

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @DepartmentID INT = 1;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary

FROM Demo.Employees

WHERE DepartmentID = @DepartmentID

ORDER BY EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   9. Pagination with salary filtering
   ============================================================================ */

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @MinimumSalary DECIMAL(12,2) = 50000;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary

FROM Demo.Employees

WHERE Salary >= @MinimumSalary

ORDER BY Salary DESC, EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   10. Pagination with multiple sorting columns
   ============================================================================ */

/*
Always include a deterministic tie-breaker.

EmployeeID ensures that records with identical salaries
still have a stable ordering.
*/

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 20;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary

FROM Demo.Employees

ORDER BY
    Salary DESC,
    EmployeeID ASC

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   11. API-style pagination
   ============================================================================ */

/*
Typical API request:

GET /employees?page=2&pageSize=20

Parameters:

@PageNumber = 2
@PageSize   = 20
*/

DECLARE @PageNumber INT = 2;
DECLARE @PageSize INT = 20;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary,
    HireDate,

    @PageNumber AS CurrentPage,
    @PageSize AS PageSize,

    COUNT(*) OVER() AS TotalRecords,

    CEILING(
        COUNT(*) OVER() * 1.0 / @PageSize
    ) AS TotalPages

FROM Demo.Employees

ORDER BY EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   12. Pagination with CTE
   ============================================================================ */

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

WITH EmployeeData AS
(
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        Email,
        DepartmentID,
        Salary,

        ROW_NUMBER() OVER
        (
            ORDER BY EmployeeID
        ) AS RowNumber

    FROM Demo.Employees
)

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary

FROM EmployeeData

WHERE RowNumber BETWEEN
    ((@PageNumber - 1) * @PageSize) + 1

AND
    (@PageNumber * @PageSize)

ORDER BY RowNumber;
GO


/* ============================================================================
   13. Pagination using ROW_NUMBER
   ============================================================================ */

/*
Alternative pagination technique.

Useful when working with older SQL Server versions
or when additional row-number logic is required.
*/

DECLARE @PageNumber INT = 2;
DECLARE @PageSize INT = 10;

WITH NumberedEmployees AS
(
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        Email,
        Salary,

        ROW_NUMBER() OVER
        (
            ORDER BY EmployeeID
        ) AS RowNumber

    FROM Demo.Employees
)

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,
    Salary

FROM NumberedEmployees

WHERE RowNumber >
    (@PageNumber - 1) * @PageSize

AND RowNumber <=
    @PageNumber * @PageSize

ORDER BY RowNumber;
GO


/* ============================================================================
   14. Keyset / Cursor Pagination
   ============================================================================ */

/*
Keyset pagination is often more efficient than OFFSET pagination
for very large tables.

Instead of saying:

"Skip 100,000 rows"

we say:

"Give me records after EmployeeID 100000"

This avoids scanning large numbers of rows.
*/

DECLARE @LastEmployeeID INT = 100;
DECLARE @PageSize INT = 20;

SELECT TOP (@PageSize)
    EmployeeID,
    FirstName,
    LastName,
    Email,
    DepartmentID,
    Salary

FROM Demo.Employees

WHERE EmployeeID > @LastEmployeeID

ORDER BY EmployeeID;
GO


/* ============================================================================
   15. Keyset pagination with composite ordering
   ============================================================================ */

/*
When sorting by multiple columns, use a matching keyset condition.

Example ordering:

Salary DESC,
EmployeeID ASC
*/

DECLARE @LastSalary DECIMAL(12,2) = 75000;
DECLARE @LastEmployeeID INT = 100;
DECLARE @PageSize INT = 20;

SELECT TOP (@PageSize)
    EmployeeID,
    FirstName,
    LastName,
    Salary

FROM Demo.Employees

WHERE
    Salary < @LastSalary

    OR
    (
        Salary = @LastSalary
        AND EmployeeID > @LastEmployeeID
    )

ORDER BY
    Salary DESC,
    EmployeeID ASC;
GO


/* ============================================================================
   16. Keyset pagination with JOIN
   ============================================================================ */

DECLARE @LastEmployeeID INT = 100;
DECLARE @PageSize INT = 20;

SELECT TOP (@PageSize)
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.Salary,
    d.DepartmentName

FROM Demo.Employees e

LEFT JOIN Demo.Departments d
    ON e.DepartmentID = d.DepartmentID

WHERE e.EmployeeID > @LastEmployeeID

ORDER BY e.EmployeeID;
GO


/* ============================================================================
   17. Pagination with search
   ============================================================================ */

DECLARE @SearchTerm NVARCHAR(100) = 'John';
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,

    COUNT(*) OVER() AS TotalResults

FROM Demo.Employees

WHERE
    FirstName LIKE '%' + @SearchTerm + '%'

    OR LastName LIKE '%' + @SearchTerm + '%'

    OR Email LIKE '%' + @SearchTerm + '%'

ORDER BY EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   18. Validate pagination parameters
   ============================================================================ */

/*
Applications should validate pagination parameters.

Example:
*/

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 25;

IF @PageNumber < 1
    SET @PageNumber = 1;

IF @PageSize < 1
    SET @PageSize = 10;

IF @PageSize > 100
    SET @PageSize = 100;

SELECT
    @PageNumber AS ValidatedPageNumber,
    @PageSize AS ValidatedPageSize;
GO


/* ============================================================================
   19. Prevent excessive OFFSET values
   ============================================================================ */

/*
Large OFFSET values can become expensive.

Example:

OFFSET 1000000 ROWS

SQL Server may need to process a large number of rows
before returning the requested page.

For large datasets, consider Keyset Pagination.
*/


DECLARE @PageNumber INT = 100;
DECLARE @PageSize INT = 50;

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary

FROM Demo.Employees

ORDER BY EmployeeID

OFFSET
    (@PageNumber - 1) * @PageSize ROWS

FETCH NEXT
    @PageSize ROWS ONLY;
GO


/* ============================================================================
   20. OFFSET vs Keyset Pagination
   ============================================================================ */

/*
OFFSET / FETCH

Best for:

- Small and medium datasets
- User-facing reports
- Direct page navigation
- "Go to page 10" functionality

Example:

Page 10
Page 20
Page 50


Keyset Pagination

Best for:

- Large datasets
- Infinite scrolling
- APIs
- Mobile applications
- "Load more" interfaces

Example:

GET /employees?afterId=100


Performance consideration:

OFFSET:
    The database may scan/skip many rows.

Keyset:
    The database can seek directly using an indexed key.

===============================================================================
*/


/* ============================================================================
   21. Recommended pagination indexes
   ============================================================================ */

/*
For:

ORDER BY EmployeeID

Consider:

CREATE INDEX IX_Employees_EmployeeID
ON Demo.Employees(EmployeeID);


For:

ORDER BY DepartmentID, EmployeeID

Consider:

CREATE INDEX IX_Employees_Department_Employee
ON Demo.Employees(DepartmentID, EmployeeID);


For:

ORDER BY Salary DESC, EmployeeID

Consider:

CREATE INDEX IX_Employees_Salary_Employee
ON Demo.Employees(Salary DESC, EmployeeID);
*/


/* ============================================================================
   22. Pagination best practices
   ============================================================================ */

/*
Recommended practices:

1. Always use ORDER BY with pagination.

2. Ensure the ORDER BY produces deterministic results.

3. Include a unique tie-breaker such as EmployeeID.

4. Validate @PageNumber and @PageSize.

5. Set a maximum page size.

6. Use indexes that support the ORDER BY clause.

7. Use OFFSET/FETCH for normal page navigation.

8. Use Keyset Pagination for very large datasets.

9. Avoid excessive OFFSET values.

10. Use COUNT(*) OVER() when total result count is needed.

11. Be aware that COUNT(*) OVER() may add overhead on large datasets.

12. Consider API requirements when choosing the pagination strategy.

===============================================================================
END OF FILE
===============================================================================
*/