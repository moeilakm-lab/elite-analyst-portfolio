--Rank all sub-categories by total profit, highest first. Show sub-category, total profit, and the rank. No partition — one global ranking across everything.

select sub_category , sum(profit) as total_profit, row_number() over (order by sum(profit) desc)  from superstore
group by sub_category 

--Rank sub-categories by total profit, but this time partition by category. Each category gets its own independent ranking. 
--Show category, sub-category, total profit, and the rank.

select category , sub_category , sum(profit) as total_profit , rank()over (partition by category order by sum(profit) desc ) as rn from superstore 
group by category , sub_category 

--Show the top 2 sub-categories by total profit within each category. Output: category, sub-category, total profit, rank. Only show rank 1 and rank 2.
with ranking as (select category , sub_category , sum(profit) as total_profit , rank () over (partition by category order by sum(profit) desc ) as rn from superstore
group by category , sub_category
)
select * from ranking 
where rn <=2 

--For each region, show the top 3 customers by total sales. Output: region, customer name, total sales, rank. Only show the top 3 per region.
with ranking as (select region , customer_name , sum(sales) as total_sales, rank() over (partition by region order by sum(sales) desc ) as rn from superstore
group by region , customer_name 
)
select * from ranking 
where rn <=3

--Rank states by total sales within each region. Use both RANK and DENSE_RANK in the same query — two separate columns. Show region, state, total sales, rank, dense rank
select region , state , sum(sales) as total_sales , rank() over (partition by region order by sum(sales) desc ) as rn , 
dense_rank() over (partition by region order by sum(sales) desc) as dense_rn from superstore
group by state , region 

--Divide all customers into 4 quartiles based on their total sales — highest sales in quartile 1, lowest in quartile 4. 
--Show customer name, total sales, and quartile. Order the final output by quartile, then total sales descending within each quartile.

with base as (select customer_name , sum(sales) as total_sales from superstore
group by customer_name
)
select customer_name , total_sales , ntile(4) over (order by total_sales desc ) as quartile from base 
order by quartile , total_sales desc  

--For each category, rank sub-categories by total sales. Then label each sub-category as 'Top' if rank 1, 'Middle' if rank 2 or 3, 'Bottom' for everything else.
--Only show sub-categories ranked 4 and below plus rank 1. Output: category, sub-category, total sales, rank, label. Order by category, then rank.
with base as (select category , sub_category, sum(sales) as total_sales from superstore
group by category , sub_category
),
ranking as (select category , sub_category , total_sales , rank() over (partition by category order by total_sales desc ) as ranks from base
),
labels as (select category , sub_category , total_sales , ranks , case 
	when ranks = 1 then 'Top'
	when ranks = 2 or ranks=3 then 'Middle'
	else 'Bottom'
	end as label 
from ranking 
)
select * from labels  
where ranks =1 or ranks >=4 
order by category , ranks 

--For each region, find the top 2 customers by total sales. For each of those customers, also show how many distinct orders they placed. 
--Label them as 'Champion' if distinct orders > 15, 'Regular' if 5 to 15, 'Occasional' for anything below 5. 
--Output: region, customer name, total sales, distinct orders, rank, label. Order by region, then rank.

with base as (select region , customer_name , sum(sales) as total_sales from superstore
group by customer_name , region
),
distincts as (select customer_name ,count(distinct(order_id)) as distinct_order from superstore 
group by customer_name
),
ranking as (select b.region, b.customer_name , b.total_sales ,distinct_order, row_number() over (partition by b.region order by total_sales desc) as ranks from base b
inner join distincts d on b.customer_name = d.customer_name
),
labels as (select * , case
	when distinct_order > 15 then 'Champion'
	when distinct_order < 5 then 'Occasional'
	else 'Regular'
end as label 
from ranking 
)
select * from labels
where ranks <=2 
order by region , ranks 

