-- ============================================================
-- MONTH 1 BOSS PROJECT: The Analytics Layer
-- Dataset: Superstore (PostgreSQL)
-- Steps: 1 (CASE WHEN classification), 2 (ROW_NUMBER ranking),
--        3 (LAG month-over-month revenue), 4 (SUM OVER running total)
-- ============================================================


-- ============================================================
-- STEP 1 + STEP 2: Product classification and customer ranking
-- ============================================================

-- classify: label each product row with a profit band using CASE WHEN
WITH classify AS (
    SELECT
        product_name,
        category,
        profit,
        region,
        CASE
            WHEN profit < 0            THEN 'Loss'
            WHEN profit >= 0 AND profit <= 50  THEN 'Low'
            WHEN profit > 50 AND profit <= 200 THEN 'Medium'
            ELSE 'High'
        END AS label
    FROM superstore
),
-- base: aggregate total sales per customer per region
base AS (
    SELECT
        customer_name,
        region,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY customer_name, region
),
-- ranking: rank customers by total sales within each region using ROW_NUMBER
ranking AS (
    SELECT
        customer_name,
        region,
        total_sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_sales DESC) AS ranks
    FROM base
)
-- Step 1 output: product classification
SELECT product_name, category, profit, label
FROM classify
ORDER BY category, profit DESC;

-- Step 2 output: customer ranking by region
WITH base AS (
    SELECT
        customer_name,
        region,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY customer_name, region
),
ranking AS (
    SELECT
        customer_name,
        region,
        total_sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_sales DESC) AS ranks
    FROM base
)
SELECT customer_name, region, total_sales, ranks
FROM ranking
ORDER BY region, ranks;


-- ============================================================
-- STEP 3: Month-over-month revenue change per region using LAG
-- ============================================================

-- base2: aggregate total sales per region per calendar month
WITH base2 AS (
    SELECT
        DATE_TRUNC('month', order_date) AS months,
        region,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY region, months
),
-- rev_differences: calculate revenue change vs prior month using LAG
rev_differences AS (
    SELECT
        months,
        region,
        total_sales,
        total_sales - LAG(total_sales) OVER (PARTITION BY region ORDER BY months) AS revenue_difference
    FROM base2
)
SELECT months, region, total_sales, revenue_difference
FROM rev_differences
ORDER BY region, months;


-- ============================================================
-- STEP 4: Running total of sales per region by month using SUM OVER
-- ============================================================

-- base3: aggregate total sales per region per calendar month
WITH base3 AS (
    SELECT
        DATE_TRUNC('month', order_date)::date AS months,
        region,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY region, months
),
-- totals: calculate cumulative running total per region ordered by month
totals AS (
    SELECT
        months,
        region,
        total_sales,
        SUM(total_sales) OVER (PARTITION BY region ORDER BY months) AS monthly_total
    FROM base3
)
SELECT months, region, total_sales, monthly_total
FROM totals
ORDER BY region, months;
