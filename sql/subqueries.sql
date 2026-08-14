--Challenge 1 — Easy
--Find all orders where the sales amount is above the overall average sales across the entire superstore table.
--Return: order_id, customer_name, sales
--Order by: sales descending

select order_id , sales ,customer_name 
from superstore 
where sales > (select avg(sales) from superstore)
order by sales desc

--Challenge 2 — Easy
--Find all orders where the discount is equal to the maximum discount given in the entire table.
--Return: order_id, product_name, discount
--(Think about which comparison operator you need when matching a single maximum value.)

select order_id , product_name , discount from superstore 
where discount = (select max(discount) from superstore)

--Challenge 3 — Easy
--Using a subquery in FROM: calculate average profit per region, then return only regions where average profit is above 30.
--Return: region, avg_profit
--Order by: avg_profit descending

select region , avg_profit from (
select region , avg(profit) as avg_profit from superstore 
group by region ) as region_profit 
where avg_profit > 30
order by avg_profit desc 


--Challenge 4 — Medium
--Using a scalar subquery in SELECT: return every row's order_id, category, profit, and a column called overall_avg_profit 
--showing the global average profit next to every row.
--Add a fourth column called diff_from_avg — the difference between that row's profit and the overall average.
--Order by diff_from_avg descending. Limit to 15 rows.

select order_id , profit ,category ,  (select avg(profit) from superstore ) as overall_avg_profit, 
profit-(select avg(profit) from superstore )as diff_from_avg from superstore 
order by diff_from_avg desc 
limit 15

--Challenge 5 — Medium
--Correlated subquery: find all orders where the profit is above the average profit for that order's specific region.
--Return: order_id, region, profit
--Order by: profit descending
--(You need two aliases for the same table. The inner query must reference the outer row's region.)

select s1.order_id , s1.region , s1.profit from superstore s1 
where s1.profit > (select avg(s2.profit) from superstore s2 where s1.region = s2.region)
order by profit desc 

--Challenge 6 — Medium
--Using EXISTS: find all customers who have placed orders in more than one region.
--Return: customer_name — distinct, no duplicates
--Order alphabetically
--(Hint: you need to find customers where there EXISTS another row with the same customer but a different region.)

select distinct customer_name from superstore s1
where exists ( select 1 from superstore s2 where s1.customer_id = s2.customer_id   and s1.region  != s2.region      )
order by s1.customer_name asc 

--Challenge 7 — Hard.
--Subquery in FROM combined with CASE WHEN:
--Inner query: calculate total_sales and total_profit per category.
--Outer query: classify each category using CASE WHEN:
--Total profit above 100,000 → 'High performer'
--Total profit above 50,000 → 'Mid performer'
--Anything else → 'Low performer
--Return: category, total_sales, total_profit, performance_label

select category , total_sales , total_profit , case 
	when total_profit>100000 then 'High performance'
	when total_profit>50000 then 'Mid performance'
	else 'Low performance'
end as performance_label
from
(select category ,  sum(sales) as total_sales , sum(profit) as total_profit from superstore
group by  category) as categorise

--Challenge 8 — Hard.
--Correlated subquery inside HAVING:
--Find every category where the average profit of only the above-average orders within that category is greater than 50.
--In plain English: for each category, look only at orders that beat their own category average — then check if those high performers average above 50.
--Return: category, second column called avg_of_top_orders
--Order by avg_of_top_orders descending
--Build it in pieces. Start by thinking about what the correlated subquery needs to calculate — before you write any outer query. 
--Write the inner query idea out in plain English first, then translate it to SQL.




SELECT category, AVG(profit) AS avg_of_top_orders
FROM superstore s1
WHERE profit > (
select avg(s2.profit) from superstore s2 where s1.category = s2.category) 
GROUP BY category
HAVING AVG(profit) > 50
ORDER BY avg_of_top_orders DESC;



--D1
--Find all products where the total quantity sold is above the average total quantity sold across all products.
--Return: product_name, total_quantity
--Order by: total_quantity descending
select product_name , total_quantity  from 
(select product_name , sum(quantity) as total_quantity from superstore
group by product_name 
) as product_total
WHERE total_quantity > (
    SELECT AVG(total_quantity) FROM (
        SELECT SUM(quantity) AS total_quantity
        FROM superstore
        GROUP BY product_name
    ) AS totals
)
order by total_quantity desc 

--D2
--Using a subquery in FROM: calculate total profit per sub-category, then return only sub-categories where total profit is above 
--the average total profit across all sub-categories.
--Return: sub_category, total_profit
--Order by: total_profit descending
select sub_category, total_profit
from ( select sub_category, sum(profit) as total_profit from superstore
group by sub_category 
) as sub_totals
where total_profit > (
select avg(total_profit) from (select sum(profit) as total_profit from superstore
group by sub_category 
) as benchmark
) order by total_profit desc 

--D3.
--For each region, show the region name, its total sales, and the overall average sales across all regions next to it.
--Return: region, total_sales, overall_avg_sales
--Build the overall average as a scalar subquery in SELECT. Build total sales with GROUP BY.
SELECT 
    region,
    SUM(sales) AS total_sales,
    (SELECT avg(sales) from superstore ) AS overall_avg_sales
FROM superstore
GROUP BY region

--D4.
--Find all orders where the discount is above the average discount for that order's specific sub-category.
--Return: order_id, sub_category, discount
--Order by: discount descending
select s1.order_id , s1.discount , s1.sub_category from superstore s1
where s1.discount > (
select avg(s2.discount) from superstore s2 
where  s1.sub_category = s2.sub_category ) 
order by discount desc 

--D5. 
--Subquery in FROM combined with CASE WHEN:
--Inner query: calculate total profit and total orders per region.
--Outer query: classify each region:
--Total profit above 100,000 → 'Strong region'
--Total profit above 50,000 → 'Growing region'
--Anything else → 'Weak region'
--Return: region, total_profit, total_orders, region_health
select region , total_profit , total_orders , case 
	when total_profit>100000 then 'Strong region'
	when total_profit>50000 then 'Growing region'
	else 'Weak region'
end as region_health from (
select region , sum(profit)as total_profit , count(order_id) as total_orders from superstore 
group by region) as totals 

--D6 
--Find every sub-category where the average profit of orders that beat their sub-category average is greater than 100.
--Return: sub_category, avg_of_top_orders
--Order by avg_of_top_orders descending
--Same pattern as Challenge 8. Correlated subquery in WHERE, then HAVING on the outer aggregation.
SELECT 
    s1.sub_category, 
    AVG(s1.Profit) AS avg_of_top_orders
FROM 
    Superstore s1
WHERE 
    s1.Profit > (
        SELECT AVG(s2.Profit) 
        FROM Superstore s2 
        WHERE s2.sub_category = s1.sub_category 
    )
GROUP BY 
    s1.sub_category 
HAVING 
    AVG(s1.Profit) > 100
ORDER BY 
    avg_of_top_orders DESC







