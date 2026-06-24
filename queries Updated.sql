-- ============================================================
-- Demonstration queries for the e-commerce schema
-- Organized by what each section is meant to demonstrate,
-- matching the "Functionality and Query Implementation" criteria.
-- ============================================================


-- ------------------------------------------------------------
-- 1. CREATE (INSERT)
-- ------------------------------------------------------------

-- Add a new customer
INSERT INTO customers (first_name, last_name, email, phone, password_hash)
VALUES ('Kevin', 'Thompson', 'kevin.thompson@example.com', '+1-503-555-0109', 'hash9');

-- Place a new order for that customer (assumes shipping address added separately)
INSERT INTO addresses (customer_id, address_line1, city, state, postal_code, country, address_type)
VALUES (9, '5 Sample Lane', 'Portland', 'OR', '97201', 'USA', 'shipping');

INSERT INTO orders (customer_id, shipping_address_id, status, total_amount)
VALUES (9, 10, 'pending', 0);

-- Add an item to that order, then update the order total to match
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (11, 6, 1, 79.99);

UPDATE orders SET total_amount = 79.99 WHERE order_id = 11;


-- ------------------------------------------------------------
-- 2. READ (SELECT)
-- ------------------------------------------------------------

-- All products currently in stock, cheapest first
SELECT product_name, price, stock_quantity
FROM products
WHERE stock_quantity > 0
ORDER BY price ASC;

-- A single customer's profile plus their default shipping address
SELECT c.first_name, c.last_name, c.email, a.city, a.country
FROM customers c
JOIN addresses a ON a.customer_id = c.customer_id AND a.address_type = 'shipping'
WHERE c.customer_id = 1;


-- ------------------------------------------------------------
-- 3. UPDATE
-- ------------------------------------------------------------

-- Restock a product
UPDATE products
SET stock_quantity = stock_quantity + 20
WHERE product_id = 5;

-- Mark an order as shipped
UPDATE orders
SET status = 'shipped'
WHERE order_id = 7;


-- ------------------------------------------------------------
-- 4. DELETE
-- ------------------------------------------------------------

-- Remove a review (e.g. retracted by the customer)
DELETE FROM reviews
WHERE customer_id = 4 AND product_id = 7;

-- Cancel and remove an order entirely (cascades to its order_items and payment)
DELETE FROM orders
WHERE order_id = 11;


-- ------------------------------------------------------------
-- 5. JOINS — combining data across tables
-- ------------------------------------------------------------

-- Full order detail: customer, products ordered, quantities, and line totals
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
ORDER BY o.order_id;

-- Orders with their payment status (LEFT JOIN in case a payment record is missing)
SELECT o.order_id, o.status AS order_status, p.payment_method, p.payment_status
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
ORDER BY o.order_id;

-- Products with their category and supplier names
SELECT pr.product_name, c.category_name, s.supplier_name
FROM products pr
LEFT JOIN categories c ON c.category_id = pr.category_id
LEFT JOIN suppliers s  ON s.supplier_id = pr.supplier_id
ORDER BY c.category_name, pr.product_name;


-- ------------------------------------------------------------
-- 6. AGGREGATIONS — business-style reporting
-- ------------------------------------------------------------

-- Total revenue and number of orders per customer
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id)          AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC;

-- Revenue per product category
SELECT
    cat.category_name,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM order_items oi
JOIN products p   ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
GROUP BY cat.category_name
ORDER BY category_revenue DESC;

-- Average rating per product (only products with at least one review)
SELECT
    p.product_name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id)      AS review_count
FROM products p
JOIN reviews r ON r.product_id = p.product_id
GROUP BY p.product_name
HAVING COUNT(r.review_id) >= 1
ORDER BY avg_rating DESC;

-- Monthly order volume and revenue
SELECT
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*)            AS orders_placed,
    SUM(total_amount)   AS revenue
FROM orders
GROUP BY month
ORDER BY month;


-- ------------------------------------------------------------
-- 7. COMPLEX FILTERS / SUBQUERIES
-- ------------------------------------------------------------

-- Customers who have spent more than the average customer
SELECT customer_name, total_spent
FROM (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        COALESCE(SUM(o.total_amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, customer_name
) spending
WHERE total_spent > (SELECT AVG(total_amount) FROM orders)
ORDER BY total_spent DESC;

-- Products that are low in stock (below 25 units) and have never been ordered
SELECT p.product_name, p.stock_quantity
FROM products p
WHERE p.stock_quantity < 25
  AND p.product_id NOT IN (SELECT DISTINCT product_id FROM order_items);

-- Customers who placed an order but have never left a review
SELECT DISTINCT c.first_name, c.last_name, c.email
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE c.customer_id NOT IN (SELECT DISTINCT customer_id FROM reviews);

-- Top 3 best-selling products by quantity sold
SELECT p.product_name, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC
LIMIT 3;
