/* MVP */

/* Q1 Are there any pay_details records lacking both a local_account_no and iban number? */

SELECT 
	COUNT(*)
FROM pay_details
WHERE pay_details IS NULL AND local_account_no IS NULL 

/* Q2 Get a table of employees first_name, last_name and country, 
 * ordered alphabetically first by country and then by last_name (put any NULLs last) */

SELECT 
	first_name,
	last_name,
	country
FROM employees
ORDER BY 
	country ASC NULLS LAST,
	last_name ASC NULLS LAST;

/* Q3 Find the details of the top ten highest paid employees in the corporation. */

SELECT 
	*
FROM employees 
ORDER BY salary DESC NULLS LAST 
LIMIT 10;

/* Q4 Find the first_name, last_name and salary of the lowest paid employee in Hungary. */

SELECT 
	first_name,
	last_name,
	salary,
	country
FROM employees
WHERE country = 'Hungary'
ORDER BY salary ASC NULLS LAST
LIMIT 1;

/* Q5 Find all the details of any employees with a ‘yahoo’ email address? */

SELECT *
FROM employees
WHERE email ILIKE '%@yahoo%'

/* Q6 Provide a breakdown of the numbers of employees enrolled, not enrolled, 
 * and with unknown enrollment status in the corporation pension scheme. */

SELECT 
	pension_enrol,
	COUNT(*)
FROM employees
GROUP BY pension_enrol 

/* Q7 What is the maximum salary among those employees in the ‘Engineering’ 
 * department who work 1.0 full-time equivalent hours (fte_hours) */

SELECT 
	department,
	fte_hours,
	MAX(salary) AS max_salary
FROM employees
WHERE
	department = 'Engineering' AND fte_hours = 1
GROUP BY 
	department,
	fte_hours;

/* Q8 Get a table of country, number of employees in that country, and the average salary of employees 
 * in that country for any countries in which more than 30 employees are based. 
 * Order the table by average salary descending. */

SELECT
	country,
	COUNT(id) AS num_of_employees,
	AVG(salary) AS avg_salary
FROM employees 
GROUP BY country 
HAVING COUNT(id) > 30
ORDER BY avg_salary DESC NULLS LAST;

/* Q9 Return a table containing each employees first_name, last_name, full-time equivalent hours (fte_hours),
 * salary, and a new column effective_yearly_salary which should contain fte_hours multiplied by salary. */

SELECT 
	first_name,
	last_name,
	fte_hours,
	salary,
	fte_hours * salary AS effective_yearly_salary
FROM employees 

/* Q10 Find the first name and last name of all employees who lack a local_tax_code */

SELECT
	e.first_name,
	e.last_name,
	pd.local_tax_code 
FROM
	employees AS e INNER JOIN pay_details AS pd 
	ON e.pay_detail_id = pd.id 
WHERE pd.local_tax_code IS NULL 

/* Q11 The expected_profit of an employee is defined as (48 * 35 * charge_cost - salary) * fte_hours,
 * where charge_cost depends upon the team to which the employee belongs.
 * Get a table showing expected_profit for each employee. */

SELECT 
	e.first_name,
	e.last_name,
	t.name AS team_name,
	(48 * 35 * CAST(t.charge_cost AS INT) - e.salary) * e.fte_hours AS expected_profit
FROM 
	employees AS e INNER JOIN teams AS t 
	ON e.team_id = t.id;



/* Q12 [Bit Tougher] Return a table of those employee first_names shared by more than one employee, 
 * together with a count of the number of times each first_name occurs.
 * Omit employees without a stored first_name from the table. 
 * Order the table descending by count, and then alphabetically by first_name. */

SELECT 
	first_name,
	COUNT(*) AS num_of_employees
FROM employees 
WHERE first_name IS NOT NULL 
GROUP BY first_name 
HAVING COUNT(first_name) >= 2 
ORDER BY 
	num_of_employees DESC,
	first_name ASC;



/* EQ */

/* [Tough] Get a list of the id, first_name, last_name, salary and fte_hours of employees in the largest department.
 * Add two extra columns showing the ratio of each employee’s salary to that department’s average salary, 
 * and each employee’s fte_hours to that department’s average fte_hours. */

WITH dep AS (
SELECT
	department,
	COUNT(id) AS num_of_employees,
	AVG(salary) AS avg_salary,
	AVG(fte_hours) AS avg_fte_hours 
FROM employees
GROUP BY department
ORDER BY num_of_employees DESC NULLS LAST
LIMIT 1
)
SELECT
	id,
	first_name,
	last_name,
	salary,
	avg_salary,
	salary / avg_salary AS ratio_salary,
	fte_hours,
	avg_fte_hours,
	fte_hours / avg_fte_hours AS ration_avg_fte_hours
FROM dep CROSS JOIN employees;


-- OR another way, same otput :)

SELECT 
    id, 
    first_name, 
    last_name, 
    department,
    salary,
    fte_hours,
    salary / AVG(salary) OVER () AS salary_over_dept_avg,
    fte_hours / AVG(fte_hours) OVER () AS fte_hours_over_dept_avg
FROM employees
WHERE department = (
  SELECT
    department
  FROM employees
  GROUP BY department
  ORDER BY COUNT(id) DESC NULLS LAST
  LIMIT 1
);


/* Q2 Have a look again at your table for MVP question 6.
 * It will likely contain a blank cell for the row relating to employees with ‘unknown’ pension enrollment status.
 * This is ambiguous: it would be better if this cell contained ‘unknown’ or something similar.
 * Can you find a way to do this, perhaps using a combination of COALESCE() and CAST(), or a CASE statement? */


			/* Q6 Provide a breakdown of the numbers of employees enrolled, not enrolled, 
 			 * and with unknown enrollment status in the corporation pension scheme. */

SELECT 
	COALESCE(CAST(pension_enrol AS VARCHAR), 'unknown'),
	COUNT(*)
FROM employees
GROUP BY pension_enrol 


/* Q3 Find the first name, last name, email address and start date of all the employees
 * who are members of the ‘Equality and Diversity’ committee.
 * Order the member employees by their length of service in the company, longest first. */

WITH empl_empl_comm AS (
SELECT 
	*
FROM
	employees AS e LEFT JOIN employees_committees AS ec
	ON e.id = ec.employee_id
)
SELECT
	first_name,
	last_name,
	email,
	start_date,
	name 
FROM 
	empl_empl_comm AS eec LEFT JOIN committees AS c 
	ON eec.committee_id = c.id
WHERE name = 'Equality and Diversity'


/* Q4 [Tough!] Use a CASE() operator to group employees who are members of committees 
 * into salary_class of 'low' (salary < 40000) or 'high' (salary >= 40000).
 * A NULL salary should lead to 'none' in salary_class. 
 * Count the number of committee members in each salary_class. */

WITH empl_empl_comm AS (
SELECT 
	*
FROM
	employees AS e RIGHT JOIN employees_committees AS ec
	ON e.id = ec.employee_id
),
salary_class_table AS ( 
SELECT
	*,
	CASE 
		WHEN salary < 40000 THEN 'low'
		WHEN salary >= 40000 THEN 'high'
		WHEN salary IS NULL THEN 'none'
	END salary_class
FROM 
	empl_empl_comm AS eec LEFT JOIN committees AS c 
	ON eec.committee_id = c.id
)
SELECT
	*,
	COUNT(salary_class) OVER (PARTITION BY salary_class) AS count_salary_class
FROM salary_class_table





