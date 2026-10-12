-- Lesson 06: Common table expressions (CTEs), aggregates and joins.
-- Run after lesson 04. Reviewed learning solutions.
-- A CTE is a named query result available within the statement that follows it.

-- Pending totals by customer: Anna's ID 1 -> 600, Martin's ID 5 -> 700.
WITH pending_payments AS (
    SELECT * FROM payments WHERE status = 'pending'
)
SELECT customer_id, SUM(amount) AS pending_amount
FROM pending_payments
GROUP BY customer_id
ORDER BY customer_id;

-- Filter the groups in the same query with HAVING: ID 5 -> 700.
WITH pending_payments AS (
    SELECT * FROM payments WHERE status = 'pending'
)
SELECT customer_id, SUM(amount) AS pending_amount
FROM pending_payments
GROUP BY customer_id
HAVING SUM(amount) > 650;

-- Once totals are columns of a CTE, the outer query can use WHERE.
WITH pending_totals AS (
    SELECT customer_id, SUM(amount) AS pending_amount
    FROM payments
    WHERE status = 'pending'
    GROUP BY customer_id
)
SELECT customer_id, pending_amount
FROM pending_totals
WHERE pending_amount > 650;

-- Completed totals above 2000: ID 2 -> 3200, ID 1 -> 2700.
WITH completed_totals AS (
    SELECT customer_id, SUM(amount) AS completed_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT customer_id, completed_amount
FROM completed_totals
WHERE completed_amount > 2000
ORDER BY completed_amount DESC;

-- Join the CTE to customer names and require at least two completed payments.
-- Expected: Anna, 2700, 2.
WITH completed_totals AS (
    SELECT customer_id, SUM(amount) AS completed_amount,
           COUNT(*) AS completed_count
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, t.completed_amount, t.completed_count
FROM completed_totals AS t
INNER JOIN customers AS c ON c.customer_id = t.customer_id
WHERE t.completed_amount > 2000 AND t.completed_count >= 2
ORDER BY t.completed_amount DESC;

-- Average from existing totals: Anna -> 1350.0.
-- In SQLite, * 1.0 BEFORE division prevents integer division.
-- There is no need to wrap this per-customer calculation in another AVG.
-- This matches AVG(amount) here because every amount is non-NULL.
WITH completed_totals AS (
    SELECT customer_id, SUM(amount) AS completed_amount,
           COUNT(*) AS completed_count
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT customer_id,
       completed_amount * 1.0 / completed_count AS avg_completed_amount
FROM completed_totals
WHERE completed_amount > 2000 AND completed_count >= 2;

-- Latest exercise: compute AVG on payment rows inside the CTE.
-- Keep customers whose average completed payment exceeds 1500: Timur, 3200, 1, 3200.0.
WITH completed_totals AS (
    SELECT customer_id,
           SUM(amount) AS completed_amount,
           COUNT(*) AS completed_count,
           AVG(amount) AS avg_completed_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT c.customer_id,
       c.customer_name,
       t.completed_amount,
       t.completed_count,
       t.avg_completed_amount
FROM completed_totals AS t
INNER JOIN customers AS c ON c.customer_id = t.customer_id
WHERE t.avg_completed_amount > 1500
ORDER BY t.avg_completed_amount DESC;

-- Review: separate SELECT columns with commas.
-- JOIN belongs after FROM and before WHERE.
-- An alias declared inside a CTE is not available in the outer query.
-- COUNT(status) worked after filtering to completed; COUNT(*) states row counting directly.
