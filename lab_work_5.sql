-- Student Name: Zhilikbai Zhibek
-- Student ID: 	25B031267


-- Task 1.1: Basic CHECK Constraint
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2: Named CHECK Constraint
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
    )
);

-- Task 1.3: Multiple Column CHECK
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT valid_dates CHECK (check_out_date > check_in_date)
);

-- Task 1.4: Testing CHECK Constraints
-- 1. Successful Inserts
INSERT INTO employees VALUES (1, 'Alice', 'Smith', 30, 50000.00);
INSERT INTO employees VALUES (2, 'Bob', 'Jones', 45, 75000.50);

INSERT INTO products_catalog VALUES (101, 'Laptop', 1200.00, 999.99);
INSERT INTO products_catalog VALUES (102, 'Headphones', 150.00, 120.00);

INSERT INTO bookings VALUES (1001, '2026-06-01', '2026-06-07', 2);
INSERT INTO bookings VALUES (1002, '2026-07-10', '2026-07-15', 4);

/*
-- 2 & 3. Failed Inserts

-- Violation 1: age out of range (< 18)
INSERT INTO employees VALUES (3, 'Charlie', 'Brown', 16, 40000.00);
-- Violation Reason: Fails 'age BETWEEN 18 AND 65' check constraint.

-- Violation 2: negative/zero salary
INSERT INTO employees VALUES (4, 'Diana', 'Prince', 35, 0.00);
-- Violation Reason: Fails 'salary > 0' check constraint.

-- Violation 3: discount_price greater than regular_price
INSERT INTO products_catalog VALUES (103, 'Phone', 800.00, 900.00);
-- Violation Reason: Fails 'valid_discount' constraint (discount must be less than regular price).

-- Violation 4: check_out_date before check_in_date
INSERT INTO bookings VALUES (1003, '2026-08-10', '2026-08-05', 3);
-- Violation Reason: Fails 'valid_dates' constraint (check_out_date must be > check_in_date).

-- Violation 5: num_guests exceeding limit (> 10)
INSERT INTO bookings VALUES (1004, '2026-09-01', '2026-09-05', 15);
-- Violation Reason: Fails 'num_guests BETWEEN 1 AND 10' check constraint.
*/



-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT, -- can be NULL
    registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL
-- 1. Successful inserts (complete records, and records with NULL in nullable columns)
INSERT INTO customers VALUES (1, 'john@example.com', '555-0192', '2026-01-15');
INSERT INTO customers VALUES (2, 'jane@example.com', NULL, '2026-02-20'); -- phone is NULL (allowed)

INSERT INTO inventory VALUES (1, 'Office Chair', 50, 129.99, CURRENT_TIMESTAMP);
INSERT INTO inventory VALUES (2, 'Desk Lamp', 150, 24.50, CURRENT_TIMESTAMP);

/*
-- 2. Failed inserts with NULL in NOT NULL columns
INSERT INTO customers VALUES (3, NULL, '555-9876', '2026-03-01');
-- Violation Reason: email column is constrained to NOT NULL.

INSERT INTO inventory VALUES (3, NULL, 10, 45.00, CURRENT_TIMESTAMP);
-- Violation Reason: item_name column is constrained to NOT NULL.
*/



-- Task 3.1 & 3.3: Users Table with Named UNIQUE Constraints
CREATE TABLE users (
    user_id INTEGER,
    username TEXT CONSTRAINT unique_username UNIQUE,
    email TEXT CONSTRAINT unique_email UNIQUE,
    created_at TIMESTAMP
);

-- Task 3.2: Multi-Column UNIQUE Constraint
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_course_sem UNIQUE (student_id, course_code, semester)
);

-- Testing UNIQUE constraints
INSERT INTO users VALUES (1, 'johndoe', 'john@mail.com', CURRENT_TIMESTAMP);
INSERT INTO users VALUES (2, 'janedoe', 'jane@mail.com', CURRENT_TIMESTAMP);

INSERT INTO course_enrollments VALUES (1, 101, 'CS101', 'Fall2026');
INSERT INTO course_enrollments VALUES (2, 101, 'CS101', 'Spring2027'); -- Allowed (different semester)
INSERT INTO course_enrollments VALUES (3, 101, 'MATH201', 'Fall2026'); -- Allowed (different course)

/*
-- Failed UNIQUE inserts
INSERT INTO users VALUES (3, 'johndoe', 'new@mail.com');
-- Violation Reason: Duplicate username 'johndoe' violates unique_username constraint.

INSERT INTO course_enrollments VALUES (4, 101, 'CS101', 'Fall2026');
-- Violation Reason: Duplicate combination of (student_id, course_code, semester) violates unique_student_course_sem.
*/



-- Task 4.1: Single Column Primary Key
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (10, 'HR', 'Building A');
INSERT INTO departments VALUES (20, 'Engineering', 'Building B');
INSERT INTO departments VALUES (30, 'Sales', 'Building C');

/*
-- Failed Primary Key inserts
INSERT INTO departments VALUES (10, 'Marketing', 'Building D');
-- Violation Reason: Duplicate dept_id (10) violates PRIMARY KEY uniqueness.

INSERT INTO departments VALUES (NULL, 'Support', 'Building E');
-- Violation Reason: NULL value in dept_id violates PRIMARY KEY (which implies NOT NULL).
*/

