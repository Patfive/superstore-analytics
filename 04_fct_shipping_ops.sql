-- File: 04_fct_shipping_ops.sql
-- Depends on: stg_orders
-- Purpose: Shipping delay and return rate by ship_mode and region (KRA: Operations)

CREATE OR REPLACE VIEW `superstore-analytics-506003.superstore.fct_shipping_ops` AS
SELECT
  ship_mode,
  region,
  COUNT(*) AS total_line_items,
  COUNT(DISTINCT order_id) AS total_orders,
  AVG(shipping_delay_days) AS avg_shipping_delay,
  COUNTIF(is_returned) AS returned_line_items,
  SAFE_DIVIDE(COUNTIF(is_returned), COUNT(*)) AS return_rate
FROM `superstore-analytics-506003.superstore.stg_orders`
GROUP BY ship_mode, region
ORDER BY ship_mode, region;

-- Baseline check: shipping_delay_days should never be negative
-- (a negative value would mean Ship Date is before Order Date — a data error)
SELECT MIN(shipping_delay_days) AS min_delay, MAX(shipping_delay_days) AS max_delay
FROM `superstore-analytics-506003.superstore.stg_orders`;

-- Baseline check: confirm the true distinct ship_mode/region combinations in source data
SELECT DISTINCT ship_mode, region
FROM `superstore-analytics-506003.superstore.stg_orders`
ORDER BY ship_mode, region;

-- Structural check: row count should match the distinct combination count confirmed above
SELECT COUNT(*) AS total_combinations
FROM `superstore-analytics-506003.superstore.fct_shipping_ops`;

-- Structural check: total_line_items across all combinations should equal 9994
SELECT SUM(total_line_items) AS summed_line_items
FROM `superstore-analytics-506003.superstore.fct_shipping_ops`;

-- Content check: which ship_mode/region pairs have the slowest delivery and/or highest return rate?
SELECT *
FROM `superstore-analytics-506003.superstore.fct_shipping_ops`
ORDER BY return_rate DESC;

-- CONCLUSION: shipping_delay_days shows no data quality issues (range 0-7 days, no negatives).
-- Return rate shows a strong REGIONAL pattern rather than a shipping-mode pattern: West region
-- has the highest return rate across all four ship modes (13.4%-23.2%), while South region
-- consistently shows the lowest (0%-5.9%). This suggests the return driver is region-specific
-- (product mix, fulfillment center, or customer base) rather than shipping speed itself.