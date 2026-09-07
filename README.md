# Superstore Sales & Operations Analysis

A KRA-driven data analysis project examining profitability, shipping operations, and customer behavior for a retail business, built end-to-end using **BigQuery (SQL)** and **Power BI**.

**Dataset:** [Superstore Sales dataset (Kaggle)](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)
**Period covered:** January 2014 – December 2017
**Tools:** Google BigQuery · SQL · Power BI

---

## Project Overview

This project analyzes a retail Superstore dataset across four Key Result Areas (KRAs): **Profitability, Operations, Customer Behavior,** and overall **Business Performance**. Each analysis was built as a validated SQL view in BigQuery, then visualized in a 5-page interactive Power BI dashboard.

Rather than presenting only clean, confirmatory findings, this project documents the full investigative process — including two hypotheses that were tested and **disconfirmed** by the data, which are reported transparently alongside the confirmed findings.

---

## KRA → KPI Framework

| KRA | KPIs Tracked |
|---|---|
| Business Performance | Total sales, total profit, total orders, seasonal trend |
| Profitability | Profit by category/sub-category, profit margin by discount level |
| Operations | Return rate by ship mode & region, average shipping delay |
| Customer Behavior | Repeat vs. one-time customer split, value/profit per order |

---

## Key Findings

1. **Discount-driven losses:** Tables, Bookcases, and Supplies are the only unprofitable sub-categories (combined –$22.4K). Profit margin turns negative once discounts exceed ~20%, and collapses further above 50% discount.

2. **Regional return-rate anomaly:** The West region shows the highest return rate across *every* shipping mode (13%–23%), while shipping delays remain consistent company-wide — indicating the driver is region-specific, not a fulfillment speed issue. A follow-up investigation ruled out a link to the loss-making sub-categories above (Tables/Bookcases were not among West's highest-return categories).

3. **Repeat customers ≠ higher-value customers:** 98.5% of customers are repeat buyers, but this reflects a 4-year purchase window rather than exceptional loyalty. Per-order value is nearly identical between repeat and one-time customers ($461 vs. $431), and one-time customers are actually *more* profitable per order ($64 vs. $55) — a result not explained by discount levels, which are nearly equal between the two groups.

4. **Consistent seasonality with underlying growth:** Sales show a repeating Q4 peak / Q1 trough pattern every year from 2014–2017, with both the peaks and troughs trending upward year-over-year — indicating real business growth beneath a predictable seasonal cycle.

---

## Repository Structure

```
/sql
  01_stg_orders.sql                     -- Staging layer: cleaned columns, return flag, shipping delay
  02_fct_category_performance.sql       -- Profitability by category/sub-category
  03_fct_discount_impact.sql            -- Profit margin by discount band
  04_fct_shipping_ops.sql               -- Return rate & shipping delay by ship mode/region
  05_west_region_category_link.sql      -- Investigation: West returns vs. loss-making categories
  06_dim_customers.sql                  -- Customer dimension: repeat vs. one-time behavior

/dashboard
  superstore_dashboard.pbix             -- Power BI report (5 pages)

/data
  superstore_kaggle.xlsx                -- Source dataset (Orders, Returns, People)
```

---

## Methodology

Every SQL view in this project follows the same validation pattern:

1. **Build** — the transformation or aggregation logic
2. **Baseline check** — verify the raw input data is clean before trusting any logic built on it (e.g., value ranges, NULL checks)
3. **Structural check** — confirm the transformation produced the expected shape (row counts, distinct combinations)
4. **Content check** — inspect the actual values for correctness and insight
5. **Conclusion** — a stated, one-paragraph takeaway, written even when the result disproves the original hypothesis

This structure is intentional: it demonstrates not just SQL syntax, but a habit of verifying assumptions against data rather than accepting first-pass results at face value.

---

## Dashboard Pages

| Page | Focus |
|---|---|
| **Title / Overview** | Project summary and navigation |
| **Performance Overview** | Company-wide KPIs and quarterly sales/profit trend |
| **Profitability** | Category profit performance and discount-margin relationship |
| **Operations** | Return rate heatmap by shipping mode and region |
| **Customer Behavior** | Repeat vs. one-time customer value and profitability comparison |

---

## Tech Stack

- **Google BigQuery** — data warehousing, SQL transformation layer
- **SQL** — staging, aggregation, and validation logic
- **Power BI** — data modeling, DAX measures, dashboard visualization

---

## Author

Patrick Cinco
