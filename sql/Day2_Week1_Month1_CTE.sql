--Challenge 1 — Easy
--Write a CTE called region_totals that calculates total sales per region. Then SELECT all columns from it, ordered by total_sales descending.
with region_totals as ( 
select region , sum(sales) as total_sales from superstore 
group by region 
)
select * from region_totals 
order by total_sales desc 

--Challenge 2 — Easy
--Write a CTE called category_profits that calculates total profit per category. Then SELECT only categories 
--where total profit is above 50,000, ordered by total profit descending.
with category_profits as (
select category , sum(profit) as total_profit from superstore
group by category 
)
select category , total_profit  from category_profits 
where total_profit > 50000
order by total_profit desc

--Challenge 3 — Easy
--Write a CTE called customer_order_counts that counts how many orders each customer has made. 
--Then SELECT all customers who have made more than 5 orders, ordered by order count descending.
with customer_order_counts as (
select customer_id , count(order_id) as orders_count from superstore 
group by customer_id 
)
select customer_id , orders_count from customer_order_counts 
where orders_count > 5
order by orders_count desc

--Challenge 4 — Medium
--Write two CTEs chained together:
--First CTE called region_sales — total sales per region
--Second CTE called region_profits — total profit per region
--Then in the main SELECT, join them together on region and show: region, total_sales, total_profit, ordered by total_sales descending.
with region_sales as (select region , sum(sales)as total_sales from superstore 
group by region
),
region_profits as (select region , sum(profit)as total_profit from superstore 
group by region
)
select region_profits.region, total_sales , total_profit from region_sales 
inner join region_profits on region_profits.region = region_sales.region 
order by total_sales desc 

--Challenge 5 — Medium
--Three CTEs this time:
--category_sales — total sales per category
--category_profits — total profit per category
--category_orders — count of orders per category
--Main SELECT: join all three on category, show category, total_sales, total_profit, order_count. Order by total_sales descending.
with category_sales as (
select category , sum(sales) as total_sales from superstore
group by category 
),
category_profit as (select category , sum(profit) as total_profit from superstore
group by category
),
category_orders as (select category, count(order_id) as orders_count from superstore 
group by category 
)
select category_sales.category, total_sales , total_profit , orders_count from category_sales 
inner join category_orders on category_sales.category =category_orders.category 
inner join category_profit on category_profit.category =category_orders.category 
order by category_sales.total_sales desc 

--Challenge 6 — Medium
--Two CTEs:
--customer_sales — total sales per customer
--customer_avg — a single value: the average of all customer total sales (hint: this CTE uses customer_sales, not superstore directly)
--Main SELECT: show customer_name and total_sales for customers above the average, ordered by total_sales descending.
--This one requires a CTE that references another CTE. Think carefully before you write.
with customer_sales as (select customer_name , sum(sales) as total_sales from superstore
group by customer_name
),
customer_avg as (select avg(total_sales) as average_sales from customer_sales
)
select customer_name,total_sales from  customer_sales
where total_sales > (select average_sales from customer_avg) 
order by total_sales desc 

--sub_category_profits — total profit per sub_category
--profit_ranked — uses sub_category_profits to add a profit classification using CASE WHEN:
--total_profit < 0 → 'Loss'
--total_profit < 10000 → 'Low'
--total_profit < 50000 → 'Medium'
--everything else → 'High'
--Main SELECT: show sub_category, total_profit, profit_band — ordered by total_profit descending.
with sub_category_profit as ( select sub_category , sum(profit) as total_profit from superstore
group by sub_category 
),
profit_ranked as (
select sub_category , total_profit ,  case
	when total_profit < 0 then 'Loss'
	when total_profit < 10000 then 'Low'
	when total_profit < 50000 then 'Medium'
	else 'High'
end as profit_band 
from sub_category_profit
)
select sub_category , total_profit , profit_band from profit_ranked 
order by total_profit desc 

--Challenge 8 — Hard
--Three CTEs:
--customer_sales — total sales per customer
--customer_profits — total profit per customer
--customer_classified — uses both CTEs joined on customer_name, calculates profit margin as total_profit / total_sales * 100, 
--then classifies using CASE WHEN:
--margin < 0 → 'Loss'
--margin < 10 → 'Low Margin'
--margin < 20 → 'Mid Margin'
--everything else → 'High Margin'
--Main SELECT: show customer_name, total_sales, total_profit, margin, margin_band — only customers with total_sales above 5000, 
--ordered by margin descending.

with customer_sales as (select customer_name , sum(sales) as total_sales from superstore 
group by customer_name
),
customer_profits as (select customer_name , sum(profit) as total_profit from superstore 
group by customer_name 
),
customer_classified as (select customer_sales.customer_name ,total_sales ,total_profit , total_profit/total_sales *100 as margin from customer_sales
inner join customer_profits on customer_sales.customer_name = customer_profits.customer_name
)
select customer_name , total_sales, total_profit,margin , case 
	when margin < 0 then 'Loss'
	when margin <10 then 'Low Margin'
	when margin <20 then 'Mid Margin'
	else 'High Margin'
