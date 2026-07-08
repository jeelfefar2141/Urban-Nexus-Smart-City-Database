# 🏙️ Urban Nexus – Smart City Municipal Management Database System

> A comprehensive PostgreSQL-based Smart City Municipal Management System designed to efficiently manage municipal operations including citizens, properties, utility billing, complaints, public assets, budgets, and work orders.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange)
![Normalization](https://img.shields.io/badge/Normalization-BCNF-success)

---

# 📌 Project Overview

Urban Nexus is a relational database project that simulates a real-world Smart City Municipal Management System.

The database centralizes municipal operations by managing:

- Citizen Records
- Property Ownership
- Utility Connections
- Smart Meter Readings
- Billing & Payments
- Complaint Management
- Public Assets
- Maintenance Scheduling
- Department Budgets
- Expense Tracking
- Work Orders
- Contractors

The project follows database design principles including normalization up to **BCNF**, proper relational modeling, and advanced SQL querying.

---

# ✨ Features

- ✅ 18+ Fully Normalized Tables
- ✅ PostgreSQL Compatible
- ✅ BCNF Normalization
- ✅ Minimal Functional Dependency Proof
- ✅ ER Diagram
- ✅ Relational Schema
- ✅ Foreign Key Constraints
- ✅ Realistic Sample Dataset
- ✅ Complex SQL Queries
- ✅ Aggregate Functions
- ✅ Window Functions
- ✅ Nested Queries
- ✅ Joins
- ✅ Set Operations
- ✅ Municipal Analytics Reports

---

# 🏛️ Database Modules

### 👤 Citizen Management

- Citizen Registration
- Household Management
- Property Ownership

---

### 🏠 Property Management

- Property Records
- Ownership History
- Zones
- Household Mapping

---

### ⚡ Utility Management

- Water
- Electricity
- Smart Meter
- Meter Reading
- Utility Connections

---

### 💳 Billing System

- Bill Generation
- Payment Transactions
- Outstanding Bills
- Revenue Reports

---

### 📢 Complaint Management

- Complaint Registration
- Department Assignment
- Officer Assignment
- Work Orders

---

### 🏗 Public Asset Management

- Public Assets
- Maintenance Scheduling
- Asset Monitoring

---

### 💰 Budget Management

- Department Budget
- Department Expenses
- Budget Utilization
- Financial Reports

---

# 🗂 Database Schema

The project consists of the following major entities:

- Citizen
- Household
- Location
- Property
- Ownership
- UtilityConnection
- SmartMeter
- MeterReading
- BillingRecord
- PaymentTransaction
- Complaint
- WorkOrder
- Contractor
- Department
- Officer
- PublicAsset
- MaintenanceSchedule
- BudgetAllocation
- DepartmentExpense

---

# 📊 Entity Relationship Diagram

The complete ER Diagram is available in:

```
Docs/ER_Diagram.pdf
```

---

# 🧩 Relational Schema

Available in:

```
Docs/Relational_Schema.pdf
```

---

# 📚 Normalization

This project includes complete database normalization documentation.

Included:

- Functional Dependency Sets
- Minimal Cover
- Attribute Closure
- Candidate Keys
- BCNF Verification

Documentation:

```
Docs/Normalization_Proofs.pdf
```

---

# 🗃 Folder Structure

```
Urban-Nexus-Smart-City-Database
│
├── Database
│   ├── ddl.sql
│   ├── inserted_data.sql
│   └── queries.sql
│
├── Docs
│   ├── ER_Diagram.pdf
│   ├── Relational_Schema.pdf
│   └── Normalization_Proofs.pdf
│
└── README.md
```

---

# 🚀 Getting Started

## Clone Repository

```bash
git clone https://github.com/jeelfefar2141/Urban-Nexus-Smart-City-Database.git
```

---

## Open PostgreSQL

Use:

- PostgreSQL
- pgAdmin 4

---

## Create Database

```sql
CREATE DATABASE urban_nexus;
```

---

## Execute Scripts

Run in the following order:

### 1️⃣ Database Structure

```
ddl.sql
```

---

### 2️⃣ Insert Data

```
inserted_data.sql
```

---

### 3️⃣ Execute Queries

```
queries.sql
```

---

# 📈 SQL Concepts Used

- CREATE TABLE
- ALTER TABLE
- PRIMARY KEY
- FOREIGN KEY
- UNIQUE Constraints
- CHECK Constraints
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- FULL JOIN
- GROUP BY
- HAVING
- ORDER BY
- UNION
- EXCEPT
- INTERSECT
- Aggregate Functions
- Window Functions
- Nested Queries
- Correlated Subqueries
- Common Table Expressions (CTE)

---

# 📊 Sample Reports

The database supports analytical reports such as:

- Citizen-wise Outstanding Bills
- Department Budget Utilization
- Revenue Analysis
- Complaint Resolution Dashboard
- Property Ownership Reports
- Utility Consumption Analysis
- Smart Meter Analytics
- Work Order Tracking
- Public Asset Maintenance Reports

---

# 🛠 Technologies Used

- PostgreSQL
- SQL
- ER Modeling
- Database Normalization
- Relational Database Design
- Git
- GitHub

---

# 🎯 Learning Outcomes

This project demonstrates practical knowledge of:

- Relational Database Design
- SQL Programming
- Database Normalization
- Advanced Query Writing
- Real-world Database Modeling
- Municipal Information Systems

---

# 👨‍💻 Author

**Jeel Patel**

B.Tech Information Technology Student

GitHub:
https://github.com/jeelfefar2141

---

# ⭐ If you found this project useful, consider giving it a Star!
