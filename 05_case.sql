-- Lesson 05: CASE and conditional aggregation.
-- Run after lesson 04. Reviewed learning solutions.

-- Translate statuses into readable labels.
SELECT payment_id, status,
       CASE
           WHEN status = 'completed' THEN 'Выполнен'
           WHEN status = 'pending' THEN 'Ожидает'
           WHEN status = 'rejected' THEN 'Отклонён'
           ELSE 'Другой статус'
       END AS status_label
FROM payments;

-- First matching WHEN wins. 900 -> small, 1000 -> medium, 2000 -> large.
-- amount is NOT NULL in this learning dataset.
SELECT payment_id, amount,
       CASE
           WHEN amount < 1000 THEN 'small'
           WHEN amount < 2000 THEN 'medium'
           ELSE 'large'
       END AS amount_category
FROM payments;

-- Counts across the dataset: completed 4, pending 2, rejected 1.
SELECT
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) AS rejected_count
FROM payments;

-- Amount totals: completed 6800, pending 1300.
-- CASE supplies an amount per row; the outer SUM adds those amounts.
SELECT
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) AS completed_amount,
    SUM(CASE WHEN status = 'pending' THEN amount ELSE 0 END) AS pending_amount
FROM payments;

-- Every customer, including zeroes for Elena.
-- Sorted names: Timur, Anna, Petr, Elena, Martin.
SELECT c.customer_id, c.customer_name,
    SUM(CASE WHEN p.status = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN p.status = 'pending' THEN p.amount ELSE 0 END) AS pending_amount,
    SUM(CASE WHEN p.status = 'completed' THEN p.amount ELSE 0 END) AS completed_amount
FROM customers AS c
LEFT JOIN payments AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY completed_amount DESC, c.customer_id ASC;

-- At least one pending payment and no completed payments.
-- Expected: Martin, completed_count 0, pending_amount 700, pending_count 1.
SELECT c.customer_id, c.customer_name,
    SUM(CASE WHEN p.status = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN p.status = 'pending' THEN p.amount ELSE 0 END) AS pending_amount,
    SUM(CASE WHEN p.status = 'pending' THEN 1 ELSE 0 END) AS pending_count
FROM customers AS c
LEFT JOIN payments AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(CASE WHEN p.status = 'pending' THEN 1 ELSE 0 END) >= 1
   AND SUM(CASE WHEN p.status = 'completed' THEN 1 ELSE 0 END) = 0
ORDER BY pending_amount DESC;

-- If Martin receives an additional completed payment, completed_count becomes 1.
-- His existing pending_count stays 1; he no longer satisfies this HAVING condition.
-- Aggregate expressions belong in SELECT (or HAVING), not in the JOIN condition.
