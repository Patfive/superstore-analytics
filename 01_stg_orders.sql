-- File: 01_stg_orders.sql
-- Depends on: raw_orders, raw_returns
-- Purpose: Cleans column names, adds shipping delay and return flag

-- stg_orders: cleaned + return flag + shipping delay
CREATE OR REPLACE VIEW `superstore-analytics-506003.superstore.stg_orders` AS
SELECT
  o.`Order ID` AS order_id,
  o.`Order Date` AS order_date,
  o.`Ship Date` AS ship_date,
  o.`Ship Mode` AS ship_mode,
  o.`Customer ID` AS customer_id,
  o.`Customer Name` AS customer_name,
  o.`Segment` AS segment,
  o.`Region` AS region,
  o.`Category` AS category,
  o.`Sub-Category` AS sub_category,
  o.`Sales` AS sales,
  o.`Quantity` AS quantity,
  o.`Discount` AS discount,
  o.`Profit` AS profit,
  DATE_DIFF(o.`Ship Date`, o.`Order Date`, DAY) AS shipping_delay_days,
  -- Note: grain of this view is one row per line item, not per order.
  -- A returned Order ID can span multiple line-item rows, so is_returned
  -- is flagged TRUE on every line item within that order (see sanity checks below).
  CASE WHEN r.Returned IS TRUE THEN TRUE ELSE FALSE END AS is_returned
FROM `superstore-analytics-506003.superstore.raw_orders` o
LEFT JOIN `superstore-analytics-506003.superstore.raw_returns` r
  ON o.`Order ID` = r.`Order ID`;

-- Sanity check: expect 9994 rows (should match raw_orders row count)
SELECT COUNT(*) AS total_rows
FROM `superstore-analytics-506003.superstore.stg_orders`;

-- Sanity check: is_returned=TRUE returns 800 rows, NOT 296.
-- This is expected: grain is line-item level, and a returned order can have
-- multiple line items, all flagged TRUE. Use COUNT(DISTINCT order_id) below
-- to validate at the order level instead.
SELECT is_returned, COUNT(*) AS row_count
FROM `superstore-analytics-506003.superstore.stg_orders`
GROUP BY is_returned;

-- Sanity check: distinct returned orders should be ~296 (matches raw_returns row count)
SELECT COUNT(DISTINCT order_id) AS distinct_returned_orders
FROM `superstore-analytics-506003.superstore.stg_orders`
WHERE is_returned = TRUE;