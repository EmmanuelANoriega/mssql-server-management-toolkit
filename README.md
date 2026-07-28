# 🗄️ Microsoft SQL Server Management Toolkit

<p align="center">

<img src="https://img.shields.io/badge/Microsoft_SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white"/>
<img src="https://img.shields.io/badge/T--SQL-336791?style=for-the-badge&logo=microsoftsqlserver&logoColor=white"/>
<img src="https://img.shields.io/badge/Database_Administration-0078D4?style=for-the-badge&logo=microsoft&logoColor=white"/>
<img src="https://img.shields.io/badge/Performance_Tuning-107C10?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Troubleshooting-FF8C00?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Database_Security-8B0000?style=for-the-badge"/>

</p>

A practical collection of **Microsoft SQL Server and T-SQL scripts** covering database administration, data querying, security, performance monitoring, troubleshooting, maintenance, and backup/restore operations.

This repository is designed as a **technical reference and hands-on learning resource** for IT professionals, Technical Support Engineers, Application Support Engineers, System Administrators, and aspiring Database Administrators.

---

## 📚 Contents

| #  | Category                | Description                                          |
| -- | ----------------------- | ---------------------------------------------------- |
| 01 | 🗄️ Database Management | Create, modify, configure, and inspect databases     |
| 02 | 📋 Table Management     | Tables, constraints, indexes, and schema changes     |
| 03 | 🔍 Data Querying        | SELECT, WHERE, JOINs, aggregates, and subqueries     |
| 04 | ✏️ Data Manipulation    | INSERT, UPDATE, DELETE, and TRUNCATE                 |
| 05 | 🔐 Security             | Logins, users, roles, and permissions                |
| 06 | ⚙️ Programmability      | Stored procedures, functions, and views              |
| 07 | 🔄 Transactions         | Transactions, savepoints, and isolation levels       |
| 08 | 📈 Performance          | Indexes, execution plans, statistics, and monitoring |
| 09 | 🔧 Maintenance          | Backups, restores, integrity checks, and maintenance |
| 10 | 🚨 Troubleshooting      | Blocking, deadlocks, errors, and diagnostics         |
| 11 | 💡 System Procedures    | Useful SQL Server system stored procedures           |

---

# 🗄️ 01 — Database Management

### Create & Configure Databases

```sql
CREATE DATABASE CompanyDB
ON PRIMARY 
(
    NAME = CompanyDB_Data,
    FILENAME = 'D:\MSSQL\Data\CompanyDB.mdf',
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 10%
)
LOG ON 
(
    NAME = CompanyDB_Log,
    FILENAME = 'D:\MSSQL\Log\CompanyDB.ldf',
    SIZE = 50MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 10%
);
```

### Database Information

```sql
-- List all databases
SELECT 
    name,
    database_id,
    create_date,
    state_desc
FROM sys.databases
ORDER BY name;
```

More examples:

📁 [`01-database-management/`](./01-database-management/)

---

# 📋 02 — Table Management

Topics covered:

* Creating tables
* Primary keys
* Foreign keys
* Unique constraints
* CHECK constraints
* Identity columns
* Computed columns
* Temporal tables
* ALTER TABLE
* Adding and removing columns
* Index creation
* Filtered indexes

Example:

```sql
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    HireDate DATE DEFAULT GETDATE(),
    Salary DECIMAL(10,2) CHECK (Salary > 0),
    DepartmentID INT
);
```

📁 [`02-table-management/`](./02-table-management/)

---

# 🔍 03 — Data Querying

This section contains practical examples for retrieving and analyzing data.

### SELECT

```sql
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Employees;
```

### JOINs

```sql
SELECT 
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d
    ON e.DepartmentID = d.DepartmentID;
```

### Aggregations

```sql
SELECT 
    DepartmentID,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AverageSalary,
    MIN(Salary) AS MinimumSalary,
    MAX(Salary) AS MaximumSalary
FROM Employees
GROUP BY DepartmentID;
```

### Subqueries

```sql
SELECT *
FROM Employees
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Employees
);
```

📁 [`03-querying/`](./03-querying/)

---

# ✏️ 04 — Data Manipulation

Examples covering:

* INSERT
* INSERT INTO SELECT
* UPDATE
* UPDATE with JOIN
* OUTPUT clause
* DELETE
* TRUNCATE

Example:

```sql
UPDATE Employees
SET 
    Salary = Salary * 1.10,
    ModifiedDate = GETDATE()
WHERE DepartmentID = 1;
```

📁 [`04-data-manipulation/`](./04-data-manipulation/)

---

# 🔐 05 — Security & Permissions

Examples covering SQL Server security administration.

### Login & User Management

```sql
CREATE LOGIN AppUser
WITH PASSWORD = 'UseASecretStoredSecurely!';
```

### Database User

```sql
CREATE USER AppUser
FOR LOGIN AppUser;
```

### Roles

```sql
CREATE ROLE DataReader;

ALTER ROLE DataReader
ADD MEMBER AppUser;
```

### Permissions

```sql
GRANT SELECT
ON SCHEMA::dbo
TO DataReader;
```

