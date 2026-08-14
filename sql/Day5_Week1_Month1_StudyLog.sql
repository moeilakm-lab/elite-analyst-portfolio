--Challenge 1 — Easy
--Classify every sub-category by its total profit into three bands, and show the band alongside the total profit.
--profit >= 10000 → 'High'
--profit >= 0 → 'Low'
--everything else → 'Loss'
--Use a CTE that computes total profit per sub-category, then classify in the next SELECT.
--Output: sub_category, total profit, band. Nothing else.

with total_prft as (select sub_category , sum(profit) as total_profit from superstore
group by sub_category 
)
select sub_category , case 
	when total_profit >=10000 then 'High'
	when total_profit >= 0 then 'Low'
	else 'Loss'
end as band ,
total_profit 
from total_prft 

--Challenge 2 — Easy
--For each region, show its total sales and label whether it beats a flat target:
--total sales >= 600000 → 'Above target'
--otherwise → 'Below target'
--CTE for the per-region totals, classify in the next SELECT.
--Output: region, total sales, label. Sort so the highest-selling region is at the top.
with per_region as (select region , sum(sales)as total_sales from superstore 
group by region 
)
select region , total_sales , case 
	when total_sales >= 600000 then 'Above target'
	else 'Below target'
end as label  
from per_region 
order by total_sales desc 

--Challenge 3 — Easy/Medium
--Show every sub-category whose total profit is above the average sub-category profit.
--Read that carefully — the benchmark is the average of the per-sub-category totals, not the average of raw rows. 
--So you need the totals first, then their average.
--Output: sub_category, total profit. Highest profit first.
with sub_total as (select sub_category , sum(profit) as total_profit from superstore
group by sub_category 
),
sub_bench as (select avg(total_profit) as average from  sub_total
)
select sub_category , total_profit from sub_total , sub_bench 
where total_profit > average 
order by sub_total.total_profit desc 

--Challenge 4 — Easy/Medium
--Now flip the grain. For each category, show its total profit and label it against the average category profit:
--above the average category profit → 'Strong'
--otherwise → 'Weak'
with total as (select category , sum(profit) as total_profit from superstore 
group by category 
)
select category , total_profit , case 
	when total_profit > (select avg(total_profit) from total ) then 'Strong'
	else 'Weak' end as lable
from total 
order by total_profit desc 

--Business question: "Which states are pulling their weight? Show me each state's total sales,
--and flag whether it's above or below the average state's sales — but I only care about the ones that are below average. Worst performers first."
with total as (select state, sum(sales) as total_sales from superstore
group by state 
)
select state , total_sales from total 
where total_sales < (select avg(total_sales) from total )
order by total_sales 

--Business question: "I want to understand our customers. For each customer, give me their total sales, 
--and bucket them: 'VIP' if they've spent more than the average customer, 'Standard' if they're at or below average 
--but still positive, 'Inactive' if their total sales are zero or somehow negative. Show me the VIPs only, biggest spenders at the top."
with totals as ( select customer_name , sum(sales) as total_sales from superstore
group by customer_name
),
avrg as (select avg(total_sales) as average from totals
),
classify as (select customer_name,total_sales , case
	when total_sales> average then 'VIP'
	when total_sales <= 0 then 'Inactive'
	else 'Standard'
end as tier
from avrg,totals 
)
select classify.customer_name , tier, classify.total_sales from classify 
where tier='VIP'
order by total_sales desc


--Business question: "For each region, I want to see its top 3 states by total sales — ranked within the region — and for each of those, 
--label whether the state's profit margin is healthy (15% or more), thin (positive but under 15%), or bleeding (zero or negative). Show region,
--state, the rank, total sales, margin, and the label. Order by region, then by rank within the region."


with Tsales as (select region ,state , sum(sales) as total_sales , sum(profit) as total_profit , sum(profit)/sum(sales) as margin from superstore
group by region , state
),
classify as (select margin , region , state , total_sales , total_profit ,  case 
	when margin >= 0.15 then 'healthy'
	when margin <=0 then  'bleeding'
	else 'thin' end as lable 
	from Tsales
),
ranking as (select state,region  ,total_sales , margin , lable , rank() over (partition by region order by total_sales desc ) as rank
from classify 
)
select * from ranking
where rank <=3
order by region , rank 


