-- Q1: Show all columns from the first 5 rows
SELECT * FROM superstore LIMIT 5;
-- Q2: Show only order_id, customer_name, and sales for all rows, order by sales in descending order
SELECT order_id, customer_name, sales FROM superstore ORDER BY sales DESC;
-- Q3: Find all orders in the 'Furniture' category. Show order_id, product_name, sales, and profit.
SELECT order_id , product_name, sales, profit from superstore WHERE category = 'Furniture';
-- Q4: Q4: Find all orders where profit is negative (we are losing money on these). Show all columns.
SELECT order_id from superstore WHERE profit < 0;
-- Q5: Q5: Find orders in 'Technology' with sales above 1000. Order by sales descending. Limit 15.
SELECT order_id, sales from superstore 
where category='Technology' and sales > 1000 
order by sales DESC
limit 15;
-- Q6: Show all distinct product categories in the table.
select DISTINCT category from superstore;
-- Q7: Show all distinct combinations of category and segment.
SELECT DISTINCT category, segment from superstore;
-- Q8 Q8: Find all orders from the 'West' region. How many rows does this return?
SELECT count (order_id) FROM superstore WHERE region = 'West';
SELECT order_id from superstore WHERE region = 'West'
--Q9: Find orders where discount > 0.4. Are these profitable? Show sales, discount, profit.
SELECT sales, discount, profit from superstore WHERE discount > 0.4;
select couny(*)from superstore where discount > 0.4 and profit > 0; --to count profitable
select count(*) from superstore where discount > 0.4 and profit < 0; --to count unprofitable
-- Q10: Find orders between 1 Jan 2023 and 31 Mar 2023 (Q1). Show order_date, sales, profit.
select order_date, sales, profit from superstore 
where order_date >= '01/01/2015' and order_date <= '31/03/2015';
--Q11: Find orders where category is either 'Technology' OR sales > 2000.
select order_id , sales, category from superstore s 
where s.category ='Technology'or sales > 2000
order by category;
--Q12: Find orders where customer_name starts with 'A'. Use LIKE 'A%'.
select order_id , customer_name from superstore s 
where s.customer_name like 'A%'
order by customer_name;
--Q13: Find the 5 orders with the highest profit. Show customer_name, product_name, profit.
select customer_name, product_name, profit from superstore s
ORDER BY profit DESC
limit 5;
-- Q14: Find the 5 orders with the lowest profit (biggest losses). Same columns.
select order_id , profit from superstore s
ORDER BY profit ASC
limit 5;
-- Q15: Find all orders where ship_mode is 'Same Day'. How many are there?
select order_id from superstore s 
where s.ship_mode ='Same Day'
--Q16: Find orders in the 'East' or 'West' region AND category = 'Technology'.
select order_id, region, category from superstore s 
where (s.region = 'East' or s.region = 'West') and category = 'Technology'
--Q17: Show orders where discount = 0 (no discount applied). Order by sales descending.
select order_id, discount, sales from superstore s 
where s.discount = 0
order by sales DESC;
--Q18: Find the order_id and sales for the single highest-value order in the dataset.
select order_id, sales from superstore s
ORDER BY sales DESC
limit 1;
--Q19: Count how many distinct customers we have. Use: SELECT COUNT(DISTINCT customer_id).
select count (DISTINCT customer_id) from superstore;
--Q20: Find all orders where profit margin is negative AND sales are above 500
select order_id ,sales, (profit/sales) as profit_margin from superstore s 
where (profit/sales) < 0 and sales > 500