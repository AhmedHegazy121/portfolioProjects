-- Task 1: Breakdown of Employees by Gender and Year
SELECT 
    YEAR(t.from_date) AS calendar_year,
    emp.gender,
    COUNT(emp.emp_no) AS num_of_employees
FROM 
    employees_mod.t_employees AS emp
JOIN 
    employees_mod.t_dept_emp AS t ON emp.emp_no = t.emp_no
GROUP BY 
    calendar_year, emp.gender
HAVING 
    calendar_year >= 1990;

 
-- Task 2: Compare the Number of Male and Female Employees in Departments Over Time
SELECT 
    d.dept_name,
    ee.gender,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active_1
FROM 
    (SELECT YEAR(hire_date) AS calendar_year
     FROM employees_mod.t_employees
     GROUP BY calendar_year) e
CROSS JOIN
    employees_mod.t_dept_manager dm
JOIN  
    employees_mod.t_departments d ON dm.dept_no = d.dept_no
JOIN
    employees_mod.t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY 
    dm.emp_no, calendar_year;



-- Task 3: Compare the Average Salary Between Male and Female Employees
SELECT
    depm.dept_name,
    e.gender,
    YEAR(temp.from_date) AS year_calendar,
    ROUND(AVG(s.salary), 2) AS avg_salary
FROM   
    employees_mod.t_salaries s 
JOIN
    employees_mod.t_employees e ON s.emp_no = e.emp_no  
JOIN
    employees_mod.t_dept_emp temp ON temp.emp_no = e.emp_no
JOIN
    employees_mod.t_departments depm ON temp.dept_no = depm.dept_no
GROUP BY  
    depm.dept_no, e.gender, year_calendar
HAVING 
    year_calendar <= 2002
ORDER BY  
    depm.dept_no;

 
 
 
-- Task 4: Compare the Average Salary Within a Specified Range (50,000 to 90,000)
-- Drop Procedure if Exists
DROP PROCEDURE IF EXISTS filter_salary;


-- Create Procedure
DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
    SELECT 
        e.gender,
        d.dept_name,
        ROUND(AVG(s.salary), 2) AS avg_salary 
    FROM 
        employees_mod.t_salaries s 
    JOIN  
        employees_mod.t_employees e ON s.emp_no = e.emp_no
    JOIN 
        employees_mod.t_dept_emp de ON de.emp_no = e.emp_no
    JOIN 
        employees_mod.t_departments d ON d.dept_no = de.dept_no
    WHERE 
        s.salary BETWEEN p_min_salary AND p_max_salary
    GROUP BY 
        d.dept_no, e.gender;
END$$
DELIMITER ;


-- Call Procedure
CALL filter_salary(50000, 90000);

 
 



