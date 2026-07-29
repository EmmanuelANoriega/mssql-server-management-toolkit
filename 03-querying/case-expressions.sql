/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       case-expressions.sql
Purpose:    CASE expressions and conditional logic in SQL Server
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. Simple CASE expression
2. Searched CASE expression
3. CASE with numeric ranges
4. CASE with NULL values
5. CASE with string values
6. CASE in ORDER BY
7. CASE with aggregate functions
8. Conditional aggregation
9. CASE in UPDATE statements
10. Nested CASE expressions
11. Business logic examples

===============================================================================
*/


/* ============================================================================
   1. Simple CASE expression
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,

    CASE DepartmentID
        WHEN 1 THEN 'IT'
        WHEN 2 THEN 'Finance'
        WHEN 3 THEN 'Human Resources'
        WHEN 4 THEN 'Operations'
        ELSE 'Other'
    END AS DepartmentName

FROM Demo.Employees;
GO


/* ============================================================================
   2. Searched CASE expression
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    CASE
        WHEN Salary < 50000 THEN 'Entry Level'
        WHEN Salary BETWEEN 50000 AND 75000 THEN 'Mid Level'
        WHEN Salary BETWEEN 75001 AND 100000 THEN 'Senior Level'
        ELSE 'Executive Level'
    END AS SalaryLevel

FROM Demo.Employees;
GO


/* ============================================================================
   3. CASE with multiple conditions
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    IsActive,

    CASE
        WHEN IsActive = 0 THEN 'Inactive'
        WHEN Salary >= 100000 THEN 'High Earner'
        WHEN Salary >= 75000 THEN 'Experienced'
        ELSE 'Standard'
    END AS EmployeeCategory

FROM Demo.Employees;
GO


/* ============================================================================
   4. CASE with NULL values
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,

    CASE
        WHEN Email IS NULL THEN 'Email Missing'
        ELSE 'Email Available'
    END AS EmailStatus

FROM Demo.Employees;
GO


/* ============================================================================
   5. CASE with string values
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    EmployeeStatus,

    CASE EmployeeStatus
        WHEN 'ACTIVE' THEN 'Employee is currently active'
        WHEN 'INACTIVE' THEN 'Employee is inactive'
        WHEN 'TERMINATED' THEN 'Employee has left the company'
        ELSE 'Unknown status'
    END AS StatusDescription

FROM Demo.Employees;
GO


/* ============================================================================
   6. CASE in ORDER BY
   ============================================================================ */

/*
Custom sorting logic.

Active employees appear first,
followed by inactive employees.
*/

SELECT
    EmployeeID,
    FirstName,
    LastName,
    IsActive
FROM Demo.Employees
ORDER BY
    CASE
        WHEN IsActive = 1 THEN 1
        ELSE 2
    END,
    LastName;
GO


/* ============================================================================
   7. CASE in ORDER BY with priority
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    EmployeeStatus
FROM Demo.Employees
ORDER BY
    CASE
        WHEN EmployeeStatus = 'ACTIVE' AND Salary >= 100000 THEN 1
        WHEN EmployeeStatus = 'ACTIVE' THEN 2
        WHEN EmployeeStatus = 'INACTIVE' THEN 3
        ELSE 4
    END;
GO


/* ============================================================================
   8. CASE with SUM
   ============================================================================ */

SELECT
    SUM
    (
        CASE
            WHEN Salary >= 75000 THEN 1
            ELSE 0
        END
    ) AS HighSalaryEmployees,

    SUM
    (
        CASE
            WHEN Salary < 75000 THEN 1
            ELSE 0
        END
    ) AS StandardSalaryEmployees

FROM Demo.Employees;
GO


/* ============================================================================
   9. Conditional aggregation
   ============================================================================ */

SELECT
    DepartmentID,

    COUNT(*) AS TotalEmployees,

    SUM
    (
        CASE
            WHEN Salary >= 75000 THEN 1
            ELSE 0
        END
    ) AS HighSalaryEmployees,

    SUM
    (
        CASE
            WHEN Salary < 75000 THEN 1
            ELSE 0
        END
    ) AS StandardSalaryEmployees

FROM Demo.Employees
GROUP BY DepartmentID;
GO


/* ============================================================================
   10. Conditional COUNT
   ============================================================================ */

SELECT
    COUNT
    (
        CASE
            WHEN IsActive = 1 THEN 1
        END
    ) AS ActiveEmployees,

    COUNT
    (
        CASE
            WHEN IsActive = 0 THEN 1
        END
    ) AS InactiveEmployees

FROM Demo.Employees;
GO


/* ============================================================================
   11. Conditional AVG
   ============================================================================ */

SELECT
    AVG
    (
        CASE
            WHEN IsActive = 1
            THEN Salary
        END
    ) AS AverageActiveEmployeeSalary,

    AVG
    (
        CASE
            WHEN IsActive = 0
            THEN Salary
        END
    ) AS AverageInactiveEmployeeSalary

FROM Demo.Employees;
GO


