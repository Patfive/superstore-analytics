-- File: 02_fct_category_performance.sql
-- Depends on: stg_orders
-- Purpose: Profitability by category/sub-category (KRA: Profitability)

CREATE OR REPLACE VIEW `superstore-analytics-506003.superstore.fct_category_performance` AS
SELECT
  category,
  sub_category,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  SAFE_DIVIDE(SUM(profit), SUM(sales)) AS profit_margin,
  AVG(discount) AS avg_discount,
  COUNT(DISTINCT order_id) AS total_orders
FROM `superstore-analytics-506003.superstore.stg_orders`
GROUP BY category, sub_category
ORDER BY total_profit ASC;

-- Baseline check: confirm true number of distinct category/sub_category combinations in source data.
-- This is the ground truth to compare against fct_category_performance's row count below —
-- if they don't match, something in the GROUP BY or source data (e.g. inconsistent casing/whitespace)
-- needs investigating before trusting the aggregated numbers.
SELECT DISTINCT category, sub_category
FROM `superstore-analytics-506003.superstore.stg_orders`
ORDER BY category, sub_category;

-- Sanity check: row count should equal the distinct combination count confirmed above
SELECT COUNT(*) AS total_combinations
FROM `superstore-analytics-506003.superstore.fct_category_performance`;

-- Quick look: which sub-categories are least profitable?
SELECT *
FROM `superstore-analytics-506003.superstore.fct_category_performance`
LIMIT 5;
