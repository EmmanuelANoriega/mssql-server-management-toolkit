/*
===============================================================================
MSSQL Server Management Toolkit
Module:     03 - Querying
File:       string-functions.sql
Purpose:    String manipulation and text functions in SQL Server
Author:     Emmanuel Alejandro Noriega
===============================================================================

Topics covered:

1. CONCAT
2. CONCAT_WS
3. LEN
4. DATALENGTH
5. LEFT
6. RIGHT
7. SUBSTRING
8. CHARINDEX
9. PATINDEX
10. REPLACE
11. TRANSLATE
12. UPPER
13. LOWER
14. LTRIM
15. RTRIM
16. TRIM
17. REVERSE
18. STRING_SPLIT
19. STRING_AGG
20. NULL handling

===============================================================================
*/


/* ============================================================================
   1. CONCAT
   ============================================================================ */

SELECT
    EmployeeID,
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM Demo.Employees;
GO


/* ============================================================================
   2. CONCAT_WS
   ============================================================================ */

SELECT
    EmployeeID,
    CONCAT_WS(' - ', EmployeeID, FirstName, LastName) AS EmployeeLabel
FROM Demo.Employees;
GO


/* ============================================================================
   3. LEN
   ============================================================================ */

SELECT
    FirstName,
    LEN(FirstName) AS FirstNameLength
FROM Demo.Employees;
GO


/* ============================================================================
   4. DATALENGTH
   ============================================================================ */

SELECT
    FirstName,
    DATALENGTH(FirstName) AS StorageBytes
FROM Demo.Employees;
GO


/* ============================================================================
   5. LEFT
   ============================================================================ */

SELECT
    FirstName,
    LEFT(FirstName, 3) AS FirstThreeCharacters
FROM Demo.Employees;
GO


/* ============================================================================
   6. RIGHT
   ============================================================================ */

SELECT
    LastName,
    RIGHT(LastName, 3) AS LastThreeCharacters
FROM Demo.Employees;
GO


/* ============================================================================
   7. SUBSTRING
   ============================================================================ */

SELECT
    FirstName,
    SUBSTRING(FirstName, 1, 3) AS FirstThreeCharacters
FROM Demo.Employees;
GO


/* ============================================================================
   8. CHARINDEX
   ============================================================================ */

SELECT
    Email,
    CHARINDEX('@', Email) AS AtSymbolPosition
FROM Demo.Employees
WHERE Email IS NOT NULL;
GO


/* ============================================================================
   9. PATINDEX
   ============================================================================ */

SELECT
    Email,
    PATINDEX('%@%', Email) AS AtSymbolPosition
FROM Demo.Employees
WHERE Email IS NOT NULL;
GO


/* ============================================================================
   10. REPLACE
   ============================================================================ */

SELECT
    Email,
    REPLACE(Email, '@company.com', '@example.com') AS UpdatedEmail
FROM Demo.Employees
WHERE Email IS NOT NULL;
GO


/* ============================================================================
   11. TRANSLATE
   ============================================================================ */

SELECT
    FirstName,
    TRANSLATE(FirstName, 'aeiou', '12345') AS TranslatedName
FROM Demo.Employees;
GO


/* ============================================================================
   12. UPPER
   ============================================================================ */

SELECT
    FirstName,
    UPPER(FirstName) AS UpperCaseName
FROM Demo.Employees;
GO


/* ============================================================================
   13. LOWER
   ============================================================================ */

SELECT
    LastName,
    LOWER(LastName) AS LowerCaseName
FROM Demo.Employees;
GO


/* ============================================================================
   14. LTRIM
   ============================================================================ */

SELECT
    LTRIM('    SQL Server') AS TrimmedLeft;
GO


/* ============================================================================
   15. RTRIM
   ============================================================================ */

SELECT
    RTRIM('SQL Server    ') AS TrimmedRight;
GO


/* ============================================================================
   16. TRIM
   ============================================================================ */

SELECT
    TRIM('    SQL Server    ') AS TrimmedText;
