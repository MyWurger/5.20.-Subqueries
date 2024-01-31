-- Задача 1. Найти сотрудников, зарплата которых с учетом комиссионных больше зарплаты их начальников.

select employee_id, first_name, last_name, coa-lesce(salary*(1+commission_pct), salary) as total_salary
from employees
where salary is not null and coa-lesce(salary*(1+commission_pct), salary) > 
(select salary
from employees AS manager
where manager.employee_id = employees.manager_id and manag-er_id is not null)


-- Задача 2. Найти отделы, которые являются единственными в той стране, где они находятся.

select department_id, department_name, l.country_id 
from departments d
join locations l using(location_id)
where country_id in 
(select country_id
from departments d
join locations l using(location_id)
group by country_id
having count(*)= 1
)


-- Задача 3. Вывести значения столбцов departments_id, employee_id, salary со-трудников, у которых оба значения salary и commission_pct совпадают со значе-ниями salary и commission_pct хотя бы одного сотрудника из отдела 30.

select department_id, employee_id, salary, commission_pct
from employees e
where
((salary, commission_pct)  = any
( select salary, commission_pct
  from employees
  where department_id = 30
)
or (commission_pct is null and salary = any 
( select salary
  from employees
  where department_id = 30 and commission_pct is null
)))
and department_id <>30


-- Задача 4. Для каждого сотрудника вывести число месяцев, прошедших между датой приема на работу этого сотрудника и датой приема на работу первого со-трудника в отдел, в котором работает сотрудник

SELECT d.department_id, e.employee_id, e.hire_date, ta-ble_date.max_hire_date, EXTRACT(YEAR FROM AGE(e.hire_date, table_date.max_hire_date))*12 + EXTRACT(MONTH FROM AGE(e.hire_date, table_date.max_hire_date))  AS months_worked
from employees e
join departments d using (department_id) 
join 
(select department_id, min(hire_date) as max_hire_date
 from employees
 where department_id is not null
 group by department_id
) as table_date on e.department_id = table_date.department_id
order by department_id;


-- Задача 5. Определить год и месяц, когда у сотрудника 152 была максимальная сумма продаж.

select year_month, total_sales
from 
(
    select to_char(order_date, 'YYYY-MM') as year_month,
           sum(quantity * unit_price) as total_sales
    from employees e
    join orders o on e.employee_id = o.salesman_id
    join order_items oi using(order_id)
    where e.employee_id = 152
    group by to_char(order_date, 'YYYY-MM')
    order by total_sales desc
) as subquery
LIMIT 1;


-- Задача 6. Для каждого дня продаж, осуществленных в мае 2017, вывести дан-ные о заказе, который имеет максимальную сумму из всех заказов, которые были оформлены в этот день.

select order_date, max(total) AS max_total
from(
select order_date, quantity * unit_price as total
from orders o join order_items oi using(order_id)
where to_char(order_date, 'MM-YYYY') = '05-2017'
group by order_date, quantity * unit_price
) as subquery
group by order_date;


-- Задача 7. В таблице Orders найти продавцов (salesman_id), у которых список клиентов, совпадает со списком клиентов продавца 179. Клиентом является по-купатель (customer_id), которым продавец оформлял заказы.

SELECT salesman_id
FROM Orders
WHERE customer_id in
(
 SELECT customer_id
 FROM Orders
 WHERE salesman_id = 179
) and salesman_id!=179

GROUP BY salesman_id
HAVING COUNT(DISTINCT customer_id) =
(
  SELECT COUNT(DISTINCT customer_id)
  FROM Orders
  WHERE salesman_id = 179
)