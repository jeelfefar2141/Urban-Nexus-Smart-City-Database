-- <----------------------------------------------------Urban_Nexus-Smart_City_Governance_Database Queries------------------------------------------------------------->


-- Scenario 1 — Citizen billing & payment dashboard
-- Municipal finance officers need to track outstanding dues, overdue bills, and payment history for utility connections across the city.

-- 1.Find citizen-wise total outstanding bill amount (including late fee) for unpaid bills.
SELECT c.aadhaar_number,
SUM(b.bill_amount + COALESCE(b.late_fee,0))
FROM Citizen c
JOIN Household h ON c.aadhaar_number = h.head_aadhaar
JOIN Property p ON h.household_id = p.household_id
JOIN UtilityConnection u ON p.property_id = u.property_id
JOIN BillingRecord b ON u.connection_id = b.connection_id
WHERE b.bill_status != 'Paid'
GROUP BY c.aadhaar_number;

-- 2.Find total revenue collected month-wise from payment transactions.
SELECT EXTRACT(MONTH FROM payment_date),
SUM(payment_amount)
FROM PaymentTransaction
GROUP BY EXTRACT(MONTH FROM payment_date);

-- 3.Find highest utility consumption per month.
SELECT EXTRACT(MONTH FROM billing_period_start),
MAX(units_consumed)
FROM BillingRecord
GROUP BY EXTRACT(MONTH FROM billing_period_start);

-- 4.Find all bills that are either paid or unpaid.
SELECT bill_id FROM BillingRecord
WHERE bill_status='Paid'
UNION
SELECT bill_id FROM BillingRecord
WHERE bill_status='Unpaid';

-- 5.Find all unpaid bills using EXCEPT operation.
SELECT bill_id FROM BillingRecord
EXCEPT
SELECT bill_id FROM BillingRecord
WHERE bill_status='Paid';

-- 6.Find utility connections that have no payment made.
SELECT connection_id
FROM UtilityConnection
WHERE connection_id NOT IN
(
SELECT connection_id
FROM BillingRecord b
JOIN PaymentTransaction p
ON b.bill_id = p.bill_id
);

-- 7.Find top 5 citizens who made highest payments.
SELECT c.aadhaar_number,
SUM(p.payment_amount)
FROM Citizen c
JOIN Household h ON c.aadhaar_number=h.head_aadhaar
JOIN Property pr ON h.household_id=pr.household_id
JOIN UtilityConnection u ON pr.property_id=u.property_id
JOIN BillingRecord b ON u.connection_id=b.connection_id
JOIN PaymentTransaction p ON b.bill_id=p.bill_id
GROUP BY c.aadhaar_number
ORDER BY SUM(p.payment_amount) DESC
LIMIT 5;

-- 8.Find average bill amount for each utility type.
SELECT u.utility_type,
AVG(b.bill_amount)
FROM UtilityConnection u
JOIN BillingRecord b
ON u.connection_id=b.connection_id
GROUP BY u.utility_type;

-- 9.Find citizens who have no pending bills.
SELECT aadhaar_number
FROM Citizen
EXCEPT
SELECT c.aadhaar_number
FROM Citizen c
JOIN Household h ON c.aadhaar_number = h.head_aadhaar
JOIN Property p ON h.household_id = p.household_id
JOIN UtilityConnection u ON p.property_id = u.property_id
JOIN BillingRecord b ON u.connection_id = b.connection_id
WHERE b.bill_status != 'Paid';

-- 10.Find connections for which bills were not generated last month.
SELECT connection_id
FROM UtilityConnection
WHERE connection_id NOT IN
(
SELECT connection_id
FROM BillingRecord
WHERE billing_period_start >=
CURRENT_DATE - INTERVAL '1 month'
);

-- 11.Find total meter reading growth for each meter.
SELECT meter_id,
MAX(reading_value)-MIN(reading_value)
FROM MeterReading
GROUP BY meter_id;

-- 12.Find the top 5 utility connections with the highest total consumption from January 2024 onwards.
SELECT connection_id,
SUM(units_consumed) AS total_units
FROM BillingRecord
WHERE billing_period_start >= '2024-01-01'
GROUP BY connection_id
ORDER BY total_units DESC
LIMIT 5;;




