-- Урок 10. Даты, месячные суммы, LAG, проценты и пропущенные месяцы.
-- Самостоятельный синтетический набор, добавленный при оформлении уроков.
-- В чате даты были условными. Это не реальные платежи и не изменение payments.
-- Запустить один раз в свежей БД. Даты TEXT в формате ISO YYYY-MM-DD.
CREATE TABLE dated_payments (
    payment_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    status TEXT NOT NULL,
    payment_date TEXT NOT NULL
);
INSERT INTO dated_payments VALUES
    (301, 1, 1200, 'completed', '2026-01-10'),
    (302, 2, 1800, 'completed', '2026-01-20'),
    (303, 1, 600, 'pending', '2026-02-05'),
    (304, 1, 1500, 'completed', '2026-03-01'),
    (305, 3, 500, 'completed', '2026-03-15'),
    (306, 5, 400, 'rejected', '2026-03-18'),
    (307, 1, 1200, 'completed', '2026-09-01'),
    (308, 2, 800, 'completed', '2026-09-01'),
    (309, 3, 500, 'completed', '2026-09-30'),
    (310, 2, 900, 'completed', '2026-10-01');

-- Сентябрь: начало включительно, начало следующего месяца исключительно.
SELECT customer_id, payment_id, amount, payment_date
FROM dated_payments
WHERE status = 'completed'
  AND payment_date >= '2026-09-01' AND payment_date < '2026-10-01'
ORDER BY payment_date, payment_id;

-- Дни сентября с не менее чем двумя выполненными платежами.
SELECT payment_date, COUNT(*) AS payment_count, SUM(amount) AS total_amount
FROM dated_payments
WHERE status = 'completed'
  AND payment_date >= '2026-09-01' AND payment_date < '2026-10-01'
GROUP BY payment_date
HAVING COUNT(*) >= 2
ORDER BY payment_date;

-- %Y — год, %m — месяц с ведущим нулём; '-' — буквальный разделитель.
SELECT strftime('%Y-%m', payment_date) AS payment_month,
       COUNT(*) AS payment_count, SUM(amount) AS total_amount
FROM dated_payments
WHERE status = 'completed'
  AND payment_date >= '2026-01-01' AND payment_date < '2027-01-01'
GROUP BY strftime('%Y-%m', payment_date)
ORDER BY payment_month;

-- Сравнение доступных месяцев. LAG без календаря пропускает отсутствующие месяцы.
-- PARTITION BY не нужен: здесь один общий ряд месячных сумм.
WITH monthly_totals AS (
    SELECT strftime('%Y-%m', payment_date) AS payment_month,
           SUM(amount) AS total_amount
    FROM dated_payments
    WHERE status = 'completed'
      AND payment_date >= '2026-01-01' AND payment_date < '2027-01-01'
    GROUP BY strftime('%Y-%m', payment_date)
),
monthly_comparison AS (
    SELECT payment_month, total_amount,
           LAG(total_amount) OVER (ORDER BY payment_month) AS previous_month_amount
    FROM monthly_totals
),
monthly_changes AS (
    SELECT payment_month, total_amount, previous_month_amount,
           total_amount - previous_month_amount AS amount_change,
           100.0 * (total_amount - previous_month_amount)
               / NULLIF(previous_month_amount, 0) AS change_percent
    FROM monthly_comparison
)
SELECT payment_month, total_amount, previous_month_amount, amount_change, change_percent
FROM monthly_changes
WHERE change_percent < -20
ORDER BY change_percent ASC, payment_month;

-- Календарь января–марта сохраняет февраль с нулём выполненных платежей.
WITH months(payment_month) AS (
    VALUES ('2026-01'), ('2026-02'), ('2026-03')
),
monthly_totals AS (
    SELECT strftime('%Y-%m', payment_date) AS payment_month,
           SUM(amount) AS total_amount
    FROM dated_payments
    WHERE status = 'completed'
      AND payment_date >= '2026-01-01' AND payment_date < '2026-04-01'
    GROUP BY strftime('%Y-%m', payment_date)
),
full_months AS (
    SELECT m.payment_month, COALESCE(t.total_amount, 0) AS total_amount
    FROM months AS m
    LEFT JOIN monthly_totals AS t ON m.payment_month = t.payment_month
),
monthly_comparison AS (
    SELECT payment_month, total_amount,
           LAG(total_amount) OVER (ORDER BY payment_month) AS previous_month_amount
    FROM full_months
)
SELECT payment_month, total_amount, previous_month_amount,
       total_amount - previous_month_amount AS amount_change,
       100.0 * (total_amount - previous_month_amount)
           / NULLIF(previous_month_amount, 0) AS change_percent
FROM monthly_comparison
ORDER BY payment_month;
-- Январь: 3000, предыдущий NULL; февраль: 0, предыдущий 3000, -100%;
-- март: 2000, предыдущий 0, процент NULL (от нуля процент роста не определён).
-- Ноль означает отсутствие выполненных платежей в полном учебном наборе.
