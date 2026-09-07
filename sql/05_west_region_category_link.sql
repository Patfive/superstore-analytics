-- File: 05_west_region_category_link.sql
-- Depends on: stg_orders
-- Purpose: Investigate whether West region's high return rate is concentrated in
--          specific categories — particularly Tables/Bookcases (ties to fct_category_performance
--          and fct_discount_impact findings)

-- Where do Tables/Bookcases rank within West, on BOTH return rate and profit?
SELECT
  category,
  sub_category,
  COUNT(*) AS total_line_items,
  SAFE_DIVIDE(COUNTIF(is_returned), COUNT(*)) AS return_rate,
  SUM(profit) AS total_profit,
  RANK() OVER (ORDER BY SAFE_DIVIDE(COUNTIF(is_returned), COUNT(*)) DESC) AS return_rate_rank,
  RANK() OVER (ORDER BY SUM(profit) ASC) AS profit_loss_rank
FROM `superstore-analytics-506003.superstore.stg_orders`
WHERE region = 'West'
GROUP BY category, sub_category;

-- CONCLUSION: Hypothesis NOT confirmed. Bookcases (worst profit, rank 1) ranks only 13th of 17
-- on return rate in West; Tables (rank 5 on profit loss) ranks 7th on return rate. West's
-- elevated return rate is instead concentrated in Fasteners, Machines, and Appliances —
-- categories unrelated to the profitability losses found in fct_category_performance.
-- Exception: Machines is a dual-problem category (rank 2 on both return rate and profit loss),
-- worth flagging separately for further investigation.