-- Scenario 2 — Complaint & work order management
-- City administrators track citizen complaints, assign departments and officers, and monitor work order progress from filing to resolution.


-- 1. Find complaints with assigned officer and contractor :
SELECT c.complaint_id, o.first_name AS officer, ct.contractor_name
FROM Complaint c
JOIN WorkOrder w ON c.complaint_id = w.complaint_id
JOIN Officer o ON w.assigned_officer_id = o.officer_id
LEFT JOIN Contractor ct ON w.contractor_id = ct.contractor_id;


-- 2. Find properties with most complaints :
SELECT property_id, COUNT(*) AS total_complaints
FROM Complaint
GROUP BY property_id
ORDER BY total_complaints DESC;


-- 3. Find total cost spent on resolved complaints :
SELECT SUM(w.cost_incurred) AS total_resolved_cost
FROM WorkOrder w
JOIN Complaint c ON w.complaint_id = c.complaint_id
WHERE c.status = 'Resolved';


-- 4. Find contractor involvement in active work :
SELECT ct.contractor_name, COUNT(*) AS active_work
FROM Contractor ct
JOIN WorkOrder w ON ct.contractor_id = w.contractor_id
WHERE w.work_status IN ('In Progress', 'Assigned')
GROUP BY ct.contractor_name;


-- 5. Find number of complaints handled by each department with total cost :
SELECT d.department_name, 
       COUNT(c.complaint_id) AS total_complaints,
       SUM(w.cost_incurred) AS total_cost
FROM Department d
JOIN Complaint c ON d.department_id = c.assigned_department_id
JOIN WorkOrder w ON c.complaint_id = w.complaint_id
GROUP BY d.department_name;


-- 6. Find complaint category with average cost per complaint :
SELECT c.complaint_category, 
       AVG(w.cost_incurred) AS avg_cost
FROM Complaint c
JOIN WorkOrder w ON c.complaint_id = w.complaint_id
GROUP BY c.complaint_category;


-- 7. Citizens who filed complaints in multiple departments :
SELECT ci.first_name, COUNT(DISTINCT c.assigned_department_id) AS dept_count
FROM Citizen ci
JOIN Complaint c ON ci.aadhaar_number = c.aadhaar_number
GROUP BY ci.first_name
HAVING COUNT(DISTINCT c.assigned_department_id) >= 1;


-- 8. Officer handling the maximum number of work orders :
SELECT o.first_name, COUNT(*) AS total
FROM Officer o
JOIN WorkOrder w ON o.officer_id = w.assigned_officer_id
GROUP BY o.officer_id
HAVING COUNT(*) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM WorkOrder
        GROUP BY assigned_officer_id
    ) AS temp
);


-- 9. Work orders with officer details and status :
SELECT w.work_order_id,
       o.first_name,
       o.designation,
       w.work_status
FROM WorkOrder w
JOIN Officer o ON w.assigned_officer_id = o.officer_id;


-- 10. Officers whose total work cost is greater than EVERY other officer (top performer) :
SELECT o.first_name, SUM(w.cost_incurred) AS total_cost
FROM Officer o
JOIN WorkOrder w ON o.officer_id = w.assigned_officer_id
GROUP BY o.officer_id
HAVING SUM(w.cost_incurred) >= ALL (
    SELECT SUM(cost_incurred)
    FROM WorkOrder
    GROUP BY assigned_officer_id
);


-- 11. Properties with highest electricity consumption :
SELECT p.property_id, MAX(mr.reading_value) AS max_usage
FROM Property p
JOIN UtilityConnection u ON p.property_id = u.property_id
JOIN SmartMeter sm ON u.connection_id = sm.connection_id
JOIN MeterReading mr ON sm.meter_id = mr.meter_id
WHERE u.utility_type = 'Electricity'
GROUP BY p.property_id;


-- 12. Complaints whose work is still not completed but bill is paid :
SELECT c.complaint_id
FROM Complaint c
JOIN WorkOrder w ON c.complaint_id = w.complaint_id
JOIN Property p ON c.property_id = p.property_id
JOIN UtilityConnection u ON p.property_id = u.property_id
JOIN BillingRecord b ON u.connection_id = b.connection_id
WHERE w.work_status != 'Completed'
AND b.bill_status = 'Paid';




