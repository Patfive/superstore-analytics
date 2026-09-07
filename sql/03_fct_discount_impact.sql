-- File: 03_fct_discount_impact.sql
-- Depends on: stg_orders
-- Purpose: Test whether higher discount levels are associated with profit loss (KRA: Profitability)

CREATE OR REPLACE VIEW `superstore-analytics-506003.superstore.fct_discount_impact` AS
SELECT
  CASE
    WHEN discount = 0 THEN '0%'
    WHEN discount <= 0.10 THEN '1-10%'
    WHEN discount <= 0.20 THEN '11-20%'
    WHEN discount <= 0.30 THEN '21-30%'
    WHEN discount <= 0.40 THEN '31-40%'
    WHEN discount <= 0.50 THEN '41-50%'
    ELSE '50%+'
  END AS discount_band,
  COUNT(*) AS total_line_items,
  COUNT(DISTINCT order_id) AS total_orders,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  SAFE_DIVIDE(SUM(profit), SUM(sales)) AS profit_margin
FROM `superstore-analytics-506003.superstore.stg_orders`
GROUP BY discount_band
ORDER BY discount_band;

-- Baseline check: confirm discount values in source data fall within expected 0.0–1.0 range
-- (if MAX is higher than 1, discount may be stored as a whole number like 50 instead of 0.50)
SELECT MIN(discount) AS min_discount, MAX(discount) AS max_discount
FROM `superstore-analytics-506003.superstore.stg_orders`;

-- Check for NULL discount values that would silently misclassify into '50%+' band
SELECT COUNT(*) AS null_discount_rows
FROM `superstore-analytics-506003.superstore.stg_orders`
WHERE discount IS NULL;

-- Sanity check: total_line_items across bands should equal 9994 (matches stg_orders line-item count)
-- Note: total_orders across bands will NOT sum to 5009 distinct orders — this is expected,
-- since a single order can span multiple discount bands (discount is set per line item).
SELECT SUM(total_line_items) AS summed_line_items
FROM `superstore-analytics-506003.superstore.fct_discount_impact`;

-- Content check: does profit_margin decline as discount_band increases?
SELECT *
FROM `superstore-analytics-506003.superstore.fct_discount_impact`
ORDER BY discount_band;

-- CONCLUSION: profit_margin declines sharply as discount_band increases, turning negative
-- above ~20% discount and reaching -119% margin at 50%+. This confirms the hypothesis that
-- excessive discounting — not weak product demand — is the primary driver of losses seen
-- in fct_category_performance (notably Tables and Bookcases).
