use employees;
/* 1. how many active employees per department */
delimiter //
drop procedure if exists activeEmpByDept//
create procedure activeEmpByDept(in dept varchar(30))
begin
	select count(*) from dept_emp de
	inner join departments d on de.dept_no = d.dept_no 
	where de.to_date > now() and d.dept_name = dept;
end
//
delimiter ;

call activeEmpByDept('Customer Service');

/* 2. Show employee first and last name, title, dept, and salary by employee number */
delimiter //
drop procedure if exists empInfo//
create procedure empInfo(in empno int)
begin
	select e.first_name as "First Name", e.last_name as "Last Name", t.title as "Title", 
	d.dept_name as "Dept", s.salary as "Salary" from employees e 
	inner join titles t on e.emp_no = t.emp_no 
	inner join dept_emp de on e.emp_no = de.emp_no
	inner join departments d on de.dept_no = d.dept_no 
	inner join salaries s on e.emp_no = s.emp_no 
	where s.to_date > now() and de.to_date > now() and t.to_date > now()
	and e.emp_no = empno;
end
//
delimiter ;

call empInfo('10758');

/* 3. change an employees title by employee number */
delimiter //
drop procedure if exists chngEmpTitle//
create procedure chngEmpTitle(in empno int, in newTitle varchar(30))
begin
	update titles set title = newTitle where emp_no = empno and to_date > now();
	select emp_no, title from titles  
	where to_date > now() and emp_no = empno;
end
//
delimiter ;

call chngEmptitle(10123, 'Engineer');

/* 4. update the lowest 50 salaries by dept and percentage */
delimiter //
drop procedure if exists annualSalaryUpdate//
create procedure annualSalaryUpdate(in dept varchar(30), in increase dec(3,2))
begin
	declare empno int;
	declare sal dec(8,2);
	declare cur cursor for
	select s.emp_no, s.salary from salaries s 
	inner join dept_emp de on s.emp_no = de.emp_no 
	inner join departments d on de.dept_no = d.dept_no
	where s.to_date > now() and de.to_date > now() and d.dept_name = dept
	order by salary asc
	limit 50;
	declare continue handler
	for not found set empno = 0;
	open cur;
	repeat  
	fetch cur into empno, sal;
	update salaries set salary = salary + (increase * sal)
	where emp_no = empno and to_date > now();
	until empno = 0
	end repeat;
	close cur;
end
//	
delimiter ;

call annualSalaryUpdate('Finance', .05);

/* 5. show current employees for department manager */
delimiter //
drop procedure if exists deptEmployees//
create procedure deptEmployees(in mEmpno int)
begin
	declare deptId varchar(5);
	select d.dept_no into deptID from departments d 
	inner join dept_manager dm on d.dept_no = dm.dept_no 
	where emp_no = mEmpno and dm.to_date > now();
	select e.first_name, e.last_name from employees e 
	inner join dept_emp de on e.emp_no = de.emp_no 
	where de.dept_no = deptID and de.to_date > now();
end
//
delimiter ;

call deptEmployees(110039);