end as margin_band
from customer_classified 
where total_sales >5000
order by margin desc

--Using a CTE, find each product's total quantity sold. Then find the average of those totals. 
--Return only products whose total quantity is above that average, ordered by total quantity descending.

with total_products as (select product_name, sum(quantity) as total_quantity from superstore
group by product_name 
),
total_avg as (select avg(total_quantity) as avg_q from total_products
)
select product_name, total_quantity  from total_products  
where total_quantity > (select avg_q from total_avg) 


--Using a CTE, find total profit per state. Then in the main SELECT, show only states where 
--total profit is above the average total profit across all states — but this time use HAVING in the main SELECT, not WHERE.
 with state_profit as ( select state , sum(profit) as total_profit from superstore 
 group by state 
 )
 select state , total_profit from state_profit
 where total_profit > (select avg(total_profit) from state_profit)
 
--Two CTEs:
--region_sales — total sales per region
--region_orders — count of distinct order_ids per region
--Main SELECT: join them on region, show region, total_sales, order_count, and a sales classification using CASE WHEN:
--total_sales >= 700000 → 'Top'
--total_sales >= 500000 → 'Mid'
--everything else → 'Low'
--Order by total_sales descending.
 
 with region_sales as (select region , sum(sales) as total_sales from superstore
 group by region
 ),
 region_orders as (select region , count(distinct(order_id)) as order_count from superstore
 group by region)
 select region_sales.region , total_sales , order_count , case
 	when total_sales>=700000 then 'Top'
 	when total_sales>=500000 then 'Mid'
 	else 'Low'
 end as Sales_classification
 from region_sales 
 inner join region_orders on region_orders.region =region_sales.region 
 order by total_sales desc 
 
 --Three CTEs:
--customer_sales — total sales per customer
--customer_profits — total profit per customer
--customer_summary — joins both on customer_name, calculates profit margin as total_profit / total_sales * 100
--Main SELECT: show customer_name, total_sales, total_profit, margin — only customers where margin is above 30 AND 
--total_sales is above 10000, ordered by margin descending.
 with customer_sales as (select customer_name , sum(sales) as total_sales from superstore 
 group by customer_name
 ),
 customer_profits as (select customer_name , sum(profit) as total_profit from superstore 
 group by customer_name 
 ),
 customer_summary as (select customer_sales.customer_name , total_profit , total_sales ,total_profit/total_sales * 100 as margin from customer_sales 
 inner join customer_profits on customer_profits.customer_name = customer_sales.customer_name 
 )
 select customer_name , total_sales, total_profit , margin from customer_summary 
 where margin > 30 and total_sales > 10000
 order by margin desc
 
--Three CTEs:
--sub_sales — total sales per sub_category
--sub_profits — total profit per sub_category
--sub_summary — joins both on sub_category, calculates margin as total_profit / total_sales * 100, adds a CASE WHEN classification:
--margin < 0 → 'Loss'
--margin < 15 → 'Weak'
--margin < 25 → 'Healthy'
--everything else → 'Strong'
--Main SELECT: show sub_category, total_sales, total_profit, margin, margin_band — only sub_categories 
--where total_sales is above 100,000, ordered by margin descending.
 with sub_sales as (select sub_category , sum(sales) as total_sales from superstore 
 group by sub_category 
 ),
 sub_profits as (select sub_category , sum(profit) as total_profit from superstore
 group by sub_category 
 ),
 sub_summary as (select total_profit , total_sales, sub_sales.sub_category , total_profit/total_sales * 100 as margin 
from sub_sales
inner join sub_profits on sub_sales.sub_category = sub_profits.sub_category 
)
select sub_category , total_sales , total_profit , margin ,
case
	 when margin < 0 then 'Loss'
	 when margin < 15 then 'Weak'
	 when margin <25 then 'Healthy'
	 else 'Strong'
end as margin_band
from sub_summary 
where total_sales > 100000
order by margin desc 


--Three CTEs:
--yearly_sales — total sales per year (extract the year from order_date)
--yearly_profits — total profit per year
--yearly_summary — joins both on year, calculates margin as total_profit / total_sales * 100
--Main SELECT: show year, total_sales, total_profit, margin — all years, ordered by year ascending. Add a CASE WHEN that flags each year:
--margin >= 12 → 'Good Year'
--margin >= 10 → 'Average Year'
--everything else → 'Poor Year'

with yearly_sales as (select extract(year from order_date) as year, sum(sales) as total_sales from superstore
group by year
),
yearly_profit as (select extract (year from order_date) as year , sum(profit) as total_profit from superstore
group by year
),
yearly_summary as (select yearly_profit.year , total_sales , total_profit , total_profit/total_sales * 100 as margin from yearly_profit
inner join yearly_sales on yearly_profit.year = yearly_sales.year
)
select year , total_sales , total_profit , margin , case
	when margin >=12 then 'Good Year'
	when margin >=10 then 'Average Year'
	else 'Poor Year'
	end as classification
	from yearly_summary 
	order by year 