use ecommerce_interview;
-- Calculate overall company revenue.
select sum(quantity*unit_price) as company_revenue
from order_items;
-- Calculate average order value.
select avg(total_order) as order_value
from (select avg(quantity*unit_price) as total_order
from order_items
group by order_id) as order_summary;
-- Calculate cancelled order percentage.
select (count(case when status in ("Cancelled") then 1 end)*100.0)/count(*) as cancelled_percentage
from orders;
-- Find the month with highest revenue.

-- Find the month with highest order volume.
select monthname(order_date) as month, count(order_id) as total_orders
from orders
group by monthname(order_date),month(order_date)
order by total_orders desc
limit 1;
-- Find the most common order status.
select status, count(*) as order_status
from orders
group by status
order by order_status desc
limit 1;
-- Generate a payment-method-wise revenue report.
select
    o.payment_method,
    SUM(oi.unit_price * oi.quantity) AS total_revenue
from orders as o
join order_items as oi
    ON o.order_id = oi.order_id
GROUP BY o.payment_method
ORDER BY total_revenue DESC;
-- Generate a category-wise business summary report.
SELECT 
    p.category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.unit_price * oi.quantity) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;
-- Generate a city-wise customer and revenue report.
SELECT 
    c.city,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(oi.unit_price * oi.quantity) AS total_revenue
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY total_revenue DESC;
-- Generate a final executive sales report containing:
SELECT 
    -- Total Revenue
    (SELECT SUM(unit_price * quantity)
     FROM order_items) AS total_revenue,

    -- Total Orders
    (SELECT COUNT(*)
     FROM orders) AS total_orders,

    -- Total Customers
    (SELECT COUNT(*)
     FROM customers) AS total_customers,

    -- Average Order Value
    (
        SELECT AVG(order_total)
        FROM (
            SELECT 
                order_id,
                SUM(unit_price * quantity) AS order_total
            FROM order_items
            GROUP BY order_id
        ) AS avg_orders
    ) AS average_order_value,

    -- Top Selling Product
    (
        SELECT p.product_name
        FROM products AS p
        JOIN order_items AS oi
            ON p.product_id = oi.product_id
        GROUP BY p.product_name
        ORDER BY SUM(oi.quantity) DESC
        LIMIT 1
    ) AS top_selling_product,

    -- Highest Revenue Category
    (
        SELECT p.category
        FROM products AS p
        JOIN order_items AS oi
            ON p.product_id = oi.product_id
        GROUP BY p.category
        ORDER BY SUM(oi.unit_price * oi.quantity) DESC
        LIMIT 1
    ) AS highest_revenue_category;