-- Scenario 3 — Property & ownership management
-- The municipal authority needs to manage property records, ownership transfers, and zone-wise analytics for tax assessment and urban planning.


-- 1.  Question: List all citizens along with the properties they own?
    SELECT c.first_name, c.last_name, p.property_id, p.zone
    FROM Citizen c JOIN Ownership o ON c.aadhaar_number =
    o.aadhaar_number JOIN Property p ON o.property_id = p.property_id;

-- 2.  Question: Which are the top 5 properties based on built-up area?
    SELECT property_id, built_up_area_sqft FROM Property ORDER
    BY built_up_area_sqft DESC LIMIT 5;

-- 3.  Question: Which bills are overdue? 
    SELECT bill_id, bill_amount, due_date 
	FROM BillingRecord 
	WHERE bill_status = 'Overdue';

-- 4.  Question: What is the total population in each ward? 
    SELECT ward_number, SUM(total_members) AS total_population FROM
    Household GROUP BY ward_number;

-- 5.  Question: Which department has received the highest number of complaints? 
    SELECT assigned_department_id, COUNT(*) AS
    total_complaints FROM Complaint GROUP BY assigned_department_id
    ORDER BY total_complaints DESC;

-- 6.  Question: How many properties exist in each zone? 
    SELECT zone, COUNT(*) AS total_properties FROM Property GROUP BY zone ORDER
    BY total_properties DESC;

-- 7.  Question: Which zone generates the highest revenue?
    SELECT 
    p.zone, SUM(b.bill_amount) AS total_revenue FROM Property p JOIN
    UtilityConnection u ON p.property_id = u.property_id JOIN
    BillingRecord b ON u.connection_id = b.connection_id GROUP BY p.zone
    ORDER BY total_revenue DESC;

-- 8.  Which properties have no billing records?
    SELECT
    p.property_id FROM Property p LEFT JOIN UtilityConnection u ON
    p.property_id = u.property_id LEFT JOIN BillingRecord b ON
    u.connection_id = b.connection_id WHERE b.bill_id IS NULL;

-- 9.  Question: What is the average utility consumption for each property type? 
    SELECT p.property_type, AVG(b.units_consumed) AS
    avg_consumption FROM Property p JOIN UtilityConnection u ON
    p.property_id = u.property_id JOIN BillingRecord b ON
    u.connection_id = b.connection_id GROUP BY p.property_type;

-- 10. Question: Which utility connections have total consumption greater than the average consumption across all connections?
    SELECT connection_id, SUM(units_consumed) AS total_units FROM
    BillingRecord GROUP BY connection_id HAVING SUM(units_consumed) > (
    SELECT AVG(total_units) FROM ( SELECT connection_id,
    SUM(units_consumed) AS total_units FROM BillingRecord GROUP BY
    connection_id ) t );

-- 11. Question: Show cumulative revenue over time?
    SELECT
    generated_date, SUM(bill_amount) AS daily_revenue,
    SUM(SUM(bill_amount)) OVER (ORDER BY generated_date) AS
    running_total FROM BillingRecord GROUP BY generated_date ORDER BY
    generated_date;

-- 12. Question: Who is the most recent owner of each property?
    SELECT property_id, aadhaar_number, ownership_start_date FROM (
    SELECT *, ROW_NUMBER() OVER ( PARTITION BY property_id ORDER BY
    ownership_start_date DESC ) AS rn FROM Ownership ) t WHERE rn = 1;

-- 13. Question: What percentage of total revenue is contributed by each property?
    SELECT p.property_id, SUM(b.bill_amount) AS
    total_revenue, ROUND( SUM(b.bill_amount) * 100.0 /
    SUM(SUM(b.bill_amount)) OVER (), 2 ) AS percentage_contribution FROM
    Property p JOIN UtilityConnection u ON p.property_id = u.property_id
    JOIN BillingRecord b ON u.connection_id = b.connection_id GROUP BY
    p.property_id ORDER BY total_revenue DESC;



