/*
===============================================================================
Project:    MSSQL Server Management Toolkit
File:       06-seed-sample-data.sql
Purpose:    Populate CompanyDB with reproducible laboratory data
Author:     Emmanuel Alejandro Noriega
===============================================================================

The data set is intentionally small and readable so it can be used for:

- SELECT queries
- WHERE conditions
- JOINs
- GROUP BY
- HAVING
- Subqueries
- INSERT / UPDATE / DELETE
- Transactions
- Stored procedures
- Views
- Performance testing
- Troubleshooting scenarios

IMPORTANT:
This script is intended for development and laboratory environments only.
The sample data is fictional.
===============================================================================
*/

USE CompanyDB;
GO


/* ============================================================================
   1. Departments
   ============================================================================ */

INSERT INTO HR.Departments
(
    DepartmentName,
    Location
)
VALUES
(N'Information Technology', N'Mexico City'),
(N'Human Resources', N'Mexico City'),
(N'Finance', N'Monterrey'),
(N'Sales', N'Guadalajara'),
(N'Operations', N'Querétaro'),
(N'Customer Support', N'Mexico City'),
(N'Engineering', N'Guadalajara'),
(N'Cybersecurity', N'Mexico City');
GO


/* ============================================================================
   2. Employees
   ============================================================================ */

/*
Management hierarchy:

Carlos → IT Manager
Sofia  → HR Manager
Miguel → Finance Manager
Laura  → Sales Manager
Daniel → Operations Manager
Andrea → Support Manager
Roberto → Engineering Manager
Fernanda → Cybersecurity Manager

Additional employees report to the managers above.
*/

INSERT INTO HR.Employees
(
    FirstName,
    LastName,
    Email,
    DepartmentID,
    ManagerID,
    HireDate,
    Salary,
    Active
)
VALUES
(
    N'Carlos',
    N'Ramirez',
    N'carlos.ramirez@company.example',
    1,
    NULL,
    '2018-03-12',
    95000.00,
    1
),
(
    N'Sofia',
    N'Torres',
    N'sofia.torres@company.example',
    2,
    NULL,
    '2019-06-17',
    88000.00,
    1
),
(
    N'Miguel',
    N'Hernandez',
    N'miguel.hernandez@company.example',
    3,
    NULL,
    '2017-11-20',
    102000.00,
    1
),
(
    N'Laura',
    N'Gomez',
    N'laura.gomez@company.example',
    4,
    NULL,
    '2020-01-13',
    85000.00,
    1
),
(
    N'Daniel',
    N'Martinez',
    N'daniel.martinez@company.example',
    5,
    NULL,
    '2018-08-06',
    90000.00,
    1
),
(
    N'Andrea',
    N'Castillo',
    N'andrea.castillo@company.example',
    6,
    NULL,
    '2021-04-19',
    78000.00,
    1
),
(
    N'Roberto',
    N'Navarro',
    N'roberto.navarro@company.example',
    7,
    NULL,
    '2016-09-26',
    110000.00,
    1
),
(
    N'Fernanda',
    N'Mendoza',
    N'fernanda.mendoza@company.example',
    8,
    NULL,
    '2020-07-15',
    98000.00,
    1
);
GO


/* ============================================================================
   3. Employees reporting to managers
   ============================================================================ */

INSERT INTO HR.Employees
(
    FirstName,
    LastName,
    Email,
    DepartmentID,
    ManagerID,
    HireDate,
    Salary,
    Active
)
VALUES
(N'Emmanuel', N'Noriega', N'emmanuel.noriega@company.example', 1, 1, '2022-02-14', 72000.00, 1),
(N'Gabriel', N'Santos', N'gabriel.santos@company.example', 1, 1, '2023-05-22', 65000.00, 1),
(N'Valeria', N'Rios', N'valeria.rios@company.example', 2, 2, '2021-09-13', 58000.00, 1),
(N'Jorge', N'Vega', N'jorge.vega@company.example', 3, 3, '2022-10-03', 69000.00, 1),
(N'Paola', N'Morales', N'paola.morales@company.example', 4, 4, '2023-01-09', 52000.00, 1),
(N'Luis', N'Perez', N'luis.perez@company.example', 4, 4, '2024-03-18', 48000.00, 1),
(N'Camila', N'Flores', N'camila.flores@company.example', 5, 5, '2022-06-27', 61000.00, 1),
(N'Ricardo', N'Fuentes', N'ricardo.fuentes@company.example', 6, 6, '2023-08-14', 55000.00, 1),
(N'Natalia', N'Cruz', N'natalia.cruz@company.example', 7, 7, '2021-11-01', 76000.00, 1),
(N'Arturo', N'Lopez', N'arturo.lopez@company.example', 7, 7, '2024-01-15', 67000.00, 1),
(N'Mariana', N'Silva', N'mariana.silva@company.example', 8, 8, '2022-12-05', 73000.00, 1),
(N'Ernesto', N'Vargas', N'ernesto.vargas@company.example', 8, 8, '2024-05-20', 62000.00, 1);
GO


/* ============================================================================
   4. Inactive employee
   ============================================================================ */

INSERT INTO HR.Employees
(
    FirstName,
    LastName,
    Email,
    DepartmentID,
    ManagerID,
    HireDate,
    Salary,
    Active
)
VALUES
(
    N'Patricia',
    N'Jimenez',
    N'patricia.jimenez@company.example',
    6,
    6,
    '2020-02-10',
    50000.00,
    0
);
GO


