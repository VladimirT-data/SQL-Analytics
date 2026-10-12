# SQL-practice

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

## How to run

Use SQLite and start with a fresh database. Run the SQL files in numerical order in the same database connection.
Lesson 01 creates `orders` and `transactions`; lesson 04 creates `customers` and `payments`.
Lessons 02-03 depend on lesson 01. Lessons 05-06 depend on lesson 04.

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
```

Run these commands from the repository directory. The in-memory database disappears when the session ends.
To repeat the setup, open a new in-memory database first; CREATE TABLE statements are intended to run once.
Comments describe each task and selected expected results. Without ORDER BY, row order is not guaranteed.

## Data

- `orders`: 4 rows.
- `transactions`: 8 rows, for filtering and aggregation practice.
- `customers`: Anna, Timur, Petr, Elena and Martin.
- `payments`: 7 rows. Elena has no payments; Martin has pending and rejected payments but no completed payments.
- All amounts use one common arbitrary currency; `payments.amount` is non-NULL.

## Review notes

- "At least 1000" means `>= 1000`.
- WHERE filters rows before grouping; HAVING filters groups.
- A LEFT JOIN preserves unmatched customers. COUNT(payment_id) ignores the NULL payment ID; COUNT(*) counts the preserved row.
- Put a payment status condition in ON when customers without a matching payment must remain.
- CASE returns a value for each row; SUM then adds those values.
- In SQLite, multiply by 1.0 before integer division when a fractional result is needed.
- CTE output columns can be filtered with WHERE in the outer query.

## Progress

Practiced: basic selection, filters, sorting, aggregates, grouping, joins, CASE and CTEs.
Current focus: combining these topics independently and checking query results.
Next: consolidation exercises, dates, subqueries and window functions, followed by an analytical SQL project.

All SQL statements were executed against SQLite during review, with representative result checks.