-- Scenario 4 — Department budget & expense tracking
-- Finance department monitors budget allocations, tracks expenditure across departments, and flags overspending or underutilization.

-- Q1 Retrieve the budget allocation and actual expenditure for each department along with remaining budget and utilization percentage.
SELECT d.department_name, ba.financial_year, ba.allocated_amount,
       COALESCE(SUM(de.expense_amount), 0) AS total_spent,
       ba.allocated_amount - COALESCE(SUM(de.expense_amount), 0) AS remaining_budget,
       ROUND(COALESCE(SUM(de.expense_amount), 0) * 100.0 / ba.allocated_amount, 2) AS utilization_pct
FROM BudgetAllocation ba
JOIN Department d
  ON ba.department_id = d.department_id
LEFT JOIN DepartmentExpense de
  ON ba.budget_id = de.budget_id
GROUP BY d.department_name, ba.financial_year, ba.allocated_amount
ORDER BY utilization_pct DESC;
 

-- Q2 Show each department's allocated budget and their total amount spent on expenses. 
SELECT d.department_name, ba.allocated_amount, SUM(de.expense_amount) AS total_spent
FROM Department d
JOIN BudgetAllocation ba ON d.department_id = ba.department_id
JOIN DepartmentExpense de ON d.department_id = de.department_id
GROUP BY d.department_name, ba.allocated_amount;


-- Q3 Find the departments where budget utilization is less than 40%.
SELECT d.department_name, ba.financial_year, ba.allocated_amount,
       COALESCE(SUM(de.expense_amount), 0)   AS spent_so_far,
       ROUND( COALESCE(SUM(de.expense_amount), 0) * 100.0 / ba.allocated_amount, 2) AS utilization_pct
FROM BudgetAllocation ba
JOIN Department d
  ON ba.department_id = d.department_id
LEFT JOIN DepartmentExpense de
  ON ba.budget_id = de.budget_id
GROUP BY d.department_name, ba.financial_year, ba.allocated_amount
HAVING COALESCE(SUM(de.expense_amount), 0) * 100.0 / ba.allocated_amount < 40
ORDER BY utilization_pct ASC;


-- Q4 Provide a category-wise breakdown of expenses for each department, including number of transactions, total amount, and percentage contribution. 
SELECT d.department_name, de.expense_category,
       COUNT(de.expense_id)   AS num_transactions,
       SUM(de.expense_amount) AS total_amount,
       ROUND( SUM(de.expense_amount) * 100.0 / SUM(SUM(de.expense_amount)) OVER (PARTITION BY d.department_name), 2) AS pct_of_dept_total
FROM DepartmentExpense de
JOIN Department d
  ON de.department_id = d.department_id
GROUP BY d.department_name, de.expense_category
ORDER BY d.department_name, total_amount DESC;


-- Q5 Analyze the monthly expense trend for each department, including number of transactions and total spending per month. 
SELECT d.department_name,
       TO_CHAR(de.expense_date, 'YYYY-MM') AS month,
       COUNT(de.expense_id) AS transactions,
       SUM(de.expense_amount) AS monthly_spend
FROM DepartmentExpense de
JOIN Department d
  ON de.department_id = d.department_id
GROUP BY d.department_name,
         TO_CHAR(de.expense_date, 'YYYY-MM')
ORDER BY d.department_name, month;


-- Q6 Generate a city-wide annual budget report showing total allocated budget, total expenditure, surplus, and utilization percentage for each financial year.
SELECT ba.financial_year,
       COUNT(DISTINCT ba.department_id) AS departments_funded,
       SUM(ba.allocated_amount) AS total_allocated,
       SUM(de.expense_amount) AS total_spent,
       SUM(ba.allocated_amount) - SUM(de.expense_amount) AS surplus,
       ROUND(SUM(de.expense_amount) * 100.0 / SUM(ba.allocated_amount), 2) AS city_utilization_pct
FROM BudgetAllocation ba
LEFT JOIN DepartmentExpense de
  ON ba.budget_id = de.budget_id
GROUP BY ba.financial_year
ORDER BY ba.financial_year DESC;


