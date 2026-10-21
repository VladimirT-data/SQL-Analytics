-- Урок 11. EXISTS, IN, DISTINCT, UNION и текст. Требуется 04_joins.sql.

-- Хотя бы один выполненный платёж больше 1000: Anna и Timur.
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1 FROM payments AS p
    WHERE p.customer_id = c.customer_id
      AND p.status = 'completed' AND p.amount > 1000
)
ORDER BY c.customer_id;

-- Ни одного выполненного платежа, включая отсутствие любых платежей.
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM payments AS p
    WHERE p.customer_id = c.customer_id AND p.status = 'completed'
)
ORDER BY c.customer_id;

-- Есть pending, нет completed: Martin.
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM payments AS p
    WHERE p.customer_id = c.customer_id AND p.status = 'completed'
)
AND EXISTS (
    SELECT 1 FROM payments AS p
    WHERE p.customer_id = c.customer_id AND p.status = 'pending'
)
ORDER BY c.customer_id;

-- Нужные поля уже есть в payments, соединение не требуется.
SELECT payment_id, customer_id, amount, status
FROM payments
WHERE status IN ('pending', 'rejected') AND amount >= 600
ORDER BY amount DESC, payment_id;

-- Уникальные клиенты с pending/rejected: 1 и 5.
SELECT DISTINCT customer_id
FROM payments
WHERE status IN ('pending', 'rejected')
ORDER BY customer_id;

-- Подзапрос находит ID по статусам, внешний запрос получает имена.
SELECT customer_id, customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM payments WHERE status IN ('pending', 'rejected')
)
ORDER BY customer_id;

-- UNION удаляет повторы целых строк. Итоговые ID: 1, 2, 3, 5.
SELECT customer_id FROM payments WHERE status = 'pending'
UNION
SELECT customer_id FROM payments WHERE status = 'completed'
ORDER BY customer_id;

-- UNION ALL сохраняет повторы: 1, 1, 1, 2, 3, 5.
SELECT customer_id FROM payments WHERE status = 'pending'
UNION ALL
SELECT customer_id FROM payments WHERE status = 'completed'
ORDER BY customer_id;
-- Один ORDER BY сортирует объединённый результат; точка с запятой только в конце.

-- Исходное имя оставлено для сравнения; его можно убрать.
SELECT customer_id, customer_name,
       LOWER(TRIM(customer_name)) AS clean_name,
       UPPER(city) AS city_upper
FROM customers
ORDER BY customer_id;
-- TRIM убирает пробелы по краям; LOWER/UPPER меняют регистр в результате.
-- SELECT не изменяет сохранённые данные. Эти примеры используют латиницу.
