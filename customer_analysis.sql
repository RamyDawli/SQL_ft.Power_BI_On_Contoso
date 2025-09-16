/*This query performs a cohort revenue and retention analysis: 
it groups customers by the year they first purchased
and then tracks their revenue and activity in subsequent years.*/

WITH yearly_cohort AS (
    SELECT DISTINCT
        customerkey,
        EXTRACT(YEAR FROM MIN(orderdate) OVER(PARTITION BY customerkey)) AS cohort_year
    FROM 
        sales
)

SELECT 
    cohort_year,
    EXTRACT(YEAR FROM s.orderdate) as purchase_date,
    CAST(SUM (s.quantity * s.netprice * s.exchangerate) AS INTEGER) AS net_revenue,
    COUNT (DISTINCT yearly_cohort.customerkey) AS num_customer
FROM yearly_cohort
LEFT JOIN sales s ON yearly_cohort.customerkey = s.customerkey
GROUP BY yearly_cohort.cohort_year, purchase_date
ORDER BY cohort_year;


/*This query calculates the customer lifetime value (LTV) for each customer
and compare it to the average Life-Time-Value for each cohort year.*/

WITH ltv AS (SELECT 
    customerkey,
    EXTRACT (YEAR FROM MIN(orderdate)) AS cohort_year,
    SUM(quantity * netprice * exchangerate) AS customer_lt_spending
FROM sales
GROUP BY customerkey
)

SELECT 
    *,
    AVG(ltv.customer_lt_spending) OVER (PARTITION BY ltv.cohort_year) AS customer_ltv
FROM ltv;



/*This query calculates the total revenue and total number of customers
for each year.*/
SELECT 
    EXTRACT (YEAR FROM orderdate) as cohort_year,
    CAST(SUM(quantity * netprice * exchangerate) AS INTEGER) as Total_revenue,
    COUNT (DISTINCT customerkey) as total_customer
FROM sales 
GROUP BY cohort_year
ORDER BY cohort_year
;




/*This query calculates the customer lifetime value (LTV) based on their total spending, 
and categorizes customers into segments based on their LTV whether they are low (< 25th percentile), 
mid (25th-75th percentile), or high (> 75th percentile) value.*/
WITH customer_ltv AS (
    SELECT 
    s.customerkey,
    SUM(s.quantity * s.netprice * s.exchangerate) as Net_spending,
    CONCAT (c.givenname, ' ', c.surname) as Full_name
FROM 
    sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
GROUP BY s.customerkey, Full_name
ORDER BY s.customerkey
), 

customer_segment AS (
        
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Net_spending) AS ltv_25th_percentile,
        PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Net_spending) AS ltv_75th_percentile
    FROM customer_ltv), 

segemnt_values AS (
    SELECT customer_ltv.*, 
    CASE 
        WHEN customer_ltv.Net_spending < customer_segment.ltv_25th_percentile THEN '1- LOW-Value'
        WHEN customer_ltv.Net_spending <= customer_segment.ltv_75th_percentile THEN '2- MID-Value' 
        ELSE '3- HIGH-Value'
    END AS customer_segment
FROM 
customer_ltv, customer_segment
) 

SELECT 
    customer_segment,
    CAST(SUM(Net_spending) AS INTEGER) AS Total_spending,
    COUNT(customerkey) AS Num_customer,
    CAST(SUM(Net_spending) AS INTEGER) / COUNT(customerkey) AS Average_spending_customer
FROM segemnt_values
GROUP BY customer_segment
ORDER BY customer_segment
;


/*This query identifies active customers for the last 6 months. However, it excludes
customers who made their first purchase within the last 6 months to avoid counting new customers as active.
It can be edited to calculated the number of each segment (active vs churned) by modifying the select 
stetement at the end by uncommenting the commented lines.
*/
WITH customer_last_purchasing_date AS (
SELECT 
    sales.customerkey,
    CONCAT(c.givenname, ' ', c.surname) AS FULL_NAME,
    MAX(sales.orderdate) AS last_purchase_date,
    MIN(sales.orderdate) AS first_purchase_date
FROM 
    sales
LEFT JOIN customer c ON sales.customerkey = c.customerkey
GROUP BY sales.customerkey, FULL_NAME
ORDER BY customerkey

), 
customer_overview AS (SELECT 
    customerkey,
    full_name,
    last_purchase_date,
    CASE 
        WHEN customer_last_purchasing_date.last_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'
        ELSE 'Active'
    END AS customer_status
FROM customer_last_purchasing_date
WHERE first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)

SELECT 
    *
    --customer_status,
    --COUNT (customerkey) AS num_customer,
    --CAST(COUNT (customerkey) * 100.0 / (SELECT COUNT (customerkey) FROM customer_overview) AS DECIMAL(5,2)) AS percentage_customer
    
FROM customer_overview
ORDER BY customerkey
--GROUP BY customer_status
--ORDER BY num_customer

