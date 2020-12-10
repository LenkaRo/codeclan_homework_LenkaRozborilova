/* Q1 Take some time to explore the database using DBeaver (you will need to create a new connection to acme_pool in DBeaver to do this):

/* How many records are there in each table? */
SELECT COUNT(*) FROM employees
-- 200

SELECT COUNT(*) FROM feedbacks
-- 60

SELECT COUNT(*) FROM teams 
-- 11

/* Identify any columns corresponding to primary keys and foreign keys in each table. */
-- ER diagrams

/* Are there any constraints on foreign keys? */
-- eg DDL of table employees
-- CONSTRAINT employees_pkey PRIMARY KEY (id),
-- CONSTRAINT employees_team_id_fkey FOREIGN KEY (team_id) REFERENCES teams(id)

/* Can you summarise any relationships between tables? */
feedbacks - employees - teams 



/* Q2 We want to store database details securely on your computer. 
 * First, create a file outside a Git repo (say in your home directory) called acme_credentials.R and 
 * add all of the connection details given above to the file as R character variables: */

/* Obtain a breakdown of the number of employees per team. 
 * Order the table by decreasing number of employees. Include all teams, even if they have no employees. */

SELECT 
	team_id,
	COUNT(id) AS num_of_employees
FROM employees
GROUP BY team_id
ORDER BY num_of_employees DESC;


/* AcmeCorp management want to send an email survey to each of their employees.
 * However, they are worried that some of the employees may not receive the email either 
 * because their email addresses may be invalid (in that they don’t contain an ‘@’ symbol), 
 * or they may not have a stored email address at all. Can you find all these employees? */

SELECT
	*
FROM employees 
WHERE email IS NULL OR email NOT LIKE '%@%'

/* Which of the employees provided the most recent feedback? What was the date of this feedback? */

SELECT 
	e.first_name,
	e.last_name,
	f.date
FROM
	employees AS e INNER JOIN feedbacks AS f 
	ON e.id = f.employee_id 
ORDER BY date DESC NULLS LAST 
LIMIT 1;

/* You are chatting with one of the AcmeCorp employees, and she mentions that one of the teams 
 * in the corporation has some employees whose stored first_name contains only their first initial, 
 * e.g. “D” instead of “Dionne”, “C” instead of “Charles”. 
 * Can you find the name of the team that she is most likely referring to 
 * (i.e. which team has the highest number of employees with single initial first_names)`? */



