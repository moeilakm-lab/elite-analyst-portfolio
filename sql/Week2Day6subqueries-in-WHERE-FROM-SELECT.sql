--Q1 — Subquery in WHERE
--Find all orders where the profit was above the average profit across all orders.
--Return: order_id, product_name, profit
--Order by profit descending.

select order_id , product_name , profit from superstore
where profit>(select avg(profit) as avg_profit from superstore)
order by profit desc 

--Q2 — Subquery in FROM
--First, write a subquery that calculates total sales per category.
--Then, wrap it — select only the categories where total sales exceed 300,000.
--Return: category, total_sales
select category , total_sales from (select category , sum(sales) total_sales from superstore 
group by category) as temp_sales
where total_sales >300000

--Q3 — Subquery in SELECT
--Show every Technology order with its product_name, sales, and the average sales across all orders as a column called overall_avg_sales.
--Filter to Technology only.
--Order by sales descending.
select product_name , sales, (select avg(sales) from superstore ) as overall_avg_sales
from superstore
where category = 'Technology'
order by sales desc 

--Q4 — Full Challenge
--This one combines what you've done. No scaffolding.
--For each sub-category, calculate average profit.
--Then return only sub-categories where the average profit is above the overall average profit across all orders.
--Return: sub_category, avg_profit
--Order by avg_profit descending.

select sub_category,average_profit  from (select sub_category , avg(profit) as average_profit from superstore
group by sub_category
) as sub_avg_profit where average_profit > (select avg(profit) from superstore)
order by average_profit desc 


