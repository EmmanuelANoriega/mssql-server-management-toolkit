/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       date-functions.sql
Purpose:    Date and time functions in SQL Server
Author:     Emmanuel Alejandro Noriega
===============================================================================
*/


/* ============================================================================
   1. Current date and time
   ============================================================================ */

SELECT
    GETDATE() AS CurrentDateTime,
    SYSDATETIME() AS HighPrecisionDateTime,
    GETUTCDATE() AS CurrentUTCDateTime,
    SYSUTCDATETIME() AS HighPrecisionUTCDateTime;
GO


/* ============================================================================
   2. Current date
   ============================================================================ */

SELECT
    CAST(GETDATE() AS DATE) AS CurrentDate;
GO


/* ============================================================================
   3. DATEFROMPARTS
   ============================================================================ */

SELECT
    DATEFROMPARTS(2026, 7, 28) AS CreatedDate;
GO


/* ============================================================================
   4. DATETIMEFROMPARTS
   ============================================================================ */

SELECT
    DATETIMEFROMPARTS(
        2026,
        7,
        28,
        10,
        30,
        0,
        0
    ) AS CreatedDateTime;
GO


/* ============================================================================
   5. DATEADD
   ============================================================================ */

SELECT
    GETDATE() AS CurrentDate,
    DATEADD(DAY, 30, GETDATE()) AS DateIn30Days,
    DATEADD(MONTH, 3, GETDATE()) AS DateIn3Months,
    DATEADD(YEAR, 1, GETDATE()) AS DateIn1Year;
GO


/* ============================================================================
   6. DATEDIFF
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,

    DATEDIFF(
        YEAR,
        HireDate,
        GETDATE()
    ) AS YearsOfService

FROM Demo.Employees;
GO


/* ============================================================================
   7. DATEDIFF for business calculations
   ============================================================================ */

SELECT
    EmployeeID,
    HireDate,

    DATEDIFF(
        DAY,
        HireDate,
        GETDATE()
    ) AS DaysSinceHire

FROM Demo.Employees;
GO


/* ============================================================================
   8. DATEPART
   ============================================================================ */

SELECT
    EmployeeID,
    HireDate,

    DATEPART(YEAR, HireDate) AS HireYear,
    DATEPART(MONTH, HireDate) AS HireMonth,
    DATEPART(DAY, HireDate) AS HireDay

FROM Demo.Employees;
GO


/* ============================================================================
   9. YEAR, MONTH and DAY
   ============================================================================ */

SELECT
    EmployeeID,
    HireDate,

    YEAR(HireDate) AS HireYear,
    MONTH(HireDate) AS HireMonth,
    DAY(HireDate) AS HireDay

FROM Demo.Employees;
GO


/* ============================================================================
   10. DATENAME
   ============================================================================ */

SELECT
    EmployeeID,
    HireDate,

    DATENAME(MONTH, HireDate) AS HireMonthName,
    DATENAME(WEEKDAY, HireDate) AS HireWeekday

FROM Demo.Employees;
GO


/* ============================================================================
   11. EOMONTH
   ============================================================================ */

SELECT
    GETDATE() AS CurrentDate,
    EOMONTH(GETDATE()) AS EndOfCurrentMonth,
    EOMONTH(GETDATE(), 1) AS EndOfNextMonth;
GO


/* ============================================================================
   12. First day of current month
   ============================================================================ */

SELECT
    DATEADD(
        MONTH,
        DATEDIFF(MONTH, 0, GETDATE()),
        0
    ) AS FirstDayOfMonth;
GO


/* ============================================================================
   13. Employees hired this year
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate

FROM Demo.Employees

WHERE HireDate >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
GO


/* ============================================================================
   14. Employees hired in the last 30 days
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate

FROM Demo.Employees

WHERE HireDate >= DATEADD(DAY, -30, GETDATE());
GO


/* ============================================================================
   15. Employees hired between two dates
   ============================================================================ */

DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate DATE = '2025-12-31';

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate

FROM Demo.Employees

WHERE HireDate >= @StartDate
AND HireDate < DATEADD(DAY, 1, @EndDate);
GO


/* ============================================================================
   16. Calculate employee tenure
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,

    CONCAT(
        DATEDIFF(YEAR, HireDate, GETDATE()),
        ' years'
    ) AS YearsOfService

FROM Demo.Employees;
GO


/* ============================================================================
   17. Employee tenure classification
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,

    CASE
        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) < 1
            THEN 'New Employee'

        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) BETWEEN 1 AND 5
            THEN 'Experienced'

        ELSE 'Long-Term Employee'
    END AS TenureCategory

FROM Demo.Employees;
GO


/* ============================================================================
   18. Date filtering - recommended pattern
   ============================================================================ */

/*
Preferred:

WHERE HireDate >= '2026-01-01'
AND HireDate < '2027-01-01'

This pattern avoids problems caused by time components.
*/

SELECT *
FROM Demo.Employees
WHERE HireDate >= '2026-01-01'
AND HireDate < '2027-01-01';
GO


/* ============================================================================
   19. Date functions best practices
   ============================================================================ */

/*
Recommended practices:

- Prefer half-open date ranges:
      >= StartDate
      < EndDate

- Be aware of time components in DATETIME values.
- Use UTC when appropriate for distributed systems.
- Avoid applying functions directly to indexed date columns in WHERE clauses.
- Use DATEADD and DATEDIFF for date arithmetic.
- Use DATETIME2 for new applications requiring precision.
- Consider timezone requirements in global applications.

===============================================================================
END OF FILE
===============================================================================
*/