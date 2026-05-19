--Challenge — CASE WHEN + aggregation combined
--Write a query that shows, per category, how many orders fall into each profit tier:
--'Loss' — profit < 0
--'Break Even' — profit = 0
--'Profit' — profit > 0
select category , count(order_id) as orders_count,
case  
	when profit=0 then 'Break Even'
	when profit  > 0 then 'Profit'
	else 'Loss'
end as profit_tier
from superstore
group by category , profit_tier

--Write a query that shows total sales per year — extract the year from order_date, sum the sales, group by year, order by year ascending.
select extract (year from order_date) as order_year,sum(sales) as total_sales from superstore
group by order_year
order by order_year  

--Write a single query that shows total sales per year, per profit tier — using CASE WHEN for the tier and EXTRACT for the year.
select sum(sales) as total_sales, extract(year from order_date)as order_year, 
case 
	when profit>0 then 'Profit'
	when profit<0 then 'Loss'
	else 'Break Even'
end as profit_tier
from superstore
group by order_year, profit_tier
order by order_year , profit_tier

--Write a query using a CTE that:

--In the CTE: labels each row with a profit_tier (CASE WHEN) and extracts order_year (EXTRACT)
--In the main query: shows total sales per year per tier, ordered by year then tier

with profitable as (
select extract(year from order_date) as order_year, sum(sales)as total_sales,
case 
	when profit >0 then 'Profit'
	when profit<0 then 'loss'
	else 'Break Even'
end as profit_tier
from superstore
group by order_year , profit_tier
)
select total_sales, profit_tier, order_year from profitable 
group by profit_tier , order_year , total_sales 
order by order_year , profit_tier 