-- Q7 List the budgets approved by each officer along with total amount approved, minimum and maximum approved amounts.
SELECT o.officer_id,
       o.first_name || ' ' || o.last_name AS approver_name,
       o.designation,
       COUNT(ba.budget_id) AS budgets_approved,
       SUM(ba.allocated_amount) AS total_amount_approved,
       MIN(ba.allocated_amount) AS min_approved,
       MAX(ba.allocated_amount) AS max_approved
FROM BudgetAllocation ba
JOIN Officer o
  ON ba.approved_by = o.officer_id
GROUP BY o.officer_id, o.first_name, o.last_name, o.designation
ORDER BY total_amount_approved DESC;


-- Q8 Retrieve the top 10 largest individual expense transactions across all departments. 
SELECT de.expense_id, d.department_name, de.expense_category, de.expense_amount, de.expense_date, de.description
FROM DepartmentExpense de
JOIN Department d
  ON de.department_id = d.department_id
ORDER BY de.expense_amount DESC
LIMIT 10;


-- Q9 Identify expense records that are not linked to any budget (orphan expenses).
SELECT de.expense_id, d.department_name, de.expense_amount, de.expense_category, de.expense_date, de.description
FROM DepartmentExpense de
JOIN Department d
  ON de.department_id = d.department_id
WHERE de.budget_id IS NULL
ORDER BY de.expense_date DESC;

-- Q10 Calculate department-wise total number of expenses, total spending, average transaction size, smallest and largest expense. 
SELECT d.department_name,
       COUNT(de.expense_id) AS total_transactions,
       SUM(de.expense_amount) AS total_spent,
       ROUND(AVG(de.expense_amount),2) AS avg_transaction_size,
       MIN(de.expense_amount) AS smallest_expense,
       MAX(de.expense_amount) AS largest_expense
FROM DepartmentExpense de
JOIN Department d
  ON de.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_transactions DESC;


Q11 Count the number of expenses made by each department for each expense category.

SELECT d.department_name, de.expense_category,
       COUNT(de.expense_id) AS frequency
FROM DepartmentExpense de
JOIN Department d
  ON de.department_id = d.department_id
GROUP BY d.department_name, de.expense_category
ORDER BY d.department_name, frequency DESC;


-- Q12 — Find departments where no expense has been recorded in the last 30 days, including their last expense date.
SELECT d.department_id, d.department_name, d.office_location,
       MAX(de.expense_date) AS last_expense_date
FROM Department d
LEFT JOIN DepartmentExpense de
  ON d.department_id = de.department_id
GROUP BY d.department_id, d.department_name, d.office_location
HAVING MAX(de.expense_date) < CURRENT_DATE - INTERVAL '30 days'
    OR MAX(de.expense_date) IS NULL
ORDER BY last_expense_date ASC NULLS FIRST;




-- Scenario 5 — Public asset & maintenance monitoring
-- The asset management team tracks city infrastructure (streetlights, roads, parks), schedules maintenance, and monitors asset conditions ward-wise.


-- Q.1)How many assets are there in each ward categorized by their condition?
SELECT
    ward_number,
    asset_condition,
    COUNT(*) AS asset_count
FROM PublicAsset
GROUP BY ward_number, asset_condition
ORDER BY ward_number, asset_condition;


-- Q.2)How many total assets are managed by each department?
SELECT
    d.department_id,
    d.department_name,
    COUNT(pa.asset_id) AS total_assets
FROM Department d
LEFT JOIN PublicAsset pa
    ON d.department_id = pa.responsible_department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_assets DESC;


-- Q.3)What is the maintenance workload of each department based on maintenance status?
SELECT
    d.department_name,
    ms.status,
    COUNT(*) AS maintenance_count
FROM MaintenanceSchedule ms
JOIN PublicAsset pa
    ON ms.asset_id = pa.asset_id
JOIN Department d
    ON pa.responsible_department_id = d.department_id
GROUP BY d.department_name, ms.status
ORDER BY d.department_name, maintenance_count DESC;


-- Q.4)Which maintenance activities are scheduled in the given time period?
-- (sample insert has 2024 dates, so use a fixed range)
SELECT
    pa.asset_name,
    pa.ward_number,
    d.department_name,
    ms.scheduled_date,
    ms.maintenance_type,
    ms.status,
    o.first_name || ' ' || o.last_name AS officer_name