--Business question: "I want to find our problem sub-categories. For each category, rank its sub-categories by total sales. 
--Then show me only the sub-categories that rank in the top 2 of their category by sales BUT are actually losing money or barely profitable — margin under 5%.
--For each, show the category, sub-category, its sales rank within the category, total sales, total profit, margin, 
--and a label: 'critical' if margin is negative, 'watch' if margin is 0 to under 5%. Order by category, then by sales rank."

with totals as (select category , sub_category ,sum(profit) as total_profit, sum(sales) as total_sales, sum(profit)/sum(sales) as margin from superstore
group by category , sub_category 
),
ranking as (select category , sub_category, total_sales,total_profit , margin , rank () over (partition by category order by total_sales desc)as rank from totals 
),
classify as (select category, sub_category , total_sales,total_profit , rank, margin, case
	when margin <0 then 'critical'
	else 'watch' end as lable
	from ranking
)
select category , sub_category , total_sales,total_profit  , margin , rank , lable from classify 
where rank <=2 and  margin <0.05 
order by category , rank

--Business question: "Show me each ship mode and its total profit — but I only want the ship modes whose total profit is above $30,000. Most profitable first."
select ship_mode , sum(profit) as total_profit from superstore
group by ship_mode 
having sum(profit) >30000
order by total_profit desc 

--Business question: "For each customer, show their name and how many separate orders they've placed.
--I only want customers with more than 5 orders. Most orders first, and if two customers tie on order count, break the tie alphabetically by name."
select customer_name , count(distinct(order_id)) total_orders from superstore
group by customer_name 
having count(order_id)>5
order by total_orders desc , customer_name

--Business question: "Within each category, rank the sub-categories by total profit, highest profit first. 
--Show category, sub-category, total profit, and the rank. I want all of them, not just the top few."

with totals as (select category , sub_category , sum(profit) as total_profit from superstore
group by category , sub_category 
)
select  category , sub_category , total_profit ,rank() over (partition by category order by total_profit  desc) as ranks
from totals 

--Business question: "Show me every region whose average order value is above the overall average order value across all regions. 
--An 'order value' means the total sales of one complete order. 
--Show region and its average order value, highest first."
with total_order as (
    select region, order_id, sum(sales) as order_value
    from superstore
    group by region, order_id
),
average_region as (
    select region, avg(order_value) as average_order
    from total_order
    group by region
)
select region, average_order
from average_region
where average_order > (select avg(order_value) from total_order)
order by average_order desc;

--Business question: "For each region, find its single best-selling sub-category by total sales. Then for that winning sub-category, 
--show the region, the sub-category name, its total sales, its total profit, and a margin health label: 'healthy' if margin is 15%+, 
--'thin' if positive but under 15%, 'bleeding' if zero or negative. Order by total sales, biggest first."

with base as (select region , sub_category , sum(sales) as total_sales, sum(profit) as total_profit , sum(profit)/sum(sales) as margin from superstore 
group by region , sub_category 
),
ranking as ( select region , sub_category , total_sales , total_profit , margin , rank () over (partition by region  order by total_sales desc) as rank from base
)
select region , sub_category , total_sales , total_profit , margin , rank , case 
	when margin >= 0.15 then 'healthy'
	when margin <=0 then 'bleeding'
	else 'thin'
end as label 
from ranking 
where rank = 1 
order by total_sales desc 

--Business question: "I'm reviewing our customer base. For each region, I want to see the top 3 customers by total sales. 
--For each of those customers show the region, customer name, their sales rank within the region, their total sales, their total profit, 
--and a loyalty label based on how many separate orders they've placed: 'champion' if more than 10 orders, 'regular' if 5 to 10 orders, 'occasional' 
--if fewer than 5. Order by region, then by sales rank."
with base as (select region , customer_name , sum(sales) as total_sales, sum(profit) as total_profit , count(distinct(order_id)) as orders_count from superstore 
group by region , customer_name
),
ranking as (select region , customer_name , total_sales , total_profit , rank() over (partition by region order by total_sales desc) as ranks , orders_count from base 
)
select region , customer_name , total_sales , total_profit , ranks, case 
	when orders_count > 10 then 'champion'
	when orders_count <5 then 'occasional'
	else 'regular'
end as lable 
from ranking 
where ranks <= 3
order by region , ranks