-- Урок 09. LAG и границы окна. Требуется 04_joins.sql.
-- payment_id задаёт порядок только для этого упражнения.
-- В реальных данных время платежа следует определять по дате/времени.

-- Предыдущий выполненный платёж того же клиента.
SELECT customer_id, payment_id, amount,
       LAG(amount) OVER (
           PARTITION BY customer_id ORDER BY payment_id
       ) AS previous_amount
FROM payments
WHERE status = 'completed'
ORDER BY customer_id, payment_id;

-- Изменение относительно предыдущего, исключая первые платежи.
WITH payment_history AS (
    SELECT customer_id, payment_id, amount,
           LAG(amount) OVER (
               PARTITION BY customer_id ORDER BY payment_id
           ) AS previous_amount
    FROM payments
    WHERE status = 'completed'
)
SELECT customer_id, payment_id, amount, previous_amount,
       amount - previous_amount AS amount_change
FROM payment_history
WHERE previous_amount IS NOT NULL
ORDER BY customer_id, payment_id;

-- Текущий плюс предыдущий платёж. Для первого предыдущий показываем как 0.
WITH payment_history AS (
    SELECT customer_id, payment_id, amount,
           LAG(amount) OVER (
               PARTITION BY customer_id ORDER BY payment_id
           ) AS previous_amount
    FROM payments
    WHERE status = 'completed'
)
SELECT customer_id, payment_id, amount,
       COALESCE(previous_amount, 0) AS previous_amount,
       amount + COALESCE(previous_amount, 0) AS two_payment_total
FROM payment_history
ORDER BY customer_id, payment_id;

-- Все предыдущие платежи отдельно и накопительный итог с текущим.
SELECT customer_id, payment_id, amount,
       COALESCE(SUM(amount) OVER (
           PARTITION BY customer_id ORDER BY payment_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
       ), 0) AS previous_total,
       SUM(amount) OVER (
           PARTITION BY customer_id ORDER BY payment_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM payments
WHERE status = 'completed'
ORDER BY customer_id, payment_id;

-- Скользящая сумма: предыдущая строка + текущая.
-- У первого платежа окно содержит текущую строку, поэтому сумма не NULL.
SELECT customer_id, payment_id, amount,
       SUM(amount) OVER (
           PARTITION BY customer_id ORDER BY payment_id
           ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
       ) AS two_payment_total
FROM payments
WHERE status = 'completed'
ORDER BY customer_id, payment_id;
-- 2 PRECEDING расширило бы окно до трёх строк.
-- LAG(amount, 2) возвращает одно значение двумя строками ранее, а не сумму.
