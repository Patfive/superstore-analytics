-- File: 06_dim_customers.sql
-- Depends on: stg_orders
-- Purpose: One row per customer with order history and repeat-purchase flag (KRA: Customer Behavior)

CREATE OR REPLACE VIEW `superstore-analytics-506003.superstore.dim_customers` AS
SELECT
  customer_id,
  customer_name,
  segment,
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  DATE_DIFF(MAX(order_date), MIN(order_date), DAY) AS customer_lifespan_days,
  COUNT(DISTINCT order_id) AS total_orders,
  SUM(sales) AS lifetime_value,
  SUM(profit) AS lifetime_profit,
  CASE WHEN COUNT(DISTINCT order_id) > 1 THEN TRUE ELSE FALSE END AS is_repeat_customer
FROM `superstore-analytics-506003.superstore.stg_orders`
GROUP BY customer_id, customer_name, segment;

-- Baseline check: confirm each customer_id maps to exactly one customer_name and segment
-- (if this fails, grouping by all three columns would silently split one customer into
-- multiple rows — a common data quality issue with denormalized source data)
-- RESULT: 0 rows returned — confirmed clean, no customer_id has conflicting name/segment values
SELECT customer_id, COUNT(DISTINCT customer_name) AS name_variants, COUNT(DISTINCT segment) AS segment_variants
FROM `superstore-analytics-506003.superstore.stg_orders`
GROUP BY customer_id
HAVING name_variants > 1 OR segment_variants > 1;

-- Structural check: row count should equal the true distinct customer count in source data
SELECT COUNT(DISTINCT customer_id) AS true_distinct_customers
FROM `superstore-analytics-506003.superstore.stg_orders`;

SELECT COUNT(*) AS dim_customers_row_count
FROM `superstore-analytics-506003.superstore.dim_customers`;

-- Content check: repeat vs one-time customer split, and value comparison between the two groups
SELECT
  is_repeat_customer,
  COUNT(*) AS customer_count,
  AVG(total_orders) AS avg_orders,
  AVG(lifetime_value) AS avg_lifetime_value,
  AVG(lifetime_profit) AS avg_lifetime_profit
FROM `superstore-analytics-506003.superstore.dim_customers`
GROUP BY is_repeat_customer;

-- Gut-check: confirm the true date range of the dataset (a long time span makes
-- a 98.5% repeat rate more plausible — most customers would reorder eventually)
SELECT MIN(order_date) AS earliest_order, MAX(order_date) AS latest_order
FROM `superstore-analytics-506003.superstore.stg_orders`;

-- Fairer comparison: average value PER ORDER, not total lifetime value
-- This controls for the fact that repeat customers mechanically have higher totals
SELECT
  is_repeat_customer,
  COUNT(*) AS customer_count,
  AVG(total_orders) AS avg_orders,
  AVG(lifetime_value) AS avg_lifetime_value,
  AVG(SAFE_DIVIDE(lifetime_value, total_orders)) AS avg_value_per_order,
  AVG(SAFE_DIVIDE(lifetime_profit, total_orders)) AS avg_profit_per_order
FROM `superstore-analytics-506003.superstore.dim_customers`
GROUP BY is_repeat_customer;

-- Follow-up: do repeat customers receive higher discounts on average, explaining lower per-order profit?
SELECT
  c.is_repeat_customer,
  AVG(o.discount) AS avg_discount_per_line_item
FROM `superstore-analytics-506003.superstore.stg_orders` o
JOIN `superstore-analytics-506003.superstore.dim_customers` c
  ON o.customer_id = c.customer_id
GROUP BY c.is_repeat_customer;

-- CONCLUSION: 781 of 793 customers (98.5%) are repeat buyers, plausible given the 4-year
-- dataset span (Jan 2014-Dec 2017). Initial "repeat customers worth 6x more" framing based on
-- lifetime_value totals is misleading — it reflects order FREQUENCY, not per-order behavior.
-- Per-order value is nearly identical ($460.60 repeat vs $430.64 one-time), and per-order
-- profit is actually LOWER for repeat customers ($54.78 vs $63.95). This gap is NOT explained
-- by discount levels (15.62% vs 15.56%, essentially equal) — root cause remains unidentified
-- and would need product-mix or category-level analysis to isolate further.
