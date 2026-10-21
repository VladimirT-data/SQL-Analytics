-- Урок 08. Оконные агрегаты и ранжирование. Требуется 04_joins.sql.
-- GROUP BY сворачивает строки; оконная функция сохраняет каждый платёж.
SELECT customer_id, payment_id, amount,
       SUM(amount) OVER (PARTITION BY customer_id) AS customer_total,
       COUNT(*) OVER (PARTITION BY customer_id) AS completed_count,
       AVG(amount) OVER (PARTITION BY customer_id) AS avg_completed_amount
FROM payments
WHERE status = 'completed'
ORDER BY customer_id, payment_id;

-- Ровно один максимальный выполненный платёж клиента.
-- При равной сумме выбираем меньший payment_id.
WITH ranked_payments AS (
    SELECT customer_id, payment_id, amount,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id ORDER BY amount DESC, payment_id ASC
           ) AS payment_rank
    FROM payments
    WHERE status = 'completed'
)
SELECT customer_id, payment_id, amount
FROM ranked_payments
WHERE payment_rank = 1
ORDER BY customer_id, payment_id;

-- Все максимальные платежи клиента.
-- Не добавляем уникальный payment_id в ORDER BY окна: он разрушил бы равенство рангов.
WITH ranked_payments AS (
    SELECT customer_id, payment_id, amount,
           RANK() OVER (
               PARTITION BY customer_id ORDER BY amount DESC
           ) AS payment_rank
    FROM payments
    WHERE status = 'completed'
)
SELECT customer_id, payment_id, amount
FROM ranked_payments
WHERE payment_rank = 1
ORDER BY customer_id, payment_id;

-- Две наибольшие различные суммы каждого клиента, со всеми совпадениями.
WITH ranked_payments AS (
    SELECT customer_id, payment_id, amount,
           DENSE_RANK() OVER (
               PARTITION BY customer_id ORDER BY amount DESC
           ) AS payment_rank
    FROM payments
    WHERE status = 'completed'
)
SELECT customer_id, payment_id, amount, payment_rank
FROM ranked_payments
WHERE payment_rank BETWEEN 1 AND 2
ORDER BY customer_id, payment_rank, payment_id;

-- Отдельный демонстрационный набор для равных сумм; payments не изменяется.
WITH example_payments(payment_id, customer_id, amount) AS (
    VALUES (201, 1, 1500), (202, 1, 1500), (203, 1, 900)
)
SELECT payment_id, amount,
       ROW_NUMBER() OVER (ORDER BY amount DESC, payment_id) AS row_num,
       RANK() OVER (ORDER BY amount DESC) AS amount_rank,
       DENSE_RANK() OVER (ORDER BY amount DESC) AS dense_amount_rank
FROM example_payments
ORDER BY amount DESC, payment_id;
-- Результат рангов: ROW_NUMBER 1,2,3; RANK 1,1,3; DENSE_RANK 1,1,2.
