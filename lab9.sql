-- Laboratory Work 9: Stored Procedures and User-Defined Functions (PostgreSQL)
-- Database: CityBike

-- PART 1: Database Setup


DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

CREATE TABLE bikes (
    bike_id      INT PRIMARY KEY,
    model        VARCHAR(50) NOT NULL,
    station_id   INT REFERENCES stations(station_id),
    daily_rate   NUMERIC(8,2) NOT NULL
);

CREATE TABLE members (
    member_id    INT PRIMARY KEY,
    full_name    VARCHAR(60) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    joined_on    DATE NOT NULL
);

CREATE TABLE rentals (
    rental_id    INT PRIMARY KEY,
    member_id    INT REFERENCES members(member_id),
    bike_id      INT REFERENCES bikes(bike_id),
    start_date   DATE NOT NULL,
    end_date     DATE,
    fee          NUMERIC(8,2)
);

INSERT INTO stations VALUES
    (10, 'Central Park', 'Almaty',   4),
    (20, 'Riverside',    'Almaty',   3),
    (30, 'Expo Gate',    'Astana',   5),
    (40, 'Old Town',     'Shymkent', 2),
    (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
    (101, 'City Cruiser', 10, 4.50),
    (102, 'City Cruiser', 10, 4.50),
    (103, 'Mountain X',   20, 7.00),
    (104, 'Mountain X',   30, 7.00),
    (105, 'Road Sprint',  30, 9.25),
    (106, 'Folding Mini', 40, 3.75),
    (107, 'Cargo Hauler', 20, 12.00),
    (108, 'Road Sprint',  10, 9.25);

INSERT INTO members VALUES
    (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
    (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
    (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
    (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
    (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
    (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
    (1,  1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
    (2,  1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
    (3,  1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
    (4,  1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
    (5,  2, 101, DATE '2024-05-01', DATE '2024-05-02', 4.50),
    (6,  2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
    (7,  2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
    (8,  3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
    (9,  3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
    (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10', 7.00),
    (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
    (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
    (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
    (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
    (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
    (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20', 7.50),
    (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
    (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
    (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
    (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
    (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
    (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);

-- Verify the setup (Expected: 5 stations, 8 bikes, 6 members, 22 rentals)
SELECT (SELECT COUNT(*) FROM stations) AS stations,
       (SELECT COUNT(*) FROM bikes)    AS bikes,
       (SELECT COUNT(*) FROM members)  AS members,
       (SELECT COUNT(*) FROM rentals)  AS rentals;



-- PART 2: Your First Function


-- ----------------------------------------------------------------------------
-- Exercise 2.1: A function over one row
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT end_date - start_date
    INTO v_days
    FROM rentals
    WHERE rental_id = p_rental_id;

    RETURN v_days;
END;
$$ LANGUAGE plpgsql;

SELECT rental_days(2);   -- 5
SELECT rental_days(11);  -- 8
SELECT rental_days(19);  -- NULL
SELECT rental_days(999); -- NULL

/*
Question 2.1:
What does your function return for rental 19, and what does it return for rental 999?
Are the two NULLs produced for the same reason?

Answer 2.1:
Both calls return NULL, but for different reasons:
- For rental 19, the row exists in the rentals table, but end_date is NULL (the rental is still open), so (NULL - start_date) evaluates to NULL.
- For rental 999, no matching row exists in the table; SELECT ... INTO finds 0 rows and leaves v_days at its default NULL value.
*/


-- ----------------------------------------------------------------------------
-- Exercise 2.2: A function over many rows
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE
    v_cnt INT;
BEGIN
    SELECT COUNT(*)::INT
    INTO v_cnt
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_cnt;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1);  -- 5
SELECT member_rental_count(5);  -- 3
SELECT member_rental_count(6);  -- 0
SELECT member_rental_count(99); -- 0

/*
Question 2.2:
Member 6 and member 99 both give the same answer. Explain why COUNT(*) returns 0
rather than NULL for a member who does not exist.

Answer 2.2:
COUNT(*) counts the number of rows matching the WHERE condition rather than aggregating a column value.
When no rows match (whether the member exists with 0 rentals like member 6, or does not exist at all like member 99),
the matching row set is empty, and the cardinality of an empty set is 0 (unlike SUM, AVG, or MAX which return NULL).
*/


-- ----------------------------------------------------------------------------
-- Exercise 2.3: Returning text
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_city VARCHAR;
BEGIN
    SELECT city
    INTO v_city
    FROM stations
    WHERE station_id = p_station_id;

    RETURN v_city;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30); -- 'Astana'
SELECT station_city(77); -- NULL


-- ----------------------------------------------------------------------------
-- Exercise 2.4: Using a function inside a query
-- ----------------------------------------------------------------------------
SELECT rental_id,
       member_id,
       rental_days(rental_id) AS duration_days
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration_days DESC;



-- PART 3: Parameter Modes


-- ----------------------------------------------------------------------------
-- Exercise 3.1: IN parameters
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100.0), 2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15); -- 62.90


-- ----------------------------------------------------------------------------
-- Exercise 3.2: OUT parameters
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
) AS $$
BEGIN
    SELECT COUNT(*)::INT,
           COALESCE(SUM(fee), 0),
           MAX(start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals
    WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);

/*
Question 3.2:
How does the output of the two calls differ? Which form would you use inside a larger query, and why?
What do you get for member 6?

Answer 3.2:
- SELECT member_stats(3) returns a single composite (record) column packed in parentheses: (5,164.75,2025-06-01).
- SELECT * FROM member_stats(3) expands the OUT parameters into three separate named columns: rental_cnt=5, total_fee=164.75, last_start=2025-06-01.
- Inside a larger query, use the FROM form (e.g. via LATERAL) because each output field can be referenced directly by its column name without tuple unpacking.
- For member 6 (Elena Petrova, who has no rentals): rental_cnt = 0, total_fee = 0, last_start = NULL.
*/


-- ----------------------------------------------------------------------------
-- Exercise 3.3: INOUT parameters
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC) AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee)
FROM rentals
WHERE rental_id = 1; -- 18.50

/*
Question 3.3:
The function has no RETURNS clause and no RETURN statement. Why does it still produce a value?

Answer 3.3:
In PostgreSQL, declaring at least one OUT or INOUT parameter implicitly defines the function's return type.
When a PL/pgSQL block reaches END, it automatically returns the final values of all OUT and INOUT variables without needing an explicit RETURN statement or RETURNS clause.
*/


-- ----------------------------------------------------------------------------
-- Exercise 3.4: VARIADIC parameters
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
) AS $$
BEGIN
    SELECT SUM(p_fees[i]),
           ROUND(AVG(p_fees[i]), 2),
           MAX(p_fees[i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
SELECT * FROM fee_summary();

/*
Question 3.4:
What happens if you call fee_summary() with no arguments at all?
Why must a VARIADIC parameter be the last one in the list?

Answer 3.4:
- Calling fee_summary() with no arguments passes an empty array; generate_subscripts produces 0 rows, so total, average, and largest all return NULL.
- A VARIADIC parameter consumes all remaining positional arguments into an array. If another parameter followed it, PostgreSQL could not unambiguously determine where the variadic argument list ends and subsequent parameters begin.
*/


-- ----------------------------------------------------------------------------
-- Exercise 3.5: Choosing a mode
-- ----------------------------------------------------------------------------
/*
Question 3.5:
State which parameter mode you would use and write one sentence of justification:
(a) the id of the row to look up -> IN: The value is only read by the function to filter rows and does not need to be modified or returned.
(b) a running balance that the caller passes in and expects back updated -> INOUT: The caller supplies an initial value that the function updates in place and returns back.
(c) a list of station ids of unknown length -> VARIADIC: It accepts any number of trailing arguments of the same type and collects them into an array automatically.
(d) two statistics returned together from one pass over a table -> OUT: Using two OUT parameters lets the function return both computed values as separate columns from a single query.
*/



-- PART 4: Default Values and Function Overloading


-- ----------------------------------------------------------------------------
-- Exercise 4.1: A function with one parameter
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1); -- 98.50
SELECT total_fees(6); -- 0


-- ----------------------------------------------------------------------------
-- Exercise 4.2: Overloading the name
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01'); -- 98.50
SELECT total_fees(1, DATE '2025-01-01'); -- 50.00


-- ----------------------------------------------------------------------------
-- Exercise 4.3: Giving a parameter a default value
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Run manually to see the error (commented out so the full script runs cleanly):
-- SELECT total_fees(1);

/*
Question 4.3:
Exact error message & hint:
ERROR:  function total_fees(integer) is not unique
LINE 1: SELECT total_fees(1);
               ^
HINT:  Could not choose a best candidate function. You might need to add explicit type casts.

Explanation:
Two overloaded functions now match a single INTEGER argument: total_fees(INT) and total_fees(INT, DATE DEFAULT '2025-01-01').
Because both candidates accept a single integer with equal type-matching priority, PostgreSQL cannot decide which one to invoke.
*/


-- ----------------------------------------------------------------------------
-- Exercise 4.4: Resolving the ambiguity
-- ----------------------------------------------------------------------------
DROP FUNCTION total_fees(INTEGER);
SELECT total_fees(1); -- 50.00

/*
Question 4.4:
Which of the two functions answers the call now, and what value does it return?
Would dropping the other version have given the same answer?

Answer 4.4:
- The two-parameter version total_fees(INT, DATE DEFAULT '2025-01-01') now answers the call using its default cut-off date, returning 50.00 (18.50 + 31.50).
- No, dropping the two-parameter version instead would have left total_fees(INT), which sums all rentals regardless of date and would have returned 98.50.
*/


-- ----------------------------------------------------------------------------
-- Exercise 4.5: Overloading on type, not just on count
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION total_fees(p_full_name VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO v_total
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    WHERE m.full_name = p_full_name;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova'); -- 98.50
SELECT total_fees(1);                  -- 50.00

/*
Question 4.5:
Adding this version does not reintroduce the error of Exercise 4.3 - why not?
The two calls above refer to the same member but return different numbers: explain exactly which function each call reaches and what makes the results differ.

Answer 4.5:
- Adding total_fees(VARCHAR) does not cause ambiguity because its first argument type (VARCHAR) is distinct from INTEGER; PostgreSQL resolves the overload unambiguously by argument data type.
- SELECT total_fees('Aisha Nurlanova') calls total_fees(VARCHAR), which sums all fees for Aisha across all dates (98.50).
- SELECT total_fees(1) calls total_fees(INT, DATE DEFAULT '2025-01-01'), which filters by start_date >= '2025-01-01' and returns 50.00.
*/



-- PART 5: Functions That Return a Table


-- ----------------------------------------------------------------------------
-- Exercise 5.1: Search by pattern
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model, b.daily_rate
    FROM bikes b
    WHERE b.model ILIKE p_pattern
    ORDER BY b.bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');

/*
Question 5.1:
Now run SELECT find_bikes('%road%'); without the FROM. How does the shape of the result change, and why?

Answer 5.1:
Instead of returning a 3-column table (found_id, found_model, found_rate), calling the function in the SELECT target list invokes it in a scalar/expression context, collapsing all three fields of each row into a single composite record column: (105,"Road Sprint",9.25) and (108,"Road Sprint",9.25).
*/


-- ----------------------------------------------------------------------------
-- Exercise 5.2: A table from a join
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE (
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration_days INT,
    fee NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id,
           b.model,
           s.station_name,
           (r.end_date - r.start_date) AS duration_days,
           r.fee
    FROM rentals r
    JOIN bikes b ON r.bike_id = b.bike_id
    JOIN stations s ON b.station_id = s.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);


-- ----------------------------------------------------------------------------
-- Exercise 5.3: When the column names collide
-- ----------------------------------------------------------------------------
-- Broken version (commented out so the script runs cleanly):
/*
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);
*/

/*
Question 5.3:
The CREATE succeeds but the call fails. Why does the error appear only at call time?
Exact error message:
ERROR:  column reference "bike_id" is ambiguous
LINE 1: SELECT bike_id, model FROM bikes WHERE station_id = p_statio...
               ^
DETAIL:  It could refer to either a PL/pgSQL variable or a table column.

Explanation:
CREATE FUNCTION only checks basic PL/pgSQL syntax; SQL statements inside the body are parsed and planned lazily on the first execution (call time). At runtime, bike_id refers both to the implicit OUT variable declared in RETURNS TABLE and to the column in bikes.
*/

-- Fix 1: Renaming the output columns
CREATE OR REPLACE FUNCTION bike_list_renamed(p_station_id INT)
RETURNS TABLE (out_bike_id INT, out_model VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model
    FROM bikes
    WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list_renamed(10);

-- Fix 2: Keeping the output names and qualifying the table columns with an alias
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model
    FROM bikes b
    WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);


-- ----------------------------------------------------------------------------
-- Exercise 5.4: Casting the output
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name,
           COUNT(b.bike_id)::INT AS s_bikes,
           (s.capacity - COUNT(b.bike_id))::INT AS s_free
    FROM stations s
    LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');

/*
Question 5.4:
The aggregate COUNT(*) produces a BIGINT. What happens if you declare the column as INT and do not cast it? Show the message you get.

Answer 5.4:
Without ::INT, PostgreSQL raises a return-type mismatch error at call time because PL/pgSQL strictly requires RETURN QUERY columns to match the declared RETURNS TABLE types:
ERROR:  structure of query does not match function result type
DETAIL:  Returned type bigint does not match expected type integer in column 2.
*/



-- PART 6: Block Structure, DO Blocks and Subblocks

-- ----------------------------------------------------------------------------
-- Exercise 6.1: An anonymous block
-- ----------------------------------------------------------------------------
DO $$
<<rental_report>>
DECLARE
    total_rentals INTEGER := 0;
BEGIN
    SELECT COUNT(*)::INT
    INTO total_rentals
    FROM rentals;

    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report $$;

/*
Question 6.1:
What happens if the label after END does not match the one at the top?

Answer 6.1:
PostgreSQL immediately rejects the block with a syntax error during compilation:
ERROR:  end label "..." does not match block's start label "rental_report"
*/


-- ----------------------------------------------------------------------------
-- Exercise 6.2: A subblock and a hidden variable
-- ----------------------------------------------------------------------------
DO $$
<<outer_block>>
DECLARE
    total_rentals INTEGER := 0;
    fee_total     NUMERIC;
BEGIN
    SELECT COUNT(*)::INT, COALESCE(SUM(fee), 0)
    INTO total_rentals, fee_total
    FROM rentals;

    RAISE NOTICE '1. Outer fee_total before subblock: %', fee_total;

    <<sub_block>>
    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(fee), 0)
        INTO fee_total
        FROM rentals
        WHERE start_date >= DATE '2025-01-01';

        RAISE NOTICE '2. Subblock fee_total (>= 2025-01-01): %', fee_total;
        RAISE NOTICE '3. Outer fee_total from inside subblock: %', outer_block.fee_total;
    END sub_block;

    RAISE NOTICE '4. Outer fee_total after subblock: %', fee_total;
END outer_block $$;

/*
Question 6.2:
Write down the four numbers your block prints. Did the assignment inside the subblock change the outer variable? What does that tell you about the scope of a declaration?

Answer 6.2:
- Printed values:
  1) 608.75 (outer fee_total before subblock)
  2) 335.25 (subblock fee_total for start_date >= 2025-01-01)
  3) 608.75 (outer_block.fee_total accessed from inside subblock)
  4) 608.75 (outer fee_total after subblock)
- No, assigning to fee_total inside the subblock did NOT alter the outer variable. Declaring a variable with the same name in a subblock creates a distinct local variable whose scope is limited to that subblock, temporarily shadowing the outer variable without modifying it.
*/


-- ----------------------------------------------------------------------------
-- Exercise 6.3: Declarations are local
-- ----------------------------------------------------------------------------
-- Failing version showing local scope error (commented out):
/*
DO $$
BEGIN
    <<first_sub>>
    DECLARE
        local_msg TEXT := 'Hello from first subblock';
    BEGIN
        RAISE NOTICE '%', local_msg;
    END first_sub;

    <<second_sub>>
    BEGIN
        RAISE NOTICE '%', local_msg; -- ERROR: column "local_msg" does not exist
    END second_sub;
END $$;
*/

-- Fixed version: declaration moved up to the outer block
DO $$
DECLARE
    shared_msg TEXT := 'Hello from outer block';
BEGIN
    <<first_sub>>
    BEGIN
        RAISE NOTICE 'First subblock sees: %', shared_msg;
    END first_sub;

    <<second_sub>>
    BEGIN
        RAISE NOTICE 'Second subblock sees: %', shared_msg;
    END second_sub;
END $$;

/*
Question 6.3:
Error recorded when second subblock reads first subblock's variable:
ERROR:  column "local_msg" does not exist
Moving the declaration to the outer block makes it visible to all nested subblocks.
*/


-- ----------------------------------------------------------------------------
-- Exercise 6.4: From a block to a function
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(fee) FILTER (WHERE start_date < p_from_date), 0),
           COALESCE(SUM(fee) FILTER (WHERE start_date >= p_from_date), 0)
    INTO before_total, after_total
    FROM rentals;
END;
$$ LANGUAGE plpgsql;

SELECT *,
       (before_total + after_total) AS combined_total,
       (SELECT SUM(fee) FROM rentals) AS table_total
FROM fee_split(DATE '2025-01-01'); -- before_total = 273.50, after_total = 335.25, sum = 608.75



-- PART 7: Practical Scenarios


-- ----------------------------------------------------------------------------
-- Exercise 7.1: Station occupancy
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
) AS $$
DECLARE
    v_capacity INT;
BEGIN
    SELECT s.capacity, COUNT(b.bike_id)::INT
    INTO v_capacity, bikes_parked
    FROM stations s
    LEFT JOIN bikes b ON b.station_id = s.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.station_id, s.capacity;

    IF v_capacity IS NULL OR v_capacity = 0 THEN
        capacity_pct := NULL;
    ELSE
        capacity_pct := ROUND((bikes_parked::NUMERIC / v_capacity) * 100, 1);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s, LATERAL station_load(s.station_id) l;

/*
Question 7.1:
Station 50 has a capacity of zero, so your function must not raise a division-by-zero error - decide what it should return instead and justify the choice.

Answer 7.1:
For station 50 (Depot, capacity = 0), capacity_pct returns NULL. Division by zero is undefined, and returning 0.0 would falsely imply that the station has free parking capacity; NULL accurately represents that occupancy percentage is not applicable to a zero-capacity depot.
*/


-- ----------------------------------------------------------------------------
-- Exercise 7.2: Top members, with a default
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE (
    member_name VARCHAR,
    rental_count INT,
    total_spent NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,
           COUNT(r.rental_id)::INT AS rental_count,
           COALESCE(SUM(r.fee), 0) AS total_spent
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY total_spent DESC, m.member_id ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);

/*
Question 7.2:
One member has more rentals than the member ranked above them, yet is ranked lower. Which member, and why is that not a bug?

Answer 7.2:
Aisha Nurlanova has 5 rentals (more than Chen Wei and Daniyar Serik, who each have 4 rentals), yet she is ranked 4th (98.50) below Chen Wei (139.25) and Daniyar Serik (138.00).
This is not a bug because the ranking is ordered by total_spent DESC rather than rental_count (and Aisha's 5th rental is still open with fee = NULL, while her other rentals used lower-rate bikes).
*/


-- ----------------------------------------------------------------------------
-- Exercise 7.3: An invoice for an open rental
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (
    member_name VARCHAR,
    bike_model VARCHAR,
    days INT,
    amount_owed NUMERIC,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,
           b.model,
           (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT AS days,
           ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date) * b.daily_rate, 2) AS amount_owed,
           (CASE WHEN r.end_date IS NULL THEN 'OPEN' ELSE 'CLOSED' END)::VARCHAR AS status
    FROM rentals r
    JOIN members m ON m.member_id = r.member_id
    JOIN bikes b ON b.bike_id = r.bike_id
    WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);

/*
Question 7.3:
For rental 11 the amount you calculate should equal the fee stored in the table. Does it?
For rental 19 the amount is different every day the lab is run - explain why, and say whether a function that depends on CURRENT_DATE can be called immutable.

Answer 7.3:
- Yes, for rental 11 the calculated amount_owed is 74.00 (8 days * 9.25), matching the stored fee.
- Rental 19 has end_date IS NULL, so its duration is computed as (CURRENT_DATE - start_date), which grows by 1 day (and +4.50 in amount_owed) each calendar day.
- A function depending on CURRENT_DATE CANNOT be declared IMMUTABLE because it returns different results on different days for the exact same input argument; its proper volatility category is STABLE.
*/


-- ----------------------------------------------------------------------------
-- Exercise 7.4: A report per city
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE (
    member_count INT,
    rental_count INT,
    total_revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON r.member_id = m.member_id
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE (
    member_count INT,
    rental_count INT,
    total_revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r
        ON r.member_id = m.member_id
       AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', DATE '2025-01-01');

/*
Question 7.4:
Both versions need a LEFT JOIN. In the two-parameter version, does the date condition belong in the ON clause or in the WHERE clause? Try both and report the difference in the member count for Almaty.

Answer 7.4:
- The date condition belongs in the ON clause.
- Placing r.start_date >= p_from_date in the WHERE clause filters out rows where r.start_date IS NULL, turning the LEFT JOIN into an INNER JOIN and dropping members with no qualifying rentals.
- For Almaty, placing the condition in ON yields member_count = 3 (Aisha, Daniyar, Elena), whereas placing it in WHERE drops Elena Petrova and yields member_count = 2.
*/


-- ============================================================================
-- LAB QUESTIONS (1 - 10)
-- ============================================================================
/*
1. Difference between a function's name and its signature, and why DROP FUNCTION needs the signature:
   A function's name is just its identifier (e.g., total_fees), whereas its signature is the unique combination of its name and input argument types (e.g., total_fees(integer, date)). Because PostgreSQL supports function overloading (multiple functions sharing the same name), the full signature is required so PostgreSQL knows unambiguously which overloaded version to drop.

2. Purpose of dollar quoting ($$) and an example that would be awkward without it:
   Dollar quoting delimits the function body without needing to escape or double single quotes inside SQL strings.
   Example:
   CREATE FUNCTION quote_demo(p_user TEXT) RETURNS TEXT AS $$
   BEGIN
       RETURN 'User ''' || p_user || ''' says: ''It''s working!''';
   END;
   $$ LANGUAGE plpgsql;
   Without $$, every single quote inside the string literal would have to be doubled, making the code hard to read and error-prone.

3. When to choose several OUT parameters vs. RETURNS TABLE:
   Choose multiple OUT parameters when a function returns a single row (one composite tuple of values, such as summary statistics for one entity). Choose RETURNS TABLE when a function returns a set of zero, one, or many rows via RETURN QUERY or RETURN NEXT.

4. Why a VARIADIC parameter must be last (with an example):
   A VARIADIC parameter collects an arbitrary number of trailing arguments into an array. If another parameter of the same type followed it—for example, func(VARIADIC a INT[], b INT DEFAULT 0)—a call like func(1, 2, 3) would be impossible to resolve because PostgreSQL could not tell whether 3 belongs to array a or to parameter b.

5. Difference between RETURN and RETURN QUERY:
   RETURN <expr> terminates the function immediately and returns a single scalar or composite value. RETURN QUERY <SELECT ...> appends all rows produced by a query to the result set of a set-returning function without ending execution immediately.

6. Why a function with a DEFAULT parameter can break an existing unambiguous call, and how to avoid it in production:
   If foo(INT) already exists and you create an overloaded foo(INT, DATE DEFAULT CURRENT_DATE), an existing call foo(10) becomes ambiguous because both candidates match a single integer argument. In production, avoid overloading with defaults on top of an existing shorter signature—either update the existing function via CREATE OR REPLACE (if compatible), drop the old signature in the same migration, or use a distinct function name.

7. What happens to a variable declared in a subblock when the subblock ends, and how to read a shadowed outer variable:
   When a subblock reaches END, all variables declared in that subblock are destroyed and deallocated, restoring visibility of any outer variable with the same name. To read a shadowed outer variable from inside the subblock, label the outer block (<<outer_label>>) and qualify the variable as outer_label.variable_name.

8. One advantage and one disadvantage of moving a business rule into a stored function:
   - Advantage: Better performance (fewer network round trips because logic executes inside the DB server) and centralized consistency across all client applications.
   - Disadvantage: Harder version control/testing, vendor lock-in to PostgreSQL's PL/pgSQL dialect, and increased CPU load on the database server (which is hardest to scale out).

9. Trusted vs. untrusted procedural languages in practice, and who can create functions in each:
   A trusted language (such as PL/pgSQL) is sandboxed inside the database and cannot access the server's file system, network, or OS; any regular database user with USAGE privilege on the language can create functions in it. An untrusted language (such as PL/Python or C) can access OS files, network sockets, and external binaries, so only a database superuser is permitted to create functions in it.

10. What happens when a colleague runs CREATE OR REPLACE FUNCTION with changed argument types:
    CREATE OR REPLACE only replaces an existing function if both its name and input argument types match exactly. Changing the argument types creates a brand-new overloaded function alongside the old one rather than replacing it, leaving two versions in the database that can cause call ambiguity or allow callers to invoke stale logic.
*/