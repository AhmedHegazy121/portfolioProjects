## task 1 breakdowen between m and f 
select 
year(t.from_date)as calender_year,emp.gender,
count(emp.emp_no) as num_of_employee
from 
employees_mod.t_employees as emp
join 
employees_mod.t_dept_emp as t
on emp.emp_no=t.emp_no
group by 
calender_year , emp.gender
having 
 calender_year >=1990;
 
 ##  task 2 comper the number between mala and femala from departments
 select 
 d.dept_name,
 ee.gender,
 dm.from_date,
 dm.to_date,
 e.calendar_year,
 case
 when year(dm.to_date) >= e.calendar_year and year(dm.from_date) <= e.calendar_year then 1
 else 0
 end AS active_1
from 
 (
 select
 year(hire_date) as calendar_year
 from
`employees_mod`.`t_employees`
 group by calendar_year) e
  cross join
  `employees_mod`.`t_dept_manager` dm
  join  
`employees_mod`.`t_departments` d on dm.dept_no = d.dept_no
 join
`employees_mod`.`t_employees` ee on dm.emp_no = ee.emp_no
 order by dm.emp_no , calendar_year; 

select
dep.dept_name,
emp.gender,
man.from_date,
man.to_date,
e.year_calendar,
case
when year(dep.to_date) >= e.year_calendar and year(dep.from_date) <=e.year_calendar then 1
else  0
 end as active

from 
 (select year(hire_date) as year_calendar
from employees_mod.t_employees
group by year_calendar ) e
cross join employees_mod.t_dept_manager  man join
employees_mod.t_departments  dep on
man.dept_no = dep.dept_no
join employees_mod.t_employees emp
on emp.emp_no = man.emp_no
order by  year_calendar , emp.emp_no


 
 ## compare the avg  salary between M and F
select
depm.dept_name,e.gender , year(temp.from_date) as year_calendar ,round(avg(s.salary),2) as salary

from   `employees_mod`.`t_salaries` s 
join
`employees_mod`.`t_employees` e
on s.emp_no =e.emp_no  
join
`employees_mod`.`t_dept_emp`  temp  on temp.emp_no = e.emp_no
join
`employees_mod`.`t_departments` depm  on temp.dept_no=temp.dept_no
group by  depm.dept_no, e.gender, year_calendar
having year_calendar <= 2002
order by  depm.dept_no;

## compare the avg  salary between(50000,90000) 
drop procedure if exists filter_salary;
DELIMITER $$
create procedure filter_salary (in p_min_salary float , in p_max_salary float)
begin
select
 e.gender,d.dept_name,round(avg(s.salary),2) as avg_salary 
 from
 employees_mod.t_salaries  s 
 join  employees_mod.t_employees e on
 s.emp_no =e.emp_no
 join 
 t_dept_emp de  on de.emp_no =e.emp_no
 join 
 employees_mod.t_departments d on d.dept_no=de.dept_no
 group by d.dept_no, e.gender;
 end$$
DELIMITER ;
 call filter_salary(50000,90000);
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 DROP PROCEDURE IF EXISTS filter_salary;
DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
    SELECT e.gender, d.dept_name, AVG(s.salary) AS avg_salary 
    FROM employees_mod.t_salaries s 
    JOIN employees_mod.t_employees e ON s.emp_no = e.emp_no
    JOIN employees_mod.t_dept_emp de ON de.emp_no = e.emp_no
    JOIN employees_mod.t_departments d ON d.dept_no = de.dept_no
    WHERE s.salary BETWEEN p_min_salary AND p_max_salary
    GROUP BY d.dept_no, e.gender;
END$$
DELIMITER ;
CALL filter_salary(50000, 90000);
 
 



