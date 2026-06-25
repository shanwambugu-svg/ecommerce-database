-- ============================================================
-- E-commerce Platform Database Schema
-- Engine: PostgreSQL (free, open-source)
-- ============================================================

DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ------------------------------------------------------------
-- CUSTOMERS
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    password_hash   VARCHAR(255) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- ADDRESSES  (1 customer : many addresses)
-- ------------------------------------------------------------
CREATE TABLE addresses (
    address_id      SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    address_line1   VARCHAR(100) NOT NULL,
    address_line2   VARCHAR(100),
    city            VARCHAR(50)  NOT NULL,
    state           VARCHAR(50),
    postal_code     VARCHAR(20)  NOT NULL,
    country         VARCHAR(50)  NOT NULL,
    address_type    VARCHAR(10)  NOT NULL CHECK (address_type IN ('shipping','billing'))
);

-- ------------------------------------------------------------
-- CATEGORIES  (self-referencing for subcategories)
-- ------------------------------------------------------------
CREATE TABLE categories (
    category_id         SERIAL PRIMARY KEY,
    category_name       VARCHAR(50) NOT NULL UNIQUE,
    parent_category_id  INT REFERENCES categories(category_id) ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- SUPPLIERS
-- ------------------------------------------------------------
CREATE TABLE suppliers (
    supplier_id     SERIAL PRIMARY KEY,
    supplier_name   VARCHAR(100) NOT NULL,
    contact_email   VARCHAR(100),
    contact_phone   VARCHAR(20)
);

-- ------------------------------------------------------------
-- PRODUCTS
-- ------------------------------------------------------------
CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    description     TEXT,
    price           DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity  INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id     INT REFERENCES categories(category_id) ON DELETE SET NULL,
    supplier_id     INT REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- ORDERS
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id            SERIAL PRIMARY KEY,
    customer_id         INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    shipping_address_id INT REFERENCES addresses(address_id) ON DELETE SET NULL,
    order_date          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status              VARCHAR(20) NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','processing','shipped','delivered','cancelled')),
    total_amount        DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0)
);

-- ------------------------------------------------------------
-- ORDER_ITEMS  (resolves the many-to-many between orders and products)
-- ------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      INT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    UNIQUE (order_id, product_id)
);

-- ------------------------------------------------------------
-- PAYMENTS  (1:1 with orders)
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id      SERIAL PRIMARY KEY,
    order_id        INT NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_method  VARCHAR(20) NOT NULL
                    CHECK (payment_method IN ('credit_card','paypal','bank_transfer','cash_on_delivery')),
    amount          DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_date    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status  VARCHAR(20) NOT NULL DEFAULT 'pending'
                    CHECK (payment_status IN ('pending','completed','failed','refunded'))
);

-- ------------------------------------------------------------
-- REVIEWS
-- ------------------------------------------------------------
CREATE TABLE reviews (
    review_id       SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    product_id      INT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    rating          INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment         TEXT,
    review_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (customer_id, product_id)
);

-- ============================================================
-- INDEXES
-- Beyond the automatic indexes PostgreSQL creates for PRIMARY KEY
-- and UNIQUE constraints, add indexes on foreign keys and columns
-- used heavily in WHERE/JOIN/ORDER BY clauses.
-- ============================================================
CREATE INDEX idx_addresses_customer       ON addresses(customer_id);
CREATE INDEX idx_products_category        ON products(category_id);
CREATE INDEX idx_products_supplier        ON products(supplier_id);
CREATE INDEX idx_orders_customer          ON orders(customer_id);
CREATE INDEX idx_orders_order_date        ON orders(order_date);
CREATE INDEX idx_order_items_order        ON order_items(order_id);
CREATE INDEX idx_order_items_product      ON order_items(product_id);
CREATE INDEX idx_reviews_product          ON reviews(product_id);
CREATE INDEX idx_payments_order           ON payments(order_id);
