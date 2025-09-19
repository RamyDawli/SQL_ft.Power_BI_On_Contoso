# 📊 Revenue & Customer Analysis Project

## 📌 Project Overview

This is a **hobby project** to deepen my SQL skills, ft. Power BI. In this project, I explore the microsoft dataset **Contoso** to analyze sales revenue, customer behavior, and product performance.

**Key objectives:**

- 💰 Analyze revenue trends and product performance
- 👥 Segment customers and calculate lifetime value (LTV)
- 📊 Practice advanced SQL (cohorts, percentiles, window functions)
- 🛠️ Enhance SQL proficiency with joins, CTEs, and date-based calculations

## 📁 Project Structure

| File                               | Description                                                    |
| ---------------------------------- | -------------------------------------------------------------- |
| `_1_EDA_Contoso.sql`                  | Exploratory queries on Contoso dataset indluding (customer, stores, products, categories)|
| `_2_Revenue_Performance_Analysis.sql` | Revenue trends, product performance, and sales metrics         |
| `_3_Customer_Analysis.sql`            | Customer behavior, retention, lifetime value, and segmentation |

---

## 📏 Key Metrics Calculated

- Total revenue by order, product, and category 💰
- Monthly net revenue trends 📅
- Median sales per product category 📊
- Revenue tiers per product category 🔝
- Average processing time between order and delivery ⏱️
- Cohort-based customer revenue tracking 📆
- Customer lifetime value (LTV) 💎
- Customer segmentation (LOW, MID, HIGH value) 🏷️
- Active vs churned customer identification 🔄

## 📈 Key Insights

**Monthly Revenue Trends (2020–2024):**

![Revenue_yearly](/Images/Revenue.png)

- Sales in general tends to dip around **March** and **April**.

**Revenue Distribution By product Category:**

![Revenue_distribution](/Images/revenue_by_category.png)

- This visualization shows how product categories contribute to overall revenue. Categories like **Computers, TV and Video, and Cameras** are dominated by **high-revenue transactions**, making them core drivers of sales, while ategories like **Games and Toys** or **Audio** rely more on **low and medium-tier sales**, suggesting lower revenue concentration but possibly higher transaction volumes.

**Cohort Impact on Future Years Total Revenue**

![Cohort_Year_Impact](/Images/Cohort_year_revenue.png)

- Shows the impact of each cohort year (eg. the year a customer made their first purchase) on total revenue of future years. This shows bad retention of customers as the previous years cohorts are not contributing much to the revenue of future years.  

**Customer Segmentation: Total Life Time Value:**

![Customer_segmentation](/Images/customer_segmentation.png)

- Shows that the sales are relying mostly on high value customers, customer that spend the most

**Active customers in the last 6 months:**

![Customer_status](/Images/customer_activation.png)

- Shows the percentage of active customer while **excluding new customers** from the last 6 months to avoid inflating activity rates. This helps distinguish truly active customers from recent first-time buyers.

## 🧑‍💻 Skills Showcased

Through this project, I was able to practice and demonstrate a wide range of SQL and data analysis skills, including:

- **Data Extraction & Transformation** 🔍

  - Writing complex `SELECT` statements with joins across multiple tables (`sales`, `customer`, `product`).
  - Applying filters, aggregations, and calculations to derive business metrics.

- **Analytical SQL Techniques** 📊

  - Using **window functions** (`OVER`, `PARTITION BY`, `PERCENTILE_CONT`) for cohort analysis, lifetime value (LTV), and median/percentile calculations.
  - Creating **CTEs** (Common Table Expressions) to structure multi-step queries for readability and reusability.
  - Performing **date-based calculations** (extracting year/month, using `AGE`, handling intervals).

- **Segmentation & Distribution Analysis** 🏷️

  - Customer segmentation based on lifetime value (low, mid, high tiers).
  - Revenue segmentation by category and revenue tier (LOW, MEDIUM, HIGH).
  - Active vs churned customer classification with conditional logic.

- **Business-Oriented Insights** 💡

  - Identifying revenue concentration in high-value customers.
  - Analyzing seasonal sales dips and trends across months/years.
  - Understanding customer retention through cohort and activity analysis.

- **Data Visualization Integration** 📈
  - Designing and embedding visuals (bar charts, revenue trends, segmentation distributions) to communicate findings effectively.
  - Connecting SQL query outputs to visualization tools Power BI.