-- Task 4.2: Composite Primary Key
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- Task 4.3: Comparison Exercise
/*
EXPLANATION NOTES:
1. Difference between UNIQUE and PRIMARY KEY:
   - A PRIMARY KEY uniquely identifies each row in a table, implicitly enforces NOT NULL, and only one PK is allowed per table.
   - A UNIQUE constraint ensures all values in a column (or group of columns) are distinct, but it allows NULL values (in standard SQL, multiple NULLs are typically permitted depending on the engine). A table can have multiple UNIQUE constraints.
2. When to use single-column vs. composite PRIMARY KEY:
   - Use a single-column PK (like an ID integer or UUID) when dealing with standard entities (e.g., users, products) where natural keys are complex or prone to change.
   - Use a composite PK for junction/association tables representing many-to-many relationships (e.g., student_courses) where uniqueness depends on the combination of two or more foreign keys.
3. Why a table has only one PRIMARY KEY:
   - The primary key defines the table's fundamental entity identity and primary clustering/indexing mechanism. Secondary unique business keys are handled via multiple UNIQUE constraints.
*/



-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Mark Taylor', 10, '2024-05-10');
INSERT INTO employees_dept VALUES (2, 'Sarah Connor', 20, '2025-01-15');

/*
-- Failed Foreign Key Insert
INSERT INTO employees_dept VALUES (3, 'John Doe', 99, '2026-02-01');
-- Violation Reason: dept_id 99 does not exist in the referenced departments table.
*/

-- Task 5.2: Multiple Foreign Keys (Library System)
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

-- Sample Data Inserts for Library System
INSERT INTO authors VALUES (1, 'J.K. Rowling', 'UK');
INSERT INTO authors VALUES (2, 'George Orwell', 'UK');

INSERT INTO publishers VALUES (1, 'Bloomsbury', 'London');
INSERT INTO publishers VALUES (2, 'Penguin Books', 'London');

INSERT INTO books VALUES (1, 'Harry Potter', 1, 1, 1997, '978-0747532699');
INSERT INTO books VALUES (2, '1984', 2, 2, 1949, '978-0451524935');

-- Task 5.3: ON DELETE Options Schema
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

-- Sample data for ON DELETE test
INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO products_fk VALUES (101, 'Smartphone', 1);

INSERT INTO orders VALUES (5001, '2026-10-01');
INSERT INTO order_items VALUES (1, 5001, 101, 2);

/*
-- Test Scenarios Documentation:
1. Try to delete a category that has products (RESTRICT):
   DELETE FROM categories WHERE category_id = 1;
   -- Result: Fails with foreign key violation because ON DELETE RESTRICT blocks deletion while child products exist.

2. Delete an order (CASCADE):
   DELETE FROM orders WHERE order_id = 5001;
   -- Result: Succeeds. Because of ON DELETE CASCADE, corresponding rows in order_items referencing order 5001 are automatically deleted.
*/



-- PART 6: Practical Application: E-commerce Database Design

CREATE TABLE ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecommerce_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES ecommerce_customers(customer_id) ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE ecommerce_order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES ecommerce_products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- 5 Sample Records per Table
INSERT INTO ecommerce_customers VALUES
(1, 'Emma Watson', 'emma@example.com', '555-0101', '2026-01-10'),
(2, 'Liam Neeson', 'liam@example.com', '555-0202', '2026-01-15'),
(3, 'Sophia Loren', 'sophia@example.com', '555-0303', '2026-02-01'),
(4, 'Noah Centineo', 'noah@example.com', '555-0404', '2026-02-20'),
(5, 'Olivia Wilde', 'olivia@example.com', '555-0505', '2026-03-05');

INSERT INTO ecommerce_products VALUES
(10, 'Wireless Mouse', 'Ergonomic optical mouse', 25.99, 150),
(20, 'Mechanical Keyboard', 'RGB backlit gaming keyboard', 89.99, 75),
(30, 'UltraWide Monitor', '34-inch curved display', 399.99, 30),
(40, 'USB-C Hub', '7-in-1 multiports adapter', 45.00, 200),
(50, 'Gaming Headset', 'Surround sound audio gear', 59.99, 100);

INSERT INTO ecommerce_orders VALUES
(1001, 1, '2026-03-10', 115.98, 'delivered'),
(1002, 2, '2026-03-12', 399.99, 'shipped'),
(1003, 3, '2026-03-14', 104.99, 'processing'),
(1004, 4, '2026-03-15', 25.99, 'pending'),
(1005, 5, '2026-03-18', 59.99, 'cancelled');

INSERT INTO ecommerce_order_details VALUES
(1, 1001, 10, 2, 25.99),
(2, 1001, 40, 1, 45.00),
(3, 1002, 30, 1, 399.99),
(4, 1003, 20, 1, 89.99),
(5, 1004, 10, 1, 25.99);

/*
-- Test queries confirming constraint operations:
SELECT c.name, o.order_id, o.status, o.total_amount
FROM ecommerce_customers c
JOIN ecommerce_orders o ON c.customer_id = o.customer_id;
*/