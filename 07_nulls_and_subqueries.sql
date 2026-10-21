-- Урок 07. NULL, COALESCE, подзапросы и соединение с агрегатами.
-- Требуется 04_joins.sql. Исправленные решения пройденных заданий.

-- Все клиенты и сумма выполненных платежей, включая нули.
WITH customer_stats AS (
    SELECT customer_id, SUM(amount) AS completed_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
       COALESCE(t.completed_amount, 0) AS completed_amount
FROM customers AS c
LEFT JOIN customer_stats AS t ON c.customer_id = t.customer_id
ORDER BY completed_amount DESC, c.customer_id;

-- Клиенты без ожидающих платежей: 2, 3, 4.
-- В CTE нет строки для клиента без pending. LEFT JOIN создаёт NULL, не 0.
WITH pending_stats AS (
    SELECT customer_id, COUNT(*) AS pending_count, SUM(amount) AS pending_amount
    FROM payments
    WHERE status = 'pending'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
       COALESCE(t.pending_count, 0) AS pending_count,
       COALESCE(t.pending_amount, 0) AS pending_amount
FROM customers AS c
LEFT JOIN pending_stats AS t ON c.customer_id = t.customer_id
WHERE COALESCE(t.pending_count, 0) = 0
ORDER BY pending_amount DESC, c.customer_id;

-- Выполненные платежи выше среднего по всем выполненным: 102 (3200).
SELECT payment_id, customer_id, amount
FROM payments
WHERE status = 'completed'
  AND amount > (SELECT AVG(amount) FROM payments WHERE status = 'completed')
ORDER BY amount DESC;

-- Максимальный выполненный платёж во всей таблице с именем клиента.
SELECT p.payment_id, p.customer_id, c.customer_name, p.amount
FROM payments AS p
INNER JOIN customers AS c ON c.customer_id = p.customer_id
WHERE p.status = 'completed'
  AND p.amount = (SELECT MAX(amount) FROM payments WHERE status = 'completed')
ORDER BY p.payment_id;

-- Максимум каждого клиента. При равных максимумах сохраняются все платежи.
WITH customer_max AS (
    SELECT customer_id, MAX(amount) AS max_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT p.customer_id, p.payment_id, p.amount
FROM payments AS p
INNER JOIN customer_max AS t
    ON p.customer_id = t.customer_id AND p.amount = t.max_amount
WHERE p.status = 'completed'
ORDER BY p.customer_id, p.payment_id;

-- Минимум каждого клиента, включая все совпадения.
WITH customer_min AS (
    SELECT customer_id, MIN(amount) AS min_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT p.customer_id, p.payment_id, p.amount
FROM payments AS p
INNER JOIN customer_min AS t
    ON p.customer_id = t.customer_id AND p.amount = t.min_amount
WHERE p.status = 'completed'
ORDER BY p.amount DESC, p.payment_id;

-- Выполненные платежи выше среднего своего клиента: 105 (1500 > 1350).
WITH customer_avg AS (
    SELECT customer_id, AVG(amount) AS avg_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT p.customer_id, p.payment_id, p.amount, t.avg_amount
FROM payments AS p
INNER JOIN customer_avg AS t
    ON p.customer_id = t.customer_id AND p.amount > t.avg_amount
WHERE p.status = 'completed'
ORDER BY p.amount DESC;

-- Ниже среднего своего клиента; разница положительная: 101, разница 150.
WITH customer_avg AS (
    SELECT customer_id, AVG(amount) AS avg_amount
    FROM payments
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT p.customer_id, p.payment_id, p.amount, t.avg_amount,
       t.avg_amount - p.amount AS difference
FROM payments AS p
INNER JOIN customer_avg AS t ON p.customer_id = t.customer_id
WHERE p.status = 'completed' AND p.amount < t.avg_amount
ORDER BY p.amount DESC;
