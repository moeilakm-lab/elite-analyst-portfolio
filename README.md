# Q3 2017 Retail Intelligence Report

## Business Question

Which segments + categories drive Q3 2017 performance?

## Data & Approach

-- Check what your dates actually look like in the table
SELECT order_date
FROM superstore
LIMIT 5;

-- Convert order_date from text to proper DATE type
ALTER TABLE superstore
ALTER COLUMN order_date TYPE DATE
USING TO_DATE(order_date, 'MM/DD/YYYY');

select count(*) as q3_orders
from superstore
where order_date between '2017-07-01' and '2017-09-30';

-- Business question: Which segments + categories drive Q3 2017 performance?

select 
	segment,
	category,
	count(*) as orders,
	round(sum(sales):: numeric, 0) as revenue,
	round(sum(profit):: numeric, 0) as profit,
	round((sum(profit)/sum(sales) * 100)::numeric, 1) as margin_pct,
	case
		when sum(profit) / sum(sales) * 100 >= 20 then 'High Priority'
		when sum(profit) / sum(sales) * 100 >= 10 then 'Medium'
		else 'Review'
	end as priority_flag
from superstore
where order_date between '2017-07-01' and '2017-09-30'
group by segment , category 
order by revenue desc;
	
## Key Findings

1- Corporate / Office Supplies generated the highest margin of any combination in Q3 at 22.6%, on $24,461 revenue.
2- Furniture is underperforming across all 3 segments in Q3, with margins between 2.7% and 5.5% — flagged as Review 
in every case despite Consumer Furniture reaching $30,592 in revenue.
3- Home Office / Technology has a 20.9% margin on $16,539 revenue — flagged High Priority 
despite the lowest order count (33 orders). High margin, underpenetrated.

## Recommendations
 
 Increase sales effort on Home Office / Technology — strong margin with room to grow volume.