> ⚠️ Never commit real passwords, connection strings, API keys, or production credentials to GitHub.

📁 [`05-security/`](./05-security/)

---

# ⚙️ 06 — Stored Procedures, Functions & Views

This section demonstrates common programmable database objects.

### Stored Procedure

```sql
CREATE PROCEDURE GetEmployeeByID
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Employees
    WHERE EmployeeID = @EmployeeID;
END;
GO
```

### Execute

```sql
EXEC GetEmployeeByID
    @EmployeeID = 123;
```

Topics:

* Stored procedures
* Parameters
* Error handling
* Transactions inside procedures
* Scalar functions
* Table-valued functions
* Views
* Indexed views

📁 [`06-programmability/`](./06-programmability/)

---

# 🔄 07 — Transactions & Isolation

Examples covering transaction management and data consistency.

```sql
BEGIN TRANSACTION;

BEGIN TRY

    UPDATE Accounts
    SET Balance = Balance - 1000
    WHERE AccountID = 1;

    UPDATE Accounts
    SET Balance = Balance + 1000
    WHERE AccountID = 2;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
```

Topics:

* Explicit transactions
* TRY/CATCH
* COMMIT
* ROLLBACK
* SAVEPOINT
* Isolation levels
* Transaction consistency

📁 [`07-transactions/`](./07-transactions/)

---

# 📈 08 — Performance & Monitoring

Performance troubleshooting examples including:

* Index management
* Index rebuilds
* Index reorganizations
* Statistics
* Execution plans
* Query performance
* Running queries
* Active sessions
* Query plan cache

Example:

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM dbo.Employees;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

### Active Requests

```sql
SELECT *
FROM sys.dm_exec_requests;
```

### Active Sessions

```sql
SELECT *
FROM sys.dm_exec_sessions;
```

📁 [`08-performance/`](./08-performance/)

---

# 🔧 09 — Backup, Restore & Maintenance

Database administration examples covering:

* Full backups
* Differential backups
* Transaction log backups
* Database restoration
* RESTORE WITH MOVE
* DBCC CHECKDB
* DBCC CHECKTABLE
* Statistics maintenance

Example:

```sql
BACKUP DATABASE CompanyDB
TO DISK = 'D:\Backups\CompanyDB_Full.bak'
WITH 
    INIT,
    STATS = 5;
```

### Database Integrity

```sql
DBCC CHECKDB ('CompanyDB')
WITH NO_INFOMSGS;
```

📁 [`09-maintenance/`](./09-maintenance/)

---

# 🚨 10 — Troubleshooting

This section focuses on real-world SQL Server troubleshooting scenarios.

### Blocking & Deadlocks

* Identify blocking sessions
* Find blocked queries
* Investigate active requests
* Identify problematic sessions
* Review query text

### Error Handling

```sql
BEGIN TRY

    SELECT 1 / 0;

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine,
        ERROR_PROCEDURE() AS ErrorProcedure;

END CATCH;
```

📁 [`10-troubleshooting/`](./10-troubleshooting/)

---

# 💡 11 — Useful System Stored Procedures

Quick reference for commonly used SQL Server system procedures.

```sql
-- Database information
EXEC sp_helpdb 'CompanyDB';

-- Database space usage
EXEC sp_spaceused;

-- Table information
EXEC sp_help 'Employees';

-- Server configuration
EXEC sp_configure;

-- Active sessions
EXEC sp_who2;

-- Lock information
EXEC sp_lock;
```

📁 [`11-system-procedures/`](./11-system-procedures/)

---

# 🧰 Recommended Workflow

When working with SQL Server in a production environment:

```text
Understand the Problem
        │
        ▼
Collect Evidence
        │
        ├── Logs
        ├── Query Metrics
        ├── Execution Plans
        └── System DMVs
        │
        ▼
Identify Root Cause
        │
        ▼
Test in Development
        │
        ▼
Validate the Solution
        │
        ▼
Deploy with Change Control
        │
        ▼
Monitor Results
        │
        ▼
Document the Resolution
```

---

# ⚠️ Best Practices

* Always test database changes in development or staging first.
* Use transactions when performing critical data modifications.
* Never run destructive queries without validating the `WHERE` clause.
* Always maintain reliable backups.
* Test database restores regularly.
* Avoid using `DBCC SHRINKDATABASE` as routine maintenance.
* Monitor query performance and index health.
* Follow least-privilege principles for database access.
* Never commit credentials or secrets to source control.
* Document production changes and troubleshooting procedures.

---

# 🎯 Purpose

This repository is intended as a **technical reference, learning resource, and personal knowledge base** for Microsoft SQL Server administration and troubleshooting.

The scripts are provided for educational and reference purposes and should be reviewed and tested in a controlled environment before being used in production.

---

## 👨‍💻 Author

**Emmanuel Alejandro Noriega**

Technical Support Engineer | Application Administrator | IT Infrastructure & Cloud Enthusiast

🌎 Mexico City, Mexico

📧 `alex.noriegab@outlook.com`

---

⭐ If you find this repository useful, consider giving it a star!
