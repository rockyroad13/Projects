/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
SELECT
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold_fact_sales f
LEFT JOIN gold_dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
YEAR(f.order_date),
p.product_name
)

SELECT 
order_year,
product_name,
current_sales,

AVG(current_sales) OVER (PARTITION by product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION by product_name) as diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION by product_name) > 0 THEN "Above Avg"
     WHEN current_sales - AVG(current_sales) OVER (PARTITION by product_name) < 0 THEN "Below Avg"
     ELSE 'Avg'
END avg_change,
-- Year-over-year Analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) prev_sales,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN "Increase"
     WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN "Decrease"
     ELSE 'No Change'
END prev_change

FROM yearly_product_sales
ORDER BY product_name, order_year
