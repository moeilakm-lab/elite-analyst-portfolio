-- Q1 — Rank all orders by sales descending using ROW_NUMBER. Show order_id, sales, row_num.

select order_id , sales , row_number() over(order by sales desc) from superstore 


--Q2 — Top 1 product by profit in each category. Use ROW_NUMBER + subquery filter.

select * from (
select product_name  , profit, category ,
row_number() over(partition by category order by profit desc) as rank_ 
from superstore 
) as np
where rank_ = 1

--Q3 — Top 3 sub-categories by total revenue globally. Use DENSE_RANK on aggregated data.

select * from (
select sub_category , sum(sales)as total_revenue, 
dense_rank() over(order by sum(sales) desc ) as rank
from superstore 
group by sub_category
)
where rank <=3

--Q4 — Rank customers by total spend. Show ROW_NUMBER, RANK, and DENSE_RANK side by side in the same query. 
--No subquery needed — just show all three columns together.

select customer_id , sum(sales) , row_number() over (order by sum(sales) desc) as row ,
rank() over(order by sum(sales) desc) as rank,
dense_rank() over (order by sum(sales) desc) as dense_rank
from superstore
group by customer_id

--Q5 — Top 2 customers by revenue in each region. DENSE_RANK + PARTITION BY region + subquery filter WHERE dr <= 2

select * from (
select customer_id ,  region, sum(sales) as total_sales,
dense_rank() over (partition by region order by sum(sales) desc) as dr
from superstore 
group by customer_id ,  region
 )
 where dr <=2

--Q6: Top 3 most profitable products in each category
--Show: product_name, category, profit, rank
--Use DENSE_RANK. Partition by category. Rank by profit descending. Filter to top 3.
select * from (
 select product_name , sum(profit) as total_profit , category,
dense_rank() over(partition by category order by sum(profit) desc) as rank
from superstore 
group by product_name , category 
)
where rank <=3

--Q7: Segment all customers into 4 spend quartiles using NTILE(4). Show customer_name, total spend, quartile number
select customer_name , sum(sales) as total_spend , ntile(4) over (order by sum(sales)) as quartile
from superstore 
group by customer_name 

--Q8: Average revenue and order count per quartile. Wrap Q7 in subquery, GROUP BY spend_quartile
select avg(total_spend )as average_rev, count(quartile ) as count , quartile  from (
select customer_name , sum(sales) as total_spend , ntile(4) over (order by sum(sales)) as quartile
from superstore 
group by customer_name )
group by quartile 
order by quartile 

--Q9: Within each segment (Consumer/Corporate/Home Office), rank customers by revenue. PARTITION BY segment
select customer_name , segment , sum(sales) as total_rev, 
row_number() over (partition by segment order by sum(sales) desc) as rank
from superstore
group by customer_name , segment 

--Q10: Bottom 3 products by profit in each category. ORDER BY profit ASC
select * from (select product_name , sum(profit) , category,
dense_rank() over (partition by category order by sum(profit)) as rank
from superstore 
group by product_name , category
)
where rank <=3

