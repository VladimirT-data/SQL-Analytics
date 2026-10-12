-- Lesson 02: ORDER BY, LIMIT and aggregate functions.
-- Run after 01_select_and_filter.sql. Reviewed learning solutions.

-- All transactions, largest first.
SELECT * FROM transactions ORDER BY amount DESC;

-- Three largest completed transactions. IDs: 6, 3, 8.
SELECT *
FROM transactions
WHERE status = 'completed'
ORDER BY amount DESC
LIMIT 3;

-- Two smallest completed transactions in Prague. Amounts: 1200, 1500.
SELECT transaction_id, amount
FROM transactions
WHERE status = 'completed' AND city = 'Prague'
ORDER BY amount ASC
LIMIT 2;

-- Number of completed transactions: 5. COUNT counts rows; SUM adds numbers.
SELECT COUNT(*) AS completed_count
FROM transactions
WHERE status = 'completed';

-- Total of all Prague transactions: 5800.
SELECT SUM(amount) AS prague_total
FROM transactions
WHERE city = 'Prague';

-- Number of completed Prague transactions: 3.
SELECT COUNT(*) AS prague_count
FROM transactions
WHERE city = 'Prague' AND status = 'completed';

-- Completed transactions: minimum 900, maximum 3200, average 1860.
SELECT MIN(amount) AS min_amount,
       MAX(amount) AS max_amount,
       AVG(amount) AS avg_amount
FROM transactions
WHERE status = 'completed';

-- Review: FROM precedes WHERE; separate ORDER BY expressions with commas.
