/*
===============================================================================
Project:    MSSQL Server Management Toolkit
File:       05-create-indexes.sql
Purpose:    Create performance-oriented indexes for CompanyDB
Author:     Emmanuel Alejandro Noriega
===============================================================================

Indexing strategy:

HR.Employees
- DepartmentID: supports department-based filtering and joins.
- ManagerID: supports manager/employee hierarchy queries.
- LastName + FirstName: supports employee lookup and sorting.
- Active filtered index: supports active employee queries.

Sales.Products
- ProductName: supports product search.
- Active filtered index: supports active product queries.

Sales.Orders
- EmployeeID + OrderDate: supports employee order history.
- OrderDate: supports date-based reporting.

Sales.OrderDetails
- OrderID: supports order detail lookups.
- ProductID: supports product sales analysis.

Audit.SalaryHistory
- EmployeeID + ChangeDate: supports employee salary history queries.

IMPORTANT:
Indexes improve read performance but introduce storage requirements and
additional overhead for INSERT, UPDATE, and DELETE operations.

Always validate indexes against real workload and execution plans.
===============================================================================
*/

USE CompanyDB;
GO


/* ============================================================================
   HR.Employees
   ============================================================================ */

/*
Index:
    IX_Employees_DepartmentID

Purpose:
    Supports queries that filter or join employees by department.
*/

CREATE NONCLUSTERED INDEX IX_Employees_DepartmentID
ON HR.Employees (DepartmentID);
GO


/*
Index:
    IX_Employees_ManagerID

Purpose:
    Supports self-join queries that retrieve employees by manager.
*/

CREATE NONCLUSTERED INDEX IX_Employees_ManagerID
ON HR.Employees (ManagerID);
GO


/*
Index:
    IX_Employees_LastName_FirstName

Purpose:
    Supports employee searches and sorting by last and first name.
*/

CREATE NONCLUSTERED INDEX IX_Employees_LastName_FirstName
ON HR.Employees (LastName, FirstName);
GO


/*
Filtered Index:
    IX_Employees_Active

Purpose:
    Optimizes queries that only retrieve active employees.

Filtered indexes can reduce storage and improve performance when the
query workload frequently targets a subset of rows.
*/

CREATE NONCLUSTERED INDEX IX_Employees_Active
ON HR.Employees (DepartmentID, EmployeeID)
INCLUDE
(
    FirstName,
    LastName,
    Email,
    Salary
)
WHERE Active = 1;
GO


/* ============================================================================
   Sales.Products
   ============================================================================ */

/*
Index:
    IX_Products_ProductName

Purpose:
    Supports product name searches and sorting.
*/

CREATE NONCLUSTERED INDEX IX_Products_ProductName
ON Sales.Products (ProductName);
GO


/*
Filtered Index:
    IX_Products_Active

Purpose:
    Optimizes queries that only return active products.
*/

CREATE NONCLUSTERED INDEX IX_Products_Active
ON Sales.Products (ProductID)
INCLUDE
(
    ProductName,
    UnitPrice,
    StockQuantity
)
WHERE Active = 1;
GO


/* ============================================================================
   Sales.Orders
   ============================================================================ */

/*
Index:
    IX_Orders_EmployeeID_OrderDate

Purpose:
    Supports queries that retrieve employee order history
    and sort/filter by order date.
*/

CREATE NONCLUSTERED INDEX IX_Orders_EmployeeID_OrderDate
ON Sales.Orders (EmployeeID, OrderDate)
INCLUDE
(
    Status,
    TotalAmount
);
GO


/*
Index:
    IX_Orders_OrderDate

Purpose:
    Supports date-based reporting and order history queries.
*/

CREATE NONCLUSTERED INDEX IX_Orders_OrderDate
ON Sales.Orders (OrderDate)
INCLUDE
(
    EmployeeID,
    Status,
    TotalAmount
);
GO


/* ============================================================================
   Sales.OrderDetails
   ============================================================================ */

/*
Index:
    IX_OrderDetails_OrderID

Purpose:
    Supports retrieving all products associated with an order.
*/

CREATE NONCLUSTERED INDEX IX_OrderDetails_OrderID
ON Sales.OrderDetails (OrderID)
INCLUDE
(
    ProductID,
    Quantity,
    UnitPrice
);
GO


/*
Index:
    IX_OrderDetails_ProductID

Purpose:
    Supports product-level sales analysis.
*/

CREATE NONCLUSTERED INDEX IX_OrderDetails_ProductID
ON Sales.OrderDetails (ProductID)
INCLUDE
(
    OrderID,
    Quantity,
    UnitPrice
);
GO


/* ============================================================================
   Audit.SalaryHistory
   ============================================================================ */

/*
Index:
    IX_SalaryHistory_EmployeeID_ChangeDate

Purpose:
    Supports retrieving salary history for a specific employee
    ordered by change date.
*/

CREATE NONCLUSTERED INDEX IX_SalaryHistory_EmployeeID_ChangeDate
ON Audit.SalaryHistory
(
    EmployeeID,
    ChangeDate DESC
)
INCLUDE
(
    OldSalary,
    NewSalary,
    ChangedBy
);
GO


/* ============================================================================
   Index Validation
   ============================================================================ */

SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint
FROM sys.indexes i
INNER JOIN sys.tables t
    ON i.object_id = t.object_id
WHERE SCHEMA_NAME(t.schema_id) IN
(
    N'HR',
    N'Sales',
    N'Audit'
)
AND i.index_id > 0
ORDER BY
    SchemaName,
    TableName,
    IndexName;
GO