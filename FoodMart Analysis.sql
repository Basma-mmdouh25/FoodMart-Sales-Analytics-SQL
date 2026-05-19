-- =========================================================
--  FOODMART SALES ANALYTICS PROJECT (PORTFOLIO VERSION)
--  Includes: Data Quality + KPIs + Product + Customer + Time Analysis
-- =========================================================

USE foodmart_sales;

-- =========================================================
-- 1) DATA QUALITY CHECKS
-- =========================================================

-- Check duplicates in dimension tables
SELECT customer_id, COUNT(*) AS cnt
FROM customer
GROUP BY customer_id
HAVING cnt > 1;

SELECT product_id, COUNT(*) AS cnt
FROM product
GROUP BY product_id
HAVING cnt > 1;

SELECT region_id, COUNT(*) AS cnt
FROM region
GROUP BY region_id
HAVING cnt > 1;

SELECT store_id, COUNT(*) AS cnt
FROM store
GROUP BY store_id
HAVING cnt > 1;

-- Check duplicate transactions (fact table integrity)
SELECT transaction_id, COUNT(*) AS cnt
FROM transactions
GROUP BY transaction_id
HAVING cnt > 1;


-- =========================================================
-- 2) REFERENTIAL INTEGRITY CHECKS (Missing Data)
-- =========================================================

-- Orphan product references
SELECT t.transaction_id
FROM transactions t
LEFT JOIN product p ON t.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Orphan customer references
SELECT t.transaction_id
FROM transactions t
LEFT JOIN customer c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Orphan store references
SELECT t.transaction_id
FROM transactions t
LEFT JOIN store s ON t.store_id = s.store_id
WHERE s.store_id IS NULL;


-- =========================================================
-- 3) CORE BUSINESS KPIs
-- =========================================================

-- Total Revenue
SELECT 
    SUM(t.quantity * p.product_retail_price) AS total_revenue
FROM transactions t
JOIN product p ON t.product_id = p.product_id;


-- Total Profit
SELECT 
    SUM(t.quantity * (p.product_retail_price - p.product_cost)) AS total_profit
FROM transactions t
JOIN product p ON t.product_id = p.product_id;


-- Average Order Value (AOV)
SELECT 
    SUM(t.quantity * p.product_retail_price) / COUNT(DISTINCT t.transaction_id) AS AOV
FROM transactions t
JOIN product p ON t.product_id = p.product_id;


-- =========================================================
-- 4) TIME-BASED ANALYSIS
-- =========================================================

-- Monthly Sales Trend
SELECT 
    dt.year,
    dt.month,
    SUM(t.quantity * p.product_retail_price) AS revenue,
    SUM(t.quantity * (p.product_retail_price - p.product_cost)) AS profit
FROM transactions t
JOIN product p ON t.product_id = p.product_id
JOIN dim_date dt ON t.transaction_date = dt.full_date
GROUP BY dt.year, dt.month
ORDER BY dt.year, dt.month;


-- Running Total Revenue (Time Intelligence)
SELECT 
    dt.year,
    dt.month,
    SUM(t.quantity * p.product_retail_price) AS monthly_revenue,
    SUM(SUM(t.quantity * p.product_retail_price)) 
        OVER (ORDER BY dt.year, dt.month) AS running_total
FROM transactions t
JOIN product p ON t.product_id = p.product_id
JOIN dim_date dt ON t.transaction_date = dt.full_date
GROUP BY dt.year, dt.month;


-- =========================================================
-- 5) CUSTOMER ANALYTICS
-- =========================================================

-- Customer Lifetime Value (CLV)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(t.quantity * p.product_retail_price) AS lifetime_value
FROM transactions t
JOIN product p ON t.product_id = p.product_id
JOIN customer c ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY lifetime_value DESC;


-- Customer Segmentation (Data-driven using NTILE)
WITH customer_revenue AS (
    SELECT 
        t.customer_id,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN product p ON t.product_id = p.product_id
    GROUP BY t.customer_id
)
SELECT 
    customer_id,
    revenue,
    NTILE(4) OVER (ORDER BY revenue DESC) AS segment_quartile
FROM customer_revenue;


-- =========================================================
-- 6) PRODUCT ANALYTICS
-- =========================================================

-- Top Products by Revenue
SELECT 
    p.product_id,
    p.product_name,
    p.product_brand,
    SUM(t.quantity) AS units_sold,
    SUM(t.quantity * p.product_retail_price) AS revenue
FROM transactions t
JOIN product p ON t.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.product_brand
ORDER BY revenue DESC
LIMIT 10;


-- Top Products by Profit
SELECT 
    p.product_id,
    p.product_name,
    p.product_brand,
    SUM(t.quantity) AS units_sold,
    SUM(t.quantity * (p.product_retail_price - p.product_cost)) AS profit
FROM transactions t
JOIN product p ON t.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.product_brand
ORDER BY profit DESC
LIMIT 10;


-- Product Popularity (Volume-based)
SELECT 
    p.product_name,
    SUM(t.quantity) AS units_sold,
    SUM(t.quantity * p.product_retail_price) AS revenue
FROM transactions t
JOIN product p ON t.product_id = p.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;


-- =========================================================
-- 7) BRAND PERFORMANCE ANALYSIS
-- =========================================================

SELECT 
    p.product_brand,
    SUM(t.quantity) AS units_sold,
    SUM(t.quantity * p.product_retail_price) AS revenue,
    SUM(t.quantity * (p.product_retail_price - p.product_cost)) AS profit
FROM transactions t
JOIN product p ON t.product_id = p.product_id
GROUP BY p.product_brand
ORDER BY revenue DESC;


-- =========================================================
-- 8) REGIONAL PERFORMANCE
-- =========================================================

-- Revenue by Region
SELECT 
    r.sales_region,
    SUM(t.quantity * p.product_retail_price) AS revenue
FROM transactions t
JOIN product p ON t.product_id = p.product_id
JOIN store s ON t.store_id = s.store_id
JOIN region r ON s.region_id = r.region_id
GROUP BY r.sales_region
ORDER BY revenue DESC;


-- Profit by Region
SELECT 
    r.sales_region,
    SUM(t.quantity * (p.product_retail_price - p.product_cost)) AS profit
FROM transactions t
JOIN product p ON t.product_id = p.product_id
JOIN store s ON t.store_id = s.store_id
JOIN region r ON s.region_id = r.region_id
GROUP BY r.sales_region
ORDER BY profit DESC;

-- =========================================================
-- 8) Time Intelligence
-- =========================================================

-- 1. Month-over-Month (MoM) Growth

WITH monthly_sales AS (
    SELECT 
        dt.year,
        dt.month,
        SUM(t.quantity * p.product_retail_price) AS revenue
    FROM transactions t
    JOIN product p ON t.product_id = p.product_id
    JOIN dim_date dt ON t.transaction_date = dt.full_date
    GROUP BY dt.year, dt.month
)
SELECT 
    year,
    month,
    revenue,
    
    LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue,

    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year, month)) 
        / NULLIF(LAG(revenue) OVER (ORDER BY year, month), 0) * 100,
    2) AS mon_growth_percent

FROM monthly_sales;