--For each region, rank customers by total sales. Then show only the customers in quartile 1 (top 25%) by total sales globally. 
--For those customers, show their region, customer name, total sales, regional rank, and global quartile. Order by global quartile, then regional rank.
with base as (select region, customer_name , sum(sales) as total_sales from superstore 
group by region , customer_name 
),
ranking as (select customer_name , region , total_sales , ntile(4)over (order by total_sales desc) as quartile from base
),
ranking_r as (select * , rank() over (partition by region order by total_sales desc) as rank from ranking 
)
select * from ranking_r 
where quartile =1 
order by quartile , rank

--D2 — COUNT DISTINCT within a ranking
--Rank customers by number of distinct orders placed, highest first. Show customer name, distinct order count, and rank. 
--Only show customers with more than 10 distinct orders. Order by rank.
with base as (select customer_name , count(distinct(order_id)) as distinct_orders from superstore 
group by customer_name 
),
ranks as (select * , rank() over (order by distinct_orders desc ) as rank from base
)
select * from ranks 
where distinct_orders > 10
order by rank

--D3 — ORDER BY reflex
--For each ship mode, show the average number of distinct orders per customer. 
--Order the output from the ship mode with the highest average down to the lowest.
with base as (select ship_mode,customer_name , count(distinct(order_id)) as distinct_orders from superstore
group by ship_mode, customer_name 
),
average as (select ship_mode, avg(distinct_orders) as avg_d_orders from base
group by ship_mode 
)
select * from average 
order by avg_d_orders desc 

--D4 — Benchmark grain + window combined
--For each category, rank sub-categories by their average order value — highest average order value first. Show category, sub-category, average order value, and rank.
with base as (select category , sub_category , order_id , sum(sales) as total_sales from superstore
group by category , sub_category , order_id  
),
average as (select category , sub_category , avg(total_sales) as average_order_v from base
group by sub_category, category 
),
ranking as (select *,RANK() OVER (PARTITION BY category ORDER BY average_order_v DESC) AS rank from average 
)
select * from ranking 

--D5 — Full combined, all tools
--For each region, find the sub-category with the highest total sales. For that sub-category, show the profit margin percentage. 
--Label it 'Strong' if margin is above 10%, 'Weak' if 0% to 10%, 'Loss' if negative. Output: region, sub-category, total sales, total profit, margin percentage, label. 
--Order by region.

with base as (select region , sub_category , sum(sales) as total_sales , sum(profit) as total_profit , sum(profit)/sum(sales)*100 as margin from superstore
group by region , sub_category 
),
ranking as (select * , rank()over (partition by region order by total_sales desc ) as rank from base
),
labels as (select * , case 
	when margin >10 then 'Strong'
	when margin <0 then 'Loss'
	else 'Weak'
	end as label 
from ranking 
)
select region, sub_category , total_sales ,total_profit,margin,label  from labels 
where rank = 1
order by region  

--For each category, rank customers by total profit contribution. Show the top 2 per category. 
--For each of those customers also show how many distinct orders they placed and what percentage of the category's total profit they represent. Label them 'Key Account' 
--if their profit share is above 5%, 'Contributor' otherwise. Output: category, customer name, total profit, distinct orders, profit share percentage, rank, label. 
--Order by category, rank.
with base as (select category , customer_name , sum(profit) as total_profit from superstore
group by category , customer_name 
),
ranking as (select * , rank()over (partition by category order by total_profit desc) as ranks from base 
),
dis_ord as (select customer_name , count(distinct(order_id)) as distinct_orders from superstore
group by customer_name 
),
category_profit as (select category , sum(profit) as cat_total_p from superstore 
group by category 
),
shared as (select b.category,b.customer_name ,b.total_profit ,r.ranks ,d.distinct_orders  , b.total_profit/cat_total_p *100 as shared_profit from base as b 
inner join ranking as r on r.customer_name=b.customer_name
inner join dis_ord as d on r.customer_name =d.customer_name 
inner join category_profit cat on b.category = cat.category and r.category = b.category 
),
labels as (select * , case
	when shared_profit > 5 then 'Key Account'
	else 'Contributor'
	end as label
from shared
)
select category , customer_name , total_profit ,distinct_orders, shared_profit ,ranks ,label from labels 
where ranks <=2
order by labels.category  
