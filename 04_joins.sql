-- Lesson 04: INNER JOIN, LEFT JOIN, NULL and counting matched payments.
-- Synthetic learning data. Reviewed solutions; setup prepared with AI assistance.
-- Run once in a fresh database, or after lessons 01-03.
-- All amounts are non-NULL and use one common arbitrary currency.

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT NOT NULL
);
CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    amount INTEGER NOT NULL,
    status TEXT NOT NULL
);
INSERT INTO customers (customer_id, customer_name, city) VALUES
    (1, 'Anna', 'Prague'),
    (2, 'Timur', 'Tashkent'),
    (3, 'Petr', 'Brno'),
    (4, 'Elena', 'Prague'),
    (5, 'Martin', 'Brno');
INSERT INTO payments (payment_id, customer_id, amount, status) VALUES
    (101, 1, 1200, 'completed'),
    (102, 2, 3200, 'completed'),
    (103, 1, 600, 'pending'),
    (104, 3, 900, 'completed'),
    (105, 1, 1500, 'completed'),
    (106, 5, 700, 'pending'),
    (107, 5, 400, 'rejected');

-- Completed payments with customer names.
SELECT c.customer_name, p.payment_id, p.amount
FROM payments AS p
INNER JOIN customers AS c ON p.customer_id = c.customer_id
WHERE p.status = 'completed'
ORDER BY p.amount DESC;

-- Completed payments from Tashkent: Timur, 102, 3200.
SELECT c.customer_name, p.payment_id, p.amount
FROM payments AS p
INNER JOIN customers AS c ON p.customer_id = c.customer_id
WHERE p.status = 'completed' AND c.city = 'Tashkent'
ORDER BY p.amount DESC;

-- Customers with at least two completed payments: Anna, 2, 2700.
SELECT c.customer_id, c.customer_name,
       COUNT(*) AS payment_count, SUM(p.amount) AS total_amount
FROM payments AS p
INNER JOIN customers AS c ON p.customer_id = c.customer_id
WHERE p.status = 'completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(*) >= 2
ORDER BY total_amount DESC;

-- Customers with completed totals above 2500: Timur, Anna.
SELECT c.customer_id, c.customer_name,
       COUNT(*) AS payment_count, SUM(p.amount) AS total_amount
FROM payments AS p
INNER JOIN customers AS c ON p.customer_id = c.customer_id
WHERE p.status = 'completed'
GROUP BY c.customer_id, c.customer_name
HAVING SUM(p.amount) > 2500
ORDER BY total_amount DESC;

-- LEFT JOIN keeps every customer, including Elena with NULL payment fields.
SELECT c.customer_id, c.customer_name, p.amount
FROM customers AS c
LEFT JOIN payments AS p ON c.customer_id = p.customer_id;

-- No payments of any status: Elena only.
SELECT c.customer_id, c.customer_name
FROM customers AS c
LEFT JOIN payments AS p ON c.customer_id = p.customer_id
WHERE p.payment_id IS NULL;

-- Count all actual payments. Counts by customer ID: 3, 1, 1, 0, 2.
-- COUNT(*) would count Elena's preserved row as 1; COUNT(payment_id) ignores NULL.
SELECT c.customer_id, c.customer_name, COUNT(p.payment_id) AS payment_count
FROM customers AS c
LEFT JOIN payments AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- Completed counts for every customer: 2, 1, 1, 0, 0.
-- Put the status condition in ON to preserve customers without matching payments.
SELECT c.customer_id, c.customer_name, COUNT(p.payment_id) AS completed_count
FROM customers AS c
LEFT JOIN payments AS p
    ON c.customer_id = p.customer_id AND p.status = 'completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- No completed payments, including no payments at all: Elena and Martin.
SELECT c.customer_id, c.customer_name, COUNT(p.payment_id) AS completed_count
FROM customers AS c
LEFT JOIN payments AS p
    ON c.customer_id = p.customer_id AND p.status = 'completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(p.payment_id) = 0
ORDER BY c.customer_id;

-- Pending counts for every customer: 1, 0, 0, 0, 1.
SELECT c.customer_id, c.customer_name, COUNT(p.payment_id) AS pending_count
FROM customers AS c
LEFT JOIN payments AS p
    ON c.customer_id = p.customer_id AND p.status = 'pending'
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- At least one pending payment: Anna and Martin.
SELECT c.customer_id, c.customer_name, COUNT(p.payment_id) AS pending_count
FROM customers AS c
LEFT JOIN payments AS p
    ON c.customer_id = p.customer_id AND p.status = 'pending'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(p.payment_id) >= 1
ORDER BY c.customer_id;

-- Equivalent result using INNER JOIN: unmatched customers are not included.
SELECT c.customer_id, c.customer_name, COUNT(p.payment_id) AS pending_count
FROM customers AS c
INNER JOIN payments AS p
    ON c.customer_id = p.customer_id AND p.status = 'pending'
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- Review: join customer_id to customer_id, not to payment_id.
-- A status cannot equal completed AND pending AND rejected at the same time.
-- A semicolon ends the statement; it belongs after the final clause.
