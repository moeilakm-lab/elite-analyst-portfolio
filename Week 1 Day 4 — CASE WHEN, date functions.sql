-- Write a query on your superstore table that classifies every order into a profit status:

--'Profitable' → profit > 0
--'Break Even' → profit = 0
--'Loss' → profit < 0

select count(order_id) as order_count, case
	when profit>0 then 'Profitable'
	when profit= 0 then 'Break even'
	else 'Loss'
end
as profit_status
from superstore
group by profit_status 


-- Write a query that shows total revenue by year from the superstore table.

select extract(YEAR from to_date(order_date,'MM/DD/YYYY'))as order_year , sum(sales) as total_profit
from superstore
group by order_year
order by order_year
