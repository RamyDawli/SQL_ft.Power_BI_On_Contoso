--Q1. List the top 10 customers by total sales amount. 
SELECT
    s.customerkey,
    CONCAT(c.givenname,' ', c.surname) AS FULL_NAME,
    CAST(SUM(s.quantity* s.netprice * s.exchangerate) AS INTEGER) AS total_spending

FROM 
    sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
GROUP BY s.customerkey, FULL_NAME
ORDER BY total_spending DESC
LIMIT 10;


--Q2. Show all products sold in 2015 with their total sales quantity.
SELECT 
    s.productkey,
    p.productname,
    SUM(s.quantity) AS total_quantity
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE orderdate BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY s.productkey, p.productname
ORDER BY total_quantity DESC


--Q3. Find the total revenue for each year.
SELECT 
    EXTRACT(YEAR FROM orderdate) as revenue_year,
    SUM(quantity * netprice * exchangerate) as total_revenue
FROM 
    sales
GROUP BY revenue_year
LIMIT 10;


--Q4. Find the top 5 products with the highest revenue in 2018.
SELECT 
    s.productkey,
    p.productname,
    CAST(SUM(quantity * exchangerate * netprice) AS INTEGER) AS total_revenue
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE s.orderdate BETWEEN '2018-01-01' AND '2018-12-31'
GROUP BY s.productkey, p.productname
ORDER BY total_revenue DESC
LIMIT 5;


--Q5. Show the monthly sales trend for the year 2019.
SELECT 
    EXTRACT (MONTH FROM orderdate) as revenue_month,
    CAST(SUM(quantity * exchangerate * netprice) AS INTEGER) AS total_revenue
FROM sales
WHERE orderdate BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY revenue_month
ORDER BY revenue_month; 


--Q6. List the top 3 stores by sales in each country.
WITH store_revenue AS (
    SELECT 
    s.storekey,
    st.DESCRIPTION,
    st.countryname,
    CAST(SUM(quantity * exchangerate * netprice) AS INTEGER) AS total_revenue,
    ROW_NUMBER()OVER(PARTITION BY st.countryname ORDER BY
    CAST(SUM(quantity * exchangerate * netprice) AS INTEGER) DESC) as ranking
FROM sales s
LEFT JOIN store st ON s.storekey = st.storekey
GROUP BY s.storekey,st.DESCRIPTION, st.countryname  
)

SELECT 
    sr.storekey,
    sr.DESCRIPTION,
    sr.countryname,
    sr.total_revenue
FROM store_revenue sr
WHERE ranking<=3;


--Q7. Find the customer segment with the highest average order value.
WITH order_revenue AS (
SELECT
    orderkey,
    customerkey,
    SUM(quantity * exchangerate * netprice) as revenue
FROM sales 
GROUP BY orderkey, customerkey
LIMIT 10
), 
customer_segmentation as (
    SELECT 
    order_revenue.*,
    CASE 
        WHEN customer.age BETWEEN '20' AND '35' THEN 'Young customers' 
        WHEN customer.age BETWEEN '35' AND '55' THEN 'Middle age customer'
        WHEN customer.age > '55' THEN 'Old customer'
        ELSE 'Teenagers'
    END AS customer_seg 
FROM
    order_revenue
LEFT JOIN customer ON order_revenue.customerkey = customer.customerkey   
)

SELECT 
    customer_seg,
    AVG(revenue)

FROM customer_segmentation
GROUP BY customer_seg;



--Q8. For each store, compute the percentage of sales coming from the top-selling product.
WITH product_rev_rank AS (SELECT
    s.storekey,
    st.DESCRIPTION,
    s.productkey,
    SUM(s.quantity*s.netprice*s.exchangerate) as product_revenue,
    ROW_NUMBER() OVER 
                (PARTITION BY s.storekey 
                ORDER BY SUM(s.quantity*s.netprice*s.exchangerate) DESC) as ranking 
FROM sales s
LEFT JOIN store st ON s.storekey= st.storekey
GROUP BY s.storekey,st.DESCRIPTION, s.productkey
), store_revenue AS (SELECT
    prr.storekey,
    SUM(prr.product_revenue) as revenue
FROM product_rev_rank as prr
GROUP BY prr.storekey)

SELECT
    prr.storekey,
    prr.DESCRIPTION,
    sr.revenue as Total_revenue,
    prr.product_revenue as TOP_Selling_Product,
    prr.product_revenue * 100 / sr.revenue as percent_of_total_revenue
FROM store_revenue sr
LEFT JOIN product_rev_rank prr ON sr.storekey = prr.storekey
WHERE prr.ranking = 1 ;



--Q9. For each country, find the product category with the highest revenue.
WITH revenue_by_cate_and_cont AS (
    SELECT
    SUM(s.quantity * s.netprice * s.exchangerate) as total_revenue,
    st.countryname,
    p.categoryname,
    ROW_NUMBER()OVER(PARTITION BY st.countryname ORDER BY SUM(s.quantity * s.netprice * s.exchangerate) DESC) as ranking
FROM sales s
LEFT JOIN store st ON s.storekey = st.storekey
LEFT JOIN product p ON s.productkey = p.productkey  
GROUP BY st.countryname, p.categoryname
)

SELECT 
    rbcc.countryname,
    rbcc.categoryname,
    CAST(rbcc.total_revenue AS INTEGER) as total_revenue
 FROM revenue_by_cate_and_cont rbcc
WHERE rbcc.ranking = 1;


--Q10. Find the top 10 customers who bought the widest variety of products.
SELECT 
    s.customerkey,
    CONCAT(c.givenname, ' ',c.surname),
    COUNT(DISTINCT p.categoryname) as varitey_count
FROM sales s 
LEFT JOIN customer c ON s.customerkey = c.customerkey
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY CONCAT(c.givenname, ' ',c.surname),s.customerkey
ORDER BY varitey_count DESC
LIMIT 10;


--Q11. Find top 3 macufacturers with the most products in the top 100 revenue-generating items
WITH pro_manu_rev AS (
SELECT 
        s.productkey,
        p.productname,
        p.manufacturer,
        SUM(s.quantity * s.netprice * s.exchangerate) AS revenue
    FROM sales s
    LEFT JOIN product p ON s.productkey = p.productkey
    GROUP BY s.productkey, p.productname, p.manufacturer
    ORDER BY revenue DESC
    LIMIT 100
)
SELECT 
    prm.manufacturer,
    CAST (SUM(prm.revenue) AS INTEGER) AS revenue_in_top_100,
    COUNT(*) AS num_of_product_in_top_100
FROM pro_manu_rev prm
GROUP BY prm.manufacturer
ORDER BY num_of_product_in_top_100 DESC 
LIMIT 3;

--Q12. Identify the customers who bought products from at least 3 different categories in 2015.
WITH orders AS (
    SELECT 
    p.categoryname,
    s.customerkey,
    CONCAT(c.givenname,' ',c.surname) as full_name
FROM sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey 
LEFT JOIN product p ON s.productkey = p.productkey
WHERE s.orderdate BETWEEN '2015-01-01' AND '2015-12-31'
), count_category AS (
SELECT 
    o.full_name,
    COUNT(DISTINCT o.categoryname) as cnt    
FROM orders o
GROUP BY o.full_name
)
SELECT * FROM count_category
WHERE count_category.cnt >= 3
ORDER BY count_category.cnt;


