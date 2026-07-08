--1) Administration / master data

CREATE TABLE Department (
department_id BIGINT PRIMARY KEY,
department_name VARCHAR(150) NOT NULL UNIQUE,
department_head_id BIGINT NULL,
contact_number VARCHAR(15),
office_location VARCHAR(255),
creation_date DATE
); 

CREATE TABLE Officer (
officer_id BIGINT PRIMARY KEY,
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
designation VARCHAR(100) NOT NULL,
department_id BIGINT NOT NULL,
mobile_number VARCHAR(15),
email VARCHAR(254) UNIQUE,
joining_date DATE,
employment_status VARCHAR(30),
FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

ALTER TABLE Department
ADD FOREIGN KEY (department_head_id) REFERENCES Officer(officer_id);

CREATE TABLE Contractor (
contractor_id BIGINT PRIMARY KEY,
contractor_name VARCHAR(150) NOT NULL,
contractor_type VARCHAR(80),
email VARCHAR(254) UNIQUE,
address VARCHAR(255),
license_number VARCHAR(100) UNIQUE,
registration_date DATE,
contact_person VARCHAR(150),
mobile_number VARCHAR(15),
status VARCHAR(30)
);

CREATE TABLE PublicAsset (
asset_id BIGINT PRIMARY KEY,
asset_name VARCHAR(150) NOT NULL,
asset_type VARCHAR(80) NOT NULL,
location VARCHAR(255),
ward_number INT,
installation_date DATE,
asset_condition VARCHAR(60),
responsible_department_id BIGINT,
FOREIGN KEY (responsible_department_id) REFERENCES Department(department_id)
);

CREATE TABLE MaintenanceSchedule (
schedule_id BIGINT PRIMARY KEY,
asset_id BIGINT NOT NULL,
scheduled_date DATE NOT NULL,
assigned_officer_id BIGINT,
status VARCHAR(30),
maintenance_type VARCHAR(80),
FOREIGN KEY (asset_id) REFERENCES PublicAsset(asset_id),
FOREIGN KEY (assigned_officer_id) REFERENCES Officer(officer_id)
);

CREATE TABLE BudgetAllocation (
budget_id BIGINT PRIMARY KEY,
department_id BIGINT NOT NULL,
financial_year VARCHAR(9) NOT NULL,
allocated_amount DECIMAL(14,2) NOT NULL,
approved_by BIGINT,
approved_date DATE,
FOREIGN KEY (department_id) REFERENCES Department(department_id),
FOREIGN KEY (approved_by) REFERENCES Officer(officer_id)
);

CREATE TABLE DepartmentExpense (
expense_id BIGINT PRIMARY KEY,
department_id BIGINT NOT NULL,
budget_id BIGINT,
expense_amount DECIMAL(14,2) NOT NULL,
expense_category VARCHAR(120) NOT NULL,
description TEXT,
expense_date DATE NOT NULL,
FOREIGN KEY (department_id) REFERENCES Department(department_id),
FOREIGN KEY (budget_id) REFERENCES BudgetAllocation(budget_id)
);

--2) Citizen / property / billing core

CREATE TABLE Citizen (
aadhaar_number CHAR(12) PRIMARY KEY,
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
gender VARCHAR(10),
date_of_birth DATE,
mobile_number VARCHAR(15) UNIQUE,
email VARCHAR(254) UNIQUE,
occupation VARCHAR(100),
registration_date DATE,
status VARCHAR(30)
);

CREATE TABLE Household (
household_id BIGINT PRIMARY KEY,
head_aadhaar CHAR(12),
total_members INT,
ward_number INT,
address_line1 VARCHAR(255),
address_line2 VARCHAR(255),
pincode VARCHAR(10),
registration_date DATE,
CONSTRAINT fk_household_head
FOREIGN KEY (head_aadhaar) REFERENCES Citizen(aadhaar_number),
CONSTRAINT fk_household_location
FOREIGN KEY (pincode) REFERENCES LOCATION(pincode)
);

CREATE TABLE Location (
pincode VARCHAR(10) PRIMARY KEY,
city VARCHAR(100) NOT NULL,
state VARCHAR(100) NOT NULL
);

CREATE TABLE Property (
property_id BIGINT PRIMARY KEY,
household_id BIGINT NOT NULL,
property_type VARCHAR(80),
property_use_type VARCHAR(80),
built_up_area_sqft DECIMAL(12,2),
land_area_sqft DECIMAL(12,2),
construction_year SMALLINT,
zone VARCHAR(50),
ward_number INT,
property_status VARCHAR(30),
FOREIGN KEY (household_id) REFERENCES Household(household_id)
);

