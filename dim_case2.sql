-- SQL Challenge Questions

-- 1. Find the longest ongoing project for each department.

SELECT
	name
    ,(end_date - start_date) AS project_length
FROM dim_2projects;

-- 2. Find all employees who are not managers.

SELECT
	de.name AS non_managers
FROM dim_2employees AS de
LEFT JOIN dim_2departments AS dd
	ON de.id = dd.manager_id
WHERE manager_id IS NULL;

-- 3. Find all employees who have been hired after the start of a project in their department.

SELECT 
	de.name AS name
FROM dim_2employees AS de
LEFT JOIN dim_2projects AS dp
	ON de.department_id = dp.department_id
WHERE de.hire_date > dp.start_date;

-- 4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).

SELECT
	de.name AS employee
    ,dd.name AS department
    ,RANK()
		OVER(PARTITION BY dd.name ORDER BY hire_date) AS hire_rank
FROM dim_2employees AS de
LEFT JOIN dim_2departments AS dd
	ON de.department_id = dd.id;

-- 5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.

WITH cte_1 AS(
SELECT 
	name
    ,hire_date
    ,LAG(hire_date,1)
		OVER (PARTITION BY department_id ORDER BY hire_date) AS previous_hire
FROM dim_2employees)
SELECT
	name
    ,datediff(hire_date,previous_hire) AS difference
FROM cte_1; 
