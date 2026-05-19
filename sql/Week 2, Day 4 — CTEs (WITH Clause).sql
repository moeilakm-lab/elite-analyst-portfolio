-- Query 1 — Your first CTE
--Business question: What are the total sales per category?
with category_sales as (
select category , sum(sales) as total_sales
from superstore 
group by category 
)

--Query 2 — Now use the CTE to filter
--Same CTE. But this time, in your SELECT below, only show categories where total sales are above 750,000.
with category_sales as (
select category , sum(sales) as total_sales
from superstore 
group by category 
)
select * from category_sales
where total_sales >750000

--Query 3 — Two CTEs at once
--You can chain multiple CTEs before your final SELECT. Like this:

WITH cte_one AS (
    ...
),
cte_two AS (
    ...
)
SELECT ...

--Your challenge:

--CTE 1: total sales per category

with category_sales as (
select category , sum(sales) as total_sales
from superstore 
group by category),

--CTE 2: total sales per region

region_sales as (
select region , sum(sales) as total_sales
from superstore
group by region 
)
--Final SELECT: show both results... but here's the twist — join them on a shared column
select * from category_sales , region_sales

--Query 4 — Real analyst use case
--Business question: Who are the top 5 customers by total sales?

with customer_sales as (
select customer_name, sum(sales) as total_sales 
from superstore 
group by customer_name
)
select * from customer_sales
order by customer_sales.total_sales desc
limit 5

-- Query 5 — CTE + Window Function combo
-- Business question: For each customer in the top 5, what is their rank by total sales?

with customer_sales as (
select customer_name, sum(sales) total_sales
from superstore 
group by customer_name
)
select customer_name , total_sales,
rank()over(order by total_sales desc)
from customer_sales
limit 5

--The Full CTE Pipeline
--Business question: Which regions have above-average total sales?
with region_sales as (select region, sum(sales) as total_sales
from superstore
group by region 
),
average_sales as (select avg(region_sales.total_sales)as avg_sales
from region_sales
)
select region from region_sales,average_sales  where average_sales.avg_sales < region_sales.total_sales

-- Query 7 — Subquery → CTE Refactor
--Here's a subquery. Your job is to rewrite it as a CTE:
SELECT customer_name, total
FROM (
    SELECT customer_name, SUM(sales) AS total
    FROM superstore
    GROUP BY customer_name
) AS sub
WHERE total > 10000;

with total_sales as ( select customer_name , sum(sales) as total from superstore
group by customer_name)
select customer_name , total 
from total_sales 
where total > 10000

--Query 8 — CTE for Transformation
--Business question: What is each order's profit margin, and which orders have a margin above 30%?
--Profit margin = (profit / sales) * 100

WITH p_margin AS (
    SELECT order_id,
           sales,
           profit,
           ROUND((profit / sales)::numeric * 100, 2) AS margin
    FROM superstore
)
SELECT order_id, margin
FROM p_margin
WHERE margin > 30
ORDER BY margin DESC

--Query 9 — Full Analyst Pipeline
--Business question:Which sub-categories have both above-average sales AND above-average profit?
--You need:
--CTE 1: total sales + total profit per sub_category
--CTE 2: average sales across all sub-categories
--CTE 3: average profit across all sub-categories
--Final SELECT: only sub-categories that beat BOTH averages
with total as (select sum(sales) as total_sales, sum(profit) as total_profit, sub_category  from superstore
group by sub_category ),
	average_sales as (select avg(total_sales ) as avg_sales  from total
	 ),
	average_profit as(select avg(total_profit ) as avg_profit from total
	)
select distinct (sub_category) from total , average_sales , average_profit  
where total_sales > avg_sales  and total_profit > avg_profit 
	
	
