/* ============================================================================
   5. Products
   ============================================================================ */

INSERT INTO Sales.Products
(
    ProductName,
    UnitPrice,
    StockQuantity,
    Active
)
VALUES
(N'Laptop Pro 14', 1850.00, 25, 1),
(N'Business Laptop 15', 1450.00, 40, 1),
(N'Wireless Keyboard', 85.00, 100, 1),
(N'Wireless Mouse', 45.00, 150, 1),
(N'USB-C Docking Station', 220.00, 60, 1),
(N'27-inch Monitor', 380.00, 45, 1),
(N'Noise Cancelling Headset', 180.00, 75, 1),
(N'External SSD 1TB', 125.00, 90, 1),
(N'Enterprise Webcam', 150.00, 50, 1),
(N'Legacy Laptop Model', 900.00, 0, 0);
GO


/* ============================================================================
   6. Orders
   ============================================================================ */

INSERT INTO Sales.Orders
(
    EmployeeID,
    OrderDate,
    Status,
    TotalAmount
)
VALUES
(9,  '2025-01-10 09:30:00', N'Completed', 1895.00),
(10, '2025-01-15 11:45:00', N'Completed', 1670.00),
(13, '2025-02-02 14:20:00', N'Completed', 850.00),
(14, '2025-02-18 10:15:00', N'Pending',   760.00),
(9,  '2025-03-05 16:40:00', N'Completed', 440.00),
(17, '2025-03-12 13:10:00', N'Completed', 1050.00),
(18, '2025-04-01 09:00:00', N'Pending',   250.00),
(19, '2025-04-15 15:30:00', N'Completed', 2000.00),
(20, '2025-05-07 12:00:00', N'Completed', 600.00),
(21, '2025-05-22 10:45:00', N'Completed', 1325.00),
(22, '2025-06-10 14:50:00', N'Pending',   375.00),
(9,  '2025-06-25 09:25:00', N'Completed', 2380.00);
GO


/* ============================================================================
   7. Order Details
   ============================================================================ */

INSERT INTO Sales.OrderDetails
(
    OrderID,
    ProductID,
    Quantity,
    UnitPrice
)
VALUES
(1,  1,  1, 1850.00),
(1,  4,  1, 45.00),

(2,  2,  1, 1450.00),
(2,  3,  1, 85.00),
(2,  4,  3, 45.00),

(3,  3,  5, 85.00),

(4,  6,  2, 380.00),

(5,  5,  2, 220.00),

(6,  7,  2, 180.00),
(6,  8,  1, 125.00),
(6,  9,  1, 150.00),

(7,  8,  2, 125.00),

(8,  1,  1, 1850.00),
(8,  5,  1, 220.00),

(9,  6,  1, 380.00),
(9,  4,  2, 45.00),
(9,  3,  2, 85.00),

(10, 2,  1, 1450.00),

(11, 8,  3, 125.00),

(12, 1,  1, 1850.00),
(12, 6,  1, 380.00),
(12, 4,  2, 45.00);
GO


/* ============================================================================
   8. Salary History
   ============================================================================ */

INSERT INTO Audit.SalaryHistory
(
    EmployeeID,
    OldSalary,
    NewSalary,
    ChangedBy,
    ChangeDate
)
VALUES
(9,  68000.00, 72000.00, N'HR.Admin', '2024-01-15'),
(9,  72000.00, 76000.00, N'HR.Admin', '2025-01-20'),

(10, 62000.00, 65000.00, N'HR.Admin', '2024-06-10'),

(13, 65000.00, 69000.00, N'HR.Admin', '2024-03-01'),

(14, 49000.00, 52000.00, N'HR.Admin', '2024-02-15'),

(17, 72000.00, 76000.00, N'HR.Admin', '2024-07-01'),

(18, 59000.00, 62000.00, N'HR.Admin', '2025-01-10');
GO


/* ============================================================================
   9. Validation - Record Counts
   ============================================================================ */

SELECT
    'HR.Departments' AS TableName,
    COUNT(*) AS RecordCount
FROM HR.Departments

UNION ALL

SELECT
    'HR.Employees',
    COUNT(*)
FROM HR.Employees

UNION ALL

SELECT
    'Sales.Products',
    COUNT(*)
FROM Sales.Products

UNION ALL

SELECT
    'Sales.Orders',
    COUNT(*)
FROM Sales.Orders

UNION ALL

SELECT
    'Sales.OrderDetails',
    COUNT(*)
FROM Sales.OrderDetails

UNION ALL

SELECT
    'Audit.SalaryHistory',
    COUNT(*)
FROM Audit.SalaryHistory;
GO


/* ============================================================================
   10. Sample relationship validation
   ============================================================================ */

SELECT
    e.EmployeeID,
    e.FirstName + N' ' + e.LastName AS EmployeeName,
    d.DepartmentName,
    m.FirstName + N' ' + m.LastName AS ManagerName
FROM HR.Employees e
INNER JOIN HR.Departments d
    ON e.DepartmentID = d.DepartmentID
LEFT JOIN HR.Employees m
    ON e.ManagerID = m.EmployeeID
ORDER BY
    d.DepartmentName,
    e.LastName;
GO