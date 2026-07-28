/*
===============================================================================
Project:    MSSQL Server Management Toolkit
File:       04-create-constraints.sql
Purpose:    Create foreign keys, unique constraints, and validation rules
Author:     Emmanuel Alejandro Noriega
===============================================================================

Relationships:

HR.Departments
      │
      │ 1:N
      ▼
HR.Employees
      │
      │ 1:N
      ▼
Sales.Orders
      │
      │ 1:N
      ▼
Sales.OrderDetails
      │
      │ N:1
      ▼
Sales.Products

HR.Employees also contains a self-referencing ManagerID relationship.

Audit.SalaryHistory references HR.Employees.

===============================================================================
*/

USE CompanyDB;
GO


/* ============================================================================
   HR.Employees → HR.Departments
   ============================================================================ */

ALTER TABLE HR.Employees
ADD CONSTRAINT FK_Employees_Department
FOREIGN KEY (DepartmentID)
REFERENCES HR.Departments(DepartmentID);
GO


/* ============================================================================
   HR.Employees → HR.Employees
   Self-referencing manager relationship
   ============================================================================ */

ALTER TABLE HR.Employees
ADD CONSTRAINT FK_Employees_Manager
FOREIGN KEY (ManagerID)
REFERENCES HR.Employees(EmployeeID);
GO


/* ============================================================================
   Unique employee email
   ============================================================================ */

ALTER TABLE HR.Employees
ADD CONSTRAINT UQ_Employees_Email
UNIQUE (Email);
GO


/* ============================================================================
   Employee salary validation
   ============================================================================ */

ALTER TABLE HR.Employees
ADD CONSTRAINT CK_Employees_Salary
CHECK (Salary > 0);
GO


/* ============================================================================
   Sales.Orders → HR.Employees
   ============================================================================ */

ALTER TABLE Sales.Orders
ADD CONSTRAINT FK_Orders_Employee
FOREIGN KEY (EmployeeID)
REFERENCES HR.Employees(EmployeeID);
GO


/* ============================================================================
   Sales.OrderDetails → Sales.Orders
   ============================================================================ */

ALTER TABLE Sales.OrderDetails
ADD CONSTRAINT FK_OrderDetails_Order
FOREIGN KEY (OrderID)
REFERENCES Sales.Orders(OrderID);
GO


/* ============================================================================
   Sales.OrderDetails → Sales.Products
   ============================================================================ */

ALTER TABLE Sales.OrderDetails
ADD CONSTRAINT FK_OrderDetails_Product
FOREIGN KEY (ProductID)
REFERENCES Sales.Products(ProductID);
GO


/* ============================================================================
   Order quantity validation
   ============================================================================ */

ALTER TABLE Sales.OrderDetails
ADD CONSTRAINT CK_OrderDetails_Quantity
CHECK (Quantity > 0);
GO


/* ============================================================================
   Order unit price validation
   ============================================================================ */

ALTER TABLE Sales.OrderDetails
ADD CONSTRAINT CK_OrderDetails_UnitPrice
CHECK (UnitPrice >= 0);
GO


/* ============================================================================
   Product price validation
   ============================================================================ */

ALTER TABLE Sales.Products
ADD CONSTRAINT CK_Products_UnitPrice
CHECK (UnitPrice >= 0);
GO


/* ============================================================================
   Product stock validation
   ============================================================================ */

ALTER TABLE Sales.Products
ADD CONSTRAINT CK_Products_StockQuantity
CHECK (StockQuantity >= 0);
GO


/* ============================================================================
   Salary history → HR.Employees
   ============================================================================ */

ALTER TABLE Audit.SalaryHistory
ADD CONSTRAINT FK_SalaryHistory_Employee
FOREIGN KEY (EmployeeID)
REFERENCES HR.Employees(EmployeeID);
GO


/* ============================================================================
   Salary history validation
   ============================================================================ */

ALTER TABLE Audit.SalaryHistory
ADD CONSTRAINT CK_SalaryHistory_SalaryValues
CHECK
(
    OldSalary >= 0
    AND NewSalary >= 0
);
GO


/* ============================================================================
   Validation: Foreign Keys
   ============================================================================ */

SELECT
    OBJECT_SCHEMA_NAME(parent_object_id) AS ParentSchema,
    OBJECT_NAME(parent_object_id) AS ParentTable,
    name AS ForeignKeyName,
    OBJECT_SCHEMA_NAME(referenced_object_id) AS ReferencedSchema,
    OBJECT_NAME(referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys
ORDER BY
    ParentSchema,
    ParentTable,
    ForeignKeyName;
GO


/* ============================================================================
   Validation: Check Constraints
   ============================================================================ */

SELECT
    OBJECT_SCHEMA_NAME(parent_object_id) AS SchemaName,
    OBJECT_NAME(parent_object_id) AS TableName,
    name AS ConstraintName,
    definition
FROM sys.check_constraints
ORDER BY
    SchemaName,
    TableName;
GO