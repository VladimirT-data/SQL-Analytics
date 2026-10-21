-- Урок 12. Итоговые задания: исправленные решения из обучения.
-- Требуется 04_joins.sql. Это учебные упражнения, отдельный проект ещё впереди.

-- 1. Все клиенты: количество и сумма completed, количество pending.
WITH completed_stats AS (
    SELECT customer_id, COUNT(*) AS completed_count, SUM(amount) AS completed_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
),
pending_stats AS (
    SELECT customer_id, COUNT(*) AS pending_count
    FROM payments
    WHERE status = 'pending'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
       COALESCE(cs.completed_count, 0) AS completed_count,
       COALESCE(cs.completed_amount, 0) AS completed_amount,
       COALESCE(ps.pending_count, 0) AS pending_count
FROM customers AS c
LEFT JOIN completed_stats AS cs ON c.customer_id = cs.customer_id
LEFT JOIN pending_stats AS ps ON c.customer_id = ps.customer_id
ORDER BY completed_amount DESC, c.customer_id ASC;

-- 2. Те же показатели только для клиентов с pending и без completed.
WITH completed_stats AS (
    SELECT customer_id, COUNT(*) AS completed_count, SUM(amount) AS completed_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
),
pending_stats AS (
    SELECT customer_id, COUNT(*) AS pending_count
    FROM payments
    WHERE status = 'pending'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
       COALESCE(cs.completed_count, 0) AS completed_count,
       COALESCE(cs.completed_amount, 0) AS completed_amount,
       COALESCE(ps.pending_count, 0) AS pending_count
FROM customers AS c
LEFT JOIN completed_stats AS cs ON c.customer_id = cs.customer_id
LEFT JOIN pending_stats AS ps ON c.customer_id = ps.customer_id
WHERE ps.pending_count >= 1 AND COALESCE(cs.completed_count, 0) = 0
ORDER BY completed_amount DESC, c.customer_id ASC;
-- Martin: 0, 0, 1. COALESCE в SELECT не меняет исходное поле в WHERE.

-- 3. Все максимальные выполненные платежи каждого клиента.
WITH max_payment AS (
    SELECT customer_id, payment_id, amount,
           RANK() OVER (
               PARTITION BY customer_id ORDER BY amount DESC
           ) AS rank_payment
    FROM payments
    WHERE status = 'completed'
)
SELECT customer_id, payment_id, amount
FROM max_payment
WHERE rank_payment = 1
ORDER BY customer_id, payment_id;

-- 4. Выполненные платежи, выросшие относительно предыдущего выполненного.
WITH previous_amounts AS (
    SELECT customer_id, payment_id, amount,
           LAG(amount) OVER (
               PARTITION BY customer_id ORDER BY payment_id
           ) AS previous_amount
    FROM payments
    WHERE status = 'completed'
),
changes AS (
    SELECT customer_id, payment_id, amount, previous_amount,
           amount - previous_amount AS amount_change
    FROM previous_amounts
)
SELECT customer_id, payment_id, amount, previous_amount, amount_change
FROM changes
WHERE amount_change > 0
ORDER BY customer_id, payment_id;
-- CTE передаёт дальше только столбцы из своего SELECT.
-- Использование previous_amount в вычитании не выводит его отдельно.

-- 5. Накопительная сумма выполненных платежей.
SELECT customer_id, payment_id, amount,
       SUM(amount) OVER (
           PARTITION BY customer_id
           ORDER BY payment_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM payments
WHERE status = 'completed'
ORDER BY customer_id, payment_id;