GO


/* ============================================================================
   17. REVERSE
   ============================================================================ */

SELECT
    FirstName,
    REVERSE(FirstName) AS ReversedName
FROM Demo.Employees;
GO


/* ============================================================================
   18. STRING_SPLIT
   ============================================================================ */

DECLARE @Tags NVARCHAR(200) =
    'SQL Server,Database,Support,Infrastructure';

SELECT
    value AS Tag
FROM STRING_SPLIT(@Tags, ',');
GO


/* ============================================================================
   19. STRING_AGG
   ============================================================================ */

SELECT
    DepartmentID,
    STRING_AGG(
        CONCAT(FirstName, ' ', LastName),
        ', '
    ) AS Employees
FROM Demo.Employees
GROUP BY DepartmentID;
GO


/* ============================================================================
   20. STRING_AGG with ordering
   ============================================================================ */

SELECT
    DepartmentID,
    STRING_AGG(
        CONCAT(FirstName, ' ', LastName),
        ', '
    ) WITHIN GROUP
    (
        ORDER BY LastName
    ) AS Employees
FROM Demo.Employees
GROUP BY DepartmentID;
GO


/* ============================================================================
   21. NULL handling with CONCAT
   ============================================================================ */

SELECT
    EmployeeID,
    CONCAT(
        FirstName,
        ' ',
        LastName,
        ' - ',
        Email
    ) AS EmployeeInformation
FROM Demo.Employees;
GO


/* ============================================================================
   22. NULL handling with COALESCE
   ============================================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    COALESCE(Email, 'No Email Available') AS Email
FROM Demo.Employees;
GO


/* ============================================================================
   23. NULL handling with ISNULL
   ============================================================================ */

SELECT
    EmployeeID,
    ISNULL(Email, 'No Email Available') AS Email
FROM Demo.Employees;
GO


/* ============================================================================
   24. Extract username from email
   ============================================================================ */

SELECT
    EmployeeID,
    Email,

    LEFT(
        Email,
        CHARINDEX('@', Email) - 1
    ) AS EmailUsername

FROM Demo.Employees
WHERE Email IS NOT NULL
AND CHARINDEX('@', Email) > 0;
GO


/* ============================================================================
   25. Extract email domain
   ============================================================================ */

SELECT
    EmployeeID,
    Email,

    SUBSTRING(
        Email,
        CHARINDEX('@', Email) + 1,
        LEN(Email)
    ) AS EmailDomain

FROM Demo.Employees
WHERE Email IS NOT NULL
AND CHARINDEX('@', Email) > 0;
GO


/* ============================================================================
   26. Normalize names
   ============================================================================ */

SELECT
    EmployeeID,

    UPPER(
        LEFT(
            LTRIM(RTRIM(FirstName)),
            1
        )
    )
    +
    LOWER(
        SUBSTRING(
            LTRIM(RTRIM(FirstName)),
            2,
            LEN(FirstName)
        )
    ) AS NormalizedFirstName

FROM Demo.Employees;
GO


/* ============================================================================
   27. Search for employees by partial name
   ============================================================================ */

DECLARE @SearchTerm NVARCHAR(100) = 'John';

SELECT
    EmployeeID,
    FirstName,
    LastName
FROM Demo.Employees
WHERE CONCAT(FirstName, ' ', LastName)
LIKE '%' + @SearchTerm + '%';
GO


/* ============================================================================
   28. String functions best practices
   ============================================================================ */

/*
Recommended practices:

- Use CONCAT when NULL values may exist.
- Validate CHARINDEX results before using them in SUBSTRING or LEFT.
- Use STRING_AGG for grouped text aggregation.
- Use STRING_SPLIT for simple delimited lists.
- Avoid applying functions to indexed columns in WHERE clauses when possible.
- Be aware of collation and case sensitivity.
- Consider Unicode support when working with international data.
- Use NVARCHAR for multilingual applications.

===============================================================================
END OF FILE
===============================================================================
*/