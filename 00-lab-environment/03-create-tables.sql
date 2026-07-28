/*
===============================================================================
Project:    MSSQL Server Management Toolkit
File:       03-create-tables.sql
Purpose:    Create laboratory tables for CompanyDB
Author:     Emmanuel Alejandro Noriega
===============================================================================

Database structure:

HR
├── Departments
└── Employees

Sales
├── Products
├── Orders
└── OrderDetails

Audit
└── SalaryHistory

Foreign keys and relationships are created separately in:
04-create-constraints.sql
===============================================================================
*/

USE CompanyDB;
GO


/* ============================================================================
   HR.Departments
   Stores organizational department information.
   ============================================================================ */

CREATE TABLE HR.Departments
(
    DepartmentID INT IDENTITY(1,1)
        CONSTRAINT PK_Departments
        PRIMARY KEY,

    DepartmentName NVARCHAR(100) NOT NULL,

    Location NVARCHAR(100) NULL,

    CreatedDate DATETIME2(0) NOT NULL
        CONSTRAINT DF_Departments_CreatedDate
        DEFAULT SYSDATETIME()
);
GO


/* ============================================================================
   HR.Employees
   Stores employee information.

   ManagerID is intentionally created without a foreign key here.
   The self-referencing relationship is added later in:
   04-create-constraints.sql
   ============================================================================ */

CREATE TABLE HR.Employees
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_Employees
        PRIMARY KEY,

    FirstName NVARCHAR(50) NOT NULL,

    LastName NVARCHAR(50) NOT NULL,

    Email NVARCHAR(150) NOT NULL,

    DepartmentID INT NOT NULL,

    ManagerID INT NULL,

    HireDate DATE NOT NULL
        CONSTRAINT DF_Employees_HireDate
        DEFAULT CAST(GETDATE() AS DATE),

    Salary DECIMAL(12,2) NOT NULL,

    Active BIT NOT NULL
        CONSTRAINT DF_Employees_Active
        DEFAULT 1,

    CreatedDate DATETIME2(0) NOT NULL
        CONSTRAINT DF_Employees_CreatedDate
        DEFAULT SYSDATETIME(),

    ModifiedDate DATETIME2(0) NOT NULL
        CONSTRAINT DF_Employees_ModifiedDate
        DEFAULT SYSDATETIME()
);
GO


/* ============================================================================
   Sales.Products
   Stores products available for sale.
   ============================================================================ */

CREATE TABLE Sales.Products
(
    ProductID INT IDENTITY(1,1)
        CONSTRAINT PK_Products
        PRIMARY KEY,

    ProductName NVARCHAR(150) NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    StockQuantity INT NOT NULL
        CONSTRAINT DF_Products_StockQuantity
        DEFAULT 0,

    Active BIT NOT NULL
        CONSTRAINT DF_Products_Active
        DEFAULT 1,

    CreatedDate DATETIME2(0) NOT NULL
        CONSTRAINT DF_Products_CreatedDate
        DEFAULT SYSDATETIME()
);
GO


/* ============================================================================
   Sales.Orders
   Stores customer/order transactions.
   ============================================================================ */

CREATE TABLE Sales.Orders
(
    OrderID INT IDENTITY(1,1)
        CONSTRAINT PK_Orders
        PRIMARY KEY,

    EmployeeID INT NOT NULL,

    OrderDate DATETIME2(0) NOT NULL
        CONSTRAINT DF_Orders_OrderDate
        DEFAULT SYSDATETIME(),

    Status NVARCHAR(30) NOT NULL
        CONSTRAINT DF_Orders_Status
        DEFAULT N'Pending',

    TotalAmount DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Orders_TotalAmount
        DEFAULT 0
);
GO


/* ============================================================================
   Sales.OrderDetails
   Stores individual products associated with each order.
   ============================================================================ */

CREATE TABLE Sales.OrderDetails
(
    OrderDetailID INT IDENTITY(1,1)
        CONSTRAINT PK_OrderDetails
        PRIMARY KEY,

    OrderID INT NOT NULL,

    ProductID INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL
);
GO


/* ============================================================================
   Audit.SalaryHistory
   Stores historical employee salary changes.
   ============================================================================ */

CREATE TABLE Audit.SalaryHistory
(
    SalaryHistoryID INT IDENTITY(1,1)
        CONSTRAINT PK_SalaryHistory
        PRIMARY KEY,

    EmployeeID INT NOT NULL,

    OldSalary DECIMAL(12,2) NOT NULL,

    NewSalary DECIMAL(12,2) NOT NULL,

    ChangedBy NVARCHAR(100) NOT NULL,

    ChangeDate DATETIME2(0) NOT NULL
        CONSTRAINT DF_SalaryHistory_ChangeDate
        DEFAULT SYSDATETIME()
);
GO


/* ============================================================================
   Validation
   ============================================================================ */

SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName
FROM sys.tables t
WHERE SCHEMA_NAME(t.schema_id) IN
(
    N'HR',
    N'Sales',
    N'Audit'
)
ORDER BY
    SchemaName,
    TableName;
GO