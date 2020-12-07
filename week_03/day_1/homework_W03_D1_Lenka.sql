/* MVP */

/* Q1 Find all the employees who work in the ‘Human Resources’ department. */

SELECT *
FROM employees
WHERE department = 'Human Resources'

/* Q2 Get the first_name, last_name, and country of the employees who work in the ‘Legal’ department */

SELECT 
	first_name,
	last_name,
	country
FROM employees
WHERE department = 'Legal'

/* Q3 Count the number of employees based in Portugal. */

SELECT COUNT(*) AS number_of_employees
FROM employees
WHERE country = 'Portugal'

/* Q4 Count the number of employees based in either Portugal or Spain. */

SELECT COUNT(*) AS number_of_employees
FROM employees
WHERE country = 'Portugal' OR country = 'Spain'

/* Q5 Count the number of pay_details records lacking a local_account_no. */

SELECT COUNT(pay_details) AS number_of_pay_details_with_no_account_no
FROM pay_details
WHERE local_account_no IS NULL;

/* Q6 Get a table with employees first_name and last_name ordered alphabetically by last_name (put any NULLs last). */

SELECT 
	first_name,
	last_name
FROM employees
ORDER BY last_name NULLS LAST 

/* Q7 How many employees have a first_name beginning with ‘F’? */

SELECT COUNT(*)
FROM employees
WHERE first_name LIKE 'F%'

/* Q8 Count the number of pension enrolled employees not based in either France or Germany. */

SELECT COUNT(*)
FROM employees
WHERE pension_enrol = TRUE AND (country != 'France' AND country != 'Germany')

/* Q8 Obtain a count by department of the employees who started work with the corporation in 2003. */

SELECT 
	department,
	COUNT(*) AS count_of_employees_start_2013
FROM employees
WHERE start_date BETWEEN '2003-01-01' AND '2003-12-31' 
GROUP BY department

/* Q9 Obtain a table showing department, fte_hours and the number of employees in each department who work each fte_hours pattern.
 * Order the table alphabetically by department, and then in ascending order of fte_hours. */

SELECT
	department,
	fte_hours,
	COUNT(*) AS number_of_employees
FROM employees
GROUP BY 
	department,
	fte_hours 
ORDER BY 
	department,
	fte_hours ASC

/* Q10 Obtain a table showing any departments in which there are two or more employees lacking a stored first name.
 * Order the table in descending order of the number of employees lacking a first name, 
 * and then in alphabetical order by department. */
	
SELECT
	department,
	COUNT(*)
FROM employees 
WHERE first_name IS NULL 
GROUP BY department 
HAVING COUNT(*) >= 2
ORDER BY department 
	
/* Q11 [Tough!] Find the proportion of employees in each department who are grade 1 */

SELECT
	department,
	grade,
	SUM(CAST(grade = 1 AS INTEGER)) AS count_grade_1,
	SUM(CAST(grade IN (0, 1) AS INTEGER)) AS count_grade_0_1
	--SUM(CAST(grade = 1 AS INTEGER)) / SUM(CAST(grade IN (0, 1) AS INTEGER))
FROM employees
WHERE grade IS NOT NULL
GROUP BY 
	department,
	grade
ORDER BY 
	department,
	grade;





