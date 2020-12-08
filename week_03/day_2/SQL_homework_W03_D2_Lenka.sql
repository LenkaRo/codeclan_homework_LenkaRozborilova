/* MVP */

/* Q1 Get a table of all employees details, together with their local_account_no and local_sort_code, if they have them */

SELECT 
	e.*,
	pd.local_account_no,
	pd.local_sort_code,
FROM 
	employees AS e LEFT JOIN pay_details AS pd
	ON e.pay_detail_id = pd.id;


/* Q2 Amend your query from question 1 above to also return the name of the team that each employee belongs to */

SELECT 
	e.*,
	pd.local_account_no,
	pd.local_sort_code,
	t.name AS team_name
FROM 
	(employees AS e LEFT JOIN pay_details AS pd
	ON e.pay_detail_id = pd.id)
LEFT JOIN teams AS t 
ON e.team_id = t.id;


/* Q3 Find the first name, last name and team name of employees who are members of teams for which 
 * the charge cost is greater than 80. Order the employees alphabetically by last name. */

SELECT 
	e.first_name,
	e.last_name,
	t.name AS team_name,
	t.charge_cost 
FROM 
	employees AS e LEFT JOIN teams AS t 
	ON e.team_id = t.id
WHERE CAST(t.charge_cost AS INT) > 80
ORDER BY e.last_name;


/* Q4 Breakdown the number of employees in each of the teams, including any teams without members. 
 * Order the table by increasing size of team. */

SELECT
	t.name AS team_name,
	COUNT(e.id) AS number_of_employees
FROM
	employees AS e RIGHT JOIN teams AS t 
	ON e.team_id = t.id 
GROUP BY t.name 
ORDER BY COUNT(e.id);


/* Q5 The effective_salary of an employee is defined as their fte_hours multiplied by their salary. 
 * Get a table for each employee showing their id, first_name, last_name, fte_hours, salary and effective_salary, 
 * along with a running total of effective_salary with employees placed in ascending order of effective_salary. */

SELECT 
	id,
	first_name,
	last_name,
	fte_hours,
	salary,
	(fte_hours * salary) AS effective_salary_asc,
	SUM(fte_hours * salary) OVER(ORDER BY fte_hours * salary) AS sum_effective_salary
FROM employees;


/* Q6 The total_day_charge of a team is defined as 
 * the charge_cost of the team multiplied by the number of employees in the team. 
 * Calculate the total_day_charge for each team. */

SELECT 
	t.name AS team_name,
	CAST(t.charge_cost AS INT) * COUNT(e.id) OVER (PARTITION BY t.name) AS total_day_charge 
FROM 
	employees AS e LEFT JOIN teams AS t 
	ON e.team_id = t.id;



/* Q7 How would you amend your query from question 6 above to show only those teams with a total_day_charge greater than 5000?
 */

SELECT 
	t.name AS team_name,
	((CAST(t.charge_cost AS INT) * COUNT(e.id) OVER (PARTITION BY t.name)) > 5000) IS TRUE AS total_day_charge_greater_than_5000 
FROM 
	employees AS e LEFT JOIN teams AS t 
	ON e.team_id = t.id;


/* EQ */

/* Q1 How many of the employees serve on one or more committees? */
	-- = 22
	
SELECT 
	COUNT(DISTINCT(employee_id))
FROM employees_committees;


/* Q2 How many of the employees do not serve on a committee */
	-- = 978
	-- got rid of distinct as did left join and that brongs throug employees working for more then 1 commettees too 
	-- check COUNT(e.id) FROM employee is 1000
	-- from task above we know 22

SELECT 
	COUNT(e.id) - COUNT(ec.employee_id)
FROM
	employees AS e LEFT JOIN employees_committees AS ec 
	ON e.id = ec.employee_id;
	

/* Q3 Get the full employee details (including committee name) of any committee members based in China. */
-- join strategy: employee e.id ec.employee_id employees_committees ec.committee_id c.id committees 

WITH 
committee_join(id) AS (
SELECT 
	*
FROM 
	committees AS c INNER JOIN employees_committees AS ec 
	ON c.id = ec.committee_id
)
SELECT 
	*
FROM employees AS e INNER JOIN committee_join
ON e.id = committee_join.employee_id
WHERE e.country = 'China';


/* [Tough!] Group committee members into the teams in which they work, 
 * counting the number of committee members in each team (including teams with no committee members). 
 * Order the list by the number of committee members, highest first. */
-- including teams with no committee members -> LEFT JOIN


WITH 
ec_e_join(id) AS (
SELECT 
	*
FROM 
	employees_committees AS ec INNER JOIN employees AS e  
	ON ec.employee_id = e.id
)
SELECT 
	name AS team_name,
	COUNT(DISTINCT(employee_id)) AS num_committees
FROM teams AS t LEFT JOIN ec_e_join
ON t.id = ec_e_join.team_id
GROUP BY name
ORDER BY num_committees DESC 



