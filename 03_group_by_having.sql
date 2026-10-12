-- Lesson 03: GROUP BY and HAVING.
-- Run after lesson 01. Reviewed learning solutions.

-- Completed totals by city: Prague 5200/3, Tashkent 3200/1, Brno 900/1.
SELECT city, SUM(amount) AS total_amount, COUNT(*) AS transaction_count
FROM transactions
WHERE status = 'completed'
GROUP BY city
ORDER BY total_amount DESC;

-- Keep city groups whose completed total exceeds 3000: Prague, Tashkent.
SELECT city, SUM(amount) AS total_amount, COUNT(*) AS transaction_count
FROM transactions
WHERE status = 'completed'
GROUP BY city
HAVING SUM(amount) > 3000
ORDER BY total_amount DESC;

-- At least two completed transactions: Prague, average 1733.333...
SELECT city, COUNT(*) AS transaction_count, AVG(amount) AS avg_amount
FROM transactions
WHERE status = 'completed'
GROUP BY city
HAVING COUNT(*) >= 2
ORDER BY avg_amount DESC;

-- First keep individual completed transactions of at least 1000.
-- Then keep cities with at least two remaining transactions: Prague, 3, 5200.
SELECT city, COUNT(*) AS transaction_count, SUM(amount) AS total_amount
FROM transactions
WHERE status = 'completed' AND amount >= 1000
GROUP BY city
HAVING COUNT(*) >= 2
ORDER BY total_amount DESC;

-- WHERE filters individual rows before grouping; HAVING filters groups.
-- "At least 1000" includes 1000: use >=, not >.
-- Aggregate expressions in HAVING avoid reliance on dialect-specific aliases.
