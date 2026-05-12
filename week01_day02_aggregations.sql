-- Q1 → Total revenue, total profit, average order value for the whole dataset
SELECT count(*) AS total_orders,
Round(sum(profit):: numeric, 2) AS total_profit,
Round(sum(sales):: numeric, 2)  AS total_revenue,
Round(AVG(sales):: numeric, 2) AS average_order_value
FROM superstore 

--Q2 → Revenue, profit, margin % by category
select category,
sum(sales) as total_revenue,
sum(profit) as total_profit,
round(((sum(profit)/sum(sales))*100) ::numeric,2) ||'%' as margin_percentage
from superstore
group by category

-- Q3 → Top 10 customers by total revenue (with order count and avg order value)

select customer_name,
count(*) as order_count,
round(sum(sales)::numeric, 2) as total_revenue,
round(avg(sales)::numeric, 2) as average_sales
from superstore
group by customer_name
order by sum(sales)desc 
limit 10

--Q4 → Revenue by year using EXTRACT
select sum(sales) as total_revenue , extract (year from to_date (order_date, 'MM/DD/YYYY' )) :: integer as year,
count(*) as total_orders
from superstore
group by extract (year from to_date (order_date, 'MM/DD/YYYY')):: integer
order by year

--Q5 → Revenue and profit by region — which is most profitable by margin %?
select  region ,sum(sales) as total_revenue , sum(profit)as total_profit , round((sum(profit)::numeric/sum(sales)::numeric*100),2) as margin_ptc
from superstore 
group by region
order by margin_ptc  desc 

--Q6 → Sub-categories with total profit below zero
select sub_category , sum(profit) as total_profit
from superstore
group by sub_category
having sum(profit)<0

--Q7 → Average discount rate by category
select category , round(avg(discount)::numeric*100,2) as avg_discount
from superstore
group by category 
order by avg_discount 

--Q8 → Orders per ship_mode
select ship_mode , count(*) as number_of_orders
from superstore 
group by ship_mode 
order by number_of_orders desc 

--Q9 → HAVING: categories where avg order value exceeds £300
select category , round(avg(sales)::numeric,2) as avg_order_value
from superstore 
group by category
having avg(sales)>300

--Q10 → HAVING: segments where total revenue > £500,000
select segment,sum(sales) as total_revenue 
from superstore 
group by segment 
having sum(sales)>500000

--Q11 → Revenue by category AND region combined
select category , region, round(sum(sales)::numeric,2) as total_revenue  
from superstore 
group by category , region
order by category , region 

--Q12 → Orders per month using DATE_TRUNC
select date_trunc('month',to_date(order_date,'MM/DD/YYYY')) as month ,
count(*) as total_orders
from superstore 
group by date_trunc('month', to_date(order_date,'MM/DD/YYYY'))
order by month

--Q13 → Avg profit per order by segment
select segment , round(avg(profit)::numeric ,2)as  Avg_profit
from superstore
group by  segment 

--Q14 → Sub-categories with more than 500 orders
select sub_category , count(*) as num_of_orders
from superstore 
group by sub_category 
having count(*) > 500
order by num_of_orders desc 

--Q15 → Total discount value by category
 
select category , round(sum(sales*discount)::numeric,2) as total_discount
from superstore group by category 
order by total_discount desc 







