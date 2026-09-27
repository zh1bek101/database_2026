--Part A: Database and Table Setup
-- 1.
CREATE DATABASE advanced_Lab;


CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50) DEFAULT 'General',
    salary INT,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);


CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INT,
    manager_id INT
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);


-- Part B: Advanced INSERT Operations
-- 2.
-- Исправленный шаг 2
INSERT INTO employees (first_name, last_name, department)
VALUES ('John', 'Doe', 'IT');
-- 3.
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Alice', 'Smith', 'HR', DEFAULT, '2022-03-15', DEFAULT);

-- 4.
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('HR', 80000, 2),
    ('Sales', 120000, 3);

-- 5.
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bob', 'Johnson', 'IT', 50000 * 1.1, CURRENT_DATE);

-- 6.
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE 1=0; -- Создаем структуру временной таблицы

INSERT INTO temp_employees
SELECT * FROM employees
WHERE department = 'IT';


-- Part C: Complex UPDATE Operations
-- 7.
UPDATE employees
SET salary = salary * 1.10;

-- 8.
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- 9.
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

-- 10.
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11.
UPDATE departments d
SET budget = budget + (
    SELECT COALESCE(AVG(salary), 0) * 0.20
    FROM employees e
    WHERE e.department = d.dept_name
);

-- 12.
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


-- Part D: Advanced DELETE Operations

-- 13.
DELETE FROM employees
WHERE status = 'Terminated';

-- 14.
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15.
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

-- 16.
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


-- Part E: Operations with NULL Values

-- 17.
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Charlie', 'Brown', NULL, NULL);

-- 18.
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19.
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;


-- Part F: RETURNING Clause Operations

-- 20.
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('David', 'Miller', 'IT', 65000, '2021-06-01')
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

-- 21.
WITH old_data AS (
    SELECT emp_id, salary AS old_salary
    FROM employees
    WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
FROM old_data o
WHERE e.emp_id = o.emp_id
RETURNING e.emp_id, o.old_salary, e.salary AS new_salary;

-- 22.
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- Part G: Advanced DML Patterns

-- 23.
INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Emma', 'Watson', 'HR', 55000
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'Emma' AND last_name = 'Watson'
);

-- 24.
UPDATE employees
SET salary = salary * CASE
    WHEN (SELECT budget FROM departments WHERE dept_name = employees.department LIMIT 1) > 100000 THEN 1.10
    ELSE 1.05
END;

-- 25.
INSERT INTO employees (first_name, last_name, department, salary)
VALUES
    ('User1', 'Test', 'IT', 40000),
    ('User2', 'Test', 'IT', 42000),
    ('User3', 'Test', 'HR', 38000),
    ('User4', 'Test', 'Sales', 45000),
    ('User5', 'Test', 'Sales', 47000);


UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Test';

-- 26.
CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);

WITH moved_rows AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved_rows;

-- 27.
UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND dept_id IN (
      SELECT d.dept_id
      FROM departments d
      JOIN employees e ON d.dept_name = e.department
      GROUP BY d.dept_id
      HAVING COUNT(e.emp_id) > 3
  );