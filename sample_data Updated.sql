-- ============================================================
-- Sample data for the e-commerce schema
-- Run after schema.sql
-- ============================================================

-- CUSTOMERS
INSERT INTO customers (first_name, last_name, email, phone, password_hash) VALUES
('Sarah',      'Johnson',   'sarah.johnson@example.com',      '+1-212-555-0101', 'hash1'),
('Michael',    'Smith',     'michael.smith@example.com',      '+1-310-555-0102', 'hash2'),
('Emily',      'Davis',     'emily.davis@example.com',        '+1-312-555-0103', 'hash3'),
('James',      'Wilson',    'james.wilson@example.com',       '+1-713-555-0104', 'hash4'),
('Jessica',    'Brown',     'jessica.brown@example.com',      '+1-602-555-0105', 'hash5'),
('Christopher','Taylor',    'christopher.taylor@example.com', '+1-206-555-0106', 'hash6'),
('Amanda',     'Martinez',  'amanda.martinez@example.com',    '+1-617-555-0107', 'hash7'),
('Daniel',     'Anderson',  'daniel.anderson@example.com',    '+1-303-555-0108', 'hash8');

-- ADDRESSES
INSERT INTO addresses (customer_id, address_line1, city, state, postal_code, country, address_type) VALUES
(1, '123 Main Street',     'New York',    'NY', '10001', 'USA', 'shipping'),
(1, '123 Main Street',     'New York',    'NY', '10001', 'USA', 'billing'),
(2, '456 Sunset Blvd',     'Los Angeles', 'CA', '90028', 'USA', 'shipping'),
(3, '789 Michigan Ave',    'Chicago',     'IL', '60611', 'USA', 'shipping'),
(4, '321 Westheimer Rd',   'Houston',     'TX', '77006', 'USA', 'shipping'),
(5, '654 Camelback Rd',    'Phoenix',     'AZ', '85013', 'USA', 'shipping'),
(6, '987 Pine Street',     'Seattle',     'WA', '98101', 'USA', 'shipping'),
(7, '159 Boylston St',     'Boston',      'MA', '02116', 'USA', 'shipping'),
(8, '753 16th Street',     'Denver',      'CO', '80202', 'USA', 'shipping');

-- CATEGORIES  (parent first, subcategories second)
INSERT INTO categories (category_name, parent_category_id) VALUES
('Electronics', NULL),
('Home & Kitchen', NULL),
('Fashion', NULL),
('Sports & Outdoors', NULL);

INSERT INTO categories (category_name, parent_category_id) VALUES
('Laptops', 1),
('Phones', 1),
('Cookware', 2);

-- SUPPLIERS
INSERT INTO suppliers (supplier_name, contact_email, contact_phone) VALUES
('TechHub Distributors',   'sales@techhub.com',   '+254711000111'),
('HomeStyle Wholesale',    'info@homestyle.com',  '+254711000222'),
('UrbanWear Ltd',          'contact@urbanwear.com','+254711000333'),
('OutdoorGear Supplies',   'support@outdoorgear.com','+254711000444');

-- PRODUCTS
INSERT INTO products (product_name, description, price, stock_quantity, category_id, supplier_id) VALUES
('UltraBook 14 Laptop',      '14-inch lightweight laptop, 16GB RAM',      899.99, 25, 5, 1),
('ProBook 15 Laptop',        '15-inch business laptop, 8GB RAM',          649.50, 18, 5, 1),
('SmartPhone X12',           '6.5-inch display, 128GB storage',           499.00, 40, 6, 1),
('SmartPhone Lite',          'Budget-friendly smartphone, 64GB storage',  219.99, 60, 6, 1),
('Non-Stick Frying Pan',     '28cm aluminium non-stick pan',               24.99, 100, 7, 2),
('Stainless Steel Pot Set',  '5-piece cooking pot set',                    79.99, 35, 7, 2),
('Cotton T-Shirt',           'Unisex crew-neck cotton t-shirt',            12.99, 200, 3, 3),
('Denim Jacket',             'Classic blue denim jacket',                  45.50, 50, 3, 3),
('Running Shoes',            'Lightweight breathable running shoes',       59.99, 70, 4, 4),
('Camping Tent (4-person)',  'Waterproof 4-person camping tent',          129.99, 20, 4, 4),
('Yoga Mat',                 'Non-slip 6mm exercise mat',                  19.99, 150, 4, 4),
('Bluetooth Headphones',     'Over-ear wireless headphones, 30h battery', 89.99, 45, 1, 1);

-- ORDERS
INSERT INTO orders (customer_id, shipping_address_id, order_date, status, total_amount) VALUES
(1, 1, '2026-01-05 10:15:00', 'delivered',  924.98),
(2, 3, '2026-01-08 14:30:00', 'delivered',  499.00),
(3, 4, '2026-02-02 09:00:00', 'shipped',    104.98),
(4, 5, '2026-02-14 16:45:00', 'delivered',   58.49),
(5, 6, '2026-03-01 11:20:00', 'processing', 649.50),
(6, 7, '2026-03-10 13:10:00', 'delivered',  149.98),
(7, 8, '2026-03-22 08:05:00', 'pending',    219.99),
(8, 9, '2026-04-02 17:40:00', 'delivered',  219.97),
(1, 1, '2026-04-15 12:00:00', 'delivered',   89.99),
(3, 4, '2026-05-01 10:30:00', 'cancelled',   45.50);

-- ORDER_ITEMS (unit_price captured at time of purchase)
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 899.99),
(1, 7, 2, 12.49),
(2, 3, 1, 499.00),
(3, 9, 1, 59.99),
(3, 5, 1, 24.99),
(3, 11, 1, 19.99),
(4, 7, 2, 12.99),
(4, 11, 1, 19.99),
(5, 2, 1, 649.50),
(6, 8, 1, 45.50),
(6, 11, 1, 19.99),
(6, 7, 3, 12.99),
(7, 4, 1, 219.99),
(8, 4, 1, 219.99),
(9, 12, 1, 89.99),
(10, 8, 1, 45.50);

-- PAYMENTS
INSERT INTO payments (order_id, payment_method, amount, payment_status) VALUES
(1, 'credit_card',     924.98, 'completed'),
(2, 'paypal',           499.00, 'completed'),
(3, 'credit_card',      104.98, 'completed'),
(4, 'cash_on_delivery',  58.49, 'completed'),
(5, 'bank_transfer',    649.50, 'pending'),
(6, 'credit_card',      149.98, 'completed'),
(7, 'paypal',           219.99, 'pending'),
(8, 'credit_card',      219.97, 'completed'),
(9, 'paypal',            89.99, 'completed'),
(10,'credit_card',       45.50, 'refunded');

-- REVIEWS
INSERT INTO reviews (customer_id, product_id, rating, comment) VALUES
(1, 1, 5, 'Excellent build quality and battery life.'),
(2, 3, 4, 'Great phone for the price.'),
(3, 9, 5, 'Very comfortable, true to size.'),
(3, 5, 4, 'Cooks evenly, easy to clean.'),
(4, 7, 3, 'Decent quality but runs a bit small.'),
(6, 8, 5, 'Love the fit and material.'),
(6, 11, 4, 'Good grip, slightly thin.'),
(8, 4, 4, 'Good value smartphone.'),
(1, 12, 5, 'Sound quality exceeded expectations.');
