--Write a query that returns:
--customer_name
--region
--sales
--Where sales > 500
select c.customer_name , o.region ,oi.sales  from customers as c
inner join orders as o on c.customer_id = o.customer_id 
inner join order_items as oi on o.order_id = oi.order_id 
where oi.sales >500



--Challenge 2 — LEFT JOIN
--Same three tables. Same columns. But this time:
--Use LEFT JOIN instead of INNER JOIN.
select c.customer_name , o.region , oi.sales from customers as c
left join orders as o on c.customer_id =o.customer_id 
left join order_items as oi on o.order_id = oi.order_id 
where oi.sales >500



--Challenge 3
--Return customer_name, segment, category, and total sales per customer per category.
--Rules:
--Join all three tables
--GROUP BY the right columns
--Alias total sales as total_sales
--ORDER BY total_sales DESC

select customer_name , segment , category , sum(sales) as total_sales from customers as c
inner join orders as o on c.customer_id =o.customer_id 
inner join order_items as oi on o.order_id = oi.order_id 
group by c.customer_name , category , c.segment 
order by total_sales desc 



--Challenge 4 — Add a filter
--Same query. Add one condition:
--Only show rows where total_sales > 5000.
select customer_name , segment , category , sum(sales) as total_sales from customers as c
inner join orders as o on c.customer_id =o.customer_id 
inner join order_items as oi on o.order_id = oi.order_id 
group by c.customer_name , category , c.segment 
having sum(sales)>5000
order by total_sales desc 



--Challenge 5 — Combine JOINs with a subquery
--You've done this separately. Now combine them.
--Find all customers whose total sales across all orders is above the average total sales per customer.
-- Customers whose total sales exceed the average total sales per customer
SELECT
    c.customer_name,
    SUM(oi.sales) AS total_sales
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY c.customer_name
HAVING SUM(oi.sales) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(oi2.sales) AS customer_total
        FROM customers AS c2
        INNER JOIN orders AS o2 ON c2.customer_id = o2.customer_id
        INNER JOIN order_items AS oi2 ON o2.order_id = oi2.order_id
        GROUP BY c2.customer_name
    ) AS totals
)
ORDER BY total_sales DESC;