/* ============================================================================
   12. CASE with date logic
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,

    CASE
        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) < 1
            THEN 'Less than 1 year'

        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) BETWEEN 1 AND 5
            THEN '1-5 years'

        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) BETWEEN 6 AND 10
            THEN '6-10 years'

        ELSE 'More than 10 years'
    END AS TenureCategory

FROM Demo.Employees;
GO


/* ============================================================================
   13. CASE for data quality validation
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Email,

    CASE
        WHEN Email IS NULL
            THEN 'Missing Email'

        WHEN Email NOT LIKE '%@%'
            THEN 'Invalid Email'

        ELSE 'Valid Email'
    END AS EmailValidation

FROM Demo.Employees;
GO


/* ============================================================================
   14. CASE for salary validation
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,

    CASE
        WHEN Salary IS NULL
            THEN 'Missing Salary'

        WHEN Salary <= 0
            THEN 'Invalid Salary'

        WHEN Salary < 30000
            THEN 'Below Expected Range'

        WHEN Salary > 500000
            THEN 'Requires Review'

        ELSE 'Valid Salary'
    END AS SalaryValidation

FROM Demo.Employees;
GO


/* ============================================================================
   15. Nested CASE expressions
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    IsActive,

    CASE
        WHEN IsActive = 0
            THEN 'Inactive'

        ELSE
            CASE
                WHEN Salary >= 100000
                    THEN 'Active - High Salary'

                WHEN Salary >= 75000
                    THEN 'Active - Medium Salary'

                ELSE 'Active - Standard Salary'
            END
    END AS EmployeeClassification

FROM Demo.Employees;
GO


/* ============================================================================
   16. CASE with GROUP BY
   ============================================================================ */

SELECT
    CASE
        WHEN Salary < 50000 THEN 'Under 50K'
        WHEN Salary BETWEEN 50000 AND 99999 THEN '50K-99K'
        ELSE '100K+'
    END AS SalaryRange,

    COUNT(*) AS EmployeeCount

FROM Demo.Employees

GROUP BY
    CASE
        WHEN Salary < 50000 THEN 'Under 50K'
        WHEN Salary BETWEEN 50000 AND 99999 THEN '50K-99K'
        ELSE '100K+'
    END

ORDER BY EmployeeCount DESC;
GO


/* ============================================================================
   17. CASE with JOIN
   ============================================================================ */

SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName,
    e.Salary,

    CASE
        WHEN e.Salary >= 100000
            THEN 'High Compensation'

        WHEN e.Salary >= 75000
            THEN 'Medium Compensation'

        ELSE 'Standard Compensation'
    END AS CompensationLevel

FROM Demo.Employees e

INNER JOIN Demo.Departments d
    ON e.DepartmentID = d.DepartmentID;
GO


/* ============================================================================
   18. CASE for support ticket priority
   ============================================================================ */

/*
Generic example useful for IT Support environments.
*/

SELECT
    TicketID,
    TicketTitle,
    Impact,
    Urgency,

    CASE
        WHEN Impact = 'High'
             AND Urgency = 'High'
            THEN 'P1 - Critical'

        WHEN Impact = 'High'
             OR Urgency = 'High'
            THEN 'P2 - High'

        WHEN Impact = 'Medium'
             AND Urgency = 'Medium'
            THEN 'P3 - Medium'

        ELSE 'P4 - Low'
    END AS CalculatedPriority

FROM Demo.SupportTickets;
GO


/* ============================================================================
   19. CASE for SLA status
   ============================================================================ */

SELECT
    TicketID,
    CreatedDate,
    ResolvedDate,

    CASE
        WHEN ResolvedDate IS NULL
            THEN 'Open'

        WHEN DATEDIFF(HOUR, CreatedDate, ResolvedDate) <= 4
            THEN 'Within SLA'

        ELSE 'SLA Breached'
    END AS SLAStatus

FROM Demo.SupportTickets;
GO


/* ============================================================================
   20. CASE in UPDATE
   ============================================================================ */

/*
IMPORTANT:

Always test the SELECT equivalent before executing UPDATE.

Example:

SELECT
    EmployeeID,
    Salary,
    CASE
        WHEN Salary < 50000
            THEN Salary * 1.10

        WHEN Salary < 75000
            THEN Salary * 1.05

        ELSE Salary
    END AS NewSalary

FROM Demo.Employees;
*/


/*
Example UPDATE:

UPDATE Demo.Employees
SET Salary =
    CASE
        WHEN Salary < 50000
            THEN Salary * 1.10

        WHEN Salary < 75000
            THEN Salary * 1.05

        ELSE Salary
    END;
*/


/* ============================================================================
   21. Conditional data transformation
   ============================================================================ */

SELECT
    EmployeeID,

    CASE
        WHEN FirstName IS NULL
            THEN 'Unknown'

        WHEN LastName IS NULL
            THEN FirstName

        ELSE FirstName + ' ' + LastName
    END AS DisplayName

FROM Demo.Employees;
GO


/* ============================================================================
   22. CASE best practices
   ============================================================================ */

/*
Recommended practices:

- Keep CASE expressions readable.
- Put the most specific conditions first.
- Always consider NULL values.
- Use ELSE to handle unexpected values.
- Avoid deeply nested CASE expressions.
- Validate UPDATE statements using SELECT first.
- Consider lookup tables when business rules become complex.
- Review execution plans for performance-sensitive queries.

===============================================================================
END OF FILE
===============================================================================
*/