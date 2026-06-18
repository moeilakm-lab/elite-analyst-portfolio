--We need a report that classifies every product into a profit band (loss, low, medium, high) and ranks customers by their total sales within each region. 
 --The report should show product name, category, profit, and the profit band label. 
--Loss — profit below 0
--Low — 0 to 50
--Medium — 50 to 200
--High — above 200
 --For the customer ranking it should show customer name, region, total sales, and their rank within the region.
 
 -- classify: label each product row with a profit band using CASE WHEN
with classify as (select product_name , profit, category ,region,  case 
	when profit > 200 then 'High'
	when profit<0 then 'loss'
	when profit >=0 and profit <=50 then 'Low'
	else 'Medium'
end as label 
from superstore 
),
-- base: aggregate total sales per customer per region
base as (select customer_name ,region ,sum(sales) as total_sales from superstore 
group by customer_name , region 
),
-- ranking: rank customers by total sales within each region using ROW_NUMBER
ranking as (select customer_name, region , total_sales ,row_number()over (partition by region order by total_sales desc) as ranks from base
order by region , ranks 
)
select customer_name , region , total_sales , ranks from ranking 
select product_name , category , profit , label from classify 