FROM MaintenanceSchedule ms
JOIN PublicAsset pa
    ON ms.asset_id = pa.asset_id
JOIN Department d
    ON pa.responsible_department_id = d.department_id
JOIN Officer o
    ON ms.assigned_officer_id = o.officer_id
WHERE ms.scheduled_date BETWEEN DATE '2024-04-01' AND DATE '2024-12-31'
  AND ms.status IN ('Scheduled', 'In Progress')
ORDER BY ms.scheduled_date;


-- Q.5)Which maintenance tasks are overdue and not yet completed?
SELECT
    ms.schedule_id,
    pa.asset_name,
    pa.location,
    pa.ward_number,
    ms.scheduled_date,
    ms.status,
    o.first_name || ' ' || o.last_name AS officer_name
FROM MaintenanceSchedule ms
JOIN PublicAsset pa
    ON ms.asset_id = pa.asset_id
JOIN Officer o
    ON ms.assigned_officer_id = o.officer_id
WHERE ms.scheduled_date < CURRENT_DATE
  AND ms.status <> 'Completed'
ORDER BY ms.scheduled_date;


-- Q.6)How many assets have never been scheduled for maintenance?
SELECT
    COUNT(*) AS unscheduled_assets
FROM PublicAsset pa
WHERE NOT EXISTS (
    SELECT 1
    FROM MaintenanceSchedule ms
    WHERE ms.asset_id = pa.asset_id
);


-- Q.7)Which officers are assigned to maintenance tasks and how many assignments do they have?
SELECT
    o.officer_id,
    o.first_name || ' ' || o.last_name AS officer_name,
    d.department_name,
    COUNT(ms.schedule_id) AS total_assignments
FROM Officer o
JOIN Department d
    ON o.department_id = d.department_id
JOIN MaintenanceSchedule ms
    ON o.officer_id = ms.assigned_officer_id
GROUP BY o.officer_id, o.first_name, o.last_name, d.department_name
HAVING COUNT(ms.schedule_id) >= 1
ORDER BY total_assignments DESC;



-- Q.8)What is the average age of assets for each asset type?
SELECT
    asset_type,
    ROUND(
        AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, installation_date)))::numeric,
        2
    ) AS avg_asset_age_years
FROM PublicAsset
GROUP BY asset_type
ORDER BY avg_asset_age_years DESC;


-- Q.9)Which wards have assets in poor or fair condition?
SELECT
    ward_number,
    COUNT(*) AS weak_condition_assets
FROM PublicAsset
WHERE asset_condition IN ('Fair', 'Poor')
GROUP BY ward_number
ORDER BY weak_condition_assets DESC;


-- Q.10)What are the maintenance details of assets under each department?
SELECT
    d.department_name,
    pa.asset_name,
    pa.asset_type,
    ms.maintenance_type,
    ms.scheduled_date,
    ms.status
FROM PublicAsset pa
JOIN Department d
    ON pa.responsible_department_id = d.department_id
JOIN MaintenanceSchedule ms
    ON pa.asset_id = ms.asset_id
ORDER BY d.department_name, ms.scheduled_date;


-- Q.11)How many assets in each department are in excellent and non-excellent condition?
SELECT
    d.department_name,
    COUNT(pa.asset_id) AS total_assets,
    COUNT(*) FILTER (WHERE pa.asset_condition = 'Excellent') AS excellent_assets,
    COUNT(*) FILTER (WHERE pa.asset_condition <> 'Excellent') AS non_excellent_assets
FROM Department d
LEFT JOIN PublicAsset pa
    ON pa.responsible_department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_name;


-- Q.12)What is the most recent maintenance record for each asset?
SELECT
    pa.asset_name,
    pa.asset_type,
    ms.schedule_id,
    ms.scheduled_date,
    ms.status,
    ms.maintenance_type
FROM PublicAsset pa
JOIN MaintenanceSchedule ms
    ON pa.asset_id = ms.asset_id
WHERE ms.scheduled_date = (
    SELECT MAX(ms2.scheduled_date)
    FROM MaintenanceSchedule ms2
    WHERE ms2.asset_id = pa.asset_id
)
ORDER BY pa.asset_name;