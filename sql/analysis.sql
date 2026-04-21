-- ============================================
-- E-COMMERCE ANALYSIS PROJECT
-- Author: Varshini A S
-- Description: Business insights + recommendation logic
-- ============================================


-- ============================================
-- 1. BASIC DATA EXPLORATION
-- ============================================

-- Total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;


-- Preview customer data
SELECT *
FROM customers
LIMIT 5;


-- ============================================
-- 2. TOP SELLING PRODUCTS
-- ============================================

-- Identify top selling products by volume
SELECT 
    product_id,
    COUNT(*) AS total_sales
FROM order_items
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;


-- ============================================
-- 3. TOP SELLING PRODUCT CATEGORIES
-- ============================================

-- Identify most purchased product categories
SELECT 
    p.product_category_name,
    COUNT(*) AS total_sales
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC
LIMIT 10;


-- ============================================
-- 4. REVENUE ANALYSIS
-- ============================================

-- Highest revenue generating categories
SELECT 
    p.product_category_name,
    ROUND(SUM(oi.price),2) AS revenue
FROM order_items oi
JOIN products p
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;


-- ============================================
-- 5. CATEGORY DEMAND + PRICING
-- ============================================

-- Analyze demand and pricing together
SELECT 
    p.product_category_name,
    COUNT(*) AS total_orders,
    ROUND(AVG(oi.price),2) AS avg_price
FROM order_items oi
JOIN products p
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC, avg_price DESC
LIMIT 10;


-- ============================================
-- 6. CUSTOMER REGION ANALYSIS
-- ============================================

-- Top states by orders and revenue
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price),2) AS revenue
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_orders DESC
LIMIT 10;


-- ============================================
-- 7. CUSTOMER BEHAVIOR ANALYSIS
-- ============================================

-- Identify repeat vs one-time customers
SELECT 
    purchase_count,
    COUNT(*) AS number_of_customers
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS purchase_count
    FROM orders o
    JOIN customers c
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) t
GROUP BY purchase_count
ORDER BY purchase_count;


-- Repeat customer rate
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        100.0 * SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS repeat_customer_rate_pct
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS purchase_count
    FROM orders o
    JOIN customers c
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) t;


-- ============================================
-- 8. RECOMMENDATION SYSTEM (CO-PURCHASE ANALYSIS)
-- ============================================

-- Identify product categories frequently bought together
SELECT 
    p1.product_category_name AS category_A,
    p2.product_category_name AS category_B,
    COUNT(*) AS times_bought_together
FROM order_items a
JOIN order_items b
ON a.order_id = b.order_id
AND a.product_id < b.product_id
JOIN products p1
ON a.product_id = p1.product_id
JOIN products p2
ON b.product_id = p2.product_id
WHERE p1.product_category_name <> p2.product_category_name
GROUP BY category_A, category_B
ORDER BY times_bought_together DESC
LIMIT 20;