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