CREATE TABLE Ownership (
ownership_id BIGINT PRIMARY KEY,
property_id BIGINT NOT NULL,
aadhaar_number CHAR(12) NOT NULL,
ownership_percentage DECIMAL(5,2) NOT NULL,
ownership_start_date DATE NOT NULL,
ownership_end_date DATE,
FOREIGN KEY (property_id) REFERENCES Property(property_id),
FOREIGN KEY (aadhaar_number) REFERENCES Citizen(aadhaar_number),
UNIQUE (property_id, aadhaar_number)
);

CREATE TABLE UtilityConnection (
connection_id BIGINT PRIMARY KEY,
utility_type VARCHAR(50) NOT NULL,
property_id BIGINT NOT NULL,
connection_status VARCHAR(30),
connection_date DATE,
connection_number VARCHAR(100) NOT NULL UNIQUE,
tariff_category VARCHAR(50),
FOREIGN KEY (property_id) REFERENCES Property(property_id)
);

CREATE TABLE SmartMeter (
meter_id BIGINT PRIMARY KEY,
connection_id BIGINT NOT NULL,
manufacturer VARCHAR(120),
meter_serial_number VARCHAR(120) UNIQUE,
installation_date DATE,
meter_status VARCHAR(30),
FOREIGN KEY (connection_id) REFERENCES UtilityConnection(connection_id)
);

CREATE TABLE MeterReading (
reading_id BIGINT PRIMARY KEY,
meter_id BIGINT NOT NULL,
reading_value DECIMAL(14,3) NOT NULL,
reading_unit VARCHAR(30),
reading_date DATE NOT NULL,
recorded_by BIGINT,
remarks TEXT,
FOREIGN KEY (meter_id) REFERENCES SmartMeter(meter_id),
FOREIGN KEY (recorded_by) REFERENCES Officer(officer_id)
);

CREATE TABLE BillingRecord (
bill_id BIGINT PRIMARY KEY,
connection_id BIGINT NOT NULL,
billing_period_start DATE NOT NULL,
billing_period_end DATE NOT NULL,
previous_reading DECIMAL(14,3),
current_reading DECIMAL(14,3),
units_consumed DECIMAL(14,3),
bill_amount DECIMAL(14,2) NOT NULL,
due_date DATE,
bill_status VARCHAR(30),
late_fee DECIMAL(14,2),
generated_date DATE,
FOREIGN KEY (connection_id) REFERENCES UtilityConnection(connection_id),
UNIQUE (connection_id, billing_period_start, billing_period_end)
);

CREATE TABLE PaymentTransaction (
payment_id BIGINT PRIMARY KEY,
bill_id BIGINT NOT NULL,
payment_date DATE NOT NULL,
payment_amount DECIMAL(14,2) NOT NULL,
payment_mode VARCHAR(40),
transaction_reference VARCHAR(120) UNIQUE,
payment_status VARCHAR(30),
FOREIGN KEY (bill_id) REFERENCES BillingRecord(bill_id)
);

--3) Complaints and work management

CREATE TABLE Complaint (
complaint_id BIGINT PRIMARY KEY,
aadhaar_number CHAR(12),
property_id BIGINT,
complaint_category VARCHAR(120) NOT NULL,
complaint_description TEXT,
complaint_date DATE NOT NULL,
priority_level VARCHAR(30),
status VARCHAR(30),
assigned_department_id BIGINT,
FOREIGN KEY (aadhaar_number) REFERENCES Citizen(aadhaar_number),
FOREIGN KEY (property_id) REFERENCES Property(property_id),
FOREIGN KEY (assigned_department_id) REFERENCES Department(department_id)
); 

CREATE TABLE WorkOrder (
work_order_id BIGINT PRIMARY KEY,
complaint_id BIGINT NOT NULL,
assigned_officer_id BIGINT,
contractor_id BIGINT,
issue_date DATE NOT NULL,
expected_completion_date DATE,
actual_completion_date DATE,
work_status VARCHAR(30),
cost_incurred DECIMAL(14,2),
FOREIGN KEY (complaint_id) REFERENCES Complaint(complaint_id),
FOREIGN KEY (assigned_officer_id) REFERENCES Officer(officer_id),
FOREIGN KEY (contractor_id) REFERENCES Contractor(contractor_id)
);

CREATE TABLE officer_work (
officer_id BIGINT NOT NULL,
work_order_id BIGINT NOT NULL,
PRIMARY KEY (officer_id, work_order_id),
CONSTRAINT fk_officer_work
    FOREIGN KEY (officer_id) REFERENCES Officer(officer_id),
CONSTRAINT fk_officer_work
    FOREIGN KEY (work_order_id) REFERENCES WorkOrder(work_order_id)
);
