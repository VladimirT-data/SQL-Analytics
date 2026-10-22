# SQL Analytics

SQL exercises and reviewed solutions by Vladimir Trifonov, as part of learning data analytics.

This repository contains synthetic practice data, not real customer or financial information.
Solutions include corrections discussed during tutoring. Dataset setup, explanations and repository organization were prepared with AI assistance.

## Lessons

| File | Topics |
| --- | --- |
| [01_select_and_filter.sql](01_select_and_filter.sql) | SELECT, WHERE, AND/OR, inclusive boundaries |
| [02_sorting_and_aggregation.sql](02_sorting_and_aggregation.sql) | ORDER BY, LIMIT, COUNT, SUM, MIN, MAX, AVG |
| [03_group_by_having.sql](03_group_by_having.sql) | GROUP BY, filtering rows versus groups |
| [04_joins.sql](04_joins.sql) | INNER/LEFT JOIN, NULL, zero-payment customers |
| [05_case.sql](05_case.sql) | CASE, conditional counts and sums |
| [06_cte.sql](06_cte.sql) | CTEs, aggregated results, joins and averages |
| [07_nulls_and_subqueries.sql](07_nulls_and_subqueries.sql) | COALESCE, scalar subqueries, min/max/average per customer |
| [08_window_ranking.sql](08_window_ranking.sql) | Window aggregates, ROW_NUMBER, RANK, DENSE_RANK |
| [09_lag_and_window_frames.sql](09_lag_and_window_frames.sql) | LAG, running totals, previous totals, sliding windows |
| [10_dates_and_monthly_analysis.sql](10_dates_and_monthly_analysis.sql) | Date ranges, strftime, monthly changes, NULLIF, calendar gaps |
| [11_exists_in_union_and_text.sql](11_exists_in_union_and_text.sql) | EXISTS, NOT EXISTS, IN, DISTINCT, UNION/ALL, TRIM/LOWER/UPPER |
| [12_final_review.sql](12_final_review.sql) | Customer reports, zero counts, maximum ties, payment growth, running totals |

## How to run

Use SQLite and start with a fresh database. Run the SQL files in numerical order in the same database connection.
Lesson 01 creates `orders` and `transactions`; lesson 04 creates `customers` and `payments`.
Lessons 02-03 depend on lesson 01. Lessons 05-09 and 11-12 depend on lesson 04.
Lesson 10 creates its own separate synthetic table, `dated_payments`, and can run independently.
Use SQLite 3.25 or newer for window functions.

In the SQLite command-line shell:

```sql
.open :memory:
.headers on
.mode column
.read 01_select_and_filter.sql
.read 02_sorting_and_aggregation.sql
.read 03_group_by_having.sql
.read 04_joins.sql
.read 05_case.sql
.read 06_cte.sql
.read 07_nulls_and_subqueries.sql
.read 08_window_ranking.sql
.read 09_lag_and_window_frames.sql
.read 10_dates_and_monthly_analysis.sql
.read 11_exists_in_union_and_text.sql
.read 12_final_review.sql
```

Run these commands from the repository directory. The in-memory database disappears when the session ends.
To repeat the setup, open a new in-memory database first; CREATE TABLE statements are intended to run once.
Comments describe each task and selected expected results. Without ORDER BY, row order is not guaranteed.

## Data

- `orders`: 4 rows.
- `transactions`: 8 rows, for filtering and aggregation practice.
- `customers`: Anna, Timur, Petr, Elena and Martin.
- `payments`: 7 rows. Elena has no payments; Martin has pending and rejected payments but no completed payments.
- `dated_payments`: 10 synthetic rows added when packaging the date exercises; February has no completed payments. Dates discussed during tutoring were illustrative, so this is a new reproducible fixture, not historical source data.
- The ranking lesson uses a small inline VALUES example to demonstrate ties without changing `payments`.
- All amounts use one common arbitrary currency; `payments.amount` is non-NULL.

## Review notes

- "At least 1000" means `>= 1000`.
- WHERE filters rows before grouping; HAVING filters groups.
- A LEFT JOIN preserves unmatched customers. COUNT(payment_id) ignores the NULL payment ID; COUNT(*) counts the preserved row.
- Put a payment status condition in ON when customers without a matching payment must remain.
- CASE returns a value for each row; SUM then adds those values.
- In SQLite, multiply by 1.0 before integer division when a fractional result is needed.
- CTE output columns can be filtered with WHERE in the outer query.

- Each CTE exposes only the columns in its SELECT. Using a column in a calculation does not expose that original column.
- COALESCE in SELECT changes the displayed value, not the source column tested by WHERE.
- PARTITION BY separates customers; ORDER BY inside OVER defines calculation order. Final ORDER BY defines display order.
- RANK/DENSE_RANK preserve equal-amount ties only when the window ordering does not break those ties with a unique ID.
- LAG returns a previous value; SUM with a ROWS frame calculates a total over a range of rows.
- UNBOUNDED PRECEDING means the start of the partition; CURRENT ROW includes the current payment.
- Payment ID order is an exercise convention, not a guarantee of real chronological order.
- LAG over monthly aggregates sees the previous available month. Join a complete calendar first to include missing months.
- NULLIF(previous_amount, 0) avoids division by zero; percent change from a zero base remains NULL.
- UNION removes duplicate result rows; UNION ALL keeps them. A final ORDER BY sorts the combined result.

## Progress

Completed the planned SQL learning and review block through 2026-10-21: selection, grouping, joins, CASE, CTEs, NULL handling, subqueries, window functions, dates, existence checks, set operations and text cleanup.
These are reviewed learning solutions, not a claim of independent mastery. Further practice continues in a separate analytical SQL project, which is not included here.

All SQL statements were executed against SQLite during review, with representative result checks including zero-payment customers, tied maxima and missing months.
