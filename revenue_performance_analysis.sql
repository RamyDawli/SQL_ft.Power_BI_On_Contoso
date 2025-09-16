/* This query retrieves a detailed revenue overview from sales along with 
customer name and product bought for orders placed after January 1, 2020.
It joins the sales, customer, and product tables, in order to get info about
the customers and products associated with each order.*/
SELECT 
    s.orderdate,
    s.quantity * s.netprice * s.exchangerate AS total_revenue,
    CONCAT( c.givenname, ' ', c.surname) AS full_name,
    c.countryfull,
    p.productname,
    p.categoryname
FROM sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
LEFT JOIN product p ON s.productkey = p.productkey
WHERE orderdate >= '2020-01-01'
ORDER BY s.orderdate;



/* This query provides a summary of customer distribution by continent for 
orders placed between January 1, 2020, and the last order date available in the database. 
It counts the total number of unique customers as well as their distribution by continent.
*/
SELECT 
    s.orderdate,
    COUNT(DISTINCT c.customerkey) AS total_customer,
    COUNT(DISTINCT CASE WHEN c.continent = 'Europe' THEN c.customerkey END) AS eu_customer,
    COUNT(DISTINCT CASE WHEN c.continent = 'North America' THEN c.customerkey END) AS na_customer,
    COUNT(DISTINCT CASE WHEN c.continent = 'Australia' THEN c.customerkey END) AS au_customer
FROM sales s
INNER JOIN customer c ON s.customerkey = c.customerkey 
WHERE s.orderdate BETWEEN '2020-01-01' AND (SELECT MAX(orderdate) FROM sales)
GROUP BY s.orderdate
ORDER BY s.orderdate;



/*This query shows the net_revenue per month between 2020 and 2024*/
SELECT 
    EXTRACT (YEAR FROM orderdate) as extract_year,
    EXTRACT (MONTH FROM orderdate) as extract_month, 
    CAST(SUM (quantity * netprice * exchangerate) AS INTEGER) as net_revenue
FROM sales
WHERE EXTRACT (YEAR FROM orderdate) BETWEEN '2020' AND '2024'
GROUP BY extract_year, extract_month
ORDER BY extract_year, extract_month
;

--include the first chart in the dashboard


/* This query calculates the total revenue generated per product category for each
year from 2020 to 2024.
 */
SELECT 
    p.categoryname,
    CAST(SUM(CASE WHEN s.orderdate BETWEEN '2020-01-01' AND '2020-12-31' THEN
        s.quantity * s.netprice * s.exchangerate END) AS INTEGER) AS revenue_2020,
    CAST(SUM(CASE WHEN s.orderdate BETWEEN '2021-01-01' AND '2021-12-31' THEN
        s.quantity * s.netprice * s.exchangerate END) AS INTEGER) AS revenue_2021,
    CAST(SUM(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' THEN
        s.quantity * s.netprice * s.exchangerate END) AS INTEGER) AS revenue_2022,
    CAST(SUM(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' THEN
        s.quantity * s.netprice * s.exchangerate END) AS INTEGER) AS revenue_2023,
    CAST(SUM(CASE WHEN s.orderdate BETWEEN '2024-01-01' AND '2024-12-31' THEN
        s.quantity * s.netprice * s.exchangerate END) AS INTEGER) AS revenue_2024
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY p.categoryname;


/*This query calculates the median sales for each product category in the last 5 years*/
SELECT 
    categoryname,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (CASE WHEN orderdate BETWEEN '2020-01-01' AND
         '2020-12-31' THEN (quantity * netprice * exchangerate)END)) AS INTEGER) AS median_sales_2020,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (CASE WHEN orderdate BETWEEN '2021-01-01' AND
         '2021-12-31' THEN (quantity * netprice * exchangerate)END)) AS INTEGER) AS median_sales_2021,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (CASE WHEN orderdate BETWEEN '2022-01-01' AND
         '2022-12-31' THEN (quantity * netprice * exchangerate)END)) AS INTEGER) AS median_sales_2022,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (CASE WHEN orderdate BETWEEN '2023-01-01' AND
         '2023-12-31' THEN (quantity * netprice * exchangerate)END)) AS INTEGER) AS median_sales_2023,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (CASE WHEN orderdate BETWEEN '2024-01-01' AND
         '2024-12-31' THEN (quantity * netprice * exchangerate)END)) AS INTEGER) AS median_sales_2024
FROM 
    sales
LEFT JOIN product ON sales.productkey = product.productkey
GROUP BY categoryname;



/* This CTE calculates the 25th and 75th percentiles of revenue and identifies revenue tiers 
for each product category (HIGH > 75th percentile, LOW < 25th percentile, otherwise MEDIUM), 
to showcase on which products to we are relying.*/
WITH percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY (quantity * netprice * exchangerate)) AS revenue_25_percentile,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY (quantity * netprice * exchangerate)) AS revenue_75_percentile
    FROM sales s
    WHERE orderdate BETWEEN '2020-01-01' AND '2024-12-31'
)
SELECT
    p.categoryname AS category,
    CASE 
        WHEN (quantity * netprice * exchangerate) <= revenue_25_percentile THEN 'LOW'
        WHEN (quantity * netprice * exchangerate) >= revenue_75_percentile THEN 'HIGH'
        ELSE 'MEDIUM' 
    END AS revenue_tier,
    CAST(SUM(quantity * netprice * exchangerate) AS INTEGER) AS total_revenue
FROM sales s
LEFT JOIN product p 
    ON s.productkey = p.productkey
CROSS JOIN percentiles
GROUP BY p.categoryname,
         CASE 
            WHEN (quantity * netprice * exchangerate) <= revenue_25_percentile THEN 'LOW'
            WHEN (quantity * netprice * exchangerate) >= revenue_75_percentile THEN 'HIGH'
            ELSE 'MEDIUM' 
         END
ORDER BY p.categoryname;



/*This query calculates the average processing time using 
age function to extract the number of days between ordering and delivering*/
SELECT 
    EXTRACT (YEAR FROM orderdate) as order_year,
    ROUND(AVG(EXTRACT (DAYS FROM AGE (deliverydate, orderdate))),2) AS avg_processing_date,
    CAST (SUM (quantity * netprice * exchangerate) AS INTEGER) AS net_revenue
FROM sales
WHERE EXTRACT (YEAR FROM orderdate) BETWEEN '2020' AND '2024'
GROUP BY order_year
ORDER BY order_year;
