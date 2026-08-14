--Rewrite this subquery as a CTE.
SELECT category, total_sales
FROM (
    SELECT category, SUM(sales) AS total_sales
    FROM superstore
    GROUP BY category
) AS category_totals
ORDER BY total_sales DESC;

with category_totals as (select category, sum(sales) as total_sales from superstore 
group by category 
)
select category , total_sales  from category_totals 
order by total_sales desc

--Rewrite this subquery as a CTE.
SELECT sub_category, avg_profit
FROM (
    SELECT sub_category, AVG(profit) AS avg_profit
    FROM superstore
    GROUP BY sub_category
) AS sub_cat_profits
WHERE avg_profit > 0
ORDER BY avg_profit DESC;

with sub_cat_profit as (select sub_category , avg(profit) as avg_profit from superstore
group by sub_category
)
select sub_category , avg_profit from sub_cat_profit 
where avg_profit >0
order by avg_profit  desc 

Rewrite it as a CTE.
SELECT region, total_sales
FROM (
    SELECT region, SUM(sales) AS total_sales
    FROM superstore
    GROUP BY region
) AS region_totals
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM (
        SELECT region, SUM(sales) AS total_sales
        FROM superstore
        GROUP BY region
    ) AS avg_calc
)
ORDER BY total_sales DESC;

with region_totals as (select region , sum(sales) as total_sales from superstore 
group by region 
),
avg_calc as (select avg(total_sales) as avg_s from region_totals
)
select region , total_sales from avg_calc , region_totals 
where total_sales > avg_s 
order by total_sales desc 

--Rewrite this as a CTE. Read it carefully — there are two levels here and a CASE WHEN involved.
SELECT 
    customer_name,
    total_sales,
    CASE 
        WHEN total_sales >= 10000 THEN 'High Value'
        WHEN total_sales >= 5000 THEN 'Mid Value'
        ELSE 'Standard'
    END AS customer_tier
FROM (
    SELECT customer_name, SUM(sales) AS total_sales
    FROM superstore
    GROUP BY customer_name
) AS customer_totals
ORDER BY total_sales DESC;

with customer_totals as (select customer_name , sum(sales) as total_sales from superstore
group by customer_name 
)
select customer_name , total_sales , case 
	when total_sales >= 10000 then 'High Value'
	when total_sales >= 5000 then 'Mid Value'
	else 'Standard'
end as customer_tier
from customer_totals 
order by total_sales desc 

--Show each region's total sales and total profit. Only include regions where total profit is above $50,000. Order by total profit descending.
select region , sum(sales) as total_sales, sum(profit)as total_profit from superstore
group by region 
having sum(profit) > 50000

--Challenge 6 — Medium
--Write this from scratch. Choose subquery or CTE
--Question: Show each sub-category's name, total sales, total profit, and profit margin percentage. 
--Only show sub-categories where the profit margin is above the average profit margin across all sub-categories. Order by profit margin descending.
--Profit margin = SUM(profit) / SUM(sales) * 100
with totals as (select sub_category , sum(sales) as total_sales, sum(profit) as total_profit , sum(profit)/sum(sales)*100 as profit_margin
from superstore
group by sub_category 
),
avg_profit as (select avg(profit_margin) as avg_margin from totals
)
select sub_category , total_sales , total_profit,profit_margin from avg_profit,totals
where profit_margin > avg_margin 
order by profit_margin desc 

--For each category, show the top 2 sub-categories by total sales. Show the category, sub-category, total sales, 
--and a rank column. Only show ranks 1 and 2.
with totals as (select sub_category , category , sum(sales)as total_sales from superstore
group by sub_category , category
),
ranking as (select RANK() OVER (PARTITION BY category ORDER BY total_sales  DESC)as sales_rank, total_sales ,category , sub_category  from totals )
select sub_category , category , total_sales, sales_rank  from ranking 
where sales_rank <=2

--Show each customer's name, their total sales, total profit, and classify them into tiers using CASE WHEN:
--'Elite' — total profit above the average total profit per customer
--'Standard' — everyone else
--Then show only Elite customers. Order by total profit descending.
with totals as (select customer_name , sum(sales) as total_sales , sum(profit) as total_profit from superstore
group by customer_name 
),
average as (select avg(total_profit) avrg_p from totals
 ),
classification as (select customer_name , total_sales , total_profit , case 
	when total_profit>avrg_p then 'Elite'
	else 'Standard'
end as classify
from average , totals) 
select customer_name , total_sales , total_profit  from classification 
where classify ='Elite'
order by total_profit desc 

--Show each product's name, total quantity sold, and the overall average total quantity per product. 
--Only show products where their total quantity sold is above that average. Order by total quantity descending.
with totals as (select product_name , sum(quantity) as total_quantity from superstore 
group by product_name
),
total_avg as (select avg(total_quantity) as total_average from totals)
select product_name , total_quantity from totals,total_avg  
where total_quantity  > total_average 
order by total_quantity desc 

--Show each region and its total sales. Only include regions where total sales are above $500,000. Order by total sales descending.
select region , sum(sales) as total_sales from superstore
group by region 
having sum(sales) > 500000
order by total_sales desc 

--Using a CTE, calculate total profit per state. Then in the main SELECT, show only states where total profit is above $10,000. 
--Order by total profit descending.
with totals as (select state, sum(profit) as total_profit from superstore
group by state
)
select state , total_profit from totals
where total_profit >10000
order by total_profit desc 

 --Show each category and ship mode combination, with total sales and total profit. 
 --Only include combinations where total profit is above $20,000. Order by total profit descending.
with totals as (select category , ship_mode , sum(sales) as total_sales, sum(profit) as total_profit from superstore
group by category , ship_mode
)
select category , ship_mode , total_sales , total_profit from totals 
where total_profit >20000
order by total_profit desc  

--Show each category's total sales, total profit, profit margin percentage, and classify each category using CASE WHEN:
--'High Margin' — profit margin above 15%
--'Low Margin' — profit margin between 0% and 15% inclusive
--'Loss' — profit margin below 0%
--Profit margin = SUM(profit) / SUM(sales) * 100
--Show all categories. Order by profit margin descending.
with totals as (select category , sum(sales) as total_sales , sum(profit) as total_profit , sum(profit)/sum(sales)* 100  as margin from superstore
group by category 
)
select category , total_sales, total_profit,margin  , case 
	when margin >15 then 'High Margin'
	when margin >=0 then 'Low Margin'
	else 'loss'
	end as classify
	from totals 
	order by margin desc 
	
-- For each region, calculate total sales, total profit, and profit margin. Then classify each region using CASE WHEN:
--'Strong' — profit margin above 14%
--'Moderate' — profit margin between 10% and 14% inclusive
--'Weak' — profit margin below 10%
--Only show regions classified as 'Weak' or 'Moderate'. Order by profit margin descending.
with totals as (select region , sum(sales)as total_sales , sum(profit)as total_profit , sum(profit)/sum(sales)*100 as margin from superstore
group by region 
),
classifying as (select region, total_sales , total_profit , margin, case 
	when margin>14 then 'Strong'
	when margin>=10 then 'Moderate'
	else 'Weak'
end as classify  
from totals
)
select region , total_sales , total_profit , margin , classify 
from classifying 
where classify ='Weak' or classify = 'Moderate'
order by margin